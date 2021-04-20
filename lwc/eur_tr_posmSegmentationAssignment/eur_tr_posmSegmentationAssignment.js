/**
 * Created by osman on 28.10.2020.
 */

import {LightningElement} from 'lwc';
import EUR_TR_DEFINITION_OBJECT from '@salesforce/schema/EUR_TR_Definition__c';


export default class POSMSegmentationAssignment extends LightningElement {

    isLoading = false;
    segmentation = EUR_TR_DEFINITION_OBJECT;

    handleClone(event) {
        this.setSelectedRow(event);
        const segmentationForm = this.template.querySelector('c-eur-tr-new-posm-segmentation-form');
        segmentationForm.openFormByClonedRecord(this.segmentation);
        this.scrollToForm();
    }

    handleUpdate(event) {
        this.setSelectedRow(event);
        const segmentationForm = this.template.querySelector('c-eur-tr-new-posm-segmentation-form');
        segmentationForm.openFormToUpdate(this.segmentation);
        this.scrollToForm();
    }

    scrollToForm() {
        const segmentationForm = this.template.querySelector('c-eur-tr-new-posm-segmentation-form');
        setTimeout(() => {
            segmentationForm.scrollIntoView();
        }, 100);
    }

    setSelectedRow(event) {
        this.segmentation = event.detail.selectedRow;
    }

    refreshTable() {
        const definitionTableLWC = this.template.querySelector('c-eur-tr-posm-segmentation-table');
        definitionTableLWC.refreshTable();
    }

}