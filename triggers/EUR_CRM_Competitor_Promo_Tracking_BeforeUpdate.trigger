trigger EUR_CRM_Competitor_Promo_Tracking_BeforeUpdate on EUR_CRM_Competitor_Promo_Tracking__c (before update) {

    List<EUR_CRM_TriggerAbstract> triggerClasses = new List<EUR_CRM_TriggerAbstract> { 
      new  EUR_CRM_CompetitorPromoActiveHandler('EUR_CRM_Competitor_Promo_Tracking__c')
    };
    
    for (EUR_CRM_TriggerAbstract triggerClass : triggerClasses) {
        triggerClass.executeTriggerAction(EUR_CRM_TriggerAbstract.TriggerAction.AFTER_UPDATE, trigger.new, trigger.newMap, trigger.oldMap);
    }
}