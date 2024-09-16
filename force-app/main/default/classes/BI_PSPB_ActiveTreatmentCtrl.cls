/**
* @description  This class is used to create tasks when a video is uploaded.
* It also handles calling methods to send SMS and email notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public class BI_PSPB_ActiveTreatmentCtrl {
    /**
	 * @description Retrieves active treatment reminders based on the given date.
	 * @param today The date for which active reminders are retrieved.
	 * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
	 */
	public static List<BI_PSPB_Treatment_Reminder__c> getActiveReminders(
		Date today
	) {
		String formattedDate = DateTime.newInstance(
				today,
				Time.newInstance(0, 0, 0, 0)
			)
			.format('yyyy-MM-dd');
		String fields = 'BI_PSPB_Care_Program_Enrollee__c, BI_PSPB_Care_Program_Enrollee__r.AccountId, BI_PSPB_Reminder_Date__c, BI_PSPB_Date_of_Treatment__c, BI_PSPB_Care_Program_Enrollee__r.Account.BI_PSP_Birthdate__c, BI_PSPB_Care_Program_Enrollee__r.Account.Name';
		String conditions =
			'BI_PSPB_Reminder_Date__c = ' +
			formattedDate +
			' ' +
			'AND BI_PSPB_Status__c = \'' +
			BI_PSPB_NotificationConstantsCtrl.actionTypeActive +
			'\' ' +
			'AND (BI_PSPB_Reminder_Type__c = \'' +
			BI_PSPB_NotificationConstantsCtrl.actionTypeTreatment +
			'\' ' +
			'OR BI_PSPB_Reminder_Type__c = \'' +
			BI_PSPB_NotificationConstantsCtrl.actionTypePrescription +
			'\' )';
		List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
			'BI_PSPB_Treatment_Reminder__c',
			fields,
			conditions,
			false
		);
		return (List<BI_PSPB_Treatment_Reminder__c>) results;
	}
}