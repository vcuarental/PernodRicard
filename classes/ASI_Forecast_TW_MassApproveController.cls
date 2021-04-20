global without sharing class ASI_Forecast_TW_MassApproveController {
    public String dataSet {get;set;}
	public Set<id> channel {get;set;}
    public Set<id> subChannel {get;set;}
    public Set<String> region {get;set;}
    public String reportUrl {get;set;}
    public Integer fiscalYearMonth { get;set; }
    public Date currMonth {get;set;}

    public ASI_Forecast_TW_MassApproveController() {
        channel = new Set<id>();
        subChannel = new Set<id>();
        region = new Set<String>();

        fiscalYearMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;
        currMonth = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        Set<String> chNameSet = new Set<String>();
        Set<String> subChNameSet = new Set<String>();
        for(ASI_Forecast_Channel_Map__c mapping : ASI_CRM_TW_Forecast_Util.searchChannelUserMapping()) {
            id channelid = mapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c;
            id subchid = mapping.ASI_Forecast_Sub_Channel__c;
            String regioncodes = mapping.ASI_Forecast_Region__c;
            String subChName = mapping.ASI_Forecast_Sub_Channel__r.name;
            if(channelid!=null) channel.add(mapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c);
            if (subchid!=null) subChannel.add(subchid);
            if (subChName!=null&subChName!='') subChNameSet.add(subChName);
            String channelName = mapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__r.name;
            if(channelName!=null&&channelName!='') chNameSet.add(channelName);
            if (regioncodes!=null&&regioncodes!='') {
                for(String regioncode : regioncodes.split(';')) {
                    region.add(regioncode);
                }
            }
        }

        ASI_CRM_TW_Settings__c cs = ASI_CRM_TW_Settings__c.getInstance();
        reportUrl = 'https://'+System.URL.getSalesforceBaseUrl().getHost()+'/';
        reportUrl += ''+ASI_CRM_TW_Forecast_Util.getForecastReportId;
        reportUrl += '?pc0='+cs.ASI_CRM_TW_ForecastReportFilter0__c+'&pn0=e&pv0=Forecast';
        reportUrl += '&pc1='+cs.ASI_CRM_TW_ForecastReportFilter1__c+'&pn1=e&pv1=';
        for(String subChName : subChNameSet){
            reportUrl+=subChName+',';
        }
        if(region.size()>0) {
            reportUrl += '&pc2='+cs.ASI_CRM_TW_ForecastReportFilter2__c+'&pn2=e&pv2=';
            for(String reg : region){
                reportUrl+=reg+',';
            }
        }
    }
    
    @RemoteAction 
    global static Map<String, List<ASI_Forecast_TW_Approve_Item>> requestForecast(String dataSet) {
        Set<id> channelSet = new Set<id>();
        Set<id> subChannelSet = new Set<id>();
        Set<String> regionSet = new Set<String>();

        Integer fiscalYearMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;
        Date currMonth = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        Set<String> chNameSet = new Set<String>();
        Set<String> subChNameSet = new Set<String>();
        for(ASI_Forecast_Channel_Map__c mapping : ASI_CRM_TW_Forecast_Util.searchChannelUserMapping()) {
            id channelid = mapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c;
            id subchid = mapping.ASI_Forecast_Sub_Channel__c;
            String regioncodes = mapping.ASI_Forecast_Region__c;
            String subChName = mapping.ASI_Forecast_Sub_Channel__r.name;
            if(channelid!=null) channelSet.add(mapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c);
            if (subchid!=null) subChannelSet.add(subchid);
            if (subChName!=null&subChName!='') subChNameSet.add(subChName);
            String channelName = mapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__r.name;
            if(channelName!=null&&channelName!='') chNameSet.add(channelName);
            if (regioncodes!=null&&regioncodes!='') {
                for(String regioncode : regioncodes.split(';')) {
                    regionSet.add(regioncode);
                }
            }
        }

        Date periodDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        List<Map<string,string>> resultList = new List<Map<string,string>>();
        List<ASI_Forecast_Item__c> itemList = new List<ASI_Forecast_Item__c>();
        Map<id, Map<id, ASI_Forecast_Item__c>> currForecastMap = new Map<id, Map<id, ASI_Forecast_Item__c>>();
        if (channelSet.size()>0) currForecastMap = ASI_CRM_TW_Forecast_Util.retrieveForecast(channelSet, subChannelSet, regionSet, periodDate);

        Map<id,Map<id,ASI_Forecast_Item__c>> budgetSummaryMap = ASI_CRM_TW_Forecast_Util.retrieveBudgetSummary(channelSet,subChannelSet,regionSet);

        Map<String, ASI_Forecast_TW_Approve_Item> submitMap = new Map<String,ASI_Forecast_TW_Approve_Item>();
        Map<String, ASI_Forecast_TW_Approve_Item> approveMap = new Map<String,ASI_Forecast_TW_Approve_Item>();
        for (id headerId : currForecastMap.keySet()) {
            String forecastStatus = 'Draft';
            Map<id, ASI_Forecast_Item__c> itemMap = currForecastMap.get(headerId);
            ASI_Forecast_TW_Approve_Item itemHeader;
            for(id itemId : itemMap.keySet()) {
                ASI_Forecast_Item__c item = itemMap.get(itemId);
                forecastStatus = item.ASI_Forecast__r.ASI_Forecast_Status__c;
                if(forecastStatus == 'Draft') continue;
                Double budgetTotal = 0;
                String channelCode = item.ASI_Forecast__r.ASI_Forecast_Channel__c;
                String subChCode   = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__c;
                String period      = item.ASI_Forecast__r.ASI_Forecast_Period__c;
                String region 	   = item.ASI_Forecast__r.ASI_Forecast_Region_tx__c;
                String customer    = item.ASI_Forecast__r.ASI_CRM_Customer__c;

                channelCode = channelCode+'_'+subChCode;
                if (region!=null && region!='') channelCode = channelCode+'_'+region;
                channelCode = channelCode+'_'+customer;
                if (forecastStatus == 'Submitted') {
                    if(submitMap.get(channelCode)==null) {
                        submitMap.put(channelCode, new ASI_Forecast_TW_Approve_Item());
                    }
                    itemHeader = submitMap.get(channelCode);
                } else if (forecastStatus == 'Final' || forecastStatus == 'Freezed') {
                    if(approveMap.get(channelCode)==null) {
                        approveMap.put(channelCode, new ASI_Forecast_TW_Approve_Item());
                    }
                    itemHeader = approveMap.get(channelCode);
                }

                system.debug(budgetSummaryMap);
                try {
                    budgetTotal = item.ASI_Forecast_Ref_Budget_Item__r.ASI_CRM_Total__c.doubleValue();
                    itemHeader.debug='success get lookup budget : ' + item.ASI_Forecast_Ref_Budget_Item__r.ASI_CRM_Total__c.doubleValue();
                } catch(Exception e) {
                    System.debug('No ref budget set ');
                    itemHeader.debug='fail get lookup budget';
                }
                try {
                    if (budgetTotal==0) {
                        budgetTotal = budgetSummaryMap.get(item.ASI_Forecast__r.ASI_CRM_Customer__r.id).get(item.ASI_Forecast_Item_Group__r.id).ASI_CRM_Total__c.doubleValue();
                    }
                } catch(Exception e) {
                    System.debug('No budget on Customer : ' + item.ASI_Forecast__r.ASI_CRM_Customer__r.id + ' item group : ' + item.ASI_Forecast_Item_Group__r.id);
                }
                forecastStatus = item.ASI_Forecast__r.ASI_Forecast_Status__c;

                itemHeader.id = headerId+'';
                itemHeader.headerids.add(headerId);
                itemHeader.period = item.ASI_Forecast__r.ASI_Forecast_Period__c+'';
                itemHeader.channel = item.ASI_Forecast__r.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c+'';
                itemHeader.subchannel = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c+'';
                itemHeader.channelId = item.ASI_Forecast__r.ASI_Forecast_Channel__c+'';
                itemHeader.subchannelId = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__c+'';
                if(item.ASI_Forecast__r.ASI_Forecast_Region_tx__c!=null && item.ASI_Forecast__r.ASI_Forecast_Region_tx__c!='') {
                    itemHeader.region = item.ASI_Forecast__r.ASI_Forecast_Region_tx__c+'';                        
                } else {
                    itemHeader.region = '-';
                }
                itemHeader.customer = item.ASI_Forecast__r.ASI_CRM_Customer__r.Name+'';
                Childs itemChild = new Childs();
                itemChild.skucode = item.ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c+'';
                itemChild.brandname = item.ASI_Forecast_Item_Group__r.ASI_CRM_TW_Brand__r.Name+'';
                itemChild.skudesc = item.ASI_Forecast_Item_Group__r.Name+'';
                itemChild.customer = item.ASI_Forecast__r.ASI_CRM_Customer__r.Name+'';
                itemChild.category = item.ASI_Forecast_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c+'';
                itemHeader.budget += itemChild.budget = budgetTotal;
                itemHeader.p1 += itemChild.p1 = item.ASI_Forecast_P1__c.setScale(2);
                itemHeader.p2 += itemChild.p2 = item.ASI_Forecast_P2__c.setScale(2);
                itemHeader.p3 += itemChild.p3 = item.ASI_Forecast_P3__c.setScale(2);
                itemHeader.p4 += itemChild.p4 = item.ASI_Forecast_P4__c.setScale(2);
                itemHeader.p5 += itemChild.p5 = item.ASI_Forecast_P5__c.setScale(2);
                itemHeader.p6 += itemChild.p6 = item.ASI_Forecast_P6__c.setScale(2);
                itemHeader.p7 += itemChild.p7 = item.ASI_Forecast_P7__c.setScale(2);
                itemHeader.p8 += itemChild.p8 = item.ASI_Forecast_P8__c.setScale(2);
                itemHeader.p9 += itemChild.p9 = item.ASI_Forecast_P9__c.setScale(2);
                itemHeader.p10 += itemChild.p10 = item.ASI_Forecast_P10__c.setScale(2);
                itemHeader.p11 += itemChild.p11 = item.ASI_Forecast_P11__c.setScale(2);
                itemHeader.p12 += itemChild.p12 = item.ASI_Forecast_P12__c.setScale(2);
                itemHeader.childs.add(itemChild);
            }
        }
        List<ASI_Forecast_TW_Approve_Item> submitList = new List<ASI_Forecast_TW_Approve_Item>();
        List<ASI_Forecast_TW_Approve_Item> approveList = new List<ASI_Forecast_TW_Approve_Item>();
        for (String key : submitMap.keySet()) {
            submitList.add(submitMap.get(key));
        }
        for (String key : approveMap.keySet()) {
            approveList.add(approveMap.get(key));
        }

        return new Map<String, List<ASI_Forecast_TW_Approve_Item>>{'Submitted'=>submitList, 'Final'=>approveList};
    }

    @RemoteAction
    global static string approveForecast(string dataSet) {
        Set<String> channelCodeSet = new Set<String>();
        List<ASI_Forecast__c> approveList = new List<ASI_Forecast__c>();
        List<Object> dataList = (List<Object>)JSON.deserializeUntyped(dataSet);
        for(Object dataObj : dataList) {
            String jsonData = JSON.serialize(dataObj);
            ASI_Forecast_TW_Approve_Item approveItem = (ASI_Forecast_TW_Approve_Item)JSON.deserialize(jsonData, ASI_Forecast_TW_Approve_Item.class);
            channelCodeSet.add(approveItem.channel);
            for(Id headerid : approveItem.headerids) {
                ASI_Forecast__c tmpItem = new ASI_Forecast__c();
                tmpItem.Id = headerid;
                tmpItem.ASI_Forecast_Status__c='Final';
                approveList.add(tmpItem);
            }
        }
        update approveList;
        Date periodDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        String currDate = periodDate.year()+'-'+periodDate.month();
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchForecastApprovedInputerByChannelCode(channelCodeSet);
        String chStr = String.join(new List<String>(channelCodeSet), ', ');
        ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>(emailList), currDate, chStr, '', 'ASI_Forecast_TW_Approved_HTML', 'ASI_Forecast_TW_InputForecastPage');
        SYSTEM.debug('pending sent mail list : ' + emailList);
        return 'success';
    }

    @RemoteAction
    global static string rejectForecast(String dataSet) {
        Set<String> channelCodeSet = new Set<String>();
        List<ASI_Forecast__c> approveList = new List<ASI_Forecast__c>();
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        String resaon = (String)dataMap.get('reason');
        system.debug('resaon : ' + resaon);
        List<Object> dataList = (List<Object>)dataMap.get('approvalData');
        for(Object dataObj : dataList) {
            String jsonData = JSON.serialize(dataObj);
            ASI_Forecast_TW_Approve_Item approveItem = (ASI_Forecast_TW_Approve_Item)JSON.deserialize(jsonData, ASI_Forecast_TW_Approve_Item.class);
            channelCodeSet.add(approveItem.channel);
            for(Id headerid : approveItem.headerids) {
                ASI_Forecast__c tmpItem = new ASI_Forecast__c();
                tmpItem.Id = headerid;
                tmpItem.ASI_Forecast_Status__c='Draft';
                approveList.add(tmpItem);
            }
        }
        update approveList;
        Date periodDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        String currDate = periodDate.year()+'-'+periodDate.month();
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchForecastInputerByChannelCode(channelCodeSet);
        String chStr = String.join(new List<String>(channelCodeSet), ', ');
        ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>(emailList), currDate, chStr, resaon, 'ASI_Forecast_TW_Rejected_HTML', 'ASI_Forecast_TW_InputForecastPage');
        SYSTEM.debug('pending sent mail list : ' + emailList);
        
        return 'success';
    }
    
    private class ASI_Forecast_TW_Approve_Item {
        public String debug='';
		public Boolean isSelect=true;
		public String id;
        public String period='';
		public String channel='';
		public String subchannel='';
		public String channelId='';
		public String subchannelId='';
		public String region='';
        public String customer='';
        public Decimal budget = 0;
		public Decimal p1=0;
		public Decimal p2=0;
		public Decimal p3=0;
		public Decimal p4=0;
		public Decimal p5=0;
		public Decimal p6=0;
		public Decimal p7=0;
		public Decimal p8=0;
		public Decimal p9=0;
		public Decimal p10=0;
		public Decimal p11=0;
		public Decimal p12=0;
		public List<Childs> childs = new List<Childs>();
        public Set<id> headerids = new Set<id>();
	}

	private class Childs {
        public String brandname='';
		public String skucode='';
		public String skudesc='';
		public String customer='';
        public String category='';
        public Decimal budget=0;
		public Decimal p1=0;
		public Decimal p2=0;
		public Decimal p3=0;
		public Decimal p4=0;
		public Decimal p5=0;
		public Decimal p6=0;
		public Decimal p7=0;
		public Decimal p8=0;
		public Decimal p9=0;
		public Decimal p10=0;
		public Decimal p11=0;
		public Decimal p12=0;
	}
    
    private class ProductDesc {
        public String skucode;
        public String skudesc;
        public String category;
        public String brandname;
        
        public ProductDesc(String code, String sku, String cate, String b){
            skucode=code;
            skudesc=sku;
            category=cate;
            brandname=b;
        }
    }
	
	private static List<ASI_Forecast_TW_Approve_Item> parse(String json) {
		return (List<ASI_Forecast_TW_Approve_Item>) System.JSON.deserialize(json, List<ASI_Forecast_TW_Approve_Item>.class);
	}
}