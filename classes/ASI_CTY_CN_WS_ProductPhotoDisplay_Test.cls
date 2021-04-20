/*****************************************************************************************************************
 * Name:
 * Test Class: ASI_CTY_CN_WS_ProductPhotoDisplay_Test
 * Description: ASI_CTY_CN_WS_ProductPhotoDisplayCtrl
 * 
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-12-22       Alex                    
 **********************************************************************************************/
@isTest
private class ASI_CTY_CN_WS_ProductPhotoDisplay_Test {
    @testSetup
    private static void createTestData() {
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;
        System.runAs(adminUser) {
                ASI_MFM_Item_Group__c itemGroup = ASI_CTY_CN_WS_TestDataFactory.generateItemGroup(true, 'TestItemGroup');
                List<ASI_CRM_Product_Warehouse_Photo__c> photos = new List<ASI_CRM_Product_Warehouse_Photo__c>();
                ASI_CRM_Product_Warehouse_Photo__c photo1 = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Item_Group__c = itemGroup.Id,
                                                                                                  ASI_CRM_Photo_Category__c='Bottle Front',
                                                                                                  ASI_CRM_Photo_Version__c=1.0,
                                                                                                  ASI_CRM_Comments__c='image1',
                                                                                                  ASI_FileID__c='a000000000001',
                                                                                                  ASI_File_Extension__c = 'test1',
                                                                                                  ASI_CTY_CN_WS_Premium_Display_Seq__c = '1',
                                                                                                  RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo'));
                photos.add(photo1);
                ASI_CRM_Product_Warehouse_Photo__c photo2 = new ASI_CRM_Product_Warehouse_Photo__c(ASI_CRM_Item_Group__c = itemGroup.Id,
                                                                                                  ASI_CRM_Photo_Category__c='Bottle Front',
                                                                                                  ASI_CRM_Photo_Version__c=2.0,
                                                                                                  ASI_CRM_Comments__c='image2',
                                                                                                  ASI_FileID__c='a000000000002',
                                                                                                  ASI_File_Extension__c = 'test2',
                                                                                                  RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Product_Warehouse_Photo__cASI_CRM_CN_Product_Warehouse_Photo'));
                photos.add(photo2);
                insert photos;
        }
    }

    static testMethod void testMethod1() {
        User adminUser = [select id from User where UserName='test2@wholesaler.com' limit 1];
        System.runAs(adminUser) {
            ASI_MFM_Item_Group__c itemGroup = [select Id from ASI_MFM_Item_Group__c limit 1];
            ApexPages.StandardController sc = new ApexPages.StandardController(itemGroup);
            ASI_CTY_CN_WS_ProductPhotoDisplayCtrl photoDisplay = new ASI_CTY_CN_WS_ProductPhotoDisplayCtrl(sc);
            photoDisplay.editSeq();
            List<ASI_CRM_Product_Warehouse_Photo__c> updatePhotos = [select id, ASI_CTY_CN_WS_Premium_Display_Seq__c from ASI_CRM_Product_Warehouse_Photo__c where ASI_CRM_Photo_Version__c = 2.0];
            updatePhotos[0].ASI_CTY_CN_WS_Premium_Display_Seq__c = '1';
            List<ASI_CRM_Product_Warehouse_Photo__c> deletePhotos = [select id, ASI_CTY_CN_WS_Premium_Display_Seq__c from ASI_CRM_Product_Warehouse_Photo__c where ASI_CRM_Photo_Version__c = 1.0];
            photoDisplay.attachmentList = updatePhotos;
            photoDisplay.deleteSeqList = deletePhotos;
            photoDisplay.saveSeq();
        }
    }
}