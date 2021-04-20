/*********************************************************************************
 * Name:ASI_CRM_SG_Payment_Test
 * Description: Test all related code to the object Payment
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/02/2015         Laputa: Conrad          Created
 * 21/02/2017         Wilken          		Added test method for reject payment request controller
 * 12/12/2017         Wilken          		[WL 1.0] P4.1 Test Class
 * 17/06/2017         Wilken          		[WL 2.0] P4.2 Test Class for ASI_CRM_SG_PaymentRequestController
*********************************************************************************/
@isTest
public class ASI_CRM_SG_Payment_Test {
    
    public static testmethod void testTrigger () {
    
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData outletData = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.customerData vendorData = new ASI_CRM_SG_TestClassHelper.customerData(true, Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Supplier'));
        ASI_CRM_SG_TestClassHelper.paymentData paymentP = new ASI_CRM_SG_TestClassHelper.paymentData(true);
        ASI_CRM_SG_TestClassHelper.paymentData paymentPWOutlet = new ASI_CRM_SG_TestClassHelper.paymentData(true, outletData.customer, vendorData.customer);
        ASI_TH_CRM_PaymentRequest__c paymentTemp = paymentP.payment;
        ASI_CRM_SG_TestClassHelper.customerData outletData2 = new ASI_CRM_SG_TestClassHelper.customerData(true, 'customName');
        //paymentTemp.ASI_CRM_CN_OutletWS__c = outletData2.customer.id;
        paymentTemp.ASI_CRM_SG_Invoice_No__c = 'test';
        update paymentTemp;
    }
    
	/*[WL 1.0] BEGIN*/
	public static testmethod void testManagePaymentRTMExceed_Controller () {
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        //ASI_CRM_SG_TestClassHelper.customerData customerC2 = new ASI_CRM_SG_TestClassHelper.customerData(true, customerC.customer);
        
        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
		
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(2));
        
        contractTargetC1.contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c = 100;
        contractTargetC2.contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c = 100;
        
        List<ASI_CRM_ContractTarget__c> contractList = new List<ASI_CRM_ContractTarget__c>();
        contractList.add(contractTargetC1.contractTarget);
        contractList.add(contractTargetC2.contractTarget);
        insert contractList;
        
        
        contractC.contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
        contractC.contract.ASI_CRM_Revising__c = true;
        update contractC.contract;
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentP = new ASI_CRM_SG_TestClassHelper.paymentData(true, contractC);
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c (recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
                                                                                                         ASI_TH_CRM_Payment_Request__c = paymentP.payment.id,
                                                                                                         ASI_CRM_SG_Sub_brand__c = subBrandList.get(1).Id,
                                                                                                         ASI_CRM_SG_Type__c = 'A&P Fund',
                                                                                                         ASI_TH_CRM_Amount__c = 20
                                                                                                         );
        insert paymentLineItem;
        
        
        test.starttest();
		String result = ASI_CRM_SG_Payment_ValidationHelper_V2.validateAmountExceedRTMContract(contractC.contract.id, false);
        test.stoptest();       
    }
	/*[WL 1.0] END*/
	
    public static testmethod void testManagePayment_Controller () {
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerC2 = new ASI_CRM_SG_TestClassHelper.customerData(true, customerC.customer);
        
        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(2));
        
        contractTargetC1.contractTarget.ASI_CRM_SG_Cash__c = 100000;
        contractTargetC2.contractTarget.ASI_CRM_SG_Cash__c = 100000;
        
        List<ASI_CRM_ContractTarget__c> contractList = new List<ASI_CRM_ContractTarget__c>();
        contractList.add(contractTargetC1.contractTarget);
        contractList.add(contractTargetC2.contractTarget);
        insert contractList;
        
        
        contractC.contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
        contractC.contract.ASI_CRM_Revising__c = true;
        update contractC.contract;
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentP = new ASI_CRM_SG_TestClassHelper.paymentData(true, contractC);
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c (recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
                                                                                                         ASI_TH_CRM_Payment_Request__c = paymentP.payment.id,
                                                                                                         ASI_CRM_SG_Sub_brand__c = subBrandList.get(1).Id,
                                                                                                         ASI_CRM_SG_Type__c = 'Sales Support',
                                                                                                         ASI_TH_CRM_Amount__c = 1
                                                                                                         );
        insert paymentLineItem;
        
