/**********************************************************************************
* Name : ASI_KOR_RSDApprovalController 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??										Created
* 2017-05-05		Laputa: Vincent			[VL 1.0] P4.2 logic
* 2017-08-07		Laputa: Vincent			[VL 2.0] Add RM approval
* 2017-08-09		Laputa: Vincent			[VL 3.0] P4.2 report
* 2017-09-08		Laputa: Vincent			[VL 4.0] check BM status before submit
**********************************************************************************/
public class ASI_KOR_RSDApprovalController{
    
    public ASI_KOR_RSD_Proposal_Header__c rsdProposalHeader {get;set;}
    public List<BMByBranchCategory> bmByBranchCategoryList {get; set;}
    public Decimal propUnitCost{get;set;}
    public Decimal propUnitCostCA{get;set;}
    public Decimal last3MonthAveVolume{get;set;}
    public Decimal last3MonthAveUnitCost{get;set;}
    public Decimal growth{get;set;}
    public Decimal targetVolume{get;set;}
    public Decimal propTotalIncentive{get;set;}
    public Decimal propPendingCAAmount{get;set;}
    public Decimal propTotalPendingIncentive{get;set;}
    public Decimal propTotalCA{get;set;}
    public Decimal branchBudget{get;set;}
    public Boolean renderSubmit {get;set;}
    public Boolean renderRecall {get;set;}
    public String status{get;set;}
	
	public Boolean renderSave {get;set;}
    
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
	
    public ASI_KOR_RSDApprovalController(ApexPages.StandardController standardController){
        renderSubmit = false;
        renderRecall = false;
		renderSave = false;
        Id headerId = ((ASI_KOR_RSD_Proposal_Header__c)standardController.getRecord()).id;
        rsdProposalHeader = [select id, ownerid,
								ASI_KOR_Status__c,
								ASI_KOR_CA_Amount_Pending__c,
								ASI_KOR_No_of_Sumitted_Branches__c,
								ASI_KOR_NSD_Proposal_Header__c,
								ASI_KOR_Region_Total_CA_Budget__c ,
								ASI_KOR_Total_CA_Amount_excl_Basic__c,
								ASI_KOR_Regional_Sales_Director_Comments__c,
								ASI_KOR_Total_Incentive_Amount_Proposal__c, 
								name,
								ASI_KOR_Month__c,
								ASI_KOR_Year__c 
							   /* [VL 1.0] BEGIN */
							   , ASI_KOR_Total_VI_Pending__c
							   /* [VL 1.0] END */
								from ASI_KOR_RSD_Proposal_Header__c 
								where id =: headerId];
        
		/* [VL 1.0] BEGIN */
		srYear = rsdProposalHeader.ASI_KOR_Year__c;
		srMonth = rsdProposalHeader.ASI_KOR_Month__c;
		/* [VL 1.0] END */
        
        if(rsdProposalHeader.ASI_KOR_Status__c == 'Draft' || rsdProposalHeader.ASI_KOR_Status__c == 'Rejected'){
            renderSubmit = true;
			renderSave = true;
        } else 
		if(rsdProposalHeader.ASI_KOR_Status__c == 'Submitted'){
            renderRecall = true;
        }
        
        rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c = rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c;
        rsdProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c = rsdProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : rsdProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c;
        rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c = rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c==null?0:rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c;
        
        Map<Id,ASI_KOR_BM_Proposal_Header__c> bmProposalHeaderMap = new Map<Id,ASI_KOR_BM_Proposal_Header__c>([
            select id, ASI_KOR_Approval_Comments__c ,
            ASI_KOR_Branch_Manager_Comments__c,ASI_KOR_Branch_Total_CA_Budget__c,
            ASI_KOR_Branch_Total_Status__c,ASI_KOR_Total_CA_Amount_excl_Basic__c,
            ASI_KOR_Total_Incentive_Amount_Proposal__c,ownerId,ASI_KOR_Status__c
            from ASI_KOR_BM_Proposal_Header__c where ASI_KOR_RSD_Proposal_Header__c =:headerId
            and (ASI_KOR_Status__c = 'Submitted' or ASI_KOR_Status__c = 'Approved by RSD'
				/* [VL 2.0] BEGIN */
				 or ASI_KOR_Status__c = 'Approved by TMKT'
				/* [VL 2.0] END */
			)
        ]);
        
        if(bmProposalHeaderMap.size()>0){
            populateDetails(bmProposalHeaderMap);
        }
        
        populateSummary();
        populateRegionalTotal();
    }
    
