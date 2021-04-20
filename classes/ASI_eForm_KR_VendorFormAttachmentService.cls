/*********************************************************************************
 * Name:ASI_eForm_KR_VendorFormAttachmentService
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-06-04		Vincent Lam             Created
*********************************************************************************/
public class ASI_eForm_KR_VendorFormAttachmentService {

    private static ASI_eForm_KR_VendorFormAttachmentService VENDOR_FORM_ATTACHMENT_SERVICE = new ASI_eForm_KR_VendorFormAttachmentService();
    
	private final static String RECORDTYPEID_KR_VENDOR_APPROVAL = Global_RecordTypeCache.getRTId('ASI_eForm_Vendor_Form__cASI_eForm_KR_Vendor_Form_Approval');
	private final static String RECORDTYPEID_KR_VENDOR_READONLY = Global_RecordTypeCache.getRTId('ASI_eForm_Vendor_Form__cASI_eForm_KR_Vendor_Form_Read_Only');
	private final static String RECORDTYPEID_KR_VENDOR_VERIFIED = Global_RecordTypeCache.getRTId('ASI_eForm_Vendor_Form__cASI_eForm_KR_Vendor_Form_Verified');
	
	private final static string KR_BLOCKDELETEMESSAGE = 'You cannot delete attachment because the Vendor Form is submitted / approved.';
	
    //Not Allow to create instance
    private ASI_eForm_KR_VendorFormAttachmentService() { 
    }
    
    public static ASI_eForm_KR_VendorFormAttachmentService getInstance() {
		return VENDOR_FORM_ATTACHMENT_SERVICE;
	}
	
	public void checkBeforeDelete(List<ASI_eForm_Vendor_Form_Attachment__c> list_o){
		Map<string, string> map_vendorFormAttachmentId_vendorFormRTId = new Map<String, string>();
		Map<Id, ASI_eForm_Vendor_Form_Attachment__c> map_o = new Map<Id, ASI_eForm_Vendor_Form_Attachment__c>(list_o);
		
		for(ASI_eForm_Vendor_Form_Attachment__c o : [select id, ASI_eForm_Vendor_Form__r.recordtypeid from ASI_eForm_Vendor_Form_Attachment__c where id in :map_o.keySet()]){
			map_vendorFormAttachmentId_vendorFormRTId.put(o.id, o.ASI_eForm_Vendor_Form__r.recordtypeid);
		}
		
		for(ASI_eForm_Vendor_Form_Attachment__c o : list_o){
			string vendorFormRTID = map_vendorFormAttachmentId_vendorFormRTId.get(o.id);
			if(vendorFormRTID == RECORDTYPEID_KR_VENDOR_APPROVAL ||
				vendorFormRTID == RECORDTYPEID_KR_VENDOR_READONLY ||
				vendorFormRTID == RECORDTYPEID_KR_VENDOR_VERIFIED
			){
				o.addError(KR_BLOCKDELETEMESSAGE);
			}
		}
	}

}