/**
 * @description   Handles the creation of tasks when a video is uploaded,
 *                and calls methods to send SMS and email notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_NotificationSettingsCtrl {
	/**
	 * @description  Handles the trigger to send notifications based on the
	 *                provided criteria. Retrieves notification details,
	 *                filters and adds contacts, and sends SMS and emails.
	 * @param accountToNotificationsMap The ID of the record related to the treatment reminders.
	 * @param enrollees The type of reminder to filter by.
	 * @param emailList The type of reminder to filter by.
	 * @param smsList The type of reminder to filter by.
	 */
	public static void addContactsToSend(
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap,
		List<CareProgramEnrollee> enrollees,
		List<Id> emailList,
		List<Id> smsList
	) {
		try {
			Set<Id> careids = new Set<Id>();
			for (CareProgramEnrollee enrollee : enrollees) {
				Date birthdate = enrollee.Account.BI_PSP_Birthdate__c;
				Integer age = BI_PSPB_EnrolleeQueryHelper.getAge(birthdate);
				if (BI_PSPB_EnrolleeQueryHelper.isLegalAge(age)) {
					processNotifications(
						accountToNotificationsMap.get(enrollee.Id),
						enrollee.Account.PersonContactId,
						emailList,
						smsList
					);
				}
				careids.add(enrollee.Id);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SmsEmailNotificationHelper.class.getName(),
				ex
			);
		}
	}
	/**
	 * @description  Adds caregiver contacts to the lists of email and SMS recipients based on the
	 *                notification settings associated with enrollees. This method maps enrollees
	 *                to their caregivers and populates the email and SMS lists with the appropriate
	 *                contact IDs for sending notifications.
	 * @param accountToNotificationsMap A map where the key is an account ID and the value is a list of
	 *                                  BI_PSP_Notification_Setting__c records, representing the
	 *                                  notification settings for each account.
	 * @param enrollees A list of CareProgramEnrollee records representing the enrollees whose caregiver
	 *                  contacts need to be added to the notification lists.
	 * @param emailList A list of contact IDs to be used for sending email notifications to caregivers.
	 *                  This list will be populated with the relevant caregiver contacts based on the enrollee data.
	 * @param smsList A list of contact IDs to be used for sending SMS notifications to caregivers.
	 *                This list will be updated with the appropriate caregiver contacts as determined
	 *                from the enrollees and their notification settings.
	 */
	public static void addContactsToSendCaregiver(
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap,
		List<CareProgramEnrollee> enrollees,
		List<Id> emailList,
		List<Id> smsList
	) {
		try {
			Set<Id> careids = new Set<Id>();
			for (CareProgramEnrollee enrollee : enrollees) {
				careids.add(enrollee.Id);
			}

			// Formulate SOQL query conditions
			String fields = 'Id, BI_PSPB_Care_Program_Enrollee__r.Id, BI_PSPB_Patient__r.BI_PSP_Birthdate__c, BI_PSPB_Patient__r.PersonContactId, BI_PSPB_Caregiver__r.PersonContactId';
			String conditionIds =
				'(\'' +
				String.join(careids, '\', \'') +
				'\')';
			String conditions =
				'BI_PSPB_Care_Program_Enrollee__c IN ' + conditionIds;

			// Execute the query
			List<SObject> caregivers = BI_PSP_CommonQueryUtility.executeQuery(
				'BI_PSPB_Enrollee_Caregiver__c',
				fields,
				conditions,
				false
			);

			// Process caregivers
			for (SObject caregiver : caregivers) {
				Id patientId = (Id) caregiver.getSObject('BI_PSPB_Caregiver__r')
					.get('Id');
				processCaregiverNotifications(
					accountToNotificationsMap.get(patientId),
					(Id) caregiver.getSObject('BI_PSPB_Caregiver__r')
						.get('PersonContactId'),
					emailList,
					smsList
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SmsEmailNotificationHelper.class.getName(),
				ex
			);
		}
	}

	/**
	 * @description  Retrieves treatment reminders based on the given criteria.
	 * @param notifications The ID of the record related to the treatment reminders.
	 * @param personContactId The type of reminder to filter by.
	 * @param emailList The type of reminder to filter by.
	 * @param smsList The type of reminder to filter by.
	 */
	private static void processNotifications(
		List<BI_PSP_Notification_Setting__c> notifications,
		Id personContactId,
		List<Id> emailList,
		List<Id> smsList
	) {
		try {
			if (!notifications.isEmpty()) {
				for (
					BI_PSP_Notification_Setting__c notification : notifications
				) {
					if (notification.BI_PSP_Email__c) {
						emailList.add(personContactId);
					}
					if (notification.BI_PSP_SMS__c) {
						smsList.add(personContactId);
					}
				}
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_SmsEmailNotificationHelper.class.toString(),
					false,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SmsEmailNotificationHelper.class.getName(),
				ex
			);
		}
	}
	/**
	 * @description  Processes caregiver notifications by evaluating the provided notification settings
	 *                and adding the relevant contact ID to the appropriate notification lists (email or SMS).
	 *                This method ensures that caregivers receive notifications based on their settings and
	 *                preferred communication channels.
	 * @param notifications A list of BI_PSP_Notification_Setting__c records containing the settings
	 *                      for caregiver notifications. These settings determine how and when notifications
	 *                      should be sent.
	 * @param personContactId The contact ID of the caregiver for whom the notifications are being processed.
	 *                        This ID is used to determine if the caregiver should receive email or SMS notifications.
	 * @param emailList A list of contact IDs for email notifications. This list will be updated with the
	 *                  personContactId if the caregiver's notification settings include email notifications.
	 * @param smsList A list of contact IDs for SMS notifications. This list will be updated with the
	 *                personContactId if the caregiver's notification settings include SMS notifications.
	 */
	private static void processCaregiverNotifications(
		List<BI_PSP_Notification_Setting__c> notifications,
		Id personContactId,
		List<Id> emailList,
		List<Id> smsList
	) {
		try {
			if (!notifications.isEmpty()) {
				for (
					BI_PSP_Notification_Setting__c notification : notifications
				) {
					if (notification.BI_PSP_Email__c) {
						emailList.add(personContactId);
					}
					if (notification.BI_PSP_SMS__c) {
						smsList.add(personContactId);
					}
				}
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_SmsEmailNotificationHelper.class.toString(),
					false,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SmsEmailNotificationHelper.class.getName(),
				ex
			);
		}
	}

	/**
	 * @description  Retrieves the URL for the given notification details.
	 * @param notificationDetails The ID of the record related to the treatment reminders.
	 * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
	 */
	public static String getNotificationUrl(
		BI_PSPB_SmsAndEmailNotificationCtrl notificationDetails
	) {
		BI_PSPB_Notification__mdt filteredNotifications = BI_PSPB_Notification__mdt.getInstance(
			BI_PSPB_NotificationConstantsCtrl.siteUrl
		);
		String bDestUrl = filteredNotifications.BI_PSPB_BrandedUrl__c;
		return bDestUrl + notificationDetails.urlPage;
	}
	/**
	 * @description  Retrieves a map of account IDs to their associated notification settings based on
	 *                the specified notification type. This method queries the notification settings for
	 *                each account and returns a map where each key is an account ID and each value is a
	 *                list of BI_PSP_Notification_Setting__c records relevant to that account.
	 * @param accountRec A list of account IDs for which the notification settings are to be retrieved.
	 * @param notificationType A string specifying the type of notifications to filter by. This determines
	 *                         which settings are included in the results.
	 * @return A map where each key is an account ID from the accountRec list, and each value is a list
	 *         of BI_PSP_Notification_Setting__c records representing the notification settings associated
	 *         with that account for the specified notification type.
	 */
	public static Map<Id, List<BI_PSP_Notification_Setting__c>> getAccountToNotificationsMap(
		List<Id> accountRec,
		String notificationType
	) {
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = new Map<Id, List<BI_PSP_Notification_Setting__c>>();
		try {
			// Convert List<Id> to a comma-separated string for the query
			String conditionIds =
				'(\'' +
				String.join(accountRec, '\', \'') +
				'\')';
			String fields = 'Id, BI_PSP_Enrollee__c, BI_PSP_Patient__c, BI_PSP_Patient__r.BI_PSP_Birthdate__c, BI_PSP_Patient__r.PersonContactId, BI_PSP_SMS__c, BI_PSP_Email__c, BI_PSP_Notification_Type__c';
			String conditions =
				'BI_PSP_Enrollee__c IN ' +
				conditionIds +
				' ' +
				'AND BI_PSP_Notification_Type__c = \'' +
				notificationType +
				'\' ';

			// Execute query and return results as List<Task>
			List<BI_PSP_Notification_Setting__c> results = (List<BI_PSP_Notification_Setting__c>) BI_PSP_CommonQueryUtility.executeQuery(
				'BI_PSP_Notification_Setting__c',
				fields,
				conditions,
				false
			);
			if (results.isEmpty()) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_NotificationSetting.class.toString(),
					false,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
			}
			for (BI_PSP_Notification_Setting__c setting : results) {
				if (
					!accountToNotificationsMap.containsKey(
						setting.BI_PSP_Enrollee__c
					)
				) {
					accountToNotificationsMap.put(
						setting.BI_PSP_Enrollee__c,
						new List<BI_PSP_Notification_Setting__c>()
					);
				}
				accountToNotificationsMap.get(setting.BI_PSP_Enrollee__c)
					.add(setting);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_NotificationSetting.class.getName(),
				ex
			);
		}
		return accountToNotificationsMap;
	}
	/**
	 * @description  Retrieves a map of caregiver IDs to their associated notification settings based on
	 *                the specified notification type. This method queries the notification settings for
	 *                caregivers related to the provided accounts and returns a map where each key is a
	 *                caregiver ID and each value is a list of BI_PSP_Notification_Setting__c records relevant
	 *                to that caregiver.
	 * @param accountRec A list of account IDs associated with caregivers for which the notification settings
	 *                   are to be retrieved.
	 * @param notificationType A string specifying the type of notifications to filter by. This determines
	 *                         which settings are included in the results for each caregiver.
	 * @return A map where each key is a caregiver ID, and each value is a list of BI_PSP_Notification_Setting__c
	 *         records representing the notification settings associated with that caregiver for the specified
	 *         notification type.
	 */
	public static Map<Id, List<BI_PSP_Notification_Setting__c>> getCaregiverToNotificationsMap(
		List<Id> accountRec,
		String notificationType
	) {
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = new Map<Id, List<BI_PSP_Notification_Setting__c>>();
		try {
			// Convert List<Id> to a comma-separated string for the query
			String conditionIds =
				'(\'' +
				String.join(accountRec, '\', \'') +
				'\')';
			String fields = 'Id, BI_PSP_Enrollee__c, BI_PSP_Patient__c, BI_PSP_Patient__r.BI_PSP_Birthdate__c, BI_PSP_Patient__r.PersonContactId, BI_PSP_SMS__c, BI_PSP_Email__c, BI_PSP_Notification_Type__c, BI_PSPB_Caregiver__c';
			String conditions =
				'BI_PSPB_Caregiver__c IN ' +
				conditionIds +
				' ' +
				'AND BI_PSP_Notification_Type__c = \'' +
				notificationType +
				'\' ';

			// Execute query and return results as List<Task>
			List<BI_PSP_Notification_Setting__c> results = (List<BI_PSP_Notification_Setting__c>) BI_PSP_CommonQueryUtility.executeQuery(
				'BI_PSP_Notification_Setting__c',
				fields,
				conditions,
				false
			);
			if (results.isEmpty()) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_NotificationSetting.class.toString(),
					false,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
			}
			for (BI_PSP_Notification_Setting__c setting : results) {
				if (
					!accountToNotificationsMap.containsKey(
						setting.BI_PSPB_Caregiver__c
					)
				) {
					accountToNotificationsMap.put(
						setting.BI_PSPB_Caregiver__c,
						new List<BI_PSP_Notification_Setting__c>()
					);
				}
				accountToNotificationsMap.get(setting.BI_PSPB_Caregiver__c)
					.add(setting);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_NotificationSetting.class.getName(),
				ex
			);
		}
		return accountToNotificationsMap;
	}
}