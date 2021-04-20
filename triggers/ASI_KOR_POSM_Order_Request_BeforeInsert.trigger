/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Request_BeforeInsert
* Description: Before insert trigger for ASI_KOR_POSM_Order_Request
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??               ??                      Created
* 2018-11-27       Alan Lau                Created in B7
****************************************************************************************************************************/

trigger ASI_KOR_POSM_Order_Request_BeforeInsert on ASI_KOR_POSM_Order_Request__c(before insert) {

    if (trigger.new[0].recordTypeId!=NULL && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_KOR_New_High_Value_POSM_Request')){
        ASI_KOR_POSM_Order_Request_TriggerClass.BeforeUpsertMethod(Trigger.New, NULL); 
    }
    
      
    if (trigger.new[0].recordTypeId!=NULL && Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_KOR_New_POSM_Request')){
        ASI_KOR_POSM_Order_Request_TriggerClass.BeforeUpsertMethod(Trigger.New, NULL); 
    }

    List<ASI_KOR_POSM_Order_Request__c> barStylingPOSMHeaderList = new List<ASI_KOR_POSM_Order_Request__c>();

    for (ASI_KOR_POSM_Order_Request__c posmHeader : Trigger.new) {
        if (Global_RecordTypeCache.getRt(posmHeader.RecordTypeId).DeveloperName.contains('ASI_KOR_Bar_Styling_POSM_Request')) {
            barStylingPOSMHeaderList.add(posmHeader);
        }
    }

    if (!barStylingPOSMHeaderList.isEmpty()) {
        ASI_KOR_POSM_Order_Request_TriggerClass.setSysApprover(barStylingPOSMHeaderList);
        ASI_KOR_POSM_Order_Request_TriggerClass.setDefaultContractPeriod(barStylingPOSMHeaderList);
        ASI_KOR_POSM_Order_Request_TriggerClass.setAverageVolume(barStylingPOSMHeaderList);
    }

}