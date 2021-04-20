/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_SalesOrderSubmissionCtrl_Test
 * Description:
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
* 30/7/2019		    Laputa - Wilson Chow	Created
 ****************************************************************************************************************************/

@isTest
public with sharing class ASI_CRM_CN_SalesOrderSubmissionCtrl_Test {

    @testSetup
    static void setup() {
        User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];

        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;

        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c= region.Id);
        insert division;

        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c= division.Id);
        insert area;

        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST', ASI_CRM_CN_Area__c= area.Id);
        insert city;

        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;

        List<ASI_MFM_Sub_Channel__c> subChannelList = new List<ASI_MFM_Sub_Channel__c>();
        subChannelList.add(new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c= channel.Id));
        subChannelList.add(new ASI_MFM_Sub_Channel__c(Name = 'VIP', ASI_CRM_CN_Channel__c= channel.Id));
        insert subChannelList;

        ASI_CRM_CN_Channel_Group__c channelGroup = new ASI_CRM_CN_Channel_Group__c(
                Name = 'OFF MOT',
                ASI_CRM_Channel_Group_Chi_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Eng_Name__c = 'OFF MOT',
                ASI_CRM_Channel_Group_Code__c = 'CN_WS Channel',
                ASI_CRM_External_ID__c = 'CN_OFF MOT',
                ASI_CRM_Sequence__c = 8
        );
        insert channelGroup;

        ASI_CRM_CN_Channel__c newChannel =
                new ASI_CRM_CN_Channel__c(
                        ASI_CRM_For_Outlet__c = true,
                        Name='Restaurant',
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_CN_Channel__cASI_CRM_CN_New_Channel'),
                        ASI_CRM_CN_On_Off__c='OFF',
                        ASI_CRM_CN_Channel_Group__c= channelGroup.Id);
        insert newChannel;

        List<ASI_CRM_AccountsAdditionalField__c> tmpCustomerList = new List<ASI_CRM_AccountsAdditionalField__c>();
        tmpCustomerList.add(
                new ASI_CRM_AccountsAdditionalField__c(
                        ASI_CRM_CN_Eng_Name__c = 'test1',
                        ASI_CRM_CN_Chi_Name__c = 'test1',
                        ASI_CRM_CN_Commercial_Team__c = 'Premium',
                        ASI_CRM_CN_JDE_Code_RTD__c = '555',
                        ASI_CRM_CN_JDE_Code__c = '111',
                        ASI_CRM_CN_JDE_Code_Premium__c = '456',
                        ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE,
                        ASI_CRM_CN_Sub_Channel__c= subChannelList[0].Id,
                        ASI_CRM_CN_CCity__c= city.Id,
                        RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS'),
                        ASI_CRM_CN_NewChannel__c = newChannel.Id
                ));
        insert tmpCustomerList;

        List<ASI_CRM_Promotion_Master__c> promotionMasterList = new List<ASI_CRM_Promotion_Master__c>();
        promotionMasterList.add(
                new ASI_CRM_Promotion_Master__c(
                        OwnerId = tempU.id,
                        ASI_CRM_Buy_X__c = 2,
                        ASI_CRM_Get_Y__c = 1,
                        ASI_CRM_Type__c = 'Buy X Get Y',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Promotion_Master__cASI_CRM_CN_Promotion_Master')
        ));
        insert promotionMasterList;

        List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
        itemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                , Name = 'TestItemGroup'
                , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                , OwnerID = tempU.id
                , ASI_CRM_Allocation_Information__c = true
        ));
        insert itemGroupList;

        List<ASI_KOR_Sales_Order_Request__c> salesOrderList = new List<ASI_KOR_Sales_Order_Request__c>();
        salesOrderList.add(
                new ASI_KOR_Sales_Order_Request__c(
                        OwnerId = tempU.id,
                        ASI_KOR_Order_Status__c = 'Open',
                        ASI_CRM_CN_Customer__c = tmpCustomerList[0].id,
                        ASI_CRM_CN_RTD__c = FALSE,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Request__cASI_CRM_CN_SalesOrder')
        ));
        insert salesOrderList;

        List<ASI_KOR_Sales_Order_Transaction__c> salesOrderLineItemList = new List<ASI_KOR_Sales_Order_Transaction__c>();
        salesOrderLineItemList.add(
                new ASI_KOR_Sales_Order_Transaction__c(
                        ASI_CRM_CN_Product_Name__c = itemGroupList[0].id,
                        ASI_KOR_Order_Qty__c = 13,
                        ASI_CRM_CN_Unit_Price_BT_with_VAT__c = 1,
                        ASI_CRM_CN_Promotion_Code__c = promotionMasterList[0].id,
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_KOR_Sales_Order_Transaction__cASI_CRM_CN_SalesOrder_Item'),
                        ASI_KOR_Sales_Order_Request__c = salesOrderList[0].id,
                        ASI_CRM_Allocation_Information__c = true
        ));
        insert salesOrderLineItemList;
    }

    @isTest
    static void testSalesOrderSubmissionCtrl() {
        system.debug('testSalesOrderSubmissionCtrl start');
        test.startTest();

        List<ASI_KOR_Sales_Order_Request__c> salesOrderList = [SELECT Id FROM ASI_KOR_Sales_Order_Request__c];
        ASI_KOR_Sales_Order_Request__c salesOrder = salesOrderList.get(0);

        ApexPages.currentPage().getParameters().put('id', salesOrder.Id);
        ASI_CRM_CN_SalesOrderSubmissionCtrl ctrl = new ASI_CRM_CN_SalesOrderSubmissionCtrl();
        ctrl.proceed();

        test.stopTest();
        system.debug('testSalesOrderSubmissionCtrl end');
    }

    @isTest
    static void testSalesOrderSubmissionCtrl_emptySoId() {
        system.debug('testSalesOrderSubmissionCtrl_emptySoId start');
        test.startTest();

        ASI_CRM_CN_SalesOrderSubmissionCtrl ctrl = new ASI_CRM_CN_SalesOrderSubmissionCtrl();
        ctrl.proceed();

        test.stopTest();
        system.debug('testSalesOrderSubmissionCtrl_emptySoId end');
    }
}