/**
 * @description This class is used for guest users, which is why it is not shared. 
 * It is used to retrieve data from the product from CareProgramProduct objects.
 * History
 * Version 	Author		Date			Detail		Description
 * 1.0      Ashif           05-Nov-2023     Created             Initial development
 * 1.1      Ashif           04-Apr-2024     Updated             Catch log added
 * 1.2      Sowmitha        30-Jul-2024     Updated             Code refactored
 */
public without sharing class BI_PSPB_ProductListCtrl {
	private static String drug = BI_PSPB_EnrollmentConstant.getLabel('SPEVIGO_DRUG');
	private static String errorForCareprogramProduct = BI_PSPB_EnrollmentConstant.getLabel('ERROR_FOR_CAREPROGRAM_PRODUCT');
/**
 * @description Fetches the products associated with a care program.
 * This method queries the CareProgram and CareProgramProduct objects to retrieve products related to a specific care program. return in lwc biPspHcpEnrollment
 *
 * @return List of CareProgramProduct objects associated with the care program.
 */
	@AuraEnabled(cacheable=true)
	public static List<CareProgramProduct> getProductList() {
		List<CareProgramProduct> lstCarePgmProducts = new List<CareProgramProduct>();
		try {
			//Since this object is invoked from a Guest User Profile which has limited access to the Health Cloud objects, User Mode cannot be used here
			// This is a searchable combo box. If the Aura Enabled Exception is thrown, for every character search, the error 
			// will be displayed that disrupts the screen design. 
			//In the respective LWC, the error message is displayed as 'Unable to find' below the combo box input field 
			//(that will be visible to the user)  if the record is not found. the record is not found.
			CareProgram careprg = new CareProgram(); 
			String fields = 'Id';
			String conditions = 'Name = \'' + drug + '\''+
								'LIMIT 1';
			Boolean withSharingKeywrd = false;
			List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQuery('CareProgram', fields, conditions, withSharingKeywrd);
			for (SObject sObj : sObjectResponses) {
				careprg = (CareProgram) sObjectResponses[0];
			}
			if(careprg !=null){
				String fieldscp = 'Id, Name';
				String conditionsForCp = 'CareProgramId = \'' + careprg.Id + '\'';
				Boolean withSharingKeyword = false;
				List<SObject> sObjectRes = BI_PSP_CommonQueryUtility.executeQuery('CareProgramProduct', fieldscp, conditionsForCp, withSharingKeyword);
				for (SObject sObj : sObjectRes) {
					lstCarePgmProducts.add((CareProgramProduct) sObj);
				}
			// This is a searchable combo box. If the Aura Enabled Exception is thrown, for every character search, the error 
			// will be displayed that disrupts the screen design. 
			//In the respective LWC, the error message is displayed as 'Unable to find' below the combo box input field 
			//(that will be visible to the user)  if the record is not found.
			}else{  
			   BI_PSP_LogMessagesUtility.logError(errorForCareprogramProduct,BI_PSPB_ProductListCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
			if(lstCarePgmProducts.isEmpty())
			{
				BI_PSP_LogMessagesUtility.logError(errorForCareprogramProduct,BI_PSPB_ProductListCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(null, BI_PSPB_ProductListCtrl.class.getName(), ex);
			// Returning null if an exception occurs
			// Handling error in Lwc
			return null;
		}
		return lstCarePgmProducts;
	}

/**
 * @description Fetches the product details in the care program product.
 * This method queries the CareProgramProduct object to retrieve details for a specific product.
 *
 * @param productId The ID of the product to fetch details for.
 * @return List of CareProgramProduct objects containing the product details.
 */
	@AuraEnabled(cacheable=true)
	public static List<CareProgramProduct> getPrescritionData(String productId) {
		List<CareProgramProduct> carepgmProductList = new List<CareProgramProduct>();
		try {
			//Since this object is invoked from a Guest User Profile which has limited access 
			//to the Health Cloud objects, User Mode cannot be used here
			if(String.isBlank(productId)){
				BI_PSP_LogMessagesUtility.logError(errorForCareprogramProduct,BI_PSPB_ProductListCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
			String fields = 'Id,Name,BI_PSPB_Product_code__c,BI_PSPB_Dosage__c,BI_PSPB_Unit__c,BI_PSPB_Unit__r.Name';
			String conditions = 'Id = \'' + productId + '\'';
			Boolean withSharingKeywrd = false;
			List<SObject> sObjectResponses = BI_PSP_CommonQueryUtility.executeQuery('CareProgramProduct', fields, conditions, withSharingKeywrd);
			for (SObject sObj : sObjectResponses) {
				carepgmProductList.add((CareProgramProduct) sObj);
			}
			if(carepgmProductList.isEmpty()){
				BI_PSP_LogMessagesUtility.logError(errorForCareprogramProduct,BI_PSPB_ProductListCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(errorForCareprogramProduct, BI_PSPB_ProductListCtrl.class.getName(), ex);
		}
		return carepgmProductList;
	}
	/**
 * @description This method retrieves a list of `BI_PSPB_Frequency__c` records based on the provided frequency name 
 * and drug name. The method is used for a searchable combo box in a Lightning Web Component (LWC) and handles potential 
 * errors gracefully to avoid disrupting the user experience.
 *
 * @param frequency The name of the frequency to filter the `BI_PSPB_Frequency__c` records.
 * @param drug The name of the drug to filter the `BI_PSPB_Frequency__c` records.
 * 
 * @return List<BI_PSPB_Frequency__c> A list of `BI_PSPB_Frequency__c` records that match the provided frequency and drug.
 * If no records are found or an exception occurs, it returns an empty list or null respectively.
 
 */
    @AuraEnabled(cacheable=true)
	public static List<BI_PSPB_Frequency__c> getFrequency(String frequency, String drug) {
		List<BI_PSPB_Frequency__c> lstFrequency = new List<BI_PSPB_Frequency__c>();
		try {
			//Since this object is invoked from a Guest User Profile which has limited access to the Health Cloud objects, User Mode cannot be used here
			// This is a searchable combo box. If the Aura Enabled Exception is thrown, for every character search, the error 
			// will be displayed that disrupts the screen design. 
			//In the respective LWC, the error message is displayed as 'Unable to find' below the combo box input field 
			//(that will be visible to the user)  if the record is not found. the record is not found.
			
				String fieldscp = 'Id, Name,BI_PSP_Quantity__c,BI_PSP_Drug__c ';
				String conditionsForCp = 'Name = \'' + frequency + '\' AND BI_PSP_Drug__r.Name = \'' + drug + '\'';
				Boolean withSharingKeyword = false;
				List<SObject> sObjectRes = BI_PSP_CommonQueryUtility.executeQuery('BI_PSPB_Frequency__c', fieldscp, conditionsForCp, withSharingKeyword);
				for (SObject sObj : sObjectRes) {
					lstFrequency.add((BI_PSPB_Frequency__c) sObj);
				}
			
			if(lstFrequency.isEmpty())
			{
				BI_PSP_LogMessagesUtility.logError(errorForCareprogramProduct,BI_PSPB_ProductListCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(null, BI_PSPB_ProductListCtrl.class.getName(), ex);
			// Returning null if an exception occurs
			// Handling error in Lwc
			return null;
		}
		return lstFrequency;
	}
	/**
 * @description This method retrieves a list of `BI_PSPB_Frequency__c` records based on the provided drug ID. 
 * The method is used for a searchable combo box in a Lightning Web Component (LWC) and handles potential 
 * errors gracefully to avoid disrupting the user experience.
 *
 * @param drug The ID of the drug to filter the `BI_PSPB_Frequency__c` records. 
 * @return List<BI_PSPB_Frequency__c> A list of `BI_PSPB_Frequency__c` records that match the provided drug ID.
 * If no records are found, it logs an error and returns an empty list. If an exception occurs, it returns null.
 */
 @AuraEnabled(cacheable=true)
	public static List<BI_PSPB_Frequency__c> getFrequencydata( String drug) {
		List<BI_PSPB_Frequency__c> lstFrequency = new List<BI_PSPB_Frequency__c>();
		try {
			//Since this object is invoked from a Guest User Profile which has limited access to the Health Cloud objects, User Mode cannot be used here
			// This is a searchable combo box. If the Aura Enabled Exception is thrown, for every character search, the error 
			// will be displayed that disrupts the screen design. 
			//In the respective LWC, the error message is displayed as 'Unable to find' below the combo box input field 
			//(that will be visible to the user)  if the record is not found. the record is not found.
			
				String fieldscp = 'Id, Name,BI_PSP_Quantity__c,BI_PSP_Drug__c ,BI_PSP_Drug__r.Id ';
				String conditionsForCp = 'BI_PSP_Drug__r.Id = \'' + drug + '\'';
				Boolean withSharingKeyword = false;
				List<SObject> sObjectRes = BI_PSP_CommonQueryUtility.executeQuery('BI_PSPB_Frequency__c', fieldscp, conditionsForCp, withSharingKeyword);
				for (SObject sObj : sObjectRes) {
					lstFrequency.add((BI_PSPB_Frequency__c) sObj);
				}
			// This is a searchable combo box. If the Aura Enabled Exception is thrown, for every character search, the error 
			// will be displayed that disrupts the screen design. 
			//In the respective LWC, the error message is displayed as 'Unable to find' below the combo box input field 
			//(that will be visible to the user)  if the record is not found.
			
			if(lstFrequency.isEmpty())
			{
				BI_PSP_LogMessagesUtility.logError(errorForCareprogramProduct,BI_PSPB_ProductListCtrl.class.getName(),true,BI_PSPB_EnrollmentConstant.getLabel('LOG_SEVERITY_ERROR'));
			}
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(null, BI_PSPB_ProductListCtrl.class.getName(), ex);
			// Returning null if an exception occurs
			// Handling error in Lwc
			return null;
		}
		return lstFrequency;
	}

	}