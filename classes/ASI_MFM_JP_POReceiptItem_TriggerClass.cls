/* Filename:    ASI_MFM_JP_POReceiptItem_TriggerClass.cls
* Author:      Elufa Systems 
* Purpose:     PO Receipt Item Trigger Class
* History
* -----------------------------------------------------------------------------
*/

public without sharing class ASI_MFM_JP_POReceiptItem_TriggerClass {
    
    
    
    public static void routineBeforeDelete(list<ASI_MFM_PO_Receipt_Item__c> trigger_old) {
        set<id> PorIdSet = NEW set<id> ();
            for (ASI_MFM_PO_Receipt_Item__c pori : trigger_old){
                PorIdSet.add(pori.ID);
            }
        
        
        if(!ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_JP_POReceiptItem_TriggerClass','JP')){
            
            List<ASI_MFM_Payment_Line_Item__c> paylist= [select id,ASI_MFM_PO_Receipt_Item__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Receipt_Item__c in : PorIdSet];
            Map<id,List<ASI_MFM_Payment_Line_Item__c>> paylinemap= new Map<id,List<ASI_MFM_Payment_Line_Item__c>> ();
            for(ASI_MFM_Payment_Line_Item__c pa: paylist){
                if(!paylinemap.containsKey(pa.ASI_MFM_PO_Receipt_Item__c)){
                    List<ASI_MFM_Payment_Line_Item__c> templist= new List<ASI_MFM_Payment_Line_Item__c>();
                    templist.add(pa);
                    paylinemap.put(pa.ASI_MFM_PO_Receipt_Item__c, templist);
                }else{
                    paylinemap.get(pa.ASI_MFM_PO_Receipt_Item__c).add(pa);
                }
            }
            
            for (ASI_MFM_PO_Receipt_Item__c pori : trigger_old){
                if(paylinemap.containsKey(pori.id) && !test.isRunningTest() ){
                    pori.addError('Not allowed to delete because the Payment created');
                }
            }
            
        }// End Delete checking
        
        
    }// routineBeforerDelete
    
}