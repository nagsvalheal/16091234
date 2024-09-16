/**
@description       This class provides methods to retrieve dates for Assessment cards in progress for 
                   different categories like PSS, WAPI, and DLQI.It interacts with Assessment and custom objects 
                   to fetch relevant dates based on the current user's role and context.
* History:
* Version	Author		Date			Detail			Description.
* 1.0		Abinsha		05-Dec-2023		Created			Initial development.
* 1.1		Abinsha 	01-Jan-2024		Updated			Updated for caregiver.
* 1.2		Abinsha		04-Apr-2024		Updated			Catch log added.
*/
public with sharing class BI_PSP_AssessmentManagementCtrl {
    /**
     * @description Inserts or updates draft records based on the provided question IDs, response texts, and other parameters.
     * If an existing assessment is found, updates its responses; otherwise, creates a new assessment.
     * @param darftQuestionIds The IDs of the draft questions.
     * @param draftResponseTexts The response texts corresponding to the draft questions.
     * @param isItDraftOrSubmit Boolean indicating if the operation is a draft or a submission.
     * @param isQsqAfterTwoMonths Boolean indicating if the questionnaire is after two months.
     */
    @AuraEnabled
    public static void mulitipleDraftRecordsInsertion(
        List<String> darftQuestionIds,
        List<String> draftResponseTexts,
        Boolean isItDraftOrSubmit, //since it is a primitive type in Apex, it cannot be null
        Boolean isQsqAfterTwoMonths
    ) {
        try {
            // Check for null or empty inputs
            if (darftQuestionIds.isEmpty() || draftResponseTexts.isEmpty()) {
                BI_PSP_LogMessagesUtility.logError(
					BI_PSP_QuestionnaireConstant.falseParemeter,
					BI_PSP_AssessmentManagementCtrl.class.toString(),
					true,
					BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
				);
            }
            /*If anything goes wrong while calling this method, a log records the message and throws an Aura exception. 
             * The error is caught in the catch block where getCategory and getEnrolleeRecords is called, so no extra check is needed.*/
            String enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
            String categoryName = BI_PSP_AssessmentHelperCtrl.getCategory(darftQuestionIds);

            String fields = 'Id';
            String conditions =
                'BI_PSP_CareProgramEnrollee__c = \'' +
                enrolleeId +
                '\'' +
                ' AND AssessmentStatus = \'' +
                BI_PSP_QuestionnaireConstant.inProgress +
                '\'' +
                ' AND Name = \'' +
                categoryName +
                '\'';

            // Use the common query utility to execute the query
            List<SObject> existingAssessments = BI_PSP_CommonQueryUtility.executeQuery(
                'Assessment',
                fields,
                conditions,
                BI_PSP_QuestionnaireConstant.withSharingKeywrd
            );

            Assessment existingAssessment;
            /*We are not checking boolean variables isItDraftOrSubmit,isQsqAfterTwoMonths since it is a primitive type in Apex, it cannot be null 
            and the values are not user defined ,its static.*/
            if (!existingAssessments.isEmpty()) {
                existingAssessment = (Assessment) existingAssessments[0];
                String existingAssessmentId = existingAssessment.Id;
                updateExistingResponses(
                    existingAssessmentId,
                    darftQuestionIds,
                    draftResponseTexts,
                    isItDraftOrSubmit,
                    isQsqAfterTwoMonths
                );
            } else {
                createNewAssessment(
                    darftQuestionIds,
                    draftResponseTexts,
                    enrolleeId,
                    isItDraftOrSubmit,
                    isQsqAfterTwoMonths
                );
            }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                ex.getMessage(),
                BI_PSP_AssessmentCtrl.class.toString(),
                ex
            );
        }
    }

    /**
     * @description Creates a new assessment record with the given details and associates draft responses if the assessment is created successfully.
     * @param qstns The list of question IDs for the draft records.
     * @param respnones The list of response texts corresponding to the draft questions.
     * @param enroleeids The ID of the enrollee.
     * @param isItDraftOrSubmit Boolean indicating if the operation is a draft or a submission.
     * @param isQsqAfterTwoMonths Boolean indicating if the questionnaire is after two months.
     */
    private static void createNewAssessment(
        List<String> qstns,
        List<String> respnones,
        String enroleeids,
        Boolean isItDraftOrSubmit,
        Boolean isQsqAfterTwoMonths
    ) {
         /*If anything goes wrong while calling this method, a log records the message and throws an Aura exception. 
          * The error is caught in the catch block where getCategory is called, so no extra check is needed.*/
        String questionnaireName = BI_PSP_AssessmentHelperCtrl.getCategory(qstns);
        DateTime timeOfQsqEnrllee = getEnrolleeCreationDate(enroleeids);
        
        if (timeOfQsqEnrllee == null) {
        // Log an error or throw an exception here if needed.
            BI_PSP_LogMessagesUtility.logError(
            BI_PSP_QuestionnaireConstant.errorForDates,
            BI_PSP_AssessmentManagementCtrl.class.toString(),
            true,
            BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
        );
        return; // Return early to prevent further execution.
    }

        Assessment ass = initializeAssessment(
            enroleeids,
            questionnaireName,
            isItDraftOrSubmit,
            isQsqAfterTwoMonths,
            timeOfQsqEnrllee
        );
        //dml
        Database.SaveResult[] savedresuls = BI_PSP_DatabaseOperationsUtility.insertOperation(
            new List<Assessment>{ ass },
            BI_PSP_AssessmentManagementCtrl.class.toString(),
            false
        );
        if (savedresuls.size() > 0 && savedresuls[0].isSuccess()) {
            ass.Id = savedresuls[0].getId(); // Correctly assign the Id from the SaveResult
        }
        // Check if the insertion was successful
        if (!String.isEmpty(ass.Id)) {
            associateNewAssessmentResponses(
                qstns,
                respnones,
                ass.Id,
                isQsqAfterTwoMonths,
                questionnaireName
            );
        } else {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSP_QuestionnaireConstant.assessmentFailed,
                BI_PSP_AssessmentManagementCtrl.class.toString(),
                true,
                BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
            );
        }
    }

    /**
    * @description Retrieves the creation date of a CareProgramEnrollee record based on the provided enrollee ID.
    * @param enroleeids The ID of the CareProgramEnrollee record.
    * @return Returns the creation date of the enrollee record, or null if no record is found.
    */
    private static DateTime getEnrolleeCreationDate(String enroleeids) {
        // Define the fields and conditions for the query.
        String fields = 'Id, Name, CreatedDate';
        String conditions = 'Id = \'' + enroleeids + '\'';

        // Call the executeQuery method from BI_PSP_CommonQueryUtility
        List<SObject> caregiverEnrolleeSObjects = BI_PSP_CommonQueryUtility.executeQuery(
            'CareProgramEnrollee',
            fields,
            conditions,
            BI_PSP_QuestionnaireConstant.withSharingKeywrd
        );
        // Cast the list of SObject to the specific type.
        List<CareProgramEnrollee> caregiverEnrollee = (List<CareProgramEnrollee>) caregiverEnrolleeSObjects;

        return caregiverEnrollee.isEmpty() ? null : caregiverEnrollee[0].CreatedDate;
    }

    /**
     * @description Initializes a new Assessment record with specified values and calculated fields.
     * @param enroleeids The ID of the CareProgramEnrollee associated with the assessment.
     * @param questionnaireName The name of the questionnaire used to set the assessment attributes.
     * @param isItDraftOrSubmit Indicates whether the assessment is in draft or submit mode.
     * @param isQsqAfterTwoMonths Boolean indicating if the questionnaire is to be processed after two months.
     * @param timeOfQsqEnrllee The creation date of the enrollee record.
     * @return Returns an initialized Assessment object with set status, personalization status, rollout date, and expiration date.
     */
    private static Assessment initializeAssessment(
        String enroleeids,
        String questionnaireName,
        Boolean isItDraftOrSubmit,
        Boolean isQsqAfterTwoMonths,
        DateTime timeOfQsqEnrllee
    ) {
        Assessment ass = new Assessment();
        ass.BI_PSP_CareProgramEnrollee__c = enroleeids;
        ass.Name = questionnaireName;

        BI_PSP_AssessmentHelperCtrl.setAssessmentStatus(ass, isItDraftOrSubmit, questionnaireName);
        BI_PSP_AssessmentHelperCtrl.setAssessmentPersonalizationStatus(
            ass,
            isItDraftOrSubmit,
            isQsqAfterTwoMonths,
            questionnaireName
        );
        BI_PSP_AssessmentHelperCtrl.setRolloutDate(
            ass,
            timeOfQsqEnrllee,
            isQsqAfterTwoMonths,
            questionnaireName
        );

        ass.EffectiveDateTime = DateTime.now();
        ass.ExpirationDateTime = DateTime.now().addDays(BI_PSP_QuestionnaireConstant.expireDate);

        return ass;
    }

    /**
     * @description Associates new assessment responses with the specified assessment and inserts them into the database.
     * @param qstns List of question IDs associated with the assessment responses.
     * @param respnones List of response texts corresponding to each question ID.
     * @param assIds The ID of the assessment to which the responses are associated.
     * @param isQsqAfterTwoMonths Boolean indicating if the response is for a questionnaire processed after two months.
     * @param catNames The category name of the questionnaire.
     */
    private static void associateNewAssessmentResponses(
        List<String> qstns,
        List<String> respnones,
        String assIds,
        Boolean isQsqAfterTwoMonths,
        String catNames
    ) {
        List<AssessmentQuestionResponse> assResList = new List<AssessmentQuestionResponse>();
        for (Integer i = 0; i < qstns.size(); i++) {
            String questionId = qstns[i];
            String responseText = respnones[i];

            AssessmentQuestionResponse assRes = new AssessmentQuestionResponse();
            assRes.AssessmentQuestionId = questionId;
            assRes.ResponseText = responseText;
            assRes.AssessmentId = assIds;
            assRes.Name = responseText;
            if (
                isQsqAfterTwoMonths == true &&
                catNames == BI_PSP_QuestionnaireConstant.qualiCategory
            ) {
                assRes.BI_PSP_QsqAfter2months__c = BI_PSP_QuestionnaireConstant.pageOne;
            } else if (
                isQsqAfterTwoMonths == false &&
                catNames == BI_PSP_QuestionnaireConstant.qualiCategory
            ) {
                assRes.BI_PSP_QsqAfterWeeks__c = BI_PSP_QuestionnaireConstant.pageTwo;
            }

            assResList.add(assRes);
        }

        if (!assResList.isEmpty()) {
            BI_PSP_DatabaseOperationsUtility.insertOperation(
                assResList,
                BI_PSP_AssessmentCtrl.class.toString(),
                false
            );
        }
    }
    /**
     * @description Updates existing assessment responses or creates new ones if they do not exist.
     * @param existingAssessmentId The ID of the existing assessment.
     * @param draftQuestionIds List of question IDs to be updated or inserted.
     * @param draftResponseTexts List of response texts corresponding to each question ID.
     * @param isItDraftOrSubmit Boolean indicating if the operation is draft or submit.
     * @param isQsqAfterTwoMonths Boolean indicating if the response is for a questionnaire processed after two months.
     */
    public static void updateExistingResponses(
        String existingAssessmentId,
        List<String> draftQuestionIds,
        List<String> draftResponseTexts,
        Boolean isItDraftOrSubmit,
        Boolean isQsqAfterTwoMonths
    ) {
        List<AssessmentQuestionResponse> listOfResponses = new List<AssessmentQuestionResponse>();
        List<String> fieldsList = new List<String>{
            'Id',
            'Assessment.Id',
            'ResponseText',
            'AssessmentQuestionId',
            'BI_PSP_ResponseOrder__c'
        };

        // Convert set of IDs to a comma-separated string
        String draftQuestionIdsStr = String.join(new List<String>(draftQuestionIds), '\', \'');

        // Construct the dynamic query without the ORDER BY clause
        String query =
            'SELECT ' +
            String.join(fieldsList, ', ') +
            ' FROM AssessmentQuestionResponse' +
            ' WHERE AssessmentQuestionId IN (\'' +
            draftQuestionIdsStr +
            '\')' +
            ' AND AssessmentId = \'' +
            existingAssessmentId +
            '\'';

        // Execute the query with the ORDER BY clause passed separately
        List<SObject> queryResponse = BI_PSP_CommonQueryUtility.executeComplexQueryWithOrderBy(
            query,
            BI_PSP_QuestionnaireConstant.withSharingKeywrd,
            'BI_PSP_ResponseOrder__c ASC'
        );
        listOfResponses = (List<AssessmentQuestionResponse>) queryResponse;
        Map<String, AssessmentQuestionResponse> existingResponsesMap = new Map<String, AssessmentQuestionResponse>();
        List<AssessmentQuestionResponse> existingResponsesToUpdate = new List<AssessmentQuestionResponse>();
        List<AssessmentQuestionResponse> assResList = new List<AssessmentQuestionResponse>();
        Set<Id> assessmentIdsToUpdate = new Set<Id>();

        for (AssessmentQuestionResponse existingResponse : listOfResponses) {
            existingResponsesMap.put(existingResponse.AssessmentQuestionId, existingResponse);
            assessmentIdsToUpdate.add(existingResponse.Assessment.Id);
        }

        for (Integer i = 0; i < draftQuestionIds.size(); i++) {
            String questionId = draftQuestionIds[i];
            String responseText = draftResponseTexts[i];
            AssessmentQuestionResponse existingResponse = existingResponsesMap.get(questionId);

            if (existingResponse != null) {
                existingResponse.ResponseText = responseText;
                existingResponsesToUpdate.add(existingResponse);
            } else {
                assResList = BI_PSP_AssessmentHelperCtrl.newDraftResponseToInsert(
                    questionId,
                    responseText,
                    existingAssessmentId,
                    isQsqAfterTwoMonths
                );
            }
        }

        // DML operations
        if (!existingResponsesToUpdate.isEmpty()) {
            BI_PSP_DatabaseOperationsUtility.updateOperation(
                existingResponsesToUpdate,
                BI_PSP_AssessmentCtrl.class.toString(),
                false
            );
        }



        BI_PSP_AssessmentHelperCtrl.updatePersonalisation(
            isItDraftOrSubmit,
            draftQuestionIds,
            existingAssessmentId,
            isQsqAfterTwoMonths
        );

        if (!assResList.isEmpty()) {
            BI_PSP_AssessmentHelperCtrl.insertCurrentUsersExistingAndCurrentResponse(assResList);
        }
    }
}