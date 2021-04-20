/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_BidDetailController       
 * Test Class:  ASI_CTY_CN_Vendor_BiddingControllerTest
 * Description: Vendor Community Bidding Detail Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-10-14       Baymax                  Create Class
 * 2020-10-14       Baymax                  Create Function getQuotationInfo
 * 2020-10-18       Baymax                  Create Function submitQuotationInfo
 * 2020-10-21       Baymax                  Create Function submitQuoteStatus
 * 2020-11-04       Baymax                  Create Function getDocumentContent
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_BidDetailController {
    /*
    * Method Name: getQuotationInfo
    * Description: get PR Line Detail Info
    * Return Type: CustomPRLine
    * Parameter  : String quotationId
    */
    @AuraEnabled 
    public static CustomPRLine getQuotationInfo(String quotationId) {
        System.debug(LoggingLevel.INFO, '*** quotationId: ' + quotationId); 
        CustomPRLine custPRLine = new CustomPRLine();
        ASI_CRM_quotation__c quotation = [SELECT Id, Name, ASI_CTY_CN_Vendor_Unitl_Price__c, ASI_CTY_CN_Vendor_Sample__c, ASI_CTY_CN_Vendor_DeadLine__c,
        ASI_CTY_CN_Vendor_Model__c, ASI_CTY_CN_Vendor_Total_Freight__c, ASI_CTY_CN_Vendor_Total_Price__c, 
        ASI_CTY_CN_Vendor_Remark__c, toLabel(ASI_CTY_CN_Vendor_Status__c), toLabel(ASI_CTY_CN_Vendor_Result_Status__c), ASI_CTY_CN_Vendor_Item_Group__c, 
        ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c, ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c, 
        ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c, ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Remark__c,
        ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Reject_Reason__c, ASI_CTY_CN_Vendor_Is_Need_Sample__c,
        ASI_CTY_CN_Vendor_Is_Need_Model__c,ASI_CTY_CN_Vendor_Deadline_Date__c, ASI_CTY_CN_Vendor_IsConfirmed__c,
        (SELECT Id, Name, ASI_CTY_CN_Purchase_Request_Line__r.Id, ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Approval_Buyer__r.Name, 
        ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Approval_Buyer__r.Phone, ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Approval_Buyer__r.MobilePhone,
        ASI_CTY_CN_Vendor_PO__c, ASI_CTY_CN_Vendor_PO__r.Name FROM Quotations_quotation__r) 
        FROM ASI_CRM_quotation__c WHERE Id = :quotationId];

        Set<Id> poIds = new Set<Id>();
        Set<Id> mergeQuotationIds = new Set<Id>();
        if (quotation != null) {
            List<ASI_CRM_quotation__c> mergeQuotation = quotation.Quotations_quotation__r;
            if (mergeQuotation != null && mergeQuotation.size() > 0) {
                for (ASI_CRM_quotation__c q : mergeQuotation) {
                    mergeQuotationIds.add(q.Id);
                    if (q.ASI_CTY_CN_Vendor_PO__c != null) {
                        poIds.add(q.ASI_CTY_CN_Vendor_PO__c);
                    }
                }
            }
        }

        List<ASI_CRM_Quotation_Line_Item__c> quoteLineItem = null;
        if (mergeQuotationIds.size() > 0) {
            quoteLineItem = [SELECT Id, Name, ASI_CTY_CN_Vendor_Freight__c, ASI_CTY_CN_Vendor_Quotation__r.Id, ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__c, 
            ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Quantity__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Owner__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Phone__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Note__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Quantity_Required__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Actual_Quantity__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Delivery_Address__c,
            ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ContactName__c
            FROM ASI_CRM_Quotation_Line_Item__c WHERE ASI_CTY_CN_Vendor_Quotation__r.Id IN :mergeQuotationIds 
            AND RecordTypeId =: ASI_CTY_CN_Vendor_Util.quotationLineItemRecordId ORDER BY ASI_CTY_CN_Vendor_Quotation__c DESC];
        }

        if (poIds.size() > 0) {
            custPRLine.poList = [SELECT Id, Name, ASI_MFM_PO_Final_Date__c, ASI_CTY_CN_Vendor_Model_Price__c, ASI_CTY_CN_Vendor_Total_Freight__c,
                                    ASI_MFM_CN_PO_Amount_RMB__c, ASI_MFM_Total_Paid_Amount__c, ASI_MFM_Total_Quantity__c, ASI_CTY_CN_Vendor_Sample_Price__c,
                                    (SELECT Id, ASI_MFM_Total_Quantity__c, ASI_MFM_Lot_Quantity__c, ASI_MFM_PO_POSM_Line_Number__c FROM Stock_In_Requests__r),
                                    (SELECT Id, Name, ASI_MFM_Unit_Price__c, ASI_MFM_Total_Price_w_VAT__c, ASI_MFM_Quantity__c FROM PO_POSM_Lines__r)
                                    FROM ASI_MFM_PO__c WHERE Id IN :poIds ORDER BY ASI_MFM_PO_Final_Date__c DESC];
        }

        Id itemGroupId = quotation.ASI_CTY_CN_Vendor_Item_Group__c;
        if (itemGroupId != null) {
            System.debug(LoggingLevel.INFO, '*** itemGroupId: ' + itemGroupId);
            CustomImageInfo ciInfo = new CustomImageInfo();
            String reocrdTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
            List<ASI_CRM_Product_Warehouse_Photo__c> tmpAttachment = [SELECT Id, ASI_CRM_Photo_Version__c, CreatedDate FROM ASI_CRM_Product_Warehouse_Photo__c
                                                                            WHERE ASI_CRM_Item_Group__c = : itemGroupId
                                                                            AND RecordTypeId = : reocrdTypeId
                                                                            ORDER BY CreatedDate DESC LIMIT 1];
            Id warehousePhotoId;
            if (tmpAttachment != null && tmpAttachment.size() > 0) {
                warehousePhotoId = tmpAttachment[0].Id;
                System.debug(LoggingLevel.INFO, '*** warehousePhotoId: ' + warehousePhotoId);
                ciInfo.Id = warehousePhotoId;
                set<String> documentIdSet = new set<String>();
                for (ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId
                   FROM ContentDocumentLink
                   WHERE LinkedEntityId =: warehousePhotoId]) {
                    documentIdSet.add(link.ContentDocumentId);
                }
                System.debug(LoggingLevel.INFO, '*** documentIdSet: ' + documentIdSet);

                if (!documentIdSet.isEmpty()) {
                    for (ContentDocument link : [SELECT Id, LastModifiedDate, CreatedBy.Name, ContentSize, FileExtension, OwnerId,
                       (SELECT Id, ContentDocumentId, PathOnClient FROM ContentVersions WHERE IsLatest = true)
                       FROM ContentDocument
                       WHERE Id IN :documentIdSet ORDER BY LastModifiedDate ASC]) {
                        if (link.ContentVersions[0] != null) {
                            ciInfo.VersionId = link.ContentVersions[0].Id;
                            ciInfo.Title = link.ContentVersions[0].PathOnClient;
                        }
                        ciInfo.Size = link.ContentSize;
                        ciInfo.OwnerId = link.OwnerId;
                        ciInfo.Type = link.FileExtension;
                        ciInfo.LastModifiedDate = link.LastModifiedDate;
                        ciInfo.CreatedBy = link.CreatedBy.Name;
                    }
                }

                custPRLine.fileList = ciInfo;
            }
        }
        
        custPRLine.quotation = quotation;
        custPRLine.quoteLineItem = quoteLineItem;
        System.debug(LoggingLevel.INFO, '*** custPRLine: ' + custPRLine);

        return custPRLine;
    }

    /*
    * Method Name: submitQuotationInfo
    * Description: submit Quotation Info
    * Return Type: ResultDate
    * Parameter  : String quotetionJson, String addressJson, String mergeQuotationIds
    */
    @AuraEnabled
    public static ResultDate submitQuotationInfo(String quotetionJson, String addressJson, String mergeQuotationIds) {
        System.debug(LoggingLevel.INFO, '*** quotetionJson: ' + quotetionJson);
        List<ASI_CRM_Quotation_Line_Item__c> address = (List<ASI_CRM_Quotation_Line_Item__c>)JSON.deserialize(addressJson, List<ASI_CRM_Quotation_Line_Item__c>.class);
        System.debug(LoggingLevel.INFO, '*** address: ' + address);
        Set<String> mergeQuoteIds = (Set<String>)JSON.deserialize(mergeQuotationIds, Set<String>.class);
        System.debug(LoggingLevel.INFO, '*** , mergeQuoteIds: ' + mergeQuoteIds);
        ASI_CRM_quotation__c quote = (ASI_CRM_quotation__c)JSON.deserialize(quotetionJson, ASI_CRM_quotation__c.class);
        System.debug(LoggingLevel.INFO, '*** quote: ' + quote);
        
        // Save the last quotation and find out the quotation in the database according to the ID
        ASI_CRM_quotation__c oldQuote = [SELECT Id, ASI_CTY_CN_Vendor_Unitl_Price__c, ASI_CTY_CN_Vendor_Result_Status__c, ASI_CTY_CN_Vendor_IsConfirmed__c FROM ASI_CRM_quotation__c WHERE Id =: quote.Id];
        if (oldQuote.ASI_CTY_CN_Vendor_Result_Status__c == ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_WIN_BID) {
            return new ResultDate(0, System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_WinQuotation_Tips);
        }

        if (oldQuote.ASI_CTY_CN_Vendor_Result_Status__c == ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_FAIL_BID) {
            return new ResultDate(0, System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_SubmitFailBid_Tips);
        }

        if (oldQuote.ASI_CTY_CN_Vendor_IsConfirmed__c) {
            return new ResultDate(0, System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_SubmitConfirmed_Tips);
        }

        quote.ASI_CTY_CN_Vendor_Old_Unitl_Price__c = oldQuote.ASI_CTY_CN_Vendor_Unitl_Price__c;

        quote.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_COMPLETED;
        quote.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;
        quote.ASI_CTY_CN_Vendor_Reject_Reason__c = '';

        List<ASI_CRM_quotation__c> mergeQuotationList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Unitl_Price__c, ASI_CTY_CN_Vendor_Sample__c,
            ASI_CTY_CN_Vendor_Model__c, ASI_CTY_CN_Vendor_Total_Freight__c, ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Remark__c,
            ASI_CTY_CN_Vendor_DeadLine__c, ASI_CTY_CN_Vendor_Status__c, ASI_CTY_CN_Vendor_Result_Status__c, ASI_CTY_CN_Purchase_Request_Line__c
            FROM ASI_CRM_quotation__c WHERE Id IN :mergeQuoteIds];

        Decimal mergeTotalFreight = 0;
        Integer totalQuantity = Integer.valueOf(quote.ASI_CTY_CN_Vendor_Total_Quantity__c);
        Map<Id, Decimal> prlEachPriceMap = new Map<Id, Decimal>();

        if (address != null && address.size() > 0) {
            for (ASI_CRM_Quotation_Line_Item__c quoteLineItem : address) {
                System.debug(LoggingLevel.INFO, '*** quoteLineItem.ASI_CTY_CN_Vendor_Quotation__c: ' + quoteLineItem.ASI_CTY_CN_Vendor_Quotation__c);
                System.debug(LoggingLevel.INFO, '*** quoteLineItem.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__c: ' + quoteLineItem.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__c);
                if (!prlEachPriceMap.containsKey(quoteLineItem.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__c)) {
                    prlEachPriceMap.put(quoteLineItem.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__c, 
                        (quoteLineItem.ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Quantity__c / quote.ASI_CTY_CN_Vendor_Total_Quantity__c));
                }
                if (quoteLineItem.ASI_CTY_CN_Vendor_Freight__c != null) {
                    mergeTotalFreight = mergeTotalFreight + quoteLineItem.ASI_CTY_CN_Vendor_Freight__c;
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** prlEachPriceMap: ' + prlEachPriceMap);

        Map<Id, Decimal> modelPriceMap = new Map<Id, Decimal>();
        Decimal modelRest = 0;

        Map<Id, Decimal> samplePriceMap = new Map<Id, Decimal>();
        Decimal sampleRest = 0;
        Decimal tempD = null;

        for (String key : prlEachPriceMap.keySet()) {
            if (!modelPriceMap.containsKey(Id.valueOf(key))) {
                tempD = ((prlEachPriceMap.get(Id.valueOf(key)) * quote.ASI_CTY_CN_Vendor_Model__c * 1000) / 1000).setScale(2);
                modelRest = modelRest + tempD;
                modelPriceMap.put(Id.valueOf(key), tempD);
            }

            if (!samplePriceMap.containsKey(Id.valueOf(key))) {
                tempD = ((prlEachPriceMap.get(Id.valueOf(key)) * quote.ASI_CTY_CN_Vendor_Sample__c * 1000) / 1000).setScale(2);
                sampleRest = sampleRest + tempD;
                samplePriceMap.put(Id.valueOf(key), tempD);
            }
        }

        modelRest = quote.ASI_CTY_CN_Vendor_Model__c - modelRest;
        sampleRest = quote.ASI_CTY_CN_Vendor_Sample__c - sampleRest;

        System.debug(LoggingLevel.INFO, '*** modelPriceMap: ' + modelPriceMap);
        System.debug(LoggingLevel.INFO, '*** samplePriceMap: ' + samplePriceMap);
        System.debug(LoggingLevel.INFO, '*** modelRest: ' + modelRest);
        System.debug(LoggingLevel.INFO, '*** sampleRest: ' + sampleRest);

        if (mergeQuotationList != null && mergeQuotationList.size() > 0) {
            ASI_CRM_quotation__c mergeQuote = null;
            for (Integer i = 0; i < mergeQuotationList.size(); i++) {
                mergeQuote = mergeQuotationList[i];

                if (i == 0) {
                    mergeQuote.ASI_CTY_CN_Vendor_Model__c = modelPriceMap.get(mergeQuote.ASI_CTY_CN_Purchase_Request_Line__c) + modelRest;
                    mergeQuote.ASI_CTY_CN_Vendor_Sample__c = samplePriceMap.get(mergeQuote.ASI_CTY_CN_Purchase_Request_Line__c) + sampleRest;
                } else {
                    mergeQuote.ASI_CTY_CN_Vendor_Model__c = modelPriceMap.get(mergeQuote.ASI_CTY_CN_Purchase_Request_Line__c);
                    mergeQuote.ASI_CTY_CN_Vendor_Sample__c = samplePriceMap.get(mergeQuote.ASI_CTY_CN_Purchase_Request_Line__c);
                }
                mergeQuote.ASI_CTY_CN_Vendor_Unitl_Price__c = quote.ASI_CTY_CN_Vendor_Unitl_Price__c;
                mergeQuote.ASI_CTY_CN_Vendor_Status__c = quote.ASI_CTY_CN_Vendor_Status__c;
                mergeQuote.ASI_CTY_CN_Vendor_Result_Status__c = quote.ASI_CTY_CN_Vendor_Result_Status__c;
                mergeQuote.ASI_CTY_CN_Vendor_Remark__c = quote.ASI_CTY_CN_Vendor_Remark__c;
                mergeQuote.ASI_CTY_CN_Vendor_DeadLine__c = quote.ASI_CTY_CN_Vendor_DeadLine__c;
                mergeQuote.ASI_CTY_CN_Vendor_Reject_Reason__c = quote.ASI_CTY_CN_Vendor_Reject_Reason__c;
                mergeQuote.ASI_CTY_CN_Vendor_Old_Unitl_Price__c = oldQuote.ASI_CTY_CN_Vendor_Unitl_Price__c;
            }
        }
        
        quote.ASI_CTY_CN_Vendor_Merge_Total_Freight__c = mergeTotalFreight;
        System.debug(LoggingLevel.INFO, '*** quote: ' + quote);

        Savepoint sp = Database.setSavepoint();
        try {
            upsert quote;
            upsert mergeQuotationList;
            upsert address;

            // send submit quotation email
            quote.ASI_CTY_CN_Vendor_Quotation_SubmitNotify__c = true;
            upsert quote;
            return new ResultDate(1, new CustomSubmitReturnData(quote, address));
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** Quotation Exception: ' + e);
            Database.rollback(sp);
            return new ResultDate(0, e.getMessage());
        }
    }

    /*
    * Method Name: submitQuoteStatus
    * Description: reject or giveUp quotation public function
    * Return Type: ResultDate
    * Parameter  : String quotationJson, String status
    */
    @AuraEnabled 
    public static ResultDate submitQuoteStatus(String quotationJson, String status) {
        Id mergeQuotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
        ASI_CRM_quotation__c quote = (ASI_CRM_quotation__c)JSON.deserialize(quotationJson, ASI_CRM_quotation__c.class);
        System.debug(LoggingLevel.INFO, '*** quote: ' + quote);
        ASI_CRM_quotation__c quoteObj = new ASI_CRM_quotation__c(Id = quote.Id);

        ASI_CRM_quotation__c quoteTemp = [SELECT Id, Name, ASI_CTY_CN_Vendor_Result_Status__c, ASI_CTY_CN_Vendor_Reject_Reason__c, ASI_CTY_CN_Vendor_IsConfirmed__c 
        FROM ASI_CRM_quotation__c WHERE Id =: quote.Id];
        System.debug(LoggingLevel.INFO, '*** status: ' + status);
        if ((status == 'Rejected' || status == 'GiveUp') && quoteTemp.ASI_CTY_CN_Vendor_Result_Status__c != ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_WIN_BID && !quoteTemp.ASI_CTY_CN_Vendor_IsConfirmed__c) {
            if (status == 'Rejected') {
                quote.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_REJECTED;
                quote.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;

                // only update price
                quoteObj.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_REJECTED;
                quoteObj.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_PENDING_CONFIRM;
                quoteObj.ASI_CTY_CN_Vendor_Reject_Reason__c = quote.ASI_CTY_CN_Vendor_Reject_Reason__c;
            } else if (status == 'GiveUp') {
                quote.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_ABANDON_BID;
                quote.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_PENDING;
                quote.ASI_CTY_CN_Vendor_Reject_Reason__c = '';

                quoteObj.ASI_CTY_CN_Vendor_Result_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_RESULT_STATUS_ABANDON_BID;
                quoteObj.ASI_CTY_CN_Vendor_Status__c = ASI_CTY_CN_Vendor_Util.QUOTATION_STATUS_PENDING;
                quoteObj.ASI_CTY_CN_Vendor_Reject_Reason__c = '';
            }

            List<ASI_CRM_quotation__c> mergeQuotationList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Status__c, ASI_CTY_CN_Vendor_Reject_Reason__c FROM ASI_CRM_quotation__c 
            WHERE ASI_CTY_CN_Vendor_Quotation__r.Id = :quote.Id AND RecordTypeId = :mergeQuotationRecordId];
            if (mergeQuotationList != null && mergeQuotationList.size() > 0) {
                for (ASI_CRM_quotation__c mergeQuote : mergeQuotationList) {
                    mergeQuote.ASI_CTY_CN_Vendor_Status__c = quoteObj.ASI_CTY_CN_Vendor_Status__c;
                    mergeQuote.ASI_CTY_CN_Vendor_Reject_Reason__c = quoteObj.ASI_CTY_CN_Vendor_Reject_Reason__c;
                    mergeQuote.ASI_CTY_CN_Vendor_Result_Status__c = quoteObj.ASI_CTY_CN_Vendor_Result_Status__c;
                }
            }
            System.debug(LoggingLevel.INFO, '*** mergeQuotationList: ' + mergeQuotationList);

            Savepoint sp = Database.setSavepoint();
            try {
                upsert quoteObj;
                upsert mergeQuotationList;

                // send rejected email
                if (status == 'Rejected') {
                    quoteObj.ASI_CTY_CN_Vendor_Quotation_SubmitNotify__c = true;
                    upsert quoteObj;
                }
                
                return new ResultDate(1, quote);
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO, '*** e: ' + e);
                Database.rollback(sp);
                return new ResultDate(0, e.getMessage());
            }
        } else {
            return new ResultDate(0, System.Label.ASI_CTY_CN_Vendor_Bidding_Detail_RejectedAbandon_Apex_Tips);
        }
    }

    /*
    * Method Name: getDocumentContent
    * Description: Get Item Group image content
    * Return Type: String
    * Parameter  : String warehousePhotoId
    */
    @AuraEnabled 
    public static String getDocumentContent(String warehousePhotoId){
        System.debug(LoggingLevel.INFO, '*** warehousePhotoId: ' + warehousePhotoId);
        Id contentDocumentId;
        String result;
        set<String> documentIdSet = new set<String>();
        ContentDocumentLink link = [SELECT Id, LinkedEntityId, ContentDocumentId
           FROM ContentDocumentLink
           WHERE LinkedEntityId =: warehousePhotoId LIMIT 1];
        if (link != null) {
            contentDocumentId = link.ContentDocumentId;
            ContentVersion cv = [SELECT Id, ContentDocumentId, FileExtension, VersionData
                FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId =:contentDocumentId];
            String content = EncodingUtil.base64Encode(cv.VersionData);
            result = 'data:image/' + cv.FileExtension + ';base64,' + content;
        }
        return result;
    }

    public class CustomImageInfo {
        @AuraEnabled 
        public String Id;
        @AuraEnabled 
        public String VersionId;
        @AuraEnabled 
        public String Title;
        @AuraEnabled 
        public Integer Size;
        @AuraEnabled 
        public String OwnerId;
        @AuraEnabled 
        public String Type;
        @AuraEnabled 
        public DateTime LastModifiedDate;
        @AuraEnabled 
        public String CreatedBy;
        @AuraEnabled 
        public String Content;
    }

    public class CustomSubmitReturnData {
        @AuraEnabled 
        public ASI_CRM_quotation__c quotation;
        @AuraEnabled 
        public List<ASI_CRM_Quotation_Line_Item__c> address;

        public CustomSubmitReturnData(ASI_CRM_quotation__c quotation, List<ASI_CRM_Quotation_Line_Item__c> address) {
            this.quotation = quotation;
            this.address = address;
        }
    }

    public class CustomPRLine {
        @AuraEnabled 
        public ASI_CRM_quotation__c quotation;
        @AuraEnabled 
        public List<ASI_CRM_Quotation_Line_Item__c> quoteLineItem;
        @AuraEnabled 
        public CustomImageInfo fileList;
        @AuraEnabled 
        public List<ASI_MFM_PO__c> poList;
    }

    public class ResultDate {
        @AuraEnabled 
        public Integer status;
        @AuraEnabled 
        public Object message;

        public ResultDate(Integer status, Object message) {
            this.status = status;
            this.message = message;
        }
    }
}