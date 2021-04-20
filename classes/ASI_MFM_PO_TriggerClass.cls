public without sharing class ASI_MFM_PO_TriggerClass {
    
    public static void routineAfterAll (list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Update Total PO Amount in Plan object       
        set<id> pid_set = new set<id>();
        if (trigger_new != null) {
            for (ASI_MFM_PO__c po:trigger_new) {
                pid_set.add(po.ASI_MFM_Plan__c);
            }
        }
        if (trigger_oldMap != null) {
            for (ASI_MFM_PO__c po:trigger_oldMap.values()) {
                pid_set.add(po.ASI_MFM_Plan__c);
            }           
        }
        if (pid_set.size() > 0) {
            //Update By Introv 20170721 Add "Accrual PO(ASI_MFM_Accrual_PO__c)" field in query to exclude accrual PO:
            list<ASI_MFM_Plan__c> p_list = [select ASI_MFM_Currency__c,ASI_MFM_Total_Draft_PO_Amount__c, (select ASI_MFM_Exchange_Rate__c, ASI_MFM_PO_Amount__c, ASI_MFM_GF_Total_PO_Amount_PR_Gulf__c,ASI_MFM_Status__c,ASI_MFM_Accrual_PO__c  from POs__r where ASI_MFM_Accrual_PO__c=false), RecordTypeID from ASI_MFM_Plan__c where id in :pid_set for update];
            recordType rt;
            
            if(trigger_new != null) {
                rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
            }else {
                rt = Global_RecordTypeCache.getRt(trigger_oldMap.values()[0].recordTypeId);
            }
            
            for (ASI_MFM_Plan__c p:p_list) {
                p.ASI_MFM_Total_PO_Amount__c = 0;
                p.ASI_MFM_GF_Total_PO_Amount_PR_Gulf__c = 0;
                //Add By Elufa 20151229
                p.ASI_MFM_Total_Draft_PO_Amount__c=0;
                
                for (ASI_MFM_PO__c po:p.POs__r) {
                    if (po.ASI_MFM_Exchange_Rate__c > 0) {
                        //Update By Introv 20170721 Bypass accrual po
                        if (rt.developerName.startsWith('ASI_MFM_TW') && p.ASI_MFM_Currency__c == 'TWD' && !po.ASI_MFM_Accrual_PO__c ) {
                            p.ASI_MFM_Total_PO_Amount__c += (po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c).setScale(0, roundingmode.half_up);
                            //Add By Elufa 20151229 : update 'Total Final & Complete PO Amount' in Plan
                            if(po.ASI_MFM_Status__c=='Draft'){
                                p.ASI_MFM_Total_Draft_PO_Amount__c += (po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c).setScale(0, roundingmode.half_up); 
                            }
                            //Add By Elufa 20151229 End
                        }else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                            p.ASI_MFM_Total_PO_Amount__c += (po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c).setScale(2, roundingmode.half_up);
                            p.ASI_MFM_GF_Total_PO_Amount_PR_Gulf__c += (po.ASI_MFM_GF_Total_PO_Amount_PR_Gulf__c * po.ASI_MFM_Exchange_Rate__c).setScale(2, roundingmode.half_up);
                            
                        } else {
                            p.ASI_MFM_Total_PO_Amount__c += (po.ASI_MFM_PO_Amount__c * po.ASI_MFM_Exchange_Rate__c).setScale(2, roundingmode.half_up);
                        }
                    }
                }
            }
            update p_list;
        }
    }
    
    public static void routineAfterDelete(list<ASI_MFM_PO__c> trigger_old) {
        // Delete PO in Data Warehouse
        if (!ASI_MFM_Function.bypassCallouts()) {
            list<id> pid_list = new list<id>();
            for (ASI_MFM_PO__c p:trigger_old) {
                pid_list.add(p.id);
            }
            if (!(test.isRunningTest() && limits.getFutureCalls() >= limits.getLimitFutureCalls())) {           
                ASI_MFM_Callout.deletePO(pid_list); 
            }
        }       
    }
    
    public static void routineAfterInsert(list<ASI_MFM_PO__c> trigger_new) {
        set<id> pid_set = new set<id>();
        map<id, id> cid_map = new map<id, id>();
        map<id,Date> SD_map  = new map<id, Date>();    
        //Added TR Logic check if the PO is extended from original PO, clone only line item with next year marked.
        boolean isExtended = false;
        
        //Introv : check if it is clone for adjust
        boolean isCloneForAdjust = false;
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if (p.ASI_MFM_Cloned_PO_ID__c != p.id) {
                pid_set.add(p.id);
                if (p.ASI_MFM_Cloned_PO_ID__c != null) {
                    if (p.ASI_MFM_Is_Extended_PO__c)
                        isExtended = true;
                    if(p.ASI_MFM_Original_PO_for_Adjustment__c != null)
                        isCloneForAdjust = true;
                    cid_map.put(p.id, p.ASI_MFM_Cloned_PO_ID__c);
                    
                    SD_map.put(p.id,p.ASI_MFM_PO_Start_Date__c);
                }   
            }
        }
        
        // Set cloned PO ID to the new PO ID 
        // Set the status to Draft for cloned PO         
        if (pid_set.size() > 0) {
            list<ASI_MFM_PO__c> PO_list = [select ASI_MFM_Cloned_PO_ID__c from ASI_MFM_PO__c where id in :pid_set for update];
            for (ASI_MFM_PO__c p:PO_list) {
                if (p.ASI_MFM_Cloned_PO_ID__c != null && !isExtended) {
                    p.ASI_MFM_Status__c = 'Draft';
                }               
                p.ASI_MFM_cloned_PO_id__c = p.id;
            }
            try{
                update PO_list;
            }catch (Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('The responsible by has no route type set up') ? true : false;
                for (ASI_MFM_PO__c p:trigger_new) {
                    if (expectedExceptionThrown) p.AddError('The responsible by has no route type set up');
                }
            } 
        } 
        
        // If cloned PO ID is not null, clone the line items of the cloned PO to the new PO         
        if (cid_map.size() > 0) {
            
            list<id> cid_list = cid_map.values();
            string query_string = 'select ASI_MFM_PO_Start_Date__c,ASI_MFM_Is_Extended_PO__c,(' + ASI_MFM_Function.buildQuery('ASI_MFM_PO_line_item__c', null, 'PO_line_items__r order by name') + ') from ASI_MFM_PO__c where id in :cid_list';
            map<id, ASI_MFM_PO__c> clone_map = new map<id, ASI_MFM_PO__c>();
            for (ASI_MFM_PO__c p:database.query(query_string)) {
                clone_map.put(p.id, p);
            }           
            list<ASI_MFM_PO_line_item__c> cloned_pi_list = new list<ASI_MFM_PO_line_item__c>();
            list<ASI_MFM_PO_line_item__c> pi_list = new list<ASI_MFM_PO_line_item__c>(); 
            for (id PO_id:cid_map.keySet()) {
                //cloned_pi_list = clone_map.get(cid_map.get(PO_id)).PO_line_items__r;
                for (ASI_MFM_PO_line_item__c cloneline : clone_map.get(cid_map.get(PO_id)).PO_line_items__r){
                    cloned_pi_list.add(cloneline);
                }
                for (ASI_MFM_PO_line_item__c cloned_pi:cloned_pi_list) {
                    if ((!isExtended) ||  (isExtended && cloned_pi.ASI_MFM_Next_Year__c))
                    {
                        ASI_MFM_PO_line_item__c pi = cloned_pi.clone(false, true);
                        pi.ASI_MFM_PO__c = PO_id;
                        pi.ASI_MFM_PO_Line_Item_External_ID__c = null;
                        pi.ASI_MFM_Synced__c = false;
                        //When clone PO, auto update all PO Line GL Date to be equal to PO Start Date
                        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_GF')
                           || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')
                           || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY'))
                        { //pi.ASI_MFM_G_L_Date__c =trigger_new[0].ASI_MFM_PO_Start_Date__c;
                              pi.ASI_MFM_G_L_Date__c=SD_map.get(PO_id);pi.ASI_MFM_SG_BA_verify__c=false;pi.ASI_MFM_Complete__c=false;pi.ASI_MFM_Adjustment_Line__c=false;pi.ASI_MFM_POSM_Deposit__c=false;pi.ASI_MFM_POSM_Balance__c=false;
                        }// Finished
                        
                        //Edited for HK MFM P2.1 @ Introv
                        if(!(pi.ASI_MFM_List_Item_Description__c.contains('Closing PO Adjustment')) && Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_HK') ){
                            if(pi.ASI_MFM_Amount__c != null){
                                //2017-07-19 Introv
                                if(isCloneForAdjust){
                                    pi.ASI_MFM_Amount__c = pi.ASI_MFM_Amount__c * -1;
                                }
                            }
                            pi_list.add(pi);
                        }else if(!(pi.ASI_MFM_List_Item_Description__c.contains('Closing PO Adjustment') && pi.ASI_MFM_Amount__c < 0)){
                            pi_list.add(pi);
                        }
                        
                        
                    }
                }
            }
            insert pi_list;
        }       
    } 
    
    public static void routineAfterUpsert(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
      
    }
    
    public static void routineAfterUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Populate the exchange rate to PO line items
        map<id, decimal> xrate_map = new map<id, decimal>();
        for (ASI_MFM_PO__c p:trigger_new) { 
            if (p.ASI_MFM_Exchange_Rate__c != trigger_oldMap.get(p.id).ASI_MFM_Exchange_Rate__c) {
                xrate_map.put(p.id, p.ASI_MFM_Exchange_Rate__c);
            }
        } 
        if (xrate_map.size() > 0) {
            list<ASI_MFM_PO_Line_Item__c> pol_list = [select ASI_MFM_PO__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :xrate_map.keySet() for update]; 
            for (ASI_MFM_PO_Line_Item__c pol:pol_list) {
                pol.ASI_MFM_Exchange_Rate__c = xrate_map.get(pol.ASI_MFM_PO__c);
            }
            update pol_list;
        }
        
        // Added by Alan Wong (Elufa) 7Apr2015  
        // complete PO and free remaining plan amount for SG AND TH AND MY
        //system.debug('rt000');
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH') || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY')){          
            Set<ID> poIDs = new Set<ID>();
            Set<ID> poID = new Set<ID>();
            List<ASI_MFM_PO_Line_Item__c> POLs = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();  //SG
            for (ASI_MFM_PO__c p:trigger_new) {
                if (p.ASI_MFM_Status__c == 'Complete' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Final' ){
                    poIDs.add(p.id);
                }
                if (p.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted'){ //
                    poID.add(p.id);
                }
            }
            ID Rectypeid;
            if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')) {
                Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('TH PO Line Item').getRecordTypeId();
            }
            else if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY')) {  // Send Email to Supplier
                Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('MY PO Line Item').getRecordTypeId();
                List<ASI_MFM_PO__c> POterms= [select ownerId,ASI_MFM_Supplier_Name__r.gvp__Primary_Email__c,ASI_MFM_Supplier_Number__c,ASI_MFM_Supplier_Name__c,ASI_MFM_TR_Supplier_Email__c from ASI_MFM_PO__c where id in: poID];
                List <String> ToAddresses = new List <String>();  //system.debug('FindSupplier'+POterms+poID);
                ID ownerid; // Get Owner ID
                boolean Emailexist=false;
                for(ASI_MFM_PO__c poi:POterms){
                    if(poi.ASI_MFM_TR_Supplier_Email__c!=null){//if(poi.ASI_MFM_Supplier_Name__r.gvp__Primary_Email__c!=null){
                        ToAddresses.add(poi.ASI_MFM_TR_Supplier_Email__c); // Get Email address of Supplier
                        ownerid=poi.ownerId;
                        Emailexist=true;
                    }
                }
                Id templateId;// ID userid = UserInfo.getUserId();
                String templateApiName = 'ASI_MFM_MY_Supplier_Email';     //  Set Email template          
                try {
                    templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
                }catch (Exception e) {
                    //throw new UtilException ('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName + ' refer to Setup | Communications Templates ' + templateApiName);
                }//User currentUser = [SELECT Id, Email FROM User WHERE Id =:userid]; // Get User Id
                for(id rid : poID){
                    if( Emailexist==true){
                       Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); email.setTargetObjectId(ownerid); email.setToAddresses( ToAddresses ); email.setWhatId(rid ); email.setSaveAsActivity(false); email.setBccSender(false); email.setUseSignature(false);
                        email.setTemplateId(templateId);
                        for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]){  
                            if(owa.DisplayName.contains('MY'))   
                                email.setOrgWideEmailAddressId(owa.id);   
                        }
                        if(!Test.isRunningTest()){     
                            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                        }
                    }
                    
                }
                
            }
            
            set<id> errorpo = new set<id>();
            List<ASI_MFM_PO_Line_Item__c> poLineList = [select ID,ASI_MFM_PO__r.ASI_MFM_Is_FOC_PO__c,ASI_MFM_PO__r.ASI_MFM_T_E__c,ASI_MFM_PO__r.ASI_MFM_Payroll_PO__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_G_L_Date__c,ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c,ASI_MFM_Requested_Balance__c, name,ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = :poIDs and ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__C = false];
            String Description;
            for (ASI_MFM_PO_Line_Item__c poL : poLineList){
                if(poL.ASI_MFM_POSM_Deposit__c == true && poL.ASI_MFM_POSM_Balance__c == false){
                    errorpo.add(poL.ASI_MFM_PO__c);
                }else{
                    if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY')){
                        decimal adjustmentamount=poL.ASI_MFM_Remaining_Balance__c;
                        
                        Description='Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + (poL.ASI_MFM_Amount__c - poL.ASI_MFM_Requested_Balance__c) + '; Remaining Amount: ' + poL.ASI_MFM_Requested_Balance__c;
                        if(adjustmentamount!=0 && Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY')){
                            ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-adjustmentamount, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid,ASI_MFM_G_L_Date__c = poL.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
                            newPOL.add(poline);
                        }
                        ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                        
                        newPOL.add(CompletePoline);
                    }else if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH') &&   !poL.ASI_MFM_PO__r.ASI_MFM_Payroll_PO__c && !poL.ASI_MFM_PO__r.ASI_MFM_Is_FOC_PO__c && !poL.ASI_MFM_PO__r.ASI_MFM_T_E__c ){
                        Description='Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + (poL.ASI_MFM_Amount__c - poL.ASI_MFM_Remaining_Balance__c) + '; Remaining Amount: ' + poL.ASI_MFM_Remaining_Balance__c;
                        ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-poL.ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid,ASI_MFM_G_L_Date__c = poL.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
                        ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                        newPOL.add(poline);
                        newPOL.add(CompletePoline);
                    }   
                }
            }
            map<id, ASI_MFM_PO__c> PO_map = new map<id, ASI_MFM_PO__c>([select id from ASI_MFM_PO__c where id in :errorpo]);        
            for (ASI_MFM_PO__c po:trigger_new) {
                if (PO_map.containsKey(po.id)) {
                    po.addError('Not allowed to complete PO without settling POSM Deposit.');
                }           
            }
            if(newPOL.size()>0){
                upsert newPOL;
            }
        }
        else if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_GF')){
            //Wilken 20160615: Allow Gulf user to mass complete PO with reversal in list view
            Set<ID> poIDs = new Set<ID>();
            
            for (ASI_MFM_PO__c p:trigger_new) {
                if (p.ASI_MFM_Status__c == 'Complete' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Final' ){
                    poIDs.add(p.id);
                }
            }
            
            ASI_MFM_GF_Payment_TriggerClass.CompletePOLine(poIDs);
        }
        
        //Added by Wilken on 20140303, Clone for Adjust feature to be used by Regional MKT and JP, when an Adjustment PO is approved, update Amount to Adjusted Amount, append line item to Original PO        
        for (ASI_MFM_PO__c p:trigger_new) {           
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP')){    
                
                if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                    if (p.ASI_MFM_Status__c == 'Final' && 
                        (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft' || trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') && 
                        p.ASI_MFM_Original_PO_for_Adjustment__c != null){
                            String soql = getCreatableFieldsSOQL('ASI_MFM_PO_Line_Item__c','ASI_MFM_PO__c= \'' + p.id + '\'');
                            List<ASI_MFM_PO_Line_Item__c> plList = (List<ASI_MFM_PO_Line_Item__c>)Database.query(soql);
                            List<ASI_MFM_PO_Line_Item__c> plListForInsert = new List<ASI_MFM_PO_Line_Item__c>();
                            
                            for (ASI_MFM_PO_Line_Item__c pl : plList){
                              ASI_MFM_PO_Line_Item__c pl2 = pl.clone(false, true); pl2.ASI_MFM_PO__c = p.ASI_MFM_Original_PO_for_Adjustment__c; pl2.ASI_MFM_Adjust_PO_Number__c = p.id; plListForInsert.add(pl2); pl.ASI_MFM_Adjust_PO_Number__c = null; pl.ASI_MFM_Adjusted_Amount__c = pl.ASI_MFM_Amount__c; pl.ASI_MFM_Amount__c = 0; pl.ASI_MFM_JDE_Status__c = 'Paid';
                            }
                            insert plListForInsert;
                            update plList;
                        }
                }
            }
            //GF Logic: Auto create PO Receipt and Payment for VAP Brand Owner or VAP FOC after approved
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                if (p.ASI_MFM_Status__c == 'Final' && (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft' || trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') && (p.ASI_MFM_PO_Type__c == 'VAP Brand Owner' || p.ASI_MFM_PO_Type__c == 'VAP FOC')){
                    //User u = [select userRole.developerName, asi_mfm_country__c from user where id = :userInfo.getUserId()];
                    User u = [select userRole.developerName, asi_mfm_country__c from user where id = :p.OwnerId];    // Modified by 2017-06-30 Linus@Introv
                    list<asi_mfm_role_prefix_relationship__c> px_list = new list<asi_mfm_role_prefix_relationship__c>();                    
                    ID paymentPrefix;
                    
                    //Wilken 20170216, retrieve Payment Prefix based on PO Prefix TR Record Type                        
                    for (asi_mfm_role_prefix_relationship__c px:[select asi_mfm_prefix__c from asi_mfm_role_prefix_relationship__c where asi_mfm_prefix__r.ASI_MFM_Inactive__c = false and asi_mfm_prefix__r.asi_mfm_module__c = 'Payment' and asi_mfm_role_name__c = :u.userRole.developerName and asi_mfm_prefix__r.asi_mfm_country_name__c = 'GF' and asi_mfm_prefix__r.ASI_MFM_TR_Rec_Type__c = :p.ASI_MFM_Prefix_TR_Record_Type__c])
                    {
                        px_list.add(px);    
                    }
                    
                    if (px_list.size() >= 1) {
                        paymentPrefix = px_list[0].asi_mfm_prefix__c;
                    }
                    
                    ASI_MFM_PO_Receipt__c receipt = new ASI_MFM_PO_Receipt__c(ASI_MFM_Receipt_Date__c = System.Today(), recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt_Read_Only'), OwnerID = p.OwnerID, ASI_MFM_Status__c = 'Final');
                    
                    insert receipt;
                    
                    //Insert payment header
                    DateTime d = datetime.now();
                    string invNum = 'SYS_' + d.format('yyyy-MM-dd hh:mm:ss');
                    
                    ASI_MFM_Payment__c pay = new ASI_MFM_Payment__c(OwnerID = p.OwnerID, ASI_MFM_Status__c = 'Final', ASI_MFM_G_L_Date__c = date.today(), ASI_MFM_Invoice_Date__c = date.today(), 
                                                                    ASI_MFM_Currency__c = p.ASI_MFM_Currency__c, recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_GF_Payment_Read_Only'), ASI_MFM_Prefix__c = paymentPrefix, 
                                                                    ASI_MFM_Supplier_Name__c = p.ASI_MFM_Supplier_Name__c, ASI_MFM_Invoice_Number__c = invNum);
                    
                    insert pay;
                    
                    List<ASI_MFM_PO_Receipt_Item__c> recItems = new List<ASI_MFM_PO_Receipt_Item__c>();
                    List<ASI_MFM_Payment_Line_Item__c> payItems = new List<ASI_MFM_Payment_Line_Item__c>();
                    
                    for (ASI_MFM_PO_Line_Item__c pItem:[select ASI_MFM_PO__c, ASI_MFM_Amount__c, ASI_MFM_Distributor_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = :p.ID]){
                        //Insert Receipt Items
                        ASI_MFM_PO_Receipt_Item__c recItem = new ASI_MFM_PO_Receipt_Item__c(ASI_MFM_PO_Receipt__c = receipt.id, recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt_Item__cASI_MFM_GF_PO_Receipt_item'), ASI_MFM_PO__c = p.ID, ASI_MFM_PO_Line_Item__c = pItem.ID, ASI_MFM_Amount__c = pItem.ASI_MFM_Amount__c);
                        
                        recItems.add(recItem);
                        
                        //Insert Payment Items
                        //Wilken 20160715, Payment line need to include distributor amount copied from PO line
                        ASI_MFM_Payment_Line_Item__c payItem = new ASI_MFM_Payment_Line_Item__c(recordTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_GF_Payment_Line_Item'),  ASI_MFM_Payment_Amount__c = pItem.ASI_MFM_Amount__c, ASI_MFM_Payment_Amount_Distributor__c = pItem.ASI_MFM_Distributor_Amount__c, ASI_MFM_Payment__c = pay.id, ASI_MFM_PO_Line_Item__c = pItem.ID, ASI_MFM_Invoice_Date__c = date.today());
                        
                        payItems.add(payItem);
                    }
                    
                    insert recItems;
                    
                    insert payItems;
                }
            }
        }
    }
    
    public static void routineBeforeDelete(list<ASI_MFM_PO__c> trigger_old) {
        // Not allowed to delete if the PO has related payment line items       
        set<id> po_set = new set<id>();
        for (ASI_MFM_PO__c p:trigger_old) { 
            if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH') && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TH_Admin') ){// For TH USE, NO ALLOW TO DELETE Final or complete PO
                if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Complete'){
                    p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');
                }
                po_set.add(p.id);
            } 
            else if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW') && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TW_Admin')  ){
                if(p.ASI_MFM_Is_Direct_Payment__c != TRUE){
                    if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Complete'){
                        p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');
                    }
                    
                    po_set.add(p.id);
                }
            }
            else {
                if(p.ASI_MFM_Status__c != 'Draft'  && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_Admin') ){
                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TR_PO')){
                        p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');
                    }else{
                        if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Complete')
                            p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');                                    
                    }                   
                }
                
                po_set.add(p.id);
            }
        }
        list<ASI_MFM_Payment_Line_Item__c> pi_list = [select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c 
                                                      where ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c != TRUE and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c in :po_set order by ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c];
        map<id, integer> pi_map = new map<id, integer>();
        id current_pid;
        integer pi_count = 0;
        for (ASI_MFM_Payment_Line_Item__c pi:pi_list) {
            if (pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c != current_pid) {
                pi_map.put(current_pid, pi_count);
                current_pid = pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c;
                pi_count = 1;
            }
            else {
                pi_count++;
            }
        }
        if (current_pid != null) {
            pi_map.put(current_pid, pi_count);
        }
        for (ASI_MFM_PO__c p:trigger_old) { 
            if (pi_map.get(p.id) > 0 && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_Admin') ) {
                p.addError('Not allowed to delete because it has related payment line items');
            }
        }
    }
    
    public static void routineBeforeInsert(list<ASI_MFM_PO__c> trigger_new) {
        // Set the PO number for new PO                     
        set<id> px_set = new set<id>();
        List<ASI_MFM_PO_Date_Range__c> pr = new List<ASI_MFM_PO_Date_Range__c>();
        Set<id> PlanIds = new set<id>();
        Map<id, id> po_map = new map<id, id>();
        for (ASI_MFM_PO__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
            //Updated Steve Wan (Introv) 20140306JP PO Number Logic
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP_PO')){
                pr = [select id, name,asi_mfm_next_number__c,ASI_MFM_GL_Date__c  from ASI_MFM_PO_Date_Range__c where ASI_MFM_PO_Start_Date__c <= :p.ASI_MFM_PO_Raised_Date__c and ASI_MFM_PO_End_Date__c >= :p.ASI_MFM_PO_Raised_Date__c Limit 1 for update];
                if (pr.size() <= 0 ){
                    p.addError('PO Raised Date is not found in the PO Date Range Table');
                }
            }
            //Updated by Wilken 20151112, SOQL for TH PO only
            if ((Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH_PO')) && p.ASI_MFM_Plan__c != null){
                PlanIds.add(p.ASI_MFM_Plan__c);
            }
        }
        if (PlanIds.size()>0){
            for(ASI_MFM_Plan__c plan: [select id, ASI_MFM_Prefix__c from ASI_MFM_Plan__c where id in :PlanIds]){
                po_map.put(plan.id, plan.ASI_MFM_Prefix__c);
            }
        }
        //20180115 Introv added Dummy PO
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, ASI_MFM_Parent_Prefix__c, ASI_MFM_TW_Delivery_Address__c, asi_mfm_next_number__c,RecordType.DeveloperName, ASI_MFM_Company__c, ASI_MFM_Default_BU__c,ASI_MFM_Default_Customer__c from asi_mfm_prefix__c where ( asi_mfm_module__c = 'PO' or asi_mfm_module__c = 'Direct PO' or asi_mfm_module__c='Accrual PO' or asi_mfm_module__c='Dummy PO') and id in :px_set for update]);
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP_PO') && pr.size() > 0){
                    p.ASI_MFM_PO_Date_Range__c = pr[0].id;
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000000).substring(1, 7);
                    p.ASI_MFM_JP_PO_Number__c = p.name + ' - ' + pr[0].name ;
                }                
                else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_HK_PO')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 4){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                    }
                    else if (px_map.get(p.asi_mfm_prefix__c).name.length() == 3){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 100000).substring(1, 6);
                    }else {
                        //Length = 2
                        p.name = px_map.get(p.asi_mfm_prefix__c).name +  string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000000).substring(1, 7);
                    }
                    
                    //HK MFM Logic: Default BU base on Prefix
                    p.ASI_MFM_BU_Code__c = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Default_BU__c;
                }                
                else if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH_PO')){
                    if(px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Parent_Prefix__c != null) {
                        if(px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Parent_Prefix__c != po_map.get(p.ASI_MFM_Plan__c)){
                            p.addError('You cannot use Prefix: ' + px_map.get(p.asi_mfm_prefix__c).name + ' for this Plan');
                        }
                    }
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                        //p.ASI_MFM_PO_Raised_Date__c=date.newinstance(p.CreatedDate.year(),p.CreatedDate.month(),p.CreatedDate.day());
                    }   
                }                
                else{
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                    
                    // Added by 2017-10-18 Linus@introv
                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW_PO')){
                        p.ASI_MFM_Delivery_Address_Line_4__c = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_TW_Delivery_Address__c;
                    }
                }
                
                
                
                px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
            }
        }
        update pr;
        ASI_MFM_Function.updatePrefix(px_map.values());        
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Set the approvers for the PO based on the routing rule objects           
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        set<id> pr_set = new set<id>();        
        Set<id> OwnerId = new Set<id>();
        Boolean IsTHPO= false;
        Map<ID, User> OwnerMap  = new Map<ID,User>();
        Map<id,ASI_MFM_PO__c> gfPOMap = new Map<id,ASI_MFM_PO__c>();
        
        for (ASI_MFM_PO__c p:trigger_new) {                        
            if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                pid_set.add(p.id);
                px_set.add(p.ASI_MFM_Prefix__c);
                //Updated Steve Wan (Introv) 20140228 JP Logic
                
                p.ASI_MFM_Sys_Approver_1__c = null;
                p.ASI_MFM_Sys_Approver_2__c = null;
                p.ASI_MFM_Sys_Approver_3__c = null;
                p.ASI_MFM_Sys_Approver_4__c = null;
                p.ASI_MFM_Sys_Approver_5__c = null;
                
            }
            OwnerId.add(p.OwnerId);
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                IsTHPO = true;
            }
        }       
        
        
        if(IsTHPO){
            OwnerMap  = new Map<ID,User>([SELECT ID, Name,managerId  FROM User WHERE Id in :  OwnerId ]);
        }
        
        
        if (pid_set.size() > 0) {       
            System.debug('Start assign approver');
            map<id, id> sb_map = new map<id, id>();
            for (ASI_MFM_PO_Line_Item__c pi:[select ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c from ASI_MFM_PO_Line_Item__c 
                                             where ASI_MFM_PO__c in :pid_set order by name desc]) {
                                                 sb_map.put(pi.ASI_MFM_PO__c, pi.ASI_MFM_Sub_brand_Code__c);
                                             }
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
            
            //Other country logic
            brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Sub_brand__c = null or ASI_MFM_Sub_brand__c in :sb_map.values()) order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc];
            
            set<id> rt_set = new set<id>();    
            
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                rt_set.add(brm.ASI_MFM_Route_Type__c);
            }                              
            
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c from ASI_MFM_Route_Rule_Detail__c 
                                                            where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c];
            
            for (ASI_MFM_PO__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null)) {                                                        
                            rtid = brm.ASI_MFM_Route_Type__c;
                            
                            break;
                        }else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                            break;
                        }                       
                    }
                    
                    if (rtid != null) {
                        
                        boolean validSubBrand = true;
                        decimal local_amount = p.ASI_MFM_PO_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                        p.ASI_MFM_Route_Type__c = rtid  ;
                        for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                            Boolean AssignApprover = true;
                            if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH') && rd.ASI_MFM_Region__c != null && p.ASI_MFM_TH_Prefix_Name__c== true && p.ASI_MFM_TH_Region__c!=null){
                                Set<String> RegionSet = new Set<String>(); // PO's region
                                RegionSet.addAll(p.ASI_MFM_TH_Region__c.split(';'));
                                if(!RegionSet.contains(rd.ASI_MFM_Region__c)){
                                    AssignApprover = false;
                                }
                            }
                            if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount && AssignApprover) {
                                if (approver_count == 0) { p.ASI_MFM_Sys_Approver_1__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 1) {  p.ASI_MFM_Sys_Approver_2__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 2) {  p.ASI_MFM_Sys_Approver_3__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 3) {  p.ASI_MFM_Sys_Approver_4__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 4) {  p.ASI_MFM_Sys_Approver_5__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 5) {  p.ASI_MFM_Sys_Approver_6__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 6) {  p.ASI_MFM_Sys_Approver_7__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 7) {  p.ASI_MFM_Sys_Approver_8__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 8) {  p.ASI_MFM_Sys_Approver_9__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 9) {  p.ASI_MFM_Sys_Approver_10__c = rd.ASI_MFM_Approver__c;
                                }                                   
                                approver_count++;                                                                                                                               
                            }
                            else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                break;
                            }
                        }
                        
                    }
                    if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                        if(p.ASI_MFM_Sys_Approver_1__c == p.OwnerID && OwnerMap.containskey(p.OwnerID) ){
                            p.ASI_MFM_Sys_Approver_1__c =OwnerMap.get(p.OwnerID).managerId;
                        }
                        if(p.ASI_MFM_Sys_Approver_2__c == p.OwnerID && OwnerMap.containskey(p.OwnerID) ){
                            p.ASI_MFM_Sys_Approver_2__c =OwnerMap.get(p.OwnerID).managerId;
                        } 
                        if(p.ASI_MFM_Sys_Approver_3__c == p.OwnerID && OwnerMap.containskey(p.OwnerID) ){
                            p.ASI_MFM_Sys_Approver_3__c=OwnerMap.get(p.OwnerID).managerId;
                        }
                        
                        if(p.ASI_MFM_Sys_Approver_1__c ==p.ASI_MFM_Sys_Approver_2__c){
                            p.ASI_MFM_Sys_Approver_2__c = null;
                        }
                        if(p.ASI_MFM_Sys_Approver_2__c ==p.ASI_MFM_Sys_Approver_3__c){
                            p.ASI_MFM_Sys_Approver_3__c = null;
                        }
                    }
                }               
            }               
        }
        
        // Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_PO__c> reject_map = new map<id, ASI_MFM_PO__c>();
        for (ASI_MFM_PO__c p:trigger_new) { 
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
            }
        }
        if (reject_map.size() > 0) {
            list<ASI_MFM_PO__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_MFM_PO__c where id in :reject_map.keySet()];
            for (ASI_MFM_PO__c r:reject_list) {
                if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                    reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
        
    } 
    
    
    public static void routineBeforeUpsert(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Retrieve exchange rate if no input 
        set<id> po_set = new set<id>();
        set<id> acc_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
        //20140410 Steve Wan Default BU for JP
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }
        String JPRecTypeID = MRecType.get('ASI_MFM_JP_PO');
        String JPBUCodeDefault;
        
        String MYRecTypeID = MRecType.get('ASI_MFM_MY_PO');
        String MYBUCodeDefault;
        
        String THRecTypeID = MRecType.get('ASI_MFM_TH_PO');
        String THVATDefault;
        
        
        //20171024 Introv added to retrieve Original PO Status
        
        Set<Id> originalPOSet = new Set<Id>();
        Set<Id> POIdSet = new Set<Id>();
        //20171024 End                
        
        for (ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()) {
            if(Setting.name == 'JP_BU_Code__c' && Setting.Country__c == 'JP'){
                JPBUCodeDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'MY_BU_Code__c' && Setting.Country__c == 'MY'){
                MYBUCodeDefault = Setting.ASI_MFM_value__c;
            }
            if(Setting.name == 'TH_Default_VAT__c' && Setting.Country__c == 'TH'){
                THVATDefault = Setting.ASI_MFM_value__c;
            }            
        }
        for (ASI_MFM_PO__c po:trigger_new) {
            
            //20171024 Introv
            if(Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_HK') 
               && ((trigger_oldMap != Null && po.ASI_MFM_Original_PO_for_Adjustment__c != Null && trigger_oldMap.get(po.id).ASI_MFM_Original_PO_for_Adjustment__c != po.ASI_MFM_Original_PO_for_Adjustment__c) 
                   || (po.ASI_MFM_Original_PO_for_Adjustment__c != Null && (po.ASI_MFM_Orginal_PO_Status__c == '' || po.ASI_MFM_Orginal_PO_Status__c == Null)))){
                       
                       originalPOSet.add(po.ASI_MFM_Original_PO_for_Adjustment__c);
                       POIdSet.add(po.Id);
                       
                   }else if(Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_HK') && po.ASI_MFM_Original_PO_for_Adjustment__c == Null){
                       
                       po.ASI_MFM_Orginal_PO_Status__c = '';
                   }
            //20171024 End
            
            //MY Logic: Default BU Code
            if (Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_MY_PO')){
                if(po.ASI_MFM_BU_Code__c == null &&  MYBUCodeDefault != null && MYBUCodeDefault != ''){
                    po.ASI_MFM_BU_Code__c = MYBUCodeDefault;
                }
                if (po.ASI_MFM_Currency__c == po.ASI_MFM_Sys_Local_Currency__c &&po.ASI_MFM_Sys_Local_Currency__c!=null) {
                    po.ASI_MFM_Exchange_Rate__c = 1;
                }
            }
            else if(po.ASI_MFM_BU_Code__c == null && po.RecordTypeId == JPRecTypeID &&  JPBUCodeDefault != null && JPBUCodeDefault != ''){//JP Logic: Default BU Code
                po.ASI_MFM_BU_Code__c = JPBUCodeDefault;
            }
            
            else if(Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_TH_PO')){
                if(po.ASI_MFM_VAT__c == null &&  THVATDefault != null && THVATDefault != ''){
                    po.ASI_MFM_VAT__c = decimal.valueOf(THVATDefault);
                }
            }
            
            
            // Check if there was an input in the decimal number output error
            boolean isDecimal = (ASI_MFM_Function.containsDecimalValue(po.ASI_MFM_PO_Original_Amount__c) || ASI_MFM_Function.containsDecimalValue(po.ASI_MFM_PO_Amount__c)) && po.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                po.addError(' You Cannot input a decimal number for a TWD currency.');
            
            if (po.ASI_MFM_Exchange_Rate__c == null || (Global_RecordTypeCache.getRt(po.recordTypeId).developerName=='ASI_MFM_MY_PO' && trigger_oldMap != Null && trigger_oldMap.get(po.id).ASI_MFM_Currency__c != po.ASI_MFM_Currency__c) ) {
                po_set.add(po.id);
                ccy_set.add(po.ASI_MFM_Currency__c);
                if (last_effective_date == null || po.ASI_MFM_PO_Raised_Date__c > last_effective_date) {
                    last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
                }
            }            
        }
        
        if (po_set.size() > 0){
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            // Conrad Pantua 20140704 Handle Capex Country (Laputa)
            if (country == 'CA'){
                country = 'HK';
                trigger_new[0].ASI_MFM_Sys_Local_Currency__c = 'HKD';
            }            
            
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;         
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];

            for (ASI_MFM_PO__c po:trigger_new) {
                if (po_set.contains(po.id)) {
                    if (po.ASI_MFM_Currency__c == po.ASI_MFM_Sys_Local_Currency__c) {
                        po.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        if (po.ASI_MFM_Currency__c != null && po.ASI_MFM_PO_Raised_Date__c != null) {                                                                           
                            for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                                if (xr.ASI_MFM_Counter_Currency__c == po.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= po.ASI_MFM_PO_Raised_Date__c && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
                                    po.ASI_MFM_Exchange_Rate__c = xr.ASI_MFM_Exchange_Rate__c;
                                    break;
                                }
                                else if (xr.ASI_MFM_Counter_Currency__c > po.ASI_MFM_Currency__c) {
                                    break;
                                }
                            }
                            
                        }
                    }               
                }
            }                       
        }
        
        //20171024 Introv
        Map<Id, ASI_MFM_PO__c> mapOrginalPO = new Map<Id, ASI_MFM_PO__c>([SELECT id   , ASI_MFM_Status__c  FROM ASI_MFM_PO__c   WHERE Id IN : originalPOSet ]);
        //20171024 End                
        
        // Set default BU code if not input by user
        recordType rt = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId);
        string country_pfx = 'ASI_MFM_' + rt.developerName.substring(8,10) + '%';
        list<ASI_MFM_BU__c> bu_list = [select id from ASI_MFM_BU__c where recordType.developerName like :country_pfx];
        if (bu_list.size() == 1) {
            for (ASI_MFM_PO__c po:trigger_new) {
                //20140410 Steve Wan Default BU for JP
                if (po.ASI_MFM_BU_Code__c == null) {
                    po.ASI_MFM_BU_Code__c = bu_list[0].id;
                }
            } 
        }
        
        
        // The prefix must be for PO
        // The prefix must be valid for the owner
        set<id> owner_set = new set<id>();
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_PO__c> PO_list = new list<ASI_MFM_PO__c>();
        for (ASI_MFM_PO__c p:trigger_new) {
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                PO_list.add(p);
            }
        }
        if (PO_list.size() > 0 && !Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_KR') ) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            //Updated by Introv 20170731 to include Prefix's ASI_MFM_Module__c ='Accrual PO':
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                                                                                    from ASI_MFM_Prefix__c where id in :prefix_set AND (ASI_MFM_Module__c = 'PO' OR ASI_MFM_Module__c ='Accrual PO') ]);
            for (ASI_MFM_PO__c p:PO_list) {
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)&& !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for PO');
                }
                else {
                    string owner_role = owner_map.get(p.ownerId).userRole.DeveloperName;
                    boolean valid_prefix = false;               
                    for (ASI_MFM_Role_Prefix_Relationship__c pr:prefix_map.get(p.ASI_MFM_Prefix__c).ASI_MFM_Role_Prefix_Relationships__r) {
                        if (pr.ASI_MFM_Role_Name__c == owner_role) {
                            valid_prefix = true;
                            break;
                        }
                    }
                    if (!valid_prefix && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
                        p.ASI_MFM_Prefix__c.addError('The prefix is not valid for the owner');                  
                    }
                }
            }
        }
        
        //Added by Wilken on 20140311, Clone for adjust PO should not allow user to change PO currency      
        //Modified by Wilken 20140317, reduce SOQL usage
        //map<id, recordType> rt_map = new map<id, recordType>([select id, developerName from recordType where sobjectType = 'ASI_MFM_PO__c']);
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP_PO')){
                if (p.ASI_MFM_Original_PO_for_Adjustment__c != null){
                    ASI_MFM_PO__c originalPO = [select id, ASI_MFM_Currency__c from ASI_MFM_PO__c where id = :p.ASI_MFM_Original_PO_for_Adjustment__c];
                    if (p.ASI_MFM_Currency__c != originalPO.ASI_MFM_Currency__c){
                        p.addError('Currency of Clone for adjust PO should be the same as original PO');
                    }
                }
                
            }
        }
    }
    
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
        
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ return null; }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        
    }  
}