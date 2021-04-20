/***************************************************************************************************************************
* Name:        ASI_KOR_BarStylingPOSMManageAllCtrlTest
* Description: Test class for ASI_KOR_BarStylingPOSMManageAllCtrl
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-11-26       Alan Lau                Created
* 2019-06-17		Wilson Chow				Increase Code Coverage: testUpdateBarStylingItemRequest()
* 																	testUpdateBarStylingPOSMRequestSubBrand()
****************************************************************************************************************************/

@IsTest
private class ASI_KOR_BarStylingPOSMManageAllCtrlTest {

	private final static String posmProoductRecordTypeName = 'ASI_KOR_POSM_Product__cASI_KOR_Bar_Styling_Item';
	private final static String barStylingPOSMHeaderRecordTypeName = 'ASI_KOR_POSM_Order_Request__cASI_KOR_Bar_Styling_POSM_Request';
	private final static String barStylingItemHeaderRecordTypeName = 'ASI_KOR_POSM_Order_Request__cASI_KOR_Locked_Bar_Styling_Item_Request';
	private final static String barStylingPOSMLineItemRecordTypeName = 'ASI_KOR_POSM_Order_Detail__cASI_KOR_Bar_Styling_POSM_Order_Detail';
	private static final String fiscalYear = 'FY0001';

	private static String supplierAccountId;
	private static String subBrandId;
	private static String posmProductId;
	private static String posmHeaderId;
	private static String posmLineItemId;

	@TestSetup
	static void setup() {

		setSupplierAccount();
		setSubBrand();
		setPOSMProduct();
		setBarStylingPOSMHeader();
		setBarStylingPOSMLineItem();
		setAttachment();

	}

	@IsTest
	static void testBarStylingPOSMManageAllPage() {
		ASI_KOR_POSM_Order_Request__c posmHeader = [SELECT Id, Name, ASI_KOR_POSM_TO_Venue__c, ASI_KOR_Status__c FROM ASI_KOR_POSM_Order_Request__c LIMIT 1];
		List<ASI_KOR_POSM_Order_Detail__c> posmLineItemList = [SELECT Id, Name, ASI_KOR_POSM_Order_Request__c, ASI_KOR_SubBrand__c, ASI_KOR_Quantity__c, ASI_KOR_Supplier__c, ASI_KOR_UnitCost__c, ASI_KOR_Item_Name__c, ASI_MFM_KR_Supplier_Email__c FROM ASI_KOR_POSM_Order_Detail__c];

		ApexPages.standardSetController sc = new ApexPages.standardSetController(posmLineItemList);
		PageReference ManageAllPage = Page.ASI_KOR_BarStylingPOSMManageAllPage;
		Test.setCurrentPage(ManageAllPage);
		ApexPages.currentPage().getParameters().put('id', posmHeader.Id);

		Test.setCurrentPageReference(ManageAllPage);

//		ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(barStylingPOSMHeader);
		ASI_KOR_BarStylingPOSMManageAllCtrl ManageAllController = new ASI_KOR_BarStylingPOSMManageAllCtrl(sc);

		ManageAllController.init();

		System.currentPageReference().getParameters().put('PARAM_clone_ID', (String) posmLineItemList[0].Id);

		ManageAllController.sendEmail();
		ManageAllController.cloneLine();
		for(Integer i = 0; i < 10; i++) {
			ManageAllController.addLineItem();
		}

        ManageAllController.saveLinetems();

        // 20190619
        ManageAllController.validateWithinBudget_pageRef();

        for(String key: ManageAllController.allPOSMLineMap.keySet()) {
            ASI_KOR_BarStylingPOSMManageAllCtrl.interimData orderDetail = ManageAllController.allPOSMLineMap.get(key);
            orderDetail.ProductItemID = key;
            orderDetail.ProductItem = key;
            orderDetail.linesItems.ASI_KOR_Guide_Unit_Cost_Adjusted__c = 10;
            orderDetail.linesItems.ASI_KOR_Quantity__c = 1;
            ManageAllController.allPOSMLineMap.put(key, orderDetail);
        }

        ManageAllController.validateWithinBudget_pageRef();
        // 20190619

		System.currentPageReference().getParameters().put('PARAM_Line_ID', (String) posmLineItemList[0].Id);

		ManageAllController.removePOSMLine();
		ManageAllController.sendEmail();

		//Test RemoteAction
		List<ASI_KOR_POSM_Product__c> Productremo = ASI_KOR_BarStylingPOSMManageAllCtrl.findPOSMproduct('ASI_KOR_POSM_Product__c','WHERE ID != NULL');
		List<Account> Accountremo = ASI_KOR_BarStylingPOSMManageAllCtrl.findSObjects('Account','WHERE ID != NULL');
	}
	
