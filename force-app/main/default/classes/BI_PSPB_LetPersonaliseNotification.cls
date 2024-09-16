/**
 * @description Used for symptomtracker, challenges and community SMS,Email and Insite Notification.
 * History
 * Version		Date		 Author		Description
 * 59		06-01-2024		Niyas		Initial Version
 * 59		12-04-2024		Niyas		Code review changes
 */
public without sharing class BI_PSPB_LetPersonaliseNotification {
	/**
	* @description This method ensures that appropriate tasks are created or updated based on the presence of assessments
	and existing tasks for the current user.
	*/
    @AuraEnabled
	public static void createTaskIfNoAssessment() {
		try {
			String enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].id;
			// Check for assessments and existing tasks
			List<Assessment> assessments = getAssessments(enrolleeId);
			List<Task> existingTasks = getExistingTasks(enrolleeId);

			// If no assessments and no existing tasks, create a new task
			if (assessments.isEmpty() && existingTasks.isEmpty()) {
				createTask(
					enrolleeId
				);
			}
			// If assessments exist but no existing tasks, create a new task
			else if (!assessments.isEmpty() && existingTasks.isEmpty()) {
				createTask(
					enrolleeId
                );
			}
			// If existing tasks are found, update the status
			else if (!existingTasks.isEmpty()) {
				Task existingTask = existingTasks[0];
				existingTask.Status = BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction;
				BI_PSP_DatabaseOperationsUtility.updateOperation(
					new List<Task>{ existingTask },
					BI_PSPB_LetPersonaliseNotification.class.toString(),
					false
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_LetPersonaliseNotification.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
	}
	/**
	* @description This method retrieves a list of Task records associated with the specified enrollee ID.
	* @param enrolleeId The ID of the enrollee whose tasks are being queried.
	* @return A list of Task records that match the specified criteria. If no tasks are found, the list will be empty.
	*/
	public static List<Task> getExistingTasks(String enrolleeId) {
		String fields = 'Id, Subject, WhatId';
		String conditions =
			'WhatId = \'' +
			enrolleeId +
			'\' ' +
			'AND Subject = \'' +
			BI_PSPB_NotificationConstantsCtrl.assessmentSubject +
			'\' ' +
			'LIMIT 1';
		List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
			'Task',
			fields,
			conditions,
			false
		);
		return (List<Task>) results;
	}
	/**
	* @description This method creates a new Task record with the specified enrollee ID and status.
	* @param enrolleeId The ID of the enrollee to associate with the new task.
	*/
	@AuraEnabled(cacheable=true)
	public static void createTask(String enrolleeId) {
        List<BI_PSPB_Enrollee_Caregiver__c> caregiver = fetchCaregiverId(enrolleeId);
        if(caregiver.isEmpty()) {
            String whatId = enrolleeId;
            taskCreation(whatId,'Patient');
        } else if(!caregiver.isEmpty() && caregiver[0].BI_PSPB_Status__c == 'Inactive') {
            String whatId = enrolleeId;
            taskCreation(whatId,'Patient');
        } else if(caregiver[0].Id != null && caregiver[0].BI_PSPB_Patient__r.BI_PSP_Age__c > 18){
            String enrollee = enrolleeId;
            taskCreation(enrollee,'Patient');
            taskCreation(enrollee,'Caregiver');
        } else {
            taskCreation(enrolleeId,'Caregiver');
        }
	}
	/**
	* @description This method creates a new Task record with the specified enrollee ID and usertype.
	* @param enrolleeId The ID of the enrollee to associate with the new task.
	* @param userType Type of the user.
	*/
    private static void taskCreation(String enrolleeId,String userType) {
        List<Task> listOfTasks = new List<Task>();
        try{
            Id caregiverId;
        List<BI_PSPB_Enrollee_Caregiver__c> caregiver = fetchCaregiverId(enrolleeId);
            if(!caregiver.isEmpty()){
                caregiverId = caregiver[0].BI_PSPB_Caregiver__r.Id;
            }
        Task newTask = new Task(
			Subject = BI_PSPB_NotificationConstantsCtrl.assessmentSubject,
			Status = 'Action Required',
			BI_PSP_Category__c = BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
			BI_PSP_Notification_Type__c = BI_PSPB_NotificationConstantsCtrl.actionTypeAction,
			WhatId = enrolleeId,
            BI_PSPB_Notification_User_Type__c = userType,
            BI_PSPB_Caregiver__c = caregiverId
		);
            if(newTask != null){
                listOfTasks.add(newTask);
            }
           BI_PSP_DatabaseOperationsUtility.insertOperation(
                listOfTasks,
                BI_PSPB_LetPersonaliseNotification.class.toString(),
                false
            );
        } catch (Exception ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_LetPersonaliseNotification.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
    }
	/**
	* @description This method fetches caregiver for the enrollee.
	* @param enrolleeId The ID of the enrollee.
	* @return List<BI_PSPB_Enrollee_Caregiver__c> List of enrollee caregiver ids.
	*/
    public static List<BI_PSPB_Enrollee_Caregiver__c> fetchCaregiverId(Id enrolleeId) {
        String fields = 'BI_PSPB_Caregiver__r.Id,BI_PSPB_Patient__c,BI_PSPB_Patient__r.BI_PSP_Age__c,BI_PSPB_Status__c';
		String conditions =
			'BI_PSPB_Care_Program_Enrollee__c = \'' +
			enrolleeId +
			'\' ' +	'LIMIT 1';
		List<SObject> enrolleeCaregiverList = BI_PSP_CommonQueryUtility.executeQuery(
			'BI_PSPB_Enrollee_Caregiver__c',
			fields,
			conditions,
			false
		);
		return enrolleeCaregiverList;
    }
	/**
	* @description This method retrieves a list of Assessment records associated with the specified enrollee ID.
	* @param enrolleeId The ID of the enrollee whose assessments are being queried.
	* @return A list of Assessment records that match the specified criteria. If no assessments are found, the list will be empty.
	*/
	public static List<Assessment> getAssessments(String enrolleeId) {
		String fields = 'Id, AssessmentStatus, BI_PSP_CareProgramEnrollee__c';
		String conditions =
			'BI_PSP_CareProgramEnrollee__c = \'' +
			enrolleeId +
			'\' ' +
			'AND AssessmentStatus = \'' +
			BI_PSPB_NotificationConstantsCtrl.inProgressType +
			'\' ' +
			'LIMIT 1';
		List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
			'Assessment',
			fields,
			conditions,
			false
		);
		return (List<Assessment>) results;
	}
}