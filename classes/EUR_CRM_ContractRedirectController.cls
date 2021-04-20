public with sharing class EUR_CRM_ContractRedirectController {
    private ApexPages.StandardController standardController {get;set;}
    
    private final static String UK_COUNTRY_CODE = 'UK';
    private final static String DE_COUNTRY_CODE = 'DE';
    private final static String DK_COUNTRY_CODE = 'DK';
    
    private final static String UK_PAGE = 'EUR_CRM_ContractSummaryPage';
    private final static String DE_PAGE = 'EUR_CRM_DE_ContractSummaryPage';
    private final static String DK_PAGE = 'EUR_CRM_DK_ContractSummaryPage';
    
   
    
    private EUR_CRM_Contract__c contractObj {get;set;}
    
    public EUR_CRM_ContractRedirectController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        contractObj = [SELECT Id, EUR_CRM_Country_Code__c 
                                            FROM EUR_CRM_Contract__c
                                            WHERE Id=:this.standardController.getId()];
    }
    
    public PageReference redirectPage(){
        PageReference pageref = null;
        if (contractObj!=null){
                if (contractObj.EUR_CRM_Country_Code__c.equalsIgnoreCase(UK_COUNTRY_CODE)){
                        pageRef = new PageReference('/'+UK_PAGE+'?id='+contractObj.Id);
                }
                else if (contractObj.EUR_CRM_Country_Code__c.equalsIgnoreCase(DE_COUNTRY_CODE)){
                        pageRef = new PageReference('/'+DE_PAGE+'?id='+contractObj.Id);
                }
                else if (contractObj.EUR_CRM_Country_Code__c.equalsIgnoreCase(DK_COUNTRY_CODE)){
                        pageRef = new PageReference('/'+DK_PAGE+'?id='+contractObj.Id);
                }
                if (pageRef!=null){
                        return pageRef.setRedirect(true);       
                }
        }
        return pageRef;
    }
}