@isTest
private class PlannedSalesTriggerTest {
    @isTest
    static void testPlannedSalesTrigger() {
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        Planned_Sales__c plannedSale = new Planned_Sales__c(
            Year__c = 2024,
            Month__c = 10,
            Car_Type__c = testProduct.Id 
        );
        insert plannedSale;

        Planned_Sales__c insertedPlannedSale = [SELECT Id, Count_of_Cars_Sold__c, Total_Amount_Earned__c FROM Planned_Sales__c WHERE Id = :plannedSale.Id];

        System.assertEquals(0, insertedPlannedSale.Count_of_Cars_Sold__c, 'Count of Cars Sold should be 0');
        System.assertEquals(0, insertedPlannedSale.Total_Amount_Earned__c, 'Total Amount Earned should be 0');

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 10000
        );
        insert testOpportunity;

        OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Product2Id = testProduct.Id, 
            Quantity = 1,
            UnitPrice = 10000
        );
        insert testOpportunityLineItem;

        plannedSale.Car_Type__c = testProduct.Id; 
        update plannedSale;

        insertedPlannedSale = [SELECT Id, Count_of_Cars_Sold__c, Total_Amount_Earned__c FROM Planned_Sales__c WHERE Id = :plannedSale.Id];

        System.assertEquals(1, insertedPlannedSale.Count_of_Cars_Sold__c, 'Count of Cars Sold should be 1');
        System.assertEquals(10000, insertedPlannedSale.Total_Amount_Earned__c, 'Total Amount Earned should be 10000');
    }
}