@isTest
public without sharing class ASI_CTY_CN_WS_TestDataFactory {
    public static User generateAdminUser(String userName){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        UserRole r = [SELECT Id FROM UserRole WHERE DeveloperName = 'ASI_ASIA'];
        User adminUser = new User(
            Alias = 'Admin', Email = 'admin@org.com', EmailEncodingKey = 'UTF-8', UserRoleId = r.Id,
            LastName = 'Admin', LanguageLocaleKey = 'zh_CN', LocaleSidKey = 'zh_CN', ProfileId = p.Id, 
            IsActive = true, TimeZoneSidKey='Asia/Shanghai', UserName = userName,
            CompanyName = 'Pernod Ricard China', Autofollow__c = false, BypassTriggers__c = 'Autofollow_User_InsertUpdate');
        insert adminUser;
        return adminUser;
    }
    public static ASI_CRM_AccountsAdditionalField__c generateWSUser(String userName){
        ASI_CRM_Region__c region = new ASI_CRM_Region__c(
            Name = 'TESTRegion');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(
            Name = 'TESTDivision', ASI_CRM_Region__c = region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(
            Name = 'TESTArea', ASI_CRM_English_Name__c = 'TESTArea', 
            ASI_CRM_Division__c = division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(
            ASI_CRM_CN_City_Code__c = 'TESTCity', ASI_CRM_CN_Area__c = area.Id);
        insert city;

        List<ASI_CRM_CN_Channel__c> cnChannelList = new List<ASI_CRM_CN_Channel__c>();
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(
            ASI_CRM_CN_On_Off__c = 'ON');
        cnChannelList.add(channel);
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(
            ASI_CRM_For_Outlet__c = true, Name = 'Restaurant',
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
            ASI_CRM_CN_On_Off__c = 'OFF');
        cnChannelList.add(newChannel);
        insert cnChannelList;

        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(
            ASI_CRM_CN_Channel__c = channel.Id);
        insert subChannel;

        Account acc = new Account(
            Name = 'TestAccount', ASI_KOR_Addr_Region__c = 'Central Region',
            RecordtypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'));
        insert acc;
        
        ASI_CRM_AccountsAdditionalField__c customer = new ASI_CRM_AccountsAdditionalField__c(
            ASI_CRM_CN_Eng_Name__c = 'TestCustomer_EN', ASI_CRM_CN_Chi_Name__c = 'TestCustomer_CN',
            Name = 'TestCustomer', ASI_CRM_CN_Commercial_Team__c = 'Premium',
            ASI_CRM_CN_Sub_Channel__c = subChannel.Id, ASI_CRM_CN_CCity__c = city.Id,
            ASI_CRM_Account__c = acc.Id, ASI_CRM_CN_WS_Tier__c = 'T2',
            ASI_CRM_CN_JDE_Code_Premium__c = '9500001', ASI_CRM_CN_NewChannel__c = newChannel.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'));
        insert customer;
        update customer;

        Contact con = new Contact(
            LastName = 'TestContact', AccountId = acc.Id,
            RecordtypeId = Global_RecordTypeCache.getRtId('ContactASI_CRM_CN_Wholesaler_Contact'));
        insert con;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'ASI_CTY_Wholesaler_CN_User'];//ASI_CTY_Wholesaler_CN_User
        User newUser = new User(
            Alias = '经销商', Email = 'standarduser@org.com', EmailEncodingKey = 'UTF-8', 
            LastName = '经销商', LanguageLocaleKey = 'zh_CN', LocaleSidKey = 'zh_CN', ProfileId = p.Id, 
            ContactId = con.Id, IsActive = true, TimeZoneSidKey='Asia/Shanghai', UserName = userName,
            CompanyName = 'Pernod Ricard China', Autofollow__c = false);
        insert newUser;

        return customer;
    }
    public static ASI_MFM_Item_Group__c generateItemGroup(Boolean doDml, String itemGroupName){
        ASI_MFM_Item_Group__c itemGroup = new ASI_MFM_Item_Group__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'), 
                Name = itemGroupName, ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode', 
                ASI_CRM_CN_Chinese_Name__c = 'TestItemGroup_CN', ASI_CRM_CN_Eng_Name__c = 'TestItemGroup_EN', 
                ASI_CRM_Allocation_Information__c = true);
        if(doDml){
            Database.insert(itemGroup);
        }
        return itemGroup;
    }
    public static ASI_KOR_Sales_Order_Request__c generateSalesOrder(Boolean doDml, String customerId){
        ASI_KOR_Sales_Order_Request__c salesOrder = new ASI_KOR_Sales_Order_Request__c(
            ASI_KOR_Order_Status__c = 'Open',
            ASI_CRM_CN_Customer__c = customerId, ASI_CRM_CN_RTD__c = FALSE,
            ASI_CRM_SG_Order_Date__c = Date.today(),
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder'));
        if(doDml){
            Database.insert(salesOrder);
        }
        return salesOrder;
    }
    public static ASI_KOR_Sales_Order_Transaction__c generateSalesOrderItem(Boolean doDml, String itemGroupId, String salesOrderId){
        ASI_KOR_Sales_Order_Transaction__c salesOrderItem = new ASI_KOR_Sales_Order_Transaction__c(
            ASI_CRM_CN_Product_Name__c = itemGroupId, ASI_KOR_Order_Qty__c = 13,
            ASI_CRM_UOM_Text__c = 'CA', ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 120,
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
            ASI_KOR_Sales_Order_Request__c = salesOrderId, ASI_CRM_Allocation_Information__c = true);
        if(doDml){
            Database.insert(salesOrderItem);
        }
        return salesOrderItem;
    }
    public static ASI_CTY_CN_WS_Custom_Category_Brand__c generateCustomCategoryBrand(Boolean doDml){
        ASI_CTY_CN_WS_Custom_Category_Brand__c customCategoryBrand = new ASI_CTY_CN_WS_Custom_Category_Brand__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Custom_Category_Brand__cASI_CTY_CN_WS_Brand_Filter'),
            Name = '威士忌',
            ASI_CTY_CN_WS_Type__c = 'PRC Premium Wholesaler');
        if(doDml){
            Database.insert(customCategoryBrand);
        }
        return customCategoryBrand;
    }
    public static ASI_MFM_Brand__c generatebrand(Boolean doDml){
        ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Brand__cASI_FOC_CN_Brand'),
            Name = '威士忌');
        if(doDml){
            Database.insert(brand);
        }
        return brand;
    }
    public static ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c generateCustomCategoryBrandRel(Boolean doDml, String customCategoryBrandId, String brandId){
        ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c customCategoryBrandRel = new ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Custom_Category_Brand_Rel__cASI_CTY_CN_WS_Custom_Category_Brand_Relationship'),
            ASI_CTY_CN_WS_Custom_Category_Brand__c = customCategoryBrandId, ASI_CTY_CN_WS_Brand__c = brandId);
        if(doDml){
            Database.insert(customCategoryBrandRel);
        }
        return customCategoryBrandRel;
    }
    public static ASI_CRM_Order_Form__c generateOrderForm(Boolean doDml){
        ASI_CRM_Order_Form__c orderForm = new ASI_CRM_Order_Form__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form'),
            ASI_CRM_Order_Form_Type__c = 'Premium', ASI_CRM_T1_Master__c = false);
        if(doDml){
            Database.insert(orderForm);
        }
        return orderForm;
    }
    public static ASI_CRM_Order_Form_Customer_Relationship__c generateOrderFormRel(Boolean doDml, String orderFormId, String customerId){
        ASI_CRM_Order_Form_Customer_Relationship__c orderFormRel = new ASI_CRM_Order_Form_Customer_Relationship__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'),
            ASI_CRM_Order_Form__c = orderFormId, ASI_CRM_Customer__c = customerId);
        if(doDml){
            Database.insert(orderFormRel);
        }
        return orderFormRel;
    }
    public static ASI_CRM_Order_Form_Detail__c generateOrderFormDetail(Boolean doDml, String orderFormId, String itemGroupId){
        ASI_CRM_Order_Form_Detail__c orderFormDetail = new ASI_CRM_Order_Form_Detail__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail'),
            ASI_CRM_Order_Form__c = orderFormId, ASI_CRM_Product_Name__c = itemGroupId);
        if(doDml){
            Database.insert(orderFormDetail);
        }
        return orderFormDetail;
    }
    public static ASI_CRM_Promotion_Master__c generatePromotionMaster(Boolean doDml){
        ASI_CRM_Promotion_Master__c promotionMaster = new ASI_CRM_Promotion_Master__c(
            Name = 'TestPromotionMaster');
        if(doDml){
            Database.insert(promotionMaster);
        }
        return promotionMaster;
    }
    public static ASI_CRM_Item_Group_Customer_Price__c generateCustomerPrice(Boolean doDml, String customerId, String itemGroupId, String promotionMasterId){
        ASI_CRM_Item_Group_Customer_Price__c customerPrice = new ASI_CRM_Item_Group_Customer_Price__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice'),
            ASI_CRM_Item_Group__c = itemGroupId, ASI_CRM_Customer__c = customerId, 
            ASI_CRM_Unit_Price_BT__c = 150, ASI_CTY_CN_WS_Promotion_Code__c = promotionMasterId);
        if(doDml){
            Database.insert(customerPrice);
        }
        return customerPrice;
    }
    // Add PermissionSet 
    public static PermissionSet SetupPermissionSet(){
        PermissionSet ps = new PermissionSet(Name='PermissionSet_for_Test_Class',Label='PermissionSet_for_Test_Class');
        insert ps;
        List<ObjectPermissions> op = new List<ObjectPermissions>();
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CRM_AccountsAdditionalField__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_KOR_Sales_Order_Request__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_KOR_Sales_Order_Transaction__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CRM_TOV__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CRM_TOV_Detail__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CRM_Order_Form__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CRM_Order_Form_Customer_Relationship__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CRM_Order_Form_Detail__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_MFM_Brand__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CTY_CN_WS_Custom_Category_Brand__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_CTY_CN_WS_Custom_Category_Brand_Rel__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        op.add(new ObjectPermissions(ParentId=ps.Id,
                                     SobjectType='ASI_MFM_Item_Group__c',
                                     PermissionsRead=true,
                                     PermissionsViewAllRecords=true));
        insert op;
        return ps;
    }
}