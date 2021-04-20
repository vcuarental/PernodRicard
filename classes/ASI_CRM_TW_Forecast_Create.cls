global without sharing class ASI_CRM_TW_Forecast_Create {
    
    public static Integer getBatchCount() {
        List<AsyncapexJob> jobList = [SELECT Id, ApexClassID, Status 
                                      FROM AsyncapexJob 
                                      WHERE ApexClassId IN (Select Id from ApexClass where Name = 'ASI_Forecast_TW_BatchCreate')
                                      AND Status != 'Aborted'
                                      AND Status != 'Completed'
                                      AND Status != 'Failed'];
        return jobList.size();
    }
    
    public static void presetSCA_cust(Set<String> idSet) {
        List<String> idList = new List<String>(idSet);
        List<Account> accountWithoutAdditionFieldList = new List<Account>();
        List<Id> idForUpdateAccAddList = new List<Id>();
        List<ASI_CRM_AccountsAdditionalField__c> acAdditionalList = new List<ASI_CRM_AccountsAdditionalField__c>();
        List<String> updatedCustomerList = new List<String>();
        idList.sort();
        List<ASI_CRM_AccountsAdditionalField__c> accAdditionList = new List<ASI_CRM_AccountsAdditionalField__c>();
        List<Account> acList = [SELECT id, name, (SELECT id,name,ASI_CRM_Is_SCA_Customer__c FROM ASI_CRM_Accounts_Additional_Fields__r), ASI_HK_CRM_JDE_Account_Number__c FROM Account WHERE ASI_HK_CRM_JDE_Account_Number__c IN :idList];
        for(Account acc : acList) {
            if(idList.contains(acc.ASI_HK_CRM_JDE_Account_Number__c)) {
                Integer index = idList.indexOf(acc.ASI_HK_CRM_JDE_Account_Number__c);
                idList.remove(index);
                if(acc.ASI_CRM_Accounts_Additional_Fields__r==null || acc.ASI_CRM_Accounts_Additional_Fields__r.size()==0) {
                    accountWithoutAdditionFieldList.add(acc);
                    continue;
                }
                for(ASI_CRM_AccountsAdditionalField__c addacc : acc.ASI_CRM_Accounts_Additional_Fields__r) {
                    acAdditionalList.add(new ASI_CRM_AccountsAdditionalField__c(id=addacc.id, ASI_CRM_Is_SCA_Customer__c=true));
                    idForUpdateAccAddList.add(addacc.id);
                    updatedCustomerList.add(acc.ASI_HK_CRM_JDE_Account_Number__c);
                }
                accAdditionList.addAll(acc.ASI_CRM_Accounts_Additional_Fields__r);
            }
        }
        
//        update acAdditionalList;
        System.debug('customers not found : ' + JSON.serialize(idList) + ' count : ' + idList.size());
        System.debug('idForUpdateAccAddList : ' + JSON.serialize(idForUpdateAccAddList));
        System.debug('update success : ' + JSON.serialize(updatedCustomerList));
    }
	public static ASI_CRM_AccountsAdditionalField__c[] getScaCustomer() {
        ASI_CRM_AccountsAdditionalField__c[] custList = [
            SELECT id, name, ASI_CRM_Region__c,
            		ASI_CRM_Channel__c, ASI_CRM_Channel__r.ASI_CRM_CN_Channel_Code__c,
            		ASI_CRM_CN_Sub_Channel__c, ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Sub_Channel_Code__c,
            		ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c, ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__r.ASI_CRM_CN_Channel_Code__c
			FROM ASI_CRM_AccountsAdditionalField__c
			WHERE ASI_CRM_Is_SCA_Customer__c = true
            AND RecordType.DeveloperName LIKE 'ASI_CRM_TW%'
        ];
        return custList;
    }
    
    public static List<ASI_Forecast__c> createBudgetHeader() { return createHeader(getScaCustomer(), false); }
    public static List<ASI_Forecast__c> createForecastHeader() { return createHeader(getScaCustomer(), true); }
    static List<ASI_Forecast__c> createHeader(ASI_CRM_AccountsAdditionalField__c[] custList, boolean isForecast) {
        String strType   = isForecast ? 'Forecast':'Budget';
        String strStatus = 'Processing';
        Id recordTypeId = Schema.SObjectType.ASI_Forecast__c.getRecordTypeInfosByName().get('TW Forecast').getRecordTypeId();
		Date periodDate;
        if (isForecast) {
            periodDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST.addMonths(1);
        } else {
            periodDate = ASI_CRM_TW_Forecast_Util.CURR_MONTH_BUDGET.addYears(1);
        }
        
        ASI_Forecast__c[] forecastList = new List<ASI_Forecast__c>();
        List<ASI_Forecast__c> currForecastList = [SELECT id
                                                  FROM ASI_Forecast__c
                                                  WHERE ASI_Forecast_Period_Date__c=:periodDate
                                                  AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                                                  AND ASI_Forecast_Type__c=:strType];
        if(currForecastList.size()>0) {
            return forecastList;
        }
        
        Map<Id,Map<Id,Map<String,Id>>> fOwnerMap = searchForecastOwner();
        for(ASI_CRM_AccountsAdditionalField__c cust : custList) {
            Id channel = cust.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c;
            Id subchannel = cust.ASI_CRM_CN_Sub_Channel__c;
            String region = cust.ASI_CRM_Region__c;
            Id fOwner = null;
            if(channel!=null && subchannel!=null && region!=null && region!=''){
                Map<Id,Map<String,Id>> subChMap = fOwnerMap.get(channel);
                Map<String,Id> regionMap;
                if(subChMap!=null) regionMap = subChMap.get(subchannel);
                if(regionMap!=null) fOwner = regionMap.get(region);
            } else {
                continue;
            }
            ASI_Forecast__c forecast = new ASI_Forecast__c(
                ASI_CRM_Customer__c 		= cust.id,
                ASI_Forecast_Sub_Channel__c = cust.ASI_CRM_CN_Sub_Channel__c,
                ASI_Forecast_Channel__c  	= cust.ASI_CRM_CN_Sub_Channel__r.ASI_CRM_CN_Channel__c,
                ASI_Forecast_Status__c 		= strStatus,
                ASI_Forecast_Type__c 		= strType,
                ASI_Forecast_Period_Date__c = periodDate
            );
            if(fOwner!=null) {
                forecast.OwnerId = fOwner;
            }
            forecast.RecordTypeId = recordTypeId;
            forecastList.add(forecast);
        }
        if(forecastList.size()>0) {
            insert forecastList;
        }
        return forecastList;
    }
    
    public static void forecastBatchSetToDraft(Set<Id> fIdSet){
        List<ASI_Forecast__c> fList = new List<ASI_Forecast__c>();
        for(Id fid: fIdSet){
            ASI_Forecast__c f = new ASI_Forecast__c(Id=fid);
        	f.ASI_Forecast_Status__c = 'Draft';
            fList.add(f);
        }
        update fList;
    }
    
    webservice static void forecastSetToDraft(Id forecastId){
        forecastBatchSetToDraft(new Set<Id>{forecastId});
//        ASI_Forecast__c f = new ASI_Forecast__c(Id=forecastId);
//        f.ASI_Forecast_Status__c  = 'Draft';
//        update f;
    }
    
    webservice static String applyNewItemToCurrentForecast(Id itemGroupId){
        ASI_MFM_Item_Group__c itemGroup = [SELECT id, ASI_CRM_Applied_To_Forecast__c 
                                           FROM ASI_MFM_Item_Group__c 
                                           WHERE ID=:itemGroupId 
                                           AND RecordType.DeveloperName Like 'ASI_MFM_TW_Item_Group'
                                           LIMIT 1];
        Set<String> channelCodeSet = new Set<String>();
        Map<String, Boolean> channelMailMap = new Map<String, Boolean>();
        for(String chCode : itemGroup.ASI_CRM_Applied_To_Forecast__c.split(';')) {
            channelCodeSet.add(chCode);
            channelMailMap.put(chCode, false);
        }
        
        system.debug('channel code : '+channelCodeSet);
		Id recordTypeId = Schema.SObjectType.ASI_Forecast_Item__c .getRecordTypeInfosByName().get('TW Forecast Item').getRecordTypeId();
        Date startOfMonth  = ASI_CRM_TW_Forecast_Util.CURR_MONTH_FORECAST;
        Date startOfNextMonth = startOfMonth.addMonths(1);
        Set<Id> submittedHeaderIdSet = new Set<Id>();
        Set<Id> finalHeaderIdSet = new Set<Id>();
        Set<String> submittedHeaderChCodeSet = new Set<String>();
        Set<String> finalHeaderChCodeSet = new Set<String>();
        List<ASI_Forecast_Item__c> forecastItemList = new List<ASI_Forecast_Item__c>();
        for(ASI_Forecast__c forecast : [SELECT id, name, ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c, ASI_Forecast_Status__c,
                                        (SELECT id FROM ASI_Forecast_Item__r WHERE ASI_Forecast_Item_Group__c = :itemGroupId)
                                        FROM ASI_Forecast__c
                                        WHERE ASI_Forecast_Type__c = 'Forecast'
                                        AND ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c IN :channelCodeSet
                                        AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
                                        AND ASI_Forecast_Period_Date__c >= :startOfMonth 
                                        AND ASI_Forecast_Period_Date__c < :startOfNextMonth]) {
			String status = forecast.ASI_Forecast_Status__c;
            if(status=='Submitted') {
                submittedHeaderIdSet.add(forecast.id);
                submittedHeaderChCodeSet.add(forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c);
            } else if(status=='Final') {
                finalHeaderIdSet.add(forecast.id);
                finalHeaderChCodeSet.add(forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c);
            }
            if(forecast.ASI_Forecast_Item__r.size()==0) {
                String fChCode = forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c;
                channelMailMap.put(fChCode, true);
                forecastItemList.add(new ASI_Forecast_Item__c(
                    ASI_Forecast__c  = forecast.id,
                    ASI_Forecast_Item_Group__c = itemGroupId,
                    ASI_Forecast_P1__c  = null,
                    ASI_Forecast_P2__c  = null,
                    ASI_Forecast_P3__c  = null,
                    ASI_Forecast_P4__c  = null,
                    ASI_Forecast_P5__c  = null,
                    ASI_Forecast_P6__c  = null,
                    ASI_Forecast_P7__c  = null,
                    ASI_Forecast_P8__c  = null,
                    ASI_Forecast_P9__c  = null,
                    ASI_Forecast_P10__c  = null,
                    ASI_Forecast_P11__c  = null,
                    ASI_Forecast_P12__c  = null,
                    RecordTypeId = recordTypeId
                ));
            }
        }
        if(forecastItemList.size() > 0) insert forecastItemList;
        if(submittedHeaderIdSet.size()>0) forecastBatchSetToDraft(submittedHeaderIdSet);
        if(finalHeaderIdSet.size()>0) forecastBatchSetToDraft(finalHeaderIdSet);
        system.debug(forecastItemList);
        system.debug(channelMailMap);
        Set<String> mailChCodeSet = new Set<String>();
        for (String chCode : channelMailMap.keySet()) {
            if(channelMailMap.get(chCode)) mailChCodeSet.add(chCode);
        }
        if(mailChCodeSet.size() > 0) {
            String chStr = String.join(new List<String>(mailChCodeSet), ',');
            Set<String> emailList = ASI_CRM_TW_Forecast_Util.searchForecastItemGroupInputerByChannelCode(mailChCodeSet);
            SYSTEM.debug('pending sent mail list : ' + emailList);        
            ASI_CRM_TW_Forecast_Util.sendForecastEmail(new List<String>(emailList),'', chStr, '', 'ASI_Forecast_TW_NewItemGroup_HTML', 'ASI_Forecast_TW_InputForecastPage');            
        }
        Map<String, Set<String>> applyResultMap = new Map<String, Set<String>>{
            'mailChCode'=>mailChCodeSet,
                'submittedChCode'=>submittedHeaderChCodeSet,
                'finalChCode'=>finalHeaderChCodeSet
                };
		return JSON.serialize(applyResultMap);
    }
	

    public static Map<Id,Map<Id,Map<String,Id>>> searchForecastOwner() {
        Map<Id,Map<Id,Map<String,Id>>> resultMap = new Map<Id,Map<Id,Map<String,Id>>>();
        List<ASI_Forecast_Channel_Map__c> chMappingList = [SELECT ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c, ASI_Forecast_Sub_Channel__c, 
                                                           ASI_Forecast_Region__c, ASI_Forecast_ChannelRegion_Manger__c
                                                           FROM ASI_Forecast_Channel_Map__c
                                                           WHERE RecordType.DeveloperName LIKE 'ASI_Forecast_TW_ChannelMap'
                                                           ];
        for(ASI_Forecast_Channel_Map__c chMapping : chMappingList) {
            List<String> regionList = new List<String>();
            String region = chMapping.ASI_Forecast_Region__c;
            Id chId    = chMapping.ASI_Forecast_Sub_Channel__r.ASI_CRM_CN_Channel__c;
            Id subChId = chMapping.ASI_Forecast_Sub_Channel__c;
            Id fOwner  = chMapping.ASI_Forecast_ChannelRegion_Manger__c;
            if(region!=null && region!='') {
                regionList = region.split(';');
            } else if(chId==null || subChId==null || fOwner==null) {
                continue;
            }
            for(String rCode : regionList) {
                if(resultMap.get(chId)==null) resultMap.put(chId, new Map<Id,Map<String,Id>>());
                if(resultMap.get(chId).get(subChId)==null) resultMap.get(chId).put(subChId, new Map<String,Id>());
                resultMap.get(chId).get(subChId).put(rCode, fOwner);
            }
        }
        return resultMap;
    }
    
    public static Set<String> searchChannelCodeByHeaderIdSet(Set<Id> headerId) {
        if (headerId.size()==0) return new Set<String>();
        Set<String> channelSet = new Set<String>();
        List<ASI_Forecast__c> fHeaderList = [
            SELECT id, ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c
            FROM ASI_Forecast__c 
            WHERE id IN :headerId
            AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
        ];
        for(ASI_Forecast__c forecast : fHeaderList) {
         	channelSet.add(forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c );   
        }
        return channelSet;
    }
    
    public static Set<Id> searchEmptyForecastHeader() {
        Set<Id> emptyHeaderIdSet = new Set<Id>();
        List<ASI_Forecast__c> fHeaderList = [SELECT id, (SELECT id FROM ASI_Forecast_Item__r)
                                             FROM ASI_Forecast__c
                                             WHERE ASI_Forecast_Status__c = 'Draft'
                                             AND RecordType.DeveloperName Like 'ASI_Forecast_TW'];
        for(ASI_Forecast__c header : fHeaderList) {
            if(header.ASI_Forecast_Item__r.size() == 0) {
                emptyHeaderIdSet.add(header.Id);
            }
        }
        return emptyHeaderIdSet;
    }
    
    public static Set<String> insertForecastItem(Set<id> headerId) {
        if (headerId.size()==0) return new Set<String>();
        Set<String> channelSet = new Set<String>();
        List<ASI_Forecast__c> fHeaderList = [
            SELECT id, ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c
            FROM ASI_Forecast__c 
            WHERE id IN :headerId
            AND RecordType.DeveloperName LIKE 'ASI_Forecast_TW'
        ];
        for(ASI_Forecast__c forecast : fHeaderList) {
         	channelSet.add(forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c );   
        }
        
        Id recordTypeId = Schema.SObjectType.ASI_Forecast_Item__c .getRecordTypeInfosByName().get('TW Forecast Item').getRecordTypeId();
        Map<String, List<id>> itemGroupMap = ASI_CRM_TW_Forecast_Util.getChannelItemMap(channelSet);
        List<ASI_Forecast_Item__c> forecastItemList = new List<ASI_Forecast_Item__c>();
        for (ASI_Forecast__c forecast : fHeaderList){
            List<id> itemGroupIdList = itemGroupMap.get(forecast.ASI_Forecast_Channel__r.ASI_CRM_CN_Channel_Code__c);
            system.debug(itemGroupIdList);
            if(itemGroupIdList == null) continue;
            for(id itemGroupId : itemGroupIdList) {
                ASI_Forecast_Item__c forecastItem = new ASI_Forecast_Item__c(
                    ASI_Forecast__c  = forecast.id,
                    ASI_Forecast_Item_Group__c = itemGroupId,
                    ASI_Forecast_P1__c  = null,
                    ASI_Forecast_P2__c  = null,
                    ASI_Forecast_P3__c  = null,
                    ASI_Forecast_P4__c  = null,
                    ASI_Forecast_P5__c  = null,
                    ASI_Forecast_P6__c  = null,
                    ASI_Forecast_P7__c  = null,
                    ASI_Forecast_P8__c  = null,
                    ASI_Forecast_P9__c  = null,
                    ASI_Forecast_P10__c  = null,
                    ASI_Forecast_P11__c  = null,
                    ASI_Forecast_P12__c  = null,
                    RecordTypeId = recordTypeId
                );
                forecastItemList.add(forecastItem);
            }
        }
        if(forecastItemList.size()>0) {insert forecastItemList;}
        system.debug(forecastItemList);
        return channelSet;
    }
}