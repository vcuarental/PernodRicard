/**************************************************************************************************
 * Name: ASI_CRM_CN_TP_BudgetPlanUpload
 * Object: ASI_MFM_Plan__c
 * Purpose: 
 * Author:  (jack yuan)
 * Create Date: 2020-3-17
 * Modify History:
 * 2020-3-17        Create this class
 **************************************************************************************************/
public without sharing class ASI_CRM_CN_TP_BudgetPlanUpload {

    public String errorHeader {get; set;}
    public List<String> bpHeaderSet{get; set;}
    public String bpListViewURL {get; set;}
    public String bpHeader {get; set;}
    public String bpBody {get; set;}


	private static final String BPRTID = Global_RecordTypeCache.getRtId('ASI_MFM_Plan__cASI_CRM_CN_TP_Budget_Plan');
    
    public ASI_CRM_CN_TP_BudgetPlanUpload() {
        ASI_CRM_CN_CustomSetting__c tpSetting = ASI_CRM_CN_CustomSetting__c.getInstance();
        bpHeaderSet = tpSetting.ASI_CRM_CN_TP_BP_Table_Header__c.split(',');
        errorHeader = tpSetting.ASI_CRM_CN_TP_BP_Table_Error_Header__c;
        bpHeader = tpSetting.ASI_CRM_CN_TP_BP_Table_Header__c;
        bpBody = tpSetting.ASI_CRM_CN_TP_BP_Table_Body__c;
        bpListViewURL = listViewURL(prefixList(),'ASI_MFM_Plan__c','CN Budget Plan');
    }

    public Map<String,String> prefixList(){
           Map<String,String> PrefixList = new Map<String,String>{};
           Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
           for(String sObj : gd.keySet()){
               Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
               PrefixList.put(r.getName(), r.getKeyPrefix());
           }
           return PrefixList;
    } 

    public String listViewURL(Map<String,String> PrefixList,String ObjectName,String ListViewLabel){
           String ListViewURL;
           String ListViewId;
           String q = 'SELECT Name FROM '+ ObjectName +' LIMIT 1';
           ApexPages.StandardSetController ACC = new ApexPages.StandardSetController(Database.getQueryLocator(q));
           List<SelectOption> ListViews = ACC.getListViewOptions();
           for(SelectOption w : ListViews ){
               if(w.getLabel()==ListViewLabel){
                   ListViewId = w.getValue().left(15);
                   ListViewURL='/'+PrefixList.get(ObjectName)+'?fcf='+ListViewId;
               }
           }
           return ListViewURL;
    }

     @RemoteAction
    public static List<List<String>> downloadOutlets(){
        List<List<String>> planOutlets = new List<List<String>>();
        List<String> csvHeader = new List<String>{'KA Banner'};
        planOutlets.add(csvHeader);
        Set<String> kaBannerSet = new Set<String>();
        for (ASI_CRM_AccountsAdditionalField__c kaBanner : [SELECT ASI_CRM_CN_TP_KA_Banner__c
                                                                  FROM ASI_CRM_AccountsAdditionalField__c
                                                                  WHERE RecordType.DeveloperName = 'ASI_CRM_Outlet_CN'
                                                                  AND ASI_CRM_CN_TP_KA_Banner__c != null
                                                                  AND ASI_CRM_Active__c = true
                                                                  AND ASI_CRM_CN_Inactive_Flag__c = false
                                                                  AND ASI_CRM_CN_TP_Dummy_Outlet__c = true
                                                                  ORDER BY ASI_CRM_CN_TP_KA_Banner__c
                                                                  LIMIT 50000]) {
            kaBannerSet.add(kaBanner.ASI_CRM_CN_TP_KA_Banner__c);
        }
        for (String kaBanner : kaBannerSet) {
            List<String> csvBody = new List<String>{kaBanner};
            planOutlets.add(csvBody);
        }
        return planOutlets;
    }

    @RemoteAction
    public static Map<String, Object> checkUploadData(String input){
        Map<String, object> inputMap = (Map<String, object>)JSON.deserializeUntyped(input);
        Map<String, object> result = new Map<String, object>();
        
        String kaAccount = (String)inputMap.get('kaAccount');
        String kaAccId = '';
        List<ASI_CRM_AccountsAdditionalField__c> kaBannerList = [SELECT ASI_CRM_CN_TP_KA_Banner__c
            		                                             FROM ASI_CRM_AccountsAdditionalField__c
            		                                             WHERE ASI_CRM_CN_TP_KA_Banner__c = :kaAccount
                                                                 LIMIT 1];
		if (kaBannerList.size() == 1) {
			result.put('kaAccount', kaBannerList[0].ASI_CRM_CN_TP_KA_Banner__c);
            // kaAccId = kaBannerList[0].Id;

		} else if (kaBannerList.size() == 0){
        	result.put('kaAccount', '');
        }

        String fiscalYear = (String)inputMap.get('fiscalYear');
        String currentFiscalYear = Date.today().month() < 7 
        						   ? 'FY' + (Date.today().year() - 2001) + (Date.today().year() - 2000)
        						   : 'FY' + (Date.today().year() - 2000) + (Date.today().year() - 1999);
        if (fiscalYear != null && Integer.valueOf(fiscalYear.substring(2)) >= Integer.valueOf(currentFiscalYear.substring(2)) ) {
        	result.put('fiscalYear', fiscalYear);
        } else {
        	result.put('fiscalYear', 'errorYear');
        }
        String bpKey = 'BP-' + kaAccount + '-' + fiscalYear;                
        result.put('duplicateBP', bpKey);

        try {
            String bpAmtStr = (String)inputMap.get('budgetAmount');
            System.debug(LoggingLevel.INFO, '*** bpAmtStr1: ' + bpAmtStr);
            if (!String.isBlank(bpAmtStr)) {
                bpAmtStr = bpAmtStr.contains(',') ? bpAmtStr.replace(',','').trim() : bpAmtStr.trim();
                System.debug(LoggingLevel.INFO, '*** bpAmtStr: ' + bpAmtStr);
                Decimal bpAmount = Decimal.valueOf(bpAmtStr);
                bpKey = 'BP-' + kaAccount + '-' + fiscalYear;                
                List<ASI_MFM_Plan__c> bps = [SELECT ASI_CRM_CN_TP_Estimated_Amount__c FROM ASI_MFM_Plan__c WHERE ASI_CRM_CN_TP_External_ID__c = :bpKey LIMIT 1];
                if (!bps.isEmpty() && bpAmount < bps[0].ASI_CRM_CN_TP_Estimated_Amount__c) {
                    result.put('BPAmount', 'invalid');
                } else {
                    result.put('BPAmount', 'success');
                }
            }
            
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            result.put('BPAmount', 'error');
        }

        return result;
    }

    @RemoteAction
    public static List<ASI_MFM_Plan__c> saveData(String BPJson){
        System.debug(LoggingLevel.INFO, '*** BPJson: ' + BPJson);
        Map<String, ASI_MFM_Prefix__c> prefixMap = new Map<String, ASI_MFM_Prefix__c>();
        List<ASI_MFM_Prefix__c> prefixlist = [SELECT Id, Name,ASI_MFM_Fiscal_year__c 
                                              FROM ASI_MFM_Prefix__c 
                                              WHERE Name = 'CN Budget Plan'];
        for (ASI_MFM_Prefix__c pre : prefixlist) {
            prefixMap.put(pre.ASI_MFM_Fiscal_year__c, pre);
        }
        List<BudgetPlan> plans = (List<BudgetPlan>)JSON.deserialize(BPJson, List<BudgetPlan>.class);
        Map<String, ASI_MFM_Plan__c> insertPlanMap = new Map<String, ASI_MFM_Plan__c>();
        for (BudgetPlan plan : plans) {
        	ASI_MFM_Plan__c newPlan = new ASI_MFM_Plan__c();
        	newPlan.RecordTypeId = BPRTID;
        	newPlan.ASI_MFM_Prefix__c = prefixMap.get(plan.fiscalYear) != null ? prefixMap.get(plan.fiscalYear).Id : null;
            newPlan.ASI_MFM_Status__c = ASI_CRM_CN_TP_Utils.TPSTATUSFINAL;
        	newPlan.ASI_CRM_CN_TP_External_ID__c = 'BP' + '-' + plan.kaAccount + '-' + plan.fiscalYear;
        	newPlan.ASI_CRM_CN_TP_KA_Banner__c = plan.kaAccount;
            // newPlan.ASI_CRM_CN_TP_Channel__c = plan.channelId;
            // newPlan.ASI_CRM_CN_TP_Region__c = plan.regionId;
        	newPlan.ASI_MFM_Fiscal_year__c = plan.fiscalYear;
        	// newplan.ASI_CRM_CN_TP_Customer__c = plan.customerId;
        	newPlan.ASI_MFM_Budget_Amount__c = Decimal.valueOf(plan.budgetAmount.replace(',', ''));
            newPlan.ASI_CRM_CN_TP_LY_Amount__c = Decimal.valueOf(plan.LYAmount.replace(',', ''));
            newPlan.ASI_CRM_CN_TP_LY_Cont_Margin_Amount__c = Decimal.valueOf(plan.LYContMarginAmount.replace(',', ''));
            newPlan.ASI_CRM_CN_TP_LY_Gross_Sales_Amount__c = Decimal.valueOf(plan.LYGrossSalesAmount.replace(',', ''));
            newPlan.ASI_CRM_CN_TP_LY_DM_Display_Amount__c = Decimal.valueOf(plan.LYDMDisplayAmount.replace(',', ''));
        	newPlan.ASI_CRM_CN_TP_LY_Promotion_Vol__c = Decimal.valueOf(plan.LYPromotionVol.replace(',', ''));
        	newplan.ASI_MFM_Budget_Owner__c = UserInfo.getUserId();
            newplan.ASI_MFM_Plan_Description__c = plan.note;
        	insertPlanMap.put(newPlan.ASI_CRM_CN_TP_External_ID__c, newPlan);
        }
        if (!insertPlanMap.isEmpty()) {
            upsert insertPlanMap.values() ASI_CRM_CN_TP_External_ID__c;
        }
        
        return insertPlanMap.values();
    }

    public class BudgetPlan {
        public Integer index;       
        public Boolean show;    
        public List<String> errors;
        public String selected;
        public Boolean loading; 
        public String status;
        public String kaAccId;
        public String channelId;
        public String regionId;
        public String kaAccount;
        public String customerId;
        public String fiscalYear;
        public String budgetAmount;
        public String LYAmount;
        public String LYContMarginAmount;
        public String LYDMDisplayAmount;
        public String LYGrossSalesAmount;
        public String LYPromotionVol;
        public String budgetOwner;
        public String budgetOwnerId;
        public String CRM;
        public String note;
        public BudgetPlan orgData;
    }


    
}