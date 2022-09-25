@isTest
private class ShowFormControllerTest {

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

        Form_Section__c formSection1 = TestDataFactory.createFormSection(form1, 'Section 1 Confirmations', 1);
        List<Form_Section__c> formSectionList = new List<Form_Section__c>{formSection1};
        insert formSectionList;

        Form_Field__c formField1 = TestDataFactory.createFormField(formSection1, 'Test question 1', 1.0, 'Yes/No');
        Form_Field__c formField2 = TestDataFactory.createFormField(formSection1, 'Test question 2', 2.0, 'Yes/No');
        Form_Field__c formField3 = TestDataFactory.createFormField(formSection1, 'Test question 3', 3.0, 'Yes/No');
        Form_Field__c formField4 = TestDataFactory.createFormField(formSection1, 'Test question 4 large string to test name of future Form Filing Detail...', 4.0, 'Yes/No');
        List<Form_Field__c> formFieldList = new List<Form_Field__c>{formField1, formField2, formField3, formField4};
        insert formFieldList;

        Form_Filing__c formFiling1 = TestDataFactory.createFormFiling(form1, engagement1, contact1);
        List<Form_Filing__c> formFilingList = new List<Form_Filing__c>{formFiling1};
        insert formFilingList;
        
        FormFilingEngagement__c formFilingEngagement = TestDataFactory.createFormFilingEngagement(engagement1, formFiling1);
        List<FormFilingEngagement__c> formFilingEngList = new List<FormFilingEngagement__c>{formFilingEngagement};
        insert formFilingEngList;      

        String testLongValue = '';
        for (Integer i; i < 32768; i++) {
            testLongValue = testLongValue + 'A';
        }
        
