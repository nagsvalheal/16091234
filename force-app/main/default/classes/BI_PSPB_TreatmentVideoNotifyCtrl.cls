/**
* @description Controller for handling video upload notifications. Creates
*                tasks for enrollees and triggers SMS and email notifications
*                upon video upload.
* @history
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_TreatmentVideoNotifyCtrl {
/**
* @description   Creates tasks for all enrollees when a video is uploaded.
*                Also triggers SMS and email notifications.
*/
public static void taskForTreatmentVideo() {
	try {
		List<SObject> enrolleeRecords = BI_PSP_CommonQueryUtility.executeQuery(
			'CareProgramEnrollee',
			'Id',
			null,
			false
		);
		if (enrolleeRecords.isEmpty()) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_TreatmentVideoNotifyCtrl.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
			return;
		}
		List<Id> enrolleeIdss = new List<Id>();
		for (SObject enrollee : enrolleeRecords) {
			enrolleeIdss.add((Id) enrollee.get('Id'));
		}
		BI_PSPB_TaskParameters params = new BI_PSPB_TaskParameters(
			BI_PSPB_NotificationConstantsCtrl.generalDemonstrationVideoSubject,
			BI_PSPB_NotificationConstantsCtrl.actionTypeGeneral,
			BI_PSPB_NotificationConstantsCtrl.treatmentVideo,
			'',
			BI_PSPB_NotificationConstantsCtrl.actionTypeUnRead
		);
		List<Task> newTaskList = BI_PSPB_TaskCreationCtrl.createTasks(
			enrolleeIdss,
			params
		);
		if (newTaskList.isEmpty()) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_TreatmentVideoNotifyCtrl.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
			return;
		}

		BI_PSP_DatabaseOperationsUtility.insertOperation(
			newTaskList,
			BI_PSPB_TreatmentVideoNotifyCtrl.class.toString(),
			false
		);

		List<Id> enrolleeIds = collectEnrolleeIds(enrolleeRecords);
		if (!enrolleeIds.isEmpty()) {
			BI_PSPB_NotificationSender.sendNotifications(
				enrolleeIds,
				BI_PSPB_NotificationConstantsCtrl.video,
				new List<String>{''}
			);
		}
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_TreatmentVideoNotifyCtrl.class.getName(),
			ex
		);
	}
}

/**
 * @description   Extracts and returns the list of enrollee IDs from the 
 *                provided enrollee records.
 * @param enrolleeRecords List of enrollees.
 * @return Returning list of Ids
 */
private static List<Id> collectEnrolleeIds(
	List<CareProgramEnrollee> enrolleeRecords
) {
	List<Id> enrolleeIds = new List<Id>();
	try {
		for (CareProgramEnrollee enrollee : enrolleeRecords) {
			enrolleeIds.add(enrollee.Id);
		}
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_EnrollmentConsent.class.getName(),
			ex
		);
	}
	return enrolleeIds;
}
}