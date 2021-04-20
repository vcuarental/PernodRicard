public with sharing class ASI_MFM_TW_CustomSettingController {  //ASI_MFM_TW_Budget_CustomSettingPage 
    public BudgetProxy setting {get; set;}
//    public WHTaxProxy WHTaxSetting {get; set;}
//    public TaxProxy TaxSetting {get; set;}
//    public POVATProxy POVATSetting {get; set;}
    
    public ASI_MFM_TW_CustomSettingController() {// Get the custom setting 
        setting = new BudgetProxy([SELECT Id, ASI_MFM_Fiscal_Year__c,ASI_MFM_Budget_Type__c  FROM ASI_MFM_Budget_Setting__c WHERE name = 'TW']);
//        WHTaxSetting = new WHTaxProxy([select Id,ASI_MFM_Value__c from ASI_MFM_Default_Value__c where name = 'TW_Default_W_H_Tax__c' AND ASI_MFM_Object__c = 'ASI_MFM_Tax_Code__c']);
//        TaxSetting = new TaxProxy([select  Id,ASI_MFM_Value__c from ASI_MFM_Default_Value__c where name='TW_Default_Tax_Type' and Country__c='TW']);
//        POVATSetting = new POVATProxy([select  Id,ASI_MFM_Value__c from ASI_MFM_Default_Value__c where name='TW_Default_VAT__c' and Country__c='TW']);
    }
    
    public PageReference save() { //Update the setting
        if (setting.Id != null) {
            update setting.getBudgetSetting();
        }
//        if (WHTaxSetting.Id != null) {
//            update WHTaxSetting.getWHTaxSetting();
//        }
//        if (TaxSetting .Id != null) {
//            update TaxSetting.getTaxSetting();
//        }
//        if (POVATSetting.Id != null) {
//           update POVATSetting.getPOVATSetting();
//        }
        PageReference pr = new PageReference(ApexPages.currentPage().getUrl());
        pr.setRedirect(true);
        return pr;
    }
 
    public class BudgetProxy {  //Budget Setting
        public Id Id {get;set;}
        public String Fiscal_Year {get;set;}
        public String Budget_Type {get;set;}
    
        public BudgetProxy(ASI_MFM_Budget_Setting__c sdp) {
            this.Id = sdp.Id;
            this.Fiscal_Year = sdp.ASI_MFM_Fiscal_Year__c;
            this.Budget_Type = sdp.ASI_MFM_Budget_Type__c;
        }
        
        public BudgetProxy() {}
        
        public ASI_MFM_Budget_Setting__c getBudgetSetting() {
            return new ASI_MFM_Budget_Setting__c(
                Id = this.Id,
                ASI_MFM_Fiscal_Year__c = this.Fiscal_Year,
                ASI_MFM_Budget_Type__c = this.Budget_Type
            );
        }
       /* 
        public void insertSetting() {
            ASI_MFM_Budget_Setting__c sdp = this.getBudgetSetting();
            insert sdp;
            this.Id = sdp.Id;
        }
        */
    }
    
//    public class WHTaxProxy { // Without holding Tax
//        public Id Id {get;set;}
//        public String Value {get;set;}
    
//        public WHTaxProxy(ASI_MFM_Default_Value__c sdp) {
//            this.Id = sdp.Id;
//            ASI_MFM_Tax_Code__c TaxCode = [select name from ASI_MFM_Tax_Code__c where id=:sdp.ASI_MFM_Value__c];
//            this.Value = Taxcode.Name;
//        }
        
//        public WHTaxProxy() {}
        
//        public ASI_MFM_Default_Value__c getWHTaxSetting() {
//            ASI_MFM_Tax_Code__c TaxCode = [select id from ASI_MFM_Tax_Code__c where name =:this.Value AND Recordtype.DeveloperName Like 'ASI_MFM_TW%'];
//            return new ASI_MFM_Default_Value__c(
//                Id = this.Id,
//                ASI_MFM_Value__c = TaxCode.id
//            );
//        }
        /*
        public void insertSetting() {
            ASI_MFM_Default_Value__c sdp = this.getWHTaxSetting();
            insert sdp;
            this.Id = sdp.Id;
        }
        */
//    }
    
//    public class TaxProxy { // Tax code setting
//        public Id Id {get;set;}
//        public String Value {get;set;}
//        public String Rate {get;set;}
    
//        public TaxProxy(ASI_MFM_Default_Value__c sdp) {
//            this.Id = sdp.Id;
//            this.Value = sdp.ASI_MFM_Value__c.substring(0,4);
//            this.Rate = sdp.ASI_MFM_Value__c.substring(6,7);
//        }
        
//        public TaxProxy() {}
        
//        public ASI_MFM_Default_Value__c getTaxSetting() {
//            return new ASI_MFM_Default_Value__c(
//                Id = this.Id,
//                ASI_MFM_Value__c = this.Value + ' (' + this.Rate + '%)'
//            );
//        }
        /*
        public void insertSetting() {
            ASI_MFM_Default_Value__c sdp = this.getTaxSetting();
            insert sdp;
            this.Id = sdp.Id;
        }
        */
//    }
    
//    public class POVATProxy {// VAT
//        public Id Id {get;set;}
//        public String Value {get;set;}
    
//        public POVATProxy(ASI_MFM_Default_Value__c sdp) {
//            this.Id = sdp.Id;
//            this.Value = sdp.ASI_MFM_Value__c;
//        }
        
//        public POVATProxy() {}
        
//        public ASI_MFM_Default_Value__c getPOVATSetting() {
//            return new ASI_MFM_Default_Value__c (
//                Id = this.Id,
//                ASI_MFM_Value__c = this.Value
//            );
//        }
        /*
        public void insertSetting() {
            ASI_MFM_Default_Value__c sdp = this.getPOVATSetting();
            insert sdp;
            this.Id = sdp.Id;
        }
        */
//    }
}