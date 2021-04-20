@isTest
private class LAT_FocoxNoFocoControllerTest {
	
	@isTest static void basicCoverage() {
	    LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
	    
	    LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
	    ap.LAT_StartDate__c = Date.today().addDays(-10);
	    ap.LAT_Status__c = 'Ação iniciada';
	    update ap;

	    LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
	    LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
	    
	    Test.startTest();
		    LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
		    aiac.LAT_Status__c = 'Ação iniciada';
		    update aiac;

		    LAT_KeyBrand__c keyBrand = new LAT_KeyBrand__c();
		    keyBrand.Name = 'Testing Brand';
		    insert keyBrand;

		    LAT_PromotionalActionKeyBrands__c apKeyBrand = new LAT_PromotionalActionKeyBrands__c();
		    apKeyBrand.Promotional_Action__c = ap.id;
		    apKeyBrand.LAT_KeyBrand__c = keyBrand.id;
		    insert apKeyBrand;
			
			LAT_FocoxNoFocoReportController fnf = new LAT_FocoxNoFocoReportController();

			LAT_FocoxNoFocoReportController.initialAction('Testing');
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, false);
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, true);
			LAT_FocoxNoFocoReportController.getAccountsForAnalitic(new List<String>(), new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteAnaliticReport(new List<String>(), new List<String>(), new List<String>(), '', '', new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteReport(new List<String>(), new List<String>(), new List<String>(), fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c, fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c);

			fnf.doChangeDate();
			fnf.doExportPDF();
			fnf.doExportExcel();
			fnf.getColorTab();

			LAT_FocoxNoFocoReportController.wrapAnaliticReportRow warp = new LAT_FocoxNoFocoReportController.wrapAnaliticReportRow('', '', 0, 0, '', '');
			LAT_FocoxNoFocoReportController.wrapFilter wf = new LAT_FocoxNoFocoReportController.wrapFilter();
			wf.regional = '';
			wf.brands = '';
			wf.pops = '';

			fnf.rightOptionsHidden = ',,,';
			fnf.leftOptionsHidden = ',,,';
			fnf.doAddCategory();
			fnf.doRemoveCategory();
		Test.stopTest();
	}

	@isTest static void basicAnaliticCoverage() {
	    LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
	    
	    LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
	    ap.LAT_StartDate__c = Date.today().addDays(-10);
	    ap.LAT_Status__c = 'Ação iniciada';
	    update ap;

	    LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
	    LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
	    
	    Test.startTest();
		    LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
		    aiac.LAT_Status__c = 'Ação iniciada';
		    update aiac;

		    LAT_KeyBrand__c keyBrand = new LAT_KeyBrand__c();
		    keyBrand.Name = 'Testing Brand';
		    insert keyBrand;

		    LAT_PromotionalActionKeyBrands__c apKeyBrand = new LAT_PromotionalActionKeyBrands__c();
		    apKeyBrand.Promotional_Action__c = ap.id;
		    apKeyBrand.LAT_KeyBrand__c = keyBrand.id;
		    insert apKeyBrand;
			
			system.currentPageReference().getParameters().put('isAnalitic', '');
			LAT_FocoxNoFocoReportController fnf = new LAT_FocoxNoFocoReportController();

			LAT_FocoxNoFocoReportController.initialAction('Testing');
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, false);
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, true);
			LAT_FocoxNoFocoReportController.getAccountsForAnalitic(new List<String>(), new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteAnaliticReport(new List<String>(), new List<String>(), new List<String>(), '', '', new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteReport(new List<String>(), new List<String>(), new List<String>(), fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c, fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c);

			fnf.doChangeDate();
			fnf.doExportPDF();
			fnf.doExportExcel();
			fnf.getColorTab();

			LAT_FocoxNoFocoReportController.wrapAnaliticReportRow warp = new LAT_FocoxNoFocoReportController.wrapAnaliticReportRow('', '', 0, 0, '', '');
			LAT_FocoxNoFocoReportController.wrapFilter wf = new LAT_FocoxNoFocoReportController.wrapFilter();
			wf.regional = '';
			wf.brands = '';
			wf.pops = '';

			fnf.rightOptionsHidden = ',,,';
			fnf.leftOptionsHidden = ',,,';
			fnf.doAddCategory();
			fnf.doRemoveCategory();

			List<Account> acc = [Select id, Name, (Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c 
                                            from LAT_AccountInAction__r
                                            order by LAT_PromotionalAction__r.LAT_StartDate__c) 
                            		from account LIMIT 1];
			if (!acc.isEmpty()) {
				LAT_FocoxNoFocoReportController.tieneFoco(acc.get(0), date.today());
				LAT_FocoxNoFocoReportController.doExecuteAnaliticReport(new List<String>(), new List<String>(), new List<String>(), acc.get(0).id, '', new List<String>{'Maio/2016','Junho/2016'});
			
			}
		Test.stopTest();
	}

		@isTest static void basicCoverageB() {
            Utils.setMigrationDoneTest(true);   
	    LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
	    
	    LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
	    ap.LAT_StartDate__c = Date.today().addDays(-10);
	    ap.LAT_Status__c = 'Ação iniciada';
	    update ap;

	    LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
	    LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
	    
	    Test.startTest();
            Utils.setMigrationDoneTest(true);   
		    LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
		    aiac.LAT_Status__c = 'Ação iniciada';
		    update aiac;

		    LAT_KeyBrand__c keyBrand = new LAT_KeyBrand__c();
		    keyBrand.Name = 'Testing Brand';
		    insert keyBrand;

		    LAT_PromotionalActionKeyBrands__c apKeyBrand = new LAT_PromotionalActionKeyBrands__c();
		    apKeyBrand.Promotional_Action__c = ap.id;
		    apKeyBrand.LAT_KeyBrand__c = keyBrand.id;
		    insert apKeyBrand;
			
			LAT_FocoxNoFocoReportController fnf = new LAT_FocoxNoFocoReportController();

			LAT_FocoxNoFocoReportController.initialAction('Testing');
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, false);
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, true);
			LAT_FocoxNoFocoReportController.getAccountsForAnalitic(new List<String>(), new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteAnaliticReport(new List<String>(), new List<String>(), new List<String>(), '', '', new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteReport(new List<String>(), new List<String>(), new List<String>(), fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c, fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c);

			fnf.doChangeDate();
			fnf.doExportPDF();
			fnf.doExportExcel();
			fnf.getColorTab();

			LAT_FocoxNoFocoReportController.wrapAnaliticReportRow warp = new LAT_FocoxNoFocoReportController.wrapAnaliticReportRow('', '', 0, 0, '', '');
			LAT_FocoxNoFocoReportController.wrapFilter wf = new LAT_FocoxNoFocoReportController.wrapFilter();
			wf.regional = '';
			wf.brands = '';
			wf.pops = '';

			fnf.rightOptionsHidden = ',,,';
			fnf.leftOptionsHidden = ',,,';
			fnf.doAddCategory();
			fnf.doRemoveCategory();
		Test.stopTest();
	}

	@isTest static void basicAnaliticCoverageB() {
            Utils.setMigrationDoneTest(true);   

	    LAT_RegionalSupervisor__c rs = LAT_ClientByRegionHandlerTest.createSupervisor(userInfo.getUserId());
	    
	    LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
	    ap.LAT_StartDate__c = Date.today().addDays(-10);
	    ap.LAT_Status__c = 'Ação iniciada';
	    update ap;

	    LAT_ClientByRegion__c cbrOn = LAT_ClientByRegionHandlerTest.createOnCBR(ap.id);
	    LAT_ClientByRegion__c cbrOff = LAT_ClientByRegionHandlerTest.createOffCBR(ap.id);
	    
	    Test.startTest();
            Utils.setMigrationDoneTest(true);   
		    LAT_AccountInAction__c aiac = LAT_ClientByRegionHandlerTest.createAccountInAction(ap.id);
		    aiac.LAT_Status__c = 'Ação iniciada';
		    update aiac;

		    LAT_KeyBrand__c keyBrand = new LAT_KeyBrand__c();
		    keyBrand.Name = 'Testing Brand';
		    insert keyBrand;

		    LAT_PromotionalActionKeyBrands__c apKeyBrand = new LAT_PromotionalActionKeyBrands__c();
		    apKeyBrand.Promotional_Action__c = ap.id;
		    apKeyBrand.LAT_KeyBrand__c = keyBrand.id;
		    insert apKeyBrand;
			
			system.currentPageReference().getParameters().put('isAnalitic', '');
			LAT_FocoxNoFocoReportController fnf = new LAT_FocoxNoFocoReportController();

			LAT_FocoxNoFocoReportController.initialAction('Testing');
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, false);
			LAT_FocoxNoFocoReportController.getCategoryBrands(fnf.planDesde, fnf.planHasta, true);
			LAT_FocoxNoFocoReportController.getAccountsForAnalitic(new List<String>(), new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteAnaliticReport(new List<String>(), new List<String>(), new List<String>(), '', '', new List<String>());
			LAT_FocoxNoFocoReportController.doExecuteReport(new List<String>(), new List<String>(), new List<String>(), fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c, fnf.planDesde.M_s_de_Ref_rencia__c, fnf.planDesde.Ano_de_Referencia__c);

			fnf.doChangeDate();
			fnf.doExportPDF();
			fnf.doExportExcel();
			fnf.getColorTab();

			LAT_FocoxNoFocoReportController.wrapAnaliticReportRow warp = new LAT_FocoxNoFocoReportController.wrapAnaliticReportRow('', '', 0, 0, '', '');
			LAT_FocoxNoFocoReportController.wrapFilter wf = new LAT_FocoxNoFocoReportController.wrapFilter();
			wf.regional = '';
			wf.brands = '';
			wf.pops = '';

			fnf.rightOptionsHidden = ',,,';
			fnf.leftOptionsHidden = ',,,';
			fnf.doAddCategory();
			fnf.doRemoveCategory();

			List<Account> acc = [Select id, Name, (Select id, LAT_PromotionalAction__r.LAT_StartDate__c, LAT_PromotionalAction__r.LAT_EndDate__c 
                                            from LAT_AccountInAction__r
                                            order by LAT_PromotionalAction__r.LAT_StartDate__c) 
                            		from account LIMIT 1];
			if (!acc.isEmpty()) {
				LAT_FocoxNoFocoReportController.tieneFoco(acc.get(0), date.today());
				LAT_FocoxNoFocoReportController.doExecuteAnaliticReport(new List<String>(), new List<String>(), new List<String>(), acc.get(0).id, '', new List<String>{'Maio/2016','Junho/2016'});
			
			}
		Test.stopTest();
	}
	
}