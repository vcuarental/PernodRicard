/*********************************************************************************
 * Name:ASI_CRM_SG_FreeGoodsRequest_Test
 * Description: Test all related code to the object Free Goods Request
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 19/03/2015       Laputa: Conrad          Created
 * 04/08/2016       Laputa: Hugo Cheung     Updated. Add test setup function   
 * 13/02/2017       Wilken Lee		        Updated. Add Delete FOC trigger test
 * 12/12/2017       Wilken Lee		        [WL 1.0] Add test coverage for P4.1
 * 17/06/2018       Wilken Lee		        [WL 2.0] Add test coverage for P4.2 ASI_CRM_SG_FreeGoodsController
*********************************************************************************/
@isTest
public class ASI_CRM_SG_FreeGoodsRequest_Test {

    @TestSetup
    public static void setupTestData() {
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        List<ASI_MFM_SKU_Code__c> skuList = ASI_CRM_SG_TestClassHelper.createSKUandPRiceData();

        ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(false);
        ASI_CRM_SG_TestClassHelper.customerData customerWhole1 = new ASI_CRM_SG_TestClassHelper.customerData(false, 'TestCustomer1');
        ASI_CRM_SG_TestClassHelper.customerData customerWhole2 = new ASI_CRM_SG_TestClassHelper.customerData(false, 'TestCustomer2');
        

        List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        customerList.add(customerC.customer);
        customerList.add(customerWhole1.customer);
        customerList.add(customerWhole2.customer);
        insert customerList;

        //ASI_CRM_SG_TestClassHelper.customerData customerC2 = new ASI_CRM_SG_TestClassHelper.customerData(true, customerC.customer);
  
		/*[WL 1.0] BEGIN*/
        //ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(true, customerC.customer, 'Contract Approved');
		ASI_CRM_SG_TestClassHelper.contractData contractC = new ASI_CRM_SG_TestClassHelper.contractData(false, customerC.customer, 'Contract Approved');
		contractC.contract.ASI_CRM_Contract_Exist_Before_RTM__c = true;
		insert contractC.contract;
		/*[WL 1.0] END*/
		
        ASI_CRM_SG_TestClassHelper.contractTargetData contractTargetC1 = new ASI_CRM_SG_TestClassHelper.contractTargetData(false, contractC.contract, skuList.get(4));
        contractTargetC1.contractTarget.ASI_CRM_SG_Events_Free_Bottles__c = 5;
        contractTargetC1.contractTarget.ASI_CRM_SG_Good_in_Kinds__c = 500;
        contractTargetC1.contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c = 5;
        insert contractTargetC1.contractTarget;

        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodR = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false, contractC.contract, 'ASI_CRM_SG_FOC');

