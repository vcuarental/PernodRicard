@isTest
public with sharing class LAT_ReceiptValidations_Batch_Test {

	@testSetup static void setup() {
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

        LAT_GeneralConfig__c cs2 = new LAT_GeneralConfig__c(
            Name = 'AR_Receipt_Errors_Email_Recipients',
            LAT_Value__c = 'test@test.com');
        insert cs2;
        
	}

	@isTest
	static void test_1(){
		Account acc = [SELECT Id, Name FROM Account limit 1];
        RCP_Receipt_ARG__c receipt = LAT_AR_WS01_ReceiptHandlerInterface_TEST.createReceipt(acc, 'RCP_ReceiptGeneratedDepositDone_AR', 'R');
        receipt.LAT_AR_IntegrationStatus__c = 'Sent to JDE';  
        receipt.ID_JDE_Debito__c = 'TEST-123';           
        receipt.Comercial_Discount_ID_JDE__c = 'TEST-123';           
        receipt.Financial_Discount_ID_JDE__c = 'TEST-123';           
        receipt.ID_JDE_Downpayments__c = 'TEST-123';            
        insert receipt;
        Test.startTest();
        DPT_Deposit_ARG__c deposit = new DPT_Deposit_ARG__c(
            ReceiptNo_AR__c = receipt.id,
            Amount_AR__c = 123,
            AccType_AR__c = 'Collection Bank Account',
            Date_AR__c  =   Date.Today(),
            Name = '2'
        );       
        insert deposit;  
        DCM_Documents_ARG__c doc = AP01_Receipt_AR_TEST.getBaseDocument(receipt);
        insert doc;
        Database.executeBatch(new LAT_ReceiptValidations_Batch(), 10); 

        Test.stopTest();
	}
}