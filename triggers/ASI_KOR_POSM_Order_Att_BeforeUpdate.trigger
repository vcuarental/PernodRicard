/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Att_BeforeUpdate
* Description: Before Update Trigger for ASI_KOR_POSM_Order_Attachment
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-12-19       Alan Lau                Created
****************************************************************************************************************************/
trigger ASI_KOR_POSM_Order_Att_BeforeUpdate on ASI_KOR_POSM_Order_Attachment__c (before update) {

    List<ASI_KOR_POSM_Order_Attachment__c> barStylingAttachmentList = new List<ASI_KOR_POSM_Order_Attachment__c>();

    for (ASI_KOR_POSM_Order_Attachment__c attachment : Trigger.new) {
        if (Global_RecordTypeCache.getRt(attachment.RecordTypeId).DeveloperName.contains('ASI_KOR_Bar_Styling_Attachment')) {
            barStylingAttachmentList.add(attachment);
        }
    }

    if (!barStylingAttachmentList.isEmpty()) {
        ASI_KOR_POSM_Order_Att_TriggerClass.blockAttachmentForFinalizedRequest(barStylingAttachmentList);
    }

}