public with sharing class CarComparisonService {

    @AuraEnabled(cacheable=true)
    public static List<CarData> getCarData(List<Id> productIds) {
        System.debug('Product IDs received: ' + productIds);  

        List<CarData> carDataList = new List<CarData>();

        try {
            for (Product2 product : [
                SELECT Id, Name, VIN_Number__c, Year_of_Manufacture__c, Brand__c, Model__c, Drive_Type__c, Fuel_Type__c, Transmission_Type__c
                FROM Product2 
                WHERE Id IN :productIds
            ]) {
                carDataList.add(new CarData(product));
            }
        } catch (Exception e) {
            System.debug('Error in getCarData: ' + e.getMessage());  
            throw new AuraHandledException('Error fetching car data: ' + e.getMessage());
        }

        System.debug('Fetched Car Data List: ' + carDataList); 
        return carDataList;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getYearOptions() {
        List<String> years = new List<String>();
        Integer currentYear = Date.today().year();
        for (Integer i = 1990; i <= currentYear; i++) {
            years.add(String.valueOf(i));
        }
        return years;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBrandOptions() {
        List<String> brands = new List<String>();
        for (AggregateResult result : [
            SELECT Brand__c FROM Product2 WHERE Brand__c != NULL GROUP BY Brand__c
        ]) {
            brands.add((String)result.get('Brand__c'));
        }
        return brands;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getModelOptions() {
        List<String> models = new List<String>();
        for (AggregateResult result : [
            SELECT Model__c FROM Product2 WHERE Model__c != NULL GROUP BY Model__c
        ]) {
            models.add((String)result.get('Model__c'));
        }
        return models;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getDriveTypeOptions() {
        List<String> driveTypes = new List<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Drive_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistValues) {
            driveTypes.add(entry.getLabel());
        }
        return driveTypes;
    }

    @AuraEnabled(cacheable=true)
    public static List<Id> getProductIds(Integer year, String brand, String model) { 
        List<Id> productIds = new List<Id>();
        for (Product2 product : [
            SELECT Id FROM Product2 
            WHERE Year_of_Manufacture__c = :year 
            AND Brand__c = :brand 
            AND Model__c = :model
        ]) {
            productIds.add(product.Id);
        }
        System.debug('Fetched Product Ids: ' + productIds);
        return productIds;
    }    

    public class CarData {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String vinNumber;
        @AuraEnabled public String yearOfManufacture;
        @AuraEnabled public String brand;
        @AuraEnabled public String model;
        @AuraEnabled public String driveType;
        @AuraEnabled public String fuelType;
        @AuraEnabled public String transmissionType;

        public CarData(Product2 product) {
            this.id = product.Id;
            this.name = product.Name;
            this.vinNumber = product.VIN_Number__c;
            this.yearOfManufacture = String.valueOf(product.Year_of_Manufacture__c);
            this.brand = product.Brand__c;
            this.model = product.Model__c;
            this.driveType = product.Drive_Type__c;
            this.fuelType = product.Fuel_Type__c;
            this.transmissionType = product.Transmission_Type__c;
        }
    }
}