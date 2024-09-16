/**
 * @description This BI_PSP_UserEmailSyncSched class used to Update the User'sEmail.
 * History:
 * Version  Author          Date            Detail              Description
 * 1.0      Ashif           20-8-2024     Created             Initial development
 */
public class BI_PSP_UserEmailSyncSched implements Schedulable {
    private static String patient =  System.Label.BI_PSPB_PatientProfile;
	private static String logSeverityError  = BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR');
	private static String caregiver = System.Label.BI_PSPB_CaregiverProfile;

/**
 * @description This method is the `execute` method implementation for a class that implements the `Schedulable` interface. 
 * It is called by the Salesforce platform when a scheduled job is triggered. This method is responsible for invoking the 
 * `updateMismatchedUsernames` method to handle updating usernames that are mismatched.
 * 
 * @param sc The `SchedulableContext` object, which provides the context in which the scheduled job is running. 
 * It contains information such as the job ID, which can be used for tracking or additional processing.
 */
    public void execute(SchedulableContext sc) {
        updateMismatchedUsernames();
    }
/**
 * @description This @future method updates mismatched usernames for users with specific profiles.
 *              It compares the Username and Email fields for each user and sets the Email to match the Username if they are different.
 *              The method only processes users with the 'BI_PSP_Patient Profile' or 'BI_PSP_Caregiver Profile' profiles.
 */

    @future
public static void updateMismatchedUsernames() {
    List<User> usersToUpdate = new List<User>();
    
    // Define the fields to query
    String fields = 'Id, Username, Email';
        
    // Define the profile names to filter
    List<String> profileNames = new List<String>{patient, caregiver};
    String profileNamesString = '\'' + String.join(profileNames, '\',\'') + '\'';

    // Build the query conditions for Profile records
    String profileConditions = 'Name IN (' + profileNamesString + ')';
    Boolean withSharingKeyword = true; // Specify sharing rules if needed
         
    // Execute the query to get Profile records
    List<SObject> profileSObjects = BI_PSP_CommonQueryUtility.executeQuery('Profile', 'Id', profileConditions, withSharingKeyword);
       
    // Extract Profile IDs
    Set<Id> profileIds = new Set<Id>();
    for (SObject sObj : profileSObjects) {
        Profile p = (Profile) sObj;
        profileIds.add(p.Id);
    }
    // Build the query conditions for User records
    List<String> profileIdStrings = new List<String>();
    for (Id profileId : profileIds) {
        profileIdStrings.add(profileId);
    }
    
    String profileIdsString = '\'' + String.join(profileIdStrings, '\',\'') + '\'';
    String userConditions = 'ProfileId IN (' + profileIdsString + ')';

    // Execute the query to get User records
    List<SObject> userSObjects = BI_PSP_CommonQueryUtility.executeQuery('User', fields, userConditions, withSharingKeyword);

    // Convert the SObject results back to User records and prepare for update
    for (SObject sObj : userSObjects) {
        User u = (User) sObj;
        if (u.Username != u.Email) {
            u.Email = u.Username;  // Ensure username and email match
            usersToUpdate.add(u);
        }
    }

    // Perform the update if there are mismatches
    if (!usersToUpdate.isEmpty()) {
        BI_PSP_DatabaseOperationsUtility.updateOperation(
            usersToUpdate, 
            BI_PSP_UserEmailSyncSched.class.getName(), 
            false
        );
    }
}


}