/**
* @description  This class holds parameters for creating a task related to video uploads.
* It includes properties for subject, notification type, category,
* treatment type, and status. It is used to manage tasks and send SMS
* and email notifications based on these parameters.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public class BI_PSPB_TaskParameters {
public String subject;
public String notificationType;
public String category;
public String treatmentType;
public String status;

/**
 * @description  Constructor to initialize the task parameters used for creating tasks
 * related to video uploads. This includes setting up the subject, 
 * notification type, category, treatment type, and status.
 * @param subject The ID of the record related to the treatment reminders.
 * @param notificationType The type of reminder to filter by.
 * @param category The type of reminder to filter by.
 * @param treatmentType The type of reminder to filter by.
 * @param status The type of reminder to filter by.
 */
public BI_PSPB_TaskParameters(
	String subject,
	String notificationType,
	String category,
	String treatmentType,
	String status
) {
	this.subject = subject;
	this.notificationType = notificationType;
	this.category = category;
	this.treatmentType = treatmentType;
	this.status = status;
}
}