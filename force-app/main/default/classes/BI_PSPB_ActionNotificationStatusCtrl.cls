/**
* @description  This class is responsible for creating tasks when a video is 
*              uploaded and for triggering the sending of SMS and email 
*              notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public without sharing class BI_PSPB_ActionNotificationStatusCtrl {
/**
 * @description  Used to create a task when a video is uploaded and calling the
 * method to send SMS and email.
 * @param recordId The ID of the record associated with the video.
 * @param actionValue The action value indicating the type of action to perform.
 * @throws SomeException Description of when an exception might be thrown.
 * @history
 */
@AuraEnabled(cacheable=false)
public static void updateActionTreatmentStatus(
String recordId,
String actionValue
) {
try {
	if (String.isBlank(recordId) || String.isBlank(actionValue)) {
		logErrorRecordNotFound();
		return;
	}

	Task taskObj = BI_PSPB_ActionTaskService.getTask(recordId);
	if (taskObj == null) {
		logErrorRecordNotFound();
		return;
	}
	String whatId = taskObj.WhatId;
    String status = taskObj.Status;
    String category = taskObj.BI_PSP_Category__c;
    String treatmentType = taskObj.BI_PSPB_Treatment_Type__c;
    String notificationType = taskObj.BI_PSP_Notification_Type__c;
	String fieldsOfRelatedTasks =
			'Id, WhatId, ' +
			'Status, BI_PSP_Category__c, ' +
			'Subject, BI_PSPB_Treatment_Type__c, BI_PSP_Notification_Type__c';
    String conditionsOfRelatedTasks = 'WhatId = \'' + whatId + '\' ' +
				'AND Status = \'' + status + '\' ' +
				'AND BI_PSP_Category__c = \'' + category + '\' ' +
        		'AND BI_PSP_Notification_Type__c = \'' + notificationType + '\' ';
    if (treatmentType != null) {
   		conditionsOfRelatedTasks += 'AND BI_PSPB_Treatment_Type__c = \'' + treatmentType + '\' ';
	}
    List<Task> relatedTasks = BI_PSP_CommonQueryUtility.executeQuery(
			'Task',
			fieldsOfRelatedTasks,
			conditionsOfRelatedTasks,
			false
		);
    List<Id> taskIds = new List<Id>();
    List<Id> whatIds = new List<Id>();
    for (Task t : relatedTasks) {
    	taskIds.add(t.Id);
        whatIds.add(t.whatId);
	}
	List<BI_PSPB_Treatment_Reminder__c> treatmentReminderRecs = BI_PSPB_ActionService.getTreatmentReminders(
		whatIds,BI_PSPB_NotificationConstantsCtrl.actionTypePrescription
	);
	updateTaskAndReminders(relatedTasks, treatmentReminderRecs, actionValue);
} catch (Exception ex) {
	logException(ex);
}
}
/**
 * @description  Used to create a task when a video is uploaded and calling the
 * method to send SMS and email.
 * @param recordId The ID of the record associated with the video.
 * @param actionValue The action value indicating the type of action to perform.
 * @throws SomeException Description of when an exception might be thrown.
 * @history
 */
@AuraEnabled(cacheable=false)
public static void updateActionDateOfTreatment(
String recordId,
String actionValue
) {
try {
	if (String.isBlank(recordId) || String.isBlank(actionValue)) {
		logErrorRecordNotFound();
		return;
	}

	Task taskObj = BI_PSPB_ActionTaskService.getTask(recordId);
    if (taskObj == null) {
		logErrorRecordNotFound();
		return;
	}
    String whatId = taskObj.WhatId;
    String status = taskObj.Status;
    String category = taskObj.BI_PSP_Category__c;
    String treatmentType = taskObj.BI_PSPB_Treatment_Type__c;
    String notificationType = taskObj.BI_PSP_Notification_Type__c;
	String fieldsOfRelatedTasks =
			'Id, WhatId, ' +
			'Status, BI_PSP_Category__c, ' +
			'Subject, BI_PSPB_Treatment_Type__c, BI_PSP_Notification_Type__c';
    String conditionsOfRelatedTasks = 'WhatId = \'' + whatId + '\' ' +
				'AND Status = \'' + status + '\' ' +
				'AND BI_PSP_Category__c = \'' + category + '\' ' +
        		'AND BI_PSP_Notification_Type__c = \'' + notificationType + '\' ';
    if (treatmentType != null) {
   		conditionsOfRelatedTasks += 'AND BI_PSPB_Treatment_Type__c = \'' + treatmentType + '\' ';
	}
    List<Task> relatedTasks = BI_PSP_CommonQueryUtility.executeQuery(
			'Task',
			fieldsOfRelatedTasks,
			conditionsOfRelatedTasks,
			false
		);
    List<Id> taskIds = new List<Id>();
    List<Id> whatIds = new List<Id>();
    for (Task t : relatedTasks) {
    	taskIds.add(t.Id);
        whatIds.add(t.whatId);
	}
	List<BI_PSPB_Treatment_Reminder__c> dateOfTreatmentRec = BI_PSPB_ActionService.getDateOfTreatmentReminder(
		whatIds,
		BI_PSPB_NotificationConstantsCtrl.dateOfTreatment
	);
	updateTaskAndReminder(relatedTasks, dateOfTreatmentRec, actionValue);
} catch (Exception ex) {
	logException(ex);
}
}
/**
 * @description  Used to create a task when a video is uploaded and calling the
 * method to send SMS and email.
 * @param taskObj The ID of the record associated with the video.
 * @param reminders The action value indicating the type of action to perform.
 * @param actionValue The action value indicating the type of action to perform.
 * @history
 */
