public with sharing class ASI_MFM_SG_CustomSettingController {
    public interimData Items {get; set;}
    
    public ASI_MFM_SG_CustomSettingController() {
        init();
        
    }
    
    public void init() {
        Items = new interimData([SELECT Id,ASI_MFM_SG_Payment_Line_Tolerance__c  FROM ASI_MFM_Setting__c]);
    }
    
    public PageReference save() { //Update the setting
        if (Items.Id != null) {
            update Items.getData();
        }
        
        PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference refresh() {
        init();
        return null;
    }
    
    
    public class interimData { 
        public Id Id {get;set;}
        public Decimal Tolerance {get;set;}
        
        public interimData(ASI_MFM_Setting__c InputData) {
            this.Id = InputData.Id;
            this.Tolerance = InputData.ASI_MFM_SG_Payment_Line_Tolerance__c;
        }
        
        public ASI_MFM_Setting__c getData() {
            return new ASI_MFM_Setting__c(
                Id = this.Id,
                ASI_MFM_SG_Payment_Line_Tolerance__c = this.Tolerance              
            );
        }
    }
    
    
    
    
}