/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:12/05/2014    *
*******************************************************************************/

@istest
public with sharing class LAT_UpdateObjectsBatch_TEST{

    static testMethod void unitTest(){
    
        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
            CNPJ__c = '54651716001150',
            Name = 'testAccount',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Client_code_AN8__c = '123697',
            Billing_Country__c ='test'
        );
        insert acc;  
        
        test.startTest();
       
        Id batchInstanceId = Database.executeBatch(new LAT_UpdateObjectsBatch('SELECT Id FROM Account')); 
        
        test.stopTest();
        
    }
}