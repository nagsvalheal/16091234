/**
* @description  Retrieves the caregiver ID associated with a given enrollee ID.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_EnrolleeProcessorCtrl {
    /**
	* @description  This method queries the BI_PSPB_Enrollee_Caregiver__c
	object to find an active caregiver linked to the provided enrollee.
	* @param enrolleeRecIds A list of IDs for which the CareProgramEnrollee records are to be fetched.
    * @return List<CareProgramEnrollee> A list of CareProgramEnrollee records that match the provided IDs.
	*/
    public static List<CareProgramEnrollee> fetchEnrolleeRecords(List<Id> enrolleeRecIds) {
        List<CareProgramEnrollee> enrolleeList;
        try{
            if(enrolleeRecIds.isEmpty()){
            	BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
                BI_PSPB_EnrolleeProcessorCtrl.class.toString(),
                true,
                BI_PSPB_NotificationConstantsCtrl.severityError
            );
            }
            String fields = 'Id, Name, Account.BI_PSP_Birthdate__c, Account.Name';
            String conditionIds = '(\'' + String.join(enrolleeRecIds, '\', \'') + '\')';
            String conditions = 'Id IN' + conditionIds;
            enrolleeList = BI_PSP_CommonQueryUtility.executeQuery('CareProgramEnrollee',
                fields, conditions, false);
                
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_EnrolleeProcessorCtrl.class.toString(),
				true, BI_PSPB_NotificationConstantsCtrl.severityError);
        }
        return enrolleeList;
    }
    /**
	* @description  Calculates the age based on the provided birthdate and today's date.
	* @param birthDate The birth date of the individual.
    * @param today The current date, used to compute the age.
    * @return Integer The age of the individual.
	*/
    public static Integer calculateAge(Date birthDate, Date today) {
        Integer age = today.year() - birthDate.year();
        if (today < birthDate.addYears(age)) {
            age--;
        }
        return age;
    }
    /**
	* @description  Fetches a set of enrollee IDs from the CareProgramEnrollee object.
    * @return Set<Id> A set of enrollee IDs.
	*/
    public static Set<Id> fetchEnrolleeIds() {
        Set<Id> enrolleeIds = new Set<Id>();
            List<SObject> enrolleeRecords = BI_PSP_CommonQueryUtility.executeQuery(
                'CareProgramEnrollee',
                'Id',
                null,
                false
            );
            for (SObject cpe : enrolleeRecords) {
                enrolleeIds.add(cpe.Id);
            }
            return enrolleeIds;
    }
}