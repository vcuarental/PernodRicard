/********************************************************************************
*  Company:Valuenet     Developer:Elena Schwarzböck      Date:04/04/2013        *
********************************************************************************/
@isTest
public with sharing class  AP01_Document_AR_TEST {
@isTest
    static void unitTest() {
        system.Test.startTest();


        RecordType rec = new RecordType(
        DeveloperName = 'DCM_Standard_AR',
        Name = 'DCM_Standard_AR', 
        SobjectType='DCM_Documents_ARG__c');
        
        RecordType record = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'DCM_Standard_AR'];
        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        
        Account acc = new Account(
        RecordTypeId = recordOffTradeArg.Id,
        CNPJ__c = '20354266645',
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
        Billing_Country__c ='test'
        );
        insert acc;
        
        list<RCP_Receipt_ARG__c> receiptList = new list<RCP_Receipt_ARG__c>();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
        Account_AR__c = acc.id,
        Status_Ar__c = 'Receipt Issued Deposit done'
        //Name = 'TEST'
        );
        receiptList.add(receipt);
        
        RCP_Receipt_ARG__c receipt2 = new RCP_Receipt_ARG__c(
        Account_AR__c = acc.id
        //Name = 'TEST'
        );
        receiptList.add(receipt2);
        
        insert receiptList;
      

        system.Test.stopTest();
        list<Titulos__c> tittList = new list<Titulos__c>();
        
        Titulos__c titulo = new Titulos__c(
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
        Ruinusebypendingreceipt_AR__c = receipt.id,
        valorSaldo__c = 10
        );
        tittList.add(titulo);
          
        Titulos__c titulo2 = new Titulos__c(
        NetSRReceipts_AR__c = 200,
        Internal_id_pk__c = 'TEST2',
        Cliente__c = acc.id,
        codigoCia__c = 'TEST2',
        dataEmissao__c = date.today(),
        dataVencimentoAtual__c = date.today(),
        dataVencimentoOriginal__c = date.today(),
        numeroDocumento__c = 1,
        parcela__c = 'T2',
        valorOriginalTitulo__c = 10,
        Ruinusebypendingreceipt_AR__c = receipt2.id,
        valorSaldo__c = 10
        );
      
        tittList.add(titulo2);
        
        insert tittList;
        
        String documentsArgRtId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR');
        list<DCM_Documents_ARG__c> docList = new list<DCM_Documents_ARG__c>();
      
        DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
        Amounttoapply_AR__c = 200,
        Internal_id_pk_AR__c = 'TEST',
        ReceiptNo_AR__c = receipt.id,
        RecordTypeId = documentsArgRtId 
        );
        docList.add(doc);
        
        DCM_Documents_ARG__c doc1 = new DCM_Documents_ARG__c(
        Amounttoapply_AR__c = 200,
        Internal_id_pk_AR__c = 'TEST2',
        ReceiptNo_AR__c = receipt.id,
        RecordTypeId = documentsArgRtId 
        );
        docList.add(doc1);
         
        insert docList;
        docList[0].Amounttoapply_AR__c = 98;
        update docList;
        delete docList;
        
    }
}