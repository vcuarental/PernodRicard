/*********************************************************************************
 * Name: ASI_CRM_SG_TestClass
 * Description: Test class for PRA customizations
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 29/05/2015         Wilken Lee            Created
 * 19/06/2016         Vincent Lam           Help to correct error in B1 / production, make change in createContract() and TnE details
 * 04/08/2016         Laputa: Hugo Cheung   Updated. Add test setup function. 
 * 03/02/2017         Wilken Lee   			Added test case for Offtake Trigger Class Blind Bonus code
 * 09/05/2017         Wilken Lee   			Updated testSalesOrderExtension_Controller for SG Re-export SO Enhancement
 * 07/08/2017         Wilken Lee   			[WL 1.0] Added test method for SG Credit Note redirect controller
 * 15/11/2017         Wilken Lee   			[WL 2.0] Add test code for Brand Event Held Daily Rollup Batch class
 * 04/01/2018         Wilken Lee   			[WL 3.0] Create Test Data in TestSetup
 * 01/02/2018         Wilken Lee   			[WL 4.0] Create Contract Test Data for Daily Roll Up Batch Class
 * 27/03/2018         Wilken Lee   			[WL 5.0] Add test method for ASI_CRM_SG_VisitDetailGPSController
 * 2018-06-19		Vincent Lam				[VL 1.0] test outlet type update from parent to child
*********************************************************************************/
@isTest
public class ASI_CRM_SG_TestClass {

    @TestSetup
    public static void setupTestData() {
		/*[WL 3.0] BEGIN*/
		//createSGContractRunningNumber();
		/*[WL 3.0] END*/		
        
        createSGTnERunningNumbers();
    }
	
	/* [VL 1.0] BEGIN */
	static testMethod void ASI_CRM_SG_TestParentOutletType(){
		ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.customerData customerParent = new ASI_CRM_SG_TestClassHelper.customerData(true);
        ASI_CRM_SG_TestClassHelper.customerData customerChild = new ASI_CRM_SG_TestClassHelper.customerData(true, customerParent.customer);
		
		customerParent.customer.ASI_CRM_Outlet_Type__c = 'Contracted Outlet';
		update customerParent.customer;
	}
	
