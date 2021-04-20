public without sharing class ASI_CRM_CN_OrderFormTriggerClass {
    
    public static void beforeUpdateMethod(List<ASI_CRM_Order_Form__c> triggerNew, Map<id, ASI_CRM_Order_Form__c> triggerOldMap){
        
        List<ASI_CRM_Order_Form_Customer_Relationship__c> OFCR = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id
                                                                                                                        FROM ASI_CRM_Order_Form_Customer_Relationship__c
                                                                                                                        WHERE ASI_CRM_Order_Form__c IN : triggerNew
                                                                                                                       ]);
        
        for(ASI_CRM_Order_Form__c obj : triggerNew){
            if(OFCR.size() > 0)
                if(triggerOldMap.get(obj.id).ASI_CRM_Order_Form_Type__c != obj.ASI_CRM_Order_Form_Type__c)
                	obj.addError('Order Form type change is not allowed');
        }
    }

    public static void beforeUpsertMethod(List<ASI_CRM_Order_Form__c> triggerNew){
       
        /*List<ASI_CRM_Order_Form__c> normalItemT1Master = new List<ASI_CRM_Order_Form__c>([SELECT id
                                                                                          FROM ASI_CRM_Order_Form__c
                                                                                          WHERE ASI_CRM_T1_Master__c = TRUE
                                                                                          AND ASI_CRM_Order_Form_Type__c = 'Normal Item'
                                                                                          AND id NOT IN : triggerNew
                                                                                         ]);
        
        List<ASI_CRM_Order_Form__c> rtdT1Master = new List<ASI_CRM_Order_Form__c>([SELECT id
                                                                                   FROM ASI_CRM_Order_Form__c
                                                                                   WHERE ASI_CRM_T1_Master__c = TRUE
                                                                                   AND ASI_CRM_Order_Form_Type__c = 'RTD'
                                                                                   AND id NOT IN : triggerNew
                                                                                  ]);
        
        for(ASI_CRM_Order_Form__c obj : triggerNew){
            if(obj.ASI_CRM_Order_Form_Type__c == 'RTD' && obj.ASI_CRM_T1_Master__c == TRUE && rtdT1Master.size() > 0)
                obj.addError(' RTD T1 Master Exists');
            if(obj.ASI_CRM_Order_Form_Type__c == 'Normal Item' && obj.ASI_CRM_T1_Master__c == TRUE && normalItemT1Master.size() > 0)
                obj.addError(' Normal Item T1 Master Exists');
        }*/
        //20160927, edited by Leo
        List<ASI_CRM_Order_Form__c> itemT1Master 
            = new List<ASI_CRM_Order_Form__c>([SELECT id, ASI_CRM_Order_Form_Type__c
                                               FROM ASI_CRM_Order_Form__c
                                               WHERE ASI_CRM_T1_Master__c = TRUE
                                               AND id NOT IN : triggerNew
                                              ]);
        Map<String,ASI_CRM_Order_Form__c> itemT1MasterMap = new Map<String,ASI_CRM_Order_Form__c>();
        if(itemT1Master.size()>0)
        {
            for(ASI_CRM_Order_Form__c obj: itemT1Master)
            {
                itemT1MasterMap.put(obj.ASI_CRM_Order_Form_Type__c, obj);
            }
            
            for(ASI_CRM_Order_Form__c obj : triggerNew){
                if(obj.ASI_CRM_Order_Form_Type__c == 'RTD' && obj.ASI_CRM_T1_Master__c == TRUE && itemT1MasterMap.containsKey(obj.ASI_CRM_Order_Form_Type__c))
                    obj.addError(' RTD T1 Master Exists');
                if(obj.ASI_CRM_Order_Form_Type__c == 'Normal Item' && obj.ASI_CRM_T1_Master__c == TRUE  && itemT1MasterMap.containsKey(obj.ASI_CRM_Order_Form_Type__c))
                    obj.addError(' Normal Item T1 Master Exists');
                if(obj.ASI_CRM_Order_Form_Type__c == 'Premium' && obj.ASI_CRM_T1_Master__c == TRUE  && itemT1MasterMap.containsKey(obj.ASI_CRM_Order_Form_Type__c))
                    obj.addError(' Premium T1 Master Exists');
            }
        }
        //20160927, edited by Leo
    }
}