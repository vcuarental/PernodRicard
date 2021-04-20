@isTest
private class LAT_VFC11_PAExportPaymentsTest {

    @isTest static void basicTest() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);

        Test.startTest();
        LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
        aiac.LAT_Status__c = 'Ação Finalizada';
        update aiac;

        LAT_ActionClientPayment__c acp = new LAT_ActionClientPayment__c(LAT_AccountInAction__c = aiac.id);
        insert acp;

        LAT_ActionClientPaymentLine__c acpl1 = new LAT_ActionClientPaymentLine__c();
        acpl1.LAT_Description__c = 'description1';
        acpl1.LAT_Value__c = 10;
        acpl1.LAT_ActionClientPayment__c = acp.id;
        insert acpl1;

        Test.stopTest();

        // ApexPages.CurrentPage().getparameters().put('id', ap.id);
        // LAT_VFC11_PAExportPaymentsController pExportC = new LAT_VFC11_PAExportPaymentsController();
    }

    @isTest static void basicTest2() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
        //LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
        LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
        aiac.LAT_Status__c = 'Ação Finalizada';
        update aiac;

        LAT_ActionClientPayment__c acp = new LAT_ActionClientPayment__c(LAT_AccountInAction__c = aiac.id);
        insert acp;


        Test.startTest();

        ApexPages.CurrentPage().getparameters().put('id', ap.id);
        LAT_VFC11_PAExportPaymentsController pExportC = new LAT_VFC11_PAExportPaymentsController();
        Test.stopTest();
    }





}