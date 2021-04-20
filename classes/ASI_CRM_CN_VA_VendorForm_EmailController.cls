/*****************************************************************************************************************
 * Name:        ASI_CRM_CN_VA_VendorForm_EmailController       
 * Test Class:  ASI_CRM_CN_VA_VendorForm_EmailCtrlTest
 * Description: CN Vendor Form Email Approval Component Class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-03-18       Sera Liao               Create
 *****************************************************************************************************************/
public with sharing class ASI_CRM_CN_VA_VendorForm_EmailController {
	public String currentFormId {SET;GET;}
  	public ASI_eForm_Vendor_Form__c vendorForm {GET;SET;}

    public Static Final Map<String, Schema.SObjectField> VENDOR_FORM_FIELD_MAP = Schema.SObjectType.ASI_eForm_Vendor_Form__c.fields.getMap();

  	// a dummy variable to invoke init() method
   	public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
  	public ASI_CRM_CN_VA_VendorForm_EmailController() {}

    public boolean init(){
        String queryField = 'id,recordtypeid,recordtype.developername,ownerid,owner.lastname,owner.firstname,asi_eform_status__c,asi_crm_cn_va_related_vendor_form__r.name,';
        for(String field : VENDOR_FORM_FIELD_MAP.keySet()) {
            if(field.toLowerCase().startsWith('asi_crm_cn_va')){
                queryField += field + ',';
            }
        }
        String query = 'SELECT ' + queryField.subString(0, queryField.length() - 1) + ' FROM ASI_eForm_Vendor_Form__c WHERE Id =:currentFormId LIMIT 1';
        List<ASI_eForm_Vendor_Form__c> vendorFormList = (List<ASI_eForm_Vendor_Form__c>) Database.query(query);
        vendorForm = vendorFormList.size() > 0 ? vendorFormList[0] : new ASI_eForm_Vendor_Form__c();
        return true;
    }
}