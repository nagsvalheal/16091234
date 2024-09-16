/**
@description Case creation for account deletion request and account access request by patients
History:
Version    Author               Date              Detail         Description
1.0        Divya Bharathi S     6-Dec-2023        Created        Initial development
1.1        Divya Bharathi S     08-Apr-2024       Updated        Add null check
1.2        Divya Bharathi S     18-Apr-2024       Updated        Add Log
*/
public with sharing class BI_PSPB_CaseAccessCtrl {
  /**
  @description This method creates a case for account access based on the user's role.
  This method is used in biPspbPatientProfiledetails and biPspbCgPatientinfo LWC component.
  */
  @AuraEnabled
public static void createAccessCase() {
  try {
      String currentUserName = UserInfo.getName();
      String currentUserEmail = UserInfo.getUserEmail();

      User currentUser = getCurrentUser(currentUserName, currentUserEmail);
      List<Account> relatedAccounts = getRelatedAccounts(currentUser, currentUserName, currentUserEmail);

      if (relatedAccounts.isEmpty()) {
        BI_PSP_LogMessagesUtility.logError(BI_PSPB_ProfileManagerConstant.accountMessage,
                                           BI_PSPB_CaseAccessCtrl.class.toString(),TRUE, 
                                           BI_PSPB_ProfileManagerConstant.LOG_SEVERITY_ERROR);
      }
      Id recordTypeId = getCaseRecordTypeId();
      List<Case> casesToInsert = createCases(relatedAccounts, currentUser.Id, recordTypeId);
		if (!casesToInsert.isEmpty()) { saveCases(casesToInsert);
      }
  } catch (Exception ex) {
    BI_PSP_LogMessagesUtility.exceptionLogMessage(BI_PSPB_ProfileManagerConstant.insertError,
                                                  BI_PSPB_CaseAccessCtrl.class.toString(),
                                                  ex);
      
  }
}
/**
 * @description Retrieves a User record based on the provided name and email.
 * This method queries the User object using the provided name and email. It returns the first User record that matches the criteria. If no User record matches, it returns null.
 * @param currentUserName The name of the user to be retrieved. This should be the exact name as stored in the User record.
 * @param currentUserEmail The email of the user to be retrieved. This should be the exact email as stored in the User record.
 * @return The User record that matches the given name and email. Returns null if no matching User record is found.
 */
public static User getCurrentUser(String currentUserName, String currentUserEmail) {
  String sObjectType = 'User';
  String fields = 'Id, Name, Email, BI_PSPB_Caregiver__c';
  String conditions = 'Name = \'' + currentUserName + '\' AND Email = \'' + currentUserEmail + '\'';
  Boolean withUserMode = true; 

  List<SObject> sObjectList = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withUserMode);

  List<User> userList = (List<User>) sObjectList;
  if (!userList.isEmpty()) {
      return userList[0];
   
  } else {  return null;
  }
}
/**
 * @description Retrieves a list of related Account records based on the provided User information.
 * This method performs different queries based on whether the currentUser has the BI_PSPB_Caregiver__c field set to true or not. 
 * If the currentUser is a caregiver, it retrieves related Account records based on the selected patient ID from the first query.
 * If the currentUser is not a caregiver, it retrieves Account records that match the provided user's name and email.
 * @param currentUser The User record used to determine the query conditions. It contains the BI_PSPB_Caregiver__c field and other relevant information.
 * @param currentUserName The name of the user to be used in query conditions.
 * @param currentUserEmail The email of the user to be used in query conditions.
 * @return A list of Account records that match the criteria based on the currentUser's caregiver status and the provided name and email.
 * If no matching Account records are found, an empty list is returned.
 */
public static List<Account> getRelatedAccounts(User currentUser, String currentUserName, String currentUserEmail) {
  List<Account> relatedAccounts = new List<Account>();

  if (currentUser.BI_PSPB_Caregiver__c) {
    String sObjectType = 'Account';
    String fields = 'Id, Name, PersonEmail, BI_PSPB_Selected_Patient_ID__c';
    String conditions = 'Name = \'' + currentUserName + '\' AND PersonEmail = \'' + currentUserEmail + 
                        '\' AND IsPersonAccount = TRUE AND BI_PSPB_Selected_Patient_ID__c != NULL';
    Boolean withUserMode = true;

    List<SObject> sObjectList = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withUserMode);
    List<Account> selectedPatientAccounts = (List<Account>) sObjectList;

    if (!selectedPatientAccounts.isEmpty()) {sObjectType = 'Account'; fields = 'Id, Name, PersonEmail';
        conditions = 'Id = \'' + selectedPatientAccounts[0].BI_PSPB_Selected_Patient_ID__c + '\'';
		sObjectList = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withUserMode);
        relatedAccounts = (List<Account>) sObjectList;
    }
} else {
    String sObjectType = 'Account';
    String fields = 'Id, Name, PersonEmail';
    String conditions = 'PersonEmail = \'' + currentUserEmail + 
                        '\' AND Name = \'' + currentUserName + '\'';
    Boolean withUserMode = true; 

    List<SObject> sObjectList = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withUserMode);
    relatedAccounts = (List<Account>) sObjectList;
}
  return relatedAccounts;
}
/**
 * @description Retrieves the record type ID for the 'Case' object based on a predefined record type name.
 * This method queries the record type ID for the 'Case' object using a predefined record type name constant. If the record type ID is not found or is blank, it logs an error message.
 * @return The ID of the 'Case' record type. If the record type ID cannot be found or is blank, it returns null.
 */
