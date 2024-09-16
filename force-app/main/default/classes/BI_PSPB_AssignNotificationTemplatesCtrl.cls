/**
 * @description   Handles the creation of tasks when a video is uploaded,
 *                and calls methods to send SMS and email notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_AssignNotificationTemplatesCtrl {
	/**
	 * @description  Handles the trigger to send notifications based on the
	 *                provided criteria. Retrieves notification details,
	 *                filters and adds contacts, and sends SMS and emails.
	 * @param recordId The ID of the record related to the treatment reminders.
	 * @param notificationTypes The type of reminder to filter by.
	 * @param enrolIds The type of reminder to filter by.
	 * @param treatmentDate The type of reminder to filter by.
	 * @param communityUserName The type of reminder to filter by.
	 */
	public static void assignPatientTemplates(
		List<Id> recordId,
		String notificationTypes,
		List<Id> enrolIds,
		String treatmentDate,
		List<String> communityUserName
	) {
		BI_PSPB_SmsAndEmailNotificationCtrl notificationDetails = BI_PSPB_SmsEmailNotificationHelper.getNotificationDetails(
			notificationTypes,
			communityUserName,
			treatmentDate
		);
		List<Id> contactIdsToSendSMS = new List<Id>();
		List<Id> contactIdsToSendEmail = new List<Id>();
		// Retrieve enrollees
		List<CareProgramEnrollee> enrollees = BI_PSPB_EnrolleeQueryHelper.getEnrollees(
			recordId
		);
		// Retrieve notifications
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = BI_PSPB_NotificationSettingsCtrl.getAccountToNotificationsMap(
			recordId,
			notificationDetails.notificationType
		);
		// Filter and add contacts
		BI_PSPB_NotificationSettingsCtrl.addContactsToSend(
			accountToNotificationsMap,
			enrollees,
			contactIdsToSendEmail,
			contactIdsToSendSMS
		);
		String url = BI_PSPB_NotificationSettingsCtrl.getNotificationUrl(
			notificationDetails
		);
		if (!contactIdsToSendEmail.isEmpty()) {
			BI_PSPB_EmailBatch.EmailBatchParams params = new BI_PSPB_EmailBatch.EmailBatchParams(
				contactIdsToSendEmail,
				notificationDetails.emailSubject,
				url,
				treatmentDate,
				notificationDetails.followName,
				new List<String>{ '' }
			);
			BI_PSPB_EmailBatch sendEmail = new BI_PSPB_EmailBatch(params);
			database.executeBatch(sendEmail, 45);
		}
		if (!contactIdsToSendSMS.isEmpty()) {
			BI_PSPB_SmsBatch sendSms = new BI_PSPB_SmsBatch(
				contactIdsToSendSMS,
				notificationDetails.subject,
				url,
				null
			);
			database.executeBatch(sendSms, 45);
		}
	}
	/**
	 * @description  Assigns notification templates related to adding caregivers based on the provided
	 *                record IDs, notification types, enrollee IDs, treatment date, and community usernames.
	 *                This method maps appropriate templates to each enrollee and caregiver to facilitate
	 *                the generation of personalized notifications for caregiver additions.
	 * @param recordId A list of record IDs representing the enrollees or accounts for which caregiver
	 *                 templates need to be assigned.
	 * @param notificationTypes A string specifying the types of notifications to be assigned, used to
	 *                          select the appropriate templates for adding caregivers.
	 * @param enrolIds A list of enrollee IDs related to the records for which caregiver templates are
	 *                 being assigned.
	 * @param treatmentDate A string representing the treatment date to be included in the notification templates.
	 * @param communityUserName A list of community usernames associated with the enrollees, used to
	 *                          personalize the notifications for caregiver additions.
	 */
	public static void assignAddCaregiverTemplates(
		List<Id> recordId,
		String notificationTypes,
		List<Id> enrolIds,
		String treatmentDate,
		List<String> communityUserName
	) {
		BI_PSPB_SmsAndEmailNotificationCtrl notificationDetails = BI_PSPB_SmsEmailNotificationHelper.getNotificationDetails(
			notificationTypes,
			communityUserName,
			treatmentDate
		);
		List<Id> contactIdsToSendSMS = new List<Id>();
		List<Id> contactIdsToSendEmail = new List<Id>();
		// Retrieve enrollees
		List<CareProgramEnrollee> enrollees = BI_PSPB_EnrolleeQueryHelper.getEnrollees(
			recordId
		);
		// Retrieve notifications
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = BI_PSPB_NotificationSettingsCtrl.getAccountToNotificationsMap(
			enrolIds,
			notificationDetails.notificationType
		);
		// Filter and add contacts
		BI_PSPB_NotificationSettingsCtrl.addContactsToSend(
			accountToNotificationsMap,
			enrollees,
			contactIdsToSendEmail,
			contactIdsToSendSMS
		);
		String url = BI_PSPB_NotificationSettingsCtrl.getNotificationUrl(
			notificationDetails
		);
		if (!contactIdsToSendEmail.isEmpty()) {
			BI_PSPB_EmailBatch.EmailBatchParams params = new BI_PSPB_EmailBatch.EmailBatchParams(
				contactIdsToSendEmail,
				notificationDetails.emailSubject,
				url,
				treatmentDate,
				notificationDetails.followName,
				new List<String>{ '' }
			);
			BI_PSPB_EmailBatch sendEmail = new BI_PSPB_EmailBatch(params);
			database.executeBatch(sendEmail, 45);
		}
		if (!contactIdsToSendSMS.isEmpty()) {
			BI_PSPB_SmsBatch sendSms = new BI_PSPB_SmsBatch(
				contactIdsToSendSMS,
				notificationDetails.subject,
				url,
				null
			);
			database.executeBatch(sendSms, 45);
		}
	}
	/**
	 * @description  Assigns notification templates for caregivers based on the provided parameters.
	 *                This method uses the caregiver notification parameters, notification types, and treatment
	 *                date to select and assign the appropriate templates for caregiver communications. It also
	 *                integrates community user names for personalized or targeted messaging.
	 *
	 * @param params An instance of BI_PSPB_CaregiverNotificationParamsCtrl containing the necessary
	 *               data for caregiver notifications, including record IDs, caregiver IDs, and patient names.
	 * @param notificationTypes A string specifying the types of notifications to be assigned (e.g.,
	 *                          'Reminder', 'Alert'). This parameter helps in filtering and selecting the appropriate
	 *                          templates for the caregivers.
	 * @param treatmentDate A string representing the treatment date associated with the notifications.
	 *                      This date is used to contextualize the communication, ensuring that notifications
	 *                      are relevant and timely.
	 * @param communityUserName A list of strings representing community user names associated with the caregivers.
	 *                          This information is used to personalize the notifications or to target specific
	 *                          community users in the communication.
	 */

	public static void assignCaregiverTemplates(
		BI_PSPB_CaregiverNotificationParamsCtrl params,
		String notificationTypes,
		String treatmentDate,
		List<String> communityUserName
	) {
		BI_PSPB_SmsAndEmailNotificationCtrl notificationDetails = BI_PSPB_SmsEmailNotificationHelper.getCaregiverNotificationDetails(
			notificationTypes,
			communityUserName,
			treatmentDate,
			params.patientName
		);

		List<Id> contactIdsToSendSMS = new List<Id>();
		List<Id> contactIdsToSendEmail = new List<Id>();

		// Retrieve enrollees
		List<CareProgramEnrollee> enrollees = BI_PSPB_EnrolleeQueryHelper.getEnrollees(
			params.recordId
		);

		// Retrieve notifications
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = BI_PSPB_NotificationSettingsCtrl.getCaregiverToNotificationsMap(
			params.caregiverIds,
			notificationDetails.notificationType
		);

		// Filter and add contacts
		BI_PSPB_NotificationSettingsCtrl.addContactsToSendCaregiver(
			accountToNotificationsMap,
			enrollees,
			contactIdsToSendEmail,
			contactIdsToSendSMS
		);

		String url = BI_PSPB_SmsEmailSenderCtrl.getNotificationUrl(
			notificationDetails
		);

		if (!contactIdsToSendEmail.isEmpty()) {
			BI_PSPB_EmailBatch.EmailBatchParams emailParams = new BI_PSPB_EmailBatch.EmailBatchParams(
				contactIdsToSendEmail,
				notificationDetails.emailSubject,
				url,
				treatmentDate,
				notificationDetails.followName,
				params.patientName
			);

			BI_PSPB_EmailBatch sendEmail = new BI_PSPB_EmailBatch(emailParams);
			Database.executeBatch(sendEmail, 45);
		}

		if (!contactIdsToSendSMS.isEmpty()) {
			BI_PSPB_SmsBatch sendSms = new BI_PSPB_SmsBatch(
				contactIdsToSendSMS,
				notificationDetails.subject,
				url,
				null
			);

			Database.executeBatch(sendSms, 45);
		}
	}
}