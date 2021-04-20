/*********************************************************************************
 * Name:ASI_MFM_CAP_PaymentLineItem_TriggerClass
 * Description: 
 * Test Class:  ASI_MFM_CAP_Payment_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/07/2019       Wilken                  [WL 1.0] Payment Line Item Exchange Rate should based on Payment Header Payment Date instead of current date
 * 21/10/2019       Wilken                  [WL 2.0] Populate Paid Amount in Base Currency field for PO Line roll-up summary
 * 
*********************************************************************************/
public without sharing class ASI_MFM_CAP_PaymentLineItem_TriggerClass {
    
    // @author: DC  @ModifiedDate: 03-Dec-2015
    // @comment: Added logic for validation of record type of sub-brand related to current record.
    public static Boolean checkValidRecordType(list<ASI_MFM_Payment_Line_Item__c> trigger_new) {
        
        set<id> pliId_set = new set<id>();
        Boolean result = true;
        
        //Added by Laputa Hugo Cheung 21-06-2016
        //Reason : Dynamic select the country with different record type
        String countryCode = 'SG';
        String subBrandRecordType = 'ASI_CRM_SG_Sub_brand';
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
            countryCode = 'HK';
            subBrandRecordType = 'ASI_HK_CRM_Sub_brand';
        } else if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')) {
            countryCode = 'TH';
            subBrandRecordType = 'ASI_TH_CRM_Sub_brand';
        }
        
        for(ASI_MFM_Payment_Line_Item__c lineItemIterator : trigger_new) {
            pliId_set.add(lineItemIterator.Id);
        }
        
        String recordTypeName = 'ASI_MFM_CAP_' + countryCode + '_Payment_Line_Item';
        
        map<Id, RecordType> id_PliRtMap = new map<Id, RecordType>(
            [SELECT Id,
                    DeveloperName
               FROM RecordType
              WHERE SobjectType = 'ASI_MFM_Payment_Line_Item__c'
                AND DeveloperName = :recordTypeName
              LIMIT 1
            ]
        );
        
        System.debug('---- id_PliRtMap ---- : ' + id_PliRtMap);
        
        Map<Id, ASI_MFM_Payment_Line_Item__c> id_PliRecordMap = new Map<Id, ASI_MFM_Payment_Line_Item__c>(
            [SELECT RecordTypeId,
                    ASI_MFM_Sub_brand__r.RecordType.DeveloperName
               FROM ASI_MFM_Payment_Line_Item__c
              WHERE Id IN :pliId_set]
        );
        
        //Added by Laputa Hugo Cheung 21-06-2016
        //Reason : Dynamic check the payment with different record type
        for(ASI_MFM_Payment_Line_Item__c lineItemIterator : trigger_new) {
            System.debug(' ---- RTName ---- : ' + lineItemIterator.ASI_MFM_Sub_brand__r.RecordType.DeveloperName);
            System.debug(' ---- Sub Brand Id ---- : ' + lineItemIterator.ASI_MFM_Sub_brand__c);
            if( id_PliRtMap.containsKey(lineItemIterator.RecordTypeId) && lineItemIterator.ASI_MFM_Sub_brand__c != NULL
            &&  !id_PliRecordMap.get(lineItemIterator.Id).ASI_MFM_Sub_brand__r.RecordType.DeveloperName.equalsIgnoreCase(subBrandRecordType)) {
                System.debug(' ---- IN IF ---- ');
                lineItemIterator.ASI_MFM_Sub_brand__c.addError('Please select a Sub-brand with Record Type "' + countryCode + ' Sub-brand".');
                result = false;
            }
        }
        return result;
    }
    
    public static void routineAfterAll(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        // Recalculate payment amount in payment request header
        set<id> ph_set = new set<id>();
        
        if(trigger_new != NULL && (
                    Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK') ||
                    Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_SG') ||
                    Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH') 
                    )
        ){  //Wilken Lee 20181204: Limit validation for HK SG and TH CAPEX Only
            if(checkValidRecordType(trigger_new) == false) {
                return;
            }
        }
        
        if (trigger_oldmap == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                ph_set.add(pi.ASI_MFM_Payment__c);
            }
        }
        else if (trigger_new == null) {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldmap.values()) {
                ph_set.add(pi.ASI_MFM_Payment__c);             
            }
            
        }
        else {
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                if (pi.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pi.id).ASI_MFM_Payment_Amount__c) {
                    ph_set.add(pi.ASI_MFM_Payment__c);
                }
                
                //Added by Laputa Hugo Cheung 21-06-2016
                //Reason : Add payment into ph_set when the record type is ASI_MFM_CAP_SG/TH/HK
                if(Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_CAP_SG') || 
                   Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_CAP_TH') || 
                   Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
                    ph_set.add(pi.ASI_MFM_Payment__c);
                }
                
            }           
        }
        
        if (ph_set.size() > 0) {
            //CAPEX: Sync paid amount with actual amount for PO for ALL direct payments and ocr
            Set<ID> poLineItemIDSet = new Set<ID>();
            boolean isAmountExceed = false;
            list<ASI_MFM_Payment__c> ph_list = [select ASI_MFM_Status__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Is_Direct_Payment__c, ASI_MFM_OCR__c, (select ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__c from Payment_Line_Items__r) from ASI_MFM_Payment__c where id in :ph_set];
            for (ASI_MFM_Payment__c ph:ph_list) {
                Decimal oldPaymentAmount = ph.ASI_MFM_Payment_Amount__c;
                ph.ASI_MFM_Payment_Amount__c = 0;
                for (ASI_MFM_Payment_Line_Item__c pi:ph.Payment_Line_Items__r) {
                    // Capex: only apply sync paid amount with actual amount in PO for draft ONLY!
                    if(ph.ASI_MFM_Status__c == 'Draft' && (ph.ASI_MFM_Is_Direct_Payment__c || ph.ASI_MFM_OCR__c)) {
                        poLineItemIDSet.add(pi.ASI_MFM_PO_Line_Item__c);
                    }
                    
                    if (pi.ASI_MFM_Payment_Amount__c != null) {
                        ph.ASI_MFM_Payment_Amount__c += pi.ASI_MFM_Payment_Amount__c;
                    }
                }
                /*if(ph.recordTypeId != null){
                    if(Global_RecordTypeCache.getRt(ph.recordTypeId).developerName.contains('ASI_MFM_CAP_SG')) {
                        ph.ASI_MFM_Payment_Amount__c = ph.ASI_MFM_Payment_Amount__c;
                    }
                }*/
            }
            update ph_list;
            // Sync paid amount with actual po line amount
            if(poLineItemIDSet.size() > 0)
            {
                List<ASI_MFM_PO_Line_Item__c> poLineItems = [SELECT ID, Name, ASI_MFM_Amount__c, ASI_MFM_Paid_Amount__c, 
                                                                (select ASI_MFM_Payment_Amount__c,ASI_MFM_PO_Line_Item__c from Payment_Line_Items__r) 
                                                            FROM ASI_MFM_PO_Line_Item__c WHERE ID IN : poLineItemIDSet];
                                                            
                List<ASI_MFM_PO_Line_Item__c> poLineItemsToUpdate = new List<ASI_MFM_PO_Line_Item__c>();
                for (ASI_MFM_PO_Line_Item__c poLineItem : poLineItems)
                {
                    Decimal sumPayment = 0;
                    for(ASI_MFM_Payment_Line_Item__c paymentLine : poLineItem.Payment_Line_Items__r)
                    {
                        if(paymentLine.ASI_MFM_Payment_Amount__c != null)
                        {
                            sumPayment += paymentLine.ASI_MFM_Payment_Amount__c;
                        }
                    }
                    if(poLineItem.ASI_MFM_Amount__c != sumPayment)
                    {
                        poLineItem.ASI_MFM_Amount__c = sumPayment;
                        poLineItemsToUpdate.add(poLineItem);
                    }
                }
                if(poLineItemsToUpdate.size() > 0)
                    update poLineItemsToUpdate;
            }
        }       

