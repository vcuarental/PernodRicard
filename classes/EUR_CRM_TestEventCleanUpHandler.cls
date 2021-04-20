@isTest
private class EUR_CRM_TestEventCleanUpHandler{

    private static EUR_CRM_Account__c account;
    
    public static void dataInsert(){

        account= EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'GB FS Indirect')[0];
        account.EUR_CRM_Sub_Channel__c = 'Field Sales';
        account.EUR_CRM_Status__c = 'Active';
        insert account; 
        
    }
    
    public static testMethod void testUpdateHandler(){
        dataInsert(); 
        test.startTest();
        account.EUR_CRM_Status__c = 'Inactive';
        update account;
        List<Event> events = [SELECT Id 
                FROM Event
                WHERE WhatId =: account.id
                AND StartDateTime>TODAY
                AND EUR_CRM_Route_Template_Item__c!=null
                AND EUR_CRM_Route_Template__c!=null ];
                
        system.assert(events.size() == 0);
        test.stopTest();
    }
    
    public static testMethod void testDeleteHandler(){
        dataInsert(); 
        test.startTest();
        delete account; 
        List<Event> events = [SELECT Id 
                FROM Event
                WHERE WhatId = :account.id
                AND StartDateTime>TODAY
                AND EUR_CRM_Route_Template_Item__c!=null
                AND EUR_CRM_Route_Template__c!=null ];
                
        system.assert(events.size() == 0); 
        test.stopTest();
    }
}