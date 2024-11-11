public with sharing class CaseHandler {
    
    public static void handleCaseCreation(List<Case> newCases) {
        Map<String, Product2> productsMap = new Map<String, Product2>();
        Set<String> vinCodes = new Set<String>();
        Map<Id, Id> caseToCarServiceMap = new Map<Id, Id>();

        Pattern vinPattern = Pattern.compile('VIN-(\\w+)');

        for (Case newCase : newCases) {
            if (newCase.Origin == 'Email') { 
                if (newCase.Subject != null) {
                    Matcher matcher = vinPattern.matcher(newCase.Subject);
                    if (matcher.find()) {
                        vinCodes.add(matcher.group(1));
                    }
                }
            }
            if (newCase.Car_VIN_Code__c != null) {
                vinCodes.add(newCase.Car_VIN_Code__c);
            }
        }

        if (!vinCodes.isEmpty()) {
            List<Product2> products = [SELECT Id, VIN_Number__c FROM Product2 WHERE VIN_Number__c IN :vinCodes];
            for (Product2 product : products) {
                productsMap.put(product.VIN_Number__c, product);
            }
        }

        List<Car_Service__c> carServices = new List<Car_Service__c>();

        for (Case newCase : newCases) {
            if (productsMap.containsKey(newCase.Car_VIN_Code__c)) {
                Car_Service__c carService = new Car_Service__c();
                carService.Car__c = productsMap.get(newCase.Car_VIN_Code__c).Id; 
                carService.Case__c = newCase.Id; 
                carService.Service_Name__c = 'General Service'; 
                carService.Date__c = Date.today(); 
                carServices.add(carService);
                caseToCarServiceMap.put(newCase.Id, carService.Id); 
            }
        }

        if (!carServices.isEmpty()) {
            insert carServices;
        }
    }      
}