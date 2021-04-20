public without sharing class ASI_MFM_SC_Payment_TriggerClass {
    
    public static void routineBeforerDelete(list<ASI_MFM_Payment__c> trigger_old) {
        for (ASI_MFM_Payment__c pa : trigger_old)
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete')
            	pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
    }

    public static void routineAfterDelete(list<ASI_MFM_Payment__c> trigger_old) {
         
    }

    public static void routineAfterUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        if((!trigger_new[0].ASI_MFM_OCR__c && !trigger_new[0].ASI_MFM_SC_Recurring__c )&&(trigger_oldMap == NULL || trigger_new[0].asi_mfm_po__c!=trigger_oldMap.get(trigger_new[0].id).asi_mfm_po__c )) {
            List<ASI_MFM_Payment_Line_Item__c> del_line = [select id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :trigger_new[0].id];
            
            Delete del_line;
            
            List<ASI_MFM_AP_Code__c> apList = [SELECT Id, Name,asi_mfm_sc_Need_Subleger__c , ASI_MFM_A_C_Code__c FROM ASI_MFM_AP_Code__c WHERE RecordType.DeveloperName = 'ASI_MFM_SC_AP_Code' AND ASI_MFM_Inactive__c = false];        
            Map<ID, ID> apcCMap = new Map<ID, ID>();
            for(ASI_MFM_AP_Code__c ap : apList) 
                apcCMap.put(ap.ID,ap.ASI_MFM_A_C_Code__c);     

            date sysDate = date.today();
            List<ASI_MFM_PO_Line_Item__c> POLlist = [Select id, ASI_MFM_AP_Group__c, ASI_MFM_AP_Code_PL__c, ASI_MFM_AP_Code__c,asi_mfm_bu_code__c,asi_mfm_sc_Subledger__c, ASI_MFM_List_Item_Description__c , asi_mfm_amount__c from ASI_MFM_PO_Line_Item__c where recordtype.name ='SC PO Line Item' and ASI_MFM_PO__c = :trigger_new[0].asi_mfm_po__c order by id];       

			//if is not gen = false, generate
            if(!trigger_new[0].ASI_MFM_Sys_Is_Not_Gen_Line__c){
            	List<ASI_MFM_Payment_Line_Item__c> paymentDetailList = new List<ASI_MFM_Payment_Line_Item__c>(); 
	            
	            for(ASI_MFM_PO_Line_Item__c pol: POLlist) {
	                paymentDetailList.add(new ASI_MFM_Payment_Line_Item__c(
                        ASI_MFM_Payment__c = trigger_new[0].id,
                        ASI_MFM_PO__c = trigger_new[0].asi_mfm_po__c,
                        ASI_MFM_PO_Line_Item__c = pol.id,
                        ASI_MFM_BU__c = pol.ASI_MFM_BU_Code__c,
                        ASI_MFM_AP_Group__c = pol.ASI_MFM_AP_Group__c,
                        ASI_MFM_AP_Code_PL__c = pol.ASI_MFM_AP_Code_PL__c,
                        ASI_MFM_AP_Code__c = pol.ASI_MFM_AP_Code__c,
                        ASI_MFM_A_C_Code__c = apcCMap.get(pol.ASI_MFM_AP_Code__c),
                        ASI_MFM_Payment_Amount__c = pol.asi_mfm_amount__c,
                        ASI_MFM_Invoice_Date__c =sysDate,
                        ASI_MFM_G_L_Date__c= sysDate,
                        asi_mfm_sc_Subledger__c = pol.asi_mfm_sc_Subledger__c,
                        recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SC_Payment_Line_Item')
                    ));
                    
					system.debug('payment trigger after upsert: '+ paymentDetailList.get(paymentDetailList.size() - 1));
	            } 
	            insert paymentDetailList;
            }
            
        } else if (trigger_oldMap!=null &&!trigger_new[0].ASI_MFM_Currency__c.equalsIgnoreCase(trigger_oldMap.get(trigger_new[0].id).ASI_MFM_Currency__c)){
            List<ASI_MFM_Payment_Line_Item__c> paymentDetail = [SELECT ID , asi_mfm_payment_amount__c,ASI_MFM_Paid_Amount_in_Base_Currency__c FROM ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c =:trigger_new[0].id];
            for (ASI_MFM_Payment_Line_Item__c payD :paymentDetail )
                payD.ASI_MFM_Paid_Amount_in_Base_Currency__c=trigger_new[0].asi_mfm_exchange_rate__c*payD.asi_mfm_payment_amount__c; 
                
            update paymentDetail ;    
        }
        
    }

    public static void routineBeforeInsert(list<ASI_MFM_Payment__c> trigger_new) {
        set<id> px_set = new set<id>();
        for (ASI_MFM_Payment__c p:trigger_new) 
            if (p.asi_mfm_prefix__c != null) 
            	px_set.add(p.asi_mfm_prefix__c);
        
        // Set the Payment ID for new Payment               
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c from asi_mfm_prefix__c 
            where asi_mfm_module__c = 'Payment' and id in :px_set for update]);
        
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values());           
    }

    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        System.debug('Start Payment routineAfterUpdate');

        Set<ID> paymentIDSet = new Set<ID>();
       
        for(ASI_MFM_Payment__c payment : trigger_new)
            paymentIDSet.add(payment.id);
        
        Map<ID,ASI_MFM_Payment_Line_Item__c> itemMap = new Map<ID,ASI_MFM_Payment_Line_Item__c>([select ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Payee__c, 
            ASI_MFM_BU__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_Payment__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Payment_Date__c 
                from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDSet]);
        
        Set<ASI_MFM_Payment_Line_Item__c> itemsForUpdate = new Set<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_Payment_Line_Item__c> itemsListForUpdate = new List<ASI_MFM_Payment_Line_Item__c>();
        Boolean needUpdateFlag = false;
        
        for(ASI_MFM_Payment__c payment : trigger_new){            
            //Update Payment Header Supplier (i.e. Payee), Invoice Date and Invoice Number into detail lines
            //Update G/L Date into Payment Line Payment Date for OBI Report
            if ((payment.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(payment.id).ASI_MFM_Invoice_Number__c 
                || payment.ASI_MFM_Invoice_Date__c != trigger_oldMap.get(payment.id).ASI_MFM_Invoice_Date__c 
                    || payment.ASI_MFM_SC_Supplier_Name__c != trigger_oldMap.get(payment.id).ASI_MFM_SC_Supplier_Name__c
                        || payment.ASI_MFM_Payment_Type__c != trigger_oldMap.get(payment.id).ASI_MFM_Payment_Type__c
                            || payment.ASI_MFM_AP_Code__c != trigger_oldMap.get(payment.id).ASI_MFM_AP_Code__c) 
                || payment.ASI_MFM_Status__c == 'Finance Verified' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Final'){
                
                for(ASI_MFM_Payment_Line_Item__c item : itemMap.values()) {
                    needUpdateFlag = false;
                    
                    if (payment.ASI_MFM_Invoice_Date__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c;
                        needUpdateFlag = true;
                    }
                    
                    if (payment.ASI_MFM_Invoice_Number__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c;
                        needUpdateFlag = true;
                    }
                             
                    //Update G/L Date into Payment Line Payment Date for OBI Report
                    if (item.ASI_MFM_Payment__c == payment.id && payment.ASI_MFM_Status__c == 'Finance Verified' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Final'){
                        item.ASI_MFM_Payment_Date__c = payment.ASI_MFM_G_L_Date__c;
                        needUpdateFlag = true;
                    }
                    
                    if (needUpdateFlag)
                        itemsForUpdate.add(item);
                }
            }
            
            //Checking before submit payment for approval
            System.debug('Original Payment Status: ' + trigger_oldMap.get(payment.id).ASI_MFM_Status__c + ' New Status: ' + payment.ASI_MFM_Status__c + ' Approved?: ' + payment.ASI_MFM_Approved__c); 
            if(payment.ASI_MFM_Status__c == 'Submitted' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Draft'){

                for(ASI_MFM_Payment_Line_Item__c item : itemMap.values()) {
                    if (item.ASI_MFM_Invoice_Date__c == null && item.ASI_MFM_Payment__c == payment.id){payment.adderror('Please enter Invoice Date');}
                    else if (item.ASI_MFM_Invoice_Number__c == null && item.ASI_MFM_Payment__c == payment.id){payment.adderror('Please enter Invoice Number');}
                    else if (item.ASI_MFM_A_C_Code__c == null && item.ASI_MFM_Payment__c == payment.id){payment.adderror('Please enter A/C Code');}
                    else if (item.ASI_MFM_Payment_Amount__c == null && item.ASI_MFM_Payment__c == payment.id){payment.adderror('Please enter Payment Amount');}
                }
                
                if (!payment.ASI_MFM_Approved__c){
                    try {
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setObjectId(payment.id);
                        Approval.ProcessResult result = Approval.process(req1);
                        
                        if (!result.isSuccess()) 
                            payment.addError('Payment ' + payment.name + ' failed for submit for approval.');
                    }
                    catch (System.DmlException e) { 
                        payment.addError(e.getDmlMessage(0));
                    }
                }
            }
            
            if (itemsForUpdate.size() > 0){
                itemsListForUpdate.addAll(itemsForUpdate);
                update itemsListForUpdate;
            }
        }
    }
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpdate');

        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Payment__c> reject_map = new map<id, ASI_MFM_Payment__c>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') 
                reject_map.put(p.id, p);
        }
        
        if (reject_map.size() > 0) {
            list<ASI_MFM_Payment__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_MFM_Payment__c where id in :reject_map.keySet()];
            for (ASI_MFM_Payment__c r:reject_list) {
                if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                    reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
    }
    
    public static void clearApprover(ASI_MFM_Payment__c payment) {
        payment.ASI_MFM_Sys_Approver_1__c = null;
        payment.ASI_MFM_Sys_Approver_2__c = null;
        payment.ASI_MFM_Sys_Approver_3__c = null;
        payment.ASI_MFM_Sys_Approver_4__c = null;
        payment.ASI_MFM_Sys_Approver_5__c = null;
        payment.ASI_MFM_Sys_Approver_6__c = null;
        payment.ASI_MFM_Sys_Approver_7__c = null;
        payment.ASI_MFM_Sys_Approver_8__c = null;
        payment.ASI_MFM_Sys_Approver_9__c = null;
        payment.ASI_MFM_Sys_Approver_10__c = null;
	}
    
    public static void addApprover(ASI_MFM_Payment__c payment, Id approver, decimal minimumAmout) {
        if (payment.ASI_MFM_Payment_Amount_in_Base_Currency__c >= minimumAmout) {
        if (payment.ASI_MFM_Sys_Approver_1__c == null) payment.ASI_MFM_Sys_Approver_1__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_2__c == null) payment.ASI_MFM_Sys_Approver_2__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_3__c == null) payment.ASI_MFM_Sys_Approver_3__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_4__c == null) payment.ASI_MFM_Sys_Approver_4__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_5__c == null) payment.ASI_MFM_Sys_Approver_5__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_6__c == null) payment.ASI_MFM_Sys_Approver_6__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_7__c == null) payment.ASI_MFM_Sys_Approver_7__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_8__c == null) payment.ASI_MFM_Sys_Approver_8__c = approver;
        else if (payment.ASI_MFM_Sys_Approver_9__c == null) payment.ASI_MFM_Sys_Approver_9__c = approver;
        }
    }

    public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
               
        List<Id> poIdList = new List<Id>();
        List<id>supplierID= new List<Id>();
        
        for (ASI_MFM_Payment__c pay:trigger_new) {

            poIdList.add(pay.asi_mfm_po__C);
            supplierID.add(pay.ASI_MFM_SC_Supplier_Name__c);
            
            if(pay.ASI_MFM_Exchange_Rate__c==null || pay.ASI_MFM_Exchange_Rate__c==0 || ( trigger_oldMap!=null &&!pay.ASI_MFM_Currency__c.equalsIgnoreCase(trigger_oldMap.get(pay.id).ASI_MFM_Currency__c)) ){
                if(pay.ASI_MFM_Currency__c.equalsIgnoreCase('HKD'))
                    pay.ASI_MFM_Exchange_Rate__c=1.0;
                else {
                    List<ASI_MFM_Exchange_Rate__c> exList=[select Id, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Counter_Currency__c= :pay.ASI_MFM_Currency__c and ASI_MFM_Base_Currency__c ='HKD' and ASI_MFM_Country__c='HK' and ASI_MFM_Application__c='MFM' and ASI_MFM_Effective_Date__c >=last_n_days:180 and ASI_MFM_Effective_Date__c<= :pay.ASI_MFM_Payment_Date__c order by ASI_MFM_Effective_Date__c desc];
                    pay.ASI_MFM_Exchange_Rate__c = (exList.size() > 0) ? exList.get(0).ASI_MFM_Exchange_Rate__c : 1.0;
                }               
            }
        }
        
        List<ASI_MFM_Payment__c> paymentSameSupplier = [SELECT ID, Name, ASI_MFM_Invoice_Number__c, ASI_MFM_SC_Supplier_Name__c 
                                                            FROM ASI_MFM_Payment__c 
                                                            WHERE ASI_MFM_SC_Supplier_Name__c IN: supplierID 
                                                            AND recordtype.developername LIKE 'ASI_MFM_SC%'
                                                            and ASI_MFM_Invoice_Number__c !=''];
            
        for (ASI_MFM_Payment__c pay:trigger_new) {
            for(ASI_MFM_Payment__c payment : paymentSameSupplier){
                if(payment.ASI_MFM_Invoice_Number__c == pay.ASI_MFM_Invoice_Number__c && payment.id != pay.id)
                    pay.adderror('Cannot have duplicate Invoice Number under the same Supplier');
            }
        }
        
        
        if (poIdList.size() > 0){
            map<id, ASI_MFM_PO__c> po_map = new map<id, ASI_MFM_PO__c>([select id,ASI_MFM_PO_Type__c from ASI_MFM_PO__c where id in :poIdList]);
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
 System.debug('po#='+pay.asi_mfm_po__c);           
                pay.ASI_MFM_Payment_Type__c=po_map.get(pay.asi_mfm_po__c).ASI_MFM_PO_Type__c; 
            }
        }
        
        //Set the approvers for the payment based on the routing rule objects          
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        set<id> pr_set = new set<id>();
        set<string> STeam = new set<string>();
        
        //Default approver assignment logic, not applied to CN, GF      
        for (ASI_MFM_Payment__c p:trigger_new) {
            pid_set.add(p.id);
            px_set.add(p.ASI_MFM_Prefix__c);                                                       
            pr_set.add(p.ownerID);           
        }

        //CAPEX HK: Approvers route type logic        
        list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
        
        brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c from ASI_MFM_Brand_Route_Type_Map__c where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and ASI_MFM_Responsible_By__c = :pr_set ];

        set<id> rt_set = new set<id>();     
            
        for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list)
            rt_set.add(brm.ASI_MFM_Route_Type__c);

        system.debug('** rt_set **' + rt_set );        
        
        list<ASI_MFM_Route_Rule_Detail__c> rule_list = new list<ASI_MFM_Route_Rule_Detail__c>();
        
        rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c,asi_mfm_hkd__c from ASI_MFM_Route_Rule_Detail__c 
                    where ASI_MFM_Route_Type__c in : rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c asc];
    
        
        for (ASI_MFM_Payment__c payment : trigger_new) {
            if (trigger_oldMap != null) {
                ASI_MFM_Payment__c old = trigger_oldMap.get(payment.id);
                
                if (payment.ASI_MFM_Route_Type__c != null && payment.OwnerId == old.OwnerId) {
                    
                    clearApprover(payment);
                    
                    List<ASI_MFM_Route_Rule_Detail__c> routeRuleDetails = [
                        SELECT ASI_MFM_Approver__c, asi_mfm_hkd__c  
                        FROM ASI_MFM_Route_Rule_Detail__c 
                        WHERE ASI_MFM_Route_Type__c = :payment.ASI_MFM_Route_Type__c
                        ORDER BY ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c
                    ];
                    
                    for (ASI_MFM_Route_Rule_Detail__c detail : routeRuleDetails)
                        addApprover(payment, detail.ASI_MFM_Approver__c, detail.asi_mfm_hkd__c);

                    continue;
                }
                            
                if (payment.ASI_MFM_Prefix__c == old.ASI_MFM_Prefix__c && payment.OwnerId == old.OwnerId)
                    continue;
            }

            Id routeTypeId = null;
	        for (ASI_MFM_Brand_Route_Type_Map__c typeMap : brm_list) {
	            if (typeMap.ASI_MFM_Prefix__c == payment.ASI_MFM_Prefix__c) {
	                routeTypeId = typeMap.ASI_MFM_Route_Type__c;
	                break;
                }
            }
            
            if (routeTypeId != null)
                payment.ASI_MFM_Route_Type__c = routeTypeId;
            
            populateApprover(payment, rule_list, payment.ASI_MFM_Submitter__c);  
        }

        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_Payment__c> Payment_list = new list<ASI_MFM_Payment__c>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                Payment_list.add(p);
            }
        }
        
        if (Payment_list.size() > 0) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'Payment']);
            for (ASI_MFM_Payment__c p:Payment_list) {
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c))
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for Payment');
                else {
                    string owner_role = owner_map.get(p.ownerId).userRole.DeveloperName;
                    boolean valid_prefix = false;               
                    for (ASI_MFM_Role_Prefix_Relationship__c pr:prefix_map.get(p.ASI_MFM_Prefix__c).ASI_MFM_Role_Prefix_Relationships__r) {
                        if (pr.ASI_MFM_Role_Name__c == owner_role) {
                            valid_prefix = true;
                            break;
                        }
                    }
                    
                    if (!valid_prefix) 
                        p.ASI_MFM_Prefix__c.addError('The prefix is not valid for the owner');                  
                }
            }
        }                
    }//End routineBeforeUpsert method
    
    
    //The method will populate Approvers on Payment record 
    public static void populateApprover(ASI_MFM_Payment__c paymentRecord, List<ASI_MFM_Route_Rule_Detail__c> pLstRouteRuleDtls,id submitter){

        decimal total=0;
        if(paymentRecord.ASI_MFM_OCR__c)
            total=paymentRecord.ASI_MFM_Payment_Amount__c==null?0:paymentRecord.ASI_MFM_Payment_Amount__c;
        else
            total=paymentRecord.ASI_MFM_Payment_Amt_Inv__c==null?0:paymentRecord.ASI_MFM_Payment_Amt_Inv__c;    
        
        decimal local_amount =  total* paymentRecord.ASI_MFM_Exchange_Rate__c;
 System.debug(paymentRecord.ASI_MFM_Payment_Amt_Inv__c+','+local_amount);
        
        clearApprover(paymentRecord);
        
        for(ASI_MFM_Route_Rule_Detail__c routeDetail : pLstRouteRuleDtls){       
  System.debug(routeDetail.asi_mfm_hkd__c+','+routeDetail.ASI_MFM_Approver__c);         
        
                if(submitter!=null && submitter==routeDetail.ASI_MFM_Approver__c)
                    continue;
            
            	addApprover(paymentRecord, routeDetail.ASI_MFM_Approver__c, routeDetail.asi_mfm_hkd__c);
        }//End for 
    }//End assignApprover method
         
}//End Class