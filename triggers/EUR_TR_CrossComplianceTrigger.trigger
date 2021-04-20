/**
 * Created by osman on 6.01.2021.
 */

trigger EUR_TR_CrossComplianceTrigger on EUR_TR_CrossCompliance__c (before insert, before update) {


    if (Trigger.isBefore && Trigger.isInsert) {
        EUR_TR_CrossComplianceTriggerHandler.handleBeforeInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        EUR_TR_CrossComplianceTriggerHandler.handleBeforeUpdate(Trigger.new);
    }

}