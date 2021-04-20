@isTest
private class ASI_MFM_CN_IBD_TriggerClass_Test {
    
	private static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
    private static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
    
    // reference : ASI_MFM_CN_SKU_TriggerClass_Test 
    static testmethod void testTriggerClass(){
        
        Profile tempP = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User tempU2 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='666', LanguageLocaleKey='en_US', 
                                              LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser666@testorg.com', ASI_KOR_Commission_Code__c='1234567', 
                                              CompanyName = 'testUserCompanyName', Country = 'Korea');
        
        insert tempU2;
                
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_MFM_CN_POSM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , ASI_MFM_CN_OneTimeItem__c = 'Yes'
                                                   , OwnerID = tempU.id
                                                  ));
        insert tmpItemGroup;
        
        List<ASI_CRM_Product_Warehouse_Photo__c> tmpPhotoList = new List<ASI_CRM_Product_Warehouse_Photo__c>();
        
        ASI_CRM_Product_Warehouse_Photo__c tmpPhoto = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Photo_Category__c = 'Testing'
                                                                                             , ASI_CRM_Item_Group__c = tmpItemGroup[0].ID
                                                                                             , ASI_CRM_Photo_Version__c = 0.1
                                                                                             , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo')
                                                                                            );
        ASI_CRM_Product_Warehouse_Photo__c tmpPhoto2 = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Photo_Category__c = 'Testing'
                                                                                              , ASI_CRM_Item_Group__c = tmpItemGroup[0].ID
                                                                                              , ASI_CRM_Photo_Version__c = 0.2
                                                                                              , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo')
                                                                                             );
        tmpPhotoList.add(tmpPhoto);
        tmpPhotoList.add(tmpPhoto2);
        
        Insert tmpPhotoList;
        
        List<ASI_MFM_SKU_Code__c> tmpSKUList = new List<ASI_MFM_SKU_Code__c>();
        
        ASI_MFM_SKU_Code__c tmpSku = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                             , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                             , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_SKU')
                                                             , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        
        ASI_MFM_SKU_Code__c tmpSku2 = new ASI_MFM_SKU_Code__c(ASI_MFM_Item_Group__c = tmpItemGroup[0].id 
                                                              , name = 'testSkue', ASI_MFM_SKU_Code__c = 'aa'
                                                              , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_FOC_CN_POSM_SKU')
                                                              , ASI_CRM_Location_Owner_JDE__c = 'Testing 666');
        
    	tmpSKUList.add(tmpSku);
        tmpSKUList.add(tmpSku2);
        
        insert tmpSKUList;

		List<ASI_FOC_Warehouse__c> tmpWarehouse = new List<ASI_FOC_Warehouse__c>();
        tmpWarehouse.add(new ASI_FOC_Warehouse__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_FOC_Warehouse__cASI_FOC_CN_Warehouse')
                                                   , Name = 'TestWarehouse'
                                                   , ASI_FOC_Warehouse_Code__c = 'TestWarehouseCode'
                                                   , ASI_FOC_JDE_Customer_Number__c = 'TestWarehouse'
                                                   , OwnerID = tempU.id
                                                  ));
        
        insert tmpWarehouse;
        
        List<ASI_MFM_Inventory_Balance__c> tmpIB = new List<ASI_MFM_Inventory_Balance__c>();
        tmpIB.add(new ASI_MFM_Inventory_Balance__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Inventory_Balance__cASI_MFM_CN_Inventory_Balance')
                                                   , ASI_MFM_SKU__c = tmpSKUList[0].id
                                                   , ASI_MFM_Warehouse__c = tmpWarehouse[0].id
                                                   , OwnerID = tempU.id
                                                  ));
        
        insert tmpIB;
        
        
        List<ASI_MFM_InventoryBalanceDetail__c> tmpIBDList = new List<ASI_MFM_InventoryBalanceDetail__c>();
        
        ASI_MFM_InventoryBalanceDetail__c tmpIBD = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                   , Name = '20181019'
                                                   , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                   , ASI_MFM_Quantity__c = 100
                                                   , ASI_MFM_SFDCAvailableQuantity__c = 100
                                                   , ASI_MFM_JDEAvailableQuantity__c = 100
                                                   , ASI_MFM_Action__c = 'Disposal'
												   , ASI_MFM_ItemGroup__c = tmpItemGroup[0].id
                                                  );
        
        ASI_MFM_InventoryBalanceDetail__c tmpIBD2 = new ASI_MFM_InventoryBalanceDetail__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_InventoryBalanceDetail__cASI_MFM_CN_InventoryBalanceDetailRcrdTpy')
                                                   , Name = '20181019'
                                                   , ASI_MFM_InventoryBalance__c = tmpIB[0].id
                                                   , ASI_MFM_Quantity__c = 200
                                                   , ASI_MFM_SFDCAvailableQuantity__c = 200
                                                   , ASI_MFM_JDEAvailableQuantity__c = 200
                                                   , ASI_MFM_Action__c = 'Disposal'
												   , ASI_MFM_ItemGroup__c = tmpItemGroup[0].id
                                                  );
        
        tmpIBDList.add(tmpIBD);
        tmpIBDList.add(tmpIBD2);
        
        test.startTest();
        
        insert tmpIBDList;
        
        tmpIBD.ASI_MFM_JDEAvailableQuantity__c = 0;
        update tmpIBD;
        
        tmpIBD2.ASI_MFM_JDEAvailableQuantity__c = 0;
        update tmpIBD2;
        
        
        test.stopTest();
    }
    
}