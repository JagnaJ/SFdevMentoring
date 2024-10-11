trigger restrictCarQuantity on OpportunityLineItem (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            OpportunityLineItemTriggerHandler.restrictCarQuantity(Trigger.new);
        }
    }
}