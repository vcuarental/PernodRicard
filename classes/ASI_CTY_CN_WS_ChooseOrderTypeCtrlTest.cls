/*****************************************************************************************************************
 * Name: ASI_CTY_CN_WS_ChooseOrderTypeController
 * Test Class:  ASI_CTY_CN_WS_ChooseOrderTypeCtrlTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-10-21       jack yuan               created
 *****************************************************************************************************************/
@isTest
private class ASI_CTY_CN_WS_ChooseOrderTypeCtrlTest {

    @testSetup
    static void testDataPre() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr1 = new User(Alias = 'teamLea', Email='teamLeader@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='teamLeader', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = p1.Id, IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='testLeader@wholesaler.com',
                            CompanyName = 'Pernod Ricard China',  BypassTriggers__c = 'Autofollow_User_InsertUpdate');
        insert usr1;

        System.runAs(usr1) {
            Account acc = new Account(Name = 'TestAccount', 
                                      RecordtypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'),
                                      ASI_KOR_Addr_Region__c = 'Central Region',
                                      Regional_Manager__c = usr1.Id);
            insert acc;

            Contact con = new Contact(LastName = 'TestContact', 
                                    RecordtypeId = Global_RecordTypeCache.getRtId('ContactASI_CRM_CN_Wholesaler_Contact'),
                                    AccountId = acc.Id);
            insert con;

            Profile p2 = [SELECT Id FROM Profile WHERE Name='ASI_CTY_Wholesaler_CN_User'];//ASI_CTY_Wholesaler_CN_User
            User usr2 = new User(Alias = '经销商', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='经销商', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                                LocaleSidKey='zh_CN', ProfileId = p2.Id, ContactId = con.Id,IsActive = true,
                                TimeZoneSidKey='Asia/Shanghai', UserName='test1@wholesaler.com',BypassTriggers__c = 'Autofollow_User_InsertUpdate',
                                CompanyName = 'Pernod Ricard China');
            insert usr2;

            insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = usr2.Id);

            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;

            ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;

            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
            insert channel;
            
            ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
            insert subChannel;
            
            ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF');
            insert newChannel;

           


            ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'a', 
                                                                                                ASI_CRM_CN_Chi_Name__c = 'a', 
                                                                                                Name = 'TestCustomer',
                                                                                                ASI_CRM_CN_Commercial_Team__c = 'Premium', 
                                                                                                ASI_CRM_CN_Sub_Channel__c=subChannel.Id, 
                                                                                                ASI_CRM_CN_CCity__c=city.Id, 
                                                                                                ASI_CRM_Account__c = acc.Id,
                                                                                                ASI_CRM_CN_WS_Tier__c = 'T2',
                                                                                                ASI_CRM_CN_JDE_Code_Premium__c = '9500001',
                                                                                                ASI_CRM_CN_NewChannel__c = newChannel.Id,
                                                                                                RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'));

            insert customer;
            update customer;

            System.runAs(usr2) {
                System.debug(LoggingLevel.INFO, '*** usr2: ' + usr2);
                ASI_KOR_Sales_Order_Request__c order = new ASI_KOR_Sales_Order_Request__c();
                order.ASI_CRM_CN_Customer__c = customer.Id;
                order.ASI_KOR_Order_Status__c = 'Open';
                order.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder');

                insert order;
            }
         
        }
        

    }
    
    static testMethod void testChooseOrderType1() {
        Test.startTest();
        User usr = [SELECT Id, Contact.AccountId FROM User WHERE UserName = 'test1@wholesaler.com'];
        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_CN_Address__c,
                                                                        ASI_CRM_CN_Commercial_Team__c
                                                                  FROM ASI_CRM_AccountsAdditionalField__c];
        System.debug(LoggingLevel.INFO, '*** customers111: ' + customers);
        System.runAs(usr) {
            ASI_CTY_CN_WS_ChooseOrderTypeController.ContactInfo conInfo = new ASI_CTY_CN_WS_ChooseOrderTypeController.ContactInfo();
            conInfo.address = 'testAddress';
            conInfo.otherRequirement = 'test';
            conInfo.accountId = customers[0].Id;
            ASI_CTY_CN_WS_ChooseOrderTypeController.getContactInfo();
            ASI_CTY_CN_WS_ChooseOrderTypeController.saveSaleOrder(JSON.serialize(conInfo));
        }
        Test.stopTest();
    }

     static testMethod void testChooseOrderType2() {
        Test.startTest();
        User usr = [SELECT Id, Contact.AccountId FROM User WHERE UserName = 'test1@wholesaler.com'];
        ASI_KOR_Sales_Order_Request__c order = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c LIMIT 1];
        order.ASI_KOR_Order_Status__c = 'Approved';
        update order;
        List<ASI_CRM_AccountsAdditionalField__c> customers = [SELECT Name, ASI_CRM_Account__c, ASI_CRM_CN_Address__c,
                                                                        ASI_CRM_CN_Commercial_Team__c
                                                                  FROM ASI_CRM_AccountsAdditionalField__c];
        System.debug(LoggingLevel.INFO, '*** customers111: ' + customers);
        System.runAs(usr) {
            ASI_CTY_CN_WS_ChooseOrderTypeController.ContactInfo conInfo = new ASI_CTY_CN_WS_ChooseOrderTypeController.ContactInfo();
            conInfo.address = 'testAddress';
            conInfo.otherRequirement = 'test';
            conInfo.accountId = customers[0].Id;
            ASI_CTY_CN_WS_ChooseOrderTypeController.getContactInfo();
            ASI_CTY_CN_WS_ChooseOrderTypeController.saveSaleOrder(JSON.serialize(conInfo));
        }
        Test.stopTest();
    }


}