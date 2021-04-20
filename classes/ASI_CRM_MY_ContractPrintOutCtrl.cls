public class ASI_CRM_MY_ContractPrintOutCtrl {

    public Id contractId {get; set;}
    public Id ownerId {get; set;}
    //public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_TH_CRM_Contract__c contractInfo {get;set;}
    public Integer totalContractMonths{get; private set;}
    public User ownerInfo {get;set;}
    public ASI_CRM_AccountsAdditionalField__c parentOutlet {get;private set;}
    public Map<String, List<SalesTargetObj>> mapOfContractTarget {get;private set;}
    public Map<String, List<SalesIncentiveObj>> mapOfSalesIncentive {get;private set;}
    public Map<String, List<VolumeIncentiveObj>> mapOfVolumeIncentive {get;private set;}
    public Map<String, List<OtherIncentiveObj>> mapOfAPOtherIncentive {get;private set;}
    public Map<String, List<OtherIncentiveObj>> mapOfSOotherIncentive {get;private set;}
    public boolean isDisplaySOotherIncentive {get;private set;}{isDisplaySOotherIncentive = false;}
    
    
    public Boolean isParentOutlet {get; private set;}{isParentOutlet = false;}
    public List<ASI_CRM_AccountsAdditionalField__c> promotionOutlets {get; private set;}{promotionOutlets = new list<ASI_CRM_AccountsAdditionalField__c>();}

    //Summary Info
    public Decimal salesTarget_totalCase {get; private set;}{salesTarget_totalCase=0;}
    public Decimal saleInc_totalFOCWSBtl {get; private set;}{saleInc_totalFOCWSBtl=0;}
    public Decimal saleInc_totalFOCPRMBtl {get; private set;}{saleInc_totalFOCPRMBtl=0;}
    public Decimal volInc_totalAchievedBtl {get; private set;}{volInc_totalAchievedBtl=0;}
    public Decimal volInc_totalCashPerCase {get; private set;}{volInc_totalCashPerCase=0;}
    public Decimal volInc_totalCash {get; private set;}{volInc_totalCash=0;}
    public Decimal otherAPInc_achivedCase {get; private set;}{otherAPInc_achivedCase=0;}
    public Decimal otherAPInc_totalFOC {get; private set;}{otherAPInc_totalFOC=0;}
    public Decimal otherAPInc_totalCashPerCase {get; private set;}{otherAPInc_totalCashPerCase=0;}
    public Decimal otherAPInc_totalCash {get; private set;}{otherAPInc_totalCash=0;}
    public Decimal otherSOInc_totalCash {get; private set;}{otherSOInc_totalCash=0;}
    public Decimal otherSOInc_totalFOC {get; private set;}{otherSOInc_totalFOC=0;}

    
    
    
    public ASI_CRM_MY_ContractPrintOutCtrl(){
        contractId = ApexPages.currentPage().getParameters().get('id');
        init();
    }
    
    public ASI_CRM_MY_ContractPrintOutCtrl(ApexPages.StandardController controller) {
        this.contractInfo = (ASI_TH_CRM_Contract__c)controller.getRecord();
        contractId = controller.getId();
        //contractId = ApexPages.currentPage().getParameters().get('id');
    }
    
    
    //Contract Target
    public class SalesTargetObj {
        public String sku_description {get; set;}
        public String packFactor {get; set;}
        public Decimal targetCase {get; set;}
        public Decimal packagingSize {get; set;}
        public Decimal salesTarget_dozenCase  {get; set;}
        
        public SalesTargetObj(ASI_CRM_ContractTarget__c salesTarget){
            sku_description = salesTarget.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c;
            packFactor = salesTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Pack_Factor__c != null ? salesTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Pack_Factor__c : '';
            targetCase = salesTarget.ASI_CRM_TargetCase__c != null ? salesTarget.ASI_CRM_TargetCase__c : 0;
            packagingSize = salesTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c != null ? salesTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c : 0;
            salesTarget_dozenCase = (targetCase * packagingSize) / 12; 
            //salesTarget_dozenCase = salesTarget_dozenCase.round(System.RoundingMode.DOWN);
			salesTarget_dozenCase = salesTarget_dozenCase.setscale(1);
        }  
    }
    
    
    public class SalesIncentiveObj {
        public String sku_description {get; set;}
        public String crossbrand_sku_description {get; set;}
        public Decimal AchievedBtl {get; set;}
        public Decimal FOCWS {get; set;}
        public Decimal FOCPRM {get; set;}
        public Decimal totalFOC {get; set;}
        public Decimal FOCWS_dozen {get; set;}
        public Decimal FOCPRM_dozen {get; set;}
        
        public SalesIncentiveObj(ASI_CRM_ContractSalesStaffIncentive__c salesIncentive){
            sku_description = salesIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c;
            crossbrand_sku_description = (salesIncentive.ASI_CRM_CrossBrandSKU__c ==null || salesIncentive.ASI_CRM_CrossBrandSKU__c==salesIncentive.ASI_CRM_SKU__c)  ? 'Same As Target' : salesIncentive.ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c;
            AchievedBtl = salesIncentive.ASI_CRM_AchievedBtl__c;
            FOCWS = salesIncentive.ASI_CRM_FOCWS__c != null ? salesIncentive.ASI_CRM_FOCWS__c : 0;
            FOCPRM = salesIncentive.ASI_CRM_FOCPRM__c != null ? salesIncentive.ASI_CRM_FOCPRM__c : 0;
            //Decimal factor = AchievedBtl / 12;
            //FOCWS_dozen = ( FOCWS / 12 ) * factor;
            FOCWS_dozen = AchievedBtl==0? 0: (FOCWS *12) /AchievedBtl ;
            //FOCWS_dozen = FOCWS_dozen.round(System.RoundingMode.DOWN);
            FOCWS_dozen = FOCWS_dozen.setscale(1);
            //FOCPRM_dozen = ( FOCPRM / 12 ) * factor;
            FOCPRM_dozen = AchievedBtl == 0 ? 0 :(FOCPRM *12) /AchievedBtl ;
            //FOCPRM_dozen = FOCPRM_dozen.round(System.RoundingMode.DOWN);
            FOCPRM_dozen = FOCPRM_dozen.setscale(1);
            totalFOC = FOCWS + FOCPRM;
        }  
    }
    

    public class VolumeIncentiveObj {
        public String sku_description {get; set;}
        public Decimal achievedBtl {get; set;}
        public Decimal achievedBtl_dozenCase {get; set;}
        public Decimal cashInc {get; set;}
        public Decimal cashInc_dozenCase {get; set;}
        
        public VolumeIncentiveObj(ASI_CRM_ContractVolumeIncentive__c volumeIncentive){
            sku_description = volumeIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c;
            achievedBtl = volumeIncentive.ASI_CRM_AchievedBtl__c != null ? volumeIncentive.ASI_CRM_AchievedBtl__c : 0;
            achievedBtl_dozenCase = achievedBtl / 12;
            //achievedBtl_dozenCase = achievedBtl_dozenCase.round(System.RoundingMode.DOWN);
            achievedBtl_dozenCase = achievedBtl_dozenCase.setscale(1);
            cashInc = volumeIncentive.ASI_CRM_CashInc__c != null ? volumeIncentive.ASI_CRM_CashInc__c : 0;
            //cashInc_dozenCase = cashInc / 12;
            cashInc_dozenCase = achievedBtl == 0 ? 0: (cashInc *12) /achievedBtl;
            // cashInc_dozenCase = cashInc_dozenCase.round(System.RoundingMode.DOWN);
            cashInc_dozenCase = cashInc_dozenCase.setscale(2);
        }  
    }
    

    public class OtherIncentiveObj {
        public String sku_description {get; set;}
        public Decimal AchievedBtl {get; set;}
        public Decimal achievedBtl_dozenCase {get; set;}
        public String contract_item_description {get; set;}
        public Decimal FOC {get; set;}
        public Decimal FOC_dozen{get;set;}
        public Decimal CashInc {get; set;}
        public Decimal CashInc_dozen {get; set;}
        public Decimal total {get; set;}
        
        public OtherIncentiveObj(ASI_CRM_ContractOtherIncentive__c otherIncentive){
            sku_description = otherIncentive.ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c;
            AchievedBtl = otherIncentive.ASI_CRM_AchievedBtl__c != null ? otherIncentive.ASI_CRM_AchievedBtl__c : 0;
            achievedBtl_dozenCase = AchievedBtl / 12;
            //achievedBtl_dozenCase = achievedBtl_dozenCase.round(System.RoundingMode.DOWN);
            achievedBtl_dozenCase = achievedBtl_dozenCase.setscale(1);
            FOC = otherIncentive.ASI_CRM_FOC__c != null ? otherIncentive.ASI_CRM_FOC__c : 0;
            FOC = FOC.setscale(1);
            FOC_dozen = AchievedBtl==0?0: (12 * FOC) / AchievedBtl;
            // FOC_dozen = FOC_dozen.round(System.RoundingMode.DOWN);
            FOC_dozen = FOC_dozen.setscale(1);
            CashInc = otherIncentive.ASI_CRM_CashInc__c != null ? otherIncentive.ASI_CRM_CashInc__c : 0;
            CashInc = CashInc.setscale(2);
            //CashInc_dozen = CashInc / 12; 
            CashInc_dozen = AchievedBtl==0? 0:(CashInc * 12)/AchievedBtl;
            //CashInc_dozen = CashInc_dozen.round(System.RoundingMode.DOWN);
            CashInc_dozen = CashInc_dozen.setscale(2);
            //total = otherIncentive.ASI_CRM_Total__c != null ? otherIncentive.ASI_CRM_Total__c : 0;
            total = CashInc;
            contract_item_description = otherIncentive.ASI_CRM_Description__c != null ? otherIncentive.ASI_CRM_Description__c : '';
        }
    }
    
    

    
    public boolean init() {
        
      
        getContractInfo();
        getSalesTarget();
        getSalesIncentive();
        getVolumeIncentive();
        getOtherIncentive();
        getOwnerContact();
        getPromotionOutlets();
        
        totalContractMonths =  contractInfo.ASI_TH_CRM_Start_Date__c.monthsBetween(contractInfo.ASI_TH_CRM_End_Date__c)+1;
        return true;
    }
    
    
    public void getContractInfo(){
        ASI_TH_CRM_Contract__c contractInfo = 
            [SELECT 
             Id, Name,ASI_CRM_CN_Outlet_WS__c,ASI_CRM_CN_Outlet_WS__r.Name,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Address__c,
             ASI_CRM_CN_Outlet_WS__r.ASI_CRM_IsParentAccount__c,OwnerId, ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Parent_Outlet__c,
             ASI_CRM_MY_Contact_Name__c,ASI_CRM_MY_Contact_Salutation__c,ASI_CRM_MY_Contact_Approver_Name__c,ASI_CRM_MY_Contact_Approver_Title__c, ASI_CRM_MY_Contact_Title__c,
             ASI_CRM_MY_Proposal_Date__c, ASI_CRM_MY_Show_APInc_CustomerObligation__c,ASI_CRM_MY_Show_StaffInc_CustObligation__c,ASI_CRM_MY_Show_StaffIncentiveSection__c,
             ASI_CRM_MY_StaffInc_CustomerObligation__c,ASI_CRM_MY_UpfrontIncentive_Term__c,ASI_CRM_MY_VolumeIncentive_PaymentTerm__c,ASI_CRM_MY_VisibilitySponsorObligation__c,
             ASI_CRM_MY_ShowVisiSponsorObligation__c,ASI_CRM_MY_VisibilitySponsorContent__c,ASI_CRM_MY_Show_VisibilitySponSection__c,ASI_CRM_MY_UpfrontInc_TermOption__c,
             ASI_CRM_MY_APIncentive_PaymentTerm__c,ASI_CRM_MY_APInc_CustomerObligation__c,ASI_CRM_MY_Trade_Offer_List__c ,
             ASI_CRM_CN_Outlet_WS__r.ASI_CRM_PostalCode__c, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_City__r.name,  ASI_CRM_CN_Outlet_WS__r.ASI_CRM_Province__c  // [SH] 2018-11-26
             FROM ASI_TH_CRM_Contract__c 
             WHERE Id = :contractId
             LIMIT 1];  
        
        ownerId = contractInfo.OwnerId;
        this.contractInfo = contractInfo;


        isParentOutlet = contractInfo.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_IsParentAccount__c;
        
        
         
    }
    
    public void getPromotionOutlets(){
        
        promotionOutlets = [SELECT Id, Name, ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_Bank__c,ASI_CRM_MY_BranchOpt__c,ASI_CRM_CN_Address__c FROM ASI_CRM_AccountsAdditionalField__c WHERE (ASI_CRM_CN_Parent_Outlet__c =:contractInfo.ASI_CRM_CN_Outlet_WS__c OR Id=:contractInfo.ASI_CRM_CN_Outlet_WS__c) ORDER BY ASI_CRM_CN_Legal_Name__c];

    }
    
    public void getParentInfo(){
        
    }
    
    
    public void getSalesTarget(){
        List<ASI_CRM_ContractTarget__c> listOfContractTarget = 
            [SELECT 
             Id, 
             Name, 
             ASI_CRM_SKU__c,
             ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
             ASI_CRM_SKU__r.ASI_HK_CRM_Packaging_Size__c,
             ASI_CRM_SKU__r.ASI_HK_CRM_Pack_Factor__c,
             ASI_CRM_TargetCase__c,
             ASI_CRM_MinSPCase__c,
             ASI_CRM_Total__c,
             ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__c,
             ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name
             FROM  ASI_CRM_ContractTarget__c 
             WHERE ASI_CRM_Contract__c = :contractId
             ORDER BY ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c
             LIMIT 1000];
        
        Map<String, List<SalesTargetObj>> contractTargetMap = new Map<String, List<SalesTargetObj>>();
        for(ASI_CRM_ContractTarget__c contractTarget : listOfContractTarget){
            String productCategory = contractTarget.ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name;
            SalesTargetObj salesTargetObj = new SalesTargetObj(contractTarget);
            List<SalesTargetObj> contractTargetList = contractTargetMap.get(productCategory) != null ? contractTargetMap.get(productCategory) : new List<SalesTargetObj>();
            contractTargetList.add(salesTargetObj);
            contractTargetMap.put(productCategory, contractTargetList);

            salesTarget_totalCase+=salesTargetObj.salesTarget_dozenCase;
        }
        
        this.mapOfContractTarget = contractTargetMap;
    }
    
    
    public void getSalesIncentive(){
        
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
                ASI_CRM_CrossBrandSKU__c,
             	ASI_CRM_CrossBrandSKU__r.ASI_MFM_SKU_Description__c,
                ASI_CRM_Packaging_Size__c, 
                ASI_CRM_AchievedBtl__c, 
                ASI_CRM_FOCPRM__c,
                ASI_CRM_FOCWS__c,
                ASI_CRM_Contract__r.ASI_TH_CRM_Start_Date__c, 
                ASI_CRM_Contract__r.ASI_TH_CRM_End_Date__c,
                ASI_CRM_SetupCode__c,
                ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
                ASI_CRM_CrossBrandSKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
                ASI_CRM_JDECOA__c 
            FROM ASI_CRM_ContractSalesStaffIncentive__c
            WHERE ASI_CRM_Contract__c = :contractId
            AND ASI_CRM_AchievedBtl__c > 0
            AND (ASI_CRM_FOCPRM__c > 0 OR ASI_CRM_FOCWS__c > 0)
            ORDER BY ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c];
        
        Map<String, List<SalesIncentiveObj>> salesIncentiveMap = new Map<String, List<SalesIncentiveObj>>();
        
        for(ASI_CRM_ContractSalesStaffIncentive__c salesIncentive : listOfSalesIncentive){
            SalesIncentiveObj salesIncentiveObj = new SalesIncentiveObj(salesIncentive);
            
            String productCategory = salesIncentive.ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name;
            List<SalesIncentiveObj> salesIncentiveList = salesIncentiveMap.get(productCategory) != null ? salesIncentiveMap.get(productCategory) : new List<SalesIncentiveObj>();
            salesIncentiveList.add(salesIncentiveObj);
            salesIncentiveMap.put(productCategory, salesIncentiveList);

            SaleInc_totalFOCWSBtl+=salesIncentiveObj.FOCWS_dozen;
            SaleInc_totalFOCPRMBtl+=salesIncentiveObj.FOCPRM_dozen;
            
        }
        
        this.mapOfSalesIncentive = salesIncentiveMap;
        
    }
    

    public void getVolumeIncentive(){ 
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
            ASI_CRM_Total__c,
            ASI_CRM_FOC__c, 
            ASI_CRM_AchievedBtl__c,
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_MY_CustomerCode__c,
            ASI_CRM_Contract__r.Name, 
            ASI_CRM_Contract__r.ASI_CRM_CN_Outlet_WS__r.Name,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
            ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
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
            ASI_CRM_Packaging_Size__c
            FROM  ASI_CRM_ContractVolumeIncentive__c
            WHERE ASI_CRM_Contract__c = :contractId
            AND ASI_CRM_AchievedBtl__c > 0
            AND ASI_CRM_CashInc__c > 0
            ORDER BY ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c];
        
        Map<String, List<VolumeIncentiveObj>> volumeIncentiveMap = new Map<String, List<VolumeIncentiveObj>>();
        for(ASI_CRM_ContractVolumeIncentive__c volumeIncentive : listOfContractVolume){
            VolumeIncentiveObj volumeIncentiveObj = new VolumeIncentiveObj(volumeIncentive);
            String productCategory = volumeIncentive.ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name;
            List<VolumeIncentiveObj> volumeIncentiveList = volumeIncentiveMap.get(productCategory) != null ? volumeIncentiveMap.get(productCategory) : new List<VolumeIncentiveObj>();
            volumeIncentiveList.add(volumeIncentiveObj);
            volumeIncentiveMap.put(productCategory, volumeIncentiveList);

            volInc_totalAchievedBtl += volumeIncentiveObj.achievedBtl_dozenCase;
            volInc_totalCashPerCase +=volumeIncentiveObj.cashInc_dozenCase;
            volInc_totalCash +=volumeIncentiveObj.cashInc;

        }
        
        this.mapOfVolumeIncentive = volumeIncentiveMap;
    }
    
    
    public void getOtherIncentive(){
        List<ASI_CRM_ContractOtherIncentive__c> listOfOtherIncentive = 
            [SELECT 
             id,
             ASI_CRM_FOC__c,
             ASI_CRM_Total__c,
             ASI_CRM_CashInc__c,
             ASI_CRM_SetupCode__c,
             ASI_CRM_Description__c,
             ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c,
             ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c, ASI_CRM_AchievedBtl__c,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.id,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_MFM_SKU_Description__c,
             ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_HK_CRM_Product_Category__r.Name,
             ASI_CRM_Type__c 
             FROM ASI_CRM_ContractOtherIncentive__c
             WHERE ASI_CRM_Contract__c = :contractId 
             AND (ASI_CRM_FOC__c > 0 OR ASI_CRM_CashInc__c > 0)
             ORDER BY ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_HK_CRM_Product_Category__r.Name, ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name, ASI_CRM_SKU__r.ASI_MFM_SKU_Description__c];
        
        Map<String, List<OtherIncentiveObj>> APotherIncentiveMap = new Map<String, List<OtherIncentiveObj>>();
        Map<String, List<OtherIncentiveObj>> SOotherIncentiveMap = new Map<String, List<OtherIncentiveObj>>();
        
        for(ASI_CRM_ContractOtherIncentive__c otherIncentive : listOfOtherIncentive){
            String productCategory = '';
            if(otherIncentive.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__c != null){
                productCategory = otherIncentive.ASI_CRM_SKU__r.ASI_CRM_SKU_Group__r.ASI_CRM_Effective_SKU__r.ASI_HK_CRM_Product_Category__r.Name;
            }
            else{
                productCategory = otherIncentive.ASI_CRM_SKU__r.ASI_HK_CRM_Product_Category__r.Name;
            }
            OtherIncentiveObj otherIncentiveObj = new OtherIncentiveObj(otherIncentive);
            if((otherIncentive.ASI_CRM_SetupCode__c == 'SPON' || otherIncentive.ASI_CRM_SetupCode__c == 'SSEC') && (otherIncentive.ASI_CRM_Type__c == 'A&P Sponsorship' || otherIncentive.ASI_CRM_Type__c == 'Events Sponsors')){
               
                List<OtherIncentiveObj> otherIncentiveList = APotherIncentiveMap.get(productCategory) != null ? APotherIncentiveMap.get(productCategory) : new List<OtherIncentiveObj>();
                otherIncentiveList.add(otherIncentiveObj);
                APotherIncentiveMap.put(productCategory, otherIncentiveList);

                otherAPInc_achivedCase += otherIncentiveObj.achievedBtl_dozenCase;
                otherAPInc_totalFOC += otherIncentiveObj.FOC_dozen;
                otherAPInc_totalCashPerCase += otherIncentiveObj.CashInc_dozen;
                otherAPInc_totalCash += otherIncentiveObj.CashInc;
            }
            else if(otherIncentive.ASI_CRM_Type__c == 'Anniversary' || otherIncentive.ASI_CRM_Type__c == 'Directors Birthday' || otherIncentive.ASI_CRM_Type__c == 'Official Opening'){
                List<OtherIncentiveObj> SOotherIncentiveList = SOotherIncentiveMap.get(productCategory) != null ? SOotherIncentiveMap.get(productCategory) : new List<OtherIncentiveObj>();
                SOotherIncentiveList.add(otherIncentiveObj);
                SOotherIncentiveMap.put(productCategory, SOotherIncentiveList);

                otherSOInc_totalFOC +=otherIncentiveObj.FOC;
                otherSOInc_totalCash +=otherIncentiveObj.CashInc;
            }
        }
        
        this.mapOfAPOtherIncentive = APotherIncentiveMap;
        this.mapOfSOotherIncentive= SOotherIncentiveMap;
        isDisplaySOotherIncentive = SOotherIncentiveMap.isEmpty() ? false : true; 
    }
    
    public void getOwnerContact(){
        
        ownerInfo = 
            [Select 
             Name, 
             Title, 
             Email,
             Phone 
             From User
             Where id =: ownerId
             LIMIT 1];
        
        
    }
    
}