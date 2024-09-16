/**
 * @description This class is used for setting up, fetching the username for the community.
 * History:
 * Version  Author      Date            Detail          Description
 * 1.0      Deepa       05-Dec-2023     Created         Initial development.
 * 1.1      Deepa       20-Jan-2024     Updated         Updated for caregiver.
 * 1.2      Deepa       04-Apr-2024     Updated         Catch log added.
 * 1.3      Deepa       22-Apr-2024     Updated         Code Review.
 * 1.4      Deepa       27-Apr-2024     Updated         Updated for KO.
 * 1.5		Deepa		27-Jul-2024		Updated			Refactor.
 */
public with sharing class BI_PSPB_FeedUsernameCtrl {
	/**
    * @description	To check the username for community already exists.
    * @return		Boolean Returns true , if there is a username already.
            Returns false when there is no username.
            Returns boolean value to biPspbCreatPost,biPspbMyPost,
            biPspbAllPost,biPspbNavBar LWC.
    */
	@AuraEnabled
	public static Boolean checkCommunityUsername() {
		List<CareProgramEnrollee> cpeRecord;
		try {
			String cpeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].id;
			// Define the parameters for the query
			String objectName = 'CareProgramEnrollee';
			String fields = 'Id, BI_PSP_CommunityUsername__c';
			String conditions = 'Id = \'' + cpeId + '\'' + 'LIMIT 1';
			Boolean withUserMode = Boolean.valueOf(
				BI_PSP_ChallengeConstant.userModeFalse
			);

			cpeRecord = BI_PSP_CommonQueryUtility.executeQuery(
				objectName,
				fields,
				conditions,
				withUserMode
			);
			if (cpeRecord[0].BI_PSP_CommunityUsername__c != null
			) {
				// Returning true when BI_PSP_CommunityUsername__c is not null.
				return true;
			} else {
				// Returning false when BI_PSP_CommunityUsername__c is null.
				return false;
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_CommunityConstant.errorWhileGetUsername,
				BI_PSPB_FeedUsernameCtrl.class.toString(),
				ex
			);
			return false; // Return false in case of an exception
		}
	}
	/**
    * @description	Retrieves the CommunityUsername for a user.
    * @return		CareProgramEnrollee - The CareProgramEnrollee record containing the 
            CommunityUsername, or null if not found.
            Returns to biPspbChatterUsername LWC.
    */
	@AuraEnabled
	public static List<Account> getCommunityUsername() {
		List<Account> accountRecord;
		try {
			// Getting the CareProgramEnrollee ID associated with the user ID.
			String accountId = BI_PSP_CurrentUser.returnTheAccounts()[0].Id;
			// Query for CareProgramEnrollee to get the CommunityUsername.
			// Define the parameters for the query
			String objectName = 'Account';
			String fields = 'Id, FirstName, LastName, PersonEmail, Phone';
			String conditions = 'Id = \'' + accountId + '\'';
			Boolean withUserMode = Boolean.valueOf(
				BI_PSP_ChallengeConstant.userModeTrue
			);

			accountRecord = BI_PSP_CommonQueryUtility.executeQuery(
				objectName,
				fields,
				conditions,
				withUserMode
			);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_CommunityConstant.errorWhileGetUsername,
				BI_PSPB_FeedUsernameCtrl.class.toString(),
				ex
			);
		}
		/** Here 'cpeRecord' is not checked for null exception as 
        it is handled in LWC.
        There are two different scenario such as it takes an action when 
        it is returned as null and another action when it is returned with values.*/
		return accountRecord;
	}
	/**
    * @description	Creates a CommunityUsername for the specified
            user if it doesn't exist.
    * @param		username - The username to insert.
    This method is used in biPspbChatterUsername LWC.
    */
	@AuraEnabled
	public static void insertCommunityUsername(string username) {
		try {
			List<CareProgramEnrollee> cpeRecord;
			if (String.isBlank(username)) {
				// Throwing an exception when user ID is blank.
				logError(BI_PSPB_CommunityConstant.errorWhileGetUsername);
			}
			// Getting the CareProgramEnrollee ID associated with the user ID.
			String cpeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
			// Query for CareProgramEnrollee to get the CommunityUsername.
			// Define the parameters for the query
			String objectName = 'CareProgramEnrollee';
			String fields = 'Id, BI_PSP_CommunityUsername__c';
			String conditions = 'Id = \'' + cpeId + '\'' + 'LIMIT 1';
			Boolean withUserMode = Boolean.valueOf(
				BI_PSP_ChallengeConstant.userModeFalse
			);

			cpeRecord = BI_PSP_CommonQueryUtility.executeQuery(
				objectName,
				fields,
				conditions,
				withUserMode
			);
			// Updating the CommunityUsername field with the provided username.
			cpeRecord[0].BI_PSP_CommunityUsername__c = username;
			// Updating the CareProgramEnrollee record.
			BI_PSP_DatabaseOperationsUtility.updateOperation(
				cpeRecord,
				BI_PSPB_FeedUsernameCtrl.class.toString(),
				false
			);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_CommunityConstant.errorWhileCreatingUsername,
				BI_PSPB_FeedUsernameCtrl.class.toString(),
				ex
			);
		}
	}
	// Method to log errors
	private static void logError(String errorMessage) {
		BI_PSP_LogMessagesUtility.logError(
			errorMessage,
			BI_PSPB_FeedUsernameCtrl.class.toString(),
			true,
			BI_PSPB_CommunityConstant.LOG_SEVERITY_ERROR
		);
	}
}