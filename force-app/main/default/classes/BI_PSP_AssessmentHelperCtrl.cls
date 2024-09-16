/**
 * @description  A class that holds helper methods for BI_PSP_AssessmentManagementCtrl class.
 * History:
 * Version   Author      Date            Detail          Description.
 * 1.0       Abinsha     05-Dec-2023     Created         Initial development.
 * 1.1       Abinsha     01-Jan-2024     Updated         Updated for caregiver.
 * 1.2       Abinsha     04-Apr-2024     Updated         Catch log added.
 */
public class BI_PSP_AssessmentHelperCtrl {
    private static List<AssessmentQuestionResponse> assResList = new List<AssessmentQuestionResponse>();
    /**
     * @description this method returns the category name of the submitted Questionnaire.
     * @param draftQuestionIds The Question Ids.
     * @return returns a string.
     */
    public static String getCategory(List<String> draftQuestionIds) {
        String categoryName;
        String activeVersionId;

        // Check if draftQuestionIds is not empty
        if (!draftQuestionIds.isEmpty()) {
            activeVersionId = draftQuestionIds[0];
        } else {
          BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.questionsNotAvailable,BI_PSP_AssessmentHelperCtrl.class.toString());
          return null;
        }

        // Define query parameters
        String sObjectType = 'AssessmentQuestion';
        String fields = 'Id, QuestionCategory';
        String conditions = 'ActiveVersionId = \'' + activeVersionId + '\' LIMIT 1';

        // Execute the query using the common query method.
        List<SObject> queryResults = BI_PSP_CommonQueryUtility.executeQuery(
            sObjectType,
            fields,
            conditions,
            BI_PSP_QuestionnaireConstant.withSharingKeywrd
        );