private static void updateTaskAndReminders(
List<Task> taskObj,
List<BI_PSPB_Treatment_Reminder__c> reminders,
String actionValue
) {
try {
    List<Task> listOfTasks = new List<Task>();
	if (
		actionValue.equals(
			BI_PSPB_NotificationConstantsCtrl.actionResponseYes
		)
	) {
    for (Task t : taskObj) {
    	t.Status = BI_PSPB_NotificationConstantsCtrl.notificationStatusComplete;
        listOfTasks.add(t);
	}
        List<BI_PSPB_Treatment_Reminder__c> reminderLists = new List<BI_PSPB_Treatment_Reminder__c>();
		for (BI_PSPB_Treatment_Reminder__c reminder : reminders) {
			reminder.BI_PSPB_Status__c = BI_PSPB_NotificationConstantsCtrl.progress;
            reminderLists.add(reminder);
		}
        updateReminder(reminderLists);
	} else if (
		actionValue.equals(
			BI_PSPB_NotificationConstantsCtrl.actionResponseNo
		)
	) {
        for (Task t : taskObj) {
    	t.Status = BI_PSPB_NotificationConstantsCtrl.notificationStatusNotComplete;
		listOfTasks.add(t);
	}
	}

	updateTask(listOfTasks);
} catch (Exception ex) {
	logException(ex);
}
}
/**
 * @description  Updates a task and reminder based on the action value.
 * @param taskObj The Task object that will be updated.
 * @param reminder The reminder object that will be updated.
 * @param actionValue The action value indicating the type of action to perform.
 */
private static void updateTaskAndReminder(
List<Task> taskObj,
List<BI_PSPB_Treatment_Reminder__c> reminder,
String actionValue
) {
try {
    List<Task> listOfTasks =  new List<Task>();
	if (
		actionValue.equals(
			BI_PSPB_NotificationConstantsCtrl.actionResponseYes
		)
	) {
        for (Task t : taskObj) {
    	t.Status = BI_PSPB_NotificationConstantsCtrl.notificationStatusComplete;
		listOfTasks.add(t);
	}
        List<BI_PSPB_Treatment_Reminder__c> reminderLists = new List<BI_PSPB_Treatment_Reminder__c>();
        for (BI_PSPB_Treatment_Reminder__c reminders : reminder) {
        reminders.BI_PSPB_Status__c = BI_PSPB_NotificationConstantsCtrl.progress;
            reminderLists.add(reminders);
        }
		updateReminder(reminderLists);
	} else if (
		actionValue.equals(
			BI_PSPB_NotificationConstantsCtrl.actionResponseNo
		)
	) {
        for (Task t : taskObj) {
    	t.Status = BI_PSPB_NotificationConstantsCtrl.notificationStatusNotComplete;
		listOfTasks.add(t);
	}
	}

	updateTask(listOfTasks);
} catch (Exception ex) {
	logException(ex);
}
}
/**
 * @description  Used to create a task when a video is uploaded and calling the
 * method to send SMS and email.
 * @param taskObj The ID of the record associated with the video.
 * @history
 */
private static void updateTask(List<Task> taskObj) {
if (!taskObj.isEmpty()) {
	BI_PSP_DatabaseOperationsUtility.updateOperation(
		taskObj,
		BI_PSPB_ActionNotificationStatusCtrl.class.toString(),
		false
	);
}
}
/**
 * @description  Updates a task and reminder based on the action value.
 * @param reminder The reminder object that will be updated.
 */
private static void updateReminder(List<BI_PSPB_Treatment_Reminder__c> reminder) {
if (!reminder.isEmpty()) {
	BI_PSP_DatabaseOperationsUtility.updateOperation(
		reminder,
		BI_PSPB_ActionNotificationStatusCtrl.class.toString(),
		false
	);
}
}
/**
 * @description  Used to create task when a video is uploaded and calling the
 * method to send sms and email.
 */
private static void logErrorRecordNotFound() {
BI_PSP_LogMessagesUtility.logError(
	BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
	BI_PSPB_ActionNotificationStatusCtrl.class.toString(),
	true,
	BI_PSPB_NotificationConstantsCtrl.severityError
);
}
/**
 * @description  Logs an exception using the BI_PSP_LogMessagesUtility.
 * @param ex The exception object that needs to be logged.
 */
private static void logException(Exception ex) {
BI_PSP_LogMessagesUtility.exceptionLogMessage(
	ex.getMessage(),
	BI_PSPB_ActionNotificationStatusCtrl.class.toString(),
	ex
);
}
}