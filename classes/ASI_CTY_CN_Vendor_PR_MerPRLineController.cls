/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_PR_MerPRLineController       
 * Test Class:  ASI_CTY_CN_Vendor_PR_AssignSpCtrTest
 * Description: Merge PR Line Item List Controller In PR Line Item
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-10-26       BLS-HUJINCHAO           Create Class
 *****************************************************************************************************************/
global without sharing class ASI_CTY_CN_Vendor_PR_MerPRLineController {
	public String purLineList {get;set;}
	
    global ASI_CTY_CN_Vendor_PR_MerPRLineController(ApexPages.StandardController con) {
		Id prlId = con.getId();
        System.debug(LoggingLevel.INFO, '*** prlId: ' + prlId);

		Id quotationRecordId = ASI_CTY_CN_Vendor_Util.quotationRecordId;
        Id mergeQuotationRecordId = ASI_CTY_CN_Vendor_Util.mergeQuotationRecordId;
        Id prLineRecordId = ASI_CTY_CN_Vendor_Util.prLineRecordId;
        Set<Id> prLineIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();

        Set<Id> quotationIds = new Set<Id>();
        for (ASI_CRM_quotation__c q : [SELECT Id, ASI_CTY_CN_Vendor_Quotation__r.Id, ASI_CTY_CN_Purchase_Request_Line__r.Id FROM ASI_CRM_quotation__c 
        	WHERE ASI_CTY_CN_Purchase_Request_Line__c = :prlId AND RecordTypeId = :quotationRecordId]) {
            quotationIds.add(q.ASI_CTY_CN_Vendor_Quotation__r.Id);
        }

        List<ASI_CRM_quotation__c> quoteList = null;
        if (quotationIds.size() > 0) {
            quoteList = [SELECT Id, Name, ASI_CTY_CN_Vendor_Supplier__r.Id, ASI_CTY_CN_Vendor_Supplier__r.Name,
            ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_Sample__c, ASI_CTY_CN_Vendor_Model__c,
            ASI_CTY_CN_Vendor_Merge_Total_Freight__c, ASI_CTY_CN_Vendor_Total_Price__c, ASI_CTY_CN_Vendor_Remark__c,
            ASI_CTY_CN_Vendor_DeadLine__c, toLabel(ASI_CTY_CN_Vendor_Status__c), toLabel(ASI_CTY_CN_Vendor_Result_Status__c),
            ASI_CTY_CN_Vendor_Deadline_Date__c, ASI_CTY_CN_Vendor_Reject_Reason__c, ASI_CTY_CN_Vendor_Unitl_Price__c, ASI_CTY_CN_Vendor_IsVisible__c,
            (SELECT Id, Name FROM Quotations_quotation__r WHERE ASI_CTY_CN_Purchase_Request_Line__c = :prlId AND RecordTypeId = :mergeQuotationRecordId)
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
}