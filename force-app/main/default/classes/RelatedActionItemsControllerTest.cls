/**
 * @description       : 
 * @author            : emmanuel.martinez@tengo.co
 * @group             : 
 * @last modified on  : 12-21-2020
 * @last modified by  : emmanuel.martinez@tengo.co
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-21-2020   emmanuel.martinez@tengo.co   Initial Version
**/

@isTest
private with sharing class RelatedActionItemsControllerTest {
    
    @testSetup
    static void setup() {
        
        Account account1 = TestDataFactory.createAccount('Test Account');  
        List<Account> accountList = new List<Account>{account1};
        insert accountList;

        Contact contact1 = TestDataFactory.createContact('Thomson', account1);
        List<Contact> contactList = new List<Contact>{contact1};
        insert contactList;
        
        Engagement__c engagement1 = TestDataFactory.createEngagement('Test Engagement 1', account1);
        List<Engagement__c> engagementList = new List<Engagement__c>{engagement1};
        insert engagementList;
        
        ActionItem__c actionItem1 = new ActionItem__c();
        actionItem1.ActionType__c = 'Cayman Compliance';
        actionItem1.Name = 'Test Action Item 1';
        actionItem1.Description__c = 'Test description';
        List<ActionItem__c> actionItemList = new List<ActionItem__c>{actionItem1};
        insert actionItemList;

        EngagementActionItem__c engActionItem = new EngagementActionItem__c();
        engActionItem.Engagement__c = engagement1.Id;
        engActionItem.ActionItem__c = actionItem1.Id;
        engActionItem.Contact__c = contact1.Id;
        engActionItem.DueDate__c = Date.newInstance(2020, 12, 24);
        engActionItem.DaysBeforeReminder__c = 10;
        List<EngagementActionItem__c> engActionItemList = new List<EngagementActionItem__c>{engActionItem};
        insert engActionItemList;

    }

    @isTest
    static void testGetRelatedActionItems() {     
        
        Engagement__c engagement = [SELECT Id FROM Engagement__c WHERE Name__c = 'Test Engagement 1' LIMIT 1];

        Test.startTest();
            List<EngagementActionItem__c> engActionItemList = RelatedActionItemsController.getRelatedActionItems(engagement.Id);
        Test.stopTest();

        System.assertEquals(false, engActionItemList.isEmpty(), 'Expected to have a non-empty list of form filings returned');

    }

    @isTest
    static void testGetRelatedActionItemsNegative() {     
        
        Engagement__c engagement = [SELECT Id FROM Engagement__c WHERE Name__c = 'Test Engagement 1' LIMIT 1];
        List<EngagementActionItem__c> engActionItemList1 = [SELECT Id FROM EngagementActionItem__c];
        delete engActionItemList1;

        Test.startTest();
            List<EngagementActionItem__c> engActionItemList2 = RelatedActionItemsController.getRelatedActionItems(engagement.Id);
        Test.stopTest();

        System.assertEquals(true, engActionItemList2.isEmpty(), 'Expected to have an empty list of form filings returned');

    }

}
