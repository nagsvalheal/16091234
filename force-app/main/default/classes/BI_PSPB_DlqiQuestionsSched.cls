/**
* @description  This class schedules a job to create a task when a video
* is uploaded. It also calls a method to send SMS and email notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_DlqiQuestionsSched implements Schedulable {
/**
* @description  Executes the scheduled job to process WPai questionnaires.
* This involves creating a task when a video is uploaded and sending 
* SMS and email notifications.
* @param ctx The context in which the job is executed.
*/
public void execute(SchedulableContext ctx) {
	try {
		BI_PSPB_DlqiQuestionnaireActionCtrl.processDlqiQuestionnaires();
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.logError(
			ex.getMessage(),
			BI_PSPB_DlqiQuestionsSched.class.toString()
			,false
			,BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
}
}