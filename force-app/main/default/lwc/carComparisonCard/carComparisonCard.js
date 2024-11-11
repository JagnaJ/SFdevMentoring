import { LightningElement, api } from 'lwc';

export default class CarComparisonCard extends LightningElement {
    @api car;

    handleRemove() {
        const removeEvent = new CustomEvent('removecar', { detail: this.car.id });
        this.dispatchEvent(removeEvent);
    }
}