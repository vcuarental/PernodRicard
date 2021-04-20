/*****************************************************************************************************************
 * Name:        ASI_CRM_CN_VA_VendorForm_Extension       
 * Test Class:  ASI_CRM_CN_VA_VendorForm_ExtensionTest
 * Description: CN Vendor Form Extension Class
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2020-03-27       Sera Liao               Create
 *****************************************************************************************************************/
public with sharing class ASI_CRM_CN_VA_VendorForm_Extension {
	public Boolean warning {GET; SET;}

	Private Static Final String ANNUAL_BUSINESS_TRANSACTION_VALUE_2M = '>= RMB 2 million';
    Private Static Final String INTERFACE_WITH_PUBLIC_OFFICIALS = 'Yes';
    
    public ASI_CRM_CN_VA_VendorForm_Extension(ApexPages.StandardController con) {
        warning = false;
        ASI_eForm_Vendor_Form__c vendorForm = [SELECT Id, 
		        									ASI_CRM_CN_VA_Related_Vendor_Form__r.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Added__c,
		        									ASI_CRM_CN_VA_BP_A3__c,
		        									ASI_CRM_CN_VA_BP_A4__c
		        								FROM ASI_eForm_Vendor_Form__c 
		        								WHERE Id =: con.getId()];
        if(!vendorForm.ASI_CRM_CN_VA_Related_Vendor_Form__r.ASI_CRM_CN_VA_Annex_1_Vendor_Is_Added__c){
        	if(vendorForm.ASI_CRM_CN_VA_BP_A3__c == ANNUAL_BUSINESS_TRANSACTION_VALUE_2M
                || vendorForm.ASI_CRM_CN_VA_BP_A4__c == INTERFACE_WITH_PUBLIC_OFFICIALS){
                warning = true;
            }
        }
    }
}