import { LightningElement, track } from 'lwc';
import getTermsAndConditions from '@salesforce/apex/ClientPortalTACController.getTermsAndConditions';
import saveAcceptedTermsAndConditions from '@salesforce/apex/ClientPortalTACController.saveAcceptedTermsAndConditions';

export default class ClientPortalTAC extends LightningElement {

    @track termsAndConditionsRecordId;
    @track termsAndConditionsText;
    @track showTermsAndConditions = false;
    @track isLoading = false;

    connectedCallback() {
        getTermsAndConditions()
        .then((data) => {

            if (data.length > 0) {
                this.showTermsAndConditions = true;
                this.termsAndConditionsRecordId = data[0].Id;
                this.termsAndConditionsText = data[0].Terms__c;
            } else {
                this.showTermsAndConditions = false;
            }
            
        }).catch(error => {

            console.log('Error in connectedCallback() getTermsAndConditions');
            this.printError(error);  

        });
        
    }

    renderedCallback() {
        if (this.showTermsAndConditions) {
            let element = this.template.querySelector('.tac-text-container');
            element.innerHTML = this.termsAndConditionsText;
        }
    }

    handleCheckboxChange(event) {
        let element = this.template.querySelector('[data-name="accept-button"]');

        if (element.disabled === true) {
            element.disabled = false;
        } else {
            element.disabled = true;
        }
    }

    acceptTAC() {
        this.isLoading = true;
        saveAcceptedTermsAndConditions({tacId : this.termsAndConditionsRecordId, tacText : this.termsAndConditionsText})
        .then((data) => {
            this.isLoading = false;
            this.showTermsAndConditions = false;
        }).catch(error => {
            this.isLoading = false;
            console.log('Error in connectedCallback() getTermsAndConditions');
            this.printError(error);  
        });
    }

    printError(error) {
        console.log("Error stack", error.stack);
        console.log("Error name", error.name);
        console.log("Error message", error.message);
    }
    
}