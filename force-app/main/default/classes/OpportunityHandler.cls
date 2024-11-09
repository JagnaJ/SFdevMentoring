public class OpportunityHandler {
    public static void handleAfterUpdateOrDelete(List<Opportunity> oldOpportunities) {
        Set<Opportunity> closedOpportunities = new Set<Opportunity>();
        Set<Id> carTypeIds = new Set<Id>();

        for (Opportunity opp : oldOpportunities) {
            if (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost') {
                closedOpportunities.add(opp);
            }

            if (opp.StageName == 'Contract Sent') {
                updateCarStatus(opp, 'Reserved');
            } else if (opp.StageName == 'Closed Won') {
                updateCarStatus(opp, 'Sold');
            } else if (opp.StageName == 'Closed Lost') {
                updateCarStatus(opp, 'Available');
            }

            Opportunity oldOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            if (oldOpp.StageName == 'Contract Sent' && 
                opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost') {
                updateCarStatus(opp, 'Available');
            }
        }

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
            
            if (newOpp.StageName == 'Closed Won' || newOpp.StageName == 'Closed Lost') {
                closedOpportunities.add(newOpp);
            }

            if (newOpp.StageName == 'Contract Sent') {
                updateCarStatus(newOpp, 'Reserved');
            } else if (newOpp.StageName == 'Closed Won') {
                updateCarStatus(newOpp, 'Sold');
            } else if (newOpp.StageName == 'Closed Lost') {
                updateCarStatus(newOpp, 'Available');
            }

            if (oldOpp != null && oldOpp.StageName == 'Contract Sent' && 
                newOpp.StageName != 'Closed Won' && newOpp.StageName != 'Closed Lost') {
                updateCarStatus(newOpp, 'Available');
            }
        }

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