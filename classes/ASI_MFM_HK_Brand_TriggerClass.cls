public class ASI_MFM_HK_Brand_TriggerClass {

    public static void routineAfterUpdate(list<ASI_MFM_Brand__c> trigger_new, map<id, ASI_MFM_Brand__c> trigger_oldMap) {
        
        set<id> brand_set = new set<id>();
        for (ASI_MFM_Brand__c b:trigger_new) { 
            if (b.ASI_TH_CRM_Active__c == false) {
				brand_set.add(b.id);
            }
        }
        if(brand_set.size()>0){
         	list<ASI_MFM_Sub_brand__c> subBrandList = new list<ASI_MFM_Sub_brand__c>([select id, ASI_MFM_Inactive__c  from ASI_MFM_Sub_brand__c where ASI_MFM_Brand__c in :brand_set]); 
            list<ASI_MFM_Sub_brand__c> subBrandUpdatedList = new list<ASI_MFM_Sub_brand__c>();
            for(ASI_MFM_Sub_brand__c sb:subBrandList){
                sb.ASI_MFM_Inactive__c = true;
                subBrandUpdatedList.add(sb);
            }
            if(subBrandUpdatedList.size()>0){
                update subBrandUpdatedList;
            }
            
        }
        
    }
}