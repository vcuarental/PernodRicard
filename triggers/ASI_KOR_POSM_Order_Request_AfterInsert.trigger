/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Request_AfterInsert
* Description: After insert trigger for ASI_KOR_POSM_Order_Request
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-12-13       Alan Lau                Created
****************************************************************************************************************************/

trigger ASI_KOR_POSM_Order_Request_AfterInsert on ASI_KOR_POSM_Order_Request__c (after insert) {

    List<ASI_KOR_POSM_Order_Request__c> barStylingPOSMHeaderList = new List<ASI_KOR_POSM_Order_Request__c>();
    List<ASI_KOR_POSM_Order_Request__c> lockedBarStylingItemHeaderList = new List<ASI_KOR_POSM_Order_Request__c>();

    for (ASI_KOR_POSM_Order_Request__c posmHeader : Trigger.new) {
        if (Global_RecordTypeCache.getRt(posmHeader.RecordTypeId).DeveloperName.contains('ASI_KOR_Bar_Styling_POSM_Request')) {
            barStylingPOSMHeaderList.add(posmHeader);
        } else if (Global_RecordTypeCache.getRt(Trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_KOR_Locked_Bar_Styling_Item_Request')) {
            lockedBarStylingItemHeaderList.add(posmHeader);
        }
    }

    if (!barStylingPOSMHeaderList.isEmpty()) {
        ASI_KOR_POSM_Order_Request_TriggerClass.grantRecordAccessToNewApprover(barStylingPOSMHeaderList);
        ASI_KOR_POSM_Order_Request_TriggerClass.sumActualSpendingAmountForBudget(barStylingPOSMHeaderList);
    }

    if (!lockedBarStylingItemHeaderList.isEmpty()) {
        ASI_KOR_POSM_Order_Request_TriggerClass.sumActualSpendingAmountForBudget(lockedBarStylingItemHeaderList);
    }

}