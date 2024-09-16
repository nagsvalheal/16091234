/**
 * @description  This class implements the Schedulable interface to create a task when
 * a video is uploaded. It invokes a method to process questionnaires and
 * handles exceptions by logging error messages.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public class BI_PSPB_TreatmentCaregiverTaskCtrl {
	public List<Id> enrolleeRecIds;
	public List<Id> enrolleePastOne;
	public List<Id> enrolleePastThree;
	public String userType;
	public Id caregiverId;

	/**
	 * @description  Initializes an instance of the BI_PSPB_TreatmentPatientTaskCtrl class, which is used
	 *               to manage and create tasks for patients and caregivers based on enrollee information
	 *               and other parameters. This constructor sets up the necessary context for task
	 *               processing by accepting lists of enrollee IDs and categorizing them based on specific
	 *               conditions.
	 * @param enrolleeRecIds A List of Ids representing the enrollee records that are being processed.
	 *                       These are the primary enrollee IDs for which tasks may be created.
	 * @param enrolleePastOne A List of Ids representing enrollee records that have a specific condition
	 *                        related to past data (e.g., past one day). This list is used to filter
	 *                        enrollees for targeted task creation.
	 * @param enrolleePastThree A List of Ids representing enrollee records that have another specific
	 *                          condition related to past data (e.g., past three days). This parameter
	 *                          helps in categorizing enrollees further for task customization.
	 * @param userType A String indicating the type of user (e.g., 'Patient' or 'Caregiver') for which
	 *                 tasks are being created. This allows tasks to be personalized based on the role
	 *                 of the user.
	 * @param caregiverId An Id representing the caregiver associated with the enrollee, if applicable.
	 *                    This ID is used to link tasks specifically targeted at caregivers.
	 */
	public BI_PSPB_TreatmentCaregiverTaskCtrl(
		List<Id> enrolleeRecIds,
		List<Id> enrolleePastOne,
		List<Id> enrolleePastThree,
		String userType,
		Id caregiverId
	) {
		this.enrolleeRecIds = enrolleeRecIds;
		this.enrolleePastOne = enrolleePastOne;
		this.enrolleePastThree = enrolleePastThree;
		this.userType = userType;
		this.caregiverId = caregiverId;
	}
}