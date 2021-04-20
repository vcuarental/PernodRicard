@isTest
public class EUR_CRM_PT_Deactivate_OP_ControllerTest {
    
    @testSetUp static void initData(){
        EUR_CRM_OP_Action_List_Template__c testTemplate = EUR_CRM_PT_TestClassHelper.createActionListTemplate();
        insert testTemplate;
        
        EUR_CRM_ObjPromo__c objPromo = EUR_CRM_PT_TestClassHelper.createObjPromo(1,'EUR_PT_Off_Trade_OP_No_of_Display','test ObjPromo',testTemplate).get(0);
        objPromo.EUR_CRM_Status__c = 'Active';
        insert objPromo;
        
        EUR_CRM_Account__c testAccount = EUR_CRM_PT_TestClassHelper.createEUAccount('test Account');
        insert testAccount;
        
        EUR_CRM_ObjPromo_Account_Mapping__c testAccountMapping = EUR_CRM_PT_TestClassHelper.createobjPromoAccMapping('EUR_PT_Account_Mapping',testAccount.Id,objPromo.Id);
        testAccountMapping.EUR_CRM_Is_Active__c = true;
        insert testAccountMapping;
        
    }
    
    static testMethod void testDeactivate(){
        EUR_CRM_ObjPromo__c objPromo = [select Id from EUR_CRM_ObjPromo__c where recordType.DeveloperName = 'EUR_PT_Off_Trade_OP_No_of_Display' limit 1];
        
        Test.startTest();
        
        Test.setCurrentPage(Page.EUR_CRM_PT_Deactivate_OP_Page);
        ApexPages.currentPage().getParameters().put('Id',objPromo.Id);
        EUR_CRM_PT_Deactivate_OP_Controller controller = new EUR_CRM_PT_Deactivate_OP_Controller();
        controller.deactivateOP();
        
        Test.stopTest();
        
    }
}