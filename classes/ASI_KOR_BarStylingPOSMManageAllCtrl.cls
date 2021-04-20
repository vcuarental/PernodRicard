/***************************************************************************************************************************
* Name:        ASI_KOR_BarStylingPOSMManageAllCtrl
* Description: Controller of manage all page ASI_KOR_BarStylingPOSMManageAllPage.page
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-11-26       Alan Lau                Created (Cloned from ASI_MFM_KR_POSMManageAllController)
* 2019-06-03		Wilson Chow				Call validateActualSpendingAmount() from trigger to controller
****************************************************************************************************************************/
public class ASI_KOR_BarStylingPOSMManageAllCtrl {

	public final String STATUS_LOCKED = 'Locked';

	public final String ACTUAL_SPENDING_AMOUNT_VALIDATION_ERROR_MESSAGE {
		get { return 'Total Actual Spending Amount cannot be greater than Total Budget Amount.'; }
	}

	public final String DUPLICATED_ITEM_ERROR_MESSAGE {
		get { return 'Each Item can only has ONE line.'; }
	}

	public String currentUserId = UserInfo.getUserId();

	public Boolean isCurrentUserApprover {get;set;}

	public Boolean isTotalActualSpendingAmountLargerThanTotalBudgetAmount {get;set;}

	public Boolean isDuplicatedItemExist {get;set;}

	public boolean UpsertPermission {
		get;set;
	}
	{
		UpsertPermission = true;
	}
	public boolean EmailUpsertPermission {
		get;set;
	}
	{
		EmailUpsertPermission = true;
	}
	public boolean SaveSuccess {
		get;set;
	}
	public boolean SentSuccess {
		get;set;
	}
	public ASI_KOR_POSM_Order_Request__c posmReqHeader {
		get; set;
	}
	public static String LINE_ITEM_NEWRECORD_PREFIX {
		get{
			return 'z';
		}
	}
	public Integer LINE_ITEM_NEWRECORD_COUNTER {
		get;set;
	}
	public String msg {
		get;set;
	}

	public ASI_KOR_POSM_Order_Detail__c create_POSMdetailrtID {
		get;set;
	}


	public List<ASI_KOR_POSM_Order_Detail__c> deleteLineItemList {
		get;set;
	}
	{
		deleteLineItemList = new List<ASI_KOR_POSM_Order_Detail__c>();
	}

	public Map<String, interimData> allPOSMLineMap {
		get;set;
	}
	{
		allPOSMLineMap = new Map<String, interimData>();
	}
	public Map<String, ASI_KOR_Sub_brand__c> allSubBrandMap {
		get;set;
	}
	{
		allSubBrandMap = new Map<String, ASI_KOR_Sub_brand__c>();
	}
	public Map<String, ASI_KOR_POSM_Product__c> POSMproductMap {
		get;set;
	}
	{
		POSMproductMap = new Map<String, ASI_KOR_POSM_Product__c>();
	}

	//For email
	public Map<id, List<ASI_KOR_POSM_Order_Detail__c>> SupplierLinesMap {
		get;set;
	}
	{
		SupplierLinesMap = new Map<id, List<ASI_KOR_POSM_Order_Detail__c>> ();
	}
	public Map<id, ASI_KOR_POSM_Order_Detail__c> LinesMap {
		get;set;
	}
	{
		LinesMap = new Map<id, ASI_KOR_POSM_Order_Detail__c> ();
	}
	public Map<ID, List<Attachment>> LineIdAttMap {
		get;set;
	}
	{
		LineIdAttMap = new Map<ID, List<Attachment>> ();
	}
	public Map<String, List<Attachment>> SupplierAttMap {
		get;set;
	}
	{
		SupplierAttMap = new Map<String, List<Attachment>> ();
	}

	//=====20190603====
	public String validationMsg{get;set;}
	public String validationAction{get;set;}
	//=================

