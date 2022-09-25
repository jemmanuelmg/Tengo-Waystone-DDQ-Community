/**
 * @description       : 
 * @author            : emmanuel.martinez@tengo.co
 * @group             : 
 * @last modified on  : 12-02-2020
 * @last modified by  : emmanuel.martinez@tengo.co
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-01-2020   emmanuel.martinez@tengo.co   Initial Version
**/
public without sharing class ShowFormController {
	
    @AuraEnabled
    public static List<Form_Section__c> getFormSectionsAndFields(Id formId) {

        List<Form_Section__c> formSectionList = [SELECT 
                                                 Name, 
                                                 Position_Order__c, 
                                                     (SELECT Name, 
                                                      Description__c, 
                                                      Position_Order__c, 
                                                      Type__c, 
                                                      Mandatory_Rule__c, 
                                                      Mandatory_Related_Field__c,
                                                      Mandatory_Related_Field_Value__c, 
                                                      Weighting__c, 
                                                      Weighting_Percent__c,
                                                      AddAdditionalComments__c 
                                                      FROM Form_Fields1__r 
                                                      ORDER BY Position_Order__c ASC) 
                                                 FROM Form_Section__c 
                                                 WHERE Form__c = :formId 
                                                 ORDER BY Position_Order__c ASC];
        return formSectionList;

    }

    @AuraEnabled
    public static void saveSubmittedForm(Id formId, Id formFilingId, Map<String, String> answerMap, Map<String, String> commentMap, Boolean isFormTotallyCompleted) {
        
        List<Form_Filing_Detail__c> detailListToUpsert = new List<Form_Filing_Detail__c>();
        List<Form_Filing_Detail__c> formFilingDetailList = [SELECT 
                                                            Name, 
                                                            Form_Field__c, 
                                                            Form_Filing__c, 
                                                            Value__c, 
                                                            Long_Value__c 
                                                            FROM Form_Filing_Detail__c 
                                                            WHERE Form_Filing__c = :formFilingId];
        
        Map<Id, Form_Field__c> formFieldMap = new Map<Id, Form_Field__c>([SELECT Name FROM Form_Field__c WHERE Form_Section__r.Form__c = :formId]);
        Map<String, Form_Filing_Detail__c> filingDetailMap = new Map<String, Form_Filing_Detail__c>();

        for (Form_Filing_Detail__c filingDetail : formFilingDetailList) {
            filingDetailMap.put(filingDetail.Form_Field__c, filingDetail);
        } 
        
        for (String questionId : answerMap.keySet()) {
            
            Form_Field__c formField = formFieldMap.get(questionId);
            
            if (filingDetailMap.containsKey(questionId)) {

                Form_Filing_Detail__c detail = filingDetailMap.get(questionId);
                
                String value = answerMap.get(questionId);
                if (value.length() > 255) {
                    detail.Value__c = null;
                    detail.Long_Value__c = value;
                } else {
                    detail.Value__c = value;
                    detail.Long_Value__c = null;
                }
                
                detail.AdditionalComments__c = commentMap.get(questionId);
                detailListToUpsert.add(detail);

            } else {
                
                Form_Filing_Detail__c detail = new Form_Filing_Detail__c();
                
                String formFilingName = 'Answer: ' + formField.Name;
                if (formFilingName.length() >= 80) {
                    formFilingName = formFilingName.left(77) + '...';
                }
                
                String value = answerMap.get(questionId);
                if (value.length() > 255) {
                    detail.Value__c = null;
                    detail.Long_Value__c = value;
                } else {
                    detail.Value__c = value;
                    detail.Long_Value__c = null;
                }
                
                detail.AdditionalComments__c = commentMap.get(questionId);
                detail.Form_Filing__c = formFilingId;
                detail.Form_Field__c = questionId;
                detail.Name = formFilingName;
                detailListToUpsert.add(detail);

            }

        } 

        if (!detailListToUpsert.isEmpty()) {
            upsert detailListToUpsert;
        }

        if (isFormTotallyCompleted) {
            Form_Filing__c formFiling = [SELECT Is_Form_Completed__c, SubmittedBy__c, Status__c, Completed_Date__c FROM Form_Filing__c WHERE Id = :formFilingId];
            formFiling.Is_Form_Completed__c = true;
            formFiling.SubmittedBy__c = UserInfo.getUserId();
            formFiling.Status__c = 'Complete';
            formFiling.Completed_Date__c = System.now().date();
            update formFiling;
        }

    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Form_Filing_Detail__c> getSubmittedAnswers(Id formFilingId) {

        List<Form_Filing_Detail__c> formFilingDetailList = [SELECT 
                                                            Name, 
                                                            Form_Field__c, 
                                                            Form_Filing__c, 
                                                            Form_Filing__r.Is_Form_Completed__c, 
                                                            Value__c, 
                                                            Long_Value__c,
                                                            AdditionalComments__c
                                                            FROM Form_Filing_Detail__c 
                                                            WHERE Form_Filing__c = :formFilingId];
                                                                   
        Map<String, Form_Filing_Detail__c> filingDetailMap = new Map<String, Form_Filing_Detail__c>();
        for (Form_Filing_Detail__c filingDetail : formFilingDetailList) {
            filingDetailMap.put(filingDetail.Form_Field__c, filingDetail);
        } 
        return filingDetailMap;

    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, String> getFormFilingEngagements(Id formFilingId) {

        Map<Id, String> idNameMap = new Map<Id, String>();
        Form_Filing__c formFiling = [SELECT Engagement__c, 
                                            Engagement__r.Name__c, 
                                            (SELECT Engagement__c, 
                                            Engagement__r.Name__c 
                                            FROM FormFilingEngagements__r) 
                                            FROM Form_Filing__c WHERE Id = :formFilingId]; 

        if (String.isNotBlank(formFiling.Engagement__c)) {
            idNameMap.put(formFiling.Engagement__c, formFiling.Engagement__r.Name__c);
        }

        for (FormFilingEngagement__c formFilEng : formFiling.FormFilingEngagements__r) {
            idNameMap.put(formFilEng.Engagement__c, formFilEng.Engagement__r.Name__c);
        }
        return idNameMap;

    }

    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectApiName, String fieldName) {

        List<String> resultList = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);
        Sobject objectName = targetType.newSObject();
        Schema.sObjectType objectType = objectName.getSObjectType(); 
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe(); 
        Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues(); 

        for (Schema.PicklistEntry entry : picklistValues) { 
            resultList.add(entry.getLabel());
        }		

        return resultList;

    }
    
}