import { LightningElement, track, api } from 'lwc';
import getRelatedActionItems from '@salesforce/apex/RelatedActionItemsController.getRelatedActionItems';

export default class RelatedActionItems extends LightningElement {

    @api recordId;
    @track actionItems = [];
    @track thereAreRecords = true;
    @track isLoading;

    connectedCallback() {      
        this.isLoading = true;

        getRelatedActionItems({engagementId : this.recordId})
        .then((data) => {
            this.thereAreRecords = data.length > 0 ? true : false;
            this.actionItems = this.normalizeFieldsOnData(data);
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            console.log('Error in connectedCallback() getRelatedActionItems');
            this.printError(error);       
        });           
               
    }

    normalizeFieldsOnData(data) {
        let currentData = [];
        data.forEach((row) => {
            let rowData = {};
            rowData.Id = row.Id;
            rowData.Name = row.Name;
            rowData.ActionSubject = row.ActionSubject__c;
            rowData.DueDate = row.DueDate__c;
            rowData.DaysRemaining = row.DaysRemaining__c;
            rowData.LastReminderSentOn = row.LastReminderSentOn__c;
            rowData.Status = row.Status__c;
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