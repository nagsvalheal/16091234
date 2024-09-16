/**
* @description  This class is used to fetch the symptom
records for the enrollee.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_SymptomProcessorCtrl {
	/**
    * @description Processes symptom trackers for the provided
	enrollee IDs and returns relevant symptom record IDs.
    * @param enrolleeIds Set of enrollee ids.
    * @param wpaiCount Integer for WPAI.
    * @return List<Id> The list of symptom record Ids.
    */
    public static List<Id> processSymptomTrackers(Set<Id> enrolleeIds, Integer wpaiCount) {
        List<Id> enrolleeRecIds = new List<Id>();
        try {
            List<BI_PSP_Symptom_Tracker__c> symptomTrackers = getEnrolleeQuery(enrolleeIds);
            if (symptomTrackers.isEmpty()) {
                logRecordNotFound();
                return enrolleeRecIds;
            }
            Map<Id, BI_PSP_Symptom_Tracker__c> latestSymptomMap = buildLatestSymptomMap(symptomTrackers);
            addRecentEnrolleeRecords(enrolleeRecIds, latestSymptomMap, wpaiCount);
        } catch (Exception ex) {
            logException(ex);
        }
        return enrolleeRecIds;
    }
	/**
	* @description Builds a map of the latest symptom trackers by enrollee ID.
	* @param symptomTrackers List of symptom tracker records to process.
	* @return Map<Id, BI_PSP_Symptom_Tracker__c> Map of latest symptom records by enrollee ID.
	*/
    private static Map<Id, BI_PSP_Symptom_Tracker__c> buildLatestSymptomMap(List<BI_PSP_Symptom_Tracker__c> symptomTrackers) {
        Map<Id, BI_PSP_Symptom_Tracker__c> latestSymptomMap = new Map<Id, BI_PSP_Symptom_Tracker__c>();
        for (BI_PSP_Symptom_Tracker__c symptom : symptomTrackers) {
            latestSymptomMap.put(symptom.BI_PSP_Care_Program_Enrollee__c, symptom);
        }
        return latestSymptomMap;
    }
	/**
	* @description Adds enrollee IDs to the list if their symptom record is within the specified number of days.
	* @param enrolleeRecIds List to which enrollee IDs will be added.
	* @param latestSymptomMap Map of latest symptom records by enrollee ID.
	* @param wpaiCount Integer representing the number of days for WPAI.
	*/
    private static void addRecentEnrolleeRecords(List<Id> enrolleeRecIds, Map<Id, BI_PSP_Symptom_Tracker__c> latestSymptomMap, Integer wpaiCount) {
        for (BI_PSP_Symptom_Tracker__c latestSymptom : latestSymptomMap.values()) {
            if (isRecordWithinDays(latestSymptom, wpaiCount)) {
                enrolleeRecIds.add(latestSymptom.BI_PSP_Care_Program_Enrollee__c);
            }
        }
    }
	/**
	* @description Checks if the symptom record's creation date is within the specified number of days.
	* @param latestSymptom Symptom tracker record to check.
	* @param wpaiCount Integer representing the number of days for WPAI.
	* @return Boolean True if the record is within the specified days, false otherwise.
	*/
    private static boolean isRecordWithinDays(BI_PSP_Symptom_Tracker__c latestSymptom, Integer wpaiCount) {
        if (latestSymptom.CreatedDate == null) {
            return false;
        }

        Date sevenDaysLaterDate = latestSymptom.CreatedDate.addDays(wpaiCount).date();
        return Date.today() == sevenDaysLaterDate;
    }
	/**
	* @description Logs an exception message with details of the caught exception.
	*/
    private static void logRecordNotFound() {
        BI_PSP_LogMessagesUtility.logError(
			BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
            BI_PSPB_SymptomProcessorCtrl.class.toString(),
            true,
            BI_PSPB_NotificationConstantsCtrl.severityError
        );
    }
	/**
	* @description Logs an exception message with details of the caught exception.
	* @param ex Exception that was caught.
	*/
    private static void logException(Exception ex) {
        BI_PSP_LogMessagesUtility.exceptionLogMessage(
            '',
            BI_PSPB_SymptomProcessorCtrl.class.getName(),
            ex
        );
    }
	/**
	* @description Retrieves symptom tracker records for the specified enrollee IDs.
	* @param enrolleeIds Set of enrollee IDs to query.
	* @return List<BI_PSP_Symptom_Tracker__c> List of symptom 
	tracker records for the provided enrollee IDs.
	*/
    public static List<BI_PSP_Symptom_Tracker__c> getEnrolleeQuery(Set<Id> enrolleeIds) {
		List<BI_PSP_Symptom_Tracker__c> symptomList;
		try{
            if(enrolleeIds.isEmpty()){
                logRecordNotFound();
            }
			List<String> enrolleeIdStrings = new List<String>();
			for (Id id : enrolleeIds) {
				enrolleeIdStrings.add(id);
			}
            String conditionIds = '(\'' + String.join(enrolleeIdStrings, '\', \'') + '\')';
			String fields = 'Id, BI_PSP_Care_Program_Enrollee__c, CreatedDate';
			String conditions = 'BI_PSP_Care_Program_Enrollee__c IN' + conditionIds 
				+ 'ORDER BY CreatedDate DESC';
			symptomList = 
				BI_PSP_CommonQueryUtility.executeQuery('BI_PSP_Symptom_Tracker__c',
				fields, conditions, false);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_SymptomProcessorCtrl.class.toString(), false,
				BI_PSPB_NotificationConstantsCtrl.severityError);
		}
		return symptomList;
    }
}