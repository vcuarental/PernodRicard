/**********************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                                        *                                                                                      *
*   Date:01/10/2013     Descripcion: Clase test de la clase LAT_MX_BTN03_NewPromissoryNote                                        *
***********************************************************************************************************************************/

@isTest

public with sharing class LAT_MX_BTN03_NewPromissoryNote_TEST {
    static testmethod void unitTest1(){
        
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
                
        list<Account> listAccount = new list<Account>();
        
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
        
        LAT_MX_BTN03_NewPromissoryNote.CreateNewPromissoryNote(string.valueof(acc1.id));
        
        test.startTest();
        
        CS002_FIeldsIds__c cs002 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_Executor__c',
            Name = 'name',
            FieldId__c= '54386',
            ObjectApiName__c='LAT_MX_PMN_PromissoryNote__c'
        );
                
        insert cs002;
        
        LAT_MX_BTN03_NewPromissoryNote.CreateNewPromissoryNote(string.valueof(acc1.id));
        
        test.stopTest();       
    }

    static testmethod void unitTest2(){
        
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
                
        list<Account> listAccount = new list<Account>();
                
        test.startTest();
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'asd',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'df',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        insert acc;
        
        CS002_FIeldsIds__c cs002 = new CS002_FIeldsIds__c(
            FieldApiName__c='LAT_MX_Executor__c',
            Name = 'name',
            FieldId__c= '54386',
            ObjectApiName__c='LAT_MX_PMN_PromissoryNote__c'
        );
                
        insert cs002;
        
        LAT_MX_BTN03_NewPromissoryNote.CreateNewPromissoryNote(string.valueof(acc.id));
        
        test.stopTest();       
    }
    
    static testmethod void unitTest3(){
        LAT_MX_BTN03_NewPromissoryNote.CreateNewPromissoryNote('11111111111');
    }    
}