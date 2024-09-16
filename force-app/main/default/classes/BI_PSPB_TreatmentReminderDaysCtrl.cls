/**
* @description This class is responsible for checking the days to send 
* notifications and for calling methods to create tasks based on treatment 
* reminder days and past due dates.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version 
*/
public with sharing class BI_PSPB_TreatmentReminderDaysCtrl {
//Treatment Reminder Count
public Integer before1Day;
public Integer before3Day;
public Integer before7Day;
public Integer before10Day;
public Integer before14Day;
//PastDue Date Count
public Integer pastdue24hrCount;
public Integer pastdue72hrCount;
/**
* @description  Constructor initializes the treatment reminder and past due 
* day counts from custom metadata, and it also prepares the data needed for 
* sending notifications and creating tasks.
*/
public BI_PSPB_TreatmentReminderDaysCtrl() {
	BI_PSPB_Days_Count__mdt mcs = BI_PSPB_Days_Count__mdt.getInstance('BI_PSPB_DaysCountofTreatment');
	before1Day = mcs.BI_PSPB_GTR_1_day_before_Day_of_Treatmen__c.intValue();
	before3Day = mcs.BI_PSPB_GTR_3_days_before_Day_of_Treatme__c.intValue();
	before7Day = mcs.BI_PSPB_PR_7_days_before_Treatment_Day__c.intValue();
	before10Day = mcs.BI_PSPB_PR_10_days_before_Treatment_Day__c.intValue();
	before14Day = mcs.BI_PSPB_PR14_days_before_Treatment_Day__c.intValue();

	BI_PSPB_Days_Count__mdt mcsps = BI_PSPB_Days_Count__mdt.getInstance('BI_PSPB_DaysCountofTreatment');
	pastdue24hrCount = mcsps.BI_PSPB_TR_Past_Due_24_hours__c.intValue();
	pastdue72hrCount = mcsps.BI_PSB_TR_Past_Due_72_hours__c.intValue();
}
}