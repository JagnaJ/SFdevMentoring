public with sharing class PlannedSalesOpportunityHandler {
    
    public static void handleOpportunityUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunityMap) {
        List<Planned_Sales__c> plannedSalesToUpdate = new List<Planned_Sales__c>();

        for (Opportunity opp : newOpportunities) {
            Opportunity oldOpp = oldOpportunityMap.get(opp.Id);
            
            if (opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won') {
                List<OpportunityLineItem> oliList = [SELECT Car_Type__c, Quantity, TotalPrice 
                                                     FROM OpportunityLineItem 
                                                     WHERE OpportunityId = :opp.Id];
                
                for (OpportunityLineItem oli : oliList) {
                    Planned_Sales__c plannedSale = getPlannedSale(opp.CloseDate, oli.Car_Type__c);
                    if (plannedSale != null) {
                        plannedSale.Count_of_Cars_Sold__c += oli.Quantity;
                        plannedSale.Total_Amount_Earned__c += oli.TotalPrice;
                        plannedSalesToUpdate.add(plannedSale);
                    }
                }
            }
        }

        if (!plannedSalesToUpdate.isEmpty()) {
            update plannedSalesToUpdate;
        }
    }

    public static void handleOpportunityDelete(List<Opportunity> oldOpportunities) {
        List<Planned_Sales__c> plannedSalesToUpdate = new List<Planned_Sales__c>();
        
        for (Opportunity opp : oldOpportunities) {
            if (opp.StageName == 'Closed Won') {
                List<OpportunityLineItem> oliList = [SELECT Car_Type__c, Quantity, TotalPrice 
                                                     FROM OpportunityLineItem 
                                                     WHERE OpportunityId = :opp.Id];
                
                for (OpportunityLineItem oli : oliList) {
                    Planned_Sales__c plannedSale = getPlannedSale(opp.CloseDate, oli.Car_Type__c);
                    if (plannedSale != null) {
                        plannedSale.Count_of_Cars_Sold__c -= oli.Quantity;
                        plannedSale.Total_Amount_Earned__c -= oli.TotalPrice;
                        plannedSalesToUpdate.add(plannedSale);
                    }
                }
            }
        }

        if (!plannedSalesToUpdate.isEmpty()) {
            update plannedSalesToUpdate;
        }
    }

    private static Planned_Sales__c getPlannedSale(Date closeDate, String carType) {
        Integer year = closeDate.year();
        Integer month = closeDate.month();

        Planned_Sales__c plannedSale = [SELECT Id, Count_of_Cars_Sold__c, Total_Amount_Earned__c
                                        FROM Planned_Sales__c
                                        WHERE Year__c = :year
                                        AND Month__c = :month
                                        AND Car_Type__c = :carType
                                        LIMIT 1];
        return plannedSale;
    }
}