	public Class interimData{
		public ASI_KOR_POSM_Order_Detail__c linesItems {
			get; set;
		}
		public String BrandGroup {
			set;get;
		}
		public String Brand {
			set;get;
		}
		public String SubBrand {
			set;get;
		}
		public String ProductItem {
			set;get;
		}
		public String BrandGroupID {
			set;get;
		}
		public String BrandID {
			set;get;
		}
		public String SubBrandID {
			set;get;
		}
		public String ProductItemID {
			set;get;
		}
		public String SupplierID {
			set;get;
		}
		public String Supplier {
			set;get;
		}
		public Decimal Amount {
			get; set;
		}
		public Boolean isProcess {
			set;get;
		}
		public String SalesBranch {
			set;get;
		}
		//Sales Branch Name - default from header
		public Decimal guideUnitCost {
			get;set;
		}
	}

	public ASI_KOR_BarStylingPOSMManageAllCtrl(ApexPages.StandardSetController stdSetController) {
		String posmReqHeaderId = ApexPages.currentPage().getParameters().get('id');
		this.posmReqHeader = [SELECT Id,Name, ownerid, ASI_KOR_Request_Date__c, ASI_KOR_Status__c,
				ASI_MFM_KR_Email_Sent__c,ASI_MFM_KR_EmailSentTime__c, ASI_KOR_POSM_TO_Venue__c,ASI_KOR_Requested_Date__c , ASI_KOR_POSM_TO_Venue__r.name,ASI_MFM_Sales_Branch__c, ASI_KOR_Sub_brand__c, ASI_KOR_Fiscal_Year__c, ASI_KOR_SYS_Approver_1__c, ASI_KOR_Remaining_Budget_Amount__c,
				(SELECT Id, ASI_KOR_Item_Name__c FROM ASI_KOR_POSM_Order_Details__r) FROM ASI_KOR_POSM_Order_Request__c WHERE Id = :posmReqHeaderId];

		this.isCurrentUserApprover = this.currentUserId.equals(this.posmReqHeader.ASI_KOR_SYS_Approver_1__c);

	}

	//public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

	public void init() {

		//POSM Line

		Id barStylingRecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_Bar_Styling_POSM_Order_Detail');
		List<ASI_KOR_POSM_Order_Detail__c> POSMlineItemList =
		[select id, name, ASI_KOR_POSM_Order_Request__c,ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__c, ASI_KOR_POSM_Order_Request__r.ASI_KOR_POSM_TO_Venue__r.name, ASI_KOR_POSM_Order_Request__r.ASI_KOR_Status__c, ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c, ASI_KOR_Remarks__c, ASI_KOR_Quantity__c,
				ASI_KOR_Item_Name__r.name, ASI_KOR_Item_Name__c,ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__c, ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c,
				ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__c,
				ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.name, ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.name, ASI_KOR_Supplier__c,ASI_KOR_Supplier__r.name,
				ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__r.name,
				ASI_KOR_UnitCost__c, ASI_KOR_TotalAmount__c , ASI_KOR_SequenceNumber__c, ASI_KOR_UOM__c ,
				ASI_MFM_KR_Supplier_Email__c, ASI_KOR_POSM_Order_Request__r.ASI_MFM_KR_Email_Sent__c, ASI_KOR_POSM_Order_Request__r.ASI_MFM_Sales_Branch__c,
				ASI_KOR_Guide_Unit_Cost__c, ASI_KOR_Total_Cost__c, RecordType.DeveloperName, //20181126 Alan Lau
				ASI_KOR_Guide_Unit_Cost_Adjusted__c
				from ASI_KOR_POSM_Order_Detail__c where ASI_KOR_POSM_Order_Request__c =: posmReqHeader.id and RecordTypeId = :barStylingRecordTypeId];

		if (!POSMlineItemList.isEmpty()) {
			// Get existing data
			for (ASI_KOR_POSM_Order_Detail__c POSMline : POSMlineItemList) {
				String porlId = (String)(POSMline.id);
				if (!allPOSMLineMap.containsKey(porlId)) {
					interimData temp = new interimData();
					temp.linesItems = POSMline;

					// temp.SalesBrand = POSMline.ASI_KOR_Sales_Branch__r.ASI_eForm_Employee_Branch_Code__c;
					temp.BrandGroup =
							POSMline.ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__r.name;
					temp.Brand = POSMline.ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.name;
					temp.SubBrand = POSMline.ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.name;
					temp.BrandGroupID =
							POSMline.ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__r.ASI_KOR_CN_Brand_Group__c;
					temp.BrandID = POSMline.ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c;
					temp.SubBrandID = POSMline.ASI_KOR_Item_Name__r.ASI_KOR_Sub_Brand__c;

					temp.ProductItemID = POSMline.ASI_KOR_Item_Name__c;
					temp.ProductItem = POSMline.ASI_KOR_Item_Name__r.name;
					temp.guideUnitCost = POSMline.ASI_KOR_Guide_Unit_Cost__c;

					temp.SupplierID = POSMline.ASI_KOR_Supplier__c;
					temp.Supplier = POSMline.ASI_KOR_Supplier__r.name;

					temp.SalesBranch = POSMline.ASI_KOR_POSM_Order_Request__r.ASI_MFM_Sales_Branch__c;

					// system.assertEquals(temp.SalesBranch, null);
					if (POSMline.ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c != null &&
									POSMline.ASI_KOR_Quantity__c != null) {
						temp.Amount = POSMline.ASI_KOR_Item_Name__r.ASI_MFM_UnitCost__c * POSMline.ASI_KOR_Quantity__c;
					}

					allPOSMLineMap.put(porlId, temp);

					//porlineID_set.add(porlId);

					LinesMap.put(POSMline.id, POSMline);

					//For supplier email:
					//SupplierEmailMap.put(POSMline.ASI_KOR_Supplier__c, POSMline);
					SupplierLinesMap.put(POSMline.ASI_KOR_Supplier__c, POSMlineItemList);
					//system.assertEquals(SupplierEmailMap, null);
				}
			}
		}
	}


