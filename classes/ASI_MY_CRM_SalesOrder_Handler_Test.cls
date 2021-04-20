@isTest
public class ASI_MY_CRM_SalesOrder_Handler_Test {
	
    static testMethod void Without_Credit_Hold_Test() {
        
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        System.runAs(userA){
            Test.startTest();
            
            Profile p = [SELECT Id FROM Profile WHERE Name='ASI MY Standard User'];
            
            List<User> l_User = new List<User>();
            User manager5 = new User();
            manager5.Alias = 'standt';
            manager5.Email='standarduser6@introv.com';
            manager5.EmailEncodingKey='UTF-8'; 
            manager5.LastName='Testing';
            manager5.LanguageLocaleKey='en_US';
            manager5.LocaleSidKey='en_US';
            manager5.ProfileId = p.Id;
            manager5.TimeZoneSidKey='America/Los_Angeles';
            manager5.UserName='standarduser6@introv.com';
            insert manager5;
            
            User manager4 = new User();
            manager4.Alias = 'standt';
            manager4.Email='standarduser5@introv.com';
            manager4.EmailEncodingKey='UTF-8'; 
            manager4.LastName='Testing';
            manager4.LanguageLocaleKey='en_US';
            manager4.LocaleSidKey='en_US';
            manager4.ProfileId = p.Id;
            manager4.ManagerId = manager5.Id;
            manager4.TimeZoneSidKey='America/Los_Angeles';
            manager4.UserName='standarduser5@introv.com';
            insert manager4;
            
            User manager3 = new User();
            manager3.Alias = 'standt';
            manager3.Email='standarduser4@introv.com';
            manager3.EmailEncodingKey='UTF-8'; 
            manager3.LastName='Testing';
            manager3.LanguageLocaleKey='en_US';
            manager3.LocaleSidKey='en_US';
            manager3.ProfileId = p.Id;
            manager3.ManagerId = manager4.Id;
            manager3.TimeZoneSidKey='America/Los_Angeles';
            manager3.UserName='standarduser4@introv.com';
            insert manager3;
            
            User manager2 = new User();
            manager2.Alias = 'standt';
            manager2.Email='standarduser1@introv.com';
            manager2.EmailEncodingKey='UTF-8'; 
            manager2.LastName='Testing';
            manager2.LanguageLocaleKey='en_US';
            manager2.LocaleSidKey='en_US';
            manager2.ProfileId = p.Id;
            manager2.ManagerId = manager3.Id;
            manager2.TimeZoneSidKey='America/Los_Angeles';
            manager2.UserName='standarduser1@introv.com';
            insert manager2;
            
            User manager1 = new User();
            manager1.Alias = 'standt';
            manager1.Email='standarduser2@introv.com';
            manager1.EmailEncodingKey='UTF-8'; 
            manager1.LastName='Testing';
            manager1.LanguageLocaleKey='en_US';
            manager1.LocaleSidKey='en_US';
            manager1.ProfileId = p.Id;
            manager1.ManagerId = manager2.Id;
            manager1.TimeZoneSidKey='America/Los_Angeles';
            manager1.UserName='standarduser2@introv.com';
            insert manager1;
            
            User user1 = new User();
            user1.Alias = 'standt';
            user1.Email='standarduser3@introv.com';
            user1.EmailEncodingKey='UTF-8'; 
            user1.LastName='Testing';
            user1.LanguageLocaleKey='en_US';
            user1.LocaleSidKey='en_US';
            user1.ProfileId = p.Id;
            user1.ManagerId = manager1.Id;
            user1.TimeZoneSidKey='America/Los_Angeles';
            user1.UserName='standarduser3@introv.com';
            insert user1;
            
            
            ASI_CRM_Fix_Approval_Route__c fix_approval_route = new ASI_CRM_Fix_Approval_Route__c();
            fix_approval_route.ASI_CRM_CN_Type__c = 'Sales Order - Without Credit Hold';
            fix_approval_route.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Fix_Approval_Route__cASI_CRM_MY_Fix_Approval_Route');
            fix_approval_route.ASI_CRM_CN_Approver_1__c = user1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_2__c = manager1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_2__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_3__c = manager2.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_3__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_4__c = manager3.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_4__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_5__c = manager4.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_5__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_6__c = manager5.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_6__c = 0;
            insert fix_approval_route;
                        
            
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
            
            List<ASI_CRM_MY_Order_Type_Mapping__c> l_insert_order_type_mapping = new List<ASI_CRM_MY_Order_Type_Mapping__c>();
            ASI_CRM_MY_Order_Type_Mapping__c order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-I8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = '	Credit Note-J8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-K8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = '';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-M8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-P8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-SD';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SD';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-I7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-J7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-K7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-M7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-P7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-SC';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SC';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-I6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-J6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-K6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-M6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-SH';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SH';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-I5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-J5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-K5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-M5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-P5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-SG';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SG';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-I3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-J3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = '';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-K3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-M3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-P3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-SB';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SB';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-I2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-J2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-K2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-M2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-P2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-SA';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SA';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            insert l_insert_order_type_mapping;
            
        	ASI_HK_CRM_Sales_Order__c sales_order = new ASI_HK_CRM_Sales_Order__c();
            sales_order.ASI_HK_CRM_Order_Date__c = system.today();
            sales_order.ASI_HK_CRM_JDE_Order_No__c = '85058456';
            sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c = 'SA';
            sales_order.ASI_CRM_Sold_To__c = customer1.Id;
            sales_order.ASI_CRM_Ship_To__c = customer1.Id;
            sales_order.OwnerId = user1.Id;
            sales_order.ASI_CRM_Order_Gross_Amount__c = 1000;
            sales_order.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order__cASI_MY_CRM_Sales_Order');
            insert sales_order;
            

			ASI_MFM_SKU_Code__c sku = ASI_CRM_MY_TestClassHelper.createSKU('Testing');  
            ASI_MFM_Sub_brand__c sub_brand = [SELECT Id FROM ASI_MFM_Sub_brand__c LIMIT 1];
            
            ASI_HK_CRM_Sales_Order_Item__c sales_order_item = new ASI_HK_CRM_Sales_Order_Item__c();
            sales_order_item.ASI_HK_CRM_Sales_Order__c = sales_order.Id;
            sales_order_item.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_Item__cASI_MY_CRM_Sales_Order_Item');
            sales_order_item.CurrencyIsoCode = 'MYR';
            sales_order_item.ASI_HK_CRM_Price__c = 1000;
            sales_order_item.ASI_HK_CRM_Quantity__c = 12;
            sales_order_item.ASI_CRM_Extended_Price__c = 1000;
            sales_order_item.ASI_HK_CRM_UOM__c = 'BT';
            sales_order_item.ASI_CRM_Pricing_UOM__c = 'CT';
            sales_order_item.ASI_CRM_Last_Status__c = '530';
            sales_order_item.ASI_HK_CRM_SKU__c = sku.Id;
            sales_order_item.ASI_CRM_Sub_Brand__c = sub_brand.Id;
            insert sales_order_item;
            update sales_order_item;
            update sales_order;
            
            sales_order.ASI_CRM_ETL_Completed__c = true;
            update sales_order;
            
            Test.stopTest();
        }
        
    }
    
