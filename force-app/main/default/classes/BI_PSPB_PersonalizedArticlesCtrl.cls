/**
 * @description This class is used to retrieve personalized articles based on questionnaire responses.
 * If an answer contains a negative response, it returns negative articles. If no negative responses are found, it returns positive articles.
 * The class was created on 10-Jul-2024.
 * History:
 * Version	Author			Date			Detail				Description
 * 1.0		Gokul Krishnan	10-Jul-2024		Created				Refactor code of personalizedmessagesctrl
 */
public with sharing class BI_PSPB_PersonalizedArticlesCtrl {
	private static String statusOfPatient;
	/**
	 * @description main method for getting personalizded articles
	 * @return list<String> Article list based on positive or negative responses
	 * retrun in LWC biPspbArticleCategoryParent, biPspbArticlesForDashboard
    */
	@AuraEnabled(cacheable=true)
	public static List<String> getPersonalizedArticles() {
		List<String> articleList = new List<String>();
		try {
			Id careProgramEnrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0]
				.id;
			// User mode is not enabled because Assessment is health cloud object
			List<Assessment> assessments = BI_PSP_CaregiverAndPatientCtrl.getAssessmentsByCurrentUserName(
				BI_PSPB_PersonalizationConstant.introductionQuestionaire
			);

			if (
				!assessments.isEmpty() &&
				assessments[0].BI_PSP_StatusForPersonalization__c ==
				BI_PSPB_PersonalizationConstant.completeStatus
			) {
				// User mode is not enabled because AssessmentQuestionResponse is health cloud object
				String sObjectType = 'AssessmentQuestionResponse';
				String fields = 'Name, ResponseText, BI_PSP_Category__c, AssessmentQuestion.Name, AssessmentQuestion.QuestionText, AssessmentQuestionId';
				String conditions =
					'AssessmentId = \'' +
					assessments[0].Id +
					'\'';
				Boolean withUserMode = false;
				List<AssessmentQuestionResponse> assessmentresponse = BI_PSP_CommonQueryUtility.executeQuery(
					sObjectType,
					fields,
					conditions,
					withUserMode
				);
				// User mode is not enabled because CareProgramEnrollee is health cloud object
				String objectType = 'CareProgramEnrollee';
				String field = 'BI_PSPB_PatientStatus__c';
				String condition = 'Id = \'' + careProgramEnrolleeId + '\'';
				Boolean userMode = false;

				List<CareProgramEnrollee> careProgramEnrolleeRecord = BI_PSP_CommonQueryUtility.executeQuery(
					objectType,
					field,
					condition,
					userMode
				);

				if (!careProgramEnrolleeRecord.isEmpty()) {
					statusOfPatient = careProgramEnrolleeRecord[0]
						.BI_PSPB_PatientStatus__c;
				}
				Set<String> negativeResponses = BI_PSPB_PersonalizedArticlesCtrl.getNegativeResponses(
					assessmentresponse
				);

				if (!negativeResponses.isEmpty()) {
					articleList = new List<String>(
						filterArticleByStatus(
							negativeResponses,
							statusOfPatient
						)
					);
					return articleList;
				}

				Set<String> positiveResponses = BI_PSPB_PersonalizedArticlesCtrl.getPositiveResponses(
					assessmentresponse
				);
				articleList = new List<String>(
					filterArticleByStatus(positiveResponses, statusOfPatient)
				);
			}
			/* The absence of an assessment record will not result
			 in an error when accessing personalized articles. */
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_PersonalizationConstant.errorRetrievePersonalizedArticles,
				BI_PSPB_PersonalizedArticlesCtrl.class.toString(),
				ex
			);
		}
		return articleList;
	}

	/**
	 * @description This method retrieves negative responses from the assessment responses
	 * @param assessmentResponse type - List<AssessmentQuestionResponse> - List of assessment question responses
	 * @return Set<String> Set of negative responses
	 */
	private static Set<String> getNegativeResponses(
		List<AssessmentQuestionResponse> assessmentResponse
	) {
		Set<String> negativeResponses = new Set<String>();

		for (AssessmentQuestionResponse response : assessmentresponse) {
			String questionName = response.AssessmentQuestion.QuestionText;
			questionName = questionName.replaceAll('\\u200B', '');
			String answer = response.ResponseText;
			Map<String, Set<String>> questMap = BI_PSPB_PersonalizationConstant.negativeResponseMap.get(
				questionName
			);
			if (questMap != null) {
				Set<String> negativeResponse = questMap.get(answer);
				if (negativeResponse != null && negativeResponse.size() > 0) {
					negativeResponses.addAll(negativeResponse);
				}
			} else if (
				questionName ==
				BI_PSPB_PersonalizationConstant.affectGppQstn
			) {
				negativeResponses.addAll(addRelationshipResponse(answer));
			}
			
		}
		negativeResponses.addAll(getGenderResponse());
		return negativeResponses;
	}

	/**
	 * @description This method retrieves positive responses from the assessment responses
	 * @param assessmentResponse List<AssessmentQuestionResponse> - List of assessment question responses
	 * @return Set<String> Set of positive responses
	 */
	private static Set<String> getPositiveResponses(
		List<AssessmentQuestionResponse> assessmentResponse
	) {
		Set<String> positiveResponses = new Set<String>();
		//get positive response from assessment
		for (AssessmentQuestionResponse response : assessmentresponse) {
			String questionName = response.AssessmentQuestion.QuestionText;
			questionName = questionName.replaceAll('\\u200B', '');
			String answer = response.ResponseText;
			Map<String, Set<String>> questMap = BI_PSPB_PersonalizationConstant.positiveResponseMap.get(
				questionName
			);
			if (questMap != null) {
				Set<String> answerCategory = questMap.get(answer);
				if (answerCategory != null && answerCategory.size() > 0) {
					positiveResponses.addAll(answerCategory);
				}
			}
		}
		positiveResponses.add(
			BI_PSPB_PersonalizationConstant.gppContagiousLabel
		);
		return positiveResponses;
	}

	/**
	 * @description This method filters articles based on the status of the patient
	 * @param  articleSet  - Set of articles
	 * @param  statusOfPatient - Status of the patient
	 * @return Set<String> Filtered set of articles
	 */
	private static Set<String> filterArticleByStatus(
		Set<String> articleSet,
		String statusOfPatient
	) {
		if (
			statusOfPatient == BI_PSPB_PersonalizationConstant.chronicStatus
		) {
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.spevigoInfusionLabel
			);
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.treatingGppLabel
			);
		} else if (
			statusOfPatient == BI_PSPB_PersonalizationConstant.acuteStatus
		) {
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.spevigoInjectionLabel
			);
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.preventionGppLabel
			);
		} else {
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.spevigoInfusionLabel
			);
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.treatingGppLabel
			);
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.spevigoInjectionLabel
			);
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.preventionGppLabel
			);
			articleSet.remove(
				BI_PSPB_PersonalizationConstant.workInGppLabel
			);
		}
		return articleSet;
	}

	private static Set<String> addRelationshipResponse(String answer) {
		Set<String> negativeArticles = new Set<String>();
		if (
			answer.containsIgnoreCase(
				BI_PSPB_PersonalizationConstant.relationshipWithFriends
			)
		) {
			negativeArticles.add(
				BI_PSPB_PersonalizationConstant.talkGppLabel
			);
		} if (
			answer.containsIgnoreCase(
				BI_PSPB_PersonalizationConstant.relationshipWithPartner
			)
		) {
			negativeArticles.add(
				BI_PSPB_PersonalizationConstant.gppIntimacyLabel
			);
		} if (
			answer.containsIgnoreCase(
				BI_PSPB_PersonalizationConstant.selfEsteem
			)
		) {
			negativeArticles.add(
				BI_PSPB_PersonalizationConstant.manageScarsLabel
			);
		}
		return negativeArticles;
	}

	/**
	 * @description This method filters articles based on the gender of the patient
	 * @return List<String> Filtered list of articles
	 */
	@AuraEnabled(cacheable = true)
	public static List<String> getGenderResponse(){
		User currentUser = BI_PSP_CurrentUser.getCurrentUser();
		Account patientAccount;
		if (currentUser.BI_PSPB_Caregiver__c) {
			patientAccount = BI_PSPB_PatientFormCtrl.getPatientInfo();
		}
		else{
			patientAccount = BI_PSPB_AccountDetailsCtrl.getAccDetails();
		}
		List<String> articles = new List<String>();
		Map<String, Set<String>> questMap = BI_PSPB_PersonalizationConstant.negativeResponseMap.get(
			BI_PSPB_PersonalizationConstant.whatGenderQstn
		);

		if (questMap != null) {
			Set<String> answerCategory = questMap.get(patientAccount.HealthCloudGA__Gender__pc);
			if (answerCategory != null && answerCategory.size() > 0) {
				articles.addAll(answerCategory);
			}
		}
		return articles;
	}

	/**
	 * Inserts a new view record into the database.
	 *
	 * @description Creates and update the just for me article list.
	 * @param articleList The Just for me article list
	 */
	@AuraEnabled(cacheable=false)
	public static void insertPersonalizedArticles(
		String articleList
	) {
		try{
			Id enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
			String articleName = 'Just For Me Article List';

			// Escape single quotes in the article name
			String escapedArticleName = String.escapeSingleQuotes(articleName);

			// Query to check if the record already exists
			String sObjectType = 'BI_PSPB_Article_like__c';
			String fields = 'Id, BI_PSPB_JustForMeArticles__c';
			String conditions = 
				'BI_PSPB_CareProgramEnrollee__c = \'' + enrolleeId + 
				'\' AND BI_PSPB_Article_name__c = \'' + escapedArticleName + '\'';

			Boolean withUserMode = false;

			// Execute the query using the common utility method
			List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
				sObjectType, fields, conditions, withUserMode
			);

			BI_PSPB_Article_like__c articlesRecord;

			if (!results.isEmpty()) {
				// Record exists with a non-empty JustForMeArticles field, update the existing record
				articlesRecord = (BI_PSPB_Article_like__c)results[0];
				articlesRecord.BI_PSPB_JustForMeArticles__c = articleList;
				
				// UPSERT operation
				BI_PSP_DatabaseOperationsUtility.updateOperation(
					new List<BI_PSPB_Article_like__c>{ articlesRecord },
					BI_PSPB_PersonalizedArticlesCtrl.class.toString(),
					false
				);
			} else {
				// No existing record found or the JustForMeArticles field is empty, create a new record
				articlesRecord = new BI_PSPB_Article_like__c(
					BI_PSPB_Article_name__c = articleName,
					BI_PSPB_CareProgramEnrollee__c = enrolleeId,
					BI_PSPB_JustForMeArticles__c = articleList
				);
				
				// Insert the new record
				BI_PSP_DatabaseOperationsUtility.insertOperation(
					new List<BI_PSPB_Article_like__c>{ articlesRecord },
					BI_PSPB_PersonalizedArticlesCtrl.class.toString(),
					false
				);
			}
		

	}
	catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(ex.getMessage(),
			BI_PSPB_PersonalizedArticlesCtrl.class.toString(),ex);
	}
}

	/**
	 * @description Retrieve the Just for me article list from Article Like object.
	 * @return A list of article names. List<String>
	 */
	@AuraEnabled(cacheable=true)
	public static String retrieveStorageArticles(){
		String articles='';
		try{
			Id enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
			String escapedArticleName = String.escapeSingleQuotes('Just For Me Article List');
			
			String sObjectType = 'BI_PSPB_Article_like__c';
			String fields = 'Id, BI_PSPB_JustForMeArticles__c';
			String conditions =
				'BI_PSPB_CareProgramEnrollee__c = \'' + 
				enrolleeId + 
				'\' AND ' + 
				'BI_PSPB_Article_name__c = \'' + 
				escapedArticleName + 
				'\'';
			
			Boolean withUserMode = false;
			
			List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
				sObjectType,
				fields,
				conditions,
				withUserMode
			);
		if (!results.isEmpty()) {
			BI_PSPB_Article_like__c articleRecord = (BI_PSPB_Article_like__c)results[0];
			articles = articleRecord.BI_PSPB_JustForMeArticles__c;
		}

	}
	catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(ex.getMessage(),
		BI_PSPB_PersonalizedArticlesCtrl.class.toString(),ex);
	}	
	return articles;
	}
}