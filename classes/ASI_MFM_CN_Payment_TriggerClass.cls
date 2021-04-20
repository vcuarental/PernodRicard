/* Filename:    ASI_MFM_CN_Payment_TriggerClass.cls
 * Author:      Michael Yip (Introv Limited)
 * Purpose:     Handle CN Payment Line Item Trigger Logic
 *
 *
 * History
 * -----------------------------------------------------------------------------
 * 2012-06-04   michael.yip@introv.com      Create
 * 2015-01-09   twinkle.li@introv.com       #Update Dynamic Approval Route
 * 
 */
public with sharing class ASI_MFM_CN_Payment_TriggerClass {
    private static List<ASI_MFM_Dynamic_Approval_Route__c> approvalRouteList = [Select ASI_MFM_Approval_Limit__c, ASI_MFM_End_of_1st_Route__c, ASI_MFM_Manager_ID__c, ASI_MFM_Type__c, ASI_MFM_User__c from ASI_MFM_Dynamic_Approval_Route__c where ASI_MFM_Type__c = 'Payment'];
    private static List<User> LUser = [Select id, ManagerID from User Where CompanyName = 'Pernod Ricard China'];
    private static List<ASI_MFM_Tax_Code__c> LTaxCode = [Select id, Name from ASI_MFM_Tax_Code__c];
    
    public static void routineBeforerDelete(list<ASI_MFM_Payment__c> trigger_old) {
        for (ASI_MFM_Payment__c pa : trigger_old)
        {
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete')
                 pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
        }
    }

    public static void routineAfterDelete(list<ASI_MFM_Payment__c> trigger_old) {
        /* Not applicable to CN MFM
        // Delete Payment in Data Warehouse
        if (!ASI_MFM_Function.bypassCallouts()) {
            list<id> pid_list = new list<id>();
            for (ASI_MFM_Payment__c p:trigger_old) {
                pid_list.add(p.id);
            }
            if (!(test.isRunningTest() && limits.getFutureCalls() >= limits.getLimitFutureCalls())) {           
                ASI_MFM_Callout.deletePayment(pid_list);
            }
        } 
        */          
    }

    public static void routineAfterUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        /* Not applicable to CN MFM
        // Pass Payment and line item details to Data Warehouse
        if (!ASI_MFM_Function.bypassCallouts()) {       
            set<id> pid_set = new set<id>();
            for (ASI_MFM_Payment__c p:trigger_new) {
                if (trigger_oldMap == null || p.ASI_MFM_Sys_Sync_Time__c == trigger_oldMap.get(p.id).ASI_MFM_Sys_Sync_Time__c) {
                    pid_set.add(p.id);
                }               
            }
            if (pid_set.size() > 0 && !system.isFuture()) {
                if (!(test.isRunningTest() && limits.getFutureCalls() >= limits.getLimitFutureCalls())) {               
                    ASI_MFM_Callout.updatePayment(pid_set);
                }
            }   
        }  
        */
        
        //20161118 Elufa
        ASI_MFM_CN_Payment_TriggerHelperClass.teamMemberSharing(trigger_new);
    }

    public static void routineBeforeInsert(list<ASI_MFM_Payment__c> trigger_new) {
        /** added by leo - 2014/06/16 **/
        // Set the Tax Code lookup from "Tax Code" picklist
        SetTaxCodeLookupValue(trigger_new);
    
        set<id> px_set = new set<id>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
        }
        
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
        
           
        //For fixing issue#115, last modified by eric tsang @ 20141214
        set <id> temp_change_paymentline = new set<id>();

        for (ASI_MFM_Payment__c p2:trigger_new) {
            if (p2.ASI_MFM_VAT_Rate__c != trigger_oldMap.get(p2.id).ASI_MFM_VAT_Rate__c){
                temp_change_paymentline.add(p2.id);
                
            }          
        }
        list <ASI_MFM_Payment_Line_Item__c> lstPayment = [select id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c in:temp_change_paymentline]; 
        
        if (lstpayment.size()>0){
        update lstPayment;
        } 
    }
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpdate');

        // 20210118 :jack_yuan - Assign current approval user
        setCurrentApprover(trigger_new, trigger_oldMap);
        /** added by leo - 2014/06/16 **/
        // Set the Tax Code lookup from "Tax Code" picklist
        SetTaxCodeLookupValue(trigger_new);
        
        // Stop Any users from setting status Complete to final
        User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
        boolean isuserAdmin = prof.profile.name.contains('System Administrator') || prof.UserRole.developername == 'ASI_MFM_TW_System_Administrator';
// Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Payment__c> reject_map = new map<id, ASI_MFM_Payment__c>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Status__c != trigger_oldMap.get(p.id).ASI_MFM_Status__c && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Complete' && !isuserAdmin)
                p.addError('Cannot change a Complete Payment status to Final or Draft. Please contact the System Administrator.');
            if (p.ASI_MFM_Status__c == 'Draft' && 
                (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') || (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Pending For Finance')
               ) {
                reject_map.put(p.id, p);
            }
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
        
        //20191108:AM@introv - change status to "Pending For Finance"
        setStatusToPendingForFinance(trigger_new);
    }


    // 20210118 :jack_yuan - Assign current approval user
    public static void setCurrentApprover(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {

        Map<Id, Id> pmtUserIdMap = new Map<Id, Id>();
        for (ASI_MFM_Payment__c pmt : trigger_new) {
            if (pmt.ASI_MFM_CN_Next_Approver_ID__c != null && pmt.ASI_MFM_CN_Next_Approver_ID__c != trigger_oldMap.get(pmt.Id).ASI_MFM_CN_Next_Approver_ID__c) {
                pmtUserIdMap.put(pmt.Id, pmt.ASI_MFM_CN_Next_Approver_ID__c);
            }
            if (pmt.ASI_MFM_CN_Next_Approver_ID__c == null && pmt.ASI_MFM_CN_Next_Approver_ID__c != trigger_oldMap.get(pmt.Id).ASI_MFM_CN_Next_Approver_ID__c) {
                pmt.ASI_MFM_CN_Current_Approver_Txt__c = null;
            }
        }
        if (!pmtUserIdMap.isEmpty()) {
            Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :pmtUserIdMap.values()]);
            for (ASI_MFM_Payment__c pmt : trigger_new) {
                if (usersMap.containsKey(pmt.ASI_MFM_CN_Next_Approver_ID__c)) {
                    pmt.ASI_MFM_CN_Current_Approver_Txt__c = usersMap.get(pmt.ASI_MFM_CN_Next_Approver_ID__c).Name;
                }
            }

        }
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        /** added by leo - 2014/06/16 **/
        // Set the Tax Code lookup from "Tax Code" picklist
        SetTaxCodeLookupValue(trigger_new);
        
    /*  Added by Michael Yip (Introv) 8Jan2014
            retreive recordtype by sojbect and filter out record by record type and filter out CN Payment
        */
        /*Map<string, id> MRecTypeID = ASI_MFM_Function.getRecordTypeId('ASI_MFM_Payment__c');
        
        for(String key : MRecTypeID.keySet()){
            if(key.contains('CN_Payment')){
                SCNRecTypeID.add(MRecTypeID.get(key));
            }
        } */
        Set<id> SCNRecTypeID = new Set<id>();
        for(RecordType rec : Global_RecordTypeCache.getRtList('ASI_MFM_Payment__c')){
            if(rec.DeveloperName.contains('CN_Payment')){
                SCNRecTypeID.add(rec.id);
            }
        }
        Set<id> SRecID = new Set<id>();
        Map<id, ASI_MFM_Payment__c> MRec = new Map<id,ASI_MFM_Payment__c>();
        for(ASI_MFM_Payment__c Rec : trigger_new){          
            if(SCNRecTypeID.contains(Rec.recordtypeid)){
                SRecID.add(Rec.id);
                MRec.put(Rec.id,Rec);
            }
        }

        // Retrieve exchange rate for new payment or when the currency or payment date is changed
        set<id> pay_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
        for (ASI_MFM_Payment__c pay:trigger_new) {
            if (pay.ASI_MFM_Exchange_Rate__c == null || (trigger_oldMap != null &&  
                (pay.ASI_MFM_Currency__c != trigger_oldMap.get(pay.id).ASI_MFM_Currency__c || pay.ASI_MFM_Payment_Date__c != trigger_oldMap.get(pay.id).ASI_MFM_Payment_Date__c))) {
                pay_set.add(pay.id);
                ccy_set.add(pay.ASI_MFM_Currency__c);
                if (last_effective_date == null || pay.ASI_MFM_Payment_Date__c > last_effective_date) {
                    last_effective_date = pay.ASI_MFM_Payment_Date__c;
                }
            }
        }

        if (pay_set.size() > 0) {
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay_set.contains(pay.id)) {
                    if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                        pay.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        pay.ASI_MFM_Exchange_Rate__c = null;    
                        if (pay.ASI_MFM_Currency__c != null && pay.ASI_MFM_Payment_Date__c != null) {                                                                           
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
        
        //Set the approvers for the payment based on the routing rule objects          
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        set<string> STeam = new set<string>();
        
        //Add by Michael Yip (Introv) 8Jan2014 add CN approver
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_CN')){
            for (ASI_MFM_Payment__c p:trigger_new) {
                if (p.ASI_MFM_Payment_Amount_RMB__c != null /*&& p.ASI_MFM_Exchange_Rate__c > 0*/) {//
                    pid_set.add(p.id);
                    px_set.add(p.ASI_MFM_Prefix__c);
                    STeam.add(p.asi_mfm_budget_owner_team__c);                                                                                         
                }
                
                if(p.ASI_MFM_CN_Payment_Original_Amount__c != null && (p.ASI_MFM_CN_Payment_Max_Approved_Amount__c == null || p.ASI_MFM_CN_Payment_Original_Amount__c > p.ASI_MFM_CN_Payment_Max_Approved_Amount__c)){
                    p.ASI_MFM_CN_Payment_Max_Approved_Amount__c = p.ASI_MFM_CN_Payment_Original_Amount__c;
                }
                
            }
            
            Map<id, ASI_MFM_Dynamic_Approval_Route__c> MAppRoute = new Map<id, ASI_MFM_Dynamic_Approval_Route__c>();
            Map<string, ASI_MFM_Fix_Approval_Route__c> MAppRouteFix = new Map<string, ASI_MFM_Fix_Approval_Route__c>();
            List<ASI_MFM_Dynamic_Approval_Route__c> LApp = approvalRouteList;
            
            for(ASI_MFM_Dynamic_Approval_Route__c a : LApp){
                MAppRoute.put(a.ASI_MFM_User__c, a);
            }
            System.debug(MAppRoute);
            List<ASI_MFM_Fix_Approval_Route__c> LFApp = [Select ASI_MFM_BA__c, ASI_MFM_Corporate_Approver_1__c, ASI_MFM_Corporate_Approver_2__c,
                                                         ASI_MFM_Corporate_Approver_3__c,ASI_MFM_Corporate_Approver_4__c,ASI_MFM_Finance__c, ASI_MFM_Module__c, ASI_MFM_Team__c,
                                                         ASI_MFM_Approval_Limit_BA__c, ASI_MFM_Approval_Limit_CA1__c, ASI_MFM_Approval_Limit_CA2__c, ASI_MFM_Approval_Limit_CA3__c,
                                                         ASI_MFM_Approval_Limit_CA4__c,ASI_MFM_Approval_Limit_Finance__c, ASI_MFM_Approval_Limit_BD__c//20160729 Ben @ Elufa added ASI_MFM_Approval_Limit_BD
                                                         from ASI_MFM_Fix_Approval_Route__c
                                                         where ASI_MFM_Module__c = 'Payment' and ASI_MFM_Team__c IN :STeam
                                                         AND RecordType.DeveloperName = 'ASI_MFM_CN_Fix_Approval_Route'//20160810 Ben @ Elufa
                                                        ];     
            for(ASI_MFM_Fix_Approval_Route__c a : LFApp){
                MAppRouteFix.put(a.ASI_MFM_Team__c, a);
            }
            System.debug(MAppRouteFix);
            
            //Updated by Twinkle 20150109 - Dynamic Route -> Managers
            
            //20161117 Elufa
            List<ASI_MFM_Payment_Line_Item__c> paymentLineITemList = new List<ASI_MFM_Payment_Line_Item__c>([SELECT Id, ASI_MFM_Payment__c, ASI_MFM_PO__c, ASI_MFM_PO__r.ASI_MFM_Plan__c, ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Project_Team__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand_Director__c FROM ASI_MFM_Payment_Line_Item__c WHERE ASI_MFM_Payment__c IN : trigger_new ORDER BY ASI_MFM_Payment__c DESC, LastModifiedDate DESC]);
            //ASI_MFM_CN_Payment_TriggerHelperClass.BudgetOwnerValidationCheck(paymentLineITemList, trigger_new);
            //20161117 End
            
            if (pid_set.size() > 0) {
                
                //20160729 Ben @ Elufa
                
                Map<Id, Id> mapBrandDirector = new Map<Id, Id>();
                for(ASI_MFM_Payment_Line_Item__c obj : paymentLineITemList){//[SELECT Id, ASI_MFM_Payment__c, ASI_MFM_Sub_brand__r.ASI_MFM_Brand_Director__c FROM ASI_MFM_Payment_Line_Item__c WHERE ASI_MFM_Payment__c IN : pid_set AND ASI_MFM_Sub_brand__c != NULL ORDER BY LastModifiedDate DESC]){//20161117 Elufa Commented
                    
                    if(pid_set.contains(obj.ASI_MFM_Payment__c) && obj.ASI_MFM_Sub_brand__c != Null){//20161117 Elufa
                        if(!mapBrandDirector.containsKey(obj.ASI_MFM_Payment__c) && obj.ASI_MFM_Sub_brand__r.ASI_MFM_Brand_Director__c != NULL){
                            mapBrandDirector.put(obj.ASI_MFM_Payment__c, obj.ASI_MFM_Sub_brand__r.ASI_MFM_Brand_Director__c);
                        }
                    }
                }
                
                //20160729 End
                
                Map<id, User> MUser = new Map<id, User>();
                for(User u : LUser){
                    MUser.put(u.id, u);
                }
                for(ASI_MFM_Dynamic_Approval_Route__c a : LApp){
                    MAppRoute.put(a.ASI_MFM_User__c, a);
                }
                
                for (ASI_MFM_Payment__c p:trigger_new) {
                    if (pid_set.contains(p.id) && p.ASI_MFM_Status__c == 'Draft'){ //20180503 Introv Added ASI_MFM_Status__c  == 'Draft'
                        setApproverToNull(p);//20180521 Introv
                        integer approver_count = 0;
                        boolean proceed = true;
                        id currentUserid = p.ASI_MFM_Budget_Owner_Manager__c;
                        system.debug(currentUserid);
                        
                        ASI_MFM_Dynamic_Approval_Route__c currentApprover = null;
                        User userCurrentApprover = null;
                        
                        while(proceed){
                            if(currentUserid != null && (MAppRoute.containsKey(currentUserid) || MUser.containsKey(currentUserid))){
                                if(MAppRoute.get(currentUserid) != null){
                                    currentApprover = MAppRoute.get(currentUserid);
                                    currentUserid = currentApprover.ASI_MFM_Manager_ID__c;
                                }
                                else{
                                    if(MUser.get(currentUserid) != null){
                                        userCurrentApprover = MUser.get(currentUserid);
                                        currentUserid = userCurrentApprover.ManagerID;
                                    }
                                }
                                
                                if(approver_count == 0){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_1__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_1__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 1){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_2__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_2__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 2){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_3__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_3__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 3){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_4__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_4__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 4){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_5__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_5__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 5){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_6__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_6__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 6){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_7__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_7__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 7){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_8__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_8__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 8){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_9__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_9__c = userCurrentApprover.id;
                                }
                                else if(approver_count == 9){
                                    if(currentApprover != null && userCurrentApprover == null)
                                        p.ASI_MFM_Sys_Approver_10__c = currentApprover.ASI_MFM_User__c;
                                    else if(currentApprover == null && userCurrentApprover != null)
                                        p.ASI_MFM_Sys_Approver_10__c = userCurrentApprover.id;
                                }
                                approver_count++;
                                
                                if(currentApprover != null && ((currentApprover.ASI_MFM_Approval_Limit__c != 0 && currentApprover.ASI_MFM_Approval_Limit__c > p.asi_mfm_payment_amount_RMB__c) || currentApprover.ASI_MFM_End_of_1st_Route__c)){
                                    proceed = false;
                                }
                                currentApprover = null;
                                userCurrentApprover = null;
                            }
                            else{
                                proceed = false;
                            }
                        }
                        ASI_MFM_Fix_Approval_Route__c fixApprover = MAppRouteFix.get(p.ASI_MFM_Budget_Owner_Team__c);
                        //
                        if(fixApprover != null){
                            //List<id> LApproverID = new list<id>();
                            if(fixApprover.ASI_MFM_Finance__c != null){
                                p.ASI_MFM_CN_Finance__c = fixApprover.ASI_MFM_Finance__c;
                                //LApproverID.add(fixApprover.ASI_MFM_Finance__c);
                                if(approver_count == 0){
                                    p.ASI_MFM_Sys_Approver_1__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 1){
                                    p.ASI_MFM_Sys_Approver_2__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 2){
                                    p.ASI_MFM_Sys_Approver_3__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 3){
                                    p.ASI_MFM_Sys_Approver_4__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 4){
                                    p.ASI_MFM_Sys_Approver_5__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 5){
                                    p.ASI_MFM_Sys_Approver_6__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 6){
                                    p.ASI_MFM_Sys_Approver_7__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 7){
                                    p.ASI_MFM_Sys_Approver_8__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 8){
                                    p.ASI_MFM_Sys_Approver_9__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                else if(approver_count == 9){
                                    p.ASI_MFM_Sys_Approver_10__c = fixApprover.ASI_MFM_Finance__c;
                                }
                                approver_count++;
                            }
                            if(fixApprover.ASI_MFM_Approval_Limit_Finance__c < p.asi_mfm_payment_amount_RMB__c || p.ASI_MFM_Is_Retainer_Agency__c){
                                p.ASI_MFM_CN_Return_Approver_1__c = fixApprover.ASI_MFM_BA__c;
                                if(approver_count == 0){
                                    p.ASI_MFM_Sys_Approver_1__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 1){
                                    p.ASI_MFM_Sys_Approver_2__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 2){
                                    p.ASI_MFM_Sys_Approver_3__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 3){
                                    p.ASI_MFM_Sys_Approver_4__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 4){
                                    p.ASI_MFM_Sys_Approver_5__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 5){
                                    p.ASI_MFM_Sys_Approver_6__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 6){
                                    p.ASI_MFM_Sys_Approver_7__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 7){
                                    p.ASI_MFM_Sys_Approver_8__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 8){
                                    p.ASI_MFM_Sys_Approver_9__c = fixApprover.ASI_MFM_BA__c;
                                }
                                else if(approver_count == 9){
                                    p.ASI_MFM_Sys_Approver_10__c = fixApprover.ASI_MFM_BA__c;
                                }
                                approver_count++;
                                if(fixApprover.ASI_MFM_Approval_Limit_BA__c < p.asi_mfm_payment_amount_RMB__c){
                                    //20160729 Ben @ Elufa
                                    if(mapBrandDirector.containsKey(p.id) && fixApprover.ASI_MFM_Approval_Limit_BD__c != NULL){
                                        
                                        p.ASI_MFM_CN_Return_Approver_2__c = mapBrandDirector.get(p.id);
                                        
                                        if(approver_count == 0){
                                            p.ASI_MFM_Sys_Approver_1__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 1){
                                            p.ASI_MFM_Sys_Approver_2__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 2){
                                            p.ASI_MFM_Sys_Approver_3__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 3){
                                            p.ASI_MFM_Sys_Approver_4__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 4){
                                            p.ASI_MFM_Sys_Approver_5__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 5){
                                            p.ASI_MFM_Sys_Approver_6__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 6){
                                            p.ASI_MFM_Sys_Approver_7__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 7){
                                            p.ASI_MFM_Sys_Approver_8__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 8){
                                            p.ASI_MFM_Sys_Approver_9__c = mapBrandDirector.get(p.id);
                                        }
                                        else if(approver_count == 9){
                                            p.ASI_MFM_Sys_Approver_10__c = mapBrandDirector.get(p.id);
                                        }
                                        approver_count++;
                                    }
                                    
                                    if(fixApprover.ASI_MFM_Approval_Limit_BD__c == NULL || fixApprover.ASI_MFM_Approval_Limit_BD__c < p.asi_mfm_payment_amount_RMB__c){
                                        //20160729 End
                                        //20160729
                                        if(p.ASI_MFM_CN_Return_Approver_2__c == NULL){
                                            p.ASI_MFM_CN_Return_Approver_2__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }else{
                                            p.ASI_MFM_CN_Return_Approver_3__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        
                                        if(approver_count == 0){
                                            p.ASI_MFM_Sys_Approver_1__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 1){
                                            p.ASI_MFM_Sys_Approver_2__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 2){
                                            p.ASI_MFM_Sys_Approver_3__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 3){
                                            p.ASI_MFM_Sys_Approver_4__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 4){
                                            p.ASI_MFM_Sys_Approver_5__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 5){
                                            p.ASI_MFM_Sys_Approver_6__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 6){
                                            p.ASI_MFM_Sys_Approver_7__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 7){
                                            p.ASI_MFM_Sys_Approver_8__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 8){
                                            p.ASI_MFM_Sys_Approver_9__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        else if(approver_count == 9){
                                            p.ASI_MFM_Sys_Approver_10__c = fixApprover.ASI_MFM_Corporate_Approver_1__c;
                                        }
                                        approver_count++;
                                        if(fixApprover.ASI_MFM_Approval_Limit_CA1__c < p.asi_mfm_payment_amount_RMB__c){
                                            //20160729
                                            if(p.ASI_MFM_CN_Return_Approver_3__c == NULL)
                                                p.ASI_MFM_CN_Return_Approver_3__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            else
                                                p.ASI_MFM_CN_Return_Approver_4__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            
                                            if(approver_count == 0){
                                                p.ASI_MFM_Sys_Approver_1__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 1){
                                                p.ASI_MFM_Sys_Approver_2__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 2){
                                                p.ASI_MFM_Sys_Approver_3__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 3){
                                                p.ASI_MFM_Sys_Approver_4__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 4){
                                                p.ASI_MFM_Sys_Approver_5__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 5){
                                                p.ASI_MFM_Sys_Approver_6__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 6){
                                                p.ASI_MFM_Sys_Approver_7__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 7){
                                                p.ASI_MFM_Sys_Approver_8__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 8){
                                                p.ASI_MFM_Sys_Approver_9__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            else if(approver_count == 9){
                                                p.ASI_MFM_Sys_Approver_10__c = fixApprover.ASI_MFM_Corporate_Approver_2__c;
                                            }
                                            approver_count++;
                                            
                                            /** added by Twinkle - 2014/06/21 **/
                                            // Expand Fix approvers from 4 to 6
                                            if(fixApprover.ASI_MFM_Approval_Limit_CA2__c < p.asi_mfm_payment_amount_RMB__c){
                                                //20160729
                                                if(p.ASI_MFM_CN_Return_Approver_4__c == NULL)
                                                	p.ASI_MFM_CN_Return_Approver_4__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                else
                                                    p.ASI_MFM_CN_Return_Approver_5__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                
                                                if(approver_count == 0){
                                                    p.ASI_MFM_Sys_Approver_1__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 1){
                                                    p.ASI_MFM_Sys_Approver_2__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 2){
                                                    p.ASI_MFM_Sys_Approver_3__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 3){
                                                    p.ASI_MFM_Sys_Approver_4__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 4){
                                                    p.ASI_MFM_Sys_Approver_5__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 5){
                                                    p.ASI_MFM_Sys_Approver_6__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 6){
                                                    p.ASI_MFM_Sys_Approver_7__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 7){
                                                    p.ASI_MFM_Sys_Approver_8__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 8){
                                                    p.ASI_MFM_Sys_Approver_9__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                else if(approver_count == 9){
                                                    p.ASI_MFM_Sys_Approver_10__c = fixApprover.ASI_MFM_Corporate_Approver_3__c;
                                                }
                                                approver_count++;
                                                
                                                if(fixApprover.ASI_MFM_Approval_Limit_CA3__c < p.asi_mfm_payment_amount_RMB__c){
                                                    //20160729
                                                    if(p.ASI_MFM_CN_Return_Approver_5__c == NULL)
                                                    	p.ASI_MFM_CN_Return_Approver_5__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    else
                                                        p.ASI_MFM_CN_Return_Approver_6__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    
                                                    if(approver_count == 0){
                                                        p.ASI_MFM_Sys_Approver_1__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 1){
                                                        p.ASI_MFM_Sys_Approver_2__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 2){
                                                        p.ASI_MFM_Sys_Approver_3__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 3){
                                                        p.ASI_MFM_Sys_Approver_4__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 4){
                                                        p.ASI_MFM_Sys_Approver_5__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 5){
                                                        p.ASI_MFM_Sys_Approver_6__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 6){
                                                        p.ASI_MFM_Sys_Approver_7__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 7){
                                                        p.ASI_MFM_Sys_Approver_8__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 8){
                                                        p.ASI_MFM_Sys_Approver_9__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                    else if(approver_count == 9){
                                                        p.ASI_MFM_Sys_Approver_10__c = fixApprover.ASI_MFM_Corporate_Approver_4__c;
                                                    }
                                                }
                                            }                                             
                                        }
                                    }
                                }
                            }
                        }
                        system.debug(p.ASI_MFM_Sys_Approver_10__c);                      
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
        if (Payment_list.size() > 0) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'Payment']);
            for (ASI_MFM_Payment__c p:Payment_list) {
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
        
        //20190212@Introv - replace workflow
        SetCNSupplierEmail(trigger_new);
        
        //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
        setFinanceLastUpdated(trigger_new, trigger_oldMap);

    } 
    
    public static void setApproverToNull(ASI_MFM_Payment__c p)
    {   
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
        p.ASI_MFM_CN_Finance__c = null;    
        p.ASI_MFM_CN_Return_Approver_1__c = null;
        p.ASI_MFM_CN_Return_Approver_2__c = null;
        p.ASI_MFM_CN_Return_Approver_3__c = null;
        p.ASI_MFM_CN_Return_Approver_4__c = null; 
        p.ASI_MFM_CN_Return_Approver_5__c = null;
        p.ASI_MFM_CN_Return_Approver_6__c = null;//20160729 Ben @ Elufa
    }
    
    public static void SetTaxCodeLookupValue(list <ASI_MFM_Payment__c> trigger_new) {
        /***** added by leo - 2014/06/16 *****/
        List<ASI_MFM_Tax_Code__c> TaxCode_List = LTaxCode;

        for (ASI_MFM_Payment__c p : trigger_new) {
            if(p.ASI_MFM_CN_Tax_Code_Picklist__c != null)
            {
                string tmpStrTaxCode = p.ASI_MFM_CN_Tax_Code_Picklist__c;
                if(TaxCode_List != null && TaxCode_List.size()>0){
                    for (ASI_MFM_Tax_Code__c tax : TaxCode_List)
                    {
                        if(tax.Name == tmpStrTaxCode)
                            p.ASI_MFM_Tax_Code__c = tax.id;
                    }
                }
            }
            else
            {
                p.ASI_MFM_Tax_Code__c = null;
            }
        }
    }
    
    //20190212@Introv - replace workflow
    private static void SetCNSupplierEmail(list <ASI_MFM_Payment__c> trigger_new) {
        Set<Id> setSupplierName = new Set<Id>();
        
        for (ASI_MFM_Payment__c p : trigger_new) {
            if (p.ASI_MFM_Supplier_Name__c != NULL)
                setSupplierName.add(p.ASI_MFM_Supplier_Name__c);
        }
        
        Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT id, ASI_LUX_Email_Business__c FROM Account WHERE id in :setSupplierName]);
        for (ASI_MFM_Payment__c p : trigger_new) {
            p.ASI_MFM_Supplier_Email__c = NULL;
            if (p.ASI_MFM_Supplier_Name__c != NULL) {
                p.ASI_MFM_Supplier_Email__c = mapAccount.get(p.ASI_MFM_Supplier_Name__c).ASI_LUX_Email_Business__c;
            }
        }
    }
    
    //20191108:AM@introv - change status to "Pending For Finance"
    private static void setStatusToPendingForFinance(list <ASI_MFM_Payment__c> trigger_new) {
        for (ASI_MFM_Payment__c p : trigger_new) {
            if ((p.ASI_MFM_Status__c == 'Submitted') 
                && (p.ASI_MFM_CN_Next_Approver_ID__c != NULL) && (p.ASI_MFM_CN_Next_Approver_ID__c.trim() != '')
               	&& (p.ASI_MFM_CN_Finance__c != NULL))
            {
                if (p.ASI_MFM_CN_Next_Approver_ID__c.trim() == p.ASI_MFM_CN_Finance__c) p.ASI_MFM_Status__c = 'Pending For Finance';
            }
            //20191111 - no need rollback status
            /*
            if ((p.ASI_MFM_Status__c == 'Pending For Finance') 
                && (p.ASI_MFM_CN_Next_Approver_ID__c != NULL) && (p.ASI_MFM_CN_Next_Approver_ID__c.trim() != '')
               	&& (p.ASI_MFM_CN_Finance__c != NULL))
            {
                if (p.ASI_MFM_CN_Next_Approver_ID__c.trim() != p.ASI_MFM_CN_Finance__c) p.ASI_MFM_Status__c = 'Submitted';
            }
			*/
        }
    }
    
    //20200401:AM@introv - set LastUpdatedBy for Payment API (GL Date + Invoice Number)
    private static void setFinanceLastUpdated(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        for (ASI_MFM_Payment__c p : trigger_new) {
            if (trigger_oldMap == NULL) {
                if ((p.ASI_MFM_G_L_Date__c != NULL) || (p.ASI_MFM_Invoice_Number__c != NULL)) p.ASI_MFM_Submitter__c = UserInfo.getUserId();
            } else {
                if ((p.ASI_MFM_G_L_Date__c != trigger_oldMap.get(p.Id).ASI_MFM_G_L_Date__c) || (p.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(p.Id).ASI_MFM_Invoice_Number__c)) p.ASI_MFM_Submitter__c = UserInfo.getUserId();
            }
        }
    }
    
}