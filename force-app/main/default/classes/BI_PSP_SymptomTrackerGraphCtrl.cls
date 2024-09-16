/**
 * @description Controller class for managing Symptom Tracker details.
 * Provides methods to retrieve and process symptom records based on enrollee ID and date range.
 */
public with sharing class BI_PSP_SymptomTrackerGraphCtrl {
	/**
	 * @description Retrieves symptom tracker details based on enrollee ID and date range.
	 *
	 * @param erolleId The enrollee ID to filter the symptom records.
	 * @return A list of SymptomTracker objects representing the symptom tracker details, or null if no records are found or an error occurs.
	 */
	@AuraEnabled(cacheable=true)
	public static List<SymptomTracker> getSymptomTrackerDetails(String erolleId) {
		try {
			List<BI_PSP_Symptom_Tracker__c> recordSymptom = fetchSymptomRecords(
				erolleId
			);
			if (recordSymptom.isEmpty()) {
				return null;
			}

			List<SymptomTracker> symptomTrackers = processSymptomRecords(
				recordSymptom
			);
			return symptomTrackers.isEmpty() ? null : symptomTrackers;
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSP_SymptomTrackerConstant.symptomErrorMsg,
				BI_PSP_SymptomTrackerGraphCtrl.class.toString(),
				ex
			);
			return null;
		}
	}
	/**
	 * @description Fetches symptom records from the database based on the given parameters.
	 *
	 * @param erolleId The enrollee ID to filter the records.
	 * @return A list of BI_PSP_Symptom_Tracker__c records matching the criteria.
	 */
	private static List<BI_PSP_Symptom_Tracker__c> fetchSymptomRecords(
		String erolleId
	) {
		String activeStatusValue = String.valueOf(
			BI_PSP_QuestionnaireConstant.symptomStatusInactive
		);
		String query =
			'SELECT Id, LastModifiedDate, BI_PSP_Care_Program_Enrollee__c, BI_PSP_EditEntrydates__c, CreatedDate ' +
			'FROM BI_PSP_Symptom_Tracker__c ' +
			'WHERE BI_PSP_Care_Program_Enrollee__c = \'' +
			erolleId +
			'\' ' +
			'AND BI_PSP_Symptom_Staus__c != \'' +
			activeStatusValue +
			'\' ' +
			'ORDER BY BI_PSP_EditEntrydates__c ASC';

		List<BI_PSP_Symptom_Tracker__c> symptomRecords = BI_PSP_CommonQueryUtility.executeComplexQuery(
			query,
			false
		);
		return symptomRecords;
	}
	
	private static List<SymptomTracker> processSymptomRecords(
		List<BI_PSP_Symptom_Tracker__c> recordSymptom
	) {
		List<SymptomTracker> symptomTrackers = new List<SymptomTracker>();
		Set<Id> symptomIds = extractSymptomIds(recordSymptom);
		Set<Date> datesWithAllergyRecords = new Set<Date>();
	
		if (!symptomIds.isEmpty()) {
			List<AllergyIntolerance> allergyTrack = fetchAllergyIntolerance(symptomIds);
			handleAllergyRecords(allergyTrack, symptomTrackers, datesWithAllergyRecords);
		}
	
		addDefaultSymptomTrackers(recordSymptom, datesWithAllergyRecords, symptomTrackers);
	
		return symptomTrackers;
	}
	
	/**
	 * @description Processes allergy records and updates symptom trackers.
	 *
	 * @param allergyTrack A list of AllergyIntolerance records.
	 * @param symptomTrackers A list to be populated with SymptomTracker objects.
	 * @param datesWithAllergyRecords A set to keep track of dates with allergy records.
	 */
	private static void handleAllergyRecords(
		List<AllergyIntolerance> allergyTrack,
		List<SymptomTracker> symptomTrackers,
		Set<Date> datesWithAllergyRecords
	) {
		if (!allergyTrack.isEmpty()) {
			for (AllergyIntolerance allergy : allergyTrack) {
				symptomTrackers.add(createSymptomTracker(allergy));
				if (allergy.BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c != null) {
					datesWithAllergyRecords.add(allergy.BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c);
				}
			}
		}
	}
	
	/**
	 * @description Adds default symptom trackers for records that do not have allergy records.
	 *
	 * @param recordSymptom A list of BI_PSP_Symptom_Tracker__c records.
	 * @param datesWithAllergyRecords A set of dates that have allergy records.
	 * @param symptomTrackers A list to be populated with default SymptomTracker objects.
	 */
	private static void addDefaultSymptomTrackers(
		List<BI_PSP_Symptom_Tracker__c> recordSymptom,
		Set<Date> datesWithAllergyRecords,
		List<SymptomTracker> symptomTrackers
	) {
		for (BI_PSP_Symptom_Tracker__c record : recordSymptom) {
			if (record.BI_PSP_EditEntrydates__c != null && !datesWithAllergyRecords.contains(record.BI_PSP_EditEntrydates__c)) {
				symptomTrackers.add(createDefaultSymptomTracker(record));
			}
		}
	}
	/**
	 * @description Extracts symptom IDs from the list of BI_PSP_Symptom_Tracker__c records.
	 *
	 * @param recordSymptom A list of BI_PSP_Symptom_Tracker__c records.
	 * @return A set of symptom IDs extracted from the records.
	 */
	private static Set<Id> extractSymptomIds(
		List<BI_PSP_Symptom_Tracker__c> recordSymptom
	) {
		Set<Id> symptomIds = new Set<Id>();
		for (BI_PSP_Symptom_Tracker__c symp : recordSymptom) {
			if (symp.Id != null) {
				// Ensure Id is not null
				symptomIds.add(symp.Id);
			}
		}

		return symptomIds;
	}
	/**
	 * @description Fetches allergy intolerance records based on symptom IDs.
	 *
	 * @param symptomIds A set of symptom IDs to filter the allergy intolerance records.
	 * @return A list of AllergyIntolerance records matching the symptom IDs.
	 */
	private static List<AllergyIntolerance> fetchAllergyIntolerance(
		Set<Id> symptomIds
	) {
		String symptomIdsString = '\'' + String.join(symptomIds, '\',\'') + '\'';
		String query =
			'SELECT Id, BI_PSP_Graph_Symptom_Name__c, BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c, ' +
			'BI_PSP_Symptoms__r.HealthCloudGA__CarePlanTemplate__r.Name ' +
			'FROM AllergyIntolerance ' +
			'WHERE BI_PSP_Symptom_Name__r.Id IN (' +
			symptomIdsString +
			')' +
			'AND BI_PSP_Symptoms__r.HealthCloudGA__CarePlanTemplate__r.Name != NULL ' +
			'AND BI_PSP_Symptoms__c != NULL ' +
			'ORDER BY BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c';

		List<AllergyIntolerance> allergyIntoleranceRecords = BI_PSP_CommonQueryUtility.executeComplexQuery(
			query,
			false
		);
		return allergyIntoleranceRecords;
	}
	/**
	 * @description Creates a SymptomTracker object from an AllergyIntolerance record.
	 *
	 * @param allergy The AllergyIntolerance record to convert.
	 * @return A SymptomTracker object representing the provided AllergyIntolerance record.
	 */
	private static SymptomTracker createSymptomTracker(
		AllergyIntolerance allergy
	) {
		SymptomTracker symp = new SymptomTracker();
		symp.symptom = allergy.BI_PSP_Symptom_Name__c;
		symp.dates = allergy.BI_PSP_Symptom_Name__r.BI_PSP_EditEntrydates__c;
		symp.name = allergy.BI_PSP_Symptoms__r.HealthCloudGA__CarePlanTemplate__r.Name;

		return symp;
	}
	/**
 * @description Creates a default SymptomTracker object indicating no symptoms for the month.
 *
 * @param recordSymptom The BI_PSP_Symptom_Tracker__c record used to populate the SymptomTracker object.
 * @return A SymptomTracker object with a message indicating no symptoms.
 */
private static SymptomTracker createDefaultSymptomTracker(BI_PSP_Symptom_Tracker__c   recordSymptom) {
    SymptomTracker symp = new SymptomTracker();
		symp.symptom = recordSymptom.Id ;
		symp.dates = recordSymptom.BI_PSP_EditEntrydates__c;
		symp.name = BI_PSP_SymptomTrackerConstant.noSymptom;
    return symp;
}
	/**
	 * Represents a wrapper class for symptom tracker data in Salesforce.
	 * @description This class encapsulates symptom tracking information retrieved from Salesforce records.
	 */
	public class SymptomTracker {
		/**
		 * The date of the symptom tracker record.
		 * @description This field represents when the symptom record was created or last modified.
		 */
		@AuraEnabled
		public Date dates; // Date of the symptom tracker record.

		/**
		 * The name associated with the symptom.
		 * @description This field represents the name of the symptom as recorded in Salesforce.
		 */
		@AuraEnabled
		public String name; // Name associated with the symptom.

		/**
		 * The description of the symptom.
		 * @description This field provides a description or additional information about the symptom.
		 */
		@AuraEnabled
		public String symptom; // Description of the symptom.
	}
}