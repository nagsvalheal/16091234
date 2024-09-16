/**
 * @description   Handles the creation of tasks when a video is uploaded,
 *                and calls methods to send SMS and email notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_NotificationTemplatesCtrl {
	/**
	 * @description  Handles the trigger to send notifications based on the
	 *                provided criteria. Retrieves notification details,
	 *                filters and adds contacts, and sends SMS and emails.
	 * @param recordId The ID of the record related to the treatment reminders.
	 * @param notificationTypes The type of reminder to filter by.
	 * @param communityUserName The type of reminder to filter by.
	 * @param treatmentDate The type of reminder to filter by.
	 */
	public static void handleTrigger(
		List<Id> recordId,
		String notificationTypes,
		List<String> communityUserName,
		String treatmentDate
	) {
		try {
			if (isInvalidInput(recordId, notificationTypes)) {
				logErrorRecordNotFound();
				return;
			}

			List<CareProgramEnrollee> enrollees = BI_PSPB_EnrolleeQueryHelper.getEnrollees(
				recordId
			);
			EnrolleeProcessingResult result = processEnrollees(enrollees);

			assignTemplates(
				result,
				notificationTypes,
				treatmentDate,
				communityUserName
			);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_NotificationTemplatesCtrl.class.getName(),
				ex
			);
		}
	}
	/**
	 * @description  Checks whether the input provided to the method is invalid based on specific
	 *                criteria. This method determines the validity by evaluating if the list of
	 *                record IDs is empty and the notification types string is blank.
	 * @param recordId A list of record IDs that should be validated. The input is considered invalid
	 *                 if this list is empty.
	 * @param notificationTypes A string representing the notification types. The input is considered
	 *                          invalid if this string is blank or empty.
	 * @return A Boolean value indicating whether the input is invalid. Returns true if the list
	 *         of record IDs is empty and the notification types string is blank; otherwise, returns false.
	 */
	private static Boolean isInvalidInput(
		List<Id> recordId,
		String notificationTypes
	) {
		return recordId.isEmpty() && String.isBlank(notificationTypes);
	}
	/**
	 * @description  Logs an error message indicating that a record was not found. This method
	 *                utilizes the BI_PSP_LogMessagesUtility to log the error with specific details,
	 *                including the error message, class name, and severity level.
	 */
	private static void logErrorRecordNotFound() {
		BI_PSP_LogMessagesUtility.logError(
			BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
			BI_PSPB_NotificationTemplatesCtrl.class.toString(),
			false,
			BI_PSPB_NotificationConstantsCtrl.severityError
		);
	}
	/**
	 * @description  Represents the results of processing enrollees, including categorized lists of
	 *                enrollee IDs, caregiver IDs, and patient names. This class is used to store
	 *                and organize the IDs and other relevant information related to enrollees and
	 *                their caregivers during the processing of tasks or notifications.
	 */
	private class EnrolleeProcessingResult {
		List<Id> patientEnrolleeIds = new List<Id>();
		List<Id> patientAddCaregiverIds = new List<Id>();
		List<Id> caregiverEnrolleeIds = new List<Id>();
		List<Id> enrolIds = new List<Id>();
		List<Id> accountRec = new List<Id>();
		List<Id> caregiverIds = new List<Id>();
		List<String> patientName = new List<String>();
	}
	/**
	 * @description  Processes a list of enrollees to categorize and organize them based on their
	 *                roles, such as patients and caregivers. This method analyzes the enrollees
	 *                and populates an EnrolleeProcessingResult object with lists of enrollee IDs,
	 *                caregiver IDs, and other relevant information required for further processing.
	 * @param enrollees A list of CareProgramEnrollee records representing the enrollees to be processed.
	 *                  These enrollees will be evaluated and sorted into different categories,
	 *                  such as patients and caregivers.
	 * @return An instance of EnrolleeProcessingResult containing the categorized lists of enrollee IDs,
	 *         caregiver IDs, patient names, and other relevant data derived from the processing of the enrollees.
	 */
	private static EnrolleeProcessingResult processEnrollees(
		List<CareProgramEnrollee> enrollees
	) {
		EnrolleeProcessingResult result = new EnrolleeProcessingResult();
		Date today = Date.today();

		for (CareProgramEnrollee enrollee : enrollees) {
			Integer age = BI_PSPB_SmsEmailSenderCtrl.calculateAge(
				enrollee.Account.BI_PSP_Birthdate__c,
				today
			);
			Id enrolleeId = enrollee.Id;
			Id caregiverId = BI_PSPB_SmsEmailSenderCtrl.fetchCaregiverId(
				enrolleeId
			);

			if (age > 18 && caregiverId != null) {
				result.patientAddCaregiverIds.add(enrollee.Id);
				result.enrolIds.add(enrollee.Id);
				result.accountRec.add(enrollee.AccountId);
			} else if (age > 18 && caregiverId == null) {
				result.patientEnrolleeIds.add(enrollee.Id);
				result.enrolIds.add(enrolleeId);
				result.accountRec.add(enrollee.AccountId);
			} else {
				result.caregiverEnrolleeIds.add(enrollee.Id);
				result.caregiverIds.add(caregiverId);
				result.patientName.add(enrollee.Account.Name);
			}
		}
		return result;
	}
	/**
	 * @description  Assigns notification templates to enrollees based on the processing results,
	 *                notification types, treatment date, and community usernames. This method maps
	 *                appropriate templates to each enrollee category to facilitate the generation
	 *                of personalized notifications.
	 * @param result An instance of EnrolleeProcessingResult containing categorized lists of enrollee IDs,
	 *               caregiver IDs, patient names, and other relevant information from the enrollee processing step.
	 * @param notificationTypes A string specifying the types of notifications to be assigned,
	 *                          used to select the appropriate templates for the enrollees.
	 * @param treatmentDate A string representing the treatment date that will be included in the
	 *                      notification templates to provide context for the notifications.
	 * @param communityUserName A list of community user names associated with the enrollees,
	 *                          used to personalize the notifications.
	 */
	private static void assignTemplates(
		EnrolleeProcessingResult result,
		String notificationTypes,
		String treatmentDate,
		List<String> communityUserName
	) {
		if (!result.patientEnrolleeIds.isEmpty()) {
			BI_PSPB_AssignNotificationTemplatesCtrl.assignPatientTemplates(
				result.patientEnrolleeIds,
				notificationTypes,
				result.enrolIds,
				treatmentDate,
				communityUserName
			);
		}

		if (!result.patientAddCaregiverIds.isEmpty()) {
			BI_PSPB_AssignNotificationTemplatesCtrl.assignPatientTemplates(
				result.patientAddCaregiverIds,
				notificationTypes,
				result.enrolIds,
				treatmentDate,
				communityUserName
			);
		}

		if (!result.caregiverEnrolleeIds.isEmpty()) {
        	// Example usage:
			BI_PSPB_CaregiverNotificationParamsCtrl params = new BI_PSPB_CaregiverNotificationParamsCtrl(
    			result.caregiverEnrolleeIds,
    			result.caregiverIds,
    			result.patientName
			);

			BI_PSPB_AssignNotificationTemplatesCtrl.assignCaregiverTemplates(
				params,
				notificationTypes,
				treatmentDate,
				communityUserName
			);
		}
	}
}