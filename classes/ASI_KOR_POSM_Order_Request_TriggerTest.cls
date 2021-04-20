/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Request_TriggerTest
* Description: Test class for ASI_KOR_POSM_Order_Request's trigger(s)
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-11-29       Alan Lau                Created
****************************************************************************************************************************/
@IsTest
private class ASI_KOR_POSM_Order_Request_TriggerTest {

	private final static List<String> monthList = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};

	private final static String supplierAccountName = 'Test Supplier Account';
	private final static String barStylingPOSMHeaderRecordTypeName = 'ASI_KOR_POSM_Order_Request__cASI_KOR_Finalized_Bar_Styling_Item_Request';
	private final static String brandName = 'brand_name';
	private final static String subBrandCode = 'sub_brand_code';
	private final static String itemGroupCode = 'item_group_code';

	private static String supplierAccountId;
	private static String brandId;
	private static String subBrandId;
	private static String posmHeaderId;
	private static String venueDepletionId;
	private static String itemGroupId;

	@TestSetup
	static void setup() {

		setSupplierAccount();
		setBrand();
		setSubBrand();
		setVenueDepletion();
		setItemGroup();
		setVenueDepletionDetail();

	}

	@IsTest
	static void testSetAverageVolumeInActualCase() {
		ASI_KOR_Brand__c brand = getBrand();
		brand.ASI_KOR_UOM__c = 'Actual Case';
		update brand;

		Date targetRequestDate = Date.today();
		insertContractPeriod(targetRequestDate);
	}

	@IsTest
	static void testSetAverageVolumeInBottle() {
		ASI_KOR_Brand__c brand = getBrand();
		brand.ASI_KOR_UOM__c = 'Bottle';
		update brand;

		Date targetRequestDate = Date.today();
		insertContractPeriod(targetRequestDate);
	}

	@IsTest
	static void testUpsertContractPeriod() {

		Date targetRequestDate = Date.today();
		insertContractPeriod(targetRequestDate);

		ASI_KOR_POSM_Order_Request__c header = getPOSMHeader(posmHeaderId);
		header.ASI_KOR_Contract_Period__c = null;

		setBarStylingPOSMHeader(header, targetRequestDate, getSupplierAccountId(supplierAccountName), getSubBrandId(subBrandCode));

	}

	@IsTest
	static void testScheduler() {

		Date targetRequestDate = Date.today();
		insertContractPeriod(targetRequestDate);

		ASI_KOR_POSM_Order_Request__c header = getPOSMHeader(posmHeaderId);
		header.ASI_KOR_Contract_Period__c = null;
		header.ASI_KOR_Installation_Completion_Date__c = Date.today().addMonths(-3);

		setBarStylingPOSMHeader(header, targetRequestDate, getSupplierAccountId(supplierAccountName), getSubBrandId(subBrandCode));

		ASI_KOR_BarStyling_Scheduler b = new ASI_KOR_BarStyling_Scheduler();
		b.execute(null);
	}

	private static void insertContractPeriod(Date targetRequestDate) {

		ASI_KOR_POSM_Order_Request__c header = new ASI_KOR_POSM_Order_Request__c(
			recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Request__cASI_KOR_Finalized_Bar_Styling_Item_Request')
		);

		setBarStylingPOSMHeader(header, targetRequestDate, getSupplierAccountId(supplierAccountName), getSubBrandId(subBrandCode));

	}

	private static void setSupplierAccount() {
		map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c');
		rt_map = ASI_MFM_Function.getRecordTypeId('Account');
		Account supplierAccount = new Account(
				recordTypeId = rt_map.get('ASI_KOR_Venue'),
				Name = supplierAccountName
		);
		insert supplierAccount;
		supplierAccountId = supplierAccount.Id;
	}

	private static void setBrand() {
		ASI_KOR_Brand__c brand = new ASI_KOR_Brand__c(
				Name = brandName
		);
		insert brand;
		brandId = brand.Id;
	}

	private static void setSubBrand() {
		ASI_KOR_Sub_Brand__c subBrand = new ASI_KOR_Sub_Brand__c(
				Name = 'TestSubBrand',
				ASI_KOR_Brand__c = brandId,
				ASI_KOR_Sub_Brand_Code__c = subBrandCode
		);
		insert subBrand;
		subBrandId = subBrand.Id;
	}

	private static void setBarStylingPOSMHeader(ASI_KOR_POSM_Order_Request__c header, Date targetRequestDate, String supplierAccountId, String subBrandId) {
		ASI_KOR_POSM_Order_Request__c posmHeader = header;
		posmHeader.recordTypeId = Global_RecordTypeCache.getRtId(barStylingPOSMHeaderRecordTypeName);
		posmHeader.ASI_KOR_POSM_TO_Venue__c = supplierAccountId;
		posmHeader.ASI_KOR_Status__c = 'Draft';
		posmHeader.ASI_KOR_Request_Target_Date__c = targetRequestDate;
		posmHeader.ASI_KOR_Sub_brand__c = subBrandId;
		upsert posmHeader;
		posmHeaderId = posmHeader.Id;
	}

	private static void setVenueDepletion() {
		ASI_KOR_Venue_Depletion__c venueDepletion = new ASI_KOR_Venue_Depletion__c(
				ASI_KOR_Venue__c = supplierAccountId,
				ASI_KOR_Year__c = String.valueOf(Date.today().year()),
				ASI_KOR_Month__c = monthList.get(Date.today().month() - 2)
		);
		insert venueDepletion;
		venueDepletionId = venueDepletion.Id;
	}

	private static void setItemGroup() {
		ASI_KOR_Item_Group__c itemGroup = new ASI_KOR_Item_Group__c(
				ASI_KOR_Sub_Brand__c = subBrandId,
				ASI_KOR_Item_Group_Code__c = itemGroupCode
		);
		insert itemGroup;
		itemGroupId = itemGroup.Id;
	}

	private static void setVenueDepletionDetail() {
		ASI_KOR_Venue_Depletion_Detail__c venueDepletionDetail = new ASI_KOR_Venue_Depletion_Detail__c(
				ASI_KOR_Venue_Depletion__c = venueDepletionId,
				ASI_KOR_Item_Group_Code__c = itemGroupId,
				ASI_KOR_Venue_Depl_Info_Depletion_Volume__c = 100,
				ASI_KOR_Venue_Depl_Info_Depletion_Case__c = 100
		);
		insert venueDepletionDetail;
	}

	private static String getSupplierAccountId(String supplierAccountName) {
		String supplierAccountId = [SELECT Id FROM Account WHERE Name = :supplierAccountName LIMIT 1].Id;

		return supplierAccountId;
	}

	private static ASI_KOR_POSM_Order_Request__c getPOSMHeader(String headerId) {
		ASI_KOR_POSM_Order_Request__c posmHeader = [SELECT Id, recordTypeId, ASI_KOR_POSM_TO_Venue__c, ASI_KOR_Status__c, ASI_KOR_Request_Target_Date__c, ASI_KOR_Contract_Period__c FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :headerId LIMIT 1];

		return posmHeader;
	}

	private static String getSubBrandId(String subBrandCode) {
		String subBrandId = [SELECT Id FROM ASI_KOR_Sub_Brand__c WHERE ASI_KOR_Sub_Brand_Code__c = :subBrandCode LIMIT 1].Id;

		return subBrandId;
	}

	private static ASI_KOR_Brand__c getBrand() {
		ASI_KOR_Brand__c brand = [SELECT Id, Name, ASI_KOR_UOM__c FROM ASI_KOR_Brand__c WHERE Name = :brandName LIMIT 1];

		return brand;
	}

}