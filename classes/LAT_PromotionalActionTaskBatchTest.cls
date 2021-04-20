@isTest
private class LAT_PromotionalActionTaskBatchTest {

	@isTest static void LAT_PromotionalActionTaskBatch() {

			LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
			ap.LAT_Status__c = 'Ação iniciada';
			Date today = Date.today();
			Date nexTaskDate = today.addDays(60);
			ap.LAT_EndDate__c = nexTaskDate;
			update ap;
			LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
			LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
			LAT_ClientByRegionHandlerTest.voidInsertAtt(ap.id);

			LAT_ClientByRegionHandlerTest.generateLATConfig('AP_SLA_IMPLEMENTEDACTION', '10');
			LAT_ClientByRegionHandlerTest.generateLATConfig('AP_SLA_COLLECTS', '10');
			LAT_ClientByRegionHandlerTest.generateLATConfig('AP_KPI_COLLECTS', '0');


			LAT_ActionKPI__c kpi = LAT_ClientByRegionHandlerTest.createKPI(ap.Id);
			LAT_ClientByRegionHandlerTest.createBrand(ap.Id);
			LAT_ClientByRegionHandlerTest.insertMech(ap.Id);

			LAT_ClientKPI__c  existingKPI = new LAT_ClientKPI__c(LAT_AccountInAction__c = aiac.Id, LAT_ActionKPI__c = kpi.Id);
			insert existingKPI;
			//List<LAT_ClientKPI__c> existingKPI = [Select Id, CreatedDate, LAT_AccountInAction__r.LAT_PromotionalAction__c,  LAT_AccountInAction__r.LAT_PromotionalAction__r.LAT_EndDate__c from LAT_ClientKPI__c where LAT_AccountInAction__c IN : clientsIds order by createdDate desc];
			ap = [Select Id, (Select Id, LAT_Account__r.ownerId, LAT_Account__r.recordTypeId, LAT_Account__r.recordType.Name  from LAT_AccountInAction__r), (Select Id, LAT_PromotionalAction__c,  LAT_KPI__c, LAT_KPI__r.Name, LAT_KPI__r.LAT_KPI_Recurring__c, LAT_KPI__r.LAT_KPI_OffTrade__c, LAT_KPI__r.LAT_KPI_OnTrade__c from LAT_ActionKPIs__r where LAT_KPI__r.LAT_KPI_Recurring__c = true) from LAT_PromotionalAction__c where id =: ap.Id ];


		Test.startTest();
	        // LAT_PromotionalActionTaskBatch batch = new LAT_PromotionalActionTaskBatch();
	        // Database.execute(batch);
			Database.executeBatch(new LAT_PromotionalActionTaskBatch(),200 );
			List<Integer> inte = New List<Integer>();
			inte.add(10);
			LAT_PromotionalActionTaskBatch.generateKPIsRecucrentsForClients(ap, inte);

        Test.stopTest();
	}



}