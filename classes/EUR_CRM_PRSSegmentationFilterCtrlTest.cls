@IsTest
private class EUR_CRM_PRSSegmentationFilterCtrlTest {

    @IsTest
    private static void getSelectionMethodOptionsTest() {
        System.runAs(makeUser()) {
            List<EUR_CRM_PRSSegmentationFilterCtrl.SelectOptionWrapper> selectionMethods =
                EUR_CRM_PRSSegmentationFilterCtrl.getSelectionMethodOptions();
            System.assertNotEquals(0, selectionMethods.size());

            System.assertEquals(EUR_CRM_PRSSegmentationFilterCtrl.NONE, selectionMethods[0].value);
            System.assertEquals(EUR_CRM_PRSSegmentationFilterCtrl.PROS, selectionMethods[1].value);
//            System.assertEquals(EUR_CRM_PRSSegmentationFilterCtrl.PROFS, selectionMethods[2].value);
        }
    }

    @IsTest
    private static void getPROSTableTest() {
        insert makeGot('EUR_GB_PRS_On_Trade_Group_Outlet_Type');
        insert makeSegAspect('EUR_GB_PRS_Segmentation_Aspect_Image_Level');
        System.runAs(makeUser()) {

        List<EUR_CRM_PRSSegmentationFilterCtrl.PROSWrapperAura> prosTable =
            EUR_CRM_PRSSegmentationFilterCtrl.getPROSTable();
        System.assertNotEquals(0, prosTable.size());
        }
    }

    private static EUR_CRM_PRS_Seg_Aspect__c makeSegAspect(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_PRS_Seg_Aspect__c(
            RecordTypeId = rtId
        ,   EUR_CRM_Segmentation_IL_Aspect_Name__c = 'Iconic'
        );
    }

    private static EUR_CRM_PRS_Group_Outlet_Type__c makeGot(String rt) {
        Id rtId = Schema.SObjectType.EUR_CRM_PRS_Group_Outlet_Type__c.getRecordTypeInfosByDeveloperName().get(rt).getRecordTypeId();
        return new EUR_CRM_PRS_Group_Outlet_Type__c(
            RecordTypeId = rtId
        ,   EUR_CRM_PRS_Group_Outlet_Name__c = 'Restaurant'
        );
    }

    @IsTest
    private static void getPROFSTest() {
        List<EUR_CRM_PRSSegmentationFilterCtrl.PROFSWrapperAura> profs =
            EUR_CRM_PRSSegmentationFilterCtrl.getPROFS();

        System.assertNotEquals(0, profs.size());
    }


    /* ========================================================= */
    /*     Makers
    /* ========================================================= */
    private static User makeUser() {
        return new User(
            Alias = 'standt'
        ,   Email = 'standarduser@testorg.com'
        ,   EmailEncodingKey = 'UTF-8'
        ,   LastName = 'Testing'
        ,   LanguageLocaleKey = 'en_US'
        ,   LocaleSidKey = 'en_US'
        ,   ProfileId = UserInfo.getProfileId()
        ,   TimeZoneSidKey = 'America/Los_Angeles'
        ,   Username = 'standarduser' + DateTime.now().getTime() + '@testorg.com'
        ,   EUR_CRM_Affiliate_Code_Picklist__c = 'GB'
        );
    }

}