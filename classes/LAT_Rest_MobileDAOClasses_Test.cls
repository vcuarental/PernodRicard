@isTest
public with sharing class LAT_Rest_MobileDAOClasses_Test { 

  	@testSetup static void setup(){
		delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];

		insert new LAT_GeneralConfig__c(
				Name = 'OPP_Verification_Email_Recipients',
				LAT_Value__c = 'aaa@aaa.com');//test y ALGO A AGREGAR
		insert new CS001_JDEInterfaceCredentials__c(Name='México', UserName__c = 'admin.Username', Country__c = '12', EndPoint_CustomerHandler__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerHandlerReq?WSDL',
				EndPoint_CustomerVerify__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerVerifyReq?WSDL', EndPoint_PriceCalculation__c = 'http://osbdev.pramericas.com/SFDC/Price/PriceCalculationReq?WSDL', 
				EndPoint_SalesOrderHandler__c = 'http://osbdev.pramericas.com/SFDC/SalesOrder/AsyncSalesOrderHandlerReq?WSDL', RemoteHostIP__c = '200.200.10.10', SystemUserID__c = 'cloud2b', EndPoint_BalanceCheck__c = 'X',
				EndPoint_ContractManager__c = 'X', EndPoint_PaymentManager__c = 'X', EndPoint_RVManager__c = 'X', PriceCalcCompanyParam__c = 'X',EndPoint_GetStock__c='https://osbdev.pramericas.com/JDE9/Inventory/GetStock?wsdl'); 
	
  	}	 
	
	@isTest
    static void test_LAT_Rest_SalesOrderReturn() {
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
		RestContext.response= res;
		LAT_Rest_SalesOrderReturn.SOR_Body body = new LAT_Rest_SalesOrderReturn.SOR_Body();
		body.orderNumber = 12345;
		body.orderType = 'SO';
		body.companyCode = '00902';
		body.country = 12345;
		body.cd_salesman = 'SO';
		body.orderNumberForeign = '00902';
		body.customerCode = body.customerShippingCode = 12345;
		body.customerBuyOrder = 'SO';
		body.businessUnit = body.note1 = body.note2 = '00902';
		body.freightType = 'F';
		body.cd_order_status = body.returnCode  = 540;
		body.orderOnHold =body.paymentTerm = body.returnMessage = '00902';
		req.requestBody = Blob.valueOf(JSON.serialize(body));
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		
		//LAT_Rest_SalesOrderReturn.POST();
		new LAT_Rest_SalesOrderReturn.ServiceResponse('Test', true);
		new LAT_Rest_SalesOrderReturn.ServiceResponse('Test', 'test', false);
		Test.stopTest();
		
	}
	
    @isTest
    static void test_LAT_Rest_GetContractInformation() {
        try{
          User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
          LAT_ContractsWS_Test.setup(u);
          LAT_Contract2__c c = LAT_ContractsWS_Test.getContract();
          Test.startTest();
          insert c;

          LAT_ContractVolume__c cv = LAT_ContractsWS_Test.getContractVolume(c.id);
          insert cv;
          LAT_ReferenceProductGrouping__c parentPG = new LAT_ReferenceProductGrouping__c (
                    RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
                    Name = 'Test Parent Prod Grouping',
                    Order__c = 100,
                    GroupType__c ='SKU'
                );
            insert parentPG;
            LAT_ReferenceProductGrouping__c paymentPG = new LAT_ReferenceProductGrouping__c (
                        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
                        Name = 'Test Product Payment Prod Grouping',
                        Order__c = 100,
                        GroupType__c ='SKU',
                        Parent__c = parentPG.Id
                    );
            insert paymentPG;

          LAT_ContractsWS_Test.inserCollectsNFLines(c.Account__c, paymentPG.Id);
          LAT_ContractsWS_Test.inserCollectsNFLinesNoParent(c.Account__c);
          // LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
          // insert paymentp;
          LAT_Payment__c paymentd = LAT_ContractsWS_Test.getPaymentDinheroWithParent(c.id);
          insert paymentd;
          LAT_ContractsWS.Contract con = new LAT_ContractsWS.Contract();
          con.ContractTerms = 6;
          con.uf = 'SP';
          con.roiSegment = 'STANDARD';
          con.RecordType = 'On Trade – contrato de patrocínio';
          LAT_ContractsWS.ContractVolume conVol = new LAT_ContractsWS.ContractVolume();
          conVol.boxesMinimum = 120;
          conVol.product = parentPG.Id;
          List<LAT_ContractsWS.ContractVolume> listConVol = new List<LAT_ContractsWS.ContractVolume>{conVol};
          con.contractVolume = listConVol;
          LAT_ContractsWS.Payments conPay = new LAT_ContractsWS.Payments();
          conPay.ProductGroup = paymentPG.Id;
          conPay.RecordType = 'Pagamento Produto';
          conPay.Volumen = 5;
          con.payments = new List<LAT_ContractsWS.Payments>{conPay};

          LAT_Rest_GetContractInformation.getContractInformation(con);
          Test.stopTest();
        } catch(Exception e){}
		
    }
 
  	@isTest 
  	static void test_LAT_Rest_GetAvailableCredit() {
    	LAT_Rest_GetAvailableCredit.getAvailbleCredit('123');
  	}
   	@isTest 
   	static void test_LAT_Rest_SalesAcademy_Get(){
     	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;
     	Account a = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    	insert a;
		Test.startTest();

		LAT_SalesAcademy__c sales = new LAT_SalesAcademy__c();
		sales.account__c = a.Id;
		insert sales;

		LAT_ClientAnalysis__c clientAnalysis = new LAT_ClientAnalysis__c();
		clientAnalysis.SalesAcademy__c = sales.Id;
		insert clientAnalysis;

		
		LAT_SWOTAnalysis__c swotAnalysis = new LAT_SWOTAnalysis__c();
		swotAnalysis.SalesAcademy__c = sales.Id;
		insert swotAnalysis;

		
		LAT_ActionPlan__c actionPlan = new LAT_ActionPlan__c();
		actionPlan.SalesAcademy__c = sales.Id;
		insert actionPlan;

		
		LAT_ObjectivesDefinition__c objetivesDefinition = new LAT_ObjectivesDefinition__c();
		objetivesDefinition.SalesAcademy__c = sales.Id;
		insert objetivesDefinition;

		
		LAT_StrategicObjectives__c strategicObjetives = new LAT_StrategicObjectives__c();
		strategicObjetives.objetive__c = objetivesDefinition.Id;
		insert strategicObjetives;
		LAT_Rest_SalesAcademy.doGet();
   	}

   	@isTest   
   	static void test_LAT_Rest_SalesAcademy_POST(){
		RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account a = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
    	insert a;
		Test.startTest();

		LAT_SalesAcademy__c sales = new LAT_SalesAcademy__c();
		sales.account__c = a.Id;
		insert sales;
			Test.stopTest();
			req.requestURI = '/services/apexrest/LAT_RestCheckStockAvailability/*';  //Request URL
			req.httpMethod = 'POST';//HTTP Request Type
			String strbody = getSalesAcademiStringBody().replace('IDSALESACADEMY', sales.Id);
			req.requestBody = Blob.valueof(strbody);
			
			RestContext.request = req;
			RestContext.response= res;
		//try{LAT_Rest_SalesAcademy.Post();}catch(Exception e){}
		//try{LAT_Rest_SalesAcademy.Put();}catch(Exception e){}
		LAT_Rest_SalesAcademy.Post();
		LAT_Rest_SalesAcademy.Put();
		LAT_SalesAcademyHandler academia = (LAT_SalesAcademyHandler)System.JSON.deserialize(req.requestBody.toString(), LAT_SalesAcademyHandler.class);
		try{LAT_Rest_SalesAcademy.upsertActionPlan(academia);}catch(Exception e){}
		try{LAT_Rest_SalesAcademy.upsertObjectivesDefinition(academia);}catch(Exception e){}
		try{LAT_Rest_SalesAcademy.upsertSWOTAnalysis(academia);}catch(Exception e){}
		try{LAT_Rest_SalesAcademy.upsertClientAnalysis(academia);}catch(Exception e){}
   	}
   
	@isTest 
	static void test_LAT_SalesAcademyHandler(){
     	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        Account a = LAT_Account_TestFactory.getAccountOffTradeBraComplete();
		insert a;
		Test.startTest();

		LAT_SalesAcademy__c sales = new LAT_SalesAcademy__c();
		sales.account__c = a.Id;
		insert sales;
			Test.stopTest();
			req.requestURI = '/services/apexrest/LAT_RestCheckStockAvailability/*';  //Request URL
			req.httpMethod = 'POST';//HTTP Request Type
			String strbody = getSalesAcademiStringBody().replace('IDSALESACADEMY', sales.Id);
			req.requestBody = Blob.valueof(strbody);
			
			RestContext.request = req;
			RestContext.response= res;
		//try{LAT_Rest_SalesAcademy.Post();}catch(Exception e){}
		//try{LAT_Rest_SalesAcademy.Put();}catch(Exception e){}
		LAT_Rest_SalesAcademy.Post();
		LAT_Rest_SalesAcademy.Put();
		LAT_SalesAcademyHandler academia = (LAT_SalesAcademyHandler)System.JSON.deserialize(req.requestBody.toString(), LAT_SalesAcademyHandler.class);

		LAT_SalesAcademyHandler.parse(strbody);
   	}

  	@isTest
   	static void test_LAT_Rest_ContractGetClientPDF(){
        try{
			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();          
			RestContext.request = req;
			RestContext.response= res;

			User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
			LAT_ContractsWS_Test.setup(u);
			LAT_Contract2__c c = LAT_ContractsWS_Test.getContract();
			Test.startTest();
			insert c;
		
			LAT_Rest_ContractGetClientPDF.POST('NO_ID');

			LAT_Rest_ContractGetClientPDF.POST(c.Id);

			Test.stopTest();
    	}catch(Exception e){}
	  }
	  
	  @isTest
	  static void test_LAT_Rest_ContractGetClientPDF2(){
	   try{
		   RestRequest req = new RestRequest();
		   RestResponse res = new RestResponse();          
		   RestContext.request = req;
		   RestContext.response= res;

		   User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
		   LAT_ContractsWS_Test.setup(u);
		   LAT_Contract2__c c = LAT_ContractsWS_Test.getContract('LAT_Eventos_Contrato_de_Parceria_Distribuidor');
		   Test.startTest();
		   insert c;
	   
		   LAT_Rest_ContractGetClientPDF.POST('NO_ID');

		   LAT_Rest_ContractGetClientPDF.POST(c.Id);

		   Test.stopTest();
	   }catch(Exception e){}
	 }


	 @isTest
	 static void test_LAT_Rest_ContractGetClientPDF3(){
	  try{
		  RestRequest req = new RestRequest();
		  RestResponse res = new RestResponse();          
		  RestContext.request = req;
		  RestContext.response= res;

		  User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
		  LAT_ContractsWS_Test.setup(u);
		  LAT_Contract2__c c = LAT_ContractsWS_Test.getContract(LAT_ContractsCalculations.EVENT_PRODUCER);
		  Test.startTest();
		  insert c;
	  
		  LAT_Rest_ContractGetClientPDF.POST('NO_ID');

		  LAT_Rest_ContractGetClientPDF.POST(c.Id);

		  Test.stopTest();
	  }catch(Exception e){}
	}

	@isTest
	static void test_LAT_Rest_ContractGetClientPDF8451(){
	 try{
		 RestRequest req = new RestRequest();
		 RestResponse res = new RestResponse();          
		 RestContext.request = req;
		 RestContext.response= res;

		 User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
		 LAT_ContractsWS_Test.setup(u);
		 LAT_Contract2__c c = LAT_ContractsWS_Test.getContract('LAT_CartaAtivacao');
		 Test.startTest();
		 insert c;
	 
		 LAT_Rest_ContractGetClientPDF.POST('NO_ID');

		 LAT_Rest_ContractGetClientPDF.POST(c.Id);

		 Test.stopTest();
	 }catch(Exception e){}
   }

	@isTest
	static void test_LAT_Rest_ContractWS(){
			try{
			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();          
			RestContext.request = req;
			RestContext.response= res;

			User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
			LAT_ContractsWS_Test.setup(u);
			LAT_Contract2__c c = LAT_ContractsWS_Test.getContract();
			Test.startTest();
			insert c;

			LAT_ContractVolume__c cv = LAT_ContractsWS_Test.getContractVolume(c.id);
			insert cv;
			LAT_ReferenceProductGrouping__c parentPG = new LAT_ReferenceProductGrouping__c (
						RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
						Name = 'Test Parent Prod Grouping',
						Order__c = 100,
						GroupType__c ='SKU'
					);
				insert parentPG;
				LAT_ReferenceProductGrouping__c paymentPG = new LAT_ReferenceProductGrouping__c (
							RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
							Name = 'Test Product Payment Prod Grouping',
							Order__c = 100,
							GroupType__c ='SKU',
							Parent__c = parentPG.Id
						);
				insert paymentPG;

			LAT_ContractsWS_Test.inserCollectsNFLines(c.Account__c, paymentPG.Id);
			LAT_ContractsWS_Test.inserCollectsNFLinesNoParent(c.Account__c);
			// LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
			// insert paymentp;
			LAT_Payment__c paymentd = LAT_ContractsWS_Test.getPaymentDinheroWithParent(c.id);
			insert paymentd;
			LAT_ContractsWS.Contract con = new LAT_ContractsWS.Contract();
			con.ContractTerms = 6;
			con.uf = 'SP';
			con.roiSegment = 'STANDARD';
			con.RecordType = 'On Trade – contrato de patrocínio';
			LAT_ContractsWS.ContractVolume conVol = new LAT_ContractsWS.ContractVolume();
			conVol.boxesMinimum = 120;
			conVol.product = parentPG.Id;
			List<LAT_ContractsWS.ContractVolume> listConVol = new List<LAT_ContractsWS.ContractVolume>{conVol};
			con.contractVolume = listConVol;
			LAT_ContractsWS.Payments conPay = new LAT_ContractsWS.Payments();
			conPay.ProductGroup = paymentPG.Id;
			conPay.RecordType = 'Pagamento Produto';
			conPay.Volumen = 5;
			con.payments = new List<LAT_ContractsWS.Payments>{conPay};

			LAT_Rest_ContractWS.ContractGeneratePayment(c.Id);
			Test.stopTest();
			} catch(Exception e){}
	}

	@isTest
	static void test_LAT_Rest_CheckPaymentRelease(){
		try{
			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();          
			RestContext.request = req;
			RestContext.response= res;
			
			User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
			LAT_ContractsWS_Test.setup(u);
			LAT_Contract2__c c = LAT_ContractsWS_Test.getContract();
			Test.startTest();
			insert c;

			LAT_ContractVolume__c cv = LAT_ContractsWS_Test.getContractVolume(c.id);
			insert cv;
			LAT_ReferenceProductGrouping__c parentPG = new LAT_ReferenceProductGrouping__c (
					RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
					Name = 'Test Parent Prod Grouping',
					Order__c = 100,
					GroupType__c ='SKU'
			);
			insert parentPG;
			LAT_ReferenceProductGrouping__c paymentPG = new LAT_ReferenceProductGrouping__c (
						RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
						Name = 'Test Product Payment Prod Grouping',
						Order__c = 100,
						GroupType__c ='SKU',
						Parent__c = parentPG.Id
			);
			insert paymentPG;

			LAT_ContractsWS_Test.inserCollectsNFLines(c.Account__c, paymentPG.Id);
			LAT_ContractsWS_Test.inserCollectsNFLinesNoParent(c.Account__c);
			// LAT_Payment__c paymentp = getPaymentProductoWithParent(c.id);
			// insert paymentp;
			LAT_Payment__c paymentd = LAT_ContractsWS_Test.getPaymentDinheroWithParent(c.id);
			insert paymentd;
			LAT_ContractsWS.Contract con = new LAT_ContractsWS.Contract();
			con.ContractTerms = 6;
			con.uf = 'SP';
			con.roiSegment = 'STANDARD';
			con.RecordType = 'On Trade – contrato de patrocínio';
			LAT_ContractsWS.ContractVolume conVol = new LAT_ContractsWS.ContractVolume();
			conVol.boxesMinimum = 120;
			conVol.product = parentPG.Id;
			List<LAT_ContractsWS.ContractVolume> listConVol = new List<LAT_ContractsWS.ContractVolume>{conVol};
			con.contractVolume = listConVol;
			LAT_ContractsWS.Payments conPay = new LAT_ContractsWS.Payments();
			conPay.ProductGroup = paymentPG.Id;
			conPay.RecordType = 'Pagamento Produto';
			conPay.Volumen = 5;
			con.payments = new List<LAT_ContractsWS.Payments>{conPay};

			LAT_Rest_CheckPaymentRelease.CheckPaymentRelease(paymentd.Id);
			LAT_Rest_ContractPayments.checkPaymentRelease(paymentd.Id);
			LAT_Rest_ContractPayments.groupPayments(new List<String> {paymentd.Id});
			
			Test.stopTest();
		} catch(Exception e){}
	}

	@isTest
	static void test_LAT_Rest_Contracts_POST(){
		try{
			
			User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
			LAT_ContractsWS_Test.setup(u);
			Account acc = [SELECT Id FROM Account LIMIT 1];
			Test.startTest();

			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();          
			RestContext.request = req;
			RestContext.response= res;
			LAT_ReferenceProductGrouping__c parentPG = new LAT_ReferenceProductGrouping__c (
						RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
						Name = 'Test Parent Prod Grouping',
						Order__c = 100,
						GroupType__c ='SKU'
				);
			insert parentPG;
			LAT_ReferenceProductGrouping__c paymentPG = new LAT_ReferenceProductGrouping__c (
						RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
						Name = 'Test Product Payment Prod Grouping',
						Order__c = 100,
						GroupType__c ='SKU',
						Parent__c = parentPG.Id
					);
			insert paymentPG;

			String strbody = getContractStringBody().replace('IDACCOUNT', acc.Id);
			strbody = strbody.replace('IDPRODUCTPAYMENT', parentPG.Id);
			strbody = strbody.replace('IDPRODUCTPAYMENTCHILD', paymentPG.Id);
			System.debug('strbody : ' + strbody);
				req.requestBody = Blob.valueof(strbody);

			LAT_Rest_Contracts.POST();
			Test.stopTest();
		} catch(Exception e){}
	}

	@isTest
	static void test_LAT_Rest_Contracts_PUT(){
		try{
			
			User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
			LAT_ContractsWS_Test.setup(u);
			Account acc = [SELECT Id FROM Account LIMIT 1];
			Test.startTest();

			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();          
			RestContext.request = req;
			RestContext.response= res;
			LAT_ReferenceProductGrouping__c parentPG = new LAT_ReferenceProductGrouping__c (
					RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
					Name = 'Test Parent Prod Grouping',
					Order__c = 100,
					GroupType__c ='SKU'
			);
			insert parentPG;
			LAT_ReferenceProductGrouping__c paymentPG = new LAT_ReferenceProductGrouping__c (
						RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
						Name = 'Test Product Payment Prod Grouping',
						Order__c = 100,
						GroupType__c ='SKU',
						Parent__c = parentPG.Id
			);
			insert paymentPG;

			String strbody = getContractStringBody().replace('IDACCOUNT', acc.Id);
			strbody = strbody.replace('IDPRODUCTPAYMENT', parentPG.Id);
			strbody = strbody.replace('IDPRODUCTPAYMENTCHILD', paymentPG.Id);
			System.debug('strbody : ' + strbody);
			req.requestBody = Blob.valueof(strbody);

			LAT_Rest_Contracts.PUT();
			Test.stopTest();
		} catch(Exception e){}
	}

	/*
	@isTest
	static void test_LAT_ContractHandlerJSON(){

		String json = getContractStringBody();
		LAT_ContractHandlerJSON r = LAT_ContractHandlerJSON.parse(json);
		

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ListClientContract objListClientContract = new LAT_ContractHandlerJSON.ListClientContract(System.JSON.createParser(json));
		

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON objJSON2Apex = new LAT_ContractHandlerJSON(System.JSON.createParser(json));
		
		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.PromotionAgreement objPromotionAgreement = new LAT_ContractHandlerJSON.PromotionAgreement(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ContractDetail objContractDetail = new LAT_ContractHandlerJSON.ContractDetail(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.VisibilityCounterPart objVisibilityCounterPart = new LAT_ContractHandlerJSON.VisibilityCounterPart(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.Provider objProvider = new LAT_ContractHandlerJSON.Provider(System.JSON.createParser(json));
		
		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ListVolume objListVolume = new LAT_ContractHandlerJSON.ListVolume(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ListProviders objListProviders = new LAT_ContractHandlerJSON.ListProviders(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.Payment objPayment = new LAT_ContractHandlerJSON.Payment(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ListVisibilityCounterPart objListVisibilityCounterPart = new LAT_ContractHandlerJSON.ListVisibilityCounterPart(System.JSON.createParser(json));
		
		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.Volume objVolume = new LAT_ContractHandlerJSON.Volume(System.JSON.createParser(json));
		
		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ListPayment objListPayment = new LAT_ContractHandlerJSON.ListPayment(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ClientContract objClientContract = new LAT_ContractHandlerJSON.ClientContract(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ListContractDetail objListContractDetail = new LAT_ContractHandlerJSON.ListContractDetail(System.JSON.createParser(json));

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		LAT_ContractHandlerJSON.ListPromotionAgreement objListPromotionAgreement = new LAT_ContractHandlerJSON.ListPromotionAgreement(System.JSON.createParser(json));	}
 
		*/
	@isTest
   	static void test_LAT_Rest_EventPaymentsWS_POST(){
		User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
		LAT_ContractsWS_Test.setup(u);
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		
		LAT_Product__c p = lat_cota_test.LAT_getProduct(); 
		p.LAT_IsRefactorProduct__c = 'Y';
		p.LAT_IsActive__c = true;
		p.LAT_BottlesPerBox__c = 12;
		p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
		insert p;

		Test.startTest();
		insert con;
		LAT_Payment__c pay1 =LAT_ContractsWS_Test.getPaymentProducto(con.Id );
		pay1.Finality__c = 'Condição Comercial';
		
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();          
		RestContext.request = req;
		RestContext.response= res;

		String strbody = getRestComCondEventCalculationsPaymentBodyPost().replace('IDACCOUNT', con.Account__c);
		strbody = strbody.replace('IDCONTRACT', con.Id);
		strbody = strbody.replace('IDPRODUCTPAYMENT', pay1.ProductGroup__c);
		System.debug('strbody : ' + strbody);
		req.requestBody = Blob.valueof(strbody);
		LAT_Rest_EventPaymentsWS.doPOST();
		LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
		rp.LAT_Product__c =p.id;
		rp.Type__c='sku';
		rp.isActive__c = true;
		rp.ReferenceGrouping__c = pay1.ProductGroup__c;
		rp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_ReferenceProduct__c', 'LAT_ProductPayment' );
		insert rp;

		rp = [SELECT Id, LAT_Product__r.LAT_BottlesPerBox__c FROM LAT_ReferenceProduct__c LIMIT 1];
		Map<Id, LAT_ReferenceProduct__c> refProdMap = new Map<Id, LAT_ReferenceProduct__c>();
		refProdMap.put(pay1.ProductGroup__c, rp);

		system.debug('%%% pay1.ProductGroup__c:' + pay1.ProductGroup__c);
		try{LAT_Rest_EventPaymentsWS.createCommercialConditionProductPayment(pay1, refProdMap);}catch(Exception e){}
		Test.stopTest();
        
   	}
	
	
	@isTest
   	static void test_LAT_Rest_EventPaymentsWS_PUT(){
     	
		User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
		LAT_ContractsWS_Test.setup(u);
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		
		LAT_Product__c p = lat_cota_test.LAT_getProduct(); 
		p.LAT_IsRefactorProduct__c = 'Y';
		p.LAT_IsActive__c = true;
		p.LAT_BottlesPerBox__c = 12;
		p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
		insert p;

		Test.startTest();
		insert con;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();          
		RestContext.request = req;
		RestContext.response= res;
		LAT_Payment__c pay1 =LAT_ContractsWS_Test.getPaymentProducto(con.Id );
		pay1.Finality__c = 'Condição Comercial';
		LAT_Payment__c pay2 =LAT_ContractsWS_Test.getPaymentProducto(con.Id );
		pay2.Finality__c = 'Condição Comercial';
		insert new List<LAT_Payment__c>{pay1, pay2};

		LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
		rp.LAT_Product__c =p.id;
		rp.Type__c='sku';
		rp.isActive__c = true;
		rp.ReferenceGrouping__c = pay1.ProductGroup__c;
		rp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_ReferenceProduct__c', 'LAT_ProductPayment' );

		system.debug('%%% pay1.ProductGroup__c:' + pay1.ProductGroup__c);
		insert rp;

		String strbody = getRestEventPaymentBody().replace('IDACCOUNT', con.Account__c);
		strbody = strbody.replace('IDPRODUCTPAYMENT', pay1.ProductGroup__c);
		strbody = strbody.replace('IDCONTRACT', con.Id);
		strbody = strbody.replace('IDPAYMENT1', pay1.Id);
		strbody = strbody.replace('IDPAYMENT2', pay2.Id);
		System.debug('strbody : ' + strbody);
		req.requestBody = Blob.valueof(strbody);
		
			LAT_Rest_EventPaymentsWS.doPUT();
		
		try{LAT_Rest_EventPaymentsWS.createCommercialConditionCashPayment(LAT_ContractsWS_Test.getPaymentDinhero(con.Id));}catch(Exception e){}
		Test.stopTest();
        
   	}

	@isTest
   	static void test_LAT_Rest_ComCondEventCalculations(){
     	  
		User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
		LAT_ContractsWS_Test.setup(u);
		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		
		LAT_Product__c p = lat_cota_test.LAT_getProduct(); 
		p.LAT_IsRefactorProduct__c = 'Y';
		p.LAT_IsActive__c = true;
		p.LAT_BottlesPerBox__c = 12;
		p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
		insert p;

		Test.startTest();
		insert con;

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();          
		RestContext.request = req;
		RestContext.response= res;
		LAT_Payment__c pay1 =LAT_ContractsWS_Test.getPaymentProducto(con.Id );
		pay1.Finality__c = 'Condição Comercial';
		LAT_Payment__c pay2 =LAT_ContractsWS_Test.getPaymentProducto(con.Id );
		pay2.Finality__c = 'Condição Comercial';
		insert new List<LAT_Payment__c>{pay1, pay2};

		LAT_ReferenceProduct__c rp = new LAT_ReferenceProduct__c();
		rp.LAT_Product__c =p.id;
		rp.Type__c='sku';
		rp.isActive__c = true;
		rp.ReferenceGrouping__c = pay1.ProductGroup__c;
		rp.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_ReferenceProduct__c', 'LAT_ProductPayment' );

		system.debug('%%% pay1.ProductGroup__c:' + pay1.ProductGroup__c);
		insert rp;

		String strbody = getRestComCondEventCalculationsPaymentBody().replace('IDACCOUNT', con.Account__c);
		strbody = strbody.replace('IDPRODUCTPAYMENT', pay1.ProductGroup__c);
		strbody = strbody.replace('IDCONTRACT', con.Id);
		strbody = strbody.replace('IDPAYMENT1', pay1.Id);
		strbody = strbody.replace('IDPAYMENT2', pay2.Id);
		System.debug('strbody : ' + strbody);
		req.requestBody = Blob.valueof(strbody);

		System.runAs(u){
			LAT_Rest_ComCondEventCalculations.PUT();
		}
		
		Test.stopTest();
        
   	}
