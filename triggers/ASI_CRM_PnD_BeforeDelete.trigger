trigger ASI_CRM_PnD_BeforeDelete on ASI_CRM_Price_And_Discount__c (before delete) {
    //2020-12-03 Wilken Lee - Add validation to block deletion of rebate setup
if (Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Bottle_Rebate') ||
    Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Budget_Net_Price') ||
    Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_First_Week_Order_Rebate') ||
    Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Master_Price_Group') ||
    Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Open_Outlet_Marketing_Fund') ||
    Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Portfolio_Rebate') ||
    Global_RecordTypeCache.getRt(trigger.old[0].recordtypeid).DeveloperName.contains('ASI_CRM_SG_Rebate_Period')){
        ASI_CRM_SG_PnD_TriggerClass.validateRebateDelete(trigger.old);
    }
}