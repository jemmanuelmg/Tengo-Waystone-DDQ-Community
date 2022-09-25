@isTest
private with sharing class RelatedFormFilingsControllerTest {
    
    @testSetup
    static void setup() {
        
        Account account1 = TestDataFactory.createAccount('Test Account');  
        List<Account> accountList = new List<Account>{account1};
        insert accountList;
        
        Engagement__c engagement1 = TestDataFactory.createEngagement('Test Engagement 1', account1);
        List<Engagement__c> engagementList = new List<Engagement__c>{engagement1};
        insert engagementList;

        Contact contact1 = TestDataFactory.createContact('Thomson', account1);
        List<Contact> contactList = new List<Contact>{contact1};
        insert contactList;

        Form__c form1 = TestDataFactory.createForm('Annual Delegate Confirmations - Investment Manager ("IM")', 1, 'DDQ Europe');
        List<Form__c> formList = new List<Form__c>{form1};
        insert formList;

        Form_Filing__c formFiling1 = TestDataFactory.createFormFiling(form1, engagement1, contact1);
        List<Form_Filing__c> formFilingList = new List<Form_Filing__c>{formFiling1};
        insert formFilingList;
        
        FormFilingEngagement__c formFilingEngagement = TestDataFactory.createFormFilingEngagement(engagement1, formFiling1);
        List<FormFilingEngagement__c> formFilingEngList = new List<FormFilingEngagement__c>{formFilingEngagement};
        insert formFilingEngList;      

    }

    @isTest
    static void testGetRelatedFormFilingsPositive() {     
        
        Engagement__c engagement = [SELECT Id FROM Engagement__c WHERE Name__c = 'Test Engagement 1' LIMIT 1];

        Test.startTest();
            List<Form_Filing__c> formFilingList = RelatedFormFilingsController.getRelatedFormFilings(engagement.Id);
        Test.stopTest();

        System.assert(!formFilingList.isEmpty(), 'Expected to have a non-empty list of form filings returned');
        System.assertEquals(1, formFilingList.size(), 'Expected to have only one form filing returned');

    }

    @isTest
    static void testGetRelatedFormFilingsNegative() {     
        
        Engagement__c engagement = [SELECT Id FROM Engagement__c WHERE Name__c = 'Test Engagement 1' LIMIT 1];
        List<Form_Filing__c> formFilingList = [SELECT Id FROM Form_Filing__c];
        delete formFilingList;

        Test.startTest();
            List<Form_Filing__c> formFilingList1 = RelatedFormFilingsController.getRelatedFormFilings(engagement.Id);
        Test.stopTest();

        System.assert(formFilingList1.isEmpty(), 'Expected to have an empty list of form filings returned');

    }

}