        //ASI_CRM_SG_TestClassHelper.paymentItemData paymentItemData1 = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentP.payment, subBrandList.get(0), 'Cash - Target Achieved');
        //ASI_CRM_SG_TestClassHelper.paymentItemData paymentItemData2 = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentP.payment, subBrandList.get(0), 'Bottle Incentive');
        //ASI_CRM_SG_TestClassHelper.paymentItemData paymentItemData3 = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentP.payment, subBrandList.get(1), 'Signages');
        //ASI_CRM_SG_TestClassHelper.paymentItemData paymentItemData4 = new ASI_CRM_SG_TestClassHelper.paymentItemData(true, paymentP.payment, subBrandList.get(1), 'Sales Support');
        
        test.starttest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(paymentP.payment);
        ASI_CRM_SG_ManagePayment_Controller buildPaymentCon = new ASI_CRM_SG_ManagePayment_Controller(sc);
        
        buildPaymentCon.retrieveSubBrandbySubBrand();
        System.currentPageReference().getParameters().put('PARAM_PAYMENTLINE_SOURCE_ITEM_ID', (String)subBrandList.get(2).id);
        buildPaymentCon.addLineItem();
        System.currentPageReference().getParameters().put('PARAM_PAYMENTLINE_SUBBRAND_ID', 'zzzzzITEMLINEZ0');
        buildPaymentCon.removeLineItem();
        buildPaymentCon.saveLinetems();
        buildPaymentCon.cancel();
        buildPaymentCon.saveLinetems();
        
        ASI_CRM_SG_SOSubmitForApp_Controller submitApp = new ASI_CRM_SG_SOSubmitForApp_Controller(sc);
        submitApp.redirect();
        
