public class ASI_NPP_NewPromotion_TriggerClass {

  public static void setNewProductPromotionFinalStatus(List<ASI_NPP_New_Promotion__c> trigger_new, Map<id,ASI_NPP_New_Promotion__c> oldMap) {
    Set<ID> npIDSet = new Set<ID>();
    List<ASI_NPP_New_Product_Promotion__c> nppUpdate = new List<ASI_NPP_New_Product_Promotion__c>();
    
        for(ASI_NPP_New_Promotion__c np : trigger_new) {
            if (oldMap != null && np.ASI_NPP_Status__c == 'Final' && oldMap.get(np.id).ASI_NPP_Status__c == 'Submitted')
                npIDSet.add(np.id);
        }
        
        if (npIDSet.size() > 0){
            List<ASI_NPP_New_Product_Promotion__c> nppList = [select ASI_NPP_Status__c from ASI_NPP_New_Product_Promotion__c where ASI_NPP_New_Promotion__c in :npIDSet];
            
            for (ASI_NPP_New_Product_Promotion__c npp:nppList){
                npp.ASI_NPP_Status__c = 'Final';
            }
            
            update nppList;
        }    
    }
}