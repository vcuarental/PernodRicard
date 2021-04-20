/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_PR_PurLineController       
 * Test Class:  ASI_CTY_CN_Vendor_PR_PurLineCtlTest
 * Description: Purchase Request Line List Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-10-09       Baymax                  Create Class
 * 2020-10-12       Baymax                  Create Function reAssignBuyer
 * 2020-10-14       Baymax                  Create Function assignSupplier
 *****************************************************************************************************************/
global without sharing class ASI_CTY_CN_Vendor_PR_PurLineController {
	public String purLineList {get;set;}
    public String statusList {get;set;}
    public String itemGroupNameList {get;set;}
    public String buyerList {get;set;}
    public String supplierList {get;set;}
    public Boolean isReadPriv {get;set;}

    global ASI_CTY_CN_Vendor_PR_PurLineController(ApexPages.StandardController con) {
        Id prLineRecordId = ASI_CTY_CN_Vendor_Util.prLineRecordId;
        System.debug(LoggingLevel.INFO, '*** prLineRecordId ' + prLineRecordId);
        Id userId = System.UserInfo.getUserId();

        List<GroupMember> gm = [SELECT Id FROM GroupMember WHERE Group.Name = 'ASI_CTY_CN_Vendor_Purchase_Manager' AND UserOrGroupId = :userId];
        if (gm != null && gm.size() > 0) {
            isReadPriv = false;
        } else {
            isReadPriv = true;
        }

        List<ASI_MFM_Buyer_Master__c> buyer = [SELECT Id FROM ASI_MFM_Buyer_Master__c WHERE ASI_MFM_Buyer__c = :userId];
        List<ASI_MFM_Purchase_Request_Line__c> prLineList = null;
        List<AggregateResult> pelList = null;
        Set<Id> buyerIds = new Set<Id>();
        if (buyer != null) {
            for (ASI_MFM_Buyer_Master__c b : buyer) {
                buyerIds.add(b.Id);
            }

            if (isReadPriv) {
                prLineList = [SELECT Id, Name, ASI_MFM_Purchase_Request__r.Name, ASI_MFM_Purchase_Request__r.Id, CreatedDate,
                ASI_MFM_Purchase_Request__r.CreatedBy.Name, ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Eng_Name__c, ASI_CTY_CN_Vendor_Item_Group_Code__r.Id, 
                ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Item_Group_Code__c, ASI_CTY_CN_Vendor_Sample_Required__c, ASI_CTY_CN_Vendor_IsSelectQuotation__c, ASI_CTY_CN_Vendor_IsMerged__c,
                ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Status__c, toLabel(ASI_CTY_CN_Vendor_Status__c) StatusLabel, ASI_CTY_CN_Vendor_Bidding_Deadline__c, ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_Supplier__r.Name,
                ASI_CTY_CN_Vendor_Select_Quotation__r.Name, ASI_CTY_CN_Vendor_Select_Quotation__r.Id, ASI_CTY_CN_Vendor_Unit_Price__c, ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_Supplier__c,
                ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Model_Required__c, ASI_CTY_CN_Vendor_Approval_Buyer__r.Name, ASI_CTY_CN_Vendor_Approval_Buyer__c, ASI_CTY_CN_Vendor_Is_MKT_Submit__c
                    FROM ASI_MFM_Purchase_Request_Line__c WHERE RecordTypeId = :prLineRecordId AND ASI_CTY_CN_Vendor_Buyer__c In :buyerIds
                    AND (ASI_CTY_CN_Vendor_Status__c != :ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_DRAFT) ORDER BY CreatedDate DESC];
            
                pelList = [SELECT ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c FROM ASI_MFM_Purchase_Request_Line__c 
                WHERE RecordTypeId = :prLineRecordId AND ASI_CTY_CN_Vendor_Buyer__c In :buyerIds
                GROUP BY ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c];
            } else {
                prLineList = [SELECT Id, Name, ASI_MFM_Purchase_Request__r.Name, ASI_MFM_Purchase_Request__r.Id, CreatedDate,
                ASI_MFM_Purchase_Request__r.CreatedBy.Name, ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c,
                ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Eng_Name__c, ASI_CTY_CN_Vendor_Item_Group_Code__r.Id, 
                ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Item_Group_Code__c, ASI_CTY_CN_Vendor_Sample_Required__c, ASI_CTY_CN_Vendor_IsSelectQuotation__c, ASI_CTY_CN_Vendor_IsMerged__c,
                ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Status__c, toLabel(ASI_CTY_CN_Vendor_Status__c) StatusLabel, ASI_CTY_CN_Vendor_Bidding_Deadline__c, ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_Supplier__r.Name, 
                ASI_CTY_CN_Vendor_Select_Quotation__r.Name, ASI_CTY_CN_Vendor_Select_Quotation__r.Id, ASI_CTY_CN_Vendor_Unit_Price__c, ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_Supplier__c, 
                ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Model_Required__c, ASI_CTY_CN_Vendor_Approval_Buyer__r.Name, ASI_CTY_CN_Vendor_Approval_Buyer__c, ASI_CTY_CN_Vendor_Is_MKT_Submit__c
                    FROM ASI_MFM_Purchase_Request_Line__c WHERE RecordTypeId = :prLineRecordId 
                    AND (ASI_CTY_CN_Vendor_Status__c != :ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_DRAFT) ORDER BY CreatedDate DESC];
            }
        }

        Set<Id> prIds = new Set<Id>();
        if (prLineList != null && prLineList.size() > 0) {
            for (ASI_MFM_Purchase_Request_Line__c prl : prLineList) {
                prIds.add(prl.Id);
            }
        }

        pelList = [SELECT ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c FROM ASI_MFM_Purchase_Request_Line__c 
                WHERE RecordTypeId = :prLineRecordId AND Id IN :prIds GROUP BY ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c];
        purLineList = JSON.serialize(prLineList);
        statusList = JSON.serialize(ASI_MFM_Purchase_Request_Line__c.ASI_CTY_CN_Vendor_Status__c.getDescribe().getPicklistValues());

        itemGroupNameList = JSON.serialize(pelList);
        System.debug(LoggingLevel.INFO, '*** itemGroupNameList: ' + itemGroupNameList);
        System.debug(LoggingLevel.INFO, '*** prLineList: ' + prLineList);
        System.debug(LoggingLevel.INFO, '*** statusList: ' + statusList);
    }

    global ASI_CTY_CN_Vendor_PR_PurLineController(ApexPages.StandardSetController con) {}

    /*
    * Method Name: initBuyerList
    * Description: init buyer list data
    * Return Type: ResultDate
    * Parameter  : 
    */
    @RemoteAction
    global static ResultDate initBuyerList() {
        Id userId = System.UserInfo.getUserId();

        ASI_MFM_Buyer_Master__c buyer = [SELECT Id FROM ASI_MFM_Buyer_Master__c WHERE ASI_MFM_Buyer__c = :userId LIMIT 1];
        Id buyerRecordId = ASI_CTY_CN_Vendor_Util.buyerRecordId;
        return new ResultDate(1, [SELECT Id, Name, ASI_MFM_Buyer__r.Id, ASI_MFM_Buyer__r.Name FROM ASI_MFM_Buyer_Master__c WHERE RecordTypeId = :buyerRecordId AND Id != :buyer.Id]);
    }

    /*
    * Method Name: initSupplierList
    * Description: init supplier list data
    * Return Type: ResultDate
    * Parameter  : String itemGroupId, String selectPRListIds
    */
    @RemoteAction
    global static ResultDate initSupplierList(String itemGroupId, String selectPRListIds) {
        System.debug(LoggingLevel.INFO, '*** itemGroupId: ' + itemGroupId);
        System.debug(LoggingLevel.INFO, '*** selectPRListIds: ' + selectPRListIds);
        Set<String> prIds = (Set<String>)JSON.deserialize(selectPRListIds, Set<String>.class);
        Set<Id> currentSupplierIds = new Set<Id>();
        for (ASI_CRM_Quotation__c q : [SELECT Id, Name, ASI_CTY_CN_Purchase_Request_Line__c, ASI_CTY_CN_Vendor_Supplier__c FROM ASI_CRM_Quotation__c 
        WHERE ASI_CTY_CN_Purchase_Request_Line__c IN :prIds AND RecordTypeId =: ASI_CTY_CN_Vendor_Util.quotationRecordId]) {
            currentSupplierIds.add(q.ASI_CTY_CN_Vendor_Supplier__c);
        }

        Id supplierRecordId = ASI_CTY_CN_Vendor_Util.supplierRecordId;
        List<CustomSupplier> supplierList = new List<CustomSupplier>();

        List<User> userList = [SELECT Id, Name, Contact.Id, Contact.Name, Contact.Account.Id, Contact.Account.Name FROM User 
        WHERE User.Profile.Name = 'ASI_CTY_PRCVendor_CN_User' AND IsActive = true 
        AND Contact.Account.RecordTypeId =:supplierRecordId AND Contact.Account.Id NOT IN :currentSupplierIds];
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
    * Method Name: reAssignBuyer
    * Description: assign PR line item to other buyers
    * Return Type: ResultDate
    * Parameter  : String purLineListJson, String buyerId
    */
    @RemoteAction
    global static ResultDate reAssignBuyer(String purLineListJson, String buyerId) {
        List<ASI_MFM_Purchase_Request_Line__c> infoList = (List<ASI_MFM_Purchase_Request_Line__c>)JSON.deserialize(purLineListJson, List<ASI_MFM_Purchase_Request_Line__c>.class);
        System.debug(LoggingLevel.INFO, '*** infoList: ' + infoList);
        System.debug(LoggingLevel.INFO, '*** buyerId: ' + buyerId);

        ASI_MFM_Buyer_Master__c buyer = [SELECT Id, ASI_MFM_Buyer__c FROM ASI_MFM_Buyer_Master__c WHERE Id =:buyerId];

        Set<Id> prlIds = new Set<Id>();
        if (infoList != null && infoList.size() > 0) {
            for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                prl.ASI_CTY_CN_Vendor_Buyer__c = buyer.Id;
                prl.ASI_CTY_CN_Vendor_Approval_Buyer__c = buyer.ASI_MFM_Buyer__c;
                prlIds.add(prl.Id);
            }

            List<ProcessInstance> proList = [SELECT Id, Status FROM ProcessInstance where TargetObject.Id In :prlIds AND Status = 'Pending'];

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
                        piwi.ActorId = buyer.ASI_MFM_Buyer__c;
                    }
                }
            }
            
            Savepoint sp = Database.setSavepoint();
            try {
                upsert infoList;
                if (piList != null && piList.size() > 0) {
                    upsert piList;
                }
                return new ResultDate(1, infoList);
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, '*** e: ' + e);
                Database.rollback(sp);
                return new ResultDate(0, e.getMessage());
            }
        }

        return new ResultDate(0, null);
    }

    /*
    * Method Name: assignSupplier
    * Description: assign PR line item to supplier
    * Return Type: ResultDate
    * Parameter  : String purLineListJson, String supplierIds, String supplierDeadLineDateJson, String sampleRequiredJson, String modelRequiredJson
    */
    @RemoteAction
    global static ResultDate assignSupplier(String purLineListJson, String supplierIds, String supplierDeadLineDateJson, String sampleRequiredJson, String modelRequiredJson) {
        List<ASI_MFM_Purchase_Request_Line__c> infoList = (List<ASI_MFM_Purchase_Request_Line__c>)JSON.deserialize(purLineListJson, List<ASI_MFM_Purchase_Request_Line__c>.class);
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

        // The price is divided equally according to the quantity
        Map<String, String> supplierDeadLineMap = (Map<String, String>)JSON.deserialize(supplierDeadLineDateJson, Map<String, String>.class);
        System.debug(LoggingLevel.INFO, '*** supplierDeadLineMap: ' + supplierDeadLineMap);

        Map<String, Boolean> sampleRequiredMap = (Map<String, Boolean>)JSON.deserialize(sampleRequiredJson, Map<String, Boolean>.class);
        System.debug(LoggingLevel.INFO, '*** sampleRequiredMap: ' + sampleRequiredMap);

        Map<String, Boolean> modelRequiredMap = (Map<String, Boolean>)JSON.deserialize(modelRequiredJson, Map<String, Boolean>.class);
        System.debug(LoggingLevel.INFO, '*** modelRequiredMap: ' + modelRequiredMap);

        Map<Id, Set<Id>> prLineAddrs = new Map<Id, Set<Id>>();
        Set<Id> prLineIds = new Set<Id>();
        List<ASI_CRM_Quotation__c> quoteList = null;

        if (infoList != null && infoList.size() > 0) {
            Id quotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
            Id mergeQuotationRecordId = ASI_CTY_CN_Vendor_Util.mergeQuotationRecordId;
            for (ASI_MFM_Purchase_Request_Line__c prLine : infoList) {
                prLineIds.add(prLine.Id);
            }

            Set<Id> addressIds = null;
            for (ASI_CRM_Address__c addr : [SELECT Id, ASI_CTY_CN_Vendor_PurLine__r.Id 
                FROM ASI_CRM_Address__c WHERE ASI_CTY_CN_Vendor_PurLine__r.Id IN :prLineIds]) {
                if (!prLineAddrs.containsKey(addr.ASI_CTY_CN_Vendor_PurLine__r.Id)) {
                    addressIds = new Set<Id>();
                } else {
                    addressIds = (Set<Id>)prLineAddrs.get(addr.ASI_CTY_CN_Vendor_PurLine__r.Id);
                }
                addressIds.add(addr.Id);
                prLineAddrs.put(addr.ASI_CTY_CN_Vendor_PurLine__r.Id, addressIds);
            }
            System.debug(LoggingLevel.INFO, '*** prLineAddrs: ' + prLineAddrs);

            // create merge quotation
            ASI_CRM_Quotation__c q = null;
            Integer totalQuantity = 0;
            for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                totalQuantity = totalQuantity + Integer.valueOf(prl.ASI_CTY_CN_Vendor_Total_Quantity__c);
            }

            quoteList = new List<ASI_CRM_Quotation__c>();
            if (supplierIdSet != null && supplierIdSet.size() > 0) {
                for (String supplierId : supplierIdSet) {
                    q = new ASI_CRM_Quotation__c();
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

                    // Visible by default
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
                    for (ASI_CRM_Quotation__c quote : quoteList) {
                        quoatationTotal.put(quote.ASI_CTY_CN_Vendor_Supplier__c, quote.Id);
                    }
                    System.debug(LoggingLevel.INFO, '*** quoatationTotal: ' + quoatationTotal);
                    
                    List<ASI_CRM_Quotation__c> mergeQuotationList = null;
                    if (infoList.size() > 0) {
                        mergeQuotationList = new List<ASI_CRM_Quotation__c>();
                        for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                            if (supplierIdSet != null && supplierIdSet.size() > 0) {
                                for (String supplierId : supplierIdSet) {
                                    q = new ASI_CRM_Quotation__c();
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

                        for (ASI_CRM_Quotation__c quote : mergeQuotationList) {
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

                    // auto send email
                    for (ASI_CRM_Quotation__c quote : quoteList) {
                        quote.ASI_CTY_CN_Vendor_Quotation_Notification__c = true;
                    }

                    upsert quoteList;

                    // update PR Line status
                    for (ASI_MFM_Purchase_Request_Line__c prl : infoList) {
                        prl.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.PRLINE_STATUS_ALLOCATED;
                        if (infoList.size() > 1) {
                            prl.ASI_CTY_CN_Vendor_IsMerged__c = true;
                        }
                    }

                    upsert infoList;
                    System.debug(LoggingLevel.INFO, '*** infoListNew: ' + infoList);

                    return new ResultDate(1, [SELECT Id, Name, ASI_MFM_Purchase_Request__r.Name, ASI_MFM_Purchase_Request__r.Id, CreatedDate,
                                                     ASI_MFM_Purchase_Request__r.CreatedBy.Name, ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Chinese_Name__c,
                                                     ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_CRM_CN_Eng_Name__c, ASI_CTY_CN_Vendor_Item_Group_Code__r.Id, 
                                                     ASI_CTY_CN_Vendor_Item_Group_Code__r.ASI_MFM_Item_Group_Code__c, ASI_CTY_CN_Vendor_Sample_Required__c, ASI_CTY_CN_Vendor_IsSelectQuotation__c, ASI_CTY_CN_Vendor_IsMerged__c,
                                                     ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Status__c, toLabel(ASI_CTY_CN_Vendor_Status__c) StatusLabel, ASI_CTY_CN_Vendor_Bidding_Deadline__c, ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_Supplier__r.Name,
                                                     ASI_CTY_CN_Vendor_Select_Quotation__r.Name, ASI_CTY_CN_Vendor_Select_Quotation__r.Id, ASI_CTY_CN_Vendor_Unit_Price__c, ASI_CTY_CN_Vendor_Select_Quotation__r.ASI_CTY_CN_Vendor_Supplier__c,
                                                     ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Model_Required__c, ASI_CTY_CN_Vendor_Approval_Buyer__r.Name, ASI_CTY_CN_Vendor_Approval_Buyer__c, ASI_CTY_CN_Vendor_Is_MKT_Submit__c
                                                     FROM ASI_MFM_Purchase_Request_Line__c WHERE Id IN :prLineIds]);
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, '*** Exception: ' + e);
                Database.rollback(sp);
                return new ResultDate(0, e.getMessage());
            }
        }

        return new ResultDate(0, 'PR Line Item is not null...');
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
}