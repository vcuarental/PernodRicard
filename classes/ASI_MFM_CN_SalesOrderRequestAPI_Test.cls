@istest
private class ASI_MFM_CN_SalesOrderRequestAPI_Test {
    
    //webService
    Private Class salesOrderClass{
        private list<salesOrderStructure> salesOrderlist = new List<salesOrderStructure>();
    }
    
    Private Class salesOrderStructure{
        
        Private String Outlet;
        Private String recordTypeID;
        Private String recordID;
        Private String requestedDate;
        Private String orderDate;
        Private Boolean RTD;
        Private Boolean premium;
        Private String contactPerson;
        Private String otherRequirement;
        Private String TelMobile;
        Private String Address;
    }
    
    Private static List<ASI_MFM_Sub_brand__c> tmpSB = new List<ASI_MFM_Sub_brand__c>();
    
    Private static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
    
    Private static User curU = [select id, ManagerId, CompanyName, Email from user where id = : userInfo.getUserId()];
    
    Private static List<ASI_CRM_CN_Brand_Group__c> tmpBrandGroup = new List<ASI_CRM_CN_Brand_Group__c>();
    
    Private Static List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrder = new List<ASI_KOR_Sales_Order_Request__c>();
    
    Private Static List<ASI_KOR_Sales_Order_Transaction__c> tmpSalesOrderLineItem = new List<ASI_KOR_Sales_Order_Transaction__c>();
    
    Private Static List<ASI_CRM_Order_Form__c> tmpOrderForm = new List<ASI_CRM_Order_Form__c>();
    
    Private Static List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItem = new List<ASI_CRM_Order_Form_Detail__c>();
    
    Private Static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
    
    Private Static List<ASI_MFM_SKU_Code__c> tmpSKU = new List<ASI_MFM_SKU_Code__c>();
    
    Private Static List<ASI_CRM_CN_T1_Price__c> tmpT1Price = new List<ASI_CRM_CN_T1_Price__c>();
    
    Private Static List<ASI_CRM_Order_Form_Customer_Relationship__c> tmpOFCR = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
    
    Private Static List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
    
    Private Static List<ASI_CRM_Item_Group_Customer_Price__c> tmpIGCP = new List<ASI_CRM_Item_Group_Customer_Price__c>();
    
    Private static List<ASI_CRM_Fix_Approval_Route__c> tmpFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
    
    Private static List<ASI_CRM_Dynamic_Approval_Route__c> tmpDynamicRoute = new List<ASI_CRM_Dynamic_Approval_Route__c>();
    
    Private static List<ASI_CRM_Promotion_Master__c> tmpPromotionMaster = new List<ASI_CRM_Promotion_Master__c>();
    
    Private Static List<ASI_MFM_Sub_Channel__c> tmpSubChannel = new List<ASI_MFM_Sub_Channel__c>();
    
    Private Static List<ASI_CRM_Item_Group_Allocation__c> itemGroupAllocation = new List<ASI_CRM_Item_Group_Allocation__c>();

