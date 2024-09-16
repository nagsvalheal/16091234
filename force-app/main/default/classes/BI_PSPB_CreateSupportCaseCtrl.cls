/**
 * @description Apex class for creating and managing support cases related to the BI_PSPB module.
 * History
 * Version  Author          Date        Detail      Description
 * 59       Niyas       06-01-2024      Created     Initial Version
 * 59       Niyas       18-04-2024      Updated     Code review changes
 */
public with sharing class BI_PSPB_CreateSupportCaseCtrl {
	 

	/** * @description Creates a new support case.
	 * @param wrapper The LeadWrapper object containing case details.
	 * @param fileIds The IDs of the files to be linked to the case.
	 * @return The ID of the created case.*/

	@AuraEnabled(cacheable=false)
	public static id createCase(LeadWrapper wrapper, List<String> fileIds) {
		//We are not checking LeadWrapper because all fields are mandatory in UI.
		Case supportCaseToInsert = new Case();
		try {
			String sObjectType = 'CareProgramEnrollee';
			String fields = 'Id, AccountId';
			String conditions = 'Id = \'' + wrapper.accountId + '\'';
			Boolean withUserMode = false; // Set this based on your requirement

			// Use the common query utility to execute the query
			List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
				sObjectType,
				fields,
				conditions,
				withUserMode
			);
			CareProgramEnrollee careProgramRecord = (results.isEmpty()? null
				: (CareProgramEnrollee) results[0]);
			if (careProgramRecord != null) {
				String recordTypeId = 
                    BI_PSP_CommonQueryUtility.retrieveRecordTypeId
                    ('Case',BI_PSPB_SupportCenterConstant.caseRecordTypeName);
				if (String.isBlank(recordTypeId)) {
					// Return null if leadId is blank
			BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.errorMsgRecordTypeNotFound,BI_PSPB_CreateSupportCaseCtrl.class.toString(),
						false,BI_PSPB_SupportCenterConstant.logError);
					return null;
				}
				supportCaseToInsert.Type = wrapper.type;
				supportCaseToInsert.BI_PSPB_Sub_Type__c = 
                    wrapper.subType;
				supportCaseToInsert.Description = wrapper.description;
				supportCaseToInsert.BI_PSP_Patient__c = 
                    careProgramRecord.Id;
				supportCaseToInsert.AccountId = 
                    careProgramRecord.AccountId;
				supportCaseToInsert.RecordTypeId = recordTypeId;
				supportCaseToInsert.Status = 
                    BI_PSPB_SupportCenterConstant.submitted;
				BI_PSP_DatabaseOperationsUtility.insertOperation(
					new List<Case>{ supportCaseToInsert },
					BI_PSPB_CreateSupportCaseCtrl.class.toString(),
					false
				);
				if (supportCaseToInsert == null) {
					BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,BI_PSPB_CreateSupportCaseCtrl.class.toString(),
						false,BI_PSPB_SupportCenterConstant.logError);
					return null;
				} else {
					if (!fileIds.isEmpty()) {
						BI_PSPB_PatientCasesFilesCtrl.getContentDocumentLinks(
							fileIds,
							supportCaseToInsert.Id
						);
					}
					return supportCaseToInsert.id;
				}
			} else {
				BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.errorMsgRecordNotFound,BI_PSPB_CreateSupportCaseCtrl.class.toString(),
					false,BI_PSPB_SupportCenterConstant.logError);
				return null;
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_CreateSupportCaseCtrl.class.toString(),
				ex
			);
			return null;
		}
	}

	/** * @description Updates a Case record with the provided information and links files to it.
	 * @param wrapper The LeadWrapper object containing case details.
	 * @param fileIds The IDs of the files to be linked to the case.
	 * @return The ID of the updated case. */

	@AuraEnabled(cacheable=false)
	public static id caseDraft(LeadWrapper wrapper, List<String> fileIds) {
		//We are not checking LeadWrapper because all fields are mandatory in UI.
		Case supportCaseToUpdate = new Case();
		try {
			String sObjectType = 'CareProgramEnrollee';
			String fields = 'Id, AccountId';
			String conditions = 'Id = \'' + wrapper.accountId + '\'';
			Boolean withUserMode = false; // Set this based on your requirement

			// Use the common query utility to execute the query
			List<SObject> results = 
                BI_PSP_CommonQueryUtility.executeQuery(
				sObjectType,
				fields,
				conditions,
				withUserMode
			);
			CareProgramEnrollee careProgramRecord = 
                (results.isEmpty()
				? null
				: (CareProgramEnrollee) results[0]);
			if (careProgramRecord != null) {
				String recordTypeId = BI_PSP_CommonQueryUtility.retrieveRecordTypeId
                    ('Case',BI_PSPB_SupportCenterConstant.caseRecordTypeName);
				if (String.isBlank(recordTypeId)) {
					BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.errorMsgRecordTypeNotFound,BI_PSPB_CreateSupportCaseCtrl.class.toString(),
						false,BI_PSPB_SupportCenterConstant.logError);
					return null;
				}
				supportCaseToUpdate.Type = wrapper.type;
				supportCaseToUpdate.BI_PSPB_Sub_Type__c = 
                    wrapper.subType;
				supportCaseToUpdate.Description = wrapper.description;
				supportCaseToUpdate.BI_PSP_Patient__c = 
                    careProgramRecord.Id;
				supportCaseToUpdate.AccountId = careProgramRecord.AccountId;
				supportCaseToUpdate.RecordTypeId = recordTypeId;
				supportCaseToUpdate.Status = 
                    BI_PSPB_SupportCenterConstant.draft;
				BI_PSP_DatabaseOperationsUtility.insertOperation(
					new List<Case>{ supportCaseToUpdate },
					BI_PSPB_CreateSupportCaseCtrl.class.toString(),
					false
				);
				if (supportCaseToUpdate == null) {
					BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,BI_PSPB_CreateSupportCaseCtrl.class.toString(),
						false,BI_PSPB_SupportCenterConstant.logError);
					return null;
				} else {
					if (!fileIds.isEmpty()) {
						BI_PSPB_PatientCasesFilesCtrl.getContentDocumentLinks(
							fileIds,
							supportCaseToUpdate.Id
						);
					}
					return supportCaseToUpdate.id;
				}
			} else {
				BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.errorMsgRecordNotFound,BI_PSPB_CreateSupportCaseCtrl.class.toString(),
					false,BI_PSPB_SupportCenterConstant.logError);
				return null;
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_CreateSupportCaseCtrl.class.toString(),
				ex
			);
			return null;
		}  
	}
