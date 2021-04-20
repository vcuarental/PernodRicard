/*********************************************************************************
* Name:ASI_MFM_SG_PO_TriggerClass
* Description: 
* Test Class: ASI_MFM_SG_PDF_Test, ASI_MFM_SG_PO_Test, ASI_MFM_SG_Class_Test
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 31/05/2018       Wilken              [WL 1.0] Auto create dummy payment when FOC PO interface to JDE
* 25/06/2018       Wilken              [WL 2.0] Approver by Brand owner need to limit to Marketing PO
* 25/07/2018       Wilken              [WL 3.0] Approver by Brand owner need to limit to Marketing PO of FY1819 onwards only
* 15/08/2018      Linus                [LH 1.0] Exclude reversal creation if [No Payment Request Required] is true
* 16/05/2019      Wilken                [WL 4.0] INC0083476 Complete PO adjustment line need to deduct T&E Amount to avoid PO overspent
*********************************************************************************/
public without sharing class ASI_MFM_SG_PO_TriggerClass {
    public static void routineAfterInsert(list<ASI_MFM_PO__c> trigger_new) {
        set<id> pid_set = new set<id>();
        map<id, id> cid_map = new map<id, id>();
        
        map<id,Date> SD_map  = new map<id, Date>(); 
        
        
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if (p.ASI_MFM_Cloned_PO_ID__c != p.id) {
                pid_set.add(p.id);
                if (p.ASI_MFM_Cloned_PO_ID__c != null) {                    
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
                if (p.ASI_MFM_Cloned_PO_ID__c != null) {
                    p.ASI_MFM_Status__c = 'Draft';
                }               
                p.ASI_MFM_cloned_PO_id__c = p.id;
            }
            
            try{
                update PO_list;
            }catch (Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('The responsible by has no route type set up') ? true : false;
                for (ASI_MFM_PO__c p:trigger_new) {
                    if (expectedExceptionThrown) p.AddError('The responsible by has no route type set up');
                }
            } 
        } 
        
        // If cloned PO ID is not null, clone the line items of the cloned PO to the new PO         
        if (cid_map.size() > 0) {
            
            list<id> cid_list = cid_map.values();
            string query_string = 'select ASI_MFM_PO_Start_Date__c,ASI_MFM_Is_Extended_PO__c,(' + ASI_MFM_Function.buildQuery('ASI_MFM_PO_line_item__c', 'ASI_MFM_PO__r.ASI_MFM_Original_PO_for_Adjustment__c', 'PO_line_items__r order by name') + ') from ASI_MFM_PO__c where id in :cid_list';
            map<id, ASI_MFM_PO__c> clone_map = new map<id, ASI_MFM_PO__c>();
            for (ASI_MFM_PO__c p:database.query(query_string)) {
                clone_map.put(p.id, p);
            }           
            list<ASI_MFM_PO_line_item__c> cloned_pi_list = new list<ASI_MFM_PO_line_item__c>();
            list<ASI_MFM_PO_line_item__c> pi_list = new list<ASI_MFM_PO_line_item__c>(); 
            for (id PO_id:cid_map.keySet()) {
                //cloned_pi_list = ;
                for (ASI_MFM_PO_line_item__c cloneline : clone_map.get(cid_map.get(PO_id)).PO_line_items__r){
                    cloned_pi_list.add(cloneline);
                }
                for (ASI_MFM_PO_line_item__c cloned_pi:cloned_pi_list) {
                    
                    
                    ASI_MFM_PO_line_item__c pi = cloned_pi.clone(false, true);
                    pi.ASI_MFM_PO__c = PO_id;
                    pi.ASI_MFM_PO_Line_Item_External_ID__c = null;
                    pi.ASI_MFM_Synced__c = false;
                    //Add By Tony Ren,When clone PO, auto update all PO Line GL Date to be equal to PO Start Date
                    if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG'))
                    { //pi.ASI_MFM_G_L_Date__c =trigger_new[0].ASI_MFM_PO_Start_Date__c;
                        pi.ASI_MFM_G_L_Date__c=SD_map.get(PO_id);
                        pi.ASI_MFM_SG_BA_verify__c=false;
                        pi.ASI_MFM_Complete__c=false;
                        pi.ASI_MFM_Adjustment_Line__c=false;
                        pi.ASI_MFM_POSM_Deposit__c=false;
                        pi.ASI_MFM_POSM_Balance__c=false; 
                    }// Finished
                    
                    if(!(pi.ASI_MFM_List_Item_Description__c.contains('Closing PO Adjustment') && pi.ASI_MFM_Amount__c < 0)){
                        pi_list.add(pi);
                    }                        
                    
                }
            }
            insert pi_list;
        }       
    } 
    
    public static void routineAfterUpdate(list<ASI_MFM_PO__c> trigger_new, map<id, ASI_MFM_PO__c> trigger_oldMap) {
        // Populate the exchange rate to PO line items
        map<id, decimal> xrate_map = new map<id, decimal>();
        Set<Id> focPOIdSet = new Set<ID>();
        Set<String> poFYSet = new Set<String>();
        
        for (ASI_MFM_PO__c p:trigger_new) { 
            if (p.ASI_MFM_Exchange_Rate__c != trigger_oldMap.get(p.id).ASI_MFM_Exchange_Rate__c) {
                xrate_map.put(p.id, p.ASI_MFM_Exchange_Rate__c);
            }
            
            /*[WL 1.0] BEGIN*/
            if(p.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(p.id).ASI_MFM_JDE_Document_Number__c == null && p.ASI_MFM_JDE_Document_Number__c != null ){
                system.debug('Create Payment for FOC PO: ' + p.Name);
                focPOIdSet.add(p.Id);
                poFYSet.add(p.ASI_MFM_PO_Fiscal_Year__c);
            }
            /*[WL 1.0] END*/
        } 
        
        if (xrate_map.size() > 0) {
            list<ASI_MFM_PO_Line_Item__c> pol_list = [select ASI_MFM_PO__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in :xrate_map.keySet() for update]; 
            for (ASI_MFM_PO_Line_Item__c pol:pol_list) {
                pol.ASI_MFM_Exchange_Rate__c = xrate_map.get(pol.ASI_MFM_PO__c);
            }
            update pol_list;
        } 
        
        /*[WL 1.0] BEGIN*/
        if (!focPOIdSet.isEmpty()){     
            List<ASI_MFM_PO_Line_Item__c> poLineList = [SELECT Id, ASI_MFM_PO__c, ASI_MFM_Amount__c FROM ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__c in :focPOIdSet];
            List<ASI_MFM_Payment_Line_Item__c> payLineToInsert = new List<ASI_MFM_Payment_Line_Item__c>();      
            List<ASI_MFM_PO__c> poListToUpdate = new List<ASI_MFM_PO__c>();
            
            List<ASI_MFM_Prefix__c> prefixList = [SELECT Id, ASI_MFM_Fiscal_year__c, ASI_MFM_TR_Rec_Type__c, ASI_MFM_Department__c FROM ASI_MFM_Prefix__c 
                                                  WHERE ASI_MFM_country_name__c = 'SG' AND ASI_MFM_Module__c = 'Payment' AND ASI_MFM_Inactive__c = false
                                                  AND ASI_MFM_Fiscal_year__c in :poFYSet];
            for (ASI_MFM_PO__c p:trigger_new) {
                if (focPOIdSet.contains(p.Id)){
                    ASI_MFM_Payment__c pay = new ASI_MFM_Payment__c();
                    
                    pay.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_SG_Payment_Read_Only');
                    pay.ASI_MFM_Status__c = 'Final';
                    pay.ASI_MFM_Invoice_Number__c = 'SYS_DUMMY_' + p.Name;
                    pay.ASI_MFM_Invoice_Date__c = System.Today();
                    pay.ASI_MFM_Supplier_Name__c = p.ASI_MFM_Supplier_Name__c;
                    pay.ASI_MFM_G_L_Date__c = System.Today();
                    pay.ASI_MFM_ETL__c = true;
                    pay.ASI_MFM_Sync_to_JDE__c = true;
                    pay.ASI_MFM_Currency__c = p.ASI_MFM_Currency__c;
                    pay.OwnerId = p.OwnerId;
                    
                    for (ASI_MFM_Prefix__c prefix:prefixList){
                        if (prefix.ASI_MFM_TR_Rec_Type__c == p.ASI_MFM_Prefix_TR_Record_Type__c && prefix.ASI_MFM_Department__c == p.ASI_MFM_Department__c
                            && prefix.ASI_MFM_Fiscal_year__c == p.ASI_MFM_PO_Fiscal_Year__c)
                            pay.ASI_MFM_Prefix__c = prefix.Id;
                    }          
                    
                    insert pay;
                    
                    for (ASI_MFM_PO_Line_Item__c poLine:poLineList){
                        if (poLine.ASI_MFM_PO__c == p.Id){
                            ASI_MFM_Payment_Line_Item__c newPayLine = new ASI_MFM_Payment_Line_Item__c();
                            
                            newPayLine.recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Line_Item__cASI_MFM_SG_Payment_Line_Item');
                            newPayLine.ASI_MFM_Payment__c  = pay.Id;
                            newPayLine.ASI_MFM_PO_Line_Item__c = poLine.Id;
                            newPayLine.ASI_MFM_PO__c = p.Id;
                            newPayLine.ASI_MFM_Payment_Amount__c = poLine.ASI_MFM_Amount__c;
                            newPayLine.ASI_MFM_Payment_Line_Item_Finance_Verify__c = true;
                            newPayLine.ASI_MFM_Voucher_Created__c = true;
                            
                            payLineToInsert.add(newPayLine);
                        }
                    }
                    
                    ASI_MFM_PO__c tempPO = new ASI_MFM_PO__c();
                    tempPO.ASI_MFM_Status__c = 'Complete';
                    tempPO.Id = p.Id;
                    
                    poListToUpdate.add(tempPO);
                }
            }
            if(!Test.isRunningTest())
                insert payLineToInsert;
            update poListToUpdate;
        }
        /*[WL 1.0] END*/
        
        // Added by Alan Wong (Elufa) 7Apr2015  
        // complete PO and free remaining plan amount for SG AND TH AND MY
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG')){          
            Set<ID> poIDs = new Set<ID>();
            Set<ID> poID = new Set<ID>();
            List<ASI_MFM_PO_Line_Item__c> POLs = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();
            for (ASI_MFM_PO__c p:trigger_new) {
                // [LH 1.0]
                if (p.ASI_MFM_Status__c == 'Complete' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Final' && p.ASI_MFM_SG_No_Payment_Request_required__c == false ){
                    poIDs.add(p.id);
                    
                }
                if (p.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted'){ //add By Tony Ren
                    poID.add(p.id);
                }
            }
            ID Rectypeid;
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG')){
                Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('SG PO Line Item').getRecordTypeId();
                if (poID.size()>0){
                    POLs = [select id, ASI_MFM_Delete_Reject__c From ASI_MFM_PO_Line_Item__c WHERE ASI_MFM_PO__C IN: poID];
                    for (ASI_MFM_PO_Line_Item__c pol: POLs){
                        pol.ASI_MFM_Delete_Reject__c = true;
                        newPOL.add(pol);
                    }
                }
            }
            
            set<id> errorpo = new set<id>();
            List<ASI_MFM_PO_Line_Item__c> poLineList = [select ID,ASI_MFM_PO__r.ASI_MFM_Is_FOC_PO__c,ASI_MFM_Paid_Amount_in_PO_Currency__c,ASI_MFM_G_L_Date__c,ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c, ASI_MFM_PO__r.ASI_MFM_T_E_Amount__c,
                                                        ASI_MFM_Requested_Balance__c, name, ASI_MFM_PO__c, ASI_MFM_Customer_Name__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_Amount__c 
                                                        from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c = :poIDs and ASI_MFM_Remaining_Balance__c > 0 AND ASI_MFM_Complete__C = false];
            String Description;
            
            /*[WL 4.0] BEGIN*/
            Map<Id,Decimal> poTnEAmountMap = new Map<Id,Decimal>();  
            
            for (ASI_MFM_PO_Line_Item__c poL : poLineList){
                if (poTnEAmountMap.get(poL.ASI_MFM_PO__c) == null){
                    poTnEAmountMap.put(poL.ASI_MFM_PO__c, poL.ASI_MFM_PO__r.ASI_MFM_T_E_Amount__c);
                }
            }
            /*[WL 4.0] END*/
            
            for (ASI_MFM_PO_Line_Item__c poL : poLineList){
                if (poL.ASI_MFM_POSM_Deposit__c == true && poL.ASI_MFM_POSM_Balance__c == false){
                    errorpo.add(poL.ASI_MFM_PO__c);
                }
                else{
                    if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG')){
                        decimal adjustmentamount = poL.ASI_MFM_Remaining_Balance__c;
                        
                        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG')){
                            adjustmentamount = poL.ASI_MFM_Amount__c-poL.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                            
                            /*[WL 4.0] BEGIN*/
                            system.debug('PO Line: ' + poL.Name + ' Remaining T&E Deduct Balance: ' + poTnEAmountMap.get(poL.ASI_MFM_PO__c) + ' This PO Line Balance: ' + adjustmentamount);
                            if (poTnEAmountMap.get(poL.ASI_MFM_PO__c) > 0){
                                Decimal remainingTnEBalance = poTnEAmountMap.get(poL.ASI_MFM_PO__c);
                                
                                if (adjustmentamount >= remainingTnEBalance){  //PO Line Balance more than T&E Amount
                                    adjustmentamount = adjustmentamount - remainingTnEBalance;
                                    poTnEAmountMap.put(poL.ASI_MFM_PO__c, 0);
                                }
                                else {  //PO Line Balance less than T&E Amount, partially reduct the amount and leave the T&E Amount to be reduced in other PO Line
                                    poTnEAmountMap.put(poL.ASI_MFM_PO__c, remainingTnEBalance - adjustmentamount);
                                    adjustmentamount = 0;
                                }
                            }
                            /*[WL 4.0] END*/
                        }
                        
                        Description = 'Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + (poL.ASI_MFM_Amount__c - poL.ASI_MFM_Requested_Balance__c) + '; Remaining Amount: ' + poL.ASI_MFM_Requested_Balance__c;
                        
                        if(!poL.ASI_MFM_PO__r.ASI_MFM_Is_FOC_PO__c && adjustmentamount!=0 && Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG')){ // 
                            ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-adjustmentamount, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid,ASI_MFM_G_L_Date__c = poL.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
                            
                            
                            newPOL.add(poline);
                        }
                        
                        ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                        
                        newPOL.add(CompletePoline);
                    }
                }
            }
            
            /*[WL 4.0] BEGIN*/
            for (ASI_MFM_PO__c po:trigger_new) {
                if (poTnEAmountMap.get(po.Id) > 0)
                    po.addError('PO Balance less than T&E Amount, cannot complete PO.');
            }
            /*[WL 4.0] END*/
            
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
    }
    
    public static void routineBeforeDelete(list<ASI_MFM_PO__c> trigger_old) {
        // Not allowed to delete if the PO has related payment line items       
        set<id> po_set = new set<id>();
        list<ASI_MFM_Payment_Line_Item__c> pi_list = new list<ASI_MFM_Payment_Line_Item__c>();
        
        for (ASI_MFM_PO__c p:trigger_old) {     
            
            if (p.ASI_MFM_Status__c == 'Final' || p.ASI_MFM_Status__c == 'Complete')
                p.addError('Not allowed to delete because the PO is in \'Final\' or \'Complete\' status');                
            po_set.add(p.id);
            
        }
        if(po_set != NULL)
            pi_list = [select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__r.ASI_MFM_Is_Direct_Payment__c != TRUE and ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c in :po_set order by ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c];
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
            if (pi_map.get(p.id) > 0) {
                p.addError('Not allowed to delete because it has related payment line items');
            }
        }
    }
    
    public static void routineBeforeInsert(list<ASI_MFM_PO__c> trigger_new) {
        // Set the PO number for new PO                     
        set<id> px_set = new set<id>();
        List<ASI_MFM_PO_Date_Range__c> pr = new List<ASI_MFM_PO_Date_Range__c>();
        Set<id> PlanIds = new set<id>();
        Map<id, string> po_map = new map<id, string>();
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
            
            
        }  
        
        //Updated by Introv 20170731 added prefix to include "Accrual PO" type //20180620 Introv remove ASI_MFM_Parent_Prefix_Multi__c
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name,ASI_MFM_Company__c, /*ASI_MFM_Parent_Prefix_Multi__c,*/ asi_mfm_next_number__c,RecordType.DeveloperName, ASI_MFM_Default_BU__c,ASI_MFM_Default_Customer__c, ASI_MFM_TW_Delivery_Address__c from asi_mfm_prefix__c where ( asi_mfm_module__c = 'PO' or asi_mfm_module__c = 'Direct PO' or asi_mfm_module__c='Accrual PO')and id in :px_set for update]);
        
        for (ASI_MFM_PO__c p:trigger_new) {
            
            
            
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                
                // Tony Ren (elufa) 25 Fer 2015
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SG_PO')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                    }
                    p.ASI_MFM_BU_Code__c = px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Default_BU__c;
                    P.ASI_MFM_SG_Customer__c=px_map.get(p.asi_mfm_prefix__c).ASI_MFM_Default_Customer__c;
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
        boolean isJP = false;
        boolean isTRLogic = false;
        
        id overrideRouteTypeId =  null;
        Set<id> poIDSet = new Set<id>();
        Map<id,ASI_MFM_PO__c> gfPOMap = new Map<id,ASI_MFM_PO__c>();
        
        for (ASI_MFM_PO__c p:trigger_new) {
            if(p.ASI_MFM_Status__c == 'Complete' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Final' && p.ASI_MFM_Is_FOC_PO__c  ){
                p.ASI_MFM_Opening_Balance__c=p.ASI_MFM_PO_Amount__c-p.ASI_MFM_Paid_Amount_in_PO_Currency__c;
            }                        
            
            if (p.ASI_MFM_PO_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                pid_set.add(p.id);
                px_set.add(p.ASI_MFM_Prefix__c);                                
                
                p.ASI_MFM_Sys_Approver_1__c = null;
                p.ASI_MFM_Sys_Approver_2__c = null;
                p.ASI_MFM_Sys_Approver_3__c = null;
                p.ASI_MFM_Sys_Approver_4__c = null;
                p.ASI_MFM_Sys_Approver_5__c = null;
                p.ASI_MFM_Sys_Approver_6__c = null;
                p.ASI_MFM_Sys_Approver_7__c = null;
                p.ASI_MFM_Sys_Approver_8__c = null;
                p.ASI_MFM_Sys_Approver_9__c = null;
                p.ASI_MFM_Sys_Approver_10__c = null;
            }
            
        }       
        
        if (!poIDSet.isEmpty()){           
            for (ASI_MFM_PO_Receipt_Item__c receiptLine:[select ASI_MFM_PO_Receipt__r.Name, ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c, ASI_MFM_PO__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO__c = :poIDSet]){
                if (receiptLine.ASI_MFM_PO_Receipt__r.ASI_MFM_Status__c != 'Final'){
                    gfPOMap.get(receiptLine.ASI_MFM_PO__c).addError('Cannot complete PO, Receipt ' + receiptLine.ASI_MFM_PO_Receipt__r.Name + ' is not final yet');
                }
            }           
            
            List<ASI_MFM_Payment_Line_Item__c> paymentLineList = new List<ASI_MFM_Payment_Line_Item__c>([select ASI_MFM_Payment__r.ASI_MFM_Status__c, ASI_MFM_Payment__r.Name, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :poIDSet]);
            
            System.debug('Payment Line Query by PO ID: ' + paymentLineList);
            
            for (ASI_MFM_Payment_Line_Item__c paymentLine:paymentLineList){
                System.debug('PO Complete Validation, Payment Status: ' + paymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c);
                if (paymentLine.ASI_MFM_Payment__r.ASI_MFM_Status__c != 'Final'){
                    gfPOMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c).addError('Cannot complete PO, Payment ' + paymentLine.ASI_MFM_Payment__r.Name + ' is not approved yet');
                }
            }
            
        }
        
        if (pid_set.size() > 0) {       
            System.debug('Start assign approver');
            map<id, id> sb_map = new map<id, id>();
            Map<id, Set<id>> brandManagerMap = new Map<id, Set<id>>();//20180409 Introv
            Boolean includedPOS=false;
            
            for (ASI_MFM_PO_Line_Item__c pi:[select ASI_MFM_PO__c, ASI_MFM_Sub_brand_Code__c, ASI_MFM_Sub_brand_Code__r.OwnerId, ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.OwnerId,ASI_MFM_SKU__c,ASI_MFM_SKU__r.ASI_HK_CRM_IsPOSProduct__c from ASI_MFM_PO_Line_Item__c 
                                             where ASI_MFM_PO__c in :pid_set order by name desc]) {
                                                 
                                                 //20180409 Introv
                                                 Set<id> tmpBrandManagerSet = new Set<Id>();
                                                 
                                                 if(brandManagerMap.containsKey(pi.ASI_MFM_PO__c)){
                                                     tmpBrandManagerSet = brandManagerMap.get(pi.ASI_MFM_PO__c);
                                                 }
                                                 if(pi.ASI_MFM_SKU__c==null || !pi.ASI_MFM_SKU__r.ASI_HK_CRM_IsPOSProduct__c)
                                                    tmpBrandManagerSet.add(pi.ASI_MFM_Sub_brand_Code__r.OwnerId);
                                                    
                                                 if(pi.ASI_MFM_SKU__c!=null && pi.ASI_MFM_SKU__r.ASI_HK_CRM_IsPOSProduct__c)
                                                    includedPOS = TRUE;                                          
                                                 
                                                 brandManagerMap.put(pi.ASI_MFM_PO__c, tmpBrandManagerSet);
                                                 //20180409 End
                                                 
                                                 sb_map.put(pi.ASI_MFM_PO__c, pi.ASI_MFM_Sub_brand_Code__c);
                                             }
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
            
            
            brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c 
                        where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Sub_brand__c = null or ASI_MFM_Sub_brand__c in :sb_map.values()) 
                        order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc];
            
            System.debug('brm_list: ' + brm_list);
            set<id> rt_set = new set<id>();    
            
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                rt_set.add(brm.ASI_MFM_Route_Type__c);
            }      
            
            map<id, ASI_MFM_Sub_brand__c> sbList_map;
            
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c from ASI_MFM_Route_Rule_Detail__c 
                                                            where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c];
            
            
            for (ASI_MFM_PO__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    Boolean isAssignBrdMng = false;
                    
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        if(brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_brand__c == null){
                            rtid = brm.ASI_MFM_Route_Type__c;
                            System.debug('rtid_null: ' + rtid);
                        }else if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_brand__c == sbid ) {                            
                            rtid = brm.ASI_MFM_Route_Type__c;
                            System.debug('rtid_sub_brand: ' + rtid);
                            
                            break;
                        }
                        else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                            System.debug('rtid_break: ' + rtid);
                            break;
                        }                       
                    }
                    List<id> approverL=new List<id>();
                    if (rtid != null) {
                        System.debug('rtid: ' + rtid);
                        boolean validSubBrand = true;
                        
                        if (validSubBrand){
                            decimal local_amount = p.ASI_MFM_PO_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                            System.debug('Local Amount: ' + local_amount);
                            System.debug('Route Type ID: ' + rtid + ' Route Rule List: ' + rule_list);
                            p.ASI_MFM_Route_Type__c = rtid;
                            
                            Id managerid=null;
                            if (includedPOS && p.ASI_MFM_Department__c.contains('SG Brand Marketing') ){
                                managerid=([Select managerid from user where id =:p.ownerid][0]).managerid;
                                
                                if(managerid!=null){
                                    p.put('ASI_MFM_Sys_Approver_' + (approver_count + 1) + '__c', managerid);
                                    approver_count++;
                                    approverL.add(managerid);
                                }
                            }
                            
                            //20180409 Introv
                            /*[WL 2.0] BEGIN*/
                            //if(brandManagerMap.containsKey(p.id)){
                            /*[WL 3.0] BEGIN*/
                            //if(brandManagerMap.containsKey(p.id) && p.ASI_MFM_Department__c != null && p.ASI_MFM_Department__c.contains('SG Brand Marketing')){
                            if(brandManagerMap.containsKey(p.id) && p.ASI_MFM_Department__c != null && p.ASI_MFM_Department__c.contains('SG Brand Marketing')
                               && p.ASI_MFM_PO_Fiscal_Year__c >= 'FY1819'){
                                   /*[WL 3.0] END*/
                                   /*[WL 2.0] END*/                                
                                   for(Id brandManager : brandManagerMap.get(p.id)){
                                        if (approverL.contains(brandManager))
                                            continue;

                                        if(p.ownerid==brandManager){
                                            approverL.add(p.ownerid);
                                            brandManager=([Select managerid from user where id =:p.ownerid][0]).managerid;
                                        }
                                            
                                        
                                       if (approver_count == 0) {
                                           p.ASI_MFM_Sys_Approver_1__c = brandManager;
                                       }
                                       else if (approver_count == 1) {                                 
                                           p.ASI_MFM_Sys_Approver_2__c = brandManager;
                                       }
                                       else if (approver_count == 2) {                                 
                                           p.ASI_MFM_Sys_Approver_3__c = brandManager;
                                       }
                                       else if (approver_count == 3) {
                                           p.ASI_MFM_Sys_Approver_4__c = brandManager;
                                       }
                                       else if (approver_count == 4) {                                 
                                           p.ASI_MFM_Sys_Approver_5__c = brandManager;
                                       }
                                       else if (approver_count == 5) {                                 
                                           p.ASI_MFM_Sys_Approver_6__c = brandManager;
                                       }
                                       else if (approver_count == 6) {                                 
                                           p.ASI_MFM_Sys_Approver_7__c = brandManager;
                                       }
                                       else if (approver_count == 7) {                                 
                                           p.ASI_MFM_Sys_Approver_8__c = brandManager;
                                       }
                                       else if (approver_count == 8) {                                 
                                           p.ASI_MFM_Sys_Approver_9__c = brandManager;
                                       }
                                       else if (approver_count == 9) {                                 
                                           p.ASI_MFM_Sys_Approver_10__c = brandManager;
                                       }
                                       approver_count++;
                                       approverL.add(brandManager);
                                   }
                                   isAssignBrdMng = true;
                               }
                            //20180409 End
                            
                            
                            
                            for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                                if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount
                                    && (    (brandManagerMap.containsKey(p.id) && !brandManagerMap.get(p.id).contains(rd.ASI_MFM_Approver__c)) 
                                        || !brandManagerMap.containsKey(p.id) || isAssignBrdMng == false)){//20180409 Introv added new condition to skip duplicated approver
                                            if (approverL.contains(rd.ASI_MFM_Approver__c))
                                                continue;
                                        
                                            if (approver_count == 0) {
                                                p.ASI_MFM_Sys_Approver_1__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 1) {                                 
                                                p.ASI_MFM_Sys_Approver_2__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 2) {                                 
                                                p.ASI_MFM_Sys_Approver_3__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 3) {                                 
                                                p.ASI_MFM_Sys_Approver_4__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 4) {                                 
                                                p.ASI_MFM_Sys_Approver_5__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 5) {                                 
                                                p.ASI_MFM_Sys_Approver_6__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 6) {                                 
                                                p.ASI_MFM_Sys_Approver_7__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 7) {                                 
                                                p.ASI_MFM_Sys_Approver_8__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 8) {                                 
                                                p.ASI_MFM_Sys_Approver_9__c = rd.ASI_MFM_Approver__c;
                                            }
                                            else if (approver_count == 9) {                                 
                                                p.ASI_MFM_Sys_Approver_10__c = rd.ASI_MFM_Approver__c;
                                            }
                                            approver_count++;      

                                            approverL.add(rd.ASI_MFM_Approver__c);
                                        }
                                
                                else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                    break;
                                }
                            }
                            
                        }
                    } 
                    else {
                        System.debug('No rt id' );
                        //If the Responsible by is changed, need check the line item.
                        if ((trigger_oldMap == null || p.ASI_MFM_Responsible_By__c != trigger_oldMap.get(p.id).ASI_MFM_Responsible_By__c) && isJP && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_ValidateSubBrandCode')){
                            p.ASI_MFM_Responsible_By__c.adderror('The responsible by has no route type set up');
                        }
                        if ((trigger_oldMap == null || p.ASI_MFM_Responsible_By__c != trigger_oldMap.get(p.id).ASI_MFM_Responsible_By__c || rtid == null) && isTRLogic && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')){
                            p.adderror('The responsible by has no route type set up');
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
        System.debug('routineBeforeUpsert');
        //20140410 Steve Wan Default BU for JP
        Map<string, id> MRecType = new map<string, id>();
        List<recordType> rtList = Global_RecordTypeCache.getRtList('ASI_MFM_PO__c');
        for (recordType rtt:rtList) {
            MRecType.put(rtt.DeveloperName, rtt.id);            
        }        
        
        boolean SGChangeCurrency =false;
        
        
        //20171024 Introv added to retrieve Original PO Status
        
        Set<Id> originalPOSet = new Set<Id>();
        Set<Id> POIdSet = new Set<Id>();
        //20171024 End
        
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_SG')){
            SGChangeCurrency=ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_SG_ChangeLAMMCurrency','SG');
        }
        
        
        
        for (ASI_MFM_PO__c po:trigger_new) {
            
            // Check if there was an input in the decimal number output error
            boolean isDecimal = (ASI_MFM_Function.containsDecimalValue(po.ASI_MFM_PO_Original_Amount__c) || ASI_MFM_Function.containsDecimalValue(po.ASI_MFM_PO_Amount__c)) && po.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                po.addError(' You Cannot input a decimal number for a TWD currency.');
            System.debug('ASI_MFM_Exchange_Rate__c '+po.ASI_MFM_Exchange_Rate__c);
            if (po.ASI_MFM_Exchange_Rate__c == null) {
                po_set.add(po.id);
                ccy_set.add(po.ASI_MFM_Currency__c);
                if (last_effective_date == null || po.ASI_MFM_PO_Raised_Date__c > last_effective_date) {
                    last_effective_date = po.ASI_MFM_PO_Raised_Date__c;
                }
            }
            
        }
        
        if (po_set.size() > 0){
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            if (country == 'SG'){
                //set Responsible By as owner
                if(trigger_new[0].ASI_MFM_Responsible_By__c==null){
                    trigger_new[0].ASI_MFM_Responsible_By__c=trigger_new[0].OwnerId;
                }
                
                if(SGChangeCurrency){
                    if( trigger_new[0].ASI_MFM_Market__c == 'Singapore'){
                        trigger_new[0].ASI_MFM_Sys_Local_Currency__c = 'SGD';
                    }
                    else{
                        trigger_new[0].ASI_MFM_Sys_Local_Currency__c = 'USD';
                    }
                    
                }else{//New Logic
                    trigger_new[0].ASI_MFM_Sys_Local_Currency__c = 'SGD';
                }
                
            }
            
            
            System.debug('ex_rate');
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;         
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                                                      where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                                                      order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            
            
            System.debug(country+'/'+base_ccy+'/'+ccy_set+'/'+last_effective_date);
            System.debug(xr_list);
            for (ASI_MFM_PO__c po:trigger_new) {
                if (po_set.contains(po.id) ) {
                    if (po.ASI_MFM_Currency__c == po.ASI_MFM_Sys_Local_Currency__c) {
                        po.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        if (po.ASI_MFM_Currency__c != null && po.ASI_MFM_PO_Raised_Date__c != null ) {                                                                           
                            for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                                if (xr.ASI_MFM_Counter_Currency__c == po.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= po.ASI_MFM_PO_Raised_Date__c && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_TR_ByPassTrigger')) {
                                    po.ASI_MFM_Exchange_Rate__c = xr.ASI_MFM_Exchange_Rate__c;
                                    break;
                                }
                                else if (xr.ASI_MFM_Counter_Currency__c > po.ASI_MFM_Currency__c) {
                                    break;
                                }
                            }
                            if(po.ASI_MFM_Exchange_Rate__c==null && Global_RecordTypeCache.getRt(po.recordTypeId).developerName.contains('ASI_MFM_SG_PO')){
                                po.ASI_MFM_Exchange_Rate__c.addError('Cannot found Exchange Rate from DataBase, Please input.');
                            }
                        }
                    }               
                }
            }                       
        }
        
        
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
        if (PO_list.size() > 0 ) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            //Updated by Introv 20170731 to include Prefix's ASI_MFM_Module__c ='Accrual PO':
            system.debug('prefix_set:' + prefix_set);
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