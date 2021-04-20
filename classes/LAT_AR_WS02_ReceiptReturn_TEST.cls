/******************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck               Date:30/05/2014  *
*******************************************************************************************/
@istest
public with sharing class LAT_AR_WS02_ReceiptReturn_TEST {

    static testMethod void unitTest1(){
        
        Account acc = new Account(
            RecordTypeId =  Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
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
                
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Account_AR__c = acc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        insert receipt;      
        
        DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
            Amounttoapply_AR__c = 200,
            Internal_id_pk_AR__c = 'TEST',
            ReceiptNo_AR__c = receipt.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc;
               
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR'),
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Name = '333458',
            Bank_AR__c = '123',
             BranBranch_AR__c = '123'
        );
        insert value;
        
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ValueType_AR__c = 'TEST',
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;
        
        DPT_Deposit_ARG__c deposit = new DPT_Deposit_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 123,
            AccType_AR__c = 'Bank Account',
            Name = '2'
        );       
        insert deposit;    
        
        System.Test.startTest();
        
        LAT_AR_WS02_ReceiptReturn.ReceiptReturn receiptRet = new LAT_AR_WS02_ReceiptReturn.ReceiptReturn();
        receiptRet.idCRMrec = receipt.Id;
        receiptRet.returnCode = 0;
        
        LAT_AR_WS02_ReceiptReturn.DocumentType docRet = new LAT_AR_WS02_ReceiptReturn.DocumentType();
        docRet.idCRMdoc = doc.Id;
        docRet.DocAppliedinJDE = true;
        receiptRet.listDocs = new List<LAT_AR_WS02_ReceiptReturn.DocumentType>{docRet};
        
        LAT_AR_WS02_ReceiptReturn.ValueType valueRet = new LAT_AR_WS02_ReceiptReturn.ValueType();
        valueRet.idCRMval = value.Id;
        valueRet.ValueRecordedinJDE = true;
        receiptRet.listValues = new List<LAT_AR_WS02_ReceiptReturn.ValueType>{valueRet};
        
        LAT_AR_WS02_ReceiptReturn.TaxCertificateType taxRet = new LAT_AR_WS02_ReceiptReturn.TaxCertificateType();
        taxRet.idCRMtax = tax.Id;
        taxRet.WithhRecordedinJDE = true;
        receiptRet.listTaxCertificates = new List<LAT_AR_WS02_ReceiptReturn.TaxCertificateType>{taxRet};
        
        LAT_AR_WS02_ReceiptReturn.DepositType depRet = new LAT_AR_WS02_ReceiptReturn.DepositType();
        depRet.idCRMdep = deposit.Id;
        depRet.DepositRecordedJDE = true;
        depRet.RecNumberInterfaceOk = true;
        receiptRet.listDeposits = new List<LAT_AR_WS02_ReceiptReturn.DepositType>{depRet};        

        LAT_AR_WS02_ReceiptReturn.ReceiptReturn(receiptRet);
  
        System.Test.stopTest();
    }

    static testMethod void unitTest2(){

        Account acc = new Account(
            RecordTypeId =  Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
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
                
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Account_AR__c = acc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        insert receipt;      
        
        DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
            Amounttoapply_AR__c = 200,
            Internal_id_pk_AR__c = 'TEST',
            ReceiptNo_AR__c = receipt.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc;
               
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR'),
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Name = '333458',
            Bank_AR__c = '123',
             BranBranch_AR__c = '123'
        );
        insert value;
        
        TXC_TaxCertificates_ARG__c tax = new TXC_TaxCertificates_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ValueType_AR__c = 'TEST',
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax;
        
        DPT_Deposit_ARG__c deposit = new DPT_Deposit_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 123,
            AccType_AR__c = 'Bank Account',
            Name = '2'
        );       
        insert deposit;    
        
        System.Test.startTest();
        
        LAT_AR_WS02_ReceiptReturn.ReceiptReturn receiptRet = new LAT_AR_WS02_ReceiptReturn.ReceiptReturn();
        receiptRet.idCRMrec = 'AAAAAAAAAAAAAAA';
        receiptRet.returnCode = 0;
        
        LAT_AR_WS02_ReceiptReturn.DocumentType docRet = new LAT_AR_WS02_ReceiptReturn.DocumentType();
        docRet.idCRMdoc = doc.Id;
        docRet.DocAppliedinJDE = true;
        receiptRet.listDocs = new List<LAT_AR_WS02_ReceiptReturn.DocumentType>{docRet};
        
        LAT_AR_WS02_ReceiptReturn.ValueType valueRet = new LAT_AR_WS02_ReceiptReturn.ValueType();
        valueRet.idCRMval = value.Id;
        valueRet.ValueRecordedinJDE = true;
        receiptRet.listValues = new List<LAT_AR_WS02_ReceiptReturn.ValueType>{valueRet};
        
        LAT_AR_WS02_ReceiptReturn.TaxCertificateType taxRet = new LAT_AR_WS02_ReceiptReturn.TaxCertificateType();
        taxRet.idCRMtax = tax.Id;
        taxRet.WithhRecordedinJDE = true;
        receiptRet.listTaxCertificates = new List<LAT_AR_WS02_ReceiptReturn.TaxCertificateType>{taxRet};
        
        LAT_AR_WS02_ReceiptReturn.DepositType depRet = new LAT_AR_WS02_ReceiptReturn.DepositType();
        depRet.idCRMdep = deposit.Id;
        depRet.DepositRecordedJDE = true;
        depRet.RecNumberInterfaceOk = true;
        receiptRet.listDeposits = new List<LAT_AR_WS02_ReceiptReturn.DepositType>{depRet};        

        LAT_AR_WS02_ReceiptReturn.ReceiptReturn(receiptRet);
    }
   
}