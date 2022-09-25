/**
 * @description       : 
 * @author            : emmanuel.martinez@tengo.co
 * @group             : 
 * @last modified on  : 12-07-2020
 * @last modified by  : emmanuel.martinez@tengo.co
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-07-2020   emmanuel.martinez@tengo.co   Initial Version
**/
public without sharing class ClientPortalTACController {
    
    @AuraEnabled(cacheable=true)
    public static List<Terms_and_Conditions__c> getTermsAndConditions() {

        Id userId = UserInfo.getUserId();
        User user  = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];

        List<Terms_And_Conditions__c> termsAndConditions = [SELECT
                                                            Terms__c,         
                                                            Name 
                                                            FROM Terms_And_Conditions__c 
                                                            WHERE Name = 'CCS__c' 
                                                            AND Id NOT IN (SELECT Terms_And_Conditions__c FROM Terms_And_Conditions_Accepted__c WHERE Contact__c = :user.ContactId )];

        return termsAndConditions;

    }

    @AuraEnabled
    public static void saveAcceptedTermsAndConditions(String tacId, String tacText) {

        Id userId = UserInfo.getUserId();
        User user  = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];

        if (user.ContactId != null) {
            Terms_and_Conditions_Accepted__c tacAccepted = new Terms_and_Conditions_Accepted__c();
            tacAccepted.Contact__c = user.ContactId;
            tacAccepted.Terms_and_Conditions__c = tacId;
            tacAccepted.Terms__c = tacText;

            insert tacAccepted;
        }

    }

}
