/*****************************************************************************************************************
 * Name: ASI_CTY_CN_WS_TOVPDFController
 * Test Class:  ASI_CTY_CN_WS_TOVPDFCtrlTest
 * Description: 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-10-21       jack yuan               created
 *****************************************************************************************************************/
@isTest
private class ASI_CTY_CN_WS_TOVPDFCtrlTest {

	@testSetup
    static void testDataPre() {
         Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr1 = new User(Alias = 'teamLea', Email='teamLeader@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='teamLeader', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = p1.Id, IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='testLeader@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert usr1;
        System.runAs(usr1) {

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

            Account acc = new Account(Name = 'TestAccount', 
                                      RecordtypeId = Global_RecordTypeCache.getRtId('AccountASI_CRM_CN_Wholesales_CN'),
                                      ASI_KOR_Addr_Region__c = 'Central Region');
            insert acc;
            
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

            Contact con = new Contact(LastName = 'TestContact', 
                                    RecordtypeId = Global_RecordTypeCache.getRtId('ContactASI_CRM_CN_Wholesaler_Contact'),
                                    AccountId = acc.Id);
            insert con;

            User curU = [select id, ManagerId, CompanyName from user where id = : userInfo.getUserId()];

            List<ASI_MFM_Item_Group__c> itemGroupList = new List<ASI_MFM_Item_Group__c>();
            itemGroupList.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                    , Name = 'TestItemGroup'
                    , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                    , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                    , OwnerID = curU.id
                    , ASI_CRM_Allocation_Information__c = true
            ));
            insert itemGroupList;

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
            insert salesOrderLineItemList;

            ASI_CRM_TOV__c tov = new ASI_CRM_TOV__c(ASI_CRM_Status__c = 'Held',
                                                    ASI_CRM_SO_Number__c = '123456',
                                                    ASI_CRM_Order_Date__c = Date.today().addDays(-15),
                                                    OwnerId = curU.id,
                                                    RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV__cASI_CRM_CN_TOV'),
                                                    ASI_CRM_SF_SO_Request_Number__c = salesOrderList[0].Id);
            insert tov;

            ASI_CRM_TOV_Detail__c tmpTOVLine = new ASI_CRM_TOV_Detail__c(ASI_CRM_TOV__c = tov.Id,
                                                                         RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_TOV_Detail__cASI_CRM_CN_CN_TOV_Detail'),
                                                                         ASI_CRM_SF_SO_Request_Line_Number__c = salesOrderLineItemList[0].Id,
                                                                         ASI_CRM_UOM__c = 'CA',
                                                                         ASI_CRM_PriceWVAT_BT__c = 100,
                                                                         ASI_CRM_Price_BT__c = 88,
                                                                         ASI_CRM_Order_QTY__c = 10);
            insert tmpTOVLine;
        }
       
    }
    
    static testMethod void testTOVPDF() {
    	Test.startTest();
        ASI_CRM_TOV__c tov = [SELECT Id FROM ASI_CRM_TOV__c WHERE ASI_CRM_SO_Number__c = '123456'];
        ApexPages.currentPage().getParameters().put('tovId', tov.Id);
		ASI_CTY_CN_WS_TOVPDFController tovpdf = new ASI_CTY_CN_WS_TOVPDFController();
		tovpdf.init();
		Test.stopTest();
    }
}