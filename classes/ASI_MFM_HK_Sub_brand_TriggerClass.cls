public class ASI_MFM_HK_Sub_brand_TriggerClass {

    public static void routineAfterUpdate(list<ASI_MFM_Sub_brand__c> trigger_new, map<id, ASI_MFM_Sub_brand__c> trigger_oldMap) {
        
        set<id> subbrand_set = new set<id>();
        for (ASI_MFM_Sub_brand__c sb:trigger_new) { 
            if (sb.ASI_MFM_Inactive__c == true) {
				subbrand_set.add(sb.id);
            }
        }
        if(subbrand_set.size()>0){
         	list<ASI_MFM_SKU_Code__c> skuList = new list<ASI_MFM_SKU_Code__c>([select id, ASI_HK_CRM_Active__c from ASI_MFM_SKU_Code__c where ASI_MFM_Sub_brand__c in :subbrand_set]); 
            list<ASI_MFM_SKU_Code__c> skuUpdatedList = new list<ASI_MFM_SKU_Code__c>();
            for(ASI_MFM_SKU_Code__c sku:skuList){
                sku.ASI_HK_CRM_Active__c = false;
                skuUpdatedList.add(sku);
            }
            if(skuUpdatedList.size()>0){
                update skuUpdatedList;
            }
            
            
            list<ASI_MFM_Item_Group__c> itemGroupList = new list<ASI_MFM_Item_Group__c>([select id, ASI_CRM_Active__c from ASI_MFM_Item_Group__c where ASI_MFM_Sub_brand__c in :subbrand_set]);
            list<ASI_MFM_Item_Group__c> itemGroupUpdatedList = new list<ASI_MFM_Item_Group__c>();
            for(ASI_MFM_Item_Group__c ig: itemGroupList){
                ig.ASI_CRM_Active__c = false;
                itemGroupUpdatedList.add(ig);
            }
            if(itemGroupUpdatedList.size()>0){
                update itemGroupUpdatedList;
            }
            
            
        }
        
    }
}