    static testMethod void With_Credit_Hold_Test() {
        
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        System.runAs(userA){
            Test.startTest();
            
            Profile p = [SELECT Id FROM Profile WHERE Name='ASI MY Standard User'];
            
            List<User> l_User = new List<User>();
            User manager5 = new User();
            manager5.Alias = 'standt';
            manager5.Email='standarduser6@introv.com';
            manager5.EmailEncodingKey='UTF-8'; 
            manager5.LastName='Testing';
            manager5.LanguageLocaleKey='en_US';
            manager5.LocaleSidKey='en_US';
            manager5.ProfileId = p.Id;
            manager5.TimeZoneSidKey='America/Los_Angeles';
            manager5.UserName='standarduser6@introv.com';
            insert manager5;
            
            User manager4 = new User();
            manager4.Alias = 'standt';
            manager4.Email='standarduser5@introv.com';
            manager4.EmailEncodingKey='UTF-8'; 
            manager4.LastName='Testing';
            manager4.LanguageLocaleKey='en_US';
            manager4.LocaleSidKey='en_US';
            manager4.ProfileId = p.Id;
            manager4.ManagerId = manager5.Id;
            manager4.TimeZoneSidKey='America/Los_Angeles';
            manager4.UserName='standarduser5@introv.com';
            insert manager4;
            
            User manager3 = new User();
            manager3.Alias = 'standt';
            manager3.Email='standarduser4@introv.com';
            manager3.EmailEncodingKey='UTF-8'; 
            manager3.LastName='Testing';
            manager3.LanguageLocaleKey='en_US';
            manager3.LocaleSidKey='en_US';
            manager3.ProfileId = p.Id;
            manager3.ManagerId = manager4.Id;
            manager3.TimeZoneSidKey='America/Los_Angeles';
            manager3.UserName='standarduser4@introv.com';
            insert manager3;
            
            User manager2 = new User();
            manager2.Alias = 'standt';
            manager2.Email='standarduser1@introv.com';
            manager2.EmailEncodingKey='UTF-8'; 
            manager2.LastName='Testing';
            manager2.LanguageLocaleKey='en_US';
            manager2.LocaleSidKey='en_US';
            manager2.ProfileId = p.Id;
            manager2.ManagerId = manager3.Id;
            manager2.TimeZoneSidKey='America/Los_Angeles';
            manager2.UserName='standarduser1@introv.com';
            insert manager2;
            
            User manager1 = new User();
            manager1.Alias = 'standt';
            manager1.Email='standarduser2@introv.com';
            manager1.EmailEncodingKey='UTF-8'; 
            manager1.LastName='Testing';
            manager1.LanguageLocaleKey='en_US';
            manager1.LocaleSidKey='en_US';
            manager1.ProfileId = p.Id;
            manager1.ManagerId = manager2.Id;
            manager1.TimeZoneSidKey='America/Los_Angeles';
            manager1.UserName='standarduser2@introv.com';
            insert manager1;
            
            User user1 = new User();
            user1.Alias = 'standt';
            user1.Email='standarduser3@introv.com';
            user1.EmailEncodingKey='UTF-8'; 
            user1.LastName='Testing';
            user1.LanguageLocaleKey='en_US';
            user1.LocaleSidKey='en_US';
            user1.ProfileId = p.Id;
            user1.ManagerId = manager1.Id;
            user1.TimeZoneSidKey='America/Los_Angeles';
            user1.UserName='standarduser3@introv.com';
            insert user1;
            
            ASI_MFM_SKU_Code__c sku = ASI_CRM_MY_TestClassHelper.createSKU('Testing');  
            ASI_MFM_Sub_brand__c sub_brand = [SELECT Id, ASI_MFM_Sub_brand_Description__c FROM ASI_MFM_Sub_brand__c LIMIT 1];
            sub_brand.ASI_MFM_Sub_brand_Description__c = 'MARTELL CORDON BLEU';
            update sub_brand;
            //system.debug('@@@sub_brand: '+sub_brand);
            
            List<ASI_CRM_Fix_Approval_Route__c> l_fix_approval_route = new List<ASI_CRM_Fix_Approval_Route__c>();
            ASI_CRM_Fix_Approval_Route__c fix_approval_route = new ASI_CRM_Fix_Approval_Route__c();
            fix_approval_route.ASI_CRM_CN_Type__c = 'Sales Order - With Credit Hold';
            fix_approval_route.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Fix_Approval_Route__cASI_CRM_MY_Fix_Approval_Route');
            fix_approval_route.ASI_CRM_CN_Approver_1__c = user1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_2__c = manager1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_2__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_3__c = manager2.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_3__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_4__c = manager3.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_4__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_5__c = manager4.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_5__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_6__c = manager5.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_6__c = 0;
			l_fix_approval_route.add(fix_approval_route);
            
            fix_approval_route = new ASI_CRM_Fix_Approval_Route__c();
            fix_approval_route.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Fix_Approval_Route__cASI_CRM_MY_Sub_Brand_Type_Fix_Approval_Route');
            fix_approval_route.ASI_CRM_MY_Sub_Brand__c  = sub_brand.Id;
            fix_approval_route.ASI_CRM_CN_Approver_1__c = user1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_2__c = manager1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_2__c = 0;
            l_fix_approval_route.add(fix_approval_route);
            
            insert l_fix_approval_route;
                        
            
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
            
            List<ASI_CRM_MY_Order_Type_Mapping__c> l_insert_order_type_mapping = new List<ASI_CRM_MY_Order_Type_Mapping__c>();
            ASI_CRM_MY_Order_Type_Mapping__c order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-I8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = '	Credit Note-J8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-K8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = '';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-M8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-P8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-SD';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SD';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-I7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-J7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-K7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-M7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-P7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-SC';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SC';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-I6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-J6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-K6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-M6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-SH';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SH';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-I5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-J5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-K5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-M5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-P5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-SG';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SG';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-I3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-J3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = '';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-K3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-M3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-P3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-SB';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SB';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-I2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-J2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-K2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-M2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-P2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-SA';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SA';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            insert l_insert_order_type_mapping;
            
        	ASI_HK_CRM_Sales_Order__c sales_order = new ASI_HK_CRM_Sales_Order__c();
            sales_order.ASI_HK_CRM_Order_Date__c = system.today();
            sales_order.ASI_HK_CRM_JDE_Order_No__c = '85058456';
            sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c = 'SA';
            sales_order.ASI_CRM_Sold_To__c = customer1.Id;
            sales_order.ASI_CRM_Ship_To__c = customer1.Id;
            sales_order.OwnerId = user1.Id;
            sales_order.ASI_CRM_Hold_Code__c = 'C1';
            sales_order.ASI_CRM_Order_Gross_Amount__c = 1000;
            sales_order.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order__cASI_MY_CRM_Sales_Order');
            insert sales_order;
            
            Attachment attach=new Attachment();   	
            attach.Name='Unit Test Attachment';
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
            attach.body=bodyBlob;
            attach.parentId=sales_order.id;
            insert attach;
			
            
            List<ASI_HK_CRM_Sales_Order_Item__c> l_soi = new List<ASI_HK_CRM_Sales_Order_Item__c>();
            ASI_HK_CRM_Sales_Order_Item__c sales_order_item = new ASI_HK_CRM_Sales_Order_Item__c();
            sales_order_item.ASI_HK_CRM_Sales_Order__c = sales_order.Id;
            sales_order_item.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_Item__cASI_MY_CRM_Sales_Order_Item');
            sales_order_item.CurrencyIsoCode = 'MYR';
            sales_order_item.ASI_HK_CRM_Price__c = 1000;
            sales_order_item.ASI_HK_CRM_Quantity__c = 12;
            sales_order_item.ASI_CRM_Extended_Price__c = 1000;
            sales_order_item.ASI_HK_CRM_UOM__c = 'BT';
            sales_order_item.ASI_CRM_Pricing_UOM__c = 'CT';
            sales_order_item.ASI_CRM_Last_Status__c = '530';
            sales_order_item.ASI_HK_CRM_SKU__c = sku.Id;
            sales_order_item.ASI_CRM_Sub_Brand__c = sub_brand.Id;
            l_soi.add(sales_order_item);
            
            sales_order_item = new ASI_HK_CRM_Sales_Order_Item__c();
            sales_order_item.ASI_HK_CRM_Sales_Order__c = sales_order.Id;
            sales_order_item.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_Item__cASI_MY_CRM_Sales_Order_Item');
            sales_order_item.CurrencyIsoCode = 'MYR';
            sales_order_item.ASI_HK_CRM_Price__c = 0;
            sales_order_item.ASI_HK_CRM_Quantity__c = 3;
            sales_order_item.ASI_CRM_Extended_Price__c = 0;
            sales_order_item.ASI_HK_CRM_UOM__c = 'BT';
            sales_order_item.ASI_CRM_Pricing_UOM__c = 'CT';
            sales_order_item.ASI_CRM_Last_Status__c = '530';
            sales_order_item.ASI_HK_CRM_SKU__c = sku.Id;
            sales_order_item.ASI_CRM_Sub_Brand__c = sub_brand.Id;
            
            l_soi.add(sales_order_item);
            insert l_soi;
            
            List<ASI_HK_CRM_Sales_Order_Item__c> l_type_soi = [SELECT ASI_CRM_System_Item_Type__c, ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Description__c 
                                                               FROM ASI_HK_CRM_Sales_Order_Item__c];
            
            for(ASI_HK_CRM_Sales_Order_Item__c soi : l_type_soi){
                system.debug('@@@soi: '+soi.ASI_CRM_System_Item_Type__c );
                system.debug('@@@soi: '+soi.ASI_CRM_Sub_Brand__r.ASI_MFM_Sub_brand_Description__c );
            }
            
            update sales_order;
            
            sales_order.ASI_CRM_ETL_Completed__c = true;
            update sales_order;
            
            Test.stopTest();
        }
        
    }
    
