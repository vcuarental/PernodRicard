/**********************************************************************************
* Name : ASI_KOR_NSDPaymentSettlementController 
* Created : Vincent Lam
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??										Created
* 2017-02-20       Laputa: Vincent         [VL 1.0] add new column Total Basic, Prepayment and Final Total
* 2017-03-05		Laputa: Vincent			[VL 2.0] create new section (class) for CA brand grouping
* 2017-05-05		Laputa: Vincent			[VL 3.0] P4.2
* 2017-08-01		Laputa: Vincent			[VL 4.0] P4.2, retuns the report id
**********************************************************************************/
public without sharing class ASI_KOR_NSDPaymentSettlementController { 
    public ASI_KOR_NSD_Payment_Settlement_Header__c nsdPaymentSettlementHeader {get;set;}
    public List<NSDByBranchCategory> nsdByBranchCategoryList {get; set;}
    public Decimal propUnitCost{get;set;}
    public Decimal last3MonthAveVolume{get;set;}
    public Decimal last3MonthAveUnitCost{get;set;}
    public Decimal growth{get;set;}
    public Decimal targetVolume{get;set;}
    public Decimal propTotalIncentive{get;set;}
    public Decimal totalFinalCAAmountexclBasic{get;set;}
    public Decimal totalPendingCAAmount{get;set;}
    public Decimal totalNFPendingCAAmount{get;set;}
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
    public Decimal propTotalCA{get;set;}
    public Decimal branchBudget{get;set;}
    public Boolean renderSubmit {get;set;}
    public Boolean renderRecall {get;set;}
    public String status{get;set;}
    public Boolean canEdit {get; set;}
    
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
	
    public ASI_KOR_NSDPaymentSettlementController (ApexPages.StandardController standardController){
        renderSubmit = false;
        renderRecall = false;
        
		/* [VL 3.0] BEGIN */
		GrandTotal_volume = 0;
		GrandTotal_VI = 0;
		GrandTotal_prepayment = 0;
		GrandTotal_prepaymentVolume = 0;
		GrandTotal_finaltotal = 0;
		GrandTotal_incentive = 0;
		GrandTotal_VI_planned = 0;
		GrandTotal_volume_target = 0;
		GrandTotal_volume_target = 0;
		GrandTotal_budget_volume = 0;
		GrandTotal_budget_vi = 0;
		/* [VL 3.0] END */
        
        Id headerId = ((ASI_KOR_NSD_Payment_Settlement_Header__c)standardController.getRecord()).id;
        nsdPaymentSettlementHeader = [select id, 
                                      ASI_KOR_Status__c,
                                      ASI_KOR_Final_CA_Amount_excl_Basic__c,
                                      ASI_KOR_Delegated_Approver__c,
                                      ASI_KOR_Comments__c, 
                                      name,
                                      ASI_KOR_CA_Amount_excl_Basic__c,
                                      ASI_KOR_No_of_Sumitted_Regions__c,
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
                                      from ASI_KOR_NSD_Payment_Settlement_Header__c where id =: headerId];
        
        if(nsdPaymentSettlementHeader.ASI_KOR_Status__c == 'Draft' || nsdPaymentSettlementHeader.ASI_KOR_Status__c == 'Rejected')
            renderSubmit = true;
        else if(nsdPaymentSettlementHeader.ASI_KOR_Status__c == 'Submitted'){
            renderRecall = true;
        }
        
        
        User currentUser = [select id, userrole.name from user where id =: UserInfo.getUserId()];
        String uRole = currentUser.userrole.name;
        
        canEdit = (!ASI_KOR_NSDApprovalController.tmktRoles.contains(uRole) || (nsdPaymentSettlementHeader.ASI_KOR_Delegated_Approver__c == currentUser.id));
        
        Map<Id,ASI_KOR_RSD_Payment_Settlement_Header__c> bmPaymentSettlementHeaderMap = 
            new Map<Id,ASI_KOR_RSD_Payment_Settlement_Header__c>([select id, 
                                                                  ASI_KOR_Approval_Comments__c ,
                                                                  ASI_KOR_Comments__c,
                                                                  ASI_KOR_CA_Amount_excl_Basic__c,
                                                                  ASI_KOR_Final_CA_Amount_excl_Basic__c, 
                                                                  ownerId,
                                                                  ASI_KOR_Status__c,
                                                                  ASI_KOR_Total_Branch_Budget__c     
                                                                  /* [VL 1.0] BEGIN */
                                                                  , ASI_KOR_Final_Basic_Amount__c
                                                                  , ASI_KOR_Pre_Payment_Amount__c
                                                                  , ASI_KOR_Final_Total_Amount__c
                                                                  /* [VL 1.0] END */
                                                                  from ASI_KOR_RSD_Payment_Settlement_Header__c where ASI_KOR_NSD_Payment_Settlement__c =:headerId
                                                                  and (ASI_KOR_Status__c ='Submitted' OR ASI_KOR_Status__c ='Approved by NSD' )
                                                                 ]);
        
        Set<Id> usersId = new Set<Id>();
        
        for(Id i: bmPaymentSettlementHeaderMap.keySet()){ 
            usersId.add(bmPaymentSettlementHeaderMap.get(i).ownerId);
        }
        Map<Id, User> userMap = new Map<Id, User> ([select id,ASI_KOR_User_Region_Name__c,ASI_KOR_User_Region_Code__c from User where id in:usersId]);
        
        Map<Id, String> branchMap = new Map<Id,String>();
        
        for(Id id : bmPaymentSettlementHeaderMap.keySet()){
            Id oId = bmPaymentSettlementHeaderMap.get(id).ownerId;
            String branchName = userMap.get(oId).ASI_KOR_User_Region_Name__c;
            branchMap.put(id,branchName);
        }
        
        Map<Id,ASI_KOR_NSD_Payment_Settlement_By_Brand__c> rsdPaymentSettlementByBrandMap = new Map<Id,ASI_KOR_NSD_Payment_Settlement_By_Brand__c>([select id, name
                                                                                                                                                    from ASI_KOR_NSD_Payment_Settlement_By_Brand__c where 
                                                                                                                                                    ASI_KOR_NSD_Payment_Settlement_Header__c  =: headerId]);
        
        List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> bmSettlementByBrands = [select id, name,
                                                                                 ASI_KOR_RSD_Payment_Settlement__c,
                                                                                 ASI_KOR_Brand__r.name,
                                                                                 ASI_KOR_Brand__r.ASI_KOR_Product_Categoray__r.Name,
                                                                                 ASI_KOR_CA_Budget__c,
                                                                                 ASI_KOR_CA_Budget_Status__c,
                                                                                 ASI_KOR_Category__c,
                                                                                 ASI_KOR_Approved_Basic_Unit_Cost__c,
                                                                                 ASI_KOR_Actual_Unit_Cost_CA_Only__c,
                                                                                 ASI_KOR_Approved_CA_Unit_Cost_Ave__c,
                                                                                 ASI_KOR_Approved_Unit_Cost_Basic_CA__c,
                                                                                 ASI_KOR_Actual_Volume__c,
                                                                                 ASI_KOR_NSD_Payment_Settlement_By_Brand__c,
                                                                                 ASI_KOR_Target_Volume__c,
                                                                                 ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                 ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,
                                                                                 ASI_KOR_Approved_CA_Unit_CA__c,
                                                                                 ASI_KOR_Progression__c,
                                                                                 ASI_KOR_UOM__c, 
                                                                                 ASI_KOR_Approved_Basic_Unit_Cost_Ave__c
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
                                                                                 ASI_KOR_RSD_Payment_Settlement_By_Brand__c
                                                                                 where ASI_KOR_NSD_Payment_Settlement_By_Brand__c in:rsdPaymentSettlementByBrandMap.keySet()
                                                                                 and ASI_KOR_RSD_Payment_Settlement__c in:bmPaymentSettlementHeaderMap.keySet()
																				/* [VL 3.0] BEGIN */
																				order by ASI_KOR_Budget_Status__c, ASI_KOR_Final_Total_Amount__c desc, ASI_KOR_Brand__r.name
																				/* [VL 3.0] END */
                                                                                ];
        
        
        Map<Id,List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>> tempMap = new Map<Id,List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>>();
        
        for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c bm: bmSettlementByBrands){
            String branch =  branchMap.get(bm.ASI_KOR_RSD_Payment_Settlement__c);
            if(tempMap.get(bm.ASI_KOR_RSD_Payment_Settlement__c) == null){
                tempMap.put(bm.ASI_KOR_RSD_Payment_Settlement__c, new List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>());
                tempMap.get(bm.ASI_KOR_RSD_Payment_Settlement__c).add(bm);
            }else{
                tempMap.get(bm.ASI_KOR_RSD_Payment_Settlement__c).add(bm);
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
        nsdByBranchCategoryList = new List<NSDByBranchCategory>();
        for(String bmHeaderId: tempMap.keySet()){
            /* [VL 2.0] BEGIN */
            /*
            NSDByBranchCategory b = new NSDByBranchCategory();
            b.rsdSettlementByBrands = tempMap.get(bmHeaderId);
            Id oId = bmPaymentSettlementHeaderMap.get(bmHeaderId).ownerId; 
            b.regionCode=  userMap.get(oId).ASI_KOR_User_Region_Code__c;
            b.regionName = userMap.get(oId).ASI_KOR_User_Region_Name__c;
            b.bmHeader =  bmPaymentSettlementHeaderMap.get(bmHeaderId);
            nsdByBranchCategoryList.add(b);
            */
            Id oId = bmPaymentSettlementHeaderMap.get(bmHeaderId).ownerId;
            string branchCode=  userMap.get(oId).ASI_KOR_User_Region_Code__c;
            string branchName = userMap.get(oId).ASI_KOR_User_Region_Name__c;
            ASI_KOR_RSD_Payment_Settlement_Header__c bmHeader = bmPaymentSettlementHeaderMap.get(bmHeaderId);
            List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> rsdSettlementByBrands1 = tempMap.get(bmHeaderId); 
            NSDByBranchCategory b = new NSDByBranchCategory(branchCode, branchName, bmHeader, rsdSettlementByBrands1);
            nsdByBranchCategoryList.add(b);
            /* [VL 2.0] END */
        }
        system.debug('XX RSD :' + nsdByBranchCategoryList.size());
        
		/* [VL 3.0] BEGIN */
		nsdByBranchCategoryList.sort();
		/* [VL 3.0] END */
        
        populateSummary();
        populateRegionalTotal();
    }
    
    private void populateRegionalTotal(){
        propUnitCost = 0;
        last3MonthAveVolume = 0;
        last3MonthAveUnitCost = 0;
        growth = 0;
        targetVolume = 0;
        propTotalIncentive = 0;
        propTotalCA = 0;
        branchBudget = 0;
        totalFinalCAAmountexclBasic = 0;
        totalPendingCAAmount = 0;
        totalnfPendingCAAmount = 0;
        status ='';
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
            branchBudget += x.branchBudget;
            totalFinalCAAmountexclBasic += x.totalFinalCAAmountexclBasic;
            totalPendingCAAmount += x.totalPendingCAAmount;
            totalNFPendingCAAmount += x.totalNFPendingCAAmount;
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
        
        growth = (last3MonthAveVolume == 0)?0:(targetVolume/last3MonthAveVolume);
            status = propTotalCA > branchBudget?'Exceeded Budget' : 'Within Budget';
		/* [VL 3.0] BEGIN */
		totalBudgetUC = totalBudgetVITemp / (totalBudgetVolumeTemp == 0 ? 1 : totalBudgetVolumeTemp);
		totalBudgetStatus = totalSettlementUC > totalBudgetUC ? 'Exceed Target' : 'Within Target';
		/* [VL 3.0] END */
    }
    
    public List<RSDByBrandByCategory> rsdByBrandByCategoryList {get;set;}
    public List<RSDByBrandByCategory> nsdByBrandByCategoryList {get;set;}
    
    public void populateSummary(){
        rsdByBrandByCategoryList = new  List<RSDByBrandByCategory>();
        List<ASI_KOR_NSD_Payment_Settlement_By_Brand__c> rsdPaymentSettlementByBrands1 =  [select id,
                                                                                           ASI_KOR_Category__c, name, 
                                                                                           ASI_KOR_Brand__r.name,
                                                                                           ASI_KOR_CA_Amount_Pending__c,
                                                                                           ASI_KOR_Total_CA_Amount_Pending__c,
                                                                                           ASI_KOR_Approved_Basic_Unit_Cost__c,
                                                                                           ASI_KOR_Approved_Basic_Unit_Cost_Ave__c,
                                                                                           ASI_KOR_Approved_CA_Unit_Cost_Ave__c,
                                                                                           ASI_KOR_Approved_Unit_Cost_Basic_CA__c,
                                                                                           ASI_KOR_Progression__c,
                                                                                           ASI_KOR_CA_Budget__c,
                                                                                           ASI_KOR_Total_CA_Amount_excl_Basic__c,
                                                                                           ASI_KOR_Actual_Unit_Cost_CA_Only__c,
                                                                                           ASI_KOR_Approved_CA_Unit_CA__c,
                                                                                           ASI_KOR_Target_Volume__c ,
                                                                                           ASI_KOR_CA_Budget_Status__c ,
                                                                                           ASI_KOR_Actual_Volume__c ,
                                                                                           ASI_KOR_Total_Final_CA_Amount_excl_Basic__c,
                                                                                           ASI_KOR_UOM__c
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
                                                                                           from ASI_KOR_NSD_Payment_Settlement_By_Brand__c where 
                                                                                           ASI_KOR_NSD_Payment_Settlement_Header__c =: nsdPaymentSettlementHeader.id];
        
        List<NSDPaymentSettlementByBrand> rsdPaymentSettlementByBrands = new List<NSDPaymentSettlementByBrand>();
        
        for(ASI_KOR_NSD_Payment_Settlement_By_Brand__c paymentSettlement : rsdPaymentSettlementByBrands1) {
            NSDPaymentSettlementByBrand paymentWrapper = new NSDPaymentSettlementByBrand();
            paymentWrapper.paymentSettlementByBrand = paymentSettlement;
            Decimal totalFinalCa = paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c != null ? paymentSettlement.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c : 0;
            Decimal actVolume = paymentSettlement.ASI_KOR_Actual_Volume__c != null ? paymentSettlement.ASI_KOR_Actual_Volume__c : 0;
            paymentWrapper.settlementUnitCost = actVolume == 0 ? 0 : totalFinalCa/actVolume;
            rsdPaymentSettlementByBrands.add(paymentWrapper);
        }
        
        Map<String, List<NSDPaymentSettlementByBrand>> regionalCategoryMap = new Map<String, List<NSDPaymentSettlementByBrand>>();
        
        for(NSDPaymentSettlementByBrand rsd: rsdPaymentSettlementByBrands ){
            if(regionalCategoryMap.get(rsd.paymentSettlementByBrand.ASI_KOR_Category__c) == null){
                List<NSDPaymentSettlementByBrand> l = new List<NSDPaymentSettlementByBrand>();
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
        
        public List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> bmSettlementByBrands {get;set;}
        
        public RSDPaymentSettlementByCABrand(string caBrand, List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> bmSettlementByBrands){
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
                for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c detail : bmSettlementByBrands ){
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
    
    public class NSDByBranchCategory /* [VL 3.0] BEGIN */ implements Comparable /* [VL 3.0] END */ {
        public ASI_KOR_RSD_Payment_Settlement_Header__c bmHeader {get;set;}
        public String regionName {get;set;}
        public String regionCode {get;set;}
        /* [VL 2.0] BEGIN */
        /*
        public List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> rsdSettlementByBrands {get;set;}
        */
        public List<RSDPaymentSettlementByCABrand> rsdPaymentSettlementByCABrands {get;set;}
        /* [VL 2.0] END */
        
        public Decimal getTargetVolume(){
            Decimal temp = 0;
            /* [VL 2.0] BEGIN */
            /*
            for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsdSettlementByBrands){
                temp = temp + ((b.ASI_KOR_Target_Volume__c == null)?0:b.ASI_KOR_Target_Volume__c);
            }
            */
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + ((b.ASI_KOR_Target_Volume__c == null)?0:b.ASI_KOR_Target_Volume__c);
                }
            }
            /* [VL 2.0] END */
            return temp;
        }        
        
        /* [VL 2.0] BEGIN */
        public NSDByBranchCategory(string branchCode, String branchName, ASI_KOR_RSD_Payment_Settlement_Header__c bmHeader, List<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> bmSettlementByBrands){
            this.regionName = branchName;
            this.regionCode = branchCode;
            this.bmHeader = bmHeader;
            map<string, list<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>> map_caBrand_detail = new map<string, list<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>>();     
            for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c detail : bmSettlementByBrands){
                string caBrand = detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__c != null ? detail.ASI_KOR_Brand__r.ASI_KOR_CA_Brand__r.name : detail.ASI_KOR_Brand__r.name;
                if (map_caBrand_detail == null || !map_caBrand_detail.containsKey(caBrand)){
                    list<ASI_KOR_RSD_Payment_Settlement_By_Brand__c> temp_list_detail = new list<ASI_KOR_RSD_Payment_Settlement_By_Brand__c>();
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
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Total_VI_Planned__c == null ? 0 : b.ASI_KOR_Total_VI_Planned__c);
                }
            }
            return temp;
        }
        public Decimal getActualVolume(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Actual_Volume__c == null ? 0 : b.ASI_KOR_Actual_Volume__c);
                }
            }
            return temp;
        }
        public Decimal getTotalVI(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Total_Final_Basic__c == null ? 0 : b.ASI_KOR_Total_Final_Basic__c);
                }
            }
            return temp;
        }
        public Decimal getTotalPrepayment(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : b.ASI_KOR_Pre_Payment_Amount__c);
                }
            }
            return temp;
        }
        public Decimal getTotalFinal(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Final_Total_Amount__c == null ? 0 : b.ASI_KOR_Final_Total_Amount__c);
                }
            }
            return temp;
        }
        public Decimal getTotalBudgetVolume(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + (b.ASI_KOR_Budget_Target_Volume__c == null ? 0 : b.ASI_KOR_Budget_Target_Volume__c);
                }
            }
            return temp;
        }
        public Decimal getTotalBudgetVI(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
                    temp = temp + ((b.ASI_KOR_Budget_Target_VI__c == null ? 0 : b.ASI_KOR_Budget_Target_VI__c) * (b.ASI_KOR_Budget_Target_Volume__c == null ? 0 : b.ASI_KOR_Budget_Target_Volume__c));
                }
            }
            return temp;
        }
        public Decimal getPrepaymentVolume(){
            Decimal temp = 0;
            for (RSDPaymentSettlementByCABrand rsd : rsdPaymentSettlementByCABrands){
                for (ASI_KOR_RSD_Payment_Settlement_By_Brand__c b: rsd.bmSettlementByBrands ){
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
			NSDByBranchCategory compareToWrap = (NSDByBranchCategory)compareTo;
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
    
    // Added Wrapper Class for ASI_KOR_NSD_Payment_Settlement_By_Brand__c to cater formula field
    public class NSDPaymentSettlementByBrand {
        
        public ASI_KOR_NSD_Payment_Settlement_By_Brand__c paymentSettlementByBrand {get;set;}
        public decimal settlementUnitCost {get;set;}
        
		/* [VL 3.0] BEGIN */
		public boolean getDisplay(){
			if (
				(this.paymentSettlementByBrand.ASI_KOR_Target_Volume__c == 0 || this.paymentSettlementByBrand.ASI_KOR_Target_Volume__c == null) &&
				(this.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c == 0 || this.paymentSettlementByBrand.ASI_KOR_Actual_Volume__c == null) &&
				(this.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c == 0 || this.paymentSettlementByBrand.ASI_KOR_Total_Final_Basic__c == null) &&
				(this.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c == 0 || this.paymentSettlementByBrand.ASI_KOR_Actual_Pre_payment_Volume__c == null) &&
				(this.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c == 0 || this.paymentSettlementByBrand.ASI_KOR_Pre_Payment_Amount__c == null) &&
				(this.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c == 0 || this.paymentSettlementByBrand.ASI_KOR_Actual_Volume_Total__c == null) &&
				(this.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c == 0 || this.paymentSettlementByBrand.ASI_KOR_Final_Total_Amount__c == null)
			){
				return false;
			} else {
				return true;
			}
		}
		/* [VL 3.0] END */
    }
    
    public class RSDByBrandByCategory { 
        public Decimal propUnitCost{get;set;}
        public Decimal targetVolume{get;set;}
        public Decimal propTotalIncentive{get;set;}
        public Decimal propTotalCA{get;set;}
        public Decimal branchBudget{get;set;}
        public Decimal totalFinalCAAmountexclBasic{get;set;}
        public Decimal totalPendingCAAmount{get;set;}
        public Decimal totalNFPendingCAAmount{get;set;}
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
        public List<NSDPaymentSettlementByBrand> rsdPaymentSettlementByBrands {get; set;}
        public RSDByBrandByCategory(List<NSDPaymentSettlementByBrand> a){
            rsdPaymentSettlementByBrands = a;
            propUnitCost = 0;
            targetVolume = 0;
            propTotalIncentive = 0;
            propTotalCA = 0;
            branchBudget = 0;
            totalFinalCAAmountexclBasic = 0;
            totalPendingCAAmount = 0;
            totalNFPendingCAAmount = 0;
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
            for(NSDPaymentSettlementByBrand b: rsdPaymentSettlementByBrands){
                //propUnitCost = propUnitCost + ((b.ASI_KOR_PaymentSettlement_Unit_Cost_Basic_CA__c== null)?0:b.ASI_KOR_PaymentSettlement_Unit_Cost_Basic_CA__c);
                targetVolume = targetVolume + ((b.paymentSettlementByBrand.ASI_KOR_Target_Volume__c == null)?0:b.paymentSettlementByBrand.ASI_KOR_Target_Volume__c);
                //propTotalIncentive = propTotalIncentive + ((b.ASI_KOR_Total_Incentive_Amount_PaymentSettlement__c== null)?0:b.ASI_KOR_Total_Incentive_Amount_PaymentSettlement__c);
                propTotalCA = propTotalCA + ((b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c);
                branchBudget = branchBudget + ((b.paymentSettlementByBrand.ASI_KOR_CA_Budget__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_CA_Budget__c);
                totalFinalCAAmountexclBasic += ((b.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c);
                totalPendingCAAmount += ((b.paymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_CA_Amount_Pending__c);
                totalNFPendingCAAmount += ((b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c== null)?0:b.paymentSettlementByBrand.ASI_KOR_Total_CA_Amount_Pending__c); 
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
    
    public PageReference handleSave(){
        
        if(nsdByBranchCategoryList != null && nsdByBranchCategoryList.size()>0){
            List<ASI_KOR_RSD_Payment_Settlement_Header__c > toUpdate = new List<ASI_KOR_RSD_Payment_Settlement_Header__c >();
            Set<Id> bmHeaders = new Set<Id>();
            for(NSDByBranchCategory b : nsdByBranchCategoryList){
                bmHeaders.add(b.bmHeader.id);
            }
            
            Map<Id,ASI_KOR_RSD_Payment_Settlement_Header__c> rsdHeadersMap = new Map<Id,ASI_KOR_RSD_Payment_Settlement_Header__c>([
                select id,
				ASI_KOR_Status__c,
				ASI_KOR_Final_CA_Amount_excl_Basic__c     
				  /* [VL 3.0] BEGIN */
				  , ASI_KOR_Final_Basic_Amount__c
				  /* [VL 3.0] END */  
                from ASI_KOR_RSD_Payment_Settlement_Header__c 
				where id in:bmHeaders]);
            
            for(NSDByBranchCategory b : nsdByBranchCategoryList){
                toUpdate.add(b.bmHeader);
                if(b.bmHeader.ASI_KOR_Status__c == 'Rejected'){
                    if(rsdHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c == 'Approved by NSD'){
                        rollUp(b.bmHeader.id,false);
                    } else 
                    {
                        ASI_KOR_RSDPaymentSettlementController.rollUpCAPending(b.bmHeader.id,false);        
						/* [VL 3.0] BEGIN */
						nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c;
						nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c -= nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == 0 ? 0 : rsdHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c;
						/* [VL 3.0] END */
                    }
                    Decimal noOfSumittedRegions = nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c==null?0:nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c;
                    nsdPaymentSettlementHeader.ASI_KOR_No_of_Sumitted_Regions__c = noOfSumittedRegions - 1;
                    
                }
				/* VL 20170531: I think this is a bug, have to move it to below IF
                rollUp(b.bmHeader.id,true);
				*/
                if(b.bmHeader.ASI_KOR_Status__c == 'Approved by NSD' && rsdHeadersMap.get(b.bmHeader.id).ASI_KOR_Status__c != 'Approved by NSD'){
                    rollUp(b.bmHeader.id,true);
					ASI_KOR_RSDPaymentSettlementController.rollUpCAPending(b.bmHeader.id,false);     
					/* [VL 3.0] BEGIN */
					nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c = nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == null ? 0 : nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c;
					nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c -= nsdPaymentSettlementHeader.ASI_KOR_Total_VI_Pending__c == 0 ? 0 : rsdHeadersMap.get(b.bmHeader.id).ASI_KOR_Final_Basic_Amount__c;
					/* [VL 3.0] END */
                }
            }
            
            try{
                update nsdPaymentSettlementHeader;
                update toUpdate;
            } catch ( DmlException exc) {
                ApexPages.addMessages(exc);
                return null;
            }
            PageReference pageRef   = new PageReference('/apex/ASI_KOR_NSDPaymentSettlement?id=' + nsdPaymentSettlementHeader.id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    public PageReference handleSubmit(){
        handleSave();
        system.debug('aaa approve button clicked!');
        ASI_KOR_NSD_Payment_Settlement_Header__c temp = new ASI_KOR_NSD_Payment_Settlement_Header__c (id=nsdPaymentSettlementHeader.id);
        temp.ASI_KOR_Status__c = 'Final Approved';
        
        try{
            update temp;
        } catch ( DmlException exc) {
            system.debug('XXX error: ' + exc);
            ApexPages.addMessages(exc);
            
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_NSDPaymentSettlement?id=' + nsdPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
    
    public PageReference handleRecall(){
        
        nsdPaymentSettlementHeader.ASI_KOR_Status__c = 'Draft';
        
        try{
            update nsdPaymentSettlementHeader; 
        } catch ( DmlException exc) {
            ApexPages.addMessages(exc);
            return null;
        }
        PageReference pageRef   = new PageReference('/apex/ASI_KOR_NSDPaymentSettlement?id=' + nsdPaymentSettlementHeader.id);
        pageRef.setRedirect(true);
        return pageRef;
        
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
                                                                                            ASI_KOR_Roll_up__c,
                                                                                            ASI_KOR_No_of_Submitted_Venues__c   
                                                                                            /* [VL 1.0] BEGIN */
                                                                                            , ASI_KOR_Total_Final_Basic__c
                                                                                            , ASI_KOR_Pre_Payment_Amount__c
                                                                                            /* [VL 1.0] END */  
                                                                                            /* [VL 3.0] BEGIN */
                                                                                            , ASI_KOR_Actual_Pre_payment_Volume__c
                                                                                            /* [VL 3.0] END */
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
			/* [VL 3.0] BEGIN */
			, ASI_KOR_Actual_Pre_payment_Volume__c
			/* [VL 3.0] END */
             from ASI_KOR_NSD_Payment_Settlement_By_Brand__c where id in:propIds ]);
        
        for(ASI_KOR_RSD_Payment_Settlement_By_Brand__c rsdBrand : rsdPaymentSettlementByBrandList ){
            
            ASI_KOR_NSD_Payment_Settlement_By_Brand__c nsdBrand = nsdPaymentSByBrandMap.get(rsdBrand.ASI_KOR_NSD_Payment_Settlement_By_Brand__c);
            nsdBrand.ASI_KOR_Actual_Volume__c = nsdBrand.ASI_KOR_Actual_Volume__c == null ? 0 : nsdBrand.ASI_KOR_Actual_Volume__c ;
            nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c = nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c == null ? 0 : nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c ;
            nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c = nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c == null ? 0 : nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c; 
            //nsdBrand.ASI_KOR_CA_Budget__c = nsdBrand.ASI_KOR_CA_Budget__c == null ? 0 : nsdBrand.ASI_KOR_CA_Budget__c ;
            nsdBrand.ASI_KOR_Target_Volume__c = nsdBrand.ASI_KOR_Target_Volume__c == null ? 0 : nsdBrand.ASI_KOR_Target_Volume__c ;
            nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c = nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c ;
            nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c = nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c ;
            nsdBrand.ASI_KOR_No_of_Submitted_Venues__c = nsdBrand.ASI_KOR_No_of_Submitted_Venues__c == null ? 0 : nsdBrand.ASI_KOR_No_of_Submitted_Venues__c ;
            /* [VL 1.0] BEGIN */
            nsdBrand.ASI_KOR_Total_Final_Basic__c = nsdBrand.ASI_KOR_Total_Final_Basic__c == null ? 0 : nsdBrand.ASI_KOR_Total_Final_Basic__c ;
            nsdBrand.ASI_KOR_Pre_Payment_Amount__c = nsdBrand.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : nsdBrand.ASI_KOR_Pre_Payment_Amount__c ;
            /* [VL 1.0] END */
			/* [VL 3.0] BEGIN */
            nsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c = nsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c == null ? 0 : nsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c ;
            /* [VL 3.0] END */
            
            system.debug('XXXX DEV ROLL UP RSD BASIC ' + rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c );
            system.debug('XXXX DEV ROLL UP RSD CA ' + rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c);
            system.debug('XXXX DEV ROLL UP NSD BASIC ' + nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c );
            system.debug('XXXX DEV ROLL UP NSD CA ' + nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c);
            
            if(rollUp && !rsdBrand.ASI_KOR_Roll_up__c ){
                rsdBrand.ASI_KOR_Roll_up__c = true;
                nsdBrand.ASI_KOR_Actual_Volume__c += rsdBrand.ASI_KOR_Actual_Volume__c == null ? 0 : rsdBrand .ASI_KOR_Actual_Volume__c ;
                nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c += rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c == null ? 0 : rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c ;
                nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c += rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c == null ? 0 : rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c;
                
                //nsdBrand.ASI_KOR_CA_Budget__c += rsdBrand.ASI_KOR_CA_Budget__c == null ? 0 : rsdBrand.ASI_KOR_CA_Budget__c ;
                nsdBrand.ASI_KOR_Target_Volume__c += rsdBrand.ASI_KOR_Target_Volume__c == null ? 0 : rsdBrand.ASI_KOR_Target_Volume__c ;
                nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c += rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c += rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_No_of_Submitted_Venues__c += rsdBrand.ASI_KOR_No_of_Submitted_Venues__c== null ? 0 : rsdBrand.ASI_KOR_No_of_Submitted_Venues__c;
                
                /* [VL 1.0] BEGIN */
                nsdBrand.ASI_KOR_Total_Final_Basic__c += rsdBrand.ASI_KOR_Total_Final_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_Final_Basic__c ;
                nsdBrand.ASI_KOR_Pre_Payment_Amount__c += rsdBrand.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : rsdBrand.ASI_KOR_Pre_Payment_Amount__c ;
                /* [VL 1.0] END */
                /* [VL 3.0] BEGIN */
                nsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c += rsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c == null ? 0 : rsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c ;
                /* [VL 3.0] END */
            }else if(!rollUp && rsdBrand.ASI_KOR_Roll_up__c ){
                rsdBrand.ASI_KOR_Roll_up__c = false;
                nsdBrand.ASI_KOR_Actual_Volume__c -= rsdBrand.ASI_KOR_Actual_Volume__c == null ? 0 : rsdBrand .ASI_KOR_Actual_Volume__c ;
                nsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c -= rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c == null ? 0 : rsdBrand.ASI_KOR_Approved_Basic_Unit_Cost__c ;
                nsdBrand.ASI_KOR_Approved_CA_Unit_CA__c -= rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c == null ? 0 : rsdBrand.ASI_KOR_Approved_CA_Unit_CA__c;
                //nsdBrand.ASI_KOR_CA_Budget__c -= rsdBrand.ASI_KOR_CA_Budget__c == null ? 0 : rsdBrand.ASI_KOR_CA_Budget__c ;
                nsdBrand.ASI_KOR_Target_Volume__c -= rsdBrand.ASI_KOR_Target_Volume__c == null ? 0 : rsdBrand.ASI_KOR_Target_Volume__c ;
                nsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c -= rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c -= rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_Final_CA_Amount_excl_Basic__c ;
                nsdBrand.ASI_KOR_No_of_Submitted_Venues__c -= rsdBrand.ASI_KOR_No_of_Submitted_Venues__c== null ? 0 : rsdBrand.ASI_KOR_No_of_Submitted_Venues__c;
                /* [VL 1.0] BEGIN */
                nsdBrand.ASI_KOR_Total_Final_Basic__c -= rsdBrand.ASI_KOR_Total_Final_Basic__c == null ? 0 : rsdBrand.ASI_KOR_Total_Final_Basic__c ;
                nsdBrand.ASI_KOR_Pre_Payment_Amount__c -= rsdBrand.ASI_KOR_Pre_Payment_Amount__c == null ? 0 : rsdBrand.ASI_KOR_Pre_Payment_Amount__c ;
                /* [VL 1.0] END */
                /* [VL 3.0] BEGIN */
                nsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c -= rsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c == null ? 0 : rsdBrand.ASI_KOR_Actual_Pre_payment_Volume__c ;
                /* [VL 3.0] END */
            }
            nsdPaymentSettlementByBrandList.add(nsdBrand);
        }
        /*
for(Id pId :nsdPaymentSByBrandMap.keySet()){
nsdPaymentSettlementByBrandList.add(nsdPaymentSByBrandMap.get(pId));
}
*/
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
		return nsdPaymentSettlementHeader.ASI_KOR_Year__c;
	}
	public string getMonth(){
		return nsdPaymentSettlementHeader.ASI_KOR_Month__c;
	}
	/* [VL 4.0] BEGIN */
    
}