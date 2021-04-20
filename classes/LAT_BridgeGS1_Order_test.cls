@isTest
public with sharing class LAT_BridgeGS1_Order_test {
    
    @TestSetup
    static void makeData(){ 
		delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
		LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;
		insert LAT_TestFactory.createCS001_JDECredentials('Argentina', '5');
		insert LAT_TestFactory.createCS001_JDECredentials('Brasil', '1');
		Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
		UDC__c regional = new UDC__c();
		regional.CodDefUsuario__c = '4546';
		regional.CodProd__c= '01';
		regional.CodUs__c= '01';
		regional.Internal_Id__c   = '1234';
		regional.RecordTypeId = idRecTypeUDC;
		insert regional;

		UDC__c bandeira = new UDC__c();
		bandeira.CodDefUsuario__c = '179';
		bandeira.CodProd__c= '01';
		bandeira.CodUs__c= '06';
		bandeira.Internal_Id__c   = '1236';
		bandeira.RecordTypeId = idRecTypeUDC;
		insert bandeira;
		
		UDC__c deposito = new UDC__c();
		deposito.CodDefUsuario__c = '05';
		deposito.CodProd__c     = 'CRM';
		deposito.CodUs__c     = 'DF';
		deposito.Internal_Id__c   = 'CRM-DF876';
		deposito.RecordTypeId = idRecTypeUdc;
		insert deposito;

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
                Client_code_An8__c = '1111',
				Client_country_An8__c = '1-1111',
				CurrencyISOCode = 'BRL',
				Business_Unit__c = deposito.Id
            );
		insert acc;

		//produto = [Select Id, Name, Sku__c From Product2 Where Sku__c = '146' AND Qtlimit 1];

		LAT_Product__c produto = new LAT_Product__c();
		produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
		produto.LAT_IsActive__c = true;
		produto.LAT_CDUnit__c = 'UN';
		produto.LAT_ExternalId__c = '146';
		produto.LAT_QTLeadTime__c = 5;
		produto.LAT_Sku__c = '444';
		produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
		insert produto;

		//Recupera os IDS de tipo de registro.
		String idOpportunity = RecordTypeForTest.getRecType( 'LAT_Opportunity__c' , 'Nova_oportunidade' );

		//Cria nova oportunidade.
		LAT_Opportunity__c opp = new LAT_Opportunity__c();
		opp.Name = 'Opp TESTE COTA';
		opp.LAT_CloseDate__c = System.today()+1;
		opp.RecordTypeId = idOpportunity;
		opp.LAT_Account__c = acc.Id;
		opp.LAT_StageName__c = 'Novo Pedido';
		opp.CurrencyISOCode = 'BRL';
		opp.LAT_NROrderJDE__c = '12345';
		insert opp;
		//Cria um novo produto da oportunidade.
		LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
		oli.LAT_Product__c = produto.Id;
		oli.LAT_Opportunity__c = opp.Id;
		oli.LAT_UnitPrice__c = 12;
		oli.LAT_Quantity__c = 12;
		oli.LAT_AR_Discount__c = 21;
		oli.LAT_AR_MaxDiscount__c = 5;
		insert oli;
    }

    @isTest
    static void test_Execute(){
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		LAT_Opportunity__c opp = [SELECT Id FROM LAT_Opportunity__c LIMIT 1];
		LAT_BridgeGS1_Order.execute(opp.Id);
		Test.stopTest();
    }
	
	@isTest
    static void test_executeEDI_SORDRSP(){
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		LAT_Opportunity__c opp = [SELECT Id FROM LAT_Opportunity__c LIMIT 1];
		LAT_BridgeGS1_Order.executeEDI_SORDRSP(opp.Id, 'FI');//
		Test.stopTest();
    }
	
	@isTest
    static void test_executeEDI_SORIN(){
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		LAT_Opportunity__c opp = [SELECT Id FROM LAT_Opportunity__c LIMIT 1];
		LAT_BridgeGS1_Order.executeEDI_SORIN(opp.Id, true);
		Test.stopTest();
    }

	@isTest
    static void integrateEdiOrder(){
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		LAT_Opportunity__c opp = [SELECT Id FROM LAT_Opportunity__c LIMIT 1];
		LAT_BridgeGS1_Order.integrateEdiOrder(opp.Id);
		Test.stopTest();
	}
	
}