/**
* @description  This class provides methods to handle PSS
related operations. It processes questionnaires
when videos are uploaded, creates tasks, and sends notifications (SMS and
email) as needed.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_PssQuestionnaireActionCtrl {
    /**
    * @description Processes PSS questionnaires by creating tasks and sending notifications
    * when a video is uploaded.
    */
    public static void processPssQuestionnaires() {
        try {
            Set<Id> enrolleeIds = BI_PSPB_EnrolleeProcessorCtrl.fetchEnrolleeIds();
            
            if (!enrolleeIds.isEmpty()) {
                Integer pssCount = BI_PSPB_QuestionsDaysCountQueryCtrl.fetchPssCount();
                List<Id> enrolleeRecIds = BI_PSPB_SymptomProcessorCtrl.processSymptomTrackers(enrolleeIds, pssCount);

                if (enrolleeRecIds.isEmpty()) {
                    BI_PSP_LogMessagesUtility.logError(
                    BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
                    BI_PSPB_PssQuestionnaireActionCtrl.class.toString(),
                    false,
                    BI_PSPB_NotificationConstantsCtrl.severityError
                    );
                }
                    List<CareProgramEnrollee> enrolleeRecords = BI_PSPB_EnrolleeProcessorCtrl.fetchEnrolleeRecords(enrolleeRecIds);
                    if(!enrolleeRecords.isEmpty()){
                        processEnrollees(enrolleeRecords);
                    }
                }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
                ex.getMessage(),
                BI_PSPB_PssQuestionnaireActionCtrl.class.toString(),
                false,
                BI_PSPB_NotificationConstantsCtrl.severityError
            );
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

        BI_PSP_DatabaseOperationsUtility.insertOperation(newTaskList, BI_PSPB_PssQuestionnaireActionCtrl.class.toString(), false);
        
        sendNotifications(sendNotificationIds);
    }
    /**
     * @description Processes a single CareProgramEnrollee record to create tasks based on the 
     * enrollee's age and caregiver status.
     * @param enrollee Enrollee record to process.
     * @param newTaskList List of tasks to add to.
     * @return List<Id> Id of the enrollees.
     */
    public static List<Id> processEnrollee(CareProgramEnrollee enrollee, List<Task> newTaskList) {
        List<Id> enrolleeEmailIds = new List<Id>();
        try {
            Date today = Date.today();
            Integer age = BI_PSPB_EnrolleeProcessorCtrl.calculateAge(enrollee.Account.BI_PSP_Birthdate__c, today);
            String patientName = enrollee.Account.Name;
            Id enrolleeId = enrollee.Id;
            Id caregiverId = BI_PSPB_CaregiverProcessorCtrl.fetchCaregiverId(enrolleeId);

            // Fetch due assessments for enrollee and caregiver
            List<Id> enrolleeSendIds = BI_PSPB_AssessmentProcessorCtrl.fetchDueAssessments(new List<Id>{enrolleeId}, BI_PSPB_NotificationConstantsCtrl.pssQuestionName);

            // Process patient tasks
            if (age > 18 && caregiverId == null && !enrolleeSendIds.isEmpty()) {
                enrolleeEmailIds.addAll(enrolleeSendIds);
                BI_PSPB_TaskParameterCtrl params = new BI_PSPB_TaskParameterCtrl(
                    BI_PSPB_NotificationConstantsCtrl.pssQuestionSubject,
                    BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
                    BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
                    '',
                    BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
                );
                newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createPatientTasks(enrolleeSendIds, params, BI_PSPB_NotificationConstantsCtrl.patient, null));
            } else {
				List<Id> caregiverSendIds = BI_PSPB_AssessmentProcessorCtrl.fetchDueAssessments(new List<Id>{enrolleeId}, BI_PSPB_NotificationConstantsCtrl.pssQuestionName);
            // Process caregiver tasks
            if (!caregiverSendIds.isEmpty()) {
                enrolleeEmailIds.addAll(caregiverSendIds);
                BI_PSPB_TaskParameterCtrl params = new BI_PSPB_TaskParameterCtrl(
                    BI_PSPB_NotificationConstantsCtrl.pssQuestionSubject,
                    BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
                    BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
                    '',
                    BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
                );
                newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createPatientTasks(caregiverSendIds, params, BI_PSPB_NotificationConstantsCtrl.patient, caregiverId));

                BI_PSPB_TaskParameterCtrl caregiverParams = new BI_PSPB_TaskParameterCtrl(
                    BI_PSPB_NotificationConstantsCtrl.pssCaregiverOne + ' ' + patientName + BI_PSPB_NotificationConstantsCtrl.pssCaregiverTwo,
                    BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
                    BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
                    '',
                    BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
                );
                newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createCaregiverTasks(caregiverSendIds, caregiverParams, BI_PSPB_NotificationConstantsCtrl.caregiver, caregiverId));
            }
		}
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
                ex.getMessage(),
                BI_PSPB_PssQuestionnaireActionCtrl.class.toString(),
                false,
                BI_PSPB_NotificationConstantsCtrl.severityError
            );
        }
        return enrolleeEmailIds;
    }

    /**
    * @description Sends SMS and email notifications.
    * @param enrolleeEmailIds Enrollee Ids for the notification to e sent.
    */
    public static void sendNotifications(List<Id> enrolleeEmailIds) {
        try {
            if (!enrolleeEmailIds.isEmpty()) {
                BI_PSPB_NotificationSender.sendNotifications(enrolleeEmailIds, BI_PSPB_NotificationConstantsCtrl.pss, new List<String>{''});
            }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                ex.getMessage(),
                BI_PSPB_PssQuestionnaireActionCtrl.class.getName(),
                ex
            );
        }
    }
}