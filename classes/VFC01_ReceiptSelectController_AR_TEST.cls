/*******************************************************************************************
*   Company:Valuenet    Developer:   Tomás Etchegaray               Date:05/04/2013        *
*******************************************************************************************/
@isTest
public with sharing class VFC01_ReceiptSelectController_AR_TEST { 
    @testSetup static void setup() {
        AP01_Receipt_AR_TEST.createAccountAR();        
        AP01_Receipt_AR_TEST.createReceiptConfigs();
    }
    
    @isTest  
    static void unitTest() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        test.startTest();
        Titulos__c tit = new Titulos__c(
            Cliente__c = acc.id,
            Internal_id_pk__c= 'asd',
            codigoCia__c = '123',
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            dataEmissao__c = date.today(),
            ActualDeliveryDate_AR__c = date.today(),
            numeroDocumento__c = 123,
            observacoesTitulo__c = 'ASD',
            valorOriginalTitulo__c = 123,
            valorSaldo__c = 123,
            parcela__c = '123'
        );
         
         insert tit;
         
        //  ApexPages.standardController TestController = new ApexPages.standardController(acc.id);
        
        Apexpages.currentPage().getParameters().put('idAcc', acc.Id); 
        Apexpages.currentPage().getParameters().put('idArray', tit.Id);
        
        
        VFC01_ReceiptSelectController_AR TestController = new VFC01_ReceiptSelectController_AR();
        string record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'RCP_ReceiptGeneratedDepositDone_AR');
        TestController.value = record;
        TestController.doContinue();
        TestController.cancel();
        test.stopTest();
        
    }
    
    @isTest 
    static void unitTest2() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        test.startTest();
        Titulos__c tit = new Titulos__c(
            Cliente__c = acc.id,
            Internal_id_pk__c= 'asd',
            codigoCia__c = '123',
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            dataEmissao__c = date.today(),
            ActualDeliveryDate_AR__c = date.today(),
            numeroDocumento__c = 123,
            observacoesTitulo__c = 'ASD',
            valorOriginalTitulo__c = 123,
            valorSaldo__c = 123,
            parcela__c = '123',
            tipoDocumento__c = 'RU',
            PaymentID_AR__c = 12345
        );
         
        insert tit;
         
        //ApexPages.standardController TestController = new ApexPages.standardController(acc.id);
        
        Apexpages.currentPage().getParameters().put('idAcc', acc.Id); 
        Apexpages.currentPage().getParameters().put('idArray', tit.Id);
        
        
        VFC01_ReceiptSelectController_AR TestController = new VFC01_ReceiptSelectController_AR();
        string record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'RCP_ReceiptGeneratedDepositPending_AR');
        TestController.value = record;
        TestController.doContinue();
        
        
        TestController.decodeMessage('ENTITY_IS_LOCKED');
        TestController.decodeMessage('REQUIRED_FIELD_MISSING');
        TestController.decodeMessage('blahblahblah');
        TestController.cancel();
        /*
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'Receipt_withholding_certificates_AR');
        TestController.value = record;
        TestController.doContinue();
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'RCP_ReceiptGeneratedDepositDone_UY');
        TestController.value = record;
        TestController.doContinue();
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'RCP_ReceiptGeneratedDepositPending_UY');
        TestController.value = record;
        TestController.doContinue();
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'LAT_AR_RCP_ReceiptOfApplyingDocuments');
        TestController.value = record;
        TestController.doContinue();
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'LAT_AR_RCP_ReceiptValueGuarantee');
        TestController.value = record;
        TestController.doContinue();
*/
        test.stopTest();
    }

    @isTest 
    static void unitTest3() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        test.startTest();
        Titulos__c tit = new Titulos__c(
            Cliente__c = acc.id,
            Internal_id_pk__c= 'asd',
            codigoCia__c = '123',
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            dataEmissao__c = date.today(),
            ActualDeliveryDate_AR__c = date.today(),
            numeroDocumento__c = 123,
            observacoesTitulo__c = 'ASD',
            valorOriginalTitulo__c = 123,
            valorSaldo__c = 123,
            parcela__c = '123'
        );
         
        insert tit;
         
        //ApexPages.standardController TestController = new ApexPages.standardController(acc.id);
        
        Apexpages.currentPage().getParameters().put('idAcc', acc.Id); 
        Apexpages.currentPage().getParameters().put('idArray', tit.Id);
        
        
        VFC01_ReceiptSelectController_AR TestController = new VFC01_ReceiptSelectController_AR();
        string record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'RCP_ReceiptGeneratedDepositPending_AR');
        TestController.value = record;
        TestController.doContinue();
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'Receipt_withholding_certificates_AR');
        TestController.value = record;
        TestController.doContinue();
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'LAT_AR_RCP_ReceiptOfApplyingDocuments');
        TestController.value = record;
        TestController.doContinue();
        test.stopTest();
        record = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c'+'LAT_AR_RCP_ReceiptValueGuarantee');
        TestController.value = record;
        TestController.doContinue();
       
    }

}