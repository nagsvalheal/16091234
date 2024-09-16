/**
 * @description Controller class for updating patient and caregiver information.
 * This class contains methods for updating lead records and caregiver records.
 * History
 * Version 	Author		Date			Detail		Description
 * 1.0		Sowmitha	30-July-2024	Created		Refactored code
 */
public without sharing class BI_PSPB_PatientEntityCtrl {
	/**
	 * @description Updates the Lead record with the provided information from the LeadWrapper.return in lwc biPspbHcpPrepopulateCaregiverForm,BiPspbHcpPrepopulatePatientForm
	 * This method updates the lead's contact and address information and logs consent.
	 *
	 * @param leadWrapper A LeadWrapper object containing the updated lead information.
	 */
	@AuraEnabled(cacheable=false)
	public static void updateLeadRecord(LeadWrapper leadWrapper) {
		//We are not checking LeadWrapper because all fields are mandatory in UI.
		try {
			// This is regarding to guestuser so can't use User_mode.
			Lead leadToUpdate = new Lead();
			String fields = 'Id,Phone,BI_PSPB_Preferred_Communication_Method__c,Country,State,City,Street,PostalCode,HealthCloudGA__Gender__c';
			String conditions = 'Id = \'' + leadWrapper.leadId + '\'';
			Boolean withSharingKeywrd = Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE'));
			List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQuery('Lead', fields, conditions, withSharingKeywrd);
			for (SObject sObj : sObjectResponses) {
				leadToUpdate = (Lead) sObjectResponses[0];
			}

			if (leadToUpdate != null) {
				leadToUpdate.Phone = leadWrapper.phone;
				leadToUpdate.HealthCloudGA__Gender__c = leadWrapper.gender;
				leadToUpdate.BI_PSPB_Preferred_Communication_Method__c = leadWrapper.prefferedMethodOfCom;
				leadToUpdate.CountryCode = leadWrapper.country;
				leadToUpdate.StateCode = leadWrapper.state;
				leadToUpdate.City = leadWrapper.city;
				leadToUpdate.Street = leadWrapper.street;
				leadToUpdate.PostalCode = leadWrapper.zipCode;
				BI_PSP_Lead_Consent__c leadConsentToInsert = new BI_PSP_Lead_Consent__c(
					BI_PSP_Lead__c = leadToUpdate.Id,
					BI_PSP_I_agree__c = true,
					BI_PSPB_Consent_Category__c = BI_PSPB_EnrollmentConstant.getLabel('PATIENT'),
					BI_PSPB_Conversion__c = true
				);

				BI_PSP_DatabaseOperationsUtility.updateOperation(new List<Lead>{ leadToUpdate },BI_PSPB_PatientEntityCtrl.class.toString(),Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE')));
				BI_PSP_DatabaseOperationsUtility.insertOperation(new List<BI_PSP_Lead_Consent__c>{ leadConsentToInsert },BI_PSPB_PatientEntityCtrl.class.toString(),Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE')));
			} else {
				BI_PSP_LogMessagesUtility.logError(BI_PSPB_EnrollmentConstant.getLabel('ERROR_MSG_RECORD_NOT_FOUND'),BI_PSPB_PatientEntityCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(ex.getMessage(),BI_PSPB_PatientEntityCtrl.class.getName(),ex);
		}
	}
	/**
 * @description This method updates the preferred method of communication, relationship to patient, 
 * and phone number for a lead's caregiver in the `BI_PSPB_Lead_Caregiver__c` object. 
 * Additionally, it inserts a new consent record into the `BI_PSP_Lead_Consent__c` object. 
 * The method handles cases where the lead ID or communication method is missing, 
 * logs errors, and performs database operations using utility methods.return in lwc BiPspbHcpPrepopulatePatientForm,biPspbHcpPrepopulateCaregiverForm
 * @param leadId The ID of the lead associated with the caregiver. This value must not be blank.
 * @param preferredMethodofCommunication The preferred method of communication for the caregiver. This value must not be blank.
 * @param relation The relationship of the caregiver to the patient.
 * @param phone The phone number of the caregiver.
 */

	@AuraEnabled(cacheable=false)
	public static void updateLead(
		String leadId,
		String preferredMethodofCommunication,
		string relation,
		string phone
	) {
		try {
			if (
				String.isBlank(leadId) ||
				String.isBlank(preferredMethodofCommunication) || String.isBlank(relation)
			) {
				BI_PSP_LogMessagesUtility.logError(BI_PSPB_EnrollmentConstant.getLabel('ERROR_MSG_RECORD_NOT_FOUND'),BI_PSPB_PatientEntityCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
			// Update Lead Caregiver
			// This is regarding to guestuser so can't use User_mode.
			String fields = 'Id,BI_PSPB_Preferred_Communication_Method__c,BI_PSPB_Lead__c';
			String conditions = 'BI_PSPB_Lead__c = \'' + leadId + '\''+
								'LIMIT 1';
			Boolean withSharingKeywrd = Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE'));
			BI_PSPB_Lead_Caregiver__c leadCaregiverToUpdate = new BI_PSPB_Lead_Caregiver__c(); 
			List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQuery('BI_PSPB_Lead_Caregiver__c', fields, conditions, withSharingKeywrd);
			for (SObject sObj : sObjectResponses) {
				leadCaregiverToUpdate = (BI_PSPB_Lead_Caregiver__c) sObjectResponses[0];
			}
			if (leadCaregiverToUpdate != null) {
				// Insert Lead Consent
				BI_PSP_Lead_Consent__c leadConsentToInsert = new BI_PSP_Lead_Consent__c();
				leadConsentToInsert.BI_PSP_Lead__c = leadCaregiverToUpdate.BI_PSPB_Lead__c;
				leadCaregiverToUpdate.BI_PSPB_Preferred_Communication_Method__c = preferredMethodofCommunication;
				leadCaregiverToUpdate.BI_PSPB_Relationship_to_Patient__c = relation;
				leadCaregiverToUpdate.BI_PSPB_Phone_number__c = phone;
				leadConsentToInsert.BI_PSPB_Consent_Category__c = BI_PSPB_EnrollmentConstant.getLabel('CAREGIVER');
				BI_PSP_DatabaseOperationsUtility.updateOperation(new List<BI_PSPB_Lead_Caregiver__c>{ leadCaregiverToUpdate },BI_PSPB_PatientEntityCtrl.class.toString(),Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE')));
				BI_PSP_DatabaseOperationsUtility.insertOperation(new List<BI_PSP_Lead_Consent__c>{ leadConsentToInsert },BI_PSPB_PatientEntityCtrl.class.toString(),Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE')));
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(BI_PSPB_EnrollmentConstant.getLabel('RECORD_CANNOT_FOUND'),BI_PSPB_PatientEntityCtrl.class.getName(),ex);
		}
	}
		/**
		 * @description This method updates the address and gender details of a Lead record based on the provided `LeadWrapper` object.
		 * It fetches the existing Lead record, updates the necessary fields, and then saves the updated record to the database.
		 * In case of any errors during the operation, the method logs the exception and handles it gracefully. return in BiPspbHcpPrepopulatePatientForm
		 * @param leadWrapper A `LeadWrapper` object containing the necessary Lead information such as `leadId`, `gender`, `country`, `state`, `city`, `street`, and `zipCode`.
		 * All fields in the `LeadWrapper` object are mandatory, as enforced by the UI.
		 */
		@AuraEnabled
		public static void updateLeadCareRecord(LeadWrapper leadWrapper) {
		// We are not checking LeadWrapper because all fields are mandatory in UI.
		try {
			if (leadWrapper != null && String.isNotBlank(leadWrapper.leadId)) {
				// Define the necessary parameters for the query
				String sObjectType = 'Lead';
				String fields = 'Id, Phone, BI_PSPB_Preferred_Communication_Method__c, Country, State, City, Street, PostalCode,HealthCloudGA__Gender__c';
				String conditions = 'Id = \'' + leadWrapper.leadId + '\'';
				Boolean withUserMode = Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE')); 

				// Call the common query utility method
				List<Lead> leadRecord = BI_PSP_CommonQueryUtility.executeQuery(sObjectType, fields, conditions, withUserMode);

				if (leadRecord != null && !leadRecord.isEmpty()) {
					Lead leadToUpdate = leadRecord[0];
					leadToUpdate.HealthCloudGA__Gender__c = leadWrapper.gender;
					leadToUpdate.CountryCode = leadWrapper.country;
					leadToUpdate.StateCode = leadWrapper.state;
					leadToUpdate.City = leadWrapper.city;
					leadToUpdate.Street = leadWrapper.street;
					leadToUpdate.PostalCode = leadWrapper.zipCode;

					// Use the utility to handle the update and any potential errors
					BI_PSP_DatabaseOperationsUtility.updateOperation(
						new List<Lead>{ leadToUpdate },
						BI_PSPB_PatientEntityCtrl.class.toString(),
						Boolean.valueOf(BI_PSPB_EnrollmentConstant.getLabel('USER_MODE_FALSE'))
					);
				} 
			} 
		} catch (Exception ex) {
			// Log the exception and rethrow a user-friendly error message
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_PatientEntityCtrl.class.getName(),
				ex
			);
		}
		}



	/**
	 * @description Wrapper class for Lead information.
	 * This class holds the data related to a Lead, including contact details and address.
	 */
	public class LeadWrapper {

		/**
		 * @description The unique identifier for the Lead.
		 */
		@AuraEnabled
		public String leadId { get; set; }

		/**
		 * @description The phone number of the Lead.
		 */
		@AuraEnabled
		public String phone { get; set; }

		/**
		 * @description The preferred method of communication for the Lead.
		 */
		@AuraEnabled
		public String prefferedMethodOfCom { get; set; }

		/**
		 * @description The country where the Lead is located.
		 */
		@AuraEnabled
		public String country { get; set; }

		/**
		 * @description The state where the Lead is located.
		 */
		@AuraEnabled
		public String state { get; set; }

		/**
		 * @description The city where the Lead is located.
		 */
		@AuraEnabled
		public String city { get; set; }

		/**
		 * @description The street address of the Lead.
		 */
		@AuraEnabled
		public String street { get; set; }

		/**
		 * @description The zip code of the Lead's address.
		 */
		@AuraEnabled
		public String zipCode { get; set; }
		/**
		 * @description The gender of the Lead's address.
		 */
		@AuraEnabled
		public String gender { get; set; }

	}

}