import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isCommunityUser from '@salesforce/apex/ContactCommunityAccessController.isCommunityUser';

export default class ContactCommunityAccess extends LightningElement {

    @api recordId;

    connectedCallback() {      
        
        let recordId = this.recordId;
        isCommunityUser({contactId : recordId})
        .then((data) => {
            console.log('>>> result ' + result);
        })
        .catch((error) => {
            console.log('Error in connectedCallback()');
            this.printError(error);
        });

    }

    printError(error) {
        console.log(JSON.parse(JSON.stringify(error)));
        console.log("Error stack", error.stack);
        console.log("Error name", error.name);
        console.log("Error message", error.message);
    }

}