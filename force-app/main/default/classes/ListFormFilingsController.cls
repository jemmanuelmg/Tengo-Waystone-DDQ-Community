/**
 * @description       : 
 * @author            : emmanuel.martinez@tengo.co
 * @group             : 
 * @last modified on  : 12-20-2020
 * @last modified by  : emmanuel.martinez@tengo.co
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-04-2020   emmanuel.martinez@tengo.co   Initial Version
**/
public without sharing class ListFormFilingsController {
    
    @AuraEnabled(cacheable=true)
    public static List<Form_Filing__c> getAvailableFormFilings(String statusOption, String yearOption) {

        Id userId = UserInfo.getUserId();
        User user  = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        
        String query = 'SELECT Name, Contact__c, Status__c, Contact__r.Name, Contact__r.Account.Name, Form__c, Form__r.Name, Form__r.Version_Number__c, Is_Form_Completed__c, CreatedDate, Completed_Date__c FROM Form_Filing__c WHERE Form__r.CommunityCloudPortal__c = true';

        if (user.ContactId != null) {
            query += ' AND Contact__c = \'' + user.ContactId + '\'';
        }
        
        if (statusOption != null && !statusOption.equals('All')) {
            query += ' AND Status__c = \'' + statusOption + '\'';
        }

        if (yearOption != null && !yearOption.equals('All')) {
            Date currentDate = System.today(); 
            Integer currentYear = currentDate.year();
            query += ' AND CALENDAR_YEAR(CreatedDate) = ' + currentYear;
        }

        query += ' ORDER BY Completed_Date__c DESC NULLS FIRST, Form__r.Name';

        List<Form_Filing__c> formFilingList = Database.query(query);

        return formFilingList;

    }
    
}