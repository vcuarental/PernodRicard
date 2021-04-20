public with sharing class ASI_MFM_KR_POSMProductAssignAutoNumber extends ASI_HK_CRM_TriggerAbstract {
    

    public ASI_MFM_KR_POSMProductAssignAutoNumber() {
        
        super('ASI_MFM_KR_POSMProductAssignAutoNumber');
   
    }

    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT)
            && !isBypassByCurrentUser()) {
    			List<ASI_KOR_POSM_Product__c> POSMPrductList = (List<ASI_KOR_POSM_Product__c>)sObjList;
    			ASI_HK_CRM_AutoNumberAssignment autoNumAssign = new ASI_HK_CRM_AutoNumberAssignment('ASI_KOR_POSM_Product__c');
    			for (ASI_KOR_POSM_Product__c product : POSMPrductList ) {
    			    if( Global_RecordTypeCache.getRt(product.RecordTypeId).developerName.startsWith('ASI_KOR_POSM_Product') && product.ASI_MFM_Item_Category__c =='Brand MKT'){
    			       product.ASI_KOR_Item_Code__c  = autoNumAssign.nextAutoNumStr();
    			    }
    			}
    			autoNumAssign.writeToDB();                
                    
            
            }
            
    }
}