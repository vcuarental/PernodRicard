public class ASI_Forecast_TW_BudgetAdminController {
    public Date defDate {get;set;}
    public String dataSet {get;set;}
    public Integer getDarftCount{ get{ return ASI_CRM_TW_Forecast_Util.budgetDraftCount();} }
    public Integer fiscalYearMonth { get;set; }
    
    public Boolean isBatch {
        get {
            Integer currBatch = ASI_CRM_TW_Forecast_Create.getBatchCount();
            return (currBatch>0);
        }
    }
    
    public ASI_Forecast_TW_BudgetAdminController(){
        defDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
        List<Map<String,String>> currList = new List<Map<String,String>>();
        List<Map<String,String>> nextList = new List<Map<String,String>>();
        fiscalYearMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;
        Date currperiod = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
        if(currperiod.month() < fiscalYearMonth) {
            currperiod = currperiod.addYears(-1);
        }
        Date startOfMonth = Date.newinstance(currperiod.year(), fiscalYearMonth, 1);
        Date startOfNextMonth = startOfMonth.addYears(1);
        defDate = startOfMonth;
        for (ASI_Forecast__c forecast : ASI_CRM_TW_Forecast_Util.searchCurrBudgetSummary(startOfMonth)) {
            currList.add(new Map<String,String>{
                'channel'=> forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c,
                    'subchannel'=>forecast.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
                    'region'=>forecast.ASI_Forecast_Region_tx__c,
                    'customer'=>forecast.ASI_CRM_Customer__r.Name,
                    'status'=>forecast.ASI_Forecast_Status__c,
                    'period'=>forecast.ASI_Forecast_Period__c
                    });
        }
        for (ASI_Forecast__c forecast : ASI_CRM_TW_Forecast_Util.searchCurrBudgetSummary(startOfNextMonth)) {
            nextList.add(new Map<String,String>{
                'channel'=> forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c,
                    'subchannel'=>forecast.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
                    'region'=>forecast.ASI_Forecast_Region_tx__c,
                    'customer'=>forecast.ASI_CRM_Customer__r.Name,
                    'status'=>forecast.ASI_Forecast_Status__c,
                    'period'=>forecast.ASI_Forecast_Period__c
                    });
        }
        dataSet = JSON.serialize(new Map<String,List<Map<String,String>>>{'current'=>currList,'next'=>nextList});
    }
    
    @RemoteAction
    public static string freezeBudget(String tmp) {
        Set<id> fHeadIdSet = new Set<id>();
        Date startOfMonth = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET;
        for (ASI_Forecast__c header : ASI_CRM_TW_Forecast_Util.searchCurrBudgetSummary(startOfMonth)) {
            fHeadIdSet.add(header.id);
        }
        if(fHeadIdSet.size() > 0){
            ASI_CRM_TW_Forecast_Util.updateForecastStatus(fHeadIdSet, 'Freezed');
        }
        return 'success';
    }
    
    @RemoteAction
    public static string createBudget(String tmp) {
        if (System.isBatch()) {
            return 'fail : batch running';
        }
        Set<id> fHeadIdSet = new Set<id>();
        for(ASI_Forecast__c header : ASI_CRM_TW_Forecast_Create.createBudgetHeader()) {
            fHeadIdSet.add(header.id);
        }

        Set<String> channelCodeSet = ASI_CRM_TW_Forecast_Create.searchChannelCodeByHeaderIdSet(fHeadIdSet);
        
        system.debug(channelCodeSet);
        Date startOfNextMonth = ASI_CRM_TW_Forecast_Util.searchCurrentBudgetMonth();
        String currDate = startOfNextMonth.year()+'-'+startOfNextMonth.month();
//        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchBudgetInputerByChannelCode(channelCodeSet);
        Id batchInstanceId = Database.executeBatch(new ASI_Forecast_TW_BatchCreate('Budget', fHeadIdSet, currDate), 10);
//        ASI_CRM_TW_Forecast_Util.sendBudgetEmail(new List<String>(emailList), currDate, '', '', 'ASI_Forecast_TW_Create', 'ASI_Forecast_TW_InputBudgetPage');
        
        return 'success call batch';
    }

}