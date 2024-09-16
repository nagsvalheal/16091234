/**
* @description A controller class used for fetching various day count metrics from
* custom metadata and performing operations related to task creation,
* SMS, and email notifications when a video is uploaded.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_QuestionsDaysCountQueryCtrl {
/**
* @description  Fetches the DLQI count from the custom metadata.
* @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
*/
public static Integer fetchDlqiCount() {
	BI_PSPB_Days_Count__mdt mcs = BI_PSPB_Days_Count__mdt.getInstance(
		BI_PSPB_NotificationConstantsCtrl.daysCountOfTreatment
	);
	return mcs.BI_PSPB_DLQI__c.intValue();
}
/**
* @description  Fetches the PSS count from the custom metadata.
* @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
*/
public static Integer fetchPssCount() {
	BI_PSPB_Days_Count__mdt mcs = BI_PSPB_Days_Count__mdt.getInstance(
		BI_PSPB_NotificationConstantsCtrl.daysCountOfTreatment
	);
	return mcs.BI_PSPB_PSS__c.intValue();
}
/**
* @description  Fetches the WPAI count from the custom metadata.
* @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
*/
public static Integer fetchWpaiCount() {
	BI_PSPB_Days_Count__mdt mcs = BI_PSPB_Days_Count__mdt.getInstance(
		BI_PSPB_NotificationConstantsCtrl.daysCountOfTreatment
	);
	return mcs.BI_PSPB_WPAI__c.intValue();
}
/**
* @description  Fetches the QSQ count from the custom metadata.
* @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
*/
public static Integer fetchQsqCount() {
	BI_PSPB_Days_Count__mdt mcs = BI_PSPB_Days_Count__mdt.getInstance(
		BI_PSPB_NotificationConstantsCtrl.daysCountOfTreatment
	);
	return mcs.BI_PSPB_QSQ__c.intValue();
}

/**
* @description  Fetches the QSQTWO count from the custom metadata.
* @return A list of BI_PSPB_Treatment_Reminder__c objects that match the criteria.
*/
public static Integer fetchQsqTwoCount() {
	BI_PSPB_Days_Count__mdt mcs = BI_PSPB_Days_Count__mdt.getInstance(
		BI_PSPB_NotificationConstantsCtrl.daysCountOfTreatment
	);
	return mcs.BI_PSPB_QSQTWO__c.intValue();
}
}