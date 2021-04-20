public with sharing  class ASI_MFM_JP_Payment_TriggerClass {
    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        Set<ID> paymentIDs = new Set<ID>();
        boolean TrueToFalse=false;
        
        // Added by 2017-06-06 Linus@Introv
        Map<ID, ASI_MFM_Payment__c> mapPayment = new Map<ID, ASI_MFM_Payment__c>();
        List<ASI_MFM_Payment_Line_Item__c> plList = new List<ASI_MFM_Payment_Line_Item__c>();
        // END - Linus@Introv
        
        for (ASI_MFM_Payment__c pay:trigger_new) {
            if(!pay.ASI_MFM_No_Need_to_ETL__c &&  trigger_oldMap.get(pay.id).ASI_MFM_No_Need_to_ETL__c){
                paymentIDs.add(pay.id);
                TrueToFalse=true;
            }
            if(pay.ASI_MFM_No_Need_to_ETL__c &&  !trigger_oldMap.get(pay.id).ASI_MFM_No_Need_to_ETL__c){
                //false to true
                paymentIDs.add(pay.id);
            }
            
            // Added by 2017-06-06 Linus@Introv
            mapPayment.put(pay.id, pay);
            // END - Linus@Introv
        }
        if(paymentIDs.size()>0){
            boolean Iserror=false;
            map<id,boolean> paymentMap =new map<id,boolean> ();
            set<id> PayIdSet= new set<id>();
            List<ASI_MFM_Payment_Line_Item__c> payLineList=[select ASI_MFM_Payment__c,ASI_MFM_ETL__c,ASI_MFM_Voucher_Created__c,ASI_MFM_Payment_Line_Item_Finance_Verify__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c in : paymentIDs];
            for(ASI_MFM_Payment_Line_Item__c pl:payLineList){
                if(TrueToFalse){
                    pl.ASI_MFM_ETL__c=false;
                    pl.ASI_MFM_ETL_Date__c=null;
                }else{
                    if(pl.ASI_MFM_Voucher_Created__c){
                        if(!PayIdSet.contains(pl.ASI_MFM_Payment__c)){
                            PayIdSet.add(pl.ASI_MFM_Payment__c);
                            paymentMap.put(pl.ASI_MFM_Payment__c, false);
                        }
                        //pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
                    }//Voucher Created checking end.
                    else if(pl.ASI_MFM_Payment_Line_Item_Finance_Verify__c){
                         pl.ASI_MFM_ETL__c=true;
                    }
                    
                }
                
            }
            
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if(paymentMap.containsKey(pay.id) && !paymentMap.get(pay.id)){
                    pay.addError('Not allowed to update \'No Need to ETL\' Flag, because Voucher Created.');
                }
            }
            
            if(payLineList.size()>0){
                update payLineList;
            }
            
        }
        
        // For JP, after updating the Invoice Number and Invoice Date, auto-sync to all Payment Line Item  ********  Added by 2017-06-06  Linus@Introv
        if(mapPayment.keySet().size() != 0){
            plList = [Select id, ASI_MFM_Payment__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :mapPayment.keySet()];
                
            for(ASI_MFM_Payment_Line_Item__c pl: plList){
                pl.ASI_MFM_Invoice_Number__c = mapPayment.get(pl.ASI_MFM_Payment__c).ASI_MFM_Invoice_Number__c;
                pl.ASI_MFM_Invoice_Date__c = mapPayment.get(pl.ASI_MFM_Payment__c).ASI_MFM_Invoice_Date__c;
            }
                        
            if(!Test.isRunningTest())
                update plList;
        
        }  
        // END - For JP, after updating the Invoice Number and Invoice Date, auto-sync to all Payment Line Item  ********  Added by 2017-06-06  Linus@Introv
    }
}