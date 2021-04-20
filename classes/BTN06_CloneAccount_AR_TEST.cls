/******************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                Date:22/03/2013     *
*******************************************************************************************/
@isTest
public with sharing class BTN06_CloneAccount_AR_TEST {
    @isTest (SeeAllData = true)   
    static void unitTest() {
    	
    	RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        
        Account acc = new Account(
    	RecordTypeId = recordOffTradeArg.Id,
        CNPJ__c = '20354266645',
        Name = 'testAccount',
        Type = 'Prospect_ARG',
        Corporate_Name__c = 'test',
        Channel_Type__c = 'Direto',
        Segmentation_Type_on_trade__c = 'Restaurant_ARG',
        Sub_Channel__c = 'Delicatessen',
        AddressLine1_AR__c= 'test',
        Shipping_Neighbourhood__c = 'test',
        Revenue_Neighbourhood__c = 'test',
        Billing_Neighbourhood__c ='test',
        Shipping_Country__c ='test',
        Revenue_Country__c ='test',
        Billing_Country__c ='test'
        );
        
        insert acc;
        
        BTN06_CloneAccount_AR.AccountClone(acc.id, 'P');
        
    }

}