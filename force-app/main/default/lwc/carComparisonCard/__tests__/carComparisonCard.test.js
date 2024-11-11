import { createElement } from 'lwc';
import CarComparisonCard from 'c/carComparisonCard';

describe('c-carComparison-card', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders car details correctly', () => {
        const element = createElement('c-carComparisonCard', {
            is: CarComparisonCard
        });
        element.car = {
            id: '1',
            name: 'Toyota Camry',
            vinNumber: '1HGCM82633A123456',
            yearOfManufacture: '2023',
            brand: 'Toyota',
            model: 'Camry',
            driveType: 'FWD',
            fuelType: 'Gasoline',
            transmissionType: 'Automatic'
        };
        document.body.appendChild(element);

        const nameEl = element.shadowRoot.querySelector('h3');
        expect(nameEl.textContent).toBe('Toyota Camry');

        const vinEl = element.shadowRoot.querySelector('p:nth-of-type(1)');
        expect(vinEl.textContent).toBe('VIN: 1HGCM82633A123456');
    });

    it('dispatches event on remove button click', () => {
        const element = createElement('c-carComparisonCard', {
            is: CarComparisonCard
        });
        element.car = { id: '1' };
        document.body.appendChild(element);

        const handler = jest.fn();
        element.addEventListener('removecar', handler);

        const button = element.shadowRoot.querySelector('lightning-button');
        button.click();

        expect(handler).toHaveBeenCalled();
    });
});
