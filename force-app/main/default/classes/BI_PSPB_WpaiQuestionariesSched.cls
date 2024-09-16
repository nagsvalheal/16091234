/**
* @description This class is used to schedule a job that processes
*              WPai questionaries. When scheduled, it calls the
*              BI_PSPB_WpaiQuestionnaireActionCtrl to handle the
*              processing. Any errors encountered during execution are
*              logged using the BI_PSP_LogMessagesUtility.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_WpaiQuestionariesSched implements Schedulable {
/**
* @description Schedules a job for processing WPai questionaries.
*               This method is invoked when the scheduled job executes.
* @param ctx The context in which the job is executed.
*/
public void execute(SchedulableContext ctx) {
	try {
		BI_PSPB_WpaiQuestionnaireActionCtrl.processWpaiQuestionnaires();
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