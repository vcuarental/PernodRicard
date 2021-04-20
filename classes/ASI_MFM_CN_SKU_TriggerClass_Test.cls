@isTest
private class ASI_MFM_CN_SKU_TriggerClass_Test {
    
    Private static User tempU = [select id from user where CompanyName = 'Pernod Ricard China' limit 1];
    Private Static List<ASI_MFM_Item_Group__c> tmpItemGroup = new List<ASI_MFM_Item_Group__c>();
    
    static testmethod void testTriggerClass(){
        
        Profile tempP = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User tempU2 = new User(Alias = '666', Email='standarduser666@testorg.com', EmailEncodingKey='UTF-8', FirstName='Testing', LastName='666', LanguageLocaleKey='en_US', 
                                          		LocaleSidKey='en_US', ProfileId = tempP.Id, TimeZoneSidKey='Asia/Hong_Kong', UserName='standarduser666@testorg.com', ASI_KOR_Commission_Code__c='1234567', 
                                              CompanyName = 'testUserCompanyName', Country = 'Korea');
        
        insert tempU2;
                
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
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
        
        test.startTest();
        
        insert tmpSKUList[0];
        Insert tmpSKUList[1];
        
        Test.setCurrentPage(Page.ASI_CRM_CN_ProductWarehouse_ListPage);
        Apexpages.currentPage().getParameters().put('id', tmpItemGroup[0].id);
        Apexpages.StandardController sc = new apexpages.StandardController(tmpItemGroup[0]);
        ASI_CRM_CN_ProductWarehouse_ListCTRL tmpC = new ASI_CRM_CN_ProductWarehouse_ListCTRL(sc);
        
        Test.setCurrentPage(Page.ASI_CRM_CN_ProductWareHouse_SKUListPage);
        Apexpages.currentPage().getParameters().put('id', tmpSKUList[0].id);
        Apexpages.StandardController sc2 = new apexpages.StandardController(tmpSKUList[0]);
        ASI_CRM_CN_ProductWarehouse_ListCTRL tmpC2 = new ASI_CRM_CN_ProductWarehouse_ListCTRL(sc2);
        
        test.stopTest();
    }
    static testMethod void testFileAttachmentController(){
        
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = tempU.id
                                                  ));
        insert tmpItemGroup;
        
        test.startTest();
        
        PageReference pageRef = Page.ASI_CRM_CN_ProductWarehouse_AttachPage;
        
        pageRef.getParameters().put('id', tmpItemGroup[0].Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(tmpItemGroup[0]);
        
        ASI_CRM_CN_ProductWarehouse_AttachCTRL fileAttachCon = new ASI_CRM_CN_ProductWarehouse_AttachCTRL();
        
        ASI_CRM_CN_ProductWarehouse_AttachCTRL fileAttachCon1 = new ASI_CRM_CN_ProductWarehouse_AttachCTRL(stdCon);
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = tmpItemGroup[0].Id;
        fileAttachCon.attachmentObjType = 'ASI_CRM_Product_Warehouse_Photo__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = attachData.size();
        fileAttachCon.contentFileName = 'Test.pdf';
        fileAttachCon.contentCategory = 'Others';
        fileAttachCon.isAttachInApproval  = false;
        
        PageReference returnPage = fileAttachCon.uploadAction();
        fileAttachCon.cancel();
        Boolean hasCategoryField = fileAttachCon.hasCategoryField;
        Integer uploadStepCount = fileAttachCon.getUploadStepCount();
        List<SelectOption> categories = fileAttachCon.categories;
        test.stopTest();
    }
    
    static testMethod void testFileAttachmentControllerError(){
        
        tmpItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                   , Name = 'TestItemGroup'
                                                   , ASI_MFM_Item_Group_Code__c = 'TestItemGroupCode'
                                                   , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                   , OwnerID = tempU.id
                                                  ));
        insert tmpItemGroup;
        
        test.startTest();
        PageReference pageRef = Page.ASI_CRM_CN_ProductWarehouse_AttachPage;
        
        pageRef.getParameters().put('id', tmpItemGroup[0].Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(tmpItemGroup[0]);
        
        ASI_CRM_CN_ProductWarehouse_AttachCTRL fileAttachCon = new ASI_CRM_CN_ProductWarehouse_AttachCTRL();
        
        Blob attachData = Blob.toPdf('a');
        fileAttachCon.sObjParentId = tempU.id;
        fileAttachCon.attachmentObjType = 'ASI_CRM_Product_Warehouse_Photo__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = attachData.size();
        fileAttachCon.contentFileName = 'Test.pdf';
        fileAttachCon.contentCategory = 'Others';
        
        PageReference returnPage = fileAttachCon.uploadAction();
        test.stopTest();
        
    }
}