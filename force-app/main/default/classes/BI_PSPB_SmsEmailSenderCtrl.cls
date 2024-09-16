/**
 * @description   Handles the creation of tasks when a video is uploaded,
 *                and calls methods to send SMS and email notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_SmsEmailSenderCtrl {
	/**
	 * @description  Handles the trigger to send notifications based on the
	 *                provided criteria. Retrieves notification details,
	 *                filters and adds contacts, and sends SMS and emails.
	 * @param recordId The ID of the record related to the treatment reminders.
	 * @param notificationTypes The type of reminder to filter by.
	 * @param communityUserName The type of reminder to filter by.
	 * @param treatmentDate The type of reminder to filter by.
	 */
	public static void handleTrigger(
		List<Id> recordId,
		String notificationTypes,
		List<String> communityUserName,
		String treatmentDate
	) {
		try {
			if (recordId.isEmpty() && String.isBlank(notificationTypes)) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_SmsEmailSenderCtrl.class.toString(),
					false,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
				return;
			}
			List<Id> enrolIds = new List<Id>();
			List<Id> accountRec = new List<Id>();
			Date today = Date.today();
			List<Id> patientEnrolleeIds = new List<Id>();
			List<Id> caregiverEnrolleeIds = new List<Id>();
            List<Id> patientAddCaregiverIds = new List<Id>();
			List<Id> caregiverIds = new List<Id>();
            List<String> patientName = new List<String>();
			// Retrieve enrollees
			List<CareProgramEnrollee> enrollees = BI_PSPB_EnrolleeQueryHelper.getEnrollees(
				recordId
			);
			for (CareProgramEnrollee enrollee : enrollees) {
				Integer age = calculateAge(
					enrollee.Account.BI_PSP_Birthdate__c,
					today
				);
				Id enrolleeId = enrollee.Id;
				Id caregiverId = fetchCaregiverId(enrolleeId);
                if (age > 18 && caregiverId != null){
                    patientAddCaregiverIds.add(enrollee.Id);
					enrolIds.add(enrollee.Id);
					accountRec.add(enrollee.AccountId);
                }
				if (age > 18 && caregiverId == null) {
					patientEnrolleeIds.add(enrollee.Id);
					enrolIds.add(enrolleeId);
					accountRec.add(enrollee.AccountId);
                } else {
					caregiverEnrolleeIds.add(enrollee.Id);
					caregiverIds.add(caregiverId);
                    patientName.add(enrollee.Account.Name);
				}
			}
            
            if(!patientEnrolleeIds.isEmpty()){
			assignPatientTemplates(
				patientEnrolleeIds,
				notificationTypes,
				enrolIds,
				treatmentDate,
				communityUserName
			);
           }
            if(!patientAddCaregiverIds.isEmpty()){
                assignPatientTemplates(
				patientAddCaregiverIds,
				notificationTypes,
				enrolIds,
				treatmentDate,
				communityUserName
			);
            }
            if(!caregiverEnrolleeIds.isEmpty()){
			assignCaregiverTemplates(
				caregiverEnrolleeIds,
				notificationTypes,
				caregiverIds,
				treatmentDate,
				communityUserName,
                patientName
			);
            }
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SmsEmailSenderCtrl.class.getName(),
				ex
			);
		}
	}
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
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = getAccountToNotificationsMap(
			recordId,
			notificationDetails.notificationType
		);
		// Filter and add contacts
		addContactsToSend(
			accountToNotificationsMap,
			enrollees,
			contactIdsToSendEmail,
			contactIdsToSendSMS
		);
		String url = getNotificationUrl(notificationDetails);
		if (!contactIdsToSendEmail.isEmpty()) {
            System.debug('contactIdsToSendEmail ' + contactIdsToSendEmail);
            /*BI_PSPB_EmailBatch.EmailBatchParams params = new BI_PSPB_EmailBatch.EmailBatchParams(
    			contactIdsToSendEmail,
    			notificationDetails.emailSubject,
    			url,
    			treatmentDate,
    			notificationDetails.followName,
    			new List<String>{ '' }
			);
            BI_PSPB_EmailBatch sendEmail = new BI_PSPB_EmailBatch(params);
            database.executeBatch(sendEmail, 45);
            System.debug('params ' + params);*/
		}
		if (!contactIdsToSendSMS.isEmpty()) {
			/*BI_PSPB_SmsBatch sendSms = new BI_PSPB_SmsBatch(
				contactIdsToSendSMS,
				notificationDetails.subject,
				url,
				null
			);
			database.executeBatch(sendSms, 45);*/
		}
	}
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
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = getAccountToNotificationsMap(
			enrolIds,
			notificationDetails.notificationType
		);
		// Filter and add contacts
		addContactsToSend(
			accountToNotificationsMap,
			enrollees,
			contactIdsToSendEmail,
			contactIdsToSendSMS
		);
		String url = getNotificationUrl(notificationDetails);
		if (!contactIdsToSendEmail.isEmpty()) {
            /*BI_PSPB_EmailBatch.EmailBatchParams params = new BI_PSPB_EmailBatch.EmailBatchParams(
    			contactIdsToSendEmail,
    			notificationDetails.emailSubject,
    			url,
    			treatmentDate,
    			notificationDetails.followName,
    			new List<String>{ '' }
			);
            BI_PSPB_EmailBatch sendEmail = new BI_PSPB_EmailBatch(params);
            database.executeBatch(sendEmail, 45);*/
		}
		if (!contactIdsToSendSMS.isEmpty()) {
			/*BI_PSPB_SmsBatch sendSms = new BI_PSPB_SmsBatch(
				contactIdsToSendSMS,
				notificationDetails.subject,
				url,
				null
			);
			database.executeBatch(sendSms, 45);*/
		}
	}
	public static void assignCaregiverTemplates(
		List<Id> recordId,
		String notificationTypes,
		List<Id> caregiverIds,
		String treatmentDate,
		List<String> communityUserName,
        List<String> patientName
	) {
		BI_PSPB_SmsAndEmailNotificationCtrl notificationDetails = BI_PSPB_SmsEmailNotificationHelper.getCaregiverNotificationDetails(
			notificationTypes,
			communityUserName,
			treatmentDate,
            patientName
		);
		List<Id> contactIdsToSendSMS = new List<Id>();
		List<Id> contactIdsToSendEmail = new List<Id>();
		// Retrieve enrollees
        List<CareProgramEnrollee> enrollees = BI_PSPB_EnrolleeQueryHelper.getEnrollees(
			recordId
		);
		// Retrieve notifications
		Map<Id, List<BI_PSP_Notification_Setting__c>> accountToNotificationsMap = getCaregiverToNotificationsMap(
			caregiverIds,
			notificationDetails.notificationType
		);
		// Filter and add contacts
		addContactsToSendCaregiver(
			accountToNotificationsMap,
			enrollees,
			contactIdsToSendEmail,
			contactIdsToSendSMS
		);
		String url = getNotificationUrl(notificationDetails);
		if (!contactIdsToSendEmail.isEmpty()) {
           /* BI_PSPB_EmailBatch.EmailBatchParams params = new BI_PSPB_EmailBatch.EmailBatchParams(
    			contactIdsToSendEmail,
    			notificationDetails.emailSubject,
    			url,
    			treatmentDate,
    			notificationDetails.followName,
    			patientName
			);
            BI_PSPB_EmailBatch sendEmail = new BI_PSPB_EmailBatch(params);
            database.executeBatch(sendEmail, 45);*/
		}
		if (!contactIdsToSendSMS.isEmpty()) {
			/*BI_PSPB_SmsBatch sendSms = new BI_PSPB_SmsBatch(
				contactIdsToSendSMS,
				notificationDetails.subject,
				url,
				null
			);
			database.executeBatch(sendSms, 45);*/
		}
	}

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
	public static Integer calculateAge(Date birthDate, Date today) {
		Integer age = today.year() - birthDate.year();
		if (today < birthDate.addYears(age)) {
			age--;
		}
		return age;
	}
	public static Id fetchCaregiverId(Id enrolleeId) {
		// Query to find the active caregiver associated with the enrollee
		List<BI_PSPB_Enrollee_Caregiver__c> enrolleeCaregiverList = [
			SELECT BI_PSPB_Caregiver__r.Id
			FROM BI_PSPB_Enrollee_Caregiver__c
			WHERE
				BI_PSPB_Care_Program_Enrollee__c = :enrolleeId
				AND BI_PSPB_Status__c = 'Active'
			LIMIT 1
		];

		// Check if any records are returned and return the caregiver ID or null
		if (!enrolleeCaregiverList.isEmpty()) {
			return enrolleeCaregiverList[0].BI_PSPB_Caregiver__r.Id;
		} else {
			return null;
		}
	}
}