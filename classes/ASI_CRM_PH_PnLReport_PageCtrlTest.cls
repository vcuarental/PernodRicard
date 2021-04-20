@isTest
public class ASI_CRM_PH_PnLReport_PageCtrlTest {

	static final String TEST_ACCOUNT_NAME = 'Test Account';
	static final Date startDate = Date.newInstance(Date.today().Year() - 1, 7, 1);
	static final Date endDate = Date.newInstance(Date.today().Year(), 6, 30);

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
				ASI_TH_CRM_Start_Date__c = startDate,
				ASI_TH_CRM_End_Date__c = endDate,
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
				ASI_CRM_EffectiveDate__c = startDate,
				RecordTypeId = skuPriceCostRecordTypeId
		));
		skuPriceCosts.add(new ASI_CRM_MY_SKUPriceCost__c(
				ASI_CRM_SKU__c = skus.get(1).Id,
				ASI_CRM_Cost__c = 90,
				ASI_CRM_Price__c = 100,
				ASI_CRM_EffectiveDate__c = startDate,
				RecordTypeId = skuPriceCostRecordTypeId
		));
		insert skuPriceCosts;

		final List<ASI_CRM_ContractTarget__c> contractTargets = new List<ASI_CRM_ContractTarget__c>();
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
            	recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')

		));
		contractTargets.add(new ASI_CRM_ContractTarget__c(
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SKU__c = skus.get(1).Id,
				ASI_CRM_Target_Total_Bottle__c = 10,
            	recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_PH_Contract_Target')
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

		final Id offtakeHeaderRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_CRM_ActualOfftakeHeader__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ActualOfftakeHeader.ASI_CRM_PH_Actual_Offtake_Header.name()
		);
		final ASI_CRM_ActualOfftakeHeader__c offtakeHeader = new ASI_CRM_ActualOfftakeHeader__c(
				RecordTypeId = offtakeHeaderRecordTypeId,
				ASI_CRM_OfftakeDate__c = startDate
		);
		insert offtakeHeader;

		final Id offtakeRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_TH_CRM_Actual_Offtake__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ActualOfftake.ASI_CRM_PH_Actual_Offtake.name()
		);
		final List<ASI_TH_CRM_Actual_Offtake__c> offtakes = new List<ASI_TH_CRM_Actual_Offtake__c>();
		offtakes.add(new ASI_TH_CRM_Actual_Offtake__c(
				ASI_CRM_ActualOfftakeHeader__c = offtakeHeader.Id,
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SG_Customer__c = customer.Id,
				ASI_TH_CRM_Offtake_G_L_Date__c = startDate.addDays(2),
				RecordTypeId = offtakeRecordTypeId,
				ASI_CRM_SKU__c = skus.get(0).Id
		));
		offtakes.add(new ASI_TH_CRM_Actual_Offtake__c(
				ASI_CRM_ActualOfftakeHeader__c = offtakeHeader.Id,
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SG_Customer__c = customer.Id,
				ASI_TH_CRM_Offtake_G_L_Date__c = startDate.addDays(2),
				RecordTypeId = offtakeRecordTypeId,
				ASI_CRM_SKU__c = skus.get(1).Id
		));
		insert offtakes;


		final ASI_TH_CRM_PaymentRequest__c paymentRequest = new ASI_TH_CRM_PaymentRequest__c(
				ASI_TH_CRM_Contract__c = contract.Id,
				ASI_TH_CRM_Status__c = 'Draft',
				recordtypeid = Global_RecordTypeCache.getRtID('ASI_TH_CRM_PaymentRequest__cASI_CRM_PH_Payment_Request_Read_Only')
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

	}

	@isTest
	static void testConstructor() {
		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		ApexPages.currentPage().getParameters().put('contractId', contract.Id);
		new ASI_CRM_PH_PnLReport_PageCtrl();
	}

	@isTest
	static void testConstructorWithCustomer() {
		final ASI_TH_CRM_Contract__c contract = ASI_CRM_PH_ContractTestUtil.getContract();
		ApexPages.currentPage().getParameters().put('customerId', contract.ASI_CRM_CN_Outlet_WS__c);
		new ASI_CRM_PH_PnLReport_PageCtrl();
	}

}