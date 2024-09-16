/**
 * @description  Handles SMS and email notifications based on different
 *                notification types. Provides methods to get notification
 *                details, add contacts for sending notifications, and get
 *                the notification URL.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_SmsEmailNotificationHelper {
	/**
	 * @description  Retrieves notification details based on the given
	 *                notification type and community user names.
	 * @param notificationTypes The ID of the record related to the treatment reminders.
	 * @param communityUserName The type of reminder to filter by.
	 * @param treatmentDate Date to be sent for notification.
	 * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
	 */
	public static BI_PSPB_SmsAndEmailNotificationCtrl getNotificationDetails(
		String notificationTypes,
		List<String> communityUserName,
		String treatmentDate
	) {
		// Map to handle notification types
		Map<String, BI_PSPB_SmsAndEmailNotificationCtrl> notificationMap = new Map<String, BI_PSPB_SmsAndEmailNotificationCtrl>{
			BI_PSPB_NotificationConstantsCtrl.generalSymptomTracker => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.generalSymptomSms,
				BI_PSPB_NotificationConstantsCtrl.generalSymptomEmail,
				BI_PSPB_NotificationConstantsCtrl.urlSymptomTracker,
				BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.generalChallenges => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.generalChallengesSms,
				BI_PSPB_NotificationConstantsCtrl.generalChallengesEmail,
				BI_PSPB_NotificationConstantsCtrl.urlChallenges,
				BI_PSPB_NotificationConstantsCtrl.actionTypeChallenges,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.generalComment => new BI_PSPB_SmsAndEmailNotificationCtrl(
				'',
				BI_PSPB_NotificationConstantsCtrl.generalCommentEmail,
				BI_PSPB_NotificationConstantsCtrl.urlMyPost,
				BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.generalCreatePost => new BI_PSPB_SmsAndEmailNotificationCtrl(
				'',
				BI_PSPB_NotificationConstantsCtrl.generalPostEmail,
				BI_PSPB_NotificationConstantsCtrl.urlAllPost,
				BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.generalReaction => new BI_PSPB_SmsAndEmailNotificationCtrl(
				'',
				BI_PSPB_NotificationConstantsCtrl.generalReactionEmail,
				BI_PSPB_NotificationConstantsCtrl.urlMyPost,
				BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.generalFollow => new BI_PSPB_SmsAndEmailNotificationCtrl(
				'',
				BI_PSPB_NotificationConstantsCtrl.generalFollowEmail,
				BI_PSPB_NotificationConstantsCtrl.urlFollower,
				BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.video => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.generalVideoSms,
				BI_PSPB_NotificationConstantsCtrl.generalVideoEmail,
				BI_PSPB_NotificationConstantsCtrl.urlFollower,
				BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.actionSymptomTracker => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionSymptomSms,
				BI_PSPB_NotificationConstantsCtrl.actionSymptomEmail,
				BI_PSPB_NotificationConstantsCtrl.urlSymptomTracker,
				BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.treatmentOne => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentOneSms +
					' ' +
					treatmentDate,
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentOneEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.treatmentThree => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentThreeSms +
					' ' +
					treatmentDate,
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentThreeEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.treatmentSeven => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentSevenSms,
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentSevenEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.treatmentTen => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentTenSms,
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentTenEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.treatmentFourteen => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentFourteenSms,
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentFourteenEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.pastDueDateZero => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionPastDueSms,
				BI_PSPB_NotificationConstantsCtrl.dateOfTreatment,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.pastDueDateOne => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionPastDueOneSms,
				BI_PSPB_NotificationConstantsCtrl.actionPastDueOneEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.pastDueDateThree => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionTreatmentDueSeventyTwo +
					' ' +
					treatmentDate +
					' ' +
					BI_PSPB_NotificationConstantsCtrl.pastTwentySubject,
				BI_PSPB_NotificationConstantsCtrl.actionPastDueThreeEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDashboard,
				BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.dlqi => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionDlqiSms,
				BI_PSPB_NotificationConstantsCtrl.actionDlqiEmail,
				BI_PSPB_NotificationConstantsCtrl.urlDlqiQuestionnaires,
				BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.pss => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionPssSms,
				BI_PSPB_NotificationConstantsCtrl.actionPssEmail,
				BI_PSPB_NotificationConstantsCtrl.urlPssQuestionnaires,
				BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.wpai => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionWpaiSms,
				BI_PSPB_NotificationConstantsCtrl.actionWpaiEmail,
				BI_PSPB_NotificationConstantsCtrl.urlWpaiQuestionnaires,
				BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.qsq => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionQsqSms,
				BI_PSPB_NotificationConstantsCtrl.actionQsqEmail,
				BI_PSPB_NotificationConstantsCtrl.urlQsqQuestionnaires,
				BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
				communityUserName
			),
			BI_PSPB_NotificationConstantsCtrl.qsqTwo => new BI_PSPB_SmsAndEmailNotificationCtrl(
				BI_PSPB_NotificationConstantsCtrl.actionQsqSms,
				BI_PSPB_NotificationConstantsCtrl.actionQsqEmail,
				BI_PSPB_NotificationConstantsCtrl.urlQsqTwoQuestionnaires,
				BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
				communityUserName
			)
		};
		try {
			// Handle special cases
			Set<String> specialTypes = new Set<String>{
				'TR1333',
				'TR7333',
				'TR100',
				'TR1466'
			};
			if (specialTypes.contains(notificationTypes)) {
				return new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.actionQsqSms,
					BI_PSPB_NotificationConstantsCtrl.actionQsqEmail,
					BI_PSPB_NotificationConstantsCtrl.urlFollower,
					BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker,
					communityUserName
				);
			}
			// Return the details based on notification type
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SmsEmailNotificationHelper.class.getName(),
				ex
			);
		}
		return notificationMap.get(notificationTypes);
	}
	/**
	 * @description  Retrieves notification details based on the given
	 *                notification type and community user names.
	 * @param notificationTypes The ID of the record related to the treatment reminders.
	 * @param communityUserName The type of reminder to filter by.
	 * @param treatmentDate Date to be sent for notification.
	 * @param patientName Date to be sent for notification.
	 * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
	 */
	public static BI_PSPB_SmsAndEmailNotificationCtrl getCaregiverNotificationDetails(
		String notificationTypes,
		List<String> communityUserName,
		String treatmentDate,
		List<String> patientName
	) {
		for (String pn : patientName) {
			// Map to handle notification types
			Map<String, BI_PSPB_SmsAndEmailNotificationCtrl> notificationMap = new Map<String, BI_PSPB_SmsAndEmailNotificationCtrl>{
				BI_PSPB_NotificationConstantsCtrl.generalSymptomTracker => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.symtomTrackerCaregiverOne +
						' ' +
						pn + ' ' +
						BI_PSPB_NotificationConstantsCtrl.symtomTrackerCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.symtomTrackerCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlSymptomTracker,
					BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.generalChallenges => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.challengesCaregiverOne +
						' ' +
						pn + ' ' +
						BI_PSPB_NotificationConstantsCtrl.challengesCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.challengesCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlChallenges,
					BI_PSPB_NotificationConstantsCtrl.actionTypeChallenges,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.generalComment => new BI_PSPB_SmsAndEmailNotificationCtrl(
					'',
					BI_PSPB_NotificationConstantsCtrl.commentCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlMyPost,
					BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.generalCreatePost => new BI_PSPB_SmsAndEmailNotificationCtrl(
					'',
					BI_PSPB_NotificationConstantsCtrl.createPostCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlAllPost,
					BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.generalReaction => new BI_PSPB_SmsAndEmailNotificationCtrl(
					'',
					BI_PSPB_NotificationConstantsCtrl.reactionCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlMyPost,
					BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.generalFollow => new BI_PSPB_SmsAndEmailNotificationCtrl(
					'',
					BI_PSPB_NotificationConstantsCtrl.followCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlFollower,
					BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.video => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.generalVideoSms,
					BI_PSPB_NotificationConstantsCtrl.treatmentVideoCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlFollower,
					BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.actionSymptomTracker => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.actionSymptomCaregiver +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.actionSymptomCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.actionSymptomCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlSymptomTracker,
					BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.treatmentOne => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.ensure +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.treatmentOneDayCaregiver +
						' ' +
						treatmentDate,
					BI_PSPB_NotificationConstantsCtrl.oneDayTreatmentCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.treatmentThree => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.pleaseEnsure +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.treatmentThreeCaregiver +
						' ' +
						treatmentDate,
					BI_PSPB_NotificationConstantsCtrl.threeDayTreatmentCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.treatmentSeven => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.recieved +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.sevenDayCaregiver,
					BI_PSPB_NotificationConstantsCtrl.sevenDayPrescriptionCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.treatmentTen => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.recieved +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.tenDayCaregiver,
					BI_PSPB_NotificationConstantsCtrl.tenDayPrescriptionCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.treatmentFourteen => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.recieved +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.fourteenDayCaregiver,
					BI_PSPB_NotificationConstantsCtrl.fourteenDayPrescriptionCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.pastDueDateZero => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.dateTreatCaregiverOne +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.dateTreatCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.dateOfTreatmentCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.pastDueDateOne => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.twentyFourCaregiverOne +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.twentyFourCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.pastTwentyFourCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.pastDueDateThree => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.twentyFourCaregiverOne +
						' ' +
						pn +
						' ' +
						BI_PSPB_NotificationConstantsCtrl.seventyTwoCaregiverTwo +
						' ' +
						treatmentDate +
						' ' +
						BI_PSPB_NotificationConstantsCtrl.pastTwentySubject,
					BI_PSPB_NotificationConstantsCtrl.pastSeventyTwoCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDashboard,
					BI_PSPB_NotificationConstantsCtrl.treatmentAndRx,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.dlqi => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.dlqiCaregiverOne +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.dlqiCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.dlqiCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlDlqiQuestionnaires,
					BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.pss => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.pssCaregiverOne +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.pssCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.pssCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlPssQuestionnaires,
					BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.wpai => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.wpaiCaregiverOne +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.wpaiCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.wpaiCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlWpaiQuestionnaires,
					BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.qsq => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.qsqCaregiverOne +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.qsqCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.qsqCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlQsqQuestionnaires,
					BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
					communityUserName
				),
				BI_PSPB_NotificationConstantsCtrl.qsqTwo => new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.qsqCaregiverOne +
						' ' +
						pn +
						BI_PSPB_NotificationConstantsCtrl.qsqCaregiverTwo,
					BI_PSPB_NotificationConstantsCtrl.qsqCaregiverEmailTemplate,
					BI_PSPB_NotificationConstantsCtrl.urlQsqTwoQuestionnaires,
					BI_PSPB_NotificationConstantsCtrl.notificationQuestionaries,
					communityUserName
				)
			};
			return notificationMap.get(notificationTypes);
		}
		try {
			// Handle special cases
			Set<String> specialTypes = new Set<String>{
				'TR1333',
				'TR7333',
				'TR100',
				'TR1466'
			};
			if (specialTypes.contains(notificationTypes)) {
				return new BI_PSPB_SmsAndEmailNotificationCtrl(
					BI_PSPB_NotificationConstantsCtrl.actionQsqSms,
					BI_PSPB_NotificationConstantsCtrl.actionQsqEmail,
					BI_PSPB_NotificationConstantsCtrl.urlFollower,
					BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker,
					communityUserName
				);
			}
			// Return the details based on notification type
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_SmsEmailNotificationHelper.class.getName(),
				ex
			);
		}
		return null;
	}

	/**
	 * @description  Adds contacts to be notified via email or SMS based on
	 *                the notification settings for the enrollees and caregivers.
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
				Date birthdate = (Date) caregiver.getSObject(
						'BI_PSPB_Patient__r'
					)
					.get('BI_PSP_Birthdate__c');
				Integer age = BI_PSPB_EnrolleeQueryHelper.getAge(birthdate);
				if (!BI_PSPB_EnrolleeQueryHelper.isLegalAge(age)) {
					Id patientId = (Id) caregiver.getSObject(
							'BI_PSPB_Care_Program_Enrollee__r'
						)
						.get('Id');
					processNotifications(
						accountToNotificationsMap.get(patientId),
						(Id) caregiver.getSObject('BI_PSPB_Caregiver__r')
							.get('PersonContactId'),
						emailList,
						smsList
					);
				}
			}

			// Process caregivers
			for (SObject caregiver : caregivers) {
				Date birthdate = (Date) caregiver.getSObject(
						'BI_PSPB_Patient__r'
					)
					.get('BI_PSP_Birthdate__c');
				Integer age = BI_PSPB_EnrolleeQueryHelper.getAge(birthdate);
				if (BI_PSPB_EnrolleeQueryHelper.isLegalAge(age)) {
					Id patientId = (Id) caregiver.getSObject(
							'BI_PSPB_Care_Program_Enrollee__r'
						)
						.get('Id');
					processNotifications(
						accountToNotificationsMap.get(patientId),
						(Id) caregiver.getSObject('BI_PSPB_Caregiver__r')
							.get('PersonContactId'),
						emailList,
						smsList
					);
				}
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
}