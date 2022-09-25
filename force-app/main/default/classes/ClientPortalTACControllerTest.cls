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
@isTest
private class ClientPortalTACControllerTest {
    
    @testSetup
    static void setup() {

        Terms_and_Conditions__c tac1 = new Terms_and_Conditions__c();
        tac1.Terms__c = 'Test text';
        tac1.Name = 'CCS__c';
        insert tac1;

        Account account1 =  TestDataFactory.createAccount('Test Account 1');
        insert account1;

        Contact contact1 = TestDataFactory.createContact('Test Contact 1', account1);
        insert contact1;

        User user1 = TestDataFactory.createUser('Test User 1', 'DMS Client Portal User', false);
        user1.ContactId = contact1.Id;
        insert user1;

    }

    @isTest
    static void getTermsAndConditionsTest() {

        Test.startTest();
            List<Terms_and_Conditions__c> tacList = ClientPortalTACController.getTermsAndConditions();
        Test.stopTest();

        System.assertEquals(false, tacList.isEmpty(), 'Expected to receive a non-empty list of TAC records');

    }

    @isTest
    static void saveAcceptedTermsAndConditions() {

        Terms_and_Conditions__c tacRecord = [SELECT Id FROM Terms_and_Conditions__c LIMIT 1];

        User communityUser = [SELECT Id FROM User WHERE LastName = 'Test User 1'];

        Test.startTest();
            System.runAs(communityUser) {
                ClientPortalTACController.saveAcceptedTermsAndConditions(tacRecord.Id, 'TAC Text');
            }
        Test.stopTest();

        List<Terms_and_Conditions_Accepted__c> tacAcceptedList = [SELECT Id FROM Terms_and_Conditions_Accepted__c];

        System.assertEquals(false, tacAcceptedList.isEmpty(), 'Expected to receive a non-empty list of TAC records');

    }

}