	static testMethod void ASI_CRM_SG_TestFreeGoodSummary() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.freeGoodsData foc = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true, 'ASI_CRM_SG_FOC');


        ApexPages.StandardController sc = new ApexPages.StandardController(foc.freeGoods);
        ASI_CRM_SG_FreeGoodSummaryCtrl controller = new ASI_CRM_SG_FreeGoodSummaryCtrl(sc);

    }
	/* [VL 1.0] END */

	/*[WL 5.0 BEGIN]*/
	static testMethod void ASI_CRM_SG_VisitDetailGPSControllerTest() {
		String monthStr;
		if (System.today().month() == 1)
			monthStr = 'January';
		else if (System.today().month() == 2)
			monthStr = 'February';
		else if (System.today().month() == 3)
			monthStr = 'March';
		else if (System.today().month() == 4)
			monthStr = 'April';
		else if (System.today().month() == 5)
			monthStr = 'May';
		else if (System.today().month() == 6)
			monthStr = 'June';
		else if (System.today().month() == 7)
			monthStr = 'July';
		else if (System.today().month() == 8)
			monthStr = 'August';
		else if (System.today().month() == 9)
			monthStr = 'September';
		else if (System.today().month() == 10)
			monthStr = 'October';
		else if (System.today().month() == 11)
			monthStr = 'November';
		else
			monthStr = 'December';
			
		ASI_HK_CRM_Visitation_Plan__c vPlan = new ASI_HK_CRM_Visitation_Plan__c(
												recordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_SG_Visitation_Plan'),
												ASI_HK_CRM_Year__c = String.valueOf(System.today().year()),
												ASI_HK_CRM_Month__c = monthStr,
												Name = 'Test Plan');
		insert vPlan;
		
		system.debug('header sys year: ' + vPlan.ASI_HK_CRM_Sys_Year__c + ' header year: ' + vPlan.ASI_HK_CRM_Year__c + ' header month: ' + vPlan.ASI_HK_CRM_Month__c);
		ASI_HK_CRM_Visitation_Plan_Detail__c vPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
																recordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_SG_Visitation_Plan_Detail'),
																ASI_HK_CRM_Visitation_Plan__c = vPlan.Id,
																ASI_HK_CRM_Subject__c = 'Test',
																ASI_HK_CRM_Visit_Date__c = System.today()
																);
		insert vPlanDetail;
		
		system.debug('detail date: ' + vPlanDetail.ASI_HK_CRM_Visit_Date__c);
		
		ApexPages.StandardController stdController = new ApexPages.StandardController(vPlanDetail);
		
		ASI_CRM_SG_VisitDetailGPSController controller = new ASI_CRM_SG_VisitDetailGPSController(stdController);
		controller.latitudeStr = '-33.8635124';
		controller.longitudeStr = '151.0883678';
		
		ASI_CRM_SG_VisitDetailGPSController controllerCheckOut = new ASI_CRM_SG_VisitDetailGPSController(stdController);
		controllerCheckOut.latitudeStr = '-33.8635124';
		controllerCheckOut.longitudeStr = '151.0883678';
		
		Test.setMock(HttpCalloutMock.class, new ASI_CRM_VN_MockLocReGenerator());
		
		System.Test.startTest();
		controller.googleMapRequestCheckIn();
		controllerCheckOut.googleMapRequestCheckOut();
		System.Test.stopTest();
	}
	/*[WL 5.0 END]*/
	
	/*[WL 1.0 BEGIN]*/
	static testMethod void ASI_CRM_RedirectCreditNote_CtrTest() {
		ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Credit_Debit_Note_No', 
										 ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2, 
										 ASI_HK_CRM_Format__c = '{YY}{00000}', 
										 ASI_HK_CRM_Running_Number__c = 2
									     );
        insert runningNumber;

		ASI_CRM_Credit_Debit_Note__c cNote = new ASI_CRM_Credit_Debit_Note__c(Name='Test', recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Credit_Debit_Note__cASI_CRM_SG_Manual_Credit_Note'));
		insert cNote;
		
		ApexPages.StandardController stdController = new ApexPages.StandardController(cNote);
		ASI_CRM_RedirectCreditNote_Ctr ctr = new ASI_CRM_RedirectCreditNote_Ctr(stdController);
		
		System.Test.startTest();
			ctr.redirect();
			
			//Test method to cover ASI_CRM_Credit_Debit_Note_BeforeDelete trigger
			delete cNote;
			
			//Test negative case when no record type for Credit Note
			ASI_CRM_Credit_Debit_Note__c cNote2 = new ASI_CRM_Credit_Debit_Note__c(Name='Test2');
			insert cNote2;
			
			ApexPages.StandardController stdController2 = new ApexPages.StandardController(cNote2);
			ASI_CRM_RedirectCreditNote_Ctr ctr2 = new ASI_CRM_RedirectCreditNote_Ctr(stdController2);
			
		System.Test.stopTest();		
	}/*[WL 1.0 END]*/
	
	public static testmethod void testApprovalNotifiController() {
		ASI_CRM_SG_FOC_ApprovalNotifiController con = new ASI_CRM_SG_FOC_ApprovalNotifiController();
		
		/*[WL 3.0] BEGIN*/
		ASI_CRM_SG_TestClassHelper.createDataSettings();
		/*[WL 3.0] END*/
		
		ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodRForm = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true, 'ASI_CRM_SG_FOC');
		ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodsRItem = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(true,freeGoodRForm.freeGoods);
		
		con.focID = freeGoodRForm.freeGoods.id;
		con.getHeader();
		con.getChilds();
	}
	
    public static testmethod void testDailyRollupBatchClass() {
        /*[WL 2.0] BEGIN*/
		ASI_CRM_Group_Outlet_Type__c groupOutletType = new ASI_CRM_Group_Outlet_Type__c(
																				ASI_CRM_SG_Group_Outlet_Name__c='Offtrade',
																				ASI_CRM_SG_Name__c='High Energy Bar'
																		   
																				);
		insert groupOutletType;
		
        ASI_CRM_AccountsAdditionalField__c outlet = new ASI_CRM_AccountsAdditionalField__c(
                                                                                        Name = 'Test Outlet',
                                                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Outlet'),
                                                                                        ASI_CRM_Business_Registration_Number__c = '958473957',
																						ASI_CRM_SG_Group_Outlet_Type__c = groupOutletType.id
                                                                                    );
        insert outlet;      
    		
		ASI_TH_CRM_Contract__c contract = createContract();
		contract.ASI_CRM_CN_Outlet_WS__c = outlet.Id;
		
		/*[WL 4.0] BEGIN*/
		contract.ASI_CRM_Recalculate_Actual_ROI__c = true;
		/*[WL 4.0] END*/
		
		update contract;
		/*[WL 2.0] END*/
		
        //Create Expense Category & Classification for the desired Account Code
        ASI_JP_TnE_Expense_Category__c expCategory = new ASI_JP_TnE_Expense_Category__c(
                                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_JP_TnE_Expense_Category__cASI_TnE_SG_Expense_Category'),
                                                                                    ASI_JP_TnE_Expense_Category_Order__c = 80
                                                                                    );
        insert expCategory;
        
        ASI_TnE_Account_Mapping__c acctMapping = new ASI_TnE_Account_Mapping__c(
                                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_TnE_Account_Mapping__cASI_TnE_SG_Account_Mapping'),
                                                                                ASI_TnE_Account_Number__c = '5559.ONPRE',
                                                                                ASI_JP_TnE_Account_Name__c = 'ON-PREMISE EXPENSES'
                                                                                );
        insert acctMapping;
        
        ASI_JP_TnE_Expense_Classification__c expClassification = new ASI_JP_TnE_Expense_Classification__c(
                                                                                                            recordtypeid = Global_RecordTypeCache.getRTId('ASI_JP_TnE_Expense_Classification__cASI_TnE_SG_Expense_Classification'),
                                                                                                            ASI_JP_TnE_Expense_Category__c = expCategory.id,
                                                                                                            ASI_JP_TnE_Account_Mapping__c = acctMapping.id
                                                                                                        );
        insert expClassification;
        
        ASI_TnE_ClaimHeader__c tneHeader = new ASI_TnE_ClaimHeader__c(
                                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_SG_Claim_Header_Finance'),
                                                                        ASI_TnE_Status__c = 'Final'
                                                                    );
        insert tneHeader;
        
        ASI_TnE_ClaimDetail__c tneDetail = new ASI_TnE_ClaimDetail__c(
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_SG_Claim_Detail'),
                                                                    ASI_TnE_ClaimHeader__c = tneHeader.id,
                                                                    // Vincent: make outlet as contract's outlet
                                                                    //ASI_TnE_Outlet__c = outlet.id,
                                                                    ASI_TnE_Outlet__c = contract.ASI_CRM_CN_Outlet_WS__c,
                                                                    // Vincent: add ASI_TnE_Receipt_Date__c within contract start and end date
                                                                    ASI_TnE_Receipt_Date__c = system.today().adddays(100),
                                                                    ASI_TnE_Expense_Category__c = expCategory.id,
                                                                    ASI_TnE_Expense_Classification__c = expClassification.id,
                                                                    ASI_TnE_Currency__c = 'SGD',
                                                                    ASI_TnE_FX_Rate__c = 1,
                                                                    ASI_TnE_Receipt_Amount__c = 1000
                                                                    );
        insert tneDetail;
        
		/*[WL 2.0] BEGIN*/
		ASI_MFM_SKU_Code__c sku = createSKUDataWithPriceCost();
		
		Account acct = new Account(
									Name = 'Test Account',
									recordtypeid = Global_RecordTypeCache.getRTId('AccountASI_CRM_SG_Outlet')
									);
		insert acct;
		
		ASI_HK_CRM_Running_Number__c runningNumber = new ASI_HK_CRM_Running_Number__c(
																					ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c',
																					ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7
																					);
		insert runningNumber;
			
		ASI_HK_CRM_Sales_Order_History__c soHHeader = new ASI_HK_CRM_Sales_Order_History__c(
																	recordtypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_History__cASI_CRM_SG_Sales_Order_History'),
																	ASI_CRM_AccountAdditionalField__c = outlet.Id,
																	ASI_HK_CRM_Account_PA__c = acct.Id,
																	ASI_HK_CRM_Order_Date__c = contract.ASI_TH_CRM_Start_Date__c+60,
																	ASI_HK_CRM_Order_Type__c = 'Singapore DF & DP Free Issue - F1'
																	);
		insert soHHeader;
		
		ASI_HK_CRM_Sales_Order_History_Detail__c soHDetail = new ASI_HK_CRM_Sales_Order_History_Detail__c(
																	recordtypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_History_Detail__cASI_CRM_SG_Sales_Order_History_Detail'),
																	ASI_HK_CRM_Sales_Order_History__c = soHHeader.Id,
																	ASI_HK_CRM_Product_SKU__c = sku.Id,
																	ASI_CRM_AG_Code__c = '0009',
																	ASI_HK_CRM_Quantity_in_Bottles__c = 10
																	);
		insert soHDetail;
		/*[WL 2.0] END*/
		
        System.Test.startTest();
            Database.executeBatch(new ASI_CRM_SG_DailyRollUp_Batch());
        System.Test.stopTest();
    }
    
    public static testmethod void testOfftakeTriggerClass() {
        
        ASI_CRM_AccountsAdditionalField__c ws = new ASI_CRM_AccountsAdditionalField__c(
                                                                                        Name = 'Test Wholesaler',
                                                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Wholesaler')
                                                                                    );
        
        insert ws;
        

        
        ASI_MFM_SKU_Code__c sku = createSKUDataWithPriceCost();
        
        ASI_CRM_Blind_Bonus__c bb = new ASI_CRM_Blind_Bonus__c(
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Blind_Bonus__cASI_CRM_SG_Wholesaler'),
                                                                ASI_CRM_Customer__c = ws.id,
																ASI_CRM_Default_Est_Blind_Bonus_Amount__c = false,
                                                                ASI_CRM_Blind_Bonus_Amount_Per_9L__c = 100,
                                                                ASI_CRM_Effective_Date__c = system.today(),
                                                                ASI_CRM_Sub_brand__c = sku.ASI_MFM_Sub_brand__c
                                                                );

        insert bb;
        
        ASI_TH_CRM_Contract__c contract = createContract();
        
        System.Test.startTest();
            ASI_TH_CRM_Actual_Offtake__c offtake = new ASI_TH_CRM_Actual_Offtake__c(
                                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake'),
                                                                                    ASI_CRM_SKU__c = sku.id,
                                                                                    ASI_TH_CRM_Quantity__c = 12,
                                                                                    ASI_CRM_Contract__c = contract.id,
                                                                                    ASI_CRM_FromWS__c = ws.id,
																					ASI_TH_CRM_Sub_brand__c = sku.ASI_MFM_Sub_brand__c
                                                                                    );
            insert offtake;
            
            offtake.ASI_TH_CRM_Quantity__c = 13;
            update offtake;
        System.Test.stopTest();
    }
    
    public static testmethod void testFreeGoodRequestCloneChildCON() {
        
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();
        
		/*[WL 3.0] BEGIN*/
		ASI_CRM_SG_TestClassHelper.createDataSettings();
		/*[WL 3.0] END*/
				
        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodRFrom = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true, 'ASI_CRM_SG_FOC');
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(true, freeGoodRFrom.freeGoods, skuList.get(1));
        
        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodRTo = new ASI_CRM_SG_TestClassHelper.freeGoodsData(true, 'ASI_CRM_SG_FOC');
        
        
         Test.startTest();
         
        PageReference testPage = Page.ASI_CRM_SG_FreeGoodRequestCloneChildPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put(ASI_CRM_SG_FreeGoodRequestCloneChildCON.URL_PARAM_NEW_ID, freeGoodRTo.freeGoods.Id);
        pageParams.put(ASI_CRM_SG_FreeGoodRequestCloneChildCON.URL_PARAM_FROM_ID, freeGoodRFrom.freeGoods.Id);
        
        Test.setCurrentPageReference(testPage);
        ASI_CRM_SG_FreeGoodRequestCloneChildCON testController = new ASI_CRM_SG_FreeGoodRequestCloneChildCON();
        PageReference initRedirectPage = testController.initPage();
        PageReference linkRedirectPage = testController.redirectToAnotherPage();
        
        String label = testController.anotherPageLabel;
        testController.newReqId = null;
        label = testController.anotherPageLabel;
        
        Test.stopTest();
    }
    
    public static testmethod void testSalesOrderExtension_Controller () {
        
		//Wilken 20170509 Add Default Customer and Ship To for test user
		Profile p = [SELECT Id FROM Profile WHERE Name = 'ASI SG External User'];
        
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
		
        System.runAs(newUser){		
			ASI_CRM_AccountsAdditionalField__c reExportCustomer = new ASI_CRM_AccountsAdditionalField__c (name = 'TestCustomer', ASI_CRM_VN_Channel__c ='CA', recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Re_Export_SO_Customer'));
			insert reExportCustomer;
				
			List<ASI_MFM_SKU_Code__c> skuList = new List<ASI_MFM_SKU_Code__c>();
			skuList = createSKUData(skuList);
			
			ASI_CRM_SG_TestClassHelper.salesOrderData salesOrderD = new ASI_CRM_SG_TestClassHelper.salesOrderData(true, 'ASI_CRM_SG_CA');
			ASI_CRM_SG_TestClassHelper.salesOrderItemData salesOrderItemD = new ASI_CRM_SG_TestClassHelper.salesOrderItemData(true, 'ASI_CRM_SG_CA', salesOrderD.salesOrder);
			salesOrderItemD.salesOrderItem.ASI_CRM_SG_SKU__c = skuList.get(0).id;
			salesOrderItemD.salesOrderItem.ASI_CRM_SG_Request_Quantity_Bottle__c = 1;
			update salesOrderItemD.salesOrderItem;
			
			ASI_CRM_SG_TestClassHelper.salesOrderItemData salesOrderItemD2 = new ASI_CRM_SG_TestClassHelper.salesOrderItemData(true, 'ASI_CRM_SG_CA', salesOrderD.salesOrder);
			salesOrderItemD2.salesOrderItem.ASI_CRM_SG_SKU__c = skuList.get(1).id;
			salesOrderItemD2.salesOrderItem.ASI_CRM_SG_Request_Quantity_Bottle__c = 1;
			update salesOrderItemD2.salesOrderItem;
			
			test.starttest();
			PageReference pageRef = Page.ASI_CRM_SG_StockInvEnquiryPage;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('id', salesOrderD.salesOrder.id);
			
			ApexPages.StandardController sc = new ApexPages.StandardController(salesOrderD.salesOrder);
			ASI_CRM_SG_SalesOrderExtensionController salesOrderController = new ASI_CRM_SG_SalesOrderExtensionController(sc);
			
			salesOrderController.checkInventory();
			
			salesOrderController.notifyOperation();
			
			//Wilken 20170523 Delete SO to test BeforeDelete trigger
			delete salesOrderD.salesOrder;
			
			test.stoptest();
		}
    }
    
    public static List<ASI_MFM_SKU_Code__c> createSKUData(List<ASI_MFM_SKU_Code__c> skuList){
    
            ASI_MFM_SKU_Code__c sku1 = new ASI_MFM_SKU_Code__c (
                                                                name='Test Sku 1',
                                                                ASI_MFM_SKU_Code__c = 'test1',
                                                                recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_CA'),
                                                                ASI_HK_CRM_Std_Bottle_Size__c = 3,
                                                                ASI_HK_CRM_Packaging_Size__c = 4,
                                                                ASI_HK_CRM_Available_Quantity__c = 10,
                                                                ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                ASI_HK_CRM_Active__c = true
                                                            );
            skuList.add(sku1);
            
                    ASI_MFM_SKU_Code__c sku2 = new ASI_MFM_SKU_Code__c (
                                                                        name='Test Sku 2',
                                                                        ASI_MFM_SKU_Code__c = 'test2',
                                                                        recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SO_CA'),
                                                                        ASI_HK_CRM_Std_Bottle_Size__c = 3,
                                                                        ASI_HK_CRM_Packaging_Size__c = 4,
                                                                        ASI_HK_CRM_Available_Quantity__c = 0,
                                                                        ASI_HK_CRM_UOM1__c = 'UOM1',
                                                                        ASI_HK_CRM_Active__c = true
                                                                );
            skuList.add(sku2);
            
            insert skuList;
        
            return skuList;
    }

    public static ASI_MFM_SKU_Code__c createSKUDataWithPriceCost(){
        ASI_MFM_Sub_brand__c sb = new ASI_MFM_Sub_brand__c(
                                                    name = 'Test sub-brand',
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_Sub_brand__cASI_CRM_SG_Sub_brand')
                                                );
                                                
        insert sb;
        
        ASI_MFM_SKU_Code__c sku = new ASI_MFM_SKU_Code__c (
                                                    name='Test Sku 3',
                                                    ASI_MFM_SKU_Code__c = 'test3',
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_MFM_SKU_Code__cASI_CRM_SG_SKU'),
                                                    ASI_HK_CRM_Std_Bottle_Size__c = 3,
                                                    ASI_HK_CRM_Packaging_Size__c = 4,
                                                    ASI_HK_CRM_Available_Quantity__c = 10,
                                                    ASI_HK_CRM_UOM1__c = 'UOM1',
                                                    ASI_HK_CRM_Active__c = true,
                                                    ASI_MFM_Sub_brand__c = sb.id
                                                );
        
        insert sku;
        
        List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCostList = new List<ASI_CRM_MY_SKUPriceCost__c>();
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost1 = new ASI_CRM_MY_SKUPriceCost__c (
                                                    ASI_CRM_Cost__c = 100,
                                                    ASI_CRM_EffectiveDate__c = system.today(),
                                                    ASI_CRM_SKU__c = sku.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Duty_Per_Bottle')
                                                );
        skuPriceCostList.add(skuPriceCost1);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost2 = new ASI_CRM_MY_SKUPriceCost__c (
                                                    ASI_CRM_Cost__c = 100,
                                                    ASI_CRM_EffectiveDate__c = system.today(),
                                                    ASI_CRM_SKU__c = sku.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_FOB_Per_Bottle')
                                                );
        skuPriceCostList.add(skuPriceCost2);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost3 = new ASI_CRM_MY_SKUPriceCost__c (
                                                    ASI_CRM_Cost__c = 100,
                                                    ASI_CRM_EffectiveDate__c = system.today(),
                                                    ASI_CRM_SKU__c = sku.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Handling_Cost_Per_Bottle')
                                                );
        skuPriceCostList.add(skuPriceCost3);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost4 = new ASI_CRM_MY_SKUPriceCost__c (
                                                    ASI_CRM_Cost__c = 100,
                                                    ASI_CRM_EffectiveDate__c = system.today(),
                                                    ASI_CRM_SKU__c = sku.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_IGC')
                                                );
        skuPriceCostList.add(skuPriceCost4);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost5 = new ASI_CRM_MY_SKUPriceCost__c (
                                                    ASI_CRM_Cost__c = 100,
                                                    ASI_CRM_EffectiveDate__c = system.today(),
                                                    ASI_CRM_SKU__c = sku.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_CRM_Standard_Cost_Per_Bottle')
                                                );
        skuPriceCostList.add(skuPriceCost5);
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost6 = new ASI_CRM_MY_SKUPriceCost__c (
                                                    ASI_CRM_Price__c = 100,
                                                    ASI_CRM_EffectiveDate__c = system.today(),
                                                    ASI_CRM_SKU__c = sku.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade')
                                                );
        skuPriceCostList.add(skuPriceCost6);        
        
        ASI_CRM_MY_SKUPriceCost__c skuPriceCost7 = new ASI_CRM_MY_SKUPriceCost__c (
                                                    ASI_CRM_Price__c = 100,
                                                    ASI_CRM_EffectiveDate__c = system.today(),
                                                    ASI_CRM_SKU__c = sku.id,
                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler')
                                                );
        skuPriceCostList.add(skuPriceCost7);        

        insert skuPriceCostList;
        
        return sku;
    }
    
    public static void createSGContractRunningNumber(){
        List<ASI_HK_CRM_Running_Number__c> runingNumberList = new List<ASI_HK_CRM_Running_Number__c>();
       
        runingNumberList.add(new ASI_HK_CRM_Running_Number__c(
                                                                ASI_HK_CRM_Object_Name__c = 'ASI_CRM_SG_Contract_No', 
                                                                ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2, 
                                                                ASI_HK_CRM_Format__c = 'PRS-{YY}-{0000}', 
                                                                ASI_HK_CRM_Running_Number__c = 2
                                                             ));
        insert runingNumberList;
    }
    
    public static void createSGTnERunningNumbers(){
        List<ASI_HK_CRM_Running_Number__c> runningNoList = new List<ASI_HK_CRM_Running_Number__c>();
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Detail', ASI_HK_CRM_Format__c = 'TED-SG-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        runningNoList.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7, ASI_HK_CRM_Fiscal_Year__c = 2015, ASI_HK_CRM_Object_Name__c = 'ASI_TnE_SG_Claim_Header', ASI_HK_CRM_Format__c = 'TE-SG-{YY}-{00000}', ASI_HK_CRM_Running_Number__c = 1));
        insert runningNoList;
    }
    
    public static ASI_TH_CRM_Contract__c createContract(){
                
                // Vincent make changes here, add the outlet to pass validation
				/*[WL 3.0] BEGIN*/
				ASI_CRM_SG_TestClassHelper.createDataSettings();
				/*[WL 3.0] END*/
				
                ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
                
                ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(
                                                                    recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only'),
                                                                    ASI_TH_CRM_Start_Date__c = system.today(),
                                                                    ASI_TH_CRM_End_Date__c = system.today().adddays(365),
                                                                    ASI_TH_CRM_Contract_Status__c = 'Contract Approved',
                                                                    ASI_CRM_CN_Outlet_WS__c = customerC.customer.id,
																	/*[WL 3.0] BEGIN*/
																	ASI_CRM_Type__c = 'Key Account'
																	/*[WL 3.0] END*/
                                                                    );
                                                                    
        insert contract;
        
        return contract;
    }
}