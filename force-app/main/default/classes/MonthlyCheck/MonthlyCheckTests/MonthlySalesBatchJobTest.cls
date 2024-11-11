@isTest
private class MonthlySalesBatchJobTest {
    @isTest static void testBatchJob() {
        List<Planned_Sales__c> salesRecords = new List<Planned_Sales__c>{
            new Planned_Sales__c(Total_Amount_Earned__c = 5000, Planned_Total_Amount__c = 10000),
            new Planned_Sales__c(Total_Amount_Earned__c = 15000, Planned_Total_Amount__c = 10000)
        };
        insert salesRecords;

        Test.startTest();
        MonthlySalesBatchJob batchJob = new MonthlySalesBatchJob();
        Database.executeBatch(batchJob, 200);
        Test.stopTest();
    }
}