        // Assuming the query only returns one record due to LIMIT 1.
        if (!queryResults.isEmpty() && queryResults[0] instanceof AssessmentQuestion) {
            AssessmentQuestion assessmentQuestion = (AssessmentQuestion) queryResults[0];
            categoryName = assessmentQuestion.QuestionCategory;
        } else {
         BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.questionsNotAvailable,BI_PSP_AssessmentHelperCtrl.class.toString());
        }
        if (String.isBlank(categoryName)) 
        {
      	BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyCategoryName,BI_PSP_AssessmentHelperCtrl.class.toString());
        }
        return categoryName;
    }

    /**
     * @description this method Sets up the assessment response field values to be inserted.
     * @param questionId The Question ID.
     * @param responseText The response text.
     * @param existingAssessmentId The existing assessment ID.
     * @param isQsqAfterTwoMonths Indicates if the assessment is after two months.
     * @return A list of `AssessmentQuestionResponse` objects.
     */
    public static List<AssessmentQuestionResponse> newDraftResponseToInsert(
        String questionId,
        String responseText,
        String existingAssessmentId,
        Boolean isQsqAfterTwoMonths
    ) {
        /*if anything goes wrong while calling this method ,we do have a log that logs a message and throws aura exception ,
         * eventually the error will get caucght in the catch where the method getEnrolleeRecords  is called from.*/
        String catNames = BI_PSP_AssessmentHelperCtrl.getCategory(new List<String>{ questionId });
        //All the parameters in this method has been checked from where this method is called from except for the boolean variable.
        AssessmentQuestionResponse assRes = new AssessmentQuestionResponse();
        assRes.AssessmentQuestionId = questionId;
        assRes.ResponseText = responseText;
        assRes.AssessmentId = existingAssessmentId;
        assRes.Name = responseText;
        if (isQsqAfterTwoMonths == true && catNames == BI_PSP_QuestionnaireConstant.qualiCategory) {
            assRes.BI_PSP_QsqAfter2months__c = BI_PSP_QuestionnaireConstant.pageOne;
        } else if (
            isQsqAfterTwoMonths == false &&
            catNames == BI_PSP_QuestionnaireConstant.qualiCategory
        ) {
            assRes.BI_PSP_QsqAfterWeeks__c = BI_PSP_QuestionnaireConstant.pageTwo;
        }

        assResList.add(assRes);
        return assResList;
    }

    /**
     * @description Updates personalization details of assessments based on given conditions.
     * @param isItDraftOrSubmit Indicates whether the operation is a draft or a submission.
     * @param draftQuestionIds List of draft question IDs.
     * @param existingAssessmentId The ID of the existing assessment to update.
     * @param isQsqAfterTwoMonths Indicates if the assessment is after two months.
     */
    public static void updatePersonalisation(
        Boolean isItDraftOrSubmit,
        List<String> draftQuestionIds,
        String existingAssessmentId,
        Boolean isQsqAfterTwoMonths
    ) {
        //All the parameters in this method has been checked from where this method is called from except for the boolean variable.
        // Get category name.
        List<Assessment> assessmentsToUpdate = new List<Assessment>();
        /*if anything goes wrong while calling this method ,we do have a log that logs a message and throws aura exception ,
        * eventually the error will get caucght in the catch where the method getEnrolleeRecords  is called from.*/
        String categoryName = BI_PSP_AssessmentHelperCtrl.getCategory(draftQuestionIds);
        // Determine status based on input conditions
        String stsOfTheQuestnr;
        if (isItDraftOrSubmit) {
            stsOfTheQuestnr = (categoryName == BI_PSP_QuestionnaireConstant.introduction)
                ? BI_PSP_QuestionnaireConstant.inProgress
                : BI_PSP_QuestionnaireConstant.completed;
        } else {
            stsOfTheQuestnr = BI_PSP_QuestionnaireConstant.inProgress;
        }

        // Query assessments to update
        String fields = 'Id';
        String conditions = 'Id = \'' + existingAssessmentId + '\'';
        List<SObject> queryResults = BI_PSP_CommonQueryUtility.executeQuery(
            'Assessment',
            fields,
            conditions,
            BI_PSP_QuestionnaireConstant.withSharingKeywrd
        );
        if (queryResults.isEmpty()) {
        BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyAssesment,BI_PSP_AssessmentHelperCtrl.class.toString());
        }
        assessmentsToUpdate = checkPersnlistnConditions(
            draftQuestionIds,
            isItDraftOrSubmit,
            queryResults,
            stsOfTheQuestnr,
            isQsqAfterTwoMonths
        );

        // Update the assessments in the database if there is any.
        if (!assessmentsToUpdate.isEmpty()) {
            BI_PSP_AssessmentHelperCtrl.updateCurrentUsersExistingResponse(assessmentsToUpdate);
        }
    }

    /**
     * @description Checks and updates personalization conditions for assessments based on provided parameters.
     * @param draftQuestionIds List of draft question IDs to determine the category.
     * @param isItDraftOrSubmit Boolean indicating if the update is a draft or a submission.
     * @param queryResults List of queried assessment records to be updated.
     * @param stsOfTheQuestnr Status to set on the assessments.
     * @param isQsqAfterTwoMonths Boolean indicating if the assessment is after two months.
     * @return List<Assessment> List of updated Assessment records.
     */
    private static List<Assessment> checkPersnlistnConditions(
        List<String> draftQuestionIds,
        Boolean isItDraftOrSubmit,
        List<SObject> queryResults,
        String stsOfTheQuestnr,
        Boolean isQsqAfterTwoMonths
    ) {
        /*if anything goes wrong while calling this method ,we do have a log that logs a message and throws aura exception ,
        * eventually the error will get caucght in the catch where the method getCategory  is called from.*/
        String categoryName = BI_PSP_AssessmentHelperCtrl.getCategory(draftQuestionIds);
        List<Assessment> assessmentsToReturn = new List<Assessment>();
        for (SObject sObj : queryResults) {
            Assessment assessment = (Assessment) sObj;
            assessment.AssessmentStatus = stsOfTheQuestnr;
            if (
                isItDraftOrSubmit == true &&
                isQsqAfterTwoMonths == true &&
                categoryName == BI_PSP_QuestionnaireConstant.qualiCategory
            ) {
                assessment.BI_PSP_StatusForPersonalization__c = BI_PSP_QuestionnaireConstant.complete;
            }
            if (
                categoryName == BI_PSP_QuestionnaireConstant.introduction &&
                categoryName != BI_PSP_QuestionnaireConstant.qualiCategory &&
                isQsqAfterTwoMonths == false
            ) {
                assessment.BI_PSP_StatusForPersonalization__c = (isItDraftOrSubmit)
                    ? BI_PSP_QuestionnaireConstant.complete
                    : BI_PSP_QuestionnaireConstant.inProgress;
            }

            assessmentsToReturn.add(assessment);
        }
        return assessmentsToReturn;
    }
    /**
     * @description Asessments to be updated.
     * @param assessmentsToUpdate contains a list of assessment records .
     */
    public static void updateCurrentUsersExistingResponse(List<Assessment> assessmentsToUpdate) {
        //dml
        BI_PSP_DatabaseOperationsUtility.updateOperation(
            assessmentsToUpdate,
            BI_PSP_AssessmentCtrl.class.toString(),
            false
        );
    }
    /**
     * @description Asessment responses to be inserted.
     * @param assResList contains a list of assessment response records .
     */
    public static void insertCurrentUsersExistingAndCurrentResponse(
        List<AssessmentQuestionResponse> assResList
    ) {
        //dml
        BI_PSP_DatabaseOperationsUtility.insertOperation(
            assResList,
            BI_PSP_AssessmentCtrl.class.toString(),
            false
        );
    }
    /**
     * @description Sets the status of the given Assessment based on draft/submit status and questionnaire name.
     * @param ass The Assessment record to be updated.
     * @param isItDraftOrSubmit Boolean indicating if the update is a draft or a submission.
     * @param questionnaireName The name of the questionnaire used to determine the assessment status.
     */
    public static void setAssessmentStatus(
        Assessment ass,
        Boolean isItDraftOrSubmit,// it is a primitive type in Apex, it cannot be null
        String questionnaireName //questionnaireName has been checked on its parent method.
    ) {
        if (isItDraftOrSubmit) {
            ass.AssessmentStatus = questionnaireName == BI_PSP_QuestionnaireConstant.introduction
                ? BI_PSP_QuestionnaireConstant.inProgress
                : BI_PSP_QuestionnaireConstant.completed;
        } else {
            ass.AssessmentStatus = BI_PSP_QuestionnaireConstant.inProgress;
        }
    }

    /**
     * @description Sets the personalization status of the given Assessment based on draft/submit status,
     * questionnaire name, and whether the questionnaire is after two months.
     * @param ass The Assessment record to be updated.
     * @param isItDraftOrSubmit Boolean indicating if the update is a draft or a submission.
     * @param isQsqAfterTwoMonths Boolean indicating if the questionnaire is after two months.
     * @param questionnaireName The name of the questionnaire used to determine the personalization status.
     */
    public static void setAssessmentPersonalizationStatus(
        Assessment ass,
        Boolean isItDraftOrSubmit,// it is a primitive type in Apex, it cannot be null
        Boolean isQsqAfterTwoMonths,// it is a primitive type in Apex, it cannot be null
        String questionnaireName //questionnaireName has been checked on its parent method.
    ) {
        Boolean preventIfAccess = false;

        if (
            isItDraftOrSubmit &&
            !isQsqAfterTwoMonths &&
            questionnaireName == BI_PSP_QuestionnaireConstant.qualiCategory
        ) {
            ass.BI_PSP_StatusForPersonalization__c = BI_PSP_QuestionnaireConstant.inProgress;
            preventIfAccess = true;
        }

        if (isItDraftOrSubmit && !preventIfAccess) {
            ass.BI_PSP_StatusForPersonalization__c = BI_PSP_QuestionnaireConstant.complete;
        } else {
            ass.BI_PSP_StatusForPersonalization__c = BI_PSP_QuestionnaireConstant.inProgress;
        }
    }

    /**
     * @description Sets the rollout date for the given Assessment based on whether the questionnaire is after two months and the category of the questionnaire.
     * @param ass The Assessment record to be updated.
     * @param timeOfQsqEnrllee The date and time when the questionnaire enrollment was completed.
     * @param isQsqAfterTwoMonths Boolean indicating if the questionnaire is after two months.
     * @param questionnaireName The name of the questionnaire used to determine the rollout date.
     */
    public static void setRolloutDate(
        Assessment ass,
        DateTime timeOfQsqEnrllee,//timeOfQsqEnrllee has been checked on its parent method.
        Boolean isQsqAfterTwoMonths,// it is a primitive type in Apex, it cannot be null.
        String questionnaireName //questionnaireName has been checked on its parent method.
    ) {
        if (
            timeOfQsqEnrllee != null &&
            questionnaireName == BI_PSP_QuestionnaireConstant.qualiCategory
        ) {
            ass.BI_PSP_RolloutforCompletedQuestionnarie__c = timeOfQsqEnrllee.addDays(
                isQsqAfterTwoMonths
                    ? BI_PSP_QuestionnaireConstant.twoMonthsInt
                    : BI_PSP_QuestionnaireConstant.fourteenWeeksInt
            );
        }
    }
}