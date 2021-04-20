/* Filename:    ASI_MFM_CN_POReceiptItem_TriggerClass.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     PO Receipt Item Trigger Class
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2012-12-20   michael.yip@introv.com      Created
 * 2014-09-15   michael.yip@introv.com      Reduce SOQL
 * 2014-12-12   Axel.Leung@introv.com       #122
 * 2015-01-07   leo.hui@introv.com          #119 - not allow delete if ETL = true
 */

public with sharing class ASI_MFM_CN_POReceiptItem_TriggerClass {
    public static void routineBeforeInsert(list<ASI_MFM_PO_Receipt_Item__c> trigger_new, map<id, ASI_MFM_PO_Receipt_Item__c> trigger_oldMap) {
        // Edited by Michael Yip (Introv) 16Sep2014 to reduce SOQL
        //Map<string, id> MRecTypeID = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Receipt_Item__c');
        Map<string, id> MRecTypeID = new Map<string, id>();
        for(RecordType rt : Global_RecordTypeCache.getRtList('ASI_MFM_PO_Receipt_Item__c')){
            MRecTypeID.put(rt.DeveloperName, rt.id);
        }
        
        Set<id> SCNRecTypeID = new Set<id>();
        for(String key : MRecTypeID.keySet()){
            if(key.contains('CN_PO_Receipt')){
                SCNRecTypeID.add(MRecTypeID.get(key));
            }
        }
        Set<id> SPORecItemID = new Set<id>();
        Map<id, ASI_MFM_PO_Receipt_Item__c> MPOReceiptItem = new Map<id,ASI_MFM_PO_Receipt_Item__c>();
        for(ASI_MFM_PO_Receipt_Item__c PORecItem : trigger_new){     
            //Modified by Wilken on 20140429, PO Receipt used by China and Gulf MFM
            if(SCNRecTypeID.contains(PORecItem.recordtypeid)){
                SPORecItemID.add(PORecItem.ASI_MFM_PO_Line_Item__c);
                MPOReceiptItem.put(PORecItem.ASI_MFM_PO_Line_Item__c,PORecItem);
            }
            PORecItem.ASI_MFM_Receipt_Amount_YTD__c = PORecItem.ASI_MFM_Amount__c;
            system.debug(PORecItem.ASI_MFM_PO_Line_Item_Receipt_Amount__c);
            system.debug(PORecItem.PO_Line_Item_Receipt_Amount_Temp__c);
        }
        
        
        if(SPORecItemID != null && SPORecItemID.size()>0){
            // Attach PO Receipt to PO directly for displaying in related list on PO page
            List<ASI_MFM_PO_Line_Item__c> LPOItem = [Select id, ASI_MFM_PO__c, name, ASI_MFM_Amount__c, 
                ASI_MFM_Paid_Amount__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_CN_PrePaid_Amount__c,ASI_MFM_CN_Paid_Amount__c 
                from ASI_MFM_PO_Line_Item__c where id IN :SPORecItemID];
            //List<ASI_MFM_PO_Receipt_Item__c> LPOReceiptItemUpdate = new List<ASI_MFM_PO_Receipt_Item__c>();
            for(ASI_MFM_PO_Line_Item__c POItem : LPOItem){
                if(MPOReceiptItem.containsKey(POItem.id)){
                    ASI_MFM_PO_Receipt_Item__c PORecItem = MPOReceiptItem.get(POItem.id);
                    PORecItem.ASI_MFM_PO__c = POItem.ASI_MFM_PO__c;
                    //LPOReceiptItemUpdate.add(PORecItem);
                    system.debug(POItem.ASI_MFM_Amount__c);
                    PORecItem.ASI_MFM_Amount__c = PORecItem.ASI_MFM_Amount__c - POItem.ASI_MFM_CN_Receipt_Amount__c;
                    if(POItem.ASI_MFM_Amount__c < PORecItem.ASI_MFM_Receipt_Amount_YTD__c){
                        PORecItem.addError('Receipt Amount cannot be larger than PO Item amount: ' + POItem.name);
                    }
                    /*
                    else if(PORecItem.ASI_MFM_Receipt_Amount_YTD__c < POItem.ASI_MFM_CN_Paid_Amount__c){
                        PORecItem.addError('Receipt Amount cannot be smaller than PO Item paid amount: ' + POItem.name);
                    }
                    */ 
                    // comment by wilson 22/4/2014
                    else if(POItem.ASI_MFM_CN_Paid_Amount__c > 0){
                        if (PORecItem.ASI_MFM_Receipt_Amount_YTD__c > 0) {
                            // 2014-12-12 Axel@introv #122 change the ">" to ">="
                            
                            system.debug('PORecItem.ASI_MFM_Receipt_Amount_YTD__c: ' + PORecItem.ASI_MFM_Receipt_Amount_YTD__c);
                            system.debug('POItem.ASI_MFM_CN_Paid_Amount__c: ' + POItem.ASI_MFM_CN_Paid_Amount__c);
                            
                            
                            if(PORecItem.ASI_MFM_Receipt_Amount_YTD__c >= POItem.ASI_MFM_CN_Paid_Amount__c){ // PORecItem.ASI_MFM_Receipt_Amount_YTD__c >= POItem.ASI_MFM_CN_Paid_Amount__c
                            }
                            else{ 
                                if (POItem.ASI_MFM_CN_PrePaid_Amount__c != 0 && PORecItem.ASI_MFM_Receipt_Amount_YTD__c < POItem.ASI_MFM_CN_PrePaid_Amount__c){
                                    
                                } else if (PORecItem.ASI_MFM_Receipt_Amount_YTD__c < POItem.ASI_MFM_CN_Paid_Amount__c){
                                    // 2018-10-12 Introv fix auto receipt issue
                                    if(math.abs(POItem.ASI_MFM_CN_Paid_Amount__c - PORecItem.ASI_MFM_Receipt_Amount_YTD__c)>1) {
                                        PORecItem.addError('Receipt Amount cannot be smaller than Payment Amount: ' + POItem.name + ', Paid Amount: ' + String.valueOf(POItem.ASI_MFM_CN_Paid_Amount__c) + ', Receipt Amount: ' + String.valueOf(PORecItem.ASI_MFM_Receipt_Amount_YTD__c) + ', Pre-Paid Amount: ' + String.valueOf(POItem.ASI_MFM_CN_PrePaid_Amount__c) );
                                    }
                                    // 2018-10-12 Introv fix auto receipt issue
                              }
                            }
                            /*
                            else if(POItem.ASI_MFM_CN_PrePaid_Amount__c != 0 && PORecItem.ASI_MFM_Receipt_Amount_YTD__c < POItem.ASI_MFM_CN_PrePaid_Amount__c){
                                PORecItem.addError('Receipt Amount cannot be smaller than Payment Amount: ' + POItem.name + ', ' + String.valueOf(POItem.ASI_MFM_CN_Paid_Amount__c) + '...' + String.valueOf(PORecItem.ASI_MFM_Receipt_Amount_YTD__c) + ' > ' + String.valueOf(POItem.ASI_MFM_CN_PrePaid_Amount__c) );
                            } else if (PORecItem.ASI_MFM_Receipt_Amount_YTD__c < POItem.ASI_MFM_CN_Paid_Amount__c) {
                                PORecItem.addError('Receipt Amount cannot be smaller than Payment Amount: ' + POItem.name);
                            }*/
                            //else{}
                        } else {
                            PORecItem.addError('Receipt Amount cannot be smaller than Payment Amount: ' + POItem.name);                            
                        }
                    }
                    else{}
                    
                }
            }            
            // calculate receipt amount from YTD entered 
        }       
    }
    
    public static void routineAfterUpsert(list<ASI_MFM_PO_Receipt_Item__c> trigger_new, map<id, ASI_MFM_PO_Receipt_Item__c> trigger_oldMap) {       
        Set<id> SPORecItemID = new Set<id>();
        Set<id> SPORecID = new Set<id>();
        Map<id, ASI_MFM_PO_Receipt_Item__c> MPOReceiptItem = new Map<id,ASI_MFM_PO_Receipt_Item__c>();
        List<ASI_MFM_PO_Line_Item__c> updateLPOItem = new List<ASI_MFM_PO_Line_Item__c>();
        
         
        for(ASI_MFM_PO_Receipt_Item__c PORecItem : trigger_new){     
            if (Global_RecordTypeCache.getRt(PORecItem.recordTypeId).developerName.contains('ASI_MFM_TR')){
                if (trigger_oldMap !=  null && trigger_oldMap.get(PORecItem.id).ASI_MFM_ETL__c == false && PORecItem.ASI_MFM_ETL__c == true){
                     SPORecItemID.add(PORecItem.ASI_MFM_PO_Line_Item__c);                   
                }
               SPORecID.add(PORecItem.ASI_MFM_PO_Receipt__c);
            }
        }
        //Validation of PO Receipt Item for Company Code, P/A
        List<ASI_MFM_PO_Receipt__c> receiptList = [select id, (select ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__r.ASI_MFM_L3__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Pay_Acc__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__r.ASI_MFM_Location__c  from PO_Receipt_Items__r) from ASI_MFM_PO_Receipt__c where id in :SPORecID];
         for(ASI_MFM_PO_Receipt_Item__c PORecItem : trigger_new){     
            if (Global_RecordTypeCache.getRt(PORecItem.recordTypeId).developerName.contains('ASI_MFM_TR')){
                    
                for (ASI_MFM_PO_Receipt__c receipt:receiptList){
                    Set<String> payAccrualSet = new Set<String>();
                    Set<String> buSet = new Set<String>();
                
                    List<ASI_MFM_PO_Receipt_Item__c> items = receipt.PO_Receipt_Items__r;
                    
                    for (ASI_MFM_PO_Receipt_Item__c item:items){
                        payAccrualSet.add(item.ASI_MFM_PO_Line_Item__r.ASI_MFM_Pay_Acc__c);
                        
                        if (item.ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__r.ASI_MFM_Location__c == 'India'){
                            buSet.add('India');
                        }
                        else if (item.ASI_MFM_PO_Line_Item__r.ASI_MFM_BU_Code__r.ASI_MFM_Location__c != 'India'){
                            buSet.add('non-India');
                        }
                    }
                    
                    System.debug(' payAccrualSet: ' + payAccrualSet + ' buSet: ' + buSet);
                    
                    if (payAccrualSet.size() >1 && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger'))
                        PORecItem.addError('Cannot perform PO Receipt for both Paid and Accrual PO Lines.');
                    
                    if (buSet.size() >1 && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger'))
                        PORecItem.addError('Cannot perform PO Receipt for both India and non-India PO Lines.');                 
                }
            }
        }
        
        if(SPORecItemID != null && SPORecItemID.size()>0){
             // Attach PO Receipt to PO directly for displaying in related list on PO page
            List<ASI_MFM_PO_Line_Item__c> LPOItem = [Select id, ASI_MFM_PO__c, name, ASI_MFM_Amount__c, 
                ASI_MFM_Paid_Amount__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_CN_PrePaid_Amount__c,ASI_MFM_CN_Paid_Amount__c ,ASI_MFM_Synced__c  
                from ASI_MFM_PO_Line_Item__c where id IN :SPORecItemID];
            for(ASI_MFM_PO_Line_Item__c POItem : LPOItem){
                if (POItem.ASI_MFM_Synced__c  == false){
                    POItem.ASI_MFM_Synced__c = true;
                    updateLPOItem.add(POItem);
                } 
            }
            if (updateLPOItem != null && updateLPOItem.size()>0){
                update updateLPOItem ;
            }
        }       
    }
    

    public static void routineBeforeDelete(list<ASI_MFM_PO_Receipt_Item__c> trigger_old) {
        // Not allowed to delete if the "ETL" = true
        set<id> po_set = new set<id>();
        for (ASI_MFM_PO_Receipt_Item__c p:trigger_old) {
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_CN') && (p.ASI_MFM_ETL__c == true || p.ASI_MFM_Auto_Receipt__c)){//20180531 Introv
                    p.addError('Not allowed to delete because the PO Receipt Item is \'ETL\' synced');
            }
        }
        // Added by Alan Wong (Elufa) 27Mar2015 
        // Block delete for Final POR or ETL == true    
        for (ASI_MFM_PO_Receipt_Item__c pi:trigger_old) {
            po_set.add(pi.ASI_MFM_PO_Receipt__c);
        }
        map<id, ASI_MFM_PO_Receipt__c> por_map = new map<id, ASI_MFM_PO_Receipt__c>([select id from ASI_MFM_PO_Receipt__c where id in :po_set and ASI_MFM_Status__c = 'Final']);     
        for (ASI_MFM_PO_Receipt_Item__c p:trigger_old) {
            if ((por_map.containsKey(p.ASI_MFM_PO_Receipt__c) || p.ASI_MFM_ETL__c == true) && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TR')) {
                if (!Test.isRunningTest())
        {
                  p.addError('Not allowed to delete because the PO Receipt Item is \'ETL\' synced or PO Receipt is Final');
                }
            }
        }

    }
 
}