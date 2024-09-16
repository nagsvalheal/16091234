/**
 * @description Handles the creation of tasks when a video is uploaded and sends SMS
 * and email notifications. This class processes reminders and manages
 * associated tasks and notifications..
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_PastDueTaskSubjectCtrl {
	/**
	 * @description Handles the insertion of newly created tasks into the database.
	 * @param newTaskList The ID of the record related to the treatment reminders.
	 */
	public static void handleTasks(List<Task> newTaskList) {
		try {
			// Null check for the newTaskList parameter
			if (newTaskList.isEmpty()) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_PastDueTaskSubjectCtrl.class.toString(),
					false,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
				return;
			}
			BI_PSP_DatabaseOperationsUtility.insertOperation(
				newTaskList,
				BI_PSPB_PastDueNotificationCtrl.class.toString(),
				false
			);
		} catch (System.DmlException ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_PastDueNotificationCtrl.class.getName(),
				ex
			);
		}
	}
	public static Task createPatientTask(
		Date targetDate,
		BI_PSPB_TaskCreationParams params,
        BI_PSPB_TreatmentPatientTaskCtrl taskPatientParams
	) {
		List<Task> tasks = new List<Task>();
		try {
			Integer daysDifference = targetDate.daysBetween(Date.today());
			String subject;
			String category = BI_PSPB_NotificationConstantsCtrl.statusDateOfTreatment;
			String treatmentType;
			String formattedDate;
			Datetime treatmentDate;

			if (daysDifference == 0) {
				taskPatientParams.enrolleeRecIds.add(
					params.reminder.BI_PSPB_Care_Program_Enrollee__c
				);
				subject = BI_PSPB_NotificationConstantsCtrl.actionTreatmentDate;
				treatmentType = BI_PSPB_NotificationConstantsCtrl.dayOfTreatment;
			} else if (daysDifference == params.pastDueDays.pastdue24hrCount) {
				taskPatientParams.enrolleePastOne.add(
					params.reminder.BI_PSPB_Care_Program_Enrollee__c
				);
				subject = BI_PSPB_NotificationConstantsCtrl.actionTreatmentDueTwentyFour;
				treatmentType = BI_PSPB_NotificationConstantsCtrl.pastDueDate;
			} else if (daysDifference == params.pastDueDays.pastdue72hrCount) {
				treatmentDate = params.reminder.BI_PSPB_Date_of_Treatment__c;
				formattedDate = treatmentDate.format('MM/dd/yyyy');
				taskPatientParams.enrolleePastThree.add(
					params.reminder.BI_PSPB_Care_Program_Enrollee__c
				);
				subject =
					BI_PSPB_NotificationConstantsCtrl.actionTreatmentDueSeventyTwo +
					' ' +
					formattedDate +
					' ' +
					BI_PSPB_NotificationConstantsCtrl.pastTwentySubject;
				treatmentType = BI_PSPB_NotificationConstantsCtrl.pastDueDateTwo;
			} else {
				return null;
			}

			BI_PSPB_TaskParameters taskParams = new BI_PSPB_TaskParameters(
				subject,
				BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
				category,
				treatmentType,
				BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
			);

			tasks = createTasks(
				new List<Id>{ params.reminder.Id },
				taskParams,
				taskPatientParams.userType,
				taskPatientParams.caregiverId
			);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_PastDueNotificationCtrl.class.getName(),
				ex
			);
		}
		// Return the first task from the list or null if the list is empty
		return tasks.isEmpty() ? null : tasks[0];
	}
	public static Task createCaregiverTask(
		Date targetDate,
		BI_PSPB_TaskCreationParams params,
		String patientName,
        BI_PSPB_TreatmentCaregiverTaskCtrl caregiverTaskParams
	) {
		List<Task> tasks = new List<Task>();
		try {
			Integer daysDifference = targetDate.daysBetween(Date.today());
			String subject;
			String category = BI_PSPB_NotificationConstantsCtrl.statusDateOfTreatment;
			String treatmentType;
			String formattedDate;
			Datetime treatmentDate;

			if (daysDifference == 0) {
				caregiverTaskParams.enrolleeRecIds.add(
					params.reminder.BI_PSPB_Care_Program_Enrollee__c
				);
				subject =
					BI_PSPB_NotificationConstantsCtrl.dateTreatCaregiverOne +
					' ' +
					patientName +
					' ' +
					BI_PSPB_NotificationConstantsCtrl.dateTreatCaregiverTwo;
				treatmentType = BI_PSPB_NotificationConstantsCtrl.dayOfTreatment;
			} else if (daysDifference == params.pastDueDays.pastdue24hrCount) {
				caregiverTaskParams.enrolleePastOne.add(
					params.reminder.BI_PSPB_Care_Program_Enrollee__c
				);
				subject =
					BI_PSPB_NotificationConstantsCtrl.twentyFourCaregiverOne +
					' ' +
					patientName +
					' ' +
					BI_PSPB_NotificationConstantsCtrl.twentyFourCaregiverTwo;
				treatmentType = BI_PSPB_NotificationConstantsCtrl.pastDueDate;
			} else if (daysDifference == params.pastDueDays.pastdue72hrCount) {
				treatmentDate = params.reminder.BI_PSPB_Date_of_Treatment__c;
				formattedDate = treatmentDate.format('MM/dd/yyyy');
				caregiverTaskParams.enrolleePastThree.add(
					params.reminder.BI_PSPB_Care_Program_Enrollee__c
				);
				subject =
					BI_PSPB_NotificationConstantsCtrl.twentyFourCaregiverOne +
					' ' +
					patientName +
					' ' +
					BI_PSPB_NotificationConstantsCtrl.seventyTwoCaregiverTwo +
					' ' +
					formattedDate +
					BI_PSPB_NotificationConstantsCtrl.pastTwentySubject;
				treatmentType = BI_PSPB_NotificationConstantsCtrl.pastDueDateTwo;
			} else {
				return null;
			}

			BI_PSPB_TaskParameters taskParams = new BI_PSPB_TaskParameters(
				subject,
				BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
				category,
				treatmentType,
				BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
			);

			tasks = createTasks(
				new List<Id>{ params.reminder.Id },
				taskParams,
				caregiverTaskParams.userType,
				caregiverTaskParams.caregiverId
			);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_PastDueNotificationCtrl.class.getName(),
				ex
			);
		}
		// Return the first task from the list or null if the list is empty
		return tasks.isEmpty() ? null : tasks[0];
	}
	/**
	 * @description  Creates tasks for a list of enrollees based on the specified task parameters,
	 *                user type, and caregiver association. This method generates tasks for each
	 *                enrollee, taking into account the provided parameters and conditions, such
	 *                as the type of user (e.g., patient or caregiver) and the associated caregiver ID.
	 * @param enrollees A list of enrollee IDs for whom the tasks need to be created.
	 * @param taskParams An instance of BI_PSPB_TaskParameters containing the parameters and
	 *                   configuration settings required for creating the tasks.
	 * @param userType A string indicating the type of user for the tasks, such as 'Patient' or 'Caregiver'.
	 * @param caregiverId The ID of the caregiver associated with the tasks, if applicable.
	 * @return A list of Task records that have been created based on the given enrollees and task parameters.
	 */

	public static List<Task> createTasks(
		List<Id> enrollees,
		BI_PSPB_TaskParameters taskParams,
		String userType,
		Id caregiverId
	) {
		List<Task> tasks = new List<Task>();
        
			for (Id enrollee : enrollees) {
				Task task = new Task();
				task.Subject = taskParams.subject;
				task.BI_PSP_Notification_Type__c = taskParams.notificationType;
				task.BI_PSP_Category__c = taskParams.category;
				task.BI_PSPB_Treatment_Type__c = taskParams.treatmentType;
				task.Status = taskParams.status;
				task.WhatId = enrollee;
				task.BI_PSPB_Notification_User_Type__c = userType;
				if (userType == 'Patient' && caregiverId != null) {
					task.BI_PSPB_Caregiver__c = caregiverId;
				} else if (userType == 'Caregiver') {
					task.BI_PSPB_Caregiver__c = caregiverId;
				}
				tasks.add(task);
			}
		return tasks;
	}
}