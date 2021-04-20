public without sharing class ASI_CRM_TW_Order_Status_TriggerCls{
    public static void routineAfterUpsert(list<ASI_CRM_Order_Status__c> trigger_new, map<id, ASI_CRM_Order_Status__c> trigger_oldMap) {
        Set<Id> setRequestLineId = new Set<Id>();
        Set<Id> setOrderStatusId = new Set<Id>();
        
        List<ASI_FOC_Request_Item__c> listRequestLine = new List<ASI_FOC_Request_Item__c>();
        List<ASI_CRM_Order_Status__c> listOrderStatus= new List<ASI_CRM_Order_Status__c>();
        Map<Id, ASI_CRM_Order_Status__c> mapOrderStatus = new Map<Id, ASI_CRM_Order_Status__c>();
        
        for(ASI_CRM_Order_Status__c os : trigger_new){
            setOrderStatusId.add(os.Id);
            setRequestLineId.add(os.ASI_CRM_FOC_POSM_Line_No__c);
            mapOrderStatus.put(os.Id, os);
        }
        
        listRequestLine = [SELECT Id, ASI_CRM_Shipped_Qty__c FROM ASI_FOC_Request_Item__c WHERE Id IN: setRequestLineId];
        
        for(ASI_CRM_Order_Status__c os : [SELECT Id, ASI_CRM_FOC_POSM_Line_No__c, ASI_CRM_Shipped_Qty__c FROM ASI_CRM_Order_Status__c WHERE ASI_CRM_FOC_POSM_Line_No__c IN: setRequestLineId]){
            if(!setOrderStatusId.contains(os.Id))
                mapOrderStatus.put(os.Id, os);
        }
        system.debug('Order Status Map: '+mapOrderStatus);
        
        for(ASI_FOC_Request_Item__c itm : listRequestLine){
            itm.ASI_CRM_Shipped_Qty__c = 0;
            
            for(Id key : mapOrderStatus.KeySet()){
                ASI_CRM_Order_Status__c tempOS = mapOrderStatus.get(key);
                
                if(itm.Id == tempOS.ASI_CRM_FOC_POSM_Line_No__c && tempOS.ASI_CRM_Shipped_Qty__c != null){
                    itm.ASI_CRM_Shipped_Qty__c += tempOS.ASI_CRM_Shipped_Qty__c;
                }
            }
        }
        system.debug('Request Line List: '+listRequestLine);
        
        update listRequestLine;
    }
    
    public static void routineAfterDelete(list<ASI_CRM_Order_Status__c> trigger_old) {
        Set<Id> setRequestLineId = new Set<Id>();
        List<ASI_FOC_Request_Item__c> listRequestLine = new List<ASI_FOC_Request_Item__c>();
        
        for(ASI_CRM_Order_Status__c os : trigger_old){
            setRequestLineId.add(os.ASI_CRM_FOC_POSM_Line_No__c);
        }
        
        listRequestLine = [SELECT Id, ASI_FOC_Request_Quantity_Bottle__c, ASI_CRM_Shipped_Qty__c FROM ASI_FOC_Request_Item__c WHERE Id IN: setRequestLineId];
        
        for(ASI_FOC_Request_Item__c itm : listRequestLine){
            if(itm.ASI_CRM_Shipped_Qty__c == null)
                itm.ASI_CRM_Shipped_Qty__c = 0;
            
            for(ASI_CRM_Order_Status__c os : trigger_old){
                itm.ASI_CRM_Shipped_Qty__c -= os.ASI_CRM_Shipped_Qty__c;
            }
        }        
        update listRequestLine;
    } 
}