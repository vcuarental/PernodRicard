Public without sharing class ASI_MFM_CN_ItemGroup_TriggerClass {

    Private Static Final Id FIX_APPROVAL_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route');
    Private Static Final Id POSM_PHOTO_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Photo');
    Private Static Final Id POSM_ARTWORK_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
    Private Static Final Id CATEGORY_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_MFM_CN_Category_Master');
    Private Static Final Id CHANNEL_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_MFM_CN_POSM_Channel');
    Private Static Final Id TRADE_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_Trade');
    Private Static Final Id TRADE_RO_RECORD_TYPE_ID = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_New_POSM_Item_Group_RO_Trade');
    
    Private Static Final Map<String, Schema.SObjectField> ITEM_GROUP_FIELD_MAP = Schema.SObjectType.ASI_MFM_Item_Group__c.fields.getMap();
    Private Static Final Map<String, Schema.SObjectField> FIX_APPROVAL_FIELD_MAP = Schema.SObjectType.ASI_CRM_Fix_Approval_Route__c.fields.getMap();
    
    Private Static Final String DRAFT_STATUS = 'Draft';
    Private Static Final String FINAL_STATUS = 'Final';
    
    Private Static Final String ACTIVE_STATUS = 'Active';
    
    Private Static Final String CATEGORY_DEPENDENCE_VALIDATION = '{0} is not valid for {1}, please select a valid one';
    Private Static Final String DELETE_VALIDATION = 'You are not allowed to delete Final or Active Item Group';
    
    /*-------MT@INTROV@20190524 start
    --------Change category map from global to local
    Private Static Final Map<Id, ASI_HK_CRM_Product_Category__c> CATEGORY_MAP = new Map<Id, ASI_HK_CRM_Product_Category__c>([SELECT Id, ASI_MFM_Level__c
                                                                                                                             , ASI_MFM_Buyer__c
                                                                                                                             , ASI_MFM_Buyer__r.ASI_MFM_Buyer__c
                                                                                                                             , Name
                                                                                                                             , ASI_HK_CRM_Category_Code__c
                                                                                                                             , ASI_MFM_Running_Number__c
                                                                                                                             , (SELECT Id
                                                                                                                                , ASI_MFM_Category_Level_2_3__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.ASI_MFM_Level__c
                                                                                                                                , ASI_CRM_CN_Product_Category__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.Name
                                                                                                                                FROM Sub_categories__r)
                                                                                                                             FROM ASI_HK_CRM_Product_Category__c 
                                                                                                                             WHERE recordTypeId = : CATEGORY_RECORD_TYPE_ID]);
    //-------MT@INTROV@20190524 end*/
    Private Static Final List<ASI_CRM_CN_Channel__c> POSM_CHANNEL_LIST = new List<ASI_CRM_CN_Channel__c>([SELECT id, Name FROM ASI_CRM_CN_Channel__c WHERE RecordTypeId = : CHANNEL_RECORD_TYPE_ID]);
    
    Private Static Map<String, ASI_CRM_Fix_Approval_Route__c> fixApprovalMap = new Map<String, ASI_CRM_Fix_Approval_Route__c>();
    Private Static Map<String, ASI_CRM_CN_Channel__c> posmChannelMap = new Map<String, ASI_CRM_CN_Channel__c>();
    Private Static Map<Id, ASI_MFM_Sub_Brand__c> subbrandMap = new Map<Id, ASI_MFM_Sub_Brand__c>();
    Private Static Map<String, ASI_HK_CRM_Product_Category__c> catMap = new Map<String, ASI_HK_CRM_Product_Category__c>();
    
    Private Static Set<String> categoryLevel_2_3_Set = new Set<String>(); 
    
    Public Static Void beforeInsertFunction(List<ASI_MFM_Item_Group__c> triggerNew){
        
        Set<Id> subbrandSet = new Set<Id>();
        Boolean isUpdatedChannel = False;
        
        //------ edit by Andy Man @20181009 (start) ------ 
        // remove trigger logic about main channel and channel
        //channelMap();
        //------ edit by Andy Man @20181009 (end) ------
        
        //-------MT@INTROV@20190524 start
        Map<Id, ASI_HK_CRM_Product_Category__c> category_map = new Map<Id, ASI_HK_CRM_Product_Category__c>([SELECT Id, ASI_MFM_Level__c
                                                                                                                             , ASI_MFM_Buyer__c
                                                                                                                             , ASI_MFM_Buyer__r.ASI_MFM_Buyer__c
                                                                                                                             , Name
                                                                                                                             , ASI_HK_CRM_Category_Code__c
                                                                                                                             , ASI_MFM_Running_Number__c
                                                                                                                             , (SELECT Id
                                                                                                                                , ASI_MFM_Category_Level_2_3__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.ASI_MFM_Level__c
                                                                                                                                , ASI_CRM_CN_Product_Category__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.Name
                                                                                                                                FROM Sub_categories__r)
                                                                                                                             FROM ASI_HK_CRM_Product_Category__c 
                                                                                                                             WHERE recordTypeId = : CATEGORY_RECORD_TYPE_ID]);
        
        //category_2_3_Map();
        category_2_3_Map(category_map);
        //-------MT@INTROV@20190524 end
        fixApprovalMap();
        
        for(ASI_MFM_Item_Group__c obj : triggerNew){
            
            if(obj.ASI_MFM_Sub_brand__c != Null)
                subbrandSet.add(obj.ASI_MFM_Sub_brand__c);
            
            if(catMap.containsKey(obj.ASI_MFM_Category_Level_1_Piclklist__c)){
                
                obj.ASI_MFM_Category_Level_1__c = catMap.get(obj.ASI_MFM_Category_Level_1_Piclklist__c).id;
            }
            
            if(catMap.containsKey(obj.ASI_MFM_Category_Level_2_Piclklist__c)){
                
                obj.ASI_MFM_Category_Level_2__c = catMap.get(obj.ASI_MFM_Category_Level_2_Piclklist__c).id;
            }
            
            if(catMap.containsKey(obj.ASI_MFM_Category_Level_3_Piclklist__c)){
                
                obj.ASI_MFM_Category_Level_3__c = catMap.get(obj.ASI_MFM_Category_Level_3_Piclklist__c).id;
            }
            // Enoch@Introv 20200228 Trade A&P 
            if(obj.recordTypeId == TRADE_RECORD_TYPE_ID) {
                obj.ASI_MFM_Is_Trade_Item__c = true;
            } else {
                obj.ASI_MFM_Is_Trade_Item__c = false;
            }
        }
        
        if(subbrandSet.size() > 0)
            subbrandMap = new Map<Id, ASI_MFM_Sub_Brand__c>([SELECT id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c WHERE id IN : subbrandSet]);
        
        for(ASI_MFM_Item_Group__c obj : triggerNew){
            
            //------ edit by Andy Man @20181009 (start) ------ 
            // remove trigger logic about main channel and channel
            /*
            if(String.isNotBlank(obj.ASI_MFM_Main_Channel__c) && posmChannelMap.containsKey(obj.ASI_MFM_Main_Channel__c)){
                
                obj.ASI_MFM_Channel__c = posmChannelMap.get(obj.ASI_MFM_Main_Channel__c).id;
            }
            */
            //------ edit by Andy Man @20181009 (end) ------
            
            if(obj.ASI_MFM_Category_Level_1__c != Null){
                
                if(obj.ASI_MFM_Category_Level_2__c != Null && !categoryLevel_2_3_Set.contains('' + obj.ASI_MFM_Category_Level_1__c + obj.ASI_MFM_Category_Level_2__c)){
                    
                    obj.ASI_MFM_Category_Level_2__c.addError(String.format(CATEGORY_DEPENDENCE_VALIDATION, new List<String>{CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_2__c).Name, CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_1__c).Name}));
                }
                
                if(obj.ASI_MFM_Category_Level_3__c != Null && !categoryLevel_2_3_Set.contains('' + obj.ASI_MFM_Category_Level_1__c + obj.ASI_MFM_Category_Level_3__c)){
                    
                    obj.ASI_MFM_Category_Level_3__c.addError(String.format(CATEGORY_DEPENDENCE_VALIDATION, new List<String>{CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_3__c).Name, CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_1__c).Name}));
                }
            }
            
            if(obj.ASI_MFM_Status__c == DRAFT_STATUS){
                if(fixApprovalMap.containsKey(Global_RecordTypeCache.getRt(obj.RecordTypeId).Name)){
                    
                    setApproverToNull(obj);
                    //-------MT@INTROV@20190524 start
                    //setApprover(obj, fixApprovalMap.get(Global_RecordTypeCache.getRt(obj.RecordTypeId).Name));
                    setApprover(obj, fixApprovalMap.get(Global_RecordTypeCache.getRt(obj.RecordTypeId).Name), category_map);
                    //-------MT@INTROV@20190524 end
                }
            }else if(obj.ASI_MFM_Status__c == FINAL_STATUS){
                
                if(String.isBlank(obj.ASI_MFM_Item_Group_Code__c)){
                    //-------MT@INTROV@20190524 start
                    //generateItemGroupCode(obj);
                    // Enoch@Introv 20200228 Trade A&P 
                    if(obj.ASI_MFM_Is_Trade_Item__c) {
                        generateItemGroupCodeForTrade(obj, category_map);
                    } else {
                        generateItemGroupCode(obj, category_map);
                    }
                    //-------MT@INTROV@20190524 end
                    isUpdatedChannel = True;
                }
            }
            
            obj.Name = obj.ASI_CRM_CN_Chinese_Name__c + '/' + obj.ASI_CRM_CN_Eng_Name__c + (String.IsNotBlank(obj.ASI_MFM_Item_Group_Code__c) ? (' - ' + obj.ASI_MFM_Item_Group_Code__c) : '');
        }
        
        if(isUpdatedChannel){
            try{
                
                Update CATEGORY_MAP.values();
                
            }catch(dmlException dmle){
                
            }
        }
    }
    
    Public Static Void beforeUpdateFunction(List<ASI_MFM_Item_Group__c> triggerNew, Map<Id, ASI_MFM_Item_Group__c> triggerOldMap){
        
        Map<Id, List<ASI_CRM_Product_Warehouse_Photo__c>> ArtworkMap = new Map<Id, List<ASI_CRM_Product_Warehouse_Photo__c>>();
        Map<Id, List<ASI_CRM_Product_Warehouse_Photo__c>> posmPhotoMap = new Map<Id, List<ASI_CRM_Product_Warehouse_Photo__c>>();
        
        Set<Id> subbrandSet = new Set<Id>();
        
        Boolean isUpdatedChannel = False;
        
        //------ edit by Andy Man @20181009 (start) ------ 
        // remove trigger logic about main channel and channel
        //channelMap();
        //------ edit by Andy Man @20181009 (end) ------
        
         //-------MT@INTROV@20190524 start
        Map<Id, ASI_HK_CRM_Product_Category__c> category_map = new Map<Id, ASI_HK_CRM_Product_Category__c>([SELECT Id, ASI_MFM_Level__c
                                                                                                                             , ASI_MFM_Buyer__c
                                                                                                                             , ASI_MFM_Buyer__r.ASI_MFM_Buyer__c
                                                                                                                             , Name
                                                                                                                             , ASI_HK_CRM_Category_Code__c
                                                                                                                             , ASI_MFM_Running_Number__c
                                                                                                                             , (SELECT Id
                                                                                                                                , ASI_MFM_Category_Level_2_3__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.ASI_MFM_Level__c
                                                                                                                                , ASI_CRM_CN_Product_Category__c
                                                                                                                                , ASI_MFM_Category_Level_2_3__r.Name
                                                                                                                                FROM Sub_categories__r)
                                                                                                                             FROM ASI_HK_CRM_Product_Category__c 
                                                                                                                             WHERE recordTypeId = : CATEGORY_RECORD_TYPE_ID]);
        
        //category_2_3_Map();
        category_2_3_Map(category_map);
        //-------MT@INTROV@20190524 end
        fixApprovalMap();
        
        for(ASI_MFM_Item_Group__c obj : triggerNew){
            
            if(obj.ASI_MFM_Sub_brand__c != Null)
                subbrandSet.add(obj.ASI_MFM_Sub_brand__c);
            
            if(catMap.containsKey(obj.ASI_MFM_Category_Level_1_Piclklist__c)){
                
                obj.ASI_MFM_Category_Level_1__c = catMap.get(obj.ASI_MFM_Category_Level_1_Piclklist__c).id;
            }
            
            if(catMap.containsKey(obj.ASI_MFM_Category_Level_2_Piclklist__c)){
                
                obj.ASI_MFM_Category_Level_2__c = catMap.get(obj.ASI_MFM_Category_Level_2_Piclklist__c).id;
            }
            
            if(catMap.containsKey(obj.ASI_MFM_Category_Level_3_Piclklist__c)){
                
                obj.ASI_MFM_Category_Level_3__c = catMap.get(obj.ASI_MFM_Category_Level_3_Piclklist__c).id;
            }
            // Enoch@Introv 20200228 Trade A&P 
            if(obj.recordTypeId == TRADE_RECORD_TYPE_ID) {
                obj.ASI_MFM_Is_Trade_Item__c = true;
            } else {
                obj.ASI_MFM_Is_Trade_Item__c = false;
            }
            
            //20200818:AM@introv - fix change error of category 1/2/3 start
            if (obj.ASI_MFM_Category_Level_1_Piclklist__c == NULL) obj.ASI_MFM_Category_Level_1__c = NULL;
            if (obj.ASI_MFM_Category_Level_2_Piclklist__c == NULL) obj.ASI_MFM_Category_Level_2__c = NULL;
            if (obj.ASI_MFM_Category_Level_3_Piclklist__c == NULL) obj.ASI_MFM_Category_Level_3__c = NULL;
            //20200818:AM@introv - fix change error of category 1/2/3 end
        }
        
        if(subbrandSet.size() > 0)
            subbrandMap = new Map<Id, ASI_MFM_Sub_Brand__c>([SELECT id, ASI_MFM_Sub_brand_Code__c FROM ASI_MFM_Sub_brand__c WHERE id IN : subbrandSet]);
        
        for(ASI_CRM_Product_Warehouse_Photo__c obj : [SELECT Id, ASI_CRM_Item_Group__c, recordTypeId FROM ASI_CRM_Product_Warehouse_Photo__c WHERE ASI_CRM_Item_Group__c IN : triggerNew]){
            
            List<ASI_CRM_Product_Warehouse_Photo__c> tmp = new List<ASI_CRM_Product_Warehouse_Photo__c>();
            
            if(obj.RecordTypeId == POSM_ARTWORK_RECORD_TYPE_ID){
                
                if(ArtworkMap.containsKey(obj.ASI_CRM_Item_Group__c)){
                    
                    tmp = ArtworkMap.get(obj.ASI_CRM_Item_Group__c);
                }
                
                tmp.add(obj);
                
                ArtworkMap.put(obj.ASI_CRM_Item_Group__c, tmp);
                
            }else if(obj.RecordTypeId == POSM_PHOTO_RECORD_TYPE_ID){
                
                if(posmPhotoMap.containsKey(obj.ASI_CRM_Item_Group__c)){
                    
                    tmp = posmPhotoMap.get(obj.ASI_CRM_Item_Group__c);
                }
                
                tmp.add(obj);
                
                posmPhotoMap.put(obj.ASI_CRM_Item_Group__c, tmp);
            }
        }
        
        for(ASI_MFM_Item_Group__c obj : triggerNew){
            
            //------ edit by Andy Man @20181009 (start) ------ 
            // remove trigger logic about main channel and channel
            /*
            if(String.isNotBlank(obj.ASI_MFM_Main_Channel__c) && posmChannelMap.containsKey(obj.ASI_MFM_Main_Channel__c)){
                
                obj.ASI_MFM_Channel__c = posmChannelMap.get(obj.ASI_MFM_Main_Channel__c).id;
            }
            */
            //------ edit by Andy Man @20181009 (end) ------
            
            if(posmPhotoMap.containsKey(obj.id))
                obj.ASI_MFM_POSM_Photo_Upload__c = true;
            else
                obj.ASI_MFM_POSM_Photo_Upload__c = false;
            
            if(ArtworkMap.containsKey(obj.id))
                obj.ASI_MFM_POSM_Final_Artwork_Upload__c = true;
            else
                obj.ASI_MFM_POSM_Final_Artwork_Upload__c = false;
            
            if(obj.ASI_MFM_Category_Level_1__c != Null){
                
                if(obj.ASI_MFM_Category_Level_2__c != Null && !categoryLevel_2_3_Set.contains('' + obj.ASI_MFM_Category_Level_1__c + obj.ASI_MFM_Category_Level_2__c)){
                    
                    obj.ASI_MFM_Category_Level_2__c.addError(String.format(CATEGORY_DEPENDENCE_VALIDATION, new List<String>{CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_2__c).Name, CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_1__c).Name}));
                }
                
                if(obj.ASI_MFM_Category_Level_3__c != Null && !categoryLevel_2_3_Set.contains('' + obj.ASI_MFM_Category_Level_1__c + obj.ASI_MFM_Category_Level_3__c)){
                    
                    obj.ASI_MFM_Category_Level_3__c.addError(String.format(CATEGORY_DEPENDENCE_VALIDATION, new List<String>{CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_3__c).Name, CATEGORY_MAP.get(obj.ASI_MFM_Category_Level_1__c).Name}));
                }
            }
            
            if(obj.ASI_MFM_Status__c == DRAFT_STATUS){
                if(fixApprovalMap.containsKey(Global_RecordTypeCache.getRt(obj.RecordTypeId).Name)){
                    
                    setApproverToNull(obj);
                    //-------MT@INTROV@20190524 start
                    //setApprover(obj, fixApprovalMap.get(Global_RecordTypeCache.getRt(obj.RecordTypeId).Name));
                    setApprover(obj, fixApprovalMap.get(Global_RecordTypeCache.getRt(obj.RecordTypeId).Name), category_map);
                    //-------MT@INTROV@20190524 end
                }
            }else if(obj.ASI_MFM_Status__c == FINAL_STATUS){
                
                if(String.isBlank(obj.ASI_MFM_Item_Group_Code__c)){
                    
                    //-------MT@INTROV@20190524 start
                    //generateItemGroupCode(obj);
                    // Enoch@Introv 20200228 Trade A&P 
                    system.debug('### record type');
                    system.debug(triggerOldMap.get(obj.Id).recordTypeId);
                    if(triggerOldMap.get(obj.Id).recordTypeId == TRADE_RO_RECORD_TYPE_ID) {
                        generateItemGroupCodeForTrade(obj, category_map);
                    } else {
                        generateItemGroupCode(obj, category_map);
                    }
                    //-------MT@INTROV@20190524 end
                    isUpdatedChannel = True;
                }
            }
            
            obj.Name = obj.ASI_CRM_CN_Chinese_Name__c + '/' + obj.ASI_CRM_CN_Eng_Name__c + (String.IsNotBlank(obj.ASI_MFM_Item_Group_Code__c) ? (' - ' + obj.ASI_MFM_Item_Group_Code__c) : '');
        }
        
        if(isUpdatedChannel){
            try{
                
                Update CATEGORY_MAP.values();
                
            }catch(dmlException dmle){
                
            }
        }
    }
    
    Public Static void beforeDeleteFunction(List<ASI_MFM_Item_Group__c> triggerOld){
        
        for(ASI_MFM_Item_Group__c obj : triggerOld){
            if(obj.ASI_MFM_Status__c == FINAL_STATUS || obj.ASI_MFM_Utilization_Status__c == ACTIVE_STATUS){
                obj.addError(DELETE_VALIDATION);
            }
        }
    }
    
    Public Static Void afterUpdateFunction(List<ASI_MFM_Item_Group__c> triggerNew, Map<Id, ASI_MFM_Item_Group__c> triggerOldMap) {
        Map<Id,Set<Id>> igMap = new Map<Id,Set<Id>>();
        
        for(ASI_MFM_Item_Group__c obj : triggerNew) {
            Boolean bRunClone = true;
            
            //check latest status
            if (bRunClone) {
                if (obj.ASI_MFM_Status__c != FINAL_STATUS) bRunClone = false;
            }
            
            //check status/clone security from change
            if (bRunClone) {
                if ((obj.ASI_MFM_Status__c == triggerOldMap.get(obj.id).ASI_MFM_Status__c)
                    && (obj.ASI_MFM_CloneSecurityFrom__c == triggerOldMap.get(obj.id).ASI_MFM_CloneSecurityFrom__c))
                    bRunClone = false;
            }
            
            //check valid clone security from
            if (bRunClone) {
                if (obj.ASI_MFM_CloneSecurityFrom__c == NULL) bRunClone = false;
            }
            
            if (bRunClone) {
                if (igMap.containsKey(obj.ASI_MFM_CloneSecurityFrom__c)) {
                    igMap.get(obj.ASI_MFM_CloneSecurityFrom__c).add(obj.Id);
                } else {
                    igMap.put(obj.ASI_MFM_CloneSecurityFrom__c, new Set<Id>{obj.Id});
                }
            }
        }
        
        if(igMap.size() > 0) {
            List<ASI_MFM_POSMCatalogSecCtrl__c> secNewLt = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
            
            List<ASI_MFM_POSMCatalogSecCtrl__c> secOldLt = [SELECT id, ASI_MFM_CanOrderinCatalog__c, ASI_MFM_ItemGroup__c, ASI_MFM_MappingType__c, ASI_MFM_Region__c, ASI_MFM_User__c, ASI_MFM_Warehouse__c FROM ASI_MFM_POSMCatalogSecCtrl__c WHERE ASI_MFM_ItemGroup__c IN :igMap.keySet()];
            if (secOldLt.size() > 0) {
                for(ASI_MFM_POSMCatalogSecCtrl__c objSec : secOldLt) {
                    for(Id objNewId : igMap.get(objSec.ASI_MFM_ItemGroup__c)) {
                        secNewLt.add(new ASI_MFM_POSMCatalogSecCtrl__c(
                            ASI_MFM_ItemGroup__c = objNewId,
                            ASI_MFM_CanOrderinCatalog__c = objSec.ASI_MFM_CanOrderinCatalog__c, 
                            ASI_MFM_MappingType__c = objSec.ASI_MFM_MappingType__c, 
                            ASI_MFM_Region__c = objSec.ASI_MFM_Region__c, 
                            ASI_MFM_User__c = objSec.ASI_MFM_User__c, 
                            ASI_MFM_Warehouse__c = objSec.ASI_MFM_Warehouse__c
                        ));
                    }
                }
            }
            
            if (secNewLt.size() > 0)
                insert secNewLt;
        }
    }
    
    @TestVisible
    //-------Enoch@INTROV@20200228 Trade A&P start
    Private Static void generateItemGroupCodeForTrade(ASI_MFM_Item_Group__c ig, Map<Id, ASI_HK_CRM_Product_Category__c> CATEGORY_MAP){            
        
        Map<String, String> regionCodeMap = new Map<String, String>{'premium' => 'A', 'prestige' => 'P', 'cognac' => 'C', 'e-commerce' => 'E', 'central' => '2', 'north west' => '3', 'north' => '4', 'ka' => '5', 'east' => '6', 'south' => '8', 'south west' => '9', 'other department at hq  (it/hr/admin/vip,etc.)' => 'B'};
                
        if(ig.ASI_MFM_Sub_brand__c != Null && subbrandMap.containsKey(ig.ASI_MFM_Sub_brand__c) && ig.ASI_MFM_Category_Level_1__c != Null && CATEGORY_MAP.containsKey(ig.ASI_MFM_Category_Level_1__c)){
            
            String fy = date.today().month() > 6 ? '' + (date.today().year() - 2000) : '' + (date.today().addYears(-1).year() - 2000);
            Integer nextNum = 0;
            
            if(CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_MFM_Running_Number__c != Null){
                
                nextNum = resetRunningNumber(3, Integer.valueOf(CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_MFM_Running_Number__c), 1);
                
            }else{
                nextNum = 0;
            }
            
            String itemGroupCode = 'Y' + subbrandMap.get(ig.ASI_MFM_Sub_brand__c).ASI_MFM_Sub_brand_Code__c + CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_HK_CRM_Category_Code__c + fy;
            itemGroupCode += runningNumber(3, nextNum);
            itemGroupCode += String.isNotBlank(ig.ASI_MFM_Usage__c) && regionCodeMap.containsKey(ig.ASI_MFM_Usage__c.toLowerCase()) ? regionCodeMap.get(ig.ASI_MFM_Usage__c.toLowerCase()) : '';

            itemGroupCode += ig.ASI_MFM_Importation__c == 'Domestic' ? 'D' : 'I';
            ig.ASI_MFM_Item_Group_Code__c = itemGroupCode;
            ig.ASI_MFM_CheckDuplicate__c = true;
            CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_MFM_Running_Number__c = nextNum;
        }
    }
    //-------Enoch@INTROV@20200228 Trade A&P end
    
    @TestVisible
    //-------MT@INTROV@20190524 start
    //Private Static void generateItemGroupCode(ASI_MFM_Item_Group__c ig){
    Private Static void generateItemGroupCode(ASI_MFM_Item_Group__c ig, Map<Id, ASI_HK_CRM_Product_Category__c> CATEGORY_MAP){            
    //-------MT@INTROV@20190524 end
        
        Map<String, String> regionCodeMap = new Map<String, String>{'premium' => 'A', 'prestige' => 'P', 'cognac' => 'C', 'e-commerce' => 'E', 'central' => '2', 'north west' => '3', 'north' => '4', 'ka' => '5', 'east' => '6', 'south' => '8', 'south west' => '9', 'other department at hq  (it/hr/admin/vip,etc.)' => 'B'};
                
        if(ig.ASI_MFM_Sub_brand__c != Null && subbrandMap.containsKey(ig.ASI_MFM_Sub_brand__c) && ig.ASI_MFM_Category_Level_1__c != Null && CATEGORY_MAP.containsKey(ig.ASI_MFM_Category_Level_1__c)){
            
            String fy = date.today().month() > 6 ? '' + (date.today().year() - 2000) : '' + (date.today().addYears(-1).year() - 2000);
            Integer nextNum = 0;
            
            if(CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_MFM_Running_Number__c != Null){
                
                nextNum = resetRunningNumber(3, Integer.valueOf(CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_MFM_Running_Number__c), 1);
                
            }else{
                nextNum = 0;
            }
            
            String itemGroupCode = 'X' + subbrandMap.get(ig.ASI_MFM_Sub_brand__c).ASI_MFM_Sub_brand_Code__c + CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_HK_CRM_Category_Code__c + fy;
            itemGroupCode += runningNumber(3, nextNum);
            itemGroupCode += String.isNotBlank(ig.ASI_MFM_Usage__c) && regionCodeMap.containsKey(ig.ASI_MFM_Usage__c.toLowerCase()) ? regionCodeMap.get(ig.ASI_MFM_Usage__c.toLowerCase()) : '';
            
            //------ edit by Andy Man @20181009 (start) ------ 
            // slight picklist value change: YES->Import ; No->Domestic ; +Import-Domestic W/H
            //itemGroupCode += ig.ASI_MFM_Importation__c == 'YES' ? 'I' : 'D';
            itemGroupCode += ig.ASI_MFM_Importation__c == 'Domestic' ? 'D' : 'I';
            //------ edit by Andy Man @20181009 (end) ------ 
            
            itemGroupCode += ig.ASI_MFM_Bundle_Item_Group__c ? 'B' : 'N';
            
            ig.ASI_MFM_Item_Group_Code__c = itemGroupCode;
            //------Arca Lau-----@20190718(start)
            ig.ASI_MFM_CheckDuplicate__c = true;
             //------Arca Lau-----@20190718(end)
            CATEGORY_MAP.get(ig.ASI_MFM_Category_Level_1__c).ASI_MFM_Running_Number__c = nextNum;
        }
    }
    
    @TestVisible
    Private Static Integer resetRunningNumber(Integer maxLength, Integer currentNumber, Integer addingNum){
        
        Integer returnNum = (currentNumber != Null ? currentNumber : 0) + addingNum;
        
        if(('' + returnNum).length() > maxLength)
            returnNum = 0;
        
        return returnNum;
    }
    
    @TestVisible
    Private Static String runningNumber(Integer maxLength, Integer nextNumber){

        String returnStr = '';
        
        for(integer i = ('' + nextNumber).length(); i < maxLength; i++){
            
            returnStr += '0';
        }
        
        Return returnStr + nextNumber;
    }
    
    @TestVisible
    Private Static void channelMap(){
        for(ASI_CRM_CN_Channel__c obj : POSM_CHANNEL_LIST){
            posmChannelMap.put(obj.Name, obj);
        }
    }
    
    @TestVisible
    //-------MT@INTROV@20190524 start
    //Private Static void category_2_3_Map(){
    Private Static void category_2_3_Map(Map<Id, ASI_HK_CRM_Product_Category__c> CATEGORY_MAP){
    //-------MT@INTROV@20190524 end        
        for(ASI_HK_CRM_Product_Category__c obj : CATEGORY_MAP.values()){
            
            catMap.put(obj.Name, obj);
            
            for(ASI_TH_CRM_Sub_category__c subCat : obj.Sub_categories__r){
                
                categoryLevel_2_3_Set.add('' + subCat.ASI_CRM_CN_Product_Category__c + subCat.ASI_MFM_Category_Level_2_3__c);
            }
        }
    }
    
    @TestVisible
    Private Static void fixApprovalMap(){
        for(ASI_CRM_Fix_Approval_Route__c obj : RetrieveFixApprovalInfo(FIX_APPROVAL_FIELD_MAP, ' WHERE RecordTypeId = \'' + FIX_APPROVAL_RECORD_TYPE_ID + '\' AND ASI_CRM_CN_Type__c LIKE \'Item Group Application\'')){
            
            fixApprovalMap.put(obj.ASI_CRM_CN_Region_Area_Channel__c, obj);
        }
    }
    
    @TestVisible
    //-------MT@INTROV@20190524 start
    //Private Static void setApprover(ASI_MFM_Item_Group__c itemGroup, ASI_CRM_Fix_Approval_Route__c fixApproval){
    Private Static void setApprover(ASI_MFM_Item_Group__c itemGroup, ASI_CRM_Fix_Approval_Route__c fixApproval, Map<Id, ASI_HK_CRM_Product_Category__c> CATEGORY_MAP){
    //-------MT@INTROV@20190524 end
        
        Integer i = 1;
        Integer j = 1;
        String sysApprover = 'asi_mfm_sys_approver_' + i + '__c';
        String fixApprover = 'asi_crm_cn_approver_' + j + '__c';
        
        if(itemGroup.ASI_MFM_Category_Level_1__c != Null && CATEGORY_MAP.containsKey(itemGroup.ASI_MFM_Category_Level_1__c) && CATEGORY_MAP.get(itemGroup.ASI_MFM_Category_Level_1__c).ASI_MFM_Buyer__c != Null){
            
            itemGroup.put(sysApprover, CATEGORY_MAP.get(itemGroup.ASI_MFM_Category_Level_1__c).ASI_MFM_Buyer__r.ASI_MFM_Buyer__c);
            i++;
            sysApprover = 'asi_mfm_sys_approver_' + i + '__c';
        }
        
        While(ITEM_GROUP_FIELD_MAP.containsKey(sysApprover) && FIX_APPROVAL_FIELD_MAP.containsKey(fixApprover)){
            
            if(itemGroup.get(sysApprover) != Null){
                
                i++;
                sysApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
                continue;
            }
            
            if(fixApproval.get(fixApprover) == Null){
                j++;
                fixApprover = 'ASI_CRM_CN_Approver_' + j + '__c';
                continue;
            }
            itemGroup.put(sysApprover, fixApproval.get(fixApprover));
            
            i++;
            sysApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
            
            j++;
            fixApprover = 'ASI_CRM_CN_Approver_' + j + '__c';
        }
    }
    
    @TestVisible
    Private Static void setApproverToNull(ASI_MFM_Item_Group__c itemGroup){
        
        Integer i = 1;
        String sysApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
        
        While(ITEM_GROUP_FIELD_MAP.containsKey(sysApprover)){
            
            itemGroup.put(sysApprover, null);
            
            i++;
            sysApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
        }
    }
    
    @TestVisible
    Private Static List<ASI_CRM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
        
        String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_CRM_Fix_Approval_Route__c ' + whereClause;
        
        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_CRM_Fix_Approval_Route__c>) Database.query(query);
        return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_CRM_Fix_Approval_Route__c>();
    }
    
    @TestVisible
    Private Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}