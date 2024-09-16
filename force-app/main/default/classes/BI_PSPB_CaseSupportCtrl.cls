/*** @description This class provides support for managing the My Cases page. It is responsible for retrieving and displaying case records.
* History
* Version   Author   Date         Detail          Description
* 1.0       Rajaa    20-Dec-2024  Created         Initial development.
* 1.1       Rajaa    06-Apr-2024  Updated         Code review changes. */

public with sharing class BI_PSPB_CaseSupportCtrl {
    
    /** * @description Retrieves a list of cases based on the provided filter criteria, including type, status, and account Id.
* Queries the Case object and returns matching records. The query uses the CareProgramEnrollee lookup field, so user mode cannot be added here.
* @param type The type of cases to retrieve. Pass 'all' to retrieve all types.
* @param status The status of cases to retrieve. Pass 'all' to retrieve cases with all statuses.
* @return A list of Case records matching the provided filter criteria. This return is used in the BI_PSPB_CaseSupportCtrl component.
*/
    @AuraEnabled(cacheable=true) 
    public static List<Case> getCases(String type, String status) {
		try{
        String programId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
        String enrolleeFields = 'Id, AccountId';
        String enrolleeConditions = 'Id = \'' + programId + '\' LIMIT 1';
        Boolean withUserMode = false;
        
        List<SObject> enrolleeResults = BI_PSP_CommonQueryUtility.executeQuery(
            'CareProgramEnrollee',
            enrolleeFields,
            enrolleeConditions,
            withUserMode
        );
        if (enrolleeResults.isEmpty()) {
            BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,
                BI_PSPB_CaseSupportCtrl.class.toString(),false,BI_PSPB_SupportCenterConstant.logError);
            return null;
        }
        
        CareProgramEnrollee careProgram = (CareProgramEnrollee) enrolleeResults[0];
        Id accountId = careProgram.AccountId;
        
        List<SObject> caseResults = buildCaseQuery(accountId, status, type);
        
        if (caseResults.isEmpty()) {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,
                BI_PSPB_CaseSupportCtrl.class.toString(),
                false,
                BI_PSPB_SupportCenterConstant.logError
            );
            return null;
        }
        return (List<Case>) caseResults;
    }
 catch (Exception ex) {
	BI_PSP_LogMessagesUtility.exceptionLogMessage(
		ex.getMessage(),
		BI_PSPB_CaseSupportCtrl.class.toString(),
		ex
	);
	return null;
}
}
    
    private static List<SObject> buildCaseQuery(
        Id accountId,
        String status,
        String type
    ) {
        String caseFields = 'Id, CaseNumber, Subject, Status, Priority, Type, BI_PSP_Patient__c, BI_PSPB_Sub_Type__c, Description, CreatedDate';
        String caseConditions =
            'AccountId = \'' +
            accountId +
            '\' AND RecordType.Name = \'' +
            BI_PSPB_SupportCenterConstant.supportCenter +
            '\'';
        
        String query =
            'SELECT ' +
            caseFields +
            ' FROM Case WHERE ' +
            caseConditions;
        
        String statusFilter = buildStatusFilter(status);
        String typeFilter = buildTypeFilter(type);
        
        if (!String.isBlank(statusFilter)) {
            query += statusFilter;
        }
        if (!String.isBlank(typeFilter)) {
            query += typeFilter;
        }
        
        query += ' ORDER BY CreatedDate DESC LIMIT 10000';
        
        Boolean withUserMode = false;
        return BI_PSP_CommonQueryUtility.executeComplexQuery(
            query,
            withUserMode
        );
    }
    
    private static String buildStatusFilter(String status) {
        if (String.isBlank(status)) {
            return '';
        }
        switch on status.toLowerCase() {
            when 'all' {
                return ' AND (Status = \'Submitted\' OR Status = \'Draft\' OR Status = \'Need More Information\')';
            }
            when 'draft' {
                return ' AND (Status = \'Draft\' OR Status = \'Need More Information\')';
            }
            when 'submitted' {
                return ' AND (Status = \'Submitted\')';
            }
            when else {
                return ' AND Status = \'' + status + '\'';
            }
        }
    }
    
    private static String buildTypeFilter(String type) {
        if (String.isBlank(type)) {
            return '';
        }
        switch on type.toLowerCase() {
            when 'all' {
                return ' AND (type = \'Medical Information Enquiry\' OR type = \'Report an Adverse Events\' OR type = \'PSP Platform Support\')';
            }
            when 'medical information enquiry' {
                return ' AND (type = \'Medical Information Enquiry\')';
            }
            when 'report adverse events' {
                return ' AND (type = \'Report an Adverse Events\')';
            }
            when 'psp platform support' {
                return ' AND (type = \'PSP Platform Support\')';
            }
            when else {
                return ' AND Type = \'' + type + '\'';
            }
        }
    }
    
    /** * @description Retrieves the details of a specific Case record identified by the caseId parameter.
* Queries the Case object and returns the corresponding Case record with various details.
* @param caseId The Id of the Case record to retrieve details for.
* @return The Case record containing details such as Id, Subject, Type, Description, Status, Sub-Type, Created Date, and Created By Id. */
    @AuraEnabled
    public static Case getCaserecord(Id caseId) {
        if (caseId == null) {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_SupportCenterConstant.parameterError,
                BI_PSPB_CaseSupportCtrl.class.toString(),
                false,
                BI_PSPB_SupportCenterConstant.logError
            );
            return null;
        }
        String caseFields = 'Id, Subject, Type, Description, Status, BI_PSPB_Sub_Type__c, CreatedDate, CreatedBy.Name';
        String caseConditions = 'Id = \'' + caseId + '\'';
        Boolean withUserMode = true;
        List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
            'Case',
            caseFields,
            caseConditions,
            withUserMode
        );
        if (results.isEmpty()) {
            BI_PSP_LogMessagesUtility.logError( BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,
                BI_PSPB_CaseSupportCtrl.class.toString(),false,BI_PSPB_SupportCenterConstant.logError);
            return null;
        }
        return (Case) results[0];
    }
	/**
 * @description Wrapper class for storing image data.
 */
