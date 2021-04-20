/*********************************************************************************
 * Name: ASI_CRM_VN_ContractCtrlTest
 * Description: Test class for ASI_CRM_VN_ContractCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created          
*/
@isTest
public class ASI_CRM_VN_ContractCtrlTest {
    
    @TestSetup
    public static void setupData() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;
        
        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;
         
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
    	insert onTradeCustomer;
       
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        insert contract;
    }
    
    public static testMethod void testCtrl() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        ASI_CRM_VN_ContractCtrl contractCtrl = new ASI_CRM_VN_ContractCtrl(sc);
  	}
    
}