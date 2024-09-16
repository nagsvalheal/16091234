/**
 * @description  This class is used to create tasks when a video is uploaded.
 * It also handles calling methods to send SMS and email notifications.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public class BI_PSPB_CaregiverNotificationParamsCtrl {
	public List<Id> recordId;
	public List<Id> caregiverIds;
	public List<String> patientName;
	/**
	 * @description  Initializes a new instance of the BI_PSPB_CaregiverNotificationParamsCtrl class,
	 *                setting up the parameters needed for caregiver notifications. This constructor
	 *                assigns the provided record IDs, caregiver IDs, and patient names to the respective
	 *                fields of the class, which are used to configure notifications for caregivers.
	 *
	 * @param recordId A list of Ids representing the records associated with the notifications. These IDs
	 *                 are typically used to identify the main entities (such as tasks or reminders) linked
	 *                 to the notification.
	 * @param caregiverIds A list of Ids representing the caregivers who are recipients of the notifications.
	 *                     These IDs identify the caregivers associated with each patient or enrollee.
	 * @param patientName A list of strings containing the names of patients associated with the notifications.
	 *                    These names are used for personalization and to ensure clarity in the caregiver communications.
	 */
	public BI_PSPB_CaregiverNotificationParamsCtrl(
		List<Id> recordId,
		List<Id> caregiverIds,
		List<String> patientName
	) {
		this.recordId = recordId;
		this.caregiverIds = caregiverIds;
		this.patientName = patientName;
	}
}