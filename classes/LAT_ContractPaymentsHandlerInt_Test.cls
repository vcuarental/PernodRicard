@isTest
public class LAT_ContractPaymentsHandlerInt_Test {
	private static string VENTAS_USERNAME = 'ventas@pernod-ricard.com.test';

	@TestSetup
	private static void setupTest(){
		initializeTest();
	}

	@isTest
	public static void calculatePaymentsInformationTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		LAT_ContractsCalculations objContractCalculations = null;
		Map<Id, LAT_ReferenceProduct__c> mapReferenceProducts = null;
		Set<String> setProductsIDs = null;
		String strRecordType = null;
		Set<String> setDistribuitorsIDs = null;
		Id objAccountId = null;

		mapReferenceProducts = new Map<Id, LAT_ReferenceProduct__c>();
		setProductsIDs = new Set<String>();
		setDistribuitorsIDs = new Set<String>();

		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);

		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
		
		Test.startTest();	
		//LAT_ContractsCalculationsTest.createProductCost(objReferenceProductGrouping.Id, objAccountId);
		
		try {
			LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(objContract.Id);
			insert pay;
			LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);
		} catch(Exception Ex ) {
			
		}
 		Test.stopTest();
	}
	/*
 	@isTest static void test_method_one() {
	//	createCreds();
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;
		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		insert payDinero;

		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00
			);
		insert cv;
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		insert payGroup;

		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}
	*/
	@isTest static void test_method_oneB() {
		LAT_Contract2__c con = retrieveContract();

		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		pay.LAT_EventActivityId__c = 10;
		insert pay;
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);}catch(Exception e){}

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		payDinero.LAT_EventActivityId__c = 10;
		insert payDinero;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);}catch(Exception e){}


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00,
				LAT_EventActivityId__c = 10
			);
		insert cv;
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.LAT_EventActivityId__c = 10;
		insert payGroup;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);}catch(Exception e){}
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}
	/*
	@isTest static void test_method_oneC() {
		LAT_Contract2__c con = retrieveContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
		update con;
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		pay.LAT_EventActivityId__c = 10;
		insert pay;
		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		payDinero.LAT_EventActivityId__c = 10;
		insert payDinero;

		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00,
				LAT_EventActivityId__c = 10
			);
		insert cv;
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.LAT_EventActivityId__c = 10;
		insert payGroup;

		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}
	*/
	@isTest static void test_methods() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;
		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		insert payDinero;

		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00
			);
		insert cv;
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		insert payGroup;

		LAT_Payment__c pay2 = [SELECT Id, LAT_Contract__r.RecordType.DeveloperName, LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.Client_code_AN8__c,LAT_Distributor__r.Business_Unit__r.Name,
		LAT_Contract__r.LAT_Distributor__r.Business_Unit__r.Name, LAT_Contract__r.account__r.Business_Unit__r.Name FROM LAT_Payment__c LIMIT 1];

		LAT_ContractPaymentsHandlerInterface.getAn8FromPayment(pay2);
		LAT_ContractPaymentsHandlerInterface.getBusinessUnitFromPayment(pay2);

		System.assertNotEquals(null, LAT_ContractPaymentsHandlerInterface.cloneOpportunity(new LAT_Opportunity__c ()));
		
		try{LAT_ContractPaymentsHandlerInterface.processIMMResponse(LAT_ContractPaymentsHandlerInterface.getMockCashPayment(), pay2);}catch(Exception e){}
		
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}

	@isTest static void test_methods2() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000 , 'valor','valor');
		LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		
		LAT_ContractPaymentsHandlerInterface.checkLocation('FABRICARESENDE');
		LAT_ContractPaymentsHandlerInterface.checkLocation('FABRICASUAPE');
		LAT_ContractPaymentsHandlerInterface.checkLocation('PRLOUVEIRA');
		LAT_ContractPaymentsHandlerInterface.checkLocation('PREXTREMA');

		try{LAT_ContractPaymentsHandlerInterface.processMEResponse(new LAT_PaymentProductHandler.SdtMsg(), pay,'10');} catch(Exception e){}
		try{LAT_ContractPaymentsHandlerInterface.processMEResponse(new LAT_PaymentMoneyHandler.SdtMsg(), pay,'10');} catch(Exception e){}
		try{LAT_ContractPaymentsHandlerInterface.updatePayment(pay,'11','11','11');}catch(Exception e){}
		
		try{LAT_ContractPaymentsHandlerInterface.updatePayment(pay,'00','00','00');}catch(Exception e){}
		Test.stopTest();
		
	}

	///DA ERROR 101- SE DIVIDE
	static void test_methods4() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoUSENOIMMSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoUSEIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSEIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSENOIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMEUSEIMMDineroSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMENOUSEIMMDineroSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMEUSEIMMDProdutorSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMENOUSEIMMProductoSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoUSENOIMMSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoUSEIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSEIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSENOIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMEUSEIMMDineroSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMENOUSEIMMDineroSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMEUSEIMMDProdutorSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}
		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMENOUSEIMMProductoSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods41() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods42() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}


	@isTest static void test_methods51() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoUSENOIMMSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods52() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoUSENOIMMSync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}
	

	@isTest static void test_methods61() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentprodutoUSEIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods62() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}
	

	@isTest static void test_methods71() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods72() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}
	

	@isTest static void test_methods81() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSEIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods82() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSEIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods91() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods2292() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentGroupMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods15151() { 
		LAT_Contract2__c con = retrieveContract();
		Attachment objAttachment = null;

		objAttachment = new Attachment();
		objAttachment.Name = 'Acordo Comercial';
		objAttachment.ParentId = con.Id; 
		objAttachment.Body = Blob.valueOf('TEST');
		Test.startTest();

		insert objAttachment;
		update objAttachment;
		
		Test.stopTest();
	}
	@isTest static void test_methodfdas91() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = true;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSENOIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}

	@isTest static void test_methods92() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;

		CS001_JDEInterfaceCredentials__c objCred = new CS001_JDEInterfaceCredentials__c();
		objCred.UseIMM__c = false;

		try{LAT_ContractPaymentsHandlerInterface.sendPaymentToPaymentDineroUSENOIMMMESync( objCred , new List<LAT_Payment__c> {pay} , pay, 10, 'test');} catch(Exception Ex) {}

		Test.stopTest();
		
	}
	@isTest static void test_method_three() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		

		Test.startTest();
		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00
			);
		insert cv;
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		insert payGroup;

		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}

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
        SystemUserID__c = 'cloud2b'
    );
    insert cred;
    }
	@isTest static void test_method_oneimm() {
		LAT_Contract2__c con = retrieveContract();
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		//insert conDA;
		
		//LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		//insert pay;
		system.debug('insert+++1');

		Test.startTest();
		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		insert payDinero;
		try{
			LAT_ContractPaymentsHandlerInterface.sendPaymentToMESync(payDinero.ParentPayment__c);

		} catch (Exception e){system.debug('excception+++1');}


		system.debug('sigue+++1');

		//try{
		//	LAT_ContractPaymentsHandlerInterface.sendPaymentToMESync(pay.ParentPayment__c);

		//} catch (Exception e){system.debug('excception+++2');}
		
		system.debug('sigue+++2');
/**
		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00
			);
		insert cv;
		system.debug('sigue+++3');
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		insert payGroup;
		try {
			LAT_ContractPaymentsHandlerInterface.sendPaymentToMESync(payGroup.ParentPayment__c);	
		} catch (Exception e){system.debug('excception+++3');}
*/
		try {
			LAT_ContractPaymentsHandlerInterface.getMockProductPayment();
			LAT_ContractPaymentsHandlerInterface.getMockCashPayment();
			LAT_ContractPaymentsHandlerInterface.processIMMResponse(LAT_ContractPaymentsHandlerInterface.getMockCashPayment(), payDinero);
		} catch (Exception e){system.debug('excception+++3111');}
		

		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}

	@isTest static void test_method_threeimm() {
		LAT_Contract2__c con = retrieveContract();
		
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		

		
		Test.startTest();
		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00
			);
		insert cv;
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		insert payGroup;
		try {
			LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		} catch (Exception e){}
		 
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
		
	}
	
	@isTest static void test_method_two() {
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {
			Test.startTest();
			Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
			LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element clas = new LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element();
			//clas.getValue();
			LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort port = new LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort();
			LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element elem = new LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element();
			port.Execute(elem);
			
			Test.stopTest();
		}
	}
	@isTest static void test_method_four() {

		User u = getLAT_SystemAdminUser();
		System.runAs(u) {
			Test.startTest();
			Map<String,String> mapa = new Map<String,String>();
			mapa.put('ANY key', 'ANY value');
			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
			
			LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element clas2 = new LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element();
			//clas2.getValue();
			LAT_PaymentProductHandler.SDTPagtoLD ppH = new LAT_PaymentProductHandler.SDTPagtoLD();
			LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort port2 = new LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort();
			port2.Execute(1,1,'TEST',1,'Test','Test','Test','Test','Test',ppH);
			Test.stopTest();
		}
	}


    public static User getLAT_SystemAdminUser() {
        
        return [SELECT Id, Email FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true and Email <> null LIMIT 1];
	}
	
    private static void initializeTest() {
        User objUser = null;
        CountrySettings objCountry = null;
		LAT_Product__c objProduct = null;
		LAT_Contract2__c objContract = null;
		Account objAccount = null;

        System.debug('initializeTest [] ->');

        deleteTriggers();
        createSettings();

        objCountry = retrieveCountryBR();        
		objAccount = createAccount(objCountry);
        createCredentials(objCountry);
		objProduct = createProduct(objCountry);
	   
		objContract = createContract(objAccount);


		createIMMData();
        System.debug('initializeTest [] <-');
    }

    private static CountrySettings retrieveCountryBR() { 
        CountrySettings objCountrySettings = null;

        System.debug('retrieveCountryBR [] ->');

        objCountrySettings = new CountrySettings();
        objCountrySettings.Country = 'Brasil';
        objCountrySettings.CountryCode  = '1';
        objCountrySettings.CountryLocale  = 'pt_BR';
        objCountrySettings.CountryTimeZoneSidKey  = 'America/Sao_Paulo';
        objCountrySettings.UserProfileId = [SELECT Id FROM Profile WHERE Name = 'LAT_BR2_Vendas' LIMIT 1].Id;
        objCountrySettings.PaymentRecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        objCountrySettings.AccountRecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
        objCountrySettings.ProductRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
        objCountrySettings.CNPJ = '91370573000162';
        objCountrySettings.CountryCurrency = 'BRL';

        System.debug('retrieveCountryBR [' + objCountrySettings + '] <-');

        return objCountrySettings;
    }

    private static CountrySettings retrieveCountryAR() { 
        CountrySettings objCountrySettings = null;

        System.debug('retrieveCountryAR [] ->');

        objCountrySettings = new CountrySettings();
        objCountrySettings.Country = 'Argentina';
        objCountrySettings.CountryCode = '6';
        objCountrySettings.CountryLocale = 'es_AR';
        objCountrySettings.CountryTimeZoneSidKey  = 'America/Argentina/Buenos_Aires';
        objCountrySettings.UserProfileId = [SELECT Id FROM Profile WHERE Name = 'LAT_AR2_Vendedor' LIMIT 1].Id;
        objCountrySettings.PaymentRecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');
        objCountrySettings.AccountRecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG');
        objCountrySettings.ProductRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'Standard_AR');
        objCountrySettings.CNPJ = '30660549311';
        objCountrySettings.CountryCurrency = 'ARS';

        System.debug('retrieveCountryAR [' + objCountrySettings + '] <-');

        return objCountrySettings;
    }

    private static CountrySettings retrieveCountryMX() { 
        CountrySettings objCountrySettings = null;

        System.debug('retrieveCountryMX [] ->');

        objCountrySettings = new CountrySettings();
        objCountrySettings.Country = 'Mexico';
        objCountrySettings.CountryCode  = '12';
        objCountrySettings.CountryLocale  = 'es_MX';
        objCountrySettings.CountryTimeZoneSidKey  = 'America/Mexico_City';
        objCountrySettings.UserProfileId = [SELECT Id FROM Profile WHERE Name = 'LAT_MX2_OnPremise' LIMIT 1].Id;
        objCountrySettings.PaymentRecordTypeId = Global_RecordTypeCache.getRtId('UDC__c'+'LAT_MX_UDC_Standard');
        objCountrySettings.AccountRecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        objCountrySettings.ProductRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard');
        objCountrySettings.CountryCurrency = 'MXN';
        objCountrySettings.CNPJ = 'TSO991022PB6';

        System.debug('retrieveCountryMX [' + objCountrySettings + '] <-');

        return objCountrySettings;
    }

    private static void deleteTriggers() {
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
    }

    private static void createSettings() {
        List<LAT_GeneralConfig__c> lstGeneralConfig = null;
        LAT_GeneralConfig__c objGeneralConfig = null;

        System.debug('createSettings [] ->');
        lstGeneralConfig = new List<LAT_GeneralConfig__c>();

        objGeneralConfig = new LAT_GeneralConfig__c();
        objGeneralConfig.Name = 'OPP_Verification_Email_Recipients';
        objGeneralConfig.LAT_Value__c = 'aaa@aaa.com';
        
        lstGeneralConfig.add(objGeneralConfig);

        objGeneralConfig = new LAT_GeneralConfig__c();
        objGeneralConfig.Name = 'MX_DEFAULT_INDEX_MARGIN';
        objGeneralConfig.LAT_Value__c = '99';
        lstGeneralConfig.add(objGeneralConfig);

        objGeneralConfig = new LAT_GeneralConfig__c();
        objGeneralConfig.Name = 'MX_IndexMarca_Notification_Users';
        objGeneralConfig.LAT_Value__c = '005D0000002h7xO';
        lstGeneralConfig.add(objGeneralConfig);
        
        insert lstGeneralConfig;

        System.debug('createSettings [] <-');
    }

    private static void postToChatter() {
        LAT_CHATTER_POST_BODY__c objPost = null;
        
        System.debug('postToChatter [] ->');

        objPost = new LAT_CHATTER_POST_BODY__c();
        objPost.Body__c =  'Test';
        objPost.Name = 'LAT_MX_ProductoSinIndexMarca';

        insert objPost;

        System.debug('postToChatter [] <-');
    }

    private static void createCredentials(CountrySettings objCountry){
        CS001_JDEInterfaceCredentials__c objJDEInterfaceCredentials = null; 
        
        System.debug('createCredentials [objCountry : ' + objCountry + '] ->');
        objJDEInterfaceCredentials = new CS001_JDEInterfaceCredentials__c();
        objJDEInterfaceCredentials.Name = objCountry.Country;
        objJDEInterfaceCredentials.Country__c = objCountry.CountryCode;
        objJDEInterfaceCredentials.EndPoint_BalanceCheck__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/BalanceCheck/BalanceCheckProxy';
        objJDEInterfaceCredentials.EndPoint_ContractManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/ContractManager/ContractManagerProxy';
        objJDEInterfaceCredentials.EndPoint_CustomerHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerHandlerReq';
        objJDEInterfaceCredentials.EndPoint_CustomerVerify__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerVerifyReq';
        objJDEInterfaceCredentials.EndPoint_PaymentManager__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/PaymentManager/PaymentManagerProxy';
        objJDEInterfaceCredentials.EndPoint_PriceCalculation__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Price/PriceCalculationReq';
        objJDEInterfaceCredentials.EndPoint_RVManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/RVManager/RVManagerProxy';
        objJDEInterfaceCredentials.EndPoint_SalesOrderHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/SalesOrder/AsyncSalesOrderHandlerReq';
        objJDEInterfaceCredentials.EndPoint_ReceiptHandeler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Collection/CollectionManagerSFDCReq';
        objJDEInterfaceCredentials.EndPoint_GetStock__c = 'http://crm.test.pernod-ricard.com.br/SFDC/test';
        objJDEInterfaceCredentials.RemoteHostIP__c = '200.200.10.10';
        objJDEInterfaceCredentials.System__c = 'X';
        objJDEInterfaceCredentials.SystemUserID__c = 'cloud2b';
        objJDEInterfaceCredentials.Exec_new_Price_Calc__c = false;
        objJDEInterfaceCredentials.UseIMM__c = true;
        insert objJDEInterfaceCredentials;

        System.debug('createCredentials [] <-');
    }

    private static User createUser(CountrySettings objCountry) {
        User objUser = null;
        
        System.debug('createUser [objCountry : ' + objCountry + '] ->');

        objUser = new User();
        objUser.Email = 'matias.rodriguezllanos-ext@pernod-ricard.com';
        objUser.Username = VENTAS_USERNAME + objCountry.CountryCode;
        objUser.LastName = 'Rodriguez Llanos';
        objUser.ProfileId = objCountry.UserProfileId;
        objUser.Alias = 'alias' + objCountry.CountryCode;
        //objUser.TimeZoneSidKey = 'America/Argentina/Buenos_Aires';
        objUser.TimeZoneSidKey = objCountry.CountryTimeZoneSidKey;
        objUser.LocaleSidKey = objCountry.CountryLocale;
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LanguageLocaleKey = objCountry.CountryLocale;
        objUser.ADDomainUser__c = '';
        objUser.PR_Affiliate__c = '';     

        insert objUser;

        System.debug('createUser [' + objUser + '] <-');

        return objUser;
    }
    
    private static User retrieveUser(CountrySettings objCountry) {
        User objUser = null;
        String strUserName = null;
        
        System.debug('retrieveUser [objCountry : ' + objCountry + '] ->');

        strUserName = VENTAS_USERNAME + objCountry.CountryCode;
        objUser = [SELECT Id FROM User WHERE ProfileId =: objCountry.UserProfileId AND Username =: strUserName ];
        
        System.debug('retrieveUser [' + objUser + '] <-');

        return objUser;
    }

    private static Account createAccount(CountrySettings objCountry) {
        Account objAccount = null;

        System.debug('createAccount [objCountry : ' + objCountry + '] ->');

        objAccount = new Account();
        objAccount.RecordTypeId = objCountry.AccountRecordTypeId; 
        objAccount.CNPJ__c = objCountry.CNPJ;
        objAccount.Name = 'testAccount' + objCountry.CNPJ;
        objAccount.Overdue__c = false;
        objAccount.Type = 'Prospect_ARG';
        objAccount.Corporate_Name__c = 'test';
        objAccount.Channel_Type__c = 'Direto';
        objAccount.Sub_Channel__c = 'Delicatessen';
        objAccount.AddressLine1_AR__c= 'test';
        objAccount.Shipping_Neighbourhood__c = 'test';
        objAccount.Revenue_Neighbourhood__c = 'test';
        objAccount.Billing_Neighbourhood__c ='test';
        objAccount.Shipping_Country__c ='test';
        objAccount.Revenue_Country__c ='test';
        objAccount.Billing_Country__c ='test';
        objAccount.Status__c = 'Novo cadastro';
        objAccount.Client_code_An8__c = '111111';
        objAccount.Client_country_An8__c = objCountry.CountryCode + '-1111';
        objAccount.CurrencyISOCode = objCountry.CountryCurrency;

        insert objAccount;   
        
        System.debug('createAccount [' + objAccount + '] <-');

        return objAccount;
    }

    private static Account retrieveAccount(CountrySettings objCountry) {
        Account objAccount = null;
        String strAccountName = null;

        System.debug('retrieveAccount [objCountry : ' + objCountry + '] ->');
        strAccountName = 'testAccount' + objCountry.CNPJ;

        objAccount = [SELECT    RecordTypeId, 
                                CNPJ__c,
                                Name, 
                                Overdue__c, 
                                Type, 
                                Corporate_Name__c, 
                                Channel_Type__c,
                                Sub_Channel__c,
                                AddressLine1_AR__c,
                                Shipping_Neighbourhood__c,
                                Revenue_Neighbourhood__c ,
                                Billing_Neighbourhood__c,
                                Shipping_Country__c,
                                Revenue_Country__c,
                                Billing_Country__c,
                                Status__c,
                                Client_code_An8__c,
                                Client_country_An8__c,
                                CurrencyISOCode 
                        FROM Account 
                        WHERE Name =: strAccountName
                        LIMIT 1 ];
        System.debug('retrieveAccount [' + objAccount + '] <-');

        return objAccount;
    }

    private static LAT_Product__c createProduct(CountrySettings objCountry) {
        LAT_Product__c objProduct = null;

        System.debug('createProduct [objCountry : ' + objCountry + ' ] ->');

        objProduct = new LAT_Product__c();
        objProduct.Name = 'TestProd' + objCountry.CountryCode;
        objProduct.LAT_IsActive__c = true;
        objProduct.LAT_CDUnit__c = 'CA';
        objProduct.LAT_ExternalID__c = '444';
        objProduct.LAT_QTLeadTime__c = 5;
        objProduct.LAT_Sku__c = '5666';
        objProduct.RecordTypeId = objCountry.ProductRecordTypeId;

        insert objProduct;
        
        System.debug('createProduct [' + objProduct + '] <-');

        return objProduct;
    }

    private static LAT_Product__c retrieveProduct(CountrySettings objCountry) {
        LAT_Product__c objProduct = null;
        String strProductName = null;
        System.debug('retrieveProduct [objCountry : ' + objCountry + '] ->');

        strProductName = 'TestProd' + objCountry.CountryCode;
        objProduct = [SELECT    Name,
                                LAT_IsActive__c,
                                LAT_CDUnit__c,
                                LAT_ExternalID__c,
                                LAT_QTLeadTime__c,
                                LAT_Sku__c,
                                RecordTypeId
                      FROM LAT_Product__c
                      WHERE Name =: strProductName
                      LIMIT 1];

        System.debug('retrieveProduct [' + objProduct + '] <-');

        return objProduct;
    }

    private static UDC__c createPaymentCondition(CountrySettings objCountry) {
        UDC__c objPaymentCondition = null;

        System.debug('createPaymentCondition [objCountry : ' + objCountry + '] ->');

        objPaymentCondition = new UDC__c();
        objPaymentCondition.CodDefUsuario__c = 'V42';
        objPaymentCondition.CodProd__c = 'CRM';
        objPaymentCondition.CodUs__c = 'PT';
        objPaymentCondition.Internal_Id__c = objCountry.CountryCode + '-V42-CRM-PT';
        objPaymentCondition.RecordTypeId = objCountry.PaymentRecordTypeId;

        insert objPaymentCondition;

        System.debug('createPaymentCondition [' + objPaymentCondition + '] <-');

        return objPaymentCondition;    
    }

    private static UDC__c retrievePaymentCondition(CountrySettings objCountry) {
        UDC__c objPaymentCondition = null;
        String strInternalId = null;

        System.debug('retrievePaymentCondition [objCountry : ' + objCountry + ' ] ->');

        strInternalId = objCountry.CountryCode + '-V42-CRM-PT';
        objPaymentCondition = [ SELECT CodDefUsuario__c, CodProd__c, CodUs__c, Internal_Id__c, RecordTypeId
                                FROM UDC__c
                                WHERE Internal_Id__c =: strInternalId
                                LIMIT 1];

        System.debug('retrievePaymentCondition [' + objPaymentCondition + '] <-');

        return objPaymentCondition;    
	}
	
	

	private static LAT_Contract2__c createContract(Account objAccount) {
		LAT_Contract2__c objContract = null;

		objContract = new LAT_Contract2__c();
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get('LAT_OnTrade_CommercialConditionContract').getRecordTypeId();
		objContract.Status__c = 'Novo Contrato';
		objContract.Account__c = objAccount.Id;
		objContract.StartDate__c = Date.today().addDays(-180);
		objContract.EndDate__C =  Date.today().addDays(180);
		objContract.ROI_Target__c = 12.0;
		objContract.LAT_ImmActivityInt__c = 10;

		insert objContract;

		return objContract;
	}

	private static LAT_ContractWorflow__c createActivityIMM() {
		LAT_ContractWorflow__c objContractWorkFlow = null;

		objContractWorkFlow = new LAT_ContractWorflow__c();
		objContractWorkFlow.WorkflowNumber__c = 10;
		objContractWorkFlow.FY__c = 'FY20';
		objContractWorkFlow.RegionalClientOnPremise__c = 'ON TRADE SPI';
		objContractWorkFlow.WF__c = 'CS';
		insert objContractWorkFlow;

		return objContractWorkFlow;
	}
	private static LAT_Payment__c createPayment(LAT_Contract2__c objContract,LAT_ContractWorflow__c objContractWorkFlow, LAT_ReferenceProductGrouping__c objReferenceProductGrouping) {
		LAT_Payment__c objPayment = null;

		objPayment = new LAT_Payment__c();
		objPayment.LAT_Contract__c = objContract.Id;
		objPayment.LAT_EventActivityId__c = 10;
		objPayment.PaymentDate__c = Date.today();
		objPayment.ProductGroup__c = objReferenceProductGrouping.Id;
		objPayment.PaymentDate__c = Datetime.now().date();
		objPayment.Finality__c = 'Condição Comercial Off Invoice';
		objPayment.Status__c = 'P'; //Pendente
		objPayment.IntegrationStatus__c = 'Novo';
		objPayment.Volumen__c = 10;
		objPayment.productValue__c = 10;
		objPayment.WorkflowME__c = objContractWorkFlow.Id; 
				
		insert objPayment;

		return objPayment;
	}


	private static LAT_Contract2__c retrieveContract() {
		LAT_Contract2__c objContract = null;

        System.debug('retrieveContract [] ->');

        objContract = [ SELECT Id, Name, ROI_Target__c, StartDate__c, EndDate__C, Account__c, Status__c,  RecordTypeId
						FROM LAT_Contract2__c
						LIMIT 1];

        System.debug('retrieveContract [' + objContract + '] <-');

        return objContract;    
	}

	private static LAT_ReferenceProductGrouping__c createReferenceProductGrouping() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;

		objReferenceProductGrouping = new LAT_ReferenceProductGrouping__c();
		objReferenceProductGrouping.Name = 'Test';
		objReferenceProductGrouping.RecordTypeId = Schema.SObjectType.LAT_ReferenceProductGrouping__c.getRecordTypeInfosByDeveloperName().get('LAT_ProductPayment').getRecordTypeId(); 
		objReferenceProductGrouping.GroupType__c = 'SKU';
		objReferenceProductGrouping.Order__c = 10;

		insert objReferenceProductGrouping;

		return objReferenceProductGrouping;
	}

	private static LAT_ReferenceProduct__c createReferenceProduct(LAT_ReferenceProductGrouping__c objReferenceProductGrouping, LAT_Product__c objProduct) {
		LAT_ReferenceProduct__c objReferenceProduct = null;
		
		objReferenceProduct = new LAT_ReferenceProduct__c();
		objReferenceProduct.Type__c = 'SKU';
		objReferenceProduct.LAT_Product__c = objProduct.id;
		objReferenceProduct.ReferenceGrouping__c = objReferenceProductGrouping.Id;
		objReferenceProduct.RecordTypeId = Schema.SObjectType.LAT_ReferenceProduct__c.getRecordTypeInfosByDeveloperName().get('LAT_ProductPayment').getRecordTypeId();
		
		insert objReferenceProduct;

		return objReferenceProduct;
	}
	
	public static void createIMMData() {
		List<LAT_IMM_Operations__c> lstIMMOperations = null;
		LAT_IMM_Operations__c objIMMOperation = null;

		lstIMMOperations = new List<LAT_IMM_Operations__c>();


		objIMMOperation = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='GetFreeGood', Service_Name_Header__c='IMM', Name = 'GetFreeGood', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		lstIMMOperations.add(objIMMOperation);

		objIMMOperation = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'CreateCashPayment',operation_Name_header__c = 'CreateCashPayment', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		lstIMMOperations.add(objIMMOperation);


		objIMMOperation = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'GetCashPayment',operation_Name_header__c = 'GetCashPayment', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		lstIMMOperations.add(objIMMOperation);
		
		objIMMOperation = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'CreateAndSendFreeGood',operation_Name_header__c = 'CreateAndSendFreeGood', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		lstIMMOperations.add(objIMMOperation);

		insert lstIMMOperations;
	}

	private static LAT_IMM_Operations__c retrieveIMMOperation(String strOperation) {
		return [SELECT userLDAP__c , Type__c, idCurrency__c,idStatus__c, idConceptoGasto__c, idAlmacen__c ,Name ,operation_Name_header__c, EndpointUrl__c, Service_Name_Header__c, Http_operation__c, x_Api_key__c
				FROM LAT_IMM_Operations__c
				WHERE Name =: strOperation];
	}
    private class CountrySettings {
        public String Country {get; set;}
        public String CountryCode {get; set;}
        public String CountryLocale {get; set;}
        public String CountryTimeZoneSidKey {get; set;}
        public String UserProfileId { get; set; }
        public String PaymentRecordTypeId { get; set; }
        public String AccountRecordTypeId { get; set; }
        public String ProductRecordTypeId { get; set; }
        public String CNPJ { get; set; }
        public String CountryCurrency { get; set; }
	}
	
	private static String retrieveMockResponse() {
		String json = '{'+
						'    "id": 175,'+
						'    "type": "CP",'+
						'    "documentType": "CP",'+
						'    "description": "Lorem Ipsum",'+
						'    "dateRequest": "2017-09-17T08:00:00.000Z",'+
						'    "dateApproval": null,'+
						'    "jdeStatus": "-",'+
						'    "userName": "BSOUZA01 - Bruno Souza",'+
						'    "login": "BSOUZA01",'+
						'    "idErp": null,'+
						'    "erpDocumentType": null,'+
						'    "amount": 0,'+
						'    "indBoi": 0,'+
						'    "idAttachment": null,'+
						'    "amountPending": 0,'+
						'    "amountReceived": 0,'+
						'    "dateAccount": null,'+
						'    "accountBatchNumber": null,'+
						'    "subarea": {'+
						'        "idSubarea": 9'+
						'    },'+
						'    "status": {'+
						'        "idStatus": 4,'+
						'        "description": "CRIADO"'+
						'    },'+
						'    "activity": {'+
						'        "idActivity": 1'+
						'    },'+
						'    "currency": {'+
						'        "idCurrency": 1,'+
						'        "exchangeRate": 1,'+
						'        "currencyCode": "BRL",'+
						'        "currencyName": "Brazil - Real"'+
						'    },'+
						'    "conceptoGasto": {'+
						'        "idConceptoGasto": 207,'+
						'        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"'+
						'    },'+
						'    "provider": {'+
						'        "id": 51557,'+
						'        "code": 16274,'+
						'        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"'+
						'    },'+
						'    "almacen": {'+
						'        "idAlmacen": 25,'+
						'        "description": "Sao Paulo"'+
						'    },'+
						'    "docType": "CP"'+
						'}';

		return json;
	}

	public static LAT_BR_IMM_RestCallHandler.GenericBodyIMM getMockCashPayment(){
    	String json= retrieveMockResponse();
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		return obj;
    }
}