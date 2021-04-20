@isTest
public class ASI_CRM_PaymentRequest_Submit_Ctrl_Test {
    @testSetup
    public static void testdata(){
        String groupId = [Select Id from Group where developername = 'ASI_CRM_MY_Contract_Final'].Id;
        insert new GroupMember(UserorGroupId = UserInfo.getUserId() , groupId = groupId );
    }
    public static testMethod void test1(){
        ASI_CRM_MY_Settings__c my_cs = ASI_CRM_MY_Settings__c.getInstance();
        Date today = my_cs!=null && my_cs.ASI_CRM_MY_Temp_Today__c!=null ? my_cs.ASI_CRM_MY_Temp_Today__c: Date.today();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customerParent = ASI_CRM_MY_TestClassHelper.createParentCustomer('customerParent', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
         ASI_CRM_AccountsAdditionalField__c customerSupplier = ASI_CRM_MY_TestClassHelper.createParentCustomer('customerParent', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_SG_Supplier');

        customerParent.ASI_CRM_CN_Inactive_Flag__c = FALSE;
        update customerParent;
        insert new ASI_CRM_MY_Settings__c(SetupOwnerId = UserInfo.getProfileId());
        ASI_TH_CRM_Contract__c contract = ASI_CRM_MY_TestClassHelper.createContract(customerParent, today, true);
        ASI_TH_CRM_Contract__c ctr = new ASI_TH_CRM_Contract__c(Id = contract.Id);
        ctr.ASI_TH_CRM_Contract_Status__c = 'Final';
        update ctr;
        ASI_TH_CRM_PaymentRequest__c pr = ASI_CRM_MY_TestClassHelper.createPaymentRequest(contract,customerParent,today);
    	pr.ASI_CRM_Vendor__c = customerSupplier.Id;
        pr.ASI_CRM_SG_Invoice_Date__c = date.today();
        update pr; 
      
        test.startTest();
       ASI_CRM_PaymentRequest_Submit_Ctrl.validateRecord(pr.Id);
        ASI_CRM_PaymentRequest_Submit_Ctrl.validateSalesSupport(pr);
        ASI_CRM_PaymentRequest_Submit_Ctrl.validateManualPaymentAttachment(pr);
          Attachment att = new Attachment(ParentId = pr.Id, body = blob.valueOf('sss'), name = 'test PR Attachment');
        insert att;
        ASI_CRM_PaymentRequest_Submit_Ctrl.validateRecord(pr.Id);
        pr.ASI_CRM_System_Remark__c = 'SG Promotion';
        pr.ASI_CRM_SG_Invoice_Date__c = null;
        update pr;
        ASI_CRM_PaymentRequest_Submit_Ctrl.validateRecord(pr.Id);
        pr.ASI_CRM_System_Generated__c = true;
        ASI_CRM_PaymentRequest_Submit_Ctrl.validateAchievement(pr);
        test.stopTest();
    }
}