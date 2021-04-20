@isTest
public class EUR_CRM_PT_ObjectivePromoPageCtrlTest {
    
    @testSetUp static void initData(){
        EUR_CRM_Category__c categoryPT = EUR_CRM_PT_TestClassHelper.createCategory('EUR_PT_Category');
        insert categoryPT;
        
        EUR_CRM_Brand__c brand = EUR_CRM_PT_TestClassHelper.createBrand('Test Name', categoryPT);
        insert brand;
        
        EUR_CRM_OP_Action_List_Template__c testTemplate = EUR_CRM_PT_TestClassHelper.createActionListTemplate();
        insert testTemplate;
        
        EUR_CRM_ObjPromo__c objPromo = EUR_CRM_PT_TestClassHelper.createObjPromo(1,'EUR_PT_Off_Trade_OP_No_of_Display','test ObjPromo',testTemplate).get(0);
        objPromo.EUR_CRM_Status__c = 'Active';
        insert objPromo;
        
        EUR_CRM_Account__c testAccount = EUR_CRM_PT_TestClassHelper.createEUAccount('test Account');
        insert testAccount;
        
        List<EUR_CRM_ObjPromo_Target__c> objectPromoTargetAccountList = EUR_CRM_PT_TestClassHelper.createOPTarget(5,'EUR_PT_Off_Trade_OP_Target_per_Account', objPromo.Id, null, testAccount.Id, brand.Id);
        insert objectPromoTargetAccountList;
        List<EUR_CRM_ObjPromo_Target__c> objectPromoTargetBrandList = EUR_CRM_PT_TestClassHelper.createOPTarget(5,'EUR_PT_Off_Trade_OP_Target_per_Brand', objPromo.Id, null, testAccount.Id, brand.Id);
        insert objectPromoTargetBrandList;
        
    }
    
    static testMethod void testdeleteRecord(){
        EUR_CRM_ObjPromo__c objPromo = [select Id from EUR_CRM_ObjPromo__c where recordType.DeveloperName = 'EUR_PT_Off_Trade_OP_No_of_Display' limit 1];
        
        Test.startTest();
        
        Test.setCurrentPage(Page.EUR_CRM_PT_ObjectivePromoPage);
        ApexPages.currentPage().getParameters().put('Id',objPromo.Id);
        ApexPages.standardController sc = new ApexPages.standardController(objPromo);
        EUR_CRM_PT_ObjectivePromoPageController controller = new EUR_CRM_PT_ObjectivePromoPageController(sc);
        controller.deleteRecord();
        
        Test.stopTest();
        
    }
    
    static testMethod void testSaveOPTarget(){
        EUR_CRM_ObjPromo__c objPromo = [select Id from EUR_CRM_ObjPromo__c where recordType.DeveloperName = 'EUR_PT_Off_Trade_OP_No_of_Display' limit 1];
        
        Test.startTest();
        
        Test.setCurrentPage(Page.EUR_CRM_PT_ObjectivePromoPage);
        ApexPages.currentPage().getParameters().put('Id',objPromo.Id);
        ApexPages.standardController sc = new ApexPages.standardController(objPromo);
        EUR_CRM_PT_ObjectivePromoPageController controller = new EUR_CRM_PT_ObjectivePromoPageController(sc);
        controller.saveOPTarget();
        
        Test.stopTest();
        
    }
    
    static testMethod void testResetRecord(){
        EUR_CRM_ObjPromo__c objPromo = [select Id from EUR_CRM_ObjPromo__c where recordType.DeveloperName = 'EUR_PT_Off_Trade_OP_No_of_Display' limit 1];
        
        Test.startTest();
        
        Test.setCurrentPage(Page.EUR_CRM_PT_ObjectivePromoPage);
        ApexPages.currentPage().getParameters().put('Id',objPromo.Id);
        ApexPages.standardController sc = new ApexPages.standardController(objPromo);
        EUR_CRM_PT_ObjectivePromoPageController controller = new EUR_CRM_PT_ObjectivePromoPageController(sc);
        controller.resetRecord();
        controller.enableEdit();
        
        Test.stopTest();
        
    }
    
}