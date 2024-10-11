@isTest
private class OpportunityTriggerTest {
    @isTest
    static void testOpportunityTrigger() {
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Contract Sent',
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

        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;

        Product2 updatedProduct = [SELECT Id, Car_Status__c FROM Product2 WHERE Id = :testProduct.Id];
        System.assertEquals('Sold', updatedProduct.Car_Status__c, 'Car Status should be Sold after Opportunity is Closed Won');

        Planned_Sales__c plannedSale = new Planned_Sales__c(
            Year__c = 2024,
            Month__c = 10,
            Car_Type__c = testProduct.Id 
        );
        insert plannedSale;

        Planned_Sales__c updatedPlannedSale = [SELECT Id, Count_of_Cars_Sold__c, Total_Amount_Earned__c FROM Planned_Sales__c WHERE Id = :plannedSale.Id];
        System.assertEquals(1, updatedPlannedSale.Count_of_Cars_Sold__c, 'Count of Cars Sold should be 1');
        System.assertEquals(10000, updatedPlannedSale.Total_Amount_Earned__c, 'Total Amount Earned should be 10000');

        delete testOpportunity;

        updatedPlannedSale = [SELECT Id, Count_of_Cars_Sold__c, Total_Amount_Earned__c FROM Planned_Sales__c WHERE Id = :plannedSale.Id];
        System.assertEquals(0, updatedPlannedSale.Count_of_Cars_Sold__c, 'Count of Cars Sold should be 0 after Opportunity deletion');
        System.assertEquals(0, updatedPlannedSale.Total_Amount_Earned__c, 'Total Amount Earned should be 0 after Opportunity deletion');

        testOpportunity.StageName = 'Contract Sent'; 
        update testOpportunity;

        Opportunity testOpportunity2 = new Opportunity(
            Name = 'Test Opportunity 2',
            StageName = 'Open',
            CloseDate = Date.today(),
            Amount = 5000
        );
        insert testOpportunity2;

        OpportunityLineItem testOpportunityLineItem2 = new OpportunityLineItem(
            OpportunityId = testOpportunity2.Id,
            Product2Id = testProduct.Id,
            Quantity = 1,
            UnitPrice = 5000
        );

        Test.startTest();
        try {
            insert testOpportunityLineItem2; 
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Warning! This Opportunity has reserved or sold cars.'), 'Warning message should be shown when adding a reserved car');
        }
        Test.stopTest();
    }
}