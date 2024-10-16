public with sharing class CaseService {
    public static void createCaseFromWebForm(String name, String email, String phone, String carBrand, String carModel, String vinCode, String reason, String description) {
        Case newCase = new Case();
        newCase.SuppliedName = name;
        newCase.SuppliedEmail = email;
        newCase.SuppliedPhone = phone;
        newCase.CarBrand__c = carBrand;
        newCase.CarModel__c = carModel;
        newCase.CarVinCode__c = vinCode;
        newCase.Subject = reason;
        newCase.Description = description;
        newCase.Origin = 'Web Car Service';
        newCase.OwnerId = [SELECT Id FROM Group WHERE Name = 'Service Cases' LIMIT 1].Id;

        insert newCase;
    }
}
