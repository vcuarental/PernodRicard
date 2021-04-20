/***************************************************************************************************************************
* Name:        ASI_KOR_POSM_Order_Request_BeforeUpdate
* Description: Before update trigger for ASI_KOR_POSM_Order_Request
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* ??               ??                      Created
* 2018-11-27       Alan Lau                Created in B7
* 2018-12-21       Alan Lau                Replaced nested loop with Trigger.newMap
* 2019-06-03        Wilson Chow             Comment part that will call validateActualSpendingAmount()
****************************************************************************************************************************/

trigger ASI_KOR_POSM_Order_Request_BeforeUpdate on ASI_KOR_POSM_Order_Request__c(before update) {
    
    if (trigger.new[0].recordTypeId!=NULL &&  Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_KOR')
        && !Global_RecordTypeCache.getRt(trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_KOR_Bar_Styling_POSM_Request')
        && !Global_RecordTypeCache.getRt(trigger.new[0].RecordTypeId).DeveloperName.contains('ASI_KOR_Locked_Bar_Styling_Item_Request')
    ){
        ASI_KOR_POSM_Order_Request_TriggerClass.BeforeUpsertMethod(Trigger.New, trigger.oldMap); 
        ASI_KOR_POSM_Order_Request_TriggerClass.BeforeUpdateMethod(Trigger.New, trigger.oldMap); 
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
    //group record by RecordType END

    //handle New Bar-Styling Item Request START
    if (!barStylingPOSMHeaderList.isEmpty()) {
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForValidatingActualSpendingAmount = new List<ASI_KOR_POSM_Order_Request__c>();
        List<ASI_KOR_POSM_Order_Request__c> posmHeaderListForUpdatingSysApprover = new List<ASI_KOR_POSM_Order_Request__c>();

        ASI_KOR_POSM_Order_Request_TriggerClass.setDefaultContractPeriod(barStylingPOSMHeaderList);

        for (ASI_KOR_POSM_Order_Request__c barStylingPOSMHeader : barStylingPOSMHeaderList) {
            if (Trigger.newMap.containsKey(barStylingPOSMHeader.Id)) {
                /*
                if (Trigger.oldMap.get(barStylingPOSMHeader.Id).ASI_KOR_Actual_Spending_Amount__c != Trigger.newMap.get(barStylingPOSMHeader.Id).ASI_KOR_Actual_Spending_Amount__c) {
                    posmHeaderListForValidatingActualSpendingAmount.add(barStylingPOSMHeader);
                }
                */

                if (Trigger.oldMap.get(barStylingPOSMHeader.Id).ASI_KOR_Sub_brand__c != Trigger.newMap.get(barStylingPOSMHeader.Id).ASI_KOR_Sub_brand__c) {
                    posmHeaderListForUpdatingSysApprover.add(barStylingPOSMHeader);
                }

                break;
            }
        }

        /*
        if (!posmHeaderListForValidatingActualSpendingAmount.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.validateActualSpendingAmount(posmHeaderListForValidatingActualSpendingAmount);
        }
        */

        if (!posmHeaderListForUpdatingSysApprover.isEmpty()) {
            ASI_KOR_POSM_Order_Request_TriggerClass.setSysApprover(posmHeaderListForUpdatingSysApprover);
        }
    }
    //handle New Bar-Styling Item Request END

    //handle Locked Bar-Styling Item Request START
    /*
    if (!lockedBarStylingItemHeaderList.isEmpty()) {
        ASI_KOR_POSM_Order_Request_TriggerClass.validateActualSpendingAmount(lockedBarStylingItemHeaderList);
    }
    */
    //handle Locked Bar-Styling Item Request END

}