/**
 * @description This BI_PSPB_ScheduleLeadConversion class used to Schedule to Lead convert
 * History:
 * Version  Author          Date            Detail              Description
 * 1.0      Ashif           05-Nov-2023     Created             Initial development
 * 1.1		Ashif			27-07-2024		Updates				Code Refactor
 */
public with sharing class BI_PSPB_OnboardingSched implements Schedulable {
	private static String patientQualified = BI_PSPB_EnrollmentConstant.getLabel('PATIENT_QUALIFIED_STATUS');
	private static String logSeverityError = BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR');
/**
 * @description This method is executed by the scheduler to handle lead conversion processes. It retrieves a list of qualified lead IDs, and if the list is not empty, it calls the `convertLead` method from `BI_PSPB_OnboardingCtrl` to perform the lead conversion. Any exceptions during the lead conversion are logged.
 * @param sc SchedulableContext - The context of the scheduled job, providing information about the job's execution.
 */
	public void execute(SchedulableContext sc) {
		List<Id> qualifiedLeadsIds = fetchQualifiedLeads();
		if (!qualifiedLeadsIds.isEmpty()) {
			try {
				//lead conversion handler is called to perform lead conversion
				BI_PSPB_OnboardingCtrl.convertLead(qualifiedLeadsIds);
			} catch (Exception ex) {
				BI_PSP_LogMessagesUtility.logError(BI_PSPB_EnrollmentConstant.getLabel('CONVERSION_ERROR'), BI_PSPB_EnrollmentCaregiver.class.getName(), false, logSeverityError);
			}
		}
	}

/**
 * @description This method fetches a list of Lead IDs for leads that are qualified (based on their status)
 * and have not yet been converted. The method queries the `Lead` object and filters records
 * based on specific criteria: `Status` equals a qualified status, and `IsConverted` is false.
 * @return List<Id> A list of Lead IDs that meet the criteria of being qualified and not converted.
 */
	public List<Id> fetchQualifiedLeads() {
		List<Lead> qualifiedLeads = new List<Lead>();
		String fields = 'Id, Name, Status';
		String conditions = 'Status = \'' + patientQualified + '\' AND IsConverted = FALSE';
		Boolean withSharingKeyword = Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE'));

		List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQuery('Lead', fields, conditions, withSharingKeyword);
		for (SObject sObj : sObjectResponses) {
			qualifiedLeads.add((Lead) sObj);
		}

		List<Id> qualifiedLeadsIds = new List<Id>();
		// Loop through the leads and collect their IDs
		for (Lead lead : qualifiedLeads) {
			qualifiedLeadsIds.add(lead.Id);
		}

		return qualifiedLeadsIds;
	}
}