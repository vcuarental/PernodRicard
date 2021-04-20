/****************************************************
 Dev: Waldemar Mayo  Version: 1  Consulting: Valuenet
****************************************************/

@IsTest
public with sharing class PCS01_AnalyticsOfCCBatch_AR_TEST {

    static testMethod void UnitTest(){
        system.Test.startTest();
        Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp');
       // insert acco;
        try{insert acco;}catch(Exception e){}
        
        RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id);
        //insert recibo;
        try{insert recibo;}catch(Exception e){}
        
        DCM_Documents_ARG__c document = new DCM_Documents_ARG__c(Name = 'asd', Internal_id_pk_AR__c = 'aaa1' , ReceiptNo_AR__c = recibo.id, NetCRMReceipts_AR__c = 1000, Amounttoapply_AR__c = 200 );
        //insert document;
        
        DCM_Documents_ARG__c document1 = new DCM_Documents_ARG__c(Name = 'ads', Internal_id_pk_AR__c = 'aaa2' , ReceiptNo_AR__c = recibo.id, NetCRMReceipts_AR__c = 1000, Amounttoapply_AR__c = 300 );
        //insert document1;
        
        //insert new List<DCM_Documents_ARG__c>{document, document1};
        try{insert new List<DCM_Documents_ARG__c>{document, document1};}catch(Exception e){}
        
        RCP_Receipt_ARG__c recibo1 = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id);
        //insert recibo1;
        try{insert recibo1;}catch(Exception e){}
        
        DCM_Documents_ARG__c document3 = new DCM_Documents_ARG__c(Name = 'asd1', Internal_id_pk_AR__c = 'aaa1' , ReceiptNo_AR__c = recibo1.id, NetCRMReceipts_AR__c = 1000, Amounttoapply_AR__c = 300 );
        //insert document3;
        
        
        DCM_Documents_ARG__c document4 = new DCM_Documents_ARG__c(Name = 'ads1', Internal_id_pk_AR__c = 'aaa2' , ReceiptNo_AR__c = recibo1.id, NetCRMReceipts_AR__c = 1000, Amounttoapply_AR__c = 200 );
        //insert document4;
        
        insert new List<DCM_Documents_ARG__c>{document3, document4};
        system.Test.stopTest();
        
        Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', NetSRReceipts_AR__c = 1000, numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'aaa1', OrderNumber_AR__c = 1, Cliente__c = acco.id );  
        //insert titulo;
        
        Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', NetSRReceipts_AR__c = 600, numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'aaa2', OrderNumber_AR__c = 2, Cliente__c = acco.id );  
        //insert titulo1;
       // insert new List<Titulos__c>{titulo, titulo1};
        try{insert new List<Titulos__c>{titulo, titulo1};}catch(Exception e){}
        
        PCS01_AnalyticsOfCCBatch_AR batch = new PCS01_AnalyticsOfCCBatch_AR();
        Database.executeBatch(batch);
    }
    
    static testMethod void UnitTest1(){
        
        Account acco = new Account(Name='TEST', Corporate_Name__c = 'Target Corp');
        //insert acco;
        try{  insert acco;}catch(Exception e){}
        
        RCP_Receipt_ARG__c recibo = new RCP_Receipt_ARG__c(Account_AR__c = acco.Id);
        //insert recibo;
        try{insert recibo;}catch(Exception e){}
        
        Titulos__c titulo = new Titulos__c (codigoCia__c = 'Targe', NetSRReceipts_AR__c = 1000, numeroDocumento__c = 12345678, parcela__c = 'tea', valorSaldo__c = 1230.54, valorOriginalTitulo__c = 500, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'aaa1', OrderNumber_AR__c = 1, Cliente__c = acco.id );  
        //insert titulo;
        
        Titulos__c titulo1 = new Titulos__c (codigoCia__c = 'Targ', NetSRReceipts_AR__c = 600, numeroDocumento__c = 12345679, parcela__c = 'tee', valorSaldo__c = 1230.55, valorOriginalTitulo__c = 501, dataEmissao__c = date.today(), dataVencimentoAtual__c = date.today().addMonths(3), dataVencimentoOriginal__c = date.today().addMonths(2), Internal_id_pk__c = 'aaa2', OrderNumber_AR__c = 2, Cliente__c = acco.id );  
        //insert titulo1;
        //insert new List<Titulos__c>{titulo, titulo1};
        try{ insert new List<Titulos__c>{titulo, titulo1};}catch(Exception e){}
        
        PCS01_AnalyticsOfCCBatch_AR batch = new PCS01_AnalyticsOfCCBatch_AR();
        Database.executeBatch(batch);        
    }
    
    static testMethod void UnitTest2(){

        RecordType record = [select id, DeveloperName from RecordType where DeveloperName = 'ACC_1_OffTrade_ARG'];
      
        Account acc = new Account(
            CNPJ__c = '20354266645',
            Name = 'testAccount',
            Type = 'Prospect_ARG',
            Corporate_Name__c = 'test',
            RecordTypeId = record.Id, 
            Channel_Type__c = 'Direto',
            Sub_Channel__c = 'Delicatessen',
            AddressLine1_AR__c= 'test',
            Shipping_Neighbourhood__c = 'test',
            Revenue_Neighbourhood__c = 'test',
            Billing_Neighbourhood__c ='test',
            Shipping_Country__c ='test',
            Revenue_Country__c ='test',
            Overdue__c = false,
            Billing_Country__c ='test'
        );
        // insert acc;
        try{insert acc;}catch(Exception e){}
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Account_AR__c = acc.id
        );
        try{insert receipt;}catch(Exception e){}
        
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Titulos__c' AND DeveloperName = 'Standard_AR'];

        Titulos__c titulo = new Titulos__c(
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST1',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            Ruinusebypendingreceipt_AR__c = receipt.id,
            Status__c = false,
            RecordTypeId = rt.id,
            valorSaldo__c = 10
        );
        //insert titulo;    
        
        Titulos__c titulo2 = new Titulos__c(
            NetSRReceipts_AR__c = 200,
            Internal_id_pk__c = 'TEST2',
            Cliente__c = acc.id,
            codigoCia__c = 'TEST',
            dataEmissao__c = date.today(),
            dataVencimentoAtual__c = date.today(),
            dataVencimentoOriginal__c = date.today(),
            numeroDocumento__c = 1,
            parcela__c = 'T',
            valorOriginalTitulo__c = 10,
            Ruinusebypendingreceipt_AR__c = receipt.id,
            Status__c = true,
            RecordTypeId = rt.id,
            valorSaldo__c = 10
        );
        //insert titulo2;  
        
        //insert new List<Titulos__c>{titulo, titulo2};
        try{insert new List<Titulos__c>{titulo, titulo2};}catch(Exception e){}
        
        PCS01_AnalyticsOfCCBatch_AR batch = new PCS01_AnalyticsOfCCBatch_AR();
        Database.executeBatch(batch);
    }
}