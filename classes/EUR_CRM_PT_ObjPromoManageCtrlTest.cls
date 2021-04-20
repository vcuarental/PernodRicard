@isTest
public class EUR_CRM_PT_ObjPromoManageCtrlTest {
    
    @testSetUp static void initData(){
        EUR_CRM_Category__c testCategory = EUR_CRM_PT_TestClassHelper.createCategory('EUR_PT_Category');
        insert testCategory;
        
        EUR_CRM_Brand__c testBrand = EUR_CRM_PT_TestClassHelper.createBrand('test brand',testCategory);
        testBrand.EUR_CRM_External_ID__c = 'Test_Class_Brand_Id';
        insert testBrand;
      
        
        List<EUR_CRM_Account__c> testAccountList = EUR_CRM_PT_TestClassHelper.createEUAccountList(5,'TestClass','Test_Class_Acc_Id');
        //testAccount.EUR_CRM_External_ID__c = 'Test_Class_Acc_Id';
        insert testAccountList;
            
        EUR_CRM_OP_Action_List_Template__c testTemplate = EUR_CRM_PT_TestClassHelper.createActionListTemplate();
        insert testTemplate;
        
        EUR_CRM_ObjPromo__c objectPromo = EUR_CRM_PT_TestClassHelper.createObjPromo(1,'EUR_PT_Off_Trade_OP_No_of_Display','test ObjPromo',testTemplate).get(0);
        objectPromo.EUR_CRM_Status__c = 'Active';
        insert objectPromo;
        
    }
    
    static testMethod void testInitPage(){
        EUR_CRM_ObjPromo__c objPromo = [select Id from EUR_CRM_ObjPromo__c where recordType.developerName = 'EUR_PT_Off_Trade_OP_No_of_Display' limit 1];
        String attBody = 'Account External ID,Brand External ID,Target No. of Display\nTest_Class_Acc_Id1,Test_Class_Brand_Id,50';
        Blob attBodyBlob = Blob.valueof(attBody);
        Attachment att = new Attachment(ParentId = objPromo.Id,
                                        name = 'testName.csv', body = attBodyBlob, ContentType ='text/plain; charset=UTF-8');
        insert att;
        
        Test.startTest();
        
        Test.setCurrentPage(Page.EUR_CRM_PT_ObjPromoManagePage);
        ApexPages.currentPage().getParameters().put('objPromoId',objPromo.Id);
         ApexPages.currentPage().getParameters().put('AttId',att.Id);
        ApexPages.standardController sc = new ApexPages.standardController(objPromo);
        EUR_CRM_PT_ObjPromoManageController controller = new EUR_CRM_PT_ObjPromoManageController(sc);
        controller.firstPage();
        controller.lastPage();
        controller.nextPage();
        controller.previousPage();
        controller.cancel();
        controller.saveTarget();
        
        Test.stopTest();
        
    }
    
     static testMethod void testUploadCSV(){
        EUR_CRM_ObjPromo__c objPromo = [select Id from EUR_CRM_ObjPromo__c where recordType.developerName = 'EUR_PT_Off_Trade_OP_No_of_Display' limit 1];
        String attBody = 'Account External ID,Brand External ID,Target No. of Display\nTest_Class_Acc_Id,Test_Class_Brand_Id,50';
        Blob attBodyBlob = Blob.valueof(attBody);

        Test.startTest();
        
        Test.setCurrentPage(Page.EUR_CRM_PT_ObjPromoManagePage);
        ApexPages.currentPage().getParameters().put('objPromoId',objPromo.Id); 
        ApexPages.standardController sc = new ApexPages.standardController(objPromo);
        EUR_CRM_PT_ObjPromoManageController controller = new EUR_CRM_PT_ObjPromoManageController(sc);
        controller.namefile = 'Test Upload.csv';
        controller.contentFile = attBodyBlob ;
        //controller.ParentId = objPromo.Id;
        controller.fileSize = 4000;
         
         controller.uploadCSV();
         controller.isProductSelectionDone = true;
         controller.isManagerLevelTargetDone = true;
         controller.isTargetManagementDone = true;
         controller.selectedSelectionMethod = '';
           controller.selectedProductSelection = '';
        
        Test.stopTest();
        
    }
    
}