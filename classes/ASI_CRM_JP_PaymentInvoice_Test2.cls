/*********************************************************************************
 * Name:ASI_CRM_JP_PaymentInvoice_Test2
 * Description: Test Class for ASI CRM Payment Invoice CRM JP
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 5/1/2015         Laputa: Hank            Created
 * 1/01/2019        Wilken Lee				[WL 1.0] Increase code coverage
*********************************************************************************/
@isTest
private class ASI_CRM_JP_PaymentInvoice_Test2 {
    
    //Test for Class ASI_CRM_JP_Invoice_AssignApprover
    static testMethod void ASI_CRM_JP_Invoice_AssignApprover_Test(){
        UserRole role = new UserRole(name = 'TEST_ROLE', DeveloperName = 'TEST_ROLE');
        insert role;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //Manager
        User u0 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test00@laputa.com');
        insert u0;
        //Approvers 1-9
        List<User> userList = new List<User>();
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id, ManagerId = u0.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test01@laputa.com');
        userList.add(u1);
        User u2 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test02@laputa.com');
        userList.add(u2);
        User u3 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test03@laputa.com');
        userList.add(u3);
        User u4 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test04@laputa.com');
        userList.add(u4);
        User u5 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test05@laputa.com');
        userList.add(u5);
        User u6 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test06@laputa.com');
        userList.add(u6);
        User u7 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test07@laputa.com');
        userList.add(u7);
        User u8 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test08@laputa.com');
        userList.add(u8);
        User u9 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test09@laputa.com');
        userList.add(u9);
        insert userList;
        
        System.RunAs(u1){
            List<ASI_CRM_Route_Type__c> routeList  = new List<ASI_CRM_Route_Type__c>();
            ASI_CRM_Route_Type__c routeType = new ASI_CRM_Route_Type__c(ASI_CRM_Module__c = 'Payment Invoice', ASI_CRM_Module_Record_Type__c = 'SPTD FOC Invoice');
            routeList.add(routeType);
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
            insert ruleList;
            
            
            List<ASI_CRM_Role_Route_Type_Relationship__c> relationList = new List<ASI_CRM_Role_Route_Type_Relationship__c>();
            ASI_CRM_Role_Route_Type_Relationship__c relation1 = new ASI_CRM_Role_Route_Type_Relationship__c(Name = 'TEST_ROLE', ASI_CRM_Route_Type__c = routeType.Id);
            relationList.add(relation1);
            insert relationList;
            
            List<ASI_CRM_Payment_Invoice__c> invoiceList = new List<ASI_CRM_Payment_Invoice__c>();
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'INV{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            
            ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_SPTD_FOC_Invoice'));
            invoiceList.add(invoice1);
            insert invoiceList;
            
			test.startTest();
			
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
            insert ap;
            ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
            insert itemGroup;
            
            ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'));
            insert contract1;
            ASI_CRM_Purchase_Contract_Line_Item__c contractLine1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
            insert contractLine1;
            
            List<ASI_CRM_Payment_Invoice_Line_Item__c> lineItemList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
            ASI_CRM_Payment_Invoice_Line_Item__c line1 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_Cash_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id);
            lineItemList.add(line1);
			
			ASI_CRM_Payment_Invoice_Line_Item__c line2 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id); //WL 1.0			
			lineItemList.add(line2); //WL 1.0
            insert lineItemList;
            
			update line2; //WL 1.0
            