        freeGoodR.freeGoods.ASI_CRM_Contract__c = contractC.contract.id;
        freeGoodR.freeGoods.ASI_CRM_Outlet__c = contractC.contract.ASI_CRM_CN_Outlet_WS__c;

        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodR2 = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false, contractC.contract, 'ASI_CRM_SG_FOC', 'Submitted');
        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodR3 = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false, contractC.contract, 'ASI_CRM_SG_FOC_Read_Only', 'Submitted');
        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodR4 = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false, contractC.contract, 'ASI_CRM_SG_POSM');

        //System Generated FOC for testing Split FOC by Outlet
        ASI_CRM_SG_TestClassHelper.freeGoodsData freeGoodR5 = new ASI_CRM_SG_TestClassHelper.freeGoodsData(false, contractC.contract, 'ASI_CRM_SG_FOC', 'Draft');

        freeGoodR5.freeGoods.ASI_CRM_Contract__c = contractC.contract.id;
        freeGoodR5.freeGoods.ASI_CRM_Outlet__c = contractC.contract.ASI_CRM_CN_Outlet_WS__c;
        freeGoodR5.freeGoods.ASI_CRM_SG_Month__c = string.ValueOf(System.Today().month());
        freeGoodR5.freeGoods.ASI_CRM_SG_Year__c = string.ValueOf(System.Today().year());
        freeGoodR5.freeGoods.ASI_CRM_SG_System_Generated__c = true;
        freeGoodR5.freeGoods.ASI_FOC_Delivery_Instruction_1__c = 'Testing Request 5';
        
        List<ASI_FOC_Free_Goods_Request__c> freeGoodList = new List<ASI_FOC_Free_Goods_Request__c>();
        freeGoodList.add(freeGoodR.freeGoods);
        freeGoodList.add(freeGoodR2.freeGoods);
        freeGoodList.add(freeGoodR3.freeGoods);
        freeGoodList.add(freeGoodR4.freeGoods);
        freeGoodList.add(freeGoodR5.freeGoods);
        insert freeGoodList;

        //ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(1));
        //ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR2 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(1));
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR3 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR2.freeGoods, skuList.get(0));
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR4 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR3.freeGoods, skuList.get(0));
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR5 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR4.freeGoods, skuList.get(2));
        freeGoodItemR3.freeGoodsItem.ASI_FOC_Actual_Quantity_Bottle__c = 2;
        freeGoodItemR3.freeGoodsItem.ASI_FOC_Request_Quantity_Bottle__c = 1;
        freeGoodItemR3.freeGoodsItem.ASI_CRM_Adjustment_Remarks__c = 'testingAdjustmentRemark8CharactersMin';
        freeGoodItemR4.freeGoodsItem.ASI_FOC_Actual_Quantity_Bottle__c = 2;
        freeGoodItemR4.freeGoodsItem.ASI_FOC_Request_Quantity_Bottle__c = 1;
        freeGoodItemR4.freeGoodsItem.ASI_CRM_Adjustment_Remarks__c = 'testingAdjustmentRemark8CharactersMin';
        freeGoodItemR5.freeGoodsItem.ASI_FOC_Actual_Quantity_Bottle__c = 2;
        freeGoodItemR5.freeGoodsItem.ASI_FOC_Request_Quantity_Bottle__c = 1;
        freeGoodItemR5.freeGoodsItem.ASI_CRM_Adjustment_Remarks__c = 'testingAdjustmentRemark8CharactersMin';
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR6 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(0), 'Cash Sponsorship');
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR7 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(0), 'Sales Incentive');
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR8 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(0), 'Adhoc Promotion/Sponsorship');
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR9 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(0), 'Anniversary');
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR11 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(1), 'Sampling');
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR12 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR.freeGoods, skuList.get(1), 'Events');
		
		//FOC Item for Split By Outlet Test Method
        ASI_CRM_SG_TestClassHelper.freeGoodsItemData freeGoodItemR10 = new ASI_CRM_SG_TestClassHelper.freeGoodsItemData(false, freeGoodR5.freeGoods, skuList.get(0), 'Sales Incentive',20);

        freeGoodItemR6.freeGoodsItem.ASI_CRM_Wholesaler__c = customerWhole1.customer.id;
        freeGoodItemR7.freeGoodsItem.ASI_CRM_Wholesaler__c = customerWhole2.customer.id;

        List<ASI_FOC_Request_Item__c> freeGoodsItemDataList = new List<ASI_FOC_Request_Item__c>();
        //freeGoodsItemDataList.add(freeGoodItemR.freeGoodsItem);
        //freeGoodsItemDataList.add(freeGoodItemR2.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR3.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR4.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR5.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR6.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR7.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR8.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR9.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR10.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR11.freeGoodsItem);
        freeGoodsItemDataList.add(freeGoodItemR12.freeGoodsItem);
        insert freeGoodsItemDataList;

        //Actual Offtake Test Data
        ASI_CRM_SG_TestClassHelper.offtakeData offtake = new ASI_CRM_SG_TestClassHelper.offtakeData(false, 'ASI_CRM_SG_Actual_offtake', contractC.contract.id, customerC.customer.id, skuList.get(0).id);
        
    }

    public static testmethod void testTrigger() {
        List<ASI_FOC_Request_Item__c> freeGoodsItemDataList = [SELECT Id FROM ASI_FOC_Request_Item__c where ASI_FOC_Request_Order__r.RecordType.DeveloperName = 'ASI_CRM_SG_FOC'];
		
		test.starttest();
        try{			
            delete freeGoodsItemDataList;
        } catch(exception ex) {
            //Catch protection delete validation trigger error
        }
		test.stoptest();
    }
    
	public static testmethod void testDeleteFOCTrigger() {
		List<ASI_FOC_Free_Goods_Request__c> freeGoodList = [SELECT Id, ASI_CRM_Contract__c,ASI_CRM_SG_Month__c, ASI_CRM_SG_Year__c  FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC')];
		
		ASI_CRM_SG_FOC_Carry_Over__c carryOver = new ASI_CRM_SG_FOC_Carry_Over__c(recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_SG_FOC_Carry_Over__cASI_CRM_SG_FOC_Carry_Over'), 
			ASI_CRM_SG_Contract__c = freeGoodList.get(0).ASI_CRM_Contract__c,
			ASI_CRM_SG_Month__c = Integer.ValueOf(freeGoodList.get(0).ASI_CRM_SG_Month__c),
			ASI_CRM_SG_Year__c = freeGoodList.get(0).ASI_CRM_SG_Year__c);
		
		insert carryOver;
		
		test.starttest();
        try{			
            delete freeGoodList;
        } catch(exception ex) {
            //Catch protection delete validation trigger error
        }
		test.stoptest();
    }
	
    public static testmethod void testsubmitForApproval_Controller () {
        
        List<ASI_FOC_Free_Goods_Request__c> freeGoodList = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId != :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC_Read_Only')];

        test.starttest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(freeGoodList.get(0));
        ASI_CRM_SG_FGSubmitForApp_Controller submitFreeGoodsCon = new ASI_CRM_SG_FGSubmitForApp_Controller(sc);
        submitFreeGoodsCon.redirect();
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(freeGoodList.get(1));
        ASI_CRM_SG_FGSubmitForApp_Controller submitFreeGoodsCon2 = new ASI_CRM_SG_FGSubmitForApp_Controller(sc2);
        submitFreeGoodsCon2.redirect();
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(freeGoodList.get(2));
        ASI_CRM_SG_FGSubmitForApp_Controller submitFreeGoodsCon3 = new ASI_CRM_SG_FGSubmitForApp_Controller(sc3);
        submitFreeGoodsCon3.redirect();
        
		
        test.stoptest();
        
    }
	
	
    public static testmethod void testFreeGoodsItem_Controller () {
        
        test.starttest();
        ASI_FOC_Free_Goods_Request__c freeGoods = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC') AND ASI_FOC_Request_Status__c != 'Submitted' LIMIT 1];
        ASI_MFM_SKU_Code__c sku = [SELECT Id FROM ASI_MFM_SKU_Code__c WHERE Name = 'Test Sku 1'];

        PageReference pageRef = Page.ASI_CRM_SG_FreeGoodsItem_Page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', freeGoods.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(freeGoods);
        ASI_CRM_SG_FreeGoodsItem_Controller freeGoodsController = new ASI_CRM_SG_FreeGoodsItem_Controller(sc);
        freeGoodsController.setSubBrandSelectOptions();
        freeGoodsController.retrieveSKUbySubBrand();
        Map<ID, Integer> tempTest = freeGoodsController.retrieveSKUCommittedQty();
        System.currentPageReference().getParameters().put('PARAM_FREEGOOD_SOURCE_ITEM_ID', sku.id);
        freeGoodsController.addRequestItem();
        System.currentPageReference().getParameters().put('PARAM_FREEGOODS_SKU_ID', 'zzzzzITEMLINEZ0');
        freeGoodsController.removeRequestSKU();
        freeGoodsController.saveRequestItem();
        freeGoodsController.cancel();
        freeGoodsController.newCounterCreatorLine();
		
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
			freeGoods.ASI_FOC_Request_Status__c = 'Final';
			update freeGoods;
			
			ApexPages.StandardController sc2 = new ApexPages.StandardController(freeGoods);
			ASI_CRM_SG_FreeGoodsController freeGoodsController2 = new ASI_CRM_SG_FreeGoodsController(sc2);
			freeGoodsController2.setToDraft();
		}
		/*[WL 2.0] END*/
        test.stoptest();
        
    }
    
    public static testmethod void testFreeGoodsItem_Validation () {
        
        test.starttest();
        ASI_FOC_Free_Goods_Request__c freeGoods = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC') AND ASI_FOC_Request_Status__c != 'Submitted' LIMIT 1];
        ASI_MFM_SKU_Code__c sku = [SELECT Id, ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c, ASI_HK_CRM_Available_Quantity__c, ASI_HK_CRM_Packaging_Size__c FROM ASI_MFM_SKU_Code__c WHERE Name = 'Test Sku 2'];

        PageReference pageRef = Page.ASI_CRM_SG_FreeGoodsItem_Page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', freeGoods.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(freeGoods);
        ASI_CRM_SG_FreeGoodsItem_Controller freeGoodsController = new ASI_CRM_SG_FreeGoodsItem_Controller(sc);
        
        freeGoodsController.setSubBrandSelectOptions();
        freeGoodsController.retrieveSKUbySubBrand();
        Map<ID, Integer> tempTest = freeGoodsController.retrieveSKUCommittedQty();
        System.currentPageReference().getParameters().put('PARAM_FREEGOOD_SOURCE_ITEM_ID', sku.id);
		
		/*[WL 1.0] BEGIN*/
		freeGoodsController.allSKUMap.put(sku.id, sku);
		/*[WL 1.0] END*/
		
        freeGoodsController.addRequestItem();
        freeGoodsController.saveRequestItem();
		
		/*[WL 1.0] BEGIN*/
		freeGoodsController.setFOCTypeSelectOptions();
		/*[WL 1.0] END*/
        test.stoptest();
        
    }
    
    public static testmethod void testSplitFOC_Controller () {
        test.starttest();
        ASI_FOC_Free_Goods_Request__c freeGoods = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC') AND ASI_FOC_Request_Status__c != 'Submitted' LIMIT 1];
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id, Name FROM ASI_CRM_AccountsAdditionalField__c WHERE Name = 'TestCustomer1' LIMIT 1];

        
        PageReference pageRef = Page.ASI_CRM_SG_SplitFOC_Page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', freeGoods.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(freeGoods);
        ASI_CRM_SG_SplitFOC_Controller splitFOCController = new ASI_CRM_SG_SplitFOC_Controller(sc);
        splitFOCController.wholeSalerSelected = customer.name;
        splitFOCController.setwholeSalerSelectOptions();
        splitFOCController.split();
        test.stoptest();
    }
    
    public static testmethod void testSplitFOCByOutlet_Controller () {
        ASI_FOC_Free_Goods_Request__c freeGoods = [SELECT Id FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC') AND ASI_FOC_Delivery_Instruction_1__c = 'Testing Request 5' LIMIT 1];
        test.starttest();
        
        PageReference pageRef = Page.ASI_CRM_SG_SplitFOCByOutlet_Page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', freeGoods.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(freeGoods);
        ASI_CRM_SG_SplitFOCByOutlet_Controller splitFOCController = new ASI_CRM_SG_SplitFOCByOutlet_Controller(sc);
        
        splitFOCController.init();
        splitFOCController.focItemWrapperList.get(0).outlet0Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet1Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet2Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet3Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet4Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet5Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet6Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet7Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet8Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet9Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet10Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet11Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet12Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet13Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet14Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet15Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet16Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet17Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet18Qty = 1;
		splitFOCController.focItemWrapperList.get(0).outlet19Qty = 1;
        system.debug(' FOC Item Wrapper First Item: ' + splitFOCController.focItemWrapperList.get(0));
        splitFOCController.split();

        test.stoptest();
    }

    public static testmethod void testFreeGoodsItem_trigger1 () {
        
        ASI_FOC_Free_Goods_Request__c freeGoods = [SELECT Id, ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC') AND ASI_FOC_Request_Status__c != 'Submitted' LIMIT 1];
              
        test.starttest();
        freeGoods.ASI_FOC_Request_Status__c = 'Draft';
        update freeGoods;
        test.stoptest();
        
    }
    
    public static testmethod void testFreeGoodsItem_trigger2 () {
        ASI_FOC_Free_Goods_Request__c freeGoods = [SELECT Id, ASI_FOC_Request_Status__c FROM ASI_FOC_Free_Goods_Request__c WHERE RecordTypeId = :Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC') AND ASI_FOC_Request_Status__c != 'Submitted' LIMIT 1];
        
        test.starttest();
        freeGoods.ASI_FOC_Request_Status__c = 'Approved';
        update freeGoods;
        
        test.stoptest();
        
    }
    
}