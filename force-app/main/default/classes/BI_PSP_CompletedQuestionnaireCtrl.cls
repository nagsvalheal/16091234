/**
@description     :An Apex Class for Retrieving Questionnaire Records where the status is in Completed
                  and expired.we are using this apex class in LWCs such as 
				  BiPspbQsqAfterFourteenWeeks,biPspbWapiCompletedQuestionnaire,biPspbPSSCompletedQuestionnaires, 
				  biPspbDlqiCompletedQuestionnaire.
* History:
* Version	Author		Date			Detail			Description
* 1.0		Abinsha		05-Dec-2023		Created			Initial development.
* 1.1		Abinsha 	01-Jan-2024		Updated			Updated for caregiver.
* 1.2		Abinsha		04-Apr-2024		Updated			Catch log added.
*/

public with sharing class BI_PSP_CompletedQuestionnaireCtrl {
    /**
     * @description Constructs a dynamic SOQL `WHERE` clause based on the provided parameters.
     * The method includes conditions for `categoryName`, `enrolleeId`, `targetDate`, and optional flags
     * for two-month and fourteen-week assessments.
     * @param categoryName The category name of the questionnaire.
     * @param enrolleeId The ID of the enrollee to filter the query.
     * @param targetDate The target date to filter the query.
     * @param twoMonths If true, includes a condition for two-month assessments.
     * @param fourteenWeeks If true, includes a condition for fourteen-week assessments.
     * @return A string representing the dynamically constructed SOQL `WHERE` clause.
     */
    private static String buildConditions(
        String categoryName,
        String enrolleeId,
        String targetDate,
        Boolean twoMonths,
        Boolean fourteenWeeks
    ) {
        String conditions = 'Assessment.BI_PSP_CareProgramEnrollee__c = \'' + enrolleeId + '\'';

        if (categoryName != null && !String.isBlank(categoryName)) {
            conditions += ' AND BI_PSP_Questionnaire_Name__c = \'' + categoryName + '\'';
        }
        if (targetDate != null && !String.isBlank(targetDate)) {
            conditions += ' AND Assessment.BI_PSP_DateForCQ__c = \'' + targetDate + '\'';
        }
        if (twoMonths) {
            conditions +=
                ' AND BI_PSP_QsqAfter2months__c = \'' +
                BI_PSP_QuestionnaireConstant.pageOne +
                '\'';
        }
        if (fourteenWeeks) {
            conditions +=
                ' AND BI_PSP_QsqAfterWeeks__c = \'' +
                BI_PSP_QuestionnaireConstant.pageTwo +
                '\'';
        }
        conditions +=
            ' AND Assessment.AssessmentStatus != \'' +
            BI_PSP_QuestionnaireConstant.inprogress +
            '\'';

        return conditions;
    }
    /**
     * @description Retrieves completed questionnaire responses for a given enrollee based on the target date and category name.
     * This method is cacheable to improve performance and reduce server load.
     * @param targetDate The target date to filter the completed questionnaires.
     * @param categoryName The category name to filter the completed questionnaires.
     * @return A list of AssessmentQuestionResponse records that match the provided criteria.
     */
    @AuraEnabled(cacheable=true)
    public static List<AssessmentQuestionResponse> getCompletedQuestionares(
        String targetDate,
        String categoryName
    ) {
        List<AssessmentQuestionResponse> assessmentResponses = new List<AssessmentQuestionResponse>();
        String enrolleeId;
        try {
             /*if anything goes wrong while calling this method ,we do have a log that logs a message and throws aura exception ,
              * eventually the error will get caucght in the catch where the method getEnrolleeRecords  is called from.*/
            enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
            if (!String.isBlank(targetDate) && !String.isBlank(categoryName)) {
                // Build conditions
                String conditions = buildConditions(
                    categoryName,
                    enrolleeId,
                    targetDate,
                    false,
                    false
                );

                // Define fields for the query
                String fields = 'Id, AssessmentQuestion.QuestionText, ResponseText, ResponseValue, BI_PSP_Questionnaire_Name__c, Assessment.Id, Assessment.EffectiveDateTime, Assessment.BI_PSP_RolloutforCompletedQuestionnarie__c, BI_PSP_ResponseOrder__c, Assessment.BI_PSP_DateForCQ__c';

                // Define ORDER BY clause
                String orderByClause = 'CreatedDate DESC';

                // Execute the query using the common query method with ORDER BY
                List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQueryWithOrderBy(
                    'AssessmentQuestionResponse',
                    fields,
                    conditions,
                    BI_PSP_QuestionnaireConstant.withSharingKeywrd,
                    orderByClause
                );

                // Cast the result to List<AssessmentQuestionResponse>
                for (SObject sObj : sObjectResponses) {
                    assessmentResponses.add((AssessmentQuestionResponse) sObj);
                }
            } else {
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSP_QuestionnaireConstant.emptyCategoryName,
                    BI_PSP_CompletedQuestionnaireCtrl.class.toString(),
                    true,
                    BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
                );
            }
            if (assessmentResponses.isEmpty()) {
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSP_QuestionnaireConstant.emptyAssesment,
                    BI_PSP_CompletedQuestionnaireCtrl.class.toString(),
                    true,
                    BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
                );
            }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                BI_PSP_QuestionnaireConstant.emptyQuestioniareResponse,
                BI_PSP_CompletedQuestionnaireCtrl.class.toString(),
                ex
            );
        }
        return assessmentResponses;
    }

    /**
     * @description Retrieves completed assessments for the current user based on the specified category name.
     * The method returns a list of `Assessment` records and is cacheable to improve performance.
     * @param categoryName The name of the category to filter the assessments.
     * @return A list of `Assessment` records that match the provided category name and are associated with the current user's enrollee ID.
     */
    @AuraEnabled(cacheable=true)
    public static List<Assessment> getQstnrcurrentcompleteddate(String categoryName) {
        List<Assessment> assessmentResponses = new List<Assessment>();
        try {
            /*if anything goes wrong while calling this method ,we do have a log that logs a message and throws aura exception ,
            * eventually the error will get caucght in the catch where the method getEnrolleeRecords  is called from.*/
            String enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;

            if (!String.isBlank(categoryName)) {
                // Build the conditions for the query
                String conditions =
                    'Name = \'' +
                    String.escapeSingleQuotes(categoryName) +
                    '\' AND BI_PSP_CareProgramEnrollee__c = \'' +
                    String.escapeSingleQuotes(enrolleeId) +
                    '\'';

                // Fields to retrieve
                String fields = 'Id, Name, EffectiveDateTime, ExpirationDateTime';

                // Define the ORDER BY clause
                String orderByClause = 'CreatedDate DESC';

                // Execute the query using the common query utility method with ORDER BY
                List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQueryWithOrderBy(
                    'Assessment',
                    fields,
                    conditions,
                    BI_PSP_QuestionnaireConstant.withSharingKeywrd,
                    orderByClause
                );

                // Cast the result to List<Assessment>
                for (SObject sObj : sObjectResponses) {
                    assessmentResponses.add((Assessment) sObj);
                }
            } else {
                // Log error for missing category name or enrollee ID
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSP_QuestionnaireConstant.emptyCategoryName,
                    BI_PSP_CompletedQuestionnaireCtrl.class.toString(),
                    true,
                    BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
                );
            }

            if (assessmentResponses.isEmpty()) {
                // Log error if no assessments are found
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSP_QuestionnaireConstant.emptyQuestioniareResponse,
                    BI_PSP_CompletedQuestionnaireCtrl.class.toString(),
                    true,
                    BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
                );
            }
        } catch (Exception ex) {
            // Log any exceptions encountered during execution
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                BI_PSP_QuestionnaireConstant.emptyAssesment,
                BI_PSP_CompletedQuestionnaireCtrl.class.toString(),
                ex
            );
        }
        return assessmentResponses;
    }
}