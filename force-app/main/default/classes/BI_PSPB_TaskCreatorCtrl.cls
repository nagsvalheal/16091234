/**
* @description  This class is used to create tasks for caregiver and patients.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_TaskCreatorCtrl {
    /**
     * @description Creates tasks for patients.
     * @param enrolleeSendIds The list of enrollee IDs to associate with the tasks.
     * @param params The task parameters.
     * @param userType The user type.
     * @param caregiverId The caregiver ID (can be null for patient tasks).
     * @return A list of tasks created.
     */
    public static List<Task> createPatientTasks(List<Id> enrolleeSendIds, BI_PSPB_TaskParameterCtrl params, String userType, Id caregiverId) {
        List<Task> tasks = new List<Task>();
            for (Id enrolleeId : enrolleeSendIds) {
                Task newTask = new Task(
                    Subject = params.subject,
                    WhatId = enrolleeId,
                    BI_PSP_Category__c = BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
                    Status = BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction,
                    BI_PSP_Notification_Type__c = params.notificationType,
                    BI_PSPB_Notification_User_Type__c = userType
                );
                tasks.add(newTask);
            }
        return tasks;
    }
    /**
     * @description Creates tasks for caregivers.
     * @param caregiverSendIds The list of caregiver IDs to associate with the tasks.
     * @param params The task parameters.
     * @param userType The user type.
     * @param caregiverId The caregiver ID (not used in this method but could be included if needed).
     * @return A list of tasks created.
     */
    public static List<Task> createCaregiverTasks(List<Id> caregiverSendIds, BI_PSPB_TaskParameterCtrl params, String userType, Id caregiverId) {
        List<Task> tasks = new List<Task>();
            for (Id caregiverIds : caregiverSendIds) {
                Task newTask = new Task(
                    Subject = params.subject,
                    WhatId = caregiverIds,
                    BI_PSP_Category__c = BI_PSPB_NotificationConstantsCtrl.actionTypeQuestionnaires,
                    Status = BI_PSPB_NotificationConstantsCtrl.actionTypeNotificatonTypeAction,
                    BI_PSP_Notification_Type__c = params.notificationType,
                    BI_PSPB_Notification_User_Type__c = userType
                );
                tasks.add(newTask);
            }
        return tasks;
    }
}