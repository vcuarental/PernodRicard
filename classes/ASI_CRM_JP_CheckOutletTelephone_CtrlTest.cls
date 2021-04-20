/*********************************************************************************
 * Name: ASI_CRM_JP_CheckOutletTelephone_CtrlTest
 * Description: Test class for ASI_CRM_JP_CheckOutletTelephone_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2018       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_JP_CheckOutletTelephone_CtrlTest{
    public static testMethod void testCtrl() {
        ApexPages.StandardController sc = new ApexPages.StandardController(new ASI_CRM_AccountsAdditionalField__c());
        
        PageReference pageRef = Page.ASI_CRM_JP_CheckOutletTelephone_Page;
        pageRef.getParameters().put('telephoneNumber', '123');
    	ASI_CRM_JP_CheckOutletTelephone_Ctrl ctrl = new ASI_CRM_JP_CheckOutletTelephone_Ctrl(sc);
        ctrl.searchTelephone();
        ctrl.cancel();
        
        String outletListJson = ctrl.outletListJson;
    }
}