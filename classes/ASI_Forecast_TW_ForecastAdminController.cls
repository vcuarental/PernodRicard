public class ASI_Forecast_TW_ForecastAdminController {
    public Date defDate {get;set;}
    public String dataSet {get;set;}
    public Integer getDarftCount{ get{ return ASI_CRM_TW_Forecast_Util.forecastDraftCount();} }
    public Integer getCutoffDay { get{return ASI_CRM_TW_Forecast_Util.INPUT_CUTOFF_DAY;} }
    
    public Boolean isBatch {
        get {
            Integer currBatch = ASI_CRM_TW_Forecast_Create.getBatchCount();
            return (currBatch>0);
        }
    }
    
    public ASI_Forecast_TW_ForecastAdminController(){
        defDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        List<Map<String,String>> currList = new List<Map<String,String>>();
        List<Map<String,String>> nextList = new List<Map<String,String>>();
        for (ASI_Forecast__c forecast : ASI_CRM_TW_Forecast_Util.searchCurrForecastSummary(ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST)) {
            currList.add(new Map<String,String>{
                'channel'=> forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c,
                'subchannel'=>forecast.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
                'region'=>forecast.ASI_Forecast_Region_tx__c,
                'customer'=>forecast.ASI_CRM_Customer__r.Name,
                'status'=>forecast.ASI_Forecast_Status__c,
                'period'=>forecast.ASI_Forecast_Period__c
            });
        }
        for (ASI_Forecast__c forecast : ASI_CRM_TW_Forecast_Util.searchCurrForecastSummary(ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST.addMonths(1))) {
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
    public static string freezeForecast(String tmp) {
        Set<id> fHeadIdSet = new Set<id>();
        /*
        for(ASI_Forecast__c header : ASI_CRM_TW_Forecast_Create.createForecastHeader()) {
            fHeadIdSet.add(header.id);
        }
        Set<String> channelCodeSet = ASI_CRM_TW_Forecast_Create.insertForecastItem(fHeadIdSet);
		fHeadIdSet.clear();
		*/
        for (ASI_Forecast__c header : ASI_CRM_TW_Forecast_Util.searchCurrForecastSummary(ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST)) {
            fHeadIdSet.add(header.id);
        }
        ASI_CRM_TW_Forecast_Util.updateForecastStatus(fHeadIdSet, 'Freezed');
        
        /*
        system.debug(channelCodeSet);
        Date defDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH;
        defDate = defDate.addMonths(1);
        String currDate = defDate.year()+'-'+defDate.month();
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchForecastInputerByChannelCode(channelCodeSet);
        SYSTEM.debug('pending sent mail list : ' + emailList);        
        ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>(emailList),currDate, '', '', 'ASI_Forecast_TW_Create_HTML', 'ASI_Forecast_TW_InputForecastPage');
		*/
        return 'success';
    }
    
    @RemoteAction
    public static string createForecast(String tmp) {
        if (System.isBatch()) {
            return 'fail : batch running';
        }
        
        Set<id> fHeadIdSet = new Set<id>();
        for(ASI_Forecast__c header : ASI_CRM_TW_Forecast_Create.createForecastHeader()) {
            fHeadIdSet.add(header.id);
        }
        Set<String> channelCodeSet = ASI_CRM_TW_Forecast_Create.searchChannelCodeByHeaderIdSet(fHeadIdSet);
       		
        // send mail
        Date defDate = ASI_CRM_TW_Forecast_Util.searchCurrentForecastMonth();
        String currDate = defDate.year()+'-'+defDate.month();
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchForecastInputerByChannelCode(channelCodeSet);
        system.debug('fHeadIdSet: '+JSON.serialize(fHeadIdSet) + ' emailList: ' + JSON.serialize(emailList));
        Id batchInstanceId = Database.executeBatch(new ASI_Forecast_TW_BatchCreate('Forecast',fHeadIdSet, currDate), 10);
//        ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>(emailList),currDate, '', '', 'ASI_Forecast_TW_Create_HTML', 'ASI_Forecast_TW_InputForecastPage');
        return 'success call batch';

    }

}