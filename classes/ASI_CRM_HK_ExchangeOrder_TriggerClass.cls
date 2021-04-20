public class ASI_CRM_HK_ExchangeOrder_TriggerClass {
    public static void routineBeforeInsert(list<ASI_CRM_Exchange_Order__c> trigger_new, map<id, ASI_CRM_Exchange_Order__c> trigger_oldMap) {
        for (ASI_CRM_Exchange_Order__c eo: trigger_new) {
            //System.debug('EO MAN: '+eo.ASI_CRM_HK_Channel_Manager__c);
            if (Global_RecordTypeCache.getRt(eo.recordTypeId).developerName.contains('ASI_CRM_HK_Exchange_Order')) {
                if (eo.ASI_CRM_HK_Channel_Manager__c == '' || eo.ASI_CRM_HK_Channel_Manager__c == null){
                    try{	
                        String uid = eo.Ownerid;       
                        user u=((user)database.query('select managerid from user where id =:uid')); 
                        if(u!=null && u.ManagerId!=null)
                            eo.ASI_CRM_HK_Channel_Manager__c = u.ManagerId;
                        //System.debug('ManagerID:::::::' + u.ManagerId);    
                    } catch (Exception e){
                        System.debug('Error: ' +eo.owner.name);
                    }
                }
                
            }
        }
    
    }
    
	public static void routineBeforeUpdate(list<ASI_CRM_Exchange_Order__c> trigger_new, map<id, ASI_CRM_Exchange_Order__c> trigger_oldMap) {
        //20151225 Ben @ Elufa System
        
        List<ASI_CRM_Exchange_Order_Item__c> lineItemList = new List<ASI_CRM_Exchange_Order_Item__c>([SELECT id
                                                                                                      , ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c
                                                                                                      , ASI_CRM_Exchange_Order__c
                                                                                                      FROM ASI_CRM_Exchange_Order_Item__c
                                                                                                      WHERE ASI_CRM_Exchange_Order__c IN : trigger_new
                                                                                                      ORDER BY Name DESC
                                                                                                     ]);
        Set<String> salesOrderNo = new Set<String>();
        
        for(ASI_CRM_Exchange_Order_Item__c obj : lineItemList){
            salesOrderNo.add(obj.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c);
        }
        
        List<ASI_HK_CRM_Sales_Order__c> salesOrderList = new List<ASI_HK_CRM_Sales_Order__c>([SELECT id
                                                                                              , Name
                                                                                              , ASI_HK_CRM_JDE_Order_No__c
                                                                                              , ASI_HK_CRM_Delivery_Address__c
                                                                                              , ASI_HK_CRM_Attention__c
                                                                                              , ASI_HK_CRM_Phone_Number__c
                                                                                              FROM ASI_HK_CRM_Sales_Order__c
                                                                                              WHERE ASI_HK_CRM_JDE_Order_No__c IN : salesOrderNo
                                                                                             ]);
        
        Map<String, ASI_HK_CRM_Sales_Order__c> mapSalesOrder = new Map<String, ASI_HK_CRM_Sales_Order__c>();
        Map<String, ASI_HK_CRM_Sales_Order__c> mapFieldValue = new Map<String, ASI_HK_CRM_Sales_Order__c>();
        for(ASI_HK_CRM_Sales_Order__c obj : salesOrderList){
            mapSalesOrder.put(obj.ASI_HK_CRM_JDE_Order_No__c, obj);
        }
        
        for(ASI_CRM_Exchange_Order_Item__c obj : lineItemList){
            if(mapSalesOrder.containsKey(obj.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c)){
                mapFieldValue.put(obj.ASI_CRM_Exchange_Order__c, mapSalesOrder.get(obj.ASI_CRM_Sales_Order_History_Detail__r.ASI_HK_CRM_Sales_Order_History__r.ASI_HK_CRM_Order_No__c));
            }
        }
        
        //20151225 End
        
        
        for (ASI_CRM_Exchange_Order__c eo: trigger_new) {
            
            //20151224 Ben @ Elufa System
            if(trigger_oldMap.get(eo.id).ASI_CRM_Status__c != eo.ASI_CRM_Status__c && eo.ASI_CRM_Status__c == 'Submitted' && eo.ASI_CRM_Number_Of_Line_Item__c == 0){
                eo.addError('At least one line item is required to submit for approval');
                break;
            }
            String[] typeSet = new String[]{'S4', 'S5', 'S9'};
            //id eoId = trigger_oldMap.get(eo.id).ASI_CRM_Exchange_Order__c;
            List<ASI_CRM_Exchange_Order_Item__c> No_specificOrderType = [Select id
                                                                         from ASI_CRM_Exchange_Order_Item__c 
                                                                         where ASI_CRM_Exchange_Order__c =: trigger_oldMap.get(eo.id).id
                                                                         	AND ASI_CRM_HK_Order_Type__c = 1];
            
            //System.debug('No_specificOrderType: '+No_specificOrderType.size());
            //System.debug(trigger_oldMap.get(eo.id).id);
            //System.debug(trigger_oldMap.get(eo.id).ASI_CRM_PO_No__c);
            //System.debug(eo.ASI_CRM_Status__c);
            if (No_specificOrderType.size() > 0 && trigger_oldMap.get(eo.id).ASI_CRM_PO_No__c == null && eo.ASI_CRM_Status__c == 'Submitted'){
                eo.addError('PO # field cannot be blank when JDE order type = (S4/S5/S9)');
                break;
            }
            
            if((eo.ASI_CRM_Address__c == NULL || eo.ASI_CRM_Address__c == '') && (eo.ASI_CRM_Attention__c == NULL || eo.ASI_CRM_Attention__c == '') && (eo.ASI_CRM_Phone__c == NULL || eo.ASI_CRM_Phone__c == '')){
                if(mapFieldValue.containsKey(eo.id)){
                    eo.ASI_CRM_Address__c = mapFieldValue.get(eo.id).ASI_HK_CRM_Delivery_Address__c;
                    eo.ASI_CRM_Attention__c = mapFieldValue.get(eo.id).ASI_HK_CRM_Attention__c;
                    eo.ASI_CRM_Phone__c = mapFieldValue.get(eo.id).ASI_HK_CRM_Phone_Number__c;
                }
            }
            
            //20151224 End
            //System.debug('EO MAN: '+eo.ASI_CRM_HK_Channel_Manager__c);
            if (Global_RecordTypeCache.getRt(eo.recordTypeId).developerName.contains('ASI_CRM_HK_Exchange_Order')) {

                 /*if (eo.ASI_CRM_HK_Channel_Manager__c == '' || eo.ASI_CRM_HK_Channel_Manager__c == null){
                   //System.debug('ManagerID:::::::Error');    
                    try{	
                        String uid = eo.Ownerid;       
                        user u=((user)database.query('select managerid from user where id =:uid')); 
                        if(u!=null && u.ManagerId!=null)
                            eo.ASI_CRM_HK_Channel_Manager__c = u.ManagerId;
                        //System.debug('ManagerID:::::::' + u.ManagerId);    
                    } catch (Exception e){
                        //System.debug('Error: ' +eo.owner.name);
                    }
                }*/
            }
        }   
    }
    
}