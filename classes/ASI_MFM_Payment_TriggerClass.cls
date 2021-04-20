public without sharing class ASI_MFM_Payment_TriggerClass {
    //Test class : ASI_MFM_InputPaymentItemsTest
    //ASI_MFM_HK_InputPaymentItemsTest
    //ASI_MFM_Payment_Trigger_TestClass, ASI_MFM_SetPOStatusController_Test
    //ASI_MFM_TW_TestClass
    //ASI_MFM_GF_PDF_Test
    //ASI_MFM_GF_TestClass_DL
	private static final Set<String> GST_Inclusive_Tax_Code = new Set<String>{'CA3', 'IC3', 'IN3', 'LA3', 'MM3', 'MY3', 'PH3', 'SG3'};
    Private Static Final Map<String, Schema.SObjectField> Payment_FIELD_MAP = Schema.SObjectType.ASI_MFM_Payment__c.fields.getMap();
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
    public static void routineBeforerDelete(list<ASI_MFM_Payment__c> trigger_old) {
        Set<Id> setPOId = new Set<Id>();
        Set<Id> setLineId = new Set<Id>();
        List<ASI_MFM_PO__c> listPO = new List<ASI_MFM_PO__c>();
        
        for (ASI_MFM_Payment__c pa : trigger_old){
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete'){
                pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
            }
            if (pa.RecordTypeId != null && Global_RecordTypeCache.getRt(pa.recordTypeId).developerName.contains('ASI_MFM_TW') && pa.ASI_MFM_Is_Direct_Payment__c == TRUE){
                setPOId.add(pa.ASI_MFM_PO__c);
            }  
            
            if (pa.RecordTypeId != null && Global_RecordTypeCache.getRt(pa.recordTypeId).developerName.contains('ASI_MFM_JP')){
                setLineId.add(pa.id);
            }  
            
        }
        if(setPOId != NULL)
            listPO = [SELECT id FROM ASI_MFM_PO__c WHERE id IN:setPOId];
        delete listPO;
        
        if(setLineId!=null){
            delete [select id from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c in : setLineId];
        }
        
    }
    
    public static void routineAfterDelete(list<ASI_MFM_Payment__c> trigger_old) {
              
    }
    
    public static void routineAfterUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
          
    }
    
    public static void routineBeforeInsert(list<ASI_MFM_Payment__c> trigger_new) {
        set<id> px_set = new set<id>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
        }
        //for JP, added on 2015-09-10
        List<ASI_MFM_Payment_Term__c> paymentTermRec = new List<ASI_MFM_Payment_Term__c>([SELECT ASI_MFM_JP_NumberOfDays__c, Name,ASI_MFM_Fixed_Date__c FROM ASI_MFM_Payment_Term__c WHERE recordType.developerName = 'ASI_MFM_JP_Payment_Term']);
        Map<String,Decimal> mapPaymentTerm = new Map<String,Decimal>();
        Map<String,Decimal> mapPaymentFixedDate = new Map<String,Decimal>();
        for(ASI_MFM_Payment_Term__c obj : paymentTermRec)
        {
            mapPaymentTerm.put(obj.Name, obj.ASI_MFM_JP_NumberOfDays__c);
            if(obj.ASI_MFM_Fixed_Date__c!=null){
                mapPaymentFixedDate.put(obj.Name, obj.ASI_MFM_Fixed_Date__c);
            }
            
        }//for JP, added on 2015-09-10
        
        // Set the Payment ID for new Payment               
        map<id, asi_mfm_prefix__c> px_map = new map<id, asi_mfm_prefix__c>([select name, asi_mfm_next_number__c,ASI_MFM_Company__c,ASI_MFM_Trade__c from asi_mfm_prefix__c 
                                                                            where asi_mfm_module__c = 'Payment' and id in :px_set for update]);
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (px_map.containsKey(p.asi_mfm_prefix__c)) {
                if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH')){
                    if (px_map.get(p.asi_mfm_prefix__c).name.length() == 5){
                        p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 1000).substring(1, 4);
                        px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                    }
                }else {
                    p.name = px_map.get(p.asi_mfm_prefix__c).name + string.valueOf(px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c + 10000).substring(1, 5);
                    px_map.get(p.asi_mfm_prefix__c).asi_mfm_next_number__c++;
                }
                
                //for JP, added on 2015-09-10
                if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP') && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_JP_Payment')){
                    if(p.ASI_MFM_Payment_Term__c != null && p.ASI_MFM_Payment_Term__c.length()>=3 && !mapPaymentTerm.isEmpty()){
                        String tempTerm = p.ASI_MFM_Payment_Term__c.right(3);
                        if(mapPaymentTerm.containsKey(tempTerm)){
                            // if the payment term contains “Month End”, the payment date should be shown as the month end. 
                            if(mapPaymentFixedDate.containsKey(tempTerm)){
                                Date selectedDate= Date.today().addDays(Integer.valueOf(mapPaymentTerm.get(tempTerm)));
                                p.ASI_MFM_JP_Payment_Date__c =  date.newInstance(selectedDate.year(),selectedDate.month(),Integer.valueOf(mapPaymentFixedDate.get(tempTerm))); 
                            }else if(p.ASI_MFM_Payment_Term__c.contains('Month End')){
                                Date selectedDate = Date.today().addDays(Integer.valueOf(mapPaymentTerm.get(tempTerm)));
                                Date firstDate = selectedDate.toStartOfMonth();
                                p.ASI_MFM_JP_Payment_Date__c =firstDate.addDays(date.daysInMonth(selectedDate.year() , selectedDate.month())  - 1);
                            }else{
                                p.ASI_MFM_JP_Payment_Date__c = Date.today().addDays(Integer.valueOf(mapPaymentTerm.get(tempTerm)));
                            }
                            //p.ASI_MFM_JP_Payment_Date__c = Date.today().addDays(Integer.valueOf(mapPaymentTerm.get(tempTerm)));
                        }                            
                        else
                            p.ASI_MFM_JP_Payment_Date__c = Date.today();
                    }
                    else{
                        p.ASI_MFM_JP_Payment_Date__c = Date.today();
                    }//for JP, added on 2015-09-10
                    
                }//for JP MFM, added on 2015-09-10  End
            }
            
            //START :: For TW, update invoice number by Introv @20160715
            if(Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW')){
                if(p.ASI_MFM_Is_Direct_Payment__c && p.ASI_MFM_Invoice_Number__c == NULL)
                    p.ASI_MFM_Invoice_Number__c = p.Name;
            }
            //END :: For TW, update invoice number by Introv @20160715
          
        }
        ASI_MFM_Function.updatePrefix(px_map.values());
        
        //20200619:AM@introv - use plan prefix instead of payment prefix
        assignIsTrade4TW(trigger_new);
    }
    
    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        // Added by Alan Wong (Elufa) 6Feb2015  
        // complete PO and free remaining plan amount for SG AND TH and MY
        // if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG') || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')  || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY')){
        if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')  || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY')){
            Set<ID> paymentIDs = new Set<ID>();
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay.ASI_MFM_Status__c == 'Final' && trigger_oldMap.get(pay.id).ASI_MFM_Status__c == 'Submitted'){
                    paymentIDs.add(pay.id);
                }
            }
            
            // if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_SG') || Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')){
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')){
                List<ASI_MFM_Payment_Line_Item__c> updatepayl = new List<ASI_MFM_Payment_Line_Item__c>();
                List<ASI_MFM_Payment_Line_Item__c> payLineListPOSM = [select id, ASI_MFM_G_L_Date__c,ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDs];
                for(ASI_MFM_Payment_Line_Item__c payline : payLineListPOSM){
                    if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')){
                        if(payline.ASI_MFM_G_L_Date__c == null){
                            payline.ASI_MFM_G_L_Date__c = payline.ASI_MFM_Payment__r.ASI_MFM_G_L_Date__c;
                            updatepayl.add(payline);
                        }
                    }
                }
                if(updatepayl.size()>0){
                    update updatepayl;
                }
            }
            ID Rectypeid;
            if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_TH')) {
                Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('TH PO Line Item').getRecordTypeId();
            }else if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.startsWith('ASI_MFM_MY')) { 
                Rectypeid = Schema.SObjectType.ASI_MFM_PO_Line_Item__c.getRecordTypeInfosByName().get('MY PO Line Item').getRecordTypeId();
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
        // Stop Any users from setting status Complete to final
        User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
        boolean isuserAdmin = prof.profile.name.contains('System Administrator') || prof.UserRole.developername == 'ASI_MFM_TW_System_Administrator';     
        // Get rejection comment when rejected
        set<id> rejected_set = new set<id>();
        map<id, ASI_MFM_Payment__c> reject_map = new map<id, ASI_MFM_Payment__c>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Status__c != trigger_oldMap.get(p.id).ASI_MFM_Status__c && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Complete' && !isuserAdmin)
                p.addError('Cannot change a Complete Payment status to Final or Draft. Please contact the System Administrator.');  
            if (p.ASI_MFM_Status__c == 'Draft' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Submitted') {
                reject_map.put(p.id, p);
            }
            if (p.ASI_MFM_Status__c == 'Submitted' && trigger_oldMap.get(p.id).ASI_MFM_Status__c == 'Draft' && Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_JP')){
                p.ASI_MFM_G_L_Date__c=Date.today();
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
    }        
    public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {

        List<ASI_MFM_Tax_Code__c> TaxCodeList=new List<ASI_MFM_Tax_Code__c>();
        
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_JP') && !ASI_MFM_Function.bypassTriggersFunctionCache('ASI_MFM_JP_Payment')){
            TaxCodeList=[select id,name from ASI_MFM_Tax_Code__c where RecordType.DeveloperName='ASI_MFM_JP_Tax_Code' and ASI_MFM_VAT_Rate__c=0 and ASI_MFM_Inactive__c=false limit 1];
        }
        
        // Recalculate VAT amount, WT amount and insurance amount for Taiwan
        decimal percent;
        for (ASI_MFM_Payment__c pay:trigger_new) {
            // Check if there was an input in the decimal number output error
            boolean isDecimal = 
                (ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_Insurance_Amount__c) || 
                 ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_Payment_Amount__c) ||
                 ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_VAT_Amount__c) ||
                 ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_WT_Amount__c)) && pay.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                pay.addError(' You Cannot input a decimal number for a TWD currency.');
            
            if (Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_TW')){
                if (pay.ASI_MFM_Payment_Amount__c != null) {
                    if (pay.ASI_MFM_Insurance_Amount__c == null ||   (trigger_oldmap != null && pay.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pay.id).ASI_MFM_Payment_Amount__c) || (trigger_oldmap != null && pay.ASI_MFM_Insurance_Percentage__c != trigger_oldmap.get(pay.id).ASI_MFM_Insurance_Percentage__c)) {
                            percent = ASI_MFM_Function.getPercentage(pay.ASI_MFM_Insurance_Percentage__c);
                            if (percent != null) {
                                if (pay.ASI_MFM_Currency__c == 'TWD') {
                                    pay.ASI_MFM_Insurance_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent * -1).setScale(0, roundingmode.half_up);
                                }
                                else {
                                    pay.ASI_MFM_Insurance_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent * -1).setScale(2, roundingmode.half_up);
                                }
                            }
                            else {
                                pay.ASI_MFM_Insurance_Amount__c = null;
                            }
                        }   
                    if (pay.ASI_MFM_VAT_Amount__c == null ||  (trigger_oldmap != null && pay.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pay.id).ASI_MFM_Payment_Amount__c) || (trigger_oldmap != null && pay.ASI_MFM_VAT_Percentage__c != trigger_oldmap.get(pay.id).ASI_MFM_VAT_Percentage__c)) {
                            percent = ASI_MFM_Function.getPercentage(pay.ASI_MFM_VAT_Percentage__c);
                            if (percent != null) {
                                if (pay.ASI_MFM_Currency__c == 'TWD') {
                                    pay.ASI_MFM_VAT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent).setScale(0, roundingmode.half_up);
                                }else {                          
                                    pay.ASI_MFM_VAT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent).setScale(2, roundingmode.half_up);
                                }
                            }else {
                                pay.ASI_MFM_VAT_Amount__c = null;
                            }
                        }
                    if (pay.ASI_MFM_WT_Amount__c == null || (trigger_oldmap != null && pay.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pay.id).ASI_MFM_Payment_Amount__c) || (trigger_oldmap != null && pay.ASI_MFM_WT_Percentage__c != trigger_oldmap.get(pay.id).ASI_MFM_WT_Percentage__c)) {
                            percent = ASI_MFM_Function.getPercentage(pay.ASI_MFM_WT_Percentage__c);
                            if (percent != null) {
                                if (pay.ASI_MFM_Currency__c == 'TWD') {
                                    pay.ASI_MFM_WT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent * -1).setScale(0, roundingmode.half_up);
                                }else {                          
                                    pay.ASI_MFM_WT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent * -1).setScale(2, roundingmode.half_up);
                                }
                            }else {
                                pay.ASI_MFM_WT_Amount__c = null;
                            }
                        }
                }                                       
            }
            
            if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_JP')){// MFM JP Logic: if foreign currency,tax rate=0%
                if(pay.ASI_MFM_Currency__c!=pay.ASI_MFM_Sys_Local_Currency__c){
                    if(TaxCodeList.size()>0){
                        pay.ASI_MFM_Tax_Code__c=TaxCodeList[0].id;
                    }
                }
            }
            
            Set<ID> supplierIDSet = new Set<ID>();
            
            if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_MY') &&  pay.ASI_MFM_Sys_Local_Currency__c!= null){
                if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                    pay.ASI_MFM_Exchange_Rate__c = 1;
                }
            }else if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_JP') &&  pay.ASI_MFM_Sys_Local_Currency__c!= null){
                if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                    pay.ASI_MFM_Exchange_Rate__c = 1;
                }
            }else if (Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_SG')){
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
        
        // Retrieve exchange rate for new payment or when the currency or payment date is changed
        set<id> pay_set = new set<id>();
        set<string> ccy_set = new set<string>(); 
        date last_effective_date;
        
        // Set the approvers for the payment based on the routing rule objects          
        set<id> pid_set = new set<id>();
        set<id> px_set = new set<id>();
        
        set<id> owner_set = new set<id>();
        Set<id> OwnerId = new Set<id>();
        set<id> prefix_set = new set<id>();
        Boolean IsTHPayment= false;
        Map<ID, User> OwnerMap  = new Map<ID,User>();
        list<ASI_MFM_Payment__c> Payment_list = new list<ASI_MFM_Payment__c>();
        
        for (ASI_MFM_Payment__c pay:trigger_new) {
            if (pay.ASI_MFM_Exchange_Rate__c == null || (trigger_oldMap != null && (pay.ASI_MFM_Currency__c != trigger_oldMap.get(pay.id).ASI_MFM_Currency__c || pay.ASI_MFM_Payment_Date__c != trigger_oldMap.get(pay.id).ASI_MFM_Payment_Date__c))) {
                pay_set.add(pay.id);
                ccy_set.add(pay.ASI_MFM_Currency__c);
                if (last_effective_date == null || pay.ASI_MFM_Payment_Date__c > last_effective_date) {
                    last_effective_date = pay.ASI_MFM_Payment_Date__c;
                }
            }
            if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_MY') && pay.ASI_MFM_Invoice_Date__c!=null){
                last_effective_date = pay.ASI_MFM_Invoice_Date__c;
            }
            if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_TH')){
                last_effective_date = pay.ASI_MFM_Invoice_Date__c;
                IsTHPayment = true;
            }
        }
        
        if (pay_set.size() > 0) {
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(8, 10);
            string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;
            
            // Conrad Pantua 20140704 Handle Capex Country (Laputa)
            if (country == 'CA'){
                country = 'HK';
                base_ccy = 'HKD';
            }
            
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
            if(country == 'PH'){
                if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_PH_DF_Payment')){
                    country = 'SG';
                }
            }

            list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
            
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if (pay_set.contains(pay.id)) {
                    if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                        pay.ASI_MFM_Exchange_Rate__c = 1;
                    }
                    else {
                        if(!Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_JP') ){
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
        
        
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Payment_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                pid_set.add(p.id);
                px_set.add(p.ASI_MFM_Prefix__c);
                setApproverToNull(p);
            }
            if (trigger_oldMap == null || p.ownerId != trigger_oldMap.get(p.id).ownerId || p.ASI_MFM_Prefix__c != trigger_oldMap.get(p.id).ASI_MFM_Prefix__c) {
                owner_set.add(p.ownerId);
                prefix_set.add(p.ASI_MFM_Prefix__c);
                Payment_list.add(p);
            }
            OwnerId.add(p.OwnerId);
        }
        if(IsTHPayment){
            OwnerMap  = new Map<ID,User>([SELECT ID, Name,managerId  FROM User WHERE Id in :  OwnerId ]);
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
                // if(!Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW'))
                // {
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
                                }else if (approver_count == 1) {                                 
                                    p.ASI_MFM_Sys_Approver_2__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 2) {                                 
                                    p.ASI_MFM_Sys_Approver_3__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 3) {                                 
                                    p.ASI_MFM_Sys_Approver_4__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 4) {                                 
                                    p.ASI_MFM_Sys_Approver_5__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 5) {                                 
                                    p.ASI_MFM_Sys_Approver_6__c = rd.ASI_MFM_Approver__c;
                                } else if (approver_count == 6) {                                 
                                    p.ASI_MFM_Sys_Approver_7__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 7) {                                 
                                    p.ASI_MFM_Sys_Approver_8__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 8) {                                 
                                    p.ASI_MFM_Sys_Approver_9__c = rd.ASI_MFM_Approver__c;
                                }else if (approver_count == 9) {                                 
                                    p.ASI_MFM_Sys_Approver_10__c = rd.ASI_MFM_Approver__c;
                                }
                                approver_count++;                                                                                                                               
                            }
                            else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                break;
                            }
                        }
                        //   For TH MFM-5 Team USE ONLY                                               Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH') && p.ASI_MFM_TH_Prefix_Name__c=='region'  && p.ASI_MFM_TH_Region__c!=null
                        if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TH') && p.ASI_MFM_TH_Prefix_Name__c==true  && p.ASI_MFM_TH_Region__c!=null){
                            
                            String[] region=p.ASI_MFM_TH_Region__c.split(';');
                            approver_count=0;
                            List<String> approverlist = new List<String>();
                            List<String> tempapproverlist = new List<String>();  // Store the Approver list
                            for (ASI_MFM_Route_Rule_Detail__c rd:rule_list) {
                                if (rd.ASI_MFM_Route_Type__c == rtid && rd.ASI_MFM_Minimum_Amount__c <= local_amount) {
                                    tempapproverlist.add(rd.ASI_MFM_Approver__c);
                                    Boolean isexist=false;
                                    if(rd.ASI_MFM_Region__c != null){
                                        for(String regions:region){
                                            if(regions==rd.ASI_MFM_Region__c){isexist=true;}
                                        }
                                        if(isexist==true){
                                            approverlist.add(rd.ASI_MFM_Approver__c);
                                        }
                                        approver_count++;
                                    }
                                }else if (rd.ASI_MFM_Route_Type__c > rtid) {
                                    break;
                                }
                            }
                            for (Integer i = approver_count;i<tempapproverlist.size();i++){
                                approverlist.add(tempapproverlist[i]);
                            }
                            p.ASI_MFM_Sys_Approver_1__c=null;
                            p.ASI_MFM_Sys_Approver_2__c=null;
                            p.ASI_MFM_Sys_Approver_3__c=null;
                            p.ASI_MFM_Sys_Approver_4__c=null;
                            p.ASI_MFM_Sys_Approver_5__c=null;
                            p.ASI_MFM_Sys_Approver_6__c=null;
                            p.ASI_MFM_Sys_Approver_7__c=null;
                            p.ASI_MFM_Sys_Approver_8__c=null;
                            p.ASI_MFM_Sys_Approver_9__c=null;
                            p.ASI_MFM_Sys_Approver_10__c=null;   
                            
                            integer Countnum=0;
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_1__c=approverlist[0];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_2__c=approverlist[1];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_3__c=approverlist[2];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_4__c=approverlist[3];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_5__c=approverlist[4];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_6__c=approverlist[5];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_7__c=approverlist[6];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_8__c=approverlist[7];
                                Countnum++;
                            }
                            if(Countnum<approverlist.size()){
                                p.ASI_MFM_Sys_Approver_9__c=approverlist[8];
                                Countnum++;
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
        }
        
        
        if (Payment_list.size() > 0  && !Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_KR') ) {
            map<id, user> owner_map = new map<id, user>([select userRole.DeveloperName from user where id in :owner_set]);
            map<id, ASI_MFM_Prefix__c> prefix_map = new map<id, ASI_MFM_Prefix__c>([select (select ASI_MFM_Role_Name__c from ASI_MFM_Role_Prefix_Relationships__r) 
                                                                                    from ASI_MFM_Prefix__c where id in :prefix_set and ASI_MFM_Module__c = 'Payment']);
            for (ASI_MFM_Payment__c p:Payment_list) {
                if (!prefix_map.containsKey(p.ASI_MFM_Prefix__c)) {
                    p.ASI_MFM_Prefix__c.addError('The prefix is not valid for Payment');
                }else {
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
        p.ASI_MFM_Sys_Approver_10__c = null;
        p.ASI_MFM_CN_Finance__c = null;    
        p.ASI_MFM_CN_Return_Approver_1__c = null;
        p.ASI_MFM_CN_Return_Approver_2__c = null;
        p.ASI_MFM_CN_Return_Approver_3__c = null; 
    }
    public static void setApprover(ASI_MFM_Payment__c pm, List<String> approverIdList){
        Integer i = 1;
        String currentApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
        Set<String> approverIdSet = new Set<String>();
        for(String s : approverIdList){
            approverIdSet.add(s);
        }
        approverIdList = new List<String>();
        for(String s : approverIdSet){
            approverIdList.add(s);
        }
        While(Payment_FIELD_MAP.containsKey(currentApprover) && i <= approverIdList.size() && i <= 10){
            pm.put(currentApprover, approverIdList[i - 1]);
            i++;
            currentApprover = 'ASI_MFM_Sys_Approver_' + i + '__c';
        }
    }
    
    //20200619:AM@introv - use plan prefix instead of payment prefix start
    private static void assignIsTrade4TW(list<ASI_MFM_Payment__c> trigger_new) {
        Set<Id> setPlanId = new Set<Id>();
        for (ASI_MFM_Payment__c p:trigger_new) {
        	if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW') && p.ASI_MFM_Plan__c != NULL) setPlanId.add(p.ASI_MFM_Plan__c);
        }
        Map<Id, ASI_MFM_Plan__c> mapPlan = new Map<Id, ASI_MFM_Plan__c>([SELECT Id, ASI_MFM_Prefix__c, ASI_MFM_Prefix__r.ASI_MFM_Trade__c FROM ASI_MFM_Plan__c WHERE Id IN :setPlanId]);
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_TW') && p.ASI_MFM_Plan__c != NULL) {
                if (mapPlan.containsKey(p.ASI_MFM_Plan__c)) {
                    ASI_MFM_Plan__c oPlan = mapPlan.get(p.ASI_MFM_Plan__c);
                    p.ASI_MFM_Trade__c = oPlan.ASI_MFM_Prefix__r.ASI_MFM_Trade__c != NULL ? oPlan.ASI_MFM_Prefix__r.ASI_MFM_Trade__c : FALSE;
                }
            }
        }
    }
    //20200619:AM@introv - use plan prefix instead of payment prefix end
}