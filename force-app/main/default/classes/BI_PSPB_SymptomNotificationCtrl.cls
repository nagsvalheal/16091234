/**
 * @description  This class handles the creation of tasks when a video is
 * uploaded. It also triggers methods to send SMS and email notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_SymptomNotificationCtrl {
	/**
	 * @description  Processes symptom notifications by creating tasks for each
	 * symptom tracker associated with uploaded videos. Sends SMS and email
	 * notifications as part of the process.
	 */
	public static void processSymptomNotifications() {
		try {
			List<SObject> enrolleeIds = fetchEnrolleeIds();

			if (!enrolleeIds.isEmpty()) {
				List<BI_PSP_Symptom_Tracker__c> symptomTrackers = BI_PSPB_SymptomTrackerQuery.fetchSymptomTrackers(
					enrolleeIds
				);

				if (!symptomTrackers.isEmpty()) {
					processAndCreateTasks(symptomTrackers);
				} else {
					logRecordNotFoundError();
				}
			} else {
				logRecordNotFoundError();
			}
		} catch (Exception ex) {
			logException(ex);
		}
	}
	/**
	 * @description  Fetches a list of enrollee IDs from the CareProgramEnrollee object using a dynamic query
	 *                utility. This method retrieves all enrollee records by executing a query that selects
	 *                their IDs, with the option to include or exclude additional filtering criteria.
	 *
	 * @return A list of SObject records representing enrollee IDs from the CareProgramEnrollee object.
	 *         The list contains the IDs of all enrollees retrieved by the query.
	 */
	private static List<SObject> fetchEnrolleeIds() {
		return BI_PSP_CommonQueryUtility.executeQuery(
			'CareProgramEnrollee',
			'Id',
			null,
			false
		);
	}
	/**
	 * @description  Processes a list of symptom tracker records and creates tasks based on the information
	 *                contained within each record. This method analyzes each symptom tracker to determine
	 *                the appropriate actions, such as generating tasks for follow-up or monitoring purposes.
	 *
	 * @param symptomTrackers A list of BI_PSP_Symptom_Tracker__c records representing symptom trackers
	 *                        that contain details about the symptoms reported by enrollees. These records
	 *                        are used to assess the need for task creation based on the reported symptoms.
	 */
	private static void processAndCreateTasks(
		List<BI_PSP_Symptom_Tracker__c> symptomTrackers
	) {
		Date today = Date.today();
		Map<Id, Id> enrolleeToCaregiverMap = new Map<Id, Id>(); // Correct mapping of Enrollee ID to Caregiver ID
		Set<Id> under18EnrolleeIds = new Set<Id>();
		Set<Id> enrolleeIdsWithCaregivers = new Set<Id>();
		list<Id> caregiverEnrolleeIds = new List<Id>();
		list<Id> patientEnrolleeIds = new List<Id>();
		String subjectForCaregiver;
		String subjectForPatient;

		for (BI_PSP_Symptom_Tracker__c tracker : symptomTrackers) {
			Integer age = BI_PSPB_SmsEmailSenderCtrl.calculateAge(
				tracker.BI_PSP_Care_Program_Enrollee__r.Account.BI_PSP_Birthdate__c,
				today
			);
			Id enrolleeId = tracker.BI_PSP_Care_Program_Enrollee__c;
			Id caregiverId = BI_PSPB_SmsEmailSenderCtrl.fetchCaregiverId(
				enrolleeId
			);
			String patientName = tracker.BI_PSP_Care_Program_Enrollee__r.Account.Name;
			subjectForCaregiver =
				BI_PSPB_NotificationConstantsCtrl.actionSymptomCaregiver +
				' ' +
				patientName +
				BI_PSPB_NotificationConstantsCtrl.actionSymptomCaregiverTwo;
			subjectForPatient = BI_PSPB_NotificationConstantsCtrl.symptomTrackerActionSubject;
			if (age > 18) {
				// Enrollee is under 18
				under18EnrolleeIds.add(enrolleeId);
				patientEnrolleeIds.add(enrolleeId);
			}

			if (caregiverId != null) {
				enrolleeToCaregiverMap.put(enrolleeId, caregiverId);
				enrolleeIdsWithCaregivers.add(enrolleeId);
				caregiverEnrolleeIds.add(enrolleeId);
			}
		}

		// Create and insert tasks for under-18 enrollees
		List<Id> under18CaregiverIds = new List<Id>();
		for (Id enrolleeId : under18EnrolleeIds) {
			under18CaregiverIds.add(
				enrolleeToCaregiverMap.containsKey(enrolleeId)
					? enrolleeToCaregiverMap.get(enrolleeId)
					: null
			);
		}
		createAndInsertTasks(
			new List<Id>(under18EnrolleeIds),
			under18CaregiverIds,
			'Patient',
			subjectForPatient
		);

		// Create and insert tasks for enrollees with caregivers
		createAndInsertTasks(
			new List<Id>(enrolleeIdsWithCaregivers),
			new List<Id>(enrolleeToCaregiverMap.values()),
			'Caregiver',
			subjectForCaregiver
		);

		// Create and insert tasks for enrollees without caregivers
		Set<Id> enrolleesWithoutCaregivers = new Set<Id>(under18EnrolleeIds);
		enrolleesWithoutCaregivers.removeAll(enrolleeIdsWithCaregivers);
		//createAndInsertTasks(new List<Id>(enrolleesWithoutCaregivers), null, 'Patient');
		if (!patientEnrolleeIds.isEmpty()) {
			sendNotifications(
				patientEnrolleeIds,
				BI_PSPB_NotificationConstantsCtrl.actionSymptomTracker,
				new List<String>{ '' }
			);
		}
		if (!caregiverEnrolleeIds.isEmpty()) {
			sendNotifications(
				caregiverEnrolleeIds,
				BI_PSPB_NotificationConstantsCtrl.actionSymptomTracker,
				new List<String>{ '' }
			);
		}
	}
	/**
	 * @description  Creates and inserts tasks for the specified enrollees and their caregivers based on
	 *                the provided user type and patient information. This method generates tasks tailored
	 *                to each enrollee or caregiver and inserts them into the system for tracking and follow-up.
	 *
	 * @param enrolleeIds A list of Ids representing the enrollees for whom tasks are to be created. These IDs
	 *                    identify the patients associated with the tasks.
	 * @param caregiverIds A list of Ids representing the caregivers associated with the enrollees, if applicable.
	 *                     These IDs are used to create tasks specifically targeted at caregivers.
	 * @param userType A string indicating the type of user for whom the tasks are being created, such as 'Patient'
	 *                 or 'Caregiver'. This parameter helps customize the task details according to the user's role.
	 * @param patientName A string representing the name of the patient for whom the task is being created.
	 *                    This name is used to personalize the task and ensure clarity in task assignments.
	 */
	private static void createAndInsertTasks(
		List<Id> enrolleeIds,
		List<Id> caregiverIds,
		String userType,
		String patientName
	) {
		if (!enrolleeIds.isEmpty()) {
			BI_PSPB_SymptomTaskParamsCtrl params = new BI_PSPB_SymptomTaskParamsCtrl.Builder()
				.setEnrollees(enrolleeIds)
				.setCaregiverIds(caregiverIds)
				.setNotificationType(
					BI_PSPB_NotificationConstantsCtrl.actionTypeAction
				)
				.setCategory(
					BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker
				)
				.setTreatmentType('')
				.setStatus(
					BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
				)
				.setUserType(userType)
				.setSubject(patientName)
				.build();

			List<Task> newTaskList = createTasks(params);

			BI_PSP_DatabaseOperationsUtility.insertOperation(
				newTaskList,
				BI_PSPB_SymptomNotificationCtrl.class.toString(),
				false
			);
		}
	}
	/**
	 * @description  Creates tasks based on the parameters provided in the BI_PSPB_SymptomTaskParamsCtrl object.
	 *               This method generates tasks for enrollees and caregivers according to specified conditions
	 *               such as notification type, category, user type, and other relevant parameters encapsulated
	 *               within the params object. The method aims to streamline the task creation process by
	 *               handling various configurations and scenarios defined in the input parameters.
	 *
	 * @param params An instance of BI_PSPB_SymptomTaskParamsCtrl that encapsulates all necessary parameters
	 *               for task creation. This includes details like lists of enrollee IDs, caregiver IDs,
	 *               notification type, category, treatment type, task status, user type, and task subject.
	 *               The params object allows the method to dynamically create tasks based on the specific
	 *               configurations passed to it.
	 *
	 * @return A List of Task objects that have been created based on the input parameters. Each task in the
	 *         list corresponds to an enrollee or caregiver, with attributes set according to the specified
	 *         configurations in the params object. The method ensures that all tasks are appropriately set
	 *         up for subsequent processing or actions.
	 */

	public static List<Task> createTasks(BI_PSPB_SymptomTaskParamsCtrl params) {
		List<Task> tasks = new List<Task>();
		try {
			for (Integer i = 0; i < params.enrollees.size(); i++) {
				Task task = new Task();
				task.BI_PSP_Notification_Type__c = params.notificationType;
				task.BI_PSP_Category__c = params.category;
				task.BI_PSPB_Treatment_Type__c = params.treatmentType;
				task.Status = params.status;
				task.Subject = params.subject;
				task.WhatId = params.enrollees[i];
				task.BI_PSPB_Notification_User_Type__c = params.userType;

				if (
					params.caregiverIds != null &&
					i < params.caregiverIds.size()
				) {
					task.BI_PSPB_Caregiver__c = params.caregiverIds[i];
				}

				tasks.add(task);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SymptomNotificationCtrl.class.getName(),
				ex
			);
		}
		return tasks;
	}

	/**
	 * @description  Logs an error message when a record is not found. This method utilizes the
	 *                BI_PSP_LogMessagesUtility to log an error with a specific error message,
	 *                indicating that a record was not found. The log entry includes the class name
	 *                where the error occurred and specifies the severity of the error.
	 */
	private static void logRecordNotFoundError() {
		BI_PSP_LogMessagesUtility.logError(
			BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
			BI_PSPB_SymptomNotificationCtrl.class.toString(),
			true,
			BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
	/**
	 * @description  Logs an error message for an exception that occurred during execution. This method
	 *                uses the BI_PSP_LogMessagesUtility to log the exception's message, along with the
	 *                class name where the exception was thrown. The log entry includes the severity level
	 *                of the error to classify the importance of the issue.
	 *
	 * @param ex The Exception object that contains details about the error that occurred. This includes
	 *           the message describing the exception.
	 */
	private static void logException(Exception ex) {
		BI_PSP_LogMessagesUtility.logError(
			ex.getMessage(),
			BI_PSPB_SymptomNotificationCtrl.class.toString(),
			true,
			BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
	/**
	 * @description  Sends notifications to a list of enrollees based on the specified notification type.
	 *                This method processes the given enrollee IDs and notification type to determine the
	 *                content and recipients of the notifications. It also incorporates community user names
	 *                for personalized or targeted communication.
	 *
	 * @param enrolleeIds A list of Ids representing the enrollees who will receive the notifications.
	 *                    These IDs identify the specific records to which the notifications are sent.
	 * @param notificationType A string indicating the type of notification to be sent (e.g., 'Reminder',
	 *                         'Alert'). This helps in customizing the notification content according to the
	 *                         specified type.
	 * @param communityUserNames A list of strings representing the names of community users associated
	 *                           with the enrollees. This information is used to personalize the notifications
	 *                           or target specific users within the community.
	 */
	public static void sendNotifications(
		List<Id> enrolleeIds,
		String notificationType,
		List<String> communityUserNames
	) {
		try {
			// Check if enrolleeIds is not empty and notificationType is not blank
			if (!enrolleeIds.isEmpty() && !String.isBlank(notificationType)) {
				BI_PSPB_NotificationTemplatesCtrl.handleTrigger(
					enrolleeIds,
					notificationType,
					communityUserNames,
					''
				);
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_NotificationSender.class.toString(),
					true,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_NotificationSetting.class.getName(),
				ex
			);
		}
	}
}