/**
 * @description       : Class for managing personalized assessments and questionnaire responses.
 *                      This class provides methods to handle the creation of new assessments,
 *                      association of responses to existing assessments, and deletion of draft responses.
 * History:
 * Version  Author      Date            Detail          Description
 * 1.0      Abinsha     05-Dec-2023     Created         Initial development.
 * 1.1      Abinsha     01-Jan-2024     Updated         Updated for caregiver.
 * 1.2      Abinsha     04-Apr-2024     Updated         Catch log added.
 */

public with sharing class BI_PSP_LetsPersonliseCtrl {
    /**
     * @description Deletes draft responses based on the provided list of IDs and ensures they belong to the current enrollee.
     * @param idOfRes Array of IDs of the draft responses to be deleted.
     */
    @AuraEnabled
    public static void draftRespoDeletion(String[] idOfRes) {
        List<AssessmentQuestionResponse> responseToDelete = new List<AssessmentQuestionResponse>();
        try {
           /*If anything goes wrong while calling this method, a log records the message and throws an Aura exception. 
            * The error is caught in the catch block where getEnrolleeRecords is called, so no need to check enrolleeId.*/
            String enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].id;

            if (idOfRes != null && idOfRes.size() > 0) {
                String conditions =
                    'Id IN (\'' +
                    String.join(idOfRes, '\', \'') +
                    '\') ' +
                    'AND Assessment.BI_PSP_CareProgramEnrollee__c = \'' +
                    enrolleeId +
                    '\'';

                List<SObject> queryResult = BI_PSP_CommonQueryUtility.executeQuery(
                    'AssessmentQuestionResponse',
                    'Id, Assessment.BI_PSP_CareProgramEnrollee__c',
                    conditions,
                    BI_PSP_QuestionnaireConstant.withSharingKeywrd
                );
                
				if (queryResult.isEmpty()) {
                    BI_PSP_LogMessagesUtility.logError(
                    BI_PSP_QuestionnaireConstant.emptyQuestioniareResponse,BI_PSP_LetsPersonliseCtrl.class.toString(),
                    true,BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
                    );
                }
                
                for (SObject sobj : queryResult) {
                    responseToDelete.add((AssessmentQuestionResponse) sobj);
                }
            } else {
                BI_PSP_LogMessagesUtility.logError(
                    BI_PSP_QuestionnaireConstant.emptyQuestioniareResponse,BI_PSP_LetsPersonliseCtrl.class.toString(),
                    true,BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
                );
            }

            if (!responseToDelete.isEmpty()) {
                BI_PSP_DatabaseOperationsUtility.deleteOperation(
                    responseToDelete,BI_PSP_LetsPersonliseCtrl.class.toString(),
                    false
                );
            }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.exceptionLogMessage(
                BI_PSP_QuestionnaireConstant.respnsNotDeltd,
                BI_PSP_LetsPersonliseCtrl.class.toString(),
                ex
            );
        }
    }
}