/*****************************************************************************************************************
 * Name:
 * Test Class: ASI_CTY_CN_WS_HomeDashboardCtrl_Test
 * Description: ASI_CTY_CN_WS_HomeDashboardController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-12-21       Alex                    
 **********************************************************************************************/
@isTest
public class ASI_CTY_CN_WS_HomeDashboardCtrl_Test {
    @testSetup
    static void testDataPre() {
       User admin = ASI_CTY_CN_WS_TestDataFactory.generateAdminUser('testAdmin@wholesaler.com');
        System.debug(LoggingLevel.INFO, '*** admin.Id: ' + admin.Id);
        System.runAs(admin) {
            Test.startTest();
            System.debug(LoggingLevel.INFO, '*** current user: ' + UserInfo.getUserId());
            ASI_CRM_AccountsAdditionalField__c customer = ASI_CTY_CN_WS_TestDataFactory.generateWSUser('testWS@wholesaler.com');
            
            ASI_MFM_Item_Group__c itemGroup = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup');

            ASI_CRM_Order_Form__c orderForm = new ASI_CRM_Order_Form__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form__cASI_CRM_CN_Order_Form'),
                ASI_CRM_Order_Form_Type__c = 'Premium', ASI_CRM_T1_Master__c = false);
            insert orderForm;

            ASI_CRM_Order_Form_Customer_Relationship__c orderFormRel = new ASI_CRM_Order_Form_Customer_Relationship__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Customer_Relationship__cASI_CRM_CN_Order_Form_Customer_Relationship'),
                ASI_CRM_Order_Form__c = orderForm.Id, ASI_CRM_Customer__c = customer.Id);
            insert orderFormRel;

            ASI_CRM_Order_Form_Detail__c orderFormDetail = new ASI_CRM_Order_Form_Detail__c(
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Order_Form_Detail__cASI_CRM_CN_Order_Form_Detail'),
                ASI_CRM_Order_Form__c = orderForm.Id, ASI_CRM_Product_Name__c = itemGroup.Id);
            insert orderFormDetail;

            ASI_KOR_Sales_Order_Request__c salesOrder = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrder(true, customer.Id);
            salesOrder.ASI_KOR_Order_Status__c = 'Submitted';
            update salesOrder;
            
            Test.stopTest();

            ASI_KOR_Sales_Order_Transaction__c salesOrderItem = ASI_CTY_CN_WS_TestDataFactory.generateSalesOrderItem(true, itemGroup.Id, salesOrder.Id);

            List<ASI_CRM_TOV__c> tovList = new List<ASI_CRM_TOV__c>();
            ASI_CRM_TOV__c tov = new ASI_CRM_TOV__c(
                ASI_CRM_Status__c = 'Held', ASI_CRM_SO_Number__c = '123456',
                ASI_CRM_Order_Date__c = Date.today().addDays(-15),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV'),
                ASI_CRM_SF_SO_Request_Number__c = salesOrder.Id);
            tovList.add(tov);
            ASI_CRM_TOV__c refundTOV = new ASI_CRM_TOV__c(
                ASI_CRM_SO_Number__c = 'RefundTOVTest', 
                ASI_CRM_SO_Type__c = 'V2', ASI_CRM_Order_Date__c = Date.today().addDays(-15),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV_Final'),
                ASI_CRM_SF_SO_Request_Number__c = salesOrder.Id);
            tovList.add(refundTOV);
            insert tovList;

            List<ASI_CRM_TOV_Detail__c> tovLineList = new List<ASI_CRM_TOV_Detail__c>();
            ASI_CRM_TOV_Detail__c tovLine = new ASI_CRM_TOV_Detail__c(
                ASI_CRM_TOV__c = tov.Id, ASI_CRM_SF_SO_Request_Line_Number__c = salesOrderItem.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV_Detail__cASI_CRM_CN_CN_TOV_Detail'),
                ASI_CRM_UOM__c = 'CA', ASI_CRM_PriceWVAT_BT__c = 100, ASI_CRM_Price_BT__c = 88,
                ASI_CRM_Order_QTY__c = 10);
            tovLineList.add(tovLine);
            ASI_CRM_TOV_Detail__c refundTOVLine = new ASI_CRM_TOV_Detail__c(
                ASI_CRM_TOV__c = refundTOV.Id, ASI_CRM_SF_SO_Request_Line_Number__c = salesOrderItem.Id,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV_Detail__cASI_CRM_CN_CN_TOV_Detail'),
                ASI_CRM_UOM__c = 'CA', ASI_CRM_PriceWVAT_BT__c = 100, ASI_CRM_Price_BT__c = 88,
                ASI_CRM_Order_QTY__c = 10);
            tovLineList.add(refundTOVLine);
            insert tovLineList;
        

            ASI_CRM_Subbrand_Volume__c subVolume = new ASI_CRM_Subbrand_Volume__c(ASI_CRM_Account__c = customer.Id,
                                                                                  ASI_CRM_End_Date__c = Date.today().addDays(-15),
                                                                                  ASI_CRM_Year__c = Date.today().addDays(-15).year() + '',
                                                                                  ASI_CRM_Month__c = Date.today().addDays(-15).month() + '',
                                                                                  ASI_CRM_Intake_Btl__c = 10,
                                                                                  ASI_CRM_WS_INV_BTL__c = 10,
                                                                                  ASI_CRM_Intake_9L__c = 20,
                                                                                  ASI_CRM_WS_INV__c = 20,
                                                                                  ASI_CRM_Offtake__c = 10,
                                                                                  ASI_CRM_Offtake_Btl__c = 10
                                                                                  );
            insert subVolume;
        }
    }

    static testMethod void testHomeDashboard() {
        Test.startTest();
        User user = [SELECT Id FROM User WHERE UserName = 'testWS@wholesaler.com'];
        insert new PermissionSetAssignment(PermissionSetId = ASI_CTY_CN_WS_TestDataFactory.SetupPermissionSet().Id,AssigneeId = user.Id);
        System.runAs(user) {
            ASI_CTY_CN_WS_HomeDashboardController.getDefaultDashboardList();
            ASI_CTY_CN_WS_HomeDashboardController.getDashboardHistoryList();
        }
        Test.stopTest();
    }
}