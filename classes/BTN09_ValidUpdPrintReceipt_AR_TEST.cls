/********************************************************************************
*  Company:Valuenet     Developer:Elena Schwarzböck      Date:16/04/2013        *
********************************************************************************/
@istest
public with sharing class BTN09_ValidUpdPrintReceipt_AR_TEST{

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
        
        system.Test.startTest();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 100,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        insert receipt;
        
        list<VLS_Values_ARG__c> listval = new list<VLS_Values_ARG__c>();
        
        VLS_Values_ARG__c val1 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Bank_AR__c = '1',
            BranBranch_AR__c = '1',
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        listval.add(val1);
        
        VLS_Values_ARG__c val2 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Bank_AR__c = '1',
            BranBranch_AR__c = '1',
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
            
        listval.add(val2);
           
        system.debug('3333 ' + listval);
        insert listval;
        
        DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc;
        
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt (receipt.id);
        
        system.Test.stopTest();
        
    }
    
    static testMethod void unitTest2(){
               
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
        
        system.Test.startTest();

        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 100,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositPending_AR')
        );
        insert receipt;
        
        list<DPT_Deposit_ARG__c> listdep = new list<DPT_Deposit_ARG__c>();
        
        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );        
        listdep.add(dep);
        
        DPT_Deposit_ARG__c dep2 = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );       
        listdep.add(dep2);
            
        insert listdep; 
              
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt (receipt.id);
        
        system.Test.stopTest();
        
    }
    
    static testMethod void unitTest3(){
               
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
        
        system.Test.startTest();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 100,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'Receipt_withholding_certificates_AR')
        );
        insert receipt;
        
        VLS_Values_ARG__c val = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Bank_AR__c = '1',
            BranBranch_AR__c = '1',
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        insert val;

        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        insert dep;                         
        
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt (receipt.id);
        
        system.Test.stopTest();
        
    }
    
    static testMethod void unitTest4(){
               
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
        
        system.Test.startTest();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 0,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        insert receipt;
        
        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        insert dep; 
        
        VLS_Values_ARG__c val1 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            Deposit_AR__c = dep.id,
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Bank_AR__c = '1',
            BranBranch_AR__c = '1',
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        insert val1;
        
        VLS_Values_ARG__c val2 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            Deposit_AR__c = dep.id,
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Bank_AR__c = '1',
            BranBranch_AR__c = '1',
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        insert val2;
        
        DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = '00',
            Name = 'TEST',
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc;
        DCM_Documents_ARG__c doc2 = new DCM_Documents_ARG__c(
            tipoDocumento_AR__c = 'FA',
            Name = 'TEST',
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc2;
                
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt (receipt.id);
        
        system.Test.stopTest();
        
    }
    
    static testMethod void unitTest5(){
               
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
        
        system.Test.startTest();

        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 0,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositPending_AR')
        );
        insert receipt;
        
        DPT_Deposit_ARG__c dep1 = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 1,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        insert dep1; 
        
        DPT_Deposit_ARG__c dep2 = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 1,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        insert dep2; 
                
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt (receipt.id);
        
        system.Test.stopTest();
        
    }
    
    static testMethod void unitTest6(){
               
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
        
        system.Test.startTest();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 0,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'Receipt_withholding_certificates_AR')
        );
        insert receipt;
                
        VLS_Values_ARG__c val = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 1,
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Bank_AR__c = '1',
            BranBranch_AR__c = '1',
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        insert val;
        
        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 1,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        insert dep;                         
        
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt(receipt.id);

        system.Test.stopTest();
        
    }
    
    static testMethod void unitTest7(){
               
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
        
        system.Test.startTest();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 0,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'LAT_AR_RCP_ReceiptValueGuarantee'),
            Discount_AR__c = 3
        );
        insert receipt;
                
        VLS_Values_ARG__c val = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 1,
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Bank_AR__c = '1',
            BranBranch_AR__c = '1',
            RecordtypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR')
        );
        insert val;
        
        DPT_Deposit_ARG__c dep = new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 1,
            ReceiptNo_AR__c = receipt.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR')
        );
        insert dep;                         
        
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt(receipt.id);

        system.Test.stopTest();
        
    }
    
    static testMethod void unitTest8(){
               
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
        
        system.Test.startTest();
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 0,
            Account_AR__c = acc.id,
            RecordtypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + 'RCP_ReceiptGeneratedDepositDone_AR')
        );
        insert receipt;                        
        
        BTN09_ValidUpdPrintReceipt_AR.ValidUpdPrintReceipt(receipt.id);

        system.Test.stopTest();
        
    }
}