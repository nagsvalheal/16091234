/**
* @description  This class is used to create tasks when a video is uploaded.
* It also handles calling methods to send SMS and email notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_TreatmentNotificationCtrl {
    /**
     * @description Processes treatment reminders, creating tasks based on
     *              uploaded videos and sending SMS and email notifications.
     */
    public static void processReminders() {
        try {
            Date today = Date.today();
            List<BI_PSPB_Treatment_Reminder__c> reminders = BI_PSPB_ActiveTreatmentCtrl.getActiveReminders(today);

            if (reminders.isEmpty()) {
                logError(BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound);
            } else {
                processRemindersList(reminders, today);
            }
        } catch (Exception ex) {
            logError(ex.getMessage());
        }
    }

    // Separate the main processing logic for reminders
    private static void processRemindersList(List<BI_PSPB_Treatment_Reminder__c> reminders, Date today) {
        BI_PSPB_TreatmentReminderDaysCtrl daysCount = new BI_PSPB_TreatmentReminderDaysCtrl();
        List<Task> newTaskList = new List<Task>();
        Map<String, Id> createdTaskIdentifiers = new Map<String, Id>();

        for (BI_PSPB_Treatment_Reminder__c reminder : reminders) {
            processSingleReminder(reminder, today, daysCount, newTaskList, createdTaskIdentifiers);
        }

        if (!newTaskList.isEmpty()) {
            BI_PSP_DatabaseOperationsUtility.insertOperation(
                newTaskList,
                BI_PSPB_TreatmentNotificationCtrl.class.toString(),
                false
            );
        }

        BI_PSPB_SendTreatmentNotificationCtrl.sendNotifications(reminders, daysCount);
    }

    // Handle processing of a single reminder
    private static void processSingleReminder(
        BI_PSPB_Treatment_Reminder__c reminder,
        Date today,
        BI_PSPB_TreatmentReminderDaysCtrl daysCount,
        List<Task> newTaskList,
        Map<String, Id> createdTaskIdentifiers
    ) {
        Integer age = BI_PSPB_SmsEmailSenderCtrl.calculateAge(
            reminder.BI_PSPB_Care_Program_Enrollee__r.Account.BI_PSP_Birthdate__c,
            today
        );
        Id enrolleeId = reminder.BI_PSPB_Care_Program_Enrollee__c;
        Id caregiverId = BI_PSPB_SmsEmailSenderCtrl.fetchCaregiverId(enrolleeId);
        Integer daysDifference = reminder.BI_PSPB_Reminder_Date__c.daysBetween(reminder.BI_PSPB_Date_of_Treatment__c);
        String taskIdentifier = reminder.Id + '-' + daysDifference;

        BI_PSPB_ReminderTaskContext context = new BI_PSPB_ReminderTaskContext(reminder, age, caregiverId, daysDifference, daysCount, taskIdentifier);
        createTasksForReminder(context, newTaskList, createdTaskIdentifiers);
    }

    // Create tasks based on the ReminderTaskContext
    private static void createTasksForReminder(
        BI_PSPB_ReminderTaskContext context,
        List<Task> newTaskList,
        Map<String, Id> createdTaskIdentifiers
    ) {
        // Create enrollee task if eligible
        if (shouldCreatePatientTask(context, createdTaskIdentifiers)) {
            Task enrolleeTask = BI_PSPB_TreatmentTaskCreateCtrl.createPatientTask(
                context.reminder, 
                context.daysDifference, 
                context.daysCount, 
                'Patient'
            );
            addTaskToList(enrolleeTask, newTaskList, createdTaskIdentifiers, context.taskIdentifier + '-Patient');
        }

        // Create caregiver task if eligible
        if (shouldCreateCaregiverTask(context.caregiverId, context.taskIdentifier, createdTaskIdentifiers)) {
            Task caregiverTask = BI_PSPB_TreatmentTaskCreateCtrl.createCaregiverTask(
                context.reminder, 
                context.daysDifference, 
                context.daysCount, 
                'Caregiver'
            );
            addTaskToList(caregiverTask, newTaskList, createdTaskIdentifiers, context.taskIdentifier + '-Caregiver');
        }
    }

    // Check conditions for creating patient task
    private static Boolean shouldCreatePatientTask(BI_PSPB_ReminderTaskContext context, Map<String, Id> createdTaskIdentifiers) {
        return !createdTaskIdentifiers.containsKey(context.taskIdentifier + '-Patient') && (context.age > 18 || context.caregiverId == null);
    }

    // Check conditions for creating caregiver task
    private static Boolean shouldCreateCaregiverTask(Id caregiverId, String taskIdentifier, Map<String, Id> createdTaskIdentifiers) {
        return caregiverId != null && !createdTaskIdentifiers.containsKey(taskIdentifier + '-Caregiver');
    }

    // Add task to the list and update identifier map
    private static void addTaskToList(Task task, List<Task> taskList, Map<String, Id> createdTaskIdentifiers, String identifier) {
        if (task != null) {
            taskList.add(task);
            createdTaskIdentifiers.put(identifier, task.Id);
        }
    }

    // Log errors
    private static void logError(String errorMessage) {
        BI_PSP_LogMessagesUtility.logError(
            errorMessage,
            BI_PSPB_TreatmentNotificationCtrl.class.toString(),
            true,
            BI_PSPB_NotificationConstantsCtrl.severityError
        );
    }
}