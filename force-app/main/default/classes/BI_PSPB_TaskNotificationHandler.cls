/**
 * @description To send email when a post is being created.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_TaskNotificationHandler {
	/**
	 * @description  Retrieves treatment reminders based on the given criteria.
	 * @param enrolleeRecords The ID of the record related to the treatment reminders.
	 * @param context The type of reminder to filter by.
	 */
	public static void handleNotifications(
		List<CareProgramEnrollee> enrolleeRecords,
		BI_PSPB_NotificationContext context
	) {
		if (
			context.category ==
			BI_PSPB_NotificationConstantsCtrl.actionTypeGeneralCommunity &&
			context.notificationType ==
			BI_PSPB_NotificationConstantsCtrl.actionTypeGeneral
		) {
			handleGeneralCommunityNotifications(context);
		} else if (
			context.category ==
			BI_PSPB_NotificationConstantsCtrl.actionTypeChallenges &&
			context.notificationType ==
			BI_PSPB_NotificationConstantsCtrl.actionTypeGeneral
		) {
			BI_PSPB_TaskRecordCtrl.handleTriggerWithMessage(
				context.recordId,
				BI_PSPB_NotificationConstantsCtrl.generalChallenges,
				new List<String>{ '' }
			);
		} else if (
			context.category ==
			BI_PSPB_NotificationConstantsCtrl.actionTypeSymptomTracker &&
			context.notificationType ==
			BI_PSPB_NotificationConstantsCtrl.actionTypeGeneral
		) {
			BI_PSPB_TaskRecordCtrl.handleTriggerWithMessage(
				context.recordId,
				BI_PSPB_NotificationConstantsCtrl.generalSymptomTracker,
				new List<String>{ '' }
			);
        } else {
            BI_PSPB_TaskRecordCtrl.handleTriggerWithMessage(
				null,
				null,
				new List<String>{ '' }
			);
        }
	}
	/**
	 * @description  Retrieves treatment reminders based on the given criteria.
	 * @param context The type of reminder to filter by.
	 */
	private static void handleGeneralCommunityNotifications(
		BI_PSPB_NotificationContext context
	) {
		Map<String, String> chatterTypeToMessageMap = new Map<String, String>{
			BI_PSPB_NotificationConstantsCtrl.comment => BI_PSPB_NotificationConstantsCtrl.generalComment,
			BI_PSPB_NotificationConstantsCtrl.reaction => BI_PSPB_NotificationConstantsCtrl.generalReaction,
			BI_PSPB_NotificationConstantsCtrl.follow => BI_PSPB_NotificationConstantsCtrl.generalFollow
		};

		String messageType = chatterTypeToMessageMap.get(context.chatterType);

		if (messageType != null) {
			BI_PSPB_TaskRecordCtrl.handleTriggerWithMessage(
				context.recordId,
				messageType,
				context.communityUserName
			);
		}
	}
}