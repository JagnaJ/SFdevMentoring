trigger PlannedSalesTrigger on Planned_Sales__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            PlannedSalesHandler.handleAfterInsertOrUpdate(Trigger.new);
        } else if (Trigger.isInsert) {
            System.enqueueJob(new PlannedSalesAsyncUpdater(Trigger.new));
        }
    }
}
