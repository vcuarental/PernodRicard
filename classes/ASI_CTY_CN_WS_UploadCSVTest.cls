/*****************************************************************************************************************
 * Name: ASI_CTY_CN_WS_UploadCSV
 * Test Class:  ASI_CTY_CN_WS_UploadCSVTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-10-21       jack yuan               created
 *****************************************************************************************************************/
@isTest
private class ASI_CTY_CN_WS_UploadCSVTest {
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
           ASI_CRM_CN_CustomSetting__c csetting = new ASI_CRM_CN_CustomSetting__c();
            csetting.ASI_CTY_CN_WS_Dev_EndPoint__c = 'http://prcdhdev.pernod-ricard-china.com:8089/PRCApi/transport/wechattransportationoutbound';
            csetting.ASI_CTY_CN_WS_Dev_JWT_Key__c = 'bTe5354ihj84AMwV6AtJ7oefZzw3qZNL';
            csetting.ASI_CTY_CN_WS_Pro_EndPoint__c = 'http://prapi.pernod-ricard-china.com:8089/prcapi/transport/wechattransportationoutbound';
            csetting.ASI_CTY_CN_WS_Pro_JWT_Key__c = '1gfi5g6unMVJaeT4WtXLGENSYaJjuELA';
            csetting.ASI_CTY_CN_WS_Download_SOR_Item_Header__c = '订单编号,订单状态,姓名,电话,订单日期,其他需求,地址,TOV,产品名称,包装规格,下单量（箱）,释放量（箱）,原价（瓶）,促销,折扣率,实际单价（瓶）,释放量金额';
            csetting.ASI_CTY_CN_WS_Upload_SOR_Item_Header__c = '产品英文名, 产品中文名, 每箱瓶数, 容量(cl), 数量(批发商输入), 单位,每瓶单价, Item Group ID(下载自动生成)';
            csetting.ASI_CTY_CN_WS_Upload_SOR_Item_Header_Err__c = '产品英文名,产品中文名, 每箱瓶数,容量(cl), 数量(批发商输入),单位,每瓶单价, Item Group ID(下载自动生成),错误信息';
            insert csetting;
            
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


            ASI_KOR_Sales_Order_Request__c sor = new ASI_KOR_Sales_Order_Request__c();
            sor.ASI_CRM_CN_Contact_Person__c = con.LastName;
            sor.ASI_CRM_CN_Customer__c = customer.Id;
            sor.ASI_CRM_CN_Premium__c = true;
            sor.ASI_CRM_SG_Order_Date__c = System.today();
            sor.ASI_KOR_Order_Status__c = 'Open';
            sor.RecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder');
            
            insert sor;

            ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(Name = 'TestCode',
                                                                        ASI_MFM_Item_Group_Code__c = 'TestCode',
                                                                        ASI_CRM_CN_Eng_Name__c = 'TestName',
                                                                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                                                                        ASI_MFM_Item_Group_External_ID__c = 'CN_123456');
            insert itemGroup;

            ASI_KOR_Sales_Order_Transaction__c sorItem = new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = itemGroup.Id,
                                                                                                ASI_KOR_Order_Qty__c = 100,
                                                                                                ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                                                                                                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                                                                                                ASI_KOR_Sales_Order_Request__c = sor.Id);
            insert sorItem;

           
           ASI_CRM_CN_Tax_Rate_Config__c taxRate = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Tax_Rate__c = 15);
           insert taxRate;

           ASI_CRM_Order_Form__c orderForm = new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                                                                       , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                                                                       , ASI_CRM_Order_Form_Type__c = 'Premium'
                                                                       , ASI_CRM_T1_Master__c = true);
           insert orderForm;

           ASI_CRM_Order_Form_Detail__c formDetail = new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                                      , ASI_CRM_Available__c = true
                                                                                      , ASI_CRM_Order_Form__c = orderForm.Id
                                                                                      , ASI_CRM_Product_Name__c = itemGroup.Id
                                                                                      , ASI_CRM_Remark__c = 'TestRemark');
           insert formDetail;

           ASI_CRM_Order_Form_Customer_Relationship__c formCustomer = new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), 
                                                                                                                      ASI_CRM_Customer__c = customer.Id, 
                                                                                                                      ASI_CRM_Order_Form__c = orderForm.Id);
           insert formCustomer;

           ASI_CRM_Item_Group_Customer_Price__c customerPrice = new ASI_CRM_Item_Group_Customer_Price__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                                                                         , ASI_CRM_Customer__c =  customer.Id
                                                                                                         , ASI_CRM_Item_Group__c = itemGroup.Id
                                                                                                         , ASI_CRM_Unit_Price_BT__c = 1);
           insert customerPrice;
       }

    }

    static testMethod void testUploadCSV() {
        Test.startTest();
        User usr = [SELECT Id FROM User WHERE UserName = 'test1@wholesaler.com'];
        ASI_CRM_AccountsAdditionalField__c customer = [SELECT Id FROM ASI_CRM_AccountsAdditionalField__c];
        ASI_MFM_Item_Group__c itemGroup = [SELECT ASI_MFM_Item_Group_External_ID__c FROM ASI_MFM_Item_Group__c];
        ASI_KOR_Sales_Order_Request__c sor = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c];
        System.runAs(usr) {
            ASI_CTY_CN_WS_UploadCSV.getUploadTemplate();
        }
        Map<String, Object> checkMap = new Map<String, Object>();
        checkMap.put('itemGroupId', itemGroup.ASI_MFM_Item_Group_External_ID__c);
        checkMap.put('orderQty', '9');
        checkMap.put('unitPricePerBottle', '23');

        List< ASI_CTY_CN_WS_UploadCSV.ProductItem> proItemlist = new List< ASI_CTY_CN_WS_UploadCSV.ProductItem>();
        ASI_CTY_CN_WS_UploadCSV.ProductItem proItem = new ASI_CTY_CN_WS_UploadCSV.ProductItem();
        proItem.itemGroupId = itemGroup.ASI_MFM_Item_Group_External_ID__c;
        proItemlist.add(proItem);

        ASI_CTY_CN_WS_UploadCSV.checkUploadData(customer.Id, JSON.serialize(checkMap));
        ASI_CTY_CN_WS_UploadCSV.submitProducts(sor.Id, JSON.serialize(proItemlist));
        Test.stopTest();
        
    }

}