        Form_Filing_Detail__c formFilingDetail1 = TestDataFactory.createFormFilingDetail(formField1, 'Test answer 1', 'Yes', 'Test comment');
        Form_Filing_Detail__c formFilingDetail2 = TestDataFactory.createFormFilingDetail(formField2, 'Test answer 2', 'No', 'Test comment');
        List<Form_Filing_Detail__c> formFilingDetailList = new List<Form_Filing_Detail__c>{formFilingDetail1, formFilingDetail2};
        insert formFilingDetailList;

    }

    @isTest
    static void testSaveSubmittedFormAllAnswerAreNew() {

        List<Form_Field__c> formFieldList = [SELECT Id FROM Form_Field__c];
        Form__c form = [SELECT Id FROM Form__c WHERE name = 'Annual Delegate Confirmations - Investment Manager ("IM")'];
        Form_Filing__c formFiling = [SELECT Id FROM Form_Filing__c WHERE Form__c = :form.Id];
        
        Map<String, String> answerMap = new Map<String, String>();
        Map<String, String> commentMap = new Map<String, String>();

        for (Form_Field__c formField : formFieldList) {
            answerMap.put(formField.Id, 'Yes');
            commentMap.put(formField.Id, 'Test comment for this answer');
        }
        
        Test.startTest();
        	ShowFormController.SaveSubmittedForm(form.Id, formFiling.Id, answerMap, commentMap, false);
        Test.stopTest();
        
        List<Form_Filing_Detail__c> formFilingDetailList = [SELECT Id FROM Form_Filing_Detail__c WHERE Value__c != null];
        System.assertEquals(6, formFilingDetailList.size(), 'Expected to have 6 Form Filing Details after saving the questionnaire');

    }
    
    @isTest
    static void testSaveSubmittedFormExistingAnswers() {

        List<Form_Field__c> formFieldList = [SELECT Id FROM Form_Field__c];
        Form__c form = [SELECT Id FROM Form__c WHERE name = 'Annual Delegate Confirmations - Investment Manager ("IM")'];
        Form_Filing__c formFiling = [SELECT Id FROM Form_Filing__c WHERE Form__c = :form.Id];
        
        Form_Filing_Detail__c existingAnswer = new Form_Filing_Detail__c();
        existingAnswer.Form_Field__c = formFieldList[0].Id;
        existingAnswer.Form_Filing__c = formFiling.Id;
        existingAnswer.Value__c = 'Yes';
        insert existingAnswer;
        
        Map<String, String> answerMap = new Map<String, String>();
        Map<String, String> commentMap = new Map<String, String>();

        for (Form_Field__c formField : formFieldList) {
            answerMap.put(formField.Id, 'Yes');
            commentMap.put(formField.Id, 'Test comment for this answer');
        }
        
        Test.startTest();
        	ShowFormController.SaveSubmittedForm(form.Id, formFiling.Id, answerMap, commentMap, false);
        Test.stopTest();
        
        List<Form_Filing_Detail__c> formFilingDetailList = [SELECT Id FROM Form_Filing_Detail__c WHERE Value__c != null];
        System.assertEquals(6, formFilingDetailList.size(), 'Expected to have 6 Form Filing Details after saving the questionnaire');

    }
    
    @isTest
    static void testSaveSubmittedFormTotally() {

        List<Form_Field__c> formFieldList = [SELECT Id FROM Form_Field__c];
        Form__c form = [SELECT Id FROM Form__c WHERE name = 'Annual Delegate Confirmations - Investment Manager ("IM")'];
        Form_Filing__c formFiling = [SELECT Id FROM Form_Filing__c WHERE Form__c = :form.Id];
        
        Map<String, String> answerMap = new Map<String, String>();
        Map<String, String> commentMap = new Map<String, String>();

        for (Form_Field__c formField : formFieldList) {
            answerMap.put(formField.Id, 'Yes');
            commentMap.put(formField.Id, 'Test comment for this answer');
        }
        
        Test.startTest();
        	ShowFormController.SaveSubmittedForm(form.Id, formFiling.Id, answerMap, commentMap, true);
        Test.stopTest();
        
        Form_Filing__c resultFormFiling = [SELECT Id, Is_Form_Completed__c, Status__c, Completed_Date__c, SubmittedBy__c FROM Form_Filing__c WHERE Form__c = :form.Id];
        System.assertEquals(true, resultFormFiling.Is_Form_Completed__c, 'Expected to have a form filing marked as completed');
        System.assertEquals('Complete', resultFormFiling.Status__c, 'Expected to have a form filing with status as complete');
        System.assertEquals(false, resultFormFiling.Completed_Date__c == null, 'Expected to have a form filing with a non-null completed date');
        System.assertEquals(false, resultFormFiling.SubmittedBy__c == null, 'Expected to have a form filing with a non-null value in the \'Submitted By\' field');

    }
    
    @isTest
    static void testGetFormSectionsAndFields() {
		
		Form__c form = [SELECT Id FROM Form__c WHERE name = 'Annual Delegate Confirmations - Investment Manager ("IM")'];        
        Test.startTest();
        	List<Form_Section__c> formSectionList = ShowFormController.getFormSectionsAndFields(form.Id);
        Test.stopTest();
        
        System.assertEquals(1, formSectionList.size(), 'Expected to receive a list with 1 Form Section');
        
    }
    
    @isTest
    static void testGetSubmittedAnswersPositive() {
		
        List<Form_Field__c> formFieldList = [SELECT Id FROM Form_Field__c];
        Form__c form = [SELECT Id FROM Form__c WHERE name = 'Annual Delegate Confirmations - Investment Manager ("IM")'];
        Form_Filing__c formFiling = [SELECT Id FROM Form_Filing__c WHERE Form__c = :form.Id];
        
		Form_Filing_Detail__c existingAnswer = new Form_Filing_Detail__c();
        existingAnswer.Form_Field__c = formFieldList[0].Id;
        existingAnswer.Form_Filing__c = formFiling.Id;
        existingAnswer.Value__c = 'Yes';
        insert existingAnswer;
        
        Test.startTest();
        	Map<String, Form_Filing_Detail__c> existingAnswersMap = ShowFormController.getSubmittedAnswers(formFiling.Id);
        Test.stopTest();
        
        Integer answersAmount = existingAnswersMap.keySet().size();
        System.assertEquals(1, answersAmount, 'Expected to have one existing answer');
        
    }
    
    @isTest
    static void testGetSubmittedAnswersNegative() {
		
        Form__c form = [SELECT Id FROM Form__c WHERE Name = 'Annual Delegate Confirmations - Investment Manager ("IM")'];
        Form_Filing__c formFiling = [SELECT Id FROM Form_Filing__c WHERE Form__c = :form.Id];
                
        Test.startTest();
        	Map<String, Form_Filing_Detail__c> existingAnswersMap = ShowFormController.getSubmittedAnswers(formFiling.Id);
        Test.stopTest();
        
        Integer answersAmount = existingAnswersMap.keySet().size();
        System.assertEquals(0, answersAmount, 'Expected to have 0 existing answers');
        
    }
    
    @isTest
    static void testGetFormFilingEngagements() {
		
        Form__c form = [SELECT Id FROM Form__c WHERE name = 'Annual Delegate Confirmations - Investment Manager ("IM")'];
        Form_Filing__c formFiling = [SELECT Id FROM Form_Filing__c WHERE Form__c = :form.Id];
                
        Test.startTest();
        	Map<Id, String> engagementMap = ShowFormController.getFormFilingEngagements(formFiling.Id);
        Test.stopTest();
        
        Integer amountOfEngagements = engagementMap.keySet().size();
        System.assertEquals(1, amountOfEngagements, 'Expected to have 1 existing Form Filing Engagement record');
        
    }
    
    @isTest
    static void testGetPicklistValuesCountries() {
        
        Test.startTest();
        	List<String> returnedValues = ShowFormController.getPicklistValues('Contact', 'MailingCountryCode');
        Test.stopTest();
        
        System.assertEquals(returnedValues.isEmpty(), false, 'Expected to have a non empty list of countries returned');
        
    }
    
    @isTest
    static void testGetPicklistValuesStrategies() {
        
        Test.startTest();
        	List<String> returnedValues = ShowFormController.getPicklistValues('Engagement__c', 'Strategy__c');
        Test.stopTest();
        
        System.assertEquals(returnedValues.isEmpty(), false, 'Expected to have a non empty list of strategies returned');
        
    }
    
}