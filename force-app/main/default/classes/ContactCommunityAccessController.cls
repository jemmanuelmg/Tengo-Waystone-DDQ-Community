/**
 * @description       : 
 * @author            : emmanuel.martinez@tengo.co
 * @group             : 
 * @last modified on  : 10-22-2020
 * @last modified by  : emmanuel.martinez@tengo.co
 * Modifications Log 
 * Ver   Date         Author                       Modification
 * 1.0   10-22-2020   emmanuel.martinez@tengo.co   Initial Version
**/
public without sharing class ContactCommunityAccessController {

    @AuraEnabled(cacheable=true)
    public static Boolean isCommunityUser(String contactId) {

        Boolean result;
        List<User> userList = [SELECT ContactId FROM User WHERE ContactId = :contactId];

        if (userList.isEmpty()) {
            result = true;
        } else {
            result = false;
        }

        return result;

    }

}