/**
 *@description Saves a list of files to a specified case record.
 *
 * This method performs the following operations:
 * 1. Validates the provided case ID.
 * 2. Checks user permissions.
 * 3. Creates ContentVersion records for the files.
 * 4. Inserts the ContentVersion records into the database.
 * 5. Creates ContentDocumentLink records to link the files to the case.
 * 6. Inserts the ContentDocumentLink records into the database.
 *
 * @param fileUploads A list of FileUploadWrapper objects containing the files to be uploaded.
 * @param caseId The ID of the case to which the files will be attached.
 */
@AuraEnabled
public static void saveFilesToCase(List<FileUploadWrapper> fileUploads, Id caseId) {
	validateCaseId(caseId);
	checkPermissions();
	
	List<ContentVersion> contentVersions = createContentVersions(fileUploads, caseId);
	if (!contentVersions.isEmpty()) {
		BI_PSP_DatabaseOperationsUtility.insertOperation(
			contentVersions,
			BI_PSPB_CreateSupportCaseCtrl.class.toString(),
			true
		);
		List<ContentDocumentLink> contentDocumentLinks = createContentDocumentLinks(contentVersions, caseId);
		if (!contentDocumentLinks.isEmpty()) {
			BI_PSP_DatabaseOperationsUtility.insertOperation(
				contentDocumentLinks,
				BI_PSPB_CreateSupportCaseCtrl.class.toString(),
				true
			);
		}
	}
}

private static void validateCaseId(Id caseId) {
	if (String.isBlank(caseId)) {
		throw new AuraHandledException(BI_PSPB_SupportCenterConstant.caseIdRequire);
	}
}

