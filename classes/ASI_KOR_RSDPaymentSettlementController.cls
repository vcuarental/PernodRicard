/**********************************************************************************
* Name : ASI_KOR_RSDPaymentSettlementController 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??										Created
* 2017-02-17       Laputa: Vincent         [VL 1.0] add new column Total Basic, Prepayment and Final Total
* 2017-03-05		Laputa: Vincent			[VL 2.0] create new section (class) for CA brand grouping
* 2017-05-05		Laputa: Vincent			[VL 3.0] P4.2
* 2017-08-01		Laputa: Vincent			[VL 4.0] P4.2, retuns the report id
* 2017-08-11		Laputa: Vincent			[VL 5.0] P4.2, add RM approval
* 2017-09-08		Laputa: Vincent			[VL 6.0] check BM status before submit
**********************************************************************************/
global class ASI_KOR_RSDPaymentSettlementController { 
    public ASI_KOR_RSD_Payment_Settlement_Header__c rsdPaymentSettlementHeader {get;set;}
    public List<RSDByBranchCategory> rsdByBranchCategoryList {get; set;}
    public Decimal propUnitCost{get;set;}
    public Decimal targetVolume{get;set;}
    public Decimal propTotalIncentive{get;set;}
    public Decimal propTotalCA{get;set;}
    public Decimal propPendingTotalCA{get;set;}
    public Decimal totalFinalCAAmountexclBasic{get;set;}
    public Decimal totalPendingCAAmount{get;set;}
    /* [VL 1.0] BEGIN */
    public Decimal totalBasic{get;set;}
    public Decimal totalPrepayment{get;set;}
    public Decimal totalFinal{get;set;}
    /* [VL 1.0] END */
    /* [VL 3.0] BEGIN */
    public Decimal     totalNormalVolume {get;set;}
    public Decimal     totalPrepaymentVolume {get;set;}
    public Decimal     totalVolumeAll {get;set;}
    public Decimal     totalSettlementUC {get;set;}
    public Decimal     totalBudgetUC {get;set;}
    public Decimal     totalBudgetVI {get;set;}
    public string      totalBudgetStatus {get;set;}
    /* [VL 3.0] END */
    public Decimal branchBudget{get;set;}
    public Boolean renderSubmit {get;set;}
    public Boolean renderRecall {get;set;}
    public String status{get;set;}
    public Boolean renderSave {get;set;}
    
	/* [VL 3.0] BEGIN */
	public Decimal 	GrandTotal_volume {get;set;}
	public Decimal 	GrandTotal_volume_target {get;set;}
	public Decimal 	GrandTotal_VI {get;set;}
	public Decimal 	GrandTotal_VI_planned {get;set;}
	public Decimal 	GrandTotal_prepayment {get;set;}
	public Decimal 	GrandTotal_prepaymentVolume {get;set;}
	public Decimal 	GrandTotal_finaltotal {get;set;}
	public Decimal 	GrandTotal_incentive {get;set;}
	public Decimal 	GrandTotal_budget_volume {get;set;}
	public Decimal 	GrandTotal_budget_vi {get;set;}
	public String 	getGrandBudgetStatus(){
		return getGrandTotal_UC() > getGrandTotal_UC_budget() ? 'Exceed Target' : 'Within Target';
	}
	public Decimal 	getGrandTotal_UC(){
		return GrandTotal_VI / (GrandTotal_volume == 0 ? 1 : GrandTotal_volume);
	} 
	public Decimal 	getGrandTotal_UC_planned(){
		return GrandTotal_VI_planned / (GrandTotal_volume == 0 ? 1 : GrandTotal_volume);
	} 
	public Decimal 	getGrandTotal_UC_budget(){
		return GrandTotal_budget_vi / (GrandTotal_budget_volume == 0 ? 1 : GrandTotal_budget_volume);
	} 
	/* [VL 3.0] END */
	
    public ASI_KOR_RSDPaymentSettlementController (ApexPages.StandardController standardController){
        
		/* [VL 3.0] BEGIN */
		GrandTotal_volume = 0;
		GrandTotal_VI = 0;
		GrandTotal_prepayment = 0;
		GrandTotal_prepaymentVolume = 0;
		GrandTotal_finaltotal = 0;
		GrandTotal_incentive = 0;
		GrandTotal_VI_planned = 0;
		GrandTotal_volume_target = 0;
		GrandTotal_budget_volume = 0;
		GrandTotal_budget_vi = 0;
		/* [VL 3.0] END */
        
        renderSubmit = false;
        renderRecall = false;
		renderSave = false;
        
        Id headerId = ((ASI_KOR_RSD_Payment_Settlement_Header__c)standardController.getRecord()).id;
        
        rsdPaymentSettlementHeader = [select id, ownerid,
                                      ASI_KOR_Status__c,
                                      ASI_KOR_Final_CA_Amount_excl_Basic__c,
                                      ASI_KOR_Comments__c, 
                                      ASI_KOR_Approval_Comments__c, 
                                      ASI_KOR_Total_Branch_Budget__c,
                                      name,ASI_KOR_CA_Amount_excl_Basic__c,
                                      ASI_KOR_No_of_Sumitted_Branches__c,
                                      ASI_KOR_CA_Amount_Pending__c,
                                      ASI_KOR_NSD_Payment_Settlement__c,
                                      ASI_KOR_Month__c,
                                      ASI_KOR_Year__c     
                                      /* [VL 1.0] BEGIN */
                                      , ASI_KOR_Final_Basic_Amount__c
                                      , ASI_KOR_Pre_Payment_Amount__c
                                      , ASI_KOR_Final_Total_Amount__c
                                      /* [VL 1.0] END */
									 /* [VL 3.0] BEGIN */
									 , ASI_KOR_Total_VI_Pending__c
									 /* [VL 3.0] END */
                                      from ASI_KOR_RSD_Payment_Settlement_Header__c where id =: headerId];
        
        if(rsdPaymentSettlementHeader.ASI_KOR_Status__c == 'Draft' || rsdPaymentSettlementHeader.ASI_KOR_Status__c == 'Rejected'){
            renderSubmit = true;
			renderSave = true;
        }else if(rsdPaymentSettlementHeader.ASI_KOR_Status__c == 'Submitted'){
            renderRecall = true;
        }
        
        //rsdPaymentSettlementHeader.ASI_KOR_Total_Branch_Budget__c =  rsdPaymentSettlementHeader.ASI_KOR_Total_Branch_Budget__c == null ? 0 : rsdPaymentSettlementHeader.ASI_KOR_Total_Branch_Budget__c;
        rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c = rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c == null ? 0 : rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c;
        rsdPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c = rsdPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c == null ? 0 : rsdPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c;
        /* [VL 1.0] BEGIN */
        rsdPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c = rsdPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c == null ? 0 : rsdPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c;  
        rsdPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c = rsdPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : rsdPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c;  
        /* [VL 1.0] END */
        
        Map<Id,ASI_KOR_BM_Payment_Settlement_Header__c> bmPaymentSettlementHeaderMap = 
            new Map<Id,ASI_KOR_BM_Payment_Settlement_Header__c>([select id, 
                                                                 ASI_KOR_Approval_Comments__c ,
                                                                 ASI_KOR_Comments__c,ASI_KOR_CA_Amount_excl_Basic__c,
                                                                 ASI_KOR_Final_CA_Amount_excl_Basic__c, 
                                                                 ownerId, 
                                                                 ASI_KOR_Status__c,
                                                                 ASI_KOR_Total_Branch_Budget__c 
                                                                 /* [VL 1.0] BEGIN */
                                                                 , ASI_KOR_Final_Basic_Amount__c
                                                                 , ASI_KOR_Pre_Payment_Amount__c
                                                                 , ASI_KOR_Final_Total_Amount__c
                                                                 /* [VL 1.0] END */ 
                                                                 from ASI_KOR_BM_Payment_Settlement_Header__c where ASI_KOR_RSD_Payment_Settlement__c =:headerId
                                                                 and (ASI_KOR_Status__c  = 'Submitted' OR ASI_KOR_Status__c  = 'Approved by RSD'
																 /* [VL 5.0] BEGIN */
																  OR ASI_KOR_Status__c  = 'Approved by TMKT'
																 /* [VL 5.0] END */
																 )
                                                                ]);
        
        if(bmPaymentSettlementHeaderMap .size() > 0)
            populateDetails(bmPaymentSettlementHeaderMap);
        
        populateSummary();
        populateRegionalTotal();
    }
    
    private void populateDetails(Map<Id,ASI_KOR_BM_Payment_Settlement_Header__c> bmPaymentSettlementHeaderMap){
        Set<Id> usersId = new Set<Id>();
        
        for(Id i: bmPaymentSettlementHeaderMap.keySet()){ 
            usersId.add(bmPaymentSettlementHeaderMap.get(i).ownerId);
        }
        Map<Id, User> userMap = new Map<Id, User> ([select id,ASI_KOR_User_Branch_Name__c,ASI_KOR_User_Branch_Code__c from User where id in:usersId]);
        
        Map<Id, String> branchMap = new Map<Id,String>();
        
        for(Id id : bmPaymentSettlementHeaderMap.keySet()){
            Id oId = bmPaymentSettlementHeaderMap.get(id).ownerId;
            String branchName = userMap.get(oId).ASI_KOR_User_Branch_Name__c;
            branchMap.put(id,branchName);
        }
        
        Map<Id,ASI_KOR_RSD_Payment_Settlement_By_Brand__c> rsdPaymentSettlementByBrandMap = new Map<Id,ASI_KOR_RSD_Payment_Settlement_By_Brand__c>([select id, name
                                                                                                                                                    from ASI_KOR_RSD_Payment_Settlement_By_Brand__c where 
                                                                                                                                                    ASI_KOR_RSD_Payment_Settlement__c =: rsdPaymentSettlementHeader.id]);
        
        List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> bmSettlementByBrands = [select id, name,
                                                                                ASI_KOR_BM_Payment_Settlement__c,
                                                                                ASI_KOR_Brand__r.name,
                                                                                ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name,
                                                                                ASI_KOR_CA_Budget__c,
                                                                                ASI_KOR_CA_Budget_Status__c,
                                                                                ASI_KOR_Category__c,
                                                                                ASI_KOR_Approved_Basic_Unit_Cost__c,
                                                                                ASI_KOR_Actual_Unit_Cost_CA_Only__c,
                                                                                ASI_KOR_Actual_Volume__c,
                                                                                ASI_KOR_RSD_Payment_Settlement_By_Brand__c,
                                                                                ASI_KOR_Target_Volume__c,
                                                                                ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,
                                                                                ASI_KOR_Progression__c,
                                                                                ASI_KOR_Approved_Unit_Cost_Basic_CA__c ,
                                                                                ASI_KOR_Approved_Basic_Unit_Cost_Ave__c,
                                                                                ASI_KOR_Approved_CA_Unit_Cost_Ave__c,
                                                                                ASI_KOR_UOM__c
                                                                                /* [VL 1.0] BEGIN */
                                                                                , ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c
                                                                                , ASI_KOR_Total_Final_Basic__c
                                                                                , ASI_KOR_Pre_Payment_Amount__c
                                                                                , ASI_KOR_Final_Total_Amount__c
                                                                                /* [VL 1.0] END */
                                                                                /* [VL 2.0] BEGIN */
                                                                                , ASI_KOR_Brand__r.ASI_KOR_CA_Brand__r.name
                                                                                /* [VL 2.0] END */
																				/* [VL 3.0] BEGIN */
																				, ASI_KOR_Total_VI_Planned__c
																				, ASI_KOR_Budget_Status__c
																				, ASI_KOR_Budget_Target_VI__c
																				, ASI_KOR_Budget_Target_Volume__c
																				, ASI_KOR_Actual_Pre_payment_Volume__c
																				/* [VL 3.0] END */
                                                                                from
                                                                                ASI_KOR_BM_Payment_Settlement_By_Brand__c
                                                                                where ASI_KOR_RSD_Payment_Settlement_By_Brand__c in:rsdPaymentSettlementByBrandMap.keySet()
                                                                                and ASI_KOR_BM_Payment_Settlement__c in:bmPaymentSettlementHeaderMap.keySet()
																				/* [VL 3.0] BEGIN */
																				order by ASI_KOR_Budget_Status__c, ASI_KOR_Total_Final_Basic__c desc, ASI_KOR_Brand__r.name
																				/* [VL 3.0] END */];
        
        
        Map<Id,List<ASI_KOR_BM_Payment_Settlement_By_Brand__c>> tempMap = new Map<Id,List<ASI_KOR_BM_Payment_Settlement_By_Brand__c>>();
        
        for(ASI_KOR_BM_Payment_Settlement_By_Brand__c bm: bmSettlementByBrands){
            String branch =  branchMap.get(bm.ASI_KOR_BM_Payment_Settlement__c);
            if(tempMap.get(bm.ASI_KOR_BM_Payment_Settlement__c) == null){
                tempMap.put(bm.ASI_KOR_BM_Payment_Settlement__c, new List<ASI_KOR_BM_Payment_Settlement_By_Brand__c>());
                tempMap.get(bm.ASI_KOR_BM_Payment_Settlement__c).add(bm);
            }else{
                tempMap.get(bm.ASI_KOR_BM_Payment_Settlement__c).add(bm);
            }
			
			/* [VL 3.0] BEGIN */
			GrandTotal_volume += bm.ASI_KOR_Actual_Volume__c == null ? 0 : bm.ASI_KOR_Actual_Volume__c;
			GrandTotal_VI += bm.ASI_KOR_Total_Final_Basic__c == null ? 0 : bm.ASI_KOR_Total_Final_Basic__c;
			GrandTotal_prepayment += bm.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : bm.ASI_KOR_Pre_Payment_Amount__c;
			GrandTotal_finaltotal += bm.ASI_KOR_Final_Total_Amount__c == null ? 0 : bm.ASI_KOR_Final_Total_Amount__c;
			GrandTotal_VI_planned += bm.ASI_KOR_Total_VI_Planned__c == null ? 0 : bm.ASI_KOR_Total_VI_Planned__c;
			GrandTotal_volume_target += bm.ASI_KOR_Target_Volume__c == null ? 0 : bm.ASI_KOR_Target_Volume__c;
			GrandTotal_budget_volume += bm.ASI_KOR_Budget_Target_Volume__c == null ? 0 : bm.ASI_KOR_Budget_Target_Volume__c;
			GrandTotal_budget_vi += bm.ASI_KOR_Budget_Target_VI__c == null ? 0 : bm.ASI_KOR_Budget_Target_VI__c;
			GrandTotal_prepaymentVolume += bm.ASI_KOR_Actual_Pre_payment_Volume__c == null ? 0 : bm.ASI_KOR_Actual_Pre_payment_Volume__c;
			/* [VL 3.0] END */
        }
        rsdByBranchCategoryList = new List<RSDByBranchCategory>();
        for(String rsdHeaderId: tempMap.keySet()){
            /* [VL 2.0] BEGIN */
            /*
            RSDByBranchCategory b = new RSDByBranchCategory();
            b.bmSettlementByBrands = tempMap.get(rsdHeaderId);
            Id oId = bmPaymentSettlementHeaderMap.get(rsdHeaderId).ownerId; 
            b.branchCode=  userMap.get(oId).ASI_KOR_User_Branch_Code__c;
            b.branchName = userMap.get(oId).ASI_KOR_User_Branch_Name__c;
            b.bmHeader =  bmPaymentSettlementHeaderMap.get(rsdHeaderId);
            rsdByBranchCategoryList.add(b);
            */
            Id oId = bmPaymentSettlementHeaderMap.get(rsdHeaderId).ownerId;
            string branchCode=  userMap.get(oId).ASI_KOR_User_Branch_Code__c;
            string branchName = userMap.get(oId).ASI_KOR_User_Branch_Name__c;
            ASI_KOR_BM_Payment_Settlement_Header__c bmHeader = bmPaymentSettlementHeaderMap.get(rsdHeaderId);
            List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> bmSettlementByBrands1 = tempMap.get(rsdHeaderId); 
            RSDByBranchCategory b = new RSDByBranchCategory(branchCode, branchName, bmHeader, bmSettlementByBrands1);
            rsdByBranchCategoryList.add(b);
            /* [VL 2.0] END */
        }
        
		/* [VL 3.0] BEGIN */
		rsdByBranchCategoryList.sort();
		/* [VL 3.0] END */
    }
    private void populateRegionalTotal(){
        propUnitCost = 0;
        targetVolume = 0;
        propTotalIncentive = 0;
        propTotalCA = 0;
        branchBudget = 0;
        totalFinalCAAmountexclBasic = 0;
        status ='';
        totalPendingCAAmount =0;
        propPendingTotalCA = 0;
        /* [VL 1.0] BEGIN */
        totalBasic = 0;
        totalPrepayment = 0;
        totalFinal = 0;
        /* [VL 1.0] END */
        /* [VL 3.0] BEGIN */
        totalNormalVolume = 0;
        totalPrepaymentVolume = 0;
        totalVolumeAll = 0;
        totalSettlementUC = 0;
        totalBudgetUC = 0;
		decimal totalBudgetVITemp = 0;
		decimal totalBudgetVolumeTemp = 0;
        /* [VL 3.0] END */
        for(RSDByBrandByCategory x:rsdByBrandByCategoryList){
            propUnitCost += x.propUnitCost ;
            targetVolume += x.targetVolume;
            propTotalCA += x.propTotalCA;
            propPendingTotalCA += x.propPendingTotalCA;
            branchBudget += x.branchBudget;
            totalFinalCAAmountexclBasic += x.totalFinalCAAmountexclBasic;
            totalPendingCAAmount += x.TotalPendingCAAmount;
            /* [VL 1.0] BEGIN */
            totalBasic += x.totalBasic;
            totalPrepayment += x.totalPrepayment;
            totalFinal += x.totalFinal;
            /* [VL 1.0] END */
			/* [VL 3.0] BEGIN */
			totalNormalVolume += x.totalNormalVolume;
			totalPrepaymentVolume += x.totalPrepaymentVolume;
			totalVolumeAll += x.totalVolumeAll;
			totalBudgetVITemp += x.totalBudgetVI;
			totalBudgetVolumeTemp += x.totalBudgetVolume;
			/* [VL 3.0] END */
        }
			/* [VL 3.0] BEGIN */
			totalSettlementUC = totalBasic / (totalNormalVolume == 0 ? 1 : totalNormalVolume);
			/* [VL 3.0] END */
        
        status = propTotalCA > branchBudget?'Exceeded Budget' : 'Within Budget';
		/* [VL 3.0] BEGIN */
		totalBudgetUC = totalBudgetVITemp / (totalBudgetVolumeTemp == 0 ? 1 : totalBudgetVolumeTemp);
		totalBudgetStatus = totalSettlementUC > totalBudgetUC ? 'Exceed Target' : 'Within Target';
		/* [VL 3.0] END */
    }
    public List<RSDByBrandByCategory> rsdByBrandByCategoryList {get;set;}
    public void populateSummary(){
        rsdByBrandByCategoryList = new  List<RSDByBrandByCategory>();
        List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> rsdPaymentSettlementByBrands1 =  [select id,
                                                                                           ASI_KOR_Category__c, name, 
                                                                                           ASI_KOR_CA_Amount_Pending__c,
                                                                                           ASI_KOR_Total_CA_Amount_Pending__c,
                                                                                           ASI_KOR_Brand__r.name,
                                                                                           ASI_KOR_Approved_Basic_Unit_Cost__c,
                                                                                           ASI_KOR_Progression__c,
                                                                                           ASI_KOR_CA_Budget__c,
                                                                                           ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                           ASI_KOR_Approved_Unit_Cost_Basic_CA__c,
                                                                                           ASI_KOR_Target_Volume__c ,
                                                                                           ASI_KOR_CA_Budget_Status__c ,
                                                                                           ASI_KOR_Actual_Volume__c ,
                                                                                           ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,
                                                                                           ASI_KOR_UOM__c,
                                                                                           ASI_KOR_Approved_Basic_Unit_Cost_Ave__c,
                                                                                           ASI_KOR_Approved_CA_Unit_Cost_Ave__c,
                                                                                           ASI_KOR_Actual_Unit_Cost_CA_Only__c   
                                                                                           /* [VL 1.0] BEGIN */
                                                                                           , ASI_KOR_Total_Final_Basic__c
                                                                                           , ASI_KOR_Pre_Payment_Amount__c
                                                                                           , ASI_KOR_Final_Total_Amount__c
                                                                                           /* [VL 1.0] END */
																							/* [VL 3.0] BEGIN */
																							, ASI_KOR_Actual_Pre_payment_Volume__c
																							, ASI_KOR_Actual_Volume_Total__c
																							, ASI_KOR_Budget_Status__c
																							, ASI_KOR_Budget_Target_VI__c
																							, ASI_KOR_Budget_Target_Volume__c
																							/* [VL 3.0] END */
                                                                                           from ASI_KOR_RSD_Payment_Settlement_By_Brand__c where 
                                                                                           ASI_KOR_RSD_Payment_Settlement__c =: rsdPaymentSettlementHeader.id];
        
        List<RSDPaymentSettlementByBrand> rsdPaymentSettlementByBrands = new List<RSDPaymentSettlementByBrand>();
        
        for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c paymentSettlement : rsdPaymentSettlementByBrands1) {
            RSDPaymentSettlementByBrand paymentWrapper = new RSDPaymentSettlementByBrand();
            paymentWrapper.paymentSettlementByBrand = paymentSettlement;
            Decimal totalFinalCa = paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c != null ? paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c : 0;
            Decimal actVolume = paymentSettlement.ASI_KOR_Actual_Volume__c != null ? paymentSettlement.ASI_KOR_Actual_Volume__c : 0;
            paymentWrapper.settlementUnitCost = actVolume == 0 ? 0 : totalFinalCa/actVolume;
            rsdPaymentSettlementByBrands.add(paymentWrapper);
        }
        
        Map<String, List<RSDPaymentSettlementByBrand>> regionalCategoryMap = new Map<String, List<RSDPaymentSettlementByBrand>>();
        
        for(RSDPaymentSettlementByBrand rsd: rsdPaymentSettlementByBrands ){
            if(regionalCategoryMap.get(rsd.paymentSettlementByBrand.ASI_KOR_Category__c) == null){
                List<RSDPaymentSettlementByBrand> l = new List<RSDPaymentSettlementByBrand>();
                l.add(rsd);
                regionalCategoryMap.put(rsd.paymentSettlementByBrand.ASI_KOR_Category__c,l);
            }else{ 
                regionalCategoryMap.get(rsd.paymentSettlementByBrand.ASI_KOR_Category__c).add(rsd);
            }
        }
        
        String[] categories = new String[] {'Local Whisky','International Whisky','Modern Spirits','Competitor�s brands'};
            
			/* [VL 3.0] BEGIN */
			/*
			for(String category:  categories){
			*/
			for(String category:  regionalCategoryMap.keySet()){
			/* [VL 3.0] END */
                if(regionalCategoryMap.get(category) == null)
                    continue; 
                RSDByBrandByCategory b = new RSDByBrandByCategory(regionalCategoryMap.get(category));
                b.category = category;
                rsdByBrandByCategoryList.add(b);
            }
        
    }
    
    /* [VL 2.0] BEGIN */
    public class RSDPaymentSettlementByCABrand {
        public Decimal caAmountexclBasic {get;set;}
        public Decimal finalCAAmountexclBasic {get;set;}
        public Decimal finalBasic {get;set;}
        public Decimal finalPrepayment {get;set;}
        public Decimal finalTotal {get;set;}
        public Decimal actualVolume {get;set;}
        public String caBrand {get;set;}
        
        public List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> bmSettlementByBrands {get;set;}
        
        public RSDPaymentSettlementByCABrand(string caBrand, List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> bmSettlementByBrands){
            caAmountexclBasic = 0;
            finalCAAmountexclBasic  = 0;
            finalBasic = 0;
            finalPrepayment = 0;
            finalTotal = 0;
            actualVolume = 0;
            this.caBrand = caBrand;
            this.bmSettlementByBrands = bmSettlementByBrands ;
            if (bmSettlementByBrands.size() > 0)
            {
                for(ASI_KOR_BM_Payment_Settlement_By_Brand__c detail : bmSettlementByBrands ){
                    if(detail.ASI_KOR_Total_CA_Amount_excl_Basic__c!= null)
                    {
                        caAmountexclBasic += detail.ASI_KOR_Total_CA_Amount_excl_Basic__c;
                    }
                    if(detail.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c!= null)
                    {
                        finalCAAmountexclBasic  += detail.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c;     
                    }
                    if(detail.ASI_KOR_Total_Final_Basic__c!= null)
                    {
                        finalBasic  += detail.ASI_KOR_Total_Final_Basic__c;     
                    }
                    if(detail.ASI_KOR_Pre_Payment_Amount__c!= null)
                    {
                        finalPrepayment  += detail.ASI_KOR_Pre_Payment_Amount__c;     
                    }
                    if(detail.ASI_KOR_Final_Total_Amount__c!= null)
                    {
                        finalTotal  += detail.ASI_KOR_Final_Total_Amount__c;     
                    }
                    if(detail.ASI_KOR_Actual_Volume__c!= null)
                    {
                        actualVolume  += detail.ASI_KOR_Actual_Volume__c;     
                    }
                }    
            }
        }
    }
    /* [VL 2.0] END */
    
    public class RSDByBranchCategory /* [VL 3.0] BEGIN */ implements Comparable /* [VL 3.0] END */{
        public ASI_KOR_BM_Payment_Settlement_Header__c bmHeader {get;set;}
        public String branchName {get;set;}
        public String branchCode {get;set;}
        /* [VL 2.0] BEGIN */
        /*
        public List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> bmSettlementByBrands {get;set;}
        */
        public List<RSDPaymentSettlementByCABrand> rsdPaymentSettlementByCABrands {get;set;}
        /* [VL 2.0] END */
        
        public Decimal getTargetVolume(){
            Decimal temp = 0;
            /* [VL 2.0] BEGIN */
            /*
            for(ASI_KOR_BM_Payment_Settlement_By_Brand__c b: bmSettlementByBrands ){
                temp = temp + ((b.ASI_KOR_Target_Volume__c == null)?0:b.ASI_KOR_Target_Volume__c);
            }
            */
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + ((b.ASI_KOR_Target_Volume__c == null)?0:b.ASI_KOR_Target_Volume__c);
                }
            }
            /* [VL 2.0] END */
            return temp;
        }
        
        /* [VL 2.0] BEGIN */
        public RSDByBranchCategory(string branchCode, String branchName, ASI_KOR_BM_Payment_Settlement_Header__c bmHeader, List<ASI_KOR_BM_Payment_Settlement_By_Brand__c> bmSettlementByBrands){
            this.branchName = branchName;
            this.branchCode = branchCode;
            this.bmHeader = bmHeader;
            map<string, list<ASI_KOR_BM_Payment_Settlement_By_Brand__c>> map_caBrand_detail = new map<string, list<ASI_KOR_BM_Payment_Settlement_By_Brand__c>>();     
            for (ASI_KOR_BM_Payment_Settlement_By_Brand__c detail : bmSettlementByBrands){
                string caBrand = detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c != null ? detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__r.name : detail.ASI_KOR_Brand__r.name;
                if (map_caBrand_detail == null || !map_caBrand_detail.containsKey(caBrand)){
                    list<ASI_KOR_BM_Payment_Settlement_By_Brand__c> temp_list_detail = new list<ASI_KOR_BM_Payment_Settlement_By_Brand__c>();
                    temp_list_detail.add(detail);
                    map_caBrand_detail.put(caBrand, temp_list_detail);
                } else {
                    map_caBrand_detail.get(caBrand).add(detail);
                }
            }
            this.rsdPaymentSettlementByCABrands = new List<RSDPaymentSettlementByCABrand>();
			/* [VL 3.0] BEGIN */
			/*
            for (string caBrand : map_caBrand_detail.keySet()){
                RSDPaymentSettlementByCABrand detail_byCAbrand = new RSDPaymentSettlementByCABrand(
                    caBrand,
                    map_caBrand_detail.get(caBrand)
                );
                this.rsdPaymentSettlementByCABrands.add(detail_byCAbrand);
            }
			*/
			RSDPaymentSettlementByCABrand detail_byCAbrand = new RSDPaymentSettlementByCABrand(
				'noCA',
				bmSettlementByBrands
			);
			this.rsdPaymentSettlementByCABrands.add(detail_byCAbrand);
			/* [VL 3.0] END */
        }
        /* [VL 2.0] END */
		
		/* [VL 3.0] BEGIN */
        public Decimal getTargetVIPlanned(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Total_VI_Planned__c == null ? 0 : b.ASI_KOR_Total_VI_Planned__c);
                }
            }
            return temp;
        }
        public Decimal getActualVolume(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Actual_Volume__c == null ? 0 : b.ASI_KOR_Actual_Volume__c);
                }
            }
            return temp;
        }
        public Decimal getTotalVI(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Total_Final_Basic__c == null ? 0 : b.ASI_KOR_Total_Final_Basic__c);
                }
            }
            return temp;
        }
        public Decimal getTotalPrepayment(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : b.ASI_KOR_Pre_Payment_Amount__c);
                }
            }
            return temp;
        }
        public Decimal getTotalFinal(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Final_Total_Amount__c == null ? 0 : b.ASI_KOR_Final_Total_Amount__c);
                }
            }
            return temp;
        }
        public Decimal getTotalBudgetVolume(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Budget_Target_Volume__c == null ? 0 : b.ASI_KOR_Budget_Target_Volume__c);
                }
            }
            return temp;
        }
        public Decimal getTotalBudgetVI(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + ((b.ASI_KOR_Budget_Target_VI__c == null ? 0 : b.ASI_KOR_Budget_Target_VI__c) * (b.ASI_KOR_Budget_Target_Volume__c == null ? 0 : b.ASI_KOR_Budget_Target_Volume__c));
                }
            }
            return temp;
        }
        public Decimal getPrepaymentVolume(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_BM_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Actual_Pre_payment_Volume__c == null ? 0 : b.ASI_KOR_Actual_Pre_payment_Volume__c);
                }
            }
            return temp;
        }
		public Decimal getPlannedUC(){
			return getTargetVIPlanned() / (getActualVolume() == 0 ? 1 : getActualVolume());
		}
		public Decimal getSettlementUC(){
			return getTotalVI() / (getActualVolume() == 0 ? 1 : getActualVolume());
		}
		public Decimal getBudgetUC(){
			return getTotalBudgetVI() / (getTotalBudgetVolume() == 0 ? 1 : getTotalBudgetVolume());
		}
		public String getBudgetStatus(){
			return getSettlementUC() > getBudgetUC() ? 'Exceed Target' : 'Within Target';
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
		/* [VL 3.0] END */
        
    }
    
    // Added Wrapper Class for ASI_KOR_RSD_Payment_Settlement_By_Brand__c to cater formula field
    public class RSDPaymentSettlementByBrand {
        
        public ASI_KOR_RSD_Payment_Settlement_By_Brand__c paymentSettlementByBrand {get;set;}
        public decimal settlementUnitCost {get;set;}
        
		/* [VL 3.0] BEGIN */
		public boolean getDisplay(){
			if (
				this.paymentSettlementByBrand.ASI_KOR_Target_Volume__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c == 0 &&
				this.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c == 0
			){
				return false;
			} else {
				return true;
			}
		}
		/* [VL 3.0] END */
    } 
    
    public class RSDByBrandByCategory{ 
        public Decimal last3MonthAveVolume {get;set;}
        public Decimal propUnitCost{get;set;}
        public Decimal targetVolume{get;set;}
        public Decimal propTotalIncentive{get;set;}
        public Decimal propTotalCA{get;set;}
        public Decimal propPendingTotalCA{get;set;}
        public Decimal branchBudget{get;set;}
        public Decimal totalFinalCAAmountexclBasic{get;set;}
        public Decimal totalPendingCAAmount{get;set;}
        /* [VL 1.0] BEGIN */
        public Decimal totalBasic{get;set;}
        public Decimal totalPrepayment{get;set;}
        public Decimal totalFinal{get;set;}
        /* [VL 1.0] END */
        /* [VL 3.0] BEGIN */
        public Decimal totalNormalVolume{get;set;}
        public Decimal totalPrepaymentVolume{get;set;}
        public Decimal totalVolumeAll{get;set;}
        public Decimal totalBudgetVI{get;set;}
        public Decimal totalBudgetVolume{get;set;}
		public Decimal getActualUnitCost(){
            return totalBasic/(totalNormalVolume == 0 ? 1 : totalNormalVolume);
        } 
		public Decimal getBudgetUnitCost(){
            return totalBudgetVI/(totalBudgetVolume == 0 ? 1 : totalBudgetVolume);
        } 
		public String getBudgetStatus(){
            return getActualUnitCost() > getBudgetUnitCost() ? 'Exceed Target' : 'Within Target';
        } 
        /* [VL 3.0] END */
        public String category{get;set;}
        public List<RSDPaymentSettlementByBrand> rsdPaymentSettlementByBrands {get; set;}
        
        public RSDByBrandByCategory(List<RSDPaymentSettlementByBrand> a){
            
            rsdPaymentSettlementByBrands = a ;
            propUnitCost = 0;
            targetVolume = 0;
            propTotalIncentive = 0;
            propTotalCA = 0;
            propPendingTotalCA = 0;
            branchBudget = 0;
            last3MonthAveVolume = 0;
            totalFinalCAAmountexclBasic = 0;
            totalPendingCAAmount = 0;
            /* [VL 1.0] BEGIN */
            totalBasic = 0;
            totalPrepayment = 0;
            totalFinal = 0;
            /* [VL 1.0] END */
            /* [VL 3.0] BEGIN */
            totalNormalVolume = 0;
            totalPrepaymentVolume = 0;
            totalVolumeAll = 0;
			totalBudgetVI = 0;
			totalBudgetVolume = 0;
            /* [VL 3.0] END */
            for(RSDPaymentSettlementByBrand b: a){
                targetVolume +=((b.paymentSettlementByBrand.ASI_KOR_Target_Volume__c == null)?0:b.paymentSettlementByBrand.ASI_KOR_Target_Volume__c);
                propTotalCA +=((b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c);
                propPendingTotalCA +=((b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c);
                branchBudget += ((b.paymentSettlementByBrand.ASI_KOR_CA_Budget__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_CA_Budget__c);
                totalFinalCAAmountexclBasic += ((b.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c);
                totalPendingCAAmount +=  ((b.paymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c);  
                /* [VL 1.0] BEGIN */
                totalBasic += ((b.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c); 
                totalPrepayment += ((b.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c); 
                totalFinal += ((b.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c); 
                /* [VL 1.0] END */  
				/* [VL 3.0] BEGIN */
                totalNormalVolume += ((b.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c); 
                totalPrepaymentVolume += ((b.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c); 
                totalVolumeAll += ((b.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c); 
                totalBudgetVI += ((b.paymentSettlementByBrand.ASI_KOR_Budget_Target_VI__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Budget_Target_VI__c); 
                totalBudgetVolume += ((b.paymentSettlementByBrand.ASI_KOR_Budget_Target_Volume__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Budget_Target_Volume__c); 
                /* [VL 3.0] END */ 
            }      
        }
        public String getStatus(){
            if(propTotalCA>branchBudget){
                return 'Exceed Budget';
            }else
                return 'Within Budget';
        }
    }
    
    public void save()
    {
        if(rsdByBranchCategoryList != null && rsdByBranchCategoryList.size()>0){
            List<ASI_KOR_BM_Payment_Settlement_Header__c > toUpdate = new List<ASI_KOR_BM_Payment_Settlement_Header__c >();
            Set<Id> bmHeaders = new Set<Id>();
            
            for(RSDByBranchCategory b : rsdByBranchCategoryList){
                bmHeaders.add(b.bmHeader.id);
            }
            
            Map<Id,ASI_KOR_BM_Payment_Settlement_Header__c> bmHeadersMap = new Map<Id,ASI_KOR_BM_Payment_Settlement_Header__c>([
                select id,ASI_KOR_Status__c,ASI_KOR_Total_Branch_Budget__c,ASI_KOR_Final_CA_Amount_excl_Basic__c,ASI_KOR_CA_Amount_excl_Basic__c,
                ASI_KOR_No_of_Submitted_Sales_Rep__c    
                                      /* [VL 1.0] BEGIN */
                                      , ASI_KOR_Final_Basic_Amount__c
                                      , ASI_KOR_Pre_Payment_Amount__c
                                      , ASI_KOR_Final_Total_Amount__c
                                      /* [VL 1.0] END */      
                                      /* [VL 3.0] BEGIN */
                                      , ASI_KOR_Total_VI_Pending__c
                                      /* [VL 3.0] END */             
                from ASI_KOR_BM_Payment_Settlement_Header__c where id in:bmHeaders]);
            
            for(RSDByBranchCategory b : rsdByBranchCategoryList){
				
				/* [VL 5.0] BEGIN */
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by RSD' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by RSD'){
					b.bmHeader.ASI_KOR_Status__c = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'It must be Approved by TMKT first.'));
				}
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c == 'Approved by RSD'){
					b.bmHeader.ASI_KOR_Status__c = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c;
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'It is already Approved by RSD.'));
				}
				/* [VL 5.0] END */
				
                toUpdate.add(b.bmHeader);
                String selectedStatus = b.bmHeader.ASI_KOR_Status__c;
                String currentStatus = bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c;
                if(selectedStatus  == 'Rejected' ){
                    ASI_KOR_BMPaymentSettlementController.submitted(b.bmHeader.id,false);
                    ASI_KOR_BMPaymentSettlementController.rollUp(b.bmHeader.id,false);
                    if(currentStatus  == 'Approved by RSD'){
                        //rsdPaymentSettlementHeader.ASI_KOR_Total_Branch_Budget__c -=  bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Branch_Budget__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Branch_Budget__c;
                        rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c -= bmHeadersMap.get(b.bmHeader.id).ASI_KOR_CA_Amount_excl_Basic__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_CA_Amount_excl_Basic__c;
                        rsdPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c -= bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c;  
                        /* [VL 1.0] BEGIN */
                        rsdPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c -= bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c;  
                        rsdPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c -= bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Pre_Payment_Amount__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Pre_Payment_Amount__c;  
                        /* [VL 1.0] END */
                    } else 
                    {
                        Decimal caAmountPending = rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c== null?0:rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c;
                        rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c = caAmountPending - (bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c  == null ?  0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c);
						/* [VL 1.0] BEGIN */
                        rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c -= bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c;   
                        /* [VL 1.0] END */
                    }
                    Decimal noOfSubmittedBranches = rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c == null?0:rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c;
                    rsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Branches__c = noOfSubmittedBranches - 1;
                    
                    
                }
                if(selectedStatus  == 'Approved by RSD' && 
                   currentStatus  != 'Approved by RSD') {
                       //rsdPaymentSettlementHeader.ASI_KOR_Total_Branch_Budget__c +=  bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Branch_Budget__c  == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Total_Branch_Budget__c ;
                       rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_excl_Basic__c += bmHeadersMap.get(b.bmHeader.id).ASI_KOR_CA_Amount_excl_Basic__c  == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_CA_Amount_excl_Basic__c;
                       rsdPaymentSettlementHeader.ASI_KOR_Final_CA_Amount_excl_Basic__c += bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c  == null ?  0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c ;
                       Decimal caAmountPending = rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c== null?0:rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c;
                       rsdPaymentSettlementHeader.ASI_KOR_CA_Amount_Pending__c = caAmountPending - (bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c  == null ?  0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_CA_Amount_excl_Basic__c);
                       /* [VL 1.0] BEGIN */
                        rsdPaymentSettlementHeader.ASI_KOR_Final_Basic_Amount__c += bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c;  
                        rsdPaymentSettlementHeader.ASI_KOR_Pre_Payment_Amount__c += bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Pre_Payment_Amount__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Pre_Payment_Amount__c;  
                        /* [VL 1.0] END */
                       /* [VL 1.0] BEGIN */
                        rsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c -= bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c == null ? 0 : bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c;   
                        /* [VL 1.0] END */
                       ASI_KOR_BMPaymentSettlementController.rollUp(b.bmHeader.id,true);
                       ASI_KOR_BMPaymentSettlementController.submitted(b.bmHeader.id,true);
                   }
            }
            
            try{
                update rsdPaymentSettlementHeader;
                update toUpdate;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);         
            }
        }
    }
    
    public PageReference handleSave(){    
		string errorMessage = approvalErrorMessage();
		if (errorMessage!=''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
			return null;
		}
        save();    
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_RSDPaymentSettlement?id=' + rsdPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference handleSubmit(){ 
		string errorMessage = approvalErrorMessage();
		if (errorMessage!=''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
			return null;
		}
        save();
		
		
		/* [VL 6.0] BEGIN */
		if (getSubmittedBM()>0) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please approve or reject all BM Payment Settlement before submit.'));
			return null;    
		}
		/* [VL 6.0] END */
		
		
        ASI_KOR_NSD_Payment_Settlement_Header__c nsdPaymentSettlementHeader = [SELECT Id, 
																				ASI_KOR_No_of_Sumitted_Regions__c 
																				/* [VL 3.0] BEGIN */
																				, ASI_KOR_Total_VI_Pending__c
																				/* [VL 3.0] END */
																				from ASI_KOR_NSD_Payment_Settlement_Header__c
                                                                               WHERE id =:rsdPaymentSettlementHeader.ASI_KOR_NSD_Payment_Settlement__c];
        
        Decimal noOfSumittedRegions =  nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c == null?0:nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c;
        nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c =  noOfSumittedRegions + 1;
        /* [VL 3.0] BEGIN */
        nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = (nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c) + totalBasic;
		/* [VL 3.0] END */
        
        
        rsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Submitted';
        rollUpCAPending(rsdPaymentSettlementHeader.Id,true);
        try{
            update nsdPaymentSettlementHeader;
            update rsdPaymentSettlementHeader;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_RSDPaymentSettlement?id=' + rsdPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference handleRecall(){
        
        rsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
        ASI_KOR_NSD_Payment_Settlement_Header__c nsdPaymentSettlementHeader = [SELECT Id, 
																				ASI_KOR_No_of_Sumitted_Regions__c 
																				/* [VL 3.0] BEGIN */
																				, ASI_KOR_Total_VI_Pending__c
																				/* [VL 3.0] END */
																				from ASI_KOR_NSD_Payment_Settlement_Header__c
                                                                               WHERE id =:rsdPaymentSettlementHeader.ASI_KOR_NSD_Payment_Settlement__c];
        
        Decimal noOfSumittedRegions =  nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c == null?0:nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c;
        nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c =  noOfSumittedRegions - 1;
        
        /* [VL 3.0] BEGIN */
        nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : (nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c - totalBasic);
		/* [VL 3.0] END */
		
        rollUpCAPending(rsdPaymentSettlementHeader.Id,false);
        
        try{
            update rsdPaymentSettlementHeader;
            update nsdPaymentSettlementHeader;
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_RSDPaymentSettlement?id=' + rsdPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public static void rollUpCAPending(Id headerId, Boolean flag){
        List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> rsdPaymentSettlementByBrandList = [select id, 
                                                                                            ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                            ASI_KOR_NSD_Payment_Settlement_By_Brand__c from 
                                                                                            ASI_KOR_RSD_Payment_Settlement_By_Brand__c where ASI_KOR_RSD_Payment_Settlement__c = :headerId];
        
        List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c> nsdPaymentSettlementByBrandList = new List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c>();
        
        Set<Id> nsdPaymentSettlementByBrandIds = new Set<Id>();
        for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdPaymentSettlementByBrand : rsdPaymentSettlementByBrandList ){
            nsdPaymentSettlementByBrandIds.add(rsdPaymentSettlementByBrand.ASI_KOR_NSD_Payment_Settlement_By_Brand__c);
        }
        
        Map<Id,ASI_KOR_NSD_Payment_Settlement_By_Brand__c> nsdPaymentSettlementByBrandMap = new Map<Id,ASI_KOR_NSD_Payment_Settlement_By_Brand__c>(
            [select id, ASI_KOR_CA_Amount_Pending__c,ASI_KOR_Total_CA_Amount_Pending__c from ASI_KOR_NSD_Payment_Settlement_By_Brand__c where id in :nsdPaymentSettlementByBrandIds]);
        
        for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdPaymentSettlementByBrand : rsdPaymentSettlementByBrandList ){
            ASI_KOR_NSD_Payment_Settlement_By_Brand__c nsdPaymentSettlementByBrand = nsdPaymentSettlementByBrandMap.get(rsdPaymentSettlementByBrand.ASI_KOR_NSD_Payment_Settlement_By_Brand__c);
            nsdPaymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c = nsdPaymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c == null?0:nsdPaymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c;
            nsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c = nsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c == null?0:nsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c;      
            if(flag){ 
                nsdPaymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c += (rsdPaymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c== null?0:rsdPaymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c); 
                nsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c += (rsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c== null?0:rsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c);            
            }else { 
                nsdPaymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c -= (rsdPaymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c== null?0:rsdPaymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c);
                nsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c -= (rsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c== null?0:rsdPaymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c);                
            }
        }
        
        for(Id pId :nsdPaymentSettlementByBrandMap .keySet()){
            nsdPaymentSettlementByBrandList.add(nsdPaymentSettlementByBrandMap.get(pId));
        }
        
        try{
            update nsdPaymentSettlementByBrandList;    
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
    
    /*
Manually roll up all related by brand records to RSD Payment settlement header id.
Parameters: 
headerId - RSD Payment Settlement Header Id
rollUp - true to roll up, false to roll down.
*/
    public void rollUp(Id headerId, Boolean rollUp){
        
        List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> rsdPaymentSettlementByBrandList = [select id, 
                                                                                            ASI_KOR_Actual_Volume__c,
                                                                                            ASI_KOR_Approved_Basic_Unit_Cost__c,
                                                                                            ASI_KOR_Approved_CA_Unit_CA__c,
                                                                                            ASI_KOR_CA_Budget__c,
                                                                                            ASI_KOR_Target_Volume__c,
                                                                                            ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                            ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,
                                                                                            ASI_KOR_NSD_Payment_Settlement_By_Brand__c,
                                                                                            ASI_KOR_No_of_Submitted_Venues__c,
                                                                                            ASI_KOR_Roll_up__c
                                                                                            from 
                                                                                            ASI_KOR_RSD_Payment_Settlement_By_Brand__c where ASI_KOR_RSD_Payment_Settlement__c = :headerId];
        
        List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c> nsdPaymentSettlementByBrandList = new List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c>();
        
        Set<Id> propIds = new Set<Id>();
        
        for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c s : rsdPaymentSettlementByBrandList ){
            propIds.add(s.ASI_KOR_NSD_Payment_Settlement_By_Brand__c);
        }
        
        Map<Id,ASI_KOR_NSD_Payment_Settlement_By_Brand__c> nsdPaymentSByBrandMap = new Map<Id,ASI_KOR_NSD_Payment_Settlement_By_Brand__c>(
            [select id,
             ASI_KOR_Actual_Volume__c,
             ASI_KOR_Approved_Basic_Unit_Cost__c,
             ASI_KOR_Approved_CA_Unit_CA__c,
             ASI_KOR_CA_Budget__c,
             ASI_KOR_Target_Volume__c,
             ASI_KOR_Total_CA_Amount_excl_Basic__c,
             ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,
             ASI_KOR_No_of_Submitted_Venues__c     
             /* [VL 1.0] BEGIN */
             , ASI_KOR_Total_Final_Basic__c
             , ASI_KOR_Pre_Payment_Amount__c
             /* [VL 1.0] END */
             from ASI_KOR_NSD_Payment_Settlement_By_Brand__c where id in:propIds ]);
        
        for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdBrand : rsdPaymentSettlementByBrandList ){
            
            ASI_KOR_NSD_Payment_Settlement_By_Brand__c nsdBrand = nsdPaymentSByBrandMap.get(rsdBrand.ASI_KOR_NSD_Payment_Settlement_By_Brand__c);
            nsdBrand.ASI_KOR_Actual_Volume__c = nsdBrand.ASI_KOR_Actual_Volume__c == null ? 0 : nsdBrand.ASI_KOR_Actual_Volume__c ;
            nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c = nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c == null ? 0 : nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c ;
            nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c = nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c == null ? 0 : nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c ;
            nsdBrand.ASI_KOR_CA_Budget__c = nsdBrand.ASI_KOR_CA_Budget__c == null ? 0 : nsdBrand.ASI_KOR_CA_Budget__c ;
            nsdBrand.ASI_KOR_Target_Volume__c = nsdBrand.ASI_KOR_Target_Volume__c == null ? 0 : nsdBrand.ASI_KOR_Target_Volume__c ;
            nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c = nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c ;
            nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c = nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c ;
            nsdBrand.ASI_KOR_No_of_Submitted_Venues__c = nsdBrand.ASI_KOR_No_of_Submitted_Venues__c == null ? 0 : nsdBrand.ASI_KOR_No_of_Submitted_Venues__c ;
            /* [VL 1.0] BEGIN */
            nsdBrand.ASI_KOR_Total_Final_Basic__c = nsdBrand.ASI_KOR_Total_Final_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_Final_Basic__c ;
            nsdBrand.ASI_KOR_Pre_Payment_Amount__c = nsdBrand.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : nsdBrand.ASI_KOR_Pre_Payment_Amount__c ;
            /* [VL 1.0] END */
            
            if(rollUp && !rsdBrand.ASI_KOR_Roll_up__c ){
                rsdBrand.ASI_KOR_Roll_up__c = true;
                nsdBrand.ASI_KOR_Actual_Volume__c += rsdBrand.ASI_KOR_Actual_Volume__c == null ? 0 : rsdBrand .ASI_KOR_Actual_Volume__c ;
                nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c += rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c == null ? 0 : rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c ;
                nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c += rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c == null ? 0 : rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c;
                nsdBrand.ASI_KOR_CA_Budget__c += rsdBrand.ASI_KOR_CA_Budget__c == null ? 0 : rsdBrand.ASI_KOR_CA_Budget__c ;
                nsdBrand.ASI_KOR_Target_Volume__c += rsdBrand.ASI_KOR_Target_Volume__c == null ? 0 : rsdBrand.ASI_KOR_Target_Volume__c ;
                nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c += rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c += rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_No_of_Submitted_Venues__c += rsdBrand.ASI_KOR_No_of_Submitted_Venues__c== null ? 0 : rsdBrand.ASI_KOR_No_of_Submitted_Venues__c;
                /* [VL 1.0] BEGIN */
                nsdBrand.ASI_KOR_Total_Final_Basic__c += nsdBrand.ASI_KOR_Total_Final_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_Final_Basic__c ;
                nsdBrand.ASI_KOR_Pre_Payment_Amount__c += nsdBrand.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : nsdBrand.ASI_KOR_Pre_Payment_Amount__c ;
                /* [VL 1.0] END */
            }else if(!rollUp && rsdBrand.ASI_KOR_Roll_up__c ){
                rsdBrand.ASI_KOR_Roll_up__c = false;
                nsdBrand.ASI_KOR_Actual_Volume__c -= rsdBrand.ASI_KOR_Actual_Volume__c == null ? 0 : rsdBrand .ASI_KOR_Actual_Volume__c ;
                nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c -= rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c == null ? 0 : rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c ;
                nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c -= rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c == null ? 0 : rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c;
                nsdBrand.ASI_KOR_CA_Budget__c -= rsdBrand.ASI_KOR_CA_Budget__c == null ? 0 : rsdBrand.ASI_KOR_CA_Budget__c ;
                nsdBrand.ASI_KOR_Target_Volume__c -= rsdBrand.ASI_KOR_Target_Volume__c == null ? 0 : rsdBrand.ASI_KOR_Target_Volume__c ;
                nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c -= rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c -= rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_No_of_Submitted_Venues__c -= rsdBrand.ASI_KOR_No_of_Submitted_Venues__c== null ? 0 : rsdBrand.ASI_KOR_No_of_Submitted_Venues__c;
                /* [VL 1.0] BEGIN */
                nsdBrand.ASI_KOR_Total_Final_Basic__c -= nsdBrand.ASI_KOR_Total_Final_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_Final_Basic__c ;
                nsdBrand.ASI_KOR_Pre_Payment_Amount__c -= nsdBrand.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : nsdBrand.ASI_KOR_Pre_Payment_Amount__c ;
                /* [VL 1.0] END */
                
            }
        }
        
        for(Id pId :nsdPaymentSByBrandMap.keySet()){
            nsdPaymentSettlementByBrandList.add(nsdPaymentSByBrandMap.get(pId));
        }
        try{
            update nsdPaymentSettlementByBrandList;
            update rsdPaymentSettlementByBrandList;
            
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
        }
    }
    
	/* [VL 4.0] BEGIN */
	public string getExceptionalReport_unitCost(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Payment_Exceptional_Report_UC' limit 1];
		return report.id;
	}
	public string getExceptionalReport_notPlanned(){
		report report = [Select ID from Report where DeveloperName = 'ASI_CRM_KR_Payment_Exceptional_Report_XPlan' limit 1];
		return report.id;
	}
	public string getYear(){
		return rsdPaymentSettlementHeader.ASI_KOR_Year__c;
	}
	public string getMonth(){
		return rsdPaymentSettlementHeader.ASI_KOR_Month__c;
	}
	/* [VL 4.0] BEGIN */
    
	/* [VL 5.0] BEGIN */
	public boolean getIsRSD(){
		return rsdPaymentSettlementHeader.ownerid == UserInfo.getUserId();
	}
	
	public string approvalErrorMessage(){
		if(rsdByBranchCategoryList != null && rsdByBranchCategoryList.size()>0){
            Set<Id> bmHeaders = new Set<Id>();
            
            for(RSDByBranchCategory b : rsdByBranchCategoryList){
                bmHeaders.add(b.bmHeader.id);
            }
            
            Map<Id,ASI_KOR_BM_Payment_Settlement_Header__c> bmHeadersMap = new Map<Id,ASI_KOR_BM_Payment_Settlement_Header__c>([
                select id,ASI_KOR_Status__c   
                from ASI_KOR_BM_Payment_Settlement_Header__c where id in:bmHeaders]);
            
            for(RSDByBranchCategory b : rsdByBranchCategoryList){
				
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by RSD' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by RSD'){
					return 'It must be Approved by TMKT first.';
				}
				if(b.bmHeader.ASI_KOR_Status__c == 'Approved by TMKT' && bmHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c == 'Approved by RSD'){
					return 'It is already Approved by RSD.';
				}
			}
		}
		return '';
	}
	
	/* [VL 5.0] END */
	
    /* [VL 6.0] BEGIN */
	private decimal getSubmittedBM(){
		list<ASI_KOR_BM_Payment_Settlement_Header__c> header = [select id,ASI_KOR_Status__c from ASI_KOR_BM_Payment_Settlement_Header__c where ASI_KOR_RSD_Payment_Settlement__c =:rsdPaymentSettlementHeader.id
			and (ASI_KOR_Status__c = 'Submitted' or ASI_KOR_Status__c = 'Approved by TMKT')];
		return header.size();
	}
    /* [VL 6.0] END */
        
}