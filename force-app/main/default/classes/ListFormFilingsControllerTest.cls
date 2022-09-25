/**
 * @description       : 
 * @author            : emmanuel.martinez@tengo.co
 * @group             : 
 * @last modified on  : 12-20-2020
 * @last modified by  : emmanuel.martinez@tengo.co
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-20-2020   emmanuel.martinez@tengo.co   Initial Version
**/
@isTest
private with sharing class ListFormFilingsControllerTest {    

    @isTest
    static void testGetAvailableFormFilings() {

        Test.startTest();
            List<Form_Filing__c> formFilingsList = ListFormFilingsController.getAvailableFormFilings(null, null);
        Test.stopTest();

        System.assertEquals(true, formFilingsList.isEmpty(), 'Expected to have an empty list of Form Filing records');
    }

    @isTest
    static void testGetAvailableFormFilingsWithParams() {

        Test.startTest();
            List<Form_Filing__c> formFilingsList = ListFormFilingsController.getAvailableFormFilings('Complete', 'Current Year');
        Test.stopTest();

        System.assertEquals(true, formFilingsList.isEmpty(), 'Expected to have an empty list of Form Filing records');
    }
}