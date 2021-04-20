/******************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck               Date:30/05/2014  *
*******************************************************************************************/
@istest
public with sharing class LAT_AR_WS01_ReceiptHandlerInterface_TEST {


    @testSetup static void setup() {
        insert LAT_TestFactory.createCS001_JDECredentials('Argentina', '6');
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
    }

    static testMethod void unitTest(){
            
        Account acc = [SELECT Id, Name FROM Account limit 1];
        RCP_Receipt_ARG__c receipt = createReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C');      
        insert receipt;
        System.Test.startTest();
        DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
            Amounttoapply_AR__c = 200,
            Internal_id_pk_AR__c = 'TEST-Test-01-01-01-01',
            ReceiptNo_AR__c = receipt.id,
            PaymentID_AR__c = 1234567890,
            RecordTypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
        );
        insert doc;

        DPT_Deposit_ARG__c dep = AP01_Receipt_AR_TEST.getBaseDeposit(receipt, '2');
        dep.From_Document__c = true; 
        dep.name = '1234567890';      
        insert dep;


               
        VLS_Values_ARG__c value = new VLS_Values_ARG__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR'),
            ReceiptNo_AR__c = receipt.id,
            ValueType_AR__c = 'E',
            Name = '333458',
            Bank_AR__c = '123',
            BranBranch_AR__c = '123',
            Deposit_AR__c   =   dep.Id
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
        
 
        
        
        
        LAT_AR_WS01_ReceiptHandlerInterface.ReceiptInterfaceJDE(receipt.id);

        System.Test.stopTest();
    }


    static testMethod void unitTest2(){
        try {
            Account acc = [SELECT Id, Name FROM Account limit 1];
            RCP_Receipt_ARG__c receipt = createReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'C');      
            insert receipt;
            System.Test.startTest();
            DCM_Documents_ARG__c doc = new DCM_Documents_ARG__c(
                Amounttoapply_AR__c = 200,
                Internal_id_pk_AR__c = 'TEST-Test-01-01-01-01',
                ReceiptNo_AR__c = receipt.id,
                PaymentID_AR__c = 1234567890,
                RecordTypeId = Global_RecordTypeCache.getRtId('DCM_Documents_ARG__c' + 'DCM_Standard_AR')
            );
            insert doc;

            DPT_Deposit_ARG__c dep = AP01_Receipt_AR_TEST.getBaseDeposit(receipt, '2'); 
            insert dep;


                   
            VLS_Values_ARG__c value = new VLS_Values_ARG__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('VLS_Values_ARG__c' + 'VLS_tandard_AR'),
                ReceiptNo_AR__c = receipt.id,
                ValueType_AR__c = 'E',
                Name = '333458',
                Bank_AR__c = '123',
                BranBranch_AR__c = '123',
                Deposit_AR__c   =   dep.Id
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
            
            
            
            
            
            LAT_AR_WS01_ReceiptHandlerInterface.ReceiptInterfaceJDE(receipt.id);
            System.Test.stopTest();
        }catch(Exception e){}
        
    }

    @istest
    static void unitTest3() {
        LAT_ReceiptHandelerTypes.listTaxCertificates_element elem = new  LAT_ReceiptHandelerTypes.listTaxCertificates_element();
        LAT_ReceiptHandelerTypes.DocumentType elem2 = new  LAT_ReceiptHandelerTypes.DocumentType();        
        LAT_ReceiptHandelerTypes.TaxCertificateType elem3 = new LAT_ReceiptHandelerTypes.TaxCertificateType();

        

    }
    public static RCP_Receipt_ARG__c createReceipt(Account acc, String recordType, String accountType) {
        return new RCP_Receipt_ARG__c(
            Account_AR__c = acc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('RCP_Receipt_ARG__c' + recordType),
            LAT_AR_DepositAccountType__c = accountType
        );

    }
    
}