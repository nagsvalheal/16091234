/**
 * @description This class serves as a centralized repository for constants and custom labels used in the update prescription process.
 * It provides easy access to labels such as share types, error messages, and record type names and IDs, ensuring consistency across the prescription-related functionality.
 * 
 * History:
 * Version   Author           Date            Detail                               Description
 * 1.0       Gokul Krishnan   10-Aug-2024     Created                               Initialized constants and custom labels for use in the prescription update process.
 */
public with sharing class BI_PSPB_PrescriptionConstant {
    public static String shareType = System.Label.BI_PSPB_ShareType;
	public static String errorForInsert = System.Label.BI_PSPB_InsertError;
    public static String recordTypeName = System.Label.BI_PSPB_PrescriptionRecordType;
	public static String errorForCase = System.Label.BI_PSPB_ErrorForCase;
	public static Id recordTypeId = BI_PSP_CommonQueryUtility.retrieveRecordTypeId('Case', recordTypeName);
}