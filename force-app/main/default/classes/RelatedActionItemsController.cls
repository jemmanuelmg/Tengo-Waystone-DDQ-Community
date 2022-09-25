/**
 * @description       : 
 * @author            : emmanuel.martinez@tengo.co
 * @group             : 
 * @last modified on  : 12-16-2020
 * @last modified by  : emmanuel.martinez@tengo.co
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   12-16-2020   emmanuel.martinez@tengo.co   Initial Version
**/

public without sharing class RelatedActionItemsController {
    
    @AuraEnabled
    public static List<EngagementActionItem__c> getRelatedActionItems(Id engagementId) {      

        List<EngagementActionItem__c> engActionItems = [SELECT 
                                                        Name, 
                                                        ActionSubject__c,
                                                        DueDate__c,
                                                        DaysRemaining__c,
                                                        LastReminderSentOn__c,
                                                        Status__c
                                                        FROM EngagementActionItem__c 
                                                        WHERE Engagement__c = :engagementId
                                                        ORDER BY DaysRemaining__c ASC];                                         

        return engActionItems;

    }
    
}
