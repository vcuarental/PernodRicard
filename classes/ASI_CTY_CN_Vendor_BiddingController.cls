/*****************************************************************************************************************
 * Name:        ASI_CTY_CN_Vendor_BiddingController       
 * Test Class:  ASI_CTY_CN_Vendor_BiddingControllerTest
 * Description: Vendor Community Bidding List Page Controller
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-10-14       Baymax                  Create Class
 * 2020-10-14       Baymax                  Create Function getPRLineInfo()
 *****************************************************************************************************************/
public without sharing class ASI_CTY_CN_Vendor_BiddingController {
    /*
    * Method Name: getPRLineInfo
    * Description: get all Quotation info of current User.
    * Return Type: List<ASI_CRM_quotation__c>
    * Parameter  : 
    */
    @AuraEnabled
    public static List<ASI_CRM_quotation__c> getQuotationInfo() {
        // get supplier according to current user id
    	Id accountId = ASI_CTY_CN_Vendor_Util.getAccountId();
        
        List<ASI_CRM_quotation__c> results = [SELECT Id, Name, CreatedDate, ASI_CTY_CN_Vendor_Item_Group__r.Id, 
        ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Chinese_Name__c, ASI_CTY_CN_Vendor_Item_Group__r.ASI_CRM_CN_Eng_Name__c,
        ASI_CTY_CN_Vendor_Item_Group__r.ASI_MFM_Item_Group_Code__c, toLabel(ASI_CTY_CN_Vendor_Status__c), toLabel(ASI_CTY_CN_Vendor_Result_Status__c), 
        ASI_CTY_CN_Vendor_Deadline_Date__c, ASI_CTY_CN_Vendor_Total_Quantity__c, ASI_CTY_CN_Vendor_IsConfirmed__c FROM ASI_CRM_quotation__c
            WHERE ASI_CTY_CN_Vendor_Supplier__c = :accountId AND ASI_CTY_CN_Vendor_IsVisible__c = TRUE 
            AND RecordTypeId = :ASI_CTY_CN_Vendor_Util.mergeQuotationRecordId ORDER BY CreatedDate DESC];
        System.debug(LoggingLevel.INFO, '*** results: ' + results);
        
        return results;
    }
}