/**
 * @description       : 
 * @author            : Svyatoslav Andrushchak
 * @group             : 
 * @last modified on  : 10-11-2024
 * @last modified by  : Svyatoslav Andrushchak
**/
public class PlannedSalesHandler {
    public static void handleAfterInsertOrUpdate(List<Planned_Sales__c> plannedSalesList) {
        Set<Id> carTypeSet = new Set<Id>();
        Map<Id, Planned_Sales__c> plannedSalesMap = new Map<Id, Planned_Sales__c>();

        for (Planned_Sales__c ps : plannedSalesList) {
            if (ps.Car_Type__c != null) {
                // Car Type is a Picklist -> String values
                carTypeSet.add(ps.Car_Type__c);
                plannedSalesMap.put(ps.Id, ps);
            }
        }

        // It's ok that you query line items by filtering them by Car
        List<OpportunityLineItem> oliList = [
            SELECT OpportunityId, Product2Id 
            FROM OpportunityLineItem 
            WHERE Product2Id IN :carTypeSet
        ];

        Map<Id, Id> opportunityToCarTypeMap = new Map<Id, Id>();
        for (OpportunityLineItem oli : oliList) {
            opportunityToCarTypeMap.put(oli.OpportunityId, oli.Product2Id);
        }

        List<AggregateResult> aggResults = [
            SELECT COUNT(Id) carsSold, SUM(Amount) totalAmount, CALENDAR_YEAR(CloseDate) year, CALENDAR_MONTH(CloseDate) month
            FROM Opportunity
            WHERE StageName = 'Closed Won'
            AND Id IN :opportunityToCarTypeMap.keySet()
            GROUP BY CALENDAR_YEAR(CloseDate), CALENDAR_MONTH(CloseDate)
        ];

        Map<Id, Integer> countOfCarsSoldMap = new Map<Id, Integer>();
        Map<Id, Decimal> totalAmountEarnedMap = new Map<Id, Decimal>();

        for (AggregateResult ar : aggResults) {
            Integer year = (Integer) ar.get('year');
            Integer month = (Integer) ar.get('month');
            Integer carsSold = (Integer) ar.get('carsSold');
            Decimal totalAmount = (Decimal) ar.get('totalAmount');

            for (Planned_Sales__c ps : plannedSalesList) {
                if (ps.Year__c == year && ps.Month__c == month && opportunityToCarTypeMap.containsKey(ps.Car_Type__c)) {
                    countOfCarsSoldMap.put(ps.Id, carsSold);
                    totalAmountEarnedMap.put(ps.Id, totalAmount);
                }
            }
        }

        List<Planned_Sales__c> plannedSalesToUpdate = new List<Planned_Sales__c>();
        for (Planned_Sales__c ps : plannedSalesList) {
            ps.Count_of_Cars_Sold__c = countOfCarsSoldMap.containsKey(ps.Id) ? countOfCarsSoldMap.get(ps.Id) : 0;
            ps.Total_Amount_Earned__c = totalAmountEarnedMap.containsKey(ps.Id) ? totalAmountEarnedMap.get(ps.Id) : 0;
            plannedSalesToUpdate.add(ps);
        }

        if (!plannedSalesToUpdate.isEmpty()) {
            update plannedSalesToUpdate;
        }
    }
}