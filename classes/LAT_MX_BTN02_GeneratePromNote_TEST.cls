@isTest 

public with sharing class LAT_MX_BTN02_GeneratePromNote_TEST {
    @isTest 
    static void unitTest() {
        
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc1 = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'NME970625KP9',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        insert acc1;
        
        LAT_MX_PMN_PromissoryNote__c pagare = new LAT_MX_PMN_PromissoryNote__c(LAT_MX_Executor__c =acc1.id );
        insert pagare;
        
         LAT_MX_BTN02_GeneratePromNote.GeneratePromNote(string.valueof(pagare.id));
        
    }

}