// Pass Payment and line item details to Data Warehouse 
        if (!ASI_MFM_Function.bypassCallouts()) {       
            set<id> pid_set = new set<id>();
            if (trigger_new != null) {
                for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                    if (trigger_oldMap == null || pi.ASI_MFM_Sys_Sync_Time__c == trigger_oldMap.get(pi.id).ASI_MFM_Sys_Sync_Time__c) {
                        pid_set.add(pi.ASI_MFM_Payment__c);
                    }               
                }
            }
            else if (trigger_oldMap != null) {
                for (ASI_MFM_Payment_Line_Item__c pi:trigger_oldMap.values()) {
                    pid_set.add(pi.ASI_MFM_Payment__c);             
                }           
            }
        } 
    }

    public static void routineBeforeDelete(list<ASI_MFM_Payment_Line_Item__c> trigger_old) {
// Not allowed to delete if the Payment is in final or complete status or voucher created flag is on
        set<id> pid_set = new set<id>();
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_old) {
            pid_set.add(pi.ASI_MFM_Payment__c);
        }
        map<id, ASI_MFM_Payment__c> Payment_map = new map<id, ASI_MFM_Payment__c>([select id from ASI_MFM_Payment__c where id in :pid_set and (ASI_MFM_Status__c = 'Final' or ASI_MFM_Status__c = 'Complete')]);        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_old) {
            if (Payment_map.containsKey(pi.ASI_MFM_Payment__c)) {
                pi.addError('Not allowed to delete because the payment is in \'Final\' or \'Complete\' status');
            }
            if (pi.ASI_MFM_Voucher_Created__c) {
                pi.addError('Not allowed to delete because voucher has been created');
            }           
        }
    }

    public static void routineBeforeInsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new) {
        set<id> payment_set = new set<id>();
        set<id> pol_set = new set<id>();
        //Added by Laputa Hugo Cheung 21-06-2016
        //Reason : Auto assign bu code when create payment line item
        set<id> all_payment_set = new set<id>();
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
            if (pi.ASI_MFM_Payee__c == null) {
                payment_set.add(pi.ASI_MFM_Payment__c);
            }
            if (pi.ASI_MFM_PO_Line_Currency__c == null || pi.ASI_MFM_PO_Line_Remaining_Amount__c == null) {
                pol_set.add(pi.ASI_MFM_PO_Line_Item__c);
            }
            all_payment_set.add(pi.ASI_MFM_Payment__c);
        }
        
        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')) {

            List<ASI_MFM_Default_Value__c> mfmDefault_PaymentTypeList = [SELECT Name, 
                                                                         Country__c, 
                                                                         ASI_MFM_Value__c, 
                                                                         ASI_MFM_Object__c 
                                                                         FROM ASI_MFM_Default_Value__c 
                                                                         WHERE Country__c = 'TH' AND 
                                                                         Name = 'CAP_TH_BU_Code' AND 
                                                                         ASI_MFM_Object__c = 'ASI_MFM_Payment_Line_Item__c'];

            if(mfmDefault_PaymentTypeList.size() != 0) {

                for(ASI_MFM_Payment_Line_Item__c pi:trigger_new) {

                    pi.ASI_MFM_BU__c = mfmDefault_PaymentTypeList.get(0).ASI_MFM_Value__c;

                }

            }

        }

        if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
            List<ASI_MFM_Payment__c> paymentList = [select Id, ASI_MFM_Company_Code__c from ASI_MFM_Payment__c where id in :all_payment_set];

            Map<String, Id> customSettingNamePaymentIdMap = new Map<String, Id>();

            for(ASI_MFM_Payment__c payment : paymentList) {

                if(String.isNotBlank(payment.ASI_MFM_Company_Code__c)) {

                    customSettingNamePaymentIdMap.put('CAP_HK_BU_' + payment.ASI_MFM_Company_Code__c, payment.Id);
                }

            }

            List<ASI_MFM_Default_Value__c> mfmDefault_PaymentTypeList = [SELECT Name, 
                                                                         Country__c, 
                                                                         ASI_MFM_Value__c, 
                                                                         ASI_MFM_Object__c 
                                                                         FROM ASI_MFM_Default_Value__c 
                                                                         WHERE Country__c = 'HK' AND 
                                                                         Name in :customSettingNamePaymentIdMap.keySet() AND 
                                                                         ASI_MFM_Object__c = 'ASI_MFM_Payment_Line_Item__c'];

            Map<Id, ASI_MFM_Default_Value__c> companyCodeMFMDefaultMap = new Map<Id, ASI_MFM_Default_Value__c>();                                                               
            for(ASI_MFM_Default_Value__c mfmDefault_PaymentType : mfmDefault_PaymentTypeList) {

                if(customSettingNamePaymentIdMap.containsKey(mfmDefault_PaymentType.Name)) {

                    companyCodeMFMDefaultMap.put(customSettingNamePaymentIdMap.get(mfmDefault_PaymentType.Name), mfmDefault_PaymentType);

                }

            }

            for(ASI_MFM_Payment_Line_Item__c pi:trigger_new) {

                if(companyCodeMFMDefaultMap.containsKey(pi.ASI_MFM_Payment__c)) {

                    pi.ASI_MFM_BU__c = companyCodeMFMDefaultMap.get(pi.ASI_MFM_Payment__c).ASI_MFM_Value__c;

                }
            }
        }
