/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_PR_AssignSpController       
 * Test Class:  ASI_CTY_CN_Vendor_PR_AssignSpCtrTest
 * Description: Assign Supplier Page Controller In PR Line Item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-10-22       Baymax                  Create Class
 * 2020-10-22       Baymax                  Create Function updateQuotation
 * 2020-10-25       Baymax                  Create Function initSupplierList
 * 2020-10-25       Baymax                  Create Function assignSupplier
 *****************************************************************************************************************/
global without sharing class ASI_CTY_CN_Vendor_PR_AssignSpController {
    public Id prlIdBase {get;set;}
    public static ASI_MFM_Purchase_Request_Line__c prl {get;set;}
	public String quotationList {get;set;}
    public String purLineList {get;set;}
    public Boolean isReadPriv {get;set;}

	global ASI_CTY_CN_Vendor_PR_AssignSpController(ApexPages.StandardController con) {
		Id prlId = con.getId();
        Id userId = System.UserInfo.getUserId();
        System.debug(LoggingLevel.INFO, '*** prlId: ' + prlId);
        prlIdBase = prlId;
        
        prl = [SELECT Id, Name, ASI_MFM_Purchase_Request__r.Name, ASI_MFM_Purchase_Request__r.Id, CreatedDate,
            ASI_MFM_Purchase_Request__r.CreatedBy.Name, ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c,
            ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Eng_Name__c, ASI_CTY_CN_Vendor_Item_Group_Code__r.Id, 
            ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Item_Group_Code__c, ASI_CTY_CN_Vendor_Sample_Required__c, 
            ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Status__c, ASI_CTY_CN_Vendor_Bidding_Deadline__c, 
            ASI_CTY_CN_Vendor_Select_Quotation__r.Name, ASI_CTY_CN_Vendor_Select_Quotation__r.Id, ASI_CTY_CN_Vendor_Unit_Price__c,
            ASI_CTY_CN_Vendor_Approval_Buyer__c, ASI_CTY_CN_Vendor_Is_MKT_Submit__c,
            ASI_CTY_CN_Vendor_Model_Required__c FROM ASI_MFM_Purchase_Request_Line__c WHERE Id = :prlId];

        isReadPriv = false;
        List<ProcessInstance> proList = [SELECT Id, Status FROM ProcessInstance where TargetObject.Id = :prlId AND Status = 'Pending'];

        Set<Id> processInstanceWorkItemIds = null;
        if (proList != null && proList.size() > 0) {
            processInstanceWorkItemIds = new Set<Id>();
            for (ProcessInstance pi : proList) {
                processInstanceWorkItemIds.add(pi.Id);
            }
        }

        List<ProcessInstanceWorkItem> piList = null;
        if (processInstanceWorkItemIds != null && processInstanceWorkItemIds.size() > 0) {
            piList = [SELECT Id, ActorId FROM ProcessInstanceWorkItem where ProcessInstanceId In :processInstanceWorkItemIds];
            if (piList != null && piList.size() > 0) {
                for (ProcessInstanceWorkItem piwi : piList) {
                    if (piwi.ActorId == userId && prl.ASI_CTY_CN_Vendor_Approval_Buyer__c == userId) {
                        isReadPriv = true;
                    }
                }
            }
        }

        if (!prl.ASI_CTY_CN_Vendor_Is_MKT_Submit__c && prl.ASI_CTY_CN_Vendor_Approval_Buyer__c == userId && prl.ASI_CTY_CN_Vendor_Status__c != ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_SUBMITTED) {
            isReadPriv = true;
        }

		Id quotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
        Id mergeQuotationRecordId = ASI_CTY_CN_Vendor_Util.mergeQuotationRecordId;
        Id prLineRecordId = ASI_CTY_CN_Vendor_Util.prLineRecordId;
        Set<Id> prLineIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();

        // select all merge quotation list
        Set<Id> quotationIds = new Set<Id>();
        for (ASI_CRM_quotation__c q : [SELECT Id, ASI_CTY_CN_Vendor_Quotation__r.Id, ASI_CTY_CN_Purchase_Request_Line__r.Id FROM ASI_CRM_quotation__c 
        	WHERE ASI_CTY_CN_Purchase_Request_Line__c = :prlId AND RecordTypeId = :quotationRecordId]) {
            quotationIds.add(q.ASI_CTY_CN_Vendor_Quotation__r.Id);
        }

        List<ASI_CRM_quotation__c> quoteList = null;
        if (quotationIds.size() > 0) {
            quoteList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Supplier__r.Id, ASI_CTY_CN_Vendor_Supplier__r.Name,
            ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Sample__c, ASI_CTY_CN_Vendor_Model__c,
            ASI_CTY_CN_Vendor_Merge_Total_Freight__c, ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Remark__c, ASI_CTY_CN_Vendor_PO__r.Name, ASI_CTY_CN_Vendor_PO__c,
            ASI_CTY_CN_Vendor_DeadLine__c, ASI_CTY_CN_Vendor_Status__c, toLabel(ASI_CTY_CN_Vendor_Status__c) StatusInfo, ASI_CTY_CN_Vendor_Result_Status__c, 
            toLabel(ASI_CTY_CN_Vendor_Result_Status__c) ResultStatus, ASI_CTY_CN_Vendor_IsConfirmed__c,
            ASI_CTY_CN_Vendor_Deadline_Date__c, ASI_CTY_CN_Vendor_Reject_Reason__c, ASI_CTY_CN_Vendor_Unitl_Price__c, ASI_CTY_CN_Vendor_IsVisible__c,
            (SELECT Id, Name, ASI_CTY_CN_Vendor_Quantity__c, ASI_CTY_CN_Vendor_Unitl_Price__c, ASI_CTY_CN_Vendor_Sample__c, ASI_CTY_CN_Vendor_Model__c, ASI_CTY_CN_Vendor_Confirmed_Price__c,
                ASI_CTY_CN_Vendor_Total_Freight__c, ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_PO__c, ASI_CTY_CN_Vendor_PO__r.Name FROM Quotations_quotation__r 
                WHERE ASI_CTY_CN_Purchase_Request_Line__c = :prlId AND RecordTypeId = :quotationRecordId)
                FROM ASI_CRM_quotation__c WHERE Id IN :quotationIds AND RecordTypeId = :mergeQuotationRecordId];

            // get all merge quotation id
            if (quoteList != null && quoteList.size() > 0) {
                for (ASI_CRM_quotation__c q : quoteList) {
                    quoteIds.add(q.Id);
                }
            }

            for (ASI_CRM_quotation__c  q : [SELECT Id, Name, (SELECT Id, Name, ASI_CTY_CN_Purchase_Request_Line__c FROM Quotations_quotation__r 
                WHERE ASI_CTY_CN_Purchase_Request_Line__c != :prlId AND RecordTypeId = :quotationRecordId)
                FROM ASI_CRM_quotation__c WHERE Id IN : quoteIds]) {
                if (q.Quotations_quotation__r.Size() > 0) {
                    for (ASI_CRM_quotation__c quote : q.Quotations_quotation__r) {
                        prLineIds.add(quote.ASI_CTY_CN_Purchase_Request_Line__c);
                    }
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** prLineIds: ' + prLineIds);
        quotationList = JSON.serialize(quoteList);

        // select merge pr line item
        List<ASI_MFM_Purchase_Request_Line__c> prLineList = null;
        if (prLineIds.size() > 0) {
            prLineList = [SELECT Id, Name, ASI_MFM_Purchase_Request__r.Name, ASI_MFM_Purchase_Request__r.Id, CreatedDate,
            ASI_MFM_Purchase_Request__r.CreatedBy.Name, ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c,
            ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Eng_Name__c, ASI_CTY_CN_Vendor_Item_Group_Code__r.Id, 
            ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Item_Group_Code__c, ASI_CTY_CN_Vendor_Sample_Required__c, 
            ASI_CTY_CN_Vendor_Total_Quantity__c, toLabel(ASI_CTY_CN_Vendor_Status__c), ASI_CTY_CN_Vendor_Bidding_Deadline__c, 
            ASI_CTY_CN_Vendor_Select_Quotation__r.Name, ASI_CTY_CN_Vendor_Select_Quotation__r.Id, ASI_CTY_CN_Vendor_Unit_Price__c
            FROM ASI_MFM_Purchase_Request_Line__c WHERE RecordTypeId = :prLineRecordId AND Id IN :prLineIds ORDER BY CreatedDate DESC];
        }
        System.debug(LoggingLevel.INFO, '*** purLineList: ' + prLineList);
        
        purLineList = JSON.serialize(prLineList);
    }

    /*
    * Method Name: initSupplierList
    * Description: init supplier list data
    * Return Type: ResultDate
    * Parameter  : String itemGroupId, String selectSupplierIds
    */
    @RemoteAction
    global static ResultDate initSupplierList(String itemGroupId, String selectSupplierIds) {
        System.debug(LoggingLevel.INFO, '*** itemGroupId: ' + itemGroupId);
        Id supplierRecordId = ASI_CTY_CN_Vendor_Util.supplierRecordId;
        Set<String> supplierIdSet = (Set<String>)JSON.deserialize(selectSupplierIds, Set<String>.class);

        List<CustomSupplier> supplierList = new List<CustomSupplier>();

        List<User> userList = [SELECT Id, Name, Contact.Id, Contact.Name, Contact.Account.Id, Contact.Account.Name FROM User 
        WHERE User.Profile.Name = 'ASI_CTY_PRCVendor_CN_User' AND IsActive = true 
        AND Contact.Account.RecordTypeId =:supplierRecordId AND Contact.Account.Id NOT IN :supplierIdSet];
        Set<Id> accountIds = new Set<Id>();
        for (User u : userList) {
            accountIds.add(u.Contact.Account.Id);
        }
        System.debug(LoggingLevel.INFO, '*** accountIds: ' + accountIds.size());
        
        List<Account> accList = [SELECT Id, Name, ASI_KOR_Addr_Region__c, ASI_MFM_City__c, Phone FROM Account 
        WHERE Id IN :accountIds];

        Map<Id, String> buyerRecentCooperation = null;
        if (accountIds.size() > 0) {
            buyerRecentCooperation = new Map<Id, String>();
            for (AggregateResult ppl : [SELECT ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c, MAX(ASI_MFM_PO__r.CreatedDate) CreatedDate
                FROM ASI_MFM_PO_POSM_Line__c WHERE ASI_MFM_Item_Group__c = :itemGroupId
                GROUP BY ASI_MFM_PO__r.ASI_MFM_Supplier_Name__c]) {
                buyerRecentCooperation.put(Id.valueOf(String.valueOf(ppl.get('ASI_MFM_Supplier_Name__c'))), String.valueOf(ppl.get('CreatedDate')));
            }
        }
        System.debug(LoggingLevel.INFO, '*** buyerRecentCooperation: ' + buyerRecentCooperation);

        for (Account acc : accList) {
            if (buyerRecentCooperation.containsKey(acc.Id)) {
                supplierList.add(new CustomSupplier(acc, buyerRecentCooperation.get(acc.Id)));
            } else {
                supplierList.add(new CustomSupplier(acc, ''));
            }
        }
        System.debug(LoggingLevel.INFO, '*** supplierList: ' + supplierList);

        return new ResultDate(1, supplierList);
    }

    /*
    * Method Name: assignSupplier
    * Description: assign PR line item to supplier
    * Return Type: ResultDate
    * Parameter  : String prlIds, String supplierIds, String supplierDeadLineDateJson, String sampleRequiredJson, String modelRequiredJson
    */
    @RemoteAction
    global static ResultDate assignSupplier(String prlIds, String supplierIds, String supplierDeadLineDateJson, String sampleRequiredJson, String modelRequiredJson) {
        System.debug(LoggingLevel.INFO, '*** prlIds: ' + prlIds);
        Set<String> prlIdSet = (Set<String>)JSON.deserialize(prlIds, Set<String>.class);
        
        List<ASI_MFM_Purchase_Request_Line__c> infoList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Item_Group_Code__c,
            ASI_CTY_CN_Vendor_Status__c, ASI_CTY_CN_Vendor_Approval_Buyer__c FROM ASI_MFM_Purchase_Request_Line__c WHERE Id IN: prlIdSet];
        
        if (infoList != null && infoList.size() > 0) {
            for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                if (prl.ASI_CTY_CN_Vendor_Approval_Buyer__c != System.UserInfo.getUserId()) {
                    return new ResultDate(0, '当前PR Line已经转发给其它的buyer,请重新刷新界面...');
                }
            }
        }
        Set<String> supplierIdSet = (Set<String>)JSON.deserialize(supplierIds, Set<String>.class);
        System.debug(LoggingLevel.INFO, '*** infoList: ' + infoList);
        System.debug(LoggingLevel.INFO, '*** supplierIds: ' + supplierIdSet);

        Map<Id, Id> supplierContactMap = null;
        List<User> supplierContactList = [SELECT Id, Name, Contact.AccountId FROM User WHERE User.Profile.Name = 'ASI_CTY_PRCVendor_CN_User' AND Contact.AccountId In :supplierIdSet];
        if (supplierContactList != null && supplierContactList.size() > 0) {
            supplierContactMap = new Map<Id, Id>();
            for (User u : supplierContactList) {
                if (!supplierContactMap.containsKey(u.Contact.AccountId)) {
                    supplierContactMap.put(u.Contact.AccountId, u.Id);
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** supplierContactMap: ' + supplierContactMap);

        Map<String, String> supplierDeadLineMap = (Map<String, String>)JSON.deserialize(supplierDeadLineDateJson, Map<String, String>.class);
        System.debug(LoggingLevel.INFO, '*** supplierDeadLineMap: ' + supplierDeadLineMap);

        Map<String, Boolean> sampleRequiredMap = (Map<String, Boolean>)JSON.deserialize(sampleRequiredJson, Map<String, Boolean>.class);
        System.debug(LoggingLevel.INFO, '*** sampleRequiredMap: ' + sampleRequiredMap);

        Map<String, Boolean> modelRequiredMap = (Map<String, Boolean>)JSON.deserialize(modelRequiredJson, Map<String, Boolean>.class);
        System.debug(LoggingLevel.INFO, '*** modelRequiredMap: ' + modelRequiredMap);

        Map<Id, Set<Id>> prLineAddrs = new Map<Id, Set<Id>>();
        Set<Id> prLineIds = new Set<Id>();
        List<ASI_CRM_quotation__c> quoteList = null;

        if (infoList != null && infoList.size() > 0) {
            Id quotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
            Id mergeQuotationRecordId = ASI_CTY_CN_Vendor_Util.mergeQuotationRecordId;

            Set<Id> addressIds = null;
            for (ASI_CRM_Address__c addr : [SELECT Id, ASI_CTY_CN_Vendor_PurLine__c 
                FROM ASI_CRM_Address__c WHERE ASI_CTY_CN_Vendor_PurLine__c IN :prlIdSet]) {
                if (!prLineAddrs.containsKey(addr.ASI_CTY_CN_Vendor_PurLine__c)) {
                    addressIds = new Set<Id>();
                } else {
                    addressIds = (Set<Id>)prLineAddrs.get(addr.ASI_CTY_CN_Vendor_PurLine__c);
                }
                addressIds.add(addr.Id);
                prLineAddrs.put(addr.ASI_CTY_CN_Vendor_PurLine__c, addressIds);
            }
            System.debug(LoggingLevel.INFO, '*** prLineAddrs: ' + prLineAddrs);

            // create merge quotation
            ASI_CRM_quotation__c q = null;
            Integer totalQuantity = 0;
            for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                totalQuantity = totalQuantity + Integer.valueOf(prl.ASI_CTY_CN_Vendor_Total_Quantity__c);
            }

            quoteList = new List<ASI_CRM_quotation__c>();
            if (supplierIdSet != null && supplierIdSet.size() > 0) {
                for (String supplierId : supplierIdSet) {
                    q = new ASI_CRM_quotation__c();
                    q.ASI_CTY_CN_Vendor_Item_Group__c = infoList[0].ASI_CTY_CN_Vendor_Item_Group_Code__c;
                    q.ASI_CTY_CN_Vendor_Old_Unitl_Price__c = 0;
                    q.ASI_CTY_CN_Vendor_Deadline_Date__c = Date.valueOf(supplierDeadLineMap.get(supplierId));
                    q.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_PENDING;
                    q.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;
                    q.RecordTypeId = mergeQuotationRecordId;
                    q.ASI_CTY_CN_Vendor_Supplier__c = Id.valueOf(supplierId);
                    q.ASI_CTY_CN_Vendor_Notification_User__c = supplierContactMap.get(supplierId);
                    q.ASI_CTY_CN_Vendor_Is_Need_Sample__c = sampleRequiredMap.get(supplierId);
                    q.ASI_CTY_CN_Vendor_Is_Need_Model__c = modelRequiredMap.get(supplierId);

                    q.ASI_CTY_CN_Vendor_Total_Quantity__c = totalQuantity;
                    q.ASI_CTY_CN_Vendor_Merge_Total_Freight__c = 0;
                    // Automatically make the offer visible to the supplier in the community
                    q.ASI_CTY_CN_Vendor_IsVisible__c = true;
                    
                    quoteList.add(q);
                }
            }
            System.debug(LoggingLevel.INFO, '*** quoteList: ' + quoteList);

            Savepoint sp = Database.setSavepoint();
            try {
                if (quoteList != null && quoteList.size() > 0) {
                    upsert quoteList;
                    System.debug(LoggingLevel.INFO, '*** quoteListNew: ' + quoteList);
                    
                    Map<Id, Id> quoatationTotal = new Map<Id, Id>();
                    // create quotation line item
                    for (ASI_CRM_quotation__c quote : quoteList) {
                        quoatationTotal.put(quote.ASI_CTY_CN_Vendor_Supplier__c, quote.Id);
                    }
                    System.debug(LoggingLevel.INFO, '*** quoatationTotal: ' + quoatationTotal);
                    
                    // create quotation according to merge quotation
                    List<ASI_CRM_quotation__c> mergeQuotationList = null;
                    if (infoList.size() > 0) {
                        mergeQuotationList = new List<ASI_CRM_quotation__c>();
                        for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                            if (supplierIdSet != null && supplierIdSet.size() > 0) {
                                for (String supplierId : supplierIdSet) {
                                    q = new ASI_CRM_quotation__c();
                                    q.ASI_CTY_CN_Vendor_Item_Group__c = prl.ASI_CTY_CN_Vendor_Item_Group_Code__c;
                                    q.ASI_CTY_CN_Vendor_Old_Unitl_Price__c = 0;
                                    q.ASI_CTY_CN_Vendor_Deadline_Date__c = Date.valueOf(supplierDeadLineMap.get(supplierId));
                                    q.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_PENDING;
                                    q.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;

                                    q.ASI_CTY_CN_Vendor_Supplier__c = Id.valueOf(supplierId);
                                    q.ASI_CTY_CN_Vendor_Notification_User__c = supplierContactMap.get(supplierId);
                                    q.ASI_CTY_CN_Vendor_Is_Need_Sample__c = sampleRequiredMap.get(supplierId);
                                    q.ASI_CTY_CN_Vendor_Is_Need_Model__c = modelRequiredMap.get(supplierId);

                                    // Automatic notification to suppliers for quotation
                                    q.ASI_CTY_CN_Vendor_IsVisible__c = true;

                                    q.ASI_CTY_CN_Purchase_Request_Line__c = prl.Id;
                                    q.RecordTypeId = quotationRecordId;
                                    q.ASI_CTY_CN_Vendor_Quotation__c = quoatationTotal.get(supplierId);
                                    mergeQuotationList.add(q);
                                }
                            }
                        }
                    }

                    System.debug(LoggingLevel.INFO, '*** mergeQuotationList: ' + mergeQuotationList);
                    if (mergeQuotationList != null && mergeQuotationList.size() > 0) {
                        upsert mergeQuotationList;

                        List<ASI_CRM_Quotation_Line_Item__c> quoteLineItemList = new List<ASI_CRM_Quotation_Line_Item__c>();
                        ASI_CRM_Quotation_Line_Item__c quoteLineItem = null;
                        Set<Id> address1 = null;

                        for (ASI_CRM_quotation__c quote : mergeQuotationList) {
                            address1 = (Set<Id>)prLineAddrs.get(quote.ASI_CTY_CN_Purchase_Request_Line__c);
                            if (address1 != null && address1.size() > 0) {
                                for (Id addsId : address1) {
                                    quoteLineItem = new ASI_CRM_Quotation_Line_Item__c();
                                    quoteLineItem.ASI_CTY_CN_Vendor_Quotation__c = quote.Id;
                                    quoteLineItem.ASI_CTY_CN_Vendor_Address__c = addsId;
                                    quoteLineItem.RecordTypeId = ASI_CTY_CN_Vendor_Util.quotationLineItemRecordId;
                                    quoteLineItemList.add(quoteLineItem);
                                }
                            }
                        }
                        System.debug(LoggingLevel.INFO, '*** quoteLineItemList: ' + quoteLineItemList);
                        if (quoteLineItemList != null && quoteLineItemList.size() > 0) {
                            upsert quoteLineItemList;
                        }
                    }

                    // send notify email
                    for (ASI_CRM_quotation__c quote : quoteList) {
                        quote.ASI_CTY_CN_Vendor_Quotation_Notification__c = true;
                    }

                    upsert quoteList;

                    // update PR Line status
                    for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                        prl.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_ALLOCATED;
                    }

                    upsert infoList;
                    System.debug(LoggingLevel.INFO, '*** infoListNew: ' + infoList);

                    return new ResultDate(1, new SubmitAssignReturn(quoteList, supplierIds));
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, '*** Assign Exception: ' + e);
                Database.rollback(sp);
                return new ResultDate(0, e.getMessage());
            }
        }

        return new ResultDate(0, 'PR Line Item Is Not Null');
    }

    /*
    * Method Name: deleteSupplier
    * Description: delete supplier
    * Return Type: ResultDate
    * Parameter  : String prlId, String quotationListJson
    */
    @RemoteAction
    global static ResultDate deleteSupplier(String prlId, String quotationListJson) {
        List<ASI_MFM_Purchase_Request_Line__c> infoList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Approval_Buyer__c FROM ASI_MFM_Purchase_Request_Line__c WHERE Id =:prlId];

        if (infoList != null && infoList.size() > 0) {
            for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                if (prl.ASI_CTY_CN_Vendor_Approval_Buyer__c != System.UserInfo.getUserId()) {
                    return new ResultDate(0, '当前PR Line已经转发给其它的buyer,请重新刷新界面...');
                }
            }
        }
        Id quotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
        
        List<ASI_CRM_quotation__c> quoteList = (List<ASI_CRM_quotation__c>)JSON.deserialize(quotationListJson, List<ASI_CRM_quotation__c>.class);
        System.debug(LoggingLevel.INFO, '*** quoteList: ' + quoteList);

        Set<Id> quotationIds = new Set<Id>();
        for (ASI_CRM_quotation__c q : quoteList) {
            quotationIds.add(q.Id);
        }
        
        Set<Id> prLineIds = new Set<Id>();
        for (ASI_CRM_quotation__c q : [SELECT Id, Name, (SELECT Id, Name, ASI_CTY_CN_Purchase_Request_Line__c FROM Quotations_quotation__r WHERE RecordTypeId = :quotationRecordId)
            FROM ASI_CRM_quotation__c WHERE Id IN :quotationIds]) {
            if (q.Quotations_quotation__r.Size() > 0) {
                for (ASI_CRM_quotation__c mergeQuote : q.Quotations_quotation__r) {
                    quoteList.add(mergeQuote);
                    prLineIds.add(mergeQuote.ASI_CTY_CN_Purchase_Request_Line__c);
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** quoteList: ' + quoteList);

        Savepoint sp = Database.setSavepoint();
        try {
            if (quoteList.size() > 0) {
                delete quoteList;
            }

            // Judge whether there are quotation lines in the merged PR line. If not, you need to change the status to in distribution
            Set<Id> savePRLineQuoteIds = new Set<Id>();
            List<ASI_CRM_quotation__c> prlQuoteList = [SELECT Id, Name, ASI_CTY_CN_Purchase_Request_Line__c FROM ASI_CRM_quotation__c WHERE ASI_CTY_CN_Purchase_Request_Line__c IN :prLineIds AND RecordTypeId = :quotationRecordId];
            if (prlQuoteList != null && prlQuoteList.size() > 0) {
                for (ASI_CRM_quotation__c q : prlQuoteList) {
                    savePRLineQuoteIds.add(q.ASI_CTY_CN_Purchase_Request_Line__c);
                }
            }
            List<ASI_MFM_Purchase_Request_Line__c> prlObjList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Status__c FROM ASI_MFM_Purchase_Request_Line__c WHERE Id IN :prLineIds];
            if (prlObjList != null && prlObjList.size() > 0) {
                for (ASI_MFM_Purchase_Request_Line__c prl : prlObjList) {
                    if (!savePRLineQuoteIds.contains(prl.Id)) {
                        prl.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_IN_DISTRIBUTION;
                    }
                }
            }
            upsert prlObjList;
            System.debug(LoggingLevel.INFO, '*** prlQuoteList: ' + prlQuoteList);
            System.debug(LoggingLevel.INFO, '*** prlObjList: ' + prlObjList);

            return new ResultDate(1, quoteList);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            Database.rollback(sp);
            return new ResultDate(0, e.getMessage());
        }
    }

    /*
    * Method Name: updateQuotation
    * Description: update Quote DeadLine Date OR notify supplier
    * Return Type: ResultDate
    * Parameter  : String quotationJson, String prlId, String deadLineDate, String flag
    */
    @RemoteAction
    global static ResultDate updateQuotation(String quotationJson, String prlId, String deadLineDate, String flag) {
    	System.debug(LoggingLevel.INFO, '*** prlId: ' + prlId);
        System.debug(LoggingLevel.INFO, '*** deadLineDate: ' + deadLineDate);

        List<ASI_MFM_Purchase_Request_Line__c> infoList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Approval_Buyer__c FROM ASI_MFM_Purchase_Request_Line__c WHERE Id =:prlId];

        if (infoList != null && infoList.size() > 0) {
            for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                if (prl.ASI_CTY_CN_Vendor_Approval_Buyer__c != System.UserInfo.getUserId()) {
                    return new ResultDate(0, '当前PR Line已经转发给其它的buyer,请重新刷新界面...');
                }
            }
        }

    	ASI_CRM_quotation__c quote = (ASI_CRM_quotation__c)JSON.deserialize(quotationJson, ASI_CRM_quotation__c.class);
        System.debug(LoggingLevel.INFO, '*** quote: ' + quote);

        ASI_CRM_quotation__c quoteTemp = [SELECT Id, Name, ASI_CTY_CN_Vendor_Result_Status__c, ASI_CTY_CN_Vendor_Status__c
        FROM ASI_CRM_quotation__c WHERE Id =: quote.Id];

        if (flag == 'UpdateDeadLineDate') {
        	quote.ASI_CTY_CN_Vendor_Deadline_Date__c = Date.valueOf(deadLineDate);
        } else if (flag == 'Notify') {
        	quote.ASI_CTY_CN_Vendor_IsVisible__c = true;
            quote.ASI_CTY_CN_Vendor_Quotation_Notification__c = true;
        } else if (flag == 'ReNotify') {
            quote.ASI_CTY_CN_Vendor_Quotation_Notification__c = true;
        } else if (flag == 'Confirm') {
            if (quoteTemp.ASI_CTY_CN_Vendor_Status__c == ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_REJECTED || quoteTemp.ASI_CTY_CN_Vendor_Result_Status__c == ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_ABANDON_BID) {
                return new ResultDate(0, System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_Rejected_WinQuotation_Tips);
            }
            quote.ASI_CTY_CN_Vendor_IsConfirmed__c = true;
        } else if (flag == 'NoConfirm') {
            quote.ASI_CTY_CN_Vendor_IsConfirmed__c = false;
        }
        System.debug(LoggingLevel.INFO, '*** quote: ' + quote);

        Id quotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
        List<ASI_CRM_quotation__c> mergeQuoteList = [SELECT Id, ASI_CTY_CN_Purchase_Request_Line__c FROM ASI_CRM_quotation__c 
        WHERE ASI_CTY_CN_Vendor_Quotation__c = :quote.Id AND RecordTypeId = :quotationRecordId];

        Set<Id> prlIds = new Set<Id>();
        if (mergeQuoteList != null && mergeQuoteList.size() > 0) {
        	for (ASI_CRM_quotation__c q : mergeQuoteList) {
                prlIds.add(q.ASI_CTY_CN_Purchase_Request_Line__c);
        		if (flag == 'UpdateDeadLineDate') {
        			q.ASI_CTY_CN_Vendor_Deadline_Date__c = Date.valueOf(deadLineDate);
        		} else if (flag == 'Notify') {
        			q.ASI_CTY_CN_Vendor_IsVisible__c = true;
		        } else if (flag == 'ReNotify') {
                } else if (flag == 'Confirm') {
                    q.ASI_CTY_CN_Vendor_IsConfirmed__c = true;
                } else if (flag == 'NoConfirm') {
                    q.ASI_CTY_CN_Vendor_IsConfirmed__c = false;
                }
        	}
        }

        Savepoint sp = Database.setSavepoint();
        try {
        	upsert quote;
        	upsert mergeQuoteList;

            List<ASI_MFM_Purchase_Request_Line__c> prlList = null;
            if (prlIds.size() > 0) {
                prlList = [SELECT Id FROM ASI_MFM_Purchase_Request_Line__c WHERE Id IN :prlIds];
                for (ASI_MFM_Purchase_Request_Line__c prl : prlList) {
                    prl.ASI_CTY_CN_Vendor_All_Price__c = getPRLineAllAmount(prl.Id);
                }
                upsert prlList;
            }
            
        	return new ResultDate(1, quote);
        } catch (Exception e) {
        	System.debug(LoggingLevel.INFO, '*** e: ' + e);
        	Database.rollback(sp);
        	return new ResultDate(0, e.getMessage());
        }
    }

    /*
    * Method Name: winOrNotWinQuotation
    * Description: win Or NotWin Quotation
    * Return Type: ResultDate
    * Parameter  : String quotationJson, String deadLineDate, String flag
    */
    @RemoteAction
    global static ResultDate winOrNotWinQuotation(String quotationJson, String prlId, String flag) {
        List<ASI_MFM_Purchase_Request_Line__c> infoList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Approval_Buyer__c FROM ASI_MFM_Purchase_Request_Line__c WHERE Id =:prlId];

        if (infoList != null && infoList.size() > 0) {
            for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                if (prl.ASI_CTY_CN_Vendor_Approval_Buyer__c != System.UserInfo.getUserId()) {
                    return new ResultDate(0, '当前PR Line已经转发给其它的buyer,请重新刷新界面...');
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** flag: ' + flag);
        ASI_CRM_quotation__c quote = (ASI_CRM_quotation__c)JSON.deserialize(quotationJson, ASI_CRM_quotation__c.class);
        System.debug(LoggingLevel.INFO, '*** quote: ' + quote);
        ASI_CRM_quotation__c quoteTemp = [SELECT Id, Name, ASI_CTY_CN_Vendor_Result_Status__c, ASI_CTY_CN_Vendor_Status__c
        FROM ASI_CRM_quotation__c WHERE Id =: quote.Id];
        
        Id quotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;

        if (flag == 'Win') {
            if (quoteTemp.ASI_CTY_CN_Vendor_Status__c == ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_REJECTED || quoteTemp.ASI_CTY_CN_Vendor_Result_Status__c == ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_ABANDON_BID) {
                return new ResultDate(0, System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_Rejected_WinQuotation_Tips);
            }
            quote.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_WIN_BID;
            quote.ASI_CTY_CN_Vendor_IsConfirmed__c = true;
        } else if (flag == 'NoWin') {
            quote.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_COMPLETED;
            quote.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;
            quote.ASI_CTY_CN_Vendor_IsConfirmed__c = false;
        }

        List<ASI_CRM_quotation__c> mergeQuoteList = [SELECT Id, ASI_CTY_CN_Purchase_Request_Line__c FROM ASI_CRM_quotation__c
        WHERE ASI_CTY_CN_Vendor_Quotation__c = :quote.Id AND RecordTypeId = :quotationRecordId];

        Set<Id> prlIds = new Set<Id>();
        Map<Id, Id> prlMergeQuoteMap = new Map<Id, Id>();
        if (mergeQuoteList != null && mergeQuoteList.size() > 0) {
            for (ASI_CRM_quotation__c q : mergeQuoteList) {
                prlIds.add(q.ASI_CTY_CN_Purchase_Request_Line__c);
                prlMergeQuoteMap.put(q.ASI_CTY_CN_Purchase_Request_Line__c, q.Id);
                if (flag == 'Win') {
                    q.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_WIN_BID;
                    q.ASI_CTY_CN_Vendor_IsConfirmed__c = true;
                } else if (flag == 'NoWin') {
                    q.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_COMPLETED;
                    q.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;
                    q.ASI_CTY_CN_Vendor_IsConfirmed__c = false;
                }
            }
        }

        List<ASI_MFM_Purchase_Request_Line__c> prLineList = null;
        if (prlIds.size() > 0) {
            prLineList = [SELECT Id, ASI_CTY_CN_Vendor_IsSelectQuotation__c, ASI_CTY_CN_Vendor_Select_Quotation__c, 
            ASI_CTY_CN_Vendor_Merge_Quotation__c FROM ASI_MFM_Purchase_Request_Line__c WHERE Id IN :prlIds];
            if (prLineList != null && prLineList.size() > 0) {
                for (ASI_MFM_Purchase_Request_Line__c prl : prLineList) {
                    if (flag == 'Win') {
                        prl.ASI_CTY_CN_Vendor_IsSelectQuotation__c = true;
                        prl.ASI_CTY_CN_Vendor_Select_Quotation__c = prlMergeQuoteMap.get(prl.Id);
                        prl.ASI_CTY_CN_Vendor_Merge_Quotation__c = quote.Id;
                        prl.ASI_CTY_CN_Vendor_Supplier__c = quote.ASI_CTY_CN_Vendor_Supplier__c;
                        prl.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_ALLOCATED;
                    } else if (flag == 'NoWin') {
                        prl.ASI_CTY_CN_Vendor_IsSelectQuotation__c = false;
                        prl.ASI_CTY_CN_Vendor_Select_Quotation__c = null;
                        prl.ASI_CTY_CN_Vendor_Merge_Quotation__c = null;
                        prl.ASI_CTY_CN_Vendor_Supplier__c = null;
                    }
                }
            }
        } 
        System.debug(LoggingLevel.INFO, '*** prLineList: ' + prLineList);

        Savepoint sp = Database.setSavepoint();
        try {
            upsert quote;
            upsert mergeQuoteList;
            
            for (ASI_MFM_Purchase_Request_Line__c p : prLineList) {
                p.ASI_CTY_CN_Vendor_All_Price__c = getPRLineAllAmount(p.Id);
            }
            upsert prLineList;
            return new ResultDate(1, quote);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            Database.rollback(sp);
            return new ResultDate(0, e.getMessage());
        }
    }

    /*
    * Method Name: getPRLineAllAmount
    * Description: get PR Line Item All Amount Public Function
    * Return Type: Decimal
    * Parameter  : String prlIdBase
    */
    private static Decimal getPRLineAllAmount(String prlIdBase) {
        System.debug(LoggingLevel.INFO, '*** prlIdBase: ' + prlIdBase);
        Decimal amount = 0;
        if (prlIdBase == null) {
            return amount;
        }

        // merge quotation ids
        Set<Id> mergeQuotation = new Set<Id>();
        for (ASI_CRM_quotation__c q : [SELECT Id, Name, ASI_CTY_CN_Purchase_Request_Line__c, ASI_CTY_CN_Vendor_IsConfirmed__c, ASI_CTY_CN_Vendor_Result_Status__c,
        ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Sample__c,
        ASI_CTY_CN_Vendor_Model__c FROM ASI_CRM_quotation__c 
        WHERE ASI_CTY_CN_Purchase_Request_Line__c = :prlIdBase AND RecordTypeId = :ASI_CTY_CN_Vendor_Util.quotationRecordId]) {
            System.debug(LoggingLevel.INFO, '*** getPRLineAllAmount-q: ' + q);
            if (q.ASI_CTY_CN_Vendor_IsConfirmed__c) {
                if (q.ASI_CTY_CN_Vendor_Result_Status__c == ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_WIN_BID) {
                    amount = amount + q.ASI_CTY_CN_Vendor_Total_Price__c;
                } else {
                    amount = amount + q.ASI_CTY_CN_Vendor_Model__c + q.ASI_CTY_CN_Vendor_Sample__c;
                }
                System.debug(LoggingLevel.INFO, '*** amount: ' + amount);
            }
        }

        return amount;
    }

    global class ResultDate {
        public Integer status;
        public Object message;
        public ResultDate(Integer status, Object message) {
            this.status = status;
            this.message = message;
        }
    }

    global class CustomSupplier {
        public Account acc;
        public String createdDate;
        public CustomSupplier(Account acc, String createdDate) {
            this.acc = acc;

            if (createdDate == '' || createdDate == null) {
                this.createdDate = System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_NoTradingHistory;
            } else {
                if (createdDate.indexOf(' ') != -1) {
                    this.createdDate = createdDate.split(' ')[0];
                } else {
                    this.createdDate = System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_NoTradingHistory;
                }
            }
        }
    }

    global class SubmitAssignReturn {
        public List<ASI_CRM_quotation__c> quotes;
        public String supplierIds;
        public SubmitAssignReturn(List<ASI_CRM_quotation__c> quotes, String supplierIds) {
            this.quotes = quotes;
            this.supplierIds = supplierIds;
        }
    }
}