/**
* @description  This class is used to create tasks when a video is uploaded.
* It also handles calling methods to send SMS and email notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_TaskCreationCtrl {
/**
* @description Creates a list of Task records based on provided enrollees
* and task parameters.
* @param enrollees List of Careprogram enrollees.
* @param taskParams Object containing task parameters.
* @return Returning list of tasks that are to be inserted.
*/
public static List<Task> createTasks(List<Id> enrollees, BI_PSPB_TaskParameters taskParams) {
	List<Task> tasks = new List<Task>();
	try {
		for (Id enrollee : enrollees) {
			Task task = new Task();
			task.Subject = taskParams.subject;
			task.BI_PSP_Notification_Type__c = taskParams.notificationType;
			task.BI_PSP_Category__c = taskParams.category;
			task.BI_PSPB_Treatment_Type__c = taskParams.treatmentType;
			task.Status = taskParams.status;
			task.WhatId = enrollee;
			tasks.add(task);
		}
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(), BI_PSPB_TaskCreationCtrl.class.getName(), ex
		);
	}
	return tasks;
}
}