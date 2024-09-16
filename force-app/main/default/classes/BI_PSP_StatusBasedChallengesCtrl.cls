/**
 * @description This class provides functionality to retrieve and manage challenges associated with a person account.
 * The methods include retrieving random challenges based on status, retrieving CareProgramEnrollee records,
 * and managing the success list of challenges. The class also includes a wrapper class to handle challenge details.
 * This controller can be utilized in Lightning Web Components and is optimized for cacheable methods.
 * History:
 * Version    Author      Date              Detail         Description
 * 1.0        Gowsic N    5-Dec-2023        Created        Initial development
 * 1.1        Saran S     20-Apr-2024       Updated        Add log, null check, descriptions
 * 1.2        Nandha      08-Aug-2024       Updated        Refactored and documented constants
 */
public without sharing class BI_PSP_StatusBasedChallengesCtrl{
    private static String available =  BI_PSP_ChallengeConstant.challengeAvailable;
    private static String active =  BI_PSP_ChallengeConstant.challengeActive;
    private static String completed =  BI_PSP_ChallengeConstant.assessmentStatusCompleted;
    private static String challengeRecType =  BI_PSP_ChallengeConstant.challengeRecordType;
    
   /**
     * @description Retrieves a list of random challenges associated with the given person account ID and status.
     * This method returns a list of `ChallengeWrapperCommon` objects, each representing a challenge related to the enrollee.
     * The method is cacheable and can be used in Lightning components for efficient data retrieval.
     * 
     * @param personAccountId The ID of the person account for which to retrieve challenges.
     * @param status The status of the challenges to filter by.
     * @return A list of `ChallengeWrapperCommon` objects containing challenge information. Returns an empty list if no challenges are found or if inputs are invalid.
     * @throws Exception If there are any issues during the challenge retrieval process.
     * @since 1.0
     */
     @AuraEnabled(cacheable=true)
        public static List<ChallengeWrapperCommon> getRandomChallenges(String personAccountId, String status) {
            List<ChallengeWrapperCommon> successList = new List<ChallengeWrapperCommon>();
            try {
                if (String.isBlank(personAccountId) || String.isBlank(status)) {
                    return successList;
                }
    
                Id awardRecordTypeId = BI_PSP_CommonQueryUtility.retrieveRecordTypeId('Award',challengeRecType);
    
                CareProgramEnrollee patientEnrollee = getCareProgramEnrollee(personAccountId);
                if (patientEnrollee == null) {
                    BI_PSP_LogMessagesUtility.logError( BI_PSP_ChallengeConstant.challengesErrorMessage, BI_PSP_RandomChallengesCtrl.class.toString(),true, BI_PSP_ChallengeConstant.LOG_SEVERITY_ERROR);
                }
                List<Award> challengeList = new List<Award>();
                if(status == available)
                {
                    challengeList = getChallengeList(patientEnrollee.Id, awardRecordTypeId,status);
    
                }else if(status == active){
                    challengeList = getChallengeListActive(patientEnrollee.Id, awardRecordTypeId,status);
    
                }else if(status == completed)
                {
                    challengeList = getChallengeListCompleted(patientEnrollee.Id, awardRecordTypeId,status);
                }
                for (Award getAllChallenge : challengeList) {
                    addChallengeToSuccessList(successList, getAllChallenge, patientEnrollee, status);
                }
    
            } catch (Exception ex) {
                BI_PSP_LogMessagesUtility.exceptionLogMessage(
                    BI_PSP_ChallengeConstant.enrolleeNf,
                    BI_PSP_RandomChallengesCtrl.class.toString(),
                    ex
                );
            }
            return successList;
        }
    /**
     * @description Method to retrieve the CareProgramEnrollee record based on the provided person account ID.
     * @param personAccountId The ID of the care program enrollee.
     * @return CareProgramEnrollee record if found, otherwise null.
     * @since 1.0
     */
        private static CareProgramEnrollee getCareProgramEnrollee(String personAccountId) {
            String sObjectType = 'CareProgramEnrollee';
            String fields = 'Id, AccountId, BI_PSP_Challenge_Rank__c';
            String conditions = 'Id = \'' + personAccountId + '\'';
            Boolean withSharingKeywrd = false;
    
            List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withSharingKeywrd);
            if (results.isEmpty()) {
                return null;
            }
            return (CareProgramEnrollee)results[0];
        }
    
    
      /**
     * @description Method to retrieve the list of Award records for a given enrollee ID, award record type ID, and available status.
     * @param enrolleeId The ID of the enrollee.
     * @param awardRecordTypeId The RecordTypeId of the Award object.
     * @param status The status of the challenges to retrieve (e.g., Available).
     * @return List of Award records.
     * @since 1.0
     */
        public static List<Award> getChallengeList(Id enrolleeId, Id awardRecordTypeId,String status) {
            String sObjectType = 'Award';
            String availability = 'Y';
            String fields = 'Id, BI_PSP_Care_Program_Plan_Template__r.Id, BI_PSP_Status__c, BI_PSP_Care_Program_Plan_Template__c,BI_PSP_Care_Program_Plan_Template__r.HealthCloudGA__CarePlanTemplate__r.BI_PSP_Challenge_Level__c,BI_PSP_AvailableVisibility__c';
            String conditions = 'RecordTypeId = \'' + awardRecordTypeId + '\' AND BI_PSP_Care_Program_Enrollee__c = \'' + enrolleeId +'\' AND BI_PSP_AvailableVisibility__c = \''+availability + '\' AND BI_PSP_Status__c = \''+status + '\'';
            Boolean withSharingKeywrd = false;
            List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withSharingKeywrd);
            if (results.isEmpty()) {
             BI_PSP_LogMessagesUtility.logError( BI_PSP_ChallengeConstant.challengesErrorMessage, 
              BI_PSP_ChallengeCtrl.class.toString(),false, BI_PSP_ChallengeConstant.LOG_SEVERITY_ERROR);
            }
            // Type casting
            List<Award> challengeList = new List<Award>();
            for (SObject result : results) {
                challengeList.add((Award)result);
            }
            
            return challengeList;
        }
    
        /**
     * @description Method to retrieve the list of Award records for a given enrollee ID, award record type ID, and active status.
     * @param enrolleeId The ID of the enrollee.
     * @param awardRecordTypeId The RecordTypeId of the Award object.
     * @param status The status of the challenges to retrieve (e.g., Active).
     * @return List of Award records.
     * @since 1.0
     */
        public static List<Award> getChallengeListActive(Id enrolleeId, Id awardRecordTypeId,String status) {
            String sObjectType = 'Award';
            String fields = 'Id, BI_PSP_Care_Program_Plan_Template__r.Id, BI_PSP_Status__c, BI_PSP_Care_Program_Plan_Template__c,BI_PSP_Care_Program_Plan_Template__r.HealthCloudGA__CarePlanTemplate__r.BI_PSP_Challenge_Level__c,BI_PSP_ActiveVisibility__c';
            String conditions = 'RecordTypeId = \'' + awardRecordTypeId + '\' AND BI_PSP_Care_Program_Enrollee__c = \'' + enrolleeId +
             '\' AND BI_PSP_Status__c = \''+status + '\'';
            Boolean withSharingKeywrd = false;
            List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withSharingKeywrd);
           if (results.isEmpty()) {
             BI_PSP_LogMessagesUtility.logError( BI_PSP_ChallengeConstant.challengesErrorMessage, 
              BI_PSP_ChallengeCtrl.class.toString(),false, BI_PSP_ChallengeConstant.LOG_SEVERITY_ERROR);
            }
            // Type casting
            List<Award> challengeList = new List<Award>();
            for (SObject result : results) {
                challengeList.add((Award)result);
            }
            return challengeList;
        }

         /**
     * @description Method to retrieve the list of Award records for a given enrollee ID, award record type ID, and Completed status.
     * @param enrolleeId The ID of the enrollee.
     * @param awardRecordTypeId The RecordTypeId of the Award object.
     * @param status The status of the challenges to retrieve (e.g., Completed).
     * @return List of Award records.
     * @since 1.0
     */
        public static List<Award> getChallengeListCompleted(Id enrolleeId, Id awardRecordTypeId,String status) {
            String sObjectType = 'Award';
            String fields = 'Id, BI_PSP_Care_Program_Plan_Template__r.Id, BI_PSP_Status__c, BI_PSP_Care_Program_Plan_Template__c,BI_PSP_Care_Program_Plan_Template__r.HealthCloudGA__CarePlanTemplate__r.BI_PSP_Challenge_Level__c,BI_PSP_ActiveVisibility__c';
            String conditions = 'RecordTypeId = \'' + awardRecordTypeId + '\' AND BI_PSP_Care_Program_Enrollee__c = \'' + enrolleeId +
             '\' AND BI_PSP_Status__c = \''+status + '\'';
            Boolean withSharingKeywrd = false;
            List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withSharingKeywrd);
           if (results.isEmpty()) {
             BI_PSP_LogMessagesUtility.logError( BI_PSP_ChallengeConstant.challengesErrorMessage, 
              BI_PSP_ChallengeCtrl.class.toString(),false, BI_PSP_ChallengeConstant.LOG_SEVERITY_ERROR);
            }
            // Type casting
            List<Award> challengeList = new List<Award>();
            for (SObject result : results) {
                challengeList.add((Award)result);
            }
            return challengeList;
        }

     /**
     * @description Method to add a challenge to the success list if it matches the given status.
     * @param successList The list of ChallengeWrapperCommon objects to add to.
     * @param getAllChallenge The Award record representing the challenge.
     * @param patientEnrollee The CareProgramEnrollee record.
     * @param status The status of the challenges to retrieve (e.g., Active, Completed).
     * @since 1.0
     */
        public static void addChallengeToSuccessList(List<ChallengeWrapperCommon> successList, Award getAllChallenge, CareProgramEnrollee patientEnrollee, String status) {
            ChallengeWrapperCommon successMessage = new ChallengeWrapperCommon();
            successMessage.availableChallenge = getAllChallenge.BI_PSP_Care_Program_Plan_Template__r.Id;
            successMessage.challengeIdToUpdate = getAllChallenge.Id;
    
            if (getAllChallenge.BI_PSP_Status__c == BI_PSP_ChallengeConstant.assessmentStatusCompleted) {
                successMessage.imageRank = patientEnrollee.BI_PSP_Challenge_Rank__c;
            }
    
            successList.add(successMessage);
        }
        
       /**
     * @description A wrapper class that represents common properties for challenges.
     * It includes information about the available challenge, the challenge ID to update,
     * and the rank of the challenge image.
     */
        public class ChallengeWrapperCommon {
            // Represents the available challenge Id
            @AuraEnabled
            public String availableChallenge;
    
            // Represents the challenge Id to update
            @AuraEnabled
            public String challengeIdToUpdate;
    
            // Represents the rank of the challenge image
            @AuraEnabled
            public String imageRank;
        }    
    
    }