/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_Promotion_Request_PDF_Test
 * Description: Test class for ASI_CRM_VN_Promotion_Request_PDF_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-01-29       Jeffrey Cheung          Created
 * 2019-01-05       Andy Zhang              Insert valid contract expenditure and resolve SOQL limitation error
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_Promotion_Request_PDF_Test {
    @IsTest static void testBehavior() {
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        User user = ASI_CRM_VN_TestClassHelper.createUserByProfileName('System Administrator');
        user.ManagerId = UserInfo.getUserId();
        insert user;

        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;

        ASI_CRM_AccountsAdditionalField__c customer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        customer.OwnerId = user.Id;
        customer.ASI_CRM_Service_Pack__c = servicePack.Id;
        insert customer;

        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;

        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(customer.Id, subBrand.Id);
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        insert contract;

        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure.ASI_CRM_VN_Item__c = 'Promotion';
        insert contractExpenditure;

        ASI_CRM_Trade_A_P_Plan__c plan = ASI_CRM_VN_TestClassHelper.createPromotionPlan();
        insert plan;
        ASI_CRM_Trade_A_P_Plan_Item__c planItem = ASI_CRM_VN_TestClassHelper.createPromotionPlanItem(plan.Id);
        insert planItem;

        plan.ASI_CRM_Status__c = 'Approved';
        update plan;
		
        System.runAs(user) {
            test.startTest();
            ASI_CRM_VN_Contract_Expenditure__c expenditure= ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
            expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
            insert expenditure;

            ASI_GiftBox_Request_Header__c requestHeader = ASI_CRM_VN_TestClassHelper.createPromotionRequest(contract.Id);
            requestHeader.ASI_CRM_Trade_A_P_Plan__c = plan.Id;
            insert requestHeader;
            test.stopTest();
            
            ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPromotionRequestItem(requestHeader.Id);
            insert requestItem;
    
            // Approve promotion request
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(requestHeader.Id);
            Approval.ProcessResult result = Approval.process(req1);
    
            List<Id> newWorkItemIds = result.getNewWorkitemIds();
    
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setAction('Approve');
    
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));
    
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
            // Done!
    
    
            ASI_CRM_VN_Promotion_Request_PDF_Ctrl controller = new ASI_CRM_VN_Promotion_Request_PDF_Ctrl();
            controller.requestId = requestHeader.Id;
            controller.init();
        }
    }
}