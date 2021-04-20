@isTest
Private class ASI_CRM_CN_PriceAndDiscount_Test {
    
    Private static User tempU = [select id,ManagerID from user where CompanyName = 'Pernod Ricard China' and ManagerID !=null limit 1]; //20161109,Leo@Elufa
    private static Boolean isDataCreated = false;
    private static ASI_CN_NPL_NPL_Request__c npl = new ASI_CN_NPL_NPL_Request__c();
    
    Private static List<ASI_MFM_Sub_brand__c> tmpSB = new List<ASI_MFM_Sub_brand__c>();
    
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
    
    Private Static List<ASI_CRM_Price_And_Discount__c> tmpPnD = new List<ASI_CRM_Price_And_Discount__c>();
    
    Private Static List<ASI_CRM_Price_And_Discount_Detail__c> tmpPnDLI = new List<ASI_CRM_Price_And_Discount_Detail__c>();
        
    private static testmethod void testMethod1(){
        
        initDataClassA();
		test.startTest();
		//新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf;        
        RecordType rec = [select id from RecordType where developerName = 'ASI_CN_NPL_Item_Master_TypeA' limit 1];
        
        ASI_CN_NPL_Item_Master__c im = new ASI_CN_NPL_Item_Master__c(recordTypeID = rec.id, ASI_CN_NPL_Status__c = 'Completed', ASI_CN_NPL_Item_Goup_Code__c = 'TestItemGroupCode'
                                                                     ,  ASI_CN_NPL_NPL_Reference_No__c = npl.id
                                                                     ,ASI_CN_NPL_Item_Group_Description_GE__c = 'a', ASI_CN_NPL_Item_Group_Description_CH__c = 'b'
                                                                    );
        insert im;
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = tempU.id
                                                  ));
        insert tmpItemGroup;
        
        List<ASI_CN_NPL_NPL_Request__c> npl2 = new List<ASI_CN_NPL_NPL_Request__c>();
        npl2.add(npl);
        
        List<ASI_CN_NPL_Item_Master__c> im2 = new List<ASI_CN_NPL_Item_Master__c>();
        im2.add(im);
        
        
        ASI_CRM_CN_NPLT1Price_triggerclass.beforeUpdateMethod(npl2);
        ASI_CRM_CN_NPLT1Price_triggerclass.beforeUpdateMethod(im2);
        
        
        im.ASI_CN_NPL_Status__c = 'Waiting For Logistics Input Item Code';
        npl.ASI_CN_NPL_Status__c = 'Open';
        update im;
        update npl;
        
        test.stopTest();
        
    }
    
    private static testmethod void testMethod2(){
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = 'Test', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Customer Price'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Adjustment'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Repack'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = '', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Customer Price (IHBR)'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = '', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Customer Price (IH & VIP)'));
        insert tmpFixRoute;
        
        //20161108,Leo@Elufa
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_User__c = tempU.id, ASI_CRM_Type__c = 'Price - Customer Price (IHBR)', ASI_CRM_Approval_Limit__c = 999999, ASI_CRM_End_of_Dynamic_Route__c = True));
        insert tmpDynamicRoute;
        //20161108,Leo@Elufa
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf; 
        
        tmpPromotionMaster.add(new ASI_CRM_Promotion_Master__c( OwnerId = tempU.id
                                                               , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                                                               , ASI_CRM_Buy_X__c = 1
                                                               , ASI_CRM_Get_Y__c = 1
                                                               , ASI_CRM_Type__c = 'Buy X Get Y'
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
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing', ASI_CRM_CN_Eng_Name__c = 'Testing1', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing2', ASI_CRM_CN_Eng_Name__c = 'Testing2', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing3', ASI_CRM_CN_Eng_Name__c = 'Testing3', ASI_CRM_CN_Estimated_annual_order_amount__c = 1,ASI_CRM_CN_Is_IHBR_Outlet__c = True, ASI_CRM_CN_Commercial_Team__c='HQ/Hotel',ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
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
        
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request')
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                     , ASI_CRM_Status__c = 'Open'
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request')
                                                     , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                     , ASI_CRM_Status__c = 'Approved'
                                                     , ASI_CRM_Effective_From__c = date.today().addDays(-1)
                                                     , ASI_CRM_Effective_To__c = date.today().addDays(100)
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_T1_Price_Adjustment_Request')
                                                     , ASI_CRM_Status__c = 'Open'
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_NPL_T1_Price_Request')
                                                     , ASI_CRM_Status__c = 'Open'
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Repacking_Price_Request')
                                                     , ASI_CRM_Status__c = 'Open'
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request')
                                                     , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                     , ASI_CRM_Status__c = 'Open'
                                                    ));
        test.startTest();
        insert tmpPnD;
        update tmpPnd;
        
        tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[0].id 
                                                              , ASI_CRM_Item_Group_Description__c = tmpItemGroup[0].id
                                                              , ASI_CRM_Total_Estimated_Vol_BT__c = 1
                                                              , ASI_CRM_New_Price_BT_with_VAT__c = 1
                                                              , ASI_CRM_Current_T1_Price_BT_with_VAT__c = 3
                                                             ));
        tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[1].id 
                                                              , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                              , ASI_CRM_Item_Group_Description__c = tmpItemGroup[0].id
                                                              , ASI_CRM_Total_Estimated_Vol_BT__c = 1
                                                              , ASI_CRM_New_Price_BT_with_VAT__c = 1
                                                              , ASI_CRM_Promotion_Code__c = tmpPromotionMaster[0].id
                                                              , ASI_CRM_Current_T1_Price_BT_with_VAT__c = 1
                                                             ));
        insert tmpPnDLI;
        //update tmpIGCP;
        
        //20161108,Leo@Elufa
        ASI_CRM_CN_PriceDiscount_EmailController ec = new ASI_CRM_CN_PriceDiscount_EmailController();
        ec.currentHeaderID = tmpPnD[1].Id;
        ec.init();
        //20161108,Leo@Elufa
        
        Test.setCurrentPage(Page.ASI_CRM_CN_PriceAndDiscountCPDRPage);
        Apexpages.currentPage().getParameters().put('id', tmpPnD[0].id);
        Apexpages.StandardSetController sc = new apexpages.StandardSetController(tmpPnD);
        ASI_CRM_CN_PriceAndDiscountCtrller so = new ASI_CRM_CN_PriceAndDiscountCtrller(sc);
        
        so.getBrandType();
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[0].id);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[0].id, '', false, 1, 500);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[0].id, '', false);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[2].id);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[2].id, '', false, 1, 500);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[2].id, '', false);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[3].id);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[3].id, '', false, 1, 500);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[3].id, '', false);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[4].id);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[4].id, '', false, 1, 500);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[4].id, '', false);
        
        List<ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem> tmpPnDLineItem = new List<ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem>();
        ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem tmpPnDLineItem2 = new ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpPnDLineItem2.skuId = tmpItemGroup[0].id;
        tmpPnDLineItem2.remark = 'TestRemark';
        tmpPnDLineItem2.price = 1;
        tmpPnDLineItem2.unitPriceSource = 'a';
        tmpPnDLineItem2.promotionCodeID = tmpPromotionMaster[0].id;
        tmpPnDLineItem2.promotionExpirationDate = '7-5-2015';
        tmpPnDLineItem2.qty = 1;
        tmpPnDLineItem2.skuInventory = 1;
        tmpPnDLineItem2.brandType = '';
        tmpPnDLineItem2.uom = '';
        tmpPnDLineItem2.qty9Lfactor = 1;
        tmpPnDLineItem2.packaging = '1';
        tmpPnDLineItem2.amount = 1;
        tmpPnDLineItem2.available = false;
        tmpPnDLineItem2.isPOS = false;
        tmpPnDLineItem2.stdNum = 1;
        
        tmpPnDLineItem.add(tmpPnDLineItem2);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem tmpPnDLineItem3 = new ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpPnDLineItem3.skuId = tmpItemGroup[0].id;
        tmpPnDLineItem3.remark = 'TestRemark';
        tmpPnDLineItem3.price = 1;
        tmpPnDLineItem3.unitPriceSource = 'a';
        tmpPnDLineItem3.promotionCodeID = tmpPromotionMaster[0].id;
        tmpPnDLineItem3.promotionExpirationDate = '7-5-2015';
        tmpPnDLineItem3.qty = 1;
        tmpPnDLineItem3.id = tmpPnDLI[0].id;
        
        tmpPnDLineItem.add(tmpPnDLineItem3);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.saveChanges(tmpPnD[0].id, tmpPnDLineItem);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SKU tmpPnDLineItem4 = new ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SKU();
        tmpPnDLineItem4.remark = '';
        tmpPnDLineItem4.buyX = 1;
        tmpPnDLineItem4.getY = 1;
        tmpPnDLineItem4.totalEstimatedVolBT = 1;
        tmpPnDLineItem4.promotionCodeID = '';
        tmpPnDLineItem4.promotionCodeName = '';
        tmpPnDLineItem4.promotionExpirationDate = '';
        tmpPnDLineItem4.unitPriceSource = '';
        tmpPnDLineItem4.price = 1;
        
        // Laputa Vincent Lam 20190305 begin
        // comment the following due to error in running test class
        // line 104, column 31: Dependent class is invalid and needs recompilation:
        // Class ASI_CRM_CN_IGCPUpdate_Schd : Dependent class is invalid and needs recompilation:
        // Class ASI_CRM_CN_IGCPUpdate_Batch : Constructor not defined: [ASI_MFM_CN_ReceiptGeneration_Batch].<Constructor>()
        /*
        system.schedule('testschedule', '0 0 0 15 3 ? 2022', new ASI_CRM_CN_IGCPUpdate_Schd());
        */
        // Laputa Vincent Lam 20190305 end
        //database.executebatch(new ASI_CRM_CN_IGCPUpdate_Batch());
        
        test.stopTest();
    }
    
    private static testmethod void testMethod3(){
        
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = 'Test', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Customer Price'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Adjustment'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Repack'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = '', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Customer Price (IHBR)'));
        tmpFixRoute.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Region_Area_Channel__c = '', ASI_CRM_CN_Approver_1__c = tempU.id,ASI_CRM_CN_Type__c='Price - Customer Price (IH & VIP)'));
        insert tmpFixRoute;
        
        //20161108,Leo@Elufa
        tmpDynamicRoute.add(new ASI_CRM_Dynamic_Approval_Route__c(ASI_CRM_User__c = tempU.id, ASI_CRM_Type__c = 'Price - Customer Price (IHBR)', ASI_CRM_Approval_Limit__c = 999999, ASI_CRM_End_of_Dynamic_Route__c = True));
        insert tmpDynamicRoute;
        //20161108,Leo@Elufa
        
        //新增税率
        ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
        insert rateConf; 
        
        tmpPromotionMaster.add(new ASI_CRM_Promotion_Master__c( OwnerId = tempU.id
                                                               , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                                                               , ASI_CRM_Buy_X__c = 1
                                                               , ASI_CRM_Get_Y__c = 1
                                                               , ASI_CRM_Type__c = 'Buy X Get Y'
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
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing', ASI_CRM_CN_Eng_Name__c = 'Testing1', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing2', ASI_CRM_CN_Eng_Name__c = 'Testing2', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing3', ASI_CRM_CN_Eng_Name__c = 'Testing3', ASI_CRM_CN_Estimated_annual_order_amount__c = 1,ASI_CRM_CN_Is_IHBR_Outlet__c = True, ASI_CRM_CN_Commercial_Team__c='HQ/Hotel',ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
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
        
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request')
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                     , ASI_CRM_Status__c = 'Open'
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request')
                                                     , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                     , ASI_CRM_Status__c = 'Approved'
                                                     , ASI_CRM_Effective_From__c = date.today().addDays(-1)
                                                     , ASI_CRM_Effective_To__c = date.today().addDays(100)
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_T1_Price_Adjustment_Request')
                                                     , ASI_CRM_Status__c = 'Open'
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_NPL_T1_Price_Request')
                                                     , ASI_CRM_Status__c = 'Open'
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Repacking_Price_Request')
                                                     , ASI_CRM_Status__c = 'Open'
                                                     , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                    ));
        tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                     , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_Customer_Price_and_Discount_Request')
                                                     , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                     , ASI_CRM_Status__c = 'Open'
                                                    ));
        test.startTest();
        insert tmpPnD;
        update tmpPnd;
        
        tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[0].id 
                                                              , ASI_CRM_Item_Group_Description__c = tmpItemGroup[0].id
                                                              , ASI_CRM_Total_Estimated_Vol_BT__c = 1
                                                              , ASI_CRM_New_Price_BT_with_VAT__c = 1
                                                              , ASI_CRM_Current_T1_Price_BT_with_VAT__c = 3
                                                             ));
        tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[1].id 
                                                              , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                              , ASI_CRM_Item_Group_Description__c = tmpItemGroup[0].id
                                                              , ASI_CRM_Total_Estimated_Vol_BT__c = 1
                                                              , ASI_CRM_New_Price_BT_with_VAT__c = 1
                                                              , ASI_CRM_Promotion_Code__c = tmpPromotionMaster[0].id
                                                              , ASI_CRM_Current_T1_Price_BT_with_VAT__c = 1
                                                             ));
        insert tmpPnDLI;
        //update tmpIGCP;
        
        //20161108,Leo@Elufa
        ASI_CRM_CN_PriceDiscount_EmailController ec = new ASI_CRM_CN_PriceDiscount_EmailController();
        ec.currentHeaderID = tmpPnD[1].Id;
        ec.init();
        //20161108,Leo@Elufa
        
        Test.setCurrentPage(Page.ASI_CRM_CN_PriceAndDiscountCPDRPage);
        Apexpages.currentPage().getParameters().put('id', tmpPnD[0].id);
        Apexpages.StandardSetController sc = new apexpages.StandardSetController(tmpPnD);
        ASI_CRM_CN_PriceAndDiscountCtrller so = new ASI_CRM_CN_PriceAndDiscountCtrller(sc);
        
        so.getBrandType();
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[0].id);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[0].id, '', false, 1, 500);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[0].id, '', false);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[2].id);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[2].id, '', false, 1, 500);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[2].id, '', false);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[3].id);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[3].id, '', false, 1, 500);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[3].id, '', false);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.lineItemList(tmpPnD[4].id);
        ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList(tmpPnD[4].id, '', false, 1, 500);
        //ASI_CRM_CN_PriceAndDiscountCtrller.normalProductList_bak(tmpPnD[4].id, '', false);
        
        List<ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem> tmpPnDLineItem = new List<ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem>();
        ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem tmpPnDLineItem2 = new ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpPnDLineItem2.skuId = tmpItemGroup[0].id;
        tmpPnDLineItem2.remark = 'TestRemark';
        tmpPnDLineItem2.price = 1;
        tmpPnDLineItem2.unitPriceSource = 'a';
        tmpPnDLineItem2.promotionCodeID = tmpPromotionMaster[0].id;
        tmpPnDLineItem2.promotionExpirationDate = '7-5-2015';
        tmpPnDLineItem2.qty = 1;
        tmpPnDLineItem2.skuInventory = 1;
        tmpPnDLineItem2.brandType = '';
        tmpPnDLineItem2.uom = '';
        tmpPnDLineItem2.qty9Lfactor = 1;
        tmpPnDLineItem2.packaging = '1';
        tmpPnDLineItem2.amount = 1;
        tmpPnDLineItem2.available = false;
        tmpPnDLineItem2.isPOS = false;
        tmpPnDLineItem2.stdNum = 1;
        
        tmpPnDLineItem.add(tmpPnDLineItem2);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem tmpPnDLineItem3 = new ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SOLineItem();
        
        tmpPnDLineItem3.skuId = tmpItemGroup[0].id;
        tmpPnDLineItem3.remark = 'TestRemark';
        tmpPnDLineItem3.price = 1;
        tmpPnDLineItem3.unitPriceSource = 'a';
        tmpPnDLineItem3.promotionCodeID = tmpPromotionMaster[0].id;
        tmpPnDLineItem3.promotionExpirationDate = '7-5-2015';
        tmpPnDLineItem3.qty = 1;
        tmpPnDLineItem3.id = tmpPnDLI[0].id;
        
        tmpPnDLineItem.add(tmpPnDLineItem3);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.saveChanges(tmpPnD[0].id, tmpPnDLineItem);
        
        ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SKU tmpPnDLineItem4 = new ASI_CRM_CN_PriceAndDiscountCtrller.ASI_HK_CRM_SKU();
        tmpPnDLineItem4.remark = '';
        tmpPnDLineItem4.buyX = 1;
        tmpPnDLineItem4.getY = 1;
        tmpPnDLineItem4.totalEstimatedVolBT = 1;
        tmpPnDLineItem4.promotionCodeID = '';
        tmpPnDLineItem4.promotionCodeName = '';
        tmpPnDLineItem4.promotionExpirationDate = '';
        tmpPnDLineItem4.unitPriceSource = '';
        tmpPnDLineItem4.price = 1;
        
        // Laputa Vincent Lam 20190305 begin
        // comment the following due to error in running test class
        // line 104, column 31: Dependent class is invalid and needs recompilation:
        // Class ASI_CRM_CN_IGCPUpdate_Schd : Dependent class is invalid and needs recompilation:
        // Class ASI_CRM_CN_IGCPUpdate_Batch : Constructor not defined: [ASI_MFM_CN_ReceiptGeneration_Batch].<Constructor>()
        /*
        system.schedule('testschedule', '0 0 0 15 3 ? 2022', new ASI_CRM_CN_IGCPUpdate_Schd());
        */
        // Laputa Vincent Lam 20190305 end
        //database.executebatch(new ASI_CRM_CN_IGCPUpdate_Batch());
        
        test.stopTest();
    }
    
    static void initDataClassA(){
        //Prepare Public Group member
            //Laputa Vincent Lam 20181214: refer to ASI_CN_NPL_RequestNextStepControllerTest
            //Profile adminProfile = [Select Id From Profile Where Name = 'ASI System Administrator'];
            Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator GDT'];
            //Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator'];
            User DMLUser = [Select Id From User Where ProfileId = :adminProfile.Id And IsActive = true Limit 1];

            User u = new User(Username = 'NPLsupervisor@supervisor.com', email = 'supervisor@supervisor.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='sup', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            User u2 = new User(Username = 'NPLuser@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
            
            System.runAs(DMLUser) {
                try {
                    //Wilken 20131125, updated brand director assignment logic, Prepare Role for Owner
                    UserRole supervisorRole = new UserRole(Name='Supervisor Role', DeveloperName = 'Supervisor_Role');
                    insert supervisorRole;
                    u.UserRoleID = supervisorRole.id;
                    
                    UserRole ownerRole = new UserRole(Name='Owner Role', DeveloperName = 'Owner_Role', ParentRoleID = supervisorRole.Id);
                    insert ownerRole;
                    u2.UserRoleID = ownerRole.id;
                    
                    insert u;
                    
                    insert u2;
                        
                    if (!isDataCreated){
                        List<Group> publicGroups = [Select Id From Group Where Name IN ('ASI CN NPL Marketing Director', 'ASI CN NPL Brand Director Approvers', 'ASI CN NPL Deputy Managing Director', 
                        'ASI CN NPL Finance Director', 'ASI CN NPL Marketing Director', 'ASI CN NPL National Sales Dev VP', 'ASI CN NPL Trade Marketing Director')];
                        List<GroupMember> groupMembers = new List<GroupMember>();
                        
                        for (Group g : publicGroups){
                            GroupMember groupMember = new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);
                            groupMembers.add(groupMember);
                        }
                        
                        insert groupMembers;

                        isDataCreated = true;
                    }
                } catch (Exception e){
                }
            } 
               
        npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CRM_CN_NPLT1PriceFlag__c = false, ASI_CN_NPL_Date__c = date.today(), RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Class_A'), ASI_CN_NPL_Classification_Text__c = 'Class A', ASI_CN_NPL_Status__c = 'Final Approved', ASI_CN_NPL_Comparable_PR_Product__c = 'ABC', ASI_CN_NPL_Profit_Loss__c ='ABC', ASI_CN_NPL_Final_Proposed_Selling_Price__c  = 1);
        
        insert npl;
        
        System.debug('NPL Id: ' + npl.Id);
    }
    
    static ID getRecordTypeIDByName(string RTName){
    
        return Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__c' + RTName);
    }
}