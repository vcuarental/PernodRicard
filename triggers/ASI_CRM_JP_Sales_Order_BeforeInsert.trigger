trigger ASI_CRM_JP_Sales_Order_BeforeInsert on ASI_CRM_JP_Sales_Order__c (before insert) {
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
     if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP')){
        if (!Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP_Manual_JDE_SO')) {
            ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {
                new ASI_CRM_JP_EncodingConverterHelper(new Set<String>{'ASI_CRM_Mailing_Name__c', 
                                                                       'ASI_CRM_Postal_Code__c', 
                                                                       'ASI_CRM_Address_Line_1__c', 
                                                                       'ASI_CRM_Address_Line_2__c', 
                                                                       'ASI_CRM_Remark__c', 
                                                                       'ASI_CRM_AKABOU_Delivery_Time__c'}),
                new ASI_CRM_JP_AssignSOAutoNumber(),
                new ASI_CRM_JP_SOAssignDutyFreeSoldTo(),
                new ASI_CRM_JP_SOAssignMarketingFOCSoldTo(),      // [SH] 2019-05-30    
                new ASI_CRM_JP_SOAssignApprover(),
                new ASI_CRM_JP_SOAssignSalesman()
            };
        }                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_INSERT, trigger.new, trigger.newMap, trigger.oldMap);
    }        
}