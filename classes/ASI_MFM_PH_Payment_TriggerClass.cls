/***************************************************************************************************************************
 * Name:        ASI_MFM_PH_Payment_TriggerClass
 * Test CLass : ASI_MFM_PH_Payment_TestClass
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-07-25       Wilken Lee              [WL 1.0] CHG0030610 Enhance Payment approval based on user's ASI MFM Department setup on user object
 * 2020-07-20       PRA                     Remove prefix 5 digital limitation
 ****************************************************************************************************************************/
public with sharing  class ASI_MFM_PH_Payment_TriggerClass {
    public static void routineBeforeInsert(list<ASI_MFM_Payment__c> trigger_new) {
        set<id> px_set = new set<id>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
        }
        
        // Set the Payment ID for new Payment               
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c,ASI_MFM_Company__c from asi_mfm_prefix__c 
            where asi_mfm_module__c = 'Payment' and id in :px_set for update]);
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                if ( Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH')){
                    //if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                        px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                    //}
                }
                
            }
        }
        ASI_MFM_Function.updatePrefix(px_map.values());           
    }

    //For MFM PH Use Only
    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        System.debug('Start Payment routineAfterUpdate');
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_PH')){
            Set<ID> paymentIDs = new Set<ID>();
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted'){
                    paymentIDs.add(pay.id);
                }
            }
            ID Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('PH PO Line Item').getRecordTypeId();
            List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_Payment_Line_Item__c> payLineList = [select id,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDs and ASI_MFM_Complete_POL__c = true  AND ASI_MFM_PO_Line_Item__r.ASI_MFM_Complete__C=false];//AND ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c > 0
            String Description;
            for (ASI_MFM_Payment_Line_Item__c payL : payLineList){
                if(payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c!=0){
                    decimal Remaining = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c - payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c;
                    Description='Closing PO Adjustment: '+payL.ASI_MFM_PO_Line_Item__r.name+'- Paid Amount: '+payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c+'; Remaining Amount: '+ Remaining;
                    ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-Remaining , ASI_MFM_PO__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid, ASI_MFM_G_L_Date__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c,ASI_MFM_Adjustment_Line__c = true);
                    newPOL.add(pol);
                }
                ASI_MFM_PO_Line_Item__c CompletePol = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__c = true, ID = payL.ASI_MFM_PO_Line_Item__c);
                
                newPOL.add(CompletePol);
            }
            upsert newPOL;
            
            // Added by 2018-01-17 Linus@introv
            // update Payment line if Exchange rate is changed
            paymentIDs.clear();
            payLineList.clear();
            for(ASI_MFM_Payment__c pay: trigger_new){
                paymentIDs.add(pay.id);
            }
            payLineList = [Select id, ASI_MFM_Payment_Amount__c, ASI_MFM_Paid_Amount_in_PO_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDs];
            for(ASI_MFM_Payment_Line_Item__c pl : payLineList){
                pl.ASI_MFM_Paid_Amount_in_PO_Currency__c = pl.ASI_MFM_Payment_Amount__c * pl.ASI_MFM_Exchange_Rate__c;
            }
            
            if(!Test.isRunningtest())
                update payLineList;
            // END - Linus@introv
        }
    }
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpdate');
        
        map<id, ASI_MFM_Payment__c> reject_map = new map<id, ASI_MFM_Payment__c>();
                
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
            }
            
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_PH')){
                Date selectedDate;
                Date StartDate;
                Date EndDate;
                if(p.ASI_MFM_Status__c == 'Final' && (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') ){
                    for (ASI_MFM_GL_Date_Setting__c Setting : ASI_MFM_GL_Date_Setting__c.getAll().values()) {
                        if(Setting.ASI_MFM_Country__c=='PH'){
                            if(Setting.ASI_MFM_Month__c==1){
                                if(Setting.ASI_MFM_Start_Date__c.month()==12){ //Set Cut off G/L Date
                                    StartDate=date.newInstance(Date.today().year()-1,Setting.ASI_MFM_Start_Date__c.month(),Setting.ASI_MFM_Start_Date__c.day());
                                }else
                                {
                                    StartDate=date.newInstance(Date.today().year(),Setting.ASI_MFM_Start_Date__c.month(),Setting.ASI_MFM_Start_Date__c.day());
                                }
                                
                            }else{
                                StartDate=date.newInstance(Date.today().year(),Setting.ASI_MFM_Start_Date__c.month(),Setting.ASI_MFM_Start_Date__c.day());
                            }
                            EndDate=date.newInstance(Date.today().year(),Setting.ASI_MFM_End_Date__c.month(),Setting.ASI_MFM_End_Date__c.day());
                            if(StartDate<=Date.today() && EndDate>=Date.today()){
                                selectedDate=date.newInstance(Date.today().year(),Setting.ASI_MFM_G_L_Date__c.month(),Setting.ASI_MFM_G_L_Date__c.day());
                            }
                        }
                    }
                    if(selectedDate==null){
                        selectedDate=Date.today();
                    }
                    p.ASI_MFM_G_L_Date__c=selectedDate;
                }   
            }   
                        
            
        }                
        
        if (reject_map.size() > 0) {
            list<ASI_MFM_Payment__c> reject_list = [select (select Comments from ProcessSteps order by createdDate desc limit 1) from ASI_MFM_Payment__c where id in :reject_map.keySet()];
            for (ASI_MFM_Payment__c r:reject_list) {
                if (r.processSteps.size() > 0 && reject_map.containsKey(r.id)) {
                    System.debug('Rejected Payment ProcessSteps: ' + r.processSteps + ' ProcessStep0: ' + r.processSteps[0]);
                    reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
    }
        
    public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {        
// Recalculate VAT amount, WT amount and insurance amount for Taiwan
        decimal percent;
        for (ASI_MFM_Payment__c pay:trigger_new) {     
            if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_PH')){
                
                if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_PH_DP')){
                    if(pay.ASI_MFM_Tax_Area__c=='12%'){// PHVAT and V
                        pay.ASI_MFM_VAT_Amount__c=12;
                        pay.ASI_MFM_JDE_Tax_Area__c='PHVAT and V';
                    }
                    if(pay.ASI_MFM_Tax_Area__c=='0%'){ //PHVAT and E
                        pay.ASI_MFM_VAT_Amount__c=0;
                        pay.ASI_MFM_JDE_Tax_Area__c='PHVAT and E';
                        
                    }
                }
            }    
        }

// Retrieve exchange rate for new payment or when the currency or payment date is changed
        set<id> pay_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
        for (ASI_MFM_Payment__c pay:trigger_new) {
            if (pay.ASI_MFM_Exchange_Rate__c == null || (trigger_oldMap != null && (pay.ASI_MFM_Currency__c != trigger_oldMap.get(pay.id).ASI_MFM_Currency__c || pay.ASI_MFM_Payment_Date__c != trigger_oldMap.get(pay.id).ASI_MFM_Payment_Date__c))) {
                pay_set.add(pay.id);
                ccy_set.add(pay.ASI_MFM_Currency__c);
                if (last_effective_date == null || pay.ASI_MFM_Payment_Date__c > last_effective_date) {
                    last_effective_date = pay.ASI_MFM_Payment_Date__c;
                }
            }
        }

        if (pay_set.size() > 0) {
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_PH_DP') == true ? 'PH': 'SG';            
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;
            
            /*            
            if (country == 'PH'){
                country = 'PH';
                base_ccy = 'PHP';
                trigger_new[0].ASI_MFM_Sys_Local_Currency__c = 'PHP';
            }
            */
            
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            system.debug('a1:'+country +'/'+base_ccy + '/'+ last_effective_date);
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay_set.contains(pay.id)) {
                    system.debug(pay.ASI_MFM_Sys_Local_Currency__c);
                    if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                        pay.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                         if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_PH') ){
                            pay.ASI_MFM_Exchange_Rate__c = null;    
                            if (pay.ASI_MFM_Currency__c != null && pay.ASI_MFM_Payment_Date__c != null ) {                                                                           
                                for (ASI_MFM_Exchange_Rate__c xr:xr_list) {
                                    if (xr.ASI_MFM_Counter_Currency__c == pay.ASI_MFM_Currency__c && xr.ASI_MFM_Effective_Date__c <= pay.ASI_MFM_Payment_Date__c) {
                                        pay.ASI_MFM_Exchange_Rate__c = xr.ASI_MFM_Exchange_Rate__c;
                                        break;
                                    }
                                    else if (xr.ASI_MFM_Counter_Currency__c > pay.ASI_MFM_Currency__c) {
                                        break;
                                    }
                                }
                            }
                        }
                    }               
                }
            }                       
        }
        
