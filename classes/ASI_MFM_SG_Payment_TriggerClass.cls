/*********************************************************************************
 * Name:ASI_MFM_SG_Payment_TriggerClass
 * Description: 
 * Test Class: ASI_MFM_SG_PDF_Test, ASI_MFM_SG_PaymentPDF_Test, ASI_MFM_SG_PaymentTestClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/06/2018       Wilken              [WL 1.0] Approver by Brand owner need to limit to Marketing Payment
 * 26/06/2018       Wilken              [WL 2.0] Marketing Payment approver based on Sub-brand owner
 * 25/07/2018       Wilken              [WL 3.0] Approver by Brand owner need to limit to Marketing PO of FY1819 onwards only
*********************************************************************************/
public without sharing class ASI_MFM_SG_Payment_TriggerClass {
    private static final Set<String> GST_Inclusive_Tax_Code = new Set<String>{'CA3', 'IC3', 'IN3', 'LA3', 'MM3', 'MY3', 'PH3', 'SG3'};
        
    
    public static void routineBeforeDelete(list<ASI_MFM_Payment__c> trigger_old) {
        
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
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SG')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                        px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                    }
                }
                
            }
            
        }
        ASI_MFM_Function.updatePrefix(px_map.values());           
    }

    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        System.debug('Start Payment routineAfterUpdate');
        
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG')) {
            Set<ID> paymentIDs = new Set<ID>();
            for (ASI_MFM_Payment__c pay:trigger_new) {
                    paymentIDs.add(pay.id);
                
            }
            
            List<ASI_MFM_Payment_Line_Item__c> payLineList = [select id,ASI_MFM_Payment_Amount__c,ASI_MFM_GST_Amount__c,ASI_MFM_Invoice_Total__c,ASI_MFM_Payment__r.ASI_MFM_GST__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDs];
            for (ASI_MFM_Payment_Line_Item__c payL : payLineList){
                //If GST in  Payment is true, calculate GST Amount
                if(payL.ASI_MFM_Payment__r.ASI_MFM_GST__c==true){
                    if (payL.ASI_MFM_GST_Amount__c==null || payL.ASI_MFM_GST_Amount__c ==0 || payL.ASI_MFM_GST_Amount__c != payL.ASI_MFM_Payment_Amount__c*0.07){
                        //payL.ASI_MFM_GST_Amount__c=payL.ASI_MFM_Payment_Amount__c*0.07;
                        payL.ASI_MFM_Invoice_Total__c=payL.ASI_MFM_Payment_Amount__c/1.07;
                        payL.ASI_MFM_GST_Amount__c = payL.ASI_MFM_Payment_Amount__c - payL.ASI_MFM_Invoice_Total__c;
                    }
                }
                //If GST in  Payment is false, clear GST Amount
                if(payL.ASI_MFM_Payment__r.ASI_MFM_GST__c==false && (payL.ASI_MFM_GST_Amount__c!=null || payL.ASI_MFM_GST_Amount__c !=0)){
                    payL.ASI_MFM_GST_Amount__c=0;
                    payL.ASI_MFM_Invoice_Total__c=payL.ASI_MFM_Payment_Amount__c;
                }
            }
            try{
                update payLineList;
            }catch(System.DMLexception e){
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    // Process exception here
                    system.debug(e.getDmlMessage(i));            
                }
            }   
        }
        
        // Added by Alan Wong (Elufa) 6Feb2015  
        // complete PO and free remaining plan amount for SG AND TH and MY
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG') ){          
            Set<ID> paymentIDs = new Set<ID>();
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted'){
                    paymentIDs.add(pay.id);
                }
            }
            
            
                List<ASI_MFM_Payment_Line_Item__c> updatepayl = new List<ASI_MFM_Payment_Line_Item__c>();
                List<ASI_MFM_Payment_Line_Item__c> payLineListPOSM = [select id, ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDs];
                for(ASI_MFM_Payment_Line_Item__c payline : payLineListPOSM){
                    
                        if(payline.ASI_MFM_G_L_Date__c == null){
                            payline.ASI_MFM_G_L_Date__c = payline.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                            updatepayl.add(payline);
                        }
                    
                }
                if(updatepayl.size()>0){
                    update updatepayl;
                }
            
            ID Rectypeid;
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG')){
                Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('SG PO Line Item').getRecordTypeId();
            }
            
            List<ASI_MFM_PO_Line_Item__c> newPOL = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_Payment_Line_Item__c> payLineList = [select id,ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__r.name,ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c,ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c,ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDs and ASI_MFM_Complete_POL__c = true AND ASI_MFM_PO_Line_Item__r.ASI_MFM_Remaining_Balance__c > 0];
            String Description;
            Set<ID> POLineIDSet = new Set<ID>();
            for (ASI_MFM_Payment_Line_Item__c payL : payLineList){
                decimal Remaining = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Amount__c - payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c;
                Description='Closing PO Adjustment: '+payL.ASI_MFM_PO_Line_Item__r.name+'- Paid Amount: '+payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Paid_Amount__c+'; Remaining Amount: '+ Remaining;
                ASI_MFM_PO_Line_Item__c pol = new ASI_MFM_PO_Line_Item__c(ASI_MFM_List_Item_Description__c = Description, ASI_MFM_Amount__c = 0-Remaining , ASI_MFM_PO__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c,ASI_MFM_Customer_Name__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Customer_Name__c, ASI_MFM_A_C_Code__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__c, ASI_MFM_Sub_brand_Code__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_Complete__C = true, recordTypeId=Rectypeid, ASI_MFM_G_L_Date__c = payL.ASI_MFM_PO_Line_Item__r.ASI_MFM_G_L_Date__c,ASI_MFM_Adjustment_Line__c = true);
                if(!POLineIDSet.contains(payL.ASI_MFM_PO_Line_Item__c)){
                    ASI_MFM_PO_Line_Item__c CompletePol = new ASI_MFM_PO_Line_Item__c(ASI_MFM_Complete__C = true, ID = payL.ASI_MFM_PO_Line_Item__c);
                    newPOL.add(CompletePol);
                    POLineIDSet.add(payL.ASI_MFM_PO_Line_Item__c);
                }
               
                newPOL.add(pol);
               
            }
            upsert newPOL;
        }
        // Finished
    }
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpdate');
        
        // Stop Any users from setting status Complete to final
        User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
        boolean isuserAdmin = prof.profile.name.contains('System Administrator') || prof.UserRole.developername == 'ASI_MFM_TW_System_Administrator';     
// Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Payment__c> reject_map = new map<id, ASI_MFM_Payment__c>();

        map<id, id> Supplier_Map = new map<id, id>();      
        
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Status__c != trigger_oldMap.get(p.id).ASI_MFM_Status__c && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Complete' && !isuserAdmin)
                p.addError('Cannot change a Complete Payment status to Final or Draft. Please contact the System Administrator.');  
            
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
                Supplier_map.put(p.id, p.ASI_MFM_Supplier_Name__c);
            }
           
            
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_SG')){
                Date selectedDate;
                Date StartDate;
                Date EndDate;
                if(p.ASI_MFM_Status__c == 'Final' && (trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') ){
                    for (ASI_MFM_GL_Date_Setting__c Setting : ASI_MFM_GL_Date_Setting__c.getAll().values()) {
                        if(Setting.ASI_MFM_Country__c=='SG'){
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
        
        List<ASI_MFM_Payment_Line_Item__c> line_list = [Select id, ASI_MFM_Payee__c, ASI_MFM_Payment__c from ASI_MFM_Payment_line_Item__c where ASI_MFM_Payment__c = :Supplier_map.keySet()];
        if(line_list.size() > 0){
            for(ASI_MFM_Payment_Line_Item__c pl: line_list){
                pl.ASI_MFM_Payee__c = Supplier_map.get(pl.ASI_MFM_Payment__c);
            }
        }
        
        if(!Test.isRunningTest())
            update line_list;
    }
        
    public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        
        
// Recalculate VAT amount, WT amount and insurance amount for Taiwan
        decimal percent;
        set<id> owner_set = new set<id>();
        for (ASI_MFM_Payment__c pay:trigger_new) {
            owner_set.add(pay.ownerId);
            // Check if there was an input in the decimal number output error
            boolean isDecimal = 
            (ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_Insurance_Amount__c) || 
            ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_Payment_Amount__c) ||
            ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_VAT_Amount__c) ||
            ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_WT_Amount__c)) && pay.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                pay.addError(' You Cannot input a decimal number for a TWD currency.');
              
            
            Set<ID> supplierIDSet = new Set<ID>();
            
            if (Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_SG')){
                if (trigger_oldMap == null || (pay.ASI_MFM_Supplier_Name__c != null && pay.ASI_MFM_Supplier_Name__c != trigger_oldMap.get(pay.id).ASI_MFM_Supplier_Name__c)){
                    supplierIDSet.add(pay.ASI_MFM_Supplier_Name__c);
                }
            }
            
            if (supplierIDSet.size() > 0){
                Map<ID, Account> supplierMap = new Map<ID, Account>([select id, ASI_LUX_Remarks__c from Account where id in :supplierIDSet]);
                
                for (ASI_MFM_Payment__c payment:trigger_new) {
                    //Wilken 20160823, include multiple Tax Rate/Area code for Payment with GST Inclusive
                    if (supplierMap.get(payment.ASI_MFM_Supplier_Name__c) != null && GST_Inclusive_Tax_Code.contains(supplierMap.get(payment.ASI_MFM_Supplier_Name__c).ASI_LUX_Remarks__c))
                        payment.ASI_MFM_GST__c = true;
                    else
                        payment.ASI_MFM_GST__c = false;
                }
            }
        }
        map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName, managerid from user where id in :owner_set]);

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
            
            if (country == 'SG'){ 
                if(ASI_MFM_ByPass_Setting.ByPassClass('ASI_MFM_SG_ChangeLAMMCurrency','SG')){
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
            
            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            system.debug('a1:'+country +'/'+base_ccy + '/'+ last_effective_date);
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay_set.contains(pay.id)) {
                    if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                        pay.ASI_MFM_Exchange_Rate__c = 1;
                    }else{
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
            Map<id, Set<id>> brandManagerMap = new Map<id, Set<id>>();//20180409 Introv

      /*[WL 2.0] BEGIN*/
            //for (ASI_MFM_Payment_Line_Item__c pi:[select ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.ASI_MFM_Brand__r.OwnerId  from ASI_MFM_Payment_Line_Item__c 
            //                                      where ASI_MFM_Payment__c in :pid_set order by name desc]) {
      for (ASI_MFM_Payment_Line_Item__c pi:[select ASI_MFM_Payment__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.OwnerId  from ASI_MFM_Payment_Line_Item__c       
                          where ASI_MFM_Payment__c in :pid_set order by name desc]) {
      /*[WL 2.0] END*/
                                                      
                                                      //20180409 Introv
                                                      Set<id> tmpBrandManagerSet = new Set<Id>();
                                                      
                                                      if(brandManagerMap.containsKey(pi.ASI_MFM_Payment__c)){
                                                          tmpBrandManagerSet = brandManagerMap.get(pi.ASI_MFM_Payment__c);
                                                      }
                                                      //Mark NG@ 2020-06-02
                                                      if(!tmpBrandManagerSet.contains(pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.OwnerId))
                                                        tmpBrandManagerSet.add(pi.ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.OwnerId);
                                                      
                                                      brandManagerMap.put(pi.ASI_MFM_Payment__c, tmpBrandManagerSet);
                                                      //20180409 End
                                                      
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
                where ASI_MFM_Route_Type__c in :rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Sequence__c];
            
            for (ASI_MFM_Payment__c p:trigger_new) {
                integer approver_count = 0;
                if (pid_set.contains(p.id)) {
                    
                    id sbid = sb_map.get(p.id);
                    id rtid;
                    for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
                        if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_brand__c == null ) {
                            rtid = brm.ASI_MFM_Route_Type__c;
                            
                        }else if (brm.ASI_MFM_Prefix__c == p.ASI_MFM_Prefix__c && brm.ASI_MFM_Sub_brand__c == sbid ) {
                            rtid = brm.ASI_MFM_Route_Type__c;
                            
                            break;
                        }
                        else if (brm.ASI_MFM_Prefix__c > p.ASI_MFM_Prefix__c) {
                            break;
                        }                       
                    }
                    
                    //20180628 Introv set first approver to Finance
                    if (rtid != null) {
                        decimal local_amount = p.ASI_MFM_Payment_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                        for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                            if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount){
                                //Mark NG 2020-06-03
                                if(approver_count <= 9 && rd.ASI_MFM_Minimum_Amount__c==0){
                                    String sysApprover = 'ASI_MFM_Sys_Approver_' + (approver_count + 1) + '__c';
                                    String approverid = rd.ASI_MFM_Approver__c;
                                    // Mark NG@ 2020-11-13
                                    if(rd.ASI_MFM_Approver__c==p.ownerid && owner_map.get(p.ownerid).managerid!=null){
                                        approverid=owner_map.get(p.ownerid).managerid;
                                    }
                                    p.put(sysApprover, approverid);
                                    approver_count++;
                                }
                            }else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                break;
                            }
                        }
                    }
                    
                    //20180409 Introv
                    /*[WL 1.0] BEGIN*/
                    //if(brandManagerMap.containsKey(p.id)){
          /*[WL 3.0] BEGIN*/
                    //if(brandManagerMap.containsKey(p.id) && p.ASI_MFM_Department__c != null && p.ASI_MFM_Department__c.contains('SG Brand Marketing')){
                    if(brandManagerMap.containsKey(p.id) && p.ASI_MFM_Department__c != null && p.ASI_MFM_Department__c.contains('SG Brand Marketing')
                        && p.ASI_MFM_CN_Fiscal_Year__c >= 'FY1819'){
          /*[WL 3.0] END*/
          /*[WL 1.0] END*/
                        for(Id brandManager : brandManagerMap.get(p.id)){
                            
                            if(approver_count <= 9){
                                String sysApprover = 'ASI_MFM_Sys_Approver_' + (approver_count + 1) + '__c';
                                String approverid = brandManager;
                                // Mark NG@ 2020-11-13
                                if(brandManager==p.ownerid && owner_map.get(p.ownerid).managerid!=null){
                                    approverid=owner_map.get(p.ownerid).managerid;
                                }
                                p.put(sysApprover, approverid);
                                approver_count++;
                            }
                            
                        }
                    }
                    // Mark NG@ 2020-06-02
                    if (rtid != null) {
                        decimal local_amount = p.ASI_MFM_Payment_Amount__c * p.ASI_MFM_Exchange_Rate__c;
                        for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                            if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount){ 
                                if(brandManagerMap.containsKey(p.id) && p.ASI_MFM_Department__c != null && p.ASI_MFM_Department__c.contains('SG Brand Marketing') 
                                    && p.ASI_MFM_CN_Fiscal_Year__c >= 'FY1819' && brandManagerMap.get(p.id).contains(rd.ASI_MFM_Approver__c))
                                        continue;
                                        
                                if(rd.ASI_MFM_Minimum_Amount__c == 0)
                                    continue;
                                else if(approver_count <= 9){
                                    String sysApprover = 'ASI_MFM_Sys_Approver_' + (approver_count + 1) + '__c';
                                    String approverid = rd.ASI_MFM_Approver__c;
                                    // Mark NG@ 2020-11-13
                                    if(rd.ASI_MFM_Approver__c==p.ownerid && owner_map.get(p.ownerid).managerid!=null){
                                        approverid=owner_map.get(p.ownerid).managerid;
                                    }
                                    
                                    p.put(sysApprover,approverid );
                                    approver_count++;
                                }
                                   
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
        
        set<id> prefix_set = new set<id>();
        list<ASI_MFM_Payment__c> Payment_list = new list<ASI_MFM_Payment__c>();
        
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                
                prefix_set.add(p.ASI_MFM_Prefix__c);
                Payment_list.add(p);
            }
        }
        
        if (Payment_list.size() > 0 ) {
           
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