            test.stopTest();
        }
	}
		
	static testMethod void ASI_CRM_JP_Invoice_AssignApprover_Test2(){
        UserRole role = new UserRole(name = 'TEST_ROLE', DeveloperName = 'TEST_ROLE');
        insert role;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //Manager
        User u0 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test00@laputa.com');
        insert u0;
        //Approvers 1-9
        List<User> userList = new List<User>();
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = role.Id, ManagerId = u0.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test01@laputa.com');
        userList.add(u1);
        insert userList;
        
        System.RunAs(u1){
            List<ASI_CRM_Route_Type__c> routeList  = new List<ASI_CRM_Route_Type__c>();
            ASI_CRM_Route_Type__c routeType = new ASI_CRM_Route_Type__c(ASI_CRM_Module__c = 'Payment Invoice', ASI_CRM_Module_Record_Type__c = 'SPTD FOC Invoice');
            routeList.add(routeType);
            insert routeList;
            
            List<ASI_CRM_Route_Rule_Detail__c> ruleList = new List<ASI_CRM_Route_Rule_Detail__c>();
            ASI_CRM_Route_Rule_Detail__c rule1 = new ASI_CRM_Route_Rule_Detail__c(ASI_CRM_Threshold__c = 0, ASI_CRM_Approver__c = u1.Id, ASI_CRM_Route_Type__c = routeType.Id);
            ruleList.add(rule1);
            insert ruleList;
            
            
            List<ASI_CRM_Role_Route_Type_Relationship__c> relationList = new List<ASI_CRM_Role_Route_Type_Relationship__c>();
            ASI_CRM_Role_Route_Type_Relationship__c relation1 = new ASI_CRM_Role_Route_Type_Relationship__c(Name = 'TEST_ROLE', ASI_CRM_Route_Type__c = routeType.Id);
            relationList.add(relation1);
            insert relationList;
            
            List<ASI_CRM_Payment_Invoice__c> invoiceList = new List<ASI_CRM_Payment_Invoice__c>();
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_PaymentInvoice_Cash_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'INV{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            insert new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c = 'ASI_CRM_JP_Contract_No', ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 1, ASI_HK_CRM_Format__c = 'R{YY}{00000}', ASI_HK_CRM_Running_Number__c = 2);
            
            ASI_CRM_Payment_Invoice__c invoice1 = new ASI_CRM_Payment_Invoice__c(ASI_CRM_Delivery_Time__c = '0000-1200',ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice__cASI_CRM_JP_Cash_Invoice'));
            invoiceList.add(invoice1);
            insert invoiceList;
            
			test.startTest();
			
            ASI_MFM_AP_Code__c ap = new ASI_MFM_AP_Code__c(Name='testAP', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_AP_Code__cASI_CRM_JP_AP_Code'));
            insert ap;
            ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'Test', ASI_CRM_Lowest_1__c = 100, ASI_CRM_Lowest_2__c = 100, recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_JP_Item_Group'));
            insert itemGroup;
            
            ASI_CRM_Purchase_Contract__c contract1 = new ASI_CRM_Purchase_Contract__c(ownerId = u1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract__cASI_CRM_JP_SPTD_Contract'));
            insert contract1;
            ASI_CRM_Purchase_Contract_Line_Item__c contractLine1 = new ASI_CRM_Purchase_Contract_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Purchase_Contract_Line_Item__cASI_CRM_JP_SPTD_Contract_Line_Item'), ASI_CRM_Purchase_Contract__c = contract1.Id, ASI_CRM_Unit_Price__c  = 100, ASI_CRM_Quantity__c = 100, ASI_CRM_Item_Group__c = itemGroup.id, ASI_CRM_Payment_Method__c='Buyback w/o condition', ASI_CRM_AP_Code__c = ap.Id);
            insert contractLine1;
            
            List<ASI_CRM_Payment_Invoice_Line_Item__c> lineItemList = new List<ASI_CRM_Payment_Invoice_Line_Item__c>();
            ASI_CRM_Payment_Invoice_Line_Item__c line1 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_SPTD_Cash_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id);
            lineItemList.add(line1);
			
			ASI_CRM_Payment_Invoice_Line_Item__c line2 = new ASI_CRM_Payment_Invoice_Line_Item__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Payment_Invoice_Line_Item__cASI_CRM_JP_Indirect_Rebate_Invoice_Line_Item'), ASI_CRM_Payment_Invoice__c = invoice1.Id, ASI_CRM_Actual_Unit_Cost__c  = 100, ASI_CRM_Actual_Quantity__c  = 100, ASI_CRM_Purchase_Contract_Line_Item__c = contractLine1.Id); //WL 1.0			
			lineItemList.add(line2); //WL 1.0
            insert lineItemList;
            
			update line2; //WL 1.0
            
            test.stopTest();
        }
    }
	
}