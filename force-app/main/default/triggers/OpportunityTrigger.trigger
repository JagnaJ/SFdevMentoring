trigger OpportunityTrigger on Opportunity (after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            OpportunityHandler.handleOpportunityUpdate(Trigger.new, Trigger.oldMap);
            OpportunityHandler.handleAfterUpdateOrDelete(Trigger.old);
        } else if (Trigger.isDelete) {
            OpportunityHandler.handleAfterUpdateOrDelete(Trigger.old);
        }
    }
}