    @isTest
    static void testMethod1() {
        curU.companyName = 'Pernod Ricard China';
        curU.ManagerId = tempU.id;
        curU.Email = 'test_user@test1.com';
        Update curU;
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = 'Test', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - eCommerce'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - VIP'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - HQ'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_CN_Type__c='Sales Order - RTD'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = '', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - IHBR'));
        // 20190621
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - MOT'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = '20190621', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - RTD'));
        // 20190621
        
        insert tmpFixRoute;
        
        //20170601
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_Type__c = 'Sales Order - IHBR', ASI_CRM_Approval_Limit__c = 1, ASI_CRM_User__c = tempU.id, ASI_CRM_End_of_Dynamic_Route__c = True
                                                                  , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Dynamic_Approval_Route__cASI_CRM_CN_Dynamic_Approval_Route')
                                                                 ));
        
        Insert tmpDynamicRoute;
        
        tmpPromotionMaster.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                                                               , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                                                              ));
        insert tmpPromotionMaster;
        
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
        
        tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id));
        tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel.Id));
        
        insert tmpSubChannel;
        
        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(
            Name = 'OFF MOT',
            ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
            ASI_CRM_External_ID__c = 'CN_OFF MOT',
            ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup;
        
        ASI_CRM_CN_Channel__c newChannel = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert newChannel;
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CRM_Code__c = 'WSTEST001', ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CRM_Code__c = 'WSTEST002', ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CRM_Code__c = 'WSTEST003', ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CRM_Code__c = 'WSTEST004', ASI_CRM_CN_Eng_Name__c = 'test4', ASI_CRM_CN_Chi_Name__c = 'test4', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_CRM_Code__c = 'WSTEST005', ASI_CRM_CN_Eng_Name__c = 'test5', ASI_CRM_CN_Chi_Name__c = 'test5', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
//        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test6', ASI_CRM_CN_Chi_Name__c = 'test6', ASI_CRM_CN_Is_IHBR_Outlet__c = True, ASI_CRM_CN_Commercial_Team__c = 'HQ/Hotel', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomer;
        
        tmpSB.add(new ASI_MFM_Sub_brand__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand')
                                           , Name = 'TestSB'
                                           , OwnerId = tempU.id
                                           , ASI_MFM_Sub_brand_Code__c = '1'
                                           , ASI_HK_CRM_English_Name__c = 'TestSB'
                                          ));
        insert tmpSB;
        
        tmpBrandGroup.add(new ASI_CRM_CN_Brand_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Brand_Group__cASI_CRM_CN_Brand_Group')
                                                        , Name = 'TestBrandGroup'
                                                        , OwnerId = tempU.id
                                                        , ASI_CRM_CN_English_Name__c = 'TestBrandGroup'
                                                        , ASI_CRM_CN_Chinese_Name__c = 'TestBrandGroup'
                                                        , ASI_CRM_CN_Sequence2__c = 10
                                                        , ASI_CRM_Brand_Group_Code__c = '1'
                                                       ));
        insert tmpBrandGroup;
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = tempU.id
                                                   , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
                                                  ));
        insert tmpItemGroup;
        
        tmpSKU.add(new ASI_MFM_SKU_Code__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                           , Name = 'TestSKU'
                                           , ASI_CRM_SKU_Status__c = '000'
                                           , ASI_MFM_Item_Group__c = tmpItemGroup[0].id
                                           , OwnerID = tempU.id
                                          ));
        insert tmpSKU;
        
        tmpT1Price.add(new ASI_CRM_CN_T1_Price__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_T1_Price__cASI_CRM_CN_T1_Price')
                                                  , ASI_CRM_CN_Effective_Date__c = date.today().addDays(-1)
                                                  , ASI_CRM_CN_T1_Price__c = 1
                                                  , ASI_CRM_CN_Item_Group__c = tmpItemGroup[0].id
                                                 ));
		insert tmpT1Price;
        
        tmpIGCP.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                                                             , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                             , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                             , ASI_CRM_Unit_Price_BT__c = 1
                                                            ));
        tmpIGCP.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                                                             , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                             , ASI_CRM_Customer__c = tmpCustomer[1].id
                                                             , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                             , ASI_CRM_Unit_Price_BT__c = 1
                                                            ));
        tmpIGCP.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                                                             , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                             , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                             , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                             , ASI_CRM_Unit_Price_BT__c = 1
                                                            ));
        insert tmpIGCP;

        itemGroupAllocation.add(new ASI_CRM_Item_Group_Allocation__c(ASI_CRM_Allocation_Quantity__c = 100
                                                                     , ASI_CRM_Commercial_Team__c = 'Premium'
                                                                     , ASI_CRM_Effective_Date__c = date.today()
                                                                     , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                                     , ASI_CRM_Region__c = region.id
                                                                     , ASI_CRM_UOM__c = 'CA'
                                                                     , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation') 
                                                                    ));
        Insert itemGroupAllocation;
        Update itemGroupAllocation;

		test.startTest();

		String jsonStr = '{"salesOrder":{"customerCode":"WSTEST001","uom":"","contactPerson":"Introv Admin","email":"test_user@test1.com","requirement":"","requestDate":"2019-10-10","phone":"21234567","address":"Hong Kong","premium":false,"rtd":false},"salesOrderItem":[{"productCode":"TestItemGroupCode","uom":"CA","qty":10}]}';

		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();
        Map<String, String> headers = req.headers;
        headers.put('Content-Type', 'application/json');

		req.requestURI = '/services/apexrest/ASI_MFM_CN_SalesOrderRequest_API';
		req.httpMethod = 'POST';
		req.requestBody = Blob.valueof(jsonStr);
		RestContext.request = req;
		RestContext.response = res;

		ASI_MFM_CN_SalesOrderRequestAPI.createSalesOrderRequest();

		test.stopTest();
    }
}