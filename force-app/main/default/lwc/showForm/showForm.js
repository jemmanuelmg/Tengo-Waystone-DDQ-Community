import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFormSectionsAndFields from '@salesforce/apex/ShowFormController.getFormSectionsAndFields';
import saveSubmittedForm from '@salesforce/apex/ShowFormController.saveSubmittedForm';
import getSubmittedAnswers from '@salesforce/apex/ShowFormController.getSubmittedAnswers';
import getFormFilingEngagements from '@salesforce/apex/ShowFormController.getFormFilingEngagements';
import getPicklistValues from '@salesforce/apex/ShowFormController.getPicklistValues';

export default class ShowForm extends LightningElement {

    @track isLoading = false;
    @track formFilingId;
    @track formId;
    @track formName;
    @track formVersion;
    @track contactId;
    @track contactName;
    @track accountName;
    @track formSectionAndFields;
    @track fundNamesList = [];
    @track formFieldIdList = [];
    @track answerMap = new Map();
    @track commentsMap = new Map();
    @track isRendered = false;
    @track urlHasParameters = true;
    @track today;
    @track reportingYear;
    @track ifFormComplete = false;
    @track countryListOptions = [];
    @track strategyListOptions = [];

    requiredBool = false;

    get yesNoOptions() {
        return [
            {'label': 'Yes', 'value': 'Yes'},
            {'label': 'No', 'value': 'No'},
        ];
    }

    get yesNoNAOptions() {
        return [
            {'label': 'Yes', 'value': 'Yes'},
            {'label': 'No', 'value': 'No'},
            {'label': 'N/A', 'value': 'N/A'}
        ];
    }

    get frequencyListOptions() {
        return [
            {'label': 'Never', 'value': 'Never'},
            {'label': 'Semi-annually', 'value': 'Semi-annually'},
            {'label': 'Annually', 'value': 'Annually'},
            {'label': 'Bi-annually or less', 'value': 'Bi-annually or less'}
        ];
    }
    
    connectedCallback() {
        this.urlHasParameters = this.validateUrlParameters();

        if (this.urlHasParameters) {   

            this.today = this.getTodaysDate();
            this.currentYear = this.getCurrentYear();
            this.isLoading = true;

            getPicklistValues({objectApiName : 'Contact', fieldName : 'MailingCountryCode'})
            .then((data) => {
                this.countryListOptions = this.convertAsLabelValueList(data);
            }).catch(error => {
                console.log('Error in connectedCallback() getPicklistValues');
                this.printError(error);  
            });

            getPicklistValues({objectApiName : 'Engagement__c', fieldName : 'Strategy__c'})
            .then((data) => {
                this.strategyListOptions = this.convertAsLabelValueList(data);
            }).catch(error => {
                console.log('Error in connectedCallback() getPicklistValues');
                this.printError(error);  
            });

            getFormSectionsAndFields({formId : this.formId})
            .then((data) => {
                this.formSectionAndFields = this.normalizeFieldsOnData(data);
                this.formFieldIdList = this.getFormFieldIdList(data);
            })
            .then(() => {
                getSubmittedAnswers({formFilingId : this.formFilingId})
                .then((data) => {
                    this.fillPrevSubmittedQuestions(data);
                    this.isLoading = false;
                })
                .catch(error => {
                    this.isLoading = false;
                    console.log('Error in connectedCallback() getSubmittedAnswers');
                    this.printError(error);       
                });
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error in connectedCallback() getFormSectionsAndFields');
                this.printError(error);       
            });

            getFormFilingEngagements({formFilingId : this.formFilingId})
            .then((data) => {
                this.fundNamesList = this.getListOfFundNames(data);
                this.isLoading = false;
            }).catch(error => {
                this.isLoading = false;
                console.log('Error in connectedCallback() getFormFilingEngagements');
                this.printError(error);       
            });           

        }       
          
    }

    getListOfFundNames(data) {
        let fundMap = new Map(Object.entries(data));
        let fundNamesList = [];

        for (let [key, value] of fundMap) {
            fundNamesList.push(value);
        }

        return fundNamesList;
    }

