//test : ASI_MFM_KR_PaymentLineItem_Test 

public  without sharing  class ASI_MFM_KR_PaymentLineItem_TriggerClass {
   
    
    public static void routineBeforeInsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new) {
        set<id> payment_set = new set<id>();
        set<id> pol_set = new set<id>();    
        //Update : Tax Explanation Code ASI_HK_CRM_Payment_Term_Code__c        “GL Offset”: ASI_KOR_Venue_Channel__c 
        String TaxExplanationCode = '';
        string GLOffset='';
        Set<id> payset= new set <id>();
        Set<id> poSet = new Set<id>(); 
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            payset.add(pi.ASI_MFM_Payment__c);
            poSet.add(pi.ASI_MFM_PO__c); 
            if(pi.ASI_MFM_Invoice_Date__c==null){
                pi.ASI_MFM_Invoice_Date__c=system.today();
            }
            if (pi.ASI_MFM_Payee__c == null) {
                payment_set.add(pi.ASI_MFM_Payment__c);
            }
            if (pi.ASI_MFM_PO_Line_Currency__c == null || pi.ASI_MFM_PO_Line_Remaining_Amount__c == null) {
                pol_set.add(pi.ASI_MFM_PO_Line_Item__c);
            }
        }
        
        // Set payee to payment header's supplier if not input by user          
        if (payment_set.size() > 0) {
            map<id, ASI_MFM_Payment__c> payment_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_Supplier_Name__c from ASI_MFM_Payment__c where id in :payment_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {  
                if (pi.ASI_MFM_Payee__c == null && payment_map.containsKey(pi.ASI_MFM_Payment__c)) {
                    pi.ASI_MFM_Payee__c = payment_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Supplier_Name__c;
                }               
            }            
        }
        
        // Set PO line currency, PO line remaining amount and PO line description
        if (pol_set.size() > 0) {
            map<id, ASI_MFM_PO_Line_Item__c> pol_map = new map<id, ASI_MFM_PO_Line_Item__c>([select ASI_MFM_Currency__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_List_Item_Description__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Paid_Amount__c from ASI_MFM_PO_Line_Item__c where id in :pol_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
                if (pol_map.containsKey(pi.ASI_MFM_PO_Line_Item__c)) {
                    if (pi.ASI_MFM_PO_Line_Currency__c == null) {
                        pi.ASI_MFM_PO_Line_Currency__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Currency__c;
                    }
                    if (pi.ASI_MFM_PO_Line_Remaining_Amount__c == null) {
                        pi.ASI_MFM_PO_Line_Remaining_Amount__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_Remaining_Balance__c;
                    }
                    if (pi.ASI_MFM_PO_Line_Description__c == null) {
                        pi.ASI_MFM_PO_Line_Description__c = pol_map.get(pi.ASI_MFM_PO_Line_Item__c).ASI_MFM_List_Item_Description__c;
                    }                   
                }
            }               
        }//End
        
        if(payset.size()>0){
            Map<id,ASI_MFM_Payment__c> PaymentMap= new Map<id,ASI_MFM_Payment__c>();
            List<ASI_MFM_Payment__c> pylist = [select id, ASI_MFM_Cash_Out_Payment__c, ASI_MFM_Offset_Payment__c, ASI_MFM_Currency__c,ASI_MFM_Status__c,ASI_MFM_Supplier_Name__c,ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c,ASI_MFM_Supplier_Name__r.ASI_KOR_Venue_Channel__c,ASI_MFM_Venue_Loan_Payment__c from ASI_MFM_Payment__c where id in : payset];
            for(ASI_MFM_Payment__c py: pylist){
                PaymentMap.put(py.id,new ASI_MFM_Payment__c (ASI_MFM_Cash_Out_Payment__c = py.ASI_MFM_Cash_Out_Payment__c, ASI_MFM_Offset_Payment__c = py.ASI_MFM_Offset_Payment__c, ASI_MFM_Currency__c=py.ASI_MFM_Currency__c,ASI_MFM_Remarks__c =py.ASI_MFM_Supplier_Name__r.ASI_HK_CRM_Payment_Term_Code__c,ASI_MFM_One_Off_Payee__c=py.ASI_MFM_Supplier_Name__r.ASI_KOR_Venue_Channel__c, ASI_MFM_Venue_Loan_Payment__c=py.ASI_MFM_Venue_Loan_Payment__c ));
            }
            
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                if(PaymentMap.containsKey(pi.ASI_MFM_Payment__c)){
                    if(PaymentMap.get(pi.ASI_MFM_Payment__c).ASI_MFM_Currency__c=='KRW'){
                        if(!PaymentMap.get(pi.ASI_MFM_Payment__c).ASI_MFM_Cash_Out_Payment__c && !PaymentMap.get(pi.ASI_MFM_Payment__c).ASI_MFM_Offset_Payment__c){//20180105 by intorv, bypass for cash out payment & offset payment
                        	pi.ASI_MFM_Tax_Explanation_Code__c=PaymentMap.get(pi.ASI_MFM_Payment__c).ASI_MFM_Remarks__c;
                        }
                        if(!PaymentMap.get(pi.ASI_MFM_Payment__c).ASI_MFM_Cash_Out_Payment__c){//20180122 by intorv, bypass for cash out payment
                        	pi.ASI_MFM_GL_Offset__c=PaymentMap.get(pi.ASI_MFM_Payment__c).ASI_MFM_One_Off_Payee__c;
                        }
                    }
                }
            } 
        }// end payset 
        
        Map<Id,ASI_MFM_PO__c> poMap = new Map<Id,ASI_MFM_PO__c>([SELECT id, ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, ASI_MFM_Plan__c, ASI_MFM_Plan__r.Name  FROM ASI_MFM_PO__c WHERE Id IN: poSet]);
        for(ASI_MFM_Payment_Line_Item__c line :trigger_new){
            if(poMap.containsKey(line.ASI_MFM_PO__c)  && poMap.get(line.ASI_MFM_PO__c).ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c !=null && poMap.get(line.ASI_MFM_PO__c).ASI_MFM_Plan__r.Name !=null  && poMap.get(line.ASI_MFM_PO__c).ASI_MFM_Plan__c !=null ){
                line.ASI_MFM_PlanText__c = poMap.get(line.ASI_MFM_PO__c).ASI_MFM_Plan__r.Name;
                line.ASI_MFM_PlanNameText__c = poMap.get(line.ASI_MFM_PO__c).ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c;
            }
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
                
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        set<id> supplier_set = new set<id>();
        set<id> supplier_THset = new set<id>();
        
        // Added by 2018-08-13 Linus@introv
        set<id> CashoutPayment_set = new set<id>();            
        map<id,id> PaymentSupplier_map = new map<id,id>();
        map<id, decimal> PaymentCashoutAmount_map = new map<id, decimal>();
        map<id, string> Supplier_map = new map<id, string>();
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            if (pi.ASI_MFM_Payment_Amount__c != null && pi.ASI_MFM_Currency__c != pi.ASI_MFM_PO_Line_Currency__c) {
                pay_ccy_set.add(pi.ASI_MFM_Currency__c);
                po_ccy_set.add(pi.ASI_MFM_PO_Line_Currency__c);
            }
            if (pi.ASI_MFM_Invoice_Date__c == null || pi.ASI_MFM_Invoice_Number__c == null) {
                pay_set.add(pi.ASI_MFM_Payment__c);
            }            
            if(pi.ASI_MFM_Cashout_Payment_Number__c != null){
                CashoutPayment_set.add(pi.ASI_MFM_Cashout_Payment_Number__c);
                pay_set.add(pi.ASI_MFM_Payment__c);
            }
        }
                
        
        map<id, ASI_MFM_Payment__c> pay_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c,recordType.developerName, ASI_MFM_Offset_Payment__c from ASI_MFM_Payment__c where id in :pay_set]);
        
        // Retrieve Cashout Payment Supplier Name    **************** 2018-08-13 Linus@introv
        if(CashoutPayment_set.size() > 0){   system.debug('Linus: enter cashout Payment');
            for(ASI_MFM_Payment__c py: [Select ASI_MFM_Supplier_Name__c, ASI_MFM_KR_TotalPayAmtIncludeVAT__c   from ASI_MFM_Payment__c where id = :CashoutPayment_set]){
                PaymentSupplier_map.put(py.id, py.ASI_MFM_Supplier_Name__c);
                PaymentCashoutAmount_map.put(py.id, py.ASI_MFM_KR_TotalPayAmtIncludeVAT__c );              
            }
            for(Account s: [Select id, name from Account where id= :PaymentSupplier_map.values()]){
                Supplier_map.put(s.id, s.name);
            }
            for(ASI_MFM_Payment_Line_Item__c pi: trigger_new){
                if(pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Offset_Payment__c == true){
                    pi.ASI_MFM_Cashout_Payment_Payee__c = Supplier_map.get(PaymentSupplier_map.get(pi.ASI_MFM_Cashout_Payment_Number__c));
                    pi.ASI_MFM_CashOut_Payment_Amount__c = PaymentCashoutAmount_map.get(pi.ASI_MFM_Cashout_Payment_Number__c); 
                }
            }
        }
        // END - Linus
        
        // Set invoice number and invoice date
        if (pay_set.size() > 0) {
            
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
                if (pi.ASI_MFM_Invoice_Date__c == null) {   
                    pi.ASI_MFM_Invoice_Date__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Date__c;
                }
                if (pi.ASI_MFM_Invoice_Number__c == null) { 
                    pi.ASI_MFM_Invoice_Number__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Number__c;
                }                                   
            }    
     
        }
        // Recalculate the paid amount in PO currency     
        string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
       
      
        list<ASI_MFM_Exchange_Rate__c> xr_list = new list<ASI_MFM_Exchange_Rate__c>();
        if (pay_ccy_set.size() > 0 && po_ccy_set.size() > 0) {
            xr_list = [select ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c in :pay_ccy_set and ASI_MFM_Counter_Currency__c in :po_ccy_set and ASI_MFM_Country__c = :country and ASI_MFM_Effective_Date__c <= :date.today() order by ASI_MFM_Effective_Date__c desc];
        }
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = null;
            pi.ASI_MFM_GF_Paid_Amount_in_PO_Currency__c = null;
            
            if (pi.ASI_MFM_Payment_Amount__c != null) {
                decimal xrate;
                if (pi.ASI_MFM_Currency__c == pi.ASI_MFM_PO_Line_Currency__c) {
                    xrate = 1;
                }
                else {
                    for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                        if (xr.ASI_MFM_Base_Currency__c == pi.ASI_MFM_Currency__c && xr.ASI_MFM_Counter_Currency__c == pi.ASI_MFM_PO_Line_Currency__c) {
                            xrate = xr.ASI_MFM_Exchange_Rate__c;
                            break;
                        }
                    }
                }
                if (xrate != null) {
                    pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);
                }
            }
            
            
            if(pi.ASI_MFM_Exchange_Rate__c!=null){
                pi.ASI_MFM_Paid_Amount_in_Base_Currency__c=pi.ASI_MFM_Exchange_Rate__c*pi.ASI_MFM_Payment_Amount__c;
            }
            
            
            
            
        }
        
    
    }    
    
    
        
    
    
    public static void routineAfterALL(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        Set<id> POReceiptItemId = new Set<id>();
        Set<id> CurrentIdSet = new Set<id>();
        
        set<id> ph_set = new set<id>();
        
        if(trigger_oldmap!=null){ //  update
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                if(pi.ASI_MFM_PO_Receipt_Item__c!=null){
                    POReceiptItemId.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }
                CurrentIdSet.add(pi.id);
            }//End For Loop
        }
        
        
        if(trigger_new!=null){ //not delete
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                if(pi.ASI_MFM_PO_Receipt_Item__c!=null){
                    POReceiptItemId.add(pi.ASI_MFM_PO_Receipt_Item__c);
                }
                CurrentIdSet.add(pi.id);
            }
        }
        
        
        
        if(POReceiptItemId.size()>0){
            List<ASI_MFM_Payment_Line_Item__c> upsertpaymentList=[select id,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_PO_Receipt_Item__c,ASI_MFM_Payment_Amount__c,ASI_MFM_Payment__r.ASI_MFM_Exchange_Rate__c from ASI_MFM_Payment_Line_Item__c where id not in : CurrentIdSet and ASI_MFM_PO_Receipt_Item__c in : POReceiptItemId];      
            List<ASI_MFM_PO_Receipt_Item__c> upsertList = new List<ASI_MFM_PO_Receipt_Item__c>();
            
            Map<Id,decimal> POR_Map=new Map<Id,decimal>();
            for(Id PORLId:POReceiptItemId){
                POR_Map.put(PORLId,0.00);
            }
            
            for(ASI_MFM_Payment_Line_Item__c pay:upsertpaymentList){
                if(!POR_Map.containsKey(pay.ASI_MFM_PO_Receipt_Item__c)){
                    POR_Map.put(pay.ASI_MFM_PO_Receipt_Item__c, pay.ASI_MFM_Paid_Amount_in_PO_Currency__c);
                }else{
                    // accumulate all Payment amount 
                    decimal PaidAmount=POR_Map.get(pay.ASI_MFM_PO_Receipt_Item__c)+pay.ASI_MFM_Paid_Amount_in_PO_Currency__c;
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
                            decimal  pamount=0.0;
                            if(pi.ASI_MFM_Paid_Amount_in_PO_Currency__c!=null){
                                pamount=pi.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                            }
                            decimal PaidAmount=POR_Map.get(pi.ASI_MFM_PO_Receipt_Item__c)+pamount;
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
        
        
        
        //For Payment Amount Update
        if (trigger_oldmap == null) { //insert
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                ph_set.add(pi.ASI_MFM_Payment__c);
                
            }
        }
        else if (trigger_new == null) { //delete
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                ph_set.add(pi.ASI_MFM_Payment__c);  
            }
        }
        else { // update
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                ph_set.add(pi.ASI_MFM_Payment__c);
            }           
        }
        if (ph_set.size() > 0) {
            list<ASI_MFM_Payment__c> ph_list = [select (select ID,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__c from Payment_Line_Items__r),id from ASI_MFM_Payment__c where id in :ph_set];
            
            for (ASI_MFM_Payment__c ph:ph_list) {
                ph.ASI_MFM_Payment_Amount__c = 0;
                for (ASI_MFM_Payment_Line_Item__c pi:ph.Payment_Line_Items__r) {
                    if (pi.ASI_MFM_Payment_Amount__c != null) {                        
                        ph.ASI_MFM_Payment_Amount__c += pi.ASI_MFM_Payment_Amount__c;
                    }
                }
                
            }
            
            update ph_list;
            system.debug('ph_list Tony : '+ph_list);
        }
        
        
    }
    
    
}