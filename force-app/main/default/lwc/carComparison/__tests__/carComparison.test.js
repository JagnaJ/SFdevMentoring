import { createElement } from 'lwc';
import CarComparison from 'c/carComparison';
import getYearOptions from '@salesforce/apex/CarComparisonService.getYearOptions';
import getBrandOptions from '@salesforce/apex/CarComparisonService.getBrandOptions';
import getModelOptions from '@salesforce/apex/CarComparisonService.getModelOptions';
import getDriveTypeOptions from '@salesforce/apex/CarComparisonService.getDriveTypeOptions';

jest.mock(
    '@salesforce/apex/CarComparisonService.getCarData',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/CarComparisonService.getYearOptions',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/CarComparisonService.getBrandOptions',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/CarComparisonService.getModelOptions',
    () => ({ default: jest.fn() }),
    { virtual: true }
);
jest.mock(
    '@salesforce/apex/CarComparisonService.getDriveTypeOptions',
    () => ({ default: jest.fn() }),
    { virtual: true }
);

describe('c-carComparison', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders with correct label and opens modal on button click', async () => {
        const element = createElement('c-carComparison', {
            is: CarComparison
        });
        document.body.appendChild(element);

        const button = element.shadowRoot.querySelector('lightning-button[label="Add Vehicle"]');
        expect(button).not.toBeNull();

        button.click();

        await Promise.resolve(); 

        const modal = element.shadowRoot.querySelector('section.slds-modal');
        expect(modal).not.toBeNull();
    });

    it('calls apex methods on load and populates options', async () => {
        getYearOptions.mockResolvedValue(['2022', '2023']);
        getBrandOptions.mockResolvedValue(['Toyota', 'Porsche']);
        getModelOptions.mockResolvedValue(['Camry', '911']);
        getDriveTypeOptions.mockResolvedValue(['FWD', 'RWD']);

        const element = createElement('c-carComparison', {
            is: CarComparison
        });
        document.body.appendChild(element);

        await Promise.resolve(); 

        const yearOptions = element.shadowRoot.querySelector('lightning-combobox[name="selectedYear"]');
        const brandOptions = element.shadowRoot.querySelector('lightning-combobox[name="selectedBrand"]');

        expect(yearOptions.options).toEqual(expect.arrayContaining([{ label: '2022', value: '2022' }]));
        expect(brandOptions.options).toEqual(expect.arrayContaining([{ label: 'Toyota', value: 'Toyota' }]));
    });
});
