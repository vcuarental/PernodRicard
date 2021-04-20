@isTest
public class ASI_CRM_NewPR_On_Contract_ctrl_Test {
    public static testMethod void test1(){
        ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
        Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customerParent = ASI_CRM_MY_TestClassHelper.createParentCustomer('customerParent', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        customerParent.ASI_CRM_CN_Inactive_Flag__c = FALSE;
        update customerParent;
        insert new ASI_CRM_MY_Settings__c(SetupOwnerId = UserInfo.getProfileId());
        ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customerParent, today, true);
        test.startTest();
        ASI_CRM_NewPR_On_Contract_ctrl.getRecordType();
        ASI_CRM_NewPR_On_Contract_ctrl.getContract(contract.Id);
        test.stopTest();
    }
}