    private void populateDetails(Map<Id,ASI_KOR_BM_Proposal_Header__c> bmProposalHeaderMap){
        Set<Id> usersId = new Set<Id>();
        
        for(Id i: bmProposalHeaderMap.keySet()){ 
            usersId.add(bmProposalHeaderMap.get(i).ownerId);
        }
        Map<Id, User> userMap = new Map<Id, User> ([select id,ASI_KOR_User_Branch_Name__c,ASI_KOR_User_Branch_Code__c from User where id in:usersId]);
        
        Map<Id, String> branchMap = new Map<Id,String>();
        
        for(Id id : bmProposalHeaderMap.keySet()){
            Id oId = bmProposalHeaderMap.get(id).ownerId;
            String branchName = userMap.get(oId).ASI_KOR_User_Branch_Name__c;
            branchMap.put(id,branchName);
        }
        
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
        
        Map<Id,ASI_KOR_RSD_Proposal_By_Brand__c> rsdProposalByBrandMap = new Map<Id,ASI_KOR_RSD_Proposal_By_Brand__c>([select id, name from ASI_KOR_RSD_Proposal_By_Brand__c where 
                                                                                                                       ASI_KOR_RSD_Proposal_Header__c =: rsdProposalHeader.id]);
        
        List<ASI_KOR_BM_Proposal_By_Brand__c> bmProposalByBrands = [select id, name,
                                                                    ASI_KOR_BM_Proposal_Header__c,
                                                                    ASI_KOR_Brand__r.name,
                                                                    ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name,
                                                                    ASI_KOR_CA_Budget__c,
                                                                    ASI_KOR_CA_Budget_Status__c,
                                                                    ASI_KOR_Category__c,
                                                                    ASI_KOR_Last_3_month_Actual_Average_Volu__c,
                                                                    ASI_KOR_Last_3_month_Actual_average_UC__c,
                                                                    ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
                                                                    ASI_KOR_Proposal_Unit_Cost_CA_Only__c,
                                                                    ASI_KOR_RSD_Proposal_By_Brand__c,
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
                                                                    ASI_KOR_BM_Proposal_By_Brand__c
                                                                    where (ASI_KOR_RSD_Proposal_By_Brand__c in:rsdProposalByBrandMap.keySet() 
																	and ASI_KOR_BM_Proposal_Header__c in:bmProposalHeaderMap.keySet())
																	/* [VL 1.0] BEGIN */
																	/*
                                                                    order by ASI_KOR_BM_Proposal_Header__c,ASI_KOR_Brand__r.name
																	*/
                                                                    order by ASI_KOR_BM_Proposal_Header__c, ASI_KOR_CA_Budget_Status__c, ASI_KOR_Total_Incentive_Amount_Proposal__c desc, ASI_KOR_Brand__r.name
																	/* [VL 1.0] END */  ];
        
        
        Map<Id,List<ASI_KOR_BM_Proposal_By_Brand__c>> tempMap = new Map<Id,List<ASI_KOR_BM_Proposal_By_Brand__c>>();
        
        for(ASI_KOR_BM_Proposal_By_Brand__c bm: bmProposalByBrands){
            String branch =  branchMap.get(bm.ASI_KOR_BM_Proposal_Header__c);
            if(tempMap.get(bm.ASI_KOR_BM_Proposal_Header__c) == null){
                tempMap.put(bm.ASI_KOR_BM_Proposal_Header__c, new List<ASI_KOR_BM_Proposal_By_Brand__c>());
                tempMap.get(bm.ASI_KOR_BM_Proposal_Header__c).add(bm);
            }else{
                tempMap.get(bm.ASI_KOR_BM_Proposal_Header__c).add(bm);
            }
			/* [VL 1.0] BEGIN */
			GrandTotal_volume += bm.ASI_KOR_Target_Volume__c == null ? 0 : bm.ASI_KOR_Target_Volume__c;
			GrandTotal_VI += bm.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bm.ASI_KOR_Total_Incentive_Amount_Proposal__c;
			GrandTotal_volume_lastMonth += bm.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : bm.ASI_KOR_Actual_Volume_1_Month_Ago__c;
			GrandTotal_VI_lastMonth += bm.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : bm.ASI_KOR_Total_VI_1_Month_Ago__c;
			GrandTotal_budget_volume += bm.ASI_KOR_Budget_Target_Volume__c == null ? 0 : bm.ASI_KOR_Budget_Target_Volume__c;
			GrandTotal_budget_vi += bm.ASI_KOR_Budget_Target_VI__c == null ? 0 : bm.ASI_KOR_Budget_Target_VI__c;
			/* [VL 1.0] END */
        }
			/* [VL 1.0] BEGIN */
			GrandTotal_UC = GrandTotal_VI / (GrandTotal_volume == 0 ? 1 : GrandTotal_volume);
			GrandTotal_UC_lastMonth = GrandTotal_VI_lastMonth / (GrandTotal_volume_lastMonth == 0 ? 1 : GrandTotal_volume_lastMonth);
			GrandTotal_UC_budget = GrandTotal_budget_vi / (GrandTotal_budget_volume == 0 ? 1 : GrandTotal_budget_volume);
			/* [VL 1.0] END */
        
        bmByBranchCategoryList = new List<BMByBranchCategory>();
        for(String bmHeaderId: tempMap.keySet()){
            BMByBranchCategory b = new BMByBranchCategory();
            b.bmProposalByBrands = tempMap.get(bmHeaderId);
            Id oId = bmProposalHeaderMap.get(bmHeaderId).ownerId; 
            b.branchCode=  userMap.get(oId).ASI_KOR_User_Branch_Code__c;
            b.branchName = userMap.get(oId).ASI_KOR_User_Branch_Name__c;
            b.bmHeader =  bmProposalHeaderMap.get(bmHeaderId);
            bmByBranchCategoryList.add(b);
        }
        system.debug('XX RSD :' + bmByBranchCategoryList.size());
		
		/* [VL 1.0] BEGIN */
		bmByBranchCategoryList.sort();
		/* [VL 1.0] END */
    }
    private void populateRegionalTotal(){
        propUnitCost = 0;
        propUnitCostCA = 0;
        last3MonthAveVolume = 0;
        last3MonthAveUnitCost = 0;
        propPendingCAAmount = 0;
        growth = 0;
        targetVolume = 0;
        propTotalIncentive = 0;
        propTotalPendingIncentive= 0;
        propTotalCA = 0;
        branchBudget = 0;
        status ='';
        
        for(RSDByBrandByCategory x:rsdByBrandByCategoryList){
            propUnitCost += x.propUnitCost ;
            propUnitCostCA += x.propUnitCostCA;
            last3MonthAveVolume += x.last3MonthAveVolume;
            // last3MonthAveUnitCost += x.
            targetVolume += x.targetVolume;
            propTotalIncentive += x.propTotalIncentive;
            propTotalPendingIncentive += x.propTotalPendingIncentive;
            propTotalCA += x.propTotalCA;
            branchBudget += x.branchBudget;
            propPendingCAAmount += x.propPendingCAAmount;
        }
        
        growth = (last3MonthAveVolume == 0)?0:(targetVolume/last3MonthAveVolume);
            status = propTotalCA > branchBudget?'Exceed Budget' : 'Within Budget';
    }
    public List<RSDByBrandByCategory> rsdByBrandByCategoryList {get;set;}
    
