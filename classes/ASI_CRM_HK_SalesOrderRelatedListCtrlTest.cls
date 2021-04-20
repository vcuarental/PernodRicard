@isTest
/*********************************************************************************
 * Name: ASI_CRM_HK_SalesOrderRelatedListCtrlTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-09-25       Wilken Lee             [WL 1.0] Added test method for ASI_CRM_HK_SORelatedListCtrl class
 */
private class ASI_CRM_HK_SalesOrderRelatedListCtrlTest {

    static testMethod void test_showSO() {
        Test.StartTest();
        
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        
        Account acc=cmData.acctPA;
                
        Test.setCurrentPage(Page.ASI_CRM_HK_AccSalesOrderRelatedListPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        ASI_CRM_HK_AccSalesOrderRelatedListCtrl c=new ASI_CRM_HK_AccSalesOrderRelatedListCtrl(sc);
        
        c.getLineItem();
        String s=c.mapSOlineJSON;
               
        Test.stopTest();
    }
	
	/*[WL 1.0] BEGIN*/
	static testMethod void test_ASI_CRM_HK_SORelatedListCtrl() {
        Test.StartTest();
        
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        ASI_HK_CRM_TestUtils.initSOWSSettings();
        ASI_HK_CRM_TestUtils.CommonData cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        
        Account acc=cmData.acctPA;
                
        Test.setCurrentPage(Page.ASI_CRM_HK_SORelatedListPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(cmData.so);
        ASI_CRM_HK_SORelatedListCtrl ctrl = new ASI_CRM_HK_SORelatedListCtrl(sc);
        
		PageReference pageRef = ctrl.editItem();
        Test.stopTest();
    }
	/*[WL 1.0] END*/
}