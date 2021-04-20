global with sharing class ASI_MFM_CN_POSMCloneSecurity_Ctrl {
    Public Class ResultObj {
        public Boolean success;
        public String message;
        public List<ASI_MFM_POSMCatalogSecCtrl__c> secList;
        Public ResultObj(Boolean b, String m){
            success = b;
			message = m;
        }
    }
    
    @RemoteAction 
    Public Static List<ASI_MFM_POSMCatalogSecCtrl__c> searchTable(List<String> idList) {
        Id secTableRTID = Global_recordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM');
        return [SELECT id,name,ASI_MFM_ItemGroup__r.name,ASI_MFM_Warehouse__r.name,ASI_MFM_User__r.name,ASI_MFM_CanOrderinCatalog__c
                FROM ASI_MFM_POSMCatalogSecCtrl__c
                WHERE recordTypeId = :secTableRTID
                AND id IN :idList];
    }
    
    @RemoteAction 
    Public Static ResultObj cloneItem(String fromItem, String toItem, String cloneType){
        Id secTableRTID = Global_recordTypeCache.getRtId('ASI_MFM_POSMCatalogSecCtrl__cASI_MFM_CN_POSM');
        List<ASI_MFM_POSMCatalogSecCtrl__c> insertItem = new List<ASI_MFM_POSMCatalogSecCtrl__c>();
        try{
            Set<String> cloneIdSet = new Set<String>{fromItem, toItem};
			Set<String> existSecKeySet = new Set<String>();
            Map<String, ASI_MFM_POSMCatalogSecCtrl__c> deduplicationMap = new Map<String, ASI_MFM_POSMCatalogSecCtrl__c>();
            
            String soqlStr = 'SELECT id,name,ASI_MFM_MappingType__c,ASI_MFM_ItemGroup__c,ASI_MFM_Warehouse__c,ASI_MFM_User__c,ASI_MFM_CanOrderinCatalog__c,ASI_MFM_Region__c'
                +' FROM ASI_MFM_POSMCatalogSecCtrl__c'
                +' WHERE recordTypeId = :secTableRTID'
                +' AND ASI_MFM_User__r.isActive = true';
            if(cloneType == 'item'){
                soqlStr += ' AND ASI_MFM_ItemGroup__c IN :cloneIdSet';
                soqlStr += ' AND ASI_MFM_MappingType__c LIKE \'Item Group - User\'';
            } else if(cloneType == 'warehouse'){
                soqlStr += ' AND ASI_MFM_Warehouse__c IN :cloneIdSet';
                soqlStr += ' AND ASI_MFM_MappingType__c LIKE \'Warehouse - User\'';
            } else if(cloneType == 'user'){
                soqlStr += ' AND ASI_MFM_User__c IN :cloneIdSet';
            } else {
                return new ResultObj(false,'Invalid Clone Type '+ cloneType);
            }
            
            for(ASI_MFM_POSMCatalogSecCtrl__c fromSec : database.query(soqlStr)){
                String key = fromSec.ASI_MFM_MappingType__c+''+toItem+''+fromSec.ASI_MFM_Warehouse__c+''+fromSec.ASI_MFM_User__c+''+fromSec.ASI_MFM_CanOrderinCatalog__c;
                if(cloneType=='warehouse') key = fromSec.ASI_MFM_MappingType__c+''+fromSec.ASI_MFM_ItemGroup__c+''+toItem+''+fromSec.ASI_MFM_User__c+''+fromSec.ASI_MFM_CanOrderinCatalog__c;
                else if(cloneType=='user') key = fromSec.ASI_MFM_MappingType__c+''+fromSec.ASI_MFM_ItemGroup__c+''+fromSec.ASI_MFM_Warehouse__c+''+toItem+''+fromSec.ASI_MFM_CanOrderinCatalog__c;
                
                if(cloneType=='item'&&fromSec.ASI_MFM_ItemGroup__c==toItem) {
                    existSecKeySet.add(key);
                    if(deduplicationMap.get(key)!=null) deduplicationMap.remove(key);
                    continue;
                }else if(cloneType=='warehouse'&&fromSec.ASI_MFM_Warehouse__c==toItem) {
                    existSecKeySet.add(key);
                    if(deduplicationMap.get(key)!=null) deduplicationMap.remove(key);
                    continue;
                }else if(cloneType=='user'&&fromSec.ASI_MFM_User__c==toItem) {
                    existSecKeySet.add(key);
                    if(deduplicationMap.get(key)!=null) deduplicationMap.remove(key);
                    continue;
                }
                if(!existSecKeySet.contains(key)) deduplicationMap.put(key,fromSec);
            }
            for(String key : deduplicationMap.keySet()){
                ASI_MFM_POSMCatalogSecCtrl__c fromSec = deduplicationMap.get(key);
                ASI_MFM_POSMCatalogSecCtrl__c clonedSec = new ASI_MFM_POSMCatalogSecCtrl__c(
                    recordTypeId = secTableRTID,
                    ASI_MFM_MappingType__c = fromSec.ASI_MFM_MappingType__c,
                    ASI_MFM_CanOrderinCatalog__c = fromSec.ASI_MFM_CanOrderinCatalog__c,
                    ASI_MFM_Region__c = fromSec.ASI_MFM_Region__c
                );
                if(cloneType=='item'){
                    clonedSec.ASI_MFM_ItemGroup__c = toItem;
                    clonedSec.ASI_MFM_User__c = fromSec.ASI_MFM_User__c;
                }else if(cloneType=='warehouse'){
                    clonedSec.ASI_MFM_Warehouse__c = toItem;
                    clonedSec.ASI_MFM_User__c = fromSec.ASI_MFM_User__c;
                }else if(cloneType=='user'){
                    clonedSec.ASI_MFM_ItemGroup__c = fromSec.ASI_MFM_ItemGroup__c;
                    clonedSec.ASI_MFM_Warehouse__c = fromSec.ASI_MFM_Warehouse__c;
                    clonedSec.ASI_MFM_User__c = toItem;
                }
                
                insertItem.add(clonedSec);
            }
            insert insertItem;
            ResultObj result = new ResultObj(true,'success');
            result.secList = insertItem;
            return result;
        } catch(Exception e) {
            return new ResultObj(false,e.getMessage());
        }
    }
    
	@RemoteAction 
    Public Static Map<String,List<ASI_MFM_Item_Group__c>> searchItem(String fromItemCode,String toItemCode) {
        Map<String,List<ASI_MFM_Item_Group__c>> result = new Map<String,List<ASI_MFM_Item_Group__c>>();
        Id posmitemRTID = Global_recordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');
        try {
            Set<String> idSet = new Set<String>{fromItemCode,toItemCode};
            //String fromItem = '%'+fromItemCode+'%';
            //String toItem   = '%'+toItemCode+'%';
            for(ASI_MFM_Item_Group__c item :[
                SELECT id, Name, ASI_MFM_Item_Group_Code__c  
                FROM ASI_MFM_Item_Group__c  
                WHERE (ASI_MFM_Item_Group_Code__c LIKE :fromItemCode OR ASI_MFM_Item_Group_Code__c LIKE :toItemCode)
                AND recordTypeId = :posmitemRTID
                AND ASI_MFM_Utilization_Status__c LIKE 'Active'
                AND ASI_CRM_CN_Hidden__c = FALSE
            ]){
                if(!result.containsKey(item.ASI_MFM_Item_Group_Code__c)) {
                    String itemgroupcode = item.ASI_MFM_Item_Group_Code__c.toLowercase();
                    result.put(itemgroupcode,new List<ASI_MFM_Item_Group__c>());
                    result.get(itemgroupcode).add(item);
                }
            }
            
        } catch(Exception e) {
            system.debug('fail to search : ' + e.getMessage());
        }
    	return result;
    }
    @RemoteAction
    Public Static Map<String,List<ASI_FOC_Warehouse__c>> searchWarehouse(String fromWarehouseCode,String toWarehouseCode) {
        Map<String,List<ASI_FOC_Warehouse__c>> result = new Map<String,List<ASI_FOC_Warehouse__c>>();
        Id whRTID = Global_recordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse');
        try {
            Set<String> idSet = new Set<String>{fromWarehouseCode,toWarehouseCode};
            //String fromWhCode = '%'+fromWarehouseCode+'%';
            //String toWhCode   = '%'+toWarehouseCode+'%';
            for(ASI_FOC_Warehouse__c warehouse :[
                SELECT id, Name, ASI_FOC_Warehouse_Code__c, ASI_FOC_Warehouse_Description__c
                FROM ASI_FOC_Warehouse__c  
                WHERE (ASI_FOC_Warehouse_Code__c LIKE :fromWarehouseCode OR ASI_FOC_Warehouse_Code__c LIKE :toWarehouseCode)
                AND recordTypeId = :whRTID
            ]){
                if(!result.containsKey(warehouse.ASI_FOC_Warehouse_Code__c)) {
                    String warehousecode = warehouse.ASI_FOC_Warehouse_Code__c.toLowercase();
                    result.put(warehousecode,new List<ASI_FOC_Warehouse__c>());
                    result.get(warehousecode).add(warehouse);
                }
            }
        } catch(Exception e) {
            system.debug('fail to search : ' + e.getMessage());
        }
    	return result;
    }
    @RemoteAction
    Public Static Map<String,List<User>> searchUser(String fromUserCode,String toUserCode) {
        Map<String,List<User>> result = new Map<String,List<User>>();
        try {
            Set<String> idSet = new Set<String>{fromUserCode,toUserCode};
            //String fromUser = '%'+fromUserCode+'%';
            //String toUser = '%'+toUserCode+'%';
            for(User user :[
                SELECT id, Name, Username
                FROM User  
                WHERE (Username LIKE :fromUserCode OR Username LIKE :toUserCode)
            ]){
                if(!result.containsKey(user.Username)) {
                    String username = user.Username.toLowercase();
                    result.put(username,new List<User>());
                    result.get(username).add(user);
                }
            }
        } catch(Exception e) {
            system.debug('fail to search : ' + e.getMessage());
        }
    	return result;
    }
}