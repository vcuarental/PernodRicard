@isTest
public class ASI_CRM_PH_ContractApprovalCtrlTest {

	static final String TEST_ACCOUNT_NAME = 'Test Account';

	@TestSetup
	static void setup() {

		string ownerId = UserInfo.getUserId();
	
		ASI_MFM_Exchange_Rate__c exRate = ASI_CRM_PH_Testfactory.createExchangeRate(Date.newInstance(Date.today().Year() - 1, 9, 1));
        insert exRate;
        
        ASI_HK_CRM_Running_Number__c runningNumber = ASI_CRM_PH_Testfactory.createRunningNumber(Date.today().year() -1);        
        insert runningNumber;
	
        /*
		final ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c();
		outletType.Name = 'test outlet';
		insert outletType;

		final Account account = new Account();
		account.Name = TEST_ACCOUNT_NAME;
		insert account;
		*/

		final list<ASI_CRM_AccountsAdditionalField__c> customers = new list<ASI_CRM_AccountsAdditionalField__c>();
		customers.add(new ASI_CRM_AccountsAdditionalField__c(
			Name = 'test customer',
			//ASI_CRM_Account__c = account.Id,
			//ASI_TH_CRM_OutletType__c = outletType.Id,
			ASI_CRM_CN_Address__c = 'address',
			ASI_CRM_Duty_Free__c = false,
			ownerid = ownerId,
			recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer')
		));
		customers.add(new ASI_CRM_AccountsAdditionalField__c(
			Name = 'test customer2',
			//ASI_CRM_Account__c = account.Id,
			//ASI_TH_CRM_OutletType__c = outletType.Id,
			ASI_CRM_CN_Address__c = 'address',
			ASI_CRM_Duty_Free__c = false,
			ownerid = ownerId,
			recordtypeid = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer')
		));
		insert customers;
		
		ASI_CRM_AccountsAdditionalField__c customer = customers[0];
		ASI_CRM_AccountsAdditionalField__c customer2 = customers[1];

		final list<ASI_TH_CRM_Contract__c> contracts = new list<ASI_TH_CRM_Contract__c>();
		contracts.add(new ASI_TH_CRM_Contract__c(
				ASI_CRM_CN_Outlet_WS__c = customer.Id,
				ASI_TH_CRM_Start_Date__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
				ASI_TH_CRM_End_Date__c = Date.newInstance(Date.today().Year(), 6, 30),
				ASI_CRM_CN_Approval_Status__c = 'Submitted',
				ASI_CRM_Activation_Fund_Amount__c = 10000,
				ASI_CRM_Marketing_Support_Fund_Amount__c = 10000,
				ownerid = ownerId,
				recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
		));
		contracts.add(new ASI_TH_CRM_Contract__c(
				ASI_CRM_CN_Outlet_WS__c = customer2.Id,
				ASI_TH_CRM_Start_Date__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
				ASI_TH_CRM_End_Date__c = Date.newInstance(Date.today().Year(), 6, 30),
				ASI_CRM_CN_Approval_Status__c = 'Submitted',
				ASI_CRM_Activation_Fund_Amount__c = 10000,
				ASI_CRM_Marketing_Support_Fund_Amount__c = 10000,
				ownerid = ownerId,
				recordtypeid = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
		));
		insert contracts;

		ASI_TH_CRM_Contract__c contract = contracts[0];
		ASI_TH_CRM_Contract__c contract2 = contracts[1];
		
		final Id skuRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_MFM_SKU_Code__c.sObjectType,
				ASI_CRM_RecordTypeApiName.SkuCode.ASI_CRM_PH_DP_SKU.name()
		);

		final ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(
				Name = 'Test Brand',
				recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_CRM_PH_DP_Brand')
		);
		insert brand;

		final List<ASI_MFM_Sub_brand__c> subBrands = new List<ASI_MFM_Sub_brand__c>();
		subBrands.add(new ASI_MFM_Sub_brand__c(
				Name = 'Sub Brand',
				ASI_MFM_Brand__c = brand.Id,
				recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_PH_DP_Sub_brand')
		));
		subBrands.add(new ASI_MFM_Sub_brand__c(
				Name = 'Sub Brand2',
				ASI_MFM_Brand__c = brand.Id,
				recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_MFM_PH_DP_Sub_brand')
		));
		insert subBrands;

