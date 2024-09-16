/** 
 * @description       : A CurrentUser Utility Class for determining user type whether it is a patient or caregiver.
 * History:
 * Version  Author      Date            Detail          Description.
 * 1.0      Abinsha     10-Jul-2024     Created         Initial development.
 * 1.1      Ashif       1-Aug -2024     Updated         Refactor the code.
 * 1.3      Abinsha     27-Aug-2024     updated         Added null checks.
 */
public inherited sharing class BI_PSP_CurrentUser {
	/**
	 * @description Returns a list of accounts based on the current user's role.
	 * If the user is a caregiver, it returns the associated patient's account.
	 * If the user is a patient, it returns the patient's account.
	 *
	 * @return List<Account> - A list of Account records. If the user is a caregiver,
	 * it returns the selected patient's account. If the user is a patient, it returns the patient's account.
	 */
	@AuraEnabled(cacheable=true)
	public static List<Account> returnTheAccounts() {
		if (getCurrentUser() == null) {
			getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.patientAccountErrorMsg,BI_PSP_CurrentUser.class.toString());
			return new List<Account>(); // Return an empty list if no user is found
		}
		User currentUser = getCurrentUser();

		if (currentUser.BI_PSPB_Caregiver__c) {
			return getCaregiverAccounts();
		} else {
			return getPatientAccounts();
		}
	}
	/**
	 * @description Retrieves the current user details.
	 * This method fetches the user information from the User object based on the current logged-in user's ID.
	 * If no user is found, it logs an error message.
	 * @return User - The current user record.
	 */
	@AuraEnabled(cacheable=true)
	public static User getCurrentUser() {
		String sObjectType = 'User';
		String fields = 'Id, Name, LastName, Email,Username, FirstName, BI_PSPB_Caregiver__c, Profile.Name';
		String conditions = 'Id = \'' + UserInfo.getUserId() + '\'';

		List<SObject> users = BI_PSP_CommonQueryUtility.executeQuery(
			sObjectType,
			fields,
			conditions,
			BI_PSP_QuestionnaireConstant.withSharingKeywrd
		);
		if (users.isEmpty()) {
			getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.careGiversPatientAccountErr,BI_PSP_CurrentUser.class.toString());
			return null;
		}
		return (User) users[0];
	}

	private static List<Account> getCaregiverAccounts() {
		Account caregiverAccount = getCaregiverAccount();
		if (caregiverAccount == null) {
			getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.careGiversPatientAccountErr,BI_PSP_CurrentUser.class.toString());
			return new List<Account>();
		}

		Account selectedPatientAccount = getSelectedPatientAccount(
			caregiverAccount.BI_PSPB_Selected_Patient_ID__c
		);
		if (selectedPatientAccount == null) {
			getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.careGiversSelectedPatientErrMsg,BI_PSP_CurrentUser.class.toString());
			return new List<Account>();
		}

		return new List<Account>{ selectedPatientAccount };
	}

	private static List<Account> getPatientAccounts() {
		Account patientAccount = getPatientAccount();
		if (patientAccount == null) {
			getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.patientAccountErrorMsg,BI_PSP_CurrentUser.class.toString());
			return new List<Account>();
		}

		return new List<Account>{ patientAccount };
	}
	/**
	 * @description Retrieves the Account record associated with the current user if they are a Caregiver.
	 *
	 * @return The Account record matching the current user's name, email, and Caregiver role.
	 *         Returns null if no matching Account is found.
	 */
	@AuraEnabled(cacheable=true)
	public static Account getCaregiverAccount() {
		String sObjectType = 'Account';
		String fields = 'Id, Name, PersonEmail,FirstName,BI_PSPB_Selected_Patient_ID__c';
		String conditions =
			'Name = \'' +
			UserInfo.getName() +
			'\' AND ' +
			'PersonEmail = \'' +
			UserInfo.getUserName() +
			'\' AND ' +
			'IsPersonAccount = TRUE AND ' +
			'BI_PSPB_User_Type__c = \'Caregiver\'';
		Boolean withUserMode = true;

		List<SObject> accounts = BI_PSP_CommonQueryUtility.executeQuery(
			sObjectType,
			fields,
			conditions,
			withUserMode
		);
		return accounts.isEmpty() ? null : (Account) accounts[0];
	}
	/**
	 *@description Retrieves an Account record based on the provided patient ID.
	 *
	 * @param selectedPatientId The ID of the Account to retrieve.
	 * @return The Account record associated with the provided ID. Returns null if no Account is found.
	 */
	public static Account getSelectedPatientAccount(Id selectedPatientId) {
		String sObjectType = 'Account';
		String fields = 'Id, Name,FirstName,PersonEmail,BI_PSP_Age__c,Phone';
		String conditions = 'Id = \'' + selectedPatientId + '\'';
		Boolean withUserMode = true;

		List<SObject> accounts = BI_PSP_CommonQueryUtility.executeQuery(
			sObjectType,
			fields,
			conditions,
			withUserMode
		);
		return accounts.isEmpty() ? null : (Account) accounts[0];
	}

	private static Account getPatientAccount() {
		String sObjectType = 'Account';
		String fields = 'Id, Name,FirstName,PersonEmail';
		String conditions =
			'PersonEmail = \'' +
			UserInfo.getUserName() +
			'\' AND ' +
			'Name = \'' +
			UserInfo.getName() +
			'\'';
		Boolean withUserMode = true;

		List<SObject> accounts = BI_PSP_CommonQueryUtility.executeQuery(
			sObjectType,
			fields,
			conditions,
			withUserMode
		);
		return accounts.isEmpty() ? null : (Account) accounts[0];
	}
	/**
 * @description Retrieves enrollee records associated with the current user's accounts.
 * This method fetches the enrollee records from the CareProgramEnrollee object based on the associated account's ID.
 * If no enrollees are found, it logs an error message.
 * 
 * @return List<CareProgramEnrollee> - A list of CareProgramEnrollee records associated with the current user's accounts.

 */
	@AuraEnabled(cacheable=true)
	public static List<CareProgramEnrollee> getEnrolleeRecords() {
		List<Account> accounts = returnTheAccounts();
		List<CareProgramEnrollee> enrollees = new List<CareProgramEnrollee>();

		if (!accounts.isEmpty()) {
			String sObjectType = 'CareProgramEnrollee';
			String fields = 'Id, Name, BI_PSP_AvatarUrl__c, BI_PSPB_PatientStatus__c,Account.BI_PSPB_User_Type__c, BI_PSP_Loginattempt__c, Account.Name,Account.Phone,Account.BI_PSP_Age__c,BI_PSPB_FirstLoginDate__c';
			String conditions = 'AccountID = \'' + accounts[0].Id + '\'';

			List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
				sObjectType,
				fields,
				conditions,
				BI_PSP_QuestionnaireConstant.withSharingKeywrd
			);
			enrollees = (List<CareProgramEnrollee>) results;

		 }
        else{
            getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.patientAccountErrorMsg,BI_PSP_CurrentUser.class.toString());
         }
		  if (enrollees.isEmpty()) {
		     getCurrentUserErrorMsg(BI_PSP_QuestionnaireConstant.emptyEnrolleRecrd,BI_PSP_CurrentUser.class.toString());
		  }
		return enrollees;
	}
	/**
	 * @description Logs an error message related to the current user.
	 *
	 * @param errroMsg The error message to be logged.
	 */
	public static void getCurrentUserErrorMsg(String errroMsg,String className) {
		BI_PSP_LogMessagesUtility.logError(
			errroMsg,
			className,
			true,
			BI_PSP_QuestionnaireConstant.LOG_SEVERITY_ERROR
		);
	}
}