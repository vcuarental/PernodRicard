@istest
Private class ASI_CRM_CN_MassUploadByBatch_Test {

    
    Private static List<ASI_MFM_Sub_brand__c> tmpSB = new List<ASI_MFM_Sub_brand__c>();
    
    Private static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
    
    Private static List<ASI_CRM_CN_Brand_Group__c> tmpBrandGroup = new List<ASI_CRM_CN_Brand_Group__c>();
    
    Private Static List<ASI_KOR_Sales_Order_Request__c> tmpSalesOrder = new List<ASI_KOR_Sales_Order_Request__c>();
    
    Private Static List<ASI_KOR_Sales_Order_Transaction__c> tmpSalesOrderLineItem = new List<ASI_KOR_Sales_Order_Transaction__c>();
    
    Private Static List<ASI_CRM_Order_Form__c> tmpOrderForm = new List<ASI_CRM_Order_Form__c>();
    
    Private Static List<ASI_CRM_Order_Form_Detail__c> tmpOrderFormLineItem = new List<ASI_CRM_Order_Form_Detail__c>();
    
    Private Static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
    
    Private Static List<ASI_CRM_CN_T1_Price__c> tmpT1Price = new List<ASI_CRM_CN_T1_Price__c>();
    
    Private Static List<ASI_CRM_Order_Form_Customer_Relationship__c> tmpOFCR = new List<ASI_CRM_Order_Form_Customer_Relationship__c>();
    
    Private Static List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
    
    Private Static List<ASI_CRM_Item_Group_Customer_Price__c> tmpIGCP = new List<ASI_CRM_Item_Group_Customer_Price__c>();
    
    Private static List<ASI_CRM_Fix_Approval_Route__c> tmpFixRoute = new List<ASI_CRM_Fix_Approval_Route__c>();
    
    Private static List<ASI_CRM_Dynamic_Approval_Route__c> tmpDynamicRoute = new List<ASI_CRM_Dynamic_Approval_Route__c>();
    
    Private static List<ASI_CRM_Promotion_Master__c> tmpPromotionMaster = new List<ASI_CRM_Promotion_Master__c>();
    
    Private Static List<ASI_MFM_Sub_Channel__c> tmpSubChannel = new List<ASI_MFM_Sub_Channel__c>();
    
    Private TestMethod Static void uploadTest(){
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = 'Test', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - eCommerce'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - VIP'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - HQ'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id, ASI_CRM_CN_Approver_2__c = tempU.id, ASI_CRM_CN_Type__c='Sales Order - RTD'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = '', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Sales Order - IHBR'));
        
        insert tmpFixRoute;
        
        tmpPromotionMaster.add(new ASI_CRM_Promotion_Master__c(	OwnerId = tempU.id
                                                               , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                                                               , Name = 'B2G1'
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
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_JDE_Code_RTD__c = '555', ASI_CRM_CN_JDE_Code__c = '111', Name='TEST1',
                                                               ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, 
                                                               ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'))); 
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
                                                   , ASI_MFM_Item_Group_External_ID__c = 'TestItemGroupCode'
                                                  ));
        insert tmpItemGroup;
        
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
                                                             , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                             , ASI_CRM_Unit_Price_BT__c = 1
                                                            ));
        tmpIGCP.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                                                             , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                             , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                             , ASI_CRM_Unit_Price_BT__c = 1
                                                            ));
        insert tmpIGCP;
        
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
    	insert tmpOrderForm;
        
        tmpOrderFormLineItem.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                  , ASI_CRM_Available__c = TRUE
                                                                  , ASI_CRM_Order_Form__c = tmpOrderForm[0].id
                                                                  , ASI_CRM_Product_Name__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Remark__c = 'TestRemark'
                                                                 ));
        tmpOrderFormLineItem.add(new ASI_CRM_Order_Form_Detail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail')
                                                                  , ASI_CRM_Available__c = TRUE
                                                                  , ASI_CRM_Order_Form__c = tmpOrderForm[1].id
                                                                  , ASI_CRM_Product_Name__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Remark__c = 'TestRemark'
                                                                 ));
        
        insert tmpOrderFormLineItem;
        
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_CN_RTD__c = FALSE
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_CN_RTD__c = True
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        tmpSalesOrder.add(new ASI_KOR_Sales_Order_Request__c(OwnerId = tempU.id
                                                             , ASI_KOR_Order_Status__c = 'Open'
                                                             , ASI_CRM_CN_Customer__c = tmpCustomer[0].id
                                                             , ASI_CRM_CN_RTD__c = FALSE
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
                                                            ));
        
        insert tmpSalesOrder;
        
        tmpOFCR.add(new ASI_CRM_Order_Form_Customer_Relationship__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'), ASI_CRM_Customer__c = tmpCustomer[0].id, ASI_CRM_Order_Form__c = tmpOrderForm[0].id));
        
        insert tmpOFCR;
        
        test.startTest();
        
        ASI_CRM_CN_MassUploadByBatch_Controller tmpUploadCtrller = new ASI_CRM_CN_MassUploadByBatch_Controller();
        
        tmpUploadCtrller.ObjAPIName = 'ASI_KOR_Sales_Order_Transaction__c';
        tmpUploadCtrller.parentID = tmpSalesOrder[2].id;
        tmpUploadCtrller.recordtypeName = 'CN SalesOrder Item';
        tmpUploadCtrller.parentField = 'ASI_KOR_Sales_Order_Request__c';
        tmpUploadCtrller.fields = 'ASI_CRM_CN_Product_Name__c,ASI_KOR_Order_Qty__c,ASI_CRM_UOM_Text__c,ASI_CRM_CN_Unit_Price_BT_with_VAT__c,ASI_CRM_CN_Free_Qty_BT__c,ASI_CRM_CN_Promotion_Code__c,ASI_CRM_CN_Remark__c';
        tmpUploadCtrller.fieldsLabel = 'Item Group ID(Auto generated when download),Order Quantity(Wholesaler Input),UOM(BOTTLE/CASE)(Wholesaler input),Unit Price Per Bottle,Free Qty,Promotion Code,Remark';
        tmpUploadCtrller.lookupEXID = 'ASI_MFM_Item_Group__c/ASI_CRM_CN_Product_Name__c:Item Group Recordtype&RecordTypeid,Item Group ID(Auto generated when download)&ASI_MFM_Item_Group_External_ID__c;ASI_CRM_Promotion_Master__c/ASI_CRM_CN_Promotion_Code__c:Promotion Master Recordtype&RecordTypeid,Promotion Code&name';
        tmpUploadCtrller.template = 'OrderTemplate';
        tmpUploadCtrller.report = '';
        tmpUploadCtrller.opt_allOrNone = true;
        tmpUploadCtrller.currentPageURL = tmpSalesOrder[2].id;
        tmpUploadCtrller.inlineVF = true;
        tmpUploadCtrller.defaultValues = 'Sales Order Request Recordtype:CN SalesOrder;Item Group Recordtype:CN CRM Item Group;Promotion Master Recordtype:CN Promotion Master;headerId:' + tmpSalesOrder[2].id;
        tmpUploadCtrller.recEXID = 'Item Group ID(Auto generated when download);headerId';
        tmpUploadCtrller.recEXIDcol = 'ASI_CRM_CN_SOT_EXID__c';
        tmpUploadCtrller.parentObjectAPIName = 'ASI_KOR_Sales_Order_Request__c';
        tmpUploadCtrller.ParentObjectUploadMsg = 'ASI_CRM_CN_SOT_Msg_Log__c';
        tmpUploadCtrller.upsertmode = true;
        tmpUploadCtrller.batchMode = true;
        tmpUploadCtrller.emailNotification = false;
        tmpUploadCtrller.namefile = '2015-05-05.csv';
        tmpUploadCtrller.contentFile = blob.valueOf('Item Group ID(Auto generated when download),Order Quantity(Wholesaler Input),UOM(BOTTLE/CASE)(Wholesaler input),Unit Price Per Bottle,Free Qty,Promotion Code,Remark\rTestItemGroupCode,8,CASE,,,,');
        tmpUploadCtrller.filesize = 2000;
        tmpUploadCtrller.dummyVar = NULL;
        
        tmpUploadCtrller.uploadCSVByBatch();
        tmpUploadCtrller.uploadCSV();
        
        tmpUploadCtrller.fields = 'ASI_CRM_CN_Promotion_Expiration_Date__c,ASI_CRM_ETL_Complete__c,ASI_CRM_CN_Product_Name__c,ASI_KOR_Order_Qty__c,ASI_CRM_UOM_Text__c,ASI_CRM_CN_Unit_Price_BT_with_VAT__c,ASI_CRM_CN_Free_Qty_BT__c,ASI_CRM_CN_Promotion_Code__c,ASI_CRM_CN_Remark__c';
        tmpUploadCtrller.fieldsLabel = 'Date,ETL,Item Group ID(Auto generated when download),Order Quantity(Wholesaler Input),UOM(BOTTLE/CASE)(Wholesaler input),Unit Price Per Bottle,Free Qty,Promotion Code,Remark';
        tmpUploadCtrller.contentFile = blob.valueOf('Date,ETL,Item Group ID(Auto generated when download),Order Quantity(Wholesaler Input),UOM(BOTTLE/CASE)(Wholesaler input),Unit Price Per Bottle,Free Qty,Promotion Code,Remark\r2015/1/1,true,TestItemGroupCode,2,CASE,0,99,B2G1,test');
        
        tmpUploadCtrller.uploadCSVByBatch();
        tmpUploadCtrller.uploadCSV();
        
        tmpUploadCtrller.fields = 'ASI_CRM_CN_Promotion_Expiration_Date__c,ASI_CRM_ETL_Complete__c,ASI_CRM_CN_Product_Name__c,ASI_KOR_Order_Qty__c,ASI_CRM_UOM_Text__c,ASI_CRM_CN_Unit_Price_BT_with_VAT__c,ASI_CRM_CN_Free_Qty_BT__c,ASI_CRM_CN_Promotion_Code__c,ASI_CRM_CN_Remark__c';
        tmpUploadCtrller.fieldsLabel = 'Date,ETL,Item Group ID(Auto generated when download),Order Quantity(Wholesaler Input),UOM(BOTTLE/CASE)(Wholesaler input),Unit Price Per Bottle,Free Qty,Promotion Code,Remark';
        tmpUploadCtrller.contentFile = blob.valueOf('Date,ETL,Item Group ID(Auto generated when download),Order Quantity(Wholesaler Input),UOM(BOTTLE/CASE)(Wholesaler input),Unit Price Per Bottle,Free Qty,Promotion Code,Remark\r2015/1/1,OK,TestItemGroupCode,3,CASE,0,99,B2G1,test');
        
        tmpUploadCtrller.uploadCSVByBatch();
        tmpUploadCtrller.uploadCSV();
        
        for(String a : tmpUploadCtrller.StatusMsgs)
        {
            
        }
        
        test.stopTest();
    }

    private testMethod static void testUploadCoveredOutlet(){
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='Central Region',RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Region__cASI_CRM_CN_Region'));
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;

        ASI_CRM_CN_Channel_Group__c ChannelGroup = new ASI_CRM_CN_Channel_Group__c(
            Name = 'OFF MOT',
            ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
            ASI_CRM_Channel_Group_Code__c = 'CN_OFF MOT',
            ASI_CRM_External_ID__c = 'CN_OFF MOT',
            ASI_CRM_Sequence__c = 8
        );
        insert ChannelGroup;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(Name='KTV',ASI_CRM_BC_Rate__c=98,ASI_CRM_CN_On_Off__c='ON',ASI_CRM_For_Outlet__c=true,RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),ASI_CRM_For_Contract__c=TRUE, ASI_CRM_CN_Channel_Group__c=ChannelGroup.Id);
        insert channel;

        //Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');

        List<ASI_CRM_AccountsAdditionalField__c> Customers = new List<ASI_CRM_AccountsAdditionalField__c>();
        //Customers.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Commercial_Team__c = 'Premium',RecordTypeId=rtWS,Name='TEST', ASI_CRM_CN_Image__c='Iconic',ASI_CRM_CN_CCity__c=city.Id,ASI_CRM_CN_NewChannel__c=channel.Id));
        Customers.add(
            new ASI_CRM_AccountsAdditionalField__c(
                ASI_CRM_CN_Commercial_Team__c = 'Premium',
                RecordTypeId = rtOutlet, Name = 'TEST',
                ASI_CRM_CN_Image__c = 'Iconic',
                ASI_CRM_CN_CCity__c = city.Id,
                ASI_CRM_CN_NewChannel__c = channel.Id,
                ASI_CRM_Channel_Group__c = ChannelGroup.Id
            )
        );
        insert Customers;

        User currentUser = [SELECT Id, Name, ManagerId, ASI_CRM_CN_Prefix__c FROM User WHERE Id =:UserInfo.getUserId()];

        List<ASI_HK_CRM_Running_Number__c> rns = new List<ASI_HK_CRM_Running_Number__c>();
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_Contract__c', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_TH_CRM_PaymentRequest__c', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        if(!String.isBlank(currentUser.ASI_CRM_CN_Prefix__c))
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_'+currentUser.ASI_CRM_CN_Prefix__c, RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        else{
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_NULL', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
            rns.add(new ASI_HK_CRM_Running_Number__c(ASI_HK_CRM_Object_Name__c='ASI_CRM_CN_ContractPONo_', RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Running_Number__cASI_CN_Running_Number')));
        }
        insert rns;

        Profile p = [SELECT Id FROM Profile where name = '系统管理员' or name = 'System Administrator'];
        List<User> LUser = new List<User>();
        LUser.add(new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ManagerId=UserInfo.getUserId(),
            LocaleSidKey='en_US', ProfileId = p.Id, ASI_CRM_Sales_Team__c = 'a',
            TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c1@testing123.com', CompanyName = 'Pernod Ricard China'));
        insert LUser[0];

        List<User> userList= new List<User> ();
        userList.add(new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, ManagerId = LUser[0].Id,
            TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c2@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        userList.add(new User(Alias = 'standts', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', Username='standarduser_c3@testing123.com', CompanyName = 'Pernod Ricard China', ASI_CRM_Sales_Team__c = 'a'));
        insert userList;

        List<ASI_CRM_Contract_Cost_Setting__c> contractCostSettings = new List<ASI_CRM_Contract_Cost_Setting__c>();
        ASI_CRM_Contract_Cost_Setting__c PSFContractCostSetting = new ASI_CRM_Contract_Cost_Setting__c(
            Name = 'PRC - PSF & Trading term incentives',
            ASI_CRM_CN_Chinese_Description__c = '空瓶回收费',
            ASI_CRM_CN_Promotion_Type__c = 'TOT/MOT Contract',
            ASI_CRM_CN_Channel__c = 'OFF MOT',
            ASI_CRM_CN_Sequence__c = 1,
            ASI_CRM_PSF_Activity_Code_Default__c = true
        );
        ASI_CRM_Contract_Cost_Setting__c OtherContractCostSetting = new ASI_CRM_Contract_Cost_Setting__c(
            Name = 'PRC - Data Sharing',
            ASI_CRM_CN_Chinese_Description__c = '数据分享扣点',
            ASI_CRM_CN_Promotion_Type__c = 'TOT/MOT Contract',
            ASI_CRM_CN_Channel__c = 'OFF MOT',
            ASI_CRM_CN_Sequence__c = 9,
            ASI_CRM_CN_Other_Cost_Payment_Request__c = true,
            ASI_CRM_CN_Fixed_Cost_Contract__c = true
        );

        contractCostSettings.add(PSFContractCostSetting);
        contractCostSettings.add(OtherContractCostSetting);
        insert contractCostSettings;

        List<ASI_CRM_Fix_Approval_Route__c> approvalRoutes = new List<ASI_CRM_Fix_Approval_Route__c>();
        approvalRoutes.add(new ASI_CRM_Fix_Approval_Route__c(
            ASI_CRM_Sales_Team__c = 'a',
            ASI_CRM_CN_Approver_1__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_2__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_3__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_4__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_5__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_6__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_7__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_8__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_9__c = UserInfo.getUserId(),
            ASI_CRM_CN_Approver_10__c = userList[1].Id,
            ASI_CRM_RVP__c= userList[1].Id,
            ASI_CRM_CN_Regional_BA__c= UserInfo.getUserId(),
            ASI_CRM_CN_Approval_Limit_1__c = -999999,
            ASI_CRM_CN_Approval_Limit_2__c = -999999,
            ASI_CRM_CN_Approval_Limit_3__c = -999999,
            ASI_CRM_CN_Approval_Limit_4__c = -999999,
            ASI_CRM_CN_Approval_Limit_5__c = -999999,
            ASI_CRM_CN_Approval_Limit_6__c = -999999,
            ASI_CRM_CN_Approval_Limit_7__c = -999999,
            ASI_CRM_CN_Approval_Limit_8__c = -999999,
            ASI_CRM_CN_Approval_Limit_9__c = -999999,
            ASI_CRM_CN_Approval_Limit_10__c = -999999,
            ASI_CRM_CN_Type__c = 'TOT/MOT Contract',
            ASI_CRM_CN_Entry_Limit__c=-999999
        )
        );
        insert approvalRoutes;


        Date PO_Start_Date = Date.newInstance(System.today().year(), System.today().month(), 1);
        Date PO_End_Date = PO_Start_Date.addMonths(1)-1;
        ASI_TH_CRM_Contract__c Contract = new ASI_TH_CRM_Contract__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract'),
            ASI_CRM_CN_Status__c = 'Draft',
            OwnerId = userList[0].Id,
            ASI_CRM_System_Debug__c=true,
            ASI_CRM_CN_PO_Start_Date__c = PO_Start_Date,
            ASI_CRM_CN_PO_End_Date__c =PO_End_Date,
            ASI_CRM_CN_PO_Version__c = '0.0',
            ASI_TH_CRM_Promotion_Type__c='TOT/MOT Contract',
            Name = 'Contract1',
            ASI_CRM_CN_Outlet_WS__c=Customers[0].Id,
            ASI_CRM_Volume_Option__c = 'Normal');
        insert Contract;

        Test.startTest();

        ASI_CRM_CN_MassUploadByBatch_Controller tmpUploadCtrller = new ASI_CRM_CN_MassUploadByBatch_Controller();

        tmpUploadCtrller.ObjAPIName = 'ASI_CRM_CN_Covered_Outlet__c';
        tmpUploadCtrller.parentID = Contract.Id;
        tmpUploadCtrller.recordtypeName = 'ASI_CRM_CN_Covered_Outlet';
        tmpUploadCtrller.parentField = 'ASI_CRM_CN_Contract__c';
        tmpUploadCtrller.fields = 'ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Target_Volume_9L__c,ASI_CRM_CN_Target_Value__c';
        tmpUploadCtrller.fieldsLabel = 'CRM Code,Target Volume (9L),Target Value';
        tmpUploadCtrller.lookupEXID = 'ASI_CRM_AccountsAdditionalField__c/ASI_CRM_CN_Outlet__c:CRM Code&ASI_CRM_CN_CRM_Code__c';
        tmpUploadCtrller.template = 'ASI_CRM_CN_Covered_Outlet_Template';
        tmpUploadCtrller.report = '';
        tmpUploadCtrller.opt_allOrNone = true;
        tmpUploadCtrller.currentPageURL = Contract.Id;
        tmpUploadCtrller.inlineVF = true;
        tmpUploadCtrller.defaultValues = 'Mass Uploaded:true;';
        tmpUploadCtrller.parentObjectAPIName = 'ASI_TH_CRM_Contract__c';
        tmpUploadCtrller.ParentObjectUploadMsg = 'ASI_CRM_Remarks__c';
        tmpUploadCtrller.upsertMode = false;
        tmpUploadCtrller.batchMode = true;
        tmpUploadCtrller.emailNotification = false;
        tmpUploadCtrller.nameFile = '2015-05-05.csv';
        tmpUploadCtrller.contentFile = Blob.valueOf('CRM Code,Target Volume (9L),Target Value\rTestItemGroupCode,8,8');
        tmpUploadCtrller.fileSize = 2000;
        tmpUploadCtrller.dummyVar = null;

        tmpUploadCtrller.uploadCSVByBatch();
        tmpUploadCtrller.uploadCSV();


        Test.stopTest();
    }
}