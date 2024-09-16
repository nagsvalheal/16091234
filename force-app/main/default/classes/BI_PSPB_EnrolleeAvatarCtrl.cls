/**
 * @description    "This class is used to update the avatar for an enrollee, 
 * 					 when an enrollee record is updated, and handle any errors that occur during these operations."
 * 
 * History:
 * Version    Author        Date         Detail              Description
 * 1.0        Ashif         20-07-2024   Created             Initial development
 */
public with sharing class BI_PSPB_EnrolleeAvatarCtrl {
	private static Integer loginAttemptValue = 1;
/**
 * @description This method updates the avatar URL of an enrollee record identified by the provided enrollee ID. 
 * It also sets default values for login attempts and the first login date if they are not already set.return in lwc biPspbAvatarSelection, biPspFirsttimeAvatarSelection
 * @param enrolleeId The ID of the enrollee record to update.
 * @param avatarSrc The URL of the new avatar image to set for the enrollee.
 */
@AuraEnabled
public static void updateEnrolleeAvatar(String enrolleeId, String avatarSrc) {
	try {
		if (String.isBlank(enrolleeId) || String.isBlank(avatarSrc)) {
			BI_PSP_LogMessagesUtility.logError(
				BI_PSPB_EnrollmentConstant.getLabel('ERROR_GETTING_CPE'),
				BI_PSPB_EnrolleeAvatarCtrl.class.getName(),
				true,
				BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR')
			);
			return; 
		}
		
		// Fetch the enrollee record from the database
		Careprogramenrollee accountToUpdate = new Careprogramenrollee(Id = enrolleeId);
        
        Decimal cpeLoginattempt = BI_PSP_CurrentUser.getEnrolleeRecords()[0].BI_PSP_Loginattempt__c;
        Date cpeFirstLoginDate = BI_PSP_CurrentUser.getEnrolleeRecords()[0].BI_PSPB_FirstLoginDate__c;
      
		// Update the avatar URL
		accountToUpdate.BI_PSP_AvatarUrl__c = avatarSrc;

		// Set default values if necessary
		if (cpeLoginattempt == 0 || cpeLoginattempt == null) {
			accountToUpdate.BI_PSP_Loginattempt__c = loginAttemptValue;
		}
		if (cpeFirstLoginDate == null ) {
			accountToUpdate.BI_PSPB_FirstLoginDate__c = Date.today();
		}

		// Perform the update operation
		BI_PSP_DatabaseOperationsUtility.updateOperation(
			new List<Careprogramenrollee>{ accountToUpdate },
			BI_PSPB_EnrolleeAvatarCtrl.class.toString(),
			Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE'))
		);

	} catch (Exception ex) {
		BI_PSP_LogMessagesUtility.exceptionLogMessage(
		   ex.getMessage(),
			BI_PSPB_EnrolleeAvatarCtrl.class.getName(),
			ex
		);
	}
}

}