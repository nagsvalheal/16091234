/**
 * @description This class represents the context for sending notifications
 * within the BI_PSPB module. It includes details such as the category and
 * type of notification, the type of community chatter, usernames involved,
 * and record IDs associated with the notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_NotificationContext {
	public String category;
	public String notificationType;
	public String chatterType;
	public List<String> communityUserName;
	public List<Id> recordId;
	/**
	 * @description Constructor to initialize the notification context with
	 * the specified category, notification type, chatter type, community
	 * usernames, and record IDs.
	 * @param category Category of the notification
	 * @param notificationType Type of the notification
	 * @param chatterType Type of community notification
	 * @param communityUserName username of the user
	 * @param recordId Id of the record that the notification to be sent
	 */
	public BI_PSPB_NotificationContext(
		String category,
		String notificationType,
		String chatterType,
		List<String> communityUserName,
		List<Id> recordId
	) {
		this.category = category;
		this.notificationType = notificationType;
		this.chatterType = chatterType;
		this.communityUserName = communityUserName;
		this.recordId = recordId;
	}
}