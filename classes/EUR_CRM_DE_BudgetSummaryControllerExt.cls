public class EUR_CRM_DE_BudgetSummaryControllerExt{
    private ApexPages.StandardController standardController{get;set;}
    private EUR_CRM_Budget__c budget{get;set;}
    public Boolean hasSubordinates {get;set;}
    public Boolean isAdmin {get;set;}

    
    public String currentFY{get{
        Date fiscalYearStart = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
        return (fiscalYearStart==null)?'':'FY'+ String.valueOf(fiscalYearStart.year()).substring(2);
    }}
    
    public EUR_CRM_DE_BudgetSummaryControllerExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.budget = (EUR_CRM_Budget__c)standardController.getRecord();
        hasSubordinates = checkRoleSubordinates(this.budget.OwnerId);
        String uProfile = [select name from Profile where id=:UserInfo.getProfileID()][0].name;
        isAdmin = uProfile == 'System Administrator' || uProfile == 'EUR System Admin' || uProfile == 'EUR DE/AT IT Admin User';
    }
    
    private Boolean checkRoleSubordinates(Id budgetOwnerId){
        Set<Id>subordinateUserIdSet = EUR_CRM_RoleUtils.getRoleSubordinateUsers(budgetOwnerId);
        return (subordinateUserIdSet!=null && subordinateUserIdSet.size()>0)?true:false;
    }
}