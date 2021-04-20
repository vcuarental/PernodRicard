/*********************************************************************************
 * Name:ASI_CRM_JP_PurchaseContract_Test2
 * Description: Test Class for Purchase Contract of JP CRM
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/1/2015       Laputa: Hank              Created
 * 2/4/2015       Laputa: Conrad            Add test method for Manage All Page for Contract
*********************************************************************************/
@isTest
private class ASI_CRM_JP_PurchaseContract_Test2 {
    //Test for ASI_CRM_JP_Contract_AssignApprover
    static testMethod void ASI_CRM_JP_Contract_AssignApprover_Test(){
        UserRole role = new UserRole(name = 'TEST_ROLE', DeveloperName = 'TEST_ROLE');
        insert role;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //Manager
        User u0 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test0@laputa.com');
        insert u0;
        //Approvers 1-9
        List<User> userList = new List<User>();
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id, ManagerId = u0.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test1@laputa.com');
        userList.add(u1);
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test2@laputa.com');
        userList.add(u2);
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test3@laputa.com');
        userList.add(u3);
        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test4@laputa.com');
        userList.add(u4);
        User u5 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test5@laputa.com');
        userList.add(u5);
        User u6 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test6@laputa.com');
        userList.add(u6);
        User u7 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test7@laputa.com');
        userList.add(u7);
        User u8 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test8@laputa.com');
        userList.add(u8);
        User u9 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test9@laputa.com');
        userList.add(u9);
        insert userList;
        
        System.RunAs(u1){
            List<ASI_CRM_Route_Type__c> routeList  = new List<ASI_CRM_Route_Type__c>();
            ASI_CRM_Route_Type__c routeType = new ASI_CRM_Route_Type__c(ASI_CRM_Module__c = 'Purchase Contract', ASI_CRM_Module_Record_Type__c = 'SPTD Contract');
            routeList.add(routeType);
            ASI_CRM_Route_Type__c routeType2 = new ASI_CRM_Route_Type__c(ASI_CRM_Module__c = 'Purchase Contract', ASI_CRM_Module_Record_Type__c = 'Direct Rebate Contract');
            routeList.add(routeType2);
            insert routeList;
        
            List<ASI_CRM_Route_Rule_Detail__c> ruleList = new List<ASI_CRM_Route_Rule_Detail__c>();
            ASI_CRM_Route_Rule_Detail__c rule1 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u1.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule1);
            ASI_CRM_Route_Rule_Detail__c rule2 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u2.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule2);
            ASI_CRM_Route_Rule_Detail__c rule3 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u3.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule3);
            ASI_CRM_Route_Rule_Detail__c rule4 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u4.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule4);
            ASI_CRM_Route_Rule_Detail__c rule5 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u5.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule5);
            ASI_CRM_Route_Rule_Detail__c rule6 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u6.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule6);
            ASI_CRM_Route_Rule_Detail__c rule7 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u7.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule7);
            ASI_CRM_Route_Rule_Detail__c rule8 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u8.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule8);
            ASI_CRM_Route_Rule_Detail__c rule9 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u9.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule9);
            ASI_CRM_Route_Rule_Detail__c rule10 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Lowest_Threshold__c = '1. (< Lowest 1)', ASI_CRM_Approver__c = u1.Id, ASI_CRM_Route_Type__c = routeType2.Id);
            ruleList.add(rule10);
            ASI_CRM_Route_Rule_Detail__c rule11 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Lowest_Threshold__c = '2. (>= Lowest1 & < Lowest 2)', ASI_CRM_Approver__c = u2.Id, ASI_CRM_Route_Type__c = routeType2.Id);
            ruleList.add(rule11);
            ASI_CRM_Route_Rule_Detail__c rule12 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Lowest_Threshold__c = '3. (>= Lowest 2)', ASI_CRM_Approver__c = u3.Id, ASI_CRM_Route_Type__c = routeType2.Id);
            ruleList.add(rule12);
            insert ruleList;
        
            List<ASI_CRM_Role_Route_Type_Relationship__c> relationList = new List<ASI_CRM_Role_Route_Type_Relationship__c>();
            ASI_CRM_Role_Route_Type_Relationship__c relation1 = new ASI_CRM_Role_Route_Type_Relationship__c(Name = 'TEST_ROLE', ASI_CRM_Route_Type__c = routeType.Id);
            relationList.add(relation1);
            ASI_CRM_Role_Route_Type_Relationship__c relation2 = new ASI_CRM_Role_Route_Type_Relationship__c(Name = 'TEST_ROLE', ASI_CRM_Route_Type__c = routeType2.Id);
            relationList.add(relation2);
            insert relationList;
            
            List<ASI_CRM_Purchase_Contract__c> contractList = new List<ASI_CRM_Purchase_Contract__c>();
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            date testDate = ASI_CRM_JP_TestClassHelper.createTestDate();
            ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addmonths(1));
            contractList.add(contract1);
            ASI_CRM_Purchase_Contract__c contract2 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_Direct_Rebate_Contract'), ASI_CRM_Start_Date__c = testDate, ASI_CRM_End_Date__c = testDate.addmonths(1) );
            contractList.add(contract2);
            insert contractList;
            
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
            insert ap;
            
            ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
            insert itemGroup;
            List<ASI_CRM_Purchase_Contract_Line_Item__c> lineItemList = new List<ASI_CRM_Purchase_Contract_Line_Item__c>();
            ASI_CRM_Purchase_Contract_Line_Item__c line1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Item_Group__c = itemGroup.Id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
            lineItemList.add(line1);
            ASI_CRM_Purchase_Contract_Line_Item__c line2 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract2.Id, ASI_CRM_Unit_Price__c  = 1000, ASI_CRM_Quantity__c = 100, ASI_CRM_Current_Direct_Rebate__c = 1000, ASI_CRM_Current_Indirect_Rebate__c = 1000, ASI_CRM_Item_Group__c = itemGroup.Id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
            lineItemList.add(line2);
            insert lineItemList;
        }
    }
}