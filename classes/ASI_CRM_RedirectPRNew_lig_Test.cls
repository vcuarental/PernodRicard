@isTest
public class ASI_CRM_RedirectPRNew_lig_Test {
     @testSetup
    public static void testdata(){
        
        String groupId = [Select Id from Group where developername = 'ASI_CRM_MY_Contract_Final'].Id;
        List<GroupMember> gpm = [Select Id from GroupMember where UserorGroupId = : UserInfo.getUserId() and groupId = : groupId ];
        if(gpm == null || gpm.size()<=0){
        insert new GroupMember(UserorGroupId = UserInfo.getUserId() , groupId = groupId );            
        }
    }
    public static testMethod void test1(){
        ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
        Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customerParent = ASI_CRM_MY_TestClassHelper.createParentCustomer('customerParent', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        customerParent.ASI_CRM_CN_Inactive_Flag__c = FALSE;
        update customerParent;
        insert new ASI_CRM_MY_Settings__c(SetupOwnerId = UserInfo.getProfileId());
        ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customerParent, today, true);
         ASI_TH_CRM_Contract__c ctr = new ASI_TH_CRM_Contract__c(Id = contract.Id);
        ctr.ASI_TH_CRM_Contract_Status__c = 'Final';
        update ctr;
        ASI_TH_CRM_PaymentRequest__c pr = ASI_CRM_MY_TestClassHelper.createPaymentRequest(contract,customerParent,today);
    	test.startTest();
        	ASI_CRM_RedirectPREdit_LightningCtrl.getRecord(pr.Id);
        	ASI_CRM_RedirectPRNew_lig.getRecordTypeName(null);
        	
        test.stopTest();
    }
}