@isTest

private class ASI_CRM_HK_AccChannelRelatedListCtrlTest {

   static testMethod void test_showPAF() {
        Test.StartTest();
             
        ASI_HK_CRM_AccountGenerator acctGenerator = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_PreApprovalFormGenerator pafGenerator = new ASI_HK_CRM_PreApprovalFormGenerator();
        ASI_HK_CRM_RunningNumberGenerator.initPAFRunningNumber();
        
        Account acctCredit = acctGenerator.generateAccount('ASI_HK_CRM_Outlet');    //Credit Account
        insert acctCredit;
        System.debug('abc1'+acctCredit.id);
                
        ASI_HK_CRM_Pre_Approval_Form__c paf = pafGenerator.generatePreApprovalForm(acctCredit, 'ASI_HK_Pre_Approval_Form');        
        Insert paf;
                
        Test.setCurrentPage(Page.ASI_CRM_HK_AccChannelPAFRelatedListPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(acctCredit);
        ASI_CRM_HK_AccChannelRelatedListCtrl c=new ASI_CRM_HK_AccChannelRelatedListCtrl(sc);
               
        Test.stopTest();
    }
}