        paymentP.payment.ASI_TH_CRM_Status__c = 'Approved';
        update paymentP.payment;
        ApexPages.StandardController sc2 = new ApexPages.StandardController(paymentP.payment);
        ASI_CRM_SG_ManagePayment_Controller buildPaymentCon2 = new ASI_CRM_SG_ManagePayment_Controller(sc2);
        buildPaymentCon2.saveLinetems();
        test.stoptest();
        delete paymentLineItem;
        
    }
	
	public static testmethod void testEdit_Approved_PR_Ctrl () {
        
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        
        List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
        
        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerC2 = new ASI_CRM_SG_TestClassHelper.customerData(true, customerC.customer);
        
        ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(2));
        
        contractTargetC1.contractTarget.ASI_CRM_SG_Cash__c = 100000;
        contractTargetC2.contractTarget.ASI_CRM_SG_Cash__c = 100000;
        
        List<ASI_CRM_ContractTarget__c> contractList = new List<ASI_CRM_ContractTarget__c>();
        contractList.add(contractTargetC1.contractTarget);
        contractList.add(contractTargetC2.contractTarget);
        insert contractList;
        
        
        contractC.contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
        contractC.contract.ASI_CRM_Revising__c = true;
        update contractC.contract;
        
        ASI_CRM_SG_TestClassHelper.paymentData paymentP = new ASI_CRM_SG_TestClassHelper.paymentData(true, contractC);
        ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c (recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
                                                                                                         ASI_TH_CRM_Payment_Request__c = paymentP.payment.id,
                                                                                                         ASI_CRM_SG_Sub_brand__c = subBrandList.get(1).Id,
                                                                                                         ASI_CRM_SG_Type__c = 'Sales Support',
                                                                                                         ASI_TH_CRM_Amount__c = 1
                                                                                                         );
        insert paymentLineItem;
        
        
		
        test.starttest();
			//Draft Payment Scenario
			paymentP.payment.ASI_TH_CRM_Status__c = 'Approved';        
			paymentP.payment.recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request_Read_Only');
			update paymentP.payment;
		
			ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(paymentP.payment);
			stdController = new ApexPages.Standardcontroller(paymentP.payment);
			ApexPages.currentPage().getParameters().put('id', paymentP.payment.id);
            ASI_CRM_SG_Edit_Approved_PR_Ctrl controller = new ASI_CRM_SG_Edit_Approved_PR_Ctrl(stdController);   
            
			
			//Standard Scenario
			ApexPages.Standardcontroller stdController2 = new ApexPages.Standardcontroller(paymentP.payment);
			stdController2 = new ApexPages.Standardcontroller(paymentP.payment);
			ApexPages.currentPage().getParameters().put('id', paymentP.payment.id);
            ASI_CRM_SG_Edit_Approved_PR_Ctrl controller2 = new ASI_CRM_SG_Edit_Approved_PR_Ctrl(stdController2);   
            
            controller2.rejectComment = 'rejected';
            controller2.rejectAction();   
            controller2.redirectPage();                           
        
			//Already Sync to JDE
			paymentP.payment.ASI_CRM_Sync_to_JDE__c = true;        
			ApexPages.Standardcontroller stdController3 = new ApexPages.Standardcontroller(paymentP.payment);
			stdController3 = new ApexPages.Standardcontroller(paymentP.payment);
			ApexPages.currentPage().getParameters().put('id', paymentP.payment.id);
            ASI_CRM_SG_Edit_Approved_PR_Ctrl controller3 = new ASI_CRM_SG_Edit_Approved_PR_Ctrl(stdController3);   
        
        test.stoptest();        
    }
    
	public static testmethod void testDeleteApproved () {
		/*[WL 2.0] BEGIN*/
		Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		
		User newUser = new User(
			profileId = p.Id,
            username = 'newUser1234@newUser1234.com',
            email = 'newUser@newUser.com',
            emailencodingkey = 'UTF-8',
            localesidkey = 'en_US',
            languagelocalekey = 'en_US',
            timezonesidkey = 'America/Los_Angeles',
            alias = 'nuser',
            lastname = 'user',
            ASI_Default_Order_Customer__c = 'TestCustomer',
            ASI_Default_Order_Ship_To__c = 'TestCustomer'
        );
        insert newUser;
				
		Group g = [select Id from Group where DeveloperName = 'ASI_CRM_SG_Sales_BA'];
		GroupMember gm = new GroupMember(GroupId = g.Id, UserOrGroupId = newUser.Id);
		insert gm;		
        
		
		System.runAs(newUser){		
		/*[WL 2.0] END*/
			ASI_CRM_SG_TestClassHelper.createDataSettings();
			
			List<ASI_MFM_Sub_brand__c> subBrandList = ASI_CRM_SG_TestClassHelper.createSubBrandData();
			List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUwithSubrand(subBrandList); 
			
			ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
			ASI_CRM_SG_TestClassHelper.customerData customerC2 = new ASI_CRM_SG_TestClassHelper.customerData(true, customerC.customer);
			
			ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer);
			ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(1));
			ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC2 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(2));
			
			contractTargetC1.contractTarget.ASI_CRM_SG_Cash__c = 100000;
			contractTargetC2.contractTarget.ASI_CRM_SG_Cash__c = 100000;
			
			List<ASI_CRM_ContractTarget__c> contractList = new List<ASI_CRM_ContractTarget__c>();
			contractList.add(contractTargetC1.contractTarget);
			contractList.add(contractTargetC2.contractTarget);
			insert contractList;
			
			
			contractC.contract.ASI_TH_CRM_Contract_Status__c = 'Contract Approved';
			contractC.contract.ASI_CRM_Revising__c = true;
			update contractC.contract;
			
			ASI_CRM_SG_TestClassHelper.paymentData paymentP = new ASI_CRM_SG_TestClassHelper.paymentData(true, contractC);
			ASI_TH_CRM_PaymentRequestLineItem__c paymentLineItem = new ASI_TH_CRM_PaymentRequestLineItem__c (recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
																											 ASI_TH_CRM_Payment_Request__c = paymentP.payment.id,
																											 ASI_CRM_SG_Sub_brand__c = subBrandList.get(1).Id,
																											 ASI_CRM_SG_Type__c = 'Sales Support',
																											 ASI_TH_CRM_Amount__c = 1
																											 );
			insert paymentLineItem;
			
			
			
			test.starttest();
				//Draft Payment Scenario
				paymentP.payment.ASI_TH_CRM_Status__c = 'Approved';        
				paymentP.payment.recordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request_Read_Only');
				update paymentP.payment;
			
				
			try{
				delete paymentP.payment;
			} catch (exception e){
				
			}
		
			/*WL 2.0] BEGIN*/		
			undelete paymentP.payment;
			system.debug('paymentLineItem Id: ' + paymentLineItem.Id + 'paymentLineItem header id: ' + paymentLineItem.ASI_TH_CRM_Payment_Request__c);
			ApexPages.StandardController sc = new ApexPages.StandardController(paymentP.payment);
			ASI_CRM_SG_PaymentRequestController paymentController = new ASI_CRM_SG_PaymentRequestController(sc);
			paymentController.setToDraft();
			/*WL 2.0] END*/
		}
		
        test.stoptest();        
    }

}