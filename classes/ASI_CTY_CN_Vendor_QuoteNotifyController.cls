/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_QuoteNotifyController       
 * Test Class:  ASI_CTY_CN_Vendor_PR_AssignSpCtrTest
 * Description: Quotation Notification Email Template Quote Info Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-10-28       Baymax                  Created Class
 * 2020-10-28       Baymax                  Created Function getQuotation
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_QuoteNotifyController {
    public String parentID {set;get;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_CRM_quotation__c quote {set;get;}
    public List<ASI_CRM_Quotation_Line_Item__c> quoteLineItemList {set;get;}

    public ASI_CTY_CN_Vendor_QuoteNotifyController() {}

    public ASI_CTY_CN_Vendor_QuoteNotifyController(String sirID) {
        parentID = sirID;
    }

    public boolean init() {
        System.debug(LoggingLevel.INFO, '*** parentID: ' + parentID);
        if (parentID != null && parentID != '') {
            this.quote = new ASI_CRM_quotation__c();
            ASI_CRM_quotation__c quotation = [SELECT Id, Name, ASI_CTY_CN_Vendor_Unitl_Price__c, ASI_CTY_CN_Vendor_Sample__c, ASI_CTY_CN_Vendor_DeadLine__c,
            ASI_CTY_CN_Vendor_Model__c, ASI_CTY_CN_Vendor_Total_Freight__c, ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Merge_Total_Freight__c,
            ASI_CTY_CN_Vendor_Remark__c, ASI_CTY_CN_Vendor_Status__c, ASI_CTY_CN_Vendor_Supplier__r.Name,
            ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c, ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c, ASI_CTY_CN_Vendor_Result_Status__c,
            ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c, ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Remark__c,
            ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Reject_Reason__c, CreatedBy.Name, ASI_CTY_CN_Vendor_IsVisible__c,
            (SELECT Id, Name, ASI_CTY_CN_Purchase_Request_Line__c, ASI_CTY_CN_Purchase_Request_Line__r.Name, ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Buyer__r.ASI_MFM_Buyer__r.Name, 
            ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Buyer__r.ASI_MFM_Buyer__r.Phone, ASI_CTY_CN_Purchase_Request_Line__r.ASI_MFM_Purchase_Request__r.Name FROM Quotations_quotation__r) 
            FROM ASI_CRM_quotation__c WHERE Id = :parentID];
            this.quote = quotation;

            System.debug(LoggingLevel.INFO, '*** this.quote: ' + this.quote);
            System.debug(LoggingLevel.INFO, '*** this.quote.Quotations_quotation__r: ' + this.quote.Quotations_quotation__r);

            Set<Id> mergeQuotationIds = new Set<Id>();
            if (quotation != null) {
                List<ASI_CRM_quotation__c> mergeQuotation = quotation.Quotations_quotation__r;
                System.debug(LoggingLevel.INFO, '*** mergeQuotation: ' + mergeQuotation);
                if (mergeQuotation != null && mergeQuotation.size() > 0) {
                    for (ASI_CRM_quotation__c q : mergeQuotation) {
                        mergeQuotationIds.add(q.Id);
                    }
                }
            }

            List<ASI_CRM_Quotation_Line_Item__c> quoteLineItem = null;
            if (mergeQuotationIds.size() > 0) {
                this.quoteLineItemList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Freight__c, ASI_CTY_CN_Vendor_Quotation__r.Id, ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__c, 
                ASI_CTY_CN_Vendor_Quotation__r.ASI_CTY_CN_Purchase_Request_Line__r.ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ReceiptOwner__r.Name,
                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Owner__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Receipt_Phone__c,
                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Note__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Quantity_Required__c,
                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Actual_Quantity__c, ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_Delivery_Address__c,
                ASI_CTY_CN_Vendor_Address__r.ASI_CTY_CN_Vendor_ContactName__c
                FROM ASI_CRM_Quotation_Line_Item__c WHERE ASI_CTY_CN_Vendor_Quotation__r.Id IN :mergeQuotationIds AND RecordTypeId =: ASI_CTY_CN_Vendor_Util.quotationLineItemRecordId ORDER BY ASI_CTY_CN_Vendor_Quotation__c DESC];
                System.debug(LoggingLevel.INFO, '*** this.quoteLineItemList: ' + this.quoteLineItemList);
            }
        }
        return true;
    }   
}