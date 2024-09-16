/**
 * @description This class provides methods to retrieve and manage Case records for Care Program Enrollees,
 * focusing on cases with draft status, adverse events, and platform support. It includes error logging
 * and supports usage with Lightning Web Components (LWC) via @AuraEnabled methods. The class enforces
 * sharing rules using "with sharing" to ensure data security.
 *  Version  Author          Date        Detail      Description
 * 59       Niyas       06-01-2024      Created     Initial Version
 * 59       Niyas       18-04-2024      Updated     Code review changes
 * 59       Rajaa       31-07-2024      Updated     Code refactor changes
 */
public with sharing class BI_PSPB_DraftSupportCtrl {
	/**
	 * @description Retrieves the latest draft Case record related to a specified Care Program Enrollee.
	 * @param accountId The Id of the Care Program Enrollee for which to retrieve the draft Case record.
	 * @return The latest draft Case record related to the specified Care Program Enrollee, or null if no matching records are found.
	 */
	@AuraEnabled(cacheable=true)
	public static List<Case> getPSPCaseRecordsMedical(String accountId) {
		if (String.isBlank(accountId)) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_SupportCenterConstant.errorMsgPatientIdNotFound,
				BI_PSPB_DraftSupportCtrl.class.toString(),
				false,
				BI_PSPB_SupportCenterConstant.logError
			);
			return null;
		}
		try {
			// Ensure values are properly formatted and escaped
			String statusDraft = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.draft
			); 
			String statusNeedMoreInfo = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.needMoreInfo
			);
			String typeMedicalInfoEnquiry = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.medicalInfoEnquiry
			);

			// Constructing the dynamic query
			String query = 'SELECT Id, BI_PSPB_Sub_Type__c, Description, BI_PSP_Patient__r.AccountId, CreatedDate FROM Case ';
			query +=
				'WHERE Id = \'' +
				String.escapeSingleQuotes(accountId) +
				'\' ';
			query +=
				'AND (Status = \'' +
				statusDraft +
				'\' OR Status = \'' +
				statusNeedMoreInfo +
				'\') ';
			query +=
				'AND Type = \'' +
				typeMedicalInfoEnquiry +
				'\' ORDER BY CreatedDate DESC LIMIT 1';

			// Executing the query
			List<Case> relatedCases = BI_PSP_CommonQueryUtility.executeComplexQuery(
				query,
				false
			);

			if (!relatedCases.isEmpty()) {
				return relatedCases;
			} else { 
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_SupportCenterConstant.recordCannotFound,
					BI_PSPB_DraftSupportCtrl.class.toString(),
					false,
					BI_PSPB_SupportCenterConstant.logError
				);
				return null;
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_DraftSupportCtrl.class.toString(),
				ex
			);
			return null;
		}
	}

	/**
	 *@description  Retrieves the most recent Case record with specific criteria related to adverse events reporting.
	 * @param accountId The Id of the CareProgramEnrollee record associated with the Case.
	 * @return The most recent Case record meeting the criteria, or null if no matching record is found.
	 */

	@AuraEnabled(cacheable=true)
	public static List<Case> getPSPCaseRecordsReport(String accountId) {
		if (String.isBlank(accountId)) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,
				BI_PSPB_DraftSupportCtrl.class.toString(),
				false,
				BI_PSPB_SupportCenterConstant.logError
			);
			return null;
		}
		try {
			//Since Careprogramenrollee lookup field is used we cannot use USER_MODE here.
			String statusDraft = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.draft
			);
			String statusNeedMoreInfo = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.needMoreInfo
			);
			String typeReportAdverseEvents = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.reportAdverseEvents
			);

			String query = 'SELECT Id,BI_PSPB_Sub_Type__c,Description,BI_PSP_Patient__r.AccountId,CreatedDate FROM Case ';
			query +=
				'WHERE Id = \'' +
				String.escapeSingleQuotes(accountId) +
				'\' ';
			query +=
				'AND (Status = \'' +
				statusDraft +
				'\' OR Status = \'' +
				statusNeedMoreInfo +
				'\') ';
			query +=
				'AND Type = \'' +
				typeReportAdverseEvents +
				'\' ORDER BY CreatedDate DESC LIMIT 1';
			List<Case> relatedCases = BI_PSP_CommonQueryUtility.executeComplexQuery(
				query,
				false
			);

			if (!relatedCases.isEmpty()) {
				return relatedCases;
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,
					BI_PSPB_DraftSupportCtrl.class.toString(),
					false,
					BI_PSPB_SupportCenterConstant.logError
				);
				return null;
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_DraftSupportCtrl.class.toString(),
				ex
			);
			return null;
		}
	}
	/**
	 *@description  Retrieves a list of draft Case records related to a specified account.
	 * @param accountId The Id of the account for which to retrieve related Case records.
	 * @return A list of draft Case records related to the specified account.
	 */

	@AuraEnabled(cacheable=true)
	public static List<Case> getPSPCaseRecordsPlatformSupport(
		String accountId
	) {
		try {
			if (String.isBlank(accountId)) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_SupportCenterConstant.errorMsgPatientIdNotFound,
					BI_PSPB_DraftSupportCtrl.class.toString(),
					false,
					BI_PSPB_SupportCenterConstant.logError
				);
			}
			//Since Careprogramenrollee lookup field is used we cannot use USER_MODE here.
			String statusDraft = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.draft
			);
			String statusNeedMoreInfo = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.needMoreInfo
			);
			String typePlatformSupport = String.escapeSingleQuotes(
				BI_PSPB_SupportCenterConstant.platformSupport
			);

			String query = 'SELECT Id,BI_PSPB_Sub_Type__c,Description,BI_PSP_Patient__r.AccountId,CreatedDate FROM Case ';
			query +=
				'WHERE Id = \'' +
				String.escapeSingleQuotes(accountId) +
				'\' ';
			query +=
				'AND (Status = \'' +
				statusDraft +
				'\' OR Status = \'' +
				statusNeedMoreInfo +
				'\') ';
			query +=
				'AND Type = \'' +
				typePlatformSupport +
				'\' ORDER BY CreatedDate DESC LIMIT 1';

			// Executing the query
			List<Case> relatedCases = BI_PSP_CommonQueryUtility.executeComplexQuery(
				query,
				false
			);

			if (!relatedCases.isEmpty()) {
				return relatedCases;
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_SupportCenterConstant.recordCannotFound,
					BI_PSPB_DraftSupportCtrl.class.toString(),
					false,
					BI_PSPB_SupportCenterConstant.logError
				);
				return null;
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_DraftSupportCtrl.class.toString(),
				ex
			);
			return null;
		}
	}