		final List<ASI_MFM_SKU_Code__c> skus = new List<ASI_MFM_SKU_Code__c>();
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku1',
				RecordTypeId = skuRecordTypeId,
				ASI_MFM_Sub_brand__c = subBrands[0].Id
		));
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku2',
				RecordTypeId = skuRecordTypeId,
				ASI_MFM_Sub_brand__c = subBrands[0].Id
		));
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku3',
				RecordTypeId = skuRecordTypeId,
				ASI_MFM_Sub_brand__c = subBrands[1].Id
		));
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku4',
				RecordTypeId = skuRecordTypeId,
				ASI_MFM_Sub_brand__c = subBrands[1].Id
		));
		insert skus;

		final Id skuPriceCostRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_MY_SKUPriceCost__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_CRM_MY_SKUPriceCost.ASI_CRM_PH_List_Price.name()
		);
		
		final List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = new List<ASI_CRM_MY_SKUPriceCost__c>();

		skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_CRM_Cost__c = 90,
				ASI_CRM_Price__c = 100,
				//ASI_CRM_EffectiveDate__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
				RecordTypeId = skuPriceCostRecordTypeId
		));
		skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
				ASI_CRM_SKU__c = skus.get(1).Id,
				ASI_CRM_Cost__c = 90,
				ASI_CRM_Price__c = 100,
				//ASI_CRM_EffectiveDate__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
				RecordTypeId = skuPriceCostRecordTypeId
		));
		skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
				ASI_CRM_SKU__c = skus.get(2).Id,
				ASI_CRM_Cost__c = 90,
				ASI_CRM_Price__c = 100,
				//ASI_CRM_EffectiveDate__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
				RecordTypeId = skuPriceCostRecordTypeId
		));
		skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
				ASI_CRM_SKU__c = skus.get(3).Id,
				ASI_CRM_Cost__c = 90,
				ASI_CRM_Price__c = 100,
				//ASI_CRM_EffectiveDate__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
				RecordTypeId = skuPriceCostRecordTypeId
		));
		insert skuPriceCosts;

		Id contractTargetRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_ContractTarget__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_CRM_ContractTarget.ASI_CRM_PH_Contract_Target.name()
		);
		final List<ASI_CRM_ContractTarget__c> contractTargets = new List<ASI_CRM_ContractTarget__c>();
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
				RecordTypeId = contractTargetRecordTypeId
		));
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(1).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
				RecordTypeId = contractTargetRecordTypeId
		));
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(2).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
				RecordTypeId = contractTargetRecordTypeId
		));
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract2.Id,
				ASI_CRM_SKU__c = skus.get(3).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
				RecordTypeId = contractTargetRecordTypeId
		));
		insert contractTargets;

		Id contractFundSchemeRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_Payment_Schedule__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_CRM_Payment_Schedule.ASI_CRM_PH_Contract_Fund.name()
		);
		final List<ASI_CRM_Payment_Schedule__c> contractFundSchemes = new List<ASI_CRM_Payment_Schedule__c>();
		contractFundSchemes.add(new ASI_CRM_Payment_Schedule__c(
				ASI_CRM_Contract__c = contract.Id,
				RecordTypeId = contractFundSchemeRecordTypeId
		));

		insert contractFundSchemes;

		Id purchaseIncentiveSchemeRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_Payment_Schedule__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_CRM_Payment_Schedule.ASI_CRM_PH_Purchase_Incentive.name()
		);
		final List<ASI_CRM_Payment_Schedule__c> purchaseIncentiveSchemes = new List<ASI_CRM_Payment_Schedule__c>();
		purchaseIncentiveSchemes.add(new ASI_CRM_Payment_Schedule__c(
				ASI_CRM_Contract__c = contract.Id,
				RecordTypeId = purchaseIncentiveSchemeRecordTypeId
		));

		insert purchaseIncentiveSchemes;

		final ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c(
				ASI_TH_CRM_Contract__c = contract.Id,
				ASI_TH_CRM_Status__c = 'Draft',
				recordtypeid = Global_RecordTypeCache.getRtID('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request')
		);
		insert paymentRequest;

		final Id paymentRequestItemRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_TH_CRM_PaymentRequestLineItem__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_TH_CRM_PaymentRequestLineItem.ASI_CRM_PH_Payment_Request_Detail.name()
		);
		final List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestItems =
				new List<ASI_TH_CRM_PaymentRequestLineItem__c>();
		paymentRequestItems.add(new ASI_TH_CRM_PaymentRequestLineItem__c(
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_TH_CRM_Payment_Request__c = paymentRequest.Id,
				RecordTypeId = paymentRequestItemRecordTypeId
		));
		insert paymentRequestItems;

		final ASI_MFM_A_C_Code__c acCode = new ASI_MFM_A_C_Code__c(
			ASI_MFM_A_C_Code__c = '5559.000000',
			recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_A_C_Code__cASI_MFM_PH_DP_A_C_Code')
		);
		insert acCode;

		final Id budgetRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_MFM_Budget__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_MFM_Budget.ASI_MFM_PH_DP_Budget.name()
		);
		final Map<String, Integer> budgetTypeOrder = new Map<String, Integer>{'LE3' => 1, 'LE2' => 2, 'LE1' => 3, 'Budget' => 4};
		final list<ASI_MFM_Budget__c> budgets = new list<ASI_MFM_Budget__c>();
		for(ASI_MFM_Sub_brand__c sb : subBrands){
			for(string type : budgetTypeOrder.keySet()){
				budgets.add(new ASI_MFM_Budget__c(
					ASI_CRM_Salesperson__c = contract.OwnerId,
					ASI_MFM_PH_Effective_Date__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
					ASI_MFM_Sub_brand_Code__c = sb.Id,
					ASI_MFM_Type__c = type,
					RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Budget__cASI_MFM_PH_DP_Budget'),
					ASI_MFM_A_C_Code__c = acCode.id,
					ASI_MFM_P1_Amount__c = 1000, ASI_MFM_P2_Amount__c = 1000, ASI_MFM_P3_Amount__c = 1000,
					ASI_MFM_P4_Amount__c = 1000, ASI_MFM_P5_Amount__c = 1000, ASI_MFM_P6_Amount__c = 1000,
					ASI_MFM_P7_Amount__c = 1000, ASI_MFM_P8_Amount__c = 1000, ASI_MFM_P9_Amount__c = 1000,
					ASI_MFM_P10_Amount__c = 1000, ASI_MFM_P11_Amount__c = 1000, ASI_MFM_P12_Amount__c = 1000
				));
			}
			
		}
		insert budgets;

		//		[select ASI_CRM_SG_Amount__c, ASI_FOC_SKU__c, ASI_FOC_SKU__r.ASI_MFM_Sub_brand__c,
		//		ASI_FOC_SKU__r.ASI_MFM_Sub_brand__r.Name
		//		from ASI_FOC_Request_Item__c
		//		where ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c >= :contract.ASI_TH_CRM_Start_Date__c
		//		and ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c <= :contract.ASI_TH_CRM_End_Date__c
		//		and ASI_FOC_Request_Order__r.ASI_CRM_Contract__r.ASI_CRM_CN_Approval_Status__c = 'Completed']

		final ASI_FOC_Free_Goods_Request__c focRequestOrder = new ASI_FOC_Free_Goods_Request__c(
				ASI_CRM_Contract__c = contract.Id,
				recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_PH_Contract_FOC_POSM_Request')
		);
		insert focRequestOrder;

		final ASI_FOC_Request_Item__c focRequestItem = new ASI_FOC_Request_Item__c(
			ASI_FOC_SKU__c = skus.get(0).Id,
			ASI_FOC_Request_Order__c = focRequestOrder.Id,
			ASI_CRM_SG_Unit_Price__c = 100,
			ASI_FOC_Request_Quantity_Bottle__c = 1,
			recordtypeid = Global_RecordTypeCache.getRTId('ASI_FOC_Request_Item__cASI_CRM_PH_FOC_POSM_Request_Item')
		);
		insert focRequestItem;
		/*
		focRequestItem.ASI_CRM_SG_Unit_Price__c  = 100;
		focRequestItem.ASI_FOC_Request_Quantity_Bottle__c   = 1;

		update focRequestItem;
		*/

	}

	@isTest
	static void testConstructor() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractSubmitApproval_Ctrl controller =
				new ASI_CRM_PH_ContractSubmitApproval_Ctrl(standardController);

	}

	@isTest
	static void testRedirect() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractSubmitApproval_Ctrl controller =
				new ASI_CRM_PH_ContractSubmitApproval_Ctrl(standardController);

		Test.startTest();
		try {
			controller.redirect();
		} catch (Exception e) {

		}
		Test.stopTest();
	}

	@isTest
	static void testRedirect_CompletedContract() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		contract.ASI_CRM_CN_Approval_Status__c = 'Completed';
		update contract;
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractSubmitApproval_Ctrl controller =
				new ASI_CRM_PH_ContractSubmitApproval_Ctrl(standardController);

		Test.startTest();
		try {
			controller.redirect();
		} catch (Exception e) {

		}
		Test.stopTest();
	}

	@isTest
	static void testYearlyOverBudget() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractSubmitApproval_Ctrl controller =
				new ASI_CRM_PH_ContractSubmitApproval_Ctrl(standardController);

		Test.startTest();
		try {
			controller.yearlyOverBudget(new Set<ASI_MFM_Budget__c>(), 1000, Date.today(), Date.today(), '', '', '');
		} catch (Exception e) {
		}
		Test.stopTest();
	}

	@isTest
	static void testYearlyOverZeroBudget() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractSubmitApproval_Ctrl controller =
				new ASI_CRM_PH_ContractSubmitApproval_Ctrl(standardController);

		Test.startTest();
		try {
			controller.yearlyOverBudget(new Set<ASI_MFM_Budget__c>(), 0, Date.today(), Date.today(), '', '', '');
		} catch (Exception e) {
		}
		Test.stopTest();
	}

	@isTest
	static void testPrivateMethods() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractSubmitApproval_Ctrl controller =
				new ASI_CRM_PH_ContractSubmitApproval_Ctrl(standardController);

	}

	@isTest
	static void testDoFormatting() {
		ASI_CRM_PH_ContractSubmitApproval_Ctrl.doFormatting(10.00, 2, ',', '.');
		ASI_CRM_PH_ContractSubmitApproval_Ctrl.doFormatting(100000.00, 2, ',', '.');
		ASI_CRM_PH_ContractSubmitApproval_Ctrl.doFormatting(-100000.00, 2, ',', '.');
		ASI_CRM_PH_ContractSubmitApproval_Ctrl.doFormatting(-100000.00, 0, ',', '.');
	}

	@isTest
	static void testPrice() {
		list<ASI_CRM_MY_SKUPriceCost__c> skuPrices = [select id from ASI_CRM_MY_SKUPriceCost__c];
		for(ASI_CRM_MY_SKUPriceCost__c p : skuPrices){
			p.ASI_CRM_EffectiveDate__c = Date.newInstance(Date.today().Year() - 1, 7, 1);
		}
		update skuPrices;
		
		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		contract.ASI_CRM_CN_Approval_Status__c = 'Completed';
		update contract;
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractSubmitApproval_Ctrl controller =
				new ASI_CRM_PH_ContractSubmitApproval_Ctrl(standardController);

		Test.startTest();
		try {
			controller.redirect();
		} catch (Exception e) {

		}
		Test.stopTest();
	}
	
	@isTest
	static void testContractTrigger() {
		
		Test.startTest();
		final List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = new List<ASI_CRM_MY_SKUPriceCost__c>();
		final list<string> list_priceCostRTID = new list<string>{
			Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Outlet_Selling_Price'),
			Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_List_Price'),
			Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Duty_Excise_Tax'),
			Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_SKU_Handling_Cost'),
			Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_COGS'),
			Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_Standard_Cost'),
			Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_PH_DP_Distribution_Cost')
		};
		
		list<ASI_MFM_SKU_Code__c> skus = [select id from ASI_MFM_SKU_Code__c];
		for(ASI_CRM_AccountsAdditionalField__c c : [select id from ASI_CRM_AccountsAdditionalField__c]){
			for(string rtId : list_priceCostRTID){
				for(ASI_MFM_SKU_Code__c sku : skus){
					skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
						ASI_CRM_SKU__c = sku.Id,
						ASI_CRM_Cost__c = 90,
						ASI_CRM_Price__c = 100,
						ASI_CRM_EffectiveDate__c = Date.newInstance(Date.today().Year() - 1, 7, 1),
						RecordTypeId = rtId,
						ASI_CRM_Customer__c = c.id
					));
				}
					
			}
		}
		insert skuPriceCosts;
		
		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		
		delete [select id from ASI_CRM_ContractTarget__c where ASI_CRM_Contract__c = :contract.Id];
		
		Id contractTargetRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_ContractTarget__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_CRM_ContractTarget.ASI_CRM_PH_Contract_Target.name()
		);
		final List<ASI_CRM_ContractTarget__c> contractTargets = new List<ASI_CRM_ContractTarget__c>();
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
				RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')
		));
		insert contractTargets;

		Test.stopTest();
	}
	
}