// Set the approvers for the payment based on the routing rule objects          
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
      
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Payment_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                pid_set.add(p.id);
                px_set.add(p.ASI_MFM_Prefix__c);
                setApproverToNull(p);
            }
        }
            
        if (pid_set.size() > 0) {       
            map<id, id> sb_map = new map<id, id>(); 
            
            for (ASI_MFM_Payment_Line_Item__c pi:[select ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c from ASI_MFM_Payment_Line_Item__c 
                where ASI_MFM_Payment__c in :pid_set order by name desc]) {
                sb_map.put(pi.ASI_MFM_Payment__c, pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c);
            }
            
            list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Sub_brand__c from ASI_MFM_Brand_Route_Type_Map__c 
                where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and (ASI_MFM_Sub_brand__c = null or ASI_MFM_Sub_brand__c in :sb_map.values()) 
                order by ASI_MFM_Prefix__c, ASI_MFM_Sub_brand__c desc]; 
            set<id> rt_set = new set<id>();     
            
            for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                rt_set.add(brm.ASI_MFM_Route_Type__c);
            }           
            
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c,ASI_MFM_Sequence__c from ASI_MFM_Route_Rule_Detail__c 
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c, ASI_MFM_Minimum_Amount__c];

            for (ASI_MFM_Payment__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_brand__c == null) {
                            rtid = brm.ASI_MFM_Route_Type__c;  
                        }else if(brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_Brand__c == sbid){
                            rtid = brm.ASI_MFM_Route_Type__c;  
                            break;
                        }
                        else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                            break;
                        }                         
                    }
                    if (rtid != null) {
                        decimal local_amount = p.ASI_MFM_Payment_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                        for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                            if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount) {
                                if (rd.ASI_MFM_Region__c == null || (rd.ASI_MFM_Region__c != null && rd.ASI_MFM_Region__c == p.ASI_MFM_User_MFM_Department__c)){    //WL 1.0
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
                                }//WL 1.0
                            }
                            else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                break;
                            }
                        }
                    }               
                }               
            }               
        }
            
