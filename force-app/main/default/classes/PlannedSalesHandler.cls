/**
 * @description       : Handler for Planned Sales Trigger
 * @author            : Svyatoslav Andrushchak
 * @group             : 
 * @last modified on  : 10-11-2024
 * @last modified by  : Svyatoslav Andrushchak
 **/
public with sharing class PlannedSalesHandler {
    private static Boolean isProcessing = false;

    public static void handleAfterInsertOrUpdate(List<Planned_Sales__c> plannedSalesList) {
        if (isProcessing) {
            return;
        }

        isProcessing = true;

        Set<String> carTypeSet = getCarTypeSet(plannedSalesList);
        Map<Id, Planned_Sales__c> plannedSalesMap = getPlannedSalesMap(plannedSalesList);

        if (Schema.sObjectType.Opportunity.isAccessible()) {
            List<OpportunityLineItem> oliList = getOpportunityLineItems(carTypeSet);
            Map<Id, Set<String>> opportunityToCarTypeMap = mapOpportunitiesToCarTypes(oliList);

            List<AggregateResult> aggResults = getAggregateResults(opportunityToCarTypeMap);
            Map<Id, Integer> countOfCarsSoldMap = new Map<Id, Integer>();
            Map<Id, Decimal> totalAmountEarnedMap = new Map<Id, Decimal>();

            processAggregateResults(aggResults, plannedSalesList, opportunityToCarTypeMap, countOfCarsSoldMap, totalAmountEarnedMap);
            updatePlannedSales(plannedSalesList, countOfCarsSoldMap, totalAmountEarnedMap);
        }

        isProcessing = false;
    }

    private static Set<String> getCarTypeSet(List<Planned_Sales__c> plannedSalesList) {
        Set<String> carTypeSet = new Set<String>();
        for (Planned_Sales__c ps : plannedSalesList) {
            if (ps.Car_Type__c != null) {
                carTypeSet.add(ps.Car_Type__c);
            }
        }
        return carTypeSet;
    }

    private static Map<Id, Planned_Sales__c> getPlannedSalesMap(List<Planned_Sales__c> plannedSalesList) {
        Map<Id, Planned_Sales__c> plannedSalesMap = new Map<Id, Planned_Sales__c>();
        for (Planned_Sales__c ps : plannedSalesList) {
            plannedSalesMap.put(ps.Id, ps);
        }
        return plannedSalesMap;
    }

    private static List<OpportunityLineItem> getOpportunityLineItems(Set<String> carTypeSet) {
        List<Product2> products = [
            SELECT Id, Planned_Sales_Lookup__c
            FROM Product2
            WHERE Planned_Sales_Lookup__c != null
        ];

        Set<Id> plannedSalesIds = new Set<Id>();
        for (Product2 product : products) {
            plannedSalesIds.add(product.Planned_Sales_Lookup__c);
        }

        return [
            SELECT OpportunityId, Product2Id
            FROM OpportunityLineItem
            WHERE Product2Id IN :products
        ];
    }

    private static Map<Id, Set<String>> mapOpportunitiesToCarTypes(List<OpportunityLineItem> oliList) {
        Map<Id, Set<String>> opportunityToCarTypeMap = new Map<Id, Set<String>>();

        for (OpportunityLineItem oli : oliList) {
            Id opportunityId = oli.OpportunityId;

            Product2 product = [
                SELECT Planned_Sales_Lookup__r.Car_Type__c
                FROM Product2
                WHERE Id = :oli.Product2Id
            ];

            if (product.Planned_Sales_Lookup__r.Car_Type__c != null) {
                if (!opportunityToCarTypeMap.containsKey(opportunityId)) {
                    opportunityToCarTypeMap.put(opportunityId, new Set<String>());
                }
                opportunityToCarTypeMap.get(opportunityId).add(product.Planned_Sales_Lookup__r.Car_Type__c);
            }
        }

        return opportunityToCarTypeMap;
    }    

    private static List<AggregateResult> getAggregateResults(Map<Id, Set<String>> opportunityToCarTypeMap) {
        return [
            SELECT COUNT(Id) carsSold, SUM(Amount) totalAmount,
                   CALENDAR_YEAR(CloseDate) year, CALENDAR_MONTH(CloseDate) month
            FROM Opportunity
            WHERE StageName = 'Closed Won'
            AND Id IN :opportunityToCarTypeMap.keySet()
            GROUP BY CALENDAR_YEAR(CloseDate), CALENDAR_MONTH(CloseDate)
        ];
    }

    private static void processAggregateResults(List<AggregateResult> aggResults, List<Planned_Sales__c> plannedSalesList, 
                                                Map<Id, Set<String>> opportunityToCarTypeMap, 
                                                Map<Id, Integer> countOfCarsSoldMap, 
                                                Map<Id, Decimal> totalAmountEarnedMap) {
        for (AggregateResult ar : aggResults) {
            Integer year = (Integer) ar.get('year');
            Integer month = (Integer) ar.get('month');
            Integer carsSold = (Integer) ar.get('carsSold');
            Decimal totalAmount = (Decimal) ar.get('totalAmount');

            for (Planned_Sales__c ps : plannedSalesList) {
                if (ps.Year__c == year && ps.Month__c == month &&
                    opportunityToCarTypeMap.containsKey(ps.Car_Type__c) &&
                    opportunityToCarTypeMap.get(ps.Car_Type__c).contains(ps.Car_Type__c)) {

                    countOfCarsSoldMap.put(ps.Id, carsSold);
                    totalAmountEarnedMap.put(ps.Id, totalAmount);
                }
            }
        }
    }

    private static void updatePlannedSales(List<Planned_Sales__c> plannedSalesList, 
                                            Map<Id, Integer> countOfCarsSoldMap, 
                                            Map<Id, Decimal> totalAmountEarnedMap) {
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


