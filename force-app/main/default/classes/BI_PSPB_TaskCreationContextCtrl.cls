/**
 * @description Handles the creation of tasks when a video is uploaded and sends SMS
 * and email notifications. This class processes reminders and manages
 * associated tasks and notifications..
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_TaskCreationContextCtrl {
	public Date targetDate;
	public BI_PSPB_PastDueNotificationCtrl.ReminderProcessingContext context;
	public BI_PSPB_TaskCreationParams params;
	public Id caregiverId;
	public String patientName;
	public Integer age;
	/**
	 * @description  Initializes a new instance of the BI_PSPB_TaskCreationContextCtrl class.
	 *                This constructor sets up the context for creating tasks related to
	 *                past due notifications, including details about the target date,
	 *                processing context, task parameters, caregiver, patient, and age.
	 * @param targetDate The target date for the task creation, representing when the task should be processed.
	 * @param context An instance of BI_PSPB_PastDueNotificationCtrl.ReminderProcessingContext,
	 *                which provides the context for processing reminders.
	 * @param params An instance of BI_PSPB_TaskCreationParams containing parameters necessary
	 *               for creating tasks.
	 * @param caregiverId The ID of the caregiver associated with the task, if applicable.
	 * @param patientName The name of the patient for whom the task is being created.
	 * @param age The age of the patient, used to determine task creation rules based on age criteria.
	 */
	public BI_PSPB_TaskCreationContextCtrl(
		Date targetDate,
		BI_PSPB_PastDueNotificationCtrl.ReminderProcessingContext context,
		BI_PSPB_TaskCreationParams params,
		Id caregiverId,
		String patientName,
		Integer age
	) {
		this.targetDate = targetDate;
		this.context = context;
		this.params = params;
		this.caregiverId = caregiverId;
		this.patientName = patientName;
		this.age = age;
	}
}