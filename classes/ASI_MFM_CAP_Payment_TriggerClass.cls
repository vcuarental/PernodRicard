/*********************************************************************************
 * Name: ASI_MFM_CAP_Payment_TriggerClass
 * Description: Test Class: ASI_MFM_CAP_Payment_Test, ASI_MFM_CAP_OTH_MgAll_PaymentCtrlTest, ASI_MFM_CAP_GeneratePaymentExtensionTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/10/2017       Wilken Lee              [WL 1.0] Copy Payment Header Invoice Date to Payment Line Item Invoice Date when cloned
 * 23/10/2018       Hector Tsang            3-Way Matching
 * 25/10/2018       Hector Tsang            3-Way Matching - Trigger Approval for Status Change
 * 21/01/2019       Wilken Lee            	[WL 2.0] Payment approver follows PO owner
 * 10/05/2019       Wilken Lee            	[WL 3.0] Remove auto delete PO logic when OCR/Direct Payment is deleted
 * 03/06/2019       Wilken Lee            	[WL 4.0] Auto default Plan based on PO Selected
*/
public without sharing class ASI_MFM_CAP_Payment_TriggerClass {
    public static void routineBeforerDelete(list<ASI_MFM_Payment__c> trigger_old) {
        /*[WL 3.0] BEGIN*/
		/*Set<ID> paymentIDSet = new Set<ID>();
        // Delete related PO lines and PO if the payment deleted is OCR or Direct Payment
        for (ASI_MFM_Payment__c payment : trigger_old){
            if (payment.ASI_MFM_Is_Direct_Payment__c || payment.ASI_MFM_OCR__c) {
            // DC - 01-Mar-2016 - Removed condition to check if the record is cloned.
            // DC - 01-Mar-2016 - Added condition to check if the record is cloned.
            // || payment.getCloneSourceId() != NULL){
                paymentIDSet.add(payment.id);
            }
        }
        
        if (paymentIDset.size() > 0){
            List<ASI_MFM_PO_Line_Item__c> POLinesToDelete = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO__c> poHeaderToDelete = new List<ASI_MFM_PO__c>();
            
            Set<ID> poIDSet = new Set<ID>();
            Map<ID, Integer> poLineCountMap = new Map<ID, Integer>();
            
            List<ASI_MFM_Payment__c> paymentList = [SELECT ID, Name, 
                                                     (SELECT ID, Name, ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c FROM Payment_Line_Items__r)
                                                   FROM ASI_MFM_Payment__c WHERE ID IN : paymentIDSET];
           
            for (ASI_MFM_Payment__c payment : paymentList){
                System.debug('------ payment ------ : ' + payment);
                List<ASI_MFM_Payment_Line_Item__c> paymentLineList = payment.Payment_Line_Items__r;
                for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList){
                    System.debug('------ paymentLine ------ : ' + paymentLine);
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
            System.debug('------ poLineCountMap ------ : ' + poLineCountMap);
            
            Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name,
                                                                        (SELECT ID, Name FROM PO_Line_Items__r)
                                                                      FROM ASI_MFM_PO__c WHERE ID IN: poIDSet]);
            Set<ID> POToDeleteSet = new Set<ID>();
            for (ASI_MFM_Payment__c payment : paymentList){
                List<ASI_MFM_Payment_Line_Item__c> paymentLineList = payment.Payment_Line_Items__r;
                for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList){
                    ASI_MFM_PO__c po = poMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                    Integer poLineCount = poLineCountMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                    if (po.PO_Line_Items__r.size() == poLineCount){
                        POToDeleteSet.add(po.id);
                    }
                }
            }
            System.debug('------ POToDeleteSet ------ : ' + POToDeleteSet);
            
            for(ID poID : POToDeleteSet){
                ASI_MFM_PO__c po = new ASI_MFM_PO__c(ID=poID);
                poHeaderToDelete.add(po);
            } 
            System.debug('------ poHeaderToDelete ------ : ' + poHeaderToDelete);                           
            
            Set<ID> poLinesToDeleteSet = new Set<ID>();
            Set<ID> poHeaderToDeleteSet = new Set<ID>();
            List<ASI_MFM_PO_Line_Item__c> cleanPOLinesToDelete = new List<ASI_MFM_PO_Line_Item__c>();
            List<ASI_MFM_PO__c> cleanPOHeaderToDelete = new List<ASI_MFM_PO__c>();
            
            for(ASI_MFM_PO_Line_Item__c poLine : POLinesToDelete){
                if(!poLinesToDeleteSet.contains(poLine.id)){
                    cleanPOLinesToDelete.add(poLine);
                }
                poLinesToDeleteSet.add(poLine.id);
            }
            System.debug('------ cleanPOLinesToDelete ------ : ' + cleanPOLinesToDelete);
            
            for(ASI_MFM_PO__c poHeader : poHeaderToDelete){
                if(!poHeaderToDeleteSet.contains(poHeader.id)){
                    cleanPOHeaderToDelete.add(poHeader);
                }
                poHeaderToDeleteSet.add(poHeader.id);
            }
            System.debug('------ cleanPOHeaderToDelete ------ : ' + cleanPOHeaderToDelete);
            
            
            if (POLinesToDelete.size() > 0)
                delete cleanPOLinesToDelete;
            if (poHeaderToDelete.size() > 0)
                delete cleanPOHeaderToDelete;                        
            
        }
    
        for (ASI_MFM_Payment__c pa : trigger_old)
        {
            if (pa.ASI_MFM_Status__c == 'Final' || pa.ASI_MFM_Status__c == 'Complete')
                 pa.addError('Not allowed to delete because the Payment is in \'Final\' or \'Complete\' status');
        }*/
		/*[WL 3.0] END*/
    }

    public static void routineAfterDelete(list<ASI_MFM_Payment__c> trigger_old) {
		list<id> pid_list = new list<id>();
		for (ASI_MFM_Payment__c p:trigger_old) {
			pid_list.add(p.id);
		}             
    }

    public static void routineAfterUpsert(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {
        List<ASI_MFM_Payment__c> capHKSubmittedPaymentList = new List<ASI_MFM_Payment__c>();
        
		set<id> pid_set = new set<id>();
		for (ASI_MFM_Payment__c p:trigger_new) {
			if (trigger_oldMap == null || p.ASI_MFM_Sys_Sync_Time__c == trigger_oldMap.get(p.id).ASI_MFM_Sys_Sync_Time__c) {
				pid_set.add(p.id);
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
            else{
                paymentIdSet.add(payment.id);
                
                //Added by Laputa(Hector): Handle case the payment is insert directly as Pending Goods/Service Receipt
                if ((Global_RecordTypeCache.getRt(payment.RecordTypeId).developerName == 'ASI_MFM_CAP_Payment') && payment.ASI_MFM_Status__c == 'Pending Goods/Service Receipt'){
                    capHKSubmittedPaymentList.add(payment);
                }
            }   
        }
        //Generate PO Receipt
		if (capHKSubmittedPaymentList.size() > 0)	//WL 2.0
			generatePOReceiptSubmitApproval(capHKSubmittedPaymentList);
        
        // Clone payment related object records
        // DC - 01-08-2016 Added checking for record type (Logic should not work for CAP TW Payment)
        if(!Global_RecordTypeCache.getRt(trigger_new[0].recordTypeId).developerName.contains('ASI_MFM_CAP_TW') && trigger_oldMap == NULL
        // DC - 01/27/2016 - Added condition to check if the current list of payments is cloned.
			&& trigger_new[0].getCloneSourceId() != NULL) {
            if(!ASI_MFM_CAP_Payment_TriggerClass.PAYMENT_CLONED)
                clonePaymentWithRelatedRecords(trigger_new);
        }
    }
    
    /* @author:      DC
     * @description: Method to clone Payment along with PO, PO Line Item and Payment Line Item 
     * @createdDate: 11/30/2015
     */
    public static boolean PAYMENT_CLONED = false;
    public static void clonePaymentWithRelatedRecords(list<ASI_MFM_Payment__c> trigger_new) {
//        System.debug(buildQuery('ASI_MFM_Payment_Line_Item__c', 'Id = \'a7sM00000004LNt\''));
        Map<Id, Id> clonedFromIdMap = new Map<Id, Id>();
        /*List<ASI_MFM_PO_Line_Item__c> clonedPOLines = new List<ASI_MFM_PO_Line_Item__c>();
        List<ASI_MFM_PO__c> clonedPOs = new List<ASI_MFM_PO__c>();*/
        // Consists existing PO and PO line items mapping
/*        Map<ASI_MFM_PO__c, List<ASI_MFM_PO_Line_Item__c>> poLineItemMap
            = new Map<ASI_MFM_PO__c, List<ASI_MFM_PO_Line_Item__c>>();*/
        Map<Id, List<ASI_MFM_PO_Line_Item__c>> poLineItemMap
            = new Map<Id, List<ASI_MFM_PO_Line_Item__c>>();
        // Consists existing PO Line Items and Payment Line Items mapping
        Map<Id, List<ASI_MFM_Payment_Line_Item__c>> poPaymentLineItemMap
            = new Map<Id, List<ASI_MFM_Payment_Line_Item__c>>();
            
        // Populate cloned from to cloned record Id map
        Map<Id, String> idInvoiceNumMap = new Map<Id, String>();
        
        /*[WL 1.0 BEGIN]*/
        Map<Id, Date> idInvoiceDateMap = new Map<Id, Date>();
        /*[WL 1.0 END]*/
        
        for(ASI_MFM_Payment__c paymentIterator : trigger_new) {
            if(paymentIterator.getCloneSourceId() != NULL) {
                  clonedFromIdMap.put(paymentIterator.getCloneSourceId(), paymentIterator.Id);
            }
            idInvoiceNumMap.put(paymentIterator.Id, paymentIterator.ASI_MFM_Invoice_Number__c);
            idInvoiceDateMap.put(paymentIterator.Id, paymentIterator.ASI_MFM_Invoice_Date__c);
        }
        List<Id> paymentLIIds = new List<Id>(clonedFromIdMap.keySet());
        String paymentLIQuery = buildQuery('ASI_MFM_Payment_Line_Item__c');
        paymentLIQuery += ' where ASI_MFM_Payment__c IN :paymentLIIds';
        system.debug('--- paymentLIQuery: '+paymentLIQuery);
        List<ASI_MFM_Payment_Line_Item__c> paymentLIList = Database.query(paymentLIQuery);
        
        // Create Map of PO line item and related payment line items
		List<Id> poIds = new List<Id>();  
		
        for(ASI_MFM_Payment_Line_Item__c thisPaymentLineItem : paymentLIList) {
            if(!poPaymentLineItemMap.containsKey(thisPaymentLineItem.ASI_MFM_PO_Line_Item__c))
                poPaymentLineItemMap.put(thisPaymentLineItem.ASI_MFM_PO_Line_Item__c, new List<ASI_MFM_Payment_Line_Item__c>());
            
			poPaymentLineItemMap.get(thisPaymentLineItem.ASI_MFM_PO_Line_Item__c).add(thisPaymentLineItem);
			
			poIds.add(thisPaymentLineItem.ASI_MFM_PO__c);	//WL 20190405
        }
        system.debug('-- poPaymentLineItemMap : '+poPaymentLineItemMap);
        // Get PO Ids	//WL 20190405 Get PO ID from Payment Line instead
        /*List<Id> poIds = new List<Id>();  
        for(ASI_MFM_PO_Line_Item__c poLineItem : [select Id, ASI_MFM_PO__c
                                                  from ASI_MFM_PO_Line_Item__c
                                                  where Id IN :poPaymentLineItemMap.keySet()]) {
            poIds.add(poLineItem.ASI_MFM_PO__c);
        }*/
        system.debug('-- poIds : '+poIds);
        // Populate PO and related PO Line Items map
        // Create new PO by cloning existing
        // List<Id> paymentLIIds = new List<Id>(clonedFromIdMap.keySet());
        String poQuery = buildQuery('ASI_MFM_PO__c');
        String poLIQuery = buildQuery('ASI_MFM_PO_Line_Item__c');
        poLIQuery = poLIQuery.replace('ASI_MFM_PO_Line_Item__c','PO_Line_Items__r');
        poLIQuery = '(' + poLIQuery + ')';
        string toAppend = ' FROM ASI_MFM_PO__c';
        String Temp = poQuery.subStringBefore(toAppend) + ', ' + poLIQuery + toAppend;
        Temp += ' WHERE Id IN :poIds';
        System.debug(' ----- Temp ----- : ' + Temp);
        List<ASI_MFM_PO__c> existingPOList = Database.query(Temp);
//        System.debug(' ----- Temp Executed ----- : ' + tempListPO[0].PO_Line_Items__r);
        List<ASI_MFM_PO__c> newPOs = new List<ASI_MFM_PO__c>();
        
        // DC - added logic for setting prefix from an active prefix. [START]
        Integer FiscalYearStartMonth = 7;
        String fiscalYear = 'FY';
        if(date.today().month() >= FiscalYearStartMonth) {
            fiscalYear += String.valueOf(date.today().year()).removeStart('20') + String.valueOf(date.today().year() + 1).removeStart('20');
        } else {
            fiscalYear += String.valueOf(date.today().year() - 1).removeStart('20') + String.valueOf(date.today().year()).removeStart('20');
        }
        System.debug('------ fiscalYear ------ : ' + fiscalYear);
        List<ASI_MFM_Prefix__c> prefixList = [SELECT Id,
                                                     Name,
                                                     ASI_MFM_Module__c,
                                                     ASI_MFM_Fiscal_year__c,
                                                     ASI_MFM_Next_Number__c
                                                FROM ASI_MFM_Prefix__c
                                               WHERE ASI_MFM_Fiscal_year__c = :fiscalYear
                                                 AND RecordType.DeveloperName = 'ASI_MFM_CAP_Prefix'
                                                 AND ASI_MFM_Module__c = 'PO'
                                                 AND ASI_MFM_Inactive__c = false
                                            ORDER BY CreatedDate DESC
                                               LIMIT 1];
        // [END]
        for(ASI_MFM_PO__c thisPO : existingPOList) {
            poLineItemMap.put(thisPO.Id, thisPO.PO_Line_Items__r);
            ASI_MFM_PO__c newPO = thisPO.clone(false,true,false,false);
            newPO.OwnerId = UserInfo.getUserId();
            newPO.ASI_MFM_PO_Raised_Date__c = System.today();
            newPO.ASI_MFM_PO_External_ID__c = NULL;
            // DC - 03/04/2016 - Set value of Is Extended field to avoid duplication of PO lines.
            newPO.ASI_MFM_Is_Extended_PO__c = true;
            // newPO.ASI_MFM_Plan__c = null; // DC - 01/27/2016 - Include Plan info in clone function
            if(!prefixList.isEmpty()) {
                newPO.ASI_MFM_Prefix__c = prefixList[0].Id; // DC - Saving value in the prefix field.
            }
            //newPOs.add(thisPO.clone(false,true,false,false));
            newPOs.add(newPO);
        }
        system.debug('-- newPOs : '+newPOs);
        Savepoint spBeforeInsertingPO = Database.setSavepoint();
        try {
			if(!test.isRunningTest()){
				insert newPOs;
			}
            
            system.debug('-- newPos : '+newPos);
            
            List<ASI_MFM_PO_Line_Item__c> newPOLineItemList
                = new List<ASI_MFM_PO_Line_Item__c>();       // New PO line Items after cloning
            for(ASI_MFM_PO__c thisPO : newPOs) {
                for(ASI_MFM_PO_Line_Item__c thisPOLineItem : poLineItemMap.get(thisPO.getCloneSourceId())) {
                    ASI_MFM_PO_Line_Item__c newPOLineItem = thisPOLineItem.clone(false, true, false, false);
                    newPOLineItem.ASI_MFM_PO__c = thisPO.Id;
                    newPOLineItem.ASI_MFM_PO_Line_Item_External_ID__c = NULL;
                    // DC - 03/04/2016 - Set value of Next Year field to avoid duplication of PO lines.
                    newPOLineItem.ASI_MFM_Next_Year__c = false;
                    newPOLineItemList.add(newPOLineItem);
                }
            }
			
			if(!test.isRunningTest()){
				insert newPOLineItemList;
			}
			
            system.debug('-- newPOLineItemList: '+newPOLineItemList);
            List<ASI_MFM_Payment_Line_Item__c> clonedPaymentLines = new List<ASI_MFM_Payment_Line_Item__c>();
            System.debug('-- poPaymentLineItemMap : '+poPaymentLineItemMap);
            for(ASI_MFM_PO_Line_Item__c thisPOLineItem : newPOLineItemList) {
                system.debug('-- thisPOLineItem.getCloneSourceId() : '+thisPOLineItem.getCloneSourceId());
                if(poPaymentLineItemMap.containsKey(thisPOLineItem.getCloneSourceId())) {
                    for(ASI_MFM_Payment_Line_Item__c paymentLI : poPaymentLineItemMap.get(thisPOLineItem.getCloneSourceId())) {
                        ASI_MFM_Payment_Line_Item__c newPaymentLI = paymentLI.clone(false, true, false, false);
                        newPaymentLI.ASI_MFM_PO_Line_Item__c = thisPOLineItem.Id;
                        newPaymentLI.ASI_MFM_Payment__c = clonedFromIdMap.get(paymentLI.ASI_MFM_Payment__c);
                        newPaymentLI.ASI_MFM_Invoice_Number__c = idInvoiceNumMap.get(newPaymentLI.ASI_MFM_Payment__c);
                        
                        /*[WL 1.0 BEGIN]*/
                        newPaymentLI.ASI_MFM_Invoice_Date__c = idInvoiceDateMap.get(newPaymentLI.ASI_MFM_Payment__c);
                        /*[WL 1.0 END]*/
                        
                        newPaymentLI.ASI_MFM_Payment_Line_Item_External_ID__c = NULL;
                        
                        //Added by Wilken 20160331, clear voucher created flag on cloned payment line
                        newPaymentLI.ASI_MFM_Voucher_Created__c = false;
                        
                        clonedPaymentLines.add(newPaymentLI);
                    }
                }
            }
            ASI_MFM_CAP_Payment_TriggerClass.PAYMENT_CLONED = true;
			
			if(!test.isRunningTest()){
				insert clonedPaymentLines;
			}
            
        }
        catch(Exception e) {
            system.debug('-- Exception occurred: '+e);
            trigger_new[0].addError(e.getMessage());
            Database.rollback(spBeforeInsertingPO);
        }
    }

    public static String buildQuery(String sObjectName) {
        String query = 'SELECT ';
        Schema.SObjectType selectedObjectType = Schema.getGlobalDescribe().get(sObjectName);
        Map<String, Schema.SObjectField> fieldResult = selectedObjectType.getDescribe()
                                                                         .fields
                                                                         .getMap();

        for(String fieldName : fieldResult.keySet()) {
            if(fieldResult.get(fieldName).getDescribe().isCreateable() == true) {
                query += fieldName + ', ';
            }
        }
        
        query = query.removeEnd(', ');
        
        query += ' FROM ' + sObjectName;
        
        /*if(!String.isBlank(condition)) {
            query += ' WHERE ' + condition;
        }*/
        
        System.debug(' ---- query ---- : ' + query);
        return query;
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
                // p.ASI_MFM_Plan__c = null; // DC - 01/27/2016 - Include Plan info in clone function
                p.ASI_MFM_ETL__c = false;
                p.ASI_MFM_Is_Direct_Payment__c = true; // DC - 01-Mar-2016 - Set Direct Payment to True when cloning to achieve the deletion functionality
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
        
		//WL 20190405 
		List<ASI_MFM_Prefix__c> prefixList = px_map.values();
		update prefixList;
		//ASI_MFM_Function.updatePrefix(px_map.values());           
    }

    public static void routineAfterUpdate(list<ASI_MFM_Payment__c> trigger_new, map<id, ASI_MFM_Payment__c> trigger_oldMap) {   
        System.debug('Start Payment routineAfterUpdate');

        Set<ID> paymentIDSet = new Set<ID>();
        List<ASI_MFM_Payment__c> capHKSubmittedPaymentList = new List<ASI_MFM_Payment__c>();
        List<ASI_MFM_Payment__c> capHKFinalPaymentList = new List<ASI_MFM_Payment__c>();
        for (ASI_MFM_Payment__c payment : trigger_new){   
            //Wilken 20161123, Update PO Status when Payment Status is changed, need to exclude Accrual PO
			//Wilken 20190405 In new CAPEX process, PO should be Final before payment raised, so the automation to make PO status follow Payment is obsolete
            /*if(trigger_oldMap.get(payment.id).ASI_MFM_Plan__c != payment.ASI_MFM_Plan__c  || trigger_oldMap.get(payment.id).ASI_MFM_Payment_Type__c != payment.ASI_MFM_Payment_Type__c
                    || trigger_oldMap.get(payment.id).ASI_MFM_Status__c != payment.ASI_MFM_Status__c ){
                paymentIDSet.add(payment.id);
            }*/
            if (Global_RecordTypeCache.getRt(payment.RecordTypeId).developerName == 'ASI_MFM_CAP_Payment'){
                /* Added by Laputa (Hector)
                        CAPEX/OPEX: 3-way matching
                            Scope: RecordType = ASI_MFM_CAP_Payment
                            After Submit: Create PO Receipt and PO Receipt Line from PO
                            After Approval: Create Payment Line from PO Receipt Line
                */
                if(payment.ASI_MFM_Status__c == 'Pending Goods/Service Receipt' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Draft'){
                    capHKSubmittedPaymentList.add(payment);
                }
            }
            
        }
        //Generate PO Receipt
		if (capHKSubmittedPaymentList.size() > 0) //WL 2.0
			generatePOReceiptSubmitApproval(capHKSubmittedPaymentList);
        
		//Wilken 20190405 In new CAPEX process, PO should be Final before payment raised, so the automation to make PO status follow Payment is obsolete
        /*if (paymentIDset.size() > 0){
            List<ASI_MFM_PO__c> poHeaderToUpdate = new List<ASI_MFM_PO__c>();
            
            Set<ID> poIDSet = new Set<ID>();
            Map<ID, Integer> poLineCountMap = new Map<ID, Integer>();
            
            List<ASI_MFM_Payment__c> paymentList = [SELECT ID, Name, ASI_MFM_Payment_Type__c,ASI_MFM_Plan__c, ASI_MFM_Status__c, (SELECT ID, Name, ASI_MFM_PO_Line_Item__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c FROM Payment_Line_Items__r)
                                                        FROM ASI_MFM_Payment__c WHERE ID IN : paymentIDset];
            
            
            for (ASI_MFM_Payment__c payment : paymentList){
                List<ASI_MFM_Payment_Line_Item__c> paymentLineList = payment.Payment_Line_Items__r;
                for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList){
                    poIDSet.add(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                }
            }
            
            Map<ID, ASI_MFM_PO__c> poMap = new Map<ID, ASI_MFM_PO__c>([SELECT ID, Name, ASI_MFM_PO_Type__c,ASI_MFM_Plan__c, recordTypeId FROM ASI_MFM_PO__c WHERE ID IN: poIDSet]);  
            
            Set<ID> poCheckSet = new Set<ID>();
            for (ASI_MFM_Payment__c payment : paymentList){
                List<ASI_MFM_Payment_Line_Item__c> paymentLineList = payment.Payment_Line_Items__r;
                for (ASI_MFM_Payment_Line_Item__c paymentLine : paymentLineList){
                    if(!poCheckSet.contains(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c) && Global_RecordTypeCache.getRt(poMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c).recordTypeId).developerName == 'ASI_MFM_CAP_PO'){
                        ASI_MFM_PO__c po = poMap.get(paymentLine.ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__c);
                        po.ASI_MFM_PO_Type__c = payment.ASI_MFM_Payment_Type__c;
                        po.ASI_MFM_Plan__c = payment.ASI_MFM_Plan__c;
                        po.ASI_MFM_Status__c = payment.ASI_MFM_Status__c;                       
                        poHeaderToUpdate.add(po);
                        poCheckSet.add(po.id);
                    }
                }
            }                
            
            if(poHeaderToUpdate.size() > 0)
                update poHeaderToUpdate;
        }*/


        // CAPEX Logic: Implement the mass submit for approval trigger for the list view
        
        String CAPEX_BUCodeDefault;
        String OPEX_BUCodeDefault;
        
        for(ASI_MFM_Default_Value__c Setting : ASI_MFM_Default_Value__c.getAll().values()){
            // CAPEX: set the capex bu code default
            if (setting.name == 'CAP_CAPEX_BU_Code__c' && Setting.Country__c == 'HK') {
                CAPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
            // OPEX: set the opex bu code default
            if (setting.name == 'CAP_OPEX_BU_Code__c' && Setting.Country__c == 'HK') {
                OPEX_BUCodeDefault = Setting.ASI_MFM_value__c;
            }
        }
        
        paymentIDSet.clear();
        
        for(ASI_MFM_Payment__c payment : trigger_new){            
            paymentIDSet.add(payment.id);
        }
        
        Map<ID,ASI_MFM_Payment_Line_Item__c> itemMap = new Map<ID,ASI_MFM_Payment_Line_Item__c>([select ASI_MFM_Invoice_Date__c, ASI_MFM_Invoice_Number__c, ASI_MFM_Payee__c, 
            ASI_MFM_G_L_Date__c, ASI_MFM_BU__c, ASI_MFM_A_C_Code__c, ASI_MFM_AP_Code__c, ASI_MFM_Payment__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Payment_Date__c 
                from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentIDSet]);
        
        Set<ASI_MFM_Payment_Line_Item__c> itemsForUpdate = new Set<ASI_MFM_Payment_Line_Item__c>();
        List<ASI_MFM_Payment_Line_Item__c> itemsListForUpdate = new List<ASI_MFM_Payment_Line_Item__c>();
        Boolean needUpdateFlag = false;
        
        for(ASI_MFM_Payment__c payment : trigger_new){            
            //Update Payment Header Supplier (i.e. Payee), Invoice Date and Invoice Number into detail lines
            //Update G/L Date into Payment Line Payment Date for OBI Report
            if ((payment.ASI_MFM_Invoice_Number__c != trigger_oldMap.get(payment.id).ASI_MFM_Invoice_Number__c 
                || payment.ASI_MFM_Invoice_Date__c != trigger_oldMap.get(payment.id).ASI_MFM_Invoice_Date__c 
                 || payment.ASI_MFM_G_L_Date__c != trigger_oldMap.get(payment.id).ASI_MFM_G_L_Date__c
                 || payment.ASI_MFM_Cashflow_Date__c != trigger_oldMap.get(payment.id).ASI_MFM_Payment_Date__c
                    || payment.ASI_MFM_Supplier_Name__c != trigger_oldMap.get(payment.id).ASI_MFM_Supplier_Name__c
                        || payment.ASI_MFM_Payment_Type__c != trigger_oldMap.get(payment.id).ASI_MFM_Payment_Type__c
                            || payment.ASI_MFM_AP_Code__c != trigger_oldMap.get(payment.id).ASI_MFM_AP_Code__c) 
                || payment.ASI_MFM_Status__c == 'Finance Verified' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Final'){
                
                for(ASI_MFM_Payment_Line_Item__c item : itemMap.values()) {
                    needUpdateFlag = false;
                    
                    if (payment.ASI_MFM_Invoice_Date__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_Invoice_Date__c = payment.ASI_MFM_Invoice_Date__c;
                        needUpdateFlag = true;
                    }
                    
                    if (payment.ASI_MFM_G_L_Date__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_G_L_Date__c = payment.ASI_MFM_G_L_Date__c;
                        needUpdateFlag = true;
                    }
                    
                    if (payment.ASI_MFM_Cashflow_Date__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_Payment_Date__c = payment.ASI_MFM_Cashflow_Date__c;
                        needUpdateFlag = true;
                    }
                    
                    if (payment.ASI_MFM_Invoice_Number__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_Invoice_Number__c = payment.ASI_MFM_Invoice_Number__c;
                        needUpdateFlag = true;
                    }

                    if (payment.ASI_MFM_Supplier_Name__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_Payee__c = payment.ASI_MFM_Supplier_Name__c;
                        needUpdateFlag = true;
                    }
                    
                    if (payment.ASI_MFM_AP_Code__c != null && item.ASI_MFM_Payment__c == payment.id){
                        item.ASI_MFM_AP_Code__c = payment.ASI_MFM_AP_Code__c;
                        needUpdateFlag = true;
                    }
                    
                    //Added by Wilken on 20150122, only update default BU if Payment Type is changed
                    if (payment.ASI_MFM_Payment_Type__c != trigger_oldMap.get(payment.id).ASI_MFM_Payment_Type__c  && item.ASI_MFM_Payment__c == payment.id){
                        if (payment.ASI_MFM_Payment_Type__c == 'CAPEX'){
                            item.ASI_MFM_BU__c = CAPEX_BUCodeDefault;
                        }
                        else if (payment.ASI_MFM_Payment_Type__c == 'OPEX'){
                            item.ASI_MFM_BU__c = OPEX_BUCodeDefault;
                        }
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
                //Validate all Payment need to have Plan
                if(payment.ASI_MFM_Plan__c == null){
                    payment.adderror('Please select the Plan before submit for approval');
                }

                //Validate all mandatory fields in payment line has value
                for(ASI_MFM_Payment_Line_Item__c item : itemMap.values()) {
                    if (item.ASI_MFM_Invoice_Date__c == null && item.ASI_MFM_Payment__c == payment.id){
                        payment.adderror('Please enter Invoice Date');
                    }
                    else if (item.ASI_MFM_Invoice_Number__c == null && item.ASI_MFM_Payment__c == payment.id){
                        payment.adderror('Please enter Invoice Number');
                    }
                    else if (item.ASI_MFM_Payee__c == null && item.ASI_MFM_Payment__c == payment.id){
                        payment.adderror('Please enter Supplier Name');
                    }
                    else if (item.ASI_MFM_BU__c == null && item.ASI_MFM_BU_Allocation__c == null && item.ASI_MFM_Payment__c == payment.id){
                        payment.adderror('Please enter BU or BU Allocation');
                    }
                    else if (item.ASI_MFM_A_C_Code__c == null && item.ASI_MFM_Payment__c == payment.id){
                        payment.adderror('Please enter A/C Code');
                    }
                    else if (item.ASI_MFM_AP_Code__c == null && item.ASI_MFM_Payment__c == payment.id){
                        payment.adderror('Please enter AP Code');
                    }
                    else if (item.ASI_MFM_Payment_Amount__c == null && item.ASI_MFM_Payment__c == payment.id){
                        payment.adderror('Please enter Payment Amount');
                    }
                }
                
                if (!payment.ASI_MFM_Approved__c){
                    try
                    {
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setObjectId(payment.id);
                        Approval.ProcessResult result = Approval.process(req1);
                        
                        if (!result.isSuccess())
                        {
                            payment.addError('Payment ' + payment.name + ' failed for submit for approval.');
                        }
                    }
                    catch (System.DmlException e)
                    {
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
        // CAPEX Logic: Implement the mass submit for approval trigger for the list view
        for(ASI_MFM_Payment__c payment : trigger_new){
            if(payment.ASI_MFM_Status__c == 'Submitted' && trigger_oldMap.get(payment.id).ASI_MFM_Status__c != payment.ASI_MFM_Status__c 
                && trigger_oldMap.get(payment.id).ASI_MFM_Status__c == 'Draft' && !payment.ASI_MFM_Approved__c){
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
                
        Set<ID> supplierID = new Set<ID> ();
        List<Id> paymentIdList = new List<Id>();
        
        for (ASI_MFM_Payment__c pay:trigger_new) {
            // DC - 02/04/2016 - Calling method for VAT Amount calculation.
            calculateVatAmount(pay, trigger_oldMap);
            if(trigger_oldMap == null)
                supplierID.add(pay.ASI_MFM_Supplier_Name__c);
            else if(trigger_oldMap.get(pay.id).ASI_MFM_Invoice_Number__c != pay.ASI_MFM_Invoice_Number__c || trigger_oldMap.get(pay.id).ASI_MFM_Supplier_Name__c != pay.ASI_MFM_Supplier_Name__c)
                supplierID.add(pay.ASI_MFM_Supplier_Name__c);
                
            //Wilken 20161117, clear Payment Line AP Code and BU Code if Payment Type is changed
            if (Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_CAP_Payment')){
                if (trigger_oldMap != null && pay.ASI_MFM_Payment_Type__c != trigger_oldMap.get(pay.Id).ASI_MFM_Payment_Type__c)
                    paymentIdList.add(pay.Id);
            }
        }
        
        if (paymentIdList.size() > 0){
            List<ASI_MFM_Payment_Line_Item__c> paymentItemList = [select Id, ASI_MFM_AP_Code__c, ASI_MFM_A_C_Code__c, ASI_MFM_BU__c from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c in :paymentIdList];
            
            for (ASI_MFM_Payment_Line_Item__c payLine:paymentItemList){
                payLine.ASI_MFM_AP_Code__c = null;
                payLine.ASI_MFM_A_C_Code__c = null;
                payLine.ASI_MFM_BU__c = null;
            }
            
            update paymentItemList;
        }
        
        if(supplierID.size() > 0){
            List<ASI_MFM_Payment__c> paymentSameSupplier = [SELECT ID, Name, ASI_MFM_Invoice_Number__c, ASI_MFM_Supplier_Name__c 
                                                            FROM ASI_MFM_Payment__c 
                                                            WHERE ASI_MFM_Supplier_Name__c IN: supplierID 
                                                            AND recordtype.developername LIKE 'ASI_MFM_CAP%'];
            
            //20181203 Wilken: the soql should be applied to SG CAP Payment only
            /*[WL 20181203] BEGIN*/
            //Map<ID,Account> supplierMap = new Map<ID, Account>([select recordType.DeveloperName from Account where id = :supplierID]);
            Map<ID,Account> supplierMap = new Map<ID, Account>();
            if (Global_RecordTypeCache.getRt(trigger_new.get(0).recordTypeId).developerName.contains('ASI_MFM_CAP_SG'))
                for (Account acc: [select recordType.DeveloperName from Account where id = :supplierID]){
                    supplierMap.put(acc.Id, acc);
                }
            /*[WL 20181203] END*/
            
            for (ASI_MFM_Payment__c pay:trigger_new) {
                for(ASI_MFM_Payment__c payment : paymentSameSupplier){
                    if(pay.ASI_MFM_Invoice_Number__c !=null && payment.ASI_MFM_Invoice_Number__c == pay.ASI_MFM_Invoice_Number__c && payment.id != pay.id)
                        pay.adderror('Cannot have duplicate Invoice Number under the same Supplier');
                }
                
                if (Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_CAP_SG')){
                    if (supplierMap.get(pay.ASI_MFM_Supplier_Name__c).recordType.DeveloperName != 'ASI_MFM_CAP_SG_Supplier')
                        pay.adderror('Please select OPEX SG Supplier record type');
                }
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
            System.debug('------ DC base_ccy ------ : ' + base_ccy);
            // Conrad Pantua 20140704 Handle Capex Country (Laputa)
            if (country == 'CA')
            {
                List<User> lstUsers = [SELECT Id,
                                              ASI_MFM_Country__c
                                         FROM User
                                        WHERE Id = :UserInfo.getUserId()
                                        LIMIT 1];

                if(!lstUsers.isEmpty() && !String.isBlank(lstUsers[0].ASI_MFM_Country__c) && lstUsers[0].ASI_MFM_Country__c.equalsIgnoreCase('TW')) {
                    country = 'TW';
                    base_ccy = 'TWD';
                } else {
                    country = 'HK';
                    base_ccy = 'HKD';
                }
            }
            trigger_new[0].ASI_MFM_Sys_Local_Currency__c = base_ccy;
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
        set<id> pr_set = new set<id>();
		set<id> poid_set = new set<id>();	//[WL 2.0]
		Map<id,id> poOwner_map = new Map<id,id>();	//[WL 2.0]
		Map<id,ASI_MFM_PO__c> poMap = new Map<id,ASI_MFM_PO__c>();	//[WL 4.0]
        set<string> STeam = new set<string>();
        
        //Default approver assignment logic, not applied to CN, GF      
        for (ASI_MFM_Payment__c p:trigger_new) {
            if (p.ASI_MFM_Payment_Amount__c != null && p.ASI_MFM_Exchange_Rate__c > 0) {
                pid_set.add(p.id);
                px_set.add(p.ASI_MFM_Prefix__c);                                                       
                pr_set.add(p.ownerID);
				
				if (p.ASI_MFM_Status__c == 'Draft')	//[WL 4.0]
					poid_set.add(p.ASI_MFM_CAP_PO__c); //[WL 2.0]
            }
        }
		
		/*[WL 2.0] BEGIN*/
		if (poid_set.size() > 0){
			List<ASI_MFM_PO__c> poList = [SELECT Id, OwnerId, ASI_MFM_Plan__c FROM ASI_MFM_PO__c WHERE ID IN :poid_set];
			
			for (ASI_MFM_PO__c po:poList){
				poOwner_map.put(po.Id, po.OwnerId);
				poMap.put(po.Id, po);	//[WL 4.0]
			}
			
			/*[WL 4.0] BEGIN*/
			for (ASI_MFM_Payment__c p:trigger_new) {
				if (Global_RecordTypeCache.getRt(p.recordTypeId).developerName.contains('ASI_MFM_CAP_Payment') && poMap.get(p.ASI_MFM_CAP_PO__c) != null){
					p.ASI_MFM_Plan__c = poMap.get(p.ASI_MFM_CAP_PO__c).ASI_MFM_Plan__c;
				}
			}
			// /*[WL 4.0] END*/
		}
		/*[WL 2.0] END*/

        //CAPEX HK: Approvers route type logic        
        list<ASI_MFM_Brand_Route_Type_Map__c> brm_list = new list<ASI_MFM_Brand_Route_Type_Map__c>();
        
        if (Global_RecordTypeCache.getRt(trigger_new.get(0).recordTypeID).DeveloperName.contains('ASI_MFM_CAP_Payment') || Global_RecordTypeCache.getRt(trigger_new.get(0).recordTypeID).DeveloperName.contains('ASI_MFM_CAP_T_E_')){
            //Regional IT CAPEX OPEX Logic
            brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c, ASI_MFM_Responsible_By__c from ASI_MFM_Brand_Route_Type_Map__c 
						where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set and 
							//ASI_MFM_Responsible_By__c in :poid_set [WL 2.0]
							ASI_MFM_Responsible_By__c in :poOwner_map.values() 	//[WL 2.0]
						order by ASI_MFM_Prefix__c, ASI_MFM_Responsible_By__c desc];
        }
        else {
            //Other CAPEX OPEX Logic
            brm_list = [select ASI_MFM_Prefix__c, ASI_MFM_Route_Type__c from ASI_MFM_Brand_Route_Type_Map__c 
                    where ASI_MFM_Active__c = true and ASI_MFM_Prefix__c in :px_set order by ASI_MFM_Prefix__c desc];
        }
        
        set<id> rt_set = new set<id>();     
            
        for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
            rt_set.add(brm.ASI_MFM_Route_Type__c);
        }      
        system.debug('** rt_set **' + rt_set );        
        
        list<ASI_MFM_Route_Rule_Detail__c> rule_list = new list<ASI_MFM_Route_Rule_Detail__c>();
        //HK CAEPX: Approver order by sequence defined
        if (Global_RecordTypeCache.getRt(trigger_new.get(0).recordTypeID).DeveloperName.contains('ASI_MFM_CAP_Payment')){
            rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c from ASI_MFM_Route_Rule_Detail__c 
                    where ASI_MFM_Route_Type__c in : rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Sequence__c asc];
            system.debug('HK CAPEX Route Rule Detail: ' + rule_list);
        }
        else {
        //Other CAPEX: Approver order by amount threshold
            rule_list = [select ASI_MFM_Approver__c, ASI_MFM_Minimum_Amount__c, ASI_MFM_Route_Type__c from ASI_MFM_Route_Rule_Detail__c 
                    where ASI_MFM_Route_Type__c in : rt_set order by ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c asc];
        }
        
        
        //Logic to fetch Route Type and Rule Details for 'Payment' module and 'TW' Country
        ID ASI_MFM_CAP_TWRouteTypeID = Global_RecordTypeCache.getRtId('ASI_MFM_Route_Type__cASI_MFM_CAP_OTH_Route_Type');
        List<ASI_MFM_Route_Rule_Detail__c> routeDetailsListTW = new List<ASI_MFM_Route_Rule_Detail__c>();
        
        List<ASI_MFM_Route_Type__c> routeTypeList = [SELECT ID, Name, RecordTypeId, 
                                                            ASI_MFM_Country__c, ASI_MFM_Module__c,
                                                           (SELECT ID, Name, ASI_MFM_Approver__c, ASI_MFM_Route_Type__c, ASI_MFM_Minimum_Amount__c 
                                                            FROM ASI_MFM_Route_Rule_Details__r 
                                                            ORDER BY ASI_MFM_Sequence__c ASC)
                                                     FROM ASI_MFM_Route_Type__c
                                                     WHERE ASI_MFM_Module__c = 'Payment' 
                                                     AND recordtypeid = :  ASI_MFM_CAP_TWRouteTypeID
                                                     AND ASI_MFM_Country__c =  'TW'];
        
        
                                                     
        if(!routeTypeList.isEmpty() && routeTypeList[0].ASI_MFM_Route_Rule_Details__r <> null && 
           !routeTypeList[0].ASI_MFM_Route_Rule_Details__r.isEmpty()){
            
            routeDetailsListTW = routeTypeList[0].ASI_MFM_Route_Rule_Details__r;
        }//End if 
                
        
        for (ASI_MFM_Payment__c pay : trigger_new){
            system.debug('Start iterate each payment for apprver assignment');
            //integer approver_count = 0;
            //Assign approver only after input payment lines and all approovers fields (Approver 2 to 10) are empty, to allow manual override approver assignment
            //Added to assign approver whenever owner is changed
            if (pid_set.contains(pay.id) 
                && (
                    (pay.ASI_MFM_Sys_Approver_2__c == null && pay.ASI_MFM_Sys_Approver_3__c == null && pay.ASI_MFM_Sys_Approver_4__c == null && pay.ASI_MFM_Sys_Approver_5__c == null 
                        && pay.ASI_MFM_Sys_Approver_6__c == null && pay.ASI_MFM_Sys_Approver_7__c == null && pay.ASI_MFM_Sys_Approver_8__c == null && pay.ASI_MFM_Sys_Approver_9__c == null 
                            && pay.ASI_MFM_Sys_Approver_10__c == null)
                    || (trigger_oldMap != null && (trigger_oldMap.get(pay.id).ownerid != pay.ownerid || trigger_oldMap.get(pay.id).ASI_MFM_Payment_Amount__c  != pay.ASI_MFM_Payment_Amount__c))
                    )
                ) 
            {
                id rtid;
                for (ASI_MFM_Brand_Route_Type_Map__c brm:brm_list) {
					/*[WL 2.0] BEGIN*/
                    if (Global_RecordTypeCache.getRt(pay.recordTypeID).DeveloperName.contains('ASI_MFM_CAP_Payment')){	//[WL 2.0] This will be used by Regional IT CAPEX
                        if (brm.ASI_MFM_Prefix__c == pay.ASI_MFM_Prefix__c && brm.ASI_MFM_Responsible_By__c == poOwner_map.get(pay.ASI_MFM_CAP_PO__c)) {
                            rtid = brm.ASI_MFM_Route_Type__c;
                            break;
                        }
                    }
					/*[WL 2.0] END*/
					else if (Global_RecordTypeCache.getRt(pay.recordTypeID).DeveloperName.contains('ASI_MFM_CAP')){	//[WL 2.0] This will be used by CAP TW
                        if (brm.ASI_MFM_Prefix__c == pay.ASI_MFM_Prefix__c && brm.ASI_MFM_Responsible_By__c == pay.ownerID) {
                            rtid = brm.ASI_MFM_Route_Type__c;
                            break;
                        }
                    }
                    else {
                        if (brm.ASI_MFM_Prefix__c == pay.ASI_MFM_Prefix__c) {
                            rtid = brm.ASI_MFM_Route_Type__c;
                            break;
                        }
                        else if (brm.ASI_MFM_Prefix__c > pay.ASI_MFM_Prefix__c) {
                            break;
                        }              
                    }
                }
                
                //Checking if the RecordType contains ASI_MFM_CAP_TW
                if(Global_RecordTypeCache.getRt(pay.recordTypeId).developerName.contains('ASI_MFM_CAP_TW') &&
                   routeDetailsListTW <> null && !routeDetailsListTW.isEmpty()){
                    
                    populateApprover(pay, 'tw', null, routeDetailsListTW);
                }//End if
                else if(rule_list <> null && !rule_list.isEmpty()){
                    system.debug('Other CAPEX, populate with rule_list');
                    populateApprover(pay, 'other', rtid , rule_list);
                }//End else
                
                /*
                if (rtid != null) {
                    for (ASI_MFM_Route_Rule_Detail__c rd: rule_list) {
                        if (rd.ASI_MFM_Route_Type__c == rtid) {
                            if (approver_count == 0) {                                 
                                pay.ASI_MFM_Sys_Approver_2__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 1) {                                 
                                pay.ASI_MFM_Sys_Approver_3__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 2) {                                 
                                pay.ASI_MFM_Sys_Approver_4__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 3) {                                 
                                pay.ASI_MFM_Sys_Approver_5__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 4) {                                 
                                pay.ASI_MFM_Sys_Approver_6__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 5) {                                 
                                pay.ASI_MFM_Sys_Approver_7__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 6) {                                 
                                pay.ASI_MFM_Sys_Approver_8__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 7) {                                 
                                pay.ASI_MFM_Sys_Approver_9__c = rd.ASI_MFM_Approver__c;
                            }
                            else if (approver_count == 8) {                                 
                                pay.ASI_MFM_Sys_Approver_10__c = rd.ASI_MFM_Approver__c;
                            }
                            approver_count++;  
                        }
                    }
                } */
            }   
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
    }//End routineBeforeUpsert method
    
    
    //The method will populate Approvers on Payment record 
    public static void populateApprover(ASI_MFM_Payment__c paymentRecord, String pType, ID pRtId,
                                        List<ASI_MFM_Route_Rule_Detail__c> pLstRouteRuleDtls){
        Integer approver_count= 0;
        decimal local_amount = paymentRecord.ASI_MFM_Payment_Amount__c * paymentRecord.ASI_MFM_Exchange_Rate__c;
         
        paymentRecord.ASI_MFM_Sys_Approver_2__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_3__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_4__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_5__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_6__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_7__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_8__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_9__c = null;
        paymentRecord.ASI_MFM_Sys_Approver_10__c = null;
        
        for(ASI_MFM_Route_Rule_Detail__c routeDetail : pLstRouteRuleDtls){            
            if((pType == 'tw' || (pType == 'other' && routeDetail.ASI_MFM_Route_Type__c == pRtId)) && routeDetail.ASI_MFM_Minimum_Amount__c <= local_amount){
                if (approver_count == 0)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_2__c = routeDetail.ASI_MFM_Approver__c;
                    
                else if (approver_count == 1)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_3__c = routeDetail.ASI_MFM_Approver__c;
                
                else if (approver_count == 2)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_4__c = routeDetail.ASI_MFM_Approver__c;
                
                else if (approver_count == 3)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_5__c = routeDetail.ASI_MFM_Approver__c;
                
                else if (approver_count == 4)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_6__c = routeDetail.ASI_MFM_Approver__c;
                
                else if (approver_count == 5)                                 
                    paymentRecord.ASI_MFM_Sys_Approver_7__c = routeDetail.ASI_MFM_Approver__c;
                
                else if (approver_count == 6)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_8__c = routeDetail.ASI_MFM_Approver__c;
            
                else if (approver_count == 7)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_9__c = routeDetail.ASI_MFM_Approver__c;
                
                else if (approver_count == 8)                                  
                    paymentRecord.ASI_MFM_Sys_Approver_10__c = routeDetail.ASI_MFM_Approver__c;
                
                approver_count++;
            }//End if pType == 'tw'
        }//End for 
    }//End assignApprover method

    // DC - 02/04/2016 - Added logic for calculation of VAT Amount.
    public static void calculateVatAmount(ASI_MFM_Payment__c pay, Map<Id, ASI_MFM_Payment__c> trigger_oldmap) {
        if (pay.ASI_MFM_VAT_Amount__c == null || 
            (trigger_oldmap != null && pay.ASI_MFM_Payment_Amount__c != trigger_oldmap.get(pay.id).ASI_MFM_Payment_Amount__c) ||
            (trigger_oldmap != null && pay.ASI_MFM_VAT_Percentage__c != trigger_oldmap.get(pay.id).ASI_MFM_VAT_Percentage__c)) {
        
            Decimal percent = ASI_MFM_Function.getPercentage(pay.ASI_MFM_VAT_Percentage__c);
        
            if (percent != NULL && pay.ASI_MFM_Payment_Amount__c != NULL) {
                if (pay.ASI_MFM_Currency__c == 'TWD') {
                    pay.ASI_MFM_VAT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent).setScale(0, roundingmode.HALF_EVEN);
                }
                else {                          
                    pay.ASI_MFM_VAT_Amount__c = (pay.ASI_MFM_Payment_Amount__c * percent).setScale(2, roundingmode.HALF_EVEN);
                }
            }
        
            else {
                pay.ASI_MFM_VAT_Amount__c = null;
            }
        }
    }
    
    public static void generatePOReceiptSubmitApproval(List<ASI_MFM_Payment__c> capHKSubmittedPaymentList){
        //Generate PO Receipt
        system.debug('capHKSubmittedPaymentList:' + capHKSubmittedPaymentList);
        List<ASI_MFM_PO_Receipt__c> generatedPOReceiptList = ASI_MFM_CAP_HK_POReceiptGeneration.GenerateHKPOReceiptFromPO(capHKSubmittedPaymentList);
        //Put those PO Receipt to Approval Process
        for(ASI_MFM_PO_Receipt__c poReceipt : generatedPOReceiptList){
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(poReceipt.id);
            req.setSubmitterId(UserInfo.getUserId());
            Approval.ProcessResult result = Approval.process(req);
        }
        
    }
    
}//End Class