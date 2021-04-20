public without sharing class ASI_MFM_GF_Payment_TriggerClass {
    private static final Set<String> GST_Inclusive_Tax_Code = new Set<String>{'CA3', 'IC3', 'IN3', 'LA3', 'MM3', 'MY3', 'PH3', 'SG3'};
    
    public static void CompletePOLine(set<id> POList){
        //For GF MFM
        String Description;
        List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();
        // PO Line
        List<ASI_MFM_PO_Line_Item__c> poLineList = [select ID,ASI_MFM_Customer_Name__c ,
                                                    ASI_MFM_Complete__c,ASI_MFM_G_L_Date__c,ASI_MFM_Recharge__c,ASI_MFM_SKU_Code__c,
                                                    ASI_MFM_POSM_Deposit__c,ASI_MFM_POSM_Balance__c,ASI_MFM_Sub_brand_Allocation_Type__c,
                                                    ASI_MFM_Requested_Balance__c, name,ASI_MFM_PO__c,ASI_MFM_AP_Code__c,ASI_MFM_Reference__c, 
                                                    ASI_MFM_Sub_brand_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_Remaining_Balance__c,ASI_MFM_Amount__c from ASI_MFM_PO_Line_Item__c where ASI_MFM_PO__c in : POList];
        
        ID Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('GF PO Line Item').getRecordTypeId();                    
        for (ASI_MFM_PO_Line_Item__c poL : poLineList){
            if(!poL.ASI_MFM_Complete__c){
                if(poL.ASI_MFM_Remaining_Balance__c!=0){
                    Description='Closing PO Adjustment: '+poL.name + '- Paid Amount: ' + (poL.ASI_MFM_Amount__c - poL.ASI_MFM_Remaining_Balance__c) + '; Remaining Amount: ' + poL.ASI_MFM_Remaining_Balance__c;
                    ASI_MFM_PO_Line_Item__c poline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-poL.ASI_MFM_Remaining_Balance__c, ASI_MFM_PO__c = poL.ASI_MFM_PO__c,ASI_MFM_Sub_brand_Allocation_Type__c =poL.ASI_MFM_Sub_brand_Allocation_Type__c,ASI_MFM_Recharge__c= poL.ASI_MFM_Recharge__c,ASI_MFM_SKU_Code__c= poL.ASI_MFM_SKU_Code__c ,ASI_MFM_Customer_Name__c = poL.ASI_MFM_Customer_Name__c,ASI_MFM_AP_Code__c= poL.ASI_MFM_AP_Code__c , ASI_MFM_A_C_Code__c = poL.ASI_MFM_A_C_Code__c, ASI_MFM_Reference__c = poL.ASI_MFM_Reference__c, ASI_MFM_Sub_brand_Code__c = poL.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid,ASI_MFM_G_L_Date__c = poL.ASI_MFM_G_L_Date__c, ASI_MFM_Adjustment_Line__c = true);
                    newPOL.add(poline);
                }
                ASI_MFM_PO_Line_Item__c CompletePoline = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = poL.ID);
                newPOL.add(CompletePoline);
            }
        }
        if(newPOL.size()>0){
            upsert newPOL;
        }
    }
    
    public static void routineBeforeDelete(list<ASI_MFM_Payment__c> trigger_old) {
        Set<Id> setPOId = new Set<Id>();
        Set<Id> setLineId = new Set<Id>();
        List<ASI_MFM_PO__c> listPO = new List<ASI_MFM_PO__c>();
        
        for (ASI_MFM_Payment__c pa : trigger_old){
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete'){
                 pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
            }                        
        }        
        
    }

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
                
                //Wilken 20161230, Gulf Duty Free uses 5 characters prefix
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_GF')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                        px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                    }
                    else if (px_map.get(p.asi_mfm_prefix__c).name.length() == 4){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                        px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                    }
                }
               
            }
            
            
        }
        ASI_MFM_Function.updatePrefix(px_map.values());           
    }

    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        System.debug('Start Payment routineAfterUpdate');
        //Gulf MFM Approval Logic
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_GF')){
            ASI_MFM_Approval_Setting__c setting = ASI_MFM_Approval_Setting__c.getInstance('GF');
            
            double maxDirectPayAmount = 0;
            double minApprovalAmount = 0;
            double toleranceAmount = 0;
            double tolerancePercent = 0;
            double exchangeRate = 0;
            double exceedAmountBaseCurr = 0;
            double exceedPercent = 0;
            double poPaidAmount = 0;
            
            Set<ID> paymentIDs = new Set<ID>();
            
            if (setting != null && setting.ASI_MFM_Payment_Min_Approval_Amt__c != null && setting.ASI_MFM_Payment_Tolerance_Amt__c != null && setting.ASI_MFM_Payment_Tolerance_Percent__c != null){
                minApprovalAmount = setting.ASI_MFM_Payment_Min_Approval_Amt__c;
                toleranceAmount = setting.ASI_MFM_Payment_Tolerance_Amt__c;
                tolerancePercent = setting.ASI_MFM_Payment_Tolerance_Percent__c;
                maxDirectPayAmount = setting.ASI_MFM_Direct_Payment_Max_Allowed_Amt__c;
            }
            
           System.debug('Approval Custom Setting: ' + minApprovalAmount + ' ' + toleranceAmount + ' ' + tolerancePercent);
            for (ASI_MFM_Payment__c pay:trigger_new) {
                paymentIDs.add(pay.id);
            }
            
            List<ASI_MFM_Payment__c> paymentListUpdate = new List<ASI_MFM_Payment__c>();
            List<ASI_MFM_PO__c> poListUpdate = new List<ASI_MFM_PO__c>();
            
            for (ASI_MFM_Payment__c pay:[select ASI_MFM_Exchange_Rate__c,ASI_MFM_Status__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Need_Approval__c, ASI_MFM_Remarks__c, ASI_MFM_Is_Direct_Payment__c from ASI_MFM_Payment__c where id = :paymentIDs]){
                if (pay.ASI_MFM_Payment_Amount__c != trigger_oldMap.get(pay.id).ASI_MFM_Payment_Amount__c){
                    if (pay.ASI_MFM_Exchange_Rate__c != null)
                        exchangeRate = pay.ASI_MFM_Exchange_Rate__c;
                    
                    //If Payment amount < 5000 USD, no need approval
                    // [SH] 2019-03-27 If Paid amount - PO amount > 10%, Need Managing Director approval
                    if (pay.ASI_MFM_Payment_Amount__c != null && exchangeRate != null && minApprovalAmount != null){
                        //Direct Payment cannot exceed $1000 USD
                        System.debug('Payment Amount: ' + pay.ASI_MFM_Payment_Amount__c + ' Exchange Rate: ' + exchangeRate + ' Max Direct Pay Amt: ' + maxDirectPayAmount);                        
                        
                        /*
                        if (pay.ASI_MFM_Payment_Amount__c * exchangeRate < minApprovalAmount){
                        pay.ASI_MFM_Need_Approval__c = false;
                        }
                        else {*/
                        //Reset need approval flag
                        pay.ASI_MFM_Need_Approval__c = false;
                        
                        List<ASI_MFM_Payment_Line_Item__c> payLines = [select ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :pay.id];
                        Set<ID> poIDs = new Set<ID>();
                        
                        System.debug('Number of Payment Lines: ' + payLines.size());
                        if (payLines.size() > 0){
                            for (ASI_MFM_Payment_Line_Item__c payLine:payLines){
                                System.debug('PO from the Payment Line: ' + payLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                                poIDs.add(payLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                            }
                        }
                        
                        List<ASI_MFM_Payment_Line_Item__c> payLinesPO = [select ASI_MFM_Paid_Amount_in_PO_Currency__c, ASI_MFM_Payment_Amount__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c = :poIDs];
                        System.debug('Number of Payment Line query from PO: ' + payLinesPO.size());
                        
                        List<ASI_MFM_PO__c> pos = [select ASI_MFM_PO_Amount__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_PO__c where id = :poIDs];
                        
                        for (ASI_MFM_PO__c po:pos){
                            poPaidAmount = 0;
                            
                            for (ASI_MFM_Payment_Line_Item__c pLine:payLinesPO){
                                System.debug('Is Payment Line PO matches?: PLine PO ID:' + pLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c + ' PO ID: ' + po.id + ' PLine Paid Amt: ' + pLine.ASI_MFM_Paid_Amount_in_PO_Currency__c);
                                if (pLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c == po.id){
                                    poPaidAmount += pLine.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                                }
                            }
                            
                            exceedAmountBaseCurr = (poPaidAmount - po.ASI_MFM_PO_Amount__c) * po.ASI_MFM_Exchange_Rate__c;
                            exceedPercent = (poPaidAmount - po.ASI_MFM_PO_Amount__c) / po.ASI_MFM_PO_Amount__c * 100;
                            System.debug('PO Amount: ' + po.ASI_MFM_PO_Amount__c + ' Payment Amt PO Curr: ' + poPaidAmount + ' Ex. Rate: ' + po.ASI_MFM_Exchange_Rate__c + ' Exceed amount in base currency: ' + exceedAmountBaseCurr + ' Exceed Percentage: ' + exceedPercent);
                            //if (exceedAmountBaseCurr >= toleranceAmount || exceedPercent >= tolerancePercent){                                
                            if (exceedPercent >= tolerancePercent){                                
                                pay.ASI_MFM_Need_Approval__c = true;  system.debug('Need Approval'); 
                            }
                        }
                        //}
                        //Clear approver if no need to approve
                        if (pay.ASI_MFM_Need_Approval__c == false){
                            pay.ASI_MFM_Sys_Approver_2__c = null;
                            pay.ASI_MFM_Sys_Approver_3__c = null;
                            pay.ASI_MFM_Sys_Approver_4__c = null;
                            pay.ASI_MFM_Sys_Approver_5__c = null;
                        }
                    }
                    if (pay.ASI_MFM_Need_Approval__c != trigger_oldMap.get(pay.id).ASI_MFM_Need_Approval__c){
                        paymentListUpdate.add(pay);
                    }
                }
                //Complete PO when Payment is approved (Only for Non-direct payment)
                System.debug('New Status: ' + pay.ASI_MFM_Status__c + ' Old Status: ' + trigger_oldMap.get(pay.id).ASI_MFM_Status__c);
                if (pay.ASI_MFM_Status__c == 'Final' && (trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted' || trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Draft')){
                    
                    Set<ID> completePOID = new Set<ID>();
                    //Change by Elufa 
                    List<ASI_MFM_Payment_Line_Item__c> payLineList = [select ASI_MFM_Complete_PO__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c, ASI_MFM_PO_Line_Item__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :pay.id ];
                    List<ASI_MFM_Payment_Line_Item__c> UpdatePaylineList = new List<ASI_MFM_Payment_Line_Item__c>();
                    
                    System.debug('payLineList Size: ' + payLineList.size());
                    
                    // Added by 2018-08-21 Linus@introv
                    // Add a logic to update PO Receipt Status to Final if Direct Payment is approved
                    if(pay.ASI_MFM_Is_Direct_Payment__c == false){
                        for (ASI_MFM_Payment_Line_Item__c payLine:payLineList){
                            System.debug('payLine PO Status: ' + payLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c);
                            if (payLine.ASI_MFM_Complete_PO__c == true && payLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Status__c == 'Final'){
                                completePOID.add(payLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                            }//ASI_MFM_Approval_Date__c
                            UpdatePaylineList.add(new ASI_MFM_Payment_Line_Item__c(id=payLine.id,  ASI_MFM_Approval_Date__c= system.now()));
                        }
                        
                        update UpdatePaylineList;
                        
                        poListUpdate = [select ASI_MFM_Status__c from ASI_MFM_PO__c where id = :completePOID];
                        CompletePOLine(completePOID);
                        System.debug('PO ID for Complete: ' + completePOID + ' poListUpdate size: ' + poListUpdate.size());
                        for (ASI_MFM_PO__c po:poListUpdate){
                            po.ASI_MFM_Status__c = 'Complete';
                        }
                    }else{
                        Set<Id> PORIid_Set = new Set<Id>();
                        Set<Id> PORId_Set = new Set<Id>();
                        for(ASI_MFM_Payment_line_item__c pl: payLineList){
                            PORIid_Set.add(pl.ASI_MFM_PO_Line_Item__c);
                        }
                        for(ASI_MFM_PO_Receipt_Item__c pori: [Select id, ASI_MFM_PO_Receipt__c from ASI_MFM_PO_Receipt_Item__c where ASI_MFM_PO_Line_Item__c=:PORIid_Set]){
                            PORId_Set.add(pori.ASI_MFM_PO_Receipt__c);
                        }
                        List<ASI_MFM_PO_Receipt__c> PORList = [Select id, ASI_MFM_Status__c, recordtypeid from ASI_MFM_PO_Receipt__c where ASI_MFM_Status__c != 'Final' and id=:PORId_Set];
                        for(ASI_MFM_PO_Receipt__c por: PORList){
                            por.ASI_MFM_Status__c = 'Final';
                            por.recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Receipt__cASI_MFM_GF_PO_Receipt_Read_Only');
                        }
                        
                        if(!Test.isRunningTest())
                            update PORList;
                    }
                    // END - Linus@introv
                }
            }
            update paymentListUpdate;
            update poListUpdate;
        }    
        
    }
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpdate');
        
        // Stop Any users from setting status Complete to final
        User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
        
    // Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Payment__c> reject_map = new map<id, ASI_MFM_Payment__c>();
                
        
        for (ASI_MFM_Payment__c p:trigger_new) {             
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
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
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;
                                    
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            system.debug('a1:'+country +'/'+base_ccy + '/'+ last_effective_date);
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay_set.contains(pay.id)) {
                    if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                        pay.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        
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
            list<ASI_MFM_Route_Rule_Detail__c> rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c,ASI_MFM_Region__c from ASI_MFM_Route_Rule_Detail__c 
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c];

            for (ASI_MFM_Payment__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && (brm.ASI_MFM_Sub_brand__c == sbid || brm.ASI_MFM_Sub_brand__c == null)) {
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
        
        if (Payment_list.size() > 0 ) {
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