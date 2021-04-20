@isTest
public class EUR_CRM_PT_ROIEvalCtrlTest {
    @testSetUp static void initData(){
        EUR_CRM_Account__c testAccount = EUR_CRM_PT_TestClassHelper.createEUAccount('test Account');
        insert testAccount;
        
        Contact testContact = EUR_CRM_PT_TestClassHelper.createContact(1,'test Contact', testAccount).get(0);
        insert testContact;
        
        EUR_CRM_Contract__c testContract = EUR_CRM_PT_TestClassHelper.createTRContract(1,'Test Contract',testAccount,testContact,'EUR_PT_Outlet_Contract').get(0);
        insert testContract;
        
        EUR_CRM_Mechanic_Type__c mechType = EUR_CRM_PT_TestClassHelper.createMechType('EUR_PT_Bar_Styling_Mechanic_Type').get(0);
        insert mechType;
        
        EUR_CRM_Contract_Activity_Item__c contractActivity = EUR_CRM_PT_TestClassHelper.createContractActivityItem(1,testContract,mechType).get(0);
        insert contractActivity;
          
    }
    
    static testMethod void testROIEval(){
         EUR_CRM_Contract__c testContract = [select id from EUR_CRM_Contract__c where recordType.DeveloperName = 'EUR_PT_Outlet_Contract' limit 1];
        Test.startTest();

        Test.setCurrentPage(Page.EUR_CRM_PT_ROIEvaluationPage);
        ApexPages.standardController sc = new ApexPages.standardController(testContract);
        EUR_CRM_PT_ROIEvalController controller = new EUR_CRM_PT_ROIEvalController(sc);
        controller.availableActivities = null;
        String testString = controller.availableActivities;
        controller.getMechanicTypes();
        
        Test.stopTest();
        
    }

}