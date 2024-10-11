trigger PlannedSalesOpportunityTrigger on Opportunity (after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            PlannedSalesOpportunityHandler.handleOpportunityUpdate(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete) {
            PlannedSalesOpportunityHandler.handleOpportunityDelete(Trigger.old);
        }
    }
}
