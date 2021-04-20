public without sharing  class ASI_MFM_JP_PaymentLineItem_TriggerClass {
    public static void routineAfterUpdate(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {   
        //Get ETL POR id in Payment line 
        Set<ID> PORIDs = new Set<ID>();
        Map<Id,decimal> POR_Map=new Map<Id,decimal>();
        List<ASI_MFM_PO_Receipt_Item__c> PORList;
        if(trigger_new!=null){
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                //Get PO Receipt Item id From Payment line Items if any ETL changes in Payment line
                if(pi.ASI_MFM_ETL__c==true && pi.ASI_MFM_PO_Receipt_Item__c!=null  && !trigger_oldMap.get(pi.id).ASI_MFM_ETL__c){
                    PORIDs.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }else if(!pi.ASI_MFM_ETL__c && trigger_oldMap.get(pi.id).ASI_MFM_ETL__c && pi.ASI_MFM_PO_Receipt_Item__c!=null){
                    PORIDs.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }else if(pi.ASI_MFM_ETL__c  && trigger_oldMap.get(pi.id).ASI_MFM_Payment_Amount__c != pi.ASI_MFM_Payment_Amount__c){
                    PORIDs.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }
                
            }
            
        }
        
        
        //For delete case
        if(trigger_new==null){
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldMap.values()) {
                if(pi.ASI_MFM_PO_Receipt_Item__c!=null){
                    PORIDs.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }
            }
        }
        
        if(PORIDs.size()>0){
            //Get Orignal PO Receipt Item Amount from database
            PORList=[select id,name,ASI_MFM_Paid_Amount__c from ASI_MFM_PO_Receipt_Item__c where id in:PORIDs];
            for(ASI_MFM_PO_Receipt_Item__c porl:PORList){
                POR_Map.put(porl.id, porl.ASI_MFM_Paid_Amount__c);
            }
			
        }
        
        
        Map<Id,decimal> UpdatePOR_Map=new Map<Id,decimal>();
        if (trigger_new != null){
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                if(pi.ASI_MFM_PO_Receipt_Item__c!=null){
                    //Case 1: Check ETL, add Payment amount in PO Receipt Item(ASI_MFM_Paid_Amount__c)
                    if(pi.ASI_MFM_ETL__c && !trigger_oldMap.get(pi.id).ASI_MFM_ETL__c ){
                        if(UpdatePOR_Map.containsKey(pi.ASI_MFM_PO_Receipt_Item__c)){
                            decimal PaidAmount=UpdatePOR_Map.get(pi.ASI_MFM_PO_Receipt_Item__c)+pi.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                            UpdatePOR_Map.remove(pi.ASI_MFM_PO_Receipt_Item__c);
                            UpdatePOR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, PaidAmount);
                        }else{
                            UpdatePOR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, pi.ASI_MFM_Paid_Amount_in_Base_Currency__c);
                        }
                    }//ENd Case 1
                    
                    //Case 2: Uncheck ETL, subtract Payment amount in PO Receipt Item(ASI_MFM_Paid_Amount__c)
                    if(trigger_oldMap!=null){
                        if(trigger_oldMap.get(pi.id).ASI_MFM_ETL__c && !pi.ASI_MFM_ETL__c){
                            if(UpdatePOR_Map.containsKey(pi.ASI_MFM_PO_Receipt_Item__c)){
                                decimal PaidAmount=UpdatePOR_Map.get(pi.ASI_MFM_PO_Receipt_Item__c)-pi.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                                UpdatePOR_Map.remove(pi.ASI_MFM_PO_Receipt_Item__c);
                                UpdatePOR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, PaidAmount);
                            }else{
                                UpdatePOR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, 0-pi.ASI_MFM_Paid_Amount_in_Base_Currency__c);
                            }
                            
                        }
                    }//End Case 2
                }
                //END
                
            }   
        }else{ // trigger_new == null, delete case
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldMap.values()) {
                if(trigger_oldMap.get(pi.id).ASI_MFM_ETL__c){
                    if(!UpdatePOR_Map.containsKey(pi.ASI_MFM_PO_Receipt_Item__c)){
                        UpdatePOR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, 0-pi.ASI_MFM_Paid_Amount_in_Base_Currency__c);
                    }else{
                        decimal PaidAmount=UpdatePOR_Map.get(pi.ASI_MFM_PO_Receipt_Item__c)-pi.ASI_MFM_Paid_Amount_in_Base_Currency__c;
                        UpdatePOR_Map.remove(pi.ASI_MFM_PO_Receipt_Item__c);
                        UpdatePOR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, PaidAmount); 
                    }
                    
                }
                
            }
        }
        //End trigger_new For Loop
        
        List<ASI_MFM_PO_Receipt_Item__c> upsertList = new List<ASI_MFM_PO_Receipt_Item__c>();
        //-------------------Update PO Receipt Item (ASI_MFM_Paid_Amount__c)----------------------------------------
        if(UpdatePOR_Map.size()>0){
            for(String key :UpdatePOR_Map.keySet()){
                ASI_MFM_PO_Receipt_Item__c P0RItemp =NEW ASI_MFM_PO_Receipt_Item__c();
                P0RItemp.ID=key;
                if(POR_Map.containsKey(key)){// Add orignal amount
                     P0RItemp.ASI_MFM_Paid_Amount__c=UpdatePOR_Map.get(key)+POR_Map.get(key);
                }else{
                     P0RItemp.ASI_MFM_Paid_Amount__c=UpdatePOR_Map.get(key); 
                    
                }
               
                upsertList.add(P0RItemp);
            }
        }
        
        //Update PO Receipt Item 
        if(upsertList.size()>0){
            update upsertList;
        }
    }
    
    public static void routineAfterALL(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        Set<id> POReceiptItemId = new Set<id>();
        Set<id> CurrentIdSet = new Set<id>();
        
        
        
        if(trigger_oldmap!=null){
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                if(pi.ASI_MFM_PO_Receipt_Item__c!=null){
                    POReceiptItemId.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }
                CurrentIdSet.add(pi.id);
            }//End For Loop
        }
        
      
        if(trigger_new!=null){
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                if(pi.ASI_MFM_PO_Receipt_Item__c!=null){
                    POReceiptItemId.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }
                CurrentIdSet.add(pi.id);
            }
        }
        if(POReceiptItemId.size()>0){
            List<ASI_MFM_Payment_Line_Item__c> upsertpaymentList=[select id,ASI_MFM_PO_Receipt_Item__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c from ASI_MFM_Payment_Line_Item__c where id not in : CurrentIdSet and ASI_MFM_PO_Receipt_Item__c in : POReceiptItemId];      
        	List<ASI_MFM_PO_Receipt_Item__c> upsertList = new List<ASI_MFM_PO_Receipt_Item__c>();
            
            Map<Id,decimal> POR_Map=new Map<Id,decimal>();
            for(Id PORLId:POReceiptItemId){
                POR_Map.put(PORLId,0.00);
            }
            
            for(ASI_MFM_Payment_Line_Item__c pay:upsertpaymentList){
                if(!POR_Map.containsKey(pay.ASI_MFM_PO_Receipt_Item__c)){
                    POR_Map.put(pay.ASI_MFM_PO_Receipt_Item__c, pay.ASI_MFM_Payment_Amount__c*pay.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c);
                }else{
                    // accumulate all Payment amount 
                    decimal PaidAmount=POR_Map.get(pay.ASI_MFM_PO_Receipt_Item__c)+pay.ASI_MFM_Payment_Amount__c*pay.ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c;
                    POR_Map.remove(pay.ASI_MFM_PO_Receipt_Item__c);
                    POR_Map.put(pay.ASI_MFM_PO_Receipt_Item__c, PaidAmount);
                }
            }
            
            if(trigger_new!=null){
                for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                    if(pi.ASI_MFM_PO_Receipt_Item__c!=null){
                        if(!POR_Map.containsKey(pi.ASI_MFM_PO_Receipt_Item__c)){
                            POR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, pi.ASI_MFM_Payment_Amount__c*pi.ASI_MFM_Exchange_Rate__c);
                        }else{
                            // accumulate all Payment amount 
                            decimal PaidAmount=POR_Map.get(pi.ASI_MFM_PO_Receipt_Item__c)+pi.ASI_MFM_Payment_Amount__c*pi.ASI_MFM_Exchange_Rate__c;
                            POR_Map.remove(pi.ASI_MFM_PO_Receipt_Item__c);
                            POR_Map.put(pi.ASI_MFM_PO_Receipt_Item__c, PaidAmount);
                        }                   
                    }
                }
                
            }// End For loop trigger new
             
            //construct Update list                  
            for(String key : POR_Map.keySet()){
                ASI_MFM_PO_Receipt_Item__c P0RItemp =NEW ASI_MFM_PO_Receipt_Item__c();
                P0RItemp.ID=key;
                P0RItemp.ASI_MFM_Payment_Amount__c=POR_Map.get(key);
                upsertList.add(P0RItemp);
            }
            
            if(upsertList.size()>0){
                update upsertList;
            }
            
        }
        
        
    }
    
    
    
}