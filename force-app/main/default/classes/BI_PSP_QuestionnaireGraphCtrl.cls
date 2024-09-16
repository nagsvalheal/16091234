/**
@description Class used for fetching values from Symptom Tracker and Questionnaire objects for chart.
and Questionnaire objects.
History:
Version    Author      Date              Detail         Description.
1.0        Gowsic N    10-Dec-2023       Created        Initial development.
1.1        Saran S     20-Apr-2024       Updated        Add log, null check, descriptions.  
1.2        Abinsha     04-Aug-2024       updated        code refactoring.
*/
public with sharing class BI_PSP_QuestionnaireGraphCtrl {
    /** 
    @description Method for getting Questionnaire details.
    Retrieves Questionnaire details based on the provided parameters.
    @param erolleId The ID of the care program enrollee.
    @param questionnaireCategory The category of the questionnaire.
    @param selectedMonths Comma-separated list of selected months.
    @return Map containing questionnaire details.
    */
	@AuraEnabled(cacheable=true)
	public static Map<String, List<AssessmentQuestionResponse>> getQuestionnaireDetails(
		String erolleId,
		String questionnaireCategory,
		String selectedMonths
	) {
		Map<String, List<AssessmentQuestionResponse>> returnQuestionResponse = new Map<String, List<AssessmentQuestionResponse>>();
		try {
			if (
				String.isBlank(erolleId) ||
				String.isBlank(questionnaireCategory) ||
				String.isBlank(selectedMonths)
			) {
               BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.falseParemeter,BI_PSP_QuestionnaireGraphCtrl.class.toString());
			}

			List<Assessment> recordAssessment = fetchAssessments(erolleId, questionnaireCategory);
			if (recordAssessment.isEmpty()) {
                BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyAssesment,BI_PSP_QuestionnaireGraphCtrl.class.toString());
			}

			Set<Id> assessmentIds = collectAssessmentIds(recordAssessment, selectedMonths);
			if (assessmentIds.isEmpty()) {
                BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyAssesment,BI_PSP_QuestionnaireGraphCtrl.class.toString());
			}

			List<AssessmentQuestionResponse> assQuesResponse = fetchAssessmentQuestionResponses(
				assessmentIds,
				questionnaireCategory
			);
			if (assQuesResponse.isEmpty()) {
            BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyQuestioniareResponse,BI_PSP_QuestionnaireGraphCtrl.class.toString());
			}

			populateReturnQuestionResponse(returnQuestionResponse, assQuesResponse);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSP_QuestionnaireConstant.assessmentFailed,
				BI_PSP_QuestionnaireGraphCtrl.class.toString(),
				ex
			);
		}

		return returnQuestionResponse.isEmpty() ? null : returnQuestionResponse;
	}

	/**
	 * @description Fetches `Assessment` records for a specific enrollee and questionnaire category, excluding assessments with a status of "In Progress".
	 * @param enrolleeId String - The ID of the enrollee whose assessments are being retrieved.
	 * @param questionnaireCategory String - The name of the questionnaire category to filter the assessments.
	 * @return List<Assessment> - A list of `Assessment` records that match the given criteria.
	 */
	private static List<Assessment> fetchAssessments(
		String enrolleeId,
		String questionnaireCategory
	) {
		// Define the fields to be retrieved
		String fields = 'Id, Name, AssessmentStatus, BI_PSP_DateForCQ__c, BI_PSP_CareProgramEnrollee__r.Name';
		// Build the conditions for the query
		String conditions =
			'BI_PSP_CareProgramEnrollee__r.Id = \'' +
			enrolleeId +
			'\' ' +
			'AND Name = \'' +
			questionnaireCategory +
			'\' ' +
			'AND AssessmentStatus != \'' +
			BI_PSP_QuestionnaireConstant.inProgress +
			'\'';

		// Define the order by clause
		String orderByText = 'EffectiveDateTime ASC';

		// Execute the query using the utility method with the order by clause
		List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQueryWithOrderBy(
			'Assessment',
			fields,
			conditions,
			BI_PSP_QuestionnaireConstant.withSharingKeywrd,
			orderByText
		);

		// Return the result as a list of Assessment objects
		return (List<Assessment>) sObjectResponses;
	}

	/**
	 * @description Collects `Assessment` IDs from a list of `Assessment` records that match a specified date (stored in `selectedMonths`).
	 * @param recordAssessment List<Assessment> - A list of `Assessment` records to be filtered.
	 * @param selectedMonths String - A date string to match against the `BI_PSP_DateForCQ__c` field of each `Assessment`.
	 * @return Set<Id> - A set of `Assessment` IDs that match the specified date criterion.
	 */
	private static Set<Id> collectAssessmentIds(
		List<Assessment> recordAssessment,
		String selectedMonths
	) {
		Set<Id> assessmentIds = new Set<Id>();
		if (!String.isBlank(selectedMonths)) {
			for (Assessment assess : recordAssessment) {
				if (selectedMonths.contains(assess.BI_PSP_DateForCQ__c)) {
					assessmentIds.add(assess.Id);
				}
			}
		}
		return assessmentIds;
	}

	/**
	 * @description Fetches `AssessmentQuestionResponse` records based on a set of `Assessment` IDs and a specified questionnaire category.
	 * @param assessmentIds Set<Id> - A set of `Assessment` IDs to filter the responses.
	 * @param questionnaireCategory String - The name of the questionnaire category to filter the responses.
	 * @return List<AssessmentQuestionResponse> - A list of `AssessmentQuestionResponse` records that match the given criteria.
	 */
	private static List<AssessmentQuestionResponse> fetchAssessmentQuestionResponses(
		Set<Id> assessmentIds,
		String questionnaireCategory
	) {
		List<String> fieldsList = new List<String>{
			'Id',
			'Assessment.Id',
			'AssessmentQuestion.QuestionText',
			'AssessmentQuestion.BI_PSP_shortQuestionText__c',
			'AssessmentQuestion.Name',
			'Assessment.AssessmentStatus',
			'ResponseText',
			'BI_PSP_Questionnaire_Name__c',
			'Assessment.BI_PSP_DateForCQ__c',
			'Assessment.Name'
		};

		List<String> assessmentIdsList = new List<String>();
		for (Id assessmentId : assessmentIds) {
			assessmentIdsList.add(assessmentId);
		}

		String assessmentIdsStr = String.join(assessmentIdsList, '\', \'');
		String query =
			'SELECT ' +
			String.join(fieldsList, ', ') +
			' FROM AssessmentQuestionResponse' +
			' WHERE AssessmentId IN (\'' +
			assessmentIdsStr +
			'\')' +
			' AND Assessment.Name = \'' +
			questionnaireCategory +
			'\'';

		List<SObject> queryResponse = BI_PSP_CommonQueryUtility.executeComplexQuery(
			query,
			BI_PSP_QuestionnaireConstant.withSharingKeywrd
		);
		return (List<AssessmentQuestionResponse>) queryResponse;
	}
	/**
	 * @description Populates a map with `AssessmentQuestionResponse` records grouped by the `BI_PSP_DateForCQ__c` field from their associated `Assessment`.
	 * @param returnQuestionResponse Map<String, List<AssessmentQuestionResponse>> - A map where the key is the date from `BI_PSP_DateForCQ__c` and the value is a list of associated `AssessmentQuestionResponse` records.
	 * @param assQuesResponse List<AssessmentQuestionResponse> - A list of `AssessmentQuestionResponse` records to be processed and added to the map.
	 */
	private static void populateReturnQuestionResponse(
		Map<String, List<AssessmentQuestionResponse>> returnQuestionResponse,
		List<AssessmentQuestionResponse> assQuesResponse
	) {
		for (AssessmentQuestionResponse assres : assQuesResponse) {
			String dateKey = String.valueOf(assres.Assessment.BI_PSP_DateForCQ__c);
			if (!returnQuestionResponse.containsKey(dateKey)) {
				returnQuestionResponse.put(dateKey, new List<AssessmentQuestionResponse>());
			}
			returnQuestionResponse.get(dateKey).add(assres);
		}
	}

	/** 
    @description Method for getting completed Questionnaire details.
    Retrieves Questionnaire details based on the provided parameters.
    @param erolleId The ID of the care program enrollee.
    @param selectedMonths Comma-separated list of selected months.
    @return size of questionnaire details.
    */
	@AuraEnabled(cacheable=true)
	public static List<Assessment> getQuestionnaireLast(String erolleId, String selectedMonths) {
		List<Assessment> assessments = new List<Assessment>();
		try {
			List<Assessment> recordAssessment = new List<Assessment>();

			// Check if both enrolleeId and selectedMonths are provided
			if (!String.isBlank(erolleId) && !String.isBlank(selectedMonths)) {
				// Define the fields to be retrieved
				String fields = 'Id, Name, AssessmentStatus, BI_PSP_DateForCQ__c, BI_PSP_CareProgramEnrollee__r.Name';

				// Build the conditions for the query
				String conditions =
					'BI_PSP_CareProgramEnrollee__r.Id = \'' +
					erolleId +
					'\' ' +
					'AND Name != \'' +
					BI_PSP_QuestionnaireConstant.introduction +
					'\' ' +
					'AND Name != \'' +
					BI_PSP_QuestionnaireConstant.qualiCategory +
					'\' ' +
					'AND AssessmentStatus != \'' +
					BI_PSP_QuestionnaireConstant.inProgress +
					'\'';

				// Define the order by clause
				String orderByText = 'EffectiveDateTime ASC';

				// Execute the query using the executeQueryWithOrderBy method
				List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQueryWithOrderBy(
					'Assessment',
					fields,
					conditions,
					BI_PSP_QuestionnaireConstant.withSharingKeywrd,
					orderByText
				);
				recordAssessment = (List<Assessment>) sObjectResponses;
			}

			// Return null if no assessments found, as required by the functionality
			if (recordAssessment.isEmpty()) {
                BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyAssesment,BI_PSP_QuestionnaireGraphCtrl.class.toString());
			}

			// Collect Assessment records for the selected months
			for (Assessment assess : recordAssessment) {
				if (selectedMonths.contains(assess.BI_PSP_DateForCQ__c)) {
					assessments.add(assess);
				}
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSP_QuestionnaireConstant.emptyAssesment,
				BI_PSP_QuestionnaireGraphCtrl.class.toString(),
				ex
			);
		}

		// Return null if no assessments are found, as required by the functionality.
		if (assessments.isEmpty()) {
			BI_PSP_CurrentUser.getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyAssesment,BI_PSP_QuestionnaireGraphCtrl.class.toString());
            return null;
		} else {
			return assessments;
		}
	}
}