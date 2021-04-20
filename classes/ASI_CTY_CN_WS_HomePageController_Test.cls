/*****************************************************************************************************************
 * Name:
 * Test Class: ASI_CTY_CN_WS_HomePageController_Test
 * Description: ASI_CTY_CN_WS_HomePageController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    -----------------------------------------------------------------------------
 * 2019-12-21       Alex                    
 **********************************************************************************************/
@isTest
private class ASI_CTY_CN_WS_HomePageController_Test {
    static testMethod void testMethod1() {
        Profile admin_p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//System Administrator
        User adminUser = new User(Alias = 'admin', Email='adminuser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='admin', LanguageLocaleKey='zh_CN', Autofollow__c = false,
                            LocaleSidKey='zh_CN', ProfileId = admin_p.Id,IsActive = true,
                            TimeZoneSidKey='Asia/Shanghai', UserName='test2@wholesaler.com',
                            CompanyName = 'Pernod Ricard China');
        insert adminUser;
        System.runAs(adminUser) {
            List<ASI_CTY_CN_WS_Setup__c> homePageList = new List<ASI_CTY_CN_WS_Setup__c>();
            homePageList.add(new ASI_CTY_CN_WS_Setup__c(Name = 'page1'
                    , ASI_CTY_CN_WS_Sequence__c = 1
                    , ASI_CTY_CN_WS_Image_Url__c = 'https://www.drinksandcommunity.cn/wordpress/wp-content/uploads/2019/09/banner-e1569576020458.jpg'
                    , ASI_CTY_CN_WS_Href__c = 'https://www.drinksandcommunity.cn/cn/post/619'
                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Setup__cASI_CTY_CN_WS_Banner')
            ));
            homePageList.add(new ASI_CTY_CN_WS_Setup__c(Name = '保乐力加官方旗舰店'
                    , ASI_CTY_CN_WS_Sequence__c = 1
                    , ASI_CTY_CN_WS_Title__c = '线上购买'
                    , ASI_CTY_CN_WS_Href__c = 'https://www.drinksandcommunity.cn/cn/post/619'
                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Setup__cASI_CTY_CN_WS_Footer')
            ));
            homePageList.add(new ASI_CTY_CN_WS_Setup__c(Name = '公告'
                    , ASI_CTY_CN_WS_Sequence__c = 1
                    , ASI_CTY_CN_WS_Subheadline__c = '即将上线,敬请期待!'
                    , ASI_CTY_CN_WS_Href__c = 'https://www.drinksandcommunity.cn/cn/post/619'
                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Setup__cASI_CTY_CN_WS_Announcement')
            ));

            insert homePageList;

            ASI_CTY_CN_WS_HomePageController.getHomeImageList();
            ASI_CTY_CN_WS_HomePageController.getHomeLinkMap();
            ASI_CTY_CN_WS_HomePageController.getHomeAnnouncement();
        }
    }
}