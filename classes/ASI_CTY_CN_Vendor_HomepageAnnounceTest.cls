@isTest
private class ASI_CTY_CN_Vendor_HomepageAnnounceTest {
    static testMethod void testMethod1() {

    	User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {

            List<ASI_CTY_CN_WS_Setup__c> homePageList = new List<ASI_CTY_CN_WS_Setup__c>();
            homePageList.add(new ASI_CTY_CN_WS_Setup__c(Name = 'page1'
                    , ASI_CTY_CN_WS_Sequence__c = 1
                    , ASI_CTY_CN_WS_Image_Url__c = 'https://www.drinksandcommunity.cn/wordpress/wp-content/uploads/2019/09/banner-e1569576020458.jpg'
                    , ASI_CTY_CN_WS_Href__c = 'https://www.drinksandcommunity.cn/cn/post/619'
                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Setup__cASI_CTY_CN_Vendor_Banner')
            ));
            homePageList.add(new ASI_CTY_CN_WS_Setup__c(Name = '保乐力加官方旗舰店'
                    , ASI_CTY_CN_WS_Sequence__c = 1
                    , ASI_CTY_CN_WS_Title__c = '线上购买'
                    , ASI_CTY_CN_WS_Href__c = 'https://www.drinksandcommunity.cn/cn/post/619'
                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Setup__cASI_CTY_CN_Vendor_Footer')
            ));
            homePageList.add(new ASI_CTY_CN_WS_Setup__c(Name = '公告'
                    , ASI_CTY_CN_WS_Sequence__c = 1
                    , ASI_CTY_CN_WS_Subheadline__c = '即将上线,敬请期待!'
                    , ASI_CTY_CN_WS_Href__c = 'https://www.drinksandcommunity.cn/cn/post/619'
                    , RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CTY_CN_WS_Setup__cASI_CTY_CN_Vendor_Announcement')
            ));

            insert homePageList;

            ASI_CTY_CN_Vendor_HomepageAnnounceCtr.getHomeImageList();
            ASI_CTY_CN_Vendor_HomepageAnnounceCtr.getHomeLinkMap();
            ASI_CTY_CN_Vendor_HomepageAnnounceCtr.getHomeAnnouncement(); 

        }
        
    }
}