// Set payee to payment header's supplier if not input by user          
        if (payment_set.size() > 0) {
            map<id, ASI_MFM_Payment__c> payment_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_Supplier_Name__c, ASI_MFM_Payment_Type__c, RecordType.DeveloperName from ASI_MFM_Payment__c where id in :payment_set]);
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {  
                if (pi.ASI_MFM_Payee__c == null && payment_map.containsKey(pi.ASI_MFM_Payment__c)) {
                    pi.ASI_MFM_Payee__c = payment_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Supplier_Name__c;
                }               
            }            
        }

// Set PO line currency, PO line remaining amount and PO line description
        if (pol_set.size() > 0) {
            map<id, ASI_MFM_PO_Line_Item__c> pol_map = new map<id, ASI_MFM_PO_Line_Item__c>([select ASI_MFM_Currency__c, ASI_MFM_Remaining_Balance__c, 
                ASI_MFM_List_Item_Description__c, ASI_MFM_CN_Receipt_Amount__c, ASI_MFM_Paid_Amount__c
                from ASI_MFM_PO_Line_Item__c where id in :pol_set]);
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
        }
    }

    public static void routineBeforeUpdate(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
// Not allow to change when the voucher created flag is on
        Set<ID> setPYI = new Set<ID>();
        
        for (ASI_MFM_Payment_Line_Item__c i : trigger_new)
            setPYI.add(i.ASI_MFM_Payment__c);   

        Profile prof = [select id, Name from Profile where Id = :UserInfo.getProfileId() ];
        boolean isuserAdmin = prof.name.contains('System Administrator') || prof.name == 'ASI_MFM_TW Power';
        Map<String, ID> rt_map = new Map<String, id>();
        for(RecordType rec :Global_RecordTypeCache.getRtList('ASI_MFM_Payment__c')){
            rt_map.put(rec.developername,rec.id);
        }
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            if (trigger_oldMap.get(pi.id).ASI_MFM_Voucher_Created__c && !isuserAdmin) {
                pi.addError('Not allow to change because voucher has been created');
            }
        }           
    }
    
    public static void routineAfterUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        set<id> supplier_set = new set<id>();
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new){
            supplier_set.add(pi.ASI_MFM_Payee__c);
        }
        
        if(trigger_new != NULL && (
                    Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK') ||
                    Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_SG') ||
                    Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH') 
                    )
        ){  //Wilken Lee 20181204: Limit validation for HK SG and TH CAPEX Only
            if(checkValidRecordType(trigger_new) == false) {
                return;
            }
        }
        
        if (supplier_set.size() > 0){
            System.debug('Supplier Set: ' + supplier_set.size());
            List<ASI_MFM_Payment_Line_Item__c> payLines = [select ASI_MFM_Payment__c, ASI_MFM_Payment__r.Name, ASI_MFM_Payee__c, ASI_MFM_Invoice_Number__c from ASI_MFM_Payment_Line_Item__c where recordtypeid = : Global_RecordTypeCache.getRtId('ASI_MFM_CAP_Payment_Line_Item') AND ASI_MFM_Payment__r.ASI_MFM_Supplier_Name__c = :supplier_set];
            System.debug('CAPEX payLines.size : ' + payLines.size());
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                for (ASI_MFM_Payment_Line_Item__c payLine:payLines){
                    System.debug('Current Line: ID:' + pi.id + ' Supplier ID: ' + pi.ASI_MFM_Payee__c + ' Inv no.: ' + pi.ASI_MFM_Invoice_Number__c + ' Payment ID: ' + pi.ASI_MFM_Payment__c);
                    System.debug('Query Line: ID:' + payLine.id + ' Supplier ID: ' + payLine.ASI_MFM_Payee__c + ' Inv no.: ' + payLine.ASI_MFM_Invoice_Number__c + ' Payment ID: ' + payLine.ASI_MFM_Payment__c);
                    if (pi.id != payLine.id && 
                        //Added by Laputa (Hector) for auto payment generation
                        (!String.isBlank(pi.ASI_MFM_Invoice_Number__c)) &&
                        pi.ASI_MFM_Payee__c == payLine.ASI_MFM_Payee__c && 
                        pi.ASI_MFM_Invoice_Number__c == payLine.ASI_MFM_Invoice_Number__c && 
                        pi.ASI_MFM_Payment__c != payLine.ASI_MFM_Payment__c){
                        pi.addError('Duplicate Invoice Number from the same Supplier is found on Payment: ' + payLine.ASI_MFM_Payment__r.Name);
                    }
                }
            }
        }
    }
    
    public static void routineBeforeUpsert(list<ASI_MFM_Payment_Line_Item__c> trigger_new, map<id, ASI_MFM_Payment_Line_Item__c> trigger_oldMap) {
        //CAPEX: Retrieve the default values for BUCode
        String CAPEX_BUCodeDefault;
        String OPEX_BUCodeDefault;
        
        //HK CAPEX Default AP Code for Accrual Payment
        String capexHKDefaultAPID = null;
        String opexHKDefaultAPID = null;
        
        for(ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()){
            // CAPEX: set the capex bu code default
            if (setting.name == 'CAP_CAPEX_BU_Code__c' && Setting.Country__c == 'HK') {
                CAPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
            // OPEX: set the opex bu code default
            if (setting.name == 'CAP_OPEX_BU_Code__c' && Setting.Country__c == 'HK') {
                OPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
            
            // CAPEX: set the capex Accrual Payment Account Code default
            if (setting.name == 'CAP_Acc_Payment_AP_Code_CAPEX' && Setting.Country__c == 'HK') {
                capexHKDefaultAPID = Setting.ASI_MFM_value__c;
            }
            // OPEX: set the opex Accrual Payment Account Code default
            if (setting.name == 'CAP_Acc_Payment_AP_Code_OPEX' && Setting.Country__c == 'HK') {
                opexHKDefaultAPID = Setting.ASI_MFM_value__c;
            }
        }
        
        //Bypass Data Integrity Logic if user name is defined in custom setting ASI_MFM_Validation_Bypass__c
        Boolean CAPBypassValidation = false;
        ASI_MFM_Validation_Bypass__c ValidationRuleSettings = ASI_MFM_Validation_Bypass__c.getInstance(UserInfo.getUserId());
        if (ValidationRuleSettings != null) {
            if (ValidationRuleSettings.ASI_MFM_Bypass_Validation__c == true && ValidationRuleSettings.ASI_MFM_Object_API__c == 'ASI_MFM_Payment_Line_Item__c' && ValidationRuleSettings.ASI_MFM_Record_Type__c == 'ASI_MFM_CAP_Payment_Line_Item') {
                CAPBypassValidation = true;
            }
        }
                
        set<string> pay_ccy_set = new set<string>();
        set<string> po_ccy_set = new set<string>();
        set<id> pay_set = new set<id>();
        
        //CAPEX
        set<ID> poLineSet = new Set<ID>();
        set<ID> apIDSet = new Set<ID>();
        set<ID> acIDSet = new Set<ID>();
        Set<ID> paymentIDSet = new Set<ID>();
        Set<ID> paymentAllIDSet = new Set<ID>();
        
        //Wilken 20161201 Validate CAP Payment Line BU Code Record Type, create map of BU Code with RecordTypeID for validation in next for-loop
        Map<Id,String> buIdRecordTypeNameMap = new Map<Id,String>();
        Set<Id> buIdSet = new Set<Id>();
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new){
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_CAP_Payment_Line_Item')){
                buIdSet.add(pi.ASI_MFM_BU__c);
            }

            if (buIdSet.size() > 0){
                for (ASI_MFM_BU__c bu:[select Id, RecordType.DeveloperName from ASI_MFM_BU__c where id in :buIdSet]){
                    buIdRecordTypeNameMap.put(bu.Id, bu.RecordType.DeveloperName);                  
                }
            }
        }
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new)
        {
            //HK CAPEX Logic: Assign default BU Code
            if (pi.ASI_MFM_BU__c == null && pi.ASI_MFM_BU_Allocation__c == null && Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_CAP_Payment_Line_Item')){
                if (pi.ASI_MFM_Payment_Type__c == 'CAPEX'){
                    pi.ASI_MFM_BU__c = CAPEX_BUCodeDefault;
                }
                else if (pi.ASI_MFM_Payment_Type__c == 'OPEX'){
                    pi.ASI_MFM_BU__c = OPEX_BUCodeDefault;
                }
            }
            
            System.debug('capexHKDefaultAPID: ' + capexHKDefaultAPID + ' opexHKDefaultAPID: ' + opexHKDefaultAPID + ' Payment Type: ' + pi.ASI_MFM_Payment_Type__c);
            if (Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('ASI_MFM_CAP_Payment_Line_Item')){
                if (pi.ASI_MFM_Is_Accrual_PO__c){
                    if (pi.ASI_MFM_Payment_Type__c == 'CAPEX')
                        pi.ASI_MFM_AP_Code__c = capexHKDefaultAPID;
                    else if (pi.ASI_MFM_Payment_Type__c == 'OPEX')
                        pi.ASI_MFM_AP_Code__c = opexHKDefaultAPID;
                }
                
                //Vincent 20161215 Only check if size of map > 0
                if (buIdRecordTypeNameMap.Size() > 0) {
                    if (buIdRecordTypeNameMap.get(pi.ASI_MFM_BU__c) != 'ASI_MFM_CAP_BU')
                        pi.addError('Please select BU Code of [CAP BU] record type.');
                }
            }
            
            if (pi.ASI_MFM_PO_Line_Item__c != null){
                poLineSet.add(pi.ASI_MFM_PO_Line_Item__c);
            }
            
            // If update
            if(trigger_oldMap!= null){
                //Added by Laputa Hugo Cheung 21-06-2016
                //Reason : If record type is TH/HK, assign AC code, else assign AP code
                if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK') || 
                   Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')) {
                    if((trigger_oldMap.get(pi.id).ASI_MFM_A_C_Code__c != pi.ASI_MFM_A_C_Code__c 
                        || trigger_oldMap.get(pi.id).ASI_MFM_Payment_List_Item_Description__c != pi.ASI_MFM_Payment_List_Item_Description__c) 
                            && pi.ASI_MFM_A_C_Code__c != null ){
                        acIdSet.add(pi.ASI_MFM_A_C_Code__c);
                    }
                    else if (trigger_oldMap.get(pi.id).ASI_MFM_PO_Line_Item__c != pi.ASI_MFM_PO_Line_Item__c && pi.ASI_MFM_PO_Line_Item__c == null && !Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('HK') ){
                        pi.ASI_MFM_A_C_Code__c = null;

                    }
                    else if(pi.ASI_MFM_Payment_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_Payment_List_Item_Description__c)
                    {
                        paymentIDSet.add(pi.ASI_MFM_Payment__c);
                    }
                } else {
                    // If AP Code is updated OR line item description is updated
                    if((trigger_oldMap.get(pi.id).ASI_MFM_AP_Code__c != pi.ASI_MFM_AP_Code__c 
                        || trigger_oldMap.get(pi.id).ASI_MFM_Payment_List_Item_Description__c != pi.ASI_MFM_Payment_List_Item_Description__c) 
                            && pi.ASI_MFM_AP_Code__c != null ){
                        apIDSet.add(pi.ASI_MFM_AP_Code__c);
                    }
                    else if (trigger_oldMap.get(pi.id).ASI_MFM_PO_Line_Item__c != pi.ASI_MFM_PO_Line_Item__c && pi.ASI_MFM_PO_Line_Item__c == null && !Global_RecordTypeCache.getRt(pi.recordTypeId).developerName.contains('SG') ){
                        pi.ASI_MFM_A_C_Code__c = null;
                        pi.ASI_MFM_AP_Code__c = null;
                    }
                    else if(pi.ASI_MFM_Payment_List_Item_Description__c != trigger_oldMap.get(pi.id).ASI_MFM_Payment_List_Item_Description__c)
                    {
                        paymentIDSet.add(pi.ASI_MFM_Payment__c);
                    }
                }
            }
            
            if(Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK') || 
               Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')) {
                if(trigger_oldMap== null && pi.ASI_MFM_A_C_Code__c != null)
                    acIDSet.add(pi.ASI_MFM_A_C_Code__c);
                    
                if(pi.ASI_MFM_A_C_Code__c != null)
                    acIDSet.add(pi.ASI_MFM_A_C_Code__c);
            } else {
                if(trigger_oldMap== null && pi.ASI_MFM_AP_Code__c != null)
                    apIDSet.add(pi.ASI_MFM_AP_Code__c);
                    
                if(pi.ASI_MFM_AP_Code__c != null)
                    apIDSet.add(pi.ASI_MFM_AP_Code__c);
            }
            
            if(trigger_oldMap== null)
                paymentIDSet.add(pi.ASI_MFM_Payment__c);
                
            paymentAllIDSet.add(pi.ASI_MFM_Payment__c);
            
        }
        
         
        
        Map<ID, ASI_MFM_PO_Line_Item__c> poLineMap = new Map<ID, ASI_MFM_PO_Line_Item__c>([SELECT ID, Name, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_PO__c FROM ASI_MFM_PO_Line_Item__c WHERE ID IN : poLineSet]);
        Map<ID, ASI_MFM_AP_Code__c> apCodeMap = new Map<ID, ASI_MFM_AP_Code__c>([SELECT ID, Name, ASI_MFM_A_C_Code__c FROM ASI_MFM_AP_Code__c WHERE ID IN : apIDSet]);
        
        Map<ID, ASI_MFM_A_C_Code__c> acCodeMap = new Map<ID, ASI_MFM_A_C_Code__c>([SELECT ID, Name, ASI_MFM_A_C_Description__c FROM ASI_MFM_A_C_Code__c WHERE ID IN : acIDSet]);
        /*Map<ID, ASI_MFM_Payment__c> paymentMap = new Map<ID, ASI_MFM_Payment__c>([SELECT ID, Name, ASI_MFM_Remarks__c FROM ASI_MFM_Payment__c
                                                                                  WHERE ID IN : paymentIDSet AND ASI_MFM_OCR__c = : true]);*/
                                                                                  
        Map<ID, ASI_MFM_Payment__c> allPaymentMap = new Map<ID, ASI_MFM_Payment__c>([SELECT ID, Name, (SELECT ID, Name, ASI_MFM_Invoice_Number__c FROM Payment_Line_Items__r) FROM ASI_MFM_Payment__c
                                                                                  WHERE ID IN : paymentAllIDSet AND ASI_MFM_OCR__c = : true]);
                                                                                  
        Map<ID, ASI_MFM_Payment__c> TnEPaymentsMap = new Map<ID, ASI_MFM_Payment__c>([SELECT ID, Name, (SELECT ID, Name, ASI_MFM_Invoice_Number__c FROM Payment_Line_Items__r) FROM ASI_MFM_Payment__c
                                                                                  WHERE ID IN : paymentAllIDSet AND recordtypeid = : Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_T_E_Payment')]);
                                                                                  
        List<ASI_MFM_PO_Line_Item__c> poLineList = new List<ASI_MFM_PO_Line_Item__c>();
        
        for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
            //Check for Invoice Number Duplicates
            /*Set<String> invoiceSet = new Set<String>();
            List<ASI_MFM_Payment_Line_Item__c>  relatedPaymentLinesList = allPaymentMap.get(pi.ASI_MFM_Payment__c) != null ? allPaymentMap.get(pi.ASI_MFM_Payment__c).Payment_Line_Items__r
                                                                            : new List<ASI_MFM_Payment_Line_Item__c>();
            for(ASI_MFM_Payment_Line_Item__c paymentLines : relatedPaymentLinesList)
            {
                if(paymentLines.ASI_MFM_Invoice_Number__c != null && paymentLines.ID != pi.id)
                    invoiceSet.add(paymentLines.ASI_MFM_Invoice_Number__c);
            }
            
            if (invoiceSet.contains(pi.ASI_MFM_Invoice_Number__c))
                pi.adderror('Duplicate Invoice Number Detected');*/
            
            // CAPEX: Match AP and AC code with PO Line and Payment Line
            ASI_MFM_PO_Line_Item__c poLine = poLineMap.get(pi.ASI_MFM_PO_Line_Item__c);
            ASI_MFM_AP_Code__c apCode;
            if(!Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK') && 
               !Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')) {
                apCode = apCodeMap.get(pi.ASI_MFM_AP_Code__c);
            }
            //ASI_MFM_Payment__c payment = paymentMap.get(pi.ASI_MFM_Payment__c);
            
            // Defaulting line item description
            ASI_MFM_Payment__c tnePayment = TnEPaymentsMap.get(pi.ASI_MFM_Payment__c);
            if(tnePayment != null && pi.ASI_MFM_Payment_List_Item_Description__c == null)
            {
                pi.ASI_MFM_Payment_List_Item_Description__c = 'T&E';
            }
            else if (tnePayment == null && 
                     pi.ASI_MFM_Payment_List_Item_Description__c == null && 
                     pi.ASI_MFM_A_C_Code__c != null &&
                     (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK') || 
                      Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TH')))
            {
                pi.ASI_MFM_Payment_List_Item_Description__c = acCodeMap.get(pi.ASI_MFM_A_C_Code__c).ASI_MFM_A_C_Description__c;
            }
            else if (tnePayment == null && 
                     pi.ASI_MFM_Payment_List_Item_Description__c == null && 
                     pi.ASI_MFM_A_C_Code__c != null)
            {
                pi.ASI_MFM_Payment_List_Item_Description__c = apCodeMap.get(pi.ASI_MFM_AP_Code__c).name;
            }
            
            // Add AC code according to selected AP Code
            // Bypass AC code if Account Name is defined in custom setting ASI_MFM_Validation_Bypass__c
            if (apCode != null && CAPBypassValidation == false){
                pi.ASI_MFM_A_C_Code__c = apCode.ASI_MFM_A_C_Code__c;
            }
            
            System.debug('Line 548 OK');
            
            //Wilken 20150323: Update PO Line dimension base on payment line, if it is not accrual PO, then align PO line amount with payment amount as well
            if (poLine != null){
                poLine.ASI_MFM_A_C_Code__c = pi.ASI_MFM_A_C_Code__c;
                poLine.ASI_MFM_AP_Code__c = pi.ASI_MFM_AP_Code__c;
                poLine.ASI_MFM_BU_Code__c = pi.ASI_MFM_BU__c;
                poLine.ASI_MFM_List_Item_Description__c = pi.ASI_MFM_Payment_List_Item_Description__c;
                
                if (poLine.ASI_MFM_PO__r.recordTypeID == Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_PO')){
                    poLine.ASI_MFM_Amount__c = poLine.ASI_MFM_Paid_Amount_in_PO_Currency__c;
                }
            
                boolean duplicateLine = false;
                
                for (ASI_MFM_PO_Line_Item__c p:poLineList){
                    if (poLine.id != null) {
                        if (poLine.id == p.id)
                            duplicateLine = true;
                    }
                }
                
                if (!duplicateLine && poLine != null)
                    poLineList.add(poLine);
                System.debug('PO Line List Size: ' + poLineList.size());
            }
            
            System.debug('Line 573 OK');
                
            // Check if there was an input in the decimal number output error
            boolean isDecimal = ASI_MFM_Function.containsDecimalValue(pi.ASI_MFM_Payment_Amount__c) && pi.ASI_MFM_Currency__c == 'TWD';
            if (isDecimal)
                pi.addError(' You Cannot input a decimal number for a TWD currency.');
            
            if (pi.ASI_MFM_Payment_Amount__c != null && pi.ASI_MFM_Currency__c != pi.ASI_MFM_PO_Line_Currency__c) {
                pay_ccy_set.add(pi.ASI_MFM_Currency__c);
                po_ccy_set.add(pi.ASI_MFM_PO_Line_Currency__c);
            }
            
            if (pi.ASI_MFM_Invoice_Date__c == null || pi.ASI_MFM_Invoice_Number__c == null
                || pi.ASI_MFM_Payment_Status__c == 'Draft') {   //WL 2.0
                pay_set.add(pi.ASI_MFM_Payment__c);
            }
        }
        
        if(poLineList.size() > 0) {
            update poLineList;
        }
        
        map<id, ASI_MFM_Payment__c> pay_map;
        // Set invoice number and invoice date
        if (pay_set.size() > 0) {
            pay_map = new map<id, ASI_MFM_Payment__c>([select ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c,recordType.developerName, ASI_MFM_Exchange_Rate__c from ASI_MFM_Payment__c where id in :pay_set]); //WL 2.0
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) { 
                if (pi.ASI_MFM_Invoice_Date__c == null && pay_map.get(pi.ASI_MFM_Payment__c) != null) {   
                    pi.ASI_MFM_Invoice_Date__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Date__c;
                }
                if (pi.ASI_MFM_Invoice_Number__c == null && pay_map.get(pi.ASI_MFM_Payment__c) != null) { 
                    pi.ASI_MFM_Invoice_Number__c = pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Invoice_Number__c;
                }      
                
                pi.ASI_MFM_Paid_Amount_in_Base_Currency__c=pay_map.get(pi.ASI_MFM_Payment__c).ASI_MFM_Exchange_Rate__c * pi.ASI_MFM_Payment_Amount__c; //WL 2.0
            }                
        }              
        
        //Added by Laputa Hugo Cheung 21-06-2016
        //Reason : HK record do not need to calculate the currency.
        if(!Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_HK')) {
            // Recalculate the paid amount in PO currency     
            string country = Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.substring(12, 14);
            Date last_effective_date = Date.today(); //[WL 1.0] For non-IT CAPEX OPEX system uses
            
            if (Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_Payment')){
                country = 'HK';
                
                /*[WL 1.0] BEGIN*/
                for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                    if (last_effective_date == null || pi.CreatedDate > last_effective_date) 
                        last_effective_date = Date.ValueOf(pi.CreatedDate);
                }
                /*[WL 1.0] END*/
            }   
                
            list<ASI_MFM_Exchange_Rate__c> xr_list = new list<ASI_MFM_Exchange_Rate__c>();
            if (pay_ccy_set.size() > 0 && po_ccy_set.size() > 0) {
                //[WL 1.0] BEGIN
                /*xr_list = [select ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                    where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c in :pay_ccy_set and ASI_MFM_Counter_Currency__c in :po_ccy_set and
                    ASI_MFM_Country__c = :country and ASI_MFM_Effective_Date__c <= :date.today() order by ASI_MFM_Effective_Date__c desc];*/
                xr_list = [select ASI_MFM_Base_Currency__c, ASI_MFM_Counter_Currency__c, ASI_MFM_Exchange_Rate__c from ASI_MFM_Exchange_Rate__c
                    where ASI_MFM_Application__c = 'MFM' and ASI_MFM_Base_Currency__c in :pay_ccy_set and ASI_MFM_Counter_Currency__c in :po_ccy_set and
                    ASI_MFM_Country__c = :country and ASI_MFM_Effective_Date__c <= :last_effective_date order by ASI_MFM_Effective_Date__c desc];
                //[WL 1.0] END
            }
            
            for (ASI_MFM_Payment_Line_Item__c pi:trigger_new) {
                pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = null;
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
                        if (country == 'TW' && pi.ASI_MFM_PO_Line_Currency__c == 'TWD') {
                            pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(0, roundingMode.half_up);
                        }
                        else {
                            pi.ASI_MFM_Paid_Amount_in_PO_Currency__c = (pi.ASI_MFM_Payment_Amount__c / xrate).setScale(2, roundingMode.half_up);
                        }
                    }
                }
            }      
        }
    }       
}