/*********************************************************************************
 * Name:ASI_CRM_JP_PurchaseContract_Test3
 * Description: Test Class for Purchase Contract of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/1/2015       Laputa: Hank              Created
 * 2/4/2015       Laputa: Conrad            Add test method for Manage All Page for Contract
*********************************************************************************/
@isTest
private class ASI_CRM_JP_PurchaseContract_Test3 {
    //Test for Class ASI_CRM_JP_ContractClone (96%)
    static testMethod void ASI_CRM_JP_ContractClone_Test(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addMonths(3));
        insert contract1;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
        insert ap;
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
       	insert itemGroup;
        
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
        insert line1;
        ASI_CRM_Purchase_Contract__c contract2 = new ASI_CRM_Purchase_Contract__c(ASI_CRM_Clone_Id__c = contract1.Id ,ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addMonths(4));
        insert contract2;
        contract2.ASI_CRM_End_Date__c = testDate.addMonths(2);
        update contract2;
        test.startTest();
        PageReference pageRef = Page.ASI_CRM_JP_SetContractDraftPage;
        pageRef.getParameters().put('Id', contract2.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(contract2);
        ASI_CRM_JP_SetContractDraftController controller = new ASI_CRM_JP_SetContractDraftController(sc);
        controller.save();
        test.stopTest();
    }
    
    static testMethod void ASI_CRM_JP_Contract_ManageAll(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        insert u1;
        insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
        date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
        ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addMonths(3));
        insert contract1;
        
        ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
        insert ap;
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
       	insert itemGroup;
        
        ASI_CRM_Purchase_Contract_Line_Item__c line1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Target_Volume__c = 10000, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
        insert line1;
        
        test.startTest();
        PageReference pageRef = Page.ASI_CRM_JP_ManageAll_ContractPage;
        pageRef.getParameters().put('Id', contract1.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(contract1);
        ASI_CRM_JP_ManageAll_ContractController controller = new ASI_CRM_JP_ManageAll_ContractController(sc);
        
        controller.saveContract();
        controller.addContractLine();
        controller.addContractLine();
        controller.addContractLine();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_SOURCE_ITEM_ID', (String)line1.id);
        controller.cloneContractLine();
        System.currentPageReference().getParameters().put('PARAM_CONTRACT_LINE_ID', (String)line1.id);
        controller.removeContractLine();
        controller.cancel();
        
        test.stopTest();
    }
    
}