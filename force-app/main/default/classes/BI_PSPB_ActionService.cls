/**
* @description  This class is responsible for creating tasks when a video is 
* uploaded and for calling methods to send SMS and email notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public without sharing class BI_PSPB_ActionService {
	/**
	 * @description  Retrieves treatment reminders based on the given criteria.
	 * @param whatId The ID of the record related to the treatment reminders.
	 * @param reminderType The type of reminder to filter by.
	 * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
	 */
    @AuraEnabled(cacheable=false)
	public static List<BI_PSPB_Treatment_Reminder__c> getTreatmentReminders(
		List<Id> whatId,
		String reminderType
	) {
        String listOfIds = '(\'' + String.join(whatId, '\', \'') + '\')';
		String fields = 'Id, BI_PSPB_Status__c, BI_PSPB_Reminder_Date__c, BI_PSPB_Care_Program_Enrollee__c, BI_PSPB_Reminder_Type__c';
		String conditions =
			'Id IN' + 
			listOfIds +
			'AND BI_PSPB_Status__c = \'' +
			BI_PSPB_NotificationConstantsCtrl.actionTypeActive +
			'\' ' +
			'AND BI_PSPB_Reminder_Type__c = \'' +
			reminderType +
			'\' ' +
			' ORDER BY BI_PSPB_Reminder_Date__c DESC ';

		// Execute query and return results as List<Task>
		List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
			'BI_PSPB_Treatment_Reminder__c',
			fields,
			conditions,
			false
		);
		return (List<BI_PSPB_Treatment_Reminder__c>) results;
	}
	/**
	 * @description  Retrieves treatment reminders based on the given criteria.
	 * @param whatId The ID of the record related to the treatment reminders.
	 * @param reminderType The type of reminder to filter by.
	 * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
	 */
    @AuraEnabled(cacheable=false)
	public static List<BI_PSPB_Treatment_Reminder__c> getDateOfTreatmentReminder(
		List<Id> whatId,
		String reminderType
	) {
        String listOfIds = '(\'' + String.join(whatId, '\', \'') + '\')';
		String fields = 'Id, BI_PSPB_Status__c, BI_PSPB_Reminder_Date__c, BI_PSPB_Care_Program_Enrollee__c, BI_PSPB_Reminder_Type__c';
		String conditions =
			'Id IN' +
			listOfIds +
			'AND BI_PSPB_Status__c = \'' +
			BI_PSPB_NotificationConstantsCtrl.actionTypeActive +
			'\' ' +
			'AND BI_PSPB_Reminder_Type__c = \'' +
			reminderType +
			'\' ' +
			' ORDER BY BI_PSPB_Reminder_Date__c DESC';

		// Execute query and return results as List<Task>
		List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
			'BI_PSPB_Treatment_Reminder__c',
			fields,
			conditions,
			false
		);
		return (List<BI_PSPB_Treatment_Reminder__c>) results;
	}
}