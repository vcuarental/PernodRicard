public with sharing class ASI_CRM_CN_TP_MOTTradePlanListCtrl {
    public Decimal taxRate {get;set;}
    public String proModeOptions {get; set;}
    public String planStatusOptions {get; set;}
    public String poStatusOptions {get; set;}
    public Decimal estAmountLimit {get; set;}
    public String bpListViewURL {get; set;}

    public ASI_CRM_CN_TP_MOTTradePlanListCtrl(){
      this.taxRate = ASI_CRM_CN_TP_Utils.getCNTaxRate();
      ASI_CRM_CN_TP_BudgetPlanUpload bpUpload = new ASI_CRM_CN_TP_BudgetPlanUpload();
      bpListViewURL = bpUpload.listViewURL(bpUpload.prefixList(),'ASI_MFM_Plan__c','CN Budget Plan');
      
      Schema.DescribeFieldResult proModeFieldResult = ASI_MFM_Plan_Line_Item__c.ASI_CRM_CN_TP_Promotion_Mode__c.getDescribe();
      this.proModeOptions = JSON.serialize(ASI_CRM_CN_TP_Utils.getPickListValuesIntoList(proModeFieldResult, 'promotionMode'));
      this.planStatusOptions = JSON.serialize(ASI_CRM_CN_TP_Utils.getSettingValuesIntoList(Label.ASI_CRM_CN_TP_Trade_Plan_Status));
      this.poStatusOptions = JSON.serialize(ASI_CRM_CN_TP_Utils.getSettingValuesIntoList(Label.ASI_CRM_CN_TP_PO_Status_CN));
      estAmountLimit = Decimal.valueOf(Label.ASI_CRM_CN_TP_Estimate_Amount_Limit);
    }

    //query Record in database
    @RemoteAction
    public static List<PlanLineItem> queryRecord(List<Id> tpItemIds){
      List<PlanLineItem> result = new List<PlanLineItem>();
      List<ASI_MFM_Plan_Line_Item__c> tempTPList = ASI_CRM_CN_TP_Utils.getTradePlanListByIds(tpItemIds);
        
      //Data Handling
        for (ASI_MFM_Plan_Line_Item__c tempTP : tempTPList) {
            String startDate_Str = DateTime.newInstance(tempTP.ASI_MFM_Plan__r.ASI_MFM_Start_Date__c.year(),tempTP.ASI_MFM_Plan__r.ASI_MFM_Start_Date__c.month(),tempTP.ASI_MFM_Plan__r.ASI_MFM_Start_Date__c.day(), 0,0,0).format('yyyy/MM/dd');
            String endDate_Str = DateTime.newInstance(tempTP.ASI_MFM_Plan__r.ASI_MFM_End_Date__c.year(),tempTP.ASI_MFM_Plan__r.ASI_MFM_End_Date__c.month(),tempTP.ASI_MFM_Plan__r.ASI_MFM_End_Date__c.day(), 0,0,0).format('yyyy/MM/dd');
            result.add(new PlanLineItem(tempTP, startDate_Str, endDate_Str));
        }

        return result;
    }
    @RemoteAction
    public static Map<String,String> generate999(String jsonData){
        List<Object> pLItemList = (List<Object>)JSON.deserializeUntyped(jsonData);
        Map<String,String> msgMap = ASI_CRM_CN_TP_Utils.generate999(pLItemList);
        return msgMap;
    }
    @RemoteAction
    public static Map<String,String> deleteItems(String jsonData){
        List<Object> pLItemList = (List<Object>)JSON.deserializeUntyped(jsonData);
        Map<String,String> msgMap = ASI_CRM_CN_TP_Utils.deletePlans(pLItemList);
        return msgMap;
    }
    @RemoteAction
    public static Map<String,String> save(String jsonData){
      system.debug('jsonData*** '+jsonData);
      List<Object> pLItemList = (List<Object>)JSON.deserializeUntyped(jsonData);
      Map<String,String> msgMap = ASI_CRM_CN_TP_Utils.savePLItem(pLItemList);
      return msgMap;
    }

    @RemoteAction
    public static Map<String,String> submitApproval(String remarks, String jsonData){
      List<Object> pLItemList = (List<Object>)JSON.deserializeUntyped(jsonData);
      Map<String,String> msgMap = ASI_CRM_CN_TP_Utils.saveTPApprovalAndUpdateTp(remarks, pLItemList);
      return msgMap;
    }

    @RemoteAction
    public static Map<String,String> generatePo(String jsonData){
      List<Object> pLItemList = (List<Object>)JSON.deserializeUntyped(jsonData);
      Map<String,String> msgMap = ASI_CRM_CN_TP_Utils.savePo(pLItemList);
      return msgMap;
    }

    @RemoteAction
    public static Map<String,String> generatePayment(String jsonData){
      List<Object> pLItemList = (List<Object>)JSON.deserializeUntyped(jsonData);
      Map<String,String> msgMap = ASI_CRM_CN_TP_Utils.savePayment(pLItemList);
      return msgMap;
    }

    @RemoteAction
    @ReadOnly
    public static List<Id> queryTpItemIds (){
        List<Id> tpItemIds = new List<Id>();//order by CreatedDate DESC
        Set<String> fYSet = ASI_CRM_CN_TP_Utils.getFYContainsPreNextCurrent();
        for(ASI_MFM_Plan_Line_Item__c tpItem : [SELECT Id FROM ASI_MFM_Plan_Line_Item__c WHERE RecordType.developerName =:ASI_CRM_CN_TP_Utils.TP_LINE_ITEM_RTNAME AND ASI_MFM_Plan__r.ASI_MFM_Fiscal_year__c in:fYSet ORDER BY CreatedDate DESC LIMIT 20000]){
            tpItemIds.add(tpItem.Id);
        }
        return tpItemIds;
    }


    public without sharing class PlanLineItem{
        public ASI_MFM_Plan_Line_Item__c item2 {Get; Set;}
        public String dateScope_str {Get; Set;}{dateScope_str='';} 
        public String startDate_str {Get; Set;}{dateScope_str='';} 
        public String endDate_str {Get; Set;}{dateScope_str='';} 
        public String promotionMode_label {Get; Set;}{promotionMode_label='';} 
        public String ischeckedToPay {Get; Set;}{ischeckedToPay='false';} 
        public Decimal fixedCost {Get; Set;}{fixedCost=0;} 
        public Decimal promotionAmount {Get; Set;}{promotionAmount=0;} 
         public planLineItem (ASI_MFM_Plan_Line_Item__c item){
            this.item2 = item;
        }

        public planLineItem (ASI_MFM_Plan_Line_Item__c item, String startDate, String endDate){
            this.item2 = item;
            this.startDate_str = startDate;
            this.endDate_str = endDate;
            this.promotionMode_label = ASI_CRM_CN_TP_Utils.getPicklistLabels('ASI_MFM_Plan_Line_Item__c', 'ASI_CRM_CN_TP_Promotion_Mode__c').get(item.ASI_CRM_CN_TP_Promotion_Mode__c);
        }

        public planLineItem (){}
    }
}