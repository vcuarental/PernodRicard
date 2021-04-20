/*********************************************************************************
 * Name: ASI_CRM_SG_SLDSDynamicLookupCtrlTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-02-21       Billy Lo                Created
 */
@isTest
private class ASI_CRM_SG_SLDSDynamicLookupCtrlTest {

	private static testMethod void testController() {
	    
	    Test.startTest();
	    
	    ASI_CRM_SG_TestClassHelper.createDataSettings();
	    ASI_CRM_SG_TestClassHelper.customerData customerC = new ASI_CRM_SG_TestClassHelper.customerData(true);
	    
	    ASI_CRM_SG_SLDSDynamicLookupController controller = new ASI_CRM_SG_SLDSDynamicLookupController();
	    controller.objectName = 'ASI_CRM_AccountsAdditionalField__c';
	    controller.label = 'Customer';
	    
	    ASI_CRM_SG_SLDSDynamicLookupController.search('ASI_CRM_AccountsAdditionalField__c','Name','','field->Id','','Name != NULL');
	    ASI_CRM_SG_SLDSDynamicLookupController.search('ASI_CRM_AccountsAdditionalField__c','Name','','url->url','','Name != NULL');
	    
	    Test.stopTest();

	}

}