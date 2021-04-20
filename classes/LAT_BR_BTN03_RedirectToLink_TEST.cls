/********************************************************************************
*  Company:Valuenet         Developer:Denis Aranda       Date:30/05/2013        *
********************************************************************************/
@isTest
public with sharing class LAT_BR_BTN03_RedirectToLink_TEST {
    
    static testMethod void UnitTest(){
        
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
        LAT_CS002_Links__c cs = new LAT_CS002_Links__c(
            LAT_OffTradeURL__c = 'google.com',
            LAT_OnTradeURL__c = 'google.com',
            Name = '23'
        );
        LAT_BR_BTN03_RedirectToLink.getsLink(acc.Id);
        
        insert cs;
        
        LAT_BR_BTN03_RedirectToLink.getsLink(acc.Id);
        
        acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
        update acc;
        
        LAT_BR_BTN03_RedirectToLink.getsLink(acc.Id);
        test.stopTest();
    }
    
    static testMethod void UnitTest2(){
        
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
        LAT_CS002_Links__c cs = new LAT_CS002_Links__c(
            Name = '23'
        );
        
        insert cs;
        LAT_BR_BTN03_RedirectToLink.getsLink(acc.Id);
        
        acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
        update acc;
        
        LAT_BR_BTN03_RedirectToLink.getsLink(acc.Id);
        test.stopTest();
    }
}