/*
   @isTest
   static void test_LAT_Rest_Planejamento(){

     String strbody = '{"planDate" : "2018-11-10"}';
     User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
     RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();          
        RestContext.request = req;
        RestContext.response= res;
        req.requestBody = Blob.valueof(strbody);
        System.runAs(u){
          LAT_Rest_Planejamento.POST(Date.today());
        }
   }
*/
   	@isTest 
   	static void test_LAT_Rest_Opportunities(){

    	createCreds();
		User vendas = [SELECT Id FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true LIMIT 1];
		Account acc;
		System.runAs(vendas){
			acc = new Account(
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
				CurrencyISOCode = 'BRL'
			);
            
            //insert acc;
            insert acc;//}catch(Exception e){
    	}
    
    	LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;

        Test.startTest();
        
    
        LAT_OpportunityHandlerJSON pedidoJSON = LAT_Rest_OpportunityFlex_Test.createPedidoJSON(acc, prod1, paymentCondition);
        
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
		RestContext.request = req;
		RestContext.response = res;
		System.runAs(vendas){
			try{LAT_Rest_Opportunities.POST();}catch (Exception e){}
			LAT_Opportunity__c opp = [SELECT Id FROM LAT_Opportunity__c LIMIT 1];
			pedidoJSON.header.Id = opp.Id;
			req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
			try{LAT_Rest_Opportunities.PUT();}catch (Exception e){}
		}
    
		Test.stopTest();

   	}
   	@isTest 
   	static void test_LAT_Rest_CalculateLeadTime(){

    	createCreds();
		UDC__c deposito = new UDC__c();
		deposito.CodDefUsuario__c = '05';
		deposito.CodProd__c     = 'CRM';
		deposito.CodUs__c     = 'DF';
		deposito.Internal_Id__c   = 'CRM-DF876';
		deposito.RecordTypeId = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
		insert deposito;
		User vendas = [SELECT Id FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true LIMIT 1];
		Account acc;
		System.runAs(vendas){
			acc = new Account(
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
				Business_Unit__c = deposito.Id,
				Revenue_UF__c = 'SP'
			);
            
            //insert acc;
            insert acc;//}catch(Exception e){
    	}
    
    	LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'),LAT_UnitWeight__c = 100);
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;
		LAT_LeadTime__c lt = new LAT_LeadTime__c(LAT_Complete__c = 10, LAT_Partial__c = 12, LAT_BusinessUnit__c = deposito.Id, LAT_UF__c = 'SP');
		insert lt;

		LAT_Holiday__c feriado = new LAT_Holiday__c(LAT_Date__c = Date.today().AddDays(10), Name = 'Test');
		insert feriado;

        Test.startTest();
        
    
        LAT_OpportunityHandlerJSON pedidoJSON = LAT_Rest_OpportunityFlex_Test.createPedidoJSON(acc, prod1, paymentCondition);
        
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
		RestContext.request = req;
		RestContext.response = res;
		System.runAs(vendas){
			try{LAT_Rest_CalculateLeadTime.processPost();}catch (Exception e){}
			try{LAT_Rest_CalculateLeadTime.isWorkingDay(Date.Today());}catch (Exception e){}
			try{LAT_Rest_CalculateLeadTime.getCalculatedDate(Date.Today(), 9);}catch (Exception e){}
			
			
		}
    
		Test.stopTest();

   	}

	@isTest 
	static void test_LAT_Rest_Opportunities_Cancel(){

    	createCreds();
		User vendas = [SELECT Id FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true LIMIT 1];
		Account acc;
		System.runAs(vendas){
      		acc = new Account(
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
        		CurrencyISOCode = 'BRL'
            );
            
            //insert acc;
            insert acc;//}catch(Exception e){
    	}
    
		LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
		insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;

        Test.startTest();
        
    
        LAT_OpportunityHandlerJSON pedidoJSON = LAT_Rest_OpportunityFlex_Test.createPedidoJSON(acc, prod1, paymentCondition);
        
		RestRequest req = new RestRequest(); 
		RestResponse res = new RestResponse();

		req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
		RestContext.request = req;
		RestContext.response = res;
		System.runAs(vendas){
			try{LAT_Rest_Opportunities.POST();}catch (Exception e){}
			LAT_Opportunity__c opp = [SELECT Id FROM LAT_Opportunity__c LIMIT 1];
			pedidoJSON.header.Id = opp.Id;
			req.requestBody   = Blob.valueOf(JSON.serialize(pedidoJSON));
			LAT_OpportunityLineItem__c oli = [SELECT Id FROM LAT_OpportunityLineItem__c LIMIT 1];
			pedidoJSON.detail[0].Id = oli.Id;
			LAT_Rest_Opportunities.cancelOpportunity(pedidoJSON);

		}
    
    	Test.stopTest();

   	}

  	@isTest
	static void test_LAT_Rest_ContractGetInformation(){
		try{
			
			User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
			LAT_ContractsWS_Test.setup(u);
			Account acc = [SELECT Id FROM Account LIMIT 1];
			Test.startTest();

			RestRequest req = new RestRequest();
			RestResponse res = new RestResponse();          
			RestContext.request = req;
			RestContext.response= res;
			LAT_ReferenceProductGrouping__c parentPG = new LAT_ReferenceProductGrouping__c (
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
				Name = 'Test Parent Prod Grouping',
				Order__c = 100,
				GroupType__c ='SKU'
			);
			insert parentPG;
			LAT_ReferenceProductGrouping__c paymentPG = new LAT_ReferenceProductGrouping__c (
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ProductPayment')   ,
				Name = 'Test Product Payment Prod Grouping',
				Order__c = 100,
				GroupType__c ='SKU',
				Parent__c = parentPG.Id
			);
			insert paymentPG;

			String strbody = getContractGetInformationBody();
			strbody = strbody.replace('IDPRODUCTPAYMENTCHILD', paymentPG.Id);
			strbody = strbody.replace('IDPRODUCTPAYMENT', parentPG.Id);
			System.debug('strbody : ' + strbody);
			req.requestBody = Blob.valueof(strbody);

			LAT_Rest_ContractGetInformation.ContractGetInformation();
			Test.stopTest();
		} catch(Exception e){}
	}
   
	/*
   	@isTest 
   	static void test_LAT_Rest_SelloutCollect(){

		User u = LAT_ContractsWS_Test.getLAT_BR2Vendas();
		System.runAs(u){
          	LAT_ContractsWS_Test.setup(u);
        }
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();

    	RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();          
        RestContext.request = req;
        RestContext.response= res;
        LAT_ReferenceProductGrouping__c parentPG = new LAT_ReferenceProductGrouping__c (
			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_ContractVolume')   ,
			Name = 'Test Parent Prod Grouping',
			Order__c = 100,
			GroupType__c ='SKU'
		);
        insert parentPG;
        LAT_ReferenceProductGrouping__c paymentPG = new LAT_ReferenceProductGrouping__c (
			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProductGrouping__c'+'LAT_SellOut')   ,
			Name = 'Test Product Payment Prod Grouping',
			Order__c = 100,
			GroupType__c ='SKU',
			Parent__c = parentPG.Id
		);
        insert paymentPG;

		String strbody = getSelloutCollectStringBody().replace('IDACCOUNT', acc.Id);
		strbody = strbody.replace('IDPRODUCTPAYMENTCHILD', paymentPG.Id);
		System.debug('strbody : ' + strbody);
		req.requestBody = Blob.valueof(strbody);
		System.runAs(u){
			LAT_Rest_SelloutCollect.PUT();
			LAT_Rest_SelloutCollect.POST();
		}
        
        Test.stopTest();

   	}
  

  	@isTest
  	static void test_LAT_Rest_ChecklistMX(){
                
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            RecordTypeId = rtOffMX
        );
        insert acc;
        
        String rtpla = Global_RecordTypeCache.getRtId('Planejamento__c' + 'LAT_MX_PLV_NewPlanning');
        
        Planejamento__c pla = new Planejamento__c(
            RecordTypeId = rtpla,
            Name = 'test',
            Ano_de_Referencia__c = string.ValueOf(date.today().year()), 
            M_s_de_Ref_rencia__c = 'Dezembro'
        );
        insert pla;
        Test.startTest();
        String rtvis = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit');
        
        Visitas__c visit = new Visitas__c(
            Conta__c = acc.Id,
            Name = 'test',
            Data_da_Visita__c = date.newInstance(date.today().year(),12,31),
            Hora_da_Visita__c = '08:00',
            Planejamento__c = pla.Id,
            Resumo_da_Visita__c = 'test',
            LAT_MX_ClienteChannel__c = 'Off Trade'
        
        );
        insert visit;
        
        String rtcheck = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + 'LAT_MX_CLV_SalesNegotiation');
        
        CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(
            RecordTypeId = rtcheck,
            Visit_AR__c = visit.Id            
        );
        
        insert check;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();          
        RestContext.request = req;
        RestContext.response= res;
       
    	String strbody = getChecklistMXStringBody();
		strbody = strbody.replace('IDCHECKLIST', check.Id);
		strbody = strbody.replace('IDVISITA', visit.Id);
		System.debug('strbody : ' + strbody);
      	req.requestBody = Blob.valueof(strbody);

      	LAT_Rest_ChecklistMX.PUT();
        Test.stopTest();
        
  	}
*/
	public static void createCreds(){
			CS001_JDEInterfaceCredentials__c cred = new CS001_JDEInterfaceCredentials__c(
			Name = 'Brasil',
			Country__c = '1',
			EndPoint_BalanceCheck__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/BalanceCheck/BalanceCheckProxy',
			EndPoint_ContractManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/ContractManager/ContractManagerProxy',
			EndPoint_CustomerHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerHandlerReq',
			EndPoint_CustomerVerify__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerVerifyReq',
			EndPoint_PaymentManager__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/PaymentManager/PaymentManagerProxy',
			EndPoint_PriceCalculation__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Price/PriceCalculationReq',
			EndPoint_RVManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/RVManager/RVManagerProxy',
			EndPoint_SalesOrderHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/SalesOrder/AsyncSalesOrderHandlerReq',
			EndPoint_ReceiptHandeler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Collection/CollectionManagerSFDCReq',
			EndPoint_GetStock__c = 'http://crm.test.pernod-ricard.com.br/SFDC/test',
			RemoteHostIP__c = '200.200.10.10',
			System__c = 'X',
			SystemUserID__c = 'cloud2b',
			Exec_new_Price_Calc__c = false
		);
		insert cred;
	}

	public static string getSalesAcademiStringBody(){
		return '{'+
			' "SWOT_Analysis": ['+
		'            {'+
		'                "weaknesses": "DENTRO DO SHOPPING - HORÁRIO DE FUNCIONAMENTOTESTCARDÁPIO DE DRINKS/BEBIDAS REDUZIDO",'+
		'                "threats": "CONCORRÊNCIA NO SHOPPING COM AÇÕES DE HAPPY HOUR",'+
		'                "strenghts": "POSICIONAMENTOTESTLOCALIZAÇÃOTESTALTA GASTRONOMIATESTAMBIENTE ACOLHEDORTESTBRIGADA ALTAMENTE QUALIFICADA E COMPETITIVA",'+
		'                "salesAcademyName": "ACV-0026",'+
		'                "salesAcademy": null,'+
		'                "recordTypeName": "LAT_On_Trade",'+
		'                "recordTypeId": "012D00000007UCVIA2",'+
		'                "name": "ASW-023",'+
		'                "id": null,'+
		'                "descriptionOpportunities": "DRINKS COM GINTESTHAPPY HOUR EM PARCERIA COM A PRBTESTESTABILIDADE DA ECONOMIATESTCARTA DE DRINKS",'+
		'                "Action_Focus": ['+
		'                    {'+
		'                        "swotId": null,'+
		'                        "id": null,'+
		'                        "description": "ENGAJAMENTO DA BRIGADA COM PRODUTOS PRBESESTENGAJAMENTO DA BRIGADA COM PRODUTOS PRB"'+
		'                    },'+
		'                    {'+
		'                        "swotId": null,'+
		'                        "id": null,'+
		'                        "description": "AUMENTO DO VOLUME DE VENDAS"'+
		'                    },'+
		'                    {'+
		'                        "swotId": null,'+
		'                        "id": null,'+
		'                        "description": "RECUPERAR CREDIBILIDADE COM O CLIENTE"'+
		'                    }'+
		'                ]'+
		'            }'+
		'        ],'+
		'        "Objectives_Definition": ['+
		'            {'+
		'                "Strategic_Objectives": ['+
		'                    {'+
		'                        "valueGoal": null,'+
		'                        "valueBox": null,'+
		'                        "strategicObjetives": "ENGAJAMENTO DA BRIGADA COM PRODUTOS PR",'+
		'                        "objetiveName": "OBE-071",'+
		'                        "objetiveId": null,'+
		'                        "negotiationArgument": "A BRIGADA ALINHADA COM A PRB, CONSEGUIREMOS IMPULSIONAR AS COMPRAS E AUMENTAR O VOLUME DA CASA, CONSEQUENTEMENTE AUMENTANDO O FATURAMENTO MENSAL",'+
		'                        "indicators": null,'+
		'                        "id": null,'+
		'                        "goal": "SER A PRMEIRA OPÇÃO OFERECIDA PELA BRIGADA",'+
		'                        "coverageGoal": null,'+
		'                        "counterparts": null,'+
		'                        "billingGoal": null,'+
		'                        "actualStatus": "BRIGADA INSATISFEITA COM A PRB"'+
		'                    },'+
		'                    {'+
		'                        "valueGoal": null,'+
		'                        "valueBox": null,'+
		'                        "strategicObjetives": "AUMENTO DO VOLUME DE VENDAS",'+
		'                        "objetiveName": "OBE-072",'+
		'                        "objetiveId": null,'+
		'                        "negotiationArgument": "O AUMENTO DO VOLUME DE VENDAS TRAS TAMBÉM UM MAIOR LUCRO PARA A CASA, ALÉM DISSO A OFERTA DE NOVOS DRINKS PERMITE CRIAR NOVAS SUPERFICIES DE CONTATO COM OS CLIENTES E OFERECER EXPERIENCIAS DIFERENTES DAS USUAIS",'+
		'                        "indicators": null,'+
		'                        "id": null,'+
		'                        "goal": "CRESCIMENTO DE 5% DAS VENDAS",'+
		'                        "coverageGoal": null,'+
		'                        "counterparts": null,'+
		'                        "billingGoal": null,'+
		'                        "actualStatus": "VOLUME DE VENDAS"'+
		'                    },'+
		'                    {'+
		'                        "valueGoal": null,'+
		'                        "valueBox": null,'+
		'                        "strategicObjetives": "RECUPERAR CREDIILIDADE COM O CLIENTE",'+
		'                        "objetiveName": "OBE-075",'+
		'                        "objetiveId": null,'+
		'                        "negotiationArgument": "FACILIDADE DE NEGOCIAÇÃO E TRANSPARENCIA NOS NEGOCIOS",'+
		'                        "indicators": null,'+
		'                        "id": null,'+
		'                        "goal": "CONSEGUIR FAZER COM QUE ESSE RELACIONAMENTO FLUA.",'+
		'                        "coverageGoal": null,'+
		'                        "counterparts": null,'+
		'                        "billingGoal": null,'+
		'                        "actualStatus": "CASA RESISTENTE A REALIZAR AÇÕES COM A PERNOD DEVIDO ATRASOS DE PAGAMENTOS DE CONTRATO E DE AÇÕES"'+
		'                    }'+
		'                ],'+
		'                "salesAcademy": null,'+
		'                "recordTypeName": "LAT_On_Trade",'+
		'                "recordTypeId": "012D00000007UCSIA2",'+
		'                "opportunitySetting": "SUPORTE DA PRB PARA ALAVANCAR VENDAS DA CASA",'+
		'                "name": "DOB-023",'+
		'                "id": null'+
		'            }'+
		'        ],'+
		'        "Header": {'+
		'            "status": "Ativo",'+
		'            "recordTypeName": "LAT_On_Trade",'+
		'            "recordTypeId": "012D00000007UCYIA2",'+
		'            "pDate": "2017-11-01",'+
		'            "name": "ACV-0026",'+
		'            "id": "IDSALESACADEMY",'+
		'            "clientName": "CAMARADA CAMARAO",'+
		'            "clientId":null'+
		'        },'+
		'        "Client_Analysis": ['+
		'            {'+
		'                "visibilitySituation": "ISIBILIDADE",'+
		'                "visibilityCause": "CASA DE FRANQUIA COM LIMITAÇÃO BEM RESTRITA DE ATIVAÇÕES",'+
		'                "teamTraining": null,'+
		'                "strengthsPlan": "A CASA POSSUI UM POSICIONAMENTO SÓLIDO E UMA BRIGADA EXCELENTE, ALÉM DE TER UMA LOCALIZAÇÃO FAVORÁVEL. PRECISA DESENVOLVER APENAS ESTIMULOS PARA QUE O CLIENTE BEBA MAIS DRINKS E INTERAJA MAIS COM OS PRODUTOS DA PRB",'+
		'                "strategicPlan": "SER REFERENCIA EM ATEDIMENDO NO SEGMENTO",'+
		'                "shopper": "HOMENS E MULHERES, CLASSE A / B+, + 25 - 40 EM BUSCA DE ALTA GASTRONOMIA OU HAPPY H].",'+
		'                "salesAcademyName": "ACV-0026",'+
		'                "salesAcademy": null,'+
		'                "recordTypeId": "012D00000007UCPIA2",'+
		'                "recomendationSituation": "RECOMENDAÇÃO DE CHIVAS",'+
		'                "recomendationCause": "CONSEGUIMOS RESGATAR O RELACIONAMENTO COM O CLIENTE E FAZER COM QUE INCENTIVEM A VENDA DOS PRODUTOS PRB",'+
		'                "promotionSituation": "CASA PROMOCIONA HAPPY HUR POR CONTA PRÓPRIA",'+
		'                "promotionCause": "O HAPPY HOUR PROMOCIONAL JÁ HAVIA ANTES DO CONTRATO E É UMA MARCA DA CASA",'+
		'                "priorities": "VOLUME",'+
		'                "priceSituation": "PREÇOS CONDIZENTES COM O DO MERCADO OU MAIS ALTO",'+
		'                "priceCause": "COMPATÍVEL COM O PÚBLICO",'+
		'                "positiveSituation": "ORLOFFESTABSOLUTESTBALLANTINEBALLANTINES 12YESTCHIVAS 12Y",'+
		'                "positiveCause": "CASA DE FRANQUIA SEM ABERTURA PARA INSERÇÃO DE MUITOS PRODUTOS",'+
		'                "name": "ANC-024",'+
		'                "logistic": null,'+
		'                "id": null,'+
		'                "goalsPlan": "AUMENTAR AS VENDAS E ABRIR MAIS FRANQUIAS",'+
		'                "experienceSituation": "ABSOLUT E CHIVAS SEMPRE PRESENTE NOS HAPPY HOURS, ASSOCIADOS A COMEMORAÇÃO COM AMIGOS E BONS MOMENTOS",'+
		'                "experienceCause": null,'+
		'                "distributionSituation": null,'+
		'                "distributionCause": null,'+
		'                "customerServices": "MÚSICA AMBIENTE / SERVIÇO DE ESTACIONAMENTO (SHOPPING)",'+
		'                "customerParticipation": "Menos 10%",'+
		'                "comercialAdhesion": "CLIENTE ESTAVA BEM ENGAJADO COM AS AÇÕES DA PRB, PORÉM HOUVE UM RECUO CONSIDERÁVEL APÓS OS DESGASTES QUE OCORRERAM POR ATRASO DE PAGTO DE PARCELA DE CONTRATO E DE AÇÕES DE CHIVAS.",'+
		'                "challengesPlan": "AS CASAS DO GRUPO JÁ SÃO BEM POSICIONADAS NO MERCADO, PORÉM PRECISAM SOBREVIVER À CRISE. ALEM DISSO O TRAMITE DE DECISÃO REQUER UM PROCESSO MUITO LONGO PARA EFETIVAR AÇÕES.",'+
		'                "brigadeTraining": "TREINADA"'+
		'            }'+
		'        ],'+
		'        "Action_Plan": ['+
		'            {'+
		'                "salesAcademyName": "ACV-0026",'+
		'                "salesAcademy": null,'+
		'                "recordTypeName": "LAT_On_Trade",'+
		'                "recordTypeId": "012D00000007UCMIA2",'+
		'                "objective": "ENGAJAMENTO DA BRIGADA COM PRODUTOS PRB",'+
		'                "name": "PLA-056",'+
		'                "indicator": "VOLUME",'+
		'                "id": null,'+
		'                "Actions": ['+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": "R$200",'+
		'                        "notes": "AGUARDANDO AUTORIZAÇÃO DA CASA",'+
		'                        "inCharge": "GERSICA TAVARES",'+
		'                        "id": null,'+
		'                        "endDate": "2017-11-30",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "CAMPANHA DE INCENTIVO",'+
		'                        "actionPlan": null'+
		'                    },'+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": null,'+
		'                        "notes": "AGUARDANDO AUTORIZAÇÃO DA CASA",'+
		'                        "inCharge": "GERSICA TAVARES",'+
		'                        "id": null,'+
		'                        "endDate": "2017-10-15",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "TREINAMENTO",'+
		'                        "actionPlan": null'+
		'                    },'+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": null,'+
		'                        "notes": "ESTÁ SENDO EXECUTADO",'+
		'                        "inCharge": "GERSICA TAVARESE ANDRÉ THÉ",'+
		'                        "id": null,'+
		'                        "endDate": "2017-11-30",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "SE APROXIMAR DA CASA ATRAVES DO OFERECIMENTO DE INGRESSOS DE SHOWS PRB À BRIGADA",'+
		'                        "actionPlan": null'+
		'                    }'+
		'                ]'+
		'            },'+
		'            {'+
		'                "salesAcademyName": "ACV-0026",'+
		'                "salesAcademy": null,'+
		'                "recordTypeName": "LAT_On_Trade",'+
		'                "recordTypeId": "012D00000007UCMIA2",'+
		'                "objective": "AUMENTO DO VOLUME DE VENDAS",'+
		'                "name": "PLA-057",'+
		'                "indicator": "VOLUME",'+
		'                "id": null,'+
		'                "Actions": ['+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": "R$1000",'+
		'                        "notes": "EM NEGOCIAÇÃO",'+
		'                        "inCharge": "GERSICA/ JOAO MORANDI",'+
		'                        "id": null,'+
		'                        "endDate": "2017-10-27",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "TROCA DO CARDAPIO DO HAPPY HOUR MANTENDO OS DRINKS DA CASA E ACRESCENDO O 2+2+1",'+
		'                        "actionPlan": null'+
		'                    },'+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": null,'+
		'                        "notes": "REALIZADO",'+
		'                        "inCharge": "GERSICA/ ROMERO",'+
		'                        "id": null,'+
		'                        "endDate": "2018-06-01",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "OFERECER PREÇOS DIFERENCIADOS E FACILITAR COMPRAS NA DISTRIBUIDORA",'+
		'                        "actionPlan": null'+
		'                    }'+
		'                ]'+
		'            },'+
		'            {'+
		'                "salesAcademyName": "ACV-0026",'+
		'                "salesAcademy": null,'+
		'                "recordTypeName": "LAT_On_Trade",'+
		'                "recordTypeId": "012D00000007UCMIA2",'+
		'                "objective": "RECUPERAR CREDIBILIDADE NO CLIENTE",'+
		'                "name": "PLA-058",'+
		'                "indicator": "RELACIONAMENTO",'+
		'                "id": null,'+
		'                "Actions": ['+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": null,'+
		'                        "notes": null,'+
		'                        "inCharge": "GERSICA TAVARES",'+
		'                        "id": null,'+
		'                        "endDate": "2017-12-30",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "REALIZAR PAGAMENTO DAS AÇÕES ANTECIPADAMENTE",'+
		'                        "actionPlan": null'+
		'                    },'+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": null,'+
		'                        "notes": null,'+
		'                        "inCharge": "GERSICA TAVARES",'+
		'                        "id": null,'+
		'                        "endDate": "2017-12-30",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "AUMENTAR FREQUENCIA DE VISITA NA CASA",'+
		'                        "actionPlan": null'+
		'                    },'+
		'                    {'+
		'                        "startDate": "2017-09-28",'+
		'                        "resourcesUsed": null,'+
		'                        "resourcesPlan": null,'+
		'                        "notes": null,'+
		'                        "inCharge": "GERSICA TAVARES",'+
		'                        "id": null,'+
		'                        "endDate": "2017-09-28",'+
		'                        "actualStatus": "Verde",'+
		'                        "actions": "DAR APOIO ÀS AÇÕES INTERNAS DA CASA, ESTANDO SEMPRE PRESENTE COM BRINDES E AGRADOS PARA A BRIGADA.",'+
		'                        "actionPlan": null'+
		'                    }'+
		'                ]'+
		'            }'+
		'        ]'+
		'    }';
	}

	public static string getContractStringBody(){
		return '{'+  
		'      "sfdcId": "eeeeeeee",'+
		'        "account": "IDACCOUNT",'+
		'        "accountName": null,'+
		'        "caap": null,'+
		'        "caapMargin": null,'+
		'        "caapMarginText": null,'+
		'        "cancelationReason": null,'+
		'        "comments": null,'+
		'        "commentsNegativeRO": null,'+
		'        "contractTerms": null,'+
		'        "contractValue": 11000,'+
		'        "endDate": "2020-11-01",'+
		'        "exclusivity": null,'+
		'        "gmdcTotal": 0,'+
		'        "isAnOpenPlace": false,'+
		'        "kpiFinancialReturn": null,'+
		'        "kpiVisibility": null,'+
		'        "money": null,'+
		'        "monthElapsed": 0,'+
		'        "nonApprovalReason": null,'+
		'        "prbCost": null,'+
		'        "processStatus": "Em Elaboração",'+
		'        "roi": 12.69,'+
		'        "standardClausesPRB": false,'+
		'        "startOfPartnership": null,'+
		'        "startDate": "2018-12-01",'+
		'        "status": "Aprovado",'+
		'        "suggestedMaximumInvesment": null,'+
		'        "totalBonus": null,'+
		'        "totalCostBonus": null,'+
		'        "totalInvestment": null,'+
		'        "totalNetSales": null,'+
		'        "value": null,'+
		'        "owner": "005D0000008T0qDIAS",'+
		'        "name": "CON-025753",'+
		'        "recordType": "012D00000007ToyIAE",'+
		'        "totalProductsPRBCost": 0,'+
		'        "totalMoneyPRBCost": 11000,'+
		'        "totalMoneyPerceivedValue": 11000,'+
		'        "totalProductsPerceivedValue": 0,'+
		'        "totalVodkaMonth": null,'+
		'        "totalWhiskyMonth": null,'+
		'        "totalOthersMonth": null,'+
		'        "totalMonth": null,'+
		'        "totalContractVolume": null,'+
		'        "totalContractVodka": null,'+
		'        "totalContractWhisky": null,'+
		'        "totalContractOthers": null,'+
		'        "prbPortfolio": "Vodkas Nacionais - Orloff;Vodkas Importadas - Absolut;Vodkas Importadas - Absolut Flavours;Vodkas Super Premium - Absolut Elyx;Gin Importado - Beefeater;Espumante - Mumm Cuvee",'+
		'        "annex1": false,'+
		'        "annex2": null,'+
		'        "withoutVolumeInformation": false,'+
		'        "customerSignedBy": null,'+
		'        "roiSegment": "PREMIUM +",'+
		'        "roiTarget": 10,'+
		'        "tradingConditionNegotiated": null,'+
		'        "customerSignatory": null,'+
		'        "regionalCustomerOnPremise": "REG NE",'+
		'        "vodkaClubCabinets": "10",'+
		'        "djBooth": null,'+
		'        "whiskyClubCabinets": "10",'+
		'        "barsShelves": "10",'+
		'        "revenue": 10.0,'+
		'        "source": null,'+
		'        "OriginalContractNumber": null,'+
		'        "OriginalContractROI": "10",'+
		'        "CancelDate": null,'+
		'        "OriginalContractName": null,'+
		'        "CalculationErrors": null,'+
		'        "CancelComments": "10",'+
		'        "CurrentSignatary": null,'+
		'        "ConsultantToTestify": true,'+
		'        "contrapartidas": "TEST",'+
		'        "listVolume": {'+
		'            "volume": ['+
		'                {'+
		'                    "contract": null,'+
		'                    "product": "IDPRODUCTPAYMENT",'+
		'                    "volumenType": null,'+
		'                    "boxesMaximum": 206,'+
		'                    "businessCondition": null,'+
		'                    "boxesContractMonth": 576'+
		'                },'+
		'                {'+
		'                    "contract": null,'+
		'                    "product": "IDPRODUCTPAYMENT",'+
		'                    "volumenType": null,'+
		'                    "boxesMaximum": 4.5,'+
		'                    "businessCondition": null,'+
		'                    "boxesContractMonth": 108'+
		'                }'+
		'            ]'+
		'        },'+
		'        "listPayment": {'+
		'            "payment": ['+
		'                {'+
		'                    "id": "IDPRODUCTPAYMENTCHILD",'+
		'                    "ammount": 1000,'+
		'                    "finality": "Contrato",'+
		'                    "contract": null,'+
		'                    "paymentDate": "2018-09-21",'+
		'                    "productGroup": null,'+
		'                    "recordType": "012D00000007Tp3IAE",'+
		'                    "volumen": null,'+
		'                    "paymentDateDone": null,'+
		'                    "status": "P",'+
		'                    "parentPayment": "test",'+
		'                    "releaseReason": "test"'+
		'                }'+
		'            ]'+
		'        },'+
		'        "listVisibilityCounterPart": {'+
		'            "visibilityCounterPart": ['+
		'                {'+
		'                    "id": null,'+
		'                    "comment": "DIVULGAÇÃO DAS MARCAS PRB NAS REDES SOCIAIS",'+
		'                    "type": "Mídia Social",'+
		'                    "contract": null'+
		'                }'+
		'            ]'+
		'        },'+
		'        "listProviders": {'+
		'            "provider": ['+
		'                {'+
		'                    "id": null,'+
		'                    "provider": "FORTALI DISTRIBUIDORA DE ALIMENTOS LTDA",'+
		'                    "cnpj": "09317318000175",'+
		'                    "contract": null'+
		'                }'+
		'            ]'+
		'        },'+
		'        "listClientContract": {'+
		'            "clientContract": ['+
		'                {'+
		'                    "id": null,'+
		'                    "client": "IDACCOUNT",'+
		'                    "contract": null'+
		'                }'+
		'            ]'+
		'        },'+
		'        "listPromotionAgreement": {'+
		'            "promotionAgreement": ['+
		'                {'+
		'                    "id": null,'+
		'                    "category": "Whisky 12 anos",'+
		'                    "contract": null,'+
		'                    "exclusivityPromotional": false,'+
		'                    "visualExclusivity": false,'+
		'                    "notes": "CHIVAS, BALLANTINES",'+
		'                    "priority": true'+
		'                }'+
		'            ]'+
		'        },'+
		'        "listContractDetail": {'+
		'            "contractDetail": []'+
		'        },'+
		'    "listContractEvent": {'+
		'      "ContractEvent": ['+
		'          {'+
		'            "contract": "718c64d6-df29-4872-b2b9-58d6fd7e2bd7",'+
		'            "dataEvento": "2019-05-26",'+
		'            "eventName": "Nombre test",'+
		'            "cidade": "a4yD0000000CeMjIAK",'+
		'            "convitesPista": 3,'+
		'            "convitesVIP": 3,'+
		'            "microRegional": "REG NO",'+
		'            "nroPessoas": 3,'+
		'            "openBar": true,'+
		'            "perfil": "a4yD0000000DVUWIA4",'+
		'            "periodo": "Diurno",'+
		'            "tipoEvento": "",'+
		'            "tipoVerba": "",'+
		'            "classeSocial": "B",'+
		'            "comunicacao": "Post Instagram",'+
		'            "estiloMusical":"Sertanejo;Pop",'+
		'            "faixaEtaria": "55 >",'+
		'            "motivo": "Outros",'+
		'            "motivoComentarios":"Es una prueba",'+
		'            "marcasAtivadas":"Absolut;Chivas",'+
		'            "ativacoes":"Avental;Cabine Dj",'+
		'            "comments":"Es una prueba con comentarios para ver si quedó todo como esperamos",'+
		'            "listVolume": {'+
		'            "volume": ['+
		'                {'+
		'                  "contract": "718c64d6-df29-4872-b2b9-58d6fd7e2bd7",'+ 
		'                  "product": "aKeD000000000GEKAY",'+
		'                  "boxesMaximum": "4.00"'+
		'                }'+
		'              ]'+
		'            }'+
		'          }'+
		'        ]'+
		'      }'+
		'    }';
	}

	public static string getContractGetInformationBody(){
		return '    {'+
		'       "contract": {'+
		'       "contractVolume": ['+
		'         {'+
		'           "Product": "IDPRODUCTPAYMENT",'+
		'           "BoxesMinimum": "6.00"'+
		'         }'+
		'       ],'+
		'       "payments": ['+
		'         {'+
		'           "Volumen": 40.0,'+
		'           "ProductGroup": "IDPRODUCTPAYMENTCHILD",'+
		'           "RecordType": "Pagamento Produto"'+
		'         }'+
		'       ],'+
		'       "ContractTerms": "24",'+
		'       "RecordType": "On Trade",'+
		'       "uf": "DF",'+
		'       "roiSegment": "PREMIUM +"'+
		'       }'+
		'    }';
	}

	public static string getSelloutCollectStringBody(){
		return '{'+
		'            "sfdcid": null,'+
		'            "account": "IDACCOUNT",'+
		'            "collectDate": "2018-12-13",'+
		'            "creationDate": "2018-12-03",'+
		'            "status": "Finalized",'+
		'            "referenceAccount": null,'+
		'            "referencedMonth": "2018-11-01",'+
		'            "unit": "CA",'+
		'            "name": "SC-80754",'+
		'            "externalId": null,'+
		'            "recordTypeDevName": "LAT_CollectNF",'+
		'            "ownerId": "005D0000008TlxpIAC",'+
		'            "ownerName": "Natuza Guerra",'+
		'            "sellOutCollectLine": ['+
		'                {'+
		'                    "sfdcid": null,'+
		'                    "referenceProductGrouping": "IDPRODUCTPAYMENTCHILD",'+
		'                    "sellOut": 2,'+
		'                    "sellOutCollect": null,'+
		'                    "stock": 0,'+
		'                    "name": "SCL-816759",'+
		'                    "positivated": true,'+
		'                    "bottle": 0,'+
		'                    "dose": 0'+
		'                }'+
		'            ]'+
		'        }';
	}

	public static string getChecklistMXStringBody(){
		return '{'+ 
		'            "Id": "IDCHECKLIST",'+
		'            "idVisita": "IDVISITA",'+
		'            "nameVisita": "July/2017 - 3188 - MBAQUE01",'+
		'            "name": "Negociacion Actividad - Off Trade",'+
		'            "subtype": null,'+
		'            "startTime": null,'+
		'            "endTime": null,'+
		'            "result": "result",'+
		'            "reason": "reason",'+
		'            "feedback": "feedback",'+
		'            "recordtype": "LAT_MX_CLV_ActivityNegotiationOff",'+
		'            "recordtypeId": "012D00000007LF9IAM",'+
		'            "questionsChecklist": ['+
		'                {'+
		'                    '+
		'                    "productId": null,'+
		'                    "productName": null,'+
		'                    "question": "PRegunta 3 texto",'+
		'                    "answered": true,'+
		'                    "answer": "estamos limpiando",'+
		'                    "answerCheckbox": false,'+
		'                    "answerFormula": null,'+
		'                    "recordtype": "Texto",'+
		'                    "recordtypeId": "012D00000007UAn"'+
		'                }'+
		'            ]'+
		'        }';
	}

	public static String getRestEventPaymentBody(){
		return '{'+
		'			"payment":['+
		'				{'+
		'					"volumen": 100.0,'+
		'					"valorEventoTotal": 4052.166666666667,'+
		'					"valorEventoProuto": 3890.08,'+
		'					"valorEventoCash": 162.08666666666704,'+
		'					"toDelete": null,'+
		'					"status": "P",'+
		'					"releaseReason": "Evento 1 test",'+
		'					"recordType": "012D00000007Tp4IAE",'+
		'					"productGroup": "IDPRODUCTPAYMENT",'+
		'					"producer": null,'+
		'					"paymentDateDone": null,'+
		'					"paymentDate": "2019-03-26",'+
		'					"id": "IDPAYMENT1",'+
		'					"finality": "Condição Comercial",'+
		'					"distribuitorId": "IDACCOUNT",'+
		'					"contract": "IDCONTRACT",'+
		'					"bonusQuantity": null,'+
		'					"bonusPercent": null,'+
		'					"ammount": null'+
		'				},'+
		'				{'+
		'					"volumen": 200.0,'+
		'					"valorEventoTotal": 12000.0,'+
		'					"valorEventoProuto": 11880.0,'+
		'					"valorEventoCash": 120.0,'+
		'					"toDelete": null,'+
		'					"status": "P",'+
		'					"releaseReason": "Evento 2 test",'+
		'					"recordType": "012D00000007Tp4IAE",'+
		'					"productGroup": "IDPRODUCTPAYMENT",'+
		'					"producer": null,'+
		'					"paymentDateDone": null,'+
		'					"paymentDate": "2019-03-26",'+
		'					"id": "IDPAYMENT2",'+
		'					"finality": "Condição Comercial",'+
		'					"distribuitorId": "IDACCOUNT",'+
		'					"contract": "IDCONTRACT",'+
		'					"bonusQuantity": null,'+
		'					"bonusPercent": null,'+
		'					"ammount": null'+
		'				}'+
		'			]'+
		'		}';
	}
	public static String getRestComCondEventCalculationsPaymentBody(){
		return 		'{'+
		'					"volumen": 100.0,'+
		'					"valorEventoTotal": 4052.166666666667,'+
		'					"valorEventoProuto": 3890.08,'+
		'					"valorEventoCash": 162.08666666666704,'+
		'					"toDelete": null,'+
		'					"status": "P",'+
		'					"releaseReason": "Evento 1 test",'+
		'					"recordType": "012D00000007Tp4IAE",'+
		'					"productGroup": "IDPRODUCTPAYMENT",'+
		'					"producer": null,'+
		'					"paymentDateDone": null,'+
		'					"paymentDate": "2019-03-26",'+
		'					"id": "IDPAYMENT1",'+
		'					"finality": "Condição Comercial",'+
		'					"distribuitorId": "IDACCOUNT",'+
		'					"contract": "IDCONTRACT",'+
		'					"bonusQuantity": null,'+
		'					"bonusPercent": null,'+
		'					"ammount": null'+
		'			}';
	}

	public static String getRestComCondEventCalculationsPaymentBodyPost(){
		return 		'{'+
		'					"volumen": 100.0,'+
		'					"valorEventoTotal": 4052.166666666667,'+
		'					"valorEventoProuto": 3890.08,'+
		'					"valorEventoCash": 162.08666666666704,'+
		'					"toDelete": null,'+
		'					"status": "P",'+
		'					"releaseReason": "Evento 1 test",'+
		'					"recordType": "012D00000007Tp4IAE",'+
		'					"productGroup": "IDPRODUCTPAYMENT",'+
		'					"producer": null,'+
		'					"paymentDateDone": null,'+
		'					"paymentDate": "2019-03-26",'+
		'					"finality": "Condição Comercial",'+
		'					"distribuitorId": "IDACCOUNT",'+
		'					"contract": "IDCONTRACT",'+
		'					"bonusQuantity": null,'+
		'					"bonusPercent": null,'+
		'					"ammount": null'+
		'			}';
	}

}