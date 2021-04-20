@isTest
private class LAT_VFC13_APClientPaymentTest {

    @isTest static void basicTest() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);

        LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
        aiac.LAT_Status__c = 'Pagamentos Autorizados';
        update aiac;

        ApexPages.StandardController sc = new ApexPages.standardController(aiac);

        LAT_VFC13_APClientPaymentController vpc13 = new LAT_VFC13_APClientPaymentController(sc);
        LAT_ActionClientPayment__c acp = new LAT_ActionClientPayment__c(LAT_AccountInAction__c = aiac.id);
        insert acp;

        LAT_ActionClientPaymentLine__c acpl1 = new LAT_ActionClientPaymentLine__c();
        acpl1.LAT_Description__c = 'description1';
        acpl1.LAT_Value__c = 10;
        acpl1.LAT_ActionClientPayment__c = acp.id;
        insert acpl1;

        vpc13 = new LAT_VFC13_APClientPaymentController(sc);

        vpc13.showEdit();
        vpc13.save();
    }

}