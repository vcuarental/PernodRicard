@isTest
private class LAT_MX_VFC09_CatalogacionCheckList_Test {
	
	@isTest static void test_method_one() {
		Visitas__c v = basicData();
		LAT_MX_VFC09_CatalogacionCheckList cc = 
				new LAT_MX_VFC09_CatalogacionCheckList(new ApexPages.StandardController( v ));
		cc.save();
	}

	public static Visitas__c basicData() {
		LAT_MX_Categories__c cat = new LAT_MX_Categories__c(Name = 'Test C');
		insert cat;
		LAT_MX_Marcas__c mar = new LAT_MX_Marcas__c(Name = 'Test M');
		insert mar;
		
		Account acc = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
		insert acc;

		//Cria novo planejamento.
		Planejamento__c plan = new Planejamento__c();
		plan.Ano_de_Referencia__c = String.valueOf(Date.today().year() + 1);
		plan.M_s_de_Ref_rencia__c = 'Janeiro';
		plan.Name = 'Teste';
		plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'LAT_MX_PLV_NewPlanning' );
		insert plan;

		Visitas__c visita = new Visitas__c();
		visita.Conta__c = acc.Id;
		visita.Name = 'NOME';
		visita.Data_da_Visita__c = Date.newInstance(Date.today().year() + 1, 1, 1);
		visita.Hora_da_Visita__c = '08:00';
		visita.Planejamento__c = plan.Id;
		visita.RecordTypeId = RecordTypeForTest.getRecType( 'Visitas__c', 'LAT_MX_VTS_PlannedVisit' );
		visita.Resumo_da_Visita__c = 'teste';
		insert visita;

		return visita;
	}
	
}