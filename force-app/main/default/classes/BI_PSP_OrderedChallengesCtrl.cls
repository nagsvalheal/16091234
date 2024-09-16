/**
@description Class used for retrieving care program enrollees with challenges associated and updating challenges related values.
Reason for using without sharing is we use Care Program Enrollee, which is a Health Cloud object; hence, we cannot utilize user mode here.
History:
Version    Author      Date              Detail         Description
1.0        Nandha      25-7-2023        Created        Initial development 
*/

public without sharing class BI_PSP_OrderedChallengesCtrl {
   /**
 * @description Retrieves a list of CarePlanTemplate records based on the given challenge ID and status filter.
 *
 * @param challengeId The ID of the challenge to filter by.
 * @return A list of CarePlanTemplate records or null if none are found.
 */
    @AuraEnabled(cacheable=true)
    public static List<HealthCloudGA__CarePlanTemplate__c> getChallenges(String challengeId) {
        List<HealthCloudGA__CarePlanTemplate__c> carePlanTemplateRecords = new List<HealthCloudGA__CarePlanTemplate__c>();
        try {
            if (!String.isBlank(challengeId)) {
                // Build the base SOQL query for Award records
                List<Award> careProgramm = fetchAwards(challengeId);
                Set<Id> carePlanTemplateIds = new Set<Id>();

                // Extract unique CarePlanTemplate IDs from the careProgramm list
                for (Award award : careProgramm) {
                    if (award.BI_PSP_Care_Program_Plan_Template__r.HealthCloudGA__CarePlanTemplate__r.Id != null) {
                        carePlanTemplateIds.add(award.BI_PSP_Care_Program_Plan_Template__r.HealthCloudGA__CarePlanTemplate__r.Id);
                    }
                }

                if (!carePlanTemplateIds.isEmpty()) {
                    carePlanTemplateRecords = fetchCarePlanTemplates(carePlanTemplateIds);
                }
            } else {
                BI_PSP_LogMessagesUtility.logError( BI_PSP_ChallengeConstant.careProgramTemplateErrorMessage, BI_PSP_OrderedChallengesCtrl.class.toString(),true, BI_PSP_ChallengeConstant.LOG_SEVERITY_ERROR);
            }
            if (carePlanTemplateRecords.isEmpty()) {
                return null;
            }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                BI_PSP_ChallengeConstant.careProgramTemplateErrorMessage,
                BI_PSP_OrderedChallengesCtrl.class.toString(),
                ex
            );
        }
        return carePlanTemplateRecords;
    }

    /**
     * @description Fetches a list of Award records associated with a given challenge ID.
     *
     * @param challengeId The ID of the challenge.
     * @return A list of Award records associated with the specified challenge ID.
     */
    private static List<Award> fetchAwards(String challengeId) {
        String fields = 'BI_PSP_Care_Program_Plan_Template__r.Id,BI_PSP_Care_Program_Plan_Template__r.HealthCloudGA__CarePlanTemplate__r.Id, BI_PSP_AvailableVisibility__c, BI_PSP_ActiveVisibility__c,BI_PSP_Status__c ,BI_PSP_Care_Program_Plan_Template__r.HealthCloudGA__CarePlanTemplate__r.BI_PSP_Challenge_Level__c';
        String sObjectType = 'Award';
        String conditions = 'BI_PSP_Care_Program_Plan_Template__r.Id = \'' + challengeId + '\'';
        Boolean withSharingKeywrd = Boolean.valueOf(BI_PSP_ChallengeConstant.userModeFalse);
    	
        List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withSharingKeywrd);
        if (results.isEmpty()) {
             BI_PSP_LogMessagesUtility.logError( BI_PSP_ChallengeConstant.challengesErrorMessage, 
              BI_PSP_ChallengeCtrl.class.toString(),false, BI_PSP_ChallengeConstant.LOG_SEVERITY_ERROR);
            }
        List<Award> careProgramm = new List<Award>();
        for (SObject result : results) {
            careProgramm.add((Award) result);
        }
        return careProgramm;
    }

    /**
     * @description Fetches a list of CarePlanTemplate records based on the provided Set of CarePlanTemplate IDs.
     *
     * @param carePlanTemplateIds The Set of CarePlanTemplate IDs to query.
     * @return A list of CarePlanTemplate records matching the provided IDs.
     */
    private static List<HealthCloudGA__CarePlanTemplate__c> fetchCarePlanTemplates(Set<Id> carePlanTemplateIds) {
        Id carePlanTemplateRecordTypeId = Schema.SObjectType.HealthCloudGA__CarePlanTemplate__c.getRecordTypeInfosByDeveloperName()
            .get(System.label.BI_PSP_Challenge)
            .getRecordTypeId();
        String fieldValues = 'Id, BI_PSP_Challenge_Reward_Points__c, Name, HealthCloudGA__Description__c, BI_PSP_Challenge_Level__c, BI_PSP_Challenge_Image__c';
        // Convert the Set<Id> to a comma-separated string for the condition
        String carePlanTemplateIdsStr = '(';
        for (Id id : carePlanTemplateIds) {
            carePlanTemplateIdsStr += '\'' + id + '\',';
        }
        carePlanTemplateIdsStr = carePlanTemplateIdsStr.removeEnd(',') + ')';
        String condition = 'Id IN ' + carePlanTemplateIdsStr + ' AND Name != NULL AND RecordTypeId = \'' + carePlanTemplateRecordTypeId + '\'';
        List<HealthCloudGA__CarePlanTemplate__c> carePlanTemplateRecords = new List<HealthCloudGA__CarePlanTemplate__c>();
        // Execute the query using the utility method
        List<SObject> cptList = BI_PSP_CommonQueryUtility.executeQuery('HealthCloudGA__CarePlanTemplate__c',fieldValues,condition,false);
        if (cptList.isEmpty()) {
             BI_PSP_LogMessagesUtility.logError( BI_PSP_ChallengeConstant.challengesErrorMessage, 
              BI_PSP_ChallengeCtrl.class.toString(),false, BI_PSP_ChallengeConstant.LOG_SEVERITY_ERROR);
            }
        for (SObject resultcp : cptList) {
            carePlanTemplateRecords.add((HealthCloudGA__CarePlanTemplate__c)resultcp);
        }
        return carePlanTemplateRecords;
    }

}