/**
	 *@description  Retrieves a list of draft Case records related to a specified account.
	 * @param caseId The Id of the account for which to retrieve related Case records.
	 * @return A list of draft Case records related to the specified account.
	 */
@AuraEnabled(cacheable=true)
public static List<Map<String, String>> getSavedImageUrls(String caseId) {   
    List<Map<String, String>> imageUrls = new List<Map<String, String>>();
    
    // Query to get ContentDocumentLink and related ContentVersion details
    // Define the object type, fields, and conditions for the query
    String sObjectType = 'ContentDocumentLink';
    String fields = 'ContentDocumentId, ContentDocument.Title, ContentDocument.LatestPublishedVersion.ContentUrl, ContentDocument.LatestPublishedVersion.Id, ContentDocument.LatestPublishedVersion.ContentSize, ContentDocument.LatestPublishedVersion.FileType';
    String conditions = 'LinkedEntityId = \'' + caseId + '\'';

    // Perform the query using the common utility
    Boolean withUserMode = false;
    List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
        sObjectType,
        fields,
        conditions,
        withUserMode
    );

    // Cast the results to the appropriate type
    List<ContentDocumentLink> docLinks = (List<ContentDocumentLink>)results;
    
    for (ContentDocumentLink docLink : docLinks) {
        Map<String, String> imageInfo = new Map<String, String>();
        imageInfo.put('id', docLink.ContentDocumentId);
        imageInfo.put('url', '/sfc/servlet.shepherd/version/download/' + docLink.ContentDocument.LatestPublishedVersion.Id);
        imageInfo.put('filename', docLink.ContentDocument.Title);  // Include filename
        
        // Convert file size from bytes to megabytes for readability
        Long fileSizeInBytes = docLink.ContentDocument.LatestPublishedVersion.ContentSize;
        Double fileSizeInMB = fileSizeInBytes / (1024.0 * 1024.0);
        imageInfo.put('size', String.valueOf(fileSizeInMB));
        
        // Include file length in the response
        imageInfo.put('length', String.valueOf(fileSizeInBytes));
        
        // Include file type in the response
        imageInfo.put('type', docLink.ContentDocument.LatestPublishedVersion.FileType);
        
        imageUrls.add(imageInfo);
    }
    
    return imageUrls;
}




}