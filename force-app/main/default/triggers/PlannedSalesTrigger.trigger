trigger PlannedSalesTrigger on Planned_Sales__c (after insert, after update) {
    if (Trigger.isAfter) {
        PlannedSalesHandler.handleAfterInsertOrUpdate(Trigger.new);
    }
}