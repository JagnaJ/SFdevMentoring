public with sharing class MonthlySalesBatchJob implements Database.Batchable<SObject>, Database.Stateful {

    public Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name, Total_Amount_Earned__c, Planned_Total_Amount__c FROM Planned_Sales__c WHERE CreatedDate = LAST_MONTH';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Planned_Sales__c> underperformingRecords = new List<Planned_Sales__c>();
        
        for (SObject obj : scope) {
            Planned_Sales__c record = (Planned_Sales__c) obj;
            if (record.Total_Amount_Earned__c < record.Planned_Total_Amount__c) {
                underperformingRecords.add(record);
            }
        }
        
        if (!underperformingRecords.isEmpty()) {
            System.enqueueJob(new SalesNotificationQueueable(underperformingRecords));
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('MonthlySalesBatchJob finished.');
    }
}
