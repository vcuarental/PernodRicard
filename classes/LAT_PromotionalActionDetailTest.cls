@isTest
private class LAT_PromotionalActionDetailTest {

    @isTest static void basicTest() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);

        ApexPages.StandardController sc = new ApexPages.standardController(ap);
        LAT_PromotionalActionDetailController pacdc = new LAT_PromotionalActionDetailController(sc);

        pacdc.redirect();
    }

}