/*********************************************************************************
 * Name:ASI_CRM_JP_PurchaseContract_Test
 * Description: Test Class for Purchase Contract of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/1/2015       Laputa: Hank              Created
 * 2/4/2015       Laputa: Conrad            Add test method for Manage All Page for Contract
*********************************************************************************/
@isTest
private class ASI_CRM_JP_PurchaseContract_Test {
    //Test for ASI_CRM_PurchaseContractTgrHdlr
    //Also cover Class ASI_CRM_JP_AssignAutoNumber_Contract and ASI_CRM_JP_AssignApprover_LineManager
    static testMethod void ASI_CRM_PurchaseContractTgrHdlr_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test2@laputa.com');
        insert u2;
        //insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        test.startTest();
        List<ASI_CRM_Purchase_Contract__c> contractList = new List<ASI_CRM_Purchase_Contract__c>();
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addmonths(1));
        ASI_CRM_Purchase_Contract__c contract2 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addmonths(1));
        ASI_CRM_Purchase_Contract__c contract3 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addmonths(1));
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = '4{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_Rebate_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        contractList.add(contract1);
        contractList.add(contract2);
        contractList.add(contract3);
        insert contractList;
        contract1.OwnerId = u2.Id;
        contract1.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract_Read_Only');
        contract2.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Indirect_Rebate_Contract_Read_Only');
        contract3.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract_Read_Only');
        update contractList;
        test.stopTest();
    }
    
    //Test for Contract PDF (86%)
    static testMethod void ASI_CRM_JP_ContractPDF(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        List<User> userList = new List<user>();

        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test4@laputa.com');
        insert u4;

        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        userList.add(u1);
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test2@laputa.com');
        userList.add(u2);
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test3@laputa.com',
            managerid = u4.id);
        userList.add(u3);
        insert userList;
        
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addMonths(3));
        insert contract1;
        contract1.ASI_CRM_Approver_1__c = u2.id;
        contract1.ASI_CRM_Approver_2__c = u3.id;
        contract1.ASI_CRM_Approver_3__c = u4.id;
        update contract1;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
        insert ap;
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
       	insert itemGroup;
        
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
        insert line1;
        
        // Create an approval request for the account
        /*
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(contract1.id);
        req1.setSubmitterId(u1.Id); 
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {u3.id});
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        System.RunAs(u3){
            Approval.ProcessResult result2 =  Approval.process(req2);
        }
        */
        test.startTest();
        PageReference pageRef = Page.ASI_CRM_JP_Contract_PDFPage;
        pageRef.getParameters().put('Id', contract1.Id);
        Test.setCurrentPage(pageRef);
        ASI_CRM_JP_ContractPDFController controller = new ASI_CRM_JP_ContractPDFController();
        controller.setcurrentHeaderId(contract1.Id); 
        controller.setinit(contract1.Id);
        controller.Header = null;
        controller.getHeader();
        controller.details = null;
        controller.getDetails();
        controller.getPageMargin();
        controller.getFirstMargin();
        controller.getApproverLanguage();
        controller.getapprovalDetails();
        controller.getCheckIfJP();
        controller.getcurrentHeaderId();
        ASI_CRM_JP_ContractPDFController.approvalDetail appdetail = new ASI_CRM_JP_ContractPDFController.approvalDetail();
        test.stopTest();
    }
}