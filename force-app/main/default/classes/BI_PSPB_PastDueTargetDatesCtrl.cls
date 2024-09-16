/**
 * @description Handles the creation of tasks when a video is uploaded and sends SMS
 * and email notifications. This class processes reminders and manages
 * associated tasks and notifications..
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_PastDueTargetDatesCtrl {
	/**
	 * @description  Retrieves a map of treatment reminders grouped by their due dates. This method
	 *                filters and returns a list of BI_PSPB_Treatment_Reminder__c records for each
	 *                date in the specified set of target dates.
	 * @param targetDates A set of dates representing the target dates for which treatment reminders
	 *                    need to be retrieved. The method will return reminders that match these dates.
	 * @return A map where each key is a Date from the targetDates set, and the corresponding value
	 *         is a list of BI_PSPB_Treatment_Reminder__c records associated with that date.
	 */
	public static Map<Date, List<BI_PSPB_Treatment_Reminder__c>> getTreatmentRecords(
		Set<Date> targetDates
	) {
		Map<Date, List<BI_PSPB_Treatment_Reminder__c>> remindersByDate = new Map<Date, List<BI_PSPB_Treatment_Reminder__c>>();
		try {
			// Null check for targetDates
			if (targetDates == null) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_PastDueTargetDatesCtrl.class.toString(),
					true,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
				return remindersByDate;
			}
			// Convert Set<Date> to a List<Date>
			List<Date> targetDatesList = new List<Date>(targetDates);

			/// Convert List<Date> to a comma-separated string in 'YYYY-MM-DD' format
			List<String> formattedDates = new List<String>();
			for (Date targetDate : targetDatesList) {
				DateTime dt = DateTime.newInstance(
					targetDate,
					Time.newInstance(0, 0, 0, 0)
				);
				formattedDates.add(dt.format('yyyy-MM-dd'));
			}
			String fields = 'BI_PSPB_Care_Program_Enrollee__c, BI_PSPB_Reminder_Type__c, BI_PSPB_Date_of_Treatment__c, BI_PSPB_Care_Program_Enrollee__r.Account.BI_PSP_Birthdate__c,BI_PSPB_Care_Program_Enrollee__r.Account.Name';
			// Convert List<Id> to a comma-separated string for the query
			String conditionIds = '(' + String.join(formattedDates, ', ') + ')';
			String conditions =
				'BI_PSPB_Date_of_Treatment__c IN ' +
				conditionIds +
				' ' +
				'AND BI_PSPB_Reminder_Type__c = \'' +
				'Date of Treatment' +
				'\' ' +
				'AND BI_PSPB_Status__c = \'' +
				BI_PSPB_NotificationConstantsCtrl.actionTypeActive +
				'\' ';

			// Execute the query using the BI_PSP_CommonQueryUtility class
			List<SObject> records = BI_PSP_CommonQueryUtility.executeQuery(
				'BI_PSPB_Treatment_Reminder__c',
				fields,
				conditions,
				false
			);

			// Null check for the records list
			if (records.isEmpty()) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_PastDueNotificationCtrl.class.toString(),
					true,
					BI_PSPB_NotificationConstantsCtrl.severityError
				);
				return remindersByDate;
			}

			for (SObject record : records) {
				BI_PSPB_Treatment_Reminder__c treatmentReminder = (BI_PSPB_Treatment_Reminder__c) record;
				Date treatmentDate = treatmentReminder.BI_PSPB_Date_of_Treatment__c;

				if (!remindersByDate.containsKey(treatmentDate)) {
					remindersByDate.put(
						treatmentDate,
						new List<BI_PSPB_Treatment_Reminder__c>()
					);
				}
				remindersByDate.get(treatmentDate).add(treatmentReminder);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_PastDueNotificationCtrl.class.toString(),
				true,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
		return remindersByDate;
	}
}