	public void addLineItem() {
		for (String k : allPOSMLineMap.keySet()) {
			System.debug(allPOSMLineMap.get(k));
		}
		UpsertPermission = true;
		SaveSuccess = false;


		string newIDCounter = newCounterCreatorLine();
		interimData temp = new interimData();

		temp.linesItems = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_POSM_Order_Request__c = posmReqHeader.id);

		allPOSMLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newIDCounter, temp);


	}


	public String newCounterCreatorLine()
		{
			String idNew;
			if (LINE_ITEM_NEWRECORD_COUNTER == null)
			{
				LINE_ITEM_NEWRECORD_COUNTER = 0;
			}//end if
			else
			{
				LINE_ITEM_NEWRECORD_COUNTER += 1;
			}//end else

			String zParser = '';
			Integer oneDigitCounter = LINE_ITEM_NEWRECORD_COUNTER;

			if (LINE_ITEM_NEWRECORD_COUNTER > 9)
			{
				Integer zNumber = LINE_ITEM_NEWRECORD_COUNTER / 10;
				for (Integer i = 0; i < zNumber; i++)
					{
						zParser += 'z';
					}//end for
				oneDigitCounter = Math.mod(LINE_ITEM_NEWRECORD_COUNTER, 10);
			}//end if

			idNew = zParser + string.valueof(oneDigitCounter);
			return idNew;
		}
	//end method: newCounterCreatorLine


	/*Method: For Auto-Complete*/
	@RemoteAction
	public static List<sObject> findSObjects(string obj, string qry) {
		List<sObject> sobjs;
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Schema.SObjectType sot = gd.get(obj);
		if (sot != null) {
			// create the filter text
			String filter = qry;


			//begin building the dynamic soql query

			//String soql = 'select Id, Name from ' + obj + filter +' order by Name limit 100';
			String soql = 'select Id, Name, ASI_LUX_Email_Business__c from ' + obj + filter + ' order by Name';


			List<String> results = new List<String>();

			System.debug('soql:' + soql);

			try {
				sobjs = Database.query(soql);
			} catch (QueryException e) {
				sobjs = null;
			}
		}
		return sobjs;
	}


	@RemoteAction
	public static List<sObject> findPOSMproduct(string obj, string qry) {
		List<sObject> sobjs;
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		Schema.SObjectType sot = gd.get(obj);
		if (sot != null) {
			// create the filter text
			String filter = qry;


			//begin building the dynamic soql query

			String soql =
					'select Id, Name, ASI_KOR_Sub_Brand__c, ASI_KOR_Sub_Brand__r.Name,ASI_MFM_UnitCost__c, ASI_KOR_UOM__c, ASI_KOR_Guide_Unit_Cost__c, ASI_KOR_Fiscal_Year__c, ASI_KOR_Sub_Brand__r.ASI_KOR_Sub_Brand_Code__c from ' +
					obj + filter +
					' AND recordtype.developername = \'ASI_KOR_Bar_Styling_Item\' order by Name';


			System.debug('soql:' + soql);

			try {
				sobjs = Database.query(soql);
			} catch (QueryException e) {
				sobjs = null;
			}
		}

		return sobjs;
	}


	//kammy start:
	public PageReference saveLinetems() {
		PageReference pageRef = null;

		UpsertPermission = true;
		SaveSuccess = false;

		Map<String, String> params = ApexPages.currentPage().getParameters();
		String isQuickSaveStr = params.get('IS_QUICK_SAVE');

		Boolean isQuickSave = (isQuickSaveStr == null) ? false : Boolean.valueOf(isQuickSaveStr);

		Database.upsertResult[] upsertTarget;
		Database.deleteResult[] deleteTarget;

		List<ASI_KOR_POSM_Order_Detail__c> upsertTargetList = new List<ASI_KOR_POSM_Order_Detail__c>();

		Boolean isRedirect = True;

		List<String> productItemIdList = new List<String>();

		for (String key : allPOSMLineMap.keySet()) {
			if (productItemIdList.contains(allPOSMLineMap.get(key).ProductItemID)) {
				isDuplicatedItemExist = true;
				return null;
			} else {
				productItemIdList.add(allPOSMLineMap.get(key).ProductItemID);
			}
		}

		if (!allPOSMLineMap.isEmpty())
		{
			isRedirect = valdationCheckingStep(allPOSMLineMap);

		}//end if

		if (!isRedirect)
		{
			UpsertPermission = false;
			SaveSuccess = false;
			return null;
		}//end if

		system.debug('isRedirect:' + isRedirect);

		create_POSMdetailrtID = new ASI_KOR_POSM_Order_Detail__c();
		create_POSMdetailrtID.recordTypeID = Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_Bar_Styling_POSM_Order_Detail');
		string developername = create_POSMdetailrtID.recordTypeID;
		if (UpsertPermission)
		{
			for (String key : allPOSMLineMap.keySet())
				{
					ASI_KOR_POSM_Order_Detail__c PLtemp = new ASI_KOR_POSM_Order_Detail__c();
					PLtemp = allPOSMLineMap.get(key).linesitems;

					//ProductItemID
					if (String.isNotEmpty(allPOSMLineMap.get(key).ProductItemID))
					{
						PLtemp.ASI_KOR_Item_Name__c = Id.valueOf(allPOSMLineMap.get(key).ProductItemID);
					}//end if

					//Record Type
					if (developername != null)
					{
						PLtemp.recordtypeid = Id.valueOf(developername);
					}//end if

					if (PLtemp.recordtypeid != null)
					{
						if (String.isNotEmpty(allPOSMLineMap.get(key).ProductItemID))
						{
							upsertTargetList.add(PLtemp);
						}//end if
					}

				}//end for
		}//end if
		system.debug('Upsert:' + upsertTargetList);
		System.Savepoint pSavepoint = Database.setSavepoint();

		try
		{
			if (deleteLineItemList.size() > 0)
			{
				deleteTarget = Database.delete(deleteLineItemList);
				deleteLineItemList.clear();
			}//end if
			if (upsertTargetList.size() > 0)
			{
				upsertTarget = Database.upsert(upsertTargetList);
				SaveSuccess = true;
				isTotalActualSpendingAmountLargerThanTotalBudgetAmount = false;
				isDuplicatedItemExist = false;
			} else
			{
				SaveSuccess = false;
			}
		}
		//end try
		catch (Exception e)
		{
			//string msg = '';
			//msg += 'Save Error : ' +e.getMessage() + '</br>';
			isTotalActualSpendingAmountLargerThanTotalBudgetAmount = e.getMessage().contains(ACTUAL_SPENDING_AMOUNT_VALIDATION_ERROR_MESSAGE);
			pageRef = null;
			Database.rollback(pSavepoint);
			UpsertPermission = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal, e.getDmlMessage(0)));
			return null;
		}//end catch

		if (!isQuickSave && UpsertPermission)
		{
			pageRef = new PageReference('/' + posmReqHeader.Id);
			pageRef.setRedirect(true);
		}//end if
		else
		{
			pageRef = null;
		}//end else

		return pageRef;
	}

	public Boolean valdationCheckingStep(Map<String, interimData>allPOSMLineMap)
		{
			Boolean isProcess = true;
			Integer idx = 1;
			msg = '';

			//system.assertEquals(allPOSMLineMap,null);
			if (allPOSMLineMap == null) return false;

			for (String key : allPOSMLineMap.keySet())
				{
					//initalize isProcess for Line
					allPOSMLineMap.get(key).isProcess = true;

					//check POSM product name
					if (String.isEmpty(allPOSMLineMap.get(key).ProductItemID) ||
							String.isEmpty(allPOSMLineMap.get(key).ProductItem))
					{
						allPOSMLineMap.get(key).linesitems.addError('Please select Product Item');
						msg += 'Line ' + idx + ' : Please select Product Item' + '</br>';
						allPOSMLineMap.get(key).isProcess = false;
						isProcess = false;
					}//end if

					//check Unit Cost
					if (allPOSMLineMap.get(key).linesitems.ASI_KOR_Guide_Unit_Cost_Adjusted__c == null)
					{
						allPOSMLineMap.get(key).linesitems.addError('Unit Cost can not be null.');
						msg += 'Line ' + idx + ' : Unit Cost can not be null.' + '</br>';
						allPOSMLineMap.get(key).isProcess = false;
						isProcess = false;
					}//end if

					//check Quantity
					if (allPOSMLineMap.get(key).linesitems.ASI_KOR_Quantity__c == null)
					{
						allPOSMLineMap.get(key).linesitems.addError('Quantity can not be null.');
						msg += 'Line ' + idx + ' : Please input Quantity' + '</br>';
						allPOSMLineMap.get(key).isProcess = false;
						isProcess = false;
					}//end if

					if (allPOSMLineMap.get(key).linesitems.ASI_KOR_Quantity__c != null &&
									allPOSMLineMap.get(key).linesitems.ASI_KOR_Guide_Unit_Cost_Adjusted__c != null) {
						allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c =
								allPOSMLineMap.get(key).linesitems.ASI_KOR_Quantity__c *
								allPOSMLineMap.get(key).linesitems.ASI_KOR_Guide_Unit_Cost_Adjusted__c;
					}
					//check Total Amount
					if (allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c == null)
					{
						allPOSMLineMap.get(key).linesitems.addError('Total Amount can not be null.');
						//msg += 'Line ' + idx + ' : Total Amount can not be null.' + '</br>';
						allPOSMLineMap.get(key).isProcess = false;
						isProcess = false;
					}//end if

					idx++;
				}//end for: loop keySet
			return isProcess;
		}


	public void removePOSMLine() {

		UpsertPermission = true;
		SaveSuccess = false;

		Map<String, String> params = ApexPages.currentPage().getParameters();
		String param_Id = params.get('PARAM_Line_ID');
		if (allPOSMLineMap.containsKey(param_Id) && !allPOSMLineMap.isEmpty())
		{
			ASI_KOR_POSM_Order_Detail__c delTarget = allPOSMLineMap.get(param_Id).linesItems;
			if (delTarget.id != null)
			{
				deleteLineItemList.add(delTarget);
			}

			allPOSMLineMap.remove(param_Id);
			SaveSuccess = false;
		}
	}

	public void cloneLine()
		{

			UpsertPermission = true;
			SaveSuccess = false;


			Map<String, String> params = ApexPages.currentPage().getParameters();
			String param_Id = params.get('PARAM_clone_ID');
			if (allPOSMLineMap.containsKey(param_Id) && !allPOSMLineMap.isEmpty()) {

				string newIDCounter = newCounterCreatorLine();
				interimData temp = new interimData();
				temp.linesItems = new ASI_KOR_POSM_Order_Detail__c(ASI_KOR_POSM_Order_Request__c = posmReqHeader.id,
						ASI_KOR_Remarks__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Remarks__c,
						ASI_KOR_Quantity__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Quantity__c,
						ASI_KOR_TotalAmount__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_TotalAmount__c,
						ASI_KOR_UnitCost__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_UnitCost__c,
					//ASI_KOR_Requested_Date__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Requested_Date__c,
						ASI_KOR_UOM__c = allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_UOM__c,
					//ASI_KOR_Sales_Branch__c =  allPOSMLineMap.get(param_Id).linesItems.ASI_KOR_Sales_Branch__c,
						ASI_MFM_KR_Supplier_Email__c =
								allPOSMLineMap.get(param_Id).linesItems.ASI_MFM_KR_Supplier_Email__c);

				temp.SalesBranch = allPOSMLineMap.get(param_Id).SalesBranch;
				temp.Brand = allPOSMLineMap.get(param_Id).Brand;
				temp.SubBrand = allPOSMLineMap.get(param_Id).SubBrand;
				temp.BrandID = allPOSMLineMap.get(param_Id).BrandID;
				temp.SubBrandID = allPOSMLineMap.get(param_Id).SubBrandID;
				temp.ProductItemID = allPOSMLineMap.get(param_Id).ProductItemID;
				temp.ProductItem = allPOSMLineMap.get(param_Id).ProductItem;
				temp.SupplierID = allPOSMLineMap.get(param_Id).SupplierID;
				temp.Supplier = allPOSMLineMap.get(param_Id).Supplier;
				temp.Amount = allPOSMLineMap.get(param_Id).Amount;
				allPOSMLineMap.put(LINE_ITEM_NEWRECORD_PREFIX + newIDCounter, temp);

			}
		}

	public Boolean EmailvaldationCheckingStep(Map<String, interimData>allPOSMLineMap)
		{
			msg = '';
			Integer idx = 1;

			if (allPOSMLineMap == null) return false;

			for (String key : allPOSMLineMap.keySet())
				{
					ASI_KOR_POSM_Order_Detail__c PLtemp = new ASI_KOR_POSM_Order_Detail__c();
					PLtemp = allPOSMLineMap.get(key).linesitems;

					//KAMMY
					//PLtemp.ASI_KOR_UOM__c = 'EA';

					if (allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c == 'undefined' ||
									allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c == null ||
									allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c == '') {

						msg += 'Line ' + idx + ' : Please input Supplier Email Address' + '</br>';
						EmailUpsertPermission = false;
						return false;

					}

					if (allPOSMLineMap.get(key).Supplier == null) {
						msg += 'Line ' + idx + ' : Please input Supplier' + '</br>';
						EmailUpsertPermission = false;
						return false;
					}

					if (PLtemp.recordtypeid == null) {
						EmailUpsertPermission = false;
						EmailUpsertPermission = false;
						return false;
						// msg += 'Line ' + idx + ' : Can not be null.' + '</br>';
					}

					idx++;

				}

			return true;

		}

	public void sendEmail()
		{
			EmailUpsertPermission = true;
			Integer idx = 1;
			msg = '';

			Boolean isRedirect = True;

			Database.upsertResult[] upsertTarget;


			List<ASI_KOR_POSM_Order_Detail__c> upsertTargetList = new List<ASI_KOR_POSM_Order_Detail__c>();


			create_POSMdetailrtID = new ASI_KOR_POSM_Order_Detail__c();
			create_POSMdetailrtID.recordTypeID =
					Global_RecordTypeCache.getRtId('ASI_KOR_POSM_Order_Detail__cASI_KOR_POSM_Order_Detail');
			string developername = create_POSMdetailrtID.recordTypeID;

			if (!allPOSMLineMap.isEmpty())
			{
				isRedirect = EmailvaldationCheckingStep(allPOSMLineMap);


			}//end if


			if (!isRedirect)
			{
				EmailUpsertPermission = false;
				SentSuccess = false;

			}//end

			//system.assertEquals(EmailUpsertPermission,null);
			if (EmailUpsertPermission = true) {

				for (String key : allPOSMLineMap.keySet())
					{
						ASI_KOR_POSM_Order_Detail__c PLtemp = new ASI_KOR_POSM_Order_Detail__c();
						PLtemp = allPOSMLineMap.get(key).linesitems;

						//KAMMY
						//PLtemp.ASI_KOR_UOM__c = 'EA';


						if (PLtemp.recordtypeid != null) {
							if (String.isNotEmpty(allPOSMLineMap.get(key).ProductItemID) &&
									String.isNotEmpty(allPOSMLineMap.get(key).SubBrandID) &&
									String.isNotEmpty(allPOSMLineMap.get(key).SupplierID) &&
									String.isNotEmpty(allPOSMLineMap.get(key).Supplier) &&
									String.isNotEmpty(
											allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c) &&
											allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c !=
											'undefined' &&
											allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c != null &&
											allPOSMLineMap.get(key).linesitems.ASI_MFM_KR_Supplier_Email__c != '') {


								PLtemp.ASI_KOR_Supplier__c = Id.valueOf(allPOSMLineMap.get(key).SupplierID);

								if (allPOSMLineMap.get(
										key).linesitems.ASI_KOR_POSM_Order_Request__r.ASI_MFM_KR_Email_Sent__c !=
										true) {
									posmReqHeader.ASI_MFM_KR_Email_Sent__c = true;

								}
								posmReqHeader.ASI_MFM_KR_EmailSentTime__c = System.now();
								upsertTargetList.add(PLtemp);

							} else {
								EmailUpsertPermission = false;
								//msg += 'Line ' + idx + ' : Please input Supplier Email Address' + '</br>';
							}
						}

						if (PLtemp.recordtypeid == null) {
							EmailUpsertPermission = false;
							// msg += 'Line ' + idx + ' : Can not be null.' + '</br>';
						}

						idx++;

					}

			}


			if (isRedirect == true && upsertTargetList.size() > 0)
			{
				try {
					upsertTarget = Database.upsert(upsertTargetList);
					update posmReqHeader;
					SentSuccess = true;
					EmailUpsertPermission = true;
				} catch (DmlException dmle) {
					EmailUpsertPermission = false;
				} catch (Exception e) {

					EmailUpsertPermission = false;
				}
			} else {
				EmailUpsertPermission = false;
				SentSuccess = false;
				//msg += 'Line ' + idx + ' : Can not be null.' + '</br>';
			}


			//Send Email:
			if (EmailUpsertPermission == true && isRedirect == true) {

				Id templateId;// ID userid = UserInfo.getUserId();
				String templateApiName = 'ASI_KOR_POSM_Request'; //  Set Email template
				List <String> ToAddresses = new List <String>();

				templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;


				if (templateId != null) {
					//if the Email template is found

					//Send email by Supplier's group
					//***Only ONE Line will pass to email's component ==>need to loop other lines manually***
					if (SupplierLinesMap.size() > 0) {
						// if there is POSM Line

						List <Attachment> AllLines =
						[select id, name,body,contenttype, ParentID from Attachment where ParentId in : LinesMap.keyset()]; //All related lines' attachments

						if (AllLines.size() > 0) {
							for (Attachment att: AllLines) {
								//for each attachment
								string supplierCode = LinesMap.containsKey(att.ParentId) ? LinesMap.get(
										att.ParentId).ASI_KOR_Supplier__c : '';
								if (SupplierAttMap.containsKey(supplierCode)) {
									SupplierAttMap.get(supplierCode).add(att);
								} else {
									List<Attachment> AttList = new List<Attachment>();
									AttList.add(att);
									SupplierAttMap.put(supplierCode, AttList); //Map SupplierAttMap <String, <List>>
								}

							}
						}


						for (String SupplierLinesItems: SupplierAttMap.keyset()) {
							//for each supplier

							for (ASI_KOR_POSM_Order_Detail__c POSMLINE : LinesMap.values()) {

								if (POSMLINE.ASI_KOR_Supplier__c == SupplierLinesItems) {
									//ID LineID = SupplierAttMap.get(SupplierLinesItems).ParentID;
									//ToAddresses.add('prsg.sfdc@gmail.com');
									// ToAddresses.add(LinesMap.get(SupplierLinesItems.ParentId).ASI_MFM_KR_Supplier_Email__c);
									ToAddresses.add(POSMLINE.ASI_MFM_KR_Supplier_Email__c);

								}
							}


							Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

							List<Messaging.Emailfileattachment> efaList = new List<Messaging.Emailfileattachment>();

							Integer numAttsBySupplier = SupplierAttMap.get(SupplierLinesItems).size();
							// system.assertEquals(numAttsBySupplier, null);


							if (numAttsBySupplier > 0) {

								for (Integer i = 0; i < numAttsBySupplier; i++) {
									Messaging.EmailFileAttachment efa =
											NEW Messaging.EmailFileAttachment(); //Define the email
									efa.setFileName(SupplierAttMap.get(SupplierLinesItems)[i].name);
									efa.setBody(SupplierAttMap.get(SupplierLinesItems)[i].body);
									efa.setContentType(SupplierAttMap.get(SupplierLinesItems)[i].contenttype);

									efaList.add(efa);
								}
							}


							email.setTargetObjectId(this.posmReqHeader.ownerid);
							email.setToAddresses(ToAddresses);
							email.setWhatId(SupplierAttMap.get(SupplierLinesItems)[0].ParentId);
							//email.setWhatId('a6bL00000008QB2');
							// system.assertEquals(email, null);
							email.setSaveAsActivity(false);
							email.setBccSender(false);
							email.setUseSignature(false);
							email.setTemplateId(templateId);

							if (efaList.size() > 0) {
								email.setFileAttachments(efaList);

							}


							Messaging.SendEmailResult [] r =
									Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); //Send the email


						}
					}
				}
			}
		}

	// 20190603 Wilson Chow Added
	/*
	public void validateWithinBudget() {

		msg = '';
		Boolean isProcess = valdationCheckingStep(allPOSMLineMap);
		if(!isProcess) {
			return;
		}

		validationMsg = null;
		Decimal newTotalAmount = 0;
		validationAction = Apexpages.currentPage().getParameters().get('action');

		for (String key : allPOSMLineMap.keySet()) {
			if (allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c != null) {
				newTotalAmount += allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c;
			}
		}

		List<ASI_KOR_POSM_Order_Request__c> requestList =
			[select Id, ASI_KOR_Fiscal_Year__c, ASI_KOR_Sub_brand__c, ASI_KOR_Region__c, ASI_KOR_Actual_Spending_Amount__c, ASI_MFM_Sales_Branch__c from ASI_KOR_POSM_Order_Request__c where Id = :posmReqHeader.Id limit 1];

		if(requestList.size() == 0) {
			return;
		}

		List<ASI_KOR_POSM_Order_Request__c> updatedRequestList = new List<ASI_KOR_POSM_Order_Request__c>();
		ASI_KOR_POSM_Order_Request__c request = requestList.get(0);
		Map<Id, Decimal> requestIdAmountMap = new Map<Id, Decimal>();

		requestIdAmountMap.put(request.Id, newTotalAmount);
		updatedRequestList.add(request);

		String errorMsg =
				ASI_KOR_POSM_Order_Request_TriggerClass.validateActualSpendingAmount(updatedRequestList, requestIdAmountMap);

		if(String.isNotBlank(errorMsg)) {
			validationMsg = errorMsg;
		}

		return;
	}
	*/
	
	public PageReference validateWithinBudget_pageRef() {

		UpsertPermission = true;
		SaveSuccess = false;
		msg = '';
		Boolean isProcess = valdationCheckingStep(allPOSMLineMap);
		if(!isProcess) {
			UpsertPermission = false;
			return null;
		}

		validationMsg = null;
		Decimal newTotalAmount = 0;
		validationAction = Apexpages.currentPage().getParameters().get('action');

		for (String key : allPOSMLineMap.keySet()) {
			if (allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c != null) {
				newTotalAmount += allPOSMLineMap.get(key).linesitems.ASI_KOR_TotalAmount__c;
			}
		}

		List<ASI_KOR_POSM_Order_Request__c> requestList =
			[select Id, ASI_KOR_Fiscal_Year__c, ASI_KOR_Sub_brand__c, ASI_KOR_Region__c, ASI_KOR_Actual_Spending_Amount__c, ASI_MFM_Sales_Branch__c from ASI_KOR_POSM_Order_Request__c where Id = :posmReqHeader.Id limit 1];

		if(requestList.size() == 0) {
			return null;
		}

		List<ASI_KOR_POSM_Order_Request__c> updatedRequestList = new List<ASI_KOR_POSM_Order_Request__c>();
		ASI_KOR_POSM_Order_Request__c request = requestList.get(0);
		Map<Id, Decimal> requestIdAmountMap = new Map<Id, Decimal>();

		requestIdAmountMap.put(request.Id, newTotalAmount);
		updatedRequestList.add(request);

		String errorMsg =
				ASI_KOR_POSM_Order_Request_TriggerClass.validateActualSpendingAmount(updatedRequestList, requestIdAmountMap);

		if(String.isNotBlank(errorMsg)) {
			validationMsg = errorMsg;
		}

		return null;
	}
}