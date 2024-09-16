/**
@description      :Apex class to retrieve draft responses for different assessment categories such 
                  as Psoriasis, Work and Activity, and Dermatology. It handles the retrieval of 
                  draft assessment question responses based on the user's role and enrollment 
                  status in the care program.below are the LWCs where this class is used
                  biPspbIntroductionQuestionnaire, biPspbDLQIquestionnaire,biPspbPSSQuestionnaire,
                  biPspbWAPIQuestionnaire,biPspbQSQuestionnaire1,biPspbQSQuestionnaire2.
* History:
* Version   Author      Date            Detail          Description
* 1.0       Abinsha     05-Dec-2023     Created         Initial development.
* 1.1       Abinsha     01-Jan-2024     Updated         Updated for caregiver.
* 1.2       Abinsha     04-Apr-2024     Updated         Catch log added.
*/

public with sharing class BI_PSP_DraftResponseCtrl {
    private static string conditions;
    private static string enrolleeId;
    /**
     * @description Constructs and returns a condition string for SOQL queries based on the provided parameters.
     * @param questCatgryName The name of the questionnaire category.
     * @param twoMonths Boolean flag indicating if the query should target records completed two months after a specific event.
     * @param inprogress The status of the assessment (typically a constant representing 'in-progress').
     * @param enrolleeId The ID of the enrollee whose records are being queried.
     * @return A string representing the conditions for an SOQL query.
     */
    public static String buildConditions(
        String questCatgryName,
        Boolean twoMonths,
        String inprogress,
        String enrolleeId
    ) {
        String conditions = '';
        conditions += 'assessment.BI_PSP_CareProgramEnrollee__c = \'' + enrolleeId + '\'';
        if(questCatgryName ==BI_PSP_QuestionnaireConstant.qualiCategory && twoMonths == true)
         {
             conditions += ' AND ';
             conditions += 'BI_PSP_QsqAfter2months__c = \'' + BI_PSP_QuestionnaireConstant.pageOne + '\'';
         }
       
           if(questCatgryName ==BI_PSP_QuestionnaireConstant.qualiCategory && twoMonths == false)
         {
              conditions += ' AND ';
             conditions += 'BI_PSP_QsqAfterWeeks__c = \'' + BI_PSP_QuestionnaireConstant.pageTwo + '\'';
         }
        conditions += ' AND ';
        conditions +=
            'Assessment.AssessmentStatus = \'' +
            BI_PSP_QuestionnaireConstant.inprogress +
            '\'';
        conditions += ' AND ';
        conditions += 'BI_PSP_Questionnaire_Name__c = \'' + questCatgryName + '\'';
        return conditions;
    }
    /**
     * @description Retrieves draft responses for assessments based on the provided questionnaire category and time frame.
     * @param questCatgryName The name of the questionnaire category.
     * @param twoMonths Boolean flag indicating if the query should target responses from two months ago.
     * @return A list of AssessmentQuestionResponse records that match the criteria.
     */
    @AuraEnabled(cacheable=true)
    public static List<AssessmentQuestionResponse> retrieveDrfatResponses(
        String questCatgryName,
        Boolean twoMonths //since it is a primitive type in Apex, it cannot be null
    ) {
        List<AssessmentQuestionResponse> liAssessRespon = new List<AssessmentQuestionResponse>();
        try {
            /*If anything goes wrong while calling this method, a log records the message and throws an Aura exception. 
            * The error is caught in the catch block where getEnrolleeRecords is called, so no need to check enrolleeId.*/
            enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].id;
            if(String.isBlank(questCatgryName))
            {
                BI_PSP_LogMessagesUtility.logError(
					BI_PSP_QuestionnaireConstant.emptyCategoryName,
					BI_PSP_CaregiverAndPatientCtrl.class.toString(),
					false,
					BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
				);
            }

            // Build the conditions string
            conditions = buildConditions(
                questCatgryName,
                twoMonths,
                BI_PSP_QuestionnaireConstant.inprogress,
                enrolleeId
            );

            String fields = 'Id, ResponseText, ResponseValue, BI_PSP_Questionnaire_Name__c, BI_PSP_ResponseOrder__c, AssessmentQuestion.Id, Assessment.Id, Assessment.AssessmentStatus';

            String orderByClause = 'BI_PSP_ResponseOrder__c ASC';
            // Execute the query using the SOQLQueryBuilder
            List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQueryWithOrderBy(
                'AssessmentQuestionResponse',
                fields,
                conditions,
                BI_PSP_QuestionnaireConstant.withSharingKeywrd,
                orderByClause
            );

            // Cast the SObject list to List<AssessmentQuestionResponse>
            for (SObject sObj : sObjectResponses) {
                liAssessRespon.add((AssessmentQuestionResponse) sObj);
            }

            if (liAssessRespon.isEmpty()) {
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSP_QuestionnaireConstant.emptyQuestioniareResponse,
                    BI_PSP_DraftResponseCtrl.class.toString(),
                    false,
                    BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
                );
            }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                BI_PSP_QuestionnaireConstant.emptyEnrollerecrd,
                BI_PSP_DraftResponseCtrl.class.toString(),
                ex
            );
        }
        return liAssessRespon;
    }
}