// The prefix must be for Payment
// The prefix must be valid for the owner
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
        
        if (Payment_list.size() > 0  && !Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_KR') ) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'Payment']);
            
            for (ASI_MFM_Payment__c p:Payment_list) {
                system.debug('prefix_map: ' + prefix_map + ' payment prefix: ' + p.ASI_MFM_Prefix__c);
                
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)) {
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for Payment');
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
                    if (!valid_prefix) {
                        p.ASI_MFM_Prefix__c.addError('The prefix is not valid for the owner');                  
                    }
                }
            }
        }                
    } 
    
    public static void setApproverToNull(ASI_MFM_Payment__c p){   
        p.ASI_MFM_Sys_Approver_1__c = null;
        p.ASI_MFM_Sys_Approver_2__c = null;
        p.ASI_MFM_Sys_Approver_3__c = null;
        p.ASI_MFM_Sys_Approver_4__c = null;
        p.ASI_MFM_Sys_Approver_5__c = null;
        p.ASI_MFM_Sys_Approver_6__c = null;
        p.ASI_MFM_Sys_Approver_7__c = null;
        p.ASI_MFM_Sys_Approver_8__c = null;
        p.ASI_MFM_Sys_Approver_9__c = null;
        p.ASI_MFM_CN_Finance__c = null;    
        p.ASI_MFM_CN_Return_Approver_1__c = null;
        p.ASI_MFM_CN_Return_Approver_2__c = null;
        p.ASI_MFM_CN_Return_Approver_3__c = null; 
    }    
}