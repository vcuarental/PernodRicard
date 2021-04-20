/*********************************************************************************
 * Name: ASI_CRM_SG_SubmitApproval_Test
 * Description: Test for ASI_CRM_SG_SubmitApprovalController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-11-24       Jeffrey Cheung          Created          
 * 2018-04-24       Wilken Lee              [WL 1.0] CHM117802599 Add mandatory comment before complete        
*/

@isTest
public class ASI_CRM_SG_SubmitApproval_Test {
    // cover try block
    static testMethod void testSubmitApproval(){
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.contractData cd = new ASI_CRM_SG_TestClassHelper.contractData(false, 'Draft');
        // meet Entry Criteria
        cd.contract.RecordTypeId = Schema.SObjectType.ASI_TH_CRM_Contract__c.getRecordTypeInfosByName().get('ASI CRM SG 2. Contract').getRecordTypeId();
        cd.contract.ASI_CRM_Sys_Allow_Submit_Approval__c = true;
        // set manager
        User u = ASI_CRM_SG_TestClassHelper.createUser();
        User manager = ASI_CRM_SG_TestClassHelper.createUser('manager');
        u.ManagerId = manager.Id;
        update u;
        // set owner
        cd.contract.OwnerId = u.Id;
        insert cd.contract;

        Test.StartTest();
        
        PageReference testPage = Page.ASI_SubmitApprovalPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', cd.contract.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_SG_SubmitApprovalController controller = new ASI_CRM_SG_SubmitApprovalController();
        
        controller.submit(); 
        
        Test.StopTest();
    }
    
    // cover catch block
    static testMethod void testSubmitApprovalFail(){
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.contractData cd = new ASI_CRM_SG_TestClassHelper.contractData(false, 'Draft');
        insert cd.contract;

        Test.StartTest();
        
        PageReference testPage = Page.ASI_SubmitApprovalPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', cd.contract.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_SG_SubmitApprovalController controller = new ASI_CRM_SG_SubmitApprovalController();
        
        controller.submit(); 
        
        Test.StopTest();
    }

	/*[WL 1.0] BEGIN*/
	static testMethod void testComplete(){
        ASI_CRM_SG_TestClassHelper.createDataSettings();
        ASI_CRM_SG_TestClassHelper.contractData cd = new ASI_CRM_SG_TestClassHelper.contractData(false, 'Contract Approved');
        // meet Entry Criteria
        cd.contract.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only');
        // set manager
        User u = ASI_CRM_SG_TestClassHelper.createUser();
        User manager = ASI_CRM_SG_TestClassHelper.createUser('manager');
        u.ManagerId = manager.Id;
        update u;
        // set owner
        cd.contract.OwnerId = u.Id;
        insert cd.contract;

        Test.StartTest();
        
        PageReference testPage = Page.ASI_SubmitApprovalPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', cd.contract.Id);
        Test.setCurrentPageReference(testPage);
        
        ASI_CRM_SG_SubmitApprovalController controller = new ASI_CRM_SG_SubmitApprovalController();
        
		controller.comment = 'test';
        controller.submit(); 
        
        Test.StopTest();
    }
	/*[WL 1.0] END*/
}