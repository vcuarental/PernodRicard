//Test class : ASI_CRM_MY_Contract_TEST

public with sharing class ASI_CRM_MY_ContributionPerCase_Ctl{
    
    public ASI_CRM_MY_ContributionPerCase_Ctl(){ }
    
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }

    private ApexPages.StandardController standardController {get;set;}
    public Integer NumOfMonth {get; set;}
    public datetime currentTime {get; set;} {currentTime = system.now();}
    public Id ContractId{get; set;}
    public ASI_TH_CRM_Contract__c  header {get;set;} {header = new ASI_TH_CRM_Contract__c ();}

    public ASI_CRM_MY_ContributionPerCase_Ctl(ApexPages.StandardController standardController){
        ContractId  = ApexPages.CurrentPage().getparameters().get('id');
        boolean d1 = init(); 
    }
    
    public Map<Integer, String> mapTableId {get; set;} {mapTableId = new Map<Integer, String>();}
    public Map<Id, ContributionPerCase> mapOfContributionPerCase {get; set;}
    public List<Map<Id, ContributionPerCase>> l_mapOfContributionPerCase {get; set;}
    public Map<String, Decimal> mapOfTotal {get; set;}
    
    // Declaration
    public integer COL_PER_PAGE = 8;
    public Map<integer, Map<integer, Map<integer, String>>> mapStrTblData{get; set;} {mapStrTblData = new Map<integer, Map<integer, Map<integer, String>>>{}; }
    public ASI_CRM_MY_ContractDBC clsContractDBC;
    public string strTitle {get; set;} {strTitle = 'Contribution Per Case (CPC)';}
    // Declaration - End
    public static Map<String, Set<id>> mapMYGroup_user = ASI_CRM_MY_Function.getMYGroup();
    
    public Id rtIGC = Global_RecordTypeCache.getRTId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_IGC'); 
    
    
    public class ContributionPerCase {
        public String SKU_description {get; set;}
        public String cross_brand_SKU_description {get; set;}
        public Decimal purchase_target_cases {get; set;}
        public Decimal purchase_value {get; set;}
        public ContributionPerCaseTotal upfront {get; set;}
        public ContributionPerCaseTotal volInc {get; set;}
        public ContributionPerCaseTotal eventsSponsorship {get; set;}
        public ContributionPerCaseTotal specialOccasions {get; set;}
        public ContributionPerCaseTotal bonus {get; set;}
        public Decimal grand_total {get; set;}
        public Decimal total_incentives_per_case {get; set;}
        public Decimal price_per_case  {get; set;}
        public Decimal trade_offer {get; set;}
        public String trade_offer_string {get; set;}
        public Decimal rsp_bottle {get; set;}
        public Decimal net_bottle {get; set;}
        public Decimal net_bot_after_inc {get; set;}
        public Decimal quantity_t  {get; set;}
        public Decimal offer_value {get; set;}
        public Decimal qty_trade_offer {get; set;}
        
        
        public ContributionPerCase(String SKU_description, String cross_brand_SKU_description, Decimal purchase_target_cases, Decimal purchase_value,
                                  ContributionPerCaseTotal upfront, ContributionPerCaseTotal volInc, ContributionPerCaseTotal eventsSponsorship,
                                  ContributionPerCaseTotal specialOccasions, ContributionPerCaseTotal bonus, Decimal grand_total,
                                  Decimal total_incentives_per_case, Decimal price_per_case, Decimal trade_offer,
                                  Decimal rsp_bottle, Decimal net_bottle, Decimal net_bot_after_inc,
                                  Decimal quantity_t, Decimal offer_value, Decimal qty_trade_offer){
                                      
                                      this.SKU_description = SKU_description;
                                      this.cross_brand_SKU_description = cross_brand_SKU_description;
                                      this.purchase_target_cases = purchase_target_cases;
                                      this.purchase_value = purchase_value;
                                      this.upfront = upfront;
                                      this.volInc = volInc;
                                      this.eventsSponsorship = eventsSponsorship;
                                      this.specialOccasions = specialOccasions;
                                      this.bonus = bonus;
                                      this.grand_total = grand_total;
                                      this.total_incentives_per_case = total_incentives_per_case;
                                      this.price_per_case = price_per_case;
                                      this.trade_offer = trade_offer;
                                      this.trade_offer_string = '12+'+ trade_offer;
                                      this.rsp_bottle = rsp_bottle;
                                      this.net_bottle = net_bottle;
                                      this.net_bot_after_inc = net_bot_after_inc;
                                      this.quantity_t = quantity_t;
                                      this.offer_value = offer_value;
                                      this.qty_trade_offer = qty_trade_offer;
            
        }
        
    }
    
 
    
    public class ContributionPerCaseTotal {
        public Decimal per_case_cash {get; set;}
        public Decimal per_case_foc {get; set;}
        public Decimal foc {get; set;}
        public Decimal total {get; set;}
        

        
        public ContributionPerCaseTotal(){
            
        }
        
        
        public ContributionPerCaseTotal(Decimal per_case_cash, Decimal per_case_foc, Decimal foc, Decimal total){
            this.per_case_cash = per_case_cash;
            this.per_case_foc = per_case_foc;
            this.foc = foc;
            this.total = total;
        }
    }
        
    
    public boolean init(){
        this.standardController = standardController;
        
        header=[select Id,Name,ASI_CRM_CN_Outlet_WS__r.name,ASI_TH_CRM_Start_Date__c,ASI_TH_CRM_End_Date__c,LastModifiedBy.FirstName,LastModifiedBy.LastName,owner.FirstName,owner.LastName,ASI_TH_CRM_Contract_Status__c,createdDate  from ASI_TH_CRM_Contract__c  where id=: ContractId];

        boolean isGroupMember = False;
       	
        Set<Id> skuSet = new Set<Id>();
        
        Map<Id, ASI_CRM_ContractTarget__c> mapOfContractTarget = new Map<Id, ASI_CRM_ContractTarget__c>();
        List<ASI_CRM_ContractTarget__c> listOfContractTarget = new List<ASI_CRM_ContractTarget__c>();
        listOfContractTarget = 
            [SELECT 
                id,
                ASI_CRM_SKU__r.Id,
             	ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,
             	ASI_CRM_TargetCase__c
             FROM ASI_CRM_ContractTarget__c
             WHERE ASI_CRM_Contract__c = :contractId 
             LIMIT 1000];
        
        for(ASI_CRM_ContractTarget__c contractTarget : listOfContractTarget){
            Id skuId = contractTarget.ASI_CRM_SKU__r.Id;
            mapOfContractTarget.put(skuId, contractTarget);
            skuSet.add(skuId);
        }
        
        
        Map<Id, ASI_CRM_ContractOtherIncentive__c> mapOfOtherIncentiveContributionPerCase = new Map<Id, ASI_CRM_ContractOtherIncentive__c>();
        List<ASI_CRM_ContractOtherIncentive__c> listOfOtherIncentive = 
            [SELECT 
             id,
             ASI_CRM_FOC__c,
             ASI_CRM_Total__c,
             ASI_CRM_CashInc__c,
             ASI_CRM_Description__c,
             ASI_CRM_SKU__r.Id,
             ASI_CRM_MinSPBtl__c,
             ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c,
             ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c, 
             ASI_CRM_AchievedBtl__c,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_HK_CRM_Product_Category__r.Name,
             ASI_CRM_Type__c,
             ASI_CRM_Contract__r.ASI_CRM_Last_Revision_Date__c
             FROM ASI_CRM_ContractOtherIncentive__c
             WHERE ASI_CRM_Contract__c = :contractId 
             AND ASI_CRM_AchievedBtl__c > 0
             AND (ASI_CRM_FOC__c > 0 OR ASI_CRM_CashInc__c > 0)
             LIMIT 1000];
        
        Map<Id, List<ASI_CRM_ContractOtherIncentive__c>> mapOfListOtherIncentiveContributionPerCase = new Map<Id, List<ASI_CRM_ContractOtherIncentive__c>>();
        for(ASI_CRM_ContractOtherIncentive__c otherIncentive : listOfOtherIncentive){
			Id skuId = otherIncentive.ASI_CRM_SKU__r.Id;
            if(mapOfOtherIncentiveContributionPerCase.get(skuId) != null){
            	//ASI_CRM_ContractOtherIncentive__c oldContributionPerCase = mapOfOtherIncentiveContributionPerCase.get(skuId);
               	//cash += oldContributionPerCase.cash;
                //total += oldContributionPerCase.total;
            }
            else{
                
            }
            List<ASI_CRM_ContractOtherIncentive__c> listOtherIncentiveContributionPerCase = mapOfListOtherIncentiveContributionPerCase.get(skuId) != null ? mapOfListOtherIncentiveContributionPerCase.get(skuId) : new List<ASI_CRM_ContractOtherIncentive__c>();
            listOtherIncentiveContributionPerCase.add(otherIncentive);
            mapOfListOtherIncentiveContributionPerCase.put(skuId, listOtherIncentiveContributionPerCase);
            mapOfOtherIncentiveContributionPerCase.put(skuId, otherIncentive);
            skuSet.add(skuId);
        }
        
        
        
        Map<Id, ASI_CRM_ContractVolumeIncentive__c> mapOfVolumeIncentiveContributionPerCase = new Map<Id, ASI_CRM_ContractVolumeIncentive__c>();
        List<ASI_CRM_ContractVolumeIncentive__c> listOfContractVolume = 
           [SELECT Id, 
            Name, 
            ASI_CRM_Description__c, 
            ASI_CRM_SKU__c, 
            ASI_CRM_SKU__r.id,
            ASI_CRM_PackFactor__c, 
            ASI_CRM_MinSPBtl__c,
            ASI_CRM_CashInc__c,
            ASI_CRM_SetupCode__c, 
            ASI_CRM_FOC__c, 
            ASI_CRM_AchievedBtl__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c,
            ASI_CRM_Contract__r.Name, 
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name,
            ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c,
            ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c,
            ASI_CRM_Contract__c,
            ASI_CRM_Contract__r.Owner.FirstName, 
            ASI_CRM_Contract__r.Owner.LastName,
            ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id,
            ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c,
            ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
            ASI_CRM_Contract__r.ASI_CRM_Last_Revision_Date__c,
            ASI_CRM_Packaging_Size__c
            FROM  ASI_CRM_ContractVolumeIncentive__c
            WHERE ASI_CRM_Contract__c = :contractId
            AND ASI_CRM_AchievedBtl__c > 0
            AND ASI_CRM_CashInc__c > 0
            ORDER BY ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Contract__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c
           	LIMIT 1000];
        
        
        for(ASI_CRM_ContractVolumeIncentive__c contractVolume : listOfContractVolume){
            Id skuId = contractVolume.ASI_CRM_SKU__r.Id;
            mapOfVolumeIncentiveContributionPerCase.put(skuId, contractVolume);
            skuSet.add(skuId);
        }
        
        
        
        Map<Id, ASI_CRM_ContractSalesStaffIncentive__c> mapOfSalesStaffContributionPerCase = new Map<Id, ASI_CRM_ContractSalesStaffIncentive__c>();
        List<ASI_CRM_ContractSalesStaffIncentive__c> listOfSalesIncentive =
            [SELECT 
                id, 
                ASI_CRM_Contract__r.Name, 
                ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__c, 
                ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.id,
                ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c,
                ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name, 
                ASI_CRM_Contract__r.id,
                ASI_CRM_Contract__r.Owner.FirstName, 
                ASI_CRM_Contract__r.Owner.LastName, 
                ASI_CRM_Contract__r.ASI_CRM_IsParentContract__c, 
                ASI_CRM_SKU__r.id,
                ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name,
                ASI_CRM_SKU__r.ASI_HK_CRM_Pack_Factor__c,
                ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c, 
                ASI_CRM_SKU__c,
                ASI_CRM_Packaging_Size__c, 
                ASI_CRM_AchievedBtl__c, 
                ASI_CRM_FOCPRM__c,
                ASI_CRM_FOCWS__c,
             	ASI_CRM_MinSPBtl__c,
                ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c, 
                ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
                ASI_CRM_SetupCode__c,
             	ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c,
             	ASI_CRM_Contract__r.ASI_CRM_Last_Revision_Date__c,
                ASI_CRM_JDECOA__c 
            FROM ASI_CRM_ContractSalesStaffIncentive__c
            WHERE ASI_CRM_Contract__c = :contractId
            AND ASI_CRM_AchievedBtl__c > 0
            
            ORDER BY ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_CRM_Contract__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c
            LIMIT 1000];
        //AND (ASI_CRM_FOCPRM__c > 0 OR ASI_CRM_FOCWS__c > 0)
        for(ASI_CRM_ContractSalesStaffIncentive__c salesIncentive : listOfSalesIncentive){
            Id skuId = salesIncentive.ASI_CRM_SKU__r.Id;
            mapOfSalesStaffContributionPerCase.put(skuId, salesIncentive);
            skuSet.add(skuId);
        }


		mapOfContributionPerCase = new Map<Id, ContributionPerCase>();		        
        for (Id skuId : skuSet){
            
            // OtherIncentiveContributionPerCase otherIncentiveContributionPerCase = mapOfOtherIncentiveContributionPerCase.containsKey(skuId) ? mapOfOtherIncentiveContributionPerCase.get(skuId) : new OtherIncentiveContributionPerCase();
            // VolumeIncentiveContributionPerCase volumeIncentiveContributionPerCase = mapOfVolumeIncentiveContributionPerCase.containsKey(skuId) ? mapOfVolumeIncentiveContributionPerCase.get(skuId) : new VolumeIncentiveContributionPerCase();
			String SKU_description = '';
            String cross_brand_SKU_description = '';
            Decimal purchase_target_cases = 0;
            Decimal purchase_value = 0;
            ContributionPerCaseTotal upfront = new ContributionPerCaseTotal(0, 0, 0, 0);
            ContributionPerCaseTotal volInc = new ContributionPerCaseTotal(0, 0, 0, 0);
            ContributionPerCaseTotal eventsSponsorship = new ContributionPerCaseTotal(0, 0, 0, 0);
            ContributionPerCaseTotal specialOccasions = new ContributionPerCaseTotal(0, 0, 0, 0);
            ContributionPerCaseTotal bonus = new ContributionPerCaseTotal(0, 0, 0, 0);
            Decimal grand_total = 0;
            Decimal total_incentives_per_case = 0;
            Decimal price_per_case = 0;
            Decimal trade_offer = 0;
            Decimal rsp_bottle = 0;
            Decimal net_bottle = 0;
            Decimal net_bot_after_inc = 0;
            Decimal quantity_t = 0;
            Decimal quantity_t_offer_bottles = 0;
            Decimal offer_value = 0;
            Decimal qty_trade_offer = 0;
            
            
            if(mapOfListOtherIncentiveContributionPerCase.containsKey(skuId)){
                
				List<ASI_CRM_ContractOtherIncentive__c> listOtherIncentive = mapOfListOtherIncentiveContributionPerCase.get(skuId); 
                
                for(ASI_CRM_ContractOtherIncentive__c otherIncentive : listOtherIncentive){
                    
                    SKU_description = otherIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c != null ? otherIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c : '';
                    
                    Decimal achievedBtl = otherIncentive.ASI_CRM_AchievedBtl__c != null ? otherIncentive.ASI_CRM_AchievedBtl__c : 0;
                    String sponsorship_type = otherIncentive.ASI_CRM_Type__c != null ? otherIncentive.ASI_CRM_Type__c : '';
                    Decimal cash = otherIncentive.ASI_CRM_CashInc__c != null ? otherIncentive.ASI_CRM_CashInc__c : 0;
                    Decimal total = otherIncentive.ASI_CRM_Total__c != null ? otherIncentive.ASI_CRM_Total__c : 0;
                    Decimal minSPBtl = otherIncentive.ASI_CRM_MinSPBtl__c != null ? otherIncentive.ASI_CRM_MinSPBtl__c : 0;
                    
                    //------------------   update 2018-11-19   ------------------
                    //purchase_target_cases = (achievedBtl / 12);
                    //purchase_target_cases = purchase_target_cases.round(System.RoundingMode.DOWN);
                    //purchase_value = purchase_target_cases * minSPBtl * 12;
                    //purchase_value = purchase_value.setScale(0, System.RoundingMode.DOWN);
                }
                
 
            }
            
            
            if(mapOfVolumeIncentiveContributionPerCase.containsKey(skuId)){
                
                ASI_CRM_ContractVolumeIncentive__c contractVolume = mapOfVolumeIncentiveContributionPerCase.get(skuId);
                SKU_description = contractVolume.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c != null ? contractVolume.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c : '';
                //Decimal achievedBtl = contractVolume.ASI_CRM_AchievedBtl__c != null ? contractVolume.ASI_CRM_AchievedBtl__c : 0;
            	Decimal cash = contractVolume.ASI_CRM_CashInc__c != null ? contractVolume.ASI_CRM_CashInc__c : 0;
                Decimal minSPBtl = contractVolume.ASI_CRM_MinSPBtl__c != null ? contractVolume.ASI_CRM_MinSPBtl__c : 0;
                
                ASI_CRM_ContractTarget__c contractTarget = mapOfContractTarget.get(skuId);
                Decimal packaging_size = contractTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null ? contractTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
                Decimal target_case = contractTarget.ASI_CRM_TargetCase__c != null ? contractTarget.ASI_CRM_TargetCase__c : 0;
                Decimal achievedBtl = target_case * packaging_size;
                
                purchase_target_cases = (achievedBtl / 12);
                //purchase_target_cases = purchase_target_cases.round(System.RoundingMode.DOWN);
                purchase_value = purchase_target_cases * minSPBtl * 12;
                purchase_value = purchase_value.setScale(0, System.RoundingMode.DOWN);
            }
            
            
            if(mapOfSalesStaffContributionPerCase.containsKey(skuId)){
                
                ASI_CRM_ContractSalesStaffIncentive__c salesIncentive = mapOfSalesStaffContributionPerCase.get(skuId);
                Decimal focprm = salesIncentive.ASI_CRM_FOCPRM__c != null ? salesIncentive.ASI_CRM_FOCPRM__c : 0;
                Decimal focws = salesIncentive.ASI_CRM_FOCWS__c != null ? salesIncentive.ASI_CRM_FOCWS__c : 0;
                Decimal total_foc = focprm + focws;
				//Decimal achievedBtl = salesIncentive.ASI_CRM_AchievedBtl__c != null ? salesIncentive.ASI_CRM_AchievedBtl__c : 0;
				Decimal minSPBtl = salesIncentive.ASI_CRM_MinSPBtl__c != null ? salesIncentive.ASI_CRM_MinSPBtl__c : 0;
                
                
                //purchase_target_cases = (achievedBtl / 12);
                //purchase_target_cases = purchase_target_cases.round(System.RoundingMode.DOWN);
                //purchase_value = purchase_target_cases * minSPBtl * 12;
                //purchase_value = purchase_value.setScale(0, System.RoundingMode.DOWN);
                
                ASI_CRM_ContractTarget__c contractTarget = mapOfContractTarget.get(skuId);
                Decimal packaging_size = contractTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null ? contractTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
                Decimal target_case = contractTarget.ASI_CRM_TargetCase__c != null ? contractTarget.ASI_CRM_TargetCase__c : 0;
                Decimal achievedBtl = target_case * packaging_size;
                
                purchase_target_cases = (achievedBtl / 12);
                purchase_target_cases = purchase_target_cases.round(System.RoundingMode.DOWN);
                purchase_value = purchase_target_cases * minSPBtl * 12;
                purchase_value = purchase_value.setScale(0, System.RoundingMode.DOWN);
                
            }
           	
            
            if(mapOfListOtherIncentiveContributionPerCase.containsKey(skuId)){
                
                List<ASI_CRM_ContractOtherIncentive__c> listOtherIncentive = mapOfListOtherIncentiveContributionPerCase.get(skuId); 
                Decimal up_total_cash = 0;
                Decimal up_total_foc = 0;
                Decimal up_total = 0;
                Decimal up_foc = 0;
                Decimal up_achievedBtl_foc = 0;
                Decimal up_achievedBtl_cash = 0;
                Decimal up_per_case_cash = 0;
                Decimal up_per_case_foc = 0;
                
                Decimal es_total_cash = 0;
                Decimal es_total_foc = 0;
                Decimal es_total = 0;
                Decimal es_foc = 0;
                Decimal es_achievedBtl_foc = 0;
                Decimal es_achievedBtl_cash = 0;
                Decimal es_per_case_cash = 0;
                Decimal es_per_case_foc = 0;
                
                
                Decimal so_total_cash = 0;
                Decimal so_total_foc = 0;
                Decimal so_total = 0;
                Decimal so_foc = 0;
                Decimal so_achievedBtl_foc = 0;
                Decimal so_achievedBtl_cash = 0;
                Decimal so_per_case_cash = 0;
                Decimal so_per_case_foc = 0;
                
                
                Decimal bo_total_cash = 0;
                Decimal bo_total_foc = 0;
                Decimal bo_total = 0;
                Decimal bo_foc = 0;
                Decimal bo_achievedBtl_foc = 0;
                Decimal bo_achievedBtl_cash = 0;
                Decimal bo_per_case_cash = 0;
                Decimal bo_per_case_foc = 0;
                
                for(ASI_CRM_ContractOtherIncentive__c otherIncentive : listOtherIncentive){
                    
                    SKU_description = otherIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c != null ? otherIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c : '';
                    
                    Decimal achievedBtl = otherIncentive.ASI_CRM_AchievedBtl__c != null ? otherIncentive.ASI_CRM_AchievedBtl__c : 0;
                    String sponsorship_type = otherIncentive.ASI_CRM_Type__c != null ? otherIncentive.ASI_CRM_Type__c : '';
                    Decimal cash = otherIncentive.ASI_CRM_CashInc__c != null ? otherIncentive.ASI_CRM_CashInc__c : 0;
                    Decimal total = otherIncentive.ASI_CRM_Total__c != null ? otherIncentive.ASI_CRM_Total__c : 0;
                    Decimal minSPBtl = otherIncentive.ASI_CRM_MinSPBtl__c != null ? otherIncentive.ASI_CRM_MinSPBtl__c : 0;
                    Decimal foc = otherIncentive.ASI_CRM_FOC__c != null ? otherIncentive.ASI_CRM_FOC__c : 0;
                    rsp_bottle = minSPBtl;
                    
                    if(sponsorship_type == 'Up Front'){
                       up_total += total;
                       if(cash > 0){
                            up_total_cash += cash;
                            up_achievedBtl_cash += achievedBtl;
                            up_per_case_cash += achievedBtl > 0 ? cash / (achievedBtl / 12) : 0;
                        }
                        else{
                            up_foc += foc;
                        	up_total_foc += (foc * minSPBtl);
                            up_achievedBtl_foc += achievedBtl;
                            up_per_case_foc += (foc * minSPBtl);
                        }
                    }     
                      
                    
                    if(sponsorship_type == 'Events Sponsors' || sponsorship_type == 'A&P Sponsorship'){
                        
                        set<id> setKSUIDs = new set<id>();
                        setKSUIDs.add(skuId);
                        
                        //Datetime last_revision_datetime =  otherIncentive.ASI_CRM_Contract__r.ASI_CRM_Last_Revision_Date__c;
                        //Date last_revision_date = date.newinstance(last_revision_datetime.year(), last_revision_datetime.month(), last_revision_datetime.day());
                        //map<id, decimal> map_total_foc = ASI_CRM_MY_Function.getSKUMinSP(setKSUIDs, last_revision_date, rtIGC);
                          
                        es_total += total;
                        if(cash > 0){
                            es_total_cash += cash;
                            es_achievedBtl_cash += achievedBtl;
                            es_per_case_cash += achievedBtl > 0 ? cash / (achievedBtl / 12) : 0;
                        }
                        else{
                            es_foc += foc;
                        	es_total_foc += (foc * minSPBtl);
                            es_achievedBtl_foc += achievedBtl;
                            es_per_case_foc += (foc * minSPBtl);
                        }
                    
                    }
                    
                    if(sponsorship_type == 'Anniversary' || sponsorship_type == 'Directors Birthday' || sponsorship_type == 'Official Opening'){
                          
                        set<id> setKSUIDs = new set<id>();
                        setKSUIDs.add(skuId);
                        
                        //Datetime last_revision_datetime =  otherIncentive.ASI_CRM_Contract__r.ASI_CRM_Last_Revision_Date__c;
                        //Date last_revision_date = date.newinstance(last_revision_datetime.year(), last_revision_datetime.month(), last_revision_datetime.day());
                        //map<id, decimal> map_total_foc = ASI_CRM_MY_Function.getSKUMinSP(setKSUIDs, last_revision_date, rtIGC);
                        so_total += total; 
                        if(cash > 0){
                            so_total_cash += cash;
                            so_achievedBtl_cash += achievedBtl;
                            so_per_case_cash += achievedBtl > 0 ? cash / (achievedBtl / 12) : 0;
                        }
                        else{
                            so_foc += foc;
                        	so_total_foc += (foc * minSPBtl);
                            so_achievedBtl_foc += achievedBtl;
                            so_per_case_foc += (foc * minSPBtl);
                        }     
                    }       
                    
                                    
                    if(sponsorship_type == 'Bonus'){
                        set<id> setKSUIDs = new set<id>();
                        setKSUIDs.add(skuId);
                        
                        //Datetime last_revision_datetime =  otherIncentive.ASI_CRM_Contract__r.ASI_CRM_Last_Revision_Date__c;
                        //Date last_revision_date = date.newinstance(last_revision_datetime.year(), last_revision_datetime.month(), last_revision_datetime.day());
                        //map<id, decimal> map_total_foc = ASI_CRM_MY_Function.getSKUMinSP(setKSUIDs, last_revision_date, rtIGC);
                        
                        bo_total += total; 
                        if(cash > 0){
                            bo_total_cash += cash;
                            bo_achievedBtl_cash += achievedBtl;
                            bo_per_case_cash += achievedBtl > 0 ? cash / (achievedBtl / 12) : 0;
                        }
                        else{
                            bo_foc += foc;
                        	bo_total_foc += (foc * minSPBtl);
                            bo_achievedBtl_foc += achievedBtl;
                            bo_per_case_foc += (foc * minSPBtl);
                        }
                    }
                }
                
                
                ContributionPerCaseTotal contributionPerCaseTotal;
                
                //Decimal up_total_cash_foc = up_total_cash + up_total_foc;
                up_total = up_total.setScale(2);
                grand_total += up_total;
                total_incentives_per_case += up_per_case_cash;
                contributionPerCaseTotal = new ContributionPerCaseTotal(up_per_case_cash, up_per_case_foc, up_foc, up_total);
                upfront = contributionPerCaseTotal;
                
                
                //Decimal es_total_cash_foc = es_total_cash + es_total_foc;
                es_total = es_total.setScale(2);
                grand_total += es_total;
                total_incentives_per_case += es_per_case_cash;   
                contributionPerCaseTotal = new ContributionPerCaseTotal(es_per_case_cash, es_per_case_foc, es_foc, es_total);
                eventsSponsorship = contributionPerCaseTotal;
                
                
                //Decimal so_total_cash_foc = so_total_cash + so_total_foc;
                so_total = so_total.setScale(2);
                grand_total += so_total;
                total_incentives_per_case += so_per_case_cash;
                contributionPerCaseTotal = new ContributionPerCaseTotal(so_per_case_cash, so_per_case_foc, so_foc, so_total);
                specialOccasions = contributionPerCaseTotal;
                
                
                //Decimal bo_total_cash_foc = bo_total_cash + bo_total_foc;
                bo_total = bo_total.setScale(2);
                grand_total += bo_total;
                total_incentives_per_case += bo_per_case_cash; 
                contributionPerCaseTotal = new ContributionPerCaseTotal(bo_per_case_cash, bo_per_case_foc, bo_foc, bo_total);
                bonus = contributionPerCaseTotal;
            }
            
            if(mapOfVolumeIncentiveContributionPerCase.containsKey(skuId)){
                
                ASI_CRM_ContractVolumeIncentive__c contractVolume = mapOfVolumeIncentiveContributionPerCase.get(skuId);
                if(SKU_description == null || SKU_description == ''){
                	SKU_description = contractVolume.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c != null ? contractVolume.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c : '';
                }
                Decimal achievedBtl = contractVolume.ASI_CRM_AchievedBtl__c != null ? contractVolume.ASI_CRM_AchievedBtl__c : 0;
            	Decimal cash = contractVolume.ASI_CRM_CashInc__c != null ? contractVolume.ASI_CRM_CashInc__c : 0;
                Decimal minSPBtl = contractVolume.ASI_CRM_MinSPBtl__c != null ? contractVolume.ASI_CRM_MinSPBtl__c : 0;
                
                rsp_bottle = minSPBtl;
                
                Decimal per_case_cash = achievedBtl > 0 ? cash / (achievedBtl / 12) : 0;
                per_case_cash = per_case_cash.round(System.RoundingMode.DOWN);
                Decimal per_case_foc = 0;
                
                grand_total += cash;
                total_incentives_per_case += per_case_cash; 
                ContributionPerCaseTotal contributionPerCaseTotal = new ContributionPerCaseTotal(per_case_cash, per_case_foc, 0, cash);
                volInc = contributionPerCaseTotal;
                
                
            }
			
			if(mapOfSalesStaffContributionPerCase.containsKey(skuId)){
                
                ASI_CRM_ContractSalesStaffIncentive__c salesIncentive = mapOfSalesStaffContributionPerCase.get(skuId);
                if(SKU_description == null || SKU_description == ''){
                	SKU_description = salesIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c != null ? salesIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c : '';
                }
                
                cross_brand_SKU_description = salesIncentive.ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c != null && salesIncentive.ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c != SKU_description ? salesIncentive.ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c: '';
                Decimal achievedBtl = salesIncentive.ASI_CRM_AchievedBtl__c != null ? salesIncentive.ASI_CRM_AchievedBtl__c : 0;
                Decimal focprm = salesIncentive.ASI_CRM_FOCPRM__c != null ? salesIncentive.ASI_CRM_FOCPRM__c : 0;
                focprm = (focprm / achievedBtl) * 12;
                focprm = focprm.setScale(2);
                Decimal focws = salesIncentive.ASI_CRM_FOCWS__c != null ? salesIncentive.ASI_CRM_FOCWS__c : 0;
                focws = (focws / achievedBtl) * 12;
                focws = focws.setScale(2);
                Decimal total_foc = focprm + focws;
				
				Decimal minSPBtl = salesIncentive.ASI_CRM_MinSPBtl__c != null ? salesIncentive.ASI_CRM_MinSPBtl__c : 0;
                
                rsp_bottle = minSPBtl;
				
                Decimal numOfBottleInCase = 12;
                
                trade_offer = total_foc;
                trade_offer = trade_offer.round(System.RoundingMode.DOWN);
                
                net_bottle = (minSPBtl * numOfBottleInCase) / (numOfBottleInCase + trade_offer);
                net_bottle = net_bottle.setScale(2, System.RoundingMode.UP);

                net_bot_after_inc = net_bottle - (total_incentives_per_case/numOfBottleInCase);
                net_bot_after_inc = net_bot_after_inc.setScale(2, System.RoundingMode.UP);
                
                quantity_t = total_foc;
                
            }
            
			price_per_case = rsp_bottle * 12;
            
            quantity_t_offer_bottles = purchase_target_cases * quantity_t;
            qty_trade_offer = quantity_t_offer_bottles / 12;
            qty_trade_offer = qty_trade_offer.round(System.RoundingMode.DOWN);
            offer_value = rsp_bottle * quantity_t_offer_bottles; 
            offer_value = offer_value.setScale(2);
            
            ContributionPerCase contributionPerCase = new ContributionPerCase(SKU_description, cross_brand_SKU_description, purchase_target_cases, purchase_value,
                                                                             upfront, volInc, eventsSponsorship,
                                                                             specialOccasions, bonus, grand_total,
                                                                             total_incentives_per_case, price_per_case, trade_offer,
                                                                             rsp_bottle, net_bottle, net_bot_after_inc,
                                                                             quantity_t_offer_bottles, offer_value, qty_trade_offer);
            
            
            mapOfContributionPerCase.put(skuId, contributionPerCase);
        }  
        
        
        l_mapOfContributionPerCase = new List<Map<Id, ContributionPerCase>>();
        Map<Id, ContributionPerCase> mapOfTempContributionPerCase = new Map<Id, ContributionPerCase>();
        mapOfTotal = new Map<String, Decimal>();
        Integer count = 1;
        for(String key : mapOfContributionPerCase.keySet()){
            
            ContributionPerCase contributionPerCase = mapOfContributionPerCase.get(key);
            mapOfTempContributionPerCase.put(key, contributionPerCase);
            if(mapOfContributionPerCase.size() == count){
                l_mapOfContributionPerCase.add(mapOfTempContributionPerCase);
            }
            else if(math.mod(count, 10) == 0){
                l_mapOfContributionPerCase.add(mapOfTempContributionPerCase);
                mapOfTempContributionPerCase = new Map<Id, ContributionPerCase>();
            }
            count++;
            
            
            Decimal purchase_target_cases = contributionPerCase.purchase_target_cases;
            Decimal total_purchase_target_cases = mapOfTotal.containsKey('total_purchase_target_cases') ? mapOfTotal.get('total_purchase_target_cases') : 0;
            total_purchase_target_cases += purchase_target_cases;
            mapOfTotal.put('total_purchase_target_cases', total_purchase_target_cases);
            
            Decimal purchase_value = contributionPerCase.purchase_value;
            Decimal total_purchase_value = mapOfTotal.containsKey('total_purchase_value') ? mapOfTotal.get('total_purchase_value') : 0;
            total_purchase_value += purchase_value;
            mapOfTotal.put('total_purchase_value', total_purchase_value);
            
            
            Decimal upfront_per_case_cash = contributionPerCase.upfront.per_case_cash;
            Decimal total_upfront_per_case_cash = mapOfTotal.containsKey('total_upfront_per_case_cash') ? mapOfTotal.get('total_upfront_per_case_cash') : 0;
            total_upfront_per_case_cash += upfront_per_case_cash;
            mapOfTotal.put('total_upfront_per_case_cash', total_upfront_per_case_cash);
            
            
            Decimal upfront_total = contributionPerCase.upfront.total;
            Decimal total_upfront_total = mapOfTotal.containsKey('total_upfront_total') ? mapOfTotal.get('total_upfront_total') : 0;
            total_upfront_total += upfront_total;
            mapOfTotal.put('total_upfront_total', total_upfront_total);
            
            Decimal volInc_per_case_cash = contributionPerCase.volInc.per_case_cash;
            Decimal total_volInc_per_case_cash = mapOfTotal.containsKey('total_volInc_per_case_cash') ? mapOfTotal.get('total_volInc_per_case_cash') : 0;
            total_volInc_per_case_cash += volInc_per_case_cash;
            mapOfTotal.put('total_volInc_per_case_cash', total_volInc_per_case_cash);
            
            Decimal volInc_total = contributionPerCase.volInc.total;
            Decimal total_volInc_total = mapOfTotal.containsKey('total_volInc_total') ? mapOfTotal.get('total_volInc_total') : 0;
            total_volInc_total += volInc_total;
            mapOfTotal.put('total_volInc_total', total_volInc_total);
            
            Decimal eventsSponsorship_per_case_cash = contributionPerCase.eventsSponsorship.per_case_cash;
            Decimal total_eventsSponsorship_per_case_cash = mapOfTotal.containsKey('total_eventsSponsorship_per_case_cash') ? mapOfTotal.get('total_eventsSponsorship_per_case_cash') : 0;
            total_eventsSponsorship_per_case_cash += eventsSponsorship_per_case_cash;
            mapOfTotal.put('total_eventsSponsorship_per_case_cash', total_eventsSponsorship_per_case_cash);
            
            Decimal eventsSponsorship_per_case_foc = contributionPerCase.eventsSponsorship.per_case_foc;
            Decimal total_eventsSponsorship_per_case_foc = mapOfTotal.containsKey('total_eventsSponsorship_per_case_foc') ? mapOfTotal.get('total_eventsSponsorship_per_case_foc') : 0;
            total_eventsSponsorship_per_case_foc += eventsSponsorship_per_case_foc;
            mapOfTotal.put('total_eventsSponsorship_per_case_foc', total_eventsSponsorship_per_case_foc);
            
            Decimal eventsSponsorship_total = contributionPerCase.eventsSponsorship.total;
            Decimal total_eventsSponsorship_total = mapOfTotal.containsKey('total_eventsSponsorship_total') ? mapOfTotal.get('total_eventsSponsorship_total') : 0;
            total_eventsSponsorship_total += eventsSponsorship_total;
            mapOfTotal.put('total_eventsSponsorship_total', total_eventsSponsorship_total);
            
            Decimal specialOccasions_per_case_cash = contributionPerCase.specialOccasions.per_case_cash;
            Decimal total_specialOccasions_per_case_cash = mapOfTotal.containsKey('total_specialOccasions_per_case_cash') ? mapOfTotal.get('total_specialOccasions_per_case_cash') : 0;
            total_specialOccasions_per_case_cash += specialOccasions_per_case_cash;
            mapOfTotal.put('total_specialOccasions_per_case_cash', total_specialOccasions_per_case_cash);
            
            Decimal specialOccasions_per_case_foc = contributionPerCase.specialOccasions.per_case_foc;
            Decimal total_specialOccasions_per_case_foc = mapOfTotal.containsKey('total_specialOccasions_per_case_foc') ? mapOfTotal.get('total_specialOccasions_per_case_foc') : 0;
            total_specialOccasions_per_case_foc += specialOccasions_per_case_foc;
            mapOfTotal.put('total_specialOccasions_per_case_foc', total_specialOccasions_per_case_foc);
            
            Decimal specialOccasions_total = contributionPerCase.specialOccasions.total;
            Decimal total_specialOccasions_total = mapOfTotal.containsKey('total_specialOccasions_total') ? mapOfTotal.get('total_specialOccasions_total') : 0;
            total_specialOccasions_total += specialOccasions_total;
            mapOfTotal.put('total_specialOccasions_total', total_specialOccasions_total);
            
            Decimal bonus_per_case_cash = contributionPerCase.bonus.per_case_cash;
            Decimal total_bonus_per_case_cash = mapOfTotal.containsKey('total_bonus_per_case_cash') ? mapOfTotal.get('total_bonus_per_case_cash') : 0;
            total_bonus_per_case_cash += bonus_per_case_cash;
            mapOfTotal.put('total_bonus_per_case_cash', total_bonus_per_case_cash);
            
            Decimal bonus_per_case_foc = contributionPerCase.bonus.per_case_foc;
            Decimal total_bonus_per_case_foc = mapOfTotal.containsKey('total_bonus_per_case_foc') ? mapOfTotal.get('total_bonus_per_case_foc') : 0;
            total_bonus_per_case_foc += bonus_per_case_foc;
            mapOfTotal.put('total_bonus_per_case_foc', total_bonus_per_case_foc);
            
            Decimal bonus_total = contributionPerCase.bonus.total;
            Decimal total_bonus_total = mapOfTotal.containsKey('total_bonus_total') ? mapOfTotal.get('total_bonus_total') : 0;
            total_bonus_total += bonus_total;
            mapOfTotal.put('total_bonus_total', total_bonus_total);
            
            Decimal grand_total = contributionPerCase.grand_total;
            Decimal total_grand_total = mapOfTotal.containsKey('total_grand_total') ? mapOfTotal.get('total_grand_total') : 0;
            total_grand_total += grand_total;
            mapOfTotal.put('total_grand_total', total_grand_total);
            
            Decimal total_incentives_per_case = contributionPerCase.total_incentives_per_case;
            Decimal total_total_incentives_per_case = mapOfTotal.containsKey('total_total_incentives_per_case') ? mapOfTotal.get('total_total_incentives_per_case') : 0;
            total_total_incentives_per_case += total_incentives_per_case;
            mapOfTotal.put('total_total_incentives_per_case', total_total_incentives_per_case);
            
            Decimal price_per_case = contributionPerCase.price_per_case;
            Decimal total_price_per_case = mapOfTotal.containsKey('total_price_per_case') ? mapOfTotal.get('total_price_per_case') : 0;
            total_price_per_case += price_per_case;
            mapOfTotal.put('total_price_per_case', total_price_per_case);
            
            Decimal trade_offer = contributionPerCase.trade_offer;
            Decimal total_trade_offer = mapOfTotal.containsKey('total_trade_offer') ? mapOfTotal.get('total_trade_offer') : 0;
            total_trade_offer += trade_offer;
            mapOfTotal.put('total_trade_offer', total_trade_offer);
            
            Decimal rsp_bottle = contributionPerCase.rsp_bottle;
            Decimal total_rsp_bottle = mapOfTotal.containsKey('total_rsp_bottle') ? mapOfTotal.get('total_rsp_bottle') : 0;
            total_rsp_bottle += rsp_bottle;
            mapOfTotal.put('total_rsp_bottle', total_rsp_bottle);
            
            Decimal net_bottle = contributionPerCase.net_bottle;
            Decimal total_net_bottle = mapOfTotal.containsKey('total_net_bottle') ? mapOfTotal.get('total_net_bottle') : 0;
            total_net_bottle += net_bottle;
            mapOfTotal.put('total_net_bottle', total_net_bottle);
            
            Decimal net_bot_after_inc = contributionPerCase.net_bot_after_inc;
            Decimal total_net_bot_after_inc = mapOfTotal.containsKey('total_net_bot_after_inc') ? mapOfTotal.get('total_net_bot_after_inc') : 0;
            total_net_bot_after_inc += net_bot_after_inc;
            mapOfTotal.put('total_net_bot_after_inc', total_net_bot_after_inc);
            
            Decimal quantity_t = contributionPerCase.quantity_t;
            Decimal total_quantity_t = mapOfTotal.containsKey('total_quantity_t') ? mapOfTotal.get('total_quantity_t') : 0;
            total_quantity_t += quantity_t;
            mapOfTotal.put('total_quantity_t', total_quantity_t);
            
            Decimal offer_value = contributionPerCase.offer_value;
            Decimal total_offer_value = mapOfTotal.containsKey('total_offer_value') ? mapOfTotal.get('total_offer_value') : 0;
            total_offer_value += offer_value;
            mapOfTotal.put('total_offer_value', total_offer_value);
            
            Decimal qty_trade_offer = contributionPerCase.qty_trade_offer;
            Decimal total_qty_trade_offer = mapOfTotal.containsKey('total_qty_trade_offer') ? mapOfTotal.get('total_qty_trade_offer') : 0;
            total_qty_trade_offer += qty_trade_offer;
            mapOfTotal.put('total_qty_trade_offer', total_qty_trade_offer);
            
            
        }
        

        return true;

	}  
    
}