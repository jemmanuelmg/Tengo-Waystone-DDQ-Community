public without sharing class RelatedFormFilingsController {
    
    @AuraEnabled
    public static List<Form_Filing__c> getRelatedFormFilings(Id engagementId) {
        
        Map<Id, Form_Filing__c> formFilingMap1 = new Map<Id, Form_Filing__c>([SELECT 
                                                                            Id 
                                                                            FROM Form_Filing__c 
                                                                            WHERE Engagement__c = :engagementId]);

        Map<Id, Form_Filing__c> formFilingMap2 = new Map<Id, Form_Filing__c>([SELECT 
                                                                            Id
                                                                            FROM Form_Filing__c 
                                                                            WHERE Id IN 
                                                                            (SELECT FormFiling__c 
                                                                            FROM FormFilingEngagement__c 
                                                                            WHERE Engagement__c = :engagementId)
                                                                            AND Id NOT IN :formFilingMap1.keySet()]);
                                                                            
        List<Id> formFilingIdList = new List<Id>();
        formFilingIdList.addAll(formFilingMap1.keySet());
        formFilingIdList.addAll(formFilingMap2.keySet());

        List<Form_Filing__c> finalResultList = [SELECT 
                                                Name, 
                                                Form__r.Name, 
                                                Form__r.FormType__c,
                                                Is_Form_Completed__c, 
                                                Completed_Date__c, 
                                                CreatedDate,
                                                Status__c,
                                                Contact__r.Name
                                                FROM Form_Filing__c 
                                                WHERE Id IN :formFilingIdList
                                                ORDER BY CreatedDate DESC];                                         

        return finalResultList;

    }
    
}