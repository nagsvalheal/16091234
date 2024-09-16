/**
* @description  This class is responsible for creating a task when a video
*               is uploaded and for calling the methods to send SMS and email
*               notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public without sharing class BI_PSPB_TaskQuestionStatusCompleted {
/**
 * @description  Marks tasks as completed based on the assessment status
 *               related to the enrollee.
 * @return List<Task> Make questions completed status.
 */
@AuraEnabled
public static List<Task> markTaskQuestionCompleted() {
	List<Task> tasksToUpdate = new List<Task>();
	try {
		String enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].id;
		Map<Id, Map<String, String>> enrolleeRecIdToAssessmentNamesMap = BI_PSPB_QuestionAssessmentService.getEnrolleeRecIdToAssessmentNamesMap(
			enrolleeId
		);
		tasksToUpdate = BI_PSPB_QuestionTaskService.getTasksToUpdate(
			enrolleeRecIdToAssessmentNamesMap
		);
		if (!tasksToUpdate.isEmpty()) {
			BI_PSP_DatabaseOperationsUtility.updateOperation(
				tasksToUpdate,
				BI_PSPB_TaskQuestionStatusCompleted.class.toString(),
				false
			);
		} else {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_TaskQuestionStatusCompleted.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			'',
			BI_PSPB_TaskQuestionStatusCompleted.class.getName(),
			ex
		);
	}
	return tasksToUpdate;
}
}