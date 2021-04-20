/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Request_AfterUpdate
* Description: After update trigger for ASI_KOR_POSM_Order_Request
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??               ??                      Created
* 2018-12-13       Alan Lau                Created in B7
* 2018-12-21       Alan Lau                Replaced nested loop with Trigger.newMap
****************************************************************************************************************************/

trigger ASI_KOR_POSM_Order_Request_AfterUpdate on ASI_KOR_POSM_Order_Request__c (after update) {

    if (Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_KOR')
        && !Global_RecordTypeCache.getRt(trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_KOR_Bar_Styling_POSM_Request')
        && !Global_RecordTypeCache.getRt(trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_KOR_Locked_Bar_Styling_Item_Request')
    ){
        ASI_KOR_POSM_Order_Request_TriggerClass.routineAfterUpdate(trigger.new, trigger.oldMap); 
    }

    List<ASI_KOR_POSM_Order_Request__c> barStylingPOSMHeaderList = new List<ASI_KOR_POSM_Order_Request__c>();
    List<ASI_KOR_POSM_Order_Request__c> lockedBarStylingItemHeaderList = new List<ASI_KOR_POSM_Order_Request__c>();

    //group record by RecordType START
    for (ASI_KOR_POSM_Order_Request__c posmHeader : Trigger.new) {
        if (Global_RecordTypeCache.getRt(posmHeader.RecordTypeId).DeveloperName.contains('ASI_KOR_Bar_Styling_POSM_Request')) {
            barStylingPOSMHeaderList.add(posmHeader);
        } else if (Global_RecordTypeCache.getRt(Trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_KOR_Locked_Bar_Styling_Item_Request')) {
            lockedBarStylingItemHeaderList.add(posmHeader);
        }
    }
    //group record by RecordType START

    //handle New Bar-Styling Item Request START
    if (!barStylingPOSMHeaderList.isEmpty()) {
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForUpdatingBudgetActualSpendingAmount = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForAddingNewSysApprover = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForRemovingOldSysApprover = new List<ASI_KOR_POSM_Order_Request__c>();

        for (ASI_KOR_POSM_Order_Request__c barStylingPOSMHeader : barStylingPOSMHeaderList) {
            if (Trigger.newMap.containsKey(barStylingPOSMHeader.Id)) {
                if (Trigger.newMap.get(barStylingPOSMHeader.Id).ASI_KOR_Actual_Spending_Amount__c != Trigger.oldMap.get(barStylingPOSMHeader.Id).ASI_KOR_Actual_Spending_Amount__c) {
                    posmHeaderListForUpdatingBudgetActualSpendingAmount.add(barStylingPOSMHeader);
                }

                if (Trigger.oldMap.get(barStylingPOSMHeader.Id).ASI_KOR_Sub_brand__c != Trigger.newMap.get(barStylingPOSMHeader.Id).ASI_KOR_Sub_brand__c) {
                    posmHeaderListForAddingNewSysApprover.add(barStylingPOSMHeader);
                    posmHeaderListForRemovingOldSysApprover.add(Trigger.oldMap.get(barStylingPOSMHeader.Id));
                }

                break;
            }
        }

        if (!posmHeaderListForUpdatingBudgetActualSpendingAmount.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.sumActualSpendingAmountForBudget(posmHeaderListForUpdatingBudgetActualSpendingAmount);
        }

        if (!posmHeaderListForAddingNewSysApprover.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.grantRecordAccessToNewApprover(posmHeaderListForAddingNewSysApprover);
        }

        if (!posmHeaderListForRemovingOldSysApprover.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.removeRecordAccessFromOldApprover(posmHeaderListForRemovingOldSysApprover);
        }
    }
    //handle New Bar-Styling Item Request END

    //handle Locked Bar-Styling Item Request START
    if (!lockedBarStylingItemHeaderList.isEmpty()) {
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForUpdatingBudgetActualSpendingAmount = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForAddingNewSysApprover = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForRemovingOldSysApprover = new List<ASI_KOR_POSM_Order_Request__c>();

        for (ASI_KOR_POSM_Order_Request__c lockedBarStylingItemHeader : lockedBarStylingItemHeaderList) {
            if (Trigger.newMap.containsKey(lockedBarStylingItemHeader.Id)) {
                if (Trigger.newMap.get(lockedBarStylingItemHeader.Id).ASI_KOR_Actual_Spending_Amount__c != Trigger.oldMap.get(lockedBarStylingItemHeader.Id).ASI_KOR_Actual_Spending_Amount__c) {
                    posmHeaderListForUpdatingBudgetActualSpendingAmount.add(lockedBarStylingItemHeader);
                }

                if (Trigger.oldMap.get(lockedBarStylingItemHeader.Id).ASI_KOR_Sub_brand__c != Trigger.newMap.get(lockedBarStylingItemHeader.Id).ASI_KOR_Sub_brand__c) {
                    posmHeaderListForAddingNewSysApprover.add(lockedBarStylingItemHeader);
                    posmHeaderListForRemovingOldSysApprover.add(Trigger.oldMap.get(lockedBarStylingItemHeader.Id));
                }

                break;
            }
        }

        if (!posmHeaderListForUpdatingBudgetActualSpendingAmount.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.sumActualSpendingAmountForBudget(posmHeaderListForUpdatingBudgetActualSpendingAmount);
        }

        if (!posmHeaderListForAddingNewSysApprover.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.grantRecordAccessToNewApprover(posmHeaderListForAddingNewSysApprover);
        }

        if (!posmHeaderListForRemovingOldSysApprover.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.removeRecordAccessFromOldApprover(posmHeaderListForRemovingOldSysApprover);
        }
    }
    //handle Locked Bar-Styling Item Request END

}