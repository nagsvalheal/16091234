/**
* @description This class schedules the batch job to expire notifications
* automatically at a defined interval. It implements the Schedulable
* interface to allow the execution of scheduled jobs.
* History
* Version	Author			Date		Detail		Description
* 1.0		Niyas		24-07-2024		Created		Refactored Version
*/
public with sharing class BI_PSPB_NotificationExpiredSched implements Schedulable {
    /**
	* @description xecutes the batch class to expire all notifications.
    * @param context The context in which the job is executed. 
	*/
    public void execute(SchedulableContext context) {
        BI_PSPB_NotificationExpiredBatch batch = new BI_PSPB_NotificationExpiredBatch();
        Database.executeBatch(batch, 100);
    }
}