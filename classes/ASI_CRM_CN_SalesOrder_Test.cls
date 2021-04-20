@istest
private class ASI_CRM_CN_SalesOrder_Test {
    
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
    
    Private static User curU = [select id, ManagerId, CompanyName from user where id = : userInfo.getUserId()];
    
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

    Private static testMethod void testMethod1(){
        
        curU.companyName = 'Pernod Ricard China';
        curU.ManagerId = tempU.id;
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
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test4', ASI_CRM_CN_Chi_Name__c = 'test4', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test5', ASI_CRM_CN_Chi_Name__c = 'test5', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel.Id));
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
        
        tmpOrderForm.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                                                   , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                                                   , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                                                   , ASI_CRM_T1_Master__c = TRUE
                                                   , OwnerID = tempU.id
                                                  ));
        tmpOrderForm.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                                                   , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                                                   , ASI_CRM_Order_Form_Type__c = 'RTD'
                                                   , ASI_CRM_T1_Master__c = TRUE
                                                   , OwnerID = tempU.id
                                                  ));
        tmpOrderForm.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                                                   , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                                                   , ASI_CRM_Order_Form_Type__c = 'Premium'
                                                   , ASI_CRM_T1_Master__c = TRUE
                                                   , OwnerID = tempU.id
                                                  ));
    	insert tmpOrderForm;
        
        tmpOrderFormLineItem.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                  , ASI_CRM_Available__c = TRUE
                                                                  , ASI_CRM_Order_Form__c = tmpOrderForm[0].id
                                                                  , ASI_CRM_Product_Name__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Remark__c = 'TestRemark'
                                                                  , ASI_CRM_Sequence__c = 1//20170217 Elufa
                                                                 ));
        tmpOrderFormLineItem.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                  , ASI_CRM_Available__c = TRUE
                                                                  , ASI_CRM_Order_Form__c = tmpOrderForm[1].id
                                                                  , ASI_CRM_Product_Name__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Remark__c = 'TestRemark'
                                                                  , ASI_CRM_Sequence__c = 1//20170217 Elufa
                                                                 ));
        tmpOrderFormLineItem.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                  , ASI_CRM_Available__c = TRUE
                                                                  , ASI_CRM_Order_Form__c = tmpOrderForm[2].id
                                                                  , ASI_CRM_Product_Name__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Remark__c = 'TestRemark'
                                                                  , ASI_CRM_Sequence__c = 1//20170217 Elufa
                                                                 ));
        
        insert tmpOrderFormLineItem;
        
        tmpOFCR.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomer[1].id, ASI_CRM_Order_Form__c = tmpOrderForm[0].id));
        tmpOFCR.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomer[1].id, ASI_CRM_Order_Form__c = tmpOrderForm[1].id));
        tmpOFCR.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomer[1].id, ASI_CRM_Order_Form__c = tmpOrderForm[2].id));
        tmpOFCR.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomer[2].id, ASI_CRM_Order_Form__c = tmpOrderForm[2].id));
        
        insert tmpOFCR;
        
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_CN_RTD__c = FALSE
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[2].id
                                                             , ASI_CRM_CN_RTD__c = False
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[1].id
                                                             , ASI_CRM_CN_RTD__c = FALSE
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[1].id
                                                             , ASI_CRM_CN_RTD__c = False
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[3].id
                                                             , ASI_CRM_CN_RTD__c = True
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[4].id
                                                             , ASI_CRM_CN_RTD__c = True
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[4].id
                                                             , ASI_CRM_CN_RTD__c = True
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        
        insert tmpSalesOrder;
        
        tmpSalesOrderLineItem.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMaster[0].id
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder[0].id
                                                                        ));
        tmpSalesOrderLineItem.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMaster[0].id
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder[1].id
                                                                        ));
        tmpSalesOrderLineItem.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMaster[0].id
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder[2].id
                                                                        ));
        tmpSalesOrderLineItem.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMaster[0].id
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder[3].id
                                                                        ));
        tmpSalesOrderLineItem.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id
                                                                         , ASI_KOR_Order_Qty__c = 1
                                                                         , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                                                                         , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMaster[0].id
                                                                         , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                                                                         , ASI_KOR_Sales_Order_Request__c = tmpSalesOrder[6].id
                                                                        ));
        insert tmpSalesOrderLineItem;
        
        update tmpSalesOrder;

        /*
        ASI_CRM_TOV__c tmpTOV = new ASI_CRM_TOV__c(ASI_CRM_Status__c = 'Draft'
                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV')
                                                   , ASI_CRM_SF_SO_Request_Number__c = tmpSalesOrder[0].id
                                                  );
        insert tmpTOV;
        update tmpTOV;

        ASI_CRM_CN_Field_ID_Mapping__c tmpCustomeObject = new ASI_CRM_CN_Field_ID_Mapping__c(Name = 'SalesOrder Field Id');
        insert tmpCustomeObject;
        
        //21080718 Introv
        Test.setCurrentPage(Page.ASI_CRM_CN_TOV_PDF);
        Apexpages.currentPage().getParameters().put('id', tmpTOV.id);
        ASI_CRM_CN_TOV_PDF_Controller tovPDFCTRL = new ASI_CRM_CN_TOV_PDF_Controller();
        tovPDFCTRL.currentHeaderID = tmpTOV.id;
        tovPDFCTRL.dummyVar = false;
        tovPDFCTRL.lineItemFGR = null;
        tovPDFCTRL.lineItem = null;
        tovPDFCTRL.totalQty = 0;
        tovPDFCTRL.init();
        
        Test.setCurrentPage(Page.ASI_CRM_CN_SalesOrderNewRequestPage);
        Apexpages.currentPage().getParameters().put('id', tmpCustomer[0].id);
        Apexpages.StandardController sc1 = new apexpages.StandardController(tmpCustomer[0]);
        ASI_CRM_CN_SalesOrderNewRequestCRTLLER newSalesOrder = new ASI_CRM_CN_SalesOrderNewRequestCRTLLER(sc1);
        newSalesOrder.newSalesOrder();
        
        Test.setCurrentPage(Page.ASI_CRM_CN_SalesOrderNewRequestPage);
        Apexpages.currentPage().getParameters().put('id', tmpCustomer[2].id);
        Apexpages.StandardController sc5 = new apexpages.StandardController(tmpCustomer[2]);
        ASI_CRM_CN_SalesOrderNewRequestCRTLLER newSalesOrder2 = new ASI_CRM_CN_SalesOrderNewRequestCRTLLER(sc5);
        newSalesOrder2.newSalesOrder();
        
        Test.setCurrentPage(Page.ASI_CRM_CN_OrderFormRequestPage);
        Apexpages.currentPage().getParameters().put('id', tmpSalesOrder[0].id);
        Apexpages.StandardSetController sc = new apexpages.StandardSetController(tmpSalesOrder);
        ASI_CRM_CN_SalesOrderRequestCtrller so = new ASI_CRM_CN_SalesOrderRequestCtrller(sc);
        ASI_CRM_CN_SalesOrder_EmailController so2 = new ASI_CRM_CN_SalesOrder_EmailController();
        
        so2.dummyVar = false;
        so2.lineItem = tmpSalesOrderLineItem;
        so2.currentHeaderID = tmpSalesOrder[0].id;
        so2.init();
        so.getBrandType();
        
        ASI_CRM_CN_SalesOrder_EmailController so3 = new ASI_CRM_CN_SalesOrder_EmailController();
        
        List<ASI_KOR_Sales_Order_Transaction__c> l = new List<ASI_KOR_Sales_Order_Transaction__c>();
        l.add(tmpSalesOrderLineItem[3]);
        so3.dummyVar = false;
        so3.lineItem = l;
        so3.currentHeaderID = tmpSalesOrder[3].id;
        so3.init();
        
        List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem>();
        
        //ASI_CRM_CN_SalesOrderRequestCtrller.getBrandType();
        ASI_CRM_CN_SalesOrderRequestCtrller.lineItemList(tmpSalesOrder[0].id);
        ASI_CRM_CN_SalesOrderRequestCtrller.normalProductList(tmpSalesOrder[0].id, '', false);
        
        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpSOLineItem2.skuId = tmpItemGroup[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMaster[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;
        
        tmpSOLineItem.add(tmpSOLineItem2);
        
        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpSOLineItem3.skuId = tmpItemGroup[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMaster[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;
        tmpSOLineItem3.id = tmpOrderFormLineItem[0].id;
        
        tmpSOLineItem.add(tmpSOLineItem3);
        
        ASI_CRM_CN_SalesOrderRequestCtrller.saveChanges(tmpOrderForm[0].id, tmpSOLineItem);
        
        String headerRecord = '{\"salesOrderlist\":[{\"recordID\":\"\",\"requestedDate\":\"' + date.today().year() + '/' + date.today().month() + '/' + date.today().day() + '\",\"orderDate\":\"' + date.today().year() + '/' + date.today().month() + '/' + date.today().day() + '\",\"RTD\":false,\"contactPerson\":\"Test\",\"otherRequirement\":\"No!!!\",\"TelMobile\":\"12345678\",\"Address\":\"HK\",\"Outlet\":\"' + tmpCustomer[0].id + '\",\"recordTypeID\":\"' + Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder') + '\"}]}';
        ASI_CRM_CN_SalesOrder_Upsert.UpsertSalesOrder(headerRecord);
        
        String lineRecord = '{\"salesOrderLIlist\":[{\"recordID\":\"\",\"SOHeader\":\"' + tmpSalesOrder[0].id + '\",\"OrderQty\":\"100\",\"recordTypeID\":\"' + Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item') + '\",\"itemGroup\":\"' + tmpItemGroup[0].id + '\",\"UOM\":\"CA\"}]}';
        ASI_CRM_CN_SalesOrderLineItem_Upsert.UpsertSalesOrderLI(lineRecord);
        
        String deleteLine = '{\"salesOrderLIlist\":[{\"recordID\":\"' + tmpSalesOrderLineItem[0].id + '\"}]}';
        ASI_CRM_CN_SalesOrderLineItem_Delete.deleteSalesOrderLI(deleteLine);
        
        String deleteRecord = '{\"salesOrderlist\":[{\"recordID\":\"' + tmpSalesOrder[0].id + '\"}]}';
        ASI_CRM_CN_SalesOrder_Detele.DeleteSalesOrder(deleteRecord);
        
        String submitRecord = '{\"salesOrderlist\":[{\"recordID\":\"' + tmpSalesOrder[2].id + '\"}]}';
        ASI_CRM_CN_SalesOrder_Submit.submitSalesOrder(submitRecord);
        */
        test.stopTest();

    }

    @isTest
    static void testMethod2() {
        system.debug('testMethod2 start');

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name='TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c= ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();
        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();

        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_KOR_Sales_Order_Transaction__c> tmpSalesOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();

        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[0].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[1].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[2].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[3].id
                , ASI_CRM_Allocation_Information__c = true
        ));
        insert tmpSalesOrderLineItemList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'RTD'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Premium'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[1].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[2].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        List<ASI_CRM_Order_Form_Customer_Relationship__c> tmpOFCRList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[0].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[1].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[2].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[2].id));

        insert tmpOFCRList;

        ASI_CRM_TOV__c tmpTOV = new ASI_CRM_TOV__c(ASI_CRM_Status__c = 'Draft'
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV')
                , ASI_CRM_SF_SO_Request_Number__c = tmpSalesOrderList[0].id
        );
        insert tmpTOV;
        update tmpTOV;

        ASI_CRM_CN_Field_ID_Mapping__c tmpCustomeObject = new ASI_CRM_CN_Field_ID_Mapping__c(Name = 'SalesOrder Field Id');
        insert tmpCustomeObject;

        //21080718 Introv
        Test.setCurrentPage(Page.ASI_CRM_CN_TOV_PDF);
        Apexpages.currentPage().getParameters().put('id', tmpTOV.id);
        ASI_CRM_CN_TOV_PDF_Controller tovPDFCTRL = new ASI_CRM_CN_TOV_PDF_Controller();
        tovPDFCTRL.currentHeaderID = tmpTOV.id;
        tovPDFCTRL.dummyVar = false;
        tovPDFCTRL.lineItemFGR = null;
        tovPDFCTRL.lineItem = null;
        tovPDFCTRL.totalQty = 0;
        tovPDFCTRL.init();

        Test.setCurrentPage(Page.ASI_CRM_CN_SalesOrderNewRequestPage);
        Apexpages.currentPage().getParameters().put('id', tmpCustomerList[0].id);
        Apexpages.StandardController sc1 = new apexpages.StandardController(tmpCustomerList[0]);
        ASI_CRM_CN_SalesOrderNewRequestCRTLLER newSalesOrder = new ASI_CRM_CN_SalesOrderNewRequestCRTLLER(sc1);
        newSalesOrder.newSalesOrder();

        Test.setCurrentPage(Page.ASI_CRM_CN_SalesOrderNewRequestPage);
        Apexpages.currentPage().getParameters().put('id', tmpCustomerList[2].id);
        Apexpages.StandardController sc5 = new apexpages.StandardController(tmpCustomerList[2]);
        ASI_CRM_CN_SalesOrderNewRequestCRTLLER newSalesOrder2 = new ASI_CRM_CN_SalesOrderNewRequestCRTLLER(sc5);
        newSalesOrder2.newSalesOrder();

        Test.setCurrentPage(Page.ASI_CRM_CN_OrderFormRequestPage);
        Apexpages.currentPage().getParameters().put('id', tmpSalesOrderList[0].id);
        Apexpages.StandardSetController sc = new apexpages.StandardSetController(tmpSalesOrderList);
        ASI_CRM_CN_SalesOrderRequestCtrller so = new ASI_CRM_CN_SalesOrderRequestCtrller(sc);
        ASI_CRM_CN_SalesOrder_EmailController so2 = new ASI_CRM_CN_SalesOrder_EmailController();

        so2.dummyVar = false;
        so2.lineItem = tmpSalesOrderLineItemList;
        so2.currentHeaderID = tmpSalesOrderList[0].id;
        so2.init();
        so.getBrandType();

        ASI_CRM_CN_SalesOrder_EmailController so3 = new ASI_CRM_CN_SalesOrder_EmailController();

        List<ASI_KOR_Sales_Order_Transaction__c> l = new List<ASI_KOR_Sales_Order_Transaction__c>();
        l.add(tmpSalesOrderLineItemList[3]);
        so3.dummyVar = false;
        so3.lineItem = l;
        so3.currentHeaderID = tmpSalesOrderList[3].id;
        so3.init();

        List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem>();

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem2.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;

        tmpSOLineItem.add(tmpSOLineItem2);

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem3.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem3.price = 1;
        tmpSOLineItem3.unitPriceSource = 'a';
        tmpSOLineItem3.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem3.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem3.qty = 1;
        tmpSOLineItem3.id = tmpOrderFormLineItemList[0].id;

        tmpSOLineItem.add(tmpSOLineItem3);

        String headerRecord = '{\"salesOrderlist\":[{\"recordID\":\"\",\"requestedDate\":\"' + date.today().year() + '/' + date.today().month() + '/' + date.today().day() + '\",\"orderDate\":\"' + date.today().year() + '/' + date.today().month() + '/' + date.today().day() + '\",\"RTD\":false,\"contactPerson\":\"Test\",\"otherRequirement\":\"No!!!\",\"TelMobile\":\"12345678\",\"Address\":\"HK\",\"Outlet\":\"' + tmpCustomerList[0].id + '\",\"recordTypeID\":\"' + Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder') + '\"}]}';
        ASI_CRM_CN_SalesOrder_Upsert.UpsertSalesOrder(headerRecord);

        system.debug('testMethod2 end');
    }

    @isTest
    static void testMethod3() {
        system.debug('testMethod3 start');
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name='TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c= ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();

        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem>();

        //ASI_CRM_CN_SalesOrderRequestCtrller.getBrandType();
        ASI_CRM_CN_SalesOrderRequestCtrller.lineItemList(tmpSalesOrderList[0].id);
        ASI_CRM_CN_SalesOrderRequestCtrller.normalProductList(tmpSalesOrderList[0].id, '', false);

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();
        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem2.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;

        tmpSOLineItem.add(tmpSOLineItem2);

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem3.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem3.price = 1;
        tmpSOLineItem3.unitPriceSource = 'a';
        tmpSOLineItem3.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem3.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem3.qty = 1;
        tmpSOLineItem3.id = tmpOrderFormLineItemList[0].id;

        tmpSOLineItem.add(tmpSOLineItem3);

        ASI_CRM_CN_SalesOrderRequestCtrller.saveChanges(tmpOrderFormList[0].id, tmpSOLineItem);

        system.debug('testMethod3 end');
    }

    @isTest
    static void testMethod4() {
        system.debug('testMethod4 start');
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name='TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c= ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();

        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem>();

        //ASI_CRM_CN_SalesOrderRequestCtrller.getBrandType();
        ASI_CRM_CN_SalesOrderRequestCtrller.lineItemList(tmpSalesOrderList[0].id);
        ASI_CRM_CN_SalesOrderRequestCtrller.normalProductList(tmpSalesOrderList[0].id, '', false);

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();
        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem2.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;

        tmpSOLineItem.add(tmpSOLineItem2);

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem3.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem3.price = 1;
        tmpSOLineItem3.unitPriceSource = 'a';
        tmpSOLineItem3.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem3.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem3.qty = 1;
        tmpSOLineItem3.id = tmpOrderFormLineItemList[0].id;

        tmpSOLineItem.add(tmpSOLineItem3);

        String lineRecord = '{\"salesOrderLIlist\":[{\"recordID\":\"\",\"SOHeader\":\"' + tmpSalesOrderList[0].id + '\",\"OrderQty\":\"100\",\"recordTypeID\":\"' + Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item') + '\",\"itemGroup\":\"' + tmpItemGroupList[0].id + '\",\"UOM\":\"CA\"}]}';
        ASI_CRM_CN_SalesOrderLineItem_Upsert.UpsertSalesOrderLI(lineRecord);

        system.debug('testMethod4 end');
    }

    @isTest
    static void testMethod5() {
        system.debug('testMethod5 start');
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name='TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c= ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();

        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_CRM_Item_Group_Allocation__c> itemGroupAllocationList = new List<ASI_CRM_Item_Group_Allocation__c>();

        itemGroupAllocationList.add(new ASI_CRM_Item_Group_Allocation__c(ASI_CRM_Allocation_Quantity__c = 100
                , ASI_CRM_Commercial_Team__c = 'Premium'
                , ASI_CRM_Effective_Date__c = date.today()
                , ASI_CRM_Item_Group__c = tmpItemGroupList[0].id
                , ASI_CRM_Region__c = region_1.id
                , ASI_CRM_UOM__c = 'CA'
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
        ));
        insert itemGroupAllocationList;

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();

        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , ASI_CRM_SG_Order_Date__c = date.today()
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_KOR_Sales_Order_Transaction__c> tmpSalesOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();

        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[0].id
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[1].id
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[2].id
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[3].id
        ));
        insert tmpSalesOrderLineItemList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem>();

        //ASI_CRM_CN_SalesOrderRequestCtrller.getBrandType();
        ASI_CRM_CN_SalesOrderRequestCtrller.lineItemList(tmpSalesOrderList[0].id);
        ASI_CRM_CN_SalesOrderRequestCtrller.normalProductList(tmpSalesOrderList[0].id, '', false);

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem2.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;

        tmpSOLineItem.add(tmpSOLineItem2);

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem3.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem3.price = 1;
        tmpSOLineItem3.unitPriceSource = 'a';
        tmpSOLineItem3.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem3.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem3.qty = 1;
        tmpSOLineItem3.id = tmpOrderFormLineItemList[0].id;

        tmpSOLineItem.add(tmpSOLineItem3);

        String deleteLine = '{\"salesOrderLIlist\":[{\"recordID\":\"' + tmpSalesOrderLineItemList[0].id + '\"}]}';
        ASI_CRM_CN_SalesOrderLineItem_Delete.deleteSalesOrderLI(deleteLine);

        system.debug('testMethod5 end');
    }

    @isTest
    static void testMethod6() {
        system.debug('testMethod6 start');
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name='TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c= ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();

        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem>();

        //ASI_CRM_CN_SalesOrderRequestCtrller.getBrandType();
        ASI_CRM_CN_SalesOrderRequestCtrller.lineItemList(tmpSalesOrderList[0].id);
        ASI_CRM_CN_SalesOrderRequestCtrller.normalProductList(tmpSalesOrderList[0].id, '', false);

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();
        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem2.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;

        tmpSOLineItem.add(tmpSOLineItem2);

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem3.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem3.price = 1;
        tmpSOLineItem3.unitPriceSource = 'a';
        tmpSOLineItem3.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem3.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem3.qty = 1;
        tmpSOLineItem3.id = tmpOrderFormLineItemList[0].id;

        tmpSOLineItem.add(tmpSOLineItem3);

        String deleteRecord = '{\"salesOrderlist\":[{\"recordID\":\"' + tmpSalesOrderList[0].id + '\"}]}';
        ASI_CRM_CN_SalesOrder_Detele.DeleteSalesOrder(deleteRecord);

        system.debug('testMethod6 end');
    }

    @isTest
    static void testMethod7() {
        system.debug('testMethod7 start');
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name='TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name='Restaurant',RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_CN_On_Off__c='OFF', ASI_CRM_CN_Channel_Group__c= ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();

        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c= tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c= city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem> tmpSOLineItem = new List<ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem>();

        //ASI_CRM_CN_SalesOrderRequestCtrller.getBrandType();
        ASI_CRM_CN_SalesOrderRequestCtrller.lineItemList(tmpSalesOrderList[0].id);
        ASI_CRM_CN_SalesOrderRequestCtrller.normalProductList(tmpSalesOrderList[0].id, '', false);

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();
        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem2 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem2.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem2.remark = 'TestRemark';
        tmpSOLineItem2.price = 1;
        tmpSOLineItem2.unitPriceSource = 'a';
        tmpSOLineItem2.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem2.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem2.qty = 1;

        tmpSOLineItem.add(tmpSOLineItem2);

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem tmpSOLineItem3 = new ASI_CRM_CN_SalesOrderRequestCtrller.ASI_HK_CRM_SOLineItem();

        tmpSOLineItem3.skuId = tmpItemGroupList[0].id;
        tmpSOLineItem3.remark = 'TestRemark';
        tmpSOLineItem3.price = 1;
        tmpSOLineItem3.unitPriceSource = 'a';
        tmpSOLineItem3.promotionCodeID = tmpPromotionMasterList[0].id;
        tmpSOLineItem3.promotionExpirationDate = '7-5-2015';
        tmpSOLineItem3.qty = 1;
        tmpSOLineItem3.id = tmpOrderFormLineItemList[0].id;

        tmpSOLineItem.add(tmpSOLineItem3);

        String submitRecord = '{\"salesOrderlist\":[{\"recordID\":\"' + tmpSalesOrderList[2].id + '\"}]}';
        ASI_CRM_CN_SalesOrder_Submit.submitSalesOrder(submitRecord);

        system.debug('testMethod7 end');
    }

    @isTest
    static void testMethod8() {
        system.debug('testMethod8 start');
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;

        ASI_CRM_Region__c region_1 = new ASI_CRM_Region__c (Name = 'TEST');
        insert region_1;

        ASI_CRM_Division__c division_1 = new ASI_CRM_Division__c(Name = 'TEST', ASI_CRM_Region__c = region_1.Id);
        insert division_1;

        ASI_CRM_CN_Area__c area_1 = new ASI_CRM_CN_Area__c(Name = 'TEST', ASI_CRM_English_Name__c = 'TEST', ASI_CRM_Division__c = division_1.Id);
        insert area_1;

        ASI_CRM_City__c city_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c = 'TEST', ASI_CRM_CN_Area__c = area_1.Id);
        insert city_1;

        ASI_CRM_CN_Channel__c channel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c = 'ON');
        insert channel_1;

        List<ASI_MFM_Sub_Channel__c> tmpSubChannelList = new List<ASI_MFM_Sub_Channel__c>();
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c = channel_1.Id));
        tmpSubChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c = channel_1.Id));

        insert tmpSubChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup_1;

        ASI_CRM_CN_Channel__c newChannel_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_For_Outlet__c = true, Name = 'Restaurant', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'), ASI_CRM_CN_On_Off__c = 'OFF', ASI_CRM_CN_Channel_Group__c = ChannelGroup_1.Id);
        insert newChannel_1;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();

        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test1', ASI_CRM_CN_Chi_Name__c = 'test1', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', ASI_CRM_CN_JDE_Code_Premium__c = '456', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c = tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c = city_1.Id, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test2', ASI_CRM_CN_Chi_Name__c = 'test2', ASI_CRM_CN_Commercial_Team__c = 'Presitge', ASI_CRM_CN_JDE_Code_RTD__c = '666', ASI_CRM_CN_JDE_Code__c = '222', ASI_CRM_CN_JDE_Code_Premium__c = '789', ASI_CRM_CN_Sub_Channel__c = tmpSubChannelList[1].Id, ASI_CRM_CN_CCity__c = city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c = system.today(), RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'), ASI_CRM_CN_NewChannel__c = newChannel_1.Id));
        tmpCustomerList.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Eng_Name__c = 'test3', ASI_CRM_CN_Chi_Name__c = 'test3', ASI_CRM_CN_Commercial_Team__c = 'Premium', ASI_CRM_CN_JDE_Code_RTD__c = '777', ASI_CRM_CN_JDE_Code__c = '333', ASI_CRM_CN_JDE_Code_Premium__c = '123', ASI_CRM_CN_Sub_Channel__c = tmpSubChannelList[0].Id, ASI_CRM_CN_CCity__c = city_1.Id, ASI_CRM_Latest_Call_Plan_Date__c = system.today(), RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
        insert tmpCustomerList;

        List<ASI_MFM_Item_Group__c> tmpItemGroupList = new List<ASI_MFM_Item_Group__c>();

        tmpItemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true//20170217 Elufa
        ));
        insert tmpItemGroupList;

        List<ASI_CRM_Item_Group_Allocation__c> itemGroupAllocationList = new List<ASI_CRM_Item_Group_Allocation__c>();

        itemGroupAllocationList.add(new ASI_CRM_Item_Group_Allocation__c(ASI_CRM_Allocation_Quantity__c = 100
                , ASI_CRM_Commercial_Team__c = 'Premium'
                , ASI_CRM_Effective_Date__c = date.today()
                , ASI_CRM_Item_Group__c = tmpItemGroupList[0].id
                , ASI_CRM_Region__c = region_1.id
                , ASI_CRM_UOM__c = 'CA'
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
        ));
        insert itemGroupAllocationList;

        List<ASI_CRM_Promotion_Master__c> tmpPromotionMasterList = new List<ASI_CRM_Promotion_Master__c>();

        tmpPromotionMasterList.add(new ASI_CRM_Promotion_Master__c(OwnerId = tempU.id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert tmpPromotionMasterList;

        List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();

        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_CN_RTD__c = FALSE
                , ASI_CRM_SG_Order_Date__c = date.today()
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = FALSE
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        tmpSalesOrderList.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                , ASI_KOR_Order_Status__c = 'Open'
                , ASI_CRM_CN_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_CN_RTD__c = False
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert tmpSalesOrderList;

        List<ASI_KOR_Sales_Order_Transaction__c> tmpSalesOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();

        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[0].id
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[1].id
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[2].id
        ));
        tmpSalesOrderLineItemList.add(new ASI_KOR_Sales_Order_Transaction__c(ASI_CRM_CN_Product_Name__c = tmpItemGroupList[0].id
                , ASI_KOR_Order_Qty__c = 1
                , ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1
                , ASI_CRM_CN_Promotion_Code__c = tmpPromotionMasterList[0].id
                , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item')
                , ASI_KOR_Sales_Order_Request__c = tmpSalesOrderList[3].id
        ));
        insert tmpSalesOrderLineItemList;

        List<ASI_CRM_Order_Form__c> tmpOrderFormList = new List<ASI_CRM_Order_Form__c>();

        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Premium'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'RTD'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        tmpOrderFormList.add(new ASI_CRM_Order_Form__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form')
                , ASI_CRM_Order_Form_Name__c = 'TestOrderForm'
                , ASI_CRM_Order_Form_Type__c = 'Normal Item'
                , ASI_CRM_T1_Master__c = TRUE
                , OwnerID = tempU.id
        ));
        insert tmpOrderFormList;

        List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItemList = new List<ASI_CRM_Order_Form_Detail__c>();

        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[0].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[1].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        tmpOrderFormLineItemList.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                , ASI_CRM_Available__c = TRUE
                , ASI_CRM_Order_Form__c = tmpOrderFormList[2].id
                , ASI_CRM_Product_Name__c = tmpItemGroupList[0].id
                , ASI_CRM_Remark__c = 'TestRemark'
                , ASI_CRM_Sequence__c = 1//20170217 Elufa
        ));
        insert tmpOrderFormLineItemList;

        List<ASI_CRM_Order_Form_Customer_Relationship__c> tmpOFCRList = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[0].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[1].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[2].id));
        tmpOFCRList.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomerList[1].id, ASI_CRM_Order_Form__c = tmpOrderFormList[2].id));

        insert tmpOFCRList;

        List<ASI_CRM_Item_Group_Customer_Price__c> tmpIGCPList = new List<ASI_CRM_Item_Group_Customer_Price__c>();

        tmpIGCPList.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                , ASI_CRM_Customer__c = tmpCustomerList[0].id
                , ASI_CRM_Item_Group__c = tmpItemGroupList[0].id
                , ASI_CRM_Unit_Price_BT__c = 1
        ));
        tmpIGCPList.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                , ASI_CRM_Customer__c = tmpCustomerList[1].id
                , ASI_CRM_Item_Group__c = tmpItemGroupList[0].id
                , ASI_CRM_Unit_Price_BT__c = 1
        ));
        tmpIGCPList.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                , ASI_CRM_Customer__c = tmpCustomerList[2].id
                , ASI_CRM_Item_Group__c = tmpItemGroupList[0].id
                , ASI_CRM_Unit_Price_BT__c = 1
                , ASI_CRM_Promotion_Expiration_Date__c = date.today()
        ));
        insert tmpIGCPList;

        ASI_CRM_CN_SalesOrderRequestCtrller.lineItemList(tmpSalesOrderList[2].id);
        ASI_CRM_CN_SalesOrderRequestCtrller.normalProductList(tmpSalesOrderList[2].id, '', false);

        system.debug('testMethod8 end');
    }

    // 20190614
    @isTest
    static void testFindDeliverZoneByCustomer(){
        system.debug('testFindDeliverZoneByCustomer start');

        ASI_CRM_Region__c region1 = new ASI_CRM_Region__c (Name='20190620');
        insert region1;

        ASI_CRM_Division__c division1 = new ASI_CRM_Division__c(Name='20190620', ASI_CRM_Region__c=region1.Id);
        insert division1;

        ASI_CRM_CN_Area__c area1 = new ASI_CRM_CN_Area__c(Name='20190620', ASI_CRM_English_Name__c='20190620', ASI_CRM_Division__c=division1.Id);
        insert area1;

        ASI_CRM_City__c city1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190620', ASI_CRM_CN_Area__c=area1.Id);
        insert city1;

        ASI_CRM_CN_Channel__c channel1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel1;

        List<ASI_MFM_Sub_Channel__c> subChannelList = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel1.Id));
        subChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel1.Id));

        insert subChannelList;

        ASI_CRM_CN_Channel_Group__c ChannelGroup1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup1;

        ASI_CRM_CN_Channel__c newChannel1 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c=ChannelGroup1.Id);
        insert newChannel1;

        List<ASI_CRM_AccountsAdditionalField__c> custList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c cust1 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust1',
                        ASI_CRM_CN_Chi_Name__c = 'cust1',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c=subChannelList.get(0).Id,
                        ASI_CRM_CN_CCity__c=city1.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel1.Id
                );
        custList.add(cust1);

        ASI_CRM_AccountsAdditionalField__c cust2 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust2',
                        ASI_CRM_CN_Chi_Name__c = 'cust2',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c=subChannelList.get(0).Id,
                        ASI_CRM_CN_CCity__c=city1.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel1.Id
                );
        custList.add(cust2);

        ASI_CRM_AccountsAdditionalField__c cust3 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust3',
                        ASI_CRM_CN_Chi_Name__c = 'cust3',
                        ASI_CRM_CN_Commercial_Team__c = 'HQ/Hotel',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c=subChannelList.get(0).Id,
                        ASI_CRM_CN_CCity__c=city1.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel1.Id
                );
        custList.add(cust3);

        insert custList;

        List<ASI_FOC_Delivery_Zone__c> dzList = new List<ASI_FOC_Delivery_Zone__c>();
        ASI_FOC_Delivery_Zone__c dz1 =
                new ASI_FOC_Delivery_Zone__c(
                        Name = 'test1',
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'),
                        ASI_CRM_Customer__c = cust1.Id,
                        ASI_CRM_Channel__c = newChannel1.Id,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_FOC_City_To__c = city1.Id
                );
        dzList.add(dz1);

        ASI_FOC_Delivery_Zone__c dz2 =
                new ASI_FOC_Delivery_Zone__c(
                        Name = 'test1',
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'),
                        ASI_CRM_Channel__c = newChannel1.Id,
                        ASI_CRM_Commercial_Team__c = 'Prestige',
                        ASI_FOC_City_To__c = city1.Id
                );
        dzList.add(dz2);

        ASI_FOC_Delivery_Zone__c dz3 =
                new ASI_FOC_Delivery_Zone__c(
                        Name = 'test1',
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'),
                        ASI_CRM_Commercial_Team__c = 'HQ/Hotel',
                        ASI_FOC_City_To__c = city1.Id
                );
        dzList.add(dz3);

        insert dzList;

        List<ASI_KOR_Sales_Order_Request__c> soList = new List<ASI_KOR_Sales_Order_Request__c>();
        ASI_KOR_Sales_Order_Request__c so1 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust1.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        );
        soList.add(so1);

        ASI_KOR_Sales_Order_Request__c so2 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust2.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        soList.add(so2);

        ASI_KOR_Sales_Order_Request__c so3 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust3.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        soList.add(so3);

        insert soList;
        update soList;

        system.debug('testFindDeliverZoneByCustomer end');
    }

    // 20190621
    @isTest
    static void testUpdateSo() {
        system.debug('testUpdateSo start');

        ASI_CRM_Region__c region2 = new ASI_CRM_Region__c (Name='20190620');
        insert region2;

        ASI_CRM_Division__c division2 = new ASI_CRM_Division__c(Name='20190620', ASI_CRM_Region__c= region2.Id);
        insert division2;

        ASI_CRM_CN_Area__c area2 = new ASI_CRM_CN_Area__c(Name='20190620', ASI_CRM_English_Name__c='20190620', ASI_CRM_Division__c= division2.Id);
        insert area2;

        ASI_CRM_City__c city2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190620', ASI_CRM_CN_Area__c= area2.Id);
        insert city2;

        ASI_CRM_CN_Channel__c channel2 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel2;

        List<ASI_MFM_Sub_Channel__c> subChannelList2 = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList2.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel2.Id));
        subChannelList2.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel2.Id));

        insert subChannelList2;

        ASI_CRM_CN_Channel_Group__c ChannelGroup2 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup2;

        ASI_CRM_CN_Channel__c newChannel2 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c= ChannelGroup2.Id);
        insert newChannel2;

        List<ASI_CRM_AccountsAdditionalField__c> custList = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c cust4 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust4',
                        ASI_CRM_CN_Chi_Name__c = 'cust4',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c= subChannelList2.get(0).Id,
                        ASI_CRM_CN_CCity__c= city2.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel2.Id
                );
        insert cust4;

        ASI_KOR_Sales_Order_Request__c so4 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust4.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        insert so4;

        ASI_CRM_Promotion_Master__c prom1 =
                new ASI_CRM_Promotion_Master__c(
                        OwnerId = tempU.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                );
        insert prom1;

        ASI_MFM_Item_Group__c itemGp1 =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = '20190621-1',
                        ASI_MFM_Item_Group_Code__c = '20190621',
                        ASI_CRM_CN_Eng_Name__c = '20190621',
                        OwnerID = tempU.id,
                        ASI_CRM_Allocation_Information__c = true
                );
        insert itemGp1;

        ASI_KOR_Sales_Order_Transaction__c tran1 =
                new ASI_KOR_Sales_Order_Transaction__c(
                        ASI_CRM_CN_Product_Name__c = itemGp1.id,
                        ASI_KOR_Order_Qty__c = 1,
                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                        ASI_CRM_CN_Promotion_Code__c = prom1.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                        ASI_KOR_Sales_Order_Request__c = so4.id
                );
        insert tran1;

        try {
            so4.ASI_KOR_Order_Status__c = 'Submitted';
            update so4;
        }
        catch(Exception e) {

        }

        try {
            so4.ASI_KOR_Order_Status__c = 'Open';
            update so4;
        }
        catch(Exception e) {

        }

        try {
            so4.ASI_CRM_CN_Premium__c = true;
            update so4;
        }
        catch(Exception e) {

        }

        try {
            so4.ASI_CRM_CN_RTD__c = true;
            update so4;
        }
        catch(Exception e) {

        }

        system.debug('testUpdateSo end');
    }

    // 20190627
    @isTest
    static void testChangeCustomer() {
        system.debug('testChangeCustomer start');

        ASI_CRM_Region__c region3 = new ASI_CRM_Region__c (Name='20190627');
        insert region3;

        ASI_CRM_Division__c division3 = new ASI_CRM_Division__c(Name='20190627', ASI_CRM_Region__c=region3.Id);
        insert division3;

        ASI_CRM_CN_Area__c area3 = new ASI_CRM_CN_Area__c(Name='20190627', ASI_CRM_English_Name__c='20190627', ASI_CRM_Division__c=division3.Id);
        insert area3;

        List<ASI_CRM_City__c> cityList = new List<ASI_CRM_City__c>();
        ASI_CRM_City__c city3 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190627', ASI_CRM_CN_Area__c=area3.Id);
        cityList.add(city3);
        ASI_CRM_City__c city3_2 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190627', ASI_CRM_CN_Area__c=area3.Id);
        cityList.add(city3_2);
        insert cityList;

        ASI_CRM_CN_Channel__c channel3 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel3;

        List<ASI_MFM_Sub_Channel__c> subChannelList3 = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList3.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel3.Id));
        subChannelList3.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel3.Id));

        insert subChannelList3;

        ASI_CRM_CN_Channel_Group__c ChannelGroup3 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup3;

        ASI_CRM_CN_Channel__c newChannel3 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c=ChannelGroup3.Id);
        insert newChannel3;

        List<ASI_CRM_AccountsAdditionalField__c> custList3 = new List<ASI_CRM_AccountsAdditionalField__c>();
        ASI_CRM_AccountsAdditionalField__c cust5 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust5',
                        ASI_CRM_CN_Chi_Name__c = 'cust5',
                        ASI_CRM_CN_Commercial_Team__c = 'Prestige',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c=subChannelList3.get(0).Id,
                        ASI_CRM_CN_CCity__c=city3.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel3.Id
                );
        custList3.add(cust5);

        ASI_CRM_AccountsAdditionalField__c cust6 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust6',
                        ASI_CRM_CN_Chi_Name__c = 'cust6',
                        ASI_CRM_CN_Commercial_Team__c = 'Prestige',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c=subChannelList3.get(0).Id,
                        ASI_CRM_CN_CCity__c=city3_2.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel3.Id
                );
        custList3.add(cust6);

        insert custList3;

        List<ASI_FOC_Delivery_Zone__c> dzList3 = new List<ASI_FOC_Delivery_Zone__c>();
        ASI_FOC_Delivery_Zone__c dz4 =
                new ASI_FOC_Delivery_Zone__c(
                        Name = 'test1',
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'),
                        ASI_CRM_Customer__c = cust5.Id,
                        ASI_CRM_Channel__c = newChannel3.Id,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_FOC_City_To__c = city3.Id
                );
        dzList3.add(dz4);

        ASI_FOC_Delivery_Zone__c dz5 =
                new ASI_FOC_Delivery_Zone__c(
                        Name = 'test1',
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Delivery_Zone__cASI_FOC_CN_Delivery_Zone'),
                        ASI_CRM_Customer__c = cust6.Id,
                        ASI_CRM_Channel__c = newChannel3.Id,
                        ASI_CRM_Commercial_Team__c = 'Prestige',
                        ASI_FOC_City_To__c = city3_2.Id
                );
        dzList3.add(dz5);

        insert dzList3;

        ASI_KOR_Sales_Order_Request__c so5 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust5.Id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        insert so5;

        try {
            so5.ASI_CRM_CN_Customer__c = cust6.Id;
            update so5;
        }
        catch(Exception e) {

        }

        system.debug('testChangeCustomer end');
    }

    // 20190621
    @isTest
    static void testUpdateAllocation() {
        system.debug('testUpdateAllocation start');

        ASI_CRM_Region__c region2 = new ASI_CRM_Region__c (Name='20190621');
        insert region2;

        ASI_MFM_Item_Group__c itemGp2 =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = '20190621-2',
                        ASI_MFM_Item_Group_Code__c = '20190621',
                        ASI_CRM_CN_Eng_Name__c = '20190621',
                        OwnerID = tempU.id,
                        ASI_CRM_Allocation_Information__c = true
        );
        insert itemGp2;

        Set<Id> allocationIdSet = new Set<Id>();

        ASI_CRM_Item_Group_Allocation__c allocation =
                new ASI_CRM_Item_Group_Allocation__c(
                        ASI_CRM_Allocation_Quantity__c = 100,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_CRM_Effective_Date__c = date.today(),
                        ASI_CRM_Item_Group__c = itemGp2.id,
                        ASI_CRM_Region__c = region2.id,
                        ASI_CRM_UOM__c = 'CA',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
                );
        insert allocation;
        allocationIdSet.add(allocation.Id);
        ASI_CRM_CN_SalesOrderTriggerClass.updateAllocation(allocationIdSet);

        system.debug('testUpdateAllocation end');
    }

    // 20190627
    @isTest
    static void testCalculateRemainingQty() {
        system.debug('testCalculateRemainingQty start');

        ASI_CRM_Region__c region4 = new ASI_CRM_Region__c (Name='20190627-2');
        insert region4;

        ASI_CRM_Division__c division4 = new ASI_CRM_Division__c(Name='20190627-2', ASI_CRM_Region__c=region4.Id);
        insert division4;

        ASI_CRM_CN_Area__c area4 = new ASI_CRM_CN_Area__c(Name='20190627-2', ASI_CRM_English_Name__c='20190627-2', ASI_CRM_Division__c=division4.Id);
        insert area4;

        ASI_CRM_City__c city4 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190627-2', ASI_CRM_CN_Area__c=area4.Id);
        insert city4;

        ASI_CRM_CN_Channel__c channel4 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel4;

        List<ASI_MFM_Sub_Channel__c> subChannelList4 = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList4.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel4.Id));
        subChannelList4.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel4.Id));

        insert subChannelList4;

        ASI_MFM_Item_Group__c itemGp4 =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = '20190627',
                        ASI_MFM_Item_Group_Code__c = '20190627',
                        ASI_CRM_CN_Eng_Name__c = '20190627',
                        OwnerID = tempU.id,
                        ASI_CRM_Allocation_Information__c = true
                );
        insert itemGp4;

        ASI_CRM_Item_Group_Allocation__c allocation2 =
                new ASI_CRM_Item_Group_Allocation__c(
                        ASI_CRM_Allocation_Quantity__c = 1,
                        ASI_CRM_MTD_Order_Quantity__c = 100,
                        ASI_CRM_Inactive__c = false,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_CRM_Effective_Date__c = date.today(),
                        ASI_CRM_Item_Group__c = itemGp4.id,
                        ASI_CRM_Region__c = region4.id,
                        ASI_CRM_UOM__c = 'CA',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
                );
        insert allocation2;

        ASI_CRM_CN_Channel_Group__c ChannelGroup4 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup4;

        ASI_CRM_CN_Channel__c newChannel4 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c= ChannelGroup4.Id);
        insert newChannel4;

        ASI_CRM_AccountsAdditionalField__c cust7 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust7',
                        ASI_CRM_CN_Chi_Name__c = 'cust7',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c=subChannelList4.get(0).Id,
                        ASI_CRM_CN_CCity__c=city4.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel4.Id
                );
        insert cust7;

        ASI_KOR_Sales_Order_Request__c so6 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust7.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        ASI_CRM_SG_Order_Date__c = date.today(),
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        insert so6;

        ASI_CRM_Promotion_Master__c promotionCode1 =
            new ASI_CRM_Promotion_Master__c(
                    OwnerId = tempU.id,
                    recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        );
        insert promotionCode1;

        ASI_KOR_Sales_Order_Transaction__c lineItem1 =
                new ASI_KOR_Sales_Order_Transaction__c(
                        ASI_CRM_CN_Product_Name__c = itemGp4.id,
                        ASI_KOR_Order_Qty__c = 100,
                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                        ASI_CRM_CN_Promotion_Code__c = promotionCode1.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                        ASI_KOR_Sales_Order_Request__c = so6.id
        );
        insert lineItem1;

        try {
            so6.ASI_KOR_Order_Status__c = 'Submitted';
            update so6;
        }
        catch(Exception e) {

        }

        system.debug('testCalculateRemainingQty end');
    }

    @isTest
    static void testCalculateRemainingQty2() {
        system.debug('testCalculateRemainingQty2 start');

        ASI_CRM_Region__c region4_1 = new ASI_CRM_Region__c (Name='20190627-2-1');
        insert region4_1;

        ASI_CRM_Division__c division4_1 = new ASI_CRM_Division__c(Name='20190627-2-1', ASI_CRM_Region__c= region4_1.Id);
        insert division4_1;

        ASI_CRM_CN_Area__c area4_1 = new ASI_CRM_CN_Area__c(Name='20190627-2-1', ASI_CRM_English_Name__c='20190627-2-1', ASI_CRM_Division__c= division4_1.Id);
        insert area4_1;

        ASI_CRM_City__c city4_1 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190627-2-1', ASI_CRM_CN_Area__c= area4_1.Id);
        insert city4_1;

        ASI_CRM_CN_Channel__c channel4_1 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel4_1;

        List<ASI_MFM_Sub_Channel__c> subChannelList4_1 = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList4_1.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel4_1.Id));
        subChannelList4_1.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel4_1.Id));

        insert subChannelList4_1;

        ASI_MFM_Item_Group__c itemGp4_1 =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = '20190627',
                        ASI_MFM_Item_Group_Code__c = '20190627',
                        ASI_CRM_CN_Eng_Name__c = '20190627',
                        OwnerID = tempU.id,
                        ASI_CRM_Allocation_Information__c = true
                );
        insert itemGp4_1;

        ASI_CRM_Item_Group_Allocation__c allocation2_1 =
                new ASI_CRM_Item_Group_Allocation__c(
                        ASI_CRM_Allocation_Quantity__c = 1,
                        ASI_CRM_MTD_Order_Quantity__c = 100,
                        ASI_CRM_Inactive__c = false,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_CRM_Effective_Date__c = date.today(),
                        ASI_CRM_Item_Group__c = itemGp4_1.id,
                        ASI_CRM_Region__c = region4_1.id,
                        ASI_CRM_UOM__c = 'CA',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
                );
        insert allocation2_1;

        ASI_CRM_CN_Channel_Group__c ChannelGroup4_1 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup4_1;

        ASI_CRM_CN_Channel__c newChannel4_1 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c= ChannelGroup4_1.Id);
        insert newChannel4_1;

        ASI_CRM_AccountsAdditionalField__c cust7_1 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust7_1',
                        ASI_CRM_CN_Chi_Name__c = 'cust7_1',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c= subChannelList4_1.get(0).Id,
                        ASI_CRM_CN_CCity__c= city4_1.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel4_1.Id
                );
        insert cust7_1;

        ASI_KOR_Sales_Order_Request__c so6_1 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Submitted',
                        ASI_CRM_CN_Customer__c = cust7_1.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        ASI_CRM_SG_Order_Date__c = date.today(),
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        insert so6_1;

        ASI_CRM_Promotion_Master__c promotionCode1_1 =
                new ASI_CRM_Promotion_Master__c(
                        OwnerId = tempU.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                );
        insert promotionCode1_1;

        ASI_KOR_Sales_Order_Transaction__c lineItem1_1 =
                new ASI_KOR_Sales_Order_Transaction__c(
                        ASI_CRM_CN_Product_Name__c = itemGp4_1.id,
                        ASI_KOR_Order_Qty__c = 100,
                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                        ASI_CRM_CN_Promotion_Code__c = promotionCode1_1.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                        ASI_KOR_Sales_Order_Request__c = so6_1.id
                );
        insert lineItem1_1;

        update allocation2_1;

        system.debug('testCalculateRemainingQty2 end');
    }

    @isTest
    static void testProcessTraceabilityAndSeason() {
        system.debug('testProcessTraceabilityAndSeason start');

        ASI_CRM_Region__c region5 = new ASI_CRM_Region__c (Name='HQ');
        insert region5;

        ASI_CRM_Division__c division5 = new ASI_CRM_Division__c(Name='20190726', ASI_CRM_Region__c= region5.Id);
        insert division5;

        ASI_CRM_CN_Area__c area5 = new ASI_CRM_CN_Area__c(Name='20190726', ASI_CRM_English_Name__c='20190726', ASI_CRM_Division__c= division5.Id);
        insert area5;

        ASI_CRM_City__c city5 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190726', ASI_CRM_CN_Area__c= area5.Id);
        insert city5;

        ASI_CRM_CN_Channel__c channel5 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel5;

        List<ASI_MFM_Sub_Channel__c> subChannelList5 = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList5.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel5.Id));
        subChannelList5.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel5.Id));

        insert subChannelList5;

        ASI_CRM_Season__c season1 =
                new ASI_CRM_Season__c(
                        ASI_CRM_Region__c = 'Headquarter',
                        ASI_CRM_Status__c = 'Active',
                        ASI_CRM_Start_Date__c = date.today().addDays(-7),
                        ASI_CRM_End_Date__c = date.today().addDays(7)
                );
        insert season1;

        ASI_HK_CRM_Product_Category__c category1 =
                new ASI_HK_CRM_Product_Category__c(
                        Name='20190726',
                        ASI_CRM_CN_Chinese_Name__c='20190726',
                        ASI_HK_CRM_English_Name__c='20190726',
                        ASI_HK_CRM_Sequence__c=1,
                        ASI_CRM_CN_9L_Conversion_Factor__c=1,
                        ASI_CRM_JDE_Category_English_Name__c = 'CHAMPAGNE',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category'));
        insert category1;

        ASI_TH_CRM_Sub_category__c subCategory1 =
                new ASI_TH_CRM_Sub_category__c(
                        Name='20190726',
                        ASI_CRM_CN_Product_Category__c=category1.Id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category'));
        insert subCategory1;

        ASI_MFM_Brand__c brand1 =
                new ASI_MFM_Brand__c(
                        Name='20190726',
                        ASI_TH_CRM_Sub_category__c = subCategory1.Id,
                        Recordtypeid=ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand'));
        insert brand1;

        ASI_MFM_Sub_brand__c subBrand1 =
                new ASI_MFM_Sub_brand__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                        Name = '20190726',
                        OwnerId = tempU.id,
                        ASI_MFM_Sub_brand_Code__c = '1',
                        ASI_HK_CRM_English_Name__c = '20190726',
                        ASI_MFM_Brand__c = brand1.Id
                );
        insert subBrand1;

        ASI_MFM_Item_Group__c itemGp5 =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = '20190726',
                        ASI_MFM_Item_Group_Code__c = '20190726',
                        ASI_CRM_CN_Eng_Name__c = '20190726',
                        OwnerID = tempU.id,
                        ASI_CRM_Allocation_Information__c = true,
                        ASI_MFM_Sub_brand__c = subBrand1.Id,
                        ASI_CRM_Selective__c = true
                );
        insert itemGp5;

        ASI_MFM_SKU_Code__c skuCode1 =
                new ASI_MFM_SKU_Code__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU'),
                        Name = '20190726',
                        ASI_CRM_SKU_Status__c = '000',
                        ASI_MFM_Item_Group__c = itemGp5.id,
                        ASI_CRM_Traceability_Puma__c = '20190726',
                        OwnerID = tempU.id
                );
        insert skuCode1;

        ASI_CRM_Item_Group_Allocation__c allocation3 =
                new ASI_CRM_Item_Group_Allocation__c(
                        ASI_CRM_Allocation_Quantity__c = 1,
                        ASI_CRM_MTD_Order_Quantity__c = 100,
                        ASI_CRM_Inactive__c = false,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_CRM_Effective_Date__c = date.today(),
                        ASI_CRM_Item_Group__c = itemGp5.id,
                        ASI_CRM_Region__c = region5.id,
                        ASI_CRM_UOM__c = 'CA',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
                );
        insert allocation3;

        ASI_CRM_CN_Channel_Group__c ChannelGroup5 =
                new ASI_CRM_CN_Channel_Group__c(
                    Name = 'OFF MOT 1',
                    ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                    ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                    ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                    ASI_CRM_External_ID__c = 'CN_OFF MOT',
                    ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup5;

        ASI_CRM_CN_Channel__c newChannel5 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c= ChannelGroup5.Id);
        insert newChannel5;

        ASI_CRM_AccountsAdditionalField__c cust8 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust8',
                        ASI_CRM_CN_Chi_Name__c = 'cust8',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c= subChannelList5.get(0).Id,
                        ASI_CRM_CN_CCity__c= city5.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel5.Id
                );
        insert cust8;

        ASI_KOR_Sales_Order_Request__c so6 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust8.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        ASI_CRM_SG_Order_Date__c = date.today(),
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        insert so6;

        ASI_CRM_Promotion_Master__c promotionCode2 =
                new ASI_CRM_Promotion_Master__c(
                        OwnerId = tempU.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                );
        insert promotionCode2;

        ASI_KOR_Sales_Order_Transaction__c lineItem1 =
                new ASI_KOR_Sales_Order_Transaction__c(
                        ASI_CRM_CN_Product_Name__c = itemGp5.id,
                        ASI_KOR_Order_Qty__c = 100,
                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                        ASI_CRM_CN_Promotion_Code__c = promotionCode2.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                        ASI_KOR_Sales_Order_Request__c = so6.id
                );
        insert lineItem1;

        system.debug('testProcessTraceabilityAndSeason end');
    }

    @isTest
    static void testProcessSeason1() {
        system.debug('testProcessSeason1 start');

        ASI_CRM_Region__c region6 = new ASI_CRM_Region__c (Name='HQ');
        insert region6;

        ASI_CRM_Division__c division6 = new ASI_CRM_Division__c(Name='20190726', ASI_CRM_Region__c= region6.Id);
        insert division6;

        ASI_CRM_CN_Area__c area6 = new ASI_CRM_CN_Area__c(Name='20190726', ASI_CRM_English_Name__c='20190726', ASI_CRM_Division__c= division6.Id);
        insert area6;

        ASI_CRM_City__c city6 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190726', ASI_CRM_CN_Area__c= area6.Id);
        insert city6;

        ASI_CRM_CN_Channel__c channel6 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel6;

        List<ASI_MFM_Sub_Channel__c> subChannelList6 = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList6.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel6.Id));
        subChannelList6.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel6.Id));

        insert subChannelList6;

        ASI_CRM_Season__c season2 =
                new ASI_CRM_Season__c(
                        ASI_CRM_Region__c = 'Headquarter',
                        ASI_CRM_Status__c = 'Active',
                        ASI_CRM_Start_Date__c = date.today().addDays(-7),
                        ASI_CRM_End_Date__c = date.today().addDays(7)
                );
        insert season2;


        ASI_MFM_Item_Group__c itemGp6 =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = '20190726',
                        ASI_MFM_Item_Group_Code__c = '20190726',
                        ASI_CRM_CN_Eng_Name__c = '20190726',
                        OwnerID = tempU.id,
                        ASI_CRM_Allocation_Information__c = true,
                        ASI_CRM_Selective__c = true
                );
        insert itemGp6;

        ASI_MFM_SKU_Code__c skuCode2 =
                new ASI_MFM_SKU_Code__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU'),
                        Name = '20190726',
                        ASI_CRM_SKU_Status__c = '000',
                        ASI_MFM_Item_Group__c = itemGp6.id,
                        ASI_CRM_Traceability_Puma__c = '20190726',
                        OwnerID = tempU.id
                );
        insert skuCode2;

        ASI_CRM_Item_Group_Allocation__c allocation4 =
                new ASI_CRM_Item_Group_Allocation__c(
                        ASI_CRM_Allocation_Quantity__c = 1,
                        ASI_CRM_MTD_Order_Quantity__c = 100,
                        ASI_CRM_Inactive__c = false,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_CRM_Effective_Date__c = date.today(),
                        ASI_CRM_Item_Group__c = itemGp6.id,
                        ASI_CRM_Region__c = region6.id,
                        ASI_CRM_UOM__c = 'CA',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
                );
        insert allocation4;

        ASI_CRM_CN_Channel_Group__c ChannelGroup6 =
                new ASI_CRM_CN_Channel_Group__c(
                    Name = 'OFF MOT 1',
                    ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                    ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                    ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                    ASI_CRM_External_ID__c = 'CN_OFF MOT',
                    ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup6;

        ASI_CRM_CN_Channel__c newChannel6 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c= ChannelGroup6.Id);
        insert newChannel6;

        ASI_CRM_AccountsAdditionalField__c cust9 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust9',
                        ASI_CRM_CN_Chi_Name__c = 'cust9',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c= subChannelList6.get(0).Id,
                        ASI_CRM_CN_CCity__c= city6.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel6.Id
                );
        insert cust9;

        ASI_KOR_Sales_Order_Request__c so7 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust9.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        ASI_CRM_SG_Order_Date__c = date.today(),
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        insert so7;

        ASI_CRM_Promotion_Master__c promotionCode3 =
                new ASI_CRM_Promotion_Master__c(
                        OwnerId = tempU.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                );
        insert promotionCode3;

        ASI_KOR_Sales_Order_Transaction__c lineItem2 =
                new ASI_KOR_Sales_Order_Transaction__c(
                        ASI_CRM_CN_Product_Name__c = itemGp6.id,
                        ASI_KOR_Order_Qty__c = 100,
                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                        ASI_CRM_CN_Promotion_Code__c = promotionCode3.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                        ASI_KOR_Sales_Order_Request__c = so7.id
                );
        insert lineItem2;

        system.debug('testProcessSeason1 end');
    }

    @isTest
    static void testProcessSeason2() {
        system.debug('testProcessSeason2 start');

        ASI_CRM_Region__c region7 = new ASI_CRM_Region__c (Name='HQ');
        insert region7;

        ASI_CRM_Division__c division7 = new ASI_CRM_Division__c(Name='20190726', ASI_CRM_Region__c= region7.Id);
        insert division7;

        ASI_CRM_CN_Area__c area7 = new ASI_CRM_CN_Area__c(Name='20190726', ASI_CRM_English_Name__c='20190726', ASI_CRM_Division__c= division7.Id);
        insert area7;

        ASI_CRM_City__c city7 = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='20190726', ASI_CRM_CN_Area__c= area7.Id);
        insert city7;

        ASI_CRM_CN_Channel__c channel7 = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel7;

        List<ASI_MFM_Sub_Channel__c> subChannelList7 = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList7.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel7.Id));
        subChannelList7.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel7.Id));

        insert subChannelList7;

        ASI_CRM_Season__c season3 =
                new ASI_CRM_Season__c(
                        ASI_CRM_Region__c = 'Headquarter',
                        ASI_CRM_Status__c = 'Active',
                        ASI_CRM_Start_Date__c = date.today().addDays(-7),
                        ASI_CRM_End_Date__c = date.today().addDays(7)
                );
        insert season3;

        ASI_HK_CRM_Product_Category__c category2 =
                new ASI_HK_CRM_Product_Category__c(
                        Name='20190726',
                        ASI_CRM_CN_Chinese_Name__c='20190726',
                        ASI_HK_CRM_English_Name__c='20190726',
                        ASI_HK_CRM_Sequence__c=1,
                        ASI_CRM_CN_9L_Conversion_Factor__c=1,
                        ASI_CRM_JDE_Category_English_Name__c = 'WINE',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Product_Category__cASI_CRM_CN_Product_Category'));
        insert category2;

        ASI_TH_CRM_Sub_category__c subCategory2 =
                new ASI_TH_CRM_Sub_category__c(
                        Name='20190726',
                        ASI_CRM_CN_Product_Category__c= category2.Id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Sub_category__cASI_CRM_CN_Sub_Category'));
        insert subCategory2;

        ASI_MFM_Brand__c brand2 =
                new ASI_MFM_Brand__c(
                        Name='20190726',
                        ASI_TH_CRM_Sub_category__c = subCategory2.Id,
                        Recordtypeid=ASI_MFM_Function.checkRecordType('ASI_MFM_Brand__c','ASI_MFM_CN_Brand'));
        insert brand2;

        ASI_MFM_Sub_brand__c subBrand2 =
                new ASI_MFM_Sub_brand__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                        Name = '20190726',
                        OwnerId = tempU.id,
                        ASI_MFM_Sub_brand_Code__c = '1',
                        ASI_HK_CRM_English_Name__c = '20190726',
                        ASI_MFM_Brand__c = brand2.Id
                );
        insert subBrand2;

        ASI_MFM_Item_Group__c itemGp7 =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = '20190726',
                        ASI_MFM_Item_Group_Code__c = '20190726',
                        ASI_CRM_CN_Eng_Name__c = '20190726',
                        OwnerID = tempU.id,
                        ASI_CRM_Allocation_Information__c = true,
                        ASI_MFM_Sub_brand__c = subBrand2.Id
                );
        insert itemGp7;

        ASI_MFM_SKU_Code__c skuCode3 =
                new ASI_MFM_SKU_Code__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU'),
                        Name = '20190726',
                        ASI_CRM_SKU_Status__c = '000',
                        ASI_MFM_Item_Group__c = itemGp7.id,
                        ASI_CRM_Traceability_Puma__c = '20190726',
                        OwnerID = tempU.id
                );
        insert skuCode3;

        ASI_CRM_Item_Group_Allocation__c allocation5 =
                new ASI_CRM_Item_Group_Allocation__c(
                        ASI_CRM_Allocation_Quantity__c = 1,
                        ASI_CRM_MTD_Order_Quantity__c = 100,
                        ASI_CRM_Inactive__c = false,
                        ASI_CRM_Commercial_Team__c = 'Premium',
                        ASI_CRM_Effective_Date__c = date.today(),
                        ASI_CRM_Item_Group__c = itemGp7.id,
                        ASI_CRM_Region__c = region7.id,
                        ASI_CRM_UOM__c = 'CA',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Allocation__cASI_CRM_CN_Item_Group_Allocation')
                );
        insert allocation5;

        ASI_CRM_CN_Channel_Group__c ChannelGroup7 = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT 1',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup7;

        ASI_CRM_CN_Channel__c newChannel7 =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c= ChannelGroup7.Id);
        insert newChannel7;

        ASI_CRM_AccountsAdditionalField__c cust10 =
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'cust10',
                        ASI_CRM_CN_Chi_Name__c = 'cust10',
                        ASI_CRM_CN_Commercial_Team__c = 'Presitge',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c= subChannelList7.get(0).Id,
                        ASI_CRM_CN_CCity__c= city7.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel7.Id
                );
        insert cust10;

        ASI_KOR_Sales_Order_Request__c so8 =
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = cust10.id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        ASI_CRM_CN_Premium__c = false,
                        ASI_CRM_SG_Order_Date__c = date.today(),
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                );
        insert so8;

        ASI_CRM_Promotion_Master__c promotionCode4 =
                new ASI_CRM_Promotion_Master__c(
                        OwnerId = tempU.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                );
        insert promotionCode4;

        ASI_KOR_Sales_Order_Transaction__c lineItem3 =
                new ASI_KOR_Sales_Order_Transaction__c(
                        ASI_CRM_CN_Product_Name__c = itemGp7.id,
                        ASI_KOR_Order_Qty__c = 100,
                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                        ASI_CRM_CN_Promotion_Code__c = promotionCode4.id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                        ASI_KOR_Sales_Order_Request__c = so8.id,
                        ASI_CRM_Traceability__c = true
                );
        insert lineItem3;

        system.debug('testProcessSeason2 end');
    }
}