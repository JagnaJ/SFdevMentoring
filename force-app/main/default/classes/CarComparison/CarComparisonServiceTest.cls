@IsTest
public class CarComparisonServiceTest {

    @TestSetup
    static void setup() {
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Toyota Camry', VIN_Number__c = '1HGCM82633A123456', Year_of_Manufacture__c = 2023, Brand__c = 'Toyota', Model__c = 'Camry', Drive_Type__c = 'FWD', Fuel_Type__c = 'Gasoline', Transmission_Type__c = 'Automatic'),
            new Product2(Name = 'Porsche 911', VIN_Number__c = 'WP0ZZZ99ZTS392124', Year_of_Manufacture__c = 2024, Brand__c = 'Porsche', Model__c = '911', Drive_Type__c = 'RWD', Fuel_Type__c = 'Gasoline', Transmission_Type__c = 'Manual')
        };
        insert products;
    }

    @IsTest
    static void testGetCarData() {
        List<Id> productIds = new List<Id>();
        List<Product2> products = [SELECT Id FROM Product2 LIMIT 2];
        for (Product2 product : products) {
            productIds.add(product.Id);
        }
    
        List<CarComparisonService.CarData> carDataList = CarComparisonService.getCarData(productIds);
    
        System.assertEquals(2, carDataList.size(), 'Should return 2 CarData entries');
        System.assertEquals('Toyota Camry', carDataList[0].name, 'First car should be Toyota Camry');
        System.assertEquals('Porsche 911', carDataList[1].name, 'Second car should be Porsche 911');
    }
    
    @IsTest
    static void testGetYearOptions() {
        List<String> years = CarComparisonService.getYearOptions();
        System.assert(!years.isEmpty(), 'Year options should not be empty');
    }

    @IsTest
    static void testGetBrandOptions() {
        List<String> brands = CarComparisonService.getBrandOptions();
        System.assertEquals(2, brands.size(), 'Should return 2 brands');
        System.assert(brands.contains('Toyota') && brands.contains('Porsche'), 'Brands should contain Toyota and Porsche');
    }

    @IsTest
    static void testGetModelOptions() {
        List<String> models = CarComparisonService.getModelOptions();
        System.assertEquals(2, models.size(), 'Should return 2 models');
        System.assert(models.contains('Camry') && models.contains('911'), 'Models should contain Camry and 911');
    }

    @IsTest
    static void testGetDriveTypeOptions() {
        List<String> driveTypes = CarComparisonService.getDriveTypeOptions();
        System.assert(!driveTypes.isEmpty(), 'Drive types should not be empty');
    }

    @IsTest
    static void testGetProductIds() {
        List<Id> productIds = CarComparisonService.getProductIds(2023, 'Toyota', 'Camry');
        System.assertEquals(1, productIds.size(), 'Should return 1 product ID');
    }
}