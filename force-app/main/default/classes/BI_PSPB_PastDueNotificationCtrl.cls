/**
 * @description Handles the creation of tasks when a video is uploaded and sends SMS
 * and email notifications. This class processes reminders and manages
 * associated tasks and notifications..
 * History
 * Version	Author			Date		Detail		Description
 * 1.0		Niyas		24-07-2024		Created		Refactored Version
 */
public with sharing class BI_PSPB_PastDueNotificationCtrl {
	/**
	 * @description  Processes past due reminders by calculating target dates, retrieving
	 * treatment reminders, creating tasks, and sending notifications.
	 */
	public static void processPastDueReminders() {
		try {
			Integer[] intervals = new List<Integer>{ 0, -1, -3 };
			Set<Date> targetDates = calculateTargetDates(intervals);
			Map<Date, List<BI_PSPB_Treatment_Reminder__c>> remindersByDate = BI_PSPB_PastDueTargetDatesCtrl.getTreatmentRecords(
				targetDates
			);

			ReminderProcessingContext context = new ReminderProcessingContext();
			processReminders(remindersByDate, targetDates, context);
			BI_PSPB_PastDueTaskSubjectCtrl.handleTasks(context.newTaskList);
			sendNotifications(
				context.enrolleeRecIds,
				context.enrolleePastOne,
				context.enrolleePastThree,
				context.pastDueDays,
				context.treatmentDate
			);
		} catch (System.DmlException ex) {
			BI_PSP_LogMessagesUtility.logError(
				ex.getMessage(),
				BI_PSPB_PastDueNotificationCtrl.class.toString(),
				true,
				BI_PSPB_NotificationConstantsCtrl.severityError
			);
		}
	}
	/**
	 * @description  Processes reminders by iterating through target dates and handling
	 * each list of reminders for those dates.
	 * @param remindersByDate The ID of the record related to the treatment reminders.
	 * @param targetDates The type of reminder to filter by.
	 * @param context The type of reminder to filter by.
	 */
	private static void processReminders(
		Map<Date, List<BI_PSPB_Treatment_Reminder__c>> remindersByDate,
		Set<Date> targetDates,
		ReminderProcessingContext context
	) {
		for (Date targetDate : targetDates) {
			if (remindersByDate.containsKey(targetDate)) {
				BI_PSPB_PastDueReminderListCtrl.processReminderList(
					remindersByDate.get(targetDate),
					targetDate,
					context
				);
			}
		}
	}

	/**
	 * @description   Sends notifications (SMS and email) based on the list of enrollee IDs
	 * and the reminder days.
	 * @param enrolleeRecIds The ID of the record related to the treatment reminders.
	 * @param enrolleePastOne The type of reminder to filter by.
	 * @param enrolleePastThree The ID of the record related to the treatment reminders.
	 * @param pastDueDays The type of reminder to filter by.
	 * @param treatmentDate Date to be sent for notification.
	 */
	private static void sendNotifications(
		List<Id> enrolleeRecIds,
		List<Id> enrolleePastOne,
		List<Id> enrolleePastThree,
		BI_PSPB_TreatmentReminderDaysCtrl pastDueDays,
		String treatmentDate
	) {
		try {
			sendNotifications1(
				enrolleeRecIds,
				enrolleePastOne,
				enrolleePastThree,
				pastDueDays,
				treatmentDate
			);
		} catch (Exception ex) {
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				ex.getMessage(),
				BI_PSPB_PastDueNotificationCtrl.class.getName(),
				ex
			);
		}
	}
	/**
	 * @description  Context class for storing details related to reminder processing,
	 * including enrollee IDs, past due reminders, and newly created tasks.
	 * @param enrolleeRecIds The ID of the record related to the treatment reminders.
	 * @param enrolleePastOne The type of reminder to filter by.
	 * @param enrolleePastThree The ID of the record related to the treatment reminders.
	 * @param pastDueDays The type of reminder to filter by.
	 * @param newTaskList The type of reminder to filter by.
	 */
	public class ReminderProcessingContext {
		public List<Id> enrolleeRecIds = new List<Id>();
		public List<Id> enrolleePastOne = new List<Id>();
		public List<Id> enrolleePastThree = new List<Id>();
		public BI_PSPB_TreatmentReminderDaysCtrl pastDueDays = new BI_PSPB_TreatmentReminderDaysCtrl();
		public List<Task> newTaskList = new List<Task>();
		public String treatmentDate;
	}
	/**
	 * @description  Calculates a set of target dates by adding the given intervals (in days)
	 *                to the current date. The intervals are specified as an array of integers.
	 *                Each interval is added to the current date to generate the target date.
	 * @param intervals An array of integers representing the number of days to add to the
	 *                  current date for each target date.
	 * @return A set of target dates calculated by adding the specified intervals to today's date.
	 */
	public static Set<Date> calculateTargetDates(Integer[] intervals) {
		Set<Date> targetDates = new Set<Date>();
		for (Integer interval : intervals) {
			targetDates.add(Date.today().addDays(interval));
		}
		return targetDates;
	}
	/**
	 * @description  Sends notifications for enrollees based on their treatment reminder status.
	 *                This method categorizes enrollees into different lists based on the past due
	 *                periods and sends the appropriate notifications for each group.
	 * @param enrolleeRecIds A list of enrollee record IDs for which notifications are to be sent.
	 * @param enrolleePastOne A list of enrollee IDs who are past due by one day.
	 * @param enrolleePastThree A list of enrollee IDs who are past due by three days.
	 * @param pastDueDays An instance of BI_PSPB_TreatmentReminderDaysCtrl representing the controller
	 *                    for managing reminder days past due.
	 * @param treatmentDate The treatment date in string format used for generating notifications.
	 */
	public static void sendNotifications1(
		List<Id> enrolleeRecIds,
		List<Id> enrolleePastOne,
		List<Id> enrolleePastThree,
		BI_PSPB_TreatmentReminderDaysCtrl pastDueDays,
		String treatmentDate
	) {
		try {
			if (!enrolleeRecIds.isEmpty()) {
				BI_PSPB_NotificationTemplatesCtrl.handleTrigger(
					enrolleeRecIds,
					BI_PSPB_NotificationConstantsCtrl.pastDueDateZero,
					new List<String>{ '' },
					''
				);
			}
			if (!enrolleePastOne.isEmpty()) {
				BI_PSPB_NotificationTemplatesCtrl.handleTrigger(
					enrolleePastOne,
					BI_PSPB_NotificationConstantsCtrl.pastDueDateOne,
					new List<String>{ '' },
					''
				);
			}
			if (!enrolleePastThree.isEmpty()) {
				BI_PSPB_NotificationTemplatesCtrl.handleTrigger(
					enrolleePastThree,
					BI_PSPB_NotificationConstantsCtrl.pastDueDateThree,
					new List<String>{ '' },
					treatmentDate
				);
			}
		} catch (System.DmlException ex) {
			BI_PSP_LogMessagesUtility.catchSystemException(
				BI_PSPB_NotificationConstantsCtrl.errorMsgRecordNotFound,
				BI_PSPB_PastDueNotificationCtrl.class.toString(),
				ex
			);
		}
	}
    
}