    validateUrlParameters() {
        let url = new URL(window.location.href);
        const urlParams = url.searchParams;
        let isValid = false;

        this.formFilingId = urlParams.get('c__id');
        this.formId = urlParams.get('c__formId');
        this.formName = urlParams.get('c__formName');
        this.contactName = urlParams.get('c__contactName');
        this.accountName = urlParams.get('c__accountName');
        this.formVersion = urlParams.get('c__formVersion');
        this.contactId = urlParams.get('c__contactId');
        this.reportingYear = urlParams.get('c__year');

        if (this.formFilingId && this.formId && this.formName && this.contactName && this.accountName && this.formVersion && this.contactId && this.reportingYear) {
            isValid = true;
            this.formName = urlParams.get('c__formName').replace('%20', ' ').replace('ampersand', '&');
            this.contactName = urlParams.get('c__contactName').replace('%20', ' ').replace('ampersand', '&');
            this.accountName = urlParams.get('c__accountName').replace('%20', ' ').replace('ampersand', '&');
        }

        return isValid;
    }

    saveQuestionnaireTotally() {
        let answerMap = this.getAnswersMap();
        let commentMap = this.getCommentsMap();

        if (this.validateInputs()) {

            let proceed = confirm("After proceeding, you will not be able to edit the answers provided. Do you want to save and finish?");
            if (proceed) {
                this.isLoading = true;
                saveSubmittedForm({formId : this.formId, formFilingId : this.formFilingId, answerMap : answerMap, commentMap : commentMap, isFormTotallyCompleted : true})
                .then(() => {
                    this.isLoading = false;
                    this.showToast('Success', 'All the information was saved successfully.', 'success');
                    window.location.href = '/clientportal/s/';
                })
                .catch(error => {
                    console.log('Error in saveQuestionnaireTotally() saveSubmittedForm (totally)');
                    this.printError(error);                   
                    this.isLoading = false;    
                });
            }

        } else {
            this.showToast('Error', 'Please fill in all the fields before proceeding, and complete the confirmation at the end of the form.', 'error');
        }
    }

    saveQuestionnairePartially() {
        this.isLoading = true;
        let answerMap = this.getAnswersMap();
        let commentMap = this.getCommentsMap();

        saveSubmittedForm({formId : this.formId, formFilingId : this.formFilingId, answerMap : answerMap, commentMap : commentMap, isFormTotallyCompleted : false})
        .then(() => {
            this.isLoading = false;
            this.showToast('Success', 'All the information was saved successfully.', 'success');
        })
        .catch(error => {
            console.log('Error in saveQuestionnairePartially() saveSubmittedForm (partially)');
            this.printError(error);  
            this.isLoading = false;     
        });

    }

    fillPrevSubmittedQuestions(data) {

        let filingDetailMap = new Map(Object.entries(data));
        let mapKeys = Array.from(filingDetailMap.keys());

        if (mapKeys.length > 0) {
            for (let i = 0; i < this.formFieldIdList.length; i++) {

                let currentId = this.formFieldIdList[i];

                if (filingDetailMap.has(currentId)) {

                    let formFilingDetail = filingDetailMap.get(currentId);
                    
                    let radioBtnSelector = '[data-inputid="' + currentId + '"]';
                    var radioBtnInput = this.template.querySelector(radioBtnSelector);

                    if (radioBtnInput) {

                        radioBtnInput.value = formFilingDetail.Value__c;

                        if (formFilingDetail.Value__c == 'Yes') {
                            this.showSecondaryQuestionsIfAny(currentId);
                        }

                    }                 
    
                    let textAreaSelector = '[data-commentfor="' + currentId + '"]';
                    var textAreaInput = this.template.querySelector(textAreaSelector);

                    if (textAreaInput) {
                        textAreaInput.value = formFilingDetail.AdditionalComments__c;
                    }

                }
                
            }

            let firstAnswerSubmitted = filingDetailMap.get(mapKeys[0]);
            if (firstAnswerSubmitted.Form_Filing__r.Is_Form_Completed__c) {
                this.setAllInputsAsDisabled();
            }
        }

        this.setEmptyInputsAsRequired();
        
    }

    setEmptyInputsAsRequired() {
        for (let i = 0; i < this.formFieldIdList.length; i++) {
            let selector = '[data-inputid="' + this.formFieldIdList[i] + '"]';
            let element = this.template.querySelector(selector);

            if (element) {
                let isSecondaryQuestion = element.hasAttribute('data-parent');
                if (!element.value && isSecondaryQuestion) {

                    let parentSelector = '[data-inputid="' + element.getAttribute('data-parent') + '"]';
                    let parentElement = this.template.querySelector(parentSelector);

                    if (parentElement.value == 'Yes') {
                        this.setAsRequired(this.formFieldIdList[i]);
                    }

                }
            }
        }
    }

