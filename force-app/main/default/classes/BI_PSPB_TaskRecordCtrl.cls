/**
 * @description Handles post-insertion tasks, including sending notifications
 * for symptom trackers, challenges, and community updates via SMS, email,
 * and in-site notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_TaskRecordCtrl {
	public static List<Id> recId = new List<Id>();
	public static String messageTypeOne;
	public static List<String> communityUserNameOne;
	/**
	 * @description Processes a list of newly inserted Task records to check for
	 * general notifications such as symptom trackers, challenges, and community
	 * updates. Sends out notifications if relevant records are found.
	 * @param newTasks The list of Task records being inserted.
	 */
	public static void handleAfterInsert(List<Task> newTasks) {
		try {
			if (!newTasks.isEmpty()) {
                List<Id> recordId = new List<Id>();
				// Iterate over each Task record in the newTasks list
				for (Task singleTask : newTasks) {
					recordId = new List<Id>{ singleTask.WhatId };
					List<String> communityUserName = new List<String>{
						singleTask.BI_PSP_CommunityUserName__c
					};

					String category = singleTask.BI_PSP_Category__c;
					String notificationType = singleTask.BI_PSP_Notification_Type__c;
					String chatterType = singleTask.BI_PSP_ChatterType__c;

					// Fetch enrollee records based on the task's related ID
					List<SObject> enrolleeRecords = BI_PSPB_TaskEnrolleeQueryCtrl.fetchEnrolleeRecords(
						recordId
					);
					if (enrolleeRecords.isEmpty()) {
						// Log an error if no enrollee records are found
						BI_PSP_LogMessagesUtility.logError(
							BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
							BI_PSPB_TaskRecordCtrl.class.toString(),
							false,
							BI_PSPB_NotificationConstantsCtrl.severityError
						);
					} else {
						// Prepare parameters for notification handling
						BI_PSPB_NotificationContext params = new BI_PSPB_NotificationContext(
							category,
							notificationType,
							chatterType,
							communityUserName,
							recordId
						);
						// Handle notifications
						BI_PSPB_TaskNotificationHandler.handleNotifications(
							enrolleeRecords,
							params
						);
					}
				}
				handleTriggerWithSend(recId, messageTypeOne, communityUserNameOne);
			} else {
				// Log an error if the newTasks list is empty
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_TaskRecordCtrl.class.toString(),
					true,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
			}
		} catch (Exception ex) {
			// Log any exceptions that occur
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_TaskRecordCtrl.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
	}

	/**
	 * @description  Retrieves treatment reminders based on the given criteria.
	 * @param recordId The ID of the record related to the treatment reminders.
	 * @param messageType The type of reminder to filter by.
	 * @param communityUserName The type of reminder to filter by.
	 */
	public static void handleTriggerWithMessage(
		List<Id> recordId,
		String messageType,
		List<String> communityUserName
	) {
		for (Id id : recordId) {
			recId.add(id); // This will add each individual Id from recordId to recId
            messageTypeOne = messageType;
			communityUserNameOne = communityUserName;
		}
	}
	/**
	 * @description  Retrieves treatment reminders based on the given criteria.
	 * @param recordId The ID of the record related to the treatment reminders.
	 * @param messageType The type of reminder to filter by.
	 * @param communityUserName The type of reminder to filter by.
	 */
	public static void handleTriggerWithSend(
		List<Id> recordId,
		String messageType,
		List<String> communityUserName
	) {
        if (!recordId.isEmpty() && !String.isBlank(messageType)) {
			BI_PSPB_NotificationTemplatesCtrl.handleTrigger(
				recordId,
				messageType,
				communityUserName,
				''
			);
        }
	}
}