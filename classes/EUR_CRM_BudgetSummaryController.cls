/*********************************************************************************
 * Name: EUR_CRM_BudgetSummaryController
 * Description: Cloned originally from EUR_CRM_DE_BudgetSummaryControllerExt, moving forward to cater multiple countries
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 9/22/2015		Conrad					Created
 *
*********************************************************************************/
public with sharing class EUR_CRM_BudgetSummaryController {
    private ApexPages.StandardController standardController{get;set;}
    private EUR_CRM_Budget__c budget{get;set;}
    public Boolean hasSubordinates {get;set;}
    
    public String currentFY{get{
        Date fiscalYearStart = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
        return (fiscalYearStart==null)?'':'FY'+ String.valueOf(fiscalYearStart.year()).substring(2);
    }}
    
    public EUR_CRM_BudgetSummaryController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.budget = (EUR_CRM_Budget__c)standardController.getRecord();
        hasSubordinates = checkRoleSubordinates(this.budget.OwnerId);
    }
    
    private Boolean checkRoleSubordinates(Id budgetOwnerId){
        Set<Id>subordinateUserIdSet = EUR_CRM_RoleUtils.getRoleSubordinateUsers(budgetOwnerId);
        return (subordinateUserIdSet!=null && subordinateUserIdSet.size()>0)?true:false;
    }
}