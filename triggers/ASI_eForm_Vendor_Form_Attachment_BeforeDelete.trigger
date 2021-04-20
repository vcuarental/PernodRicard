/*********************************************************************************
 * Name:ASI_eForm_Vendor_Form_Attachment_BeforeDelete
 * Description: Before Update trigger for Vendor Form Attachment
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-06-04		Vincent Lam             Created
*********************************************************************************/
trigger ASI_eForm_Vendor_Form_Attachment_BeforeDelete on ASI_eForm_Vendor_Form_Attachment__c (before delete) {
	List<ASI_eForm_Vendor_Form_Attachment__c> list_oOld = trigger.old;
    List<ASI_eForm_Vendor_Form_Attachment__c> list_kr = new List<ASI_eForm_Vendor_Form_Attachment__c>();
    
    for(ASI_eForm_Vendor_Form_Attachment__c o : list_oOld) {
        if(o.recordtypeId == Global_RecordTypeCache.getRtId('ASI_eForm_Vendor_Form_Attachment__cASI_eForm_KR_Vendor_Form_Attachment')) {
            list_kr.add(o);
        }
    }
    
    if(list_kr.size() > 0) ASI_eForm_KR_VendorFormAttachmentService.getInstance().checkBeforeDelete(list_kr);
}