global without sharing class ASI_Forecast_TW_InputForecastController {
    public String dataSet {get;set;}
    public Date currMonth {get;set;}
    public Set<id> channel {get;set;}
    public Set<id> subChannel {get;set;}
    public Set<String> region {get;set;}
    public String reportUrl {get;set;}
    public Boolean isSubmitUser {get;set;}
    public Boolean isProcressing {get;set;}

    public ASI_Forecast_TW_InputForecastController(){
        isSubmitUser = false;
        currMonth = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        if(ASI_CRM_TW_Forecast_Create.getBatchCount()>0){
            dataSet = JSON.serialize(new Map<String, List<ASI_Forecast_TW_Input_Item>>());
            isProcressing = true;
            return;
        }
        channel = new Set<id>();
        subChannel = new Set<id>();
        region = new Set<String>();
        Set<String> subChNameSet = new Set<String>();
        for(ASI_Forecast_Channel_Map__c mapping : ASI_CRM_TW_Forecast_Util.searchSubChannelUserMapping()) {
            if(mapping.ASI_Forecast_SubmitUser__c!=null && mapping.ASI_Forecast_SubmitUser__c==true) {
                isSubmitUser = true;
            }
            id channelid = mapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c;
            id subchid = mapping.ASI_Forecast_Sub_Channel__c;
            String regioncodes = mapping.ASI_Forecast_Region__c;
            String subChName = mapping.ASI_Forecast_Sub_Channel__r.name;
            if (channelid!=null) channel.add(channelid);
            if (subchid!=null) subChannel.add(subchid);
            if (subChName!=null&subChName!='') subChNameSet.add(subChName);
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
        
        Date periodDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        Date prevPeriodDate = periodDate.addMonths(-1);
        List<ASI_Forecast_TW_Input_Item> resultList = new List<ASI_Forecast_TW_Input_Item>();
        List<ASI_Forecast_TW_Input_Item> submitList = new List<ASI_Forecast_TW_Input_Item>();
        List<ASI_Forecast_TW_Input_Item> procressingList = new List<ASI_Forecast_TW_Input_Item>();
        List<ASI_Forecast_Item__c> itemList = new List<ASI_Forecast_Item__c>();
        Map<id,Map<id,ASI_Forecast_Item__c>> currForecastMap = new Map<id,Map<id,ASI_Forecast_Item__c>>();
        Map<id,Map<id,ASI_Forecast_Item__c>> forecastSummaryMap = ASI_CRM_TW_Forecast_Util.retrieveForecastSummary(channel,subchannel,region,prevPeriodDate);
        Map<id,Map<id,ASI_Forecast_Item__c>> budgetSummaryMap = ASI_CRM_TW_Forecast_Util.retrieveBudgetSummaryForForecast(channel,subchannel,region);
        if(channel.size()>0) currForecastMap = ASI_CRM_TW_Forecast_Util.retrieveForecast(channel, subchannel, region, periodDate);


        for (id headerId : currForecastMap.keySet()) {
            String forecastStatus = 'Draft';
            Map<id, ASI_Forecast_Item__c> itemMap = currForecastMap.get(headerId);
            for(id itemId : itemMap.keySet()) {
                ASI_Forecast_TW_Input_Item tmpItem = new ASI_Forecast_TW_Input_Item();
                ASI_Forecast_Item__c item = itemMap.get(itemId);

                forecastStatus = item.ASI_Forecast__r.ASI_Forecast_Status__c;
                
                Double budgetTotal = 0;
                try {
                    budgetTotal = item.ASI_Forecast_Ref_Budget_Item__r.ASI_CRM_Total__c.doubleValue();
                    tmpItem.debug='success get lookup budget : ' + item.ASI_Forecast_Ref_Budget_Item__r.ASI_CRM_Total__c.doubleValue();
                } catch(Exception e) {
                    System.debug('No ref budget set ');
                    tmpItem.debug='fail get lookup budget';
                }
                try {
                    if(budgetTotal==0){
                        budgetTotal = budgetSummaryMap.get(item.ASI_Forecast__r.ASI_CRM_Customer__r.id).get(item.ASI_Forecast_Item_Group__r.id).ASI_CRM_Total__c.doubleValue();
                        tmpItem.debug='use search budget total for first ui init';
                    }
                } catch(Exception e) {
                    System.debug('No budget on Customer : ' + item.ASI_Forecast__r.ASI_CRM_Customer__r.id + ' item group : ' + item.ASI_Forecast_Item_Group__r.id);
                    tmpItem.debug='No reference budget';
                }
                tmpItem.lastModifedDate = item.LastModifiedDate.getTime();
                tmpItem.headerId=headerId+'';
                tmpItem.Id=item.id+'';
                tmpItem.period = item.ASI_Forecast__r.ASI_Forecast_Period__c+'';
                tmpItem.brandname = item.ASI_Forecast_Item_Group__r.ASI_CRM_TW_Brand__r.Name+'';
                tmpItem.category = item.ASI_Forecast_Item_Group__r.ASI_MFM_Sub_brand__r.ASI_HK_CRM_Product_Category__r.ASI_HK_CRM_English_Name__c+'';
                tmpItem.status = item.ASI_Forecast__r.ASI_Forecast_Status__c+'';
                tmpItem.skucode = item.ASI_Forecast_Item_Group__r.ASI_MFM_Item_Group_Code__c+'';
                tmpItem.skudesc = item.ASI_Forecast_Item_Group__r.name+'';
                tmpItem.channel = item.ASI_Forecast__r.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c+'';
                tmpItem.subchannel = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c+'';
                tmpItem.channelId = item.ASI_Forecast__r.ASI_Forecast_Channel__c+'';
                tmpItem.subchannelId = item.ASI_Forecast__r.ASI_Forecast_Sub_Channel__c+'';
                if(item.ASI_Forecast__r.ASI_Forecast_Region_tx__c!=null && item.ASI_Forecast__r.ASI_Forecast_Region_tx__c!=''){
                    tmpItem.region = item.ASI_Forecast__r.ASI_Forecast_Region_tx__c+'';
                } else {
                    tmpItem.region = '-';
                }
                tmpItem.refforecast = (item.ASI_Forecast_Ref_Item__c==null)?'':item.ASI_Forecast_Ref_Item__c+''; 
                tmpItem.refbudget = (item.ASI_Forecast_Ref_Budget_Item__c==null)?'':item.ASI_Forecast_Ref_Budget_Item__c+'';
                tmpItem.budget = budgetTotal;
                tmpItem.customer = item.ASI_Forecast__r.ASI_CRM_Customer__r.Name+'';
                tmpItem.itemgroup = item.ASI_Forecast_Item_Group__c+'';
                if(item.ASI_Forecast_P1__c!=null)tmpItem.p1 = item.ASI_Forecast_P1__c.doubleValue();
                if(item.ASI_Forecast_P2__c!=null)tmpItem.p2 = item.ASI_Forecast_P2__c.doubleValue();
                if(item.ASI_Forecast_P3__c!=null)tmpItem.p3 = item.ASI_Forecast_P3__c.doubleValue();
                if(item.ASI_Forecast_P4__c!=null)tmpItem.p4 = item.ASI_Forecast_P4__c.doubleValue();
                if(item.ASI_Forecast_P5__c!=null)tmpItem.p5 = item.ASI_Forecast_P5__c.doubleValue();
                if(item.ASI_Forecast_P6__c!=null)tmpItem.p6 = item.ASI_Forecast_P6__c.doubleValue();
                if(item.ASI_Forecast_P7__c!=null)tmpItem.p7 = item.ASI_Forecast_P7__c.doubleValue();
                if(item.ASI_Forecast_P8__c!=null)tmpItem.p8 = item.ASI_Forecast_P8__c.doubleValue();
                if(item.ASI_Forecast_P9__c!=null)tmpItem.p9 = item.ASI_Forecast_P9__c.doubleValue();
                if(item.ASI_Forecast_P10__c!=null)tmpItem.p10 = item.ASI_Forecast_P10__c.doubleValue();
                if(item.ASI_Forecast_P11__c!=null)tmpItem.p11 = item.ASI_Forecast_P11__c.doubleValue();
                if(item.ASI_Forecast_P12__c!=null)tmpItem.p12 = item.ASI_Forecast_P12__c.doubleValue();
                
                try {
                    ASI_Forecast_Item__c prevForecastItem = forecastSummaryMap.get(item.ASI_Forecast__r.ASI_CRM_Customer__r.id).get(item.ASI_Forecast_Item_Group__r.id);
                    if(tmpItem.refforecast=='') tmpItem.refforecast = prevForecastItem.Id;
                    assignForecastPeriod(tmpItem, prevForecastItem);
                } catch(Exception e) {
                    System.debug('No prev forecsst : ' + item.ASI_Forecast__r.ASI_CRM_Customer__r.id + ' item group : ' + item.ASI_Forecast_Item_Group__r.id);
                }
                try {
                    ASI_Forecast_Item__c prevForecastItem = forecastSummaryMap.get(item.ASI_Forecast__r.ASI_CRM_Customer__r.id).get(item.ASI_Forecast_Item_Group__r.id);
                    if(tmpItem.refforecast=='') tmpItem.refforecast = prevForecastItem.Id;
                    assignForecastSecondPeriod(tmpItem, prevForecastItem);
                } catch(Exception e) {
                    System.debug('No budget : ' + item.ASI_Forecast__r.ASI_CRM_Customer__r.id + ' item group : ' + item.ASI_Forecast_Item_Group__r.id);
                }
                try {
                    ASI_Forecast_Item__c budgetItem = budgetSummaryMap.get(item.ASI_Forecast__r.ASI_CRM_Customer__r.id).get(item.ASI_Forecast_Item_Group__r.id);
                    if(tmpItem.refbudget=='') tmpItem.refbudget = budgetItem.Id;
                    assignBudgetPeriod(tmpItem, budgetItem);
                } catch(Exception e) {
                    System.debug('No budget : ' + item.ASI_Forecast__r.ASI_CRM_Customer__r.id + ' item group : ' + item.ASI_Forecast_Item_Group__r.id);
                }
                
                handleNullPeriod(tmpItem);
                
                if (forecastStatus == 'Draft') {
                    resultList.add(tmpItem);
                } else if(forecastStatus == 'Processing'){
                    procressingList.add(tmpItem);
                } else {
                    submitList.add(tmpItem);
                }
            }
        }
        system.debug('resultList: '+ JSON.serialize(resultList));
        system.debug('submitList: '+ JSON.serialize(submitList));
        system.debug('procressingList: '+ JSON.serialize(procressingList));
        

        isProcressing = (procressingList.size() > 0);

        String jsonstring = JSON.serializepretty(new Map<String, List<ASI_Forecast_TW_Input_Item>>{'Submitted'=>submitList, 'Draft'=>resultList, 'Procressing'=>procressingList});
        String jsonModified = jsonstring.replace('\r\n', '');
        jsonModified = jsonModified.replace('\n', '');
        jsonModified = jsonModified.replace('\r', '');
        dataSet = jsonModified;
        
    }
    @TestVisible
    private void handleNullPeriod(ASI_Forecast_TW_Input_Item inputItem){
        if(inputItem.p1 == null) inputItem.p1 = 0;
        if(inputItem.p2 == null) inputItem.p2 = 0;
        if(inputItem.p3 == null) inputItem.p3 = 0;
        if(inputItem.p4 == null) inputItem.p4 = 0;
        if(inputItem.p5 == null) inputItem.p5 = 0;
        if(inputItem.p6 == null) inputItem.p6 = 0;
        if(inputItem.p7 == null) inputItem.p7 = 0;
        if(inputItem.p8 == null) inputItem.p8 = 0;
        if(inputItem.p9 == null) inputItem.p9 = 0;
        if(inputItem.p10 == null) inputItem.p10 = 0;
        if(inputItem.p11 == null) inputItem.p11 = 0;
        if(inputItem.p12 == null) inputItem.p12 = 0;
    }
	@TestVisible
    private void assignForecastPeriod(ASI_Forecast_TW_Input_Item inputItem, ASI_Forecast_Item__c prevForecastItem){
        if(inputItem.p1 == null) inputItem.p1 = prevForecastItem.ASI_Forecast_P2__c;
        if(inputItem.p2 == null) inputItem.p2 = prevForecastItem.ASI_Forecast_P3__c;
        if(inputItem.p3 == null) inputItem.p3 = prevForecastItem.ASI_Forecast_P4__c;
        if(inputItem.p4 == null) inputItem.p4 = prevForecastItem.ASI_Forecast_P5__c;
        if(inputItem.p5 == null) inputItem.p5 = prevForecastItem.ASI_Forecast_P6__c;
        if(inputItem.p6 == null) inputItem.p6 = prevForecastItem.ASI_Forecast_P7__c;
    }
    @TestVisible
    private void assignForecastSecondPeriod(ASI_Forecast_TW_Input_Item inputItem, ASI_Forecast_Item__c prevForecastItem){
        if(inputItem.p7 == null) inputItem.p7 = prevForecastItem.ASI_Forecast_P8__c;
        if(inputItem.p8 == null) inputItem.p8 = prevForecastItem.ASI_Forecast_P9__c;
        if(inputItem.p9 == null) inputItem.p9 = prevForecastItem.ASI_Forecast_P10__c;
        if(inputItem.p10 == null) inputItem.p10 = prevForecastItem.ASI_Forecast_P11__c;
        if(inputItem.p11 == null) inputItem.p11 = prevForecastItem.ASI_Forecast_P12__c;
//        if(inputItem.p12 == null) inputItem.p12 = prevForecastItem.ASI_Forecast_P1__c;
    }
    private void assignBudgetPeriod(ASI_Forecast_TW_Input_Item inputItem, ASI_Forecast_Item__c budgetItem){
        Integer month = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST.month();
        //if(inputItem.p1 == null) inputItem.p1 = getBudgetPeriod(budgetItem, month-1);
        //if(inputItem.p2 == null) inputItem.p2 = getBudgetPeriod(budgetItem, month);
        //if(inputItem.p3 == null) inputItem.p3 = getBudgetPeriod(budgetItem, month+1);
        //if(inputItem.p4 == null) inputItem.p4 = getBudgetPeriod(budgetItem, month+2);
        //if(inputItem.p5 == null) inputItem.p5 = getBudgetPeriod(budgetItem, month+3);
        //if(inputItem.p6 == null) inputItem.p6 = getBudgetPeriod(budgetItem, month+4);
        
        if(inputItem.p7 == null) inputItem.p7 = getBudgetPeriod(budgetItem, month+5);
        if(inputItem.p8 == null) inputItem.p8 = getBudgetPeriod(budgetItem, month+6);
        if(inputItem.p9 == null) inputItem.p9 = getBudgetPeriod(budgetItem, month+7);
        if(inputItem.p10 == null) inputItem.p10 = getBudgetPeriod(budgetItem, month+8);
        if(inputItem.p11 == null) inputItem.p11 = getBudgetPeriod(budgetItem, month+9);
        if(inputItem.p12 == null) inputItem.p12 = getBudgetPeriod(budgetItem, month+10);
    }
    @TestVisible
    private Double getBudgetPeriod(ASI_Forecast_Item__c budgetItem, Integer month){
        Integer orgFiscalMonth = ASI_CRM_TW_Forecast_Util.FISCAL_YEAR_MONTH;
        Integer periodTarget =   Math.mod((month+orgFiscalMonth), 12);
        if(periodTarget==0) return budgetItem.ASI_Forecast_P12__c;
        if(periodTarget==1) return budgetItem.ASI_Forecast_P1__c;
        if(periodTarget==2) return budgetItem.ASI_Forecast_P2__c;
        if(periodTarget==3) return budgetItem.ASI_Forecast_P3__c;
        if(periodTarget==4) return budgetItem.ASI_Forecast_P4__c;
        if(periodTarget==5) return budgetItem.ASI_Forecast_P5__c;
        if(periodTarget==6) return budgetItem.ASI_Forecast_P6__c;
        if(periodTarget==7) return budgetItem.ASI_Forecast_P7__c;
        if(periodTarget==8) return budgetItem.ASI_Forecast_P8__c;
        if(periodTarget==9) return budgetItem.ASI_Forecast_P9__c;
        if(periodTarget==10) return budgetItem.ASI_Forecast_P10__c;
        if(periodTarget==11) return budgetItem.ASI_Forecast_P11__c;
        return 0;
    }
    
    @RemoteAction
    global static Map<String,String> saveForecast(string dataSet) {        
        List<ASI_Forecast_Item__c> itemList = new List<ASI_Forecast_Item__c>();
        List<Object> dataList = (List<Object>)JSON.deserializeUntyped(dataSet);
        Set<Id> updateItemIdSet = new Set<Id>();
        Long lastModifyTimeStamp;
        system.debug(dataList);
        for(Object dataObj : dataList) {
            Map<String,Object> dataMap = (Map<String,Object>)dataObj;
            Id itemId = (Id)dataMap.get('Id');
            Long modifyTime = (Long)dataMap.get('lastModifedDate');
            if(modifyTime!=null) {
                lastModifyTimeStamp = (lastModifyTimeStamp>modifyTime) ? lastModifyTimeStamp:modifyTime;
            }
            updateItemIdSet.add(itemId);
            ASI_Forecast_Item__c item = new ASI_Forecast_Item__c(
                Id = itemId,
                ASI_Forecast_P1__c = Double.valueof(dataMap.get('p1')),
                ASI_Forecast_P2__c = Double.valueof(dataMap.get('p2')),
                ASI_Forecast_P3__c = Double.valueof(dataMap.get('p3')),
                ASI_Forecast_P4__c = Double.valueof(dataMap.get('p4')),
                ASI_Forecast_P5__c = Double.valueof(dataMap.get('p5')),
                ASI_Forecast_P6__c = Double.valueof(dataMap.get('p6')),
                ASI_Forecast_P7__c = Double.valueof(dataMap.get('p7')),
                ASI_Forecast_P8__c = Double.valueof(dataMap.get('p8')),
                ASI_Forecast_P9__c = Double.valueof(dataMap.get('p9')),
                ASI_Forecast_P10__c = Double.valueof(dataMap.get('p10')),
                ASI_Forecast_P11__c = Double.valueof(dataMap.get('p11')),
                ASI_Forecast_P12__c = Double.valueof(dataMap.get('p12'))
            );
            if(dataMap.get('refforecast')!='') {
                item.ASI_Forecast_Ref_Item__c  = (Id)dataMap.get('refforecast');
            }
            if(dataMap.get('refbudget')!='') {
                item.ASI_Forecast_Ref_Budget_Item__c  = (Id)dataMap.get('refbudget');
            }
            itemList.add(item);
        }
        Map<String,String> resultMap = new Map<String,String>();
        List<ASI_Forecast_Item__c> serverItemList = [SELECT id, LastModifiedDate 
                                                     FROM ASI_Forecast_Item__c
                                                     WHERE id IN :updateItemIdSet
                                                     ];
        for(ASI_Forecast_Item__c serverItem : serverItemList) {
            if(serverItem.LastModifiedDate.getTime() > lastModifyTimeStamp) {
                resultMap.put('result', 'false');
                resultMap.put('message', 'Forecast lock due to another update, Please Refresh');
                return resultMap;

            }
        }
        update (itemList);
        resultMap.put('result', 'true');
        resultMap.put('message', 'Success Save');
        return resultMap;
    }
    
    @RemoteAction
    global static Map<String,String> submitForecast(string dataSet) {
        Set<Id>headerIdSet = new Set<Id>();
        Set<Id>nonApprovalheaderIdSet = new Set<Id>();
        Set<String>channelSet = new Set<String>();
        Set<Id>subChannelIdSet = new Set<Id>();
        Set<Id> updateItemIdSet = new Set<Id>();
        Long lastModifyTimeStamp;
        List<ASI_Forecast_Item__c> itemList = new List<ASI_Forecast_Item__c>();
        List<Object> dataList = (List<Object>)JSON.deserializeUntyped(dataSet);
        for(Object dataObj : dataList) {
            Map<String,Object> dataMap = (Map<String,Object>)dataObj;
			channelSet.add((String)dataMap.get('channel'));
            subChannelIdSet.add((Id)dataMap.get('subchannelId'));
        }
        Map<Id,Boolean> subChSkipApprovalMap = ASI_CRM_TW_Forecast_Util.checkSkipApprovalBySubChId(subChannelIdSet);
        
        
        for(Object dataObj : dataList) {
            Map<String,Object> dataMap = (Map<String,Object>)dataObj;
            Id subChannlId = (Id)dataMap.get('subchannelId');
            if(subChSkipApprovalMap.get(subChannlId)) {
                nonApprovalheaderIdSet.add((Id)dataMap.get('headerId'));
            } else {
	            headerIdSet.add((Id)dataMap.get('headerId'));
            }
            Id itemId = (Id)dataMap.get('Id');
            Long modifyTime = (Long)dataMap.get('lastModifedDate');
            if(modifyTime!=null) {
                lastModifyTimeStamp = (lastModifyTimeStamp>modifyTime) ? lastModifyTimeStamp:modifyTime;
            }
            updateItemIdSet.add(itemId);

            ASI_Forecast_Item__c item = new ASI_Forecast_Item__c(
                Id = (Id)dataMap.get('Id'),
                ASI_Forecast_P1__c = Double.valueof(dataMap.get('p1')),
                ASI_Forecast_P2__c = Double.valueof(dataMap.get('p2')),
                ASI_Forecast_P3__c = Double.valueof(dataMap.get('p3')),
                ASI_Forecast_P4__c = Double.valueof(dataMap.get('p4')),
                ASI_Forecast_P5__c = Double.valueof(dataMap.get('p5')),
                ASI_Forecast_P6__c = Double.valueof(dataMap.get('p6')),
                ASI_Forecast_P7__c = Double.valueof(dataMap.get('p7')),
                ASI_Forecast_P8__c = Double.valueof(dataMap.get('p8')),
                ASI_Forecast_P9__c = Double.valueof(dataMap.get('p9')),
                ASI_Forecast_P10__c = Double.valueof(dataMap.get('p10')),
                ASI_Forecast_P11__c = Double.valueof(dataMap.get('p11')),
                ASI_Forecast_P12__c = Double.valueof(dataMap.get('p12'))
            );
            if(dataMap.get('refforecast')!='') {
                item.ASI_Forecast_Ref_Item__c  = (Id)dataMap.get('refforecast');
            }
            if(dataMap.get('refbudget')!='') {
                item.ASI_Forecast_Ref_Budget_Item__c  = (Id)dataMap.get('refbudget');
            }
            itemList.add(item);
        }
        
        Map<String,String> resultMap = new Map<String,String>();
        List<ASI_Forecast_Item__c> serverItemList = [SELECT id, LastModifiedDate 
                                                     FROM ASI_Forecast_Item__c
                                                     WHERE id IN :updateItemIdSet
                                                     ];
        for(ASI_Forecast_Item__c serverItem : serverItemList) {
            if(serverItem.LastModifiedDate.getTime() > lastModifyTimeStamp) {
                resultMap.put('result', 'false');
                resultMap.put('message', 'Forecast lock due to another update, Please Refresh');
                return resultMap;

            }
        }
        
        ASI_CRM_TW_Forecast_Util.updateForecastStatus(headerIdSet, 'Submitted');
        ASI_CRM_TW_Forecast_Util.updateForecastStatus(nonApprovalheaderIdSet, 'Final');
        update (itemList);
        
        Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchForecastApproverByChannelCode(channelSet);
        String chStr = String.join(new List<String>(channelSet), ', ');
        ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>(emailList), '', chStr, '', 'ASI_Forecast_TW_Submitted_HTML', 'ASI_Forecast_TW_MassApprovePage');
        SYSTEM.debug('pending sent mail list : ' + emailList);
        
        resultMap.put('result', 'true');
        resultMap.put('message', 'Success Save');
        return resultMap;
        
    }
    
    @TestVisible
    private class ASI_Forecast_TW_Input_Item {
        public Long lastModifedDate=0;
        public String debug='';
        public String headerId='';
        public String period='';
        public String refforecast='';
        public String refbudget='';
        public String Id='';
        public String brandname='';
        public String category='';
        public String status='';
        public String skucode='';
        public String skudesc='';
        public String channel='';
        public String subchannel='';
        public String channelId='';
        public String subchannelId='';        
        public String region='';
        public String customer='';
        public Double budget=0;
        public String itemgroup='';
		public Double p1=null;
		public Double p2=null;
		public Double p3=null;
		public Double p4=null;
		public Double p5=null;
		public Double p6=null;
		public Double p7=null;
		public Double p8=null;
		public Double p9=null;
		public Double p10=null;
		public Double p11=null;
		public Double p12=null;
	}
}