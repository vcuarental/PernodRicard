/*********************************************************************************
 * Name: ASI_CRM_VN_PDFTest
 * Description: Test class for all pdf page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/08/2017       Hugo Cheung             Created
 * 05/01/2019       Andy Zhang              Insert valid contract expenditure
*/
@isTest
public class ASI_CRM_VN_PDFTest {
    
    @TestSetup
    public static void setupData() {
        Test.startTest();
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        ASI_CRM_VN_TestClassHelper.createCustomSettings();
        ASI_CRM_VN_TestClassHelper.createRunningNumber();
        ASI_CRM_VN_TestClassHelper.createExchangeRate();
        
        User u = ASI_CRM_VN_TestClassHelper.createUser(systemAdminProfile.Id);
        u.ManagerId = UserInfo.getUserId();
        insert u;
        
        ASI_GiftBox_Inventory_Master__c inventoryItem = ASI_CRM_VN_TestClassHelper.createInventoryItem();
        insert inventoryItem;
        
        ASI_GiftBox_Inventory_Detail__c inventoryItemDetail = ASI_CRM_VN_TestClassHelper.createInventoryItemDetail(inventoryItem.Id);
        insert inventoryItemDetail;
        
        ASI_MFM_Sub_brand__c subBrand = ASI_CRM_VN_TestClassHelper.createSubBrand();
        insert subBrand;
        
        ASI_MFM_SKU_Code__c sku = ASI_CRM_VN_TestClassHelper.createSKU(subBrand.Id);
        insert sku;
        
        ASI_CRM_ServicePack__c servicePack = ASI_CRM_VN_TestClassHelper.createServicePack();
        insert servicePack;
         
        ASI_CRM_AccountsAdditionalField__c onTradeCustomer = ASI_CRM_VN_TestClassHelper.createOnTradeCustomer();
        onTradeCustomer.ASI_CRM_Service_Pack__c = servicePack.Id;
    	insert onTradeCustomer;
       
        ASI_TH_CRM_Actual_Offtake__c actualOfftake = ASI_CRM_VN_TestClassHelper.createActualOfftake(onTradeCustomer.Id, subBrand.Id);
        insert actualOfftake;
        
        ASI_CRM_VN_Contract__c contract = ASI_CRM_VN_TestClassHelper.createContract(onTradeCustomer.Id, subBrand.Id);
        contract.ASI_CRM_Sys_Owner_Manager__c = u.Id;
        insert contract;

        ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis = ASI_CRM_VN_TestClassHelper.createBottleAnalysis(contract.Id, sku.Id);
        insert bottleAnalysis;
        
        List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList = new List<ASI_CRM_VN_Contract_Expenditure__c>();
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure1 = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure1.ASI_CRM_VN_Item__c   = 'Glassware (Including Ice Buckets)';
        contractExpenditure1.ASI_CRM_VN_Amount__c = 5000000;
        insert contractExpenditure1;
        
        ASI_CRM_VN_Contract_Expenditure__c contractExpenditure2 = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        contractExpenditure2.ASI_CRM_VN_Item__c                        = 'Promotion';
        contractExpenditure2.ASI_CRM_VN_Payment_Times__c               = '3';
        contractExpenditure2.ASI_CRM_VN_Achieved_Target_for_2nd_Pmt__c = 10;
        contractExpenditure2.ASI_CRM_VN_Achieved_Target_for_3rd_Pmt__c = 40;
        insert contractExpenditure2;
        
        Approval.ProcessSubmitRequest contractReq = new Approval.ProcessSubmitRequest();
        contractReq.setComments('Approve.');
        contractReq.setNextApproverIds(new Id[] {u.Id});
        contractReq.setObjectId(contract.Id);
        Approval.ProcessResult result = Approval.process(contractReq);

        List<Id> newWorkItemIds = result.getNewWorkitemIds();

        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {u.ManagerId});

        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));

        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
		
        Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
        req3.setWorkitemId(result2.getNewWorkitemIds().get(0));
        req3.setAction('Approve');
        Approval.ProcessResult result3 =  Approval.process(req3);
	
        contract.ASI_CRM_Area_Code__c       = '123456';
        contract.ASI_CRM_Contract_Number__c = 'Testing Contract 1';
        contract.ASI_CRM_Contract_Status__c = 'Approved';
        update contract;
        Test.stopTest();
    }
    
    public static testMethod void testPDFPage() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        PageReference pageRef = Page.ASI_CRM_VN_PDF_Page;
        pageRef.getParameters().put('pdfType', 'Testing');
        pageRef.getParameters().put('id', contract.Id);
        Test.setCurrentPage(pageRef);
        
        ASI_CRM_VN_PDF_Ctrl pdfCtrl = new ASI_CRM_VN_PDF_Ctrl();
    }
    
    public static testMethod void testMCFPDF() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        
        ASI_CRM_VN_MCF_PDF_Ctrl mcfPDFCtrl = new ASI_CRM_VN_MCF_PDF_Ctrl();
        mcfPDFCtrl.contractId = contract.Id;
        
        Boolean initCtrl = mcfPDFCtrl.isPageInit;
    }
    
    public static testMethod void testCapsulePDF() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];

        ASI_CRM_VN_MCF_Capsule_PDF_Ctrl capsulePDFCtrl = new ASI_CRM_VN_MCF_Capsule_PDF_Ctrl();
        capsulePDFCtrl.contractId = contract.Id;
        Boolean initCtrl = capsulePDFCtrl.isPageInit;
    }
    
    public static testMethod void testSPPDF() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        ASI_GiftBox_Inventory_Master__c inventoryItem = [SELECT Id FROM ASI_GiftBox_Inventory_Master__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'prvtest'];
        
        Test.startTest();
        ASI_CRM_VN_Contract_Expenditure__c expenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
        insert expenditure;

            ASI_GiftBox_Request_Header__c posmRequest = ASI_CRM_VN_TestClassHelper.createPOSMRequest(contract.Id);
            insert posmRequest;

            List<ASI_GiftBox_Request_Item__c> requestItemList = new List<ASI_GiftBox_Request_Item__c>();
            for(Integer i = 0 ; i < 2 ; i++) {
                ASI_GiftBox_Request_Item__c requestItem = ASI_CRM_VN_TestClassHelper.createPOSMRequestItem(posmRequest.Id, inventoryItem.Id);
                requestItemList.add(requestItem);
            }
            insert requestItemList;

            System.runAs(u) {
                Approval.ProcessSubmitRequest requestReq = new Approval.ProcessSubmitRequest();
                requestReq.setComments('Approve.');
                requestReq.setNextApproverIds(new Id[] {u.Id});
                requestReq.setObjectId(posmRequest.Id);
                Approval.ProcessResult result = Approval.process(requestReq);

                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setWorkitemId(result.getNewWorkitemIds().get(0));
                req2.setAction('Approve');
                Approval.ProcessResult result2 =  Approval.process(req2);
				
                if(result2.getNewWorkitemIds().size() > 0) {
                    Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
                    req3.setWorkitemId(result2.getNewWorkitemIds().get(0));
                    req3.setAction('Approve');
                    Approval.ProcessResult result3 =  Approval.process(req3);
                }
            }

            ASI_CRM_VN_SP_Request_PDF_Ctrl spPDFCtrl = new ASI_CRM_VN_SP_Request_PDF_Ctrl();
            spPDFCtrl.requestId = posmRequest.Id;

            Boolean initCtrl = spPDFCtrl.isPageInit;
        Test.stopTest();
    }
    
    public static testMethod void testCSPDF() {
        ASI_CRM_VN_Contract__c contract = [SELECT Id, ASI_CRM_Outlet_WS__c, ASI_CRM_Key_Brand__c FROM ASI_CRM_VN_Contract__c LIMIT 1];
        User u = [SELECT Id FROM User WHERE Alias = 'prvtest'];
        
        Test.startTest();
        ASI_CRM_VN_Contract_Expenditure__c expenditure = ASI_CRM_VN_TestClassHelper.createContractExpenditure(contract.Id);
        expenditure.ASI_CRM_VN_Item__c = 'Lump Sum';
        insert expenditure;

            ASI_GiftBox_Request_Header__c csRequest = ASI_CRM_VN_TestClassHelper.createCSRequest(contract.Id);
        	insert csRequest;

            System.runAs(u) {
                // Approve CS Request
                Approval.ProcessSubmitRequest csRequestReq = new Approval.ProcessSubmitRequest();
                csRequestReq.setNextApproverIds(new Id[] {u.Id});
                csRequestReq.setObjectId(csRequest.Id);

                Approval.ProcessResult result = Approval.process(csRequestReq);


                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setWorkitemId(result.getNewWorkitemIds().get(0));
                req2.setAction('Approve');


                // Submit the request for approval
                Approval.ProcessResult result2 =  Approval.process(req2);

                Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
                System.debug(result2.getNewWorkitemIds());
                if(result2.getNewWorkitemIds().size()>0) {
                    req3.setWorkitemId(result2.getNewWorkitemIds().get(0));
                    req3.setAction('Approve');
                    Approval.ProcessResult result3 =  Approval.process(req3);
                }



            }


            ASI_CRM_VN_CS_Request_PDF_Ctrl csPDFCtrl = new ASI_CRM_VN_CS_Request_PDF_Ctrl();
            csPDFCtrl.requestId = csRequest.Id;

            Boolean initCtrl = csPDFCtrl.isPageInit;
        Test.stopTest();
    }
    
}