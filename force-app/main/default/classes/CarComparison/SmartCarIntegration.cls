public with sharing class SmartCarIntegration {
    private static final String BASE_ENDPOINT = 'callout:SmartCar_Legacy/v2.0';

    @AuraEnabled
    public static VehicleDetailsWrapper getVehicleDetails(String vehicleId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_ENDPOINT + '/vehicles/' + vehicleId);
        req.setMethod('GET');

        System.debug('getVehicleDetails: Sending request to ' + req.getEndpoint());

        try {
            HttpResponse res = new Http().send(req);
            System.debug('getVehicleDetails: Received response with status ' + res.getStatus());
            System.debug('getVehicleDetails: Response body ' + res.getBody());

            if (res.getStatusCode() == 200) {
                VehicleDetailsWrapper vehicleDetails = (VehicleDetailsWrapper) JSON.deserialize(res.getBody(), VehicleDetailsWrapper.class);
                System.debug('getVehicleDetails: Parsed VehicleDetailsWrapper ' + vehicleDetails);
                return vehicleDetails;
            } else {
                throw new CalloutException('Failed to retrieve vehicle details: ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Error in getVehicleDetails: ' + e.getMessage());
            throw new CalloutException('Error retrieving vehicle details: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static LocationWrapper getVehicleLocation(String vehicleId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_ENDPOINT + '/vehicles/' + vehicleId + '/location');
        req.setMethod('GET');

        System.debug('getVehicleLocation: Sending request to ' + req.getEndpoint());

        try {
            HttpResponse res = new Http().send(req);
            System.debug('getVehicleLocation: Received response with status ' + res.getStatus());
            System.debug('getVehicleLocation: Response body ' + res.getBody());

            if (res.getStatusCode() == 200) {
                LocationWrapper location = (LocationWrapper) JSON.deserialize(res.getBody(), LocationWrapper.class);
                System.debug('getVehicleLocation: Parsed LocationWrapper ' + location);
                return location;
            } else {
                throw new CalloutException('Failed to retrieve vehicle location: ' + res.getStatus());
            }
        } catch (Exception e) {
            System.debug('Error in getVehicleLocation: ' + e.getMessage());
            throw new CalloutException('Error retrieving vehicle location: ' + e.getMessage());
        }
    }
}