    setAllInputsAsDisabled() {
        this.ifFormComplete = true;
        let confirmationCheckbox = this.template.querySelector('lightning-input[data-name="confirmation"]');
        confirmationCheckbox.checked = true;

        this.template.querySelectorAll('lightning-radio-group, lightning-input, lightning-textarea, lightning-button, lightning-combobox')
        .forEach((input) => {
            input.disabled = true;
        });
    }

    getAnswersMap() {
        let answerMap = new Map();
        for (let i = 0; i < this.formFieldIdList.length; i++) { 
            var currentId = this.formFieldIdList[i];
            var inputSelector = '[data-inputid="' + currentId + '"]';
            var input = this.template.querySelector(inputSelector);
            if (input) {
                answerMap[currentId] = input.value;
            }
        }
        return answerMap;
    }

    getCommentsMap() {
        let commentsMap = new Map();
        for (let i = 0; i < this.formFieldIdList.length; i++) { 
            var currentId = this.formFieldIdList[i];
            var inputSelector = '[data-commentfor="' + currentId + '"]';
            var input = this.template.querySelector(inputSelector);
            if (input) {
                commentsMap[currentId] = input.value;
            }
        }
        return commentsMap;
    }

    validateInputs() {
        const validationResult = [...this.template.querySelectorAll('lightning-radio-group, lightning-input, lightning-combobox, lightning-textarea')]
            .reduce((validSoFar, inputField) => {

                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();

            }, true);

        return validationResult;
    }

    normalizeFieldsOnData(data) {
        data.forEach(function(section) {
            section.Form_Fields1__r.forEach(function(formField) {

                if (formField.Mandatory_Rule__c == 'Mandatory') {
                    formField.IsMandatory = true;
                }

                if (formField.Mandatory_Related_Field__c == null) {
                    formField.isPrimaryQuestion = true;
                } else {
                    formField.isPrimaryQuestion = false;
                }

                if (formField.Type__c == 'Country List') {
                    formField.isCountryList = true;
                } else if (formField.Type__c == 'Large String') {
                    formField.isLargeString = true;
                } else if (formField.Type__c == 'Frequency List') {
                    formField.isFrequencyList = true;
                } else if (formField.Type__c == 'Yes/No') {
                    formField.isYesNo = true;
                } else if (formField.Type__c == 'Yes/No/NA') {
                    formField.isYesNoNA = true;
                } else if (formField.Type__c == 'Percentage') {
                    formField.isPercentage = true;
                } else if (formField.Type__c == 'Strategy List') {
                    formField.isStrategyList = true;
                }
                
                let parentFormFieldId = formField.Id;
                let secondaryQuestions = [];

                section.Form_Fields1__r.forEach(function(secondaryFormField) {
                    if (secondaryFormField.Mandatory_Related_Field__c == parentFormFieldId) {
                        secondaryQuestions.push(secondaryFormField);
                    }
                });
                
                formField.secondaryQuestions = secondaryQuestions;

                if (secondaryQuestions.length > 0) {
                    formField.hasSecondaryQuestions = true;
                }

            });
        });

        return data;
    }

    getFormFieldIdList(data) {
        let formFieldIdList = [];
        data.forEach(function(section) {
            section.Form_Fields1__r.forEach(function(formField) {
                formFieldIdList.push(formField.Id);
            });
        });
        return formFieldIdList;
    }