private static void checkPermissions() {
	if (!Schema.sObjectType.ContentVersion.isCreateable() ||
		!Schema.sObjectType.ContentDocumentLink.isCreateable()) {
		throw new AuraHandledException(BI_PSPB_SupportCenterConstant.permissionToCreate);
	}
}

private static List<ContentVersion> createContentVersions(List<FileUploadWrapper> fileUploads, Id caseId) {
	List<ContentVersion> contentVersions = new List<ContentVersion>();
	Set<String> fileNames = new Set<String>();
	
	for (FileUploadWrapper fileUpload : fileUploads) {
		if (fileNames.contains(fileUpload.fileName)) {
			continue;
		}
		fileNames.add(fileUpload.fileName);
		
		ContentVersion contentVersion = new ContentVersion();
		contentVersion.Title = fileUpload.fileName;
		contentVersion.PathOnClient = '/' + fileUpload.fileName;
		contentVersion.VersionData = EncodingUtil.base64Decode(fileUpload.fileData);
		contentVersion.FirstPublishLocationId = caseId;
		contentVersions.add(contentVersion);
	}
	return contentVersions;
}

Public static List<ContentDocumentLink> createContentDocumentLinks(List<ContentVersion> contentVersions, Id caseId) {
	List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
	Set<Id> contentVersionIds = new Set<Id>();
	
	for (ContentVersion cv : contentVersions) {
		contentVersionIds.add(cv.Id);
	}
	
	Map<Id, Id> contentVersionToDocumentIdMap = fetchContentDocumentIds(contentVersionIds);
	Map<Id, Id> existingLinks = fetchExistingLinks(caseId);
	
	for (ContentVersion cv : contentVersions) {
		Id contentDocumentId = contentVersionToDocumentIdMap.get(cv.Id);
		if (contentDocumentId != null && !existingLinks.containsKey(contentDocumentId)) {
			ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
			contentDocumentLink.ContentDocumentId = contentDocumentId;
			contentDocumentLink.LinkedEntityId = caseId;
			contentDocumentLink.ShareType = BI_PSPB_SupportCenterConstant.shareType; // View permission
			contentDocumentLinks.add(contentDocumentLink);
			existingLinks.put(contentDocumentId, caseId);
		}
	}
	
	return contentDocumentLinks;
}

public static Map<Id, Id> fetchContentDocumentIds(Set<Id> contentVersionIds) {
	Map<Id, Id> contentVersionToDocumentIdMap = new Map<Id, Id>();
	for (ContentVersion cv : [
		SELECT Id, ContentDocumentId 
		FROM ContentVersion 
		WHERE Id IN :contentVersionIds
	]) {
		contentVersionToDocumentIdMap.put(cv.Id, cv.ContentDocumentId);
	}
	return contentVersionToDocumentIdMap;
}

 public static Map<Id, Id> fetchExistingLinks(Id caseId) {
        Map<Id, Id> existingLinks = new Map<Id, Id>();
        for (ContentDocumentLink link : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :caseId
        ]) {
            existingLinks.put(link.ContentDocumentId, link.LinkedEntityId);
        }
        return existingLinks;
    }
/**
 * Wrapper class for handling file uploads.
 *
 * @description This class is used to encapsulate the details of a file being uploaded, including its name and base64-encoded data.
 */
public class FileUploadWrapper {
    /**
     *@description The name of the file being uploaded.
     */
    @AuraEnabled
    public String fileName { get; set; }

    /**
     *@description The base64-encoded data of the file being uploaded.
     */
    @AuraEnabled
    public String fileData { get; set; }
}


	/** * @description A wrapper class used to hold a group of related data fields together. This class encapsulates information about a patient or caregiver. */
	public class LeadWrapper {
		/** * @description The account ID associated with the patient or caregiver. */
		@AuraEnabled
		public String accountId { get; set; }
		/**     * @description The type of the patient or caregiver. */
		@AuraEnabled
		public String type { get; set; }
		/** * @description The subtype address of the patient or caregiver. */
		@AuraEnabled
		public String subType { get; set; }
		/** * @description The description of the patient or caregiver. */
		@AuraEnabled
		public String description { get; set; }
	}
}