public with sharing class WebToCaseController {
    @AuraEnabled
    public static String sendWebToCase(Map<String, String> formData) {
        try {
            Case newCase = new Case();
            
            newCase.SuppliedName = formData.get('name');
            newCase.SuppliedEmail = formData.get('email');
            newCase.SuppliedPhone = formData.get('phone');
            newCase.Subject = formData.get('subject');
            newCase.Description = formData.get('description');
            newCase.CarBrand__c = formData.get('carBrand');
            newCase.Car_Model__c = formData.get('carModel');
            newCase.Car_VIN_Code__c = formData.get('carVin');
            
            
            newCase.Origin = 'Web Car Service'; 

            System.debug('Supplied Name: ' + newCase.SuppliedName);
            System.debug('Car VIN Code: ' + newCase.Car_VIN_Code__c);
            System.debug('Case Origin: ' + newCase.Origin);

            insert newCase;
            
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return 'ERROR: ' + e.getMessage();
        }
    }
}