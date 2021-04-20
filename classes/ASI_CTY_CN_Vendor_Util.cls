/* Filename:    ASI_CTY_CN_WS_Utils.cls
 * Author:      wangzhiqiang 
 * Date:        2020-09-01
 * Description: Wholesaler Platform Project Util class
 */
public without sharing class ASI_CTY_CN_Vendor_Util {
    // record type 
	public static final Id quotationRecordId = Global_RecordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Quotation');
	public static final Id mergeQuotationRecordId = Global_RecordTypeCache.getRtId('ASI_CRM_Quotation__cASI_CTY_CN_Vendor_Merge_Quotation');
	public static final Id quotationLineItemRecordId = Global_RecordTypeCache.getRtId('ASI_CRM_Quotation_Line_Item__cASI_CTY_CN_Vendor_Quotation_Line_Item');
    public static final Id prLineRecordId = Global_RecordTypeCache.getRtId('ASI_MFM_Purchase_Request_Line__cASI_CN_Vendor_Purchase_Request_Line');
	public static final Id buyerRecordId = Global_RecordTypeCache.getRtId('ASI_MFM_Buyer_Master__cASI_MFM_CN_Buyer_Master');
	public static final Id supplierRecordId = Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Supplier');
    public static final Id poLineItemRecordId = Global_RecordTypeCache.getRtId('ASI_MFM_PO_Line_Item__cASI_MFM_CN_PO_Line_Item');
    public static final Id itemGroupPhotoRecordId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_MFM_CN_POSM_Final_Artwork_Photo');
    public static final Id itemGroupRecordId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group');

    // PR Line Item Status
    public static final String PRLINE_STATUS_IN_DISTRIBUTION = 'In Distribution';
    public static final String PRLINE_STATUS_ALLOCATED = 'Allocated';
    public static final String PRLINE_STATUS_REJECT = 'Reject';
    public static final String PRLINE_STATUS_DRAFT = 'Draft';
    public static final String PRLINE_STATUS_APPROVED = 'Approved';
    public static final String PRLINE_STATUS_RECALL = 'Recall';
    public static final String PRLINE_STATUS_SUBMITTED = 'Submitted';

    // quotation status
    public static final String QUOTATION_STATUS_PENDING = 'Pending';
    public static final String QUOTATION_STATUS_COMPLETED = 'Completed';
    public static final String QUOTATION_STATUS_REJECTED = 'Rejected';

    // quotation result status
    public static final String QUOTATION_RESULT_STATUS_WIN_BID = 'Win-Bid';
    public static final String QUOTATION_RESULT_STATUS_FAIL_BID = 'Fail-Bid';
    public static final String QUOTATION_RESULT_STATUS_ABANDON_BID = 'Abandon-Bid';
    public static final String QUOTATION_RESULT_STATUS_PENDING_CONFIRM = 'Pending Confirm';

	@AuraEnabled
    public static Id getAccountId() {
        final String userId = UserInfo.getUserId(); 
        final List <User> usrs = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];
        if (!usrs.isEmpty()) {
            return (usrs[0].Contact != null) ? usrs[0].Contact.AccountId : null;
        }
        return null;
    }
}