public class OpportunityHandler {
    public static void handleAfterUpdateOrDelete(List<Opportunity> oldOpportunities) {
        Set<Opportunity> closedOpportunities = new Set<Opportunity>();
        Set<Id> carTypeIds = new Set<Id>();

        for (Opportunity opp : oldOpportunities) {
            // Check if the opportunity is closed
            if (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost') {
                closedOpportunities.add(opp);
            }

            // Update car status based on the opportunity stage
            if (opp.StageName == 'Contract Sent') {
                updateCarStatus(opp, 'Reserved');
            } else if (opp.StageName == 'Closed Won') {
                updateCarStatus(opp, 'Sold');
            } else if (opp.StageName == 'Closed Lost') {
                updateCarStatus(opp, 'Available');
            }

            // Check previous stage and update status if necessary
            Opportunity oldOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            if (oldOpp.StageName == 'Contract Sent' && 
                opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost') {
                updateCarStatus(opp, 'Available');
            }
        }

        // Get related OpportunityLineItems for closed opportunities
        List<OpportunityLineItem> oliList = [
            SELECT Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId IN :closedOpportunities
        ];

        for (OpportunityLineItem oli : oliList) {
            carTypeIds.add(oli.Product2Id);
        }

        validateCarStatusForOpportunities(carTypeIds, closedOpportunities);
    }

    public static void handleOpportunityUpdate(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities) {
        Set<Opportunity> closedOpportunities = new Set<Opportunity>();
        Set<Id> carTypeIds = new Set<Id>();

        for (Opportunity newOpp : newOpportunities) {
            Opportunity oldOpp = oldOpportunities.get(newOpp.Id);
            
            // Check if the opportunity is closed
            if (newOpp.StageName == 'Closed Won' || newOpp.StageName == 'Closed Lost') {
                closedOpportunities.add(newOpp);
            }

            // Update car status based on the opportunity stage
            if (newOpp.StageName == 'Contract Sent') {
                updateCarStatus(newOpp, 'Reserved');
            } else if (newOpp.StageName == 'Closed Won') {
                updateCarStatus(newOpp, 'Sold');
            } else if (newOpp.StageName == 'Closed Lost') {
                updateCarStatus(newOpp, 'Available');
            }

            // Check previous stage and update status if necessary
            if (oldOpp != null && oldOpp.StageName == 'Contract Sent' && 
                newOpp.StageName != 'Closed Won' && newOpp.StageName != 'Closed Lost') {
                updateCarStatus(newOpp, 'Available');
            }
        }

        // Get related OpportunityLineItems for closed opportunities
        List<OpportunityLineItem> oliList = [
            SELECT Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId IN :closedOpportunities
        ];

        for (OpportunityLineItem oli : oliList) {
            carTypeIds.add(oli.Product2Id);
        }

        validateCarStatusForOpportunities(carTypeIds, closedOpportunities);
    }

    private static void updateCarStatus(Opportunity opp, String status) {
        List<Product2> carsToUpdate = [
            SELECT Id, Car_Status__c 
            FROM Product2 
            WHERE Id IN (SELECT Product2Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id)
        ];

        for (Product2 car : carsToUpdate) {
            car.Car_Status__c = status;
        }

        if (!carsToUpdate.isEmpty()) {
            update carsToUpdate; 
        }
    }

    private static void validateCarStatusForOpportunities(Set<Id> carTypeIds, Set<Opportunity> closedOpportunities) {
        List<OpportunityLineItem> reservedOrSoldOLIs = [
            SELECT Id, Product2Id, OpportunityId 
            FROM OpportunityLineItem 
            WHERE Product2Id IN :carTypeIds 
            AND Product2.Car_Status__c IN ('Reserved', 'Sold')
        ];

        for (OpportunityLineItem oli : reservedOrSoldOLIs) {
            Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :oli.OpportunityId LIMIT 1];
            if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost') {
                oli.addError('Warning! This Opportunity has reserved or sold cars. You are not able to move forward with it until you remove those cars, or they are back available.');
            }
        }
    }
}
