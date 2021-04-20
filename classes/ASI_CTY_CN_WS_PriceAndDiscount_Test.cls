/*****************************************************************************************************************
 * Name:
 * Test Class: ASI_CTY_CN_WS_PriceAndDiscount_Test
 * Description: ASI_CTY_CN_WS_PriceAndDiscountSearchCtrl
 *              ASI_CTY_CN_WS_PriceAndDiscountUploadCtrl
 *              ASI_CTY_CN_WS_PriceDiscountDetailCtrl
 *              ASI_CTY_CN_WS_Utils
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-12-22       Alex                    
 **********************************************************************************************/
@isTest
private class ASI_CTY_CN_WS_PriceAndDiscount_Test {
    Private static List<ASI_CRM_Item_Group_Customer_Price__c> tmpIGCP = new List<ASI_CRM_Item_Group_Customer_Price__c>();
    Private static List<ASI_CRM_Promotion_Master__c> tmpPromotionMaster = new List<ASI_CRM_Promotion_Master__c>();
    Private static List<ASI_MFM_Sub_Channel__c> tmpSubChannel = new List<ASI_MFM_Sub_Channel__c>();
    Private static List<ASI_CRM_Price_And_Discount__c> tmpPnD = new List<ASI_CRM_Price_And_Discount__c>();
    Private static List<ASI_CRM_Price_And_Discount_Detail__c> tmpPnDLI = new List<ASI_CRM_Price_And_Discount_Detail__c>();
    Private static List<ASI_CRM_AccountsAdditionalField__c> tmpCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
    Private static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
    Private static List<ASI_CRM_CN_T1_Price__c> tmpT1Price = new List<ASI_CRM_CN_T1_Price__c>();
    Private static List<ASI_MFM_SKU_Code__c> tmpSKU = new List<ASI_MFM_SKU_Code__c>();
    Private static User tempU = [select id,ManagerID from user where CompanyName = 'Pernod Ricard China' and ManagerID !=null limit 1]; //20161109,Leo@Elufa

