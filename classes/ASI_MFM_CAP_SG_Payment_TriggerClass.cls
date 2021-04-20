/***************************************************************************************************************************
 * Name:        ASI_MFM_CAP_SG_Payment_TriggerClass
 * Description: 
 * Test Class: Name:ASI_MFM_CAP_SG_Payment_Test, ASI_MFM_CAP_HK_Payment_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-08-30       Wilken Lee              [WL 1.0] Add Japan BOI logic
 * 2020-02-10       Wilken Lee              [WL 2.0] Change to compare "Payment Amount from Invoice" (round up to integer) and "Good In Transit Amount" for submission
 ****************************************************************************************************************************/
public without sharing class ASI_MFM_CAP_SG_Payment_TriggerClass {
    public static void routineBeforerDelete(list<ASI_MFM_Payment__c> trigger_old) {
        Set<ID> paymentIDSet = new Set<ID>();
        // Delete related PO lines and PO if the payment deleted is OCR or Direct Payment
        for (ASI_MFM_Payment__c payment : trigger_old)
        {
            paymentIDSet.add(payment.id);
        }
        
        if (paymentIDset.size() > 0)
        {
            List<ASI_MFM_PO_Line_Item__c> POLinesToDelete = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO__c> poHeaderToDelete = new List<ASI_MFM_PO__c>();
            
            Set<ID> poIDSet = new Set<ID>();
            Map<ID, Integer> poLineCountMap = new Map<ID, Integer>();
            
            List<ASI_MFM_Payment__c> paymentList = [SELECT ID, Name, 
                                                     (SELECT ID, Name, ASI_MFM_PO_Line_Item__c,
                                                     ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c
                                                     FROM Payment_Line_Items__r)
                                                   FROM ASI_MFM_Payment__c
                                                   WHERE ID IN : paymentIDSET];
            
           
            for (ASI_MFM_Payment__c payment : paymentList)
            {
                List<ASI_MFM_Payment_Line_Item__c> paymentLineList = payment.Payment_Line_Items__r;
                for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList)
                {
                    ASI_MFM_PO_Line_Item__c poLine = new ASI_MFM_PO_Line_Item__c(ID = paymentLine.ASI_MFM_PO_Line_Item__c);
                    POLinesToDelete.add(poLine);
                    poIDSet.add(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                    if(poLineCountMap.containskey(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c))
                    {
                        Integer count = poLineCountMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                        count++;
                        poLineCountMap.put(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, count);
                    }
                    else
                    {
                        poLineCountMap.put(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c, 1);
                    }
                }
            }
            
            Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name,
                                                                        (SELECT ID, Name FROM PO_Line_Items__r)
                                                                      FROM ASI_MFM_PO__c
                                                                      WHERE ID IN: poIDSet]);
            Set<ID> POToDeleteSet = new Set<ID>();
            for (ASI_MFM_Payment__c payment : paymentList)
            {
                List<ASI_MFM_Payment_Line_Item__c> paymentLineList = payment.Payment_Line_Items__r;
                for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList)
                {
                    ASI_MFM_PO__c po = poMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                    Integer poLineCount = poLineCountMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                    if (po.PO_Line_Items__r.size() == poLineCount)
                    {
                        POToDeleteSet.add(po.id);
                    }
                }
            }
            
            for(ID poID : POToDeleteSet)
            {
                ASI_MFM_PO__c po = new ASI_MFM_PO__c(ID=poID);
                poHeaderToDelete.add(po);
            }                            
            
            Set<ID> poLinesToDeleteSet = new Set<ID>();
            Set<ID> poHeaderToDeleteSet = new Set<ID>();
            List<ASI_MFM_PO_Line_Item__c> cleanPOLinesToDelete = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO__c> cleanPOHeaderToDelete = new List<ASI_MFM_PO__c>();
            
            for(ASI_MFM_PO_Line_Item__c poLine : POLinesToDelete)
            {
                if(!poLinesToDeleteSet.contains(poLine.id))
                {
                    cleanPOLinesToDelete.add(poLine);
                }
                poLinesToDeleteSet.add(poLine.id);
            }
            
            for(ASI_MFM_PO__c poHeader : poHeaderToDelete)
            {
                if(!poHeaderToDeleteSet.contains(poHeader.id))
                {
                    cleanPOHeaderToDelete.add(poHeader);
                }
                poHeaderToDeleteSet.add(poHeader.id);
            }
            
            
            if (POLinesToDelete.size() > 0)
                delete cleanPOLinesToDelete;
            if (poHeaderToDelete.size() > 0)
                delete cleanPOHeaderToDelete;                        
            
        }
    
        for (ASI_MFM_Payment__c pa : trigger_old)
        {
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete')
                 pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
        }
    }

    public static void routineAfterDelete(list<ASI_MFM_Payment__c> trigger_old) {
// Delete Payment in Data Warehouse
        if (!ASI_MFM_Function.bypassCallouts()) {
            list<id> pid_list = new list<id>();
            for (ASI_MFM_Payment__c p:trigger_old) {
                pid_list.add(p.id);
            }
        }           
    }

    public static void routineAfterUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        //Removed by Laputa Hugo Cheung 21-06-2016
        //Reason : The following codes are unused.
        /*
        // Pass Payment and line item details to Data Warehouse
        if (!ASI_MFM_Function.bypassCallouts()) {       
            set<id> pid_set = new set<id>();
            for (ASI_MFM_Payment__c p:trigger_new) {
                if (trigger_oldMap == null || p.ASI_MFM_Sys_Sync_Time__c == trigger_oldMap.get(p.id).ASI_MFM_Sys_Sync_Time__c) {
                    pid_set.add(p.id);
                }               
            }

        }
        Set<ID> paymentIDSet = new Set<ID>();
        for(ASI_MFM_Payment__c payment : trigger_new)
        {
            if(trigger_oldMap != null)
            {
                if(trigger_oldMap.get(payment.id).ASI_MFM_Remarks__c != payment.ASI_MFM_Remarks__c || 
                    trigger_oldMap.get(payment.id).ASI_MFM_AP_Code__c != payment.ASI_MFM_AP_Code__c)
                    paymentIDSet.add(payment.id);
            }
            else
                paymentIdSet.add(payment.id);
        }
        */
        
        /* Wilken 20150511, move the function to AfterUpdate to avoid looping validation check for duplicate invoice number due to the payment line is updated twice when user save the Payment
        Map<ID, ASI_MFM_Payment__c> paymentMap = new Map<ID, ASI_MFM_Payment__c>([SELECT ID, Name, ASI_MFM_Remarks__c, 
                                                                                (SELECT ID, Name, ASI_MFM_Payment_List_Item_Description__c FROM Payment_Line_Items__r)
                                                                                FROM ASI_MFM_Payment__c WHERE ID IN : paymentIdSet]);
                                                                                
        List<ASI_MFM_Payment_Line_Item__c> paymentLineItemToUpdate = new List<ASI_MFM_Payment_Line_Item__c>();                                                                     
        for(ASI_MFM_Payment__c payment : trigger_new)
        {
            if(paymentmap.get(payment.id) != null)
            {
                List<ASI_MFM_Payment_Line_Item__c> paymentLineList = paymentmap.get(payment.id).Payment_Line_Items__r;
                for(ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList)
                {
                    boolean paymentLineUpdate = false;
                    if(payment.ASI_MFM_OCR__c || payment.ASI_MFM_Is_Direct_Payment__c)
                    {
                        paymentLine.ASI_MFM_Payment_List_Item_Description__c = paymentmap.get(payment.id).ASI_MFM_Remarks__c;
                        paymentLineUpdate = true;
                    }
                    if(trigger_oldMap != null)
                    {
                        if(trigger_oldMap.get(payment.id).ASI_MFM_AP_Code__c != payment.ASI_MFM_AP_Code__c)
                        {
                            paymentLine.ASI_MFM_AP_Code__c = payment.ASI_MFM_AP_Code__c;
                            paymentLineUpdate = true;
                        }
                    }
                    if(paymentLineUpdate)
                        paymentLineItemToUpdate.add(paymentLine);
                }
            }
        }
        
        if(paymentLineItemToUpdate.size() > 0)
            update paymentLineItemToUpdate;
        */
    }

    public static void routineBeforeInsert(list<ASI_MFM_Payment__c> trigger_new) {
        set<id> px_set = new set<id>();
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.asi_mfm_prefix__c != null) {
                px_set.add(p.asi_mfm_prefix__c);
            }
            // @DC - 7-Dec-2015 - Set field values when the current record is a cloned record
            if(p.getCloneSourceId() != null) {
                p.ASI_MFM_Status__c = 'Draft';
                p.ASI_MFM_Plan__c = null;
                p.ASI_MFM_ETL__c = false;
                p.ASI_MFM_Is_Direct_Payment__c = false;
                p.ASI_MFM_OCR__c = false;
                p.ASI_MFM_Payment_External_ID__c = null;
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
        // CAPEX Logic: Implement the mass submit for approval trigger for the list view
        
        String CAPEX_BUCodeDefault;
        String OPEX_BUCodeDefault;
        
        Map<String, ASI_MFM_Default_Value__c> companyCodeMFMDefaultMap = new Map<String, ASI_MFM_Default_Value__c>();
        
        for(ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()){
            // CAPEX: set the capex bu code default
            if (setting.name == 'CAP_CAPEX_BU_Code__c' && Setting.Country__c == 'SG') {
                CAPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
            // OPEX: set the opex bu code default
            if (setting.name == 'CAP_OPEX_BU_Code__c' && Setting.Country__c == 'SG') {
                OPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
            
            if(Setting.Name.startsWithIgnoreCase('CAP_HK_BU_') &&
               Setting.Country__c == 'HK' &&
               Setting.ASI_MFM_Object__c == 'ASI_MFM_Payment_Line_Item__c') {
                companyCodeMFMDefaultMap.put(Setting.Name, Setting);
            }
        }
        
        List<ASI_MFM_Payment__c> paymentToUpdateList = new List<ASI_MFM_Payment__c>();//WL 1.0
        
        for(ASI_MFM_Payment__c payment : trigger_new){            
            //Update Payment Header Supplier (i.e. Payee), Invoice Date and Invoice Number into detail lines
            if (payment.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(payment.id).ASI_MFM_Invoice_Number__c 
                || payment.ASI_MFM_Invoice_Date__c != trigger_oldMap.get(payment.id).ASI_MFM_Invoice_Date__c 
                    || payment.ASI_MFM_Supplier_Name__c != trigger_oldMap.get(payment.id).ASI_MFM_Supplier_Name__c
                        || payment.ASI_MFM_Payment_Type__c != trigger_oldMap.get(payment.id).ASI_MFM_Payment_Type__c
                            || payment.ASI_MFM_AP_Code__c != trigger_oldMap.get(payment.id).ASI_MFM_AP_Code__c
//                                    || payment.ASI_MFM_Exchange_Rate__c != trigger_oldMap.get(payment.id).ASI_MFM_Exchange_Rate__c
                                        || payment.ASI_MFM_Company_Code__c != trigger_oldMap.get(payment.id).ASI_MFM_Company_Code__c){
                List<ASI_MFM_Payment_Line_Item__c> itemList = [select ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Payee__c, ASI_MFM_BU__c, ASI_MFM_AP_Code__c, ASI_MFM_A_C_Code__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :payment.id];
                
                for (ASI_MFM_Payment_Line_Item__c item:itemList){
                    item.ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c;
                    item.ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c;
                    item.ASI_MFM_Payee__c = payment.ASI_MFM_Supplier_Name__c;
                    //item.ASI_MFM_AP_Code__c = payment.ASI_MFM_AP_Code__c;
                    
                    //Added by Laputa Hugo Cheung 21-06-2016
                    //Reason : Only SG payment record need to set default BU code
                    if(Global_RecordTypeCache.getRt(payment.RecordTypeId).developerName.contains('ASI_MFM_CAP_SG')) {
                        //Added by Wilken on 20150122, only update default BU if Payment Type is changed
                        if (payment.ASI_MFM_Payment_Type__c != trigger_oldMap.get(payment.id).ASI_MFM_Payment_Type__c){
                            if (payment.ASI_MFM_Payment_Type__c == 'CAPEX'){
                                item.ASI_MFM_BU__c = CAPEX_BUCodeDefault;
                            }
                            else if (payment.ASI_MFM_Payment_Type__c == 'OPEX'){
                                item.ASI_MFM_BU__c = OPEX_BUCodeDefault;
                            }
                        }
                    }
                    
                    //Added by Laputa Hugo Cheung 21-06-2016
                    //Reason : For HK record, assign the BU code depend on company code
                    if(Global_RecordTypeCache.getRt(payment.RecordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
                        if(companyCodeMFMDefaultMap.containsKey('CAP_HK_BU_' + payment.ASI_MFM_Company_Code__c)) {
                            item.ASI_MFM_BU__c = companyCodeMFMDefaultMap.get('CAP_HK_BU_' + payment.ASI_MFM_Company_Code__c).ASI_MFM_Value__c;
                        }
                    }   
                }
                
                try {
                    update itemList;
                }
                catch (System.DmlException e)
                {
                    payment.addError(e.getDmlMessage(0));
                }
            }
            
            //Checking before submit payment for approval
            System.debug('Original Payment Status: ' + trigger_oldMap.get(payment.id).ASI_MFM_Status__c + ' New Status: ' + payment.ASI_MFM_Status__c + ' Approved?: ' + payment.ASI_MFM_Approved__c);
             
            if(payment.ASI_MFM_Status__c == 'Submitted' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Draft'){
                /* Added by Laputa (Hector)
                    CAPEX/OPEX: 3-way matching
                        Scope: RecordType = ASI_MFM_CAP_HK
                        After Submit: Create PO Receipt and PO Receipt Line from PO
                        After Approval: Create Payment Line from PO Receipt Line
                */
                
                
                 
                List<ASI_MFM_Payment_Line_Item__c> itemList = [SELECT ASI_MFM_Invoice_Date__c, 
                                                                    ASI_MFM_Invoice_Number__c, 
                                                                    ASI_MFM_Payee__c, 
                                                                    ASI_MFM_BU__c, 
                                                                    ASI_MFM_A_C_Code__c, 
                                                                    ASI_MFM_AP_Code__c, 
                                                                    ASI_MFM_Payment_Amount__c 
                                                                FROM ASI_MFM_Payment_Line_Item__c 
                                                                WHERE ASI_MFM_Payment__c = :payment.id];

                //Validate all mandatory fields in payment line has value
                for (ASI_MFM_Payment_Line_Item__c payline:itemList){
                    if (payline.ASI_MFM_Invoice_Date__c == null){
                        payment.adderror('Please enter Invoice Date');
                    }
                    else if (payline.ASI_MFM_Invoice_Number__c == null){
                        payment.adderror('Please enter Invoice Number');
                    }
                    else if (payline.ASI_MFM_Payee__c == null){
                        payment.adderror('Please enter Supplier Name');
                    }
                    else if (payline.ASI_MFM_A_C_Code__c == null){
                        payment.adderror('Please enter A/C Code');
                    }
                    //Added by Laputa Hugo Cheung 21-06-2016
                    //Reason : Only SG record need to have AP code
                    else if (payline.ASI_MFM_AP_Code__c == null && 
                             Global_RecordTypeCache.getRt(payment.RecordTypeId).developerName.contains('ASI_MFM_CAP_SG')){
                        payment.adderror('Please enter AP Code');
                    }
                }
            }
            
            /*[WL 1.0] BEGIN*/
            //JP BOI auto submit when status changes from ETL fill in Goods In Transit Amount which matches with Payment Line amount
            
            if(Global_RecordTypeCache.getRt(payment.RecordTypeId).developerName.contains('ASI_MFM_CAP_JP') 
                && !payment.ASI_MFM_Approved__c && payment.ASI_MFM_Status__c == 'Draft'
                && payment.ASI_MFM_Goods_In_Transit_Amount__c != null 
                    && payment.ASI_MFM_Goods_In_Transit_Amount__c != trigger_oldMap.get(payment.id).ASI_MFM_Goods_In_Transit_Amount__c) {
                
                //if (payment.ASI_MFM_Goods_In_Transit_Amount_SFDC__c == payment.ASI_MFM_Goods_In_Transit_Amount__c){ //WL 2.0
                if (payment.ASI_MFM_Payment_Amt_Inv__c.round(System.RoundingMode.HALF_UP) == payment.ASI_MFM_Goods_In_Transit_Amount__c){   //WL 2.0
                    try {
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setObjectId(payment.id);
                        Approval.ProcessResult result = Approval.process(req1);
                        
                        if (!result.isSuccess())
                        {
                            payment.addError('Payment ' + payment.name + ' failed for submit for approval.');
                        }
                    }
                    catch (System.DmlException e){
                        payment.addError(e.getDmlMessage(0));
                    }
                }
                else {
                    ASI_MFM_Payment__c paymentUpdate = new ASI_MFM_Payment__c();
                    paymentUpdate.Id = payment.Id;
                    paymentUpdate.ASI_MFM_Web_Service_Failed__c = true;
                    paymentToUpdateList.add(paymentUpdate);
                }
            }
            /*[WL 1.0] END*/
        }
        
        /*[WL 1.0] BEGIN*/
        if (paymentToUpdateList.size() > 0)
            update paymentToUpdateList;
        /*[WL 1.0] END*/
    }
    
    
    public static void routineBeforeUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        System.debug('Start Payment routineBeforeUpdate');
        // CAPEX Logic: Implement the mass submit for approval trigger for the list view
               
        for(ASI_MFM_Payment__c payment : trigger_new)
        {
            if(payment.ASI_MFM_Status__c == 'Submitted' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c != payment.ASI_MFM_Status__c 
                && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Draft' && !payment.ASI_MFM_Approved__c
                && !Global_RecordTypeCache.getRt(payment.recordTypeId).developerName.contains('ASI_MFM_CAP_HK'))
            {
                try
                {
                    if (payment.ownerid != userinfo.getuserid())
                    {
                        payment.ASI_MFM_Sys_Approver_1__c = payment.ownerid;
                    }
                }
                catch (System.DmlException e)
                {
                    payment.addError(e.getDmlMessage(0));
                }
            }
        }
        
        // Stop Any users from setting status Complete to final
        
        
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
                    reject_map.get(r.id).ASI_MFM_Sys_Rejected__c = true;
                    reject_map.get(r.id).ASI_MFM_Sys_Reject_Comments__c = r.processSteps[0].comments;
                }
            }
        }
        
    }
        
   public static void routineBeforeUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        decimal percent;
        
        User prof = [select id, Name, Profile.name, Profile.id, UserRole.developername from User where Id = :UserInfo.getUserId() ];
        boolean isuserAdmin = prof.profile.name.contains('System Administrator');
        
        Set<ID> supplierID = new Set<ID> ();
        Set<String> allInvoice = new Set<String>();
        //Recalculate Payment Amount when freight cost is changed
        Set<ID> paymentIDSet = new Set<ID>();

        for (ASI_MFM_Payment__c pay:trigger_new) {
            if(trigger_oldMap == null) {
                supplierID.add(pay.ASI_MFM_Supplier_Name__c);
                paymentIDSet.add(pay.id);
            }
            else if(trigger_oldMap.get(pay.id).ASI_MFM_Invoice_Number__c != pay.ASI_MFM_Invoice_Number__c) {
                supplierID.add(pay.ASI_MFM_Supplier_Name__c);
            }  
        }

        if(paymentIDSet.size() > 0) {
            Map<ID, ASI_MFM_Payment__c> paymentHeaderMap = new Map<ID, ASI_MFM_Payment__c> ([SELECT ID, Name, (SELECT ID, Name, ASI_MFM_Payment_Amount__c FROM Payment_Line_Items__r)
                                                                                                FROM ASI_MFM_Payment__c
                                                                                                WHERE ID IN : paymentIDSet]);

            for(ASI_MFM_Payment__c pay:trigger_new) {
                
                if(paymentHeaderMap.containsKey(pay.id)) {

                    Decimal paymentAmountLines = 0;
                    List<ASI_MFM_Payment_Line_Item__c> paymentLineItemList = paymentHeaderMap.get(pay.id).Payment_Line_Items__r;
                    for(ASI_MFM_Payment_Line_Item__c paymentItem : paymentLineItemList) {
                        paymentAmountLines += paymentItem.ASI_MFM_Payment_Amount__c != null ? paymentItem.ASI_MFM_Payment_Amount__c : 0;
                    }
                    pay.ASI_MFM_Payment_Amount__c = paymentAmountLines;
                }
            }
        }
        Map<ID, Account> supplierMap = new Map<ID, Account>();
        //Added by Laputa Hugo Cheung 21-06-2016
        //Reason : Dynamic select the payment record with different record type
        String countryCode = 'SG';
        if(supplierID.size() > 0)
        {
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
                countryCode = 'HK';
            } else if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')) {
                countryCode = 'TH';
            } else if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_JP')) {
                countryCode = 'JP';
            }
            
            
            supplierMap = new Map<ID, Account>([SELECT ID, Name, recordtype.developername FROM Account WHERE ID IN : supplierID]);
            
            String recordTypeName = 'ASI_MFM_CAP_' + countryCode + '%';
            List<ASI_MFM_Payment__c> paymentSameSupplier = [SELECT ID, Name, ASI_MFM_Invoice_Number__c, ASI_MFM_Supplier_Name__c 
                                                            FROM ASI_MFM_Payment__c 
                                                            WHERE ASI_MFM_Supplier_Name__c IN: supplierID 
                                                            AND recordtype.developername LIKE :recordTypeName];
            
            for(ASI_MFM_Payment__c payment : paymentSameSupplier)
            {
                if(payment.ASI_MFM_Invoice_Number__c != null)
                    allInvoice.add(payment.ASI_MFM_Invoice_Number__c);
            }
        }
        
        for (ASI_MFM_Payment__c pay:trigger_new) {
            //Added by Laputa Hugo Cheung 21-06-2016
            //Reason : Dynamic show the supplier error with different record type
            //Temp Disabled for testing
            if(supplierMap.containsKey(pay.ASI_MFM_Supplier_Name__c)) {
                if(supplierMap.get(pay.ASI_MFM_Supplier_Name__c).recordtype.developername != 'ASI_MFM_CAP_' + countryCode + '_Supplier') {
                    pay.ASI_MFM_Supplier_Name__c.adderror('Must select Supplier with CAP ' + countryCode + ' Supplier recordtype.');
                }
            }
        
            if(allInvoice.size() > 0)
            {
                if(allInvoice.contains(pay.ASI_MFM_Invoice_Number__c) && !isuserAdmin)
                {
                    pay.adderror('Cannot have duplicate Invoice Number under the same Supplier');
                }
            }
            // Check if there was an input in the decimal number output error
            boolean isDecimal = 
            (ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_Insurance_Amount__c) || 
            ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_Payment_Amount__c) ||
            ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_VAT_Amount__c) ||
            ASI_MFM_Function.containsDecimalValue(pay.ASI_MFM_WT_Amount__c)) && pay.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                pay.addError(' You Cannot input a decimal number for a TWD currency.');
              
            if (Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_TW') || Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_CAP')){
                if (pay.ASI_MFM_Payment_Amount__c != null) {
                    if (pay.ASI_MFM_Insurance_Amount__c == null || 
                        (trigger_oldmap != null && pay.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pay.id).ASI_MFM_Payment_Amount__c) ||
                        (trigger_oldmap != null && pay.ASI_MFM_Insurance_Percentage__c != trigger_oldmap.get(pay.id).ASI_MFM_Insurance_Percentage__c)) {
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
                    if (pay.ASI_MFM_VAT_Amount__c == null || 
                        (trigger_oldmap != null && pay.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pay.id).ASI_MFM_Payment_Amount__c) ||
                        (trigger_oldmap != null && pay.ASI_MFM_VAT_Percentage__c != trigger_oldmap.get(pay.id).ASI_MFM_VAT_Percentage__c)) {
                        percent = ASI_MFM_Function.getPercentage(pay.ASI_MFM_VAT_Percentage__c);
                        if (percent != null) {
                            if (pay.ASI_MFM_Currency__c == 'TWD') {
                                pay.ASI_MFM_VAT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent).setScale(0, roundingmode.half_up);
                            }
                            else {                          
                                pay.ASI_MFM_VAT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent).setScale(2, roundingmode.half_up);
                            }
                        }
                        else {
                            pay.ASI_MFM_VAT_Amount__c = null;
                        }
                    }
                    if (pay.ASI_MFM_WT_Amount__c == null || 
                        (trigger_oldmap != null && pay.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pay.id).ASI_MFM_Payment_Amount__c) ||
                        (trigger_oldmap != null && pay.ASI_MFM_WT_Percentage__c != trigger_oldmap.get(pay.id).ASI_MFM_WT_Percentage__c)) {
                        percent = ASI_MFM_Function.getPercentage(pay.ASI_MFM_WT_Percentage__c);
                        if (percent != null) {
                            if (pay.ASI_MFM_Currency__c == 'TWD') {
                                pay.ASI_MFM_WT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent * -1).setScale(0, roundingmode.half_up);
                            }
                            else {                          
                                pay.ASI_MFM_WT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent * -1).setScale(2, roundingmode.half_up);
                            }
                        }
                        else {
                            pay.ASI_MFM_WT_Amount__c = null;
                        }
                    }
                }                                       
            }
        }
     

        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_SG') ) {
            // Retrieve exchange rate for new payment or when the currency or payment date is changed
            set<id> pay_set = new set<id>();
            set<string> ccy_set = new set<string>(); 
            date last_effective_date;
            Set<String> paymentTypeSet = new Set<String>();
            for (ASI_MFM_Payment__c pay:trigger_new) {
                if(pay.ASI_MFM_Payment_Type__c != null) {
                    paymentTypeSet.add(pay.ASI_MFM_Payment_Type__c);                
                }
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
                string country = 'SG';
                string base_ccy = trigger_new[0].ASI_MFM_Sys_Local_Currency__c;
            
                list<ASI_MFM_Exchange_Rate__c> xr_list = [select ASI_MFM_Counter_Currency__c, ASI_MFM_Effective_Date__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                    where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Country__c = :country and ASI_MFM_Base_Currency__c = :base_ccy
                    and ASI_MFM_Counter_Currency__c in :ccy_set and ASI_MFM_Effective_Date__c <= :last_effective_date
                    order by ASI_MFM_Counter_Currency__c asc, ASI_MFM_Effective_Date__c desc];
                for (ASI_MFM_Payment__c pay:trigger_new) {
                    if (pay_set.contains(pay.id)) {
                        if (pay.ASI_MFM_Currency__c == pay.ASI_MFM_Sys_Local_Currency__c) {
                            pay.ASI_MFM_Exchange_Rate__c = 1;
                        }else {
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
        }
    
        //Added by Laputa Hugo Cheung 21-06-2016
        //Reason : Auto populate approver for HK record
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
            populateApprover(trigger_new, trigger_oldMap);
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
    //Set the payment approver
    private static void populateApprover(List<ASI_MFM_Payment__c> paymentList, Map<Id, ASI_MFM_Payment__c> oldPaymentMap) {
        
        //Collect the company code and payment type 
        Set<String> companyCodeSet = new Set<String>();
        Set<String> paymentTypeSet = new Set<String>();
                 
        for(ASI_MFM_Payment__c pay : paymentList) {
            
            if(oldPaymentMap == null || 
               oldPaymentMap.get(pay.Id).OwnerId != pay.OwnerId || 
               oldPaymentMap.get(pay.Id).ASI_MFM_Payment_Amount_FX__c != pay.ASI_MFM_Payment_Amount_FX__c ||
               oldPaymentMap.get(pay.Id).ASI_MFM_Company_Code__c != pay.ASI_MFM_Company_Code__c) {
                
                //Reset both approver
                pay.ASI_MFM_Sys_Approver_1__c = null;
                pay.ASI_MFM_Sys_Approver_2__c = null;
                pay.ASI_MFM_Sys_Approver_3__c = null;
                pay.ASI_MFM_Sys_Approver_4__c = null;
                pay.ASI_MFM_Sys_Approver_5__c = null;
                pay.ASI_MFM_Sys_Approver_6__c = null;
                pay.ASI_MFM_Sys_Approver_7__c = null;
                pay.ASI_MFM_Sys_Approver_8__c = null;
    
                if(pay.ASI_MFM_Payment_Type__c != null) {
                    companyCodeSet.add(pay.ASI_MFM_Company_Code__c);
                    paymentTypeSet.add(pay.ASI_MFM_Payment_Type__c);                
                }
            }
        }
    
        if(companyCodeSet.size() != 0 && paymentTypeSet.size() != 0) {
            
            ID CAPEXRouteTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_CAP_HK_Route_Type');
            
            //Collect the route type record from ASI_MFM_Route_Type__c object with condition
            //Record Type = 'ASI_MFM_CAP_HK_Route_Type'
            //Country = 'HK'
            //Module = 'Payment'
            //Type must inside set paymentTypeSet and not equal to null
            //Company code must inside companyCodeSet and not equal to null
            List<ASI_MFM_Route_Type__c> routeTypeList = [SELECT ID, Name, ASI_MFM_Country__c, ASI_MFM_Module__c, ASI_MFM_Type__c, ASI_MFM_Company_Code__c, ASI_MFM_Sales_Route_Type_Amount_From__c, ASI_MFM_Sales_Route_Type_Amount_To__c,
                                                            (SELECT ID, Name, ASI_MFM_Minimum_Amount__c, ASI_MFM_Approver__c FROM ASI_MFM_Route_Rule_Details__r ORDER BY ASI_MFM_Sequence__c ASC)
                                                                 FROM ASI_MFM_Route_Type__c
                                                                    WHERE 
                                                                    recordtypeid = : CAPEXRouteTypeID
                                                                    AND ASI_MFM_Country__c = : 'HK' 
                                                                    AND ASI_MFM_Module__c = 'Payment'
                                                                    AND ASI_MFM_Type__c IN : paymentTypeSet
                                                                    AND ASI_MFM_Type__c <> NULL
                                                                    AND ASI_MFM_Company_Code__c IN : companyCodeSet
                                                                    AND ASI_MFM_Company_Code__c <> NULL];
    
            //Convert the route type record to a map
            Map<String, List<ASI_MFM_Route_Type__c>> routeTypeCompanyCodeMap = new Map<String, List<ASI_MFM_Route_Type__c>>();
    
            for(ASI_MFM_Route_Type__c routeType : routeTypeList) {
    
                List<ASI_MFM_Route_Type__c> tempRouteTypeList;
    
                if(routeTypeCompanyCodeMap.containsKey(routeType.ASI_MFM_Type__c + routeType.ASI_MFM_Company_Code__c)) {
    
                    tempRouteTypeList = routeTypeCompanyCodeMap.get(routeType.ASI_MFM_Type__c + routeType.ASI_MFM_Company_Code__c);
    
                } else {
    
                    tempRouteTypeList = new List<ASI_MFM_Route_Type__c>();
    
                }
    
                tempRouteTypeList.add(routeType);
                routeTypeCompanyCodeMap.put(routeType.ASI_MFM_Type__c + routeType.ASI_MFM_Company_Code__c, tempRouteTypeList);
    
            }                                                        
    
            if (routeTypeList.size() > 0) {
    
                for (ASI_MFM_Payment__c pay : paymentList) {
    
                    if(routeTypeCompanyCodeMap.containsKey(pay.ASI_MFM_Payment_Type__c + pay.ASI_MFM_Company_Code__c)) {
    
                        List<ASI_MFM_Route_Type__c> tempRouteTypeList = routeTypeCompanyCodeMap.get(pay.ASI_MFM_Payment_Type__c + pay.ASI_MFM_Company_Code__c);
    
                        for(ASI_MFM_Route_Type__c routeType : tempRouteTypeList) {
    
                            List<ASI_MFM_Route_Rule_Detail__c> routeDetailsList = routeType.ASI_MFM_Route_Rule_Details__r;
    
                            //If the from or to amount not null
                            if(routeType.ASI_MFM_Sales_Route_Type_Amount_From__c != null ||
                               routeType.ASI_MFM_Sales_Route_Type_Amount_To__c != null) {
    
                                Boolean withinFromToAmount = false;
    
                                //Check payment amount is between from and to ammount
                                if(routeType.ASI_MFM_Sales_Route_Type_Amount_From__c == null) {
                                    
                                    if(pay.ASI_MFM_Payment_Amount_FX__c <= routeType.ASI_MFM_Sales_Route_Type_Amount_To__c) {    
                                        withinFromToAmount = true;    
                                    }    
                                } else if (routeType.ASI_MFM_Sales_Route_Type_Amount_To__c == null) {    
                                    if(pay.ASI_MFM_Payment_Amount_FX__c >= routeType.ASI_MFM_Sales_Route_Type_Amount_From__c) {    
                                        withinFromToAmount = true;    
                                    }    
                                }
    
                                else {    
                                    if (pay.ASI_MFM_Payment_Amount_FX__c >= routeType.ASI_MFM_Sales_Route_Type_Amount_From__c && 
                                        pay.ASI_MFM_Payment_Amount_FX__c <= routeType.ASI_MFM_Sales_Route_Type_Amount_To__c) {    
                                        withinFromToAmount = true;    
                                    }    
                                }
    
                                //If the payment amount is between from and to amount, assign the approver
                                if(withinFromToAmount) {    
                                    integer approver_count = 0;
    
                                    for (ASI_MFM_Route_Rule_Detail__c routeDetail : routeDetailsList) {    
                                        if (approver_count == 0) {    
                                            pay.ASI_MFM_Sys_Approver_1__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 1) {     
                                            pay.ASI_MFM_Sys_Approver_2__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 2) {    
                                            pay.ASI_MFM_Sys_Approver_3__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 3) {     
                                            pay.ASI_MFM_Sys_Approver_4__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 4) {    
                                            pay.ASI_MFM_Sys_Approver_5__c = routeDetail.ASI_MFM_Approver__c;                                        
                                        } else if (approver_count == 5) {              
                                            pay.ASI_MFM_Sys_Approver_6__c = routeDetail.ASI_MFM_Approver__c;                                        
                                        } else if (approver_count == 6) {     
                                            pay.ASI_MFM_Sys_Approver_7__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 7) {                                     
                                            pay.ASI_MFM_Sys_Approver_8__c = routeDetail.ASI_MFM_Approver__c;    
                                        }                   
                                        approver_count++;    
                                    }    
                                }
                                
                            //If the from and to amount is null
                            } else {
    
                                integer approver_count = 0;
    
                                //Assign approver if the payment amount is higher or equal to route detail min amount
                                for (ASI_MFM_Route_Rule_Detail__c routeDetail : routeDetailsList) {
    
                                    if(pay.ASI_MFM_Payment_Amount_FX__c >= routeDetail.ASI_MFM_Minimum_Amount__c) {    
                                        if (approver_count == 0) {    
                                            pay.ASI_MFM_Sys_Approver_1__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 1) {     
                                            pay.ASI_MFM_Sys_Approver_2__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 2) {    
                                            pay.ASI_MFM_Sys_Approver_3__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 3) {     
                                            pay.ASI_MFM_Sys_Approver_4__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 4) {    
                                            pay.ASI_MFM_Sys_Approver_5__c = routeDetail.ASI_MFM_Approver__c;                                            
                                        } else if (approver_count == 5) {              
                                            pay.ASI_MFM_Sys_Approver_6__c = routeDetail.ASI_MFM_Approver__c;                                            
                                        } else if (approver_count == 6) {     
                                            pay.ASI_MFM_Sys_Approver_7__c = routeDetail.ASI_MFM_Approver__c;    
                                        } else if (approver_count == 7) {                                     
                                            pay.ASI_MFM_Sys_Approver_8__c = routeDetail.ASI_MFM_Approver__c;    
                                        }                   
                                        approver_count++;    
                                    }    
                                }    
                            }
    
                        }
                    }    
                }    
            }
        }
    }
}