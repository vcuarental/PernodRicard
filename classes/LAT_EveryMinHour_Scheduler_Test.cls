@isTest
private class LAT_EveryMinHour_Scheduler_Test {
	
	@isTest static void test_EveryHour() {

		setup();
		//insert createSchedulerConfig('PCS01_AnalyticsOfCCBatch_AR', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_MX_Planejamento_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_BR_Planejamento_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_Contract_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_CheckPaymentStatusOnME_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
        insert createSchedulerConfig('LAT_BR_Check_Pending_Visits_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
        insert createSchedulerConfig('LAT_ReceiptValidations_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
        insert createSchedulerConfig('LAT_Check_Account_Chaged_Owner_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
        insert createSchedulerConfig('LAT_ApprovalProcessSLA_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_RecordIntegrationVerifications', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_AR_B2B_PriceCalc_Scheduler', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);

		Test.startTest();
		
		LAT_EveryHour_Scheduler sh1 = new LAT_EveryHour_Scheduler();
		String sch = '0 0 2 * * ?';
        try{System.schedule('Test EveryHour Schedule', sch, sh1);}catch(Exception e){}
        
		Test.stopTest();
        delete [SELECT id from LAT_SchedulerConfig__c];
        insert createSchedulerConfig('LAT_BR_PromotionalActionScheduler', 'LAT_EveryHour_Scheduler', Datetime.now().day(), Datetime.now().hour(), Datetime.now().minute(), 20);
		try{System.schedule('Test EveryHour Schedule2', sch, sh1);}catch(Exception e){}

        insert createSchedulerConfig('LAT_BR_SellOutTaskCreator', 'LAT_EveryHour_Scheduler',null, Datetime.now().hour(), Datetime.now().minute(), 20);
		try{System.schedule('Test EveryHour Schedule3', sch, sh1);}catch(Exception e){}

	}
    @isTest static void test_EveryHour2() {

		setup();
		
		insert createSchedulerConfig('LAT_RecordIntegrationVerifications', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);

		Test.startTest();
		
		LAT_EveryHour_Scheduler sh1 = new LAT_EveryHour_Scheduler();
		String sch = '0 0 2 * * ?';
        try{System.schedule('Test EveryHour Schedule', sch, sh1);}catch(Exception e){}
        
		Test.stopTest();
        delete [SELECT id from LAT_SchedulerConfig__c];
		insert createSchedulerConfig('LAT_AR_B2B_PriceCalc_Scheduler', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		try{System.schedule('Test EveryHour Schedule2', sch, sh1);}catch(Exception e){}


	}
	
	@isTest static void test_EveryMinute() {
		setup();
		insert createSchedulerConfig('LAT_UY_StockCheckBatch', 'LAT_EveryMinute_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_AR_StockCheckBatch', 'LAT_EveryMinute_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);
		insert createSchedulerConfig('LAT_RecordIntegrationVerifications', 'LAT_EveryMinute_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);

		Test.startTest();
		
		LAT_EveryMinute_Scheduler sh1 = new LAT_EveryMinute_Scheduler();
		String sch = '0 0 2 * * ?';
		System.schedule('Test EveryMinute Schedule', sch, sh1);
		
		LAT_RecordIntegrationVerifications.verifyAccountsIntegration();

        LAT_RecordIntegrationVerifications.verifyOpportunitiesIntegration();
        LAT_RecordIntegrationVerifications.verifyDocusignUsers();
        LAT_RecordIntegrationVerifications.verifyApprovalsUsers();
		Test.stopTest();
	}
	
	public static LAT_SchedulerConfig__c createSchedulerConfig(String apexClass, String scheduler, Integer day, Integer hour, Integer minute, Integer batchSize) {
		return new LAT_SchedulerConfig__c(
			Name			= apexClass,
			Apex_Class__c 	= apexClass,
			Scheduler__c 	= scheduler,
			Hour__c 		= hour,
			Day__c			= day,
			Batch_Size__c	= batchSize,
			Minute__c		= minute
			);

	}

	public static void setup(){

		LAT_PromotionalAction__c ap = LAT_ClientByRegionHandlerTest.createAP();
        ap.LAT_StartDate__c =   date.today().addDays(30);
        ap.LAT_EndDate__c =   date.today().addDays(40);
        update ap;

        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
   			name = 'OPP_Verification_Email_Recipients',
    		lat_value__c = 'test@zimmic.com,test@zimmic.com');

        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(
   			name = 'LAT_ACCOUNT_VERIFICATION_QUERY',
   			lat_value__c = 'SELECT Id, Name FROM Account LIMIT 1');
 
        LAT_GeneralConfig__c cfg3 = new LAT_GeneralConfig__c(
   			name = 'OPP_Verification_StatusToCheck',
   			lat_value__c = 'Novo Pedido');

        LAT_GeneralConfig__c cfg4 = new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_OBJECTS',
                    LAT_Value__c = '\'Account\',\'LAT_Contract2__c\'');
		
        insert new List<LAT_GeneralConfig__c> {cfg1, cfg2, cfg3, cfg4 };

        LAT_ClientByRegionHandlerTest.generateLATConfig('Promotional_Action_Task_Days', '10');
        LAT_GeneralConfig__c lgc = new LAT_GeneralConfig__c();
        List<LAT_CHATTER_POST_BODY__c> lg2 = [Select Name from LAT_CHATTER_POST_BODY__c where Name = 'LAT_BR_AP_IniciarAcao'];
        if(lg2.size() == 0) {
            LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
            lg.Name = 'LAT_BR_AP_IniciarAcao';
            lg.Body__c = 'Ação Promocional xx_ACTION_NAME_xx iniciará em xx_START_DATE_xx';
            insert lg;

        }
		LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
            	Name = 'COLLETA_CREATE_TASKS',
             	LAT_Value__c = 'false');
		insert cfg;
		LAT_ContractsWS_Test.createCreds();


        List < UDC__c > tabelas = new List < UDC__c > ();

        Id idRecTypeUdc = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard');
       
        UDC__c regional = new UDC__c(
           CodDefUsuario__c = '5',
           Name = 'REG ONTRADE',
           CodProd__c = '01',
           CodUs__c = '01',
           Internal_Id__c = '1-5-01-01',
           RecordTypeId = idRecTypeUdc
       );

       insert regional;

       UDC__c micro = new UDC__c(
           Name = 'ME',
           CodDefUsuario__c = '051',
           Internal_Id__c = '1-051-01-07',
           CodProd__c = '01',
           CodUs__c = '07',
           RecordTypeId = idRecTypeUdc
       );

       insert micro;
	}

	@isTest static void test_Pending_Visits() {

		List<User> users = [SELECT Id, name FROM User WHERE profile.Name = 'LAT_BR2_Vendas' 
                            and isActive = true and (C_digo_JDE__c like '1%' or C_digo_JDE__c like '3%') limit 2];


        System.debug('usrename: ' + users[0].name);
        System.debug('usrename: ' + users[1].name);

        User u = users.get(0);
        User u2 = users.get(1);


        Planejamento__c plan = new  Planejamento__c(); 
        plan.Name = 'Plan Agosto 2019'; 
        plan.M_s_de_Ref_rencia__c = 'Agosto';
        plan.Ano_de_Referencia__c = '2019';
        plan.ownerid = u.id;

        Planejamento__c plan2 = new  Planejamento__c(); 
        plan2.Name = 'Plan Agosto 2019'; 
        plan2.M_s_de_Ref_rencia__c = 'Agosto';
        plan2.Ano_de_Referencia__c = '2019';
        plan2.ownerid = u2.id;
		System.debug('%%%%% paso 1');
        insert new List<Planejamento__c>{plan, plan2};

		System.debug('%%%%% paso 2');
        Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'), 
                CNPJ__c = '58815921000192',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'LD',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                Sub_Channel__c = 'Delicatessen',
                AddressLine1_AR__c= 'test',
                Shipping_Neighbourhood__c = 'test',
                Revenue_Neighbourhood__c = 'test',
                Billing_Neighbourhood__c ='test',
                Shipping_Country__c ='test',
                Revenue_Country__c ='test', 
                Billing_Country__c ='test',
                Status__c = 'Novo Cadastro');

        insert acc;
		Test.startTest();
		System.debug('%%%%% paso 3');

        Visitas__c visita = new Visitas__c(); 
        visita.Conta__c = acc.Id;
        visita.Data_da_Visita__c = System.today();
        visita.planejamento__c = plan.Id;
        visita.Hora_da_Visita__c = '8:00';
        visita.Resumo_da_Visita__c = 'xxxx';
        visita.status__c = 'Planejada';
        insert visita;
		insert createSchedulerConfig('LAT_BR_Check_Pending_Visits_Batch', 'LAT_EveryHour_Scheduler', null, Datetime.now().hour(), Datetime.now().minute(), 20);

		
		
		LAT_EveryHour_Scheduler sh1 = new LAT_EveryHour_Scheduler();
		String sch = '0 0 2 * * ?';
		System.debug('%%%%% paso 4');
        try{System.schedule('Test EveryHour Schedule', sch, sh1);}catch(Exception e){}
        
        list<Visitas__c> lista = [Select Id, Conta__r.ownerid, Planejamento__c, Planejamento__r.ownerid, Planejamento__r.Ano_de_Referencia__c, Planejamento__r.M_s_de_Ref_rencia__c From Visitas__c where status__c != 'Encerrada' and createddate = Last_N_Months:2];
		
		Test.stopTest();

    }


}