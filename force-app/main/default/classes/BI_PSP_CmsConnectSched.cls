/**
@description This is a Scheduled apex class to check if a new article is created in the channel and creates a Task record.
			 This class Contain Without Sharing Because we have to update tasks created by System Admin from Patient profile .
			 hence, we cannot utilize user mode here and additionally these methods are used by guest users as
		  	 Guest users typically have limited object and field-level permission we haven't used user mode.
History:
Version    Author      Date              Detail       Description
1.0        Anand S     Nov 12, 2023      Created      Initial development
1.1        Rajaa S     17-May-2024       Updated      Add log, null check, descriptions   
1.2		   Rajaa S	   21-May-2024		 Updated	  Add Custom Labels and Catch
*/
public with sharing class BI_PSP_CmsConnectSched implements Schedulable {
    
    /**
     * @description Executes the scheduled job to create tasks based on content published in the CMS.
     * @param context The SchedulableContext object that provides context about the scheduled job.
     */
        public void execute(SchedulableContext context) {
            createTaskOnContentPublish();
        }
    /**
     * @description Retrieves patient IDs, enrollees, and CMS content to create tasks for newly published content.
     *              This method handles the entire flow from retrieving data to saving tasks.
     */
        
        public static void createTaskOnContentPublish() {
            try {
                Set<Id> patientIds = getPatientIds();
                List<CareProgramEnrollee> carePrgEnrlle = getCareProgramEnrollees(patientIds);
                String channelId = getChannelId(BI_PSPB_CmsConstant.cmsSiteName);
                List<Task> newTasks = createTasks(channelId, carePrgEnrlle);
                saveTasks(newTasks);
            } catch (Exception ex) {
                BI_PSP_LogMessagesUtility.logError(BI_PSPB_CmsConstant.errorCmsChannelIdRetrieve,
                    BI_PSP_CmsConnectSched.class.toString(),false,BI_PSPB_CmsConstant.logError);
            }
        }
    
        private static Set<Id> getPatientIds() {
            String fields = 'Id, BI_PSP_Patient__c';
            String conditions = 'BI_PSP_Insite_Notification__c = true';
            Boolean withSharingKeywrd = true; 
            List<BI_PSP_Notification_Setting__c> acclist = BI_PSP_CommonQueryUtility.executeQuery('BI_PSP_Notification_Setting__c', fields, conditions, withSharingKeywrd);
            Set<Id> patientIds = new Set<Id>();
            if (!acclist.isEmpty()) {
                for (BI_PSP_Notification_Setting__c setting : acclist) {
                    patientIds.add(setting.BI_PSP_Patient__c);
                }
            } else {
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSPB_CmsConstant.patientAccountErrorMsg,
                    BI_PSP_CmsConnectSched.class.toString(),
                    false,
                    BI_PSPB_CmsConstant.logError
                );
            }
            return patientIds;
        }
    
        private static List<CareProgramEnrollee> getCareProgramEnrollees(Set<Id> patientIds) {
           // List <CareProgramEnrollee> carePrgEnrlle = [SELECT Id FROM CareProgramEnrollee WHERE AccountId IN :patientIds];
            String fields ='Id';
            String leadIdsString = '\'' + String.join(patientIds, '\',\'') + '\'';
            String conditions = 'AccountId IN (' + leadIdsString + ')';
            Boolean withSharingKeywrd = false;
            List <CareProgramEnrollee> carePrgEnrlle =BI_PSP_CommonQueryUtility.executeQuery('CareProgramEnrollee', fields, conditions, withSharingKeywrd);
            if (carePrgEnrlle.isEmpty()) {
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSPB_CmsConstant.patientEnrolleeErrorMsg,
                    BI_PSP_CmsConnectSched.class.toString(),
                    false,
                    BI_PSPB_CmsConstant.logError
                );
            }
            return carePrgEnrlle;
        }
    
        private static List<Task> createTasks(String channelId, List<CareProgramEnrollee> carePrgEnrlle) {
            List<Task> newTasks = new List<Task>();
            
            if (!String.isBlank(channelId) && !carePrgEnrlle.isEmpty()) {
                DateTime startDate = System.now().addHours(-1);
                DateTime endDate = System.now();
                String startDateIso = startDate.formatGMT(BI_PSPB_CmsConstant.cmsTimeFormat);
                String endDateIso = endDate.formatGMT(BI_PSPB_CmsConstant.cmsTimeFormat);
    
                ConnectApi.ManagedContentVersionCollection managedContentVersionCollection = ConnectApi.ManagedContent.getAllContent(
                    channelId,
                    0,
                    25,
                    BI_PSPB_CmsConstant.usLocale,
                    BI_PSPB_CmsConstant.CMSNews,
                    false,
                    startDateIso,
                    endDateIso, 
                    false
                ); 
                for (CareProgramEnrollee cpelist : carePrgEnrlle) {
                    for (ConnectApi.ManagedContentVersion contentVersion : managedContentVersionCollection.items) {
                        
                        if (contentVersion.publishedDate != null && contentVersion.publishedDate.date() == Date.today()) {
                            
                            Task newTask = createNewTask(cpelist, contentVersion);
                            newTasks.add(newTask);
                        }
                    }
                }
            } else {
               
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSPB_CmsConstant.errorCmsChannelIdRetrieve,
                    BI_PSP_CmsConnectSched.class.toString(),
                    false,
                    BI_PSPB_CmsConstant.logError
                );
            }
            return newTasks;
        }
    
        private static Task createNewTask(CareProgramEnrollee cpelist, ConnectApi.ManagedContentVersion contentVersion) {
            DateTime publishedDateTime = contentVersion.publishedDate;
    
            Task newTask = new Task(
                Subject = BI_PSPB_CmsConstant.cmsSubject,
                WhatId = cpelist.Id,
                Status = BI_PSPB_CmsConstant.actionTypeUnRead,
                BI_PSP_Category__c = BI_PSPB_CmsConstant.actionTypeGeneralContent,
                BI_PSP_Notification_Type__c = BI_PSPB_CmsConstant.actionTypeGeneral,
                ReminderDateTime = publishedDateTime
            );
    
            return newTask;
        }
    /**
     * @description Saves a list of tasks by calling the insertOperation method from the BI_PSP_DatabaseOperationsUtility class.
     *              If the list of tasks is not empty, it attempts to insert them into the database.
     *              In case of any exception during the insert operation, an error is logged using the BI_PSP_LogMessagesUtility.
     * @param newTasks List of Task objects to be inserted into the database. Must not be null.
     * @throws CustomException If there is an issue during the insert operation (e.g., database errors).
     */
        public static void saveTasks(List<Task> newTasks) {
            try{
            if (!newTasks.isEmpty()) {
             BI_PSP_DatabaseOperationsUtility.insertOperation(
                    newTasks,
                    BI_PSP_CmsConnectSched.class.toString(),
                    false
                );
            }
        }
        catch(Exception ex){
            BI_PSP_LogMessagesUtility.logError(BI_PSPB_CmsConstant.inserterror,
                BI_PSP_CmsConnectSched.class.toString(),false,BI_PSPB_CmsConstant.logError);
        }
        }
    /**
     * @description Retrieves the unique identifier (channelId) for the specified channel name.
     *              If the channel name is blank or the channel is not found, logs an error message and returns null.
     * @param channelName The name of the channel for which the channelId is to be retrieved.
     * @return The unique identifier (channelId) of the specified channel, or null if the channel is not found.
     * @throws AuraHandledException if the channel name is blank.
     */
        public static String getChannelId(String channelName) {
            try {
                if (String.isBlank(channelName)) {
                    BI_PSP_LogMessagesUtility.logError(
                        BI_PSPB_CmsConstant.errorCmsChannelIdRetrieve,
                        BI_PSP_CmsConnectSched.class.toString(),
                        false,
                        BI_PSPB_CmsConstant.logError
                    );
                }
    
                ConnectApi.ManagedContentChannelCollection channelRepObj = ConnectApi.ManagedContent.getAllDeliveryChannels(0, 10);
                
                for (ConnectApi.ManagedContentChannel channelObj : channelRepObj.channels) {
                    if (channelObj.channelName == channelName) {
                        return channelObj.channelId;
                    }
                }
    
                BI_PSP_LogMessagesUtility.logError(BI_PSPB_CmsConstant.errorCmsChannelIdRetrieve,
                    BI_PSP_CmsConnectSched.class.toString(),false,BI_PSPB_CmsConstant.logError);
                return null;
            } catch (Exception ex) {
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSPB_CmsConstant.errorCmsChannelIdRetrieve,
                    BI_PSP_CmsConnectSched.class.toString(),
                    false,
                    BI_PSPB_CmsConstant.logError
                );
                return null;
            }
        }
    }