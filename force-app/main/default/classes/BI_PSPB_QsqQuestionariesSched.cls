/**
* @description  This class implements the Schedulable interface to create
*               a task that triggers when a video is uploaded. It calls the
*               method to process questionnaires and sends SMS and email
*               notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_QsqQuestionariesSched implements Schedulable {
/**
* @description  Executes the scheduled job to process questionnaires.
*               It invokes the BI_PSPB_QsqQuestionariesSched
*               class to handle the processing and send SMS and email
*               notifications.
* @param ctx The context in which the job is executed.
*/
public void execute(SchedulableContext ctx) {
	try {
		BI_PSPB_QsqQuestionnaireActionCtrl.processQsqQuestionnaires();
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.logError(
			ex.getMessage(),
			BI_PSPB_QsqQuestionariesSched.class.toString()
			,false
			,BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
	}
}