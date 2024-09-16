/**
* @description  This class is used to fetch the assessments for the enrollee.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_AssessmentProcessorCtrl {
	/**
    * @description Constructor for BI_PSPB_TaskParameterCtrl.
    * @param enrolleeIds List of enrollee ids.
    * @param assessmentName Name of the assessment.
    * @return List<Id> The list of assessment Ids.
    */
    public static List<Id> fetchDueAssessments(List<Id> enrolleeIds, String assessmentName) {
        List<Id> enrolleeSendIds = new List<Id>();
        try {
            String conditionIds = '(\'' + String.join(enrolleeIds, '\', \'') + '\')';
			String fields = 'Id, BI_PSP_CareProgramEnrollee__c, Name, AssessmentStatus';
            String conditions = 'BI_PSP_CareProgramEnrollee__c IN' + conditionIds
				+ 'AND Name = \'' + assessmentName + '\' ';
			List<Assessment> assessments = 
                BI_PSP_CommonQueryUtility.executeQuery('Assessment',fields, conditions, false);
            for (Assessment assessment : assessments) {
			if (
				assessment.AssessmentStatus ==
				BI_PSPB_NotificationConstantsCtrl.inProgressType
			) {
				enrolleeSendIds.add(						
					assessment.BI_PSP_CareProgramEnrollee__c
				);
			}
		}

		// Map to store assessments per CareProgramEnrollee
		Map<Id, List<Assessment>> parentChildMap = new Map<Id, List<Assessment>>();

		// Get parent records (CareProgramEnrollee)
		List<CareProgramEnrollee> parentRecords = getEnrolleeQuery(
			enrolleeIds
		);
		for (CareProgramEnrollee parent : parentRecords) {
			parentChildMap.put(parent.Id, new List<Assessment>());
		}

		// Get child assessments
		List<Assessment> assessmentChildRecords = getAssessmentChildQuery(
			new List<Id>(parentChildMap.keySet()),
			assessmentName
		);
		for (Assessment child : assessmentChildRecords) {
			if (
				parentChildMap.containsKey(
					child.BI_PSP_CareProgramEnrollee__c
				)
			) {
				parentChildMap.get(child.BI_PSP_CareProgramEnrollee__c)
					.add(child);
			}
		}

		// Add parent records to enrolleeSendIds if they have no child assessments
		for (CareProgramEnrollee parent : parentRecords) {
			if (parentChildMap.get(parent.Id).isEmpty()) {
				enrolleeSendIds.add(parent.Id);
			}
		}
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),	
				BI_PSPB_AssessmentProcessorCtrl.class.toString(), false,
				BI_PSPB_NotificationConstantsCtrl.severityError);
        }
        return enrolleeSendIds;
    }
	/**
    * @description  Fetches child assessment records based on a
	list of assessment IDs and a specific question name.
    * @param assessmentIdList List of assessment ids.
    * @param questionName Name of the assessment.
    * @return List<Assessment> The list of assessment.
    */
    public static List<Assessment> getAssessmentChildQuery(
	List<Id> assessmentIdList,
	String questionName
) {
	String conditionIds =
		'(\'' +
		String.join(assessmentIdList, '\', \'') +
		'\')';
	String fields = 'Id, Name, BI_PSP_CareProgramEnrollee__c, AssessmentStatus, AssessmentRating';
	String conditions =
		'BI_PSP_CareProgramEnrollee__c IN ' +
		conditionIds +
		' ' +
		'AND Name = \'' +
		questionName +
		'\' ';
	List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
		'Assessment',
		fields,
		conditions,
		false
	);
	return results;
}
	/**
    * @description  Retrieves enrollee records based on a list of enrollee IDs.
    * @param enrolleeList List of enrollee ids.
    * @return List<CareProgramEnrollee> The list of assessment Ids.
    */
    public static List<CareProgramEnrollee> getEnrolleeQuery(
	List<Id> enrolleeList
) {
	String conditionIds =
		'(\'' +
		String.join(enrolleeList, '\', \'') +
		'\')';
	String fields = 'Id, BI_PSPB_FirstLoginDate__c';
	String conditions = 'Id IN ' + conditionIds + ' ';
	List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
		'CareProgramEnrollee',
		fields,
		conditions,
		false
	);
	return results;
}
}