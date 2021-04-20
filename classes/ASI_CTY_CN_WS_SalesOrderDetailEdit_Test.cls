@isTest
private class ASI_CTY_CN_WS_SalesOrderDetailEdit_Test {
    @testSetup
    static void testDataPre() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', UserRoleId= r.Id,
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;
       
        System.runAs(adminUser) {
            Test.startTest();
            Account acc = new Account(Name = 'TestAccount', 
                                      RecordtypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'),
                                      ASI_KOR_Addr_Region__c = 'Central Region');
            insert acc;

            Contact con = new Contact(LastName = 'TestContact', 
                                    RecordtypeId = Global_RecordTypeCache.getRtId('ContactASI_CRM_CN_Wholesaler_Contact'),
                                    AccountId = acc.Id);
            insert con;

            Profile p2 = [SELECT Id FROM Profile WHERE Name='ASI_CTY_Wholesaler_CN_User'];//ASI_CTY_Wholesaler_CN_User
            User usr2 = new User(Alias = '经销商', Email='standarduser@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='经销商', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                                LocaleSidKey='zh_CN', ProfileId = p2.Id, ContactId = con.Id,IsActive = true,
                                TimeZoneSidKey='Asia/Shanghai', UserName='test1@wholesaler.com',
                                CompanyName = 'Pernod Ricard China');
            insert usr2;
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

            User curU = [select id, ManagerId, CompanyName from user where id = : userInfo.getUserId()];

            List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
            itemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                    , Name = 'TestItemGroup'
                    , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                    , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                    , OwnerID = curU.id
                    , ASI_CRM_Allocation_Information__c = true
            ));
            itemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                    , Name = 'TestItemGroup1'
                    , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode1'
                    , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup1'
                    , OwnerID = curU.id
                    , ASI_CRM_Allocation_Information__c = true
            ));
            insert itemGroupList;
            Test.stopTest();
            List<ASI_KOR_Sales_Order_Request__c> salesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();
            salesOrderList.add(
                    new ASI_KOR_Sales_Order_Request__c(
                            OwnerId = curU.id,
                            ASI_KOR_Order_Status__c = 'Submitted',
                            ASI_CRM_CN_Customer__c = customer.id,
                            ASI_CRM_CN_RTD__c = FALSE,
                            ASI_CRM_SG_Order_Date__c = Date.today().addDays(-20),
                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
            ));
            insert salesOrderList;

            List<ASI_KOR_Sales_Order_Transaction__c> salesOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();
            salesOrderLineItemList.add(
                    new ASI_KOR_Sales_Order_Transaction__c(
                            ASI_CRM_CN_Product_Name__c = itemGroupList[0].id,
                            ASI_KOR_Order_Qty__c = 13,
                            ASI_CRM_UOM_Text__c = 'CA',
                            ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 120,
                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                            ASI_KOR_Sales_Order_Request__c = salesOrderList[0].id,
                            ASI_CRM_Allocation_Information__c = true
            ));
            salesOrderLineItemList.add(
                    new ASI_KOR_Sales_Order_Transaction__c(
                            ASI_CRM_CN_Product_Name__c = itemGroupList[1].id,
                            ASI_KOR_Order_Qty__c = 20,
                            ASI_CRM_UOM_Text__c = 'CA',
                            ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 100,
                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                            ASI_KOR_Sales_Order_Request__c = salesOrderList[0].id,
                            ASI_CRM_Allocation_Information__c = true
            ));
            insert salesOrderLineItemList;
        }
    }

    static testMethod void testSalesOrderEdit() {
        User adminUser = [select id from User where UserName='test2@wholesaler.com' limit 1];
        System.runAs(adminUser) {
            Test.startTest();
            List<ASI_KOR_Sales_Order_Request__c> sor = [select Id from ASI_KOR_Sales_Order_Request__c];
            List<ASI_KOR_Sales_Order_Transaction__c> sorItems = [select Id, ASI_KOR_Order_Qty__c from ASI_KOR_Sales_Order_Transaction__c];
            ApexPages.currentPage().getParameters().put('id', sor.get(0).id);
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(sor);
            ASI_CTY_CN_WS_SalesOrderDetailEditCtrl sorEdit = new ASI_CTY_CN_WS_SalesOrderDetailEditCtrl(ssc);
            ASI_CTY_CN_WS_SalesOrderDetailEditCtrl.lineItemList(sor.get(0).id);
            List<Object> editList = new List<Object>();
            Map<String, Object> editMap = new Map<String, Object>();
            editMap.put('id', sorItems.get(0).id);
            editMap.put('orderQty', 10);
            editList.add(editMap);
            String editStr = JSON.serialize(editList);
            List<Object> delSor = new List<Object>();
            delSor.add(sorItems.get(1).id);
            String delStr = JSON.serialize(delSor);
            ASI_CTY_CN_WS_SalesOrderDetailEditCtrl.saveChanges(String.valueOf(sor.get(0).id), editStr, delStr);
            Test.stopTest();
        }
    }


}