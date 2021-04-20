@isTest
public class LAT_RecordIntegrationVerificationsTest {

 @testSetup
public static void testSetup() {
		delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
    	Profile p = [SELECT Id FROM Profile WHERE Name='LAT_BR2_Vendas'];
    	User u01 = new User(Alias = 'aaa', Email='aaa@aaa.com',
	      EmailEncodingKey='UTF-8', LastName='aaa', FirstName='aaa', LanguageLocaleKey='en_US',
	      LocaleSidKey='en_US', ProfileId = p.Id,
	      TimeZoneSidKey='America/Los_Angeles', UserName='aaa@aaa.com.pernodTest',
	      IsActive = false,ManagerId = UserInfo.getUserId(), Gerente_regional__c = UserInfo.getUserId()
	    );
	    User u02 = new User(Alias = 'aaa', Email='bbb@bbb.com',
	      EmailEncodingKey='UTF-8', LastName='aaa', FirstName='aaa', LanguageLocaleKey='en_US',
	      LocaleSidKey='en_US', ProfileId = p.Id,
	      TimeZoneSidKey='America/Los_Angeles', UserName='bbb@bbb.com.pernodTest',
	      IsActive = true
	    );
	    User u03 = new User(Alias = 'aaa', Email='ccc@ccc.com',
	      EmailEncodingKey='UTF-8', LastName='aaa', FirstName='aaa', LanguageLocaleKey='en_US',
	      LocaleSidKey='en_US', ProfileId = p.Id,
	      TimeZoneSidKey='America/Los_Angeles', UserName='bccc@ccc.com.pernodTest',
	      IsActive = false
	    );        
	    List < LAT_GeneralConfig__c > generalConfigs = new List < LAT_GeneralConfig__c > ();
	    
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'USERS_TO_BYPASSVALIDATIONS_1',
            LAT_Value__c = UserInfo.getUserId()));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'BRASIL_USER_VERIFICATION_PROFILES',
            LAT_Value__c = 'LAT_BR2_Vendas'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'OPP_Verification_Email_Recipients',
            LAT_Value__c = 'aaa@aaa.com'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'LAT_ACCOUNT_VERIFICATION_QUERY',
            LAT_Value__c = 'SELECT ID, Name FROM ACCOUNT LIMIT 1'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'LAT_PRODUCT_COST_CHANNELS',
            LAT_Value__c = '101,102,103,104,112,113,114,115,116'));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'APPROVAL_SLA_OBJECTS',
            LAT_Value__c = '\'LAT_Case__c\',\'Account\',\'LAT_Contract2__c\',\'LAT_Opportunity__c\',\'LAT_Payment__c\''));
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'OPP_Verification_StatusToCheck',
            LAT_Value__c = '\'Pedido enviado para o JDE\', \'Pedido com erro no JDE\', \'Mobile Order\', \'Moblie Order Sent To JDE\''));

		Id StaticResourceId = [Select Id from StaticResource limit 1].id;
        generalConfigs.add(new LAT_GeneralConfig__c(
            Name = 'LAT_ContractMinutaPadrao',
            LAT_Value__c = StaticResourceId));
        insert generalConfigs;
	    insert new List<User>{u01,u02,u03};
         LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
            (ds_Username__c = 'testUsername',
             ds_password__c='test',
             ds_integrationKey__c = 'test'
            );
        dSconfig.LAT_ComercialDirectorId__c = UserInfo.getUserId();
        dSconfig.LAT_FinancialDirectorId__c = UserInfo.getUserId();
        dSconfig.LAT_PresidentId__c = u01.Id;
        dSconfig.LAT_TradeManagerId__c = UserInfo.getUserId();
        dSconfig.LAT_Testemunha_PRB_Id__c = UserInfo.getUserId();
        dSconfig.LAT_ComercialDirectorId_PRESTIGE__c = UserInfo.getUserId();
        dSconfig.LAT_FinancialDirectorId__c = UserInfo.getUserId();
        dSconfig.LAT_PresidentId__c = UserInfo.getUserId();
        dSconfig.LAT_TradeManagerId__c = UserInfo.getUserId();
        dSconfig.LAT_Testemunha_PRB_Id_PRESTIGE__c = UserInfo.getUserId();
        insert dSconfig;
        
        Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
                CNPJ__c = '91370573000162',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'Prospect_ARG',
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
                Status__c = 'Novo cadastro',
                Client_code_an8__c = 'somean8',
                OwnerId = u01.Id
            );
        insert acc;



    }

    @isTest
    static void test1() {
    	User u01 = [SELECT id from User where Email='aaa@aaa.com'];
    	User u02 = [SELECT id from User where Email='bbb@bbb.com'];
    	User u03 = [SELECT id from User where Email='ccc@ccc.com'];
    	//LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		Test.startTest();
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		con.OwnerId = u01.Id;
		con.Manager__c = u03.Id;
		
		insert con;
    	LAT_Payment__c pay1 = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'R',
				Manager__c = u01.Id,
				Ammount__c = 1000.00
			);
    	insert pay1;
		LAT_ContractsWS_Test.getParentRefProdGrouping();
    	
    	LAT_RecordIntegrationVerifications.verifyDocusignUsers();
    	LAT_RecordIntegrationVerifications.verifyApprovalsUsers();
    	LAT_RecordIntegrationVerifications.getAdminEmails();
    	LAT_RecordIntegrationVerifications.verifyBrasilUsers();
    	LAT_RecordIntegrationVerifications.verifyManagerFieldsInPayments();
    	LAT_RecordIntegrationVerifications.verifyManagerFieldsInContracts();
    	LAT_RecordIntegrationVerifications.notifyGroupsProductWithoutChilds();
		try{LAT_RecordIntegrationVerifications.retrieveErrorsColetaNF(new List<LAT_ReferenceProductGrouping__c>());}catch(exception e){}
		try{LAT_RecordIntegrationVerifications.retrieveErrorsContractVolume(new List<LAT_ReferenceProductGrouping__c>());}catch(exception e){}
		try{LAT_RecordIntegrationVerifications.retrieveErrorsPagamentoProducto(new List<LAT_ReferenceProductGrouping__c>());}catch(exception e){}
		LAT_RecordIntegrationVerifications.verifyAccountsIntegration();
    	Test.stopTest();




    }

    @isTest
    static void test2() {
    	User u01 = [SELECT id from User where Email='aaa@aaa.com'];
    	User u02 = [SELECT id from User where Email='bbb@bbb.com'];
    	User u03 = [SELECT id from User where Email='ccc@ccc.com'];
    	//LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		Test.startTest();
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		con.OwnerId = u02.Id;
		
		insert con;
    	LAT_Payment__c pay1 = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'R',
				Manager__c = u02.Id,
				Ammount__c = 1000.00
			);
    	insert pay1;
    	LAT_RecordIntegrationVerifications.verifyOpportunitiesIntegration();
    	LAT_RecordIntegrationVerifications.verifyManagerFieldsInPayments();
    	LAT_RecordIntegrationVerifications.verifyManagerFieldsInContracts();
    	Test.stopTest();




    }


}