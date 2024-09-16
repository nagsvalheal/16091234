/**
* @description This class is used to get treatment and prescription records
for the enrolled care program enrollee.
* History
* Version	Author			Date		Detail		Description
* 1.0		Ragavi		26-08-2024		Created		New Version
*/
public without sharing class BI_PSPB_InsiteTreatmentCtrl {
    @AuraEnabled
    /**
    * @description  Retrieves treatment and prescription records for the enrollee id.
    * @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
    */
    public static List<BI_PSPB_Treatment_Reminder__c> getTreatmentRecords() {
	List<SObject> treatmentRecords;
	try{
        Id enrolleeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
            String fields = 'Id, BI_PSPB_Date_of_Treatment__c, BI_PSPB_Care_Program_Enrollee__c, BI_PSPB_Reminder_Type__c, BI_PSPB_Status__c';
            String conditions = 'BI_PSPB_Care_Program_Enrollee__c = \'' + enrolleeId + '\' AND BI_PSPB_Status__c = \'' +
            BI_PSPB_NotificationConstantsCtrl.actionTypeActive + '\'';
            treatmentRecords = BI_PSP_CommonQueryUtility.executeQuery(
                'BI_PSPB_Treatment_Reminder__c',
                fields,
                conditions,
                false
            );
        } catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
			ex.getMessage(),
			BI_PSPB_InsiteTreatmentCtrl.class.toString(),
			ex
		);
		}
        return treatmentRecords;
    }
}