/**
* @description  This class implements the Schedulable interface to create a task when
* a video is uploaded. It invokes a method to process questionnaires and
* handles exceptions by logging error messages.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_PssQuestionariesSched implements Schedulable {
/**
* @description  This method is executed as part of the scheduled job. It processes
* the questionnaires by calling the method from the service controller.
* Any exceptions encountered during execution are logged with error
* severity.
* @param ctx The context in which the job is executed.
*/
public void execute(SchedulableContext ctx) {
	try {
		BI_PSPB_PssQuestionnaireActionCtrl.processPssQuestionnaires();
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.logError(
			ex.getMessage(),
			BI_PSPB_PssQuestionariesSched.class.toString()
			,false
			,BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
}
}