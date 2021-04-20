public without sharing class EUR_CRM_BudgetUtil{
    private static Organization fiscalYearOrgDetails {get;set;}
    
    public static Organization retrieveFiscalYearOrg(){
        Organization  org = new Organization() ;  
        org = [select FiscalYearStartMonth, UsesStartDateAsFiscalYearName from Organization where id=:Userinfo.getOrganizationId()];
        
        fiscalYearOrgDetails = org;
        return org;
    }

    public static Date retrieveFiscalYearStart(){
        Organization  org = fiscalYearOrgDetails; 
        if(fiscalYearOrgDetails == null){
            org = retrieveFiscalYearOrg();
        }
        
        Date currentDate = Date.today();
        Integer fiscalYear = currentDate.year();

        if(! org.UsesStartDateAsFiscalYearName && currentDate.month()>=org.FiscalYearStartMonth){
            fiscalYear = currentDate.year()+1;
        }
        
        return Date.newinstance(fiscalYear, org.FiscalYearStartMonth, 1);   
    }
    
    public static Boolean isFYCurrentYear(){
        Organization  org = fiscalYearOrgDetails; 
        if(fiscalYearOrgDetails == null){
            org = retrieveFiscalYearOrg();
        }
        return org.UsesStartDateAsFiscalYearName;
    }
}