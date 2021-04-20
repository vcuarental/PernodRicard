@isTest
public class ASI_CRM_PH_MassUploadByBatchCtrlTest {

	static final String TEST_ACCOUNT_NAME = 'Test Account';
	static final Date startDate = Date.newInstance(Date.today().Year() - 1, 7, 1);
	static final Date endDate = Date.newInstance(Date.today().Year(), 6, 30);
	static final String OFFTAKE_CSV_FILENAME = 'offtakes.csv';

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
		customer.ASI_CRM_MY_CustomerCode__c = 'C001';
		customer.recordtypeid = Global_RecordTypeCache.getRtID('ASI_CRM_AccountsAdditionalField__cASI_CRM_PH_Customer');

		insert customer;

		final Id contractRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_TH_CRM_Contract__c.sObjectType,
				ASI_CRM_RecordTypeApiName.ASI_TH_CRM_Contract.ASI_CRM_PH_Contract_Read_Only.name()
		);

		final ASI_TH_CRM_Contract__c contract = new ASI_TH_CRM_Contract__c(
				ASI_CRM_CN_Outlet_WS__c = customer.Id,
				ASI_TH_CRM_Start_Date__c = startDate,
				ASI_TH_CRM_End_Date__c = endDate,
				recordtypeid = Global_RecordTypeCache.getRtID('ASI_TH_CRM_Contract__cASI_CRM_PH_Contract')
		);
		insert contract;

		contract.RecordTypeId = contractRecordTypeId;
		update contract;

		final Id skuRecordTypeId = ASI_CRM_RecordTypeUtil.getRecordTypeIdByApiName(
				ASI_MFM_SKU_Code__c.sObjectType,
				ASI_CRM_RecordTypeApiName.SkuCode.ASI_CRM_PH_DP_SKU.name()
		);

		final List<ASI_MFM_SKU_Code__c> skus = new List<ASI_MFM_SKU_Code__c>();
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku1',
				ASI_MFM_SKU_Code__c = 'AEL275',
				RecordTypeId = skuRecordTypeId
		));
		skus.add(new ASI_MFM_SKU_Code__c(
				Name = 'test sku2',
				ASI_MFM_SKU_Code__c = '01123C',
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
				RecordTypeId = purchaseIncentiveSchemeRecordTypeId,
				ASI_CRM_Target_Start_Date__c = startDate,
				ASI_CRM_Target_End_Date__c = endDate,
				ASI_CRM_Sys_Parent_record__c = true
		));
		purchaseIncentiveSchemes.add(new ASI_CRM_Payment_Schedule__c(
				ASI_CRM_Contract__c = contract.Id,
				RecordTypeId = purchaseIncentiveSchemeRecordTypeId,
				ASI_CRM_Target_Start_Date__c = startDate,
				ASI_CRM_Target_End_Date__c = endDate
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
		//		ASI_CRM_Year__c = offtakeHeaderYear,
		//		ASI_CRM_Month__c = offtakeHeaderMonth,
		//		ASI_CRM_All_Offtakes_Removed__c = false,
		//		ASI_CRM_Upload_Failed__c = false
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
				ASI_CRM_SKU__c = skus.get(0).Id,
				ASI_CRM_Original_Quantity__c = 10,
				ASI_CRM_Outlet_Selling_Price__c = 10
		));
		offtakes.add(new ASI_TH_CRM_Actual_Offtake__c(
				ASI_CRM_ActualOfftakeHeader__c = offtakeHeader.Id,
				ASI_CRM_Contract__c = contract.Id,
				ASI_CRM_SG_Customer__c = customer.Id,
				ASI_TH_CRM_Offtake_G_L_Date__c = startDate.addDays(2),
				RecordTypeId = offtakeRecordTypeId,
				ASI_CRM_SKU__c = skus.get(1).Id,
				ASI_CRM_Original_Quantity__c = 10,
				ASI_CRM_Outlet_Selling_Price__c = 10
		));
		insert offtakes;


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
	}

	@isTest
	static void testController() {
		final ASI_CRM_PH_MassUploadByBatchController c = new ASI_CRM_PH_MassUploadByBatchController();

		c.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
		c.recordtypeName = 'ASI CRM SG Actual Offtake';
		c.defaultValues = 'Type (Uploaded):Off-Trade';
		c.fields = 'Name,ASI_TH_CRM_Quantity__c';
		c.fieldsLabel = 'Name,Quantity';
		c.emailNotification = true;
		c.init();

		c.refreshPage();
		c.refreshPage2();

		ASI_CRM_PH_MassUploadByBatchController.Row r =
				new ASI_CRM_PH_MassUploadByBatchController.Row(new Account(), 'Name', '');

		ASI_CRM_PH_MassUploadByBatchController.Row r1 =
				new ASI_CRM_PH_MassUploadByBatchController.Row(new Account());

		r1.addError('Error');

		System.assert(r != null);
		System.assert(r1 != null);
	}

	@isTest
	static void testControllerWithoutEmailNotification() {
		final ASI_CRM_PH_MassUploadByBatchController c = new ASI_CRM_PH_MassUploadByBatchController();

		c.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
		c.recordtypeName = 'ASI CRM SG Actual Offtake';
		c.defaultValues = 'Type (Uploaded):Off-Trade';
		c.fields = 'Id,Name';
		c.fieldsLabel = 'Name,Quantity';
		c.emailNotification = false;
		c.init();
	}

	@isTest
	static void testUploadInvalidFile() {

		final ASI_CRM_PH_MassUploadByBatchController c = new ASI_CRM_PH_MassUploadByBatchController();
		c.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
		c.recordtypeName = 'ASI CRM SG Actual Offtake';
		c.defaultValues = 'Type (Uploaded):Off-Trade';
		c.fields = 'Id,Name';
		c.fieldsLabel = 'Name,Quantity';
		c.emailNotification = false;
		c.init();

		c.fileSize = 100000;
		c.nameFile = 'test';
		c.uploadCSVByBatch();
	}

	@isTest
	static void testUploadCsvByBatch() {

		final List<String> attachmentCsvHeader = new List<String>{
				'Customer',
				'Offtake G/L Date',
				'SKU Code',
				'Invoice No.',
				'Quantity'
				};
		final List<String> attachmentRow = new List<String>();
		attachmentRow.add('C001');
		//		attachmentRow.add(offtakeHeader.ASI_CRM_OfftakeDate__c.format());
		attachmentRow.add('20151010');
		attachmentRow.add('AEL275');
		attachmentRow.add('ABCD123');
		attachmentRow.add('123');

		String attachmentContent = String.join(attachmentCsvHeader, ',') + ASI_CRM_CSVReaderHelper.CRLF;
		attachmentContent += String.join(attachmentRow, ',');

		final ASI_CRM_PH_MassUploadByBatchController c = new ASI_CRM_PH_MassUploadByBatchController();

		c.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
		c.recordtypeName = 'ASI CRM SG Actual Offtake';
		c.defaultValues = 'Type (Uploaded):Off-Trade';
		c.fields = 'Id,Name';
		c.fieldsLabel = 'Name,Quantity';
		c.emailNotification = false;
		c.init();

		c.fileSize = 1000;
		c.nameFile = 'test.csv';
		c.currentPageURL = '';
		c.contentFile = Blob.valueOf(attachmentContent);

		c.uploadCSVByBatch();

		System.assert(c.StatusMsgs != null);
		System.assert(c.isDisplayErrorLog != null);
	}

	@isTest
	static void forTestCoverage() {
		final ASI_CRM_PH_MassUploadByBatchController c = new ASI_CRM_PH_MassUploadByBatchController();

		c.ObjAPIName = 'ASI_TH_CRM_Actual_Offtake__c';
		c.recordtypeName = 'ASI CRM SG Actual Offtake';
		c.defaultValues = 'Type (Uploaded):Off-Trade';
		c.fields = 'Id,Name';
		c.fieldsLabel = 'Name,Quantity';
		c.emailNotification = false;
		c.init();

		c.inlineVF = true;
		c.recEXID = null;
		c.recEXIDcol = null;
		c.parentObjectAPIName = null;
		c.ParentObjectUploadMsg = null;
		c.noOfLastRowToIgnore = null;
		c.upsertMode = false;
		c.batchMode = true;
		c.opt_allOrNone = true;
		c.containsHeader = true;
		c.dummyVar = false;

		c.objName = 'Account';
		c.LOutputRow = null;
		c.LErrorRows = null;
	}
}