	@IsTest
	static void testBarStylingAttachment(){
		ASI_KOR_POSM_Order_Request__c posmHeader = [SELECT Id, Name, ASI_KOR_POSM_TO_Venue__c, ASI_KOR_Status__c FROM ASI_KOR_POSM_Order_Request__c LIMIT 1];
		PageReference pageRef = Page.ASI_KOR_POSMOrderFileAttPage;
            
            pageRef.getParameters().put('id', posmHeader.Id);
            
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(posmHeader);
            
            ASI_KOR_POSMOrderFileAttController fileAttachCon = new ASI_KOR_POSMOrderFileAttController();
            
            Blob attachData = Blob.toPdf('Test');
            fileAttachCon.sObjParentId = posmHeader.Id;
            fileAttachCon.attachmentObjType = 'ASI_KOR_POSM_Order_Attachment__c';
            fileAttachCon.contentData = attachData;
            fileAttachCon.fileSize = attachData.size();
            fileAttachCon.contentFileName = 'Test.pdf';
            fileAttachCon.contentCategory = 'Quotation';
            //fileAttachCon.recordTypeName = 'ASI_eForm_HK_Vendor_Form_Attachment';
            
            PageReference returnPage = fileAttachCon.uploadAction();
            
            
            String nextPage = fileAttachCon.cancel().getUrl();
            
            //Test for class properties
            Boolean hasCategoryField = fileAttachCon.hasCategoryField;
            Integer uploadStepCount = fileAttachCon.getUploadStepCount();
            List<SelectOption> categories = fileAttachCon.categories;
			String label = fileAttachCon.attachmentObjLabel;
	}

	@isTest
	static void testUpdateBarStylingItemRequest() {
		ASI_KOR_POSM_Order_Request__c posmHeader =
			[SELECT Id, Name, ASI_KOR_POSM_TO_Venue__c, ASI_KOR_Status__c
			FROM ASI_KOR_POSM_Order_Request__c
			LIMIT 1];

		ASI_KOR_Sub_Brand__c subBrand =
			[select Id, Name, ASI_KOR_Sub_Brand_Code__c
			from ASI_KOR_Sub_Brand__c
			limit 1];
		subBrand.ASI_KOR_Sub_Brand_Code__c = '20190617';
		subBrand.Name = '20190617';
		update subBrand;

		posmHeader.ASI_KOR_Sub_Brand__c = subBrand.Id;
		posmHeader.recordTypeId = Global_RecordTypeCache.getRtId(barStylingItemHeaderRecordTypeName);
		update posmHeader;

		PageReference pageRef = Page.ASI_KOR_POSMOrderFileAttPage;

		pageRef.getParameters().put('id', posmHeader.Id);

		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdCon = new ApexPages.StandardController(posmHeader);

		ASI_KOR_POSMOrderFileAttController fileAttachCon = new ASI_KOR_POSMOrderFileAttController();

		Blob attachData = Blob.toPdf('Test');
		fileAttachCon.sObjParentId = posmHeader.Id;
		fileAttachCon.attachmentObjType = 'ASI_KOR_POSM_Order_Attachment__c';
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = attachData.size();
		fileAttachCon.contentFileName = 'Test.pdf';
		fileAttachCon.contentCategory = 'Quotation';
		//fileAttachCon.recordTypeName = 'ASI_eForm_HK_Vendor_Form_Attachment';

		PageReference returnPage = fileAttachCon.uploadAction();


		String nextPage = fileAttachCon.cancel().getUrl();

		//Test for class properties
		Boolean hasCategoryField = fileAttachCon.hasCategoryField;
		Integer uploadStepCount = fileAttachCon.getUploadStepCount();
		List<SelectOption> categories = fileAttachCon.categories;
		String label = fileAttachCon.attachmentObjLabel;
	}

	@isTest
	static void testUpdateBarStylingPOSMRequestSubBrand() {
		ASI_KOR_POSM_Order_Request__c posmHeader =
			[SELECT Id, Name, ASI_KOR_POSM_TO_Venue__c, ASI_KOR_Status__c
			FROM ASI_KOR_POSM_Order_Request__c
			LIMIT 1];

		ASI_KOR_Sub_Brand__c subBrand =
		[select Id, Name, ASI_KOR_Sub_Brand_Code__c
		from ASI_KOR_Sub_Brand__c
		limit 1];
		subBrand.ASI_KOR_Sub_Brand_Code__c = '20190617';
		subBrand.Name = '20190617';
		update subBrand;

		posmHeader.ASI_KOR_Sub_Brand__c = subBrand.Id;
		update posmHeader;

		PageReference pageRef = Page.ASI_KOR_POSMOrderFileAttPage;

		pageRef.getParameters().put('id', posmHeader.Id);

		Test.setCurrentPage(pageRef);

		ApexPages.StandardController stdCon = new ApexPages.StandardController(posmHeader);

		ASI_KOR_POSMOrderFileAttController fileAttachCon = new ASI_KOR_POSMOrderFileAttController();

		Blob attachData = Blob.toPdf('Test');
		fileAttachCon.sObjParentId = posmHeader.Id;
		fileAttachCon.attachmentObjType = 'ASI_KOR_POSM_Order_Attachment__c';
		fileAttachCon.contentData = attachData;
		fileAttachCon.fileSize = attachData.size();
		fileAttachCon.contentFileName = 'Test.pdf';
		fileAttachCon.contentCategory = 'Quotation';
		//fileAttachCon.recordTypeName = 'ASI_eForm_HK_Vendor_Form_Attachment';

		PageReference returnPage = fileAttachCon.uploadAction();


		String nextPage = fileAttachCon.cancel().getUrl();

		//Test for class properties
		Boolean hasCategoryField = fileAttachCon.hasCategoryField;
		Integer uploadStepCount = fileAttachCon.getUploadStepCount();
		List<SelectOption> categories = fileAttachCon.categories;
		String label = fileAttachCon.attachmentObjLabel;
	}

