trigger ASI_CRM_JP_Sales_Order_BeforeUpdate on ASI_CRM_JP_Sales_Order__c (before update) {
    List<ASI_CRM_JP_TriggerAbstract> ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract>();
    
     if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeid).developerName.contains('ASI_CRM_JP')){
        ASI_CRM_JP_triggerClasses = new List<ASI_CRM_JP_TriggerAbstract> {
            new ASI_CRM_JP_EncodingConverterHelper(new Set<String>{'ASI_CRM_Mailing_Name__c', 
                                                                       'ASI_CRM_Postal_Code__c', 
                                                                       'ASI_CRM_Address_Line_1__c', 
                                                                       'ASI_CRM_Address_Line_2__c', 
                                                                       'ASI_CRM_Remark__c', 
                                                                       'ASI_CRM_AKABOU_Delivery_Time__c'}),
            new ASI_CRM_JP_AssignSOAutoNumber(),                
            new ASI_CRM_JP_SOAssignDate(),
            new ASI_CRM_JP_SOAssignAPCode(),
            new ASI_CRM_JP_SOAssignSalesmanCode(),
            new ASI_CRM_JP_SOAssignSalesman(),
            new ASI_CRM_JP_SOAssignApprover(),
            new ASI_CRM_JP_SOAssignDutyFreeSoldTo(),
            new ASI_CRM_JP_SOAssignMarketingFOCSoldTo() //[SH] 2019-06-14    
        };                    
    } 
    
    for (ASI_CRM_JP_TriggerAbstract triggerClass : ASI_CRM_JP_triggerClasses){
        triggerClass.executeTriggerAction(ASI_CRM_JP_TriggerAbstract.TriggerAction.BEFORE_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}