/**
 * Created by osman on 27.01.2021.
 */

trigger EUR_TR_IncentiveTrigger on EUR_TR_Incentive__c (after insert, after update ) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            EUR_TR_IncentiveTriggerHandler.handleAfterInsert(Trigger.newMap);
        }
        if (Trigger.isUpdate) {
            EUR_TR_IncentiveTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }


}