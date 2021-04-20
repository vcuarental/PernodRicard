public class ASI_MFM_GF_POReceiptEmailController {
    public Id receiptID {get;set;}
    public ASI_MFM_PO_Receipt__c getReceipt()
    {
        ASI_MFM_PO_Receipt__c rec = [select Name, ASI_MFM_Receipt_Date__c from ASI_MFM_PO_Receipt__c where id = :receiptID LIMIT 1];
        return rec;
    }
    
    public List<ASI_MFM_PO_Receipt_Item__c> getrecList()
    {
        List<ASI_MFM_PO_Receipt_Item__c> itemList;

        itemList = [SELECT ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Supplier_Name__r.Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_Amount__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_List_Item_Description__c FROM ASI_MFM_PO_Receipt_Item__c WHERE ASI_MFM_PO_Receipt__c = :receiptID AND ASI_MFM_PO__r.ASI_MFM_PO_Type__c = 'VAP Brand Owner'];
        return itemList;
    }
}