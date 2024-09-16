/**
* @description  This class is used to schedule a job that creates a task when 
* a video is uploaded and also calls methods to send SMS and email 
* notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_TreatmentPastRemindersSched implements Schedulable {
/**
* @description Schedules a job that processes past due reminders when a 
* post is created in the community.
* @param sc The context in which the job is executed.
*/
public void execute(SchedulableContext sc) {
	try {
		BI_PSPB_PastDueNotificationCtrl.processPastDueReminders();
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.logError(
			ex.getMessage(),
			BI_PSPB_TreatmentPastRemindersSched.class.toString()
			,false
			,BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
}
}