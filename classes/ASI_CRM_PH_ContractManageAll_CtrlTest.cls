@isTest(isParallel=false)
private class ASI_CRM_PH_ContractManageAll_CtrlTest {

	static final String TEST_ACCOUNT_NAME = 'Test Account';

	@TestSetup
	static void setup() {

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

		final ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c();
		customer.Name = 'test customer';
		//customer.ASI_CRM_Account__c = account.Id;
		//customer.ASI_TH_CRM_OutletType__c = outletType.Id;
		customer.ASI_CRM_CN_Address__c = 'address';
		customer.ASI_CRM_Duty_Free__c = false;
		customer.recordtypeid = Global_RecordTypeCache.getRtID('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer');
		insert customer;

		final ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(
				ASI_CRM_CN_Outlet_WS__c = customer.Id,
				ASI_TH_CRM_Start_Date__c = Date.today().toStartOfMonth().addDays(1),
				recordtypeid = Global_RecordTypeCache.getRtID('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
		);
		insert contract;

		final Id skuRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_MFM_SKU_Code__c.sObjectType,
				ASI_CRM_RecordTypeApiName.SkuCode.ASI_CRM_PH_DP_SKU.name()
		);

		final List<ASI_MFM_SKU_Code__c> skus = new List<ASI_MFM_SKU_Code__c>();
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku1',
				RecordTypeId = skuRecordTypeId
		));
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku2',
				RecordTypeId = skuRecordTypeId
		));
		insert skus;

		final Id skuPriceCostRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_MY_SKUPriceCost__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_CRM_MY_SKUPriceCost.ASI_CRM_PH_Outlet_Selling_Price.name()
		);

		final List<ASI_CRM_MY_SKUPriceCost__c> skuPriceCosts = new List<ASI_CRM_MY_SKUPriceCost__c>();
		skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_CRM_Cost__c = 90,
				ASI_CRM_Price__c = 100,
				ASI_CRM_EffectiveDate__c = Date.today().toStartOfMonth(),
				RecordTypeId = skuPriceCostRecordTypeId
		));
		skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
				ASI_CRM_SKU__c = skus.get(1).Id,
				ASI_CRM_Cost__c = 90,
				ASI_CRM_Price__c = 100,
				ASI_CRM_EffectiveDate__c = Date.today().toStartOfMonth(),
				RecordTypeId = skuPriceCostRecordTypeId
		));
		insert skuPriceCosts;

		final List<ASI_CRM_ContractTarget__c> contractTargets = new List<ASI_CRM_ContractTarget__c>();
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
				recordtypeid = Global_RecordTypeCache.getRtID('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')

		));
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(1).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
				recordtypeid = Global_RecordTypeCache.getRtID('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')
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
	}

	@isTest
	static void testConstructor() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractManageAll_Ctrl controller = new ASI_CRM_PH_ContractManageAll_Ctrl(standardController);

		System.assertEquals(controller.contractId, contract.Id);
	}

	@isTest
	static void testSaveRecord_WithException() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractManageAll_Ctrl controller = new ASI_CRM_PH_ContractManageAll_Ctrl(standardController);

		ApexPages.currentPage().getParameters().put('updateContractTargetListJson', 'Invalid JSON');
		controller.saveRecord();
	}

	@isTest
	static void testCancel() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractManageAll_Ctrl controller = new ASI_CRM_PH_ContractManageAll_Ctrl(standardController);
		final PageReference pageReference = controller.cancel();

		System.assert(pageReference != null);
	}

	@isTest
	static void testSaveRecord() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final List<ASI_CRM_ContractTarget__c> contractTargets = ASI_CRM_PH_ContractTestUtil.getContractTargets(contract.Id);
		final List<ASI_CRM_Payment_Schedule__c> contractFundSchemes = ASI_CRM_PH_ContractTestUtil.getContractFundSchemes(contract.Id);
		final List<ASI_CRM_Payment_Schedule__c> purchaseIncentiveSchemes = ASI_CRM_PH_ContractTestUtil.gePurchaseIncentiveSchemes(contract.Id);

		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractManageAll_Ctrl controller = new ASI_CRM_PH_ContractManageAll_Ctrl(standardController);

		ApexPages.currentPage().getParameters().put('updateContractTargetListJson', JSON.serialize(contractTargets));
		System.debug(ApexPages.currentPage().getParameters().get('updateContractTargetListJson'));
		ApexPages.currentPage().getParameters().put('updateSupportMapJson', JSON.serialize(contract));
		ApexPages.currentPage().getParameters().put('updateContractFundSchemeListJson',
				JSON.serialize(contractFundSchemes));
		ApexPages.currentPage().getParameters().put('deleteContractFundSchemeListJson', '[]');
		ApexPages.currentPage().getParameters().put('updatePurchaseIncentiveSchemeListJson',
				JSON.serialize(purchaseIncentiveSchemes));
		ApexPages.currentPage().getParameters().put('deletePurchaseIncentiveSchemeListJson', '[]');
		ApexPages.currentPage().getParameters().put('updateContractTargetMonthlyListJson', '[]');

		controller.saveRecord();
	}

	@isTest
	static void testSaveRecord_WithParseException() {

		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		final ApexPages.StandardController standardController = new ApexPages.StandardController(contract);
		final ASI_CRM_PH_ContractManageAll_Ctrl controller = new ASI_CRM_PH_ContractManageAll_Ctrl(standardController);

		ApexPages.currentPage().getParameters().put('updateContractTargetListJson', 'Invalid Value');
		System.debug(ApexPages.currentPage().getParameters().get('updateContractTargetListJson'));
		ApexPages.currentPage().getParameters().put('updateSupportMapJson', JSON.serialize(contract));
		ApexPages.currentPage().getParameters().put('updateContractFundSchemeListJson',
				JSON.serialize('Invalid JSON'));
		ApexPages.currentPage().getParameters().put('deleteContractFundSchemeListJson', '[]');
		ApexPages.currentPage().getParameters().put('updatePurchaseIncentiveSchemeListJson',
				JSON.serialize('Invalid JSON'));
		ApexPages.currentPage().getParameters().put('deletePurchaseIncentiveSchemeListJson', '[]');
		ApexPages.currentPage().getParameters().put('updateContractTargetMonthlyListJson', '[]');

		controller.saveRecord();
	}

}