    public void populateSummary(){
        rsdByBrandByCategoryList = new  List<RSDByBrandByCategory>();
        
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
		
        List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdProposalByBrandsTemp = [select id,ASI_KOR_Category__c, name, 
                                                                          ASI_KOR_Brand__r.name,
                                                                          ASI_KOR_Proposal_Unit_Cost_Basic_CA__c,
                                                                          ASI_KOR_Growth__c,
                                                                          ASI_KOR_CA_Budget__c,
                                                                          ASI_KOR_Last_3_month_Actual_Average_Volu__c,
                                                                          ASI_KOR_CA_Amount_Pending__c,
                                                                          ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                          ASI_KOR_Total_Incentive_Amount_Proposal__c,
                                                                          ASI_KOR_Proposal_Unit_Cost_CA_Only__c,
                                                                          ASI_KOR_Target_Volume__c ,
                                                                          ASI_KOR_CA_Budget_Status__c ,
                                                                          ASI_KOR_Total_Incentive_Amount_Pending__c,
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
                                                                          from ASI_KOR_RSD_Proposal_By_Brand__c where 
                                                                          ASI_KOR_RSD_Proposal_Header__c =: rsdProposalHeader.id];
        
        List<RSDByBrandByUnitCostCap> rsdProposalByBrands =  new List<RSDByBrandByUnitCostCap>();
        Set<ID> brandIDSet = new Set<ID>();
        //Set<String> branchSet = new Set<String>();
        
        List<ASI_KOR_Budget__c> budgetList = new List<ASI_KOR_Budget__c>();
        Map<String, ASI_KOR_Budget__c> budgetMap = new Map<String, ASI_KOR_Budget__c>();
        
        for(ASI_KOR_RSD_Proposal_By_Brand__c rsdPerBrand : rsdProposalByBrandsTemp) {
            if(rsdPerBrand.ASI_KOR_Brand__c != null) {
                brandIDSet.add(rsdPerBrand.ASI_KOR_Brand__c);
            }
        }
        
        if(brandIDSet.size() > 0) {
            
            budgetList = [SELECT ID, Name, ASI_KOR_Brand__c, ASI_KOR_Unit_Cost_Cap__c, ASI_KOR_Month__c, ASI_KOR_Year__c,  ASI_KOR_Branch_Name__c
                          FROM ASI_KOR_Budget__c
                          WHERE ASI_KOR_Brand__c IN : brandIDSet 
                          AND ASI_KOR_Month__c = : rsdProposalHeader.ASI_KOR_Month__c 
                          AND ASI_KOR_Year__c = : rsdProposalHeader.ASI_KOR_Year__c 
                          /*AND ASI_KOR_Branch_Name__c IN : branchSet*/ ];
            
            if(budgetList.size() > 0) {
                for(ASI_KOR_Budget__c budget : budgetList) {
                    budgetMap.put((String)budget.ASI_KOR_Brand__c , budget);
                }
            }
        }
        
        for(ASI_KOR_RSD_Proposal_By_Brand__c rsdPerBrand : rsdProposalByBrandsTemp) {
            RSDByBrandByUnitCostCap RSDByUnitCap = new RSDByBrandByUnitCostCap();
            RSDByUnitCap.srProposalByBrandsItem = rsdPerBrand;
            
            //String branch =  branchMap.get(bm.ASI_KOR_BM_Proposal_Header__c);
            
            if(budgetMap.containsKey(rsdPerBrand.ASI_KOR_Brand__c)) {
                RSDByUnitCap.unitCostCap = budgetMap.get(rsdPerBrand.ASI_KOR_Brand__c).ASI_KOR_Unit_Cost_Cap__c;
            }
            rsdProposalByBrands.add(RSDByUnitCap);
        }
        
        Map<String, List<RSDByBrandByUnitCostCap>> regionalCategoryMap = new Map<String, List<RSDByBrandByUnitCostCap>>();
        
        for(RSDByBrandByUnitCostCap rsd: rsdProposalByBrands ){
            if(regionalCategoryMap.get(rsd.srProposalByBrandsItem.ASI_KOR_Category__c) == null){
                List<RSDByBrandByUnitCostCap> l = new List<RSDByBrandByUnitCostCap>();
                l.add(rsd);
                regionalCategoryMap.put(rsd.srProposalByBrandsItem.ASI_KOR_Category__c,l);
            }else{ 
                regionalCategoryMap.get(rsd.srProposalByBrandsItem.ASI_KOR_Category__c).add(rsd);
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
		for(String category:  regionalCategoryMap.keySet()){
		/* [VL 1.0] END */
			if(regionalCategoryMap.get(category) == null)
				continue;
			RSDByBrandByCategory b = new RSDByBrandByCategory(regionalCategoryMap.get(category));
			b.category = category;
			// b.rsdProposalByBrands = regionalCategoryMap.get(category);
			rsdByBrandByCategoryList.add(b);
			
			/* [VL 1.0] BEGIN */
			for (RSDByBrandByUnitCostCap bmByBrandWrap : b.rsdProposalByBrands){
					ASI_KOR_RSD_Proposal_By_Brand__c bmByBrand = bmByBrandWrap.srProposalByBrandsItem;
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
    
    public class BMByBranchCategory /* [VL 1.0] BEGIN */ implements Comparable /* [VL 1.0] END */{
        public ASI_KOR_BM_Proposal_Header__c bmHeader {get;set;}
        public String branchName {get;set;}
        public String branchCode {get;set;}
        public List<ASI_KOR_BM_Proposal_By_Brand__c> bmProposalByBrands {get;set;}
        
        public Decimal getTargetVolume(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c b: bmProposalByBrands ){
                temp = temp + ((b.ASI_KOR_Target_Volume__c == null)?0:b.ASI_KOR_Target_Volume__c);
            }
            return temp;
        }
		/* [VL 1.0] BEGIN */
        public Decimal getTotalVI(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c detail : bmProposalByBrands){
				temp += detail.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : detail.ASI_KOR_Total_Incentive_Amount_Proposal__c;
            }
            return temp;
        } 
        public Decimal getTotalTargetVolume(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c detail : bmProposalByBrands){
                temp += detail.ASI_KOR_Target_Volume__c == null ? 0 : detail.ASI_KOR_Target_Volume__c;
            }
            return temp;
        } 
        public Decimal getTotalUC(){
            return getTotalVI()/ (getTotalTargetVolume() == 0 ? 1 : getTotalTargetVolume());
        } 
        public Decimal getTotalVI_lastMonth(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c detail : bmProposalByBrands){
                temp += detail.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Total_VI_1_Month_Ago__c;
            }
            return temp;
        } 
        public Decimal getTotalActualVolume_lastMonth(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c detail : bmProposalByBrands){
                temp += detail.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : detail.ASI_KOR_Actual_Volume_1_Month_Ago__c;
            }
            return temp;
        } 
        public Decimal getTotalUC_lastMonth(){
            return getTotalVI_lastMonth()/ (getTotalActualVolume_lastMonth() == 0 ? 1 : getTotalActualVolume_lastMonth());
        } 
        public Decimal getTotalBudget(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c detail : bmProposalByBrands){
                temp += detail.ASI_KOR_CA_Budget__c == null ? 0 : detail.ASI_KOR_CA_Budget__c;
            }
            return temp;
        } 
        public Decimal getTotalBudgetVI(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c detail : bmProposalByBrands){
                temp += detail.ASI_KOR_Budget_Target_VI__c == null ? 0 : detail.ASI_KOR_Budget_Target_VI__c;
            }
            return temp;
        } 
        public Decimal getTotalBudgetVolume(){
            Decimal temp = 0;
            for(ASI_KOR_BM_Proposal_By_Brand__c detail : bmProposalByBrands){
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
			BMByBranchCategory compareToWrap = (BMByBranchCategory)compareTo;
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
    public class RSDByBrandByUnitCostCap{
        public Decimal unitCostCap {get; set; }
        public ASI_KOR_RSD_Proposal_By_Brand__c srProposalByBrandsItem {get; set; }
        public String getUnitCostStatus(){
            Decimal x = this.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c;
            Decimal z = this.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c;
            if(z>x)
                return 'Exceed Budget'; 
            else
                return 'Within Budget';
        }
		/* [VL 1.0] BEGIN */
		public boolean getDisplay(){
			if (
				this.srProposalByBrandsItem.ASI_KOR_Total_Incentive_Amount_Pending__c == 0 &&
				this.srProposalByBrandsItem.ASI_KOR_Target_Volume_Pending__c == 0 &&
				this.srProposalByBrandsItem.ASI_KOR_Total_VI_1_Month_Ago__c == 0 &&
				this.srProposalByBrandsItem.ASI_KOR_Actual_Volume_1_Month_Ago__c == 0 &&
				this.srProposalByBrandsItem.ASI_KOR_Total_VI_2_Months_Ago__c == 0 &&
				this.srProposalByBrandsItem.ASI_KOR_Actual_Volume_2_Months_Ago__c == 0
			){
				return false;
			} else {
				return true;
			}
		}
		/* [VL 1.0] END */
    }
    
    public class RSDByBrandByCategory{ 
        public Decimal last3MonthAveVolume {get;set;}
        public Decimal propUnitCost{get;set;}
        public Decimal  propUnitCostCA {get;set;}
        public Decimal targetVolume{get;set;}
        public Decimal propTotalIncentive{get;set;}
        public Decimal propPendingCAAmount{get;set;}
        public Decimal propTotalPendingIncentive{get;set;}
        public Decimal propTotalCA{get;set;}
        public Decimal branchBudget{get;set;}
        public String category{get;set;}
        public List<RSDByBrandByUnitCostCap> rsdProposalByBrands {get; set;}
        public RSDByBrandByCategory(List<RSDByBrandByUnitCostCap> a){
            rsdProposalByBrands = a;
            propUnitCost = 0;
            propUnitCostCA = 0;
            targetVolume = 0;
            propTotalIncentive = 0;
            propPendingCAAmount=0;
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
            for(RSDByBrandByUnitCostCap b: rsdProposalByBrands){
                propUnitCost = propUnitCost + ((b.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c== null)?0:b.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_Basic_CA__c);
                propUnitCostCA = propUnitCostCA + ((b.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c == null)?0:b.srProposalByBrandsItem.ASI_KOR_Proposal_Unit_Cost_CA_Only__c);
                targetVolume = targetVolume + ((b.srProposalByBrandsItem.ASI_KOR_Target_Volume__c == null)?0:b.srProposalByBrandsItem.ASI_KOR_Target_Volume__c);
                propTotalIncentive = propTotalIncentive + ((b.srProposalByBrandsItem.ASI_KOR_Total_Incentive_Amount_Proposal__c== null)?0:b.srProposalByBrandsItem.ASI_KOR_Total_Incentive_Amount_Proposal__c);
                propTotalPendingIncentive = propTotalPendingIncentive + ((b.srProposalByBrandsItem.ASI_KOR_Total_Incentive_Amount_Pending__c== null)?0:b.srProposalByBrandsItem.ASI_KOR_Total_Incentive_Amount_Pending__c);
                propPendingCAAmount = propPendingCAAmount  + ((b.srProposalByBrandsItem.ASI_KOR_CA_Amount_Pending__c== null)?0:b.srProposalByBrandsItem.ASI_KOR_CA_Amount_Pending__c);
                propTotalCA = propTotalCA + ((b.srProposalByBrandsItem.ASI_KOR_Total_CA_Amount_excl_Basic__c== null)?0:b.srProposalByBrandsItem.ASI_KOR_Total_CA_Amount_excl_Basic__c);
                branchBudget = branchBudget + ((b.srProposalByBrandsItem.ASI_KOR_CA_Budget__c== null)?0:b.srProposalByBrandsItem.ASI_KOR_CA_Budget__c);
                last3MonthAveVolume = last3MonthAveVolume +((b.srProposalByBrandsItem.ASI_KOR_Last_3_month_Actual_Average_Volu__c== null)?0:b.srProposalByBrandsItem.ASI_KOR_Last_3_month_Actual_Average_Volu__c);
				/* [VL 1.0] BEGIN */
				ASI_KOR_Total_Incentive_Amount_Proposal += b.srProposalByBrandsItem.ASI_KOR_Total_Incentive_Amount_Pending__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Total_Incentive_Amount_Pending__c;
				ASI_KOR_Target_Volume                   += b.srProposalByBrandsItem.ASI_KOR_Target_Volume_Pending__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Target_Volume_Pending__c;
				ASI_KOR_Total_VI_1M_Ago                 += b.srProposalByBrandsItem.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Total_VI_1_Month_Ago__c;
				ASI_KOR_Actual_Volume_1M_Ago            += b.srProposalByBrandsItem.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Actual_Volume_1_Month_Ago__c;
				ASI_KOR_Total_VI_2M_Ago                 += b.srProposalByBrandsItem.ASI_KOR_Total_VI_2_Months_Ago__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Total_VI_2_Months_Ago__c;
				ASI_KOR_Actual_Volume_2M_Ago            += b.srProposalByBrandsItem.ASI_KOR_Actual_Volume_2_Months_Ago__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Actual_Volume_2_Months_Ago__c;
				ASI_KOR_Budget_Target_VI                += b.srProposalByBrandsItem.ASI_KOR_Budget_Target_VI__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Budget_Target_VI__c;
				ASI_KOR_Budget_Target_Volume            += b.srProposalByBrandsItem.ASI_KOR_Budget_Target_Volume__c == null ? 0 : b.srProposalByBrandsItem.ASI_KOR_Budget_Target_Volume__c;
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
    
    public PageReference handleSave(){
        
        if(bmByBranchCategoryList != null && bmByBranchCategoryList.size()>0){
            List<ASI_KOR_BM_Proposal_Header__c > toUpdate = new List<ASI_KOR_BM_Proposal_Header__c >();
            Set<Id> bmHeaders = new Set<Id>();
            for(BMByBranchCategory b : bmByBranchCategoryList){
                bmHeaders.add(b.bmHeader.id);
            }
            
            Map<Id,ASI_KOR_BM_Proposal_Header__c > bmHeadersMap = new Map<Id,ASI_KOR_BM_Proposal_Header__c>([
                select id,
				ASI_KOR_Status__c,
				ASI_KOR_Total_CA_Amount_excl_Basic__c,
				ASI_KOR_Total_Incentive_Amount_Proposal__c,
                ASI_KOR_Branch_Total_CA_Budget__c 
				from ASI_KOR_BM_Proposal_Header__c 
				where id in:bmHeaders]);
            
            for(BMByBranchCategory b : bmByBranchCategoryList){
                
				/* [VL 2.0] BEGIN */
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by RSD' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by RSD'){
					b.bmHeader.ASI_KOR_Status__c = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'It must be Approved by TMKT first.'));
					return null;
				}
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c == 'Approved by RSD'){
					b.bmHeader.ASI_KOR_Status__c = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'It is already Approved by RSD.'));
					return null;
				}
				/* [VL 2.0] END */
				
				toUpdate.add(b.bmHeader);
                if(b.bmHeader.ASI_KOR_Status__c == 'Rejected'){
                    ASI_KOR_BMApprovalController.submitted(b.bmHeader.id, false);
                    //ASI_KOR_BMApprovalController.updateBranchTotalBudget(b.bmHeader);
                    if(bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c == 'Approved by RSD'){
                        rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c -=bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c;
                        rsdProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c -=bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0: bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
                        //--
                        //rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c = rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c==null?0:rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c;
                        //--
                        
                        Decimal branchBudget = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c;
                        
                        //--
                        //rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c -= branchBudget;
                        //--
                        ASI_KOR_BMApprovalController.rollUp(b.bmHeader.id,false);
                    }else{
                        rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c =  rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : (rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c - (b.bmHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c) ) ;
						/* [VL 1.0] BEGIN */
						rsdProposalHeader.ASI_KOR_Total_VI_Pending__c -=  bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
						/* [VL 1.0] END */
                            
                    }
                    rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c = rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c == null? 0 : ( rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c - 1);
                        
                }
                if(b.bmHeader.ASI_KOR_Status__c == 'Approved by RSD' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by RSD'){
                    //add rsd header
                    ASI_KOR_BMApprovalController.submitted(b.bmHeader.id, true);
                    rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c += bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0: bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c;
                    rsdProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c +=bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
                    //Decimal branchBudget = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c;
                    //rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c+= branchBudget;
                    ASI_KOR_BMApprovalController.rollUp(b.bmHeader.id,true);
                    rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c =  rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : (rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c - (b.bmHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c) ) ;
					/* [VL 1.0] BEGIN */
					rsdProposalHeader.ASI_KOR_Total_VI_Pending__c = rsdProposalHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : rsdProposalHeader.ASI_KOR_Total_VI_Pending__c  - (bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c);
					/* [VL 1.0] END */
                        
                }
            }
            
            try{
                update rsdProposalHeader;
                update toUpdate;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            }
            PageReference pageRef   = new PageReference('/apex/ASI_KOR_RSDApproval?id=' + rsdProposalHeader.id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    public void handleQuickSave(){
        
        if(bmByBranchCategoryList != null && bmByBranchCategoryList.size()>0){
            List<ASI_KOR_BM_Proposal_Header__c > toUpdate = new List<ASI_KOR_BM_Proposal_Header__c >();
            Set<Id> bmHeaders = new Set<Id>();
            for(BMByBranchCategory b : bmByBranchCategoryList){
                bmHeaders.add(b.bmHeader.id);
            }
            
            Map<Id,ASI_KOR_BM_Proposal_Header__c > bmHeadersMap = new Map<Id,ASI_KOR_BM_Proposal_Header__c>([
                select id,ASI_KOR_Status__c,ASI_KOR_Total_CA_Amount_excl_Basic__c,ASI_KOR_Total_Incentive_Amount_Proposal__c
                ,ASI_KOR_Branch_Total_CA_Budget__c from ASI_KOR_BM_Proposal_Header__c where id in:bmHeaders]);
            
            for(BMByBranchCategory b : bmByBranchCategoryList){
                			
				toUpdate.add(b.bmHeader);
                if(b.bmHeader.ASI_KOR_Status__c == 'Rejected'){
                    
                    //ASI_KOR_BMApprovalController.updateBranchTotalBudget(b.bmHeader);
                    if(bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c == 'Approved by RSD'){
                        rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c -=bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c;
                        rsdProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c -=bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0: bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
                        //--
                        //rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c = rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c==null?0:rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c;
                        
                        //Decimal branchBudget = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c;
                        //rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c -= branchBudget;
                        //--
                        ASI_KOR_BMApprovalController.rollUp(b.bmHeader.id,false);
                        rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c = rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c == null? 0 : ( rsdProposalHeader.ASI_KOR_No_of_Sumitted_Branches__c - 1);
                    }else{
                        rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c =  rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : (rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c - (rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c) ) ;
                        /* [VL 1.0] BEGIN */
						rsdProposalHeader.ASI_KOR_Total_VI_Pending__c -=  bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
						/* [VL 1.0] END */ 
                    }
                }
                if(b.bmHeader.ASI_KOR_Status__c == 'Approved by RSD' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by RSD'){
                    //add rsd header
                    rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c += bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0: bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_CA_Amount_excl_Basic__c;
                    rsdProposalHeader.ASI_KOR_Total_Incentive_Amount_Proposal__c +=bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c;
                    //--
                    //Decimal branchBudget = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Branch_Total_CA_Budget__c;
                    //rsdProposalHeader.ASI_KOR_Region_Total_CA_Budget__c+= branchBudget;
                    //--
                    
                    ASI_KOR_BMApprovalController.rollUp(b.bmHeader.id,true);
                    rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c =  rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c == null ? 0 : (rsdProposalHeader.ASI_KOR_CA_Amount_Pending__c - (rsdProposalHeader.ASI_KOR_Total_CA_Amount_excl_Basic__c) ) ;
                    /* [VL 1.0] BEGIN */
					rsdProposalHeader.ASI_KOR_Total_VI_Pending__c = rsdProposalHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : rsdProposalHeader.ASI_KOR_Total_VI_Pending__c  - (bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Incentive_Amount_Proposal__c);
					/* [VL 1.0] END */
                }
            }
            
            try{
                update rsdProposalHeader;
                update toUpdate;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                
            }
        }
        
    }
    
    public PageReference handleSubmit(){
				/* [VL 2.0] BEGIN */
		if(bmByBranchCategoryList != null && bmByBranchCategoryList.size()>0){
            Set<Id> bmHeaders = new Set<Id>();
            for(BMByBranchCategory b : bmByBranchCategoryList){
                bmHeaders.add(b.bmHeader.id);
            }
            
            Map<Id,ASI_KOR_BM_Proposal_Header__c > bmHeadersMap = new Map<Id,ASI_KOR_BM_Proposal_Header__c>([
                select id,ASI_KOR_Status__c from ASI_KOR_BM_Proposal_Header__c where id in:bmHeaders]);
            
            for(BMByBranchCategory b : bmByBranchCategoryList){
                					
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by RSD' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by RSD'){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'It must be Approved by TMKT first.'));
					return null;
				}
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c == 'Approved by RSD'){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'It is already Approved by RSD.'));
					return null;
				}
			}
		}
				/* [VL 2.0] END */
				
        handleQuickSave();
        /*
ASI_KOR_NSD_Proposal_Header__c nsdHeader = [select ASI_KOR_No_of_Sumitted_Regions__c,ASI_KOR_CA_Amount_Pending__c 
from ASI_KOR_NSD_Proposal_Header__c
where id=:rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c];
nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c = nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c == null ? 1 : (nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c + 1);
*/
		/* [VL 4.0] BEGIN */
		if (getSubmittedBM()>0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please approve or reject all BM Sales Planning before submit.'));
			return null;    
		}
		/* [VL 4.0] END */
		
		/* [VL 1.0] BEGIN */
		ASI_KOR_NSD_Proposal_Header__c nsdHeader = [
			select id, ASI_KOR_Total_VI_Pending__c 
			from ASI_KOR_NSD_Proposal_Header__c
			where id =:rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c
			limit 1
		];
		decimal nsdTotalPendingVI = nsdHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : nsdHeader.ASI_KOR_Total_VI_Pending__c;
		nsdHeader.ASI_KOR_Total_VI_Pending__c = nsdTotalPendingVI + (GrandTotal_VI == null ? 0 : GrandTotal_VI);
		/* [VL 1.0] END */
		
        rsdProposalHeader.ASI_KOR_Status__c = 'Submitted';
        rollUpCAPending(rsdProposalHeader.id,true);
        try{
            //update nsdHeader;
			/* [VL 1.0] BEGIN */
			update nsdHeader;
			/* [VL 1.0] END */
            update rsdProposalHeader;
            //rollUp(rsdProposalHeader.id);
			
			/* [VL 1.0] BEGIN */
			database.executeBatch(new ASI_KOR_CalPrevMonthsValueByBrand_NSD(),20);
			/* [VL 1.0] END */

        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_RSDApproval?id=' + rsdProposalHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public PageReference handleRecall(){
        /*
ASI_KOR_NSD_Proposal_Header__c nsdHeader = [select ASI_KOR_No_of_Sumitted_Regions__c,ASI_KOR_CA_Amount_Pending__c 
from ASI_KOR_NSD_Proposal_Header__c
where id=:rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c];
nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c = nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c == null ? 0 : (nsdHeader.ASI_KOR_No_of_Sumitted_Regions__c - 1);
*/
		/* [VL 1.0] BEGIN */
		ASI_KOR_NSD_Proposal_Header__c nsdHeader = [
			select id, ASI_KOR_Total_VI_Pending__c 
			from ASI_KOR_NSD_Proposal_Header__c
			where id =:rsdProposalHeader.ASI_KOR_NSD_Proposal_Header__c
			limit 1
		];
		decimal nsdTotalPendingVI = nsdHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : nsdHeader.ASI_KOR_Total_VI_Pending__c;
		nsdHeader.ASI_KOR_Total_VI_Pending__c = nsdTotalPendingVI - (GrandTotal_VI == null ? 0 : GrandTotal_VI);
		/* [VL 1.0] END */
		
        rsdProposalHeader.ASI_KOR_Status__c = 'Draft';
        rollUpCAPending(rsdProposalHeader.id,false);
        try{
            //update nsdHeader;
			/* [VL 1.0] BEGIN */
			update nsdHeader;
			/* [VL 1.0] END */
            update rsdProposalHeader;
            //rollDown(rsdProposalHeader.id);
			
			/* [VL 1.0] BEGIN */
			database.executeBatch(new ASI_KOR_CalPrevMonthsValueByBrand_NSD(),20);
			/* [VL 1.0] END */
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_RSDApproval?id=' + rsdProposalHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public static void rollUp(Id headerId, Boolean flag){
        List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdProposalByBrandList = [select id, 
                                                                         ASI_KOR_Target_Volume__c,
                                                                         ASI_KOR_CA_Budget__c,
                                                                         ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                         ASI_KOR_Total_Incentive_Amount_Proposal__c,
                                                                         ASI_KOR_NSD_Proposal_By_Brand__c, 
																		 ASI_KOR_Roll_up__c,
                                                                         ASI_KOR_Last_3_month_Actual_average_Volu__c  
																		 from ASI_KOR_RSD_Proposal_By_Brand__c 
																		 where ASI_KOR_RSD_Proposal_Header__c = :headerId];
        List<ASI_KOR_NSD_Proposal_By_Brand__c> nsdProposalByBrandList = new List<ASI_KOR_NSD_Proposal_By_Brand__c>();
        
        Set<Id> propIds = new Set<Id>();
        for(ASI_KOR_RSD_Proposal_By_Brand__c s : rsdProposalByBrandList ){
            propIds.add(s.ASI_KOR_NSD_Proposal_By_Brand__c);
        }
        
        Map<Id,ASI_KOR_NSD_Proposal_By_Brand__c> nsdProposalByBrandMap = new Map<Id,ASI_KOR_NSD_Proposal_By_Brand__c>(
            [select id,
				ASI_KOR_Target_Volume__c,
				ASI_KOR_CA_Budget__c,
				ASI_KOR_Total_CA_Amount_excl_Basic__c,
				ASI_KOR_Total_Incentive_Amount_Proposal__c,
				ASI_KOR_Last_3_month_Actual_average_Volu__c  
			 from ASI_KOR_NSD_Proposal_By_Brand__c 
			 where id in:propIds ]);
        
        for(ASI_KOR_RSD_Proposal_By_Brand__c s : rsdProposalByBrandList ){
            ASI_KOR_NSD_Proposal_By_Brand__c nsdBrand = nsdProposalByBrandMap.get(s.ASI_KOR_NSD_Proposal_By_Brand__c);
            nsdBrand.ASI_KOR_Target_Volume__c = nsdBrand.ASI_KOR_Target_Volume__c == null ? 0 : nsdBrand.ASI_KOR_Target_Volume__c;
            nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c = nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c;
            nsdBrand.ASI_KOR_Total_Incentive_Amount_Proposal__c = nsdBrand.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : nsdBrand.ASI_KOR_Total_Incentive_Amount_Proposal__c;
            nsdBrand.ASI_KOR_CA_Budget__c= nsdBrand.ASI_KOR_CA_Budget__c== null ? 0 : nsdBrand.ASI_KOR_CA_Budget__c;
            nsdBrand.ASI_KOR_Last_3_month_Actual_average_Volu__c = nsdBrand.ASI_KOR_Last_3_month_Actual_average_Volu__c == null ? 0 : nsdBrand.ASI_KOR_Last_3_month_Actual_average_Volu__c;
			 
            if(!s.ASI_KOR_Roll_up__c && flag){
                s.ASI_KOR_Roll_up__c = flag;
                nsdBrand.ASI_KOR_Target_Volume__c += (s.ASI_KOR_Target_Volume__c == null ? 0 : s.ASI_KOR_Target_Volume__c); 
                nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c += (s.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : s.ASI_KOR_Total_CA_Amount_excl_Basic__c ); 
                nsdBrand.ASI_KOR_Total_Incentive_Amount_Proposal__c += (s.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : s.ASI_KOR_Total_Incentive_Amount_Proposal__c ); 
                
                //--
                //nsdBrand.ASI_KOR_CA_Budget__c += (s.ASI_KOR_CA_Budget__c== null ? 0 : s.ASI_KOR_CA_Budget__c); 
                //--
                
                nsdBrand.ASI_KOR_Last_3_month_Actual_average_Volu__c += (s.ASI_KOR_Last_3_month_Actual_average_Volu__c == null ? 0 : s.ASI_KOR_Last_3_month_Actual_average_Volu__c);
                
            }else if(s.ASI_KOR_Roll_up__c && !flag){
                s.ASI_KOR_Roll_up__c = flag;
                nsdBrand.ASI_KOR_Target_Volume__c -= (s.ASI_KOR_Target_Volume__c == null ? 0 : s.ASI_KOR_Target_Volume__c); 
                nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c -= (s.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : s.ASI_KOR_Total_CA_Amount_excl_Basic__c ); 
                nsdBrand.ASI_KOR_Total_Incentive_Amount_Proposal__c -= (s.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : s.ASI_KOR_Total_Incentive_Amount_Proposal__c ); 
                
                //--
                //nsdBrand.ASI_KOR_CA_Budget__c -= (s.ASI_KOR_CA_Budget__c== null ? 0 : s.ASI_KOR_CA_Budget__c); 
                //--
                
                nsdBrand.ASI_KOR_Last_3_month_Actual_average_Volu__c -= (s.ASI_KOR_Last_3_month_Actual_average_Volu__c == null ? 0 : s.ASI_KOR_Last_3_month_Actual_average_Volu__c);
                
            }
            
            
            
        }
        
        for(Id pId :nsdProposalByBrandMap.keySet()){
            nsdProposalByBrandList.add(nsdProposalByBrandMap.get(pId));
        }
        try{
            update nsdProposalByBrandList;
            update rsdProposalByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    public static void rollUpCAPending(Id headerId, Boolean flag /* [VL 1.0] BEGIN */, Boolean approvedFlag/* [VL 1.0] BEGIN */){
        List<ASI_KOR_RSD_Proposal_By_Brand__c> rsdProposalByBrandList = [select id, 
                                                                         ASI_KOR_Total_CA_Amount_excl_Basic__c,
																		 ASI_KOR_Total_Incentive_Amount_Proposal__c,
                                                                         ASI_KOR_NSD_Proposal_By_Brand__c 
																		 /* [VL 1.0] BEGIN */
																		  , ASI_KOR_Actual_Volume_1_Month_Ago__c
																		  , ASI_KOR_Actual_Volume_2_Months_Ago__c
																		  , ASI_KOR_Total_VI_1_Month_Ago__c
																		  , ASI_KOR_Total_VI_2_Months_Ago__c
																		  , ASI_KOR_Target_Volume_Pending__c
																		 /* [VL 1.0] END */
																		 from ASI_KOR_RSD_Proposal_By_Brand__c 
																		 where ASI_KOR_RSD_Proposal_Header__c = :headerId];
        
        List<ASI_KOR_NSD_Proposal_By_Brand__c> nsdProposalByBrandList = new List<ASI_KOR_NSD_Proposal_By_Brand__c>();
        
        Set<Id> propIds = new Set<Id>();
        for(ASI_KOR_RSD_Proposal_By_Brand__c s : rsdProposalByBrandList ){
            propIds.add(s.ASI_KOR_NSD_Proposal_By_Brand__c);
        }
        
        Map<Id,ASI_KOR_NSD_Proposal_By_Brand__c> nsdProposalByBrandMap = new Map<Id,ASI_KOR_NSD_Proposal_By_Brand__c>(
            [select id,
				ASI_KOR_CA_Amount_Pending__c, 
				ASI_KOR_Total_Incentive_Amount_Pending__c
			 /* [VL 1.0] BEGIN */
			  , ASI_KOR_Actual_Volume_1_Month_Ago__c
			  , ASI_KOR_Actual_Volume_2_Months_Ago__c
			  , ASI_KOR_Total_VI_1_Month_Ago__c
			  , ASI_KOR_Total_VI_2_Months_Ago__c
			  , ASI_KOR_Target_Volume_Pending__c
			 /* [VL 1.0] END */
             from ASI_KOR_NSD_Proposal_By_Brand__c 
			 where id in:propIds ]);
        
        for(ASI_KOR_RSD_Proposal_By_Brand__c s : rsdProposalByBrandList ){
            ASI_KOR_NSD_Proposal_By_Brand__c nsdBrand = nsdProposalByBrandMap.get(s.ASI_KOR_NSD_Proposal_By_Brand__c);
            nsdBrand.ASI_KOR_CA_Amount_Pending__c = nsdBrand.ASI_KOR_CA_Amount_Pending__c == null ? 0 : nsdBrand.ASI_KOR_CA_Amount_Pending__c;
            nsdBrand.ASI_KOR_Total_Incentive_Amount_Pending__c = nsdBrand.ASI_KOR_Total_Incentive_Amount_Pending__c == null ? 0 : nsdBrand.ASI_KOR_Total_Incentive_Amount_Pending__c;
			/* [VL 1.0] BEGIN */
            nsdBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c = nsdBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : nsdBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c;
            nsdBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c = nsdBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c == null ? 0 : nsdBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c;
            nsdBrand.ASI_KOR_Total_VI_1_Month_Ago__c = nsdBrand.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : nsdBrand.ASI_KOR_Total_VI_1_Month_Ago__c;
            nsdBrand.ASI_KOR_Total_VI_2_Months_Ago__c = nsdBrand.ASI_KOR_Total_VI_2_Months_Ago__c == null ? 0 : nsdBrand.ASI_KOR_Total_VI_2_Months_Ago__c;
            nsdBrand.ASI_KOR_Target_Volume_Pending__c = nsdBrand.ASI_KOR_Target_Volume_Pending__c == null ? 0 : nsdBrand.ASI_KOR_Target_Volume_Pending__c;
			/* [VL 1.0] END */
            if(flag){ 
                nsdBrand.ASI_KOR_CA_Amount_Pending__c += (s.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : s.ASI_KOR_Total_CA_Amount_excl_Basic__c);
				/* [VL 1.0] BEGIN */ 
				/*
                nsdBrand.ASI_KOR_Total_Incentive_Amount_Pending__c += (s.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : s.ASI_KOR_Total_Incentive_Amount_Proposal__c); 
				*/
				if (!approvedFlag){ 
					nsdBrand.ASI_KOR_Target_Volume_Pending__c += (s.ASI_KOR_Target_Volume_Pending__c == null ? 0 : s.ASI_KOR_Target_Volume_Pending__c);  	
					nsdBrand.ASI_KOR_Total_Incentive_Amount_Pending__c += (s.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : s.ASI_KOR_Total_Incentive_Amount_Proposal__c); 
					//nsdBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c += (s.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : s.ASI_KOR_Actual_Volume_1_Month_Ago__c); 
					//nsdBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c += (s.ASI_KOR_Actual_Volume_2_Months_Ago__c == null ? 0 : s.ASI_KOR_Actual_Volume_2_Months_Ago__c); 
					//nsdBrand.ASI_KOR_Total_VI_1_Month_Ago__c += (s.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : s.ASI_KOR_Total_VI_1_Month_Ago__c); 
					//nsdBrand.ASI_KOR_Total_VI_2_Months_Ago__c += (s.ASI_KOR_Total_VI_2_Months_Ago__c == null ? 0 : s.ASI_KOR_Total_VI_2_Months_Ago__c); 
				}
				/* [VL 1.0] END */
                
            }else { 
                nsdBrand.ASI_KOR_CA_Amount_Pending__c -= (s.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : s.ASI_KOR_Total_CA_Amount_excl_Basic__c); 
				/* [VL 1.0] BEGIN */
				/*
                nsdBrand.ASI_KOR_Total_Incentive_Amount_Pending__c -= (s.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : s.ASI_KOR_Total_Incentive_Amount_Proposal__c); 
				*/
				if (!approvedFlag){
					nsdBrand.ASI_KOR_Target_Volume_Pending__c -= (s.ASI_KOR_Target_Volume_Pending__c == null ? 0 : s.ASI_KOR_Target_Volume_Pending__c); 
					nsdBrand.ASI_KOR_Total_Incentive_Amount_Pending__c -= (s.ASI_KOR_Total_Incentive_Amount_Proposal__c == null ? 0 : s.ASI_KOR_Total_Incentive_Amount_Proposal__c); 
					//nsdBrand.ASI_KOR_Actual_Volume_1_Month_Ago__c -= (s.ASI_KOR_Actual_Volume_1_Month_Ago__c == null ? 0 : s.ASI_KOR_Actual_Volume_1_Month_Ago__c); 
					//nsdBrand.ASI_KOR_Actual_Volume_2_Months_Ago__c -= (s.ASI_KOR_Actual_Volume_2_Months_Ago__c == null ? 0 : s.ASI_KOR_Actual_Volume_2_Months_Ago__c); 
					//nsdBrand.ASI_KOR_Total_VI_1_Month_Ago__c -= (s.ASI_KOR_Total_VI_1_Month_Ago__c == null ? 0 : s.ASI_KOR_Total_VI_1_Month_Ago__c); 
					//nsdBrand.ASI_KOR_Total_VI_2_Months_Ago__c -= (s.ASI_KOR_Total_VI_2_Months_Ago__c == null ? 0 : s.ASI_KOR_Total_VI_2_Months_Ago__c); 
				}
				/* [VL 1.0] END */
                
            }
            
            
            
        }
        
        for(Id pId :nsdProposalByBrandMap.keySet()){
            nsdProposalByBrandList.add(nsdProposalByBrandMap.get(pId));
        }
        try{
            update nsdProposalByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
	
	/* [VL 2.0] BEGIN */
	public boolean getIsRSD(){
		return rsdProposalHeader.ownerid == UserInfo.getUserId();
	}
	/* [VL 2.0] END */
	
    /* [VL 1.0] BEGIN */
    public static void rollUpCAPending(Id headerId, Boolean flag){
		rollUpCAPending(headerId, flag, false);
	}
	/* [VL 1.0] END */
	
	/* [VL 3.0] BEGIN */
	public string getExceptionalReport_unitCost(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Sales_Planning_Report_UC' limit 1];
		return report.id;
	}
	public string getYear(){
		return rsdProposalHeader.ASI_KOR_Year__c;
	}
	public string getMonth(){
		return rsdProposalHeader.ASI_KOR_Month__c;
	}
	/* [VL 3.0] BEGIN */
    
    /* [VL 4.0] BEGIN */
	private decimal getSubmittedBM(){
		list<ASI_KOR_BM_Proposal_Header__c> header = [select id,ASI_KOR_Status__c from ASI_KOR_BM_Proposal_Header__c where ASI_KOR_RSD_Proposal_Header__c =:rsdProposalHeader.id 
		and (ASI_KOR_Status__c = 'Submitted' or ASI_KOR_Status__c = 'Approved by TMKT')];
		return header.size();
	}
    /* [VL 4.0] END */
        
}