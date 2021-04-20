public class ASI_CRM_SG_CreditNoteItem_TriggerClass {
    public static void updateItemDetails(List<ASI_CRM_Credit_Debit_Note_Line_Item__c > newList){
        Set<String> creditNoteHeaderList = new Set<String>();
        Map<String, String> keyToLineItemMap = new Map<String,String>();
        for(ASI_CRM_Credit_Debit_Note_Line_Item__c lineItem : newList){
            creditNoteHeaderList.add(lineItem.ASI_CRM_Credit_Debit_Note__c);
            String key = lineItem.ASI_CRM_SG_Rebate_Type__c + '_'+ lineItem.ASI_CRM_Sub_brand__c;
            keyToLineItemMap.put(key,lineItem.Id);
        }
        List<ASI_CRM_SG_Credit_Note_Item_Detail__c> itemDetailsToUpdate = new List<ASI_CRM_SG_Credit_Note_Item_Detail__c>();
        for(ASI_CRM_SG_Credit_Note_Item_Detail__c itemDetail : [Select Id,ASI_CRM_SG_Credit_Debit_Note_Line_Item__c,ASI_CRM_SG_Rebate_Type__c,ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c from ASI_CRM_SG_Credit_Note_Item_Detail__c where ASI_CRM_SG_Credit_Debit_Note__c IN :creditNoteHeaderList]){
            String key = itemDetail.ASI_CRM_SG_Rebate_Type__c + '_' + itemDetail.ASI_CRM_SG_SKU__r.ASI_MFM_Sub_brand__c;
            if(keyToLineItemMap.containsKey(key)){
                itemDetail.ASI_CRM_SG_Credit_Debit_Note_Line_Item__c =keyToLineItemMap.get(key);
                itemDetailsToUpdate.add(itemDetail);
             } 
        }
        if(itemDetailsToUpdate != null && itemDetailsToUpdate.size()>0){
            update itemDetailsToUpdate;
        }
    }
}