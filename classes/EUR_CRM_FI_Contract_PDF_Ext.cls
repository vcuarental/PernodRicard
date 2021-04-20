public without sharing class EUR_CRM_FI_Contract_PDF_Ext  {
    
    public EUR_CRM_Account__c euAccount {get;set;}
    private EUR_CRM_Contract__c  contractObj {get;set;} 
  
    //constructor
    public EUR_CRM_FI_Contract_PDF_Ext(ApexPages.StandardController standardController){
        //init 
        contractObj = (EUR_CRM_Contract__c )standardController.getRecord();
        euAccount = [select name,EUR_CRM_Business_Type__c, owner.name,ownerid, EUR_CRM_Invoice_Street__c,EUR_CRM_Invoice_Postal_Code__c, EUR_CRM_Invoice_City__c, EUR_CRM_Value_Added_Tax_ID_No__c from EUR_CRM_Account__c  where id =: contractObj.EUR_CRM_Account__c];
        //Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=mytest.pdf' );
    }
    
    public User getSRContact(){
        return [select name, email, phone from user where id =: euAccount.ownerid];
    }
    public Contact getAccountContact(){
        if( contractObj.EUR_CRM_Contact__c != null)
           return [select name, email, phone from contact where id =: contractObj.EUR_CRM_Contact__c];
        else
            return null;
    }
    
    public Boolean getHasSubOutlets(){
        if(euAccount.EUR_CRM_Business_Type__c != 'Head Office' || contractObj.recordtype.developername != 'EUR_FI_Chain_Contract')
           return false;
            
        List<EUR_CRM_Account__c> subOutlets = getSubOutlets();
        return subOutlets != null && subOutlets.size() > 0 ;
    }
    
    public List<EUR_CRM_Account__c> getSubOutlets(){
        return [select name from eur_crm_account__c where EUR_CRM_Parent_Account__c =: contractObj.eur_crm_account__c];
    
    }
    /*
    public class ContractWrapper{
        public String contactName {get;set;}
        public String contactTelephone {get;set;}
        public String contactEmail {get;set;}
        
        public ContractWrapper(){
        
        }
    }
    */
    public String getDraftDate(){
       return  system.today().format();
    }
}