import { LightningElement, track, api } from 'lwc';
import getAvailableFormFilings from '@salesforce/apex/ListFormFilingsController.getAvailableFormFilings';

export default class ListFormFilings extends LightningElement {

    @track formFilings = [];
    @track isLoading = false;
    @track thereAreFormFilings = true;
    @track showCompletedDate = false;
    @api status = 'All';
    @api year = 'All';

    connectedCallback() {      
        this.isLoading = true;

        if (this.status != 'Draft') {
            this.showCompletedDate = true;
        }

        getAvailableFormFilings({statusOption : this.status, yearOption : this.year})
        .then((data) => {
            if (data.length > 0) {
                this.formFilings = this.normalizeFieldsOnData(data); 
            } else {
                this.thereAreFormFilings = false;
            }
            this.isLoading = false;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('Error in connectedCallback()');
            this.printError(error);       
        });
        
    }

    normalizeFieldsOnData(data) {
        let currentData = [];
        let i = 0;
        data.forEach((row) => {
            let rowData = {};
            let escapedAccountName = this.escapeUrlSpecialCharacters(row.Contact__r.Account.Name);
            let escapedContactName = this.escapeUrlSpecialCharacters(row.Contact__r.Name)
            let escapedFormName = this.escapeUrlSpecialCharacters(row.Form__r.Name);
            let createdDate = new Date(row.CreatedDate);
            rowData.CreatedDate = row.CreatedDate.split('T')[0];
            rowData.Id = row.Id;
            rowData.Name = row.Name;
            rowData.FormName = row.Form__r.Name;
            rowData.Status = row.Status__c;
            rowData.CompletedDate = row.Completed_Date__c;
            rowData.Link = '/clientportal/s/show-questionnaire?c__id=' + row.Id + '&c__formId=' 
                            + row.Form__c + '&c__formName=' 
                            + escapedFormName + '&c__formVersion=' 
                            + row.Form__r.Version_Number__c + '&c__contactId=' 
                            + row.Contact__c + '&c__contactName=' 
                            + escapedContactName + '&c__accountName=' 
                            + escapedAccountName + '&c__year=' 
                            + createdDate.getFullYear();
            
            currentData.push(rowData);
        });

        return currentData;    
    }

    escapeUrlSpecialCharacters(stringValue) {
        return stringValue.replace('&', 'ampersand').replace('?=', '');
    }

    printError(error) {
        console.log(JSON.parse(JSON.stringify(error)));
        console.log("Error stack", error.stack);
        console.log("Error name", error.name);
        console.log("Error message", error.message);
    }

}