public with sharing class ASI_MFM_GF_Payment_PDF_PageController {
    public id paymentID {set;get;}
    public ASI_MFM_Payment__c paymentCurrent{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> paymentLineList{get;set;}
    
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public ASI_MFM_GF_Payment_PDF_PageController(){
      
    }
    
     public boolean init(){
        paymentCurrent = [select Name, Owner.Name, ASI_MFM_Payment_Date__c, ASI_MFM_Currency__c, ASI_MFM_Remarks__c, ASI_MFM_One_Off_Payee__c, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c, ASI_MFM_GF_Payment_Amount_Include_VAT__c from ASI_MFM_Payment__c where id = :paymentID];
        System.debug('Payment ID: ' + paymentID + ' Payment SOQL: ' + paymentCurrent);
        
        paymentLineList =[
            select ASI_MFM_Payee__r.Name, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c,
                ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Sub_brand_Code__c, 
                    ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_Payment_Amount__c, ASI_MFM_GF_Payment_Amount_Include_VAT__c 
            from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentID order by Name];
        
        return true;        
    }
}