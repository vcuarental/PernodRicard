@isTest
private class LAT_BR_VFC25_TrainingSurvey_Test {
	static testMethod void  Test_1() {
    
    List<LAT_BR_TrainingSurveyQuestions__c> settings = new List<LAT_BR_TrainingSurveyQuestions__c>();
    settings.add(new LAT_BR_TrainingSurveyQuestions__c(Name = 'test Moxo', LAT_BR_TSQ_Type__c='MIXOLOGISTA',LAT_BR_TSQ_Question__c='Foi realizado treinamento com mixologista?', LAT_BR_TSQ_Order__c = 2));  
    settings.add(new LAT_BR_TrainingSurveyQuestions__c(Name = 'Test CSR', LAT_BR_TSQ_Type__c='CSR', LAT_BR_TSQ_Question__c='Foi realizado treinamento de CSR?', LAT_BR_TSQ_Order__c = 1)); 
    settings.add(new LAT_BR_TrainingSurveyQuestions__c(Name = 'Test Other', LAT_BR_TSQ_Type__c='OTHER', LAT_BR_TSQ_Question__c='Foi realizado otro treinamento?', LAT_BR_TSQ_Order__c = 3));   
    insert settings;
    //Cria novo usuario.
    User usuario = new User();
    usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
    insert usuario; 

    Account acc = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
    insert acc;
    Test.startTest();
    Id idRecTypePlan = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
   //Cria novo planejamento.
    Planejamento__c plan = new Planejamento__c();
    plan.Ano_de_Referencia__c = '2015';
    plan.M_s_de_Ref_rencia__c = 'Fevereiro';
    plan.Name = 'Teste';
    plan.OwnerId = usuario.Id;
    plan.RecordTypeId = idRecTypePlan;
    insert plan;
    
    //Cria nova visita
    Visitas__c visita = new Visitas__c();
    visita.Name = 'Teste';
    visita.Data_da_Visita__c = System.today();
    visita.Hora_da_Visita__c = '08:00';
    visita.Planejamento__c = plan.Id;
    visita.Tipo_de_Visita__c = 'Execução';
    visita.Conta__c = acc.Id;
    visita.Status__c = 'Planejada';
    visita.RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
    visita.Resumo_da_Visita__c = 'teste';
    insert visita;
		LAT_BR_VFC25_TrainingSurvey controller1 = new LAT_BR_VFC25_TrainingSurvey();
    controller1.cancel();
    ApexPages.currentPage().getParameters().put('visita', visita.Id);

    LAT_BR_VFC25_TrainingSurvey controller = new LAT_BR_VFC25_TrainingSurvey();
    controller.getposibleAnswers();
    controller.cancel();
    controller.questions.get(0).Answer = 'SIM';
    controller.questions.get(0).data = Date.today();
    controller.save();
    controller.questions.get(1).Answer = 'SIM';
    controller.questions.get(1).data = Date.today();
    controller.questions.get(2).Answer = 'SIM';
    controller.questions.get(2).data = Date.today();
    controller.save();
    controller.questions.get(2).OtherText = 'teste other text';
    controller.save();


    Test.stopTest();
	}
}