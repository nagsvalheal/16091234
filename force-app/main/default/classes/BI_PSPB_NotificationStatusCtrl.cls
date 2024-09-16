/**
* @description Controller for updating the status of Tasks based on 
*              notifications. Handles marking tasks as read or completed.
* History
* Version	Author			Date		Detail		Description
* 1.0		Ragavi		24-07-2024		Created		Refactored Version
*/
public without sharing class BI_PSPB_NotificationStatusCtrl {
	/**
	 * @description Updating the task status as Read.
	 * @param taskId Id of the Task to be updated.
	 * @return Returning the task marked as read.
	 */
	@AuraEnabled
	public static List<Task> markTaskRead(String taskId) {
	List<Task> listOfTasks = new List<Task>();
	List<Id> taskIdList = new List<Id>();
	try {
		 taskIdList.add(taskId);
		listOfTasks = updateTaskStatus(
			taskIdList,
			BI_PSPB_NotificationConstantsCtrl.actionTypeRead
		);
		if (!listOfTasks.isEmpty()) {
			BI_PSP_DatabaseOperationsUtility.updateOperation(
				listOfTasks,
				BI_PSPB_NotificationStatusCtrl.class.toString(),
				false
			);
		}
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_NotificationStatusCtrl.class.getName(),
			ex
		);
	}
	return listOfTasks;
	}
	/**
	* @description Updating the task status as Completed.
	* @param taskId Id of the Task to be updated.
	* @return Returning the task marked as read.
	*/
	@AuraEnabled
	public static List<Task> markTaskCompleted(String taskId) {
	List<Task> updateTasks = new List<Task>();
	try {
		String fields =
				'Id, WhatId, ' +
				'Status, BI_PSP_Category__c, ' + 
				'Subject, BI_PSPB_Treatment_Type__c, BI_PSP_Notification_Type__c';
		String conditions = 'Id = \'' + taskId + '\'';
		List<Task> task = BI_PSP_CommonQueryUtility.executeQuery(
				'Task',
				fields,
				conditions,
				false
			);
        if(task == null){
            BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_NotificationStatusCtrl.class.toString(),
				true,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
        }
		String whatId = task[0].WhatId;
		String status = task[0].Status;
		String category = task[0].BI_PSP_Category__c;
		String treatmentType = task[0].BI_PSPB_Treatment_Type__c;
		String notificationType = task[0].BI_PSP_Notification_Type__c;
		String fieldsOfRelatedTasks =
				'Id, WhatId, ' +
				'Status, BI_PSP_Category__c, ' +
				'Subject, BI_PSPB_Treatment_Type__c, BI_PSP_Notification_Type__c';
		String conditionsOfRelatedTasks = 'WhatId = \'' + whatId + '\' ' +
					'AND Status = \'' + status + '\' ' +
					'AND BI_PSP_Category__c = \'' + category + '\' ' +
					'AND BI_PSP_Notification_Type__c = \'' + notificationType + '\' ';
		if (treatmentType != null) {
			conditionsOfRelatedTasks += 'AND BI_PSPB_Treatment_Type__c = \'' + treatmentType + '\' ';
		}
		List<Task> relatedTasks = BI_PSP_CommonQueryUtility.executeQuery(
				'Task',
				fieldsOfRelatedTasks,
				conditionsOfRelatedTasks,
				false
			);
		List<Id> taskIds = new List<Id>();
		for (Task t : relatedTasks) {
			taskIds.add(t.Id);
		}
		updateTasks = updateTaskStatus(
				taskIds,
			BI_PSPB_NotificationConstantsCtrl.notificationStatusComplete
		 );
		/**if (!updateTasks.isEmpty()) {
			BI_PSP_DatabaseOperationsUtility.updateOperation(
				updateTasks,
				BI_PSPB_NotificationStatusCtrl.class.toString(),
				false
			);
		}	*/
	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_NotificationStatusCtrl.class.getName(),
			ex
		);
	}
	return updateTasks;
	}
	/**
	* @description Updating the task status as mentioned.
	* @param taskId Id of the Task to be updated.
	* @param newStatus Status of the Task to be updated.
	* @return Returning the task updated.
	*/
	private static List<Task> updateTaskStatus(
	List<Id> taskId,
	String newStatus
	) {
	List<SObject> tasksToUpdate = new List<SObject>();
	List<Task> updatedTasks = new List<Task>();
	try {
		if (taskId.isEmpty()) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_NotificationStatusCtrl.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
		tasksToUpdate = BI_PSPB_InsiteTaskQueryctrl.fetchTasks(taskId);
		if (tasksToUpdate.isEmpty()) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_NotificationStatusCtrl.class.toString(),
				false,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
	
		updatedTasks = BI_PSPB_InsiteTaskUpdater.updateTaskStatus(
			tasksToUpdate,
			newStatus
		);
		if (!updatedTasks.isEmpty()) {
			BI_PSP_DatabaseOperationsUtility.updateOperation(
				updatedTasks,
				BI_PSPB_NotificationStatusCtrl.class.toString(),
				false
			);
		}
	} catch (System.DmlException ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_NotificationStatusCtrl.class.getName(),
			ex
		);
	}
	return updatedTasks;
	}
		
	/**
	* @description Updating the task status as mentioned.
	* @param userType Type of the user.
	*/
	@AuraEnabled(cacheable = false)
    public static void updateTaskStatusSetting(String userType) {
        try {
            List<Id> idOfEnrollee = determineWhatIds(userType);
            
            if (!idOfEnrollee.isEmpty()) {
                List<Task> relatedTasks = fetchRelatedTasks(idOfEnrollee);
                
                if (!relatedTasks.isEmpty()) {
                    updateTasksStatus(relatedTasks);
                }
            }
        } catch (System.DmlException ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                ex.getMessage(),
                BI_PSPB_NotificationStatusCtrl.class.getName(),
                ex
            );
        }
    }

    // Method to determine WhatIds based on userType and enrollee age
    private static List<Id> determineWhatIds(String userType) {
        List<Id> idOfEnrollee = new List<Id>();
        Date today = Date.today();
        String enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].id;

        List<CareProgramEnrollee> enrollee = fetchEnrolleeDetails(enrolleeId);
        List<BI_PSPB_Enrollee_Caregiver__c> enrolleeCaregiver = fetchEnrolleeCaregiver(enrolleeId);

        Integer age = BI_PSPB_SmsEmailSenderCtrl.calculateAge(enrollee[0].Account.BI_PSP_Birthdate__c, today);
        
        if (userType == 'Patient' && age > 18 && enrolleeCaregiver.isEmpty()) {
            idOfEnrollee.add(enrolleeId);
        } else if (userType == 'Caregiver' && age > 18 && !enrolleeCaregiver.isEmpty()) {
            idOfEnrollee.add(BI_PSP_CurrentUser.getCaregiverAccount().id
                );
            idOfEnrollee.add(enrolleeId);
        } else if (userType == 'Caregiver' && age < 18) {
            idOfEnrollee.add(BI_PSP_CurrentUser.getCaregiverAccount().id
                );
        }

        return idOfEnrollee;
    }

    // Method to fetch enrollee details
    private static List<CareProgramEnrollee> fetchEnrolleeDetails(String enrolleeId) {
        String fields = 'Id, AccountId, Account.BI_PSP_Birthdate__c';
        String conditions = 'Id = \'' + enrolleeId + '\'';
        return BI_PSP_CommonQueryUtility.executeQuery('CareProgramEnrollee', fields, conditions, false);
    }

    // Method to fetch enrollee caregiver details
    private static List<BI_PSPB_Enrollee_Caregiver__c> fetchEnrolleeCaregiver(String enrolleeId) {
        String fields = 'Id, BI_PSPB_Care_Program_Enrollee__c, BI_PSPB_Status__c, BI_PSPB_Patient__r.Id';
        String conditions = 'BI_PSPB_Care_Program_Enrollee__c = \'' + enrolleeId + '\'' +
                            ' AND BI_PSPB_Status__c = \'' + BI_PSPB_NotificationConstantsCtrl.actionTypeActive + '\'' +
                            ' LIMIT 1';
        return BI_PSP_CommonQueryUtility.executeQuery('BI_PSPB_Enrollee_Caregiver__c', fields, conditions, false);
    }

    // Method to fetch related tasks
    private static List<Task> fetchRelatedTasks(List<Id> idOfEnrollee) {
        String whatIdCondition = '(\'' + String.join(idOfEnrollee, '\', \'') + '\')';
        String fieldsOfTask = 'Id, WhatId, Status, BI_PSP_Category__c, Subject, BI_PSPB_Treatment_Type__c, BI_PSP_Notification_Type__c';
        String conditionsOfTask = 'WhatId IN ' + whatIdCondition +
                                  ' AND Status = \'' + BI_PSPB_NotificationConstantsCtrl.taskStatusAction + '\'' +
                                  ' AND BI_PSP_Category__c = \'Notification Setting\' ' +
                                  ' AND BI_PSP_Notification_Type__c = \'' + BI_PSPB_NotificationConstantsCtrl.actionTypeAction + '\' ';
        
        return BI_PSP_CommonQueryUtility.executeQuery('Task', fieldsOfTask, conditionsOfTask, false);
    }

    // Method to update tasks' status
    private static void updateTasksStatus(List<Task> tasks) {
        for (Task t : tasks) {
            t.Status = BI_PSPB_NotificationConstantsCtrl.notificationStatusComplete;
        }

        BI_PSP_DatabaseOperationsUtility.updateOperation(
            tasks,
            BI_PSPB_NotificationStatusCtrl.class.toString(),
            false
        );
    }
	}