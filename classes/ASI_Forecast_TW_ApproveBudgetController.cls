global without sharing class ASI_Forecast_TW_ApproveBudgetController {
    
    public Date defDate {get;set;}
    public String dataSet {get;set;}
    public String reportUrl {get;set;}
    public Integer fiscalYearMonth { get;set; }
    public String debug {get;set;}
    
	public Set<id> channel { get;set; }
	public Set<id> subChannel { get;set; }
	public Set<String> region { get;set; }
    
	public ASI_Forecast_TW_ApproveBudgetController() {

        channel = new Set<id>();
        subChannel = new Set<id>();
        region = new Set<String>();
        
        fiscalYearMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;

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
        reportUrl += ''+ASI_CRM_TW_Forecast_Util.getBudgetReportId;
        reportUrl += '?pc0='+cs.ASI_CRM_TW_ForecastReportFilter0__c+'&pn0=e&pv0=Budget';
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
    global static Map<String, Object> requestBudget(String dataSet) {

        Set<id> channelSet = new Set<id>();
        Set<id> subChannelSet = new Set<id>();
        Set<String> regionSet = new Set<String>();
        
        Integer fiscalYearMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;
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
                
        List<Map<string,string>> resultList = new List<Map<string,string>>();
        List<ASI_Forecast_Item__c> itemList = new List<ASI_Forecast_Item__c>();
        Map<id, Map<id, ASI_Forecast_Item__c>> nextBudgetMap = new Map<id, Map<id, ASI_Forecast_Item__c>>();
        if (channelSet.size()>0) nextBudgetMap = ASI_CRM_TW_Forecast_Util.retrieveBudget(channelSet, subChannelSet, regionSet);
        system.debug('nextBudgetMap : ' + JSON.serialize(nextBudgetMap));

        Map<String, ASI_Forecast_TW_Approve_Item> submitMap = new Map<String,ASI_Forecast_TW_Approve_Item>();
        Map<String, ASI_Forecast_TW_Approve_Item> aproveMap = new Map<String,ASI_Forecast_TW_Approve_Item>();
        Map<Id, ProductDesc> prodDescMap = new Map<Id, ProductDesc>();
        for (id headerId : nextBudgetMap.keySet()) {
            String forecastStatus = 'Draft';
            
            Map<id, ASI_Forecast_Item__c> itemMap = nextBudgetMap.get(headerId);
            ASI_Forecast_TW_Approve_Item itemHeader;
            for(id itemId : itemMap.keySet()) {
                
                ASI_Forecast_Item__c item = itemMap.get(itemId);
                forecastStatus = item.ASI_Forecast__r.ASI_Forecast_Status__c;
                if(forecastStatus == 'Draft') continue;
                String channelCode = item.ASI_Forecast__r.ASI_Forecast_Channel__c;
                String subChCode   = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__c;
                String region      = item.ASI_Forecast__r.ASI_Forecast_Region_tx__c;
                String customer    = item.ASI_Forecast__r.ASI_CRM_Customer__c;
                channelCode = channelCode+'_'+subChCode;
                if(region!=null&&region!='') {
                    channelCode = channelCode+'_'+region;
                }
                channelCode = channelCode+'_'+customer;
                
                Integer budgetTotal = 0;
                if (forecastStatus == 'Submitted') {
                    if(submitMap.get(channelCode)==null) {
                        submitMap.put(channelCode, new ASI_Forecast_TW_Approve_Item());
                    }
                    itemHeader = submitMap.get(channelCode);
                } else if (forecastStatus == 'Final' || forecastStatus == 'Freezed') {
                    if(aproveMap.get(channelCode)==null) {
                        aproveMap.put(channelCode, new ASI_Forecast_TW_Approve_Item());
                    }
                    itemHeader = aproveMap.get(channelCode);
                }

                itemHeader.headerids.add(headerId);
                
                itemHeader.id = headerId+'';
                itemHeader.period = item.ASI_Forecast__r.ASI_Forecast_Period__c+'';
                itemHeader.channel = item.ASI_Forecast__r.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c+'';
                itemHeader.subchannel = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c;
                itemHeader.channelId = item.ASI_Forecast__r.ASI_Forecast_Channel__c+'';
                itemHeader.subchannelId = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__c;
                itemHeader.region = item.ASI_Forecast__r.ASI_Forecast_Region_tx__c;
                itemHeader.customer = item.ASI_Forecast__r.ASI_CRM_Customer__r.Name+'';
                if(itemHeader.region==null || itemHeader.region=='') {
                    itemHeader.region = '--';
                } else {
                    itemHeader.region = itemHeader.region+'';
                }
                
                Childs itemChild = new Childs();
                itemChild.itemid = item.ASI_Forecast_Item_Group__r.id;
                itemHeader.p1 += itemChild.p1 = item.ASI_Forecast_P1__c.doubleValue();
                itemHeader.p2 += itemChild.p2 = item.ASI_Forecast_P2__c.doubleValue();
                itemHeader.p3 += itemChild.p3 = item.ASI_Forecast_P3__c.doubleValue();
                itemHeader.p4 += itemChild.p4 = item.ASI_Forecast_P4__c.doubleValue();
                itemHeader.p5 += itemChild.p5 = item.ASI_Forecast_P5__c.doubleValue();
                itemHeader.p6 += itemChild.p6 = item.ASI_Forecast_P6__c.doubleValue();
                itemHeader.p7 += itemChild.p7 = item.ASI_Forecast_P7__c.doubleValue();
                itemHeader.p8 += itemChild.p8 = item.ASI_Forecast_P8__c.doubleValue();
                itemHeader.p9 += itemChild.p9 = item.ASI_Forecast_P9__c.doubleValue();
                itemHeader.p10 += itemChild.p10 = item.ASI_Forecast_P10__c.doubleValue();
                itemHeader.p11 += itemChild.p11 = item.ASI_Forecast_P11__c.doubleValue();
                itemHeader.p12 += itemChild.p12 = item.ASI_Forecast_P12__c.doubleValue();
                itemHeader.childs.add(itemChild);
                if(!prodDescMap.containsKey(item.ASI_Forecast_Item_Group__r.id)) {
                    prodDescMap.put(item.ASI_Forecast_Item_Group__r.id, new ProductDesc(
                        item.ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c+'',
                        item.ASI_Forecast_Item_Group__r.Name+'',
                        item.ASI_Forecast_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c+'',
                        item.ASI_Forecast_Item_Group__r.ASI_CRM_TW_Brand__r.Name+''
                    ));
                }
            }

            //Final Draft Submit
            system.debug(forecastStatus);
        }

        Map<String, List<ASI_Forecast_TW_Approve_Item>> budgetMap = new Map<String, List<ASI_Forecast_TW_Approve_Item>>();
        List<ASI_Forecast_TW_Approve_Item> submitList = new List<ASI_Forecast_TW_Approve_Item>();
        List<ASI_Forecast_TW_Approve_Item> aproveList = new List<ASI_Forecast_TW_Approve_Item>();
        for (String key : submitMap.keySet()) {
            submitList.add(submitMap.get(key));
        }
        for (String key : aproveMap.keySet()) {
            aproveList.add(aproveMap.get(key));
        }
        return new Map<String, Object>{'Submitted'=>submitList, 'Final'=>aproveList, 'Product'=>prodDescMap};
    }
    
    @RemoteAction
    global static string approveBudget(string dataSet) {
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
        
        Date currperiod = Date.today();
        Integer fYearMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;
        if(currperiod.month() >= fYearMonth) {
            currperiod = currperiod.addYears(1);
        }
        Date startOfMonth = Date.newinstance(currperiod.year(), fYearMonth, 1);
        String currDate = startOfMonth.year()+'-'+startOfMonth.month();
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchBudgetApprovedInputerByChannelCode(channelCodeSet);
        String chStr = String.join(new List<String>(channelCodeSet), ', ');
        ASI_CRM_TW_Forecast_Util.sendBudgetEmail(new List<String>(emailList), currDate, chStr, '', 'ASI_Forecast_TW_Approved_HTML', 'ASI_Forecast_TW_InputBudgetPage');
        SYSTEM.debug('pending sent mail list : ' + emailList);
        return 'success';
    }
    
    @RemoteAction
    global static string rejectBudget(string dataSet) {
        Set<String> channelCodeSet = new Set<String>();
        List<ASI_Forecast__c> approveList = new List<ASI_Forecast__c>();
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        String resaon = (String)dataMap.get('reason');
        system.debug('resaon : ' + resaon);
        List<Object> dataList = (List<Object>)dataMap.get('approvalData');
        for(Object dataObj : dataList) {
            String jsonData = JSON.serialize(dataObj);
            ASI_Forecast_TW_Approve_Item approveItem = (ASI_Forecast_TW_Approve_Item)JSON.deserialize(jsonData, ASI_Forecast_TW_Approve_Item.class);
            for(Id headerid : approveItem.headerids) {
                channelCodeSet.add(approveItem.channel);
                ASI_Forecast__c tmpItem = new ASI_Forecast__c();
                tmpItem.Id = headerid;
                tmpItem.ASI_Forecast_Status__c='Draft';
                approveList.add(tmpItem);
            }
        }
        update approveList;
        
        Date currperiod = Date.today();
        Integer fYearMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;
        if(currperiod.month() >= fYearMonth) {
            currperiod = currperiod.addYears(1);
        }
        Date startOfMonth = Date.newinstance(currperiod.year(), fYearMonth, 1);
        String currDate = startOfMonth.year()+'-'+startOfMonth.month();
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchBudgetInputerByChannelCode(channelCodeSet);
        String chStr = String.join(new List<String>(channelCodeSet), ', ');
        ASI_CRM_TW_Forecast_Util.sendBudgetEmail(new List<String>(emailList), currDate, chStr, resaon, 'ASI_Forecast_TW_Rejected_HTML', 'ASI_Forecast_TW_InputBudgetPage');
        SYSTEM.debug('pending sent mail list : ' + emailList);
        return 'success';
    }
    
    private class ASI_Forecast_TW_Approve_Item {
		public Boolean isSelect=true;
		public String id;
        public String period='';
		public String channel='';
		public String subchannel='';
		public String channelId='';
		public String subchannelId='';
		public String region='';
        public String customer='';
        public Double budget = 0;
		public Double p1=0;
		public Double p2=0;
		public Double p3=0;
		public Double p4=0;
		public Double p5=0;
		public Double p6=0;
		public Double p7=0;
		public Double p8=0;
		public Double p9=0;
		public Double p10=0;
		public Double p11=0;
		public Double p12=0;
		public List<Childs> childs = new List<Childs>();
        public Set<id> headerids = new Set<id>();
	}

	private class Childs {
        public Id itemid;
        public Integer budget=0;
		public Double p1=0;
		public Double p2=0;
		public Double p3=0;
		public Double p4=0;
		public Double p5=0;
		public Double p6=0;
		public Double p7=0;
		public Double p8=0;
		public Double p9=0;
		public Double p10=0;
		public Double p11=0;
		public Double p12=0;
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