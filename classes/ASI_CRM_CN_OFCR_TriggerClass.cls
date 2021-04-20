public without sharing class ASI_CRM_CN_OFCR_TriggerClass {
    
    public static void beforeUpsertMethod(List<ASI_CRM_Order_Form_Customer_Relationship__c> triggerOld){
        
        Set<id> customerSetID = new Set<id>();
        Map<String, ASI_CRM_Order_Form_Customer_Relationship__c> mapOrderForm = new Map<String, ASI_CRM_Order_Form_Customer_Relationship__c>();
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c obj : triggerOld)
        	customerSetID.add(obj.ASI_CRM_Customer__c);
            
        List<ASI_CRM_Order_Form_Customer_Relationship__c> allOrderFormCustomerRelationship = new List<ASI_CRM_Order_Form_Customer_Relationship__c>([SELECT id
                                                                                                                                                    , ASI_CRM_Order_Form_Type__c
                                                                                                                                                    , ASI_CRM_Customer__c
                                                                                                                                                    FROM ASI_CRM_Order_Form_Customer_Relationship__c
                                                                                                                                                    WHERE ASI_CRM_Customer__c IN : customerSetID
                                                                                                                                                    AND id NOT IN : triggerOld
                                                                                                                                                   ]);
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c obj : allOrderFormCustomerRelationship)
            mapOrderForm.put(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Order_Form_Type__c, obj);
        
        for(ASI_CRM_Order_Form_Customer_Relationship__c obj : triggerOld){
            
            if(mapOrderForm.containsKey(obj.ASI_CRM_Customer__c + '' + obj.ASI_CRM_Order_Form_Type__c)){
                obj.addError('Duplicate Order Form Customer Relationship');
            }
        }
    }
}