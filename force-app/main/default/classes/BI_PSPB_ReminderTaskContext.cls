/**
 * @description  This class implements the Schedulable interface to create a task when
 * a video is uploaded. It invokes a method to process questionnaires and
 * handles exceptions by logging error messages.
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public class BI_PSPB_ReminderTaskContext {
	public BI_PSPB_Treatment_Reminder__c reminder;
	public Integer age;
	public Id caregiverId;
	public Integer daysDifference;
	public BI_PSPB_TreatmentReminderDaysCtrl daysCount;
	public String taskIdentifier;

	/**
	 * @description  Represents the context for creating reminder-related tasks, encapsulating all necessary
	 *                details such as the treatment reminder, age of the enrollee, caregiver information,
	 *                difference in days, reminder days configuration, and task identifier. This class
	 *                serves as a container for passing relevant data to methods that create and manage
	 *                tasks related to treatment reminders.
	 * @param reminder A BI_PSPB_Treatment_Reminder__c record representing the specific treatment reminder
	 *                 for which tasks are being created. It provides the core details about the reminder.
	 * @param age An integer representing the age of the enrollee associated with the reminder, used to
	 *            determine task eligibility and customization based on age-specific criteria.
	 * @param caregiverId An Id representing the caregiver associated with the enrollee, if applicable.
	 *                    This ID is used to create tasks specifically targeted at caregivers.
	 * @param daysDifference An integer representing the difference in days between the reminder's target date
	 *                       and the current date, which helps to calculate the timing and due date of the task.
	 * @param daysCount An instance of BI_PSPB_TreatmentReminderDaysCtrl that outlines the configuration for
	 *                  reminder days, including parameters for when tasks should be created relative to the
	 *                  reminder's due date.
	 * @param taskIdentifier A string that serves as an identifier for the task, used to uniquely distinguish
	 *                       tasks within the context of processing reminders.
	 */
	public BI_PSPB_ReminderTaskContext(
		BI_PSPB_Treatment_Reminder__c reminder,
		Integer age,
		Id caregiverId,
		Integer daysDifference,
		BI_PSPB_TreatmentReminderDaysCtrl daysCount,
		String taskIdentifier
	) {
		this.reminder = reminder;
		this.age = age;
		this.caregiverId = caregiverId;
		this.daysDifference = daysDifference;
		this.daysCount = daysCount;
		this.taskIdentifier = taskIdentifier;
	}
}