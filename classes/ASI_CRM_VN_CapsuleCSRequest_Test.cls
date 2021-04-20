/*********************************************************************************
 * Name: ASI_CRM_VN_CapsuleCSRequest_Test
 * Description: Class for Capsule CS Request
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 11/12/2017       Hugo Cheung             Created
 * 08/01/2019       Andy Zhang              Revise contract expenditure
*/
@isTest
public class ASI_CRM_VN_CapsuleCSRequest_Test {
    
    @TestSetup
    public static void setupData() {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();

        User u = ASI_CRM_VN_TestClassHelper.createUser(systemAdminProfile.Id);
        u.ManagerId = UserInfo.getUserId();
        insert u;
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        ASI_MFM_Sub_brand__c subBrand2 = ASI_CRM_VN_TestClassHelper.createSubBrand();
        
        List<ASI_MFM_Sub_brand__c> subBrandList = new List<ASI_MFM_Sub_brand__c>();
        subBrandList.add(subBrand);
        subBrandList.add(subBrand2);
        insert subBrandList;
        
        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;
         
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
    	insert onTradeCustomer;
        
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        ASI_TH_CRM_Actual_Offtake__c actualOfftake2 = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand2.Id);
        actualOfftakeList.add(actualOfftake);
        actualOfftakeList.add(actualOfftake2);
        insert actualOfftakeList;
       
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        contract.RecordTypeId               = Global_RecordTypeCache.getRtId('ASI_CRM_VN_Contract__c' + 'ASI_CRM_VN_Capsule_Agreement_Contract');
        insert contract;

        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure = ASI_CRM_VN_TestClassHelper.createCapsuleContractExpenditure(contract.Id, subBrand.Id);
        contractExpenditure.ASI_CRM_VN_Item__c     = 'Lump Sum';
        contractExpenditure.ASI_CRM_Achieved_Target_for_1st_Pmt__c = 5;
        contractExpenditure.ASI_CRM_VN_Amount__c = 1000;
        contractExpenditure.ASI_CRM_VN_Quantity__c = 1;
        contractExpenditure.ASI_CRM_Amount_for_1st_Payment__c = 1000;
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure2 = ASI_CRM_VN_TestClassHelper.createCapsuleContractExpenditure(contract.Id, subBrand2.Id);
        contractExpenditure2.ASI_CRM_VN_Item__c     = 'Lump Sum';
        contractExpenditure2.ASI_CRM_Achieved_Target_for_1st_Pmt__c = 5;
        contractExpenditure2.ASI_CRM_VN_Amount__c = 1000;
        contractExpenditure2.ASI_CRM_VN_Quantity__c = 1;
        contractExpenditure2.ASI_CRM_Amount_for_1st_Payment__c = 1000;
        contractExpenditureList.add(contractExpenditure);
        contractExpenditureList.add(contractExpenditure2);
        insert contractExpenditureList;
    }
	
    public static testMethod void testCapsuleCSRequest() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];

        System.debug([SELECT Id FROM ASI_GiftBox_Request_Header__c]);
    	ASI_GiftBox_Request_Header__c capsuleCSRequest = ASI_CRM_VN_TestClassHelper.createCapsuleCSRequest(contract.Id);
        insert capsuleCSRequest;
        
        capsuleCSRequest.ASI_GiftBox_Status__c = 'Approved';
        update capsuleCSRequest;
        
        List<ASI_GiftBox_Request_Item__c> itemList = [SELECT Id FROM ASI_GiftBox_Request_Item__c];
        for(ASI_GiftBox_Request_Item__c item : itemList) {
            item.ASI_CRM_Amount__c = 5;
        }
        update itemList;
        try {
        	delete itemList;
        } catch(Exception e) {
        }
        try {
        	delete capsuleCSRequest;
        } catch(Exception e) {
        }
    }
    
    public static testMethod void testPDF() {
    	ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'prvtest'];
        
        Test.startTest();

    		ASI_GiftBox_Request_Header__c capsuleCSRequest = ASI_CRM_VN_TestClassHelper.createCapsuleCSRequest(contract.Id);
        	capsuleCSRequest.ASI_CRM_Sys_Pending_Approval__c = true;
        	insert capsuleCSRequest;

            System.runAs(u) {
                Approval.ProcessSubmitRequest csRequestReq = new Approval.ProcessSubmitRequest();
                csRequestReq.setComments('Approve please.');
                csRequestReq.setNextApproverIds(new Id[] {u.Id});
                csRequestReq.setObjectId(capsuleCSRequest.Id);
                Approval.ProcessResult result = Approval.process(csRequestReq);

                List<Id> newWorkItemIds = result.getNewWorkitemIds();

                // Instantiate the new ProcessWorkitemRequest object and populate it
                Approval.ProcessWorkitemRequest req2 =
                        new Approval.ProcessWorkitemRequest();
                req2.setComments('Approving request.');
                req2.setAction('Approve');
                req2.setNextApproverIds(new Id[] {u.Id});

                // Use the ID from the newly created item to specify the item to be worked
                req2.setWorkitemId(newWorkItemIds.get(0));

                // Submit the request for approval
                Approval.ProcessResult result2 =  Approval.process(req2);
                

                ASI_CRM_VN_CapsuleCS_Request_PDF_Ctrl csPDFCtrl = new ASI_CRM_VN_CapsuleCS_Request_PDF_Ctrl();
                csPDFCtrl.requestId = capsuleCSRequest.Id;
                Boolean initCtrl = csPDFCtrl.isPageInit;

            }


        Test.stopTest();
    }
    
    public static testmethod void testComponent() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_MFM_Sub_brand__c subBrand = [SELECT Id FROM ASI_MFM_Sub_brand__c LIMIT 1];


    	ASI_GiftBox_Request_Header__c capsuleCSRequest = ASI_CRM_VN_TestClassHelper.createCapsuleCSRequest(contract.Id);
        insert capsuleCSRequest;
        
        ASI_CRM_VN_CapsuleCSRequestItemTableCtrl ctrl = new ASI_CRM_VN_CapsuleCSRequestItemTableCtrl();
        ctrl.requestId = capsuleCSRequest.Id;
        
        Boolean initCtrl = ctrl.isPageInit;
    }
}