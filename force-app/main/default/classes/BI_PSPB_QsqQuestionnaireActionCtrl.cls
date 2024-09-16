/**
 * @description  This class handles the creation of tasks when a video is uploaded.
 * It also includes methods for sending SMS and email notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_QsqQuestionnaireActionCtrl {
	/**
	* @description  Processes the creation of tasks for enrollees when questionnaires
	* are uploaded. It also handles the invocation of methods to send SMS and email
	* notifications based on the processed questionnaire data.
	*/
	public static void processQsqQuestionnaires() {
		try {
			Integer qsqCount = BI_PSPB_QuestionsDaysCountQueryCtrl.fetchQsqCount();
			Integer qsqTwoCount = BI_PSPB_QuestionsDaysCountQueryCtrl.fetchQsqTwoCount();
			List<Id> enrolleeQsqOneIds = processEnrollees(
				qsqCount
			);
			if (!enrolleeQsqOneIds.isEmpty()) {
				processQsq(
					enrolleeQsqOneIds,
					BI_PSPB_NotificationConstantsCtrl.qsqQuestionName,
					BI_PSPB_NotificationConstantsCtrl.qsq,
					BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
				);
			}
			List<Id> enrolleeQsqTwoIds = processEnrollees(
				qsqTwoCount
			);

			if (!enrolleeQsqTwoIds.isEmpty()) {
				processQsq(
					enrolleeQsqTwoIds, BI_PSPB_NotificationConstantsCtrl.qsqQuestionName,
                    BI_PSPB_NotificationConstantsCtrl.qsq,
					BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_QsqQuestionnaireActionCtrl.class.toString(),
				true,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
	}

	/**
	 * @description    Creates tasks for the provided list of enrollee IDs and initiates
	 * methods to send SMS and email notifications. Handles the creation of tasks and
	 * logging if no records are found or if an error occurs.
	 * @param enrolleeQsqIds A list of enrollee IDs that need to be processed. This list should not be null or empty.
	 * @param questionName The name of the question related to the assessment. This is used for fetching due assessments.
	 * @param notificationType The type of notification to be sent (e.g., SMS, email). This determines the type of notification that will be sent.
	 * @param actionType The type of action being performed. This is used to categorize or specify the nature of the action.
	 */
	public static void processQsq(
		List<Id> enrolleeQsqIds,
		String questionName,
		String notificationType,
		String actionType
	) {
		try {
            Date today = Date.today();
            List<Task> newTaskList = new List<Task>();
            List<Id> patientEnrolleeIds = new List<Id>();
    		List<Id> caregiverEnrolleeIds = new List<Id>();
            List<Id> enrolleeSendQsqIds = new List<Id>();
            List<Id> caregiverSendIds = new List<Id>();
			if (!enrolleeQsqIds.isEmpty()) {
                List<CareProgramEnrollee> enrolleeRecords = BI_PSPB_EnrolleeProcessorCtrl.fetchEnrolleeRecords(enrolleeQsqIds);
                system.debug('enrolleeRecords'+enrolleeRecords);
                for (CareProgramEnrollee enrollee : enrolleeRecords) {
                    system.debug('enrollee.Account.BI_PSP_Birthdate__c'+enrollee.Account.BI_PSP_Birthdate__c);
                    Integer age = BI_PSPB_EnrolleeProcessorCtrl.calculateAge(enrollee.Account.BI_PSP_Birthdate__c, today);
                    system.debug('age'+age);
                    Id enrolleeId = enrollee.Id;
                    system.debug('enrollee.name'+enrollee.Name);
                    Id caregiverId = BI_PSPB_CaregiverProcessorCtrl.fetchCaregiverId(enrolleeId);
                    system.debug('caregiverId'+caregiverId);
					String patientName = enrollee.Account.Name;
                    
                    if (age > 18 && caregiverId == null) {
                        patientEnrolleeIds = new List<Id>{enrolleeId};
                        enrolleeSendQsqIds = BI_PSPB_AssessmentProcessorCtrl.fetchDueAssessments(
							patientEnrolleeIds,
							questionName
						);
                        BI_PSPB_TaskParameterCtrl params = new BI_PSPB_TaskParameterCtrl(
						BI_PSPB_NotificationConstantsCtrl.qsqQuestionSubject,
						BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
						BI_PSPB_NotificationConstantsCtrl.qsq,
						'',
						BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
					);

						newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createPatientTasks(
							enrolleeSendQsqIds,
							params,
                            BI_PSPB_NotificationConstantsCtrl.patient,
                            caregiverId
						));
                    } else {
                        caregiverEnrolleeIds = new List<Id>{enrolleeId};
                        caregiverSendIds = BI_PSPB_AssessmentProcessorCtrl.fetchDueAssessments(
							caregiverEnrolleeIds,
							questionName
						);
                        if (age > 18 && caregiverId != null) {
                            BI_PSPB_TaskParameterCtrl params = new BI_PSPB_TaskParameterCtrl(
                                BI_PSPB_NotificationConstantsCtrl.qsqQuestionSubject,
                                BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
                                BI_PSPB_NotificationConstantsCtrl.qsq,
                                '',
                                BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
                            );

						newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createPatientTasks(
							caregiverSendIds,
							params,
                            BI_PSPB_NotificationConstantsCtrl.patient,
                            caregiverId
						));
                    }
                    BI_PSPB_TaskParameterCtrl params = new BI_PSPB_TaskParameterCtrl(
						BI_PSPB_NotificationConstantsCtrl.qsqCaregiverOne + ' ' + patientName + 
							BI_PSPB_NotificationConstantsCtrl.qsqCaregiverTwo,
						BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
						BI_PSPB_NotificationConstantsCtrl.qsq,
						'',
						BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction
					);

						newTaskList.addAll(BI_PSPB_TaskCreatorCtrl.createCaregiverTasks(
							caregiverSendIds,
							params,
                            BI_PSPB_NotificationConstantsCtrl.caregiver,
                            caregiverId
						));
                        
                }
                }
				BI_PSP_DatabaseOperationsUtility.insertOperation(
					newTaskList,
					BI_PSPB_QsqQuestionnaireActionCtrl.class.toString(),
					false
				);
				sendNotifications(
					enrolleeSendQsqIds,
					notificationType,
					new List<String>{ '' }
				);
                sendNotifications(
					caregiverSendIds,
					notificationType,
					new List<String>{ '' }
				);
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,BI_PSPB_QsqQuestionnaireActionCtrl.class.toString(),
					false, BI_PSPB_NotificationConstantsCtrl.severityError
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_QsqQuestionnaireActionCtrl.class.toString(),
				true,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
	}
	/**
	* @description This method processes list of enrollees and create tasks.
	* @param qsqCount Count of the day the notification to be sent.
	* @return List<Id> List of care program enrollees.
    */
    private static List<Id> processEnrollees(Integer qsqCount) {
	List<Id> enrolleeRecIds = new List<Id>();
		// Fetch CareProgramEnrollee objects
		List<CareProgramEnrollee> enrollees = fetchEnrollees();
		for (CareProgramEnrollee enrollee : enrollees) {
			Date enrolleeCreatedDate = enrollee.BI_PSPB_FirstLoginDate__c;
			if (enrolleeCreatedDate == System.today().addDays(-qsqCount)) {
				enrolleeRecIds.add(enrollee.Id);
			}
		}
	return enrolleeRecIds;
}
	/**
	* @description  Fetches CareProgramEnrollee records from the database. 
	* @return A list of CareProgramEnrollee objects.
	*/
public static List<CareProgramEnrollee> fetchEnrollees() {
	List<CareProgramEnrollee> enrolleeRecords = new List<CareProgramEnrollee>();
		// Query CareProgramEnrollee objects
		String fields = 'Id, BI_PSPB_FirstLoginDate__c';
		enrolleeRecords = BI_PSP_CommonQueryUtility.executeQuery(
		'CareProgramEnrollee',
		fields,
		null,
		false
	);
	return enrolleeRecords;
}
	/**
	* @description This method processes list of enrollees and create tasks.
	* @param enrolleeIds Ids of enrollees.
	* @param notificationType Type of the notification in task.
	* @param communityUserNames Username of the user.
    */
    private static void sendNotifications(
    List<Id> enrolleeIds,
    String notificationType, 
    List<String> communityUserNames
) {
    try {
        // Check if enrolleeIds is not empty and notificationType is not blank
        if (!enrolleeIds.isEmpty() && !String.isBlank(notificationType)) {
            System.debug('enrolleeIds ' + enrolleeIds);
            System.debug('notificationType ' + notificationType);
            BI_PSPB_NotificationTemplatesCtrl.handleTrigger(
                enrolleeIds,
                notificationType,
                communityUserNames,
                ''
            );
        } else {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
                BI_PSPB_QsqQuestionnaireActionCtrl.class.toString(),
                false,
                BI_PSPB_NotificationConstantsCtrl.severityError
            );
        }
    } catch (Exception ex) {
        BI_PSP_LogMessagesUtility.exceptionLogMessage(
            ex.getMessage(),
            BI_PSPB_QsqQuestionnaireActionCtrl.class.getName(),
            ex
        );
    }
}
}