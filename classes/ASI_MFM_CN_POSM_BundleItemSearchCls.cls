global with sharing class ASI_MFM_CN_POSM_BundleItemSearchCls {
	public String posmItemMapJson {get;set;}
    public Boolean isDelete {get;set;}
    public String dItemId {get;set;}
    
	public ASI_MFM_CN_POSM_BundleItemSearchCls() {
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        try {
            String bDelete = ApexPages.currentPage().getParameters().get('delete');
            if(bDelete!=null && bDelete=='true') {
                isDelete = true;
                dItemId = ApexPages.currentPage().getParameters().get('Id');
            } else {
                isDelete = false;
                dItemId = '';
            }
        } catch(Exception e) {
        	
        }  
        // Enoch@Introv 20191204 Fix view state
        posmItemMapJson = '';
/*
        List<ASI_MFM_Item_Group__c> itemGroupList = [SELECT Id,name,ASI_MFM_Item_Group_Code__c,ASI_MFM_Item_Group_Description__c,ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Bundle_Item_Group__c 
                                                     FROM ASI_MFM_Item_Group__c 
                                                     WHERE RecordTypeId=:posmitemRTID 
                                                     AND ASI_MFM_Utilization_Status__c Like 'Active'
                                                     AND ASI_MFM_Bundle_Item_Group__c = false
                                                    ];
        
        Map<String,ItemGroupObj> posmItemGroupMap = new Map<String,ItemGroupObj>();
        for(ASI_MFM_Item_Group__c itemGroup : itemGroupList) {
            ItemGroupObj objItemGroup = new ItemGroupObj(itemGroup);
            posmItemGroupMap.put(objItemGroup.name, objItemGroup);
        }
        
        
        posmItemMapJson = JSON.serialize(posmItemGroupMap);
*/
    }
    
    @RemoteAction
    Public Static Map<String,ItemGroupObj> searchItemByName(String keyword){
        String searchName = '%'+keyword+'%';
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        List<ASI_MFM_Item_Group__c> itemGroupList = [SELECT Id,name,ASI_MFM_Item_Group_Code__c,ASI_MFM_Item_Group_Description__c,ASI_MFM_Reference_Unit_Price__c, ASI_MFM_Bundle_Item_Group__c 
                                                     FROM ASI_MFM_Item_Group__c 
                                                     WHERE RecordTypeId=:posmitemRTID 
                                                     AND ASI_MFM_Utilization_Status__c Like 'Active'
                                                     AND ASI_MFM_Bundle_Item_Group__c = false
                                                     AND name LIKE :searchName
                                                    ];
        
        Map<String,ItemGroupObj> posmItemGroupMap = new Map<String,ItemGroupObj>();
        for(ASI_MFM_Item_Group__c itemGroup : itemGroupList) {
            ItemGroupObj objItemGroup = new ItemGroupObj(itemGroup);
            posmItemGroupMap.put(objItemGroup.name, objItemGroup);
        }
        return posmItemGroupMap;
    }
    
    @RemoteAction 
    Public Static String deleteBundle(String itemid) {
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        try {
            if(itemid!=null && itemid!='') {
                ASI_MFM_Item_Group__c itemGroupList = [SELECT Id, ASI_MFM_Status__c, ASI_MFM_Item_Group_Code__c
                                                       FROM ASI_MFM_Item_Group__c
                                                       WHERE RecordTypeId=:posmitemRTID 
                                                       AND Id=:itemid
                                                       AND ASI_MFM_Bundle_Item_Group__c = true LIMIT 1];
                if(itemGroupList!=null && (itemGroupList.ASI_MFM_Item_Group_Code__c != null || itemGroupList.ASI_MFM_Item_Group_Code__c != '')) {
                    itemGroupList.ASI_MFM_Status__c = 'Draft';
                    update itemGroupList;
                    delete itemGroupList;
                }
            }
        } catch(Exception e) {
            system.debug('fail to delete : ' + e.getMessage());
        }
    	return itemid;
    }
    
    @RemoteAction
    global static ResultObj searchBundleItem(String dataSet) {
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
        List<Object> itemList = (List<Object>)dataMap.get('itemList');
        
        Set<Id> itemIdSet = new Set<Id>();
        List<String> itemSearchList = new List<String>();
        List<BundleItem> searchItemList = new List<BundleItem>();
        for(Object itemObj : itemList) {
            String jsonData = JSON.serialize(itemObj);
            BundleItem item = (BundleItem)JSON.deserialize(jsonData, BundleItem.class);
            if(item.id==null) return new ResultObj(false,'Please Select Valid Item Group.',null);
            if(itemIdSet.contains(item.id)) return new ResultObj(false,'Please Combain Same Item Group.',null);
            
            itemIdSet.add(item.id);
            itemSearchList.add(item.id+''+item.qty);
            searchItemList.add(item);
        }
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        Id posmItemLineRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group_Line__cASI_MFM_CN_Bundle_Item_Group_Line');
        List<ASI_MFM_Item_Group__c> posmItemList = [SELECT id, name,
                                                    (SELECT ASI_MFM_Item_Group_Component__c, ASI_MFM_Unit_Quantity_in_Bundle__c
                                                     FROM Item_Group_Lines__r)
                                                    FROM ASI_MFM_Item_Group__c
                                                    WHERE ASI_MFM_Bundle_Item_Group__c = true
                                                    AND RecordTypeId = :posmitemRTID
                                                    AND id IN (SELECT ASI_MFM_Item_Group__c
                                                               FROM ASI_MFM_Item_Group_Line__c
                                                               WHERE ASI_MFM_Item_Group_Component__c IN :itemIdSet
                                                               AND RecordTypeId = :posmItemLineRTID
                                                              )];
        List<ASI_MFM_Item_Group__c> matchedItemGroupList = new List<ASI_MFM_Item_Group__c>();
        List<String> diffDebug;
        List<String> arrDebug1;
        List<String> arrDebug2;
        for(ASI_MFM_Item_Group__c itemGroup : posmItemList) {
            List<String> componentItemList = new List<String>();
            for(ASI_MFM_Item_Group_Line__c  itemLine : itemGroup.Item_Group_Lines__r) {
                componentItemList.add(itemLine.ASI_MFM_Item_Group_Component__c+''+itemLine.ASI_MFM_Unit_Quantity_in_Bundle__c);
            }
            if(componentItemList.size()!=itemSearchList.size()) continue;
            if(arrayMatch(componentItemList,itemSearchList).size()==componentItemList.size()) {
                matchedItemGroupList.add(itemGroup);
            } else {
                continue;
            }
        }
        if(matchedItemGroupList.size()>1) {
            String itemGroupName;
            for(ASI_MFM_Item_Group__c matchedItemGroup : matchedItemGroupList){
                itemGroupName += ' ' +  matchedItemGroup.name;
            }
            return new ResultObj(false,'More Than one Match Item Group :'+itemGroupName,null);       
        }
        if(matchedItemGroupList.size()==0) {
            return new ResultObj(true,'No Match Item Group.',null);
        }
        return new ResultObj(true,'success',matchedItemGroupList.get(0).id);
    }
    
    @RemoteAction
    global static ResultObj createBundleItem(String dataSet) {
        try {
            Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSet);
            List<Object> itemList = (List<Object>)dataMap.get('itemList');
            List<BundleItem> searchItemList = new List<BundleItem>();
            for(Object itemObj : itemList) {
                String jsonData = JSON.serialize(itemObj);
                BundleItem item = (BundleItem)JSON.deserialize(jsonData, BundleItem.class);
                searchItemList.add(item);
            }
            return new ResultObj(true,'success',insertNewBundleItem(searchItemList));
            
        } catch (Exception e) {
            return new ResultObj(false,'Fail To Create Item. Error : ' + e.getMessage(),null);
        }
    }
    
    static Id insertNewBundleItem(List<BundleItem> searchItem) {
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        Id posmItemLineRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group_Line__cASI_MFM_CN_Bundle_Item_Group_Line');
        ASI_MFM_Item_Group__c newItemGroup = new ASI_MFM_Item_Group__c(name='System autoupdate, do not change.',RecordTypeId=posmitemRTID, ASI_MFM_Bundle_Item_Group__c=true);
        insert newItemGroup;
        List<ASI_MFM_Item_Group_Line__c> itemLineList = new List<ASI_MFM_Item_Group_Line__c>();
        for(BundleItem item : searchItem) {
            ASI_MFM_Item_Group_Line__c itemGroupLine = new ASI_MFM_Item_Group_Line__c(
                ASI_MFM_Item_Group__c = newItemGroup.id,
                ASI_MFM_Item_Group_Component__c = item.id,
                ASI_MFM_Unit_Quantity_in_Bundle__c = item.qty,
                RecordTypeId=posmItemLineRTID
            );
            itemLineList.add(itemGroupLine);
        }
        insert itemLineList;
        return newItemGroup.id;
    }
    
    static List<String> arrayMatch(List<String> arr1, List<String> arr2) {
        arr1.sort();
        arr2.sort();
        List<String> ret = new List<String>();
        for(Integer i=0; i<arr1.size(); i++) {
            if(arr2.indexOf(arr1.get(i)) > -1) {
                ret.add(arr1.get(i));
            }
        }
        return ret;
    }
    
    
    global class ResultObj {
    	public String message;
        public Boolean success;
        public Id bundleItemId;
        public ResultObj(Boolean b, String m, String id){
            message = m;
            success = b;
            bundleItemId = id;
        }
    }
    
    global class ItemGroupObj {
        public Id id;
        public String name;
        public String description;
        public decimal unitPrice;
        public Boolean isBundle;
        public ItemGroupObj(ASI_MFM_Item_Group__c itemGroup) {
            this.id = itemGroup.id;
            this.name = itemGroup.name+' '+itemGroup.ASI_MFM_Item_Group_Code__c;
            this.unitPrice = (itemGroup.ASI_MFM_Reference_Unit_Price__c!=null)? itemGroup.ASI_MFM_Reference_Unit_Price__c:0;
            this.description = (itemGroup.ASI_MFM_Item_Group_Description__c!=null)? itemGroup.ASI_MFM_Item_Group_Description__c:'';
            this.isBundle = (itemGroup.ASI_MFM_Bundle_Item_Group__c!=null)? itemGroup.ASI_MFM_Bundle_Item_Group__c:false;
        }
    }
    
    global class BundleItem {
        public Decimal qty;
        public String name;
        public Id id;
        
        public BundleItem(){}
	}
}