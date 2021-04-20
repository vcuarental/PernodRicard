/**********************************************************************************
* Name : ASI_KOR_NSDApprovalController 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??										Created
* 2017-05-05		Laputa: Vincent			[VL 1.0] P4.2 logic
* 2017-08-09		Laputa: Vincent			[VL 2.0] P4.2 report
**********************************************************************************/
public without sharing class ASI_KOR_NSDApprovalController{
    
    public ASI_KOR_NSD_Proposal_Header__c nsdHeader {get;set;}
    public List<RSDByBranchCategory> rsdByRegionCategoryList {get; set;}
    public Decimal propUnitCost{get;set;}
    public Decimal propUnitCostCA{get;set;}
    public Decimal last3MonthAveVolume{get;set;}
    public Decimal last3MonthAveUnitCost{get;set;}
    public Decimal growth{get;set;}
    public Decimal targetVolume{get;set;}
    public Decimal propTotalIncentive{get;set;}
    public Decimal propTotalPendingIncentive{get;set;}
    public Decimal propPendingCA{get;set;}
    public Decimal propTotalCA{get;set;}
    public Decimal branchBudget{get;set;}
    public String status{get;set;}
    public Boolean renderApprove {get; set;}
    public Boolean renderRecall {get; set;}
    public Boolean canEdit {get; set;}
    public static Set<String> tmktRoles = new Set<String>{'Trade Marketing Director','Trade Marketing Team','Business Development (Admin)'};
        
        
	/* [VL 1.0] BEGIN */
    public String srMonth {get;set;}
    public String srYear {get;set;} 
    public Decimal GrandTotalByBrand_volume_2M {get;set;}
    public Decimal GrandTotalByBrand_volume_1M {get;set;}
    public Decimal GrandTotalByBrand_volume_TM {get;set;}
    public Decimal GrandTotalByBrand_vi_2M     {get;set;}
    public Decimal GrandTotalByBrand_vi_1M     {get;set;}
    public Decimal GrandTotalByBrand_vi_TM     {get;set;}
    public Decimal GrandTotalByBrand_volume_budget {get;set;}
    public Decimal GrandTotalByBrand_vi_budget     {get;set;}
	public Decimal getGrandTotalByBrand_uc_2M() {
		return GrandTotalByBrand_vi_2M / (GrandTotalByBrand_volume_2M == 0 ? 1 : GrandTotalByBrand_volume_2M);
	}
	public Decimal getGrandTotalByBrand_uc_1M() {
		return GrandTotalByBrand_vi_1M / (GrandTotalByBrand_volume_1M == 0 ? 1 : GrandTotalByBrand_volume_1M);
	}
	public Decimal getGrandTotalByBrand_uc_TM() {
		return GrandTotalByBrand_vi_TM / (GrandTotalByBrand_volume_TM == 0 ? 1 : GrandTotalByBrand_volume_TM);
	}
	public Decimal getGrandTotalByBrand_uc_budget() {
		return GrandTotalByBrand_vi_budget / (GrandTotalByBrand_volume_budget == 0 ? 1 : GrandTotalByBrand_volume_budget);
	}
	public String getGrandTotalByBrandBudgetStatus(){
		return getGrandTotalByBrand_uc_TM() > getGrandTotalByBrand_uc_budget() ? 'Exceed Target' : 'Within Target';
	}
	
	public string getLast2Month_year(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-2);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('yyyy');
	}
	public string getLast2Month_month(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-2);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('MM');
	}
	public string getLast1Month_year(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-1);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('yyyy');
	}
	public string getLast1Month_month(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Date lastDate = thisProposalDate.addMonths(-1);
		Datetime lastDateTime = Datetime.newInstance(lastDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('MM');
	}
	public string getThisMonth_year(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Datetime lastDateTime = Datetime.newInstance(thisProposalDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('yyyy');
	}
	public string getThisMonth_month(){
		Date thisProposalDate = Date.newInstance(integer.valueOf(srYear), integer.valueOf(srMonth), 1);
		Datetime lastDateTime = Datetime.newInstance(thisProposalDate, Time.newInstance(12, 0, 0, 0));
		return lastDateTime.format('MM');
	}
	public Decimal 	GrandTotal_volume {get;set;}
	public Decimal 	GrandTotal_UC {get;set;}
	public Decimal 	GrandTotal_VI {get;set;}
	public Decimal 	GrandTotal_volume_lastMonth {get;set;}
	public Decimal 	GrandTotal_UC_lastMonth {get;set;}
	public Decimal 	GrandTotal_VI_lastMonth {get;set;}
	public Decimal 	GrandTotal_budget_volume {get;set;}
	public Decimal 	GrandTotal_budget_vi {get;set;}
	public Decimal 	GrandTotal_UC_budget {get;set;}
	public String 	getGrandBudgetStatus(){
		return GrandTotal_UC > GrandTotal_UC_budget ? 'Exceed Target' : 'Within Target';
	}
	/* [VL 1.0] END */
	
        public ASI_KOR_NSDApprovalController(ApexPages.StandardController standardController){
            system.debug('XX');
            renderRecall= false;
            renderApprove = false;
            
            
            Id headerId = ((ASI_KOR_NSD_Proposal_Header__c)standardController.getRecord()).id;
            nsdHeader = [select id,
							ASI_KOR_Delegated_Approver__c ,
							ASI_KOR_No_of_Sumitted_Regions__c,
							ASI_KOR_CA_Amount_Pending__c,
                         ASI_KOR_National_Sales_Director_Comments__c,
						 ASI_KOR_Total_CA_Amount_excl_Basic__c,
						 ASI_KOR_Total_Incentive_Amount_Proposal__c, 
						 name,
						 ASI_KOR_Month__c, 
						 ASI_KOR_Status__c, 
						 ASI_KOR_Year__c 
						   /* [VL 1.0] BEGIN */
						   , ASI_KOR_Total_VI_Pending__c
						   /* [VL 1.0] END */
						 from ASI_KOR_NSD_Proposal_Header__c 
						 where id =: headerId];
            
			/* [VL 1.0] BEGIN */
			srYear = nsdHeader.ASI_KOR_Year__c;
			srMonth = nsdHeader.ASI_KOR_Month__c;
			/* [VL 1.0] END */
			
            if(nsdHeader.ASI_KOR_Status__c != 'Approved'){
                renderApprove= true;
            }
            
            User currentUser = [select id, userrole.name from user where id =: UserInfo.getUserId()];
            String uRole = currentUser.userrole.name;
            
            canEdit = (!tmktRoles.contains(uRole) || (nsdHeader.ASI_KOR_Delegated_Approver__c == currentUser.id));
            
            Map<Id,ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderMap = new Map<Id,ASI_KOR_RSD_Proposal_Header__c>([select id,
                                                                                                                      ASI_KOR_Approval_Comments__c,ASI_KOR_Regional_Sales_Director_Comments__c,
                                                                                                                      ASI_KOR_Region_Total_CA_Budget__c,ASI_KOR_Region_Total_Status__c,
                                                                                                                      ASI_KOR_Total_CA_Amount_excl_Basic__c,ASI_KOR_Total_Incentive_Amount_Proposal__c,ownerId,ASI_KOR_Status__c 
                                                                                                                      from ASI_KOR_RSD_Proposal_Header__c where ASI_KOR_NSD_Proposal_Header__c =:headerId
                                                                                                                      and (ASI_KOR_Status__c = 'Submitted' or ASI_KOR_Status__c = 'Approved by NSD')
                                                                                                                     ]);
            
            if(rsdProposalHeaderMap.size()>0)
                populateDetails(rsdProposalHeaderMap);
            
            populateSummary();
            populateNationalTotal();
        }
    
    private void populateDetails(Map<Id,ASI_KOR_RSD_Proposal_Header__c> rsdProposalHeaderMap){
        
		/* [VL 1.0] BEGIN */
		GrandTotal_volume = 0;
		GrandTotal_UC = 0;
		GrandTotal_VI = 0;
		GrandTotal_volume_lastMonth = 0;
		GrandTotal_UC_lastMonth = 0;
		GrandTotal_VI_lastMonth = 0;
		GrandTotal_budget_volume = 0;
		GrandTotal_budget_vi = 0;
		GrandTotal_UC_budget = 0;
		/* [VL 1.0] END */
        
        
        Set<Id> usersId = new Set<Id>();
        
        for(Id i: rsdProposalHeaderMap.keySet()){ 
            usersId.add(rsdProposalHeaderMap.get(i).ownerId);
        }
        Map<Id, User> userMap = new Map<Id, User> ([select id,ASI_KOR_User_Region_Name__c,ASI_KOR_User_Region_Code__c from User where id in:usersId]);
        
        Map<Id, String> regionMap = new Map<Id,String>();
        
        for(Id id : rsdProposalHeaderMap.keySet()){
            Id oId = rsdProposalHeaderMap.get(id).ownerId;
            String regionName= userMap.get(oId).ASI_KOR_User_Region_Name__c;
            regionMap.put(id,regionName);
        }
        
        Map<Id,ASI_KOR_NSD_Proposal_By_Brand__c> nsdProposalByBrandMap = new Map<Id,ASI_KOR_NSD_Proposal_By_Brand__c>([select id, name from ASI_KOR_NSD_Proposal_By_Brand__c where 
                                                                                                                       ASI_KOR_NSD_Proposal_Header__c =: nsdHeader.id]);
        
        List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdProposalByBrands = [select id, name,
                                                                      ASI_KOR_RSD_Proposal_Header__c,
                                                                      ASI_KOR_Brand__r.name,
                                                                      ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name,
                                                                      ASI_KOR_CA_Budget__c,
                                                                      ASI_KOR_CA_Budget_Status__c,
                                                                      ASI_KOR_Category__c,
                                                                      ASI_KOR_Last_3_month_Actual_Average_Volu__c,
                                                                      ASI_KOR_Last_3_month_Actual_Average_UC__c,
                                                                      ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
                                                                      ASI_KOR_Proposal_Unit_Cost_CA_Only__c,
                                                                      ASI_KOR_NSD_Proposal_By_Brand__c,
                                                                      ASI_KOR_Target_Volume__c,
                                                                      ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                      ASI_KOR_Total_Incentive_Amount_Proposal__c,
                                                                      ASI_KOR_Growth__c,
                                                                      ASI_KOR_UOM__c
																	/* [VL 1.0] BEGIN */
																	, ASI_KOR_Actual_Volume_1_Month_Ago__c
																	, ASI_KOR_Actual_Volume_2_Months_Ago__c
																	, ASI_KOR_Total_VI_1_Month_Ago__c
																	, ASI_KOR_Total_VI_2_Months_Ago__c
																	, ASI_KOR_Unit_Cost_1_Month_Ago__c
																	, ASI_KOR_Budget_Target_VI__c
																	, ASI_KOR_Budget_Target_Volume__c
																	/* [VL 1.0] END */
                                                                      from
                                                                      ASI_KOR_RSD_Proposal_By_Brand__c
                                                                      where (ASI_KOR_NSD_Proposal_By_Brand__c in: nsdProposalByBrandMap.keySet() and
                                                                             ASI_KOR_RSD_Proposal_Header__c in:rsdProposalHeaderMap.keySet())
																	/* [VL 1.0] BEGIN */
																	/*
                                                                    order by ASI_KOR_RSD_Proposal_Header__c,ASI_KOR_Brand__r.name
																	*/
                                                                    order by ASI_KOR_RSD_Proposal_Header__c, ASI_KOR_CA_Budget_Status__c, ASI_KOR_Total_Incentive_Amount_Proposal__c desc, ASI_KOR_Brand__r.name
																	/* [VL 1.0] END */ 
                                                                      ];
        
        
        Map<Id,List<ASI_KOR_RSD_Proposal_By_Brand__c>> tempMap = new Map<Id,List<ASI_KOR_RSD_Proposal_By_Brand__c>>();
        
        for(ASI_KOR_RSD_Proposal_By_Brand__c rsd: rsdProposalByBrands){
            String region =  regionMap.get(rsd.ASI_KOR_RSD_Proposal_Header__c);
            if(tempMap.get(rsd.ASI_KOR_RSD_Proposal_Header__c) == null){
                tempMap.put(rsd.ASI_KOR_RSD_Proposal_Header__c, new List<ASI_KOR_RSD_Proposal_By_Brand__c>());
                tempMap.get(rsd.ASI_KOR_RSD_Proposal_Header__c).add(rsd);
            }else{
                tempMap.get(rsd.ASI_KOR_RSD_Proposal_Header__c).add(rsd);
            }
			/* [VL 1.0] BEGIN */
			GrandTotal_volume += rsd.ASI_KOR_Target_Volume__c == null ? 0 : rsd.ASI_KOR_Target_Volume__c;
			GrandTotal_VI += rsd.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : rsd.ASI_KOR_Total_Incentive_Amount_Proposal__c;
			GrandTotal_volume_lastMonth += rsd.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : rsd.ASI_KOR_Actual_Volume_1_Month_Ago__c;
			GrandTotal_VI_lastMonth += rsd.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : rsd.ASI_KOR_Total_VI_1_Month_Ago__c;
			GrandTotal_budget_volume += rsd.ASI_KOR_Budget_Target_Volume__c == null ? 0 : rsd.ASI_KOR_Budget_Target_Volume__c;
			GrandTotal_budget_vi += rsd.ASI_KOR_Budget_Target_VI__c == null ? 0 : rsd.ASI_KOR_Budget_Target_VI__c;
			/* [VL 1.0] END */
        } 
			/* [VL 1.0] BEGIN */
			GrandTotal_UC = GrandTotal_VI / (GrandTotal_volume == 0 ? 1 : GrandTotal_volume);
			GrandTotal_UC_lastMonth = GrandTotal_VI_lastMonth / (GrandTotal_volume_lastMonth == 0 ? 1 : GrandTotal_volume_lastMonth);
			GrandTotal_UC_budget = GrandTotal_budget_vi / (GrandTotal_budget_volume == 0 ? 1 : GrandTotal_budget_volume);
			/* [VL 1.0] END */
			
        rsdByRegionCategoryList = new List<RSDByBranchCategory>();
        for(String bmHeaderId: tempMap.keySet()){
            RSDByBranchCategory b = new RSDByBranchCategory();
            b.rsdProposalByBrands = tempMap.get(bmHeaderId);
            Id oId = rsdProposalHeaderMap.get(bmHeaderId).ownerId; 
            b.regionCode=  userMap.get(oId).ASI_KOR_User_Region_Code__c;
            b.regionName = userMap.get(oId).ASI_KOR_User_Region_Name__c;
            b.rsdHeader =  rsdProposalHeaderMap.get(bmHeaderId);
            rsdByRegionCategoryList.add(b);
        }
		
		/* [VL 1.0] BEGIN */
		rsdByRegionCategoryList.sort();
		/* [VL 1.0] END */
    }
    private void populateNationalTotal(){
        propUnitCost = 0;
        propUnitCostCA = 0;
        last3MonthAveVolume = 0;
        last3MonthAveUnitCost = 0;
        growth = 0;
        targetVolume = 0;
        propTotalIncentive = 0;
        propTotalPendingIncentive = 0;
        propTotalCA = 0;
        propPendingCA=0;
        branchBudget = 0;
        status ='';
        
        for(NSDByBrandByCategory x:nsdByBrandByCategoryList){
            propUnitCost += x.propUnitCost ;
            propUnitCostCA += x.propUnitCostCA ;
            propPendingCA += x.propPendingCA ;
            last3MonthAveVolume += x.last3MonthAveVolume;
            // last3MonthAveUnitCost += x.
            targetVolume += x.targetVolume;
            propTotalIncentive += x.propTotalIncentive;
            propTotalPendingIncentive +=x.propTotalPendingIncentive;
            propTotalCA += x.propTotalCA;
            branchBudget += x.branchBudget;
        }
        
        growth = (last3MonthAveVolume == 0)?0:(targetVolume/last3MonthAveVolume);
            status = propTotalCA > branchBudget?'Exceed Budget' : 'Within Budget';
    }
    
    
    public List<NSDByBrandByCategory> nsdByBrandByCategoryList {get;set;}
    public void populateSummary(){
        nsdByBrandByCategoryList = new  List<NSDByBrandByCategory>();
        
		/* [VL 1.0] BEGIN */
		GrandTotalByBrand_volume_2M = 0;
		GrandTotalByBrand_volume_1M = 0;
		GrandTotalByBrand_volume_TM = 0;
		GrandTotalByBrand_vi_2M     = 0;
		GrandTotalByBrand_vi_1M     = 0;
		GrandTotalByBrand_vi_TM     = 0;
		GrandTotalByBrand_vi_budget = 0;
		GrandTotalByBrand_volume_budget = 0;
		/* [VL 1.0] END */
		
        List<ASI_KOR_NSD_Proposal_By_Brand__c> nsdProposalByBrandsTemp =  [select id,ASI_KOR_Category__c, name, 
                                                                           ASI_KOR_Brand__r.name,
                                                                           ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
                                                                           ASI_KOR_Growth__c,
                                                                           ASI_KOR_CA_Budget__c,
                                                                           ASI_KOR_Last_3_month_Actual_Average_Volu__c,
                                                                           ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                           ASI_KOR_Total_Incentive_Amount_Proposal__c,
                                                                           ASI_KOR_CA_Amount_Pending__c,
                                                                           ASI_KOR_Total_Incentive_Amount_Pending__c,
                                                                           ASI_KOR_Proposal_Unit_Cost_CA_Only__c,
                                                                           ASI_KOR_Target_Volume__c ,
                                                                           ASI_KOR_CA_Budget_Status__c ,
                                                                           ASI_KOR_UOM__c
																		  /* [VL 1.0] BEGIN */
																		  , ASI_KOR_Actual_Volume_1_Month_Ago__c
																		  , ASI_KOR_Actual_Volume_2_Months_Ago__c
																		  , ASI_KOR_Total_VI_1_Month_Ago__c
																		  , ASI_KOR_Total_VI_2_Months_Ago__c
																		  , ASI_KOR_Target_Volume_Pending__c
																		  , ASI_KOR_Budget_Target_VI__c
																		  , ASI_KOR_Budget_Target_Volume__c
																		  /* [VL 1.0] END */
                                                                           from ASI_KOR_NSD_Proposal_By_Brand__c where 
                                                                           ASI_KOR_NSD_Proposal_Header__c =: nsdHeader.id];
        
        List<NSDByBrandByUnitCostCap> NSDByBrandByUnitCostCapList = new List<NSDByBrandByUnitCostCap>();
        Set<ID> brandIDSet = new Set<ID>();
        
        List<ASI_KOR_Budget__c> budgetList = new List<ASI_KOR_Budget__c>();
        Map<String, ASI_KOR_Budget__c> budgetMap = new Map<String, ASI_KOR_Budget__c>();
        
        for(ASI_KOR_NSD_Proposal_By_Brand__c nsdPerBrand : nsdProposalByBrandsTemp) {
            if(nsdPerBrand.ASI_KOR_Brand__c != null) {
                brandIDSet.add(nsdPerBrand.ASI_KOR_Brand__c);
            }
        }
        
        if(brandIDSet.size() > 0) {
            
            budgetList = [SELECT ID, Name, ASI_KOR_Brand__c, ASI_KOR_Unit_Cost_Cap__c, ASI_KOR_Month__c, ASI_KOR_Year__c,  ASI_KOR_Branch_Name__c
                          FROM ASI_KOR_Budget__c
                          WHERE ASI_KOR_Brand__c IN : brandIDSet 
                          AND ASI_KOR_Month__c = : nsdHeader.ASI_KOR_Month__c 
                          AND ASI_KOR_Year__c = : nsdHeader.ASI_KOR_Year__c 
                          /*AND ASI_KOR_Branch_Name__c IN : branchSet*/ ];
            
            if(budgetList.size() > 0) {
                for(ASI_KOR_Budget__c budget : budgetList) {
                    budgetMap.put((String)budget.ASI_KOR_Brand__c, budget);
                }
            }
        }
        
        for(ASI_KOR_NSD_Proposal_By_Brand__c nsdProposalByBrandsTempItem : nsdProposalByBrandsTemp) {
            NSDByBrandByUnitCostCap NSDByBrandByUnitCostCapItem = new NSDByBrandByUnitCostCap();
            NSDByBrandByUnitCostCapItem.NSDByBrandItem = nsdProposalByBrandsTempItem;
            
            if(budgetMap.containsKey(nsdProposalByBrandsTempItem.ASI_KOR_Brand__c)) {
                NSDByBrandByUnitCostCapItem.unitCostCap = budgetMap.get(nsdProposalByBrandsTempItem.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c;
            }
            
            NSDByBrandByUnitCostCapList.add(NSDByBrandByUnitCostCapItem);
        }
        
        List<NSDByBrandByUnitCostCap> nsdProposalByBrands =  NSDByBrandByUnitCostCapList;
        
        Map<String, List<NSDByBrandByUnitCostCap>> nationalCategoryMap = new Map<String, List<NSDByBrandByUnitCostCap>>();
        
        for(NSDByBrandByUnitCostCap nsd: nsdProposalByBrands ){
            if(nationalCategoryMap.get(nsd.NSDByBrandItem.ASI_KOR_Category__c) == null){
                List<NSDByBrandByUnitCostCap> l = new List<NSDByBrandByUnitCostCap>();
                l.add(nsd);
                nationalCategoryMap.put(nsd.NSDByBrandItem.ASI_KOR_Category__c,l);
            }else{ 
                nationalCategoryMap.get(nsd.NSDByBrandItem.ASI_KOR_Category__c).add(nsd);
            }
            //if(bm.ASI_KOR_CA_Budget__c == null){
            //   bm.ASI_KOR_CA_Budget__c = brandBudget.get(bm.ASI_KOR_Brand__c);
            //   budgetUpdate.add(bm);
            //}
        }
        String[] categories = new String[] {'Local Whisky','International Whisky','Modern Spirits','Competitor’s brands'};
            
		/* [VL 1.0] BEGIN */
		/*
		for(String category:  categories){
		*/
		for(String category:  nationalCategoryMap.keySet()){
		/* [VL 1.0] END */
			if(nationalCategoryMap.get(category) == null)
				continue;         
			
			NSDByBrandByCategory b = new NSDByBrandByCategory(nationalCategoryMap.get(category));
			b.category = category;
			// b.rsdProposalByBrands = regionalCategoryMap.get(category);
			nsdByBrandByCategoryList.add(b);
			
			/* [VL 1.0] BEGIN */
			for (NSDByBrandByUnitCostCap bmByBrandWrap : b.nsdProposalByBrands){
					ASI_KOR_NSD_Proposal_By_Brand__c bmByBrand = bmByBrandWrap.NSDByBrandItem;
					GrandTotalByBrand_vi_TM     += bmByBrand.ASI_KOR_Total_Incentive_Amount_Pending__c == null ? 0 : bmByBrand.ASI_KOR_Total_Incentive_Amount_Pending__c;
					GrandTotalByBrand_volume_TM += bmByBrand.ASI_KOR_Target_Volume_Pending__c == null ? 0 : bmByBrand.ASI_KOR_Target_Volume_Pending__c;
					GrandTotalByBrand_vi_1M     += bmByBrand.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Total_VI_1_Month_Ago__c;
					GrandTotalByBrand_volume_1M += bmByBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c;
					GrandTotalByBrand_vi_2M     += bmByBrand.ASI_KOR_Total_VI_2_Months_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Total_VI_2_Months_Ago__c;
					GrandTotalByBrand_volume_2M += bmByBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c == null ? 0 : bmByBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c;
					GrandTotalByBrand_vi_budget     += bmByBrand.ASI_KOR_Budget_Target_VI__c == null ? 0 : bmByBrand.ASI_KOR_Budget_Target_VI__c;
					GrandTotalByBrand_volume_budget += bmByBrand.ASI_KOR_Budget_Target_Volume__c == null ? 0 : bmByBrand.ASI_KOR_Budget_Target_Volume__c;
			}
			/* [VL 1.0] END */
		}
        
    }
    public class RSDByBranchCategory /* [VL 1.0] BEGIN */ implements Comparable /* [VL 1.0] END */{
        public ASI_KOR_RSD_Proposal_Header__c rsdHeader {get;set;} 
        public String regionName {get;set;}
        public String regionCode {get;set;}
        public List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdProposalByBrands {get;set;}
        
        public Decimal getTargetVolume(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c b: rsdProposalByBrands){
                temp = temp + ((b.ASI_KOR_Target_Volume__c == null)?0:b.ASI_KOR_Target_Volume__c);
            }
            return temp;
        }
		/* [VL 1.0] BEGIN */
        public Decimal getTotalVI(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c detail : rsdProposalByBrands){
				temp += detail.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : detail.ASI_KOR_Total_Incentive_Amount_Proposal__c;
            }
            return temp;
        } 
        public Decimal getTotalTargetVolume(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c detail : rsdProposalByBrands){
                temp += detail.ASI_KOR_Target_Volume__c == null ? 0 : detail.ASI_KOR_Target_Volume__c;
            }
            return temp;
        } 
        public Decimal getTotalUC(){
            return getTotalVI()/ (getTotalTargetVolume() == 0 ? 1 : getTotalTargetVolume());
        } 
        public Decimal getTotalVI_lastMonth(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c detail : rsdProposalByBrands){
                temp += detail.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Total_VI_1_Month_Ago__c;
            }
            return temp;
        } 
        public Decimal getTotalActualVolume_lastMonth(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c detail : rsdProposalByBrands){
                temp += detail.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Actual_Volume_1_Month_Ago__c;
            }
            return temp;
        } 
        public Decimal getTotalUC_lastMonth(){
            return getTotalVI_lastMonth()/ (getTotalActualVolume_lastMonth() == 0 ? 1 : getTotalActualVolume_lastMonth());
        } 
        public Decimal getTotalBudget(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c detail : rsdProposalByBrands){
                temp += detail.ASI_KOR_CA_Budget__c == null ? 0 : detail.ASI_KOR_CA_Budget__c;
            }
            return temp;
        } 
        public Decimal getTotalBudgetVI(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c detail : rsdProposalByBrands){
                temp += detail.ASI_KOR_Budget_Target_VI__c == null ? 0 : detail.ASI_KOR_Budget_Target_VI__c;
            }
            return temp;
        } 
        public Decimal getTotalBudgetVolume(){
            Decimal temp = 0;
            for(ASI_KOR_RSD_Proposal_By_Brand__c detail : rsdProposalByBrands){
                temp += detail.ASI_KOR_Budget_Target_Volume__c == null ? 0 : detail.ASI_KOR_Budget_Target_Volume__c;
            }
            return temp;
        } 
        public Decimal getTotalBudgetUC(){
            return getTotalBudgetVI()/ (getTotalBudgetVolume() == 0 ? 1 : getTotalBudgetVolume());
        } 
        public String getVenueStatus(){
            return getTotalUC() > getTotalBudgetUC() ? 'Exceed Target' : 'Within Target';
        } 
		
		public Integer compareTo(Object compareTo){
			RSDByBranchCategory compareToWrap = (RSDByBranchCategory)compareTo;
			Integer returnValue = 0;
			if (getTotalVI()>compareToWrap.getTotalVI()) {
				returnValue = -1;
			} else
			if (getTotalVI()<compareToWrap.getTotalVI()) {
				returnValue = 1;
			} 
			return returnValue;
		}
		/* [VL 1.0] END */
    }
    
    //Inner class to accomodate UnitCost
    public class NSDByBrandByUnitCostCap{
        public Decimal unitCostCap {get; set; }
        
        public ASI_KOR_NSD_Proposal_By_Brand__c NSDByBrandItem {get; set; }
        
        
        public String getUnitCostStatus(){
            Decimal x = this.NSDByBrandItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
            Decimal z = this.NSDByBrandItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c;
            if(z>x)
                return 'Exceed Budget'; 
            else
                return 'Within Budget';
        }
		
		/* [VL 1.0] BEGIN */
		public boolean getDisplay(){
			if (
				this.NSDByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c == 0 &&
				this.NSDByBrandItem.ASI_KOR_Target_Volume_Pending__c == 0 &&
				this.NSDByBrandItem.ASI_KOR_Total_VI_1_Month_Ago__c == 0 &&
				this.NSDByBrandItem.ASI_KOR_Actual_Volume_1_Month_Ago__c == 0 &&
				this.NSDByBrandItem.ASI_KOR_Total_VI_2_Months_Ago__c == 0 &&
				this.NSDByBrandItem.ASI_KOR_Actual_Volume_2_Months_Ago__c == 0
			){
				return false;
			} else {
				return true;
			}
		}
		/* [VL 1.0] END */
    }
    
    
    public class NSDByBrandByCategory{ 
        public  Decimal last3MonthAveVolume {get;set;}
        public Decimal propUnitCost{get;set;}
        public Decimal propUnitCostCA{get;set;}
        public Decimal targetVolume{get;set;}
        public Decimal propTotalIncentive{get;set;}
        public Decimal propTotalPendingIncentive{get;set;}
        public Decimal propPendingCA{get;set;}
        public Decimal propTotalCA{get;set;}
        public Decimal branchBudget{get;set;}
        public String category{get;set;}
        public List<NSDByBrandByUnitCostCap> nsdProposalByBrands {get; set;}
        public NSDByBrandByCategory(List<NSDByBrandByUnitCostCap> a){
            nsdProposalByBrands = a;
            propUnitCost = 0;
            propUnitCostCA = 0;
            targetVolume = 0;
            propTotalIncentive = 0;
            propPendingCA = 0;
            propTotalPendingIncentive = 0;
            propTotalCA = 0;
            branchBudget = 0;
            last3MonthAveVolume = 0;
			/* [VL 1.0] BEGIN */
			this.ASI_KOR_Total_Incentive_Amount_Proposal = 0;
			this.ASI_KOR_Target_Volume = 0;
			this.ASI_KOR_Total_VI_1M_Ago = 0;
			this.ASI_KOR_Actual_Volume_1M_Ago = 0;
			this.ASI_KOR_Total_VI_2M_Ago = 0;
			this.ASI_KOR_Actual_Volume_2M_Ago = 0;
			this.ASI_KOR_Budget_Target_VI = 0;
			this.ASI_KOR_Budget_Target_Volume = 0;
			/* [VL 1.0] END */
            for(NSDByBrandByUnitCostCap b: nsdProposalByBrands){
                propUnitCost = propUnitCost + ((b.NSDByBrandItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c== null)?0:b.NSDByBrandItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c);
                propUnitCostCA = propUnitCost + ((b.NSDByBrandItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c== null)?0:b.NSDByBrandItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c);
                propPendingCA = propPendingCA + ((b.NSDByBrandItem.ASI_KOR_CA_Amount_Pending__c== null)?0:b.NSDByBrandItem.ASI_KOR_CA_Amount_Pending__c);
                targetVolume = targetVolume + ((b.NSDByBrandItem.ASI_KOR_Target_Volume__c == null)?0:b.NSDByBrandItem.ASI_KOR_Target_Volume__c);
                propTotalIncentive = propTotalIncentive + ((b.NSDByBrandItem.ASI_KOR_Total_Incentive_Amount_Proposal__c== null)?0:b.NSDByBrandItem.ASI_KOR_Total_Incentive_Amount_Proposal__c);
                propTotalPendingIncentive = propTotalPendingIncentive + ((b.NSDByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c== null)?0:b.NSDByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c);
                propTotalCA = propTotalCA + ((b.NSDByBrandItem.ASI_KOR_Total_CA_Amount_excl_Basic__c== null)?0:b.NSDByBrandItem.ASI_KOR_Total_CA_Amount_excl_Basic__c);
                branchBudget = branchBudget + ((b.NSDByBrandItem.ASI_KOR_CA_Budget__c== null)?0:b.NSDByBrandItem.ASI_KOR_CA_Budget__c);
                last3MonthAveVolume = last3MonthAveVolume +((b.NSDByBrandItem.ASI_KOR_Last_3_month_Actual_Average_Volu__c== null)?0:b.NSDByBrandItem.ASI_KOR_Last_3_month_Actual_Average_Volu__c);
				/* [VL 1.0] BEGIN */
				ASI_KOR_Total_Incentive_Amount_Proposal += b.NSDByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Total_Incentive_Amount_Pending__c;
				ASI_KOR_Target_Volume                   += b.NSDByBrandItem.ASI_KOR_Target_Volume_Pending__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Target_Volume_Pending__c;
				ASI_KOR_Total_VI_1M_Ago                 += b.NSDByBrandItem.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Total_VI_1_Month_Ago__c;
				ASI_KOR_Actual_Volume_1M_Ago            += b.NSDByBrandItem.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Actual_Volume_1_Month_Ago__c;
				ASI_KOR_Total_VI_2M_Ago                 += b.NSDByBrandItem.ASI_KOR_Total_VI_2_Months_Ago__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Total_VI_2_Months_Ago__c;
				ASI_KOR_Actual_Volume_2M_Ago            += b.NSDByBrandItem.ASI_KOR_Actual_Volume_2_Months_Ago__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Actual_Volume_2_Months_Ago__c;
				ASI_KOR_Budget_Target_VI                += b.NSDByBrandItem.ASI_KOR_Budget_Target_VI__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Budget_Target_VI__c;
				ASI_KOR_Budget_Target_Volume            += b.NSDByBrandItem.ASI_KOR_Budget_Target_Volume__c == null ? 0 : b.NSDByBrandItem.ASI_KOR_Budget_Target_Volume__c;
				/* [VL 1.0] END */
            }
        }
        public String getStatus(){
            if(propTotalCA>branchBudget){
                return 'Exceed Budget';
            }else
                return 'Within Budget';
        }
		
		/* [VL 1.0] BEGIN */
        public Decimal ASI_KOR_Total_Incentive_Amount_Proposal {get; set; }
        public Decimal ASI_KOR_Target_Volume {get; set; }
        public Decimal ASI_KOR_Total_VI_1M_Ago {get; set; }
        public Decimal ASI_KOR_Actual_Volume_1M_Ago {get; set; }
        public Decimal ASI_KOR_Total_VI_2M_Ago {get; set; }
        public Decimal ASI_KOR_Actual_Volume_2M_Ago {get; set; }
        public Decimal ASI_KOR_Budget_Target_VI {get; set; }
        public Decimal ASI_KOR_Budget_Target_Volume {get; set; }
		public Decimal getUnitCost_thisMonth(){
			return this.ASI_KOR_Total_Incentive_Amount_Proposal/(this.ASI_KOR_Target_Volume == 0 ? 1 : this.ASI_KOR_Target_Volume);
		}
		public Decimal getUnitCost_1MonthAgo(){
			return this.ASI_KOR_Total_VI_1M_Ago/(this.ASI_KOR_Actual_Volume_1M_Ago == 0 ? 1 : this.ASI_KOR_Actual_Volume_1M_Ago);
		}
		public Decimal getUnitCost_2MonthAgo(){
			return this.ASI_KOR_Total_VI_2M_Ago/(this.ASI_KOR_Actual_Volume_2M_Ago == 0 ? 1 : this.ASI_KOR_Actual_Volume_2M_Ago);
		}
		public Decimal getUnitCost_budget(){
			return this.ASI_KOR_Budget_Target_VI/(this.ASI_KOR_Budget_Target_Volume == 0 ? 1 : this.ASI_KOR_Budget_Target_Volume);
		}
		public string getBudgetStatus(){
			return getUnitCost_thisMonth() > getUnitCost_budget() ? 'Exceed Target' : 'Within Target';
		}
		/* [VL 1.0] END */
    }
    public void quickSave(){
        if(rsdByRegionCategoryList != null && rsdByRegionCategoryList.size()>0){
            List<ASI_KOR_RSD_Proposal_Header__c > toUpdate = new List<ASI_KOR_RSD_Proposal_Header__c >();
            
            Set<Id> rsdHeaders = new Set<Id>();
            for(RSDByBranchCategory b : rsdByRegionCategoryList){
                rsdHeaders.add(b.rsdHeader.id);
            }
            
            Map<Id,ASI_KOR_RSD_Proposal_Header__c > rsdHeadersMap = new Map<Id,ASI_KOR_RSD_Proposal_Header__c>([
                select id,ASI_KOR_Status__c,ASI_KOR_Total_CA_Amount_excl_Basic__c,ASI_KOR_Total_Incentive_Amount_Proposal__c
                from ASI_KOR_RSD_Proposal_Header__c where id in: rsdHeaders ]);
            
            for(RSDByBranchCategory b : rsdByRegionCategoryList){
                toUpdate.add(b.rsdHeader);
                if(b.rsdHeader.ASI_KOR_Status__c == 'Rejected'){
                    
                    if(rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Status__c == 'Approved by NSD'){
                        ASI_KOR_RSDApprovalController.rollUp(b.rsdHeader.id,false);
                        //   nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c = nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c;
                        //   nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c -=rsdHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
                        
						/* [VL 1.0] BEGIN */
						ASI_KOR_RSDApprovalController.rollUpCAPending(b.rsdHeader.id,false);
						/* [VL 1.0] END */
                        
                    }else {
                        ASI_KOR_RSDApprovalController.rollUpCAPending(b.rsdHeader.id,false);
						/* [VL 1.0] BEGIN */
						nsdHeader.ASI_KOR_Total_VI_Pending__c -=  rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
						/* [VL 1.0] END */
                    }
                    nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c = nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c == null ? 0 : (nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c - 1);
                        
                }
                if(b.rsdHeader.ASI_KOR_Status__c == 'Approved by NSD' && rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Status__c != 'Approved by NSD'){
                    ASI_KOR_RSDApprovalController.rollUp(b.rsdHeader.id,true);
                    ASI_KOR_RSDApprovalController.rollUpCAPending(b.rsdHeader.id,false);
					/* [VL 1.0] BEGIN */
					nsdHeader.ASI_KOR_Total_VI_Pending__c = nsdHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : nsdHeader.ASI_KOR_Total_VI_Pending__c  - (rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c);
					/* [VL 1.0] END */
                }
            }
            
            try{
                update toUpdate;
                update nsdHeader;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                
            }
        }
    }
    public PageReference handleSave(){
        
        if(rsdByRegionCategoryList != null && rsdByRegionCategoryList.size()>0){
            List<ASI_KOR_RSD_Proposal_Header__c > toUpdate = new List<ASI_KOR_RSD_Proposal_Header__c >();
            
            Set<Id> rsdHeaders = new Set<Id>();
            for(RSDByBranchCategory b : rsdByRegionCategoryList){
                rsdHeaders.add(b.rsdHeader.id);
            }
            
            Map<Id,ASI_KOR_RSD_Proposal_Header__c > rsdHeadersMap = new Map<Id,ASI_KOR_RSD_Proposal_Header__c>([
                select id,ASI_KOR_Status__c,ASI_KOR_Total_CA_Amount_excl_Basic__c,ASI_KOR_Total_Incentive_Amount_Proposal__c
                from ASI_KOR_RSD_Proposal_Header__c where id in: rsdHeaders ]);
            
            for(RSDByBranchCategory b : rsdByRegionCategoryList){
                toUpdate.add(b.rsdHeader);
                if(b.rsdHeader.ASI_KOR_Status__c == 'Rejected'){
                    
                    if(rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Status__c == 'Approved by NSD'){
                        ASI_KOR_RSDApprovalController.rollUp(b.rsdHeader.id,false);
                        //   nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c = nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c;
                        //   nsdHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c -=rsdHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
						
						/* [VL 1.0] BEGIN */
						ASI_KOR_RSDApprovalController.rollUpCAPending(b.rsdHeader.id,false);
						/* [VL 1.0] END */
                        
                    }else {
                        ASI_KOR_RSDApprovalController.rollUpCAPending(b.rsdHeader.id,false);
						/* [VL 1.0] BEGIN */
						nsdHeader.ASI_KOR_Total_VI_Pending__c -=  rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
						/* [VL 1.0] END */
                    }
                    nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c = nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c == null ? 0 : (nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c - 1);
                }
                if(b.rsdHeader.ASI_KOR_Status__c == 'Approved by NSD' && rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Status__c != 'Approved by NSD'){
                    ASI_KOR_RSDApprovalController.rollUp(b.rsdHeader.id,true);
					/* [VL 1.0] BEGIN */
					/*
                    ASI_KOR_RSDApprovalController.rollUpCAPending(b.rsdHeader.id,false);
					*/
                    ASI_KOR_RSDApprovalController.rollUpCAPending(b.rsdHeader.id,false,true);
					nsdHeader.ASI_KOR_Total_VI_Pending__c = nsdHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : nsdHeader.ASI_KOR_Total_VI_Pending__c  - (rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : rsdHeadersMap.get(b.rsdHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c);
					/* [VL 1.0] END */
                }
            }
            
            try{
                update toUpdate;
                update nsdHeader;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            }
            PageReference pageRef   = new PageReference('/apex/ASI_KOR_NSDApproval?id=' + nsdHeader.id);
            pageRef.setRedirect(true);
            System.debug( ' about to redirect to: ' +ApexPages.currentPage().getParameters().get('retUrl'));
            
            return pageRef;
        }
        
        return null;
    }
    
    public PageReference handleSubmit(){
        
        quickSave();
        
        system.debug('aaa approve button clicked!');
        ASI_KOR_NSD_Proposal_Header__c d = new ASI_KOR_NSD_Proposal_Header__c();
        d.id = nsdHeader.id;
        d.ASI_KOR_Status__c = 'Approved';
        
        try{
            update d;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_NSDApproval?id=' + nsdHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
	
	/* [VL 2.0] BEGIN */
	public string getExceptionalReport_unitCost(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Sales_Planning_Report_UC' limit 1];
		return report.id;
	}
	public string getYear(){
		return nsdHeader.ASI_KOR_Year__c;
	}
	public string getMonth(){
		return nsdHeader.ASI_KOR_Month__c;
	}
	/* [VL 2.0] BEGIN */
    
    /*
public static Boolean manualShare(Id headerId, Id userId){
ASI_KOR_NSD_Proposal_Header__share nHeader = new ASI_KOR_NSD_Proposal_Header__share();
nHeader.ParentId = headerId;
nHeader.UserOrGroupId  = userId;
nHeader.AccessLevel = 'Edit';
nHeader.RowCause = Schema.ASI_KOR_NSD_Proposal_Header__Share.RowCause.Manual;
Database.SaveResult sr = Database.insert(nHeader,false);

// Process the save results.
if(sr.isSuccess()){
// Indicates success
system.debug('xxs success');
return true;
}
else {
// Get first save result error.
Database.Error err = sr.getErrors()[0];

// Check if the error is related to trival access level.
// Access levels equal or more permissive than the object's default 
// access level are not allowed. 
// These sharing records are not required and thus an insert exception is acceptable. 
if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
err.getMessage().contains('AccessLevel')){
// Indicates success.
system.debug('yyy fail' +  err.getMessage());
return true;
}
else{
// Indicates failure.
system.debug('zzz fail' +  err.getMessage());
return false;
}
}

}

public static Boolean manualShare2(Id headerId, Id userId){
ASI_KOR_RSD_Proposal_Header__share nHeader = new ASI_KOR_RSD_Proposal_Header__share();
nHeader.ParentId = headerId;
nHeader.UserOrGroupId  = userId;
nHeader.AccessLevel = 'Edit';
nHeader.RowCause = Schema.ASI_KOR_RSD_Proposal_Header__share.RowCause.Manual;
Database.SaveResult sr = Database.insert(nHeader,false);

// Process the save results.
if(sr.isSuccess()){
// Indicates success
system.debug('xxs success');
return true;
}
else {
// Get first save result error.
Database.Error err = sr.getErrors()[0];

// Check if the error is related to trival access level.
// Access levels equal or more permissive than the object's default 
// access level are not allowed. 
// These sharing records are not required and thus an insert exception is acceptable. 
if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
err.getMessage().contains('AccessLevel')){
// Indicates success.
system.debug('yyy fail' +  err.getMessage());
return true;
}
else{
// Indicates failure.
system.debug('zzz fail' +  err.getMessage());
return false;
}
}

}
*/
}