	@isTest
	static void testForRestInASI_KOR_POSM_Order_Request_TriggerClass() {
		ASI_KOR_POSM_Order_Request__c posmHeader = new ASI_KOR_POSM_Order_Request__c(
				recordTypeId = Global_RecordTypeCache.getRtId(barStylingPOSMHeaderRecordTypeName),
				ASI_KOR_POSM_TO_Venue__c = supplierAccountId,
				ASI_KOR_Status__c = 'Draft',
				ASI_KOR_Fiscal_Year__c = fiscalYear,
				ASI_KOR_Request_Target_Date__c = Date.today().addDays(5),
				ASI_KOR_SYS_Approver_1__c = UserInfo.getUserId()
		);
		insert posmHeader;
		posmHeaderId = posmHeader.Id;
	}

	private static void setSupplierAccount() {
		map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_KOR_POSM_Order_Request__c');
		rt_map = ASI_MFM_Function.getRecordTypeId('Account');
		Account supplierAccount = new Account(
				recordTypeId = rt_map.get('ASI_KOR_Venue'),
				Name = 'Name1'
		);
		insert supplierAccount;
		supplierAccountId = supplierAccount.Id;
	}

	private static void setSubBrand() {
		ASI_KOR_Sub_Brand__c subBrand = new ASI_KOR_Sub_Brand__c(
				Name = 'TestSubBrand',
				ASI_KOR_Sub_Brand_Code__c = 'Code'
		);
		insert subBrand;
		subBrandId = subBrand.Id;
	}

	private static void setPOSMProduct() {
		ASI_KOR_POSM_Product__c posmProduct = new ASI_KOR_POSM_Product__c(
				recordTypeId = Global_RecordTypeCache.getRtId(posmProoductRecordTypeName),
				Name = 'TestProduct',
				ASI_MFM_UnitCost__c = 10,
				ASI_KOR_Sub_brand__c = subBrandId,
				ASI_KOR_Fiscal_Year__c = fiscalYear
		);
		insert posmProduct;
		posmProductId = posmProduct.Id;
	}

	private static void setBarStylingPOSMHeader() {
		ASI_KOR_POSM_Order_Request__c posmHeader = new ASI_KOR_POSM_Order_Request__c(
				recordTypeId = Global_RecordTypeCache.getRtId(barStylingPOSMHeaderRecordTypeName),
				ASI_KOR_POSM_TO_Venue__c = supplierAccountId,
				ASI_KOR_Status__c = 'Draft',
				ASI_KOR_Fiscal_Year__c = fiscalYear
		);
		insert posmHeader;
		posmHeaderId = posmHeader.Id;
	}

	private static void setBarStylingPOSMLineItem() {
		ASI_KOR_POSM_Order_Detail__c posmLineItem = new ASI_KOR_POSM_Order_Detail__c(
				recordTypeId = Global_RecordTypeCache.getRtId(barStylingPOSMLineItemRecordTypeName),
				ASI_KOR_POSM_Order_Request__c = posmHeaderId,
				ASI_KOR_Quantity__c = 10,
				ASI_KOR_Supplier__c = supplierAccountId,
				ASI_KOR_UnitCost__c = 100,
				ASI_KOR_Item_Name__c = posmProductId,
				ASI_MFM_KR_Supplier_Email__c = 'test@gmail.com');
		insert posmLineItem;
		posmLineItemId = posmLineItem.Id;
	}

	private static void setAttachment() {
		ASI_KOR_POSM_Order_Request__c posmHeader = [SELECT Id, Name, ASI_KOR_POSM_TO_Venue__c, ASI_KOR_Status__c FROM ASI_KOR_POSM_Order_Request__c LIMIT 1];
		List<ASI_KOR_POSM_Order_Attachment__c> attList = new List<ASI_KOR_POSM_Order_Attachment__c>();
            attList.add(new ASI_KOR_POSM_Order_Attachment__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Attachment__cASI_KOR_Bar_Styling_Attachment')
			, ASI_KOR_POSM_Order_Request__c = posmHeader.id
		   ));
		  Insert attList;
            Delete attList;
	}
}