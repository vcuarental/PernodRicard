public with sharing class ASI_MFM_TW_CashFormP2_Ctrl{
    public String paid{set;get;}
    
    public ASI_MFM_TW_CashFormP2_Ctrl() {
        paid = ApexPages.CurrentPage().getParameters().get('paid');
    }
    
    public PageReference ViewPayment() {        
        return new PageReference('/' + this.paid); 
    }
}