@isTest
/**********************************************************************************
* Name : ASI_HK_CRM_SalesOrderTriggerTest
* Created : 
* Revision History:
* 1. 19/09/2017 - [WL 1.0] testErrStrToTime does not exist in ASI_HK_CRM_SalesOrderAdjustDeliveryDate class
* 2. 25/09/2018 - [WL 2.0] Add test data to cater validation that Stock Release function is available for Sales Admin only
**********************************************************************************/
public with sharing class ASI_HK_CRM_SalesOrderTriggerTest {
    
    private static ASI_HK_CRM_TestUtils.CommonData cmData;
    
    static {
        ASI_HK_CRM_TestUtils.initSOEssentialSettings();
        cmData = new ASI_HK_CRM_TestUtils.CommonData();
        ASI_HK_CRM_TestUtils.assignCreditAccountData(cmData, 3, 3);
        ASI_HK_CRM_TestUtils.assignSalesOrderData(cmData, 3, 3);
    }
    
    static testMethod void testMain() {
        Test.startTest();
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        update so;
        Test.stopTest();
        delete so;
        undelete so;
    }
    static testMethod void testSOItem() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='sa@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, ASI_Department__c ='Luxury',
                            TimeZoneSidKey='America/Los_Angeles', UserName='sa@testorg.com');
        insert usr;
        System.runAs(usr)
        {
            Account acc = new Account(name = 'PARK N SHOP ', 
                                      ASI_HK_CRM_Payment_Term_Code__c='070',
                                      ASI_HK_CRM_Payment_Term_Description__c = 'Open A/C 70 Days',
                                      recordTypeId =  Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet') );
            
            
            insert acc;
            
            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c( 
                name = 'PARK N SHOP ',
                ASI_CRM_Account__c =acc.Id , 
                recordTypeId =  Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet') );
            
            insert customer;
            ASI_HK_CRM_Sales_Order__c so2 = new ASI_HK_CRM_Sales_Order__c(
                recordTypeId =  Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order__cASI_HK_CRM_Sales_Order_Normal') ,
                ASI_HK_CRM_Customer_DA__c =  acc.ID,
                ASI_HK_CRM_Reason_PaymentMethodChange__c ='test',
                ASI_HK_CRM_Order_Date__c =  System.today()
            );
            insert so2;
            
            
        }
        Test.stopTest();
        
    }
    static testMethod void test_cancelItem() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='sa@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, ASI_Department__c ='Luxury',
                            TimeZoneSidKey='America/Los_Angeles', UserName='sa@testorg.com');
        insert usr;
        System.runAs(usr)
        {
            Account acc = new Account(name = 'PARK N SHOP ', 
                                      ASI_HK_CRM_Payment_Term_Code__c='070',
                                      ASI_HK_CRM_Payment_Term_Description__c = 'Open A/C 70 Days',
                                      recordTypeId =  Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet') );
            
            
            insert acc;
            
            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c( 
                name = 'PARK N SHOP ',
                ASI_CRM_Account__c =acc.Id , 
                recordTypeId =  Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet') );
            
            insert customer;
            
            ASI_HK_CRM_Sales_Order__c so = cmData.so;
            so.ASI_HK_CRM_Has_Cancelled_Line_Item__c = false;
            so.ownerId = usr.Id;
            so.ASI_HK_CRM_Customer_DA__c = acc.ID;
            so.ASI_HK_CRM_Payment_Method__c =  'SALESMAN';
            so.ASI_HK_CRM_Reason_PaymentMethodChange__c ='test';
            update so;
            
            so.ASI_HK_CRM_Payment_Method__c =  'N/A';
            update so;            
            
            list<ASI_HK_CRM_Sales_Order_Item__c> soItems = cmData.soDetailList;
            list<ASI_HK_CRM_Sales_Order_Item__c> soItemsUpdate = new  list<ASI_HK_CRM_Sales_Order_Item__c>();
            for (ASI_HK_CRM_Sales_Order_Item__c soItem : soItems)
            {
                soItem.ASI_HK_CRM_Cancel_Qty__c = 1;
                soItemsUpdate.add(soItem);
            }
            update soItemsUpdate;
        }
        Test.stopTest();
    }
    
    static testMethod void test_cancelItem_2() {
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='sa@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='sa@testorg.com');
        insert usr;
        System.runAs(usr)
        {
            ASI_HK_CRM_Sales_Order__c so = cmData.so;
            so.ASI_HK_CRM_Has_Cancelled_Line_Item__c = false;
            so.ASI_HK_CRM_Order_Status_Name__c = 'Draft';
            so.ASI_HK_CRM_Urgent_Order_Confirmed__c ='Yes';
            so.ASI_HK_CRM_Urgent_Order__c = true;
            so.ownerId = usr.Id;
            update so;
            list<ASI_HK_CRM_Sales_Order_Item__c> soItems = cmData.soDetailList;
            list<ASI_HK_CRM_Sales_Order_Item__c> soItemsUpdate = new  list<ASI_HK_CRM_Sales_Order_Item__c>();
            for (ASI_HK_CRM_Sales_Order_Item__c soItem : soItems)
            {
                soItem.ASI_HK_CRM_Cancel_Qty__c = 1;
                soItemsUpdate.add(soItem);
            }
            update soItemsUpdate;
        }
        Test.stopTest();
    }
    
    static testMethod void testValidator() {
        Test.startTest();
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Order_Status_Name__c = 'Draft';
        so.ASI_HK_CRM_Urgent_Order_Confirmed__c = 'Yes'; 
        so.ASI_HK_CRM_Urgent_Order__c = true;
        try{ update so;}
        catch(exception e){}
        so.ASI_HK_CRM_Order_Status_Name__c = 'SA Approved';
        so.ASI_HK_CRM_Urgent_Order_Confirmed__c = 'No'; 
        so.ASI_HK_CRM_Urgent_Order__c = true;
        try{ update so;} 
        catch(exception e){}
        Test.stopTest();
    }    
    
    static testMethod void testDataManipulation() {
        Test.startTest();
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Delivery_Window_Instruction__c = 'Before';
        so.ASI_HK_CRM_Delivery_Time_1__c = '08:00';
        so.ASI_HK_CRM_Payment_Method__c = 'CASH';
        so.ASI_HK_CRM_Reason_PaymentMethodChange__c = 'TEST';
        update so;
        
        so.ASI_HK_CRM_Delivery_Window_Instruction__c = 'Between';
        update so;
        
        so.ASI_HK_CRM_Delivery_Time_1__c = '12:00';
        update so;
        
        so.ASI_HK_CRM_Delivery_Window_Instruction__c = 'Before';
        so.ASI_HK_CRM_Delivery_Time_1__c = '08:00';
        so.ASI_HK_CRM_Payment_Method__c = 'N/A';
        update so;
        
        Test.stopTest();
    }
    static testMethod void testDataManipulation2() {
        Test.startTest();
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Delivery_Window_Instruction__c = 'Between';
        so.ASI_HK_CRM_Delivery_Time_1__c = '08:00';
        so.ASI_HK_CRM_Delivery_Time_2__c = '09:00';
        so.ASI_HK_CRM_Payment_Method__c = 'N/A';
        update so;
        
        ASI_HK_CRM_AccountGenerator accGen = new ASI_HK_CRM_AccountGenerator();
        Account acc_Potential = accGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_POTENTIAL);
        insert acc_Potential;
        so.ASI_HK_CRM_Account_PA__c = acc_Potential.id;
        update so;
        
        so.ASI_HK_CRM_Delivery_Time_2__c = null;
        update so;
        
        
        Test.stopTest();        
    }
    
    static testMethod void testUrgentOrder() {
        Test.startTest();
        
        ASI_HK_CRM_Sales_Order__c so = cmData.so;
        so.ASI_HK_CRM_Urgent_Order__c = true;
        //update so;
        
        Test.stopTest();
    }
    
    static testMethod void testApproverAssign() {
        final String holdCode = 'Test';
        
        ASI_HK_CRM_Sales_Order__c so = [SELECT Id, Name FROM ASI_HK_CRM_Sales_Order__c WHERE Id = :cmData.so.Id];
        
        ASI_HK_CRM_RoutingTableGenerator rTableGen = new ASI_HK_CRM_RoutingTableGenerator();
        ASI_HK_CRM_SO_Routing_Table_Header__c rTableHeader = rTableGen.generateRoutingTableHeader();
        rTableHeader.Name = 'Test1';
        rTableHeader.ASI_HK_CRM_Field_API_Name_1__c = 'ASI_HK_CRM_Credit_Hold_Reason__c';
        rTableHeader.ASI_HK_CRM_Value_1__c = holdCode;
        insert rTableHeader;
        
        ASI_HK_CRM_SO_Routing_Table_Detail__c rTableDetail1 = rTableGen.generateRoutingTableDetail(rTableHeader, ASI_HK_CRM_RoutingTableGenerator.RT_DetailSpecificUser);
        rTableDetail1.ASI_HK_CRM_Approver_No__c = 1;
        String roleId = UserInfo.getUserRoleId();
        if (!String.isBlank(roleId)) {
            List<UserRole> uRole = [SELECT Id, DeveloperName FROM UserRole WHERE Id = :roleId];
            if (uRole.size() > 0)
                rTableDetail1.ASI_HK_CRM_Approver_Role_Name__c = uRole.get(0).DeveloperName;
        }
        rTableDetail1.ASI_HK_CRM_Approver__c = UserInfo.getUserId();
        rTableDetail1.ASI_HK_CRM_Jump_to_New_User__c = true;
        rTableDetail1.ASI_HK_CRM_Field_API_Name_1__c = 'Name';
        rTableDetail1.ASI_HK_CRM_Value_1__c = so.Name;
        
        ASI_HK_CRM_SO_Routing_Table_Detail__c rTableDetail2 = rTableGen.generateRoutingTableDetail(rTableHeader, ASI_HK_CRM_RoutingTableGenerator.RT_DetailUserField);
        rTableDetail2.ASI_HK_CRM_Approver_No__c = 2;
        rTableDetail2.ASI_HK_CRM_User_Field__c = 'ManagerId';
        rTableDetail2.ASI_HK_CRM_Field_API_Name_1__c = 'ASI_HK_CRM_User_D_O__c';
        rTableDetail2.ASI_HK_CRM_Value_1__c = '1';
        
        insert new ASI_HK_CRM_SO_Routing_Table_Detail__c[] {rTableDetail1, rTableDetail2};
            
            Test.startTest();
        
        so.ASI_HK_CRM_Credit_Hold_Reason__c = holdCode;
        so.ASI_HK_CRM_User_D_O__c = true;
        update so;
        
        Test.stopTest();
    }
    
    
    static testMethod void test_errorDelivery(){
        Test.startTest();
        try{
            ASI_HK_CRM_SalesOrderAdjustDeliveryDate soAdd = new ASI_HK_CRM_SalesOrderAdjustDeliveryDate();
            /*[WL 1.0 BEGIN]*/
            //soAdd.testErrStrToTime();
            /*[WL 1.0 END]*/
        }
        catch(exception e){}
        Test.stopTest();
        
    }  
    
    static testMethod void test_StockRelease(){
        Test.startTest();
        List<User> userList = new List<User>();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User usr = new User(Alias = 'standt', Email='sa@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='sa@testorg.com');
        userList.add(usr);
        
        /*[WL 2.0] BEGIN*/
        User user2 = new User(Alias = 'standt', Email='sa@testorg.com', 
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p.Id, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='sa2@testorg.com');
        userList.add(user2);
        
        insert userList;
        
        System.runAs(user2)
        {
            PermissionSet pSet = [select Id from PermissionSet where Name = 'ASI_CRM_HK_SA_Add_on' limit 1];
            
            PermissionSetAssignment pSetAssignment = new PermissionSetAssignment();
            pSetAssignment.AssigneeId = usr.Id;
            pSetAssignment.PermissionSetId = pSet.Id;
            insert pSetAssignment;
        }
        /*[WL 2.0] END*/
        
        System.runAs(usr)
        {
            ASI_HK_CRM_Sales_Order__c so = cmData.so;
            so.ASI_HK_CRM_Has_Cancelled_Line_Item__c = false;
            so.ownerId = usr.Id;
            update so;
            list<ASI_HK_CRM_Sales_Order_Item__c> soItems = cmData.soDetailList;
            list<ASI_HK_CRM_Sales_Order_Item__c> soItemsUpdate = new  list<ASI_HK_CRM_Sales_Order_Item__c>();
            for (ASI_HK_CRM_Sales_Order_Item__c soItem : soItems)
            {
                soItem.ASI_HK_CRM_Reserve_Stock_No__c = 'Testing1234';
                soItemsUpdate.add(soItem);
            }
            update soItemsUpdate;
            
            for (ASI_HK_CRM_Sales_Order_Item__c soItem : soItemsUpdate)
            {
                soItem.ASI_HK_CRM_Reserve_Stock_No__c = '';
                soItem.ASI_CRM_Request_Release_Qty__c = null; //[WL 2.0]
            }
            update soItemsUpdate;
            
            for (ASI_HK_CRM_Sales_Order_Item__c soItem : soItemsUpdate)
            {
                soItem.ASI_HK_CRM_Reserve_Stock_No__c = 'Testing5678';
            }
            update soItemsUpdate;
            
            for (ASI_HK_CRM_Sales_Order_Item__c soItem : soItemsUpdate)
            {
                soItem.ASI_HK_CRM_Stock_Reserve_Status__c = 'Stock Released';
            }
            update soItemsUpdate;
        }
        Test.stopTest();
    }
   
    
}