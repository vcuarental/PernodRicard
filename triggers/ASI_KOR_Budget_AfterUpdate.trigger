/***************************************************************************************************************************
* Name:        ASI_KOR_Budget_AfterUpdate
* Description: After update trigger for ASI_KOR_Budget
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2019-01-04       Alan Lau                Created
****************************************************************************************************************************/

trigger ASI_KOR_Budget_AfterUpdate on ASI_KOR_Budget__c (after update) {

    List<ASI_KOR_Budget__c> barStylingBudgetList = new List<ASI_KOR_Budget__c>();

    for (ASI_KOR_Budget__c budget : Trigger.new) {
        if (Global_RecordTypeCache.getRt(budget.RecordTypeId).DeveloperName.contains('ASI_KOR_Bar_Styling')) {
            barStylingBudgetList.add(budget);
        }
    }

    if (!barStylingBudgetList.isEmpty()) {
        List<ASI_KOR_Budget__c> budgetListForUpdatingPOSMRemainingBudget = new List<ASI_KOR_Budget__c>();

        for (ASI_KOR_Budget__c budget : barStylingBudgetList) {
            if (Trigger.newMap.get(budget.Id).ASI_KOR_Actual_Spending_Amount__c != Trigger.oldMap.get(budget.Id).ASI_KOR_Actual_Spending_Amount__c
                    || Trigger.newMap.get(budget.Id).ASI_KOR_Budget_Amount__c != Trigger.oldMap.get(budget.Id).ASI_KOR_Budget_Amount__c) {
                budgetListForUpdatingPOSMRemainingBudget.add(budget);
            }
        }

        if (!budgetListForUpdatingPOSMRemainingBudget.isEmpty()) {
            ASI_KOR_Budget_TriggerClass.updateBarStylingPOSMRequestRemainingBudget(budgetListForUpdatingPOSMRemainingBudget);
        }
    }
}