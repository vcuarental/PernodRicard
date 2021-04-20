/**
 * Created by osman on 6.01.2021.
 */

trigger EUR_TR_AccountProfitabilityTrigger on EUR_TR_AccountProfitability__c (before insert, before update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        EUR_TR_AccountProfitabilityTrigHandler.handleBeforeInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        EUR_TR_AccountProfitabilityTrigHandler.handleBeforeUpdate(Trigger.new);
    }

}