    printError(error) {
        console.log("Error stack", error.stack);
        console.log("Error name", error.name);
        console.log("Error message", error.message);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title, 
                message: message, 
                variant: variant
            })
        );
    }

    getTodaysDate() {
        var today = new Date();
        var dayOfMonth = String(today.getDate()).padStart(2, '0');
        var fullYear = today.getFullYear();
        var monthName = today.toLocaleString('default', { month: 'long' });
        var finalValue = monthName + ' ' + dayOfMonth + ', ' + fullYear;
        return finalValue;
    }

    getCurrentYear() {
        var today = new Date();
        var fullYear = today.getFullYear();
        return fullYear;
    }

    convertAsLabelValueList(data) {
        let resultList = [];
        data.forEach((item) => {
            let option = {label : item, value : item};
            resultList.push(option);
        });

        return resultList;
    }

    handleChangeYesNo(event) {
        let inputId = event.currentTarget.dataset.inputid;
        let value = event.detail.value;
        let secondaryQuestionsBlock = this.template.querySelector('[data-activatedby="' + inputId + '"]');

        if (value == 'Yes' && secondaryQuestionsBlock) {

            secondaryQuestionsBlock.className = secondaryQuestionsBlock.className.replace(/hidden/g, 'show');
            this.setRelatedQuestionsMandatory(inputId);
            
        } else if (value == 'No' && secondaryQuestionsBlock) {
            
            secondaryQuestionsBlock.className = secondaryQuestionsBlock.className.replace(/show/g, 'hidden');
            this.setRelatedQuestionsNotMandatory(inputId);
        }

    }

    setRelatedQuestionsMandatory(parentFormFieldId) {
        let relatedQuestionIds = this.getRelatedQuestions(parentFormFieldId);

        for (let i = 0; i < relatedQuestionIds.length; i++) {
            let selector = '[data-inputid="' + relatedQuestionIds[i] + '"]';
            var childQuestion = this.template.querySelector(selector);

            if (childQuestion) {
                if (!childQuestion.value) {
                    this.setAsRequired(relatedQuestionIds[i]);
                }
            }
        }
    }

    setRelatedQuestionsNotMandatory(parentFormFieldId) {
        let relatedQuestionIds = this.getRelatedQuestions(parentFormFieldId);

        for (let i = 0; i < relatedQuestionIds.length; i++) {
            let selector = '[data-inputid="' + relatedQuestionIds[i] + '"]';
            var childQuestion = this.template.querySelector(selector);
        
            this.setAsNotRequired(relatedQuestionIds[i]);
            childQuestion.value = undefined;            
        }
    }

    getRelatedQuestions(parentFormFieldId) {
        let relatedQuestionIds = [];

        this.formSectionAndFields.forEach(function(section) {
            section.Form_Fields1__r.forEach(function(formField) {

                if (formField.Id == parentFormFieldId) {

                    if (formField.hasSecondaryQuestions) {

                        formField.secondaryQuestions.forEach(function(element){
                            relatedQuestionIds.push(element.Id)
                        }); 

                    }

                }
                
            });
        });

        return relatedQuestionIds;
    }

    setAsRequired(formFieldId) {
        let selector = '[data-inputid="' + formFieldId + '"]';
        var element = this.template.querySelector(selector);
        
        if (!element.hasAttribute('required')) {
            element.setAttribute('required', 'required');
            element.setCustomValidity( "Complete this field." );
        }        
    }

    setAsRequiredAndReport(formFieldId) {
        let selector = '[data-inputid="' + formFieldId + '"]';
        var element = this.template.querySelector(selector);
        
        if (!element.hasAttribute('required')) {
            element.setAttribute('required', 'required');
            element.setCustomValidity( "Complete this field." );
            element.reportValidity();
        }        
    }

    setAsNotRequired(formFieldId) {
        let selector = '[data-inputid="' + formFieldId + '"]';
        var element = this.template.querySelector(selector);

        let tempBool = false;
        if (!element.value) {
            element.value = 'temp';
            tempBool = true;
        }

        if (element.hasAttribute('required')) {
            element.removeAttribute('required');
        }

        element.setCustomValidity('');
        element.reportValidity();        

        if (tempBool) {
            element.value = undefined;
        }        
    }

    reportValidityOf(formFieldId) {
        const validationResult = [...this.template.querySelectorAll('[data-inputid="' + formFieldId + '"]')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        return validationResult;
    }

    handleChangeRequired(event) {
        let inputId = event.currentTarget.dataset.inputid;
        let selector = '[data-inputid="' + inputId + '"]';
        var element = this.template.querySelector(selector);

        if (element) {
            if (element.value) {
                this.setAsNotRequired(inputId);
            } else {
                this.setAsRequiredAndReport(inputId);
            }
        }
        
        this.handleChangeYesNo(event);
    }

    showSecondaryQuestionsIfAny(parentFormFieldId) {
        let selector = '[data-activatedby="' + parentFormFieldId + '"]';
        var element = this.template.querySelector(selector);
        if (element) {
            element.className = element.className.replace(/hidden/g, 'show');
        }
    }

}