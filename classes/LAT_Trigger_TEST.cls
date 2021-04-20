/******************************************************************************
*   Company:Valuenet    Developers:Waldemar Mayo       Date:23/10/2013        *
*******************************************************************************/

@isTest
public with sharing class LAT_Trigger_TEST {
    
    static testMethod void UnitTest(){
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        if(rtOffMX != null){
            Account acc = new Account(
                Name = 'TEST',
                AccountNumber = '1000', 
                Status__c = 'Novo cadastro',
                Type = 'Payer',
                Phone = '1-11-1111-1111',
                Fax = '11-1111-1111',
                Notes__c = 'TEST',
                AddressLine1_AR__c = 'TEST',
                CNPJ__c = 'LOZM701213E52',
                Corporate_Name__c = 'TEST',
                Channel__c = 'WS',
                Segmentation_Type_on_trade__c = 'MOP',
                RecordTypeId = rtOffMX
            );
            insert acc;
        }
    }
}