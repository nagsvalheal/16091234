/**
* @description  This class is used to create a task when a video is uploaded and
*               to call methods that send SMS and email notifications.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public without sharing class BI_PSPB_ActionTaskService {
/**
 * @description  Retrieves the Task record associated with the given record ID
 *               and triggers methods to send SMS and email notifications.
 * @param recordId The ID of the Task record to retrieve. This should be a valid Salesforce ID.
 * @return Task The Task record corresponding to the given record ID. If no record is found,
* the method will throw an error due to accessing an empty list.
*/
@AuraEnabled(cacheable=false)
public static Task getTask(String recordId) {
String fields = 'Id, WhatId, ' +
			'Status, BI_PSP_Category__c, ' + 
			'Subject, BI_PSPB_Treatment_Type__c, BI_PSP_Notification_Type__c';
String conditions =
	'Id = \'' +
	recordId +
	'\' LIMIT 1 ';
List<SObject> results = BI_PSP_CommonQueryUtility.executeQuery(
	'Task',
	fields,
	conditions,
	false
);
return (Task) results[0];
}
}