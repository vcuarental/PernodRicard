/********************************************************************************** 
* Company:Valuenet           Developer:Elena Schwarzböck          Date:17/04/2013 * 
***********************************************************************************/ 

@istest
public with sharing class VFC02_PrintReceiptController_AR_TEST{

    static testMethod void unitTest1(){

        Account acc = new Account(
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG'),
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
        
        RCP_Receipt_ARG__c receipt1 = new RCP_Receipt_ARG__c(
            CollectionAgent_AR__c = 'TEST',
            AN8_AR__c = 'TEST',
            Downpayments_AR__c = 100,
            Discount_AR__c = 100,
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 100,
            Account_AR__c = acc.id,
            date_AR__c = date.newinstance(1960, 2, 1),
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        insert receipt1; 
        Test.startTest();
        VLS_Values_ARG__c val1 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ValueType_AR__c = 'E',
            Bank_AR__c = 'Ban',
            BranBranch_AR__c = 'bra',
            ReceiptNo_AR__c = receipt1.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        insert val1;
        /*
        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            Name = 'asds',
            Amount_AR__c = 121,
            AccType_AR__c = 'Bank Account',
            ReceiptNo_AR__c = receipt1.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        insert dep;
        */
        DCM_Documents_ARG__c doc1= new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            ReceiptNo_AR__c = receipt1.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc1;
        
        TXC_TaxCertificates_ARG__c tax1 = new TXC_TaxCertificates_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ValueType_AR__c = 'TEST',
            ReceiptNo_AR__c = receipt1.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax1;  
        
        Apexpages.currentPage().getParameters().put('IdRec', receipt1.Id);

        VFC02_PrintReceiptController_AR TestExtensionPrintReceiptController = new VFC02_PrintReceiptController_AR();
        
        RCP_Receipt_ARG__c receipt2 = new RCP_Receipt_ARG__c(
            CollectionAgent_AR__c = 'TEST',
            AN8_AR__c = 'TEST',
            //Debits_AR__c = 100,
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 100,
            Account_AR__c = acc.id,
            date_AR__c = date.newinstance(1960, 12, 11),
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        insert receipt2; 
        
        VLS_Values_ARG__c val2 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ValueType_AR__c = 'E',
            Bank_AR__c = 'Ban',
            BranBranch_AR__c = 'bra',
            ReceiptNo_AR__c = receipt2.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        insert val2;
        
        DCM_Documents_ARG__c doc2= new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            Amounttoapply_AR__c = 100,
            ReceiptNo_AR__c = receipt2.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc2;
        
        DCM_Documents_ARG__c doc3= new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '01',
            Amounttoapply_AR__c = 50,
            Name = 'TEST',
            ReceiptNo_AR__c = receipt2.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc3;
        
        TXC_TaxCertificates_ARG__c tax2 = new TXC_TaxCertificates_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ValueType_AR__c = 'TEST',
            ReceiptNo_AR__c = receipt2.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('TXC_TaxCertificates_ARG__c' + 'TXC_Standard_AR')
        );
        insert tax2;  
        
        Apexpages.currentPage().getParameters().put('IdRec', receipt2.Id);

        VFC02_PrintReceiptController_AR TestExtensionPrintReceiptController2 = new VFC02_PrintReceiptController_AR();
        
        Test.stopTest();
    }
}