    static testMethod void FOC_Test() {
        
        User userA = ASI_CRM_MY_TestClassHelper.createUser();
        System.runAs(userA){
            Test.startTest();
            
            Profile p = [SELECT Id FROM Profile WHERE Name='ASI MY Standard User'];
            
            List<User> l_User = new List<User>();
            User manager5 = new User();
            manager5.Alias = 'standt';
            manager5.Email='standarduser6@introv.com';
            manager5.EmailEncodingKey='UTF-8'; 
            manager5.LastName='Testing';
            manager5.LanguageLocaleKey='en_US';
            manager5.LocaleSidKey='en_US';
            manager5.ProfileId = p.Id;
            manager5.TimeZoneSidKey='America/Los_Angeles';
            manager5.UserName='standarduser6@introv.com';
            insert manager5;
            
            User manager4 = new User();
            manager4.Alias = 'standt';
            manager4.Email='standarduser5@introv.com';
            manager4.EmailEncodingKey='UTF-8'; 
            manager4.LastName='Testing';
            manager4.LanguageLocaleKey='en_US';
            manager4.LocaleSidKey='en_US';
            manager4.ProfileId = p.Id;
            manager4.ManagerId = manager5.Id;
            manager4.TimeZoneSidKey='America/Los_Angeles';
            manager4.UserName='standarduser5@introv.com';
            insert manager4;
            
            User manager3 = new User();
            manager3.Alias = 'standt';
            manager3.Email='standarduser4@introv.com';
            manager3.EmailEncodingKey='UTF-8'; 
            manager3.LastName='Testing';
            manager3.LanguageLocaleKey='en_US';
            manager3.LocaleSidKey='en_US';
            manager3.ProfileId = p.Id;
            manager3.ManagerId = manager4.Id;
            manager3.TimeZoneSidKey='America/Los_Angeles';
            manager3.UserName='standarduser4@introv.com';
            insert manager3;
            
            User manager2 = new User();
            manager2.Alias = 'standt';
            manager2.Email='standarduser1@introv.com';
            manager2.EmailEncodingKey='UTF-8'; 
            manager2.LastName='Testing';
            manager2.LanguageLocaleKey='en_US';
            manager2.LocaleSidKey='en_US';
            manager2.ProfileId = p.Id;
            manager2.ManagerId = manager3.Id;
            manager2.TimeZoneSidKey='America/Los_Angeles';
            manager2.UserName='standarduser1@introv.com';
            insert manager2;
            
            User manager1 = new User();
            manager1.Alias = 'standt';
            manager1.Email='standarduser2@introv.com';
            manager1.EmailEncodingKey='UTF-8'; 
            manager1.LastName='Testing';
            manager1.LanguageLocaleKey='en_US';
            manager1.LocaleSidKey='en_US';
            manager1.ProfileId = p.Id;
            manager1.ManagerId = manager2.Id;
            manager1.TimeZoneSidKey='America/Los_Angeles';
            manager1.UserName='standarduser2@introv.com';
            insert manager1;
            
            User user1 = new User();
            user1.Alias = 'standt';
            user1.Email='standarduser3@introv.com';
            user1.EmailEncodingKey='UTF-8'; 
            user1.LastName='Testing';
            user1.LanguageLocaleKey='en_US';
            user1.LocaleSidKey='en_US';
            user1.ProfileId = p.Id;
            user1.ManagerId = manager1.Id;
            user1.TimeZoneSidKey='America/Los_Angeles';
            user1.UserName='standarduser3@introv.com';
            insert user1;
            
            
            ASI_CRM_Fix_Approval_Route__c fix_approval_route = new ASI_CRM_Fix_Approval_Route__c();
            fix_approval_route.ASI_CRM_CN_Type__c = 'FOC';
            fix_approval_route.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Fix_Approval_Route__cASI_CRM_MY_Fix_Approval_Route');
            fix_approval_route.ASI_CRM_CN_Approver_1__c = user1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_1__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_2__c = manager1.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_2__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_3__c = manager2.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_3__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_4__c = manager3.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_4__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_5__c = manager4.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_5__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_6__c = manager5.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_6__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_7__c = manager5.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_7__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_8__c = manager5.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_8__c = 0;
            fix_approval_route.ASI_CRM_CN_Approver_9__c = manager5.Id;
            fix_approval_route.ASI_CRM_CN_Approval_Limit_9__c = 0;
            insert fix_approval_route;
                        
            
            ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
            
            List<ASI_CRM_MY_Order_Type_Mapping__c> l_insert_order_type_mapping = new List<ASI_CRM_MY_Order_Type_Mapping__c>();
            ASI_CRM_MY_Order_Type_Mapping__c order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-I8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = '	Credit Note-J8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-K8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = '';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-M8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-P8';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P8';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Credit Note-SD';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Credit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SD';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-I7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-J7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-K7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-M7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-P7';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P7';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Debit Note-SC';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Debit Note';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SC';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-I6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-J6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-K6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-M6';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M6';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC Return-SH';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SH';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-I5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-J5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-K5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-M5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-P5';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P5';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'FOC-SG';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'FOC';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SG';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-I3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-J3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = '';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-K3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-M3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-P3';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P3';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order Return-SB';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order Return';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SB';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-I2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'I2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-J2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'J2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-K2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'K2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-M2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'M2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-P2';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'P2';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            order_type_mapping = new ASI_CRM_MY_Order_Type_Mapping__c();
            order_type_mapping.Name = 'Sales Order-SA';
            order_type_mapping.ASI_CRM_MY_Order_Type__c  = 'Sales Order';
            order_type_mapping.ASI_CRM_MY_Order_Type_Code__c = 'SA';
            l_insert_order_type_mapping.add(order_type_mapping);
            
            insert l_insert_order_type_mapping;
            
        	ASI_HK_CRM_Sales_Order__c sales_order = new ASI_HK_CRM_Sales_Order__c();
            sales_order.ASI_HK_CRM_Order_Date__c = system.today();
            sales_order.ASI_HK_CRM_JDE_Order_No__c = '85058456';
            sales_order.ASI_HK_CRM_JDE_Order_Type_Code__c = 'J5';
            sales_order.ASI_CRM_Sold_To__c = customer1.Id;
            sales_order.ASI_CRM_Ship_To__c = customer1.Id;
            sales_order.OwnerId = user1.Id;
            sales_order.ASI_CRM_Order_Gross_Amount__c = 1000;
            sales_order.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order__cASI_MY_CRM_Sales_Order');
            insert sales_order;

			ASI_MFM_SKU_Code__c sku = ASI_CRM_MY_TestClassHelper.createSKU('Testing');  
            ASI_MFM_Sub_brand__c sub_brand = [SELECT Id FROM ASI_MFM_Sub_brand__c LIMIT 1];
            
            ASI_HK_CRM_Sales_Order_Item__c sales_order_item = new ASI_HK_CRM_Sales_Order_Item__c();
            sales_order_item.ASI_HK_CRM_Sales_Order__c = sales_order.Id;
            sales_order_item.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Sales_Order_Item__cASI_MY_CRM_Sales_Order_Item');
            sales_order_item.CurrencyIsoCode = 'MYR';
            sales_order_item.ASI_HK_CRM_Price__c = 1000;
            sales_order_item.ASI_HK_CRM_Quantity__c = 12;
            sales_order_item.ASI_CRM_Extended_Price__c = 1000;
            sales_order_item.ASI_HK_CRM_UOM__c = 'BT';
            sales_order_item.ASI_CRM_Pricing_UOM__c = 'CT';
            sales_order_item.ASI_CRM_Last_Status__c = '530';
            sales_order_item.ASI_HK_CRM_SKU__c = sku.Id;
            sales_order_item.ASI_CRM_Sub_Brand__c = sub_brand.Id;
            insert sales_order_item;
            update sales_order;
            
            sales_order.ASI_CRM_ETL_Completed__c = true;
            update sales_order;
            
            Test.stopTest();
        }
        
    }
    
}