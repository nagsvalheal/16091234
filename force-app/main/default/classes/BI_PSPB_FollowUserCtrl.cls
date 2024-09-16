/**
 * @description This class is used to fetch, insert and delete
 *              the follow and following records.
 * History:
 * Version Author      Date            Detail   Description
 * 1.0     Ragavi      05-Dec-2023     Created  Initial development.
 * 1.1     Ragavi      05-Jan-2024     Updated  Updated to filter records without nullpointer exception.
 * 1.2     Ragavi      04-Apr-2024     Updated  Catch log added.
 * 1.3     Ragavi      22-Apr-2024     Updated  Code Review.
 * 1.4     Ragavi      27-Apr-2024     Updated  Indentation.
 * 1.5	   Deepa	   27-Jul-2024	   Updated	Refactor.
 */
public with sharing class BI_PSPB_FollowUserCtrl {
	/**
	* @description		Used to follow the accounts as followers and following.
	* @param			enrolleeIdToFollow - Id of the user to follow.
	This method is used in biPspbMyFollowers,biPspbMyFollowing,biPspbAllPost
	and biPspbMyPost LWC.
	*/
	@AuraEnabled(cacheable=false)
	public static void followUser(String enrolleeIdToFollow) {
		try {
			// Getting the CareProgramEnrollee ID associated with the user ID.
			String enrolleeIdWhoFollows = BI_PSP_CurrentUser.getEnrolleeRecords()[0]
				.Id;
			// Check if enrolleeIdWhoFollows and enrolleeIdToFollow are  blank.
			if (String.isBlank(enrolleeIdToFollow)) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_CommunityConstant.errorWhileGetEnrolleeId,
					BI_PSPB_FollowUserCtrl.class.toString(),
					true,
					BI_PSPB_CommunityConstant.LOG_SEVERITY_ERROR
				);
			}

			//Checking for if there any existing records before following.
			// Using common query utility to check existing records
			String objectName = 'BI_PSP_FeedFollow__c';
			String fields = 'Id';
			String conditions =
				'(BI_PSP_CareProgramEnrolleeAccount__c = \'' +
				enrolleeIdWhoFollows +
				'\' AND BI_PSP_CareProgramEnrolleeFollow__c = \'' +
				enrolleeIdToFollow +
				'\' AND BI_PSP_Type__c = \'' +
				BI_PSPB_CommunityConstant.following +
				'\') OR (BI_PSP_CareProgramEnrolleeAccount__c = \'' +
				enrolleeIdToFollow +
				'\' AND BI_PSP_CareProgramEnrolleeFollow__c = \'' +
				enrolleeIdWhoFollows +
				'\' AND BI_PSP_Type__c = \'' +
				BI_PSPB_CommunityConstant.follower +
				'\')LIMIT 1';
			Boolean withUserMode = Boolean.valueOf(
				BI_PSP_ChallengeConstant.userModeFalse
			);

			List<BI_PSP_FeedFollow__c> existingRecords = BI_PSP_CommonQueryUtility.executeQuery(
				objectName,
				fields,
				conditions,
				withUserMode
			);

			// Check if there are no existing records for the follow relationship.
			if (!existingRecords.isEmpty()) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_CommunityConstant.alreadyFollowing,
					BI_PSPB_FollowUserCtrl.class.toString(),
					true,
					BI_PSPB_CommunityConstant.LOG_SEVERITY_ERROR
				);
			}
			List<BI_PSP_FeedFollow__c> insertFeedFollowList = new List<BI_PSP_FeedFollow__c>();
			// Create a new record for the follower.
			BI_PSP_FeedFollow__c newfollower = new BI_PSP_FeedFollow__c(
				BI_PSP_CareProgramEnrolleeAccount__c = enrolleeIdWhoFollows,
				BI_PSP_CareProgramEnrolleeFollow__c = enrolleeIdToFollow,
				BI_PSP_Type__c = BI_PSPB_CommunityConstant.following
			);
			insertFeedFollowList.add(newfollower);
			// Create a new record for the user being followed.
			BI_PSP_FeedFollow__c newfollowing = new BI_PSP_FeedFollow__c(
				BI_PSP_CareProgramEnrolleeAccount__c = enrolleeIdToFollow,
				BI_PSP_CareProgramEnrolleeFollow__c = enrolleeIdWhoFollows,
				BI_PSP_Type__c = BI_PSPB_CommunityConstant.follower
			);
			insertFeedFollowList.add(newfollowing);
			// Insert the new records into the database.
			BI_PSP_DatabaseOperationsUtility.insertOperation(
				insertFeedFollowList,
				BI_PSPB_FeedItemCtrl.class.toString(),
				false
			);
		} catch (Exception ex) {
			// Catch any other exceptions that might occur during the process.
			// Log the exception and throw a general error exception.
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_CommunityConstant.errorWhileFollowing,
				BI_PSPB_FollowUserCtrl.class.toString(),
				ex
			);
		}
	}
	/**
	* @description		Used to fetch all followers of the loggedin user.
	* @return			List<BI_PSP_FeedFollow__c> - All followers for that user.
						Returns to biPspbMyFollowers and biPspbMyFollowing LWC.
	*/
	@AuraEnabled(cacheable=false)
	public static List<BI_PSP_FeedFollow__c> getMyFollowers() {
		List<BI_PSP_FeedFollow__c> followers;
		try {
			// Getting the CareProgramEnrollee ID associated with the user ID.
			String cpeId = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
			// Querying the database to retrieve followers for the logged-in user.
			String objectName = 'BI_PSP_FeedFollow__c';
			String fields = 'BI_PSP_CareProgramEnrolleeFollow__c, BI_PSP_CareProgramEnrolleeFollow__r.BI_PSP_CommunityUsername__c, BI_PSP_Type__c, BI_PSP_CareProgramEnrolleeAccount__c, BI_PSP_CareProgramEnrolleeAccount__r.BI_PSP_CommunityUsername__c, BI_PSP_CareProgramEnrolleeFollow__r.BI_PSP_AvatarUrl__c';
			String conditions =
				'BI_PSP_CareProgramEnrolleeAccount__c = \'' +
				cpeId +
				'\' AND (BI_PSP_Type__c = \'' +
				BI_PSPB_CommunityConstant.follower +
				'\' OR BI_PSP_Type__c = \'' +
				BI_PSPB_CommunityConstant.following +
				'\')';
			Boolean withUserMode = Boolean.valueOf(
				BI_PSP_ChallengeConstant.userModeFalse
			);
			followers = BI_PSP_CommonQueryUtility.executeQuery(
				objectName,
				fields,
				conditions,
				withUserMode
			);
		} catch (Exception ex) {
			// Catch any other exceptions that might occur during the process.
			// Log the exception and throw a general error exception.
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_CommunityConstant.errorWhileGettingFollowers,
				BI_PSPB_FollowUserCtrl.class.toString(),
				ex
			);
		}
		/** Here 'followers' is not checked for null exception as 
			it is handled in LWC.
			There are two different scenario such as it takes an action when 
			it is returned as null and another action when it is returned with values.
		*/
		return followers;
	}
	/**
	* @description		Used to unfollow the account that is being followed.
	* @param			enrolleeIdToUnFollow - Id of the account that to be unfollowed.
	This method is used in biPspbMyFollowers,biPspbMyFollowing,biPspbAllPost
	and biPspbMyPost LWC.
	*/
	@AuraEnabled(cacheable=false)
	public static void unfollowUser(String enrolleeIdToUnFollow) {
		try {
			// Getting the CareProgramEnrollee ID associated with the user ID.
			String enrolleeIdWhoUnfollows = BI_PSP_CurrentUser.getEnrolleeRecords()[0].Id;
			// Checking if enrolleeIdToUnFollow and accountId obtained are  blank.
			if (String.isBlank(enrolleeIdToUnFollow)) {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_CommunityConstant.errorWhileGetEnrolleeId,
					BI_PSPB_FollowUserCtrl.class.toString(),
					true,
					BI_PSPB_CommunityConstant.LOG_SEVERITY_ERROR
				);
			}

			// Querying  to retrieve the follower and following records to unfollow.
			// Using common query utility to retrieve follower and following records
			String fields = 'Id';
			String objectName = 'BI_PSP_FeedFollow__c';
			String conditionsForUnfollower =
				'BI_PSP_CareProgramEnrolleeAccount__c = \'' +
				enrolleeIdWhoUnfollows +
				'\' AND BI_PSP_CareProgramEnrolleeFollow__c = \'' +
				enrolleeIdToUnFollow +
				'\' AND BI_PSP_Type__c = \'' +
				BI_PSPB_CommunityConstant.following +
				'\' LIMIT 1';

			String conditionsForUnfollowing =
				'BI_PSP_CareProgramEnrolleeAccount__c = \'' +
				enrolleeIdToUnFollow +
				'\' AND BI_PSP_CareProgramEnrolleeFollow__c = \'' +
				enrolleeIdWhoUnfollows +
				'\' AND BI_PSP_Type__c = \'' +
				BI_PSPB_CommunityConstant.follower +
				'\' LIMIT 1';
			Boolean withUserMode = Boolean.valueOf(
				BI_PSP_ChallengeConstant.userModeFalse
			);

			List<BI_PSP_FeedFollow__c> unfollowerResults = BI_PSP_CommonQueryUtility.executeQuery(
				objectName,
				fields,
				conditionsForUnfollower,
				withUserMode
			);
			List<BI_PSP_FeedFollow__c> unfollowingResults = BI_PSP_CommonQueryUtility.executeQuery(
				objectName,
				fields,
				conditionsForUnfollowing,
				withUserMode
			);

			/*Checking if both follower and following records exist
			 before proceeding with unfollowing. */
			if (!unfollowerResults.isEmpty() && !unfollowingResults.isEmpty()) {
				List<BI_PSP_FeedFollow__c> deleteFeedUnfollowList = new List<BI_PSP_FeedFollow__c>();
				// Cast results to BI_PSP_FeedFollow__c and add to the list
				deleteFeedUnfollowList.add(
					(BI_PSP_FeedFollow__c) unfollowerResults[0]
				);
				deleteFeedUnfollowList.add(
					(BI_PSP_FeedFollow__c) unfollowingResults[0]
				);

				// Deleting the follower and following records.

				BI_PSP_DatabaseOperationsUtility.deleteOperation(
					deleteFeedUnfollowList,
					BI_PSPB_FollowUserCtrl.class.toString(),
					false
				);
			} else {
				BI_PSP_LogMessagesUtility.logError(
					BI_PSPB_CommunityConstant.errorWhileUnfollowing,
					BI_PSPB_FollowUserCtrl.class.toString(),
					true,
					BI_PSPB_CommunityConstant.LOG_SEVERITY_ERROR
				);
			}
		} catch (Exception ex) {
			// Catch any other exceptions that might occur during the process.
			// Log the exception and throw a general error exception.
			BI_PSP_LogMessagesUtility.exceptionLogMessage(
				BI_PSPB_CommunityConstant.errorWhileUnfollowing,
				BI_PSPB_FollowUserCtrl.class.toString(),
				ex
			);
		}
	}
}