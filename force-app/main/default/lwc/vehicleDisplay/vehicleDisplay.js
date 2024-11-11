import { LightningElement, track } from 'lwc';
import getVehicleDetails from '@salesforce/apex/SmartCarIntegration.getVehicleDetails';
import getVehicleLocation from '@salesforce/apex/SmartCarIntegration.getVehicleLocation';

export default class VehicleDisplay extends LightningElement {
    @track vehicle = { make: '', model: '', year: '', location: null };
    @track mapMarkers = [];
    @track mapCenter = {
        latitude: 37.7749,
        longitude: -122.4194
    };
    @track error = null;

    handleGetVehicle() {
        this.error = null;

        getVehicleDetails({ vehicleId: '90dddba8-ee06-4593-bb83-41f2bc276d3c' })
            .then(result => {
                console.log('Vehicle Details:', result);
                if (result) {
                    this.vehicle.make = result.make || 'N/A';
                    this.vehicle.model = result.model || 'N/A';
                    this.vehicle.year = result.year || 'N/A';
                    return getVehicleLocation({ vehicleId: '90dddba8-ee06-4593-bb83-41f2bc276d3c' });
                }
                throw new Error('Vehicle details not found');
            })
            .then(locationResult => {
                console.log('Vehicle Location:', locationResult);
                if (locationResult) {
                    this.vehicle.location = locationResult;
                    this.mapMarkers = [{
                        location: {
                            Latitude: locationResult.latitude,
                            Longitude: locationResult.longitude
                        },
                        title: `${this.vehicle.make} ${this.vehicle.model}`
                    }];
                    this.mapCenter = {
                        latitude: locationResult.latitude,
                        longitude: locationResult.longitude
                    };
                } else {
                    this.mapMarkers = [];
                }
            })
            .catch(error => {
                console.error('Error:', error);
                this.error = 'Failed to retrieve vehicle details or location. Please try again.';
                this.vehicle = { make: '', model: '', year: '', location: null };
                this.mapMarkers = [];
            });
    }

    get locationText() {
        return this.vehicle.location 
            ? `${this.vehicle.location.latitude}, ${this.vehicle.location.longitude}` 
            : 'N/A';
    }
}