public without sharing class ASI_MFM_KR_POReceiptItem_TriggerClass {
    public static void routineBeforeInsert(list<ASI_MFM_PO_Receipt_Item__c> trigger_new){
        set<id> POLineSet = new set<id>();
        //1st round loop get Id Set
        for (ASI_MFM_PO_Receipt_Item__c porl:trigger_new) {
            if(Global_RecordTypeCache.getRt(porl.recordTypeID).DeveloperName.contains('ASI_MFM_KR') && porl.ASI_MFM_PO_Line_Item__c!=null){
                POLineSet.add(porl.ASI_MFM_PO_Line_Item__c);
            }
        }
        
        Map<id,ASI_MFM_PO_Line_Item__c> POLineMap=new Map<id,ASI_MFM_PO_Line_Item__c>();
        if(POLineSet.size()>0){
            POLineMap =new Map<id,ASI_MFM_PO_Line_Item__c>([select id,ASI_MFM_PO__c,ASI_MFM_Plan_Line_Item__c from ASI_MFM_PO_Line_Item__c where id in : POLineSet]);
        }
        
        //2nd round loop update value
         for (ASI_MFM_PO_Receipt_Item__c porl:trigger_new) {
             if(POLineMap.size()>0 && porl.ASI_MFM_PO_Line_Item__c!=null){
                 if(POLineMap.containsKey(porl.ASI_MFM_PO_Line_Item__c)){
                     porl.ASI_MFM_PO__c=POLineMap.get(porl.ASI_MFM_PO_Line_Item__c).ASI_MFM_PO__c;
                     //UPDATE Plan field in PO reciept
                     if(POLineMap.get(porl.ASI_MFM_PO_Line_Item__c).ASI_MFM_Plan_Line_Item__c!=null)porl.ASI_MFM_Plan_Line_Item__c=POLineMap.get(porl.ASI_MFM_PO_Line_Item__c).ASI_MFM_Plan_Line_Item__c;  
                 }
             }
             
         }
    }
    
    
       
    
    public static void routineBeforeDelete(list<ASI_MFM_PO_Receipt_Item__c> trigger_old) {
        if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_KR_POReceiptItem_TriggerClass','KR')){
            
            Set<id> setIdPOR = new Set<id>();
            Map<id, ASI_MFM_Payment_Line_Item__c> mapPL = new Map<id, ASI_MFM_Payment_Line_Item__c>();
            Map<id, ASI_MFM_PO_Line_Item__c> mapPOL = new Map<id, ASI_MFM_PO_Line_Item__c>();
            Map<id, id> mapPORPOL = new Map<id, id>();
            
            for(ASI_MFM_PO_Receipt_Item__c p:trigger_old){
                setIdPOR.add(p.id);
                mapPORPOL.put(p.id, p.ASI_MFM_PO_Line_Item__c);
            }       
            for(ASI_MFM_Payment_Line_Item__c pa: [Select id, name, ASI_MFM_Payment_Status__c, ASI_MFM_PO_Receipt_Item__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Receipt_Item__c IN :setIdPOR]){
                mapPL.put(pa.ASI_MFM_PO_Receipt_Item__c, pa);
            }
            
            for(ASI_MFM_PO_Line_Item__c pol: [Select id, ASI_MFM_PO_Status__c, ASI_MFM_PO__r.name from ASI_MFM_PO_Line_Item__c where id IN: mapPORPOL.values()]){
                mapPOL.put(pol.id, pol);
            }
            
            for(ASI_MFM_PO_Receipt_Item__c p: trigger_old){
                // if there is Payment created, PO receipt can't be deleted
                if(mapPL.get(p.id) != null){
                    p.addError('Not allowed to delete because Payment is created');
                }
                
                // if PO status is 'Submitted', 'Approved' or 'Final', PO receipt can't be deleted
                if(!Test.isRunningTest() && (mapPOL.get(mapPORPOL.get(p.id)).ASI_MFM_PO_Status__c == 'Submitted' || mapPOL.get(mapPORPOL.get(p.id)).ASI_MFM_PO_Status__c == 'Final' || mapPOL.get(mapPORPOL.get(p.id)).ASI_MFM_PO_Status__c == 'Approved')){
                    p.addError('Not allowed to delete because PO ' + mapPOL.get(mapPORPOL.get(p.id)).ASI_MFM_PO__r.name + ' is \'Submitted\', \'Approved\' or \'Final\'');
                }
            }        
            
        }// End Delete checking
        
        
    }// routineBeforerDelete
    
    
}