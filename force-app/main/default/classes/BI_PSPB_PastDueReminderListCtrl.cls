/**
 * @description Handles the creation of tasks when a video is uploaded and sends SMS
 * and email notifications. This class processes reminders and manages
 * associated tasks and notifications..
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_PastDueReminderListCtrl {
	/**
	 * @description  Processes a list of treatment reminders by handling each reminder
	 *                based on the specified target date and processing context. This method
	 *                performs the necessary actions for reminders that match the target date
	 *                and context criteria.
	 * @param reminders A list of BI_PSPB_Treatment_Reminder__c records representing the treatment reminders
	 *                  that need to be processed.
	 * @param targetDate The target date used to filter and process the reminders that are due.
	 * @param context An instance of BI_PSPB_PastDueNotificationCtrl.ReminderProcessingContext
	 *                that provides the context for processing the reminders, including any
	 *                specific rules or parameters for handling them.
	 */
	public static void processReminderList(
		List<BI_PSPB_Treatment_Reminder__c> reminders,
		Date targetDate,
		BI_PSPB_PastDueNotificationCtrl.ReminderProcessingContext context
	) {
		Date today = Date.today();
		for (BI_PSPB_Treatment_Reminder__c reminder : reminders) {
			processSingleReminder(reminder, targetDate, today, context);
		}
	}
    /**
 	 * @description  Processes a single treatment reminder by evaluating its relevance to the target 
 	 *                date and the current date, and applying the rules defined in the processing context. 
 *                This method handles the specific logic for managing one reminder based on its 
 *                due status and other parameters.
 * @param reminder A BI_PSPB_Treatment_Reminder__c record representing the treatment reminder 
 *                 to be processed.
 * @param targetDate The target date against which the reminder's due status is evaluated.
 * @param today The current date, used for comparison to determine if the reminder is past due 
 *              or requires immediate action.
 * @param context An instance of BI_PSPB_PastDueNotificationCtrl.ReminderProcessingContext 
 *                providing the context and rules for processing the reminder, such as 
 *                notification settings or task creation criteria.
 */
	private static void processSingleReminder(
		BI_PSPB_Treatment_Reminder__c reminder,
		Date targetDate,
		Date today,
		BI_PSPB_PastDueNotificationCtrl.ReminderProcessingContext context
	) {
		Datetime treatmentDate = reminder.BI_PSPB_Date_of_Treatment__c;
		context.treatmentDate = treatmentDate.format('MM/dd/yyyy');
		String patientName = reminder.BI_PSPB_Care_Program_Enrollee__r.Account.Name;
		Integer age = BI_PSPB_SmsEmailSenderCtrl.calculateAge(
			reminder.BI_PSPB_Care_Program_Enrollee__r.Account.BI_PSP_Birthdate__c,
			today
		);
		Id enrolleeId = reminder.BI_PSPB_Care_Program_Enrollee__c;
		Id caregiverId = BI_PSPB_SmsEmailSenderCtrl.fetchCaregiverId(
			enrolleeId
		);
		BI_PSPB_TaskCreationParams params = new BI_PSPB_TaskCreationParams(
			reminder,
			context.pastDueDays
		);

		BI_PSPB_TaskCreationContextCtrl taskContext = new BI_PSPB_TaskCreationContextCtrl(
			targetDate,
			context,
			params,
			caregiverId,
			patientName,
			age
		);

		if (age > 18) {
			createPatientTaskIfEligible(taskContext);
		}
		createCaregiverTaskIfEligible(taskContext);
	}
/**
 * @description  Creates a task for a patient if the patient meets the eligibility criteria 
 *                defined in the task creation context. This method checks conditions such as 
 *                the patient's age, caregiver status, and other relevant factors to determine 
 *                whether a task should be created.
 * @param taskContext An instance of BI_PSPB_TaskCreationContextCtrl that contains the 
 *                    necessary context for task creation, including details about the 
 *                    target date, processing context, task parameters, caregiver, patient name, 
 *                    and age. This context is used to evaluate the patient's eligibility for the task.
 */
	private static void createPatientTaskIfEligible(
		BI_PSPB_TaskCreationContextCtrl taskContext
	) {
        BI_PSPB_TreatmentPatientTaskCtrl patientParams = new BI_PSPB_TreatmentPatientTaskCtrl(
            taskContext.context.enrolleeRecIds,
			taskContext.context.enrolleePastOne,
			taskContext.context.enrolleePastThree,
			'Patient',
			taskContext.caregiverId
            );
		Task newTask = BI_PSPB_PastDueTaskSubjectCtrl.createPatientTask(
			taskContext.targetDate,
			taskContext.params,
            patientParams
		);

		if (newTask != null) {
			taskContext.context.newTaskList.add(newTask);
		}
	}
    /**
 * @description  Creates a task for a caregiver if the caregiver meets the eligibility criteria 
 *                specified in the task creation context. This method checks relevant conditions, 
 *                such as the caregiver's association with the patient, target date, and other 
 *                parameters to decide if a task should be created for the caregiver.
 * @param taskContext An instance of BI_PSPB_TaskCreationContextCtrl that includes the 
 *                    context for task creation, containing details like the target date, 
 *                    reminder processing context, task parameters, caregiver ID, patient name, 
 *                    and age. This context is used to assess the caregiver's eligibility for the task.
 */
	private static void createCaregiverTaskIfEligible(
		BI_PSPB_TaskCreationContextCtrl taskContext
	) {
		if (taskContext.age <= 18 || taskContext.caregiverId != null) {
            
            BI_PSPB_TreatmentCaregiverTaskCtrl patientParams = new BI_PSPB_TreatmentCaregiverTaskCtrl(  
				taskContext.context.enrolleeRecIds,
				taskContext.context.enrolleePastOne,
				taskContext.context.enrolleePastThree,
				'Caregiver',
				taskContext.caregiverId
                );
			Task newTask = BI_PSPB_PastDueTaskSubjectCtrl.createCaregiverTask(
				taskContext.targetDate,
				taskContext.params,
				taskContext.patientName,
                patientParams
			);

			if (newTask != null) {
				taskContext.context.newTaskList.add(newTask);
			}
		}
	}
}