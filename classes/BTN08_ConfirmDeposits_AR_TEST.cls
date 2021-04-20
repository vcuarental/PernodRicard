/********************************************************************************
*  Company:Valuenet     Developer:Elena Schwarzböck      Date:09/04/2013        *
********************************************************************************/
@isTest
public with sharing class  BTN08_ConfirmDeposits_AR_TEST {
@isTest (SeeAllData = true)   
    static void unitTest() {
    
        system.Test.startTest();
        
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
        
        RecordType rt1 = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositPending_AR' AND SobjectType ='RCP_Receipt_ARG__c'];
        RecordType rt2 = [SELECT Id FROM RecordType WHERE DeveloperName = 'RCP_ReceiptPrintedDepositPending_UY' AND SobjectType ='RCP_Receipt_ARG__c'];
        RecordType rt3 = [SELECT Id FROM RecordType WHERE DeveloperName = 'Receipt_withholding_certificates_AR' AND SobjectType ='RCP_Receipt_ARG__c'];
        
        RCP_Receipt_ARG__c receipt = new RCP_Receipt_ARG__c(
        Status_AR__c = 'TEST',
        AmountsControl_AR__c = 100,
        Account_AR__c = acc.id,
        recordtypeid = rt1.id
        //Name = 'TEST'
        );
        
        insert receipt;
        
        RCP_Receipt_ARG__c receipt1 = new RCP_Receipt_ARG__c(
        Status_AR__c = 'TEST',
        AmountsControl_AR__c = 100,
        Account_AR__c = acc.id,
        recordtypeid = rt2.id
        //Name = 'TEST'
        );
        
        insert receipt1;        
        
        RCP_Receipt_ARG__c receipt2 = new RCP_Receipt_ARG__c(
        Status_AR__c = 'TEST',
        AmountsControl_AR__c = 100,
        Account_AR__c = acc.id,
        recordtypeid = rt3.id
        //Name = 'TEST'
        );
        
        insert receipt2;        
        
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
        Name = '000',
        ReceiptNo_AR__c = receipt.id
        );
        insert value;
        
        RCP_Receipt_ARG__c receipt3 = new RCP_Receipt_ARG__c(
            Status_AR__c = 'TEST',
            AmountsControl_AR__c = 10,
            Account_AR__c = acc.id,
            recordtypeid = rt3.id
            //Name = 'TEST'
        );
        insert receipt3;
        
        system.Test.stopTest();
        
        DPT_Deposit_ARG__c dep3= new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 10,
            ReceiptNo_AR__c = receipt3.id
        );
        insert dep3;  
        
        VLS_Values_ARG__c val3 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 10,
            Deposit_AR__c = dep3.id,
            ReceiptNo_AR__c = receipt3.id,
            Bank_AR__c = 'ABC', 
            BranBranch_AR__c = 'ABC'
        );
        insert val3;       

        VLS_Values_ARG__c val1 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt1.id,
            Bank_AR__c = 'ABC', 
            BranBranch_AR__c = 'ABC'
        );
        insert val1;
        
        VLS_Values_ARG__c val2 = new VLS_Values_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt1.id,
            Bank_AR__c = 'ABC', 
            BranBranch_AR__c = 'ABC'
            );
        insert val2;            
        
        DPT_Deposit_ARG__c dep1= new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt2.id
        );
        insert dep1; 
        
        DPT_Deposit_ARG__c dep2= new DPT_Deposit_ARG__c(
            Name = '000',
            Amount_AR__c = 100,
            ReceiptNo_AR__c = receipt2.id
            );
        insert dep2; 
        
        
        
        BTN08_ConfirmDeposits_AR.ConfirmDeposits(receipt.id);
        BTN08_ConfirmDeposits_AR.ConfirmDeposits(receipt1.id);
        BTN08_ConfirmDeposits_AR.ConfirmDeposits(receipt2.id);
        BTN08_ConfirmDeposits_AR.ConfirmDeposits(receipt3.id);

        
    }
}