@isTest
private class LAT_VFC12_UploadPaymentsTest {

    @isTest static void basicTest() {
        LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
        LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
        LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);

        LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
        aiac.LAT_Status__c = 'Ação Finalizada';
        update aiac;

        String csv = 'ID CLIENTE,CLIENTE,Descrição 1,Valor/Quantidade 1,Descrição 2,Valor/Quantidade 2,Descrição 3,Valor/Quantidade 3,Descrição 4,Valor/Quantidade 4 \n'
                                + aiac.id + ',DISTRIBUIDORA APL,desc1,10,desc2,10,desc3,10,desc4,10 \n';

        ApexPages.CurrentPage().getparameters().put('id', ap.id);
        LAT_VFC12_UploadPaymentsController upc = new LAT_VFC12_UploadPaymentsController();
        upc.toParse = Blob.valueOf(csv);
        upc.upload();

    }
}