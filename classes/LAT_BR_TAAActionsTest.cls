@isTest
private class LAT_BR_TAAActionsTest {
	
	@testSetup
    public static void testSetup() {
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        Account acc = LAT_Account_TestFactory.getBRAAccountBase('Off_Trade');
        insert acc;
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
              Name = 'TAA_SERVICE_EMAIL',
              LAT_Value__c = ';');
        insert cfg;

		Contact cont = new Contact(
			Email = 'test@test.com',
			FirstName = 'test',
			LastName = 'Contact',
			AccountId = acc.id,
			Phone = '11 1111-1111'
		);
		insert cont;
    }

	@isTest static void TAAsendConfirmationEmailTest() {
		
		Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];
        
		Test.startTest();
			Planejamento__c plan = new Planejamento__c();
	        plan.Ano_de_Referencia__c = '2012';
	        plan.M_s_de_Ref_rencia__c = 'Janeiro';
	        plan.Name = 'Teste';
	        plan.OwnerId = UserInfo.getUserId();//usuario.Id;
	        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
	        try{insert plan;}catch(Exception e){}
	        
	        Id idRecTypeVis = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
	    
		
	        Visitas__c visita = new Visitas__c(
	          Name = 'Teste',
	          Data_da_Visita__c = System.today(),
	          Hora_da_Visita__c = '08:00',
	          Planejamento__c = plan.Id,
	          Tipo_de_Visita__c = 'Execução',
	          Conta__c = cont.AccountId,
	          Status__c = 'Planejada',
	          RecordTypeId = idRecTypeVis,
	          Resumo_da_Visita__c = 'Teste'
	        );
	        try{insert visita;}catch(Exception e){}

	        LAT_BR_TAA__c taa = new LAT_BR_TAA__c(
	        	Contact__c = cont.id,
	        	Visit__c = visita.id,
	        	ClientObjectives__c = 'Test Client Objectives',
	        	PRBObjectives__c = 'Test PRBObjectives',
	        	LastVisit__c = 'Test LastVisit',
	        	DoNotSendEmail__c = false,
	        	Date__c = date.today()
	        );
			insert taa;
			List<LAT_BR_TAAAgreement__c> taaAgList = new List<LAT_BR_TAAAgreement__c>();
			LAT_BR_TAAAgreement__c taaAg = new LAT_BR_TAAAgreement__c(
				LAT_BR_TAA__c = taa.id,
				Accompaniment__c = true,
				Due_Date__c = date.today(),
				Items__c = 'item 1'
			);
			LAT_BR_TAAAgreement__c taaAg2 = new LAT_BR_TAAAgreement__c(
				LAT_BR_TAA__c = taa.id,
				Accompaniment__c = true,
				Items__c = 'item 2'
			);
			taaAgList.add(taaAg);
			taaAgList.add(taaAg2);

			LAT_BR_TAAActions.insertPDF(new Set<Id> {taa.Id});
			LAT_BR_TAAActions.addTAAAttachment(new List<String> {taa.Id});
			insert taaAgList;
			visita.Status__c = 'Encerrada';
			visita.LAT_MX_GoalAchieved__c = 'Test goal';
			visita.LAT_BR_CommentsAboutVisitGoal__c = 'Test Comments';
			//update visita;

			taaAg.toDelete__c = true;
			//update taaAg;
		Test.stopTest();
	}
	
	@isTest static void TAAsendConfirmationEmailTest2() {
		
		Contact cont = [SELECT Id, AccountId FROM Contact LIMIT 1];
        
		Test.startTest();
			Planejamento__c plan = new Planejamento__c();
	        plan.Ano_de_Referencia__c = '2012';
	        plan.M_s_de_Ref_rencia__c = 'Janeiro';
	        plan.Name = 'Teste';
	        plan.OwnerId = UserInfo.getUserId();//usuario.Id;
	        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
	        try{insert plan;}catch(Exception e){}
	        
	        Id idRecTypeVis = RecordTypeForTest.getRecType( 'Visitas__c', 'BRA_Standard' );
	    
		
	        Visitas__c visita = new Visitas__c(
	          Name = 'Teste',
	          Data_da_Visita__c = System.today(),
	          Hora_da_Visita__c = '08:00',
	          Planejamento__c = plan.Id,
	          Tipo_de_Visita__c = 'Execução',
	          Conta__c = cont.AccountId,
	          Status__c = 'Planejada',
	          RecordTypeId = idRecTypeVis,
	          Resumo_da_Visita__c = 'Teste'
	        );
	        try{insert visita;}catch(Exception e){}

	        LAT_BR_TAA__c taa = new LAT_BR_TAA__c(
	        	Contact__c = cont.id,
	        	Visit__c = visita.id,
	        	ClientObjectives__c = 'Test Client Objectives',
	        	PRBObjectives__c = 'Test PRBObjectives',
	        	LastVisit__c = 'Test LastVisit',
	        	DoNotSendEmail__c = false,
	        	Date__c = date.today()
	        );
			insert taa;
			List<LAT_BR_TAAAgreement__c> taaAgList = new List<LAT_BR_TAAAgreement__c>();
			LAT_BR_TAAAgreement__c taaAg = new LAT_BR_TAAAgreement__c(
				LAT_BR_TAA__c = taa.id,
				Accompaniment__c = true,
				Due_Date__c = date.today(),
				Items__c = 'item 1'
			);
			LAT_BR_TAAAgreement__c taaAg2 = new LAT_BR_TAAAgreement__c(
				LAT_BR_TAA__c = taa.id,
				Accompaniment__c = true,
				Items__c = 'item 2'
			);
			taaAgList.add(taaAg);
			taaAgList.add(taaAg2);

			insert taaAgList;
			LAT_BR_TAAActions.DeleteAgreements(taaAgList);
			LAT_BR_TAAActions.sendEmailToContact(new Set<Id> {taa.Id});
			
			visita.Status__c = 'Encerrada';
			visita.LAT_MX_GoalAchieved__c = 'Test goal';
			visita.LAT_BR_CommentsAboutVisitGoal__c = 'Test Comments';
			//update visita;

			taaAg.toDelete__c = true;
			//update taaAg;
		Test.stopTest();
	}
	
}