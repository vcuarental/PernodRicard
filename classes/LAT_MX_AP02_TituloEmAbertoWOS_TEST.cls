/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:10/12/2013    *
*******************************************************************************/

@istest
public with sharing class LAT_MX_AP02_TituloEmAbertoWOS_TEST {

    static testMethod void unitTest() {
               
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
            LAT_MX_FiscalEntityType__c = 'Individual',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade'),
            credit_line__c = 100000
        );
        
        insert acc;
        
        Titulos__c titulo = new Titulos__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('Titulos__c' + 'LAT_MX_TEA_Standard'),
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            valorSaldo__c = 10
        );
        
        test.startTest();
        
        try{
            insert titulo;
            delete titulo;
        }catch(exception e){}
        
        test.stopTest();    
    }
}