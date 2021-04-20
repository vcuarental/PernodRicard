/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/
@isTest
    
public with sharing class LAT_VFC01_02_VisRecHoursController_TEST {
    
    static testMethod void unitTest(){
        
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG');
            
        Account acc = new Account(
            CNPJ__c = '30500008454',
            Name = 'testAccount123',
            Overdue__c = true,
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test92569',
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c = 'test0',
            Shipping_Neighbourhood__c = 'test3',
            Revenue_Neighbourhood__c = 'test2',
            Billing_Neighbourhood__c ='test1',
            Shipping_Country__c ='test4',
            Revenue_Country__c ='test5',
            Billing_Country__c ='test8',
            Status__c = 'Em aprovação - Financeiro',
            RecordTypeId = rtOffMX,
            Client_code_AN8__c = '0'
        );
        insert acc;   
        
        ApexPages.StandardController controller = new ApexPages.StandardController(acc);
        LAT_VFC01_02_VisRecHoursController visHours = new LAT_VFC01_02_VisRecHoursController(controller);
    }
}