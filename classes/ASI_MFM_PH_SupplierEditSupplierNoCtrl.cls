public without sharing class ASI_MFM_PH_SupplierEditSupplierNoCtrl {

    public Account currentAccount {set;get;}
    private ApexPages.StandardController controller;
    public String supplierNumber {set; get;}
    public boolean refreshPage      {set;get;}

    public  ASI_MFM_PH_SupplierEditSupplierNoCtrl(ApexPages.StandardController stdController) {
        this.currentAccount = (Account) stdController.getRecord();
        this.controller = stdController;
        if(this.currentAccount!=null){
            this.currentAccount = [Select id ,ASI_TH_CRM_Supplier__c from Account where id =: this.currentAccount.Id ];
            this.supplierNumber = this.currentAccount.ASI_TH_CRM_Supplier__c== null?'(BLANK)':  this.currentAccount.ASI_TH_CRM_Supplier__c;
            refreshPage = false;
        }
     
    }
    
    public PageReference cancel() {
        PageReference rs = this.controller.cancel();
        return null; 
    }
    
    public PageReference customsave() {
        
        //supplierNumber = 'test1234';
        if(supplierNumber == null || (supplierNumber!=null && supplierNumber!='(BLANK)'))
        this.currentAccount.ASI_TH_CRM_Supplier__c = supplierNumber; 
        try{
            update this.currentAccount;
        }catch (exception ex){
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());               //ApexPages.addMessage(myMsg);

        }
        
        refreshPage = true;
        
        PageReference rs = this.controller.save();

        return null;
    }
    


}