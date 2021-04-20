@isTest
private class ASI_CRM_CN_PhysicalIC_WebService_Test {
    
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
    
	private Class PhysicalInventory{
        private list <PhysicalInventoryStructure> PhysicalInventoryList { set; get; }
    }
    
    private with sharing class PhysicalInventoryStructure{
        private String recordID { set; get; }
        private Boolean confirmed { set; get; }
    }
    
    private Class PhysicalInventoryLI{
        private list <PhysicalInventoryItemStructure> PhysicalInventoryItemList { set; get; }
    }
    
    private with sharing class PhysicalInventoryItemStructure{
        
        private String recordID { set; get; }
        private String DateOfChecking { set; get; }
        private Decimal InventoryBtl { set; get; }
        private Decimal InventoryBtlFromWS { set; get; }
        private String itemGroup { set; get; }
        private String PhysicalInventoryCheck { set; get; }
        
    }
    
    static testMethod void PhysicalIventoryUpdateTest() {
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TESTCITY');
        insert city;
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;
        
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, ASI_CRM_CN_CCity__c=city.Id));
        insert listAA;
        
        ASI_CRM_Physical_Inventory_Check__c tmpPIC = new ASI_CRM_Physical_Inventory_Check__c(ASI_CRM_WS__c = listAA[0].id, ASI_CRM_Month__c = date.today(), ASI_CRM_Confirmed__c = false, RecordTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check__cASI_CRM_CN_Inventory_Check'));
        insert tmpPIC;
        
        Test.startTest();
        /*test*/
        
        String record = '{\"PhysicalInventoryList\":[{\"recordID\":\"' + tmpPIC.id + '\",\"confirmed\":true}]}';
        ASI_CRM_CN_PhysicalIC_Update.updatePhysicalInventoryCheck(record);
        Test.stopTest();
   }
    
    static testMethod void PhysicalIventoryItemUpsertTest() {
        
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
        
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Is_IHBR_Outlet__c = TRUE, ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[1].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS')));
        tmpCustomer.add(new ASI_CRM_AccountsAdditionalField__c(ASI_CRM_CN_Sub_Channel__c=tmpSubChannel[0].Id, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_Latest_Call_Plan_Date__c=system.today(), RecordTypeId=Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN')));
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
                                                   , ASI_CRM_CN_Consumer_Website__c = TRUE
                                                   , ASI_CRM_CN_Consumer_web_Code_C__c = 'TestItemGroupCode'
                                                  ));
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup2'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode2'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup2'
                                                   , OwnerID = tempU.id
                                                   , ASI_CRM_CN_Consumer_Website__c = TRUE
                                                   , ASI_CRM_CN_Consumer_web_Code_C__c = 'TestItemGroupCode2'
                                                  ));
        insert tmpItemGroup;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        
        map<string, RecordType> mapRtA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('Account'))
            mapRtA.put(rt.developerName, rt);
        
        map<string, RecordType> mapRtAA = new map<string, RecordType>();
        for(RecordType rt: Global_RecordTypeCache.getRtList('ASI_CRM_AccountsAdditionalField__c'))
            mapRtAA.put(rt.developerName, rt);
        
        list<Account> listA = new list<Account>();
        listA.add(new Account(Name='TEST', RecordTypeId=mapRtA.get('ASI_MFM_CN_Outlet').Id));
        insert listA;
        
        list<ASI_CRM_AccountsAdditionalField__c> listAA = new list<ASI_CRM_AccountsAdditionalField__c>();
        listAA.add(new ASI_CRM_AccountsAdditionalField__c(Name='TEST', RecordTypeId=mapRtAA.get('ASI_CRM_CN_WS').Id, ASI_CRM_Account__c=listA[0].Id, ASI_CRM_CN_CCity__c=city.Id));
        insert listAA;
        
        ASI_CRM_Physical_Inventory_Check__c tmpPIC = new ASI_CRM_Physical_Inventory_Check__c(ASI_CRM_WS__c = listAA[0].id, ASI_CRM_Month__c = date.today(), ASI_CRM_Confirmed__c = false, RecordTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check__cASI_CRM_CN_Inventory_Check'));
        insert tmpPIC;
        
        ASI_CRM_Physical_Inventory_Check_Item__c tmpPICI = new ASI_CRM_Physical_Inventory_Check_Item__c(ASI_CRM_Date_of_Checking__c = date.today(), ASI_CRM_Physical_Inventory_Check__c = tmpPIC.id, ASI_CRM_Item_Group__c = tmpItemGroup[0].id, RecordTypeID = Global_RecordTypeCache.getRtId('ASI_CRM_Physical_Inventory_Check_Item__cASI_CRM_CN_Physical_Inventory_Check_Item'));
        insert tmpPICI;
        
        Test.startTest();
        /*test*/
        
        String record = '{\"PhysicalInventoryItemList\":[{\"recordID\":\"' + tmpPICI.id + '\",\"DateOfChecking\":\"2015/08/31\",\"InventoryBtl\":\"1\",\"InventoryBtlFromWS\":\"2\",\"itemGroup\":\"' + tmpItemGroup[0].id + '\",\"PhysicalInventoryCheck\":\"' + tmpPIC.id + '\"},{\"recordID\":\"\",\"DateOfChecking\":\"2015/05/21\",\"InventoryBtl\":\"1\",\"InventoryBtlFromWS\":\"2\",\"itemGroup\":\"' + tmpItemGroup[1].id + '\",\"PhysicalInventoryCheck\":\"' + tmpPIC.id + '\"}]}';
        ASI_CRM_CN_PhysicalICI_Upsert.upsertPhysicalInventoryItem(record);
        String record2 = '{\"PhysicalInventoryItemList\":[{\"recordID\":\"' + tmpPICI.id + '\"}]}';
        ASI_CRM_CN_PhysicalICI_Del.delPhysicalInventoryItem(record2);
        Test.stopTest();
   }
}