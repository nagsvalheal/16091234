/**
* @description  This class provides parameters for the tasks' fields that
are to be created.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public class BI_PSPB_TaskParameterCtrl {
    /** @description Subject of the task */
    public String subject { get; set; }
    /** @description type of notification of the task */
    public String notificationType { get; set; }
    /** @description category of notification of the task */
    public String category { get; set; }
    /** @description type of treatment of the task */
    public String treatmentType { get; set; }
    /** @description status of the task */
    public String status { get; set; }
    /**
    * @description Constructor for BI_PSPB_TaskParameterCtrl.
    * @param subject The subject of the task.
    * @param notificationType The type of notification.
    * @param category The category of the task.
    * @param treatmentType The treatment type associated with the task.
    * @param status The status of the task.
    */
    public BI_PSPB_TaskParameterCtrl(String subject, String notificationType, String category, String treatmentType, String status) {
        if(subject == null) {
            BI_PSP_LogMessagesUtility.logError(
                BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
                BI_PSPB_TaskParameterCtrl.class.toString(),
                true,
                BI_PSPB_NotificationConstantsCtrl.severityError
				);
        }
        this.subject = subject;
        this.notificationType = notificationType;
        this.category = category;
        this.treatmentType = treatmentType;
        this.status = status;
    }
}