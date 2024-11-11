@isTest
private class SalesNotificationQueueableTest {
    @isTest static void testQueueable() {
        List<Planned_Sales__c> underperformingRecords = new List<Planned_Sales__c>{
            new Planned_Sales__c(Total_Amount_Earned__c = 5000, Planned_Total_Amount__c = 10000)
        };
        insert underperformingRecords;

        Test.startTest();
        System.enqueueJob(new SalesNotificationQueueable(underperformingRecords));
        Test.stopTest();
    }
}