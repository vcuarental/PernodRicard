public with sharing class ASI_MFM_POLineItem {

    public static asi_mfm_po_line_item__c setAmount(asi_mfm_po_line_item__c pi) {
// If item amount is null, set item amount to item quantity x item unit price           
        if (pi.ASI_MFM_Amount__c == null && pi.ASI_MFM_Quantity__c != null && pi.ASI_MFM_Unit_Price__c != null) {
            pi.ASI_MFM_Amount__c = (pi.ASI_MFM_Quantity__c * pi.ASI_MFM_Unit_Price__c).setScale(0, roundingmode.half_up);
        }
            
// If item amount is null, set item amount to PO original amount x item percentage
        if (pi.ASI_MFM_Amount__c == null && pi.ASI_MFM_PO_Original_Amount__c != null && pi.ASI_MFM_PO_Percentage__c != null) {
            pi.ASI_MFM_Amount__c = (pi.ASI_MFM_PO_Original_Amount__c * pi.ASI_MFM_PO_Percentage__c / 100).setScale(2);
        }           
        return pi;      
    }
    
    
}