    static testMethod void testCNPriceAndDiscount() {
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;
        System.runAs(adminUser) {
            

            ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
            insert region;
            
            ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
            insert division;
            
            ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
            insert area;
            
            ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c=area.Id);
            insert city;

            ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON', ASI_CRM_For_Outlet__c=true, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'));
            insert channel;
            
            tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id));
            tmpSubChannel.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c=channel.Id));
            
            insert tmpSubChannel;
            
            tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing', ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_CRM_Code__c='test001', ASI_CRM_CN_Eng_Name__c = 'Testing1', ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
            tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing2', ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_CRM_Code__c='test002', ASI_CRM_CN_Eng_Name__c = 'Testing2', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
            tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing3', ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_CRM_Code__c='test003', ASI_CRM_CN_Eng_Name__c = 'Testing3', ASI_CRM_CN_Estimated_annual_order_amount__c = 1,ASI_CRM_CN_Is_IHBR_Outlet__c = True, ASI_CRM_CN_Commercial_Team__c='Premium', ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_JDE_Code__c = 'asd', ASI_CRM_CN_JDE_Code_RTD__c = 'asd', ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
            tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Chi_Name__c = 'testing4', ASI_CRM_CN_NewChannel__c=channel.Id, ASI_CRM_CN_CRM_Code__c='test004', ASI_CRM_CN_Eng_Name__c = 'Testing4', ASI_CRM_CN_Is_IHBR_Outlet__c = FALSE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_JDE_Code__c = 'asde', ASI_CRM_CN_JDE_Code_RTD__c = 'asde', ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
            insert tmpCustomer;

            tmpPromotionMaster.add(new ASI_CRM_Promotion_Master__c( OwnerId = tempU.id
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
                                                                   , ASI_CRM_Buy_X__c = 1
                                                                   , ASI_CRM_Get_Y__c = 1
                                                                   , ASI_CRM_Type__c = 'Buy X Get Y'
                                                                  ));
            tmpPromotionMaster.add(new ASI_CRM_Promotion_Master__c( OwnerId = tempU.id
                                                                   , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CTY_WS_CN_Promotion_Master_Hierarchy')
                                                                   , Name = 'Test_Code'
                                                                   , ASI_CTY_CN_WS_Customer_Type__c = 'Outlet'
                                                                   , ASI_CTY_CN_WS_Commercial_Team__c = 'Premium'
                                                                   , ASI_CTY_CN_WS_Channel__c = channel.Id
                                                                   , ASI_CTY_CN_WS_Region__c = region.Id
                                                                   , ASI_CTY_CN_WS_Trade_a_p_Promotion_Code__c = 'Test_AP'
                                                                   , ASI_CTY_CN_WS_Normal_Promotion_Code__c = 'Test_Normal'
                                                                   , ASI_CTY_CN_WS_AD_Promotion_Code__c = 'Test_AD'
                                                                  ));
            insert tmpPromotionMaster;
            
            tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                       , Name = 'TestItemGroup'
                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                       , ASI_CRM_CN_Not_In_Use__c = FALSE
                                                       , ASI_CRM_CN_Gift_Set_C__c = FALSE
                                                       , ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
                                                       , OwnerID = tempU.id
                                                      ));
            tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                       , Name = 'TestItemGroup1'
                                                       , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode1'
                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup1'
                                                       , ASI_CRM_CN_Not_In_Use__c = FALSE
                                                       , ASI_CRM_CN_Gift_Set_C__c = FALSE
                                                       , ASI_CRM_CN_EMPTY_BOX_C__c = FALSE
                                                       , OwnerID = tempU.id
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
                                                      , ASI_CRM_CN_T1_Price__c = 10
                                                      , ASI_CRM_CN_Item_Group__c = tmpItemGroup[0].id
                                                     ));
            insert tmpT1Price;
            
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
                                                         , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CTY_CN_WS_Customer_Price_and_Discount_Request_A_D_Discount')
                                                         , ASI_CRM_Status__c = 'Open'
                                                         , ASI_CRM_Customer__c = tmpCustomer[2].id
                                                        ));
            tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                         , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CTY_CN_WS_Customer_Price_and_Discount_Request_A_D_Discount')
                                                         , ASI_CRM_Status__c = 'Approved'
                                                         , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                         , ASI_CRM_Effective_From__c = date.today().addDays(-10)
                                                         , ASI_CRM_Effective_To__c = date.today().addDays(100)
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
            tmpPnD.add(new ASI_CRM_Price_And_Discount__c(OwnerId = tempU.id
                                                         , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CTY_CN_WS_Customer_Price_and_Discount_Request_Trade_a_p_Discount')
                                                         , ASI_CRM_Customer__c = tmpCustomer[3].id
                                                         , ASI_CRM_Status__c = 'Approved'
                                                         , ASI_CRM_Effective_From__c = date.today().addDays(-10)
                                                         , ASI_CRM_Effective_To__c = date.today().addDays(100)
                                                        ));
            insert tmpPnD;
            update tmpPnd;
            
            tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[0].id 
                                                                  , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
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
            tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[2].id 
                                                                  , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                                  , ASI_CRM_Item_Group_Description__c = tmpItemGroup[0].id
                                                                  , ASI_CRM_Total_Estimated_Vol_BT__c = 1
                                                                  , ASI_CRM_New_Price_BT_with_VAT__c = 1
                                                                  , ASI_CRM_Promotion_Code__c = tmpPromotionMaster[0].id
                                                                  , ASI_CRM_Current_T1_Price_BT_with_VAT__c = 1
                                                                  , ASI_CTY_CN_WS_Disount_Value__c = 10
                                                                 ));
            tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[3].id 
                                                                  , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                                  , ASI_CRM_Item_Group_Description__c = tmpItemGroup[0].id
                                                                  , ASI_CTY_CN_WS_Level1_Promotion_Code__c = tmpPromotionMaster[1].id
                                                                  , ASI_CTY_CN_WS_Value_Type__c= '% base price'
                                                                  , ASI_CTY_CN_WS_Disount_Value__c = 10
                                                                 ));
            tmpPnDLI.add(new ASI_CRM_Price_And_Discount_Detail__c(ASI_CRM_Price_And_Discount__c = tmpPnD[7].id 
                                                                  , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount_Detail__cASI_CRM_CN_Price_And_Discount_Detail')
                                                                  , ASI_CRM_Item_Group_Description__c = tmpItemGroup[0].id
                                                                  , ASI_CTY_CN_WS_Level1_Promotion_Code__c = tmpPromotionMaster[1].id
                                                                  , ASI_CTY_CN_WS_Value_Type__c= 'add on amount'
                                                                  , ASI_CTY_CN_WS_Disount_Value__c = 5
                                                                 ));
            insert tmpPnDLI;

            tmpIGCP.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                                                                 , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                                 , ASI_CRM_Customer__c = tmpCustomer[0].id
                                                                 , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                                 , ASI_CRM_Unit_Price_BT__c = 9
                                                                ));
            tmpIGCP.add(new ASI_CRM_Item_Group_Customer_Price__c(OwnerId = tempU.id
                                                                 , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Item_Group_Customer_Price__cASI_CRM_CN_ItemGroupCustomerPrice')
                                                                 , ASI_CRM_Customer__c = tmpCustomer[3].id
                                                                 , ASI_CRM_Item_Group__c = tmpItemGroup[0].id
                                                                 , ASI_CRM_Unit_Price_BT__c = 9
                                                                ));
            insert tmpIGCP;
            test.startTest();
            ASI_CRM_Order_Form__c orderForm = ASI_CTY_CN_WS_TestDataFactory.generateOrderForm(true);
            ASI_CRM_Order_Form_Customer_Relationship__c orderFormRel1 = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormRel(true, orderForm.Id, tmpCustomer[0].id);
            ASI_CRM_Order_Form_Customer_Relationship__c orderFormRel2 = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormRel(true, orderForm.Id, tmpCustomer[3].id);
            ASI_CRM_Order_Form_Detail__c orderFormDetail1 = ASI_CTY_CN_WS_TestDataFactory.generateOrderFormDetail(true, orderForm.Id, tmpItemGroup[0].id);

            List<ASI_KOR_Sales_Order_Request__c> salesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();
            salesOrderList.add(
                    new ASI_KOR_Sales_Order_Request__c(
                            ASI_KOR_Order_Status__c = 'Open',
                            ASI_CRM_CN_Customer__c = tmpCustomer[0].id,
                            ASI_CRM_CN_RTD__c = FALSE,
                            ASI_CRM_SG_Order_Date__c = Date.today().addDays(-20),
                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
            ));
            salesOrderList.add(
                    new ASI_KOR_Sales_Order_Request__c(
                            ASI_KOR_Order_Status__c = 'Open',
                            ASI_CRM_CN_Customer__c = tmpCustomer[3].id,
                            ASI_CRM_CN_RTD__c = FALSE,
                            ASI_CRM_SG_Order_Date__c = Date.today().addDays(-20),
                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
            ));
            insert salesOrderList;

            List<ASI_KOR_Sales_Order_Transaction__c> salesOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();
            salesOrderLineItemList.add(
                    new ASI_KOR_Sales_Order_Transaction__c(
                            ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id,
                            ASI_KOR_Order_Qty__c = 20,
                            ASI_CRM_UOM_Text__c = 'CA',
                            ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 100,
                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                            ASI_KOR_Sales_Order_Request__c = salesOrderList[0].id,
                            ASI_CRM_Allocation_Information__c = true
            ));
            salesOrderLineItemList.add(
                    new ASI_KOR_Sales_Order_Transaction__c(
                            ASI_CRM_CN_Product_Name__c = tmpItemGroup[0].id,
                            ASI_KOR_Order_Qty__c = 20,
                            ASI_CRM_UOM_Text__c = 'CA',
                            ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 100,
                            recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                            ASI_KOR_Sales_Order_Request__c = salesOrderList[1].id,
                            ASI_CRM_Allocation_Information__c = true
            ));
            insert salesOrderLineItemList;

            ASI_CRM_CN_Brand_Group__c tmpBrandGroup = new ASI_CRM_CN_Brand_Group__c(Name = 'Test1\'Test2');
            
            insert tmpBrandGroup;

            ASI_MFM_Sub_brand__c testSubBrand1 = new ASI_MFM_Sub_brand__c(
              RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
              Name = 'TestSubBrand1'
            );
        
            ASI_MFM_Sub_brand__c testSubBrand2 = new ASI_MFM_Sub_brand__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Sub_brand__cASI_FOC_CN_Sub_brand'),
                Name = 'TestSubBrand2'
            );

            insert new List<ASI_MFM_Sub_brand__c> {testSubBrand1, testSubBrand2};
            
            ASI_CRM_CN_Tax_Rate_Config__c rateConf = new ASI_CRM_CN_Tax_Rate_Config__c(ASI_CRM_CN_Effective_From__c=Date.today(),ASI_CRM_CN_Tax_Rate__c=13);
            insert rateConf;

            //test ASI_CTY_CN_WS_PriceAndDiscountSearchCtrl
            ASI_CTY_CN_WS_PriceAndDiscountSearchCtrl ctrl = new ASI_CTY_CN_WS_PriceAndDiscountSearchCtrl();
            ctrl.search();
            ctrl.searchPrice.ASI_CRM_Customer__c = tmpCustomer[0].id;
            ctrl.searchPrice.ASI_CRM_Item_Group__c = tmpItemGroup[0].id;
            ctrl.search();
            ctrl.getSearchResults();
            ctrl.first();
            ctrl.last();
            ctrl.previous();
            ctrl.next();


            //test ASI_CTY_CN_WS_PriceAndDiscountUploadCtrl
            testPriceAndDiscountUploadCtrl();

            //test ASI_CTY_CN_WS_PriceDiscountDetailCtrl
            ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(tmpPnD);
            ApexPages.currentPage().getParameters().put('id', tmpPnD[2].id);
            ASI_CRM_Price_And_Discount__c aa = [SELECT Id, ASI_CRM_Status__c FROM ASI_CRM_Price_And_Discount__c WHERE Id = :tmpPnD[2].id];
            aa.ASI_CRM_Status__c= 'Submitted';
            update aa;
            ASI_CTY_CN_WS_PriceDiscountDetailCtrl detailCtrlError = new ASI_CTY_CN_WS_PriceDiscountDetailCtrl(ssc);
            aa.ASI_CRM_Status__c= 'Open';
            update aa;
            ASI_CTY_CN_WS_PriceDiscountDetailCtrl detailCtrl = new ASI_CTY_CN_WS_PriceDiscountDetailCtrl(ssc);
            ASI_CTY_CN_WS_PriceDiscountDetailCtrl.lineItemList(ID.valueOf(tmpPnD[2].id));
            ASI_CTY_CN_WS_PriceDiscountDetailCtrl.normalProductList(String.valueOf(tmpPnD[2].id), String.valueOf(tmpCustomer[2].id), true);
            List<ASI_CTY_CN_WS_PriceDiscountDetailCtrl.ASI_CTY_CN_WS_SOLineItem> remoteLineItems = new List<ASI_CTY_CN_WS_PriceDiscountDetailCtrl.ASI_CTY_CN_WS_SOLineItem>();
            ASI_CTY_CN_WS_PriceDiscountDetailCtrl.ASI_CTY_CN_WS_SOLineItem remoteLineItem = new ASI_CTY_CN_WS_PriceDiscountDetailCtrl.ASI_CTY_CN_WS_SOLineItem();
            remoteLineItem.id = null;
            remoteLineItem.price = 8;
            //remoteLineItem.skuId = tmpItemGroup[0].id;
            remoteLineItem.currentT1PriceBTwithVAT = 8;
            remoteLineItem.level1PromotionCodeId = tmpPromotionMaster[1].id;
            remoteLineItem.discountValue = 10;
            remoteLineItem.valueType = '% base price';
            remoteLineItems.add(remoteLineItem);
            ASI_CTY_CN_WS_PriceDiscountDetailCtrl.saveChanges(String.valueOf(tmpPnD[2].id), remoteLineItems);
            detailCtrl.getBrandType();
            test.stopTest();

            //test ASI_CTY_CN_WS_Utils
            ASI_CTY_CN_WS_Utils.calculateWSPriceInfo(tmpCustomer[0].id, new Set<Id>{tmpItemGroup[0].id});
            ASI_CTY_CN_WS_Utils.getItemGroupUnitPriceWithVat(tmpCustomer[0].id, new Set<Id>{tmpItemGroup[0].id, tmpItemGroup[1].id});
            ASI_CTY_CN_WS_Utils.getAccountId();

            //add by alex 20200731
            database.executebatch(new ASI_CRM_CN_IGCPUpdate_Batch());
        }
    }

    static void testPriceAndDiscountUploadCtrl(){
        ASI_CTY_CN_WS_PriceAndDiscountUploadCtrl uploadCtrl = new ASI_CTY_CN_WS_PriceAndDiscountUploadCtrl();

        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rONTEST0001,TestItemGroupCode,2019-12-11,2059-12-31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();

        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rONTEST0001,TestItemGroupCode,2019-12-11,2059-12-31,200,price discount %,,,10,cn customer price and discount request - a&d discount');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
        //error1
        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest003,TestItemGroupCode,2019-12-11,2059-12-31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 800000000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
        //error2
        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest003,TestItemGroupCode,2019-12-11,2059-12-31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.exl';
        uploadCtrl.uploadCSV();

        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest003,TestItemGroupCode,2019/12/11,2059/12/31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();

        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest003,TestItemGroupCode,2089-12-11,2059-12-31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
        //error3
        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\r,TestItemGroupCode,2019-12-11,2059-12-31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
        //error4
        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest006,,2019-12-11,2059-12-31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
        //error5
        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest003,TestItemGroupCode,2019-12-11,2059-12-31,200,,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
        //error6
        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest003,TestItemGroupCode,2069-12-11,2059-12-31,200,get x buy y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
        //error7
        uploadCtrl.contentFile = Blob.valueOf('Customer CRM Code,item group code,Effective From,Effective To,New Price,Promotion Type,Buy X,Get Y,Discount Value,Record Type\rtest007,TestItemGroupCode,2019-12-11,2059-12-31,200,buy x get y,1,1,,cn customer price and discount request');
        uploadCtrl.fileSize = 2000;
        uploadCtrl.nameFile = 'test.csv';
        uploadCtrl.uploadCSV();
    }
}