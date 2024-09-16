/**
* @description  This class provides methods to handle WPAI
related operations. It processes questionnaires
when videos are uploaded, creates tasks, and sends notifications (SMS and
email) as needed.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_WpaiQuestionnaireActionCtrl {
	/**
	* @description  Processes wpai questionnaires by creating tasks for due
	* assessments when a video is uploaded. It also sends notifications (SMS
	* and email) to the relevant parties.
	*/
    public static void processWpaiQuestionnaires() {
        try {
            Set<Id> enrolleeIds = 
                BI_PSPB_EnrolleeProcessorCtrl.fetchEnrolleeIds();                
            if (enrolleeIds.isEmpty()) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
					BI_PSPB_WpaiQuestionnaireActionCtrl.class.toString(),
					false, BI_PSPB_NotificationConstantsCtrl.severityError);
			}
                Integer wpaiCount = BI_PSPB_QuestionsDaysCountQueryCtrl.fetchWpaiCount();
                List<Id> enrolleeRecIds = BI_PSPB_SymptomProcessorCtrl.processSymptomTrackers(enrolleeIds, wpaiCount);
                if (!enrolleeRecIds.isEmpty()) {
                    List<CareProgramEnrollee> enrolleeRecords = 
						BI_PSPB_EnrolleeProcessorCtrl.fetchEnrolleeRecords(enrolleeRecIds);
					if(!enrolleeRecords.isEmpty()){
						processEnrollees(enrolleeRecords);
					}
                }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_WpaiQuestionnaireActionCtrl.class.toString(), false,
				BI_PSPB_NotificationConstantsCtrl.severityError);
        }
    }
	/**
	* @description This method processes list of enrollees and create tasks.
	* @param enrolleeRecords Enrollee for the notifications to be sent.
    */
	private static void processEnrollees(List<CareProgramEnrollee> enrolleeRecords){
		List<Task> newTaskList = new List<Task>();
		List<Id> sendNotificationIds = new List<Id>();
		for (CareProgramEnrollee enrollee : enrolleeRecords) {
			List<Id> enrolleeEmailIds = processEnrollee(enrollee, newTaskList);
			if(!enrolleeEmailIds.isEmpty()){
			sendNotificationIds.addAll(enrolleeEmailIds);
			}
		}
		BI_PSP_DatabaseOperationsUtility.insertOperation(newTaskList, BI_PSPB_WpaiQuestionnaireActionCtrl.class.toString(), false);
		sendNotifications(sendNotificationIds);
	}
	/**
	* @description This method processes a single CareProgramEnrollee record to create and
    add tasks to the newTaskList based on the enrollee's age and caregiver status.
	* @param enrollee Enrollee for the questions to retrieve.
    * @param newTaskList List of tasks that are to be created.
	* @return List<Id> List of enrollee ids.
    */
    public static List<Id> processEnrollee(CareProgramEnrollee enrollee, List<Task> newTaskList) {
		List<Id> enrolleeEmailIds = new List<Id>();
		try {
			Date today = Date.today();
			Integer age = BI_PSPB_EnrolleeProcessorCtrl.calculateAge(enrollee.Account.BI_PSP_Birthdate__c, today);
            String patientName = enrollee.Account.Name;
			Id enrolleeId = enrollee.Id;
			Id caregiverId = BI_PSPB_CaregiverProcessorCtrl.fetchCaregiverId(enrolleeId);
			List<Id> enrolleeSendIds = BI_PSPB_AssessmentProcessorCtrl.fetchDueAssessments(new List<Id>{enrolleeId}, BI_PSPB_NotificationConstantsCtrl.wpaiQuestionName);
            if ((age > 18 && caregiverId == null) && !enrolleeSendIds.isEmpty()) {
				enrolleeEmailIds.addAll(enrolleeSendIds);
					BI_PSPB_TaskParameterCtrl params = new BI_PSPB_TaskParameterCtrl(
						BI_PSPB_NotificationConstantsCtrl.wpaiQuestionSubject,
						BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
						BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
						'',
						BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
					);
					newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createPatientTasks(enrolleeSendIds, params, BI_PSPB_NotificationConstantsCtrl.patient, null));
			} else {
				List<Id> caregiverSendIds = BI_PSPB_AssessmentProcessorCtrl.fetchDueAssessments(new List<Id>{enrolleeId}, BI_PSPB_NotificationConstantsCtrl.wpaiQuestionName);
				if (!caregiverSendIds.isEmpty()) {
					enrolleeEmailIds.addAll(caregiverSendIds);
					BI_PSPB_TaskParameterCtrl params = new BI_PSPB_TaskParameterCtrl(
						BI_PSPB_NotificationConstantsCtrl.wpaiQuestionSubject,
						BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
						BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
						'',
						BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
					);
					newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createPatientTasks(caregiverSendIds, params, BI_PSPB_NotificationConstantsCtrl.patient, caregiverId));

					BI_PSPB_TaskParameterCtrl params2 = new BI_PSPB_TaskParameterCtrl(
						BI_PSPB_NotificationConstantsCtrl.wpaiCaregiverOne + ' ' + patientName + BI_PSPB_NotificationConstantsCtrl.wpaiCaregiverTwo,
						BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
						BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
						'',
						BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
					);
					newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createCaregiverTasks(caregiverSendIds, params2, BI_PSPB_NotificationConstantsCtrl.caregiver, caregiverId));
				}
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_WpaiQuestionnaireActionCtrl.class.toString(), false,
				BI_PSPB_NotificationConstantsCtrl.severityError);
		}
		return enrolleeEmailIds;
    }
	/**
	* @description Method is used to send SMS and email notification.
	* @param enrolleeEmailIds Ids for sending notifications.
    */
    public static void sendNotifications(List<Id> enrolleeEmailIds) {
		try{
			if (!enrolleeEmailIds.isEmpty()) {
				BI_PSPB_NotificationSender.sendNotifications(enrolleeEmailIds, BI_PSPB_NotificationConstantsCtrl.wpai, new List<String>{''});
			}
		} catch (Exception ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                ex.getMessage(),
                BI_PSPB_NotificationSetting.class.getName(),
                ex
            );
        }	
    }
}