/***************************************************************************************************************************
 * Name:        ASI_CRM_PH_PaymentReqTriggerClass_Test
 * Description: Contains the test methods for ASI_CRM_PH_PaymentRequest_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-01-25       Calvin Chiu (LAPUTA)    Created
 ****************************************************************************************************************************/
@isTest
public without sharing class ASI_CRM_PH_PaymentReqTriggerClass_Test {
    @testSetup
    public static void testUp(){
        ASI_MFM_Exchange_Rate__c exRate = ASI_CRM_PH_Testfactory.createExchangeRate(Date.newInstance(Date.today().Year() - 1, 9, 1));
        insert exRate;
        
        ASI_HK_CRM_Running_Number__c runningNumber = ASI_CRM_PH_Testfactory.createRunningNumber(Date.today().year() -1);        
        insert runningNumber;
        
        List<ASI_CRM_AccountsAdditionalField__c> customerList = ASI_CRM_PH_Testfactory.createCustomers('MODERN OFF TRADE', true, true, 1);
        insert customerList;        
        
        List<ASI_TH_CRM_Contract__c> contractList = ASI_CRM_PH_Testfactory.createContracts(customerList[0].Id, Date.newInstance(Date.today().Year() - 1, 7, 1), Date.newInstance(Date.today().Year(), 6, 30), 1);
        contractList[0].ASI_CRM_Contract_Fund_Amount__c = 100;	 
        contractList[0].ASI_CRM_Marketing_Support_Fund_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Activation_Fund_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Merchandise_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Purchase_Incentive_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Staff_Incentive_Amount__c = 100;	 	 
        contractList[0].ASI_CRM_Bottle_Rebate_Amount__c = 100;
        contractList[0].ASI_CRM_Sales_Revenue_Target_Outlet__c = 100;
        contractList[0].ASI_CRM_SG_Net_Sales__c = 1000;
        insert contractList;      
        
        ASI_MFM_Sub_brand__c subbrand = ASI_CRM_PH_Testfactory.createSubBrand();
        insert subbrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_PH_Testfactory.createSKU(subbrand.Id);
        insert sku;
        
        ASI_CRM_MY_SKUPriceCost__c priceCost = ASI_CRM_PH_Testfactory.createSKUPriceCost(sku.Id, customerList[0].Id);
        insert priceCost;
        
        ASI_CRM_ContractTarget__c target = ASI_CRM_PH_Testfactory.createContractTarget(contractList[0].Id, sku.Id);
        insert target;
        
        List<ASI_CRM_Payment_Schedule__c> schdList = new List<ASI_CRM_Payment_Schedule__c>();
        schdList.add(ASI_CRM_PH_Testfactory.createPaymentSchedule(contractList[0].Id, Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Contract_Fund')));
        schdList.add(ASI_CRM_PH_Testfactory.createPaymentSchedule(contractList[0].Id, Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Schedule__cASI_CRM_PH_Purchase_Incentive')));
        insert schdList;
        
        insert ASI_CRM_PH_Testfactory.createFOCRequest(contractList[0].Id, Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request'));
    }
    
    @isTest static void testBeforeUpsertDP(){
        ASI_CRM_AccountsAdditionalField__c customer = [select id from ASI_CRM_AccountsAdditionalField__c where Name = 'Test Customer 0' Limit 1];
        customer.ASI_CRM_Duty_Free__c = false;
        update customer;
        
        ASI_TH_CRM_PaymentRequest__c paymentReq = new ASI_TH_CRM_PaymentRequest__c();
        paymentReq.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
        paymentReq.ASI_TH_CRM_Status__c = 'Draft';
        paymentReq.ASI_CRM_Payment_Type__c = 'Bottle Rebate';
        paymentReq.ASI_TH_CRM_Contract__c = [select id from ASI_TH_CRM_Contract__c where Name Like 'PRP%' limit 1].id;
        insert paymentReq;
        
		ASI_TH_CRM_PaymentRequest__c updatedPaymentReq = [select ASI_CRM_Exchange_Rate__c from ASI_TH_CRM_PaymentRequest__c where id =: paymentReq.Id];
		System.assertEquals(updatedPaymentReq.ASI_CRM_Exchange_Rate__c, 1);  
        
        updatedPaymentReq.ASI_TH_CRM_Status__c = 'Approved';
        update updatedPaymentReq;
        
        try{
            delete updatedPaymentReq;
        }catch(Exception ex){
            System.Assert(ex.getMessage().contains('You cannot delete submitted or approved payment'));
        }
    }
    
    @isTest
    public static void testBeforeUpsertDF(){
        List<ASI_TH_CRM_PaymentRequest__c> paymentReqList = new List<ASI_TH_CRM_PaymentRequest__c>();
        
        ASI_TH_CRM_PaymentRequest__c paymentReq1 = new ASI_TH_CRM_PaymentRequest__c();
        paymentReq1.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
        paymentReq1.ASI_TH_CRM_Status__c = 'Draft';
        paymentReq1.ASI_TH_CRM_Contract__c = [select id from ASI_TH_CRM_Contract__c where Name Like 'PRP%' limit 1].id;
        paymentReq1.ASI_CRM_Payment_Type__c = 'Contract Fund';
        paymentReq1.ASI_CRM_Payment_Amount__c = 95;
        paymentReqList.add(paymentReq1);
        
        ASI_TH_CRM_PaymentRequest__c paymentReq2 = new ASI_TH_CRM_PaymentRequest__c();
        paymentReq2.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
        paymentReq2.ASI_TH_CRM_Status__c = 'Draft';
        paymentReq2.ASI_TH_CRM_Contract__c = [select id from ASI_TH_CRM_Contract__c where Name Like 'PRP%' limit 1].id;
        paymentReq2.ASI_CRM_Payment_Type__c = 'Bottle Rebate';
        paymentReq2.ASI_CRM_Payment_Amount__c = 95;
        paymentReqList.add(paymentReq2);
        
        ASI_TH_CRM_PaymentRequest__c paymentReq3 = new ASI_TH_CRM_PaymentRequest__c();
        paymentReq3.recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request');
        paymentReq3.ASI_TH_CRM_Status__c = 'Draft';
        paymentReq3.ASI_TH_CRM_Contract__c = [select id from ASI_TH_CRM_Contract__c where Name Like 'PRP%' limit 1].id;
        paymentReq3.ASI_CRM_Payment_Type__c = 'Staff Incentive';
        paymentReq3.ASI_CRM_Payment_Amount__c = 95;
        paymentReqList.add(paymentReq3);
                
        insert paymentReqList;
        
		ASI_TH_CRM_PaymentRequest__c updatedPaymentReq = [select ASI_CRM_Exchange_Rate__c from ASI_TH_CRM_PaymentRequest__c where id =: paymentReqList[0].Id];
		System.assertEquals(updatedPaymentReq.ASI_CRM_Exchange_Rate__c, 2);     
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> payReqItemList = [select id from ASI_TH_CRM_PaymentRequestLineItem__c];
        System.assertEquals(payReqItemList.size(), 3);
        
        paymentReqList[0].ASI_CRM_Payment_Amount__c = 98;
        update paymentReqList[0];        
    }
}