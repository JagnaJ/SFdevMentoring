@IsTest
private class SmartCarIntegrationTest {

    private class SmartCarIntegrationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            if (req.getEndpoint().contains('/location')) {
                res.setBody('{"latitude": 37.7749, "longitude": -122.4194}');
            } else {
                res.setBody('{"make": "TOYOTA", "model": "RAV 4", "year": 2020}');
            }
            
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    static void testGetVehicleDetails() {
        Test.setMock(HttpCalloutMock.class, new SmartCarIntegrationMock());

        VehicleDetailsWrapper vehicleDetails = SmartCarIntegration.getVehicleDetails('90dddba8-ee06-4593-bb83-41f2bc276d3c');
        System.assertNotEquals(null, vehicleDetails, 'Vehicle details should not be null');
        System.assertEquals('TOYOTA', vehicleDetails.make, 'Make should match');
        System.assertEquals('RAV 4', vehicleDetails.model, 'Model should match');
        System.assertEquals(2020, vehicleDetails.year, 'Year should match');
    }

    @IsTest
    static void testGetVehicleLocation() {
        Test.setMock(HttpCalloutMock.class, new SmartCarIntegrationMock());

        LocationWrapper location = SmartCarIntegration.getVehicleLocation('90dddba8-ee06-4593-bb83-41f2bc276d3c');
        System.assertNotEquals(null, location, 'Location should not be null');
        System.assertEquals(37.7749, location.latitude, 'Latitude should match');
        System.assertEquals(-122.4194, location.longitude, 'Longitude should match');
    }
}