public class ImageWrapper {
    /**
     * @description Base64 encoded image data.
     */
    @AuraEnabled
    public String base64Image { get; set; }

    /**
     * @description Title of the image.
     */
    @AuraEnabled
    public String title { get; set; }

    /**
     * @description Type of the file (e.g., 'image/png', 'image/jpeg').
     */
    @AuraEnabled
    public String fileType { get; set; }
    /**
 *@description This property is used to store and retrieve the ID of the ContentVersion associated with the component.
 */
     @AuraEnabled
    public String contentVersionId { get; set; } // Add this line

    /**
     * @description Constructor for the ImageWrapper class.
     *
     * @param base64Image Base64 encoded image data.
     * @param title Title of the image.
     * @param fileType Type of the file.
     *  @param contentVersionId The ID of the ContentVersion record to be set.
     */
    public ImageWrapper(String base64Image, String title, String fileType,String contentVersionId) {
        this.base64Image = base64Image;
        this.title = title;
        this.fileType = fileType; 
        this.contentVersionId = contentVersionId;
    }
}

/**
 * @description Retrieves the base64 encoded image data associated with the provided caseId.
 * If image data is found, it is returned as a list of ImageWrapper objects. 
 * If no image data is found, an empty list is returned.
 * @param caseId The Id of the Case for which to retrieve the image data.
 * @return A list of ImageWrapper objects representing the image data.
 */
@AuraEnabled(cacheable=true)
public static List<ImageWrapper> getBaseImage(Id caseId) {
    List<ImageWrapper> images = new List<ImageWrapper>();
    try {
        if (caseId == null) {
            BI_PSP_LogMessagesUtility.logError(BI_PSPB_SupportCenterConstant.parameterError,
                BI_PSPB_CaseSupportCtrl.class.toString(), false, BI_PSPB_SupportCenterConstant.logError);
            return images;
        }
        List<ContentDocumentLink> contentDocs = getContentDocumentIds(caseId);
        if (contentDocs.isEmpty()) {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_SupportCenterConstant.errorMsgCaseRecordNotFound,
                BI_PSPB_CaseSupportCtrl.class.toString(),
                false,
                BI_PSPB_SupportCenterConstant.logError
            );
            return images;
        }
        for (ContentDocumentLink contentDoc : contentDocs) {
            images.addAll(getImages(contentDoc));
        }
    } catch (Exception ex) {
        BI_PSP_LogMessagesUtility.exceptionLogMessage(ex.getMessage(),
            BI_PSPB_CaseSupportCtrl.class.toString(), ex);
    }
    
    return images;
}

/**
 * @description Retrieves up to three ContentDocumentLink records related to the provided caseId.
 * @param caseId The Id of the Case for which to retrieve ContentDocumentLinks.
 * @return A list of up to three ContentDocumentLink records associated with the Case.
 */
private static List<ContentDocumentLink> getContentDocumentIds(Id caseId) {
    String fields = 'ContentDocumentId, ContentDocument.Title';
    String sObjectType = 'ContentDocumentLink';
    String conditions =
        'LinkedEntityId = \'' + caseId +
        '\' AND ContentDocument.FileType IN (\'jpg\', \'png\', \'pdf\') WITH USER_MODE ORDER BY SystemModstamp DESC LIMIT 3';
    Boolean withUserMode = false; // Enforce sharing rules
    
    List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
        sObjectType,
        fields,
        conditions,
        withUserMode
    );
    
    return (List<ContentDocumentLink>) results;
}

/**
 * @description Retrieves up to three ImageWrapper objects from the ContentVersion based on the provided ContentDocumentId.
 * @param contentDoc The ContentDocumentLink record to retrieve image data for.
 * @return A list of up to three ImageWrapper objects representing the image data.
 */
private static List<ImageWrapper> getImages(ContentDocumentLink contentDoc) {
    List<ImageWrapper> imageWrappers = new List<ImageWrapper>();
    String sObjectType = 'ContentVersion';
    String contentId = contentDoc.ContentDocumentId;
    String fields = 'VersionData, Title, FileType';
    String conditions = 
        'ContentDocumentId = \'' + contentId + 
        '\' AND FileType IN (\'jpg\', \'png\', \'pdf\') WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 3';
    Boolean withUserMode = false;
    
    List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
        sObjectType,
        fields,
        conditions,
        withUserMode
    );
    List<ContentVersion> contents = (List<ContentVersion>) results;
    
    for (ContentVersion content : contents) {
        if (content.VersionData != null) {
            String base64Image = BI_PSPB_SupportCenterConstant.baseImage + EncodingUtil.base64Encode(content.VersionData);
            String title = content.Title;
            String fileType = content.FileType;
             String contentVersionId = content.Id;
            imageWrappers.add(new ImageWrapper(base64Image, title, fileType, contentVersionId));
        } else {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_SupportCenterConstant.error,
                BI_PSPB_CaseSupportCtrl.class.toString(),
                false,
                BI_PSPB_SupportCenterConstant.logError
            );
        }
    }
   
    return imageWrappers;
}

}