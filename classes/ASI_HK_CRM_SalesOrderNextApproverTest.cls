/*********************************************************************************
 * Name:ASI_HK_CRM_SalesOrderNextApproverTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 28/11/2017       Wilken Lee          	[WL 1.0] Modify updateApprover method not to use @future to avoid batch apex limit
*********************************************************************************/
@isTest
private class ASI_HK_CRM_SalesOrderNextApproverTest {

    static testMethod void soNextApproverTest() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Is_Web_Service_Failed__c = false;
        so.ASI_HK_CRM_Order_Status_Name__c = 'Submitted';
        update so;
        
        Set<Id> soIdSet = new Set<Id>();
        ASI_HK_CRM_SalesOrderNextApprover.updateApprover(soIdSet);
    }
    
    static testMethod void soNextApproverTest2() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
		
		Test.startTest();
		ASI_HK_CRM_Sales_Order__c so = cmData.so;
		
		/*[WL 1.0] BEGIN*/
        //so.ASI_HK_CRM_Order_Status_Name__c = 'Submitted';
		so.ASI_HK_CRM_Order_Status_Name__c = 'Hold Code Received';
		so.ASI_HK_CRM_SYS_Approver_1__c = UserInfo.getUserId();
		so.ASI_HK_CRM_SYS_Greater_Than_Min_Amount__c = true;
		/*[WL 1.0] END*/
        
        so.ASI_HK_CRM_Is_Web_Service_Failed__c = false;

        update so;
        
        Set<Id> soIdSet = new Set<Id>();
        ASI_HK_CRM_SalesOrderNextApprover.updateApprover2(soIdSet);
    }
	
	/*[WL 1.0] BEGIN*/
	static testMethod void soNextApproverTestSubmit() {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        //ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
		
		Test.startTest();
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Is_Web_Service_Failed__c = false;
        so.ASI_HK_CRM_Order_Status_Name__c = 'Hold Code Received';
		so.ASI_HK_CRM_SYS_Approver_1__c = UserInfo.getUserId();
		so.ASI_HK_CRM_SYS_Greater_Than_Min_Amount__c = true;
        update so;

		system.debug(' SO ASI_HK_CRM_SYS_Greater_Than_Min_Amount__c: ' + so.ASI_HK_CRM_SYS_Greater_Than_Min_Amount__c + ' ASI_HK_CRM_SYS_Approver_1__c: ' + so.ASI_HK_CRM_SYS_Approver_1__c);
		
		Test.stopTest();
		/*Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(so.id);
		Approval.ProcessResult result = Approval.process(req1);*/
    }
	/*[WL 1.0] END*/
}