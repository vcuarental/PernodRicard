global without sharing class ASI_CRM_TW_Forecast_Util {
    public static Integer FISCAL_YEAR_MONTH = [SELECT FiscalYearStartMonth FROM Organization].FiscalYearStartMonth;
	public static Integer INPUT_CUTOFF_DAY  = getCutoffDay();
    public static Date CURR_MONTH_BUDGET    = searchCurrentBudgetMonth();
    public static Date CURR_MONTH_FORECAST  = searchCurrentForecastMonth();
    public static Date FREEZED_MONTH_BUDGET = searchFreezedBudgetMonth();
    public static Datetime LAST_FORECAST_CD {
        get{
            List<ASI_Forecast__c> forecastList = [SELECT id, CreatedDate, name
                                                  FROM ASI_Forecast__c
                                                  WHERE RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                                                  ORDER BY CreatedDate DESC
                                                  LIMIT 1];
            if(forecastList.size()>0) {
                return forecastList.get(0).CreatedDate;
            } else {
                return System.now();
            }
        }
    }
    public static Id getForecastReportId {
        get {
            List<Report> reportList = [SELECT  Id, DeveloperName FROM Report
                             WHERE DeveloperName = 'ASI_CRM_TW_Forecast'];
            if (reportList.size() > 0) {
                return reportList.get(0).id;
            }
            return null;
        }
    }
    public static Id getBudgetReportId {
        get{
            
            List<Report> reportList = [SELECT  Id, DeveloperName FROM Report
                             WHERE DeveloperName = 'ASI_CRM_TW_Budget'];
            if (reportList.size() > 0) {
                return reportList.get(0).id;
            }
            return null;
        }
    }
    private static Integer getCutoffDay() {
        Integer cutoffDay = 15;
        try {
//            ASI_CRM_TW_Settings__c cs = ASI_CRM_TW_Settings__c.getOrgDefaults();
//	        cutoffDay = (cs.ASI_CRM_TW_Forecast_Cutoff_Day__c==null)? 15 : Integer.valueOf(cs.ASI_CRM_TW_Forecast_Cutoff_Day__c);
        } catch(exception e) {}
        
		return cutoffDay;
    }
    private static Date CURR_MONTH {
        get {
            Date now = Date.today();
            if(now.day() > INPUT_CUTOFF_DAY) return now.addMonths(1).toStartOfMonth();
            return now.toStartOfMonth();
        }
    }
    public static Date searchFreezedBudgetMonth() {
        ASI_Forecast__c[] lastForecasts = [SELECT ASI_Forecast_Period_Date__c  
                                           FROM ASI_Forecast__c
                                           WHERE ASI_Forecast_Type__c = 'Budget'
                                           AND ASI_Forecast_Status__c = 'Freezed'
                                           AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                                           ORDER BY ASI_Forecast_Period_Date__c DESC
                                           LIMIT 1];
        if(lastForecasts!=null && lastForecasts.size()>0) {
            return lastForecasts.get(0).ASI_Forecast_Period_Date__c;
        }
        return Date.newinstance(CURR_MONTH.year(), FISCAL_YEAR_MONTH, 1);
    }
	public static Date searchCurrentBudgetMonth() {
        ASI_Forecast__c[] lastForecasts = [SELECT ASI_Forecast_Period_Date__c  
                                           FROM ASI_Forecast__c
                                           WHERE ASI_Forecast_Type__c = 'Budget'
                                           AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                                           ORDER BY ASI_Forecast_Period_Date__c DESC
                                           LIMIT 1];
        if(lastForecasts!=null && lastForecasts.size()>0) {
            return lastForecasts.get(0).ASI_Forecast_Period_Date__c;
        }
        return Date.newinstance(CURR_MONTH.year(), FISCAL_YEAR_MONTH, 1);
    }
    public static Date searchCurrentForecastMonth() {
        ASI_Forecast__c[] lastForecasts = [SELECT ASI_Forecast_Period_Date__c  
                                           FROM ASI_Forecast__c
                                           WHERE ASI_Forecast_Type__c = 'Forecast'
                                           AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                                           ORDER BY ASI_Forecast_Period_Date__c DESC
                                           LIMIT 1];
        if(lastForecasts!=null && lastForecasts.size()>0) {
            return lastForecasts.get(0).ASI_Forecast_Period_Date__c;
        }
        return CURR_MONTH;
    }

    public static void updateForecastStatus(Set<id> headerIdSet, String s) {
        List<ASI_Forecast__c> forecastList = new List<ASI_Forecast__c>();
        for (id id : headerIdSet) {
            ASI_Forecast__c forecast = new ASI_Forecast__c(Id=id,ASI_Forecast_Status__c = s);
            forecastList.add(forecast);
        }
        update forecastList;
    }
    
    public static Integer forecastDraftCount() { return draftCount(true); }
    public static Integer budgetDraftCount() { return draftCount(false); }
    private static Integer draftCount(Boolean isForecast) {
        String ftype = isForecast? 'Forecast':'Budget';
        Date startOfMonth = CURR_MONTH_FORECAST;
        Date startOfNextMonth;
        if(isForecast) {
            startOfNextMonth = startOfMonth.addMonths(1);
        } else {
//            if(startOfMonth.month()<FISCAL_YEAR_MONTH) {
//                startOfMonth = startOfMonth.addYears(-1);
//            }
            startOfMonth = CURR_MONTH_BUDGET;
            startOfNextMonth = startOfMonth.addYears(1);
        }

        List<ASI_Forecast__c> forecast = [
            SELECT id, ASI_Forecast_Period_Date__c
            FROM ASI_Forecast__c 
            WHERE ASI_Forecast_Period_Date__c >= :startOfMonth 
            AND ASI_Forecast_Period_Date__c < :startOfNextMonth
            AND (ASI_Forecast_Status__c = 'Draft' OR ASI_Forecast_Status__c='Submitted')
			AND ASI_Forecast_Type__c = :ftype
            AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
        ];
        return forecast.Size();
    }
    
    public static List<ASI_Forecast_Channel_Map__c> searchSubChannelUserMapping() {
        return [SELECT id, name, ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c, 
                ASI_Forecast_Sub_Channel__r.name, ASI_Forecast_SubmitUser__c,
                ASI_Forecast_Sub_Channel__c, ASI_Forecast_Region__c
                FROM ASI_Forecast_Channel_Map__c 
                WHERE ASI_Forecast_ChannelRegion_Manger__c = :UserInfo.getUserId()
                AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW_ChannelMap'];
    }
    public static List<ASI_Forecast_Channel_Map__c> searchChannelUserMapping() {
        return [SELECT id, name, ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c, 
                ASI_Forecast_Sub_Channel__r.name, ASI_Forecast_SubmitUser__c,
                ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__r.name, 
                ASI_Forecast_Sub_Channel__c, ASI_Forecast_Region__c 
                FROM ASI_Forecast_Channel_Map__c 
                WHERE ASI_Forecast_National_Manager__c = :UserInfo.getUserId()
                AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW_ChannelMap'];
    }
    
    public static List<ASI_Forecast__c> searchCurrForecastSummary(Date periodDate){ return searchSummary(periodDate, true); }
    public static List<ASI_Forecast__c> searchCurrBudgetSummary(Date periodDate){ return searchSummary(periodDate, false); }
    private static List<ASI_Forecast__c> searchSummary(Date periodDate,Boolean isForecast){
    	String ftype = isForecast? 'Forecast':'Budget';
        Date startOfMonth = periodDate.toStartOfMonth();
		Date startOfNextMonth = startOfMonth.addMonths(1);
        List<ASI_Forecast__c> forecastList = [SELECT id, name, ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c, 
                                              ASI_CRM_Customer__r.Name,
                                              ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
                                              ASI_Forecast_Region_tx__c, ASI_Forecast_Period__c, ASI_Forecast_Status__c 
                                              FROM ASI_Forecast__c 
                                              WHERE ASI_Forecast_Period_Date__c >= :startOfMonth 
                                              AND ASI_Forecast_Period_Date__c < :startOfNextMonth 
                                              AND ASI_Forecast_Type__c = :ftype
                                              AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'];
        return forecastList;
    }
    
    public static List<ASI_Forecast_Item__c> searchForecastForReport(Date startPeriod, Date endPeriod){ return searchForecastForReport(startPeriod, endPeriod, true); }
    public static List<ASI_Forecast_Item__c> searchBudgetForReport(Date startPeriod, Date endPeriod){ return searchForecastForReport(startPeriod, endPeriod, false); }
	private static List<ASI_Forecast_Item__c> searchForecastForReport(Date startPeriod, Date endPeriod, Boolean isForecast){
        String fType = (isForecast) ? 'Forecast':'Budget';
        
        Date startOfMonth = startPeriod.toStartOfMonth();
        Date startOfNextMonth= endPeriod.toStartOfMonth();
        List<ASI_Forecast_Item__c> itemList = [SELECT
                                              ASI_Forecast_Item_Group__c, ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Description__c,
                                              ASI_Forecast_P1__c, ASI_Forecast_P2__c, ASI_Forecast_P3__c, ASI_Forecast_P4__c, 
                                              ASI_Forecast_P5__c, ASI_Forecast_P6__c, ASI_Forecast_P7__c, ASI_Forecast_P8__c, 
                                              ASI_Forecast_P9__c, ASI_Forecast_P10__c, ASI_Forecast_P11__c, ASI_Forecast_P12__c,
                                              ASI_Forecast_Item_Pack__c, ASI_Forecast_Item_Size__c 
                                              FROM ASI_Forecast_Item__c
                                              WHERE ASI_Forecast_Period_Date__c >= :startOfMonth 
                                              AND ASI_Forecast_Period_Date__c < :startOfNextMonth
                                              AND ASI_Forecast__r.ASI_Forecast_Type__c = :fType
                                              //AND ASI_Forecast__r.ASI_Forecast_Status__c != 'Draft'
                                              AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW_Item'];
        return itemList;
    }
    
    private static string forecastQueryString() {
        String queryString = 'SELECT id, ';
		queryString += '(SELECT id, LastModifiedDate, ASI_Forecast__r.LastModifiedDate, ASI_Forecast__r.name, ASI_Forecast__r.ASI_Forecast_Region_tx__c, ASI_Forecast__r.ASI_Forecast_Status__c, ASI_Forecast__r.ASI_CRM_Customer__r.id, ASI_Forecast__r.ASI_CRM_Customer__r.Name, ';
        queryString += 'ASI_Forecast_Ref_Item__c, ASI_Forecast_Ref_Budget_Item__c, ASI_Forecast_Ref_Budget_Item__r.ASI_CRM_Total__c, ';
        queryString += 'ASI_Forecast__r.ASI_Forecast_Channel__c, ASI_Forecast__r.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c, ';
        queryString += 'ASI_Forecast__r.ASI_Forecast_Period__c, ASI_Forecast__r.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,  ';
        queryString += 'ASI_Forecast_Item_Group__r.ASI_CRM_TW_Brand__r.Name, ';
        queryString += 'ASI_Forecast_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Product_Category__c, ASI_Forecast_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c, ';
        queryString += 'ASI_Forecast_Item_Group__r.id, ASI_Forecast_Item_Group__r.Name, ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Description__c , ';
        queryString += 'ASI_Forecast_P1__c, ASI_Forecast_P2__c, ASI_Forecast_P3__c, ASI_Forecast_P4__c, ASI_Forecast_P5__c, ASI_Forecast_P6__c, ASI_Forecast_P7__c, ASI_Forecast_P8__c, ASI_Forecast_P9__c, ASI_Forecast_P10__c, ASI_Forecast_P11__c, ASI_Forecast_P12__c, ';
        queryString += 'ASI_CRM_Total__c ';
        queryString += 'FROM ASI_Forecast_Item__r) ';
        queryString += 'FROM ASI_Forecast__c ';
		queryString += 'WHERE ASI_Forecast_Period_Date__c >= :startOfMonth AND ASI_Forecast_Period_Date__c < :startOfNextMonth ';
        queryString += 'AND RecordType.DeveloperName Like \'ASI_Forecast_TW\' ';
        return queryString;
    }
    
    public static Map<id,Map<id,ASI_Forecast_Item__c>> retrieveForecastSummary(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions, Date periodDate) {
        Map<id,Map<id,ASI_Forecast_Item__c>> resultMap = new Map<id,Map<id,ASI_Forecast_Item__c>>();
        Map<id, Map<id, ASI_Forecast_Item__c>> currBudgetMap = retrieveForecast(channelIds,subChannelIds,regions, periodDate);
        system.debug('currBudgetMap : ' + currBudgetMap);
        for (id headerId : currBudgetMap.keySet()) {
            Map<id, ASI_Forecast_Item__c> itemMap = currBudgetMap.get(headerId);
            for(id itemId : itemMap.keySet()) {
                ASI_Forecast_Item__c item = itemMap.get(itemid);
                if(item.ASI_Forecast__r.ASI_Forecast_Status__c == 'Final' || item.ASI_Forecast__r.ASI_Forecast_Status__c == 'Freezed') {
                    id custId = item.ASI_Forecast__r.ASI_CRM_Customer__r.id;
                    if(resultMap.get(custId)==null) resultMap.put(custId, new Map<id,ASI_Forecast_Item__c>());
                    resultMap.get(custId).put(item.ASI_Forecast_Item_Group__r.id, item);
                }
            }
        }
        return resultMap;
    }
    public static Map<id, Map<id, ASI_Forecast_Item__c>> retrieveForecast(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions, Date periodDate) {
        Date startOfMonth = periodDate.toStartOfMonth();
		Date startOfNextMonth = periodDate.addMonths(1);
        return searchForecast(channelIds, subChannelIds, regions, startOfMonth, startOfNextMonth, true);
    }
	public static Map<id, Map<id, ASI_Forecast_Item__c>> retrieveForecastRange(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions, Date startPeriodDate, Date endPeriodDate) {
        Date startOfMonth = startPeriodDate.toStartOfMonth();
		Date startOfNextMonth = endPeriodDate.toStartOfMonth();
        return searchForecast(channelIds, subChannelIds, regions, startOfMonth, startOfNextMonth, true);
    }
    public static Map<id,Map<id,ASI_Forecast_Item__c>> retrieveBudgetSummary(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions) {
        Date period = CURR_MONTH_BUDGET.addYears(-1);
        return retrieveBudgetSummaryByDate(channelIds, subChannelIds, regions, period);
    }
    public static Map<id,Map<id,ASI_Forecast_Item__c>> retrieveBudgetSummaryForForecast(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions) {
        Date currForecastMonth = CURR_MONTH_FORECAST;
		Integer fiscalMonth = FISCAL_YEAR_MONTH;
        Date budgetPeriod = Date.newInstance(currForecastMonth.year(), fiscalMonth, 1);
        if (currForecastMonth.month() < fiscalMonth) {
            budgetPeriod = budgetPeriod.addYears(-1);
        }
        return retrieveBudgetSummaryByDate(channelIds, subChannelIds, regions, budgetPeriod);
    }

	private static Map<id,Map<id,ASI_Forecast_Item__c>> retrieveBudgetSummaryByDate(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions, Date period) {
        Map<id,Map<id,ASI_Forecast_Item__c>> resultMap = new Map<id,Map<id,ASI_Forecast_Item__c>>();
        Map<id, Map<id, ASI_Forecast_Item__c>> currBudgetMap = retrieveBudgetByDate(channelIds,subChannelIds,regions, period);
        for (id headerId : currBudgetMap.keySet()) {
            Map<id, ASI_Forecast_Item__c> itemMap = currBudgetMap.get(headerId);
            for(id itemId : itemMap.keySet()) {
                //system.debug('item Id : ' + itemId );
                ASI_Forecast_Item__c item = itemMap.get(itemid);
                if(item.ASI_Forecast__r.ASI_Forecast_Status__c == 'Freezed') {
                    id custId = item.ASI_Forecast__r.ASI_CRM_Customer__r.id;
                    if(resultMap.get(custId)==null) resultMap.put(custId, new Map<id,ASI_Forecast_Item__c>());
                    resultMap.get(custId).put(item.ASI_Forecast_Item_Group__r.id, item);
                }
            }
        }
        return resultMap;
    }
    public static Map<id, Map<id, ASI_Forecast_Item__c>> retrieveBudget(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions) {
        Date currPeriod = CURR_MONTH_BUDGET;
		Date startOfMonth = Date.newinstance(currPeriod.year(), FISCAL_YEAR_MONTH, 1);
		Date startOfNextMonth = startOfMonth.addYears(1);
        return searchForecast(channelIds, subChannelIds, regions, startOfMonth, startOfNextMonth, false);
    }
    private static Map<id, Map<id, ASI_Forecast_Item__c>> retrieveBudgetByDate(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions, Date period) {
		Date startOfMonth = Date.newinstance(period.year(), FISCAL_YEAR_MONTH, 1);
		Date startOfNextMonth = startOfMonth.addYears(1);
        return searchForecast(channelIds, subChannelIds, regions, startOfMonth, startOfNextMonth, false);
    }
    private static Map<id, Map<id, ASI_Forecast_Item__c>> searchForecast(Set<id> channelIds, Set<id> subChannelIds, Set<String> regions, Date startOfMonth, Date startOfNextMonth, Boolean isForecast) {
        String fType = isForecast ? 'Forecast':'Budget';
		String queryString = forecastQueryString();
        String chIdStr = '' ;
        if (channelIds!=null && channelIds.size()>0) {
            for(Id cid : channelIds) chIdStr += '\'' + cid + '\',';
            chIdStr = '('+chIdStr.removeEnd(',')+')';
        }
        String subChIdStr ='';
        if (subChannelIds!=null && subChannelIds.size()>0) {
            for(Id cid : subChannelIds) subChIdStr += '\'' + cid + '\',';
            subChIdStr = '('+subChIdStr.removeEnd(',')+')';
        }
        String regionStr = '';
        if (regions!=null && regions.size()>0) {
            for(String r : regions) regionStr += '\'' + r + '\',';
            regionStr = '('+regionStr.removeEnd(',')+')';
        }
        if (chIdStr!='') { queryString += 'AND ASI_Forecast_Channel__c IN'+chIdStr ; }
        if (subChIdStr!='') { queryString += 'AND ASI_Forecast_Sub_Channel__c IN'+subChIdStr; }
        if (regionStr!='') {
            queryString += 'AND ASI_Forecast_Region_tx__c IN'+regionStr; 
        }
        queryString += 'AND ASI_Forecast_Type__c = :fType ';
        queryString += 'ORDER BY ASI_Forecast_Period_Date__c';
        
        
        system.debug('startOfMonth : ' + startOfMonth);
        system.debug('startOfNextMonth : ' + startOfNextMonth);
        system.debug('queryString : '+queryString);

        Map<id, Map<id, ASI_Forecast_Item__c>> resultMap = new Map<id, Map<id, ASI_Forecast_Item__c>>();
		for (ASI_Forecast__c forecast : (List<ASI_Forecast__c>)Database.query(queryString) ){
            Map<id, ASI_Forecast_Item__c> fItemMap = new Map<id, ASI_Forecast_Item__c>();
            for(ASI_Forecast_Item__c fItem : forecast.ASI_Forecast_Item__r) {
                id itemGroupId = fItem.ASI_Forecast_Item_Group__c;
                fItemMap.put(itemGroupId, fItem);
            }
            resultMap.put(forecast.id, fItemMap);
        }
		return resultMap;
    }
    
    public static Map<id, Map<id, ASI_Forecast_Item__c>> searchCurrentForecast(Set<Id> currForecastIds){
        Date startOfMonth = Date.today().toStartOfMonth();
		Date startOfNextMonth = startOfMonth.addMonths(1);
		String queryString = forecastQueryString();
        String idStr = '' ;
        if (currForecastIds!=null) {
            for(Id fid : currForecastIds) idStr += '\'' + fid + '\',';
            idStr = '('+idStr.removeEnd(',')+')';
        }
        if (idStr!='') { queryString += 'AND id IN'+idStr ; }
        queryString += 'ORDER BY ASI_Forecast_Period_Date__c';
        Map<id, Map<id, ASI_Forecast_Item__c>> resultMap = new Map<id, Map<id, ASI_Forecast_Item__c>>();
		for (ASI_Forecast__c forecast : (List<ASI_Forecast__c>)Database.query(queryString) ){
            Map<id, ASI_Forecast_Item__c> fItemMap = new Map<id, ASI_Forecast_Item__c>();
            for(ASI_Forecast_Item__c fItem : forecast.ASI_Forecast_Item__r) {
                id itemGroupId = fItem.ASI_Forecast_Item_Group__c;
                fItemMap.put(itemGroupId, fItem);
            }
            resultMap.put(forecast.id, fItemMap);
        }
		return resultMap;
    }
    
    public static Map<String, List<id>> getChannelItemMap(Set<String> channelSet) {
        System.debug(channelSet);
        Map<String, List<id>> channelItemMap = new Map<String,List<id>>();
        String queryString = 'SELECT id, name, ASI_CRM_Applied_To_Forecast__c, ASI_MFM_Sub_brand__r.name FROM ASI_MFM_Item_Group__c WHERE RecordType.DeveloperName Like \'ASI_MFM_TW_Item_Group\' AND ASI_CRM_Active__c = true AND ASI_CRM_Applied_To_Forecast__c INCLUDES(';
        for(String channel :channelSet) { queryString += '\''+channel+'\','; }
        queryString = queryString.removeEnd(',') +')';
        for (ASI_MFM_Item_Group__c itemGroup : (List<ASI_MFM_Item_Group__c>)Database.query(queryString) ){
            system.debug('Name : '+itemGroup.name + ' id : ' + itemGroup.id + ' sub brand : ' + itemGroup.ASI_MFM_Sub_brand__r.name + ' Appto : ' + itemGroup.ASI_CRM_Applied_To_Forecast__c);
            for(String channelCode : itemGroup.ASI_CRM_Applied_To_Forecast__c.split(';')) {
                if (channelItemMap.get(channelCode)==null) {
                    channelItemMap.put(channelCode, new List<id>());
                }
                channelItemMap.get(channelCode).add(itemGroup.id);
            }
        }
        return channelItemMap;
    }
    
    public static Map<Id,Boolean> checkSkipApprovalBySubChId(Set<Id> subChId) {
        Map<Id,Boolean> result = new Map<Id,Boolean>();
        for(ASI_Forecast_Channel_Map__c mapping : [SELECT id, ASI_Forecast_Sub_Channel__c, ASI_Forecast_National_Manager__c 
                                                   FROM ASI_Forecast_Channel_Map__c 
                                                   WHERE ASI_Forecast_Sub_Channel__c IN :subChId
                                                   AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW_ChannelMap']) {
            result.put(mapping.ASI_Forecast_Sub_Channel__c, (mapping.ASI_Forecast_National_Manager__c==null));
        }
        return result;
    }
    
    public static Set<String>  searchForecastApproverByChannelCode(Set<String>channelSet) {return searchApproverByChannelCode(channelSet,true, true, true, false);}
    public static Set<String>  searchForecastInputerByChannelCode(Set<String>channelSet) {return searchApproverByChannelCode(channelSet,true, false, true, false);}
    public static Set<String>  searchForecastItemGroupInputerByChannelCode(Set<String>channelSet) {return searchApproverByChannelCode(channelSet,true, false, true, true);}
    public static Set<String>  searchForecastApprovedInputerByChannelCode(Set<String>channelSet) {return searchApproverByChannelCode(channelSet,true, false, false, false);}
    public static Set<String>  searchBudgetApproverByChannelCode(Set<String>channelSet) {return searchApproverByChannelCode(channelSet,false, true, true, false);}
    public static Set<String>  searchBudgetInputerByChannelCode(Set<String>channelSet) {return searchApproverByChannelCode(channelSet,false, false, true, false);}
    public static Set<String>  searchBudgetApprovedInputerByChannelCode(Set<String>channelSet) {return searchApproverByChannelCode(channelSet,false, false, false, false);}
    private static Set<String> searchApproverByChannelCode(Set<String>channelSet, Boolean isForecast, Boolean isApprover, Boolean isDraft, Boolean isSkipDraftCheck){
        Map<Id, Integer> userDraftCountMap = new Map<Id, Integer>();
        Map<String,List<Id>> chUserMap = new Map<String,List<Id>>();
        Map<Id, String> userMailMap = new Map<Id, String>();
        Set<Id> userIdSet = new Set<Id>();
        Set<String> chIdSet = new Set<String>();

        List<ASI_Forecast_Channel_Map__c> userMappingList = [SELECT id,name, ASI_Forecast_Channel__c, ASI_Forecast_Sub_Channel_Code__c,
                                                             ASI_Forecast_Sub_Channel__c , ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c, 
                                                             ASI_Forecast_National_Manager__r.Email, ASI_Forecast_ChannelRegion_Manger__r.Email,
                                                             ASI_Forecast_National_Manager__c, ASI_Forecast_ChannelRegion_Manger__c,
                                                             ASI_Forecast_Region__c
                                                             FROM ASI_Forecast_Channel_Map__c
                                                             WHERE ASI_Forecast_Channel__c IN :channelSet
                                                             AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW_ChannelMap'];
        for(ASI_Forecast_Channel_Map__c chMapping : userMappingList) {
            Id userId;
            String mail;
            String channelId;
            if(isApprover) {
				userId = chMapping.ASI_Forecast_National_Manager__c;
                mail = chMapping.ASI_Forecast_National_Manager__r.Email;
                channelId  = chMapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c;
                chIdSet.add(channelId);
            } else {
                userId = chMapping.ASI_Forecast_ChannelRegion_Manger__c;
                mail = chMapping.ASI_Forecast_ChannelRegion_Manger__r.Email;
                channelId  = chMapping.ASI_Forecast_Sub_Channel__c+'_'+chMapping.ASI_Forecast_Region__c;
                chIdSet.add(chMapping.ASI_Forecast_Sub_Channel__c);
            }
            if(userId!=null) {
                userIdSet.add(userId);
                userDraftCountMap.put(userId, 0);
                if(!chUserMap.containsKey(channelId)) {chUserMap.put(channelId, new List<Id>());}
                chUserMap.get(channelId).add(userId);
                userMailMap.put(userId, mail);
            }
        }
        
        System.debug('userIdSet : ' + userIdSet);
        System.debug('chIdSet : ' + chIdSet);
		System.debug('chUserMap : ' + chUserMap);
        System.debug('userMailMap : ' + userMailMap);
        
        Date startOfMonth;
        Date startOfNextMonth;
        if(isForecast) {
            startOfMonth = searchCurrentForecastMonth();
            startOfNextMonth = startOfMonth.addMonths(1);
        } else {
            startOfMonth = searchCurrentBudgetMonth();
            startOfNextMonth = startOfMonth.addYears(1);
        }
        String fType = isForecast ? 'Forecast':'Budget';
        List<ASI_Forecast__c> forecastList; 
        if(isApprover) {
            forecastList = [SELECT id,name,ASI_Forecast_Channel__c,ASI_Forecast_Sub_Channel__c,ASI_Forecast_Region_tx__c 
                            FROM ASI_Forecast__c 
                            WHERE ASI_Forecast_Type__c = :fType
                            AND ASI_Forecast_Period_Date__c >= :startOfMonth AND ASI_Forecast_Period_Date__c < :startOfNextMonth 
                            AND ASI_Forecast_Status__c='Draft'
                            AND ASI_Forecast_Channel__c IN :chIdSet
                            AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                           ];
        } else {
            String fStatus = (isDraft)?'Draft':'Final';
            forecastList = [SELECT id,name,ASI_Forecast_Channel__c,ASI_Forecast_Sub_Channel__c,ASI_Forecast_Region_tx__c 
                            FROM ASI_Forecast__c 
                            WHERE ASI_Forecast_Type__c = :fType
                            AND ASI_Forecast_Period_Date__c >= :startOfMonth AND ASI_Forecast_Period_Date__c < :startOfNextMonth 
                            AND ASI_Forecast_Status__c=:fStatus
                            AND ASI_Forecast_Sub_Channel__c IN :chIdSet
                            AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                           ];
            System.debug('fStatus: '+ fStatus);
        }
        System.debug('fType: '+ fType);
        System.debug('startOfMonth : '+ startOfMonth);
        System.debug('startOfNextMonth : '+ startOfNextMonth);
        system.debug('forecast search result : ' + forecastList);
        for (ASI_Forecast__c forecast : forecastList) {
            String channelId;
            if(isApprover) {
                channelId = forecast.ASI_Forecast_Channel__c;
            } else {
                channelId = forecast.ASI_Forecast_Sub_Channel__c+'_'+forecast.ASI_Forecast_Region_tx__c;
            }
            System.debug('get user : ' + channelId);
            List<Id> userIdList = chUserMap.get(channelId);
            if(userIdList!=null && userIdList.size()>0) {
                for(Id userId:userIdList) {
                    userDraftCountMap.put(userId, userDraftCountMap.get(userId)+1);
                }
            }
        }
        System.debug('userDraftCountMap : ' + userDraftCountMap);
        
        Set<String> userMailList = new Set<String>();
        for(Id key : userDraftCountMap.keySet()) {
            Integer draftCount = userDraftCountMap.get(key);
//            if((isApprover && draftCount==0) || (!isApprover && draftCount>0) || isSkipDraftCheck) {
            if((isApprover) || (!isApprover && draftCount>0) || isSkipDraftCheck) {
                userMailList.add(userMailMap.get(key));
            }
        }
        return userMailList;
    }
    public static void sendForecastEmail(List<String> mailList, String period, String channel, String reason, String emailTemplateName, String pageName){ sendEmail(mailList, period, channel, reason, emailTemplateName, pageName, true); }
    public static void sendBudgetEmail(List<String> mailList, String period, String channel, String reason, String emailTemplateName, String pageName){ sendEmail(mailList, period, channel, reason, emailTemplateName, pageName, false); }
    private static void sendEmail(List<String> mailList, String period, String channel, String reason, String emailTemplateName , String pageName, Boolean isForecast){
        if (mailList==null || mailList.size()==0)return;
//        if (!mailList.contains('dev.pra@introv.com')) {
//            mailList.add('dev.pra@introv.com');
//        }
//        mailList = new List<String>{'dev.pra@introv.com'};
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =:emailTemplateName];
        // process the merge fields
        String pageUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/'+ pageName;
        String fType = (isForecast) ? 'Forecast':'Budget';
        String subject = emailTemplate.Subject;
        subject = subject.replace('{!period}', period);
        subject = subject.replace('{!type}', fType);
        
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{!period}', period);
        htmlBody = htmlBody.replace('{!type}', fType);        
        htmlBody = htmlBody.replace('{!url}', pageUrl);
        htmlBody = htmlBody.replace('{!channel}', channel);
        htmlBody = htmlBody.replace('{!reason}', reason);
        htmlBody = htmlBody.replace(']]>', '');
        
        String plainBody = emailTemplate.Body;
        plainBody = plainBody.replace('{!period}', period);
        plainBody = plainBody.replace('{!url}', pageUrl);
        plainBody = plainBody.replace('{!channel}', channel);
        plainBody = plainBody.replace('{!reason}', reason);
        plainBody = plainBody.replace('{!type}', fType);
        plainBody = plainBody.replace('{!cutoffday}', ''+INPUT_CUTOFF_DAY);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = mailList;
//        message.setReplyTo('dev.pra@introv.com');
		message.setSenderDisplayName(fType +' sender');

//        message.optOutPolicy = 'FILTER';
        message.setSubject(subject);
        system.debug(htmlBody);
//        message.setHtmlBody(htmlBody);
        message.setHtmlBody('<html>'+htmlBody+'</html>');
        message.setPlainTextBody(plainBody);
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};

        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
    } 
}