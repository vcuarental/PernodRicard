@isTest

public with sharing class LAT_MX_VFC01_GeneratePromNoteCtrl_TEST {
    
    static testmethod void unitest(){
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
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX,
            LAT_MX_FiscalEntityType__c = 'Company',
            CNPJ__c = 'NME970625KP9'
        );
        insert acc1;
        
        LAT_MX_PMN_PromissoryNote__c pagare = new LAT_MX_PMN_PromissoryNote__c(LAT_MX_Executor__c =acc1.id, LAT_MX_DueDate__c = date.today().addDays(20), LAT_MX_Amount__c = 121 );
        insert pagare;
        Apexpages.currentPage().getParameters().put('idPagare', pagare.Id);
        LAT_MX_VFC01_GeneratePromNoteCtrl testController = new LAT_MX_VFC01_GeneratePromNoteCtrl();

        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1239582,23);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1239582,3);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1,00);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1,1);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(111111000,00);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(111111000,31);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1000,00);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(100,00);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1000,90);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(90,1);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(90,8);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(90,00);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(90,23);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1000,1);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1001,0);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1001,4);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(1001,64);
        LAT_MX_VFC01_GeneratePromNoteCtrl.ConvertNumberToText(90,34);
        
    } 
}