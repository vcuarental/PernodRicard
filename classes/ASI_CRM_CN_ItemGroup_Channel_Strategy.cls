/**********************************************************************
 * 
 *
 * @url: /services/apexrest/ASI_CRM_CN_ItemGroup_Channel_Strategy
 * @data:
 *  {
        "LastModified_Dt_from": "2010-01-01 00:00:00",
        "LastModified_Dt_to": "2020-08-30 00:00:00",
        "SellinRegion":["CENTRAL","SOUTH","NORTH","SOUTH WEST","EAST","NORTH WEST","HQ"],
        "SellinChannel":["MACON","PT_WS","PT_VIP","PT_TOT","MOT_WS","PT_AIR"]
    }
*************************************************************************/
@RestResource(urlMapping='/ASI_CRM_CN_ItemGroup_Channel_Strategy')
global without sharing class ASI_CRM_CN_ItemGroup_Channel_Strategy {
    @HttpPost
    global static ResponeInfo doPost() {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        requestInfo data = (requestInfo)JSON.deserializeStrict(body.toString(), requestInfo.class);
        ResponeInfo info = new ResponeInfo();
        List<String> channelList = data.sellinChannel;
        List<String> regionList = regionChange(data.sellinRegion);
        System.debug(LoggingLevel.INFO, '*** regionList: ' + regionList);
        System.debug(LoggingLevel.INFO, '*** channelList: ' + channelList);        
       	List<String> excludedRegions = System.Label.ASI_CRM_CN_ItemGroup_Channel_Excluded_Regions.split(',');    
		List<String> regionsStr = new List<String>();
		Schema.DescribeFieldResult fieldResultRegion = ASI_CRM_CN_Channel_Strategy_Line_Item__c.ASI_NPL_Region__c.getDescribe();
		List<Schema.PicklistEntry> pleRegion = fieldResultRegion.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : pleRegion){    
		    if (!excludedRegions.contains(pickListVal.getValue()) ) {
		        regionsStr.add(pickListVal.getValue());
		    }               
		}
        String sql = '';

        try{
            sql = 'SELECT id'
                + ' ,ASI_MFM_Sell_In_Region__c'
                + ' ,ASI_MFM_Sell_In_Channel__c'
                + ' ,ASI_MFM_Intake_Channel__c'
                + ' ,ASI_MFM_Intake_Sub_Channel__c'
                + ' ,ASI_MFM_Intake_Region__c'
                + ' FROM ASI_MFM_Channel_Mapping__c';
            if ((data.sellinChannel != null && data.sellinChannel.size() > 0) && (regionList == null || regionList.size() <= 0)) {
                sql += ' WHERE (ASI_MFM_Sell_In_Channel__c in: channelList OR ASI_MFM_Sell_In_Channel__c = \'All\')';
            }
            if ((regionList != null && regionList.size() > 0) && (data.sellinChannel == null || data.sellinChannel.size() <= 0) ){
                sql += ' WHERE (ASI_MFM_Sell_In_Region__c in:regionList OR ASI_MFM_Sell_In_Region__c = \'All\')';
            }
            if ((regionList != null && regionList.size() > 0) && (data.sellinChannel != null && data.sellinChannel.size() > 0)) {
                sql += ' WHERE (ASI_MFM_Sell_In_Channel__c in: channelList OR ASI_MFM_Sell_In_Channel__c = \'All\')'
                    + ' AND (ASI_MFM_Sell_In_Region__c in:regionList OR ASI_MFM_Sell_In_Region__c = \'All\')';
            }
            List<ASI_MFM_Channel_Mapping__c> cmList = Database.query(sql);
            
            System.debug(LoggingLevel.INFO, '*** cmList.size(): ' + cmList.size());
            if (cmList.size() == 0) {
                info.errorMsg = '未搜索到相关记录';
                info.success = false;
                info.totalSize = 0;
                info.dataInfos = new List<DataInfo>();
                return info;
            }
            //Map<Intake_Channel+Intake Sub-Channel,List<Map<Intake Region,Mapping>>>
            Map<String,Map<String,List<ASI_MFM_Channel_Mapping__c>>> key_keyCMMap = new Map<String,Map<String,List<ASI_MFM_Channel_Mapping__c>>>();
            //Map<Intake_Channel+Intake Sub-Channel,List<Mapping>>
            Map<String,List<ASI_MFM_Channel_Mapping__c>> regMap = new Map<String,List<ASI_MFM_Channel_Mapping__c>>();

            for (ASI_MFM_Channel_Mapping__c cm : cmList) {
                String key1 = cm.ASI_MFM_Intake_Channel__c + ',' + cm.ASI_MFM_Intake_Sub_Channel__c;    
                List<ASI_MFM_Channel_Mapping__c> s_cmList = regMap.get(key1);
                if (s_cmList == null) {
                    s_cmList = new List<ASI_MFM_Channel_Mapping__c>();
                    regMap.put(key1 , s_cmList);
                }
                s_cmList.add(cm);
            }
            System.debug(LoggingLevel.INFO, '*** regMap.values().size(): ' + regMap.values().size());
            for (String key : regMap.keySet()) {
                Map<String,List<ASI_MFM_Channel_Mapping__c>> key_CMMap =  key_keyCMMap.get(key);
                if (key_CMMap == null) {
                    key_CMMap = new Map<String,List<ASI_MFM_Channel_Mapping__c>>();

                    key_keyCMMap.put(key, key_CMMap);
                }
                for (ASI_MFM_Channel_Mapping__c cm : regMap.get(key)) {
                    List<ASI_MFM_Channel_Mapping__c> ss_cmList = key_CMMap.get(cm.ASI_MFM_Intake_Region__c);
                    if (ss_cmList == null) {
                        ss_cmList = new List<ASI_MFM_Channel_Mapping__c>();
                        key_CMMap.put(cm.ASI_MFM_Intake_Region__c, ss_cmList);
                    }
                    ss_cmList.add(cm);
                }
            }  
            System.debug(LoggingLevel.INFO, '*** key_keyCMMap.values().size(): ' + key_keyCMMap.values().size());
            List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> itemList = [SELECT Id,ASI_NPL_Channel__c,LastModifiedDate
                                                                        ,ASI_CRM_CN_Channel_Strategy__c
                                                                        ,ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Vision__c
                                                                        ,ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Item_Group__r.Name
                                                                        ,ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Item_Group_Code__c                
                                                                        ,ASI_NPL_Sub_Channel__c,ASI_NPL_Region__c,ASI_NPL_Version__c
                                                        FROM ASI_CRM_CN_Channel_Strategy_Line_Item__c 
                                                        WHERE  ASI_NPL_Type__c = 'Sub-Channel Entitlement' 
                                                        AND ASI_NPL_Entitled__c  = true
                                                        AND ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Item_Group__c != null
                                                        AND LastModifiedDate <=: Datetime.valueOf(data.lastModified_Dt_to)
                                                        AND LastModifiedDate >=: Datetime.valueOf(data.lastModified_Dt_from)];
            if (itemList.size() == 0) {
                info.errorMsg = '未搜索到相关记录';
                info.success = false;
                info.totalSize = 0;
                info.dataInfos = new List<DataInfo>();
                return info;
            } 
            List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> item_finallyList = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
            for ( String key : key_keyCMMap.keySet() ) {
                for ( ASI_CRM_CN_Channel_Strategy_Line_Item__c item : itemList ) {
                    String key_itme_1 = item.ASI_NPL_Channel__c +','+ item.ASI_NPL_Sub_Channel__c;
                    if (key == key_itme_1 && item.ASI_NPL_Version__c == item.ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Vision__c) {
                        item_finallyList.add(item);                   
                    }
                }
            }          
            Map<String, List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>> item_finallyMap = new Map<String, List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>>();
            for (ASI_CRM_CN_Channel_Strategy_Line_Item__c item : item_finallyList) {
                String key = item.ASI_NPL_Channel__c+','+item.ASI_NPL_Sub_Channel__c;
                List<ASI_CRM_CN_Channel_Strategy_Line_Item__c> item_twoList = item_finallyMap.get(key);
                if (item_twoList == null) {
                    item_twoList = new List<ASI_CRM_CN_Channel_Strategy_Line_Item__c>();
                    item_finallyMap.put(key, item_twoList);
                }
                item_twoList.add(item);
            }
            System.debug(LoggingLevel.INFO, '*** item_finallyMap.values().size(): ' + item_finallyMap.values().size());
            if (item_finallyMap != null) {
                info.errorMsg = '';
                info.success = true;
                info.dataInfos = new List<DataInfo>();
                Map<String,DateTime> dataInfoMap = new Map<String,DateTime>();
                for (String itemkey : item_finallyMap.keySet()) {
                    for (ASI_CRM_CN_Channel_Strategy_Line_Item__c item: item_finallyMap.get(itemkey)) {
                        if (item.ASI_NPL_Region__c == null || item.ASI_NPL_Region__c == '') continue;
                        for (String reg : key_keyCMMap.get(itemkey).keySet()) {
                            
                            if (item.ASI_NPL_Region__c.contains(reg) || item.ASI_NPL_Region__c == 'All' || reg == 'All') {
                                for (ASI_MFM_Channel_Mapping__c mapping :  key_keyCMMap.get(itemkey).get(reg)) {
                                    if (mapping != null) {                                      
                                        if (reg == 'All') {
                                            for (String strReg : regionsStr) {
                                                String key = item.ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Item_Group__r.Name + ',' 
                                                    +item.ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Item_Group_Code__c + ','
                                                    +mapping.ASI_MFM_Sell_In_Channel__c + ','
                                                    +regionChange2(strReg);

                                                if (!dataInfoMap.containsKey(key)) {
                                                    dataInfoMap.put(key, item.LastModifiedDate);
                                                }else{
                                                    if (dataInfoMap.get(key) <= item.LastModifiedDate) {
                                                        dataInfoMap.put(key,item.LastModifiedDate);
                                                    }
                                                }
                                            }
                                        }else{
                                            String key = item.ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Item_Group__r.Name + ',' 
                                                    +item.ASI_CRM_CN_Channel_Strategy__r.ASI_NPL_Item_Group_Code__c + ','
                                                    +mapping.ASI_MFM_Sell_In_Channel__c + ','
                                                    +regionChange2(mapping.ASI_MFM_Sell_In_Region__c);
                                            if (!dataInfoMap.containsKey(key)) {
                                                dataInfoMap.put(key, item.LastModifiedDate);
                                            }else{
                                                if (dataInfoMap.get(key) <= item.LastModifiedDate) {
                                                    dataInfoMap.put(key,item.LastModifiedDate);
                                                }
                                            }
                                        }                                        
                                    }
                                } 
                            }
                        }                        
                    }
                }
                for (String str : dataInfoMap.keySet()) {
                    DataInfo dataInfo = new DataInfo();
                    dataInfo.itemGroupName = str.split(',')[0];
                    dataInfo.itemGroupCode = str.split(',')[1];
                    dataInfo.sellInChannel =str.split(',')[2];
                    dataInfo.sellinRegion = str.split(',')[3];
                    dataInfo.lastModifyDate = String.valueOf(dataInfoMap.get(str));
                    info.dataInfos.add(dataInfo);
                }
                info.totalSize = info.dataInfos.size();
            }else{
                info.errorMsg = '未搜索到相关记录';
                info.success = false;
                info.totalSize = 0;
                info.dataInfos = new List<DataInfo>();
            }       
            RestResponse res = RestContext.Response;
            res.statusCode=200;
        }catch(Exception e){
            info.errorMsg = '发生未知错误！请将错误信息提供给系统管理员进行处理：'+e.getMessage()+'|||'+e.getLineNumber();
            info.success = false;
            info.totalSize = 0;
            info.dataInfos = new List<DataInfo>();
        }     
        
        return info;
    }
    private static List<String> regionChange(List<String> regions){
        List<String> new_regions = new List<String>();
        for(String reg : regions){
            if (reg == 'SOUTH WEST') { reg = 'SW'; }else if(reg == 'NORTH WEST'){ reg = 'NW'; }
            new_regions.add(reg);
        }
        return new_regions;
    }
    private static String regionChange2(String region){
        if (region == 'SW') {
            region = 'SOUTH WEST';
        }else if(region == 'NW'){
                region = 'NORTH WEST';
            }
        return region.toUpperCase();
    }
    global class ResponeInfo{
        global Integer totalSize;
        global String errorMsg;
        global Boolean success;
        global List<DataInfo> dataInfos;
    }
    global class DataInfo{
        global String itemGroupName;
        global String itemGroupCode;
        global String sellInChannel;
        global String sellInRegion;
        global String lastModifyDate;
    }
    global class requestInfo{
        global String lastModified_Dt_from;
        global String lastModified_Dt_to;
        global List<String> sellinChannel;
        global List<String> sellinRegion;
    }

}