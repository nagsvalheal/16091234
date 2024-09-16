/**
 * @description Apex class for creating and managing support cases related to the BI_PSPB module.
 * History
 * Version  Author          Date            Detail      Description
 * 59       Gokul           06-01-2024      Created     Initial Version
 * 59       Praveen         18-04-2024      Updated     Code review changes
 */
public with sharing class BI_PSPB_PatientCasesFilesCtrl {
	/**
* @description		Method to create ContentDocumentLinks for uploading files related to a case record
* @param			fileIds (List<String>)-  this string store the file ids. 
* @param			caseId (Id) this string store the related account ids.
This method used in BI_PSPB_InsertCaserecordforUpdateRx apex.
*/
	public static void getContentDocumentLinks(
		List<String> fileIds,
		string caseId
	) {
		// List to hold ContentDocumentLink records to be inserted.
		List<ContentDocumentLink> fileLinks = new List<ContentDocumentLink>();
		try {
			// The values in the fileIds can be null.Hence null check is not done.
			if (String.isNotBlank(caseId)) {
				// Loop through the list of fileIds provided.
				for (String fileId : fileIds) {
					// Create a ContentDocumentLink record for each fileId.
					ContentDocumentLink link = new ContentDocumentLink(
						ContentDocumentId = fileId,
						LinkedEntityId = caseId,
						ShareType = BI_PSPB_PrescriptionConstant.shareType // 'V' for sharing the file with the record.
					);
					fileLinks.add(link); // Add the ContentDocumentLink record to the list.
				}
				// Check if there are ContentDocumentLink records to be inserted.
			if(!fileLinks.isEmpty()){
				BI_PSP_DatabaseOperationsUtility.insertOperation(
					fileLinks,
					BI_PSPB_PatientCasesFilesCtrl.class.toString(),
					true
				);
				}
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_PrescriptionConstant.errorForInsert,
				BI_PSPB_PatientCasesFilesCtrl.class.toString(),
				ex
			);
		}
	}
  
    	/**
* @description		Method to create ContentDocumentLinks for uploading files related to a case record
* @param			caseId (List<String>)-  this string store the file ids. 
* @param			fileId (Id) this string store the related account ids.
This method used in BI_PSPB_InsertCaserecordforUpdateRx apex.
*/
@AuraEnabled
public static void deleteFile(Id caseId, Id fileId) {
    validateParameters(caseId, fileId);
    checkDeletePermissions();
    List<ContentDocumentLink> linksToDelete = findLinksToDelete(caseId, fileId);
    deleteLinks(linksToDelete);
}

private static void validateParameters(Id caseId, Id fileId) {
    if (caseId == null || fileId == null) {
        throw new AuraHandledException(BI_PSPB_SupportCenterConstants.invalidCaseId);
    }
}

private static void checkDeletePermissions() {
    if (!Schema.sObjectType.ContentDocumentLink.isAccessible() || 
        !Schema.sObjectType.ContentDocumentLink.isDeletable()) {
        throw new AuraHandledException(BI_PSPB_SupportCenterConstants.permissionToDelete);
    }
}

private static List<ContentDocumentLink> findLinksToDelete(Id caseId, Id fileId) {
    String sObjectType = 'ContentDocumentLink';
	String fields = 'Id';
	String conditions = 'LinkedEntityId = \'' + caseId + '\' AND ContentDocumentId = \'' + fileId + '\'';

	// Perform the query using the common utility
	Boolean withUserMode = false;
	List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
		sObjectType,
		fields,
		conditions,
		withUserMode
	);

	// Cast the results to the appropriate type
    List<ContentDocumentLink> linksToDelete = (List<ContentDocumentLink>)results;
    
    if (linksToDelete.isEmpty()) {
        throw new AuraHandledException(BI_PSPB_SupportCenterConstants.noFilesFound + caseId + BI_PSPB_SupportCenterConstants.fileIdToDelete + fileId);
    }
    
    return linksToDelete;
}

private static void deleteLinks(List<ContentDocumentLink> linksToDelete) {
    try {
        BI_PSP_DatabaseOperationsUtility.deleteOperation(
            linksToDelete,
            BI_PSPB_PatientCasesFilesCtrl.class.toString(),
            true
        );
    } catch (Exception e) {
        throw new AuraHandledException(BI_PSPB_SupportCenterConstants.fileIdCount + e.getMessage());
    }
}
}