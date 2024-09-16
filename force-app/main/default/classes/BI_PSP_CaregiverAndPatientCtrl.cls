/**
@description       This Apex class is responsible for retrieving assessments based on the 
				   current user's role (caregiver or patient).It determines the user's role based
				   on their profile and retrieves the latest assessment for the specified category.
* History:
* Version	Author		Date			Detail			Description
* 1.0		Harish		05-Dec-2023		Created			Initial development.
* 1.1		Harish 	    01-Jan-2024		Updated			Updated for caregiver.
* 1.2		Abinsha		04-Apr-2024		Updated			Catch log added.
*/
public with sharing class BI_PSP_CaregiverAndPatientCtrl {	
	/**
     * @description Retrieves the latest assessment for the specified category based on the current
     * user's role (caregiver or patient).we are using this apex class in LWCs such as cards,Questionnaire
				  biPspbQualitativeCompletedQuestionnaire2,  biPspbQualitativeCompletedQuestionnaire,
				  biPspbWapiCompletedQuestionnaire,biPspbPSSCompletedQuestionnaires, 
				  biPspbDlqiCompletedQuestionnaire.
     * @param categoryname The name of the assessment category.
     * @return List of assessments matching the specified category for the current user.
     */
	@AuraEnabled(cacheable=true)
	public static List<Assessment> getAssessmentsByCurrentUserName(String categoryname) {
        string enrolleeId;
		List<Assessment> assessments = new List<Assessment>();
		try {
            /*If anything goes wrong while calling this method, a log records the message and throws an Aura exception. 
            * The error is caught in the catch block where getEnrolleeRecords is called, so no need to check enrolleeId*/
			enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].id;
			if (String.isBlank(categoryname)) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSP_QuestionnaireConstant.emptyCategoryName,
					BI_PSP_CaregiverAndPatientCtrl.class.toString(),
					true,
					BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
				);
			}
			// Prepare the fields and conditions for the query
			String sObjectType = 'Assessment';
			String fields =
				'Id, Name, AssessmentStatus, EffectiveDateTime, ExpirationDateTime, ' +
				'BI_PSP_StatusForPersonalization__c, BI_PSP_RolloutforCompletedQuestionnarie__c';
			String conditions =
				'BI_PSP_CareProgramEnrollee__c = \'' +
				enrolleeId +
				'\' AND Name = \'' +
				categoryname +
				'\'';
			String orderByClause = 'EffectiveDateTime DESC';
			String limitClause = 'LIMIT 1';
			// Execute the query using the common query method
			List<SObject> result = BI_PSP_CommonQueryUtility.executeQueryWithOrderBy(
				sObjectType,
				fields,
				conditions, 
				BI_PSP_QuestionnaireConstant.withSharingKeywrd,
				orderByClause + ' ' + limitClause
			);

			if (!result.isEmpty()) {
				assessments = (List<Assessment>) result;
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSP_QuestionnaireConstant.emptyAssesment,
					BI_PSP_CaregiverAndPatientCtrl.class.toString(),
					false,
					BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
				);
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSP_QuestionnaireConstant.emptyEnrollerecrd,
				BI_PSP_CaregiverAndPatientCtrl.class.toString(),
				ex
			);
		}
		return assessments;
	}
}