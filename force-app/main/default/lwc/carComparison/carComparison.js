import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchCarData from '@salesforce/apex/CarComparisonService.getCarData';
import fetchYearOptions from '@salesforce/apex/CarComparisonService.getYearOptions';
import fetchBrandOptions from '@salesforce/apex/CarComparisonService.getBrandOptions';
import fetchModelOptions from '@salesforce/apex/CarComparisonService.getModelOptions';
import fetchDriveTypeOptions from '@salesforce/apex/CarComparisonService.getDriveTypeOptions';
import fetchProductIds from '@salesforce/apex/CarComparisonService.getProductIds';
import fetchEnabledComparisonSettings from '@salesforce/apex/CarComparisonSettingsController.getEnabledCarComparisonSettings';

export default class CarComparison extends LightningElement {
     isModalOpen = false;
     yearOptions = [];
     brandOptions = [];
     modelOptions = [];
     driveTypeOptions = [];
     selectedCarIds = [];
     carDetails = [];
     formattedCarDetails = [];
     selectedYear;
     selectedBrand;
     selectedModel;
     selectedDriveType;
     enabledSpecifications = [];

    connectedCallback() {
        this.loadEnabledSpecifications();
    }

    @wire(fetchYearOptions)
    loadYearOptions(result) {
        if (result) {
            if (result.data) {
                this.yearOptions = result.data.map(year => ({ label: year, value: year }));
            } else if (result.error) {
                console.error('Error fetching year options:', result.error);
            }
        }
    }
    
    @wire(fetchBrandOptions)
    loadBrandOptions(result) {
        if (result) {
            if (result.data) {
                this.brandOptions = result.data.map(brand => ({ label: brand, value: brand }));
            } else if (result.error) {
                console.error('Error fetching brand options:', result.error);
            }
        }
    }
    
    @wire(fetchModelOptions)
    loadModelOptions(result) {
        if (result) {
            if (result.data) {
                this.modelOptions = result.data.map(model => ({ label: model, value: model }));
            } else if (result.error) {
                console.error('Error fetching model options:', result.error);
            }
        }
    }
    
    @wire(fetchDriveTypeOptions)
    loadDriveTypeOptions(result) {
        if (result) {
            if (result.data) {
                this.driveTypeOptions = result.data.map(driveType => ({ label: driveType, value: driveType }));
            } else if (result.error) {
                console.error('Error fetching drive type options:', result.error);
            }
        }
    }
    
    @wire(fetchEnabledComparisonSettings)
    loadEnabledSpecifications(result) {
        if (result) {
            if (result.data) {
                this.enabledSpecifications = result.data.map(setting => setting.Specification__c);
            } else if (result.error) {
                console.error('Error fetching enabled comparison settings:', result.error);
            }
        }
    }       

    async addSelectedCar() {
        try {
            const productIds = await fetchProductIds({
                year: this.selectedYear,
                brand: this.selectedBrand,
                model: this.selectedModel
            });

            if (!productIds || productIds.length === 0) {
                this.showToast('No Car Found', 'No car found with the selected criteria.', 'warning');
                return;
            }

            const carId = productIds[0]; 

            if (this.selectedCarIds.includes(carId)) {
                this.showToast('Duplicate Selection', 'This car is already selected.', 'info');
                return;
            }

            if (this.selectedCarIds.length >= 4) {
                this.showToast('Limit Exceeded', 'You can only compare up to 4 cars.', 'warning');
                return;
            }

            this.selectedCarIds.push(carId);

            const data = await fetchCarData({ productIds: this.selectedCarIds });
            this.carDetails = data;
            this.prepareCarDetails();
            this.closeModal();

        } catch (error) {
            console.error('Error fetching car data:', error);
        }
    }

    prepareCarDetails() {
        console.log('Car Details:', JSON.stringify(this.carDetails, null, 2));
        this.formattedCarDetails = this.carDetails.map(car => ({
            id: car.id,
            name: car.name,
            vinNumber: car.vinNumber,
            yearOfManufacture: car.yearOfManufacture,
            brand: car.brand,
            model: car.model,
            driveType: car.driveType,
            fuelType: car.fuelType,
            transmissionType: car.transmissionType,
        }));
    }    

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleSelection(event) {
        const { name, value } = event.target;
        this[name] = value;
    }

    handleRemoveCar(event) {
        const carId = event.detail;
        this.selectedCarIds = this.selectedCarIds.filter(id => id !== carId);
        this.carDetails = this.carDetails.filter(car => car.id !== carId);
        this.prepareCarDetails();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}