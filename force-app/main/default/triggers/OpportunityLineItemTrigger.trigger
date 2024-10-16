trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OpportunityLineItemTriggerHandler.validateLineItems(Trigger.new);
        }
    }
}