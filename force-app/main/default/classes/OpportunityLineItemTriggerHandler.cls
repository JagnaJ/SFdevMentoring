public with sharing class OpportunityLineItemTriggerHandler {
    public static void restrictCarQuantity(List<OpportunityLineItem> lineItems) {
        if (lineItems != null && !lineItems.isEmpty()) {
            for (OpportunityLineItem item : lineItems) {
                if (item.Quantity != 1) {
                    item.addError('Quantity of the car must be 1.');
                }
            }
        }
    }
}