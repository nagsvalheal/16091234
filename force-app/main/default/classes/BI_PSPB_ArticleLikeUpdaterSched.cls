/**
 * @description This class implements the Schedulable and Database.Batchable interfaces to perform scheduled and batch actions related to updating article likes.
 * This class is used to retrieve article like records, randomize the list of articles within the records, and update them accordingly.
 * History
 * Version 	Author			Date			Detail				Description
 * 1.1		Gokulkrishnan T	31-Aug-2024		Updated				Added batch implementation to handle large queries.
 */
public with sharing class BI_PSPB_ArticleLikeUpdaterSched implements Schedulable, Database.Batchable<SObject> {
    public static final String LOG_SEVERITY_ERROR  = System.Label.BI_PSP_ErrorSeverity;

    /**
     * @description Executes the scheduled job to update article like records in the BI_PSPB_Article_like__c object.
     * @param ctx The context in which the job is executed.
     */
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new BI_PSPB_ArticleLikeUpdaterSched(), 200);
    }

    /**
     * @description Query method for the batch job to retrieve article like records.
	 * 
	 * @param batchContext The context in which the batch job is executed.
     * @return QueryLocator that will be used to process the records in chunks.
     */
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        String query = 'SELECT Id, BI_PSPB_JustForMeArticles__c, BI_PSPB_Reaction__c ' +
                       'FROM BI_PSPB_Article_like__c ' +
                       'WHERE BI_PSPB_Reaction__c = null';
        return Database.getQueryLocator(query);
    }

    /**
     * @description Executes the logic for each batch of records retrieved by the start method.
     * @param batchContext The context in which the batch job is executed.
     * @param scope The list of records to be processed in this batch.
     */
    public void execute(Database.BatchableContext batchContext, List<BI_PSPB_Article_like__c> scope) {
        updateArticleLikes(scope);
    }

    /**
     * @description Final method to execute after all batches are processed.
     * @param batchContext The context in which the batch job is executed.
     */
    public void finish(Database.BatchableContext batchContext) {
        BI_PSP_LogMessagesUtility.logError(
            'Batch job finished successfully.',
            BI_PSPB_ArticleLikeUpdaterSched.class.toString(),
            false,
            LOG_SEVERITY_ERROR
        );
    }

    /**
     * @description Retrieves and updates article like records by randomizing the list of articles within each record.
     * @param articleLikeRecords The list of article like records to be processed.
     */
    public static void updateArticleLikes(List<BI_PSPB_Article_like__c> articleLikeRecords) {
        try {
            List<BI_PSPB_Article_like__c> recordsToUpdate = new List<BI_PSPB_Article_like__c>();

            for (BI_PSPB_Article_like__c articleLike : articleLikeRecords) {
                String articlesJson = articleLike.BI_PSPB_JustForMeArticles__c;
                if (String.isNotBlank(articlesJson)) {
                    List<String> articleList = (List<String>) JSON.deserialize(articlesJson, List<String>.class);
                    if (!articleList.isEmpty()) {
                        // Randomize the list
                        articleList = randomizeList(articleList);

                        // Convert back to JSON string
                        String updatedJson = JSON.serialize(articleList);

                        // Update the JSON string field
                        articleLike.BI_PSPB_JustForMeArticles__c = updatedJson;

                        // Add to the list for bulk update
                        recordsToUpdate.add(articleLike);
                    }
                }
            }

            // Bulk update the records
            if (!recordsToUpdate.isEmpty()) {
                BI_PSP_DatabaseOperationsUtility.updateOperation(
                    recordsToUpdate,
                    BI_PSPB_ArticleLikeUpdaterSched.class.toString(),
                    false
                );
            }
        } catch (Exception ex) {
            BI_PSP_LogMessagesUtility.logError(
                ex.getMessage(), BI_PSPB_ArticleLikeUpdaterSched.class.toString(),
                false, LOG_SEVERITY_ERROR
            );
        }
    }

    /**
     * @description Helper method to randomize the list of articles.
     * @param arr List of articles to be randomized.
     * @return List<String> A new list of articles in random order.
     */
    private static List<String> randomizeList(List<String> arr) {
        List<String> randomizedList = new List<String>();
        while (!arr.isEmpty()) {
            Integer randomIndex = Math.mod(
                Math.abs(Crypto.getRandomInteger()),
                arr.size()
            );
            randomizedList.add(arr.remove(randomIndex));
        }
        return randomizedList;
    }
}