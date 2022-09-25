import { LightningElement, track, api } from 'lwc';
import getRelatedFormFilings from '@salesforce/apex/RelatedFormFilingsController.getRelatedFormFilings';

export default class RelatedFormFilings extends LightningElement {

    @api recordId;
    @track formFilings = [];
    @track thereAreRecords = true;
    @track isLoading;

    connectedCallback() {      
        this.isLoading = true;

        getRelatedFormFilings({engagementId : this.recordId})
        .then((data) => {
            this.thereAreRecords = data.length > 0 ? true : false;
            this.formFilings = this.normalizeFieldsOnData(data);
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            console.log('Error in connectedCallback() getRelatedFormFilings');
            this.printError(error);       
        });           
               
    }

    normalizeFieldsOnData(data) {
        let currentData = [];
        data.forEach((row) => {
            let rowData = {};
            rowData.Id = row.Id;
            rowData.Name = row.Name;
            rowData.FormName = row.Form__r.Name;
            rowData.FormType = row.Form__r.FormType__c;
            rowData.Status = row.Is_Form_Completed__c == true ? 'Complete' : 'Draft';
            rowData.CompletedDate = row.Completed_Date__c;
            rowData.CreatedDate = row.CreatedDate.split('T')[0];
            rowData.ContactName = row.Contact__r.Name;
            rowData.Link = '/' + row.Id;
            currentData.push(rowData);
        });

        return currentData;
    }

    printError(error) {
        console.log("Error stack", error.stack);
        console.log("Error name", error.name);
        console.log("Error message", error.message);
    }

}