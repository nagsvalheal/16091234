/**
* @description  Schedules and executes tasks related to symptom notifications.
*				Specifically, it creates tasks when a video is uploaded and triggers
*				methods to send SMS and email notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/ 
public with sharing class BI_PSPB_SymptomNotificationSched implements Schedulable {
/**
 * @description  Executes the scheduled job, which involves creating tasks for video
 *				 uploads and invoking methods to send SMS and email notifications.
 * @param ctx The context in which the job is executed.
*/
public void execute(SchedulableContext ctx) {
	try {
		BI_PSPB_SymptomNotificationCtrl.processSymptomNotifications();
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.logError(
			ex.getMessage(),
			BI_PSPB_SymptomNotificationSched.class.toString()
			,false
			,BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
}
}