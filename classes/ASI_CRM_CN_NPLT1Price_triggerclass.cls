public without sharing class ASI_CRM_CN_NPLT1Price_triggerclass {
	
    public static void beforeUpdateMethod(List<sObject> triggerNew){
        
        String objectType = triggerNew.getSObjectType().getDescribe().getName();
        Map<id, ASI_CN_NPL_NPL_Request__c> mapNPL = new Map<id, ASI_CN_NPL_NPL_Request__c>();
        Map<id, ASI_CN_NPL_Item_Master__c> mapItemMaster;
        Set<id> nplHeaderID = new Set<id>();
        Set<id> itemMasterHeaderID = new Set<id>();
        Set<id> nplIdSet = new Set<id>();

        for(sObject obj : triggerNew){
            
            if(objectType == 'ASI_CN_NPL_NPL_Request__c'){
                
                if(obj.get('ASI_CN_NPL_Status__c') == 'Final Approved' && !Boolean.valueOf(obj.get('ASI_CRM_CN_NPLT1PriceFlag__c')) && ( obj.get('ASI_CN_NPL_Classification__c') == 'Class A' || obj.get('ASI_CN_NPL_Classification__c') == 'Class B' || obj.get('ASI_CN_NPL_Classification__c') == 'Class D' || obj.get('ASI_CN_NPL_Classification__c') == 'Class E' || obj.get('ASI_CN_NPL_Classification__c') == 'Class F') )
                    mapNPL.put(obj.id, (ASI_CN_NPL_NPL_Request__c) obj);//nplHeaderID.add(obj.id);
            }else if(objectType == 'ASI_CN_NPL_Item_Master__c'){
                
                if(obj.get('ASI_CN_NPL_Status__c') == 'Completed' && obj.get('ASI_CN_NPL_Item_Master_Type__c') == 'NPL' ){
                    itemMasterHeaderID.add(obj.id);
                    nplIdSet.add(String.valueOf(obj.get('ASI_CN_NPL_NPL_Reference_No__c')));
                }
            }
        }
        
        if(mapNPL.keySet().size() > 0){//nplHeaderID.size() > 0){
            /*mapNPL = new Map<id, ASI_CN_NPL_NPL_Request__c>([SELECT id
                                                             , ASI_CN_NPL_Status__c
                                                             , ASI_CN_NPL_Item_Master__c
                                                             , ASI_CRM_CN_NPLT1PriceFlag__c
                                                             , ASI_CN_NPL_Final_Proposed_Selling_Price__c
                                                             , ASI_CN_NPL_Target_Vol_Domestic__c
                                                             FROM ASI_CN_NPL_NPL_Request__c
                                                             WHERE id IN : nplHeaderID
                                                            ]);*/
            
            mapItemMaster = new Map<id, ASI_CN_NPL_Item_Master__c>();
            List<ASI_CN_NPL_Item_Master__c> itemMasterList = new List<ASI_CN_NPL_Item_Master__c>([SELECT id
                                                                                                  , ASI_CN_NPL_Status__c
                                                                                                  , ASI_CN_NPL_Item_Goup_Code__c
                                                                                                  , ASI_CN_NPL_NPL_Reference_No__c
                                                                                                  , ASI_CN_NPL_Item_Group_Description_GE__c
                                                                                                  , ASI_CN_NPL_Item_Group_Description_CH__c
                                                                                                  , ASI_CN_NPL_NPL_Reference_No__r.ASI_CRM_CN_NPLT1PriceFlag__c
                                                                                                  , ASI_CN_NPL_NPL_Reference_No__r.ASI_CN_NPL_Status__c
                                                                                                  FROM ASI_CN_NPL_Item_Master__c
                                                                                                  WHERE ASI_CN_NPL_NPL_Reference_No__c IN : mapNPL.keySet()
                                                                                                  AND ASI_CN_NPL_Status__c = 'Completed'
                                                                                                  AND ASI_CN_NPL_Item_Master_Type__c = 'NPL'
                                                                                                  AND ASI_CN_NPL_Item_Goup_Code__c != NULL
                                                                                                  AND ASI_CN_NPL_Item_Goup_Code__c != ''
                                                                                                 ]);
            
            for(ASI_CN_NPL_Item_Master__c obj : itemMasterList)
            	mapItemMaster.put(obj.ASI_CN_NPL_NPL_Reference_No__c, obj);
            
            validationMethod(triggerNew, mapNPL, mapItemMaster, objectType);
            
        }else if(itemMasterHeaderID.size() > 0){
            /*mapItemMaster = new Map<id, ASI_CN_NPL_Item_Master__c>([SELECT id
                                                                    , ASI_CN_NPL_Status__c
                                                                    , ASI_CN_NPL_Item_Goup_Code__c
                                                                    , ASI_CN_NPL_NPL_Reference_No__c
                                                                    , ASI_CN_NPL_Item_Group_Description_GE__c
                                                                    , ASI_CN_NPL_Item_Group_Description_CH__c
                                                                    , ASI_CN_NPL_NPL_Reference_No__r.ASI_CRM_CN_NPLT1PriceFlag__c
                                                                    , ASI_CN_NPL_NPL_Reference_No__r.ASI_CN_NPL_Status__c
                                                                    FROM ASI_CN_NPL_Item_Master__c
                                                                    WHERE id IN : itemMasterHeaderID
                                                                    AND ASI_CN_NPL_NPL_Reference_No__r.ASI_CRM_CN_NPLT1PriceFlag__c = FALSE
                                                                    AND ASI_CN_NPL_NPL_Reference_No__r.ASI_CN_NPL_Status__c = 'Final Approved'
                                                                   ]);*/
            
            /*for(ASI_CN_NPL_Item_Master__c obj : mapItemMaster.values()){
                nplIdSet.add(obj.ASI_CN_NPL_NPL_Reference_No__c);
            }*/
            
            mapNPL = new Map<id, ASI_CN_NPL_NPL_Request__c>([SELECT id
                                                             , ASI_CN_NPL_Status__c
                                                             , ASI_CN_NPL_Final_Proposed_Selling_Price__c
                                                             , ASI_CN_NPL_Target_Vol_Domestic__c
                                                             , ASI_CN_NPL_Item_Master__c
                                                             , ASI_CRM_CN_NPLT1PriceFlag__c
                                                             FROM ASI_CN_NPL_NPL_Request__c
                                                             WHERE id IN : nplIdSet
                                                             AND ASI_CRM_CN_NPLT1PriceFlag__c = FALSE
                                                             AND ASI_CN_NPL_Status__c = 'Final Approved'
                                                             AND ( ASI_CN_NPL_Classification__c = 'Class A'
                                                                  OR ASI_CN_NPL_Classification__c = 'Class B'
                                                                  OR ASI_CN_NPL_Classification__c = 'Class D'
                                                                  OR ASI_CN_NPL_Classification__c = 'Class E'
                                                                  OR ASI_CN_NPL_Classification__c = 'Class F' )
                                                             ]);
            
            mapItemMaster = new Map<id, ASI_CN_NPL_Item_Master__c>();
            
            for(sObject obj : triggerNew){
                
                ASI_CN_NPL_Item_Master__c tmp = (ASI_CN_NPL_Item_Master__c) obj;
                
                if(mapNPL.containsKey(tmp.ASI_CN_NPL_NPL_Reference_No__c)){
                    
                    mapItemMaster.put(tmp.id, tmp);
                }
            }
                                                                    
            validationMethod(triggerNew, mapNPL, mapItemMaster, objectType);
        }
    }
    
    private static void validationMethod(List<sObject> triggerNew, Map<id, ASI_CN_NPL_NPL_Request__c> mapNPL, Map<id, ASI_CN_NPL_Item_Master__c> mapItemMaster, String objectType){
		
        Map<id, ASI_CN_NPL_Item_Master__c> matchedCase = new Map<id, ASI_CN_NPL_Item_Master__c>();
        
        for(sObject obj : triggerNew){
            
            if(objectType == 'ASI_CN_NPL_Item_Master__c'){
                
                if(obj.get('ASI_CN_NPL_Item_Goup_Code__c') == '' || obj.get('ASI_CN_NPL_Item_Goup_Code__c') == null){
                    
                    //obj.addError(' Please input the item group code to complete the item master');
                    //break;
                }else if( obj.get('ASI_CN_NPL_NPL_Reference_No__c') == NULL ){
                    
                    //obj.addError(' Please input the NPL reference number to complete the item master');
                    //break;
                }else{
                    
                    if(mapItemMaster.containsKey(obj.id)){
                    	//matchedCase.put(mapItemMaster.get(obj.id).ASI_CN_NPL_NPL_Reference_No__c, mapItemMaster.get(obj.id));
                    	ASI_CN_NPL_Item_Master__c tmp = (ASI_CN_NPL_Item_Master__c) obj;
                    	matchedCase.put(tmp.ASI_CN_NPL_NPL_Reference_No__c, tmp);
                    }
                }
            
            }else if(objectType == 'ASI_CN_NPL_NPL_Request__c'){
                
                if(mapItemMaster.containsKey(obj.id))
                    matchedCase.put(obj.id, mapItemMaster.get(obj.id));
            }
        }
        if(matchedCase.size() > 0)
        	updateMethod(triggerNew, matchedCase, objectType, mapNPL);
    }
        
    private static void updateMethod(List<sObject> triggerNew, Map<id, ASI_CN_NPL_Item_Master__c> matchedCase, String objectType, Map<id, ASI_CN_NPL_NPL_Request__c> mapNPL){
            
        if(matchedCase.size() > 0){
            
            List<Database.SaveResult> results = new List<Database.SaveResult>();
            Map<String, ASI_MFM_Item_Group__c> mapItemGroup = new Map<String, ASI_MFM_Item_Group__c>();
            List<String> errorMsg = new List<String>();
            List<String> errorMsg2 = new List<String>();
            Set<id> headerID = new Set<id>();
            Set<String> itemGroupCode = new Set<String>();
            List<ASI_CRM_Price_And_Discount__c> insertPnDList = new List<ASI_CRM_Price_And_Discount__c>();
            List<ASI_CRM_Price_And_Discount__c> tmpPnDList = new List<ASI_CRM_Price_And_Discount__c>();
            List<ASI_CRM_Price_And_Discount_Detail__c> insertPnDLineItemList = new List<ASI_CRM_Price_And_Discount_Detail__c>();
            List<ASI_CN_NPL_NPL_Request__c> updateNPL = new List<ASI_CN_NPL_NPL_Request__c>();
            Boolean hasError = FALSE;
            
            if(objectType == 'ASI_CN_NPL_Item_Master__c'){
                for(sObject obj : triggerNew){
                    itemGroupCode.add(string.valueOf(obj.get('ASI_CN_NPL_Item_Goup_Code__c')));
                }
            }else if(objectType == 'ASI_CN_NPL_NPL_Request__c'){
                for(ASI_CN_NPL_Item_Master__c obj : matchedCase.values()){
                	itemGroupCode.add(obj.ASI_CN_NPL_Item_Goup_Code__c);
            	}
            }
            
            
            List<ASI_MFM_Item_Group__c> itemGroup = new List<ASI_MFM_Item_Group__c>([SELECT id
                                                                                     , ASI_MFM_Sub_brand__c
                                                                                     , ASI_MFM_Item_Group_Code__c
                                                                                     FROM ASI_MFM_Item_Group__c
                                                                                     WHERE ASI_MFM_Item_Group_Code__c IN : itemGroupCode
                                                                                    ]);
            
            for(ASI_MFM_Item_Group__c obj : itemGroup){
                mapItemGroup.put(obj.ASI_MFM_Item_Group_Code__c, obj);
            }
            
            BOOLEAN itemGroupExist = TRUE;
            
            for(sObject obj : triggerNew){
                if(objectType == 'ASI_CN_NPL_Item_Master__c'){
                    if(!mapItemGroup.containsKey(String.valueOf(obj.get('ASI_CN_NPL_Item_Goup_Code__c')))){
                        obj.addError('Item Group with Item Group Code (' + obj.get('ASI_CN_NPL_Item_Goup_Code__c') + ') not found.');
                        itemGroupExist = FALSE;
                        hasError = TRUE;
                    	break;
                    }
                }else if(objectType == 'ASI_CN_NPL_NPL_Request__c'){
                    if(!mapItemGroup.containsKey(matchedCase.get(obj.id).ASI_CN_NPL_Item_Goup_Code__c)){
                        obj.addError('Item Group with Item Group Code (' + matchedCase.get(obj.id).ASI_CN_NPL_Item_Goup_Code__c + ') not found.');
                		itemGroupExist = FALSE;
                        hasError = TRUE;
                        break;
                    }
                }
            }
            
            if(!hasError){
                for(String obj : matchedCase.keySet()){
                    
                    insertPnDList.add(new ASI_CRM_Price_And_Discount__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_NPL_T1_Price_Request_RO')
                                                                        , ASI_CRM_NPL_Reference_Number__c = obj
                                                                        , ASI_CRM_Status__c = 'Pending for BO to PRCSW Pirce'
                                                                        , ASI_CRM_Remark__c = matchedCase.get(obj).ASI_CN_NPL_Item_Group_Description_GE__c + '\r\n' + matchedCase.get(obj).ASI_CN_NPL_Item_Group_Description_CH__c + '\r\nItem Group Code : ' + matchedCase.get(obj).ASI_CN_NPL_Item_Goup_Code__c
                                                                        , ASI_CRM_Item_Master_Reference_Number__c = matchedCase.get(obj).id
                                                                        , ASI_CRM_Effective_From__c = date.today()
                                                                       ));
                    updateNPL.add(new ASI_CN_NPL_NPL_Request__c(id = obj
                                                                , ASI_CRM_CN_NPLT1PriceFlag__c = true
                                                               ));
                    
                }
                Savepoint sp = Database.setSavepoint();
                try{
                    
                    results = database.insert(insertPnDList,true);
                    
                    if(objectType == 'ASI_CN_NPL_Item_Master__c')
                        update updateNPL;
                    else if(objectType == 'ASI_CN_NPL_NPL_Request__c'){
                        for(sObject obj : triggerNew){
                            if(matchedCase.containsKey(obj.id))
                                obj.put('ASI_CRM_CN_NPLT1PriceFlag__c', true);
                        }
                    }
                    
                    for(Database.SaveResult res: results){
                        if(res.isSuccess()){
                            headerID.add(res.getId());
                        }
                    }
                    
                }catch(dmlexception ex){
                    hasError = TRUE;
                    for(sObject obj : triggerNew){
                        obj.addError(ex.getMessage() );
                    }
                    Database.rollback(sp);
                }
                
                if(!hasError){
                    tmpPnDList = [SELECT id
                                  , ASI_CRM_Item_Master_Reference_Number__r.ASI_CN_NPL_Item_Goup_Code__c
                                  , ASI_CRM_NPL_Reference_Number__c
                                  FROM ASI_CRM_Price_And_Discount__c
                                  WHERE id IN : headerID
                                 ];
                    
                    for(ASI_CRM_Price_And_Discount__c obj : tmpPnDList){
                        if(objectType == 'ASI_CN_NPL_Item_Master__c' && itemGroupExist){
                            
                            insertPnDLineItemList.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = obj.id
                                                                                               , ASI_CRM_Item_Group_Description__c = mapItemGroup.get(matchedCase.get(obj.ASI_CRM_NPL_Reference_Number__c).ASI_CN_NPL_Item_Goup_Code__c).id
                                                                                               , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                                                               , ASI_CRM_Total_Estimated_Vol_BT__c = mapNPL.get(obj.ASI_CRM_NPL_Reference_Number__c).ASI_CN_NPL_Target_Vol_Domestic__c
                                                                                               , ASI_CRM_New_Price_BT_with_VAT__c = mapNPL.get(obj.ASI_CRM_NPL_Reference_Number__c).ASI_CN_NPL_Final_Proposed_Selling_Price__c
                                                                                              ));
                        }else if(objectType == 'ASI_CN_NPL_NPL_Request__c' && itemGroupExist){
                            
                            insertPnDLineItemList.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = obj.id
                                                                                               , ASI_CRM_Item_Group_Description__c = mapItemGroup.get(obj.ASI_CRM_Item_Master_Reference_Number__r.ASI_CN_NPL_Item_Goup_Code__c).id
                                                                                               , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                                                               , ASI_CRM_Total_Estimated_Vol_BT__c = mapNPL.get(obj.ASI_CRM_NPL_Reference_Number__c).ASI_CN_NPL_Target_Vol_Domestic__c
                                                                                               , ASI_CRM_New_Price_BT_with_VAT__c = mapNPL.get(obj.ASI_CRM_NPL_Reference_Number__c).ASI_CN_NPL_Final_Proposed_Selling_Price__c
                                                                                              ));
                        }
                    }
                    
                    try{
                        
                        insert insertPnDLineItemList;
                        
                    }catch(dmlexception ex){
                        for(sObject obj : triggerNew){
                            obj.addError(ex.getMessage());
                        }
                        Database.rollback(sp);
                    }
                }
            }
    	}
    }
}