public static Id getCaseRecordTypeId() {

     Id recordTypeId = BI_PSP_CommonQueryUtility.retrieveRecordTypeId('Case',BI_PSPB_ProfileManagerConstant.caseRecordType);
  
  if (String.isBlank(recordTypeId)) {
    BI_PSP_LogMessagesUtility.logError(BI_PSPB_ProfileManagerConstant.accountMessage,BI_PSPB_CaseAccessCtrl.class.toString(),TRUE,
                                       BI_PSPB_ProfileManagerConstant.LOG_SEVERITY_ERROR);
  } 
	 return recordTypeId;
}
/**
 * Creates a list of Case records based on the provided related Accounts.
 * This method generates a list of Case records, setting various fields such as Subject, Description, and Priority for each Case.
 * @description It assigns each Case to the specified owner and sets the record type for the Case. The Account IDs from the provided list are used to associate each Case with an Account.
 * @param relatedAccounts A list of Account records that will be associated with the newly created Cases. Each Account ID is used to set the  field of the Case.
 * @param ownerId The ID of the user who will be the owner of the newly created Cases. This ID is used to set the field of each Case.
 * @param recordTypeId The ID of the record type to assign to the newly created Cases. This ID is used to set the  field of each Case.
 * @return A list of Case records with the specified fields set, ready to be inserted into the database. The list contains one Case for each Account in the provided  list.
 */
public static List<Case> createCases(List<Account> relatedAccounts, Id ownerId, Id recordTypeId) {
  List<Case> casesToInsert = new List<Case>();

  for (Account relatedAccount : relatedAccounts) {
      Case newCase = new Case();
      newCase.Subject = BI_PSPB_ProfileManagerConstant.accessReq;
      newCase.Description = BI_PSPB_ProfileManagerConstant.accessReq;
      newCase.BI_PSP_Type__c = BI_PSPB_ProfileManagerConstant.accessReq;
      newCase.Priority = BI_PSPB_ProfileManagerConstant.medium;
      newCase.OwnerId = ownerId;
      newCase.AccountId = relatedAccount.Id;
      newCase.RecordTypeId = recordTypeId;
      casesToInsert.add(newCase);
  } return casesToInsert;
}
/**
 * @description Inserts a list of Case records into the database.
 * This method calls a utility function to perform an insert operation for the provided list of Case records. The insert operation is logged with the class name and a failure flag indicating whether the operation should be logged as a failure.
 * @param casesToInsert A list of Case records to be inserted into the database. Each Case in the list should be fully populated with the necessary field values before this method is called.
 */
public static void saveCases(List<Case> casesToInsert) {
  BI_PSP_DatabaseOperationsUtility.insertOperation( casesToInsert ,BI_PSPB_CaseAccessCtrl.class.toString(),FALSE);

}
  /**
   * @description Retrieves the checkbox values for a given case record.
   *              This method is used in biPspbPatientProfiledetails and biPspbCgPatientinfo LWC components.
   * @param relatedAccounts The Id of the related account.
   * @return The Case record containing checkbox values if found; otherwise, null.
   */
  @AuraEnabled(cacheable=true)
  public static Case checkboxPersonalAccess(String relatedAccounts) {
      Case caseRecord;
      try {
          if (String.isBlank(relatedAccounts)) {
            BI_PSP_LogMessagesUtility.logError(BI_PSPB_ProfileManagerConstant.caseAccess, BI_PSPB_CaseAccessCtrl.class.toString(),false,BI_PSPB_ProfileManagerConstant.LOG_SEVERITY_ERROR);
          }

String sObjectType = 'Case';
String fields = 'Id, BI_PSP_Personal_Information_Request__c, BI_PSP_Account_Deletion_Request__c';
String conditions = 'AccountId = \'' + relatedAccounts + 
                    '\' AND BI_PSP_Type__c = \'' + BI_PSPB_ProfileManagerConstant.accessReq + '\'';
Boolean withUserMode = true; 

List<SObject> sObjectList = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withUserMode);

List<Case> casesList = (List<Case>) sObjectList;

if (!casesList.isEmpty()) {
    caseRecord = casesList[0];
}
          if (caseRecord == null) {
            BI_PSP_LogMessagesUtility.logError(BI_PSPB_ProfileManagerConstant.caseAccess, 
            BI_PSPB_CaseAccessCtrl.class.toString(),false,BI_PSPB_ProfileManagerConstant.LOG_SEVERITY_ERROR);
              return null;
          }
    
      } catch (Exception ex) {
        BI_PSP_LogMessagesUtility.exceptionLogMessage(BI_PSPB_ProfileManagerConstant.caseAccess,BI_PSPB_CaseAccessCtrl.class.toString(),ex);
      }
      return caseRecord;
  }    
}