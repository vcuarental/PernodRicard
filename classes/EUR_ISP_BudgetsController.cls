/**
 * Apex Controller for Budget component of iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_BudgetsController
{
	@AuraEnabled
	public static EUR_CRM_Budget__c getCurrentBudget()
	{
		EUR_CRM_Budget__c budget = EUR_ISP_BudgetService.getCurrentBudget();
		return budget != null ? budget : new EUR_CRM_Budget__c();
	}
}