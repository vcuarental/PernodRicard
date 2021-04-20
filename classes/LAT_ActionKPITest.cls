@isTest
private class LAT_ActionKPITest {
	
	@isTest static void testActionKPITrigger() {
		LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
    	LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
    	LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
        aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
        update aiac;
        
    	LAT_ActionKPIMaster__c kpiMaster = createKPI();

    	LAT_ActionKPI__c actionKPI = new LAT_ActionKPI__c();
    	actionKPI.LAT_KPI__c = kpiMaster.id;
    	actionKPI.LAT_PromotionalAction__c = ap.id;
    	insert actionKPI;

	}

	@isTest static void testActionKPIUPload() {
		LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
    	LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
    	LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
        aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
        update aiac;
    	LAT_ActionKPIMaster__c kpiMaster = createKPI();

    	LAT_ActionKPI__c actionKPI = new LAT_ActionKPI__c();
    	actionKPI.LAT_KPI__c = kpiMaster.id;
    	actionKPI.LAT_PromotionalAction__c = ap.id;
    	insert actionKPI;

        LAT_VFC16_UploadKPIController ukpic = new LAT_VFC16_UploadKPIController();
        ukpic.upload();
        ukpic.cancel();
	}

	@isTest static void testActionKPIDownload() {
		LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
    	LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
    	LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
        aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
        update aiac;
    	LAT_ActionKPIMaster__c kpiMaster = createKPI();

    	LAT_ActionKPI__c actionKPI = new LAT_ActionKPI__c();
    	actionKPI.LAT_KPI__c = kpiMaster.id;
    	actionKPI.LAT_PromotionalAction__c = ap.id;
    	insert actionKPI;

    	LAT_VFC15_APActionKPIController apAction = new LAT_VFC15_APActionKPIController();

	}

	public static LAT_ActionKPIMaster__c createKPI() {
		LAT_ActionKPIMaster__c master = new LAT_ActionKPIMaster__c();
		master.LAT_Description__c = 'Testing';
		master.LAT_Type__c = 'Number';
		insert master;

		return master;
	}
	
}