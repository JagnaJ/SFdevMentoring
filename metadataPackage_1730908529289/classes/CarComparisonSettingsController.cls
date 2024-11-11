public with sharing class CarComparisonSettingsController {
    @AuraEnabled(cacheable=true)
    public static List<Car_Comparison_Setting__mdt> getEnabledCarComparisonSettings() {
        return [SELECT Specification__c, Enabled__c FROM Car_Comparison_Setting__mdt];
    }
}
