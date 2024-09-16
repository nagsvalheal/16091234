/**
* @description  Retrieves the caregiver ID associated with a given enrollee ID.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_CaregiverProcessorCtrl {
	/**
	* @description  This method queries the BI_PSPB_Enrollee_Caregiver__c
	object to find an active caregiver linked to the provided enrollee.
	* @param enrolleeId Id of the Cre program enrollee.
	* @return Id Id of the enrollee caregiver.
	*/
    public static Id fetchCaregiverId(Id enrolleeId) {
		List<BI_PSPB_Enrollee_Caregiver__c> enrolleeCaregiverList;
		try{
            if(enrolleeId == null){
                BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
                BI_PSPB_CaregiverProcessorCtrl.class.toString(),
                true,
                BI_PSPB_NotificationConstantsCtrl.severityError
				);
            }
            system.debug('enrolleeId'+enrolleeId);
			// Query to find the active caregiver associated with the enrollee
			String fields =
				'BI_PSPB_Caregiver__r.Id,BI_PSPB_Care_Program_Enrollee__c,BI_PSPB_Status__c';
			String conditions = 'BI_PSPB_Care_Program_Enrollee__c = \'' + enrolleeId + '\''
				+ 'AND BI_PSPB_Status__c = \'' +
				BI_PSPB_NotificationConstantsCtrl.actionTypeActive + '\' ' +
				'LIMIT 1';
			enrolleeCaregiverList = 
				BI_PSP_CommonQueryUtility.executeQuery('BI_PSPB_Enrollee_Caregiver__c',fields,conditions,false);
		} catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_CaregiverProcessorCtrl.class.toString(),
				true, BI_PSPB_NotificationConstantsCtrl.severityError);
        }
		// Check if any records are returned and return the caregiver ID or null
		if (!enrolleeCaregiverList.isEmpty()) {
			return enrolleeCaregiverList[0].BI_PSPB_Caregiver__r.Id;
		} else {
			return null;
		}
	}
}