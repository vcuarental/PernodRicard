public class ASI_CRM_VisitationController
{    
    public ASI_CRM_VisitationController()
    {
	}
	
	public class callResult
	{
		@AuraEnabled
		public String type { get; set; }

		@AuraEnabled
        public String message { get; set; }
	}

	public class VPD {
		@AuraEnabled
		public String custAddress { get; set; }

		@AuraEnabled
		public String custPhone { get; set; }

		@AuraEnabled
		public ASI_HK_CRM_Visitation_Plan_Detail__c vpd { get; set; }
	}

	public class VisitResult
    {
        @AuraEnabled
        public Integer page { get; set; }
		
		@AuraEnabled
		public Integer totalPage { get; set; }
		
		@AuraEnabled
        public List<VPD> vpdList { get; set; }
	}
	
	public class RSPResult
	{
		@AuraEnabled
		public Boolean previousVisit { get; set; }

		@AuraEnabled
		public ASI_HK_CRM_Visitation_Plan_Detail__c vpd { get; set; }
		
		@AuraEnabled
		public ASI_CRM_RSPHeader__c rspHeader { get; set; }

		@AuraEnabled
		public List<ASI_TH_CRM_RSP__c> rspDetails { get; set; }

		// @AuraEnabled
		// public List<ASI_MFM_SKU_Code__c> skuList { get; set; }
	}

	@AuraEnabled
    public static List<VPD> getTodayVisit() 
    {
		ID userID = UserInfo.getUserId();
		Date today = System.Today();
		ASI_CRM_VisitationPlanSetting__c setting = ASI_CRM_VisitationPlanSetting__c.getInstance();

		string query = 'select ID, Name, ASI_HK_CRM_Visitation_Plan__c'
						+ ', ASI_CRM_MY_Customer__c, ASI_CRM_MY_Customer__r.Name, ASI_CRM_MY_Customer__r.ASI_TH_CRM_OutletType__r.Name'
						+ ', ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s, ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s'
						+ ', ASI_CRM_MY_Customer__r.' + setting.ASI_CRM_Customer_Address__c + ', ASI_CRM_MY_Customer__r.' + setting.ASI_CRM_Customer_Phone__c
						+ ', ASI_CRM_MY_Customer__r.ASI_CRM_JP_City_Ward__c, ASI_CRM_MY_Customer__r.ASI_CRM_JP_Town__c'
						+ ', ASI_CRM_MY_Customer__r.ASI_CRM_Street_Number__c, ASI_CRM_MY_Customer__r.ASI_CRM_Building_Floor_Number__c '
						+ ', ASI_CRM_MY_Customer__r.ASI_CRM_Country__c'
						+ ', ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Status__c'
						+ ' from ASI_HK_CRM_Visitation_Plan_Detail__c'
						+ ' where ASI_HK_CRM_Visitation_Plan__r.OwnerId = :userID'
						+ ' and ASI_CRM_MY_Customer__c != null'
						+ ' and ASI_HK_CRM_Visit_Date__c = :today'
						+ ' order by ASI_HK_CRM_Visit_Date__c desc'
						+ ' limit 100';
		
		List<ASI_HK_CRM_Visitation_Plan_Detail__c> vList = database.query(query);
		List<VPD> vpdList = new List<VPD>();

		for (ASI_HK_CRM_Visitation_Plan_Detail__c v : vList)
		{
			VPD vpd = new VPD();
			vpd.vpd = v;
			vpd.custAddress = String.valueOf(v.getSobject('ASI_CRM_MY_Customer__r').get(setting.ASI_CRM_Customer_Address__c));
			vpd.custPhone = String.valueOf(v.getSobject('ASI_CRM_MY_Customer__r').get(setting.ASI_CRM_Customer_Phone__c));
			vpdList.add(vpd);
		}

		return vpdList;
	}
	
	@AuraEnabled
    public static VisitResult getPreviousVisit(ID customerID, ID visitID, Integer page, Integer pSize) 
    {
		if (page < 1)
		{
			page = 1;
		}

		Date today = System.today();
		Integer offset = (page - 1) * pSize;
		
		ID userID = UserInfo.getUserId();
		ASI_CRM_VisitationPlanSetting__c setting = ASI_CRM_VisitationPlanSetting__c.getInstance();

		Integer totalRecords = 0;

		if (customerID == null)
		{
			totalRecords = [
				select count()
				from ASI_HK_CRM_Visitation_Plan_Detail__c
				where ASI_HK_CRM_Visitation_Plan__r.OwnerId = :userID
			];
		}
		else
		{
			totalRecords = [
				select count()
				from ASI_HK_CRM_Visitation_Plan_Detail__c
				where ASI_HK_CRM_Visitation_Plan__r.OwnerId = :userID
				and ASI_CRM_MY_Customer__c = :customerID
				and ID != :visitID
			];	
		}

		Decimal tPage = ((Decimal)totalRecords / (Decimal)pSize);
		Integer totalPage = (Integer)Math.ceil(tPage);

		if (page > totalPage)
		{
			page = totalPage;
		}

		string query = '';
		if (customerID == null)
		{
			query = 'select ID, Name, ASI_HK_CRM_Visitation_Plan__c'
						+ ', ASI_CRM_MY_Customer__c, ASI_CRM_MY_Customer__r.Name, ASI_CRM_MY_Customer__r.ASI_TH_CRM_OutletType__r.Name'
						+ ', ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s, ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s'
						+ ', ASI_CRM_MY_Customer__r.' + setting.ASI_CRM_Customer_Address__c + ', ASI_CRM_MY_Customer__r.' + setting.ASI_CRM_Customer_Phone__c
						+ ', ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Status__c'
						+ ' from ASI_HK_CRM_Visitation_Plan_Detail__c'
						+ ' where ASI_HK_CRM_Visitation_Plan__r.OwnerId = :userID'
						+ ' and ASI_HK_CRM_Visit_Date__c < :today'
						+ ' order by ASI_HK_CRM_Visit_Date__c desc'
						+ ' limit :pSize offset :offset';
		}
		else
		{
			query = 'select ID, Name, ASI_HK_CRM_Visitation_Plan__c'
						+ ', ASI_CRM_MY_Customer__c, ASI_CRM_MY_Customer__r.Name, ASI_CRM_MY_Customer__r.ASI_TH_CRM_OutletType__r.Name'
						+ ', ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s, ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s'
						+ ', ASI_CRM_MY_Customer__r.' + setting.ASI_CRM_Customer_Address__c + ', ASI_CRM_MY_Customer__r.' + setting.ASI_CRM_Customer_Phone__c
						+ ', ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Status__c'
						+ ' from ASI_HK_CRM_Visitation_Plan_Detail__c'
						+ ' where ASI_HK_CRM_Visitation_Plan__r.OwnerId = :userID'
						+ ' and ASI_CRM_MY_Customer__c = :customerID'
						+ ' and ASI_HK_CRM_Visit_Date__c < :today'
						+ ' and ID != :visitID'
						+ ' order by ASI_HK_CRM_Visit_Date__c desc'
						+ ' limit :pSize offset :offset';
		}

		List<ASI_HK_CRM_Visitation_Plan_Detail__c> vList = database.query(query);
		List<VPD> vpdList = new List<VPD>();

		for (ASI_HK_CRM_Visitation_Plan_Detail__c v : vList)
		{
			VPD vpd = new VPD();
			vpd.vpd = v;
			vpd.custAddress = String.valueOf(v.getSobject('ASI_CRM_MY_Customer__r').get(setting.ASI_CRM_Customer_Address__c));
			vpd.custPhone = String.valueOf(v.getSobject('ASI_CRM_MY_Customer__r').get(setting.ASI_CRM_Customer_Phone__c));
			vpdList.add(vpd);
		}
		
		VisitResult result = new VisitResult();
		result.page = page;
		result.totalPage = totalPage;
		result.vpdList = vpdList;

		return result;
	}

	@AuraEnabled
    public static List<ASI_CRM_AccountsAdditionalField__c> getCustomerList(string name)
    {
		if (name == '')
		{
			return new List<ASI_CRM_AccountsAdditionalField__c>();
		}

		ASI_CRM_VisitationRTypeMapping__c setting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		Set<ID> customerRTID = new Set<ID>();
		List<string> rtArr = setting.ASI_CRM_CustomerRTypeAPI__c.split(',');
		for (string api : rtArr)
		{
			customerRTID.add(Global_RecordTypeCache.getRtId(api));
		}

		string searchStr = '%' + name + '%';
		return [
			select ID, Name
			from ASI_CRM_AccountsAdditionalField__c
			where RecordTypeId in :customerRTID
			and Name like :searchStr
			order by Name
			limit 5
		];
	}

	@AuraEnabled
    public static List<ASI_MFM_SKU_Code__c> getSKUList(string name)
    {
		ASI_CRM_VisitationRTypeMapping__c setting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		ID skuRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_SKURTypeAPI__c);
		string filter = setting.ASI_CRM_SKURSPFilter__c;

		if (name == '')
		{
			return new List<ASI_MFM_SKU_Code__c>();
		}

		string searchStr = '%' + name + '%';

		string query = 'select ID, Name, ASI_MFM_SKU_Code__c, ASI_HK_CRM_English_Name__c, ASI_MFM_Sub_brand__c'
						+ ' from ASI_MFM_SKU_Code__c'
						+ ' where RecordTypeId = :skuRTID'
						+ ' and Name like :searchStr'
						+ (filter != null ? ' and (' + filter + ')' : '')
						+ ' order by Name'
						+ ' limit 20';
		
		// return [
		// 	select ID, Name, ASI_MFM_SKU_Code__c, ASI_HK_CRM_English_Name__c, ASI_MFM_Sub_brand__c
		// 	from ASI_MFM_SKU_Code__c
		// 	where RecordTypeId = :skuRTID
        //     and ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_Category_Code__c != 'PR'
        //     //and ASI_HK_CRM_IsPOSProduct__c = false and ASI_HK_CRM_Active__c = true
		// 	and Name like :searchStr
		// 	order by Name
		// 	limit 20
		// ];

		return database.query(query);
	}

	@AuraEnabled
    public static RSPResult getRSP(ID visitID)
    {
		RSPResult result = new RSPResult();

		if (visitID == null)
		{
			return result;
		}

		Date today = System.today();

		List<ASI_HK_CRM_Visitation_Plan_Detail__c> vpdList = [
			select ID, Name, ASI_HK_CRM_Visitation_Plan__c
					, ASI_CRM_MY_Customer__c, ASI_CRM_MY_Customer__r.Name
					, ASI_TH_CRM_Visit_Date_Time_From__c, ASI_TH_CRM_Visit_Date_Time_To__c, ASI_HK_CRM_Visit_Date__c
			from ASI_HK_CRM_Visitation_Plan_Detail__c
			where ID = :visitID
			limit 1];
		
		if (vpdList.size() == 0)
		{
			return result;
		}

		result.vpd = vpdList[0];

		if (result.vpd.ASI_HK_CRM_Visit_Date__c != today)
		{
			result.previousVisit = true;
		}
		else
		{
			if (result.vpd.ASI_TH_CRM_Visit_Date_Time_From__c != null && result.vpd.ASI_TH_CRM_Visit_Date_Time_To__c != null)
			{
				result.previousVisit = true;
			}
			else
			{
				result.previousVisit = false;
			}
		}
		

		ASI_CRM_VisitationRTypeMapping__c setting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		ID rspHeaderRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_RSPHeaderRTypeAPI__c);
		ID rspDetailRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_RSPDetailRTypeAPI__c);
		ID subBrandRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_SubBrandRTypeAPI__c);
		ID skuRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_SKURTypeAPI__c);
		ID userID = UserInfo.getUserId();

		List<ASI_CRM_RSPHeader__c> rspHeader = [
			select ID, Name, ASI_CRM_Branch__c
					, ASI_CRM_Customer__c, ASI_CRM_Date__c, ASI_CRM_Remark__c
			from ASI_CRM_RSPHeader__c
			where 
			RecordTypeId = :rspHeaderRTID
			and OwnerId = :userID
			and ASI_CRM_Customer__c = :result.vpd.ASI_CRM_MY_Customer__c
			and ASI_CRM_Date__c = :result.vpd.ASI_HK_CRM_Visit_Date__c
			limit 1
		];

		if (rspHeader.size() >= 1)
		{
			result.rspHeader = rspHeader[0];
			if (result.rspHeader.ASI_CRM_Remark__c == null)
			{
				result.rspHeader.ASI_CRM_Remark__c = '';
			}

			List<ASI_TH_CRM_RSP__c> rspDetails = [
				select ID, Name, ASI_CRM_RSPHeader__c
						, ASI_CRM_CN_Input_Date_Time__c, ASI_CRM_Price_to_Consumer__c
						, ASI_CRM_SKU__c, ASI_CRM_SKU__r.Name
				from ASI_TH_CRM_RSP__c
				where
				ASI_CRM_RSPHeader__c = :result.rspHeader.Id
				order by ID
			];

			result.rspDetails = rspDetails;
		}
		
		if (result.rspHeader == null)
		{
			result.rspHeader = new ASI_CRM_RSPHeader__c(
				ASI_CRM_Customer__c = result.vpd.ASI_CRM_MY_Customer__c,
				ASI_CRM_Date__c = result.vpd.ASI_HK_CRM_Visit_Date__c,
				ASI_CRM_Remark__c = ''
			);
		}

		if (result.rspDetails == null)
		{
			result.rspDetails = new List<ASI_TH_CRM_RSP__c>();
		}

		// result.skuList = [
		// 	select ID, Name, ASI_MFM_SKU_Code__c, ASI_HK_CRM_English_Name__c, ASI_MFM_Sub_brand__c
		// 	from ASI_MFM_SKU_Code__c
		// 	where RecordTypeId = :skuRTID
		// 	order by ID
		// ];

		return result;
	}

	@AuraEnabled
    public static CallREsult saveRSP(string rspHeaderStr, string rspDetailsStr, string deleteRspDetailsStr)
    {
		CallResult result = new CallResult();
		result.type = 'success';
		result.message = 'No RSP Saved.';

		ASI_CRM_RSPHeader__c rspHeader = (ASI_CRM_RSPHeader__c)System.JSON.deserializeStrict(rspHeaderStr, ASI_CRM_RSPHeader__c.class);
		List<ASI_TH_CRM_RSP__c> rspDetails = (List<ASI_TH_CRM_RSP__c>)System.JSON.deserializeStrict(rspDetailsStr, List<ASI_TH_CRM_RSP__c>.class);
		List<ASI_TH_CRM_RSP__c> deleteRspDetails = (List<ASI_TH_CRM_RSP__c>)System.JSON.deserializeStrict(deleteRspDetailsStr, List<ASI_TH_CRM_RSP__c>.class);
		ASI_CRM_VisitationRTypeMapping__c setting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		ID rspHeaderRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_RSPHeaderRTypeAPI__c);
		ID rspDetailRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_RSPDetailRTypeAPI__c);
		Datetime today = System.now();
		List<ASI_TH_CRM_RSP__c> upsertList = new List<ASI_TH_CRM_RSP__c>();

		if (rspHeader == null && rspDetails.size() == 0 && deleteRspDetails.size() == 0)
		{
			result.type = 'error';
			result.message = 'Fail to Saved';
			return result;
		}
		
		try
		{
			for (ASI_TH_CRM_RSP__c detail : rspDetails)
			{
				if (detail.ASI_CRM_SKU__c != null && detail.ASI_CRM_Price_to_Consumer__c > 0)
				{
					upsertList.add(detail);
				}
				else if (detail.Id != null && (detail.ASI_CRM_SKU__c == null || detail.ASI_CRM_Price_to_Consumer__c <= 0))
				{
					deleteRspDetails.add(detail);
				}
			}

			if (rspHeader != null)
			{
				rspHeader.RecordTypeId = rspHeaderRTID;
				upsert rspHeader;
			}

			if (upsertList.size() > 0)
			{
				for (ASI_TH_CRM_RSP__c detail : upsertList)
				{
					detail.ASI_CRM_RSPHeader__c = rspHeader.Id;
					detail.RecordTypeId = rspDetailRTID;
					detail.ASI_CRM_CN_Input_Date_Time__c = today;
				}

				upsert upsertList;
			}

			if (deleteRspDetails.size() > 0)
			{
				delete deleteRspDetails;
			}
		}
		catch (Exception e)
		{
			result.type = 'error';
			result.message = e.getMessage();
			return result;
		}

		if (upsertList.size() > 0)
		{
			result.type = 'success';
			result.message = upsertList.size() + ' RSP Saved';
			return result;
		}

		return result;
	}

	@AuraEnabled
	public static CallResult saveAdhoc(ID customerID)
    {
		CallResult result = new CallResult();
		result.type = 'success';
		result.message = 'Visitation Saved';

		if (customerID == null)
		{
			result.type = 'error';
			result.message = 'Please select customer';
			return result;
		}
		
		ID userID = UserInfo.getUserId();
		ASI_CRM_VisitationRTypeMapping__c setting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		ID visitPlanRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_VisitationPlanRTypeAPI__c);
		ID visitPlanDetailRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_VisitationPlanDetailAHRTypeAPI__c);
		Date today = System.today();

		List<ASI_HK_CRM_Visitation_Plan__c> planList = [
			select ID
			from ASI_HK_CRM_Visitation_Plan__c
			where OwnerId = :userID
			and ASI_CRM_TH_Month_Start_Date__c <= :today
			and ASI_CRM_TH_Month_End_Date__c >= :today
			limit 1
		];

		if (planList.size() == 0)
		{
			result.type = 'error';
			result.message = 'Please create Vistiation Plan first';
			return result;
		}

		List<ASI_HK_CRM_Visitation_Plan_Detail__c> detailList = [
			select ID
			from ASI_HK_CRM_Visitation_Plan_Detail__c
			where ASI_HK_CRM_Visitation_Plan__c = :planList[0].ID
			and ASI_CRM_MY_Customer__c = :customerID
			and ASI_HK_CRM_Visit_Date__c = :today
			limit 1
		];

		if (detailList.size() > 0)
		{
			result.type = 'error';
			result.message = 'You cannot visit same Customer twice';
			return result;
		}

		ASI_HK_CRM_Visitation_Plan_Detail__c detail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
			ASI_HK_CRM_Visitation_Plan__c = planList[0].ID,
			ASI_CRM_MY_Customer__c = customerID,
			ASI_HK_CRM_Visit_Date__c = today,
			ASI_HK_CRM_Status__c = 'Ad-hoc',
			RecordTypeId = visitPlanDetailRTID
		);

		try {
			insert detail;
		}
		catch (Exception e)
		{
			result.type = 'error';
			result.message = e.getMessage();
			return result;
		}

		return result;
	}
}