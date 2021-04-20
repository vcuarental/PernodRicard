public class ASI_MFM_HK_Item_Group_TriggerClass {

    public static void routineAfterUpdate(list<ASI_MFM_Item_Group__c> trigger_new, map<id, ASI_MFM_Item_Group__c> trigger_oldMap) {
        
        set<id> itemGroup_set = new set<id>();
        for (ASI_MFM_Item_Group__c ig:trigger_new) { 
            if (ig.ASI_CRM_Active__c == false) {
				itemGroup_set.add(ig.id);
            }
        }
        if(itemGroup_set.size()>0){
         	list<ASI_MFM_SKU_Code__c> skuList = new list<ASI_MFM_SKU_Code__c>([select id, ASI_HK_CRM_Active__c from ASI_MFM_SKU_Code__c where ASI_MFM_Item_Group__c in :itemGroup_set]); 
            list<ASI_MFM_SKU_Code__c> skuUpdatedList = new list<ASI_MFM_SKU_Code__c>();
            for(ASI_MFM_SKU_Code__c sku:skuList){
                sku.ASI_HK_CRM_Active__c = false;
                skuUpdatedList.add(sku);
            }
            if(skuUpdatedList.size()>0){
                update skuUpdatedList;
            }
            
        }
        
    }
}