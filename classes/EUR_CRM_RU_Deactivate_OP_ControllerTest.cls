@isTest
public class EUR_CRM_RU_Deactivate_OP_ControllerTest {
    
    @testSetUp static void initData(){
        
        EUR_CRM_Apex_Configuration__c apexConfig = EUR_CRM_RU_TestClassHelper.createApexConfig();
        insert apexConfig;
        
        EUR_CRM_Account__c testAccount = EUR_CRM_RU_TestClassHelper.createEUAccount('test Account');
        insert testAccount;
        
        EUR_CRM_OP_Action_List_Template__c testTemplate = EUR_CRM_RU_TestClassHelper.createActionListTemplate();
        insert testTemplate;
        
        EUR_CRM_ObjPromo__c objPromo = EUR_CRM_RU_TestClassHelper.createObjPromo(1,'EUR_RU_ON_Trade_Phase_1','test ObjPromo',testTemplate).get(0);
        objPromo.EUR_CRM_Status__c = 'Active';
        insert objPromo;
        
        
        
        EUR_CRM_ObjPromo_Account_Mapping__c testAccountMapping = EUR_CRM_RU_TestClassHelper.createOPAccountMapping(1,'EUR_RU_O_P_Account_Mapping',testAccount,objPromo).get(0);
        testAccountMapping.EUR_CRM_Is_Active__c = true;
        insert testAccountMapping;
        
        
        
    }
    
    static testMethod void testDeactivate(){
        EUR_CRM_ObjPromo__c objPromo = [select Id from EUR_CRM_ObjPromo__c where recordType.DeveloperName = 'EUR_RU_ON_Trade_Phase_1' limit 1];
        
        Test.startTest();
        
        Test.setCurrentPage(Page.EUR_CRM_RU_Deactivate_OP_Page);
        ApexPages.currentPage().getParameters().put('Id',objPromo.Id);
        EUR_CRM_RU_Deactivate_OP_Controller controller = new EUR_CRM_RU_Deactivate_OP_Controller();
        controller.deactivateOP();
        
        Test.stopTest();
        
    }
    
}