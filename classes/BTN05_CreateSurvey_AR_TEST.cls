/******************************************************************************************
*   Company:Valuenet    Developers:   Tomás Etchegaray                Date:21/03/2013     *
*******************************************************************************************/
@isTest
public with sharing class BTN05_CreateSurvey_AR_TEST {


@isTest    
    static void unitTest() {
        system.Test.startTest();

   //     RecordType record = [select id, DeveloperName from RecordType where DeveloperName = 'SRV_1_Bar_AR'];
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

        system.Test.stopTest();
        
        CS002_FIeldsIds__c cs002 = new CS002_FIeldsIds__c(
        FieldApiName__c='AccountName_AR__c',
        Name = 'name',
        FieldId__c= '54386',
        ObjectApiName__c='SRV_Survey_ARG__c');
         
        
        insert cs002;
        
        BTN05_CreateSurvey_AR.CreateSurvey(acc.id);
        
    }
}