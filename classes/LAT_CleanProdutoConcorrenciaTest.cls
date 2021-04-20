@isTest
private class LAT_CleanProdutoConcorrenciaTest {
	
    private static testMethod void TestBatch () {
    			
		test.startTest();
			Planejamento__c p = new Planejamento__c();
			p.Name = 'Test';
			p.M_s_de_Ref_rencia__c = 'Dezembro';
			p.Ano_de_Referencia__c = '2014';
			p.Status_do_Planejamento__c = 'Não Iniciado';
			insert p;

			Visitas__c v = new Visitas__c();
			v.Name = 'Test';
			v.Data_da_Visita__c = date.Today();
			v.Hora_da_Visita__c = '03:00';
			v.Tipo_de_Visita__c = 'POP';
			v.Status__c = 'Planejada';
			v.Planejamento__c = p.id;
			insert v;

			Checklist_de_visita__c cdv = new Checklist_de_visita__c();
			cdv.Visita__c = v.id;
			insert cdv;

			Produto_Concorr_ncia__c PPRC = new Produto_Concorr_ncia__c();
			PPRC.Checklist_de_visita__c = cdv.id;
			insert PPRC;

			Planejamento__c p1 = new Planejamento__c();
			p1.Name = 'Test';
			p1.M_s_de_Ref_rencia__c = 'Novembro';
			p1.Ano_de_Referencia__c = '2014';
			p1.Status_do_Planejamento__c = 'Não Iniciado';
			insert p1;

			Visitas__c v1 = new Visitas__c();
			v1.Name = 'Test';
			v1.Data_da_Visita__c = date.Today();
			v1.Hora_da_Visita__c = '03:00';
			v1.Tipo_de_Visita__c = 'POP';
			v1.Status__c = 'Planejada';
			v1.Planejamento__c = p.id;
			insert v1;

			Checklist_de_visita__c cdv1 = new Checklist_de_visita__c();
			cdv1.Visita__c = v1.id;
			insert cdv1;

			Produto_Concorr_ncia__c PPRC1 = new Produto_Concorr_ncia__c();
			PPRC1.Checklist_de_visita__c = cdv1.id;
			PPRC1.Qtde_de_Caixas_Estoque__c = 1;
			insert PPRC1;

			Map<Integer, List<Integer>> YearMonth = new Map<Integer, List<Integer>>();
			List<Integer> months = new List<Integer>{Date.Today().month()};
			YearMonth.put(Date.Today().year(), months);

			LAT_CleanProdutoConcorrencia cpc = new LAT_CleanProdutoConcorrencia(YearMonth);
			Database.executeBatch(cpc, 10);		
		test.stopTest();
		
	}
}