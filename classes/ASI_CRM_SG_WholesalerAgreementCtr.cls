public with sharing class ASI_CRM_SG_WholesalerAgreementCtr {
    public String today { get; set; }
    public String currentDay { get; set; }
    public String currentP60Days { get; set; }
    public String customDate { get; set; }
    public String customMonth { get; set; }
    public String money1 { get; set; }
    public String money2 { get; set; }
    public String money3 { get; set; }
    public String money4 { get; set; }
    public String money5 { get; set; }
    public String Name { get; set; }
    public String registrationNo { get; set; }
    public String wholesalerType { get; set; }
    public String paymentTerms { get; set; } {paymentTerms = '';}
    public ASI_CRM_AccountsAdditionalField__c CustomerInfo { get; set; } {CustomerInfo =  new ASI_CRM_AccountsAdditionalField__c();}
    public String TnC_Chx9 { get; set; } {TnC_Chx9 = 'true';}
    
    public ASI_CRM_SG_WholesalerAgreementCtr(ApexPages.StandardController con) {
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename=test123.pdf');
    }
    
    public ASI_CRM_SG_WholesalerAgreementCtr() {
        
        if(ApexPages.currentPage().getParameters().get('Today') != null) {
            today = ApexPages.currentPage().getParameters().get('Today');
        }
        if(ApexPages.currentPage().getParameters().get('currentDay') != null) {
            currentDay = ApexPages.currentPage().getParameters().get('currentDay');
        }
        if(ApexPages.currentPage().getParameters().get('currentP60Days') != null) {
            currentP60Days = ApexPages.currentPage().getParameters().get('currentP60Days');
        }
        if(ApexPages.currentPage().getParameters().get('customDate') != null) {
            customDate = ApexPages.currentPage().getParameters().get('customDate');
        }
        if(ApexPages.currentPage().getParameters().get('customMonth') != null) {
            customMonth = ApexPages.currentPage().getParameters().get('customMonth');
        }
        if(ApexPages.currentPage().getParameters().get('money1') != null) {
            money1 = ApexPages.currentPage().getParameters().get('money1');
        }
        if(ApexPages.currentPage().getParameters().get('money2') != null) {
            money2 = ApexPages.currentPage().getParameters().get('money2');
        }
        if(ApexPages.currentPage().getParameters().get('money3') != null) {
            money3 = ApexPages.currentPage().getParameters().get('money3');
        }
        if(ApexPages.currentPage().getParameters().get('money4') != null) {
            money4 = ApexPages.currentPage().getParameters().get('money4');
        }
        
        if(ApexPages.currentPage().getParameters().get('money5') != null) {
            money5 = ApexPages.currentPage().getParameters().get('money5');
        }
        
        
        if(ApexPages.currentPage().getParameters().get('TnC_Chx9') != null) {
            TnC_Chx9 = ApexPages.currentPage().getParameters().get('TnC_Chx9');
        }
        String recordId = '';
        if(ApexPages.currentPage().getParameters().get('recordId') != null) {
            recordId = ApexPages.currentPage().getParameters().get('recordId');
        }
        if(recordId != ''){
            
            CustomerInfo = [Select Id, Name, ASI_CRM_SG_Credit_Limit__c,ASI_CRM_Business_Registration_Number__c,ASI_CRM_Wholesaler_Type__c,ASI_CRM_SG_Payment_Terms_A_R__c
                        from ASI_CRM_AccountsAdditionalField__c where id =: recordId];
            List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            customerList = [Select Id, Name, ASI_CRM_Business_Registration_Number__c from ASI_CRM_AccountsAdditionalField__c
                            where ASI_CRM_CN_Parent_Outlet__r.Name =: CustomerInfo.Name and recordType.DeveloperName = 'ASI_CRM_SG_Outlet' limit 1]; 
            
            registrationNo = '';
            if(customerList != null && customerList.size() > 0){
                registrationNo = customerList[0].ASI_CRM_Business_Registration_Number__c;
            }
            paymentTerms = CustomerInfo.ASI_CRM_SG_Payment_Terms_A_R__c !=null?CustomerInfo.ASI_CRM_SG_Payment_Terms_A_R__c:'0';
             
            
            Name = CustomerInfo.Name;
            wholesalerType = CustomerInfo.ASI_CRM_Wholesaler_Type__c;
            
        }
        
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+Name+' Wholesaler Agreement.pdf');
    }
    
    @AuraEnabled(cacheable=false)
    public static customerWithRN getCustomerInfo(String recordId) {
        customerWithRN custWithRN = new customerWithRN();
        List<ASI_CRM_AccountsAdditionalField__c> customerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c currentCustomer = new ASI_CRM_AccountsAdditionalField__c();
        currentCustomer = [Select Id, Name,ASI_CRM_SG_Credit_Limit__c, ASI_CRM_Business_Registration_Number__c,ASI_CRM_Wholesaler_Type__c,ASI_CRM_SG_Payment_Terms_A_R__c
                           from ASI_CRM_AccountsAdditionalField__c where id =: recordId];
        
        customerList = [Select Id, Name, ASI_CRM_Business_Registration_Number__c from ASI_CRM_AccountsAdditionalField__c
                        where ASI_CRM_CN_Parent_Outlet__r.Name =: currentCustomer.Name and recordType.DeveloperName = 'ASI_CRM_SG_Outlet' limit 1]; 
        
        if(customerList != null && customerList.size() > 0){
            custWithRN.registrationNo = customerList[0].ASI_CRM_Business_Registration_Number__c;
        }
        custWithRN.PaymentTerms = currentCustomer.ASI_CRM_SG_Payment_Terms_A_R__c!=null?currentCustomer.ASI_CRM_SG_Payment_Terms_A_R__c : '0';
        custWithRN.Name = currentCustomer.Name;
        custWithRN.CreditLimit = string.valueOf(currentCustomer.ASI_CRM_SG_Credit_Limit__c);
        custWithRN.wholeSalerType = currentCustomer.ASI_CRM_Wholesaler_Type__c;
        return custWithRN;
    }
    
    public class customerWithRN {
        @AuraEnabled
        public String registrationNo {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String wholeSalerType {get;set;}
        @AuraEnabled
        public String PaymentTerms  {get;set;}
         @AuraEnabled
        public String CreditLimit  {get;set;}
        
        
        public customerWithRN() {
            this.registrationNo = '';
            this.Name = '';
            this.wholeSalerType = '';
            this.PaymentTerms = '';
            this.CreditLimit = '';
        }
    }
}