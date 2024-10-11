public class OpportunityHandler {
    public static void handleAfterUpdateOrDelete(Map<Id, Opportunity> oldMap) {
        Set<Id> closedOpportunityIds = new Set<Id>();
        Set<Id> carTypeIds = new Set<Id>();

        for (Opportunity opp : oldMap.values()) {
            if (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost') {
                closedOpportunityIds.add(opp.Id);
            }

            if (opp.StageName == 'Contract Sent') {
                updateCarStatus(opp, 'Reserved');
            } else if (opp.StageName == 'Closed Won') {
                updateCarStatus(opp, 'Sold');
            } else if (opp.StageName == 'Closed Lost') {
                updateCarStatus(opp, 'Available');
            } else if (oldMap.get(opp.Id).StageName == 'Contract Sent' && opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost') {
                updateCarStatus(opp, 'Available');
            }
        }

        List<OpportunityLineItem> oliList = [
            SELECT Product2Id
            FROM OpportunityLineItem
            WHERE OpportunityId IN :closedOpportunityIds
        ];

        for (OpportunityLineItem oli : oliList) {
            carTypeIds.add(oli.Product2Id);
        }

        validateCarStatusForOpportunities(carTypeIds, closedOpportunityIds);
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

    private static void validateCarStatusForOpportunities(Set<Id> carTypeIds, Set<Id> closedOpportunityIds) {
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