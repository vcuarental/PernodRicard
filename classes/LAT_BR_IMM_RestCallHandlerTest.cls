@isTest
public class LAT_BR_IMM_RestCallHandlerTest {
    private static string VENTAS_USERNAME = 'ventas@pernod-ricard.com.test';

	@TestSetup
    private static void setup() {         
		LAT_Product__c objProduct = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;

		System.debug('setup [] ->');

		delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];   

		initializeTest();

		System.debug('setup [] <-');
	}

	@IsTest
	private static void responseClassesTest() {
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM objGenericBodyIMM = null;
		LAT_BR_IMM_RestCallHandler.cls_skus objSKU = null;

		objGenericBodyIMM = new LAT_BR_IMM_RestCallHandler.GenericBodyIMM();
		objGenericBodyIMM.activity = new LAT_BR_IMM_RestCallHandler.cls_activity();
		objGenericBodyIMM.activity.idActivity = 1;

		objGenericBodyIMM.soldTo = new LAT_BR_IMM_RestCallHandler.cls_soldTo();
		objGenericBodyIMM.soldTo.id = 1;
		objGenericBodyIMM.soldTo.internalClient = 1;
		objGenericBodyIMM.soldTo.name = 'test';

		objGenericBodyIMM.almacen = new LAT_BR_IMM_RestCallHandler.cls_almacen();
		objGenericBodyIMM.almacen.idAlmacen = '1';
		objGenericBodyIMM.almacen.name = 'test';

		objGenericBodyIMM.conceptoGasto = new LAT_BR_IMM_RestCallHandler.cls_conceptoGasto();
		objGenericBodyIMM.conceptoGasto.idConceptoGasto = 1;
		objGenericBodyIMM.conceptoGasto.name = 'test';

		objGenericBodyIMM.shipTo = new LAT_BR_IMM_RestCallHandler.cls_shipTo();
		objGenericBodyIMM.shipTo.idAddress = 1;
		objGenericBodyIMM.shipTo.address1 = 'test';
		objGenericBodyIMM.shipTo.address2 = 'test';
		objGenericBodyIMM.shipTo.city = 'test';
		objGenericBodyIMM.shipTo.cliente = 'test';
		objGenericBodyIMM.shipTo.country = 'test';
		objGenericBodyIMM.shipTo.postalCode = 'test';
		objGenericBodyIMM.shipTo.state = 'test';

		objGenericBodyIMM.currency_p = new LAT_BR_IMM_RestCallHandler.cls_currency();
		objGenericBodyIMM.currency_p.idCurrency = 1;
		objGenericBodyIMM.currency_p.code = 'test';
		objGenericBodyIMM.currency_p.name = 'test';

		objGenericBodyIMM.status = new LAT_BR_IMM_RestCallHandler.cls_status();
		objGenericBodyIMM.status.idStatus = 1;
		objGenericBodyIMM.status.name = 'test';
		objGenericBodyIMM.status.description = 'test';

		objGenericBodyIMM.activity = new LAT_BR_IMM_RestCallHandler.cls_activity();
		objGenericBodyIMM.activity.idActivity = 1;

		objGenericBodyIMM.subarea = new LAT_BR_IMM_RestCallHandler.cls_subarea();
		objGenericBodyIMM.subarea.idSubarea = 1;

		objGenericBodyIMM.provider = new LAT_BR_IMM_RestCallHandler.cls_provider();
		objGenericBodyIMM.provider.id = 1;
		objGenericBodyIMM.provider.code = 1;
		objGenericBodyIMM.provider.providerName = 'test';

		objSKU = new LAT_BR_IMM_RestCallHandler.cls_skus();
		objSKU.status = new LAT_BR_IMM_RestCallHandler.cls_status();
		objSKU.status.idStatus = 1;
		objSKU.status.description = 'Test';
		objSKU.status.name = 'Test';

		objSKU.sku = new LAT_BR_IMM_RestCallHandler.cls_sku();
		objSKU.sku.description = 'Test';
		objSKU.sku.code = 'Test';

		objSKU.measureUnit = new LAT_BR_IMM_RestCallHandler.cls_measureUnit();
		objSKU.measureUnit.uniMed = 'test';
		objSKU.measureUnit.unitCost = 1;
		objSKU.requestedQuantity = 1;
		objSKU.totalCost = 1;
		objSKU.deliverDate = 'Test';
		objSKU.accountBatchNumber = 1;
		
		objGenericBodyIMM.skus = new List<LAT_BR_IMM_RestCallHandler.cls_skus>();
		objGenericBodyIMM.skus.add(objSKU);

		objGenericBodyIMM.userName = 'userName';
        objGenericBodyIMM.userLDAP = 'userLDAP';
        objGenericBodyIMM.id = 32; //32
        objGenericBodyIMM.type = 'PSC'; //PSC
        objGenericBodyIMM.companyId = 'PSC'; //PSC
        objGenericBodyIMM.description = 'Teste de IntegraciÃ³n'; //Teste de IntegraciÃ³n
		objGenericBodyIMM.requestDate = '2017-11-02T15:21:56.000Z'; //2017-11-02T15:21:56.000Z

		objGenericBodyIMM.confiPriceCatalogue = true;
		objGenericBodyIMM.idActivity = 1;
		objGenericBodyIMM.amount = 200; //200
		objGenericBodyIMM.invoiceName = 'Test';
        objGenericBodyIMM.totalAmount = 200;
        objGenericBodyIMM.bottles = 2;
        objGenericBodyIMM.deliveryClient = 'Test';
        objGenericBodyIMM.requestingUser  = 'Test'; //JGOMES01 - Jefferson Gomes
        objGenericBodyIMM.jdeId  = 'Test';
        objGenericBodyIMM.idErp  = 1111;
		objGenericBodyIMM.jdeStatus  = 'Test';
		objGenericBodyIMM.balance  = 'Test';
        objGenericBodyIMM.orderType  = 'Test'; //SM
        objGenericBodyIMM.phone  = 1111; //551192223333
        objGenericBodyIMM.contact = 'Test'; //Lionel Messi
        objGenericBodyIMM.deliveryInstructions = 'Test'; //delivery Instructions
		objGenericBodyIMM.indBoi = 100; //0
        objGenericBodyIMM.targetModule = 'Test'; //Lionel Messi
		objGenericBodyIMM.targetReference = 1111; //Lionel Messi
		

		System.assertNotEquals(null,objGenericBodyIMM);
		System.assertNotEquals(null,objGenericBodyIMM.activity);
		System.assertEquals(1,objGenericBodyIMM.activity.idActivity);
		System.assertEquals(1,objGenericBodyIMM.soldTo.id);
		System.assertEquals(1,objGenericBodyIMM.soldTo.internalClient);
		System.assertEquals('test',objGenericBodyIMM.soldTo.name);		
		System.assertEquals('1',objGenericBodyIMM.almacen.idAlmacen);
		System.assertEquals('test',objGenericBodyIMM.almacen.name);		
		System.assertEquals(1,objGenericBodyIMM.conceptoGasto.idConceptoGasto);
		System.assertEquals('test',objGenericBodyIMM.conceptoGasto.name);
		System.assertEquals(1,objGenericBodyIMM.shipTo.idAddress);
		System.assertEquals('test',objGenericBodyIMM.shipTo.address1);
		System.assertEquals('test',objGenericBodyIMM.shipTo.address2);
		System.assertEquals('test',objGenericBodyIMM.shipTo.city);
		System.assertEquals('test',objGenericBodyIMM.shipTo.cliente);
		System.assertEquals('test',objGenericBodyIMM.shipTo.country);
		System.assertEquals('test',objGenericBodyIMM.shipTo.postalCode);
		System.assertEquals('test',objGenericBodyIMM.shipTo.state);
		System.assertEquals(1,objGenericBodyIMM.currency_p.idCurrency);
		System.assertEquals('test',objGenericBodyIMM.currency_p.code);
		System.assertEquals('test',objGenericBodyIMM.currency_p.name);
		System.assertEquals(1,objGenericBodyIMM.status.idStatus);
		System.assertEquals('test',objGenericBodyIMM.status.name);
		System.assertEquals('test',objGenericBodyIMM.status.description);
		System.assertEquals(1,objGenericBodyIMM.activity.idActivity);
		System.assertEquals(1,objGenericBodyIMM.subarea.idSubarea);
		System.assertEquals(1,objGenericBodyIMM.provider.id);
		System.assertEquals(1,objGenericBodyIMM.provider.code);
		System.assertEquals('test',objGenericBodyIMM.provider.providerName);
		
		System.assertEquals('userName',objGenericBodyIMM.userName);
        System.assertEquals('userLDAP',objGenericBodyIMM.userLDAP);
        System.assertEquals(32,objGenericBodyIMM.id); //32
        System.assertEquals('PSC',objGenericBodyIMM.type); //PSC
        System.assertEquals('PSC',objGenericBodyIMM.companyId); //PSC
        System.assertEquals('Teste de IntegraciÃ³n',objGenericBodyIMM.description ); //Teste de IntegraciÃ³n
		System.assertEquals('2017-11-02T15:21:56.000Z',objGenericBodyIMM.requestDate); //2017-11-02T15:21:56.000Z

		System.assertEquals(true,objGenericBodyIMM.confiPriceCatalogue);
		System.assertEquals(1,objGenericBodyIMM.idActivity);
		System.assertEquals(200,objGenericBodyIMM.amount); //200
		System.assertEquals('Test',objGenericBodyIMM.invoiceName);
        System.assertEquals(200,objGenericBodyIMM.totalAmount);
        System.assertEquals(2,objGenericBodyIMM.bottles);
        System.assertEquals('Test',objGenericBodyIMM.deliveryClient);
        System.assertEquals('Test',objGenericBodyIMM.requestingUser); //JGOMES01 - Jefferson Gomes
        System.assertEquals('Test',objGenericBodyIMM.jdeId);
        System.assertEquals(1111,objGenericBodyIMM.idErp);
		System.assertEquals('Test',objGenericBodyIMM.jdeStatus);
		System.assertEquals('Test',objGenericBodyIMM.balance);
        System.assertEquals('Test',objGenericBodyIMM.orderType); //SM
        System.assertEquals(1111,objGenericBodyIMM.phone); //551192223333
        System.assertEquals('Test',objGenericBodyIMM.contact); //Lionel Messi
        System.assertEquals('Test',objGenericBodyIMM.deliveryInstructions); //delivery Instructions
		System.assertEquals(100,objGenericBodyIMM.indBoi); //0
        System.assertEquals('Test',objGenericBodyIMM.targetModule); //Lionel Messi
		System.assertEquals(1111,objGenericBodyIMM.targetReference); //Lionel Messi
		


		System.assertEquals(1,objGenericBodyIMM.skus[0].status.idStatus); //Lionel Messi
		System.assertEquals('Test',objGenericBodyIMM.skus[0].status.description); //Lionel Messi
		System.assertEquals('Test',objGenericBodyIMM.skus[0].status.name); //Lionel Messi


		System.assertEquals('Test',objGenericBodyIMM.skus[0].sku.description); //Lionel Messi
		System.assertEquals('Test',objGenericBodyIMM.skus[0].sku.code); //Lionel Messi


		System.assertEquals('test',objGenericBodyIMM.skus[0].measureUnit.uniMed); //Lionel Messi
		System.assertEquals(1,objGenericBodyIMM.skus[0].measureUnit.unitCost); //Lionel Messi

		System.assertEquals('Test',objGenericBodyIMM.skus[0].deliverDate); //Lionel Messi
		System.assertEquals(1,objGenericBodyIMM.skus[0].requestedQuantity); //Lionel Messi
		System.assertEquals(1,objGenericBodyIMM.skus[0].totalCost); //Lionel Messi
		System.assertEquals(1,objGenericBodyIMM.skus[0].requestedQuantity); //Lionel Messi		
	}

	@isTest
	private static void genericMethodsTest() {
		System.assertEquals('Condição Comercial Off Invoice',LAT_BR_IMM_RestCallHandler.FINALITY_COMMERCIAL_CONDITION);
		System.assertEquals('x-api-key', LAT_BR_IMM_RestCallHandler.IMM_API_KEY_HEADER);
		System.assertEquals('x-service-name', LAT_BR_IMM_RestCallHandler.IMM_SERVICE_NAME_HEADER);
		System.assertEquals('x-service-operation', LAT_BR_IMM_RestCallHandler.IMM_SERVICE_OPERATION_HEADER);
	
		// Operations
		System.assertEquals('GetFreeGood', LAT_BR_IMM_RestCallHandler.IMM_OPERATION_GET_FREEGOOD);
		System.assertEquals('GetCashPayment', LAT_BR_IMM_RestCallHandler.IMM_OPERATION_GET_PAYMENT);
		System.assertEquals('CreateCashPayment', LAT_BR_IMM_RestCallHandler.IMM_OPERATION_PAYMEMTN);
		System.assertEquals('CreateAndSendFreeGood', LAT_BR_IMM_RestCallHandler.IMM_OPERATION_POST_FREEGOOD);
	
		System.assertEquals(0, LAT_BR_IMM_RestCallHandler.IMM_FREE_GOOD_CONCEPTO_PAGO);
		System.assertEquals(0, LAT_BR_IMM_RestCallHandler.IMM_FREE_PAYMENT_CONCEPTO_PAGO);
		System.assertEquals(2, LAT_BR_IMM_RestCallHandler.EVENT_DEVELOPER_NAMES.size());
	
		
		LAT_BR_IMM_RestCallHandler.bodyTest = 'test';
		System.assertEquals('test', LAT_BR_IMM_RestCallHandler.bodyTest);

		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.createIMMException('strBody', 'strMessage'));

	}

	@isTest
	public static void retrieveProductsTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);

		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.retrieveProductSKUMap( new Set<Id> { objReferenceProductGrouping.Id} ));
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.retrieveRegionaProductSKURMap( new Set<Id> { objReferenceProductGrouping.Id}, objPayment ));
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.retrieveAN8( objPayment) );

		Test.stopTest();
	}

	@isTest
	public static void createFreeGoodRequestTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_IMM_Operations__c objIMMOperations = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<String,String> mapResult = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);
		objIMMOperations = retrieveIMMOperation('CreateAndSendFreeGood');
		mapResult = new Map<String,String>();

		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapResult));

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		objPayment = createPayment(objContract, objContractWorkFlow, objReferenceProductGrouping);
		LAT_BR_IMM_RestCallHandler.bodyTest = retrieveMockResponse();
		
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.createFreeGoodRequest(objPayment, objIMMOperations));

		Test.stopTest();
	}

	@isTest
	public static void createFreeGoodTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_IMM_Operations__c objIMMOperations = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<String,String> mapResult = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);
		objIMMOperations = retrieveIMMOperation('CreateAndSendFreeGood');
		mapResult = new Map<String,String>();

		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(200, 'Status', 'Test', mapResult));

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		objPayment = createPayment(objContract, objContractWorkFlow, objReferenceProductGrouping);
		LAT_BR_IMM_RestCallHandler.bodyTest = retrieveMockResponse();
		
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.createFreeGood(new List<LAT_Payment__c> { objPayment }));

		Test.stopTest();
	}

	@isTest
	public static void createFreeGoodGroupTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_IMM_Operations__c objIMMOperations = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<String,String> mapResult = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);
		objIMMOperations = retrieveIMMOperation('CreateAndSendFreeGood');
		mapResult = new Map<String,String>();

		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(200, 'Status', 'Test', mapResult));

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		objPayment = createPayment(objContract, objContractWorkFlow, objReferenceProductGrouping);
		LAT_BR_IMM_RestCallHandler.bodyTest = retrieveMockResponse();
		
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.createFreeGoodGroup(objPayment, new List<LAT_Payment__c> { objPayment }));

		Test.stopTest();
	}

	@isTest
	public static void createFreeGoodGroupEventosTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_IMM_Operations__c objIMMOperations = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<String,String> mapResult = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);
		objIMMOperations = retrieveIMMOperation('CreateAndSendFreeGood');
		mapResult = new Map<String,String>();

		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(200, 'Status', 'Test', mapResult));

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		objPayment = createPayment(objContract, objContractWorkFlow, objReferenceProductGrouping);
		LAT_BR_IMM_RestCallHandler.bodyTest = retrieveMockResponse();
		
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.createFreeGoodGroupEventos(objPayment, new List<LAT_Payment__c> { objPayment }));

		Test.stopTest();
	}

	@isTest
	public static void createCashPaymentTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_IMM_Operations__c objIMMOperations = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<String,String> mapResult = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);
		objIMMOperations = retrieveIMMOperation('CreateAndSendFreeGood');
		mapResult = new Map<String,String>();

		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(200, 'Status', 'Test', mapResult));

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		objPayment = createPayment(objContract, objContractWorkFlow, objReferenceProductGrouping);
		LAT_BR_IMM_RestCallHandler.bodyTest = retrieveMockResponse();
		
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.createCashPayment(objPayment));

		Test.stopTest();
	}
	@isTest
	public static void getFreeGoodTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_IMM_Operations__c objIMMOperations = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<String,String> mapResult = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);
		objIMMOperations = retrieveIMMOperation('CreateAndSendFreeGood');
		mapResult = new Map<String,String>();

		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(200, 'Status', 'Test', mapResult));

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		objPayment = createPayment(objContract, objContractWorkFlow, objReferenceProductGrouping);
		LAT_BR_IMM_RestCallHandler.bodyTest = retrieveMockResponse();
		
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.getFreeGood(objPayment.Id));

		Test.stopTest();
	}
	
	@isTest
	public static void getCashPaymentTest() {
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_IMM_Operations__c objIMMOperations = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<String,String> mapResult = null;
		
		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);
		objIMMOperations = retrieveIMMOperation('CreateAndSendFreeGood');
		mapResult = new Map<String,String>();

		Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(200, 'Status', 'Test', mapResult));

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();
		objPayment = createPayment(objContract, objContractWorkFlow, objReferenceProductGrouping);
		LAT_BR_IMM_RestCallHandler.bodyTest = retrieveMockResponse();
		
		System.assertNotEquals(null, LAT_BR_IMM_RestCallHandler.getCashPayment(objPayment.Id));

		Test.stopTest();
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
	
	public static String retrieveMockResponse() {
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
	/*
		// static testMethod void  testIntegrationService(){
		// 	LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		// 	insert con;
		// 	Test.startTest();
        //
		// 	LAT_IMM_Operations__c op = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='GetFreeGood', Service_Name_Header__c='IMM', Name = 'GetFreeGood', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		// 	insert op;
        //
        //
		// 	LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		// 	insert pay;
        //
        //
        //
		// 	Test.stopTest();
		// }

	@isTest static void createPaymentReq() {


		String json=		'{'+
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

		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		LAT_Contract2__c con = getContract();
		insert con;
		Test.startTest();

		LAT_IMM_Operations__c op = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='GetFreeGood', Service_Name_Header__c='IMM', Name = 'GetFreeGood', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		insert op;



		//createFreeGood(List < LAT_Payment__c > payments)

		//createFreeGoodGroup(LAT_Payment__c parent, List < LAT_Payment__c > payments)

		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		insert pay;
		LAT_BR_IMM_RestCallHandler.bodyTest = json;
		try {
			LAT_BR_IMM_RestCallHandler.GenericBodyIMM imm =	LAT_BR_IMM_RestCallHandler.getFreeGood(pay.id);
		} catch (Exception e) {}
		

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinhero(con.Id);
		insert payDinero;

		LAT_Payment__c payDineroQ = [Select Finality__c, LAT_Contract__r.Name, WFNumber__c, Ammount__c, LAT_Contract__r.account__r.Client_code_AN8__c,  CreatedDate from LAT_Payment__c where Id =: payDinero.id  ];

		op.userLDAP__c = 'BSOUZA01';
		op.idStatus__c = 2;
		op.idAlmacen__c = '40';
		op.Name = 'CreateCashPayment';
		op.operation_Name_header__c = 'CreateCashPayment';
		update op;
		try {
			
			LAT_BR_IMM_RestCallHandler.GenericBodyIMM gPay = LAT_BR_IMM_RestCallHandler.createCashPayment(payDineroQ);
			// LAT_IMM_IntegrateService Tests
		} catch (Exception e) {}

		try {
			LAT_IMM_IntegrateService.updatePaymentFromImm(payDinero.Id);
		} catch (Exception e) {
			System.debug('Error en LAT_BR_RestCallHandler: ' + e);
		}
		

		// LAT_Payment__c cv = new LAT_Payment__c (
		// 			LAT_Contract__c = con.id,
		// 			PaymentDateDone__c = Date.today(),
		// 			PaymentDate__c	 = Date.today(),
		// 			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
		// 			paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
		// 			Status__c = 'I',
		// 			Ammount__c = 1000.00
		// 		);
		// 	insert cv;
		// 	LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		// 	payGroup.ParentPayment__c = cv.id;
		// 	insert payGroup;

			//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		Test.stopTest();

		// @isTest
		// private class LAT_ContractPaymentsHandlerInt_Test {
        //
		// 	@isTest static void test_method_one() {
		// 		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		// 		insert con;
		// 		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
		// 			Contract__c = con.Id,
		// 			DANumber__c = 12345,
		// 			Fiscal_Year__c = 'FY17',
		// 			Type__c = 'TE',
		// 			status__c = 'Ativo'
		// 			); 
		// 		insert conDA;
		// 		Test.startTest();
		// 		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		// 		insert pay;
		// 		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);
        //
		// 		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		// 		insert payDinero;
        //
		// 		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);
        //
        //
		// 		LAT_Payment__c cv = new LAT_Payment__c (
		// 				LAT_Contract__c = con.id,
		// 				PaymentDateDone__c = Date.today(),
		// 				PaymentDate__c	 = Date.today(),
		// 				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
		// 				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
		// 				Status__c = 'I',
		// 				Ammount__c = 1000.00
		// 			);
		// 		insert cv;
		// 		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		// 		payGroup.ParentPayment__c = cv.id;
		// 		insert payGroup;
        //
		// 		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		// 		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		// 		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		// 		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		// 		Test.stopTest();
		// 	}
        //
		// 	@isTest static void test_method_three() {
		// 		LAT_Contract2__c con = LAT_ContractsWS_Test.getContract();
		// 		insert con;
		// 		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
		// 			Contract__c = con.Id,
		// 			DANumber__c = 12345,
		// 			Fiscal_Year__c = 'FY17',
		// 			Type__c = 'TE',
		// 			status__c = 'Ativo'
		// 			);
		// 		insert conDA;
        //
        //
		// 		Test.startTest();
		// 		LAT_Payment__c cv = new LAT_Payment__c (
		// 				LAT_Contract__c = con.id,
		// 				PaymentDateDone__c = Date.today(),
		// 				PaymentDate__c	 = Date.today(),
		// 				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoDinheiro'),
		// 				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
		// 				Status__c = 'I',
		// 				Ammount__c = 1000.00
		// 			);
		// 		insert cv;
		// 		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		// 		payGroup.ParentPayment__c = cv.id;
		// 		insert payGroup;
        //
		// 		LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		// 		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		// 		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		// 		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		// 		Test.stopTest();
		// 	}
        //
		// 	@isTest static void test_method_two() {
		// 		User u = LAT_ContractsCalculationsTest.getLAT_SystemAdminUser();
		// 		System.runAs(u) {
		// 			Test.startTest();
		// 			Map<String,String> mapa = new Map<String,String>();
		// 			mapa.put('ANY key', 'ANY value');
		// 			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		// 			LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element clas = new LAT_PaymentMoneyHandler.WSPagtoCheque_ExecuteResponse_element();
		// 			//clas.getValue();
		// 			LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort port = new LAT_PaymentMoneyHandler.WSPagtoChequeSoapBindingQSPort();
		// 			LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element elem = new LAT_PaymentMoneyHandler.WSPagtoCheque_Execute_element();
		// 			port.Execute(elem);
        //
		// 			Test.stopTest();
		// 		}
		// 	}
		// 	@isTest static void test_method_four() {
		// 		User u = LAT_ContractsCalculationsTest.getLAT_SystemAdminUser();
		// 		System.runAs(u) {
		// 			Test.startTest();
		// 			Map<String,String> mapa = new Map<String,String>();
		// 			mapa.put('ANY key', 'ANY value');
		// 			Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
        //
		// 			LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element clas2 = new LAT_PaymentProductHandler.WSPagtoProduto_ExecuteResponse_element();
		// 			//clas2.getValue();
		// 			LAT_PaymentProductHandler.SDTPagtoLD ppH = new LAT_PaymentProductHandler.SDTPagtoLD();
		// 			LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort port2 = new LAT_PaymentProductHandler.WSPagtoProdutoSoapBindingQSPort();
		// 			port2.Execute(1,1,'TEST',1,'Test','Test','Test','Test','Test',ppH);
		// 			Test.stopTest();
		// 		}
		// 	}
        //
		// }
		//System.assert(obj != null);
	}

	@isTest static void testCreateFreeGoodandgroupB() {

		addIMMData();
		LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;
		LAT_Contract2__c con = getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
		insert con;
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY20',
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		LAT_Product__c p = lat_cota_test.LAT_getProduct();
            p.LAT_IsRefactorProduct__c = 'Y';
            p.LAT_IsActive__c = true;
			p.LAT_ProductCode__c = '12';
			p.LAT_Sku__c = '12';
            p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
		insert p;
		
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		pay.LAT_EventActivityId__c = 10;
		pay.PaymentDate__c	 = Date.today();
		//insert pay;

		LAT_ReferenceProduct__c refProd = new LAT_ReferenceProduct__c(
			Type__c='SKU',
			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_ProductPayment'),
        	ReferenceGrouping__c = pay.ProductGroup__c,
        	IsActive__c = true,
			LAT_Product__c = p.Id
		);
		insert refProd;

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		payDinero.LAT_EventActivityId__c = 10;
		payDinero.PaymentDate__c	 = Date.today();
		//insert payDinero;

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00,
				ProductGroup__c =  pay.ProductGroup__c,
				Volumen__c = 200
			);
		insert new List<LAT_Payment__c>{cv, pay, payDinero};
		LAT_ContractWorflow__c nuevo = new LAT_ContractWorflow__c();
		nuevo.WorkflowNumber__c = 10;
		nuevo.FY__c = 'FY20';
		nuevo.RegionalClientOnPremise__c = 'ON TRADE SPI';
		nuevo.WF__c = 'CS';
		insert nuevo;

		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.ProductGroup__c =  pay.ProductGroup__c;
		payGroup.LAT_Contract__c = con.Id;
		payGroup.WorkflowME__c = nuevo.Id;
		payGroup.PaymentDate__c	 = Date.today();
		payGroup.LAT_EventActivityId__c = 10;
		insert payGroup;

		payGroup = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,LAT_Contract__r.RecordType.Developername,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payGroup.Id
	  ];

	  cv = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),LAT_Contract__r.RecordType.Developername,
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : cv.Id
	  ];

		try{
			LAT_BR_IMM_RestCallHandler.createFreeGoodGroup(payGroup, new list<LAT_Payment__c>{cv, pay});
		} catch (Exception e) {}
		

		try{
			LAT_BR_IMM_RestCallHandler.createFreeGood(new list<LAT_Payment__c>{cv, pay});
		} catch (Exception e) {}

		try{
			LAT_BR_IMM_RestCallHandler.getCashPayment(payDinero.Id);
		} catch (Exception e) {}
		//

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}
	@isTest static void testCreateFreeGoodandgroup() {

		addIMMData();
		LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;
		LAT_Contract2__c con = getContract();
		insert con;
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY20', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		LAT_Product__c p = lat_cota_test.LAT_getProduct();
            p.LAT_IsRefactorProduct__c = 'Y';
            p.LAT_IsActive__c = true;
			p.LAT_ProductCode__c = '12';
			p.LAT_Sku__c = '12';
            p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
		insert p;
		
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		pay.LAT_EventActivityId__c = 10;
		pay.PaymentDate__c	 = Date.today();
		//insert pay;

		LAT_ReferenceProduct__c refProd = new LAT_ReferenceProduct__c(
			Type__c='SKU',
			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_ProductPayment'),
        	ReferenceGrouping__c = pay.ProductGroup__c,
        	IsActive__c = true,
			LAT_Product__c = p.Id
		);
		insert refProd;

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		payDinero.LAT_EventActivityId__c = 10;
		payDinero.PaymentDate__c	 = Date.today();
		//insert payDinero;

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00,
				ProductGroup__c =  pay.ProductGroup__c,
				Volumen__c = 200
			);
		insert new List<LAT_Payment__c>{cv, pay, payDinero};
		LAT_ContractWorflow__c nuevo = new LAT_ContractWorflow__c();
		nuevo.WorkflowNumber__c = 10;
		nuevo.FY__c = 'FY20';
		nuevo.RegionalClientOnPremise__c = 'ON TRADE SPI';
		nuevo.WF__c = 'CS';
		insert nuevo;

		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.ProductGroup__c =  pay.ProductGroup__c;
		payGroup.LAT_Contract__c = con.Id;
		payGroup.WorkflowME__c = nuevo.Id;
		payGroup.PaymentDate__c	 = Date.today();
		payGroup.LAT_EventActivityId__c = 10;
		insert payGroup;

		payGroup = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,LAT_Contract__r.RecordType.Developername,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payGroup.Id
	  ];

	  cv = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),LAT_Contract__r.RecordType.Developername,
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : cv.Id
	  ];

		try{
			LAT_BR_IMM_RestCallHandler.createFreeGoodGroup(payGroup, new list<LAT_Payment__c>{cv, pay});
		} catch (Exception e) {}
		

		try{
			LAT_BR_IMM_RestCallHandler.createFreeGood(new list<LAT_Payment__c>{cv, pay});
		} catch (Exception e) {}

		try{
			LAT_BR_IMM_RestCallHandler.getCashPayment(payDinero.Id);
		} catch (Exception e) {}
		//

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}
	@isTest static void testcreateFreeGoodGroupEventos() {

		addIMMData();
		LAT_Contract2__c con = getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
		insert con;

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
		Test.startTest();

		insert new List<LAT_Payment__C>{cv};
		
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.LAT_Contract__c = con.Id;
		payGroup.LAT_EventActivityId__c = 10;
		payGroup.LAT_Producer__c = true;
		payGroup.LAT_Distributor__c = con.Account__c;
		payGroup.Finality__c = 'Condição Comercial';
		insert payGroup;

		payGroup = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from 					Investimentos_Bonifica_es_e_Pagamentos__r),
	   		LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
			CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, 					LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Contract__r.RecordType.Developername,
	   		Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   		Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payGroup.Id
	  	];

		cv = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from 					Investimentos_Bonifica_es_e_Pagamentos__r ), 
			LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
			CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Contract__r.RecordType.Developername,
			Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
			Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : cv.Id
		];

		
		try{
			LAT_BR_IMM_RestCallHandler.createFreeGoodGroupEventos(payGroup, new list<LAT_Payment__c>{cv,payGroup });
		} catch (Exception e) {}
		//
		Test.stopTest();
	}
	@isTest static void testCreateFreeGoodandgroupB2() {

		addIMMData();
		LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;
		LAT_Contract2__c con = getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
		insert con;
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY20',
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		LAT_Product__c p = lat_cota_test.LAT_getProduct();
            p.LAT_IsRefactorProduct__c = 'Y';
            p.LAT_IsActive__c = true;
			p.LAT_ProductCode__c = '12';
			p.LAT_Sku__c = '12';
            p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
		insert p;
		
		Test.startTest();
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		pay.LAT_EventActivityId__c = 10;
		pay.PaymentDate__c	 = Date.today();
		//insert pay;

		LAT_ReferenceProduct__c refProd = new LAT_ReferenceProduct__c(
			Type__c='SKU',
			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_ProductPayment'),
        	ReferenceGrouping__c = pay.ProductGroup__c,
        	IsActive__c = true,
			LAT_Product__c = p.Id
		);
		insert refProd;

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		payDinero.LAT_EventActivityId__c = 10;
		payDinero.PaymentDate__c	 = Date.today();
		//insert payDinero;

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00,
				ProductGroup__c =  pay.ProductGroup__c,
				Volumen__c = 200
			);
		insert new List<LAT_Payment__c>{cv, pay, payDinero};
		LAT_ContractWorflow__c nuevo = new LAT_ContractWorflow__c();
		nuevo.WorkflowNumber__c = 10;
		nuevo.FY__c = 'FY20';
		nuevo.RegionalClientOnPremise__c = 'ON TRADE SPI';
		nuevo.WF__c = 'CS';
		insert nuevo;

		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.ProductGroup__c =  pay.ProductGroup__c;
		payGroup.LAT_Contract__c = con.Id;
		payGroup.WorkflowME__c = nuevo.Id;
		payGroup.PaymentDate__c	 = Date.today();
		payGroup.LAT_EventActivityId__c = 10;
		insert payGroup;

		payGroup = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,LAT_Contract__r.RecordType.Developername,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payGroup.Id
	  ];

	  cv = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),LAT_Contract__r.RecordType.Developername,
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : cv.Id
	  ];

		try{
			payGroup.IDMe__c = '1212';
			LAT_BR_IMM_RestCallHandler.createFreeGoodGroup(payGroup, new list<LAT_Payment__c>{cv, pay});
		} catch (Exception e) {}
		

		try{
			LAT_BR_IMM_RestCallHandler.createFreeGood(new list<LAT_Payment__c>{cv, pay});
		} catch (Exception e) {}

		try{
			payDinero.IDMe__c = '1213';
			LAT_BR_IMM_RestCallHandler.getCashPayment(payDinero.Id);
		} catch (Exception e) {}
		//

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}
	@isTest static void testcreateFreeGoodGroupEventos2() {

		addIMMData();
		LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;
		LAT_Contract2__c con = getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
		insert con;
		LAT_Product__c p = lat_cota_test.LAT_getProduct();
            p.LAT_IsRefactorProduct__c = 'Y';
            p.LAT_IsActive__c = true;
			p.LAT_ProductCode__c = '12';
			p.LAT_SKU__c = '12';
            p.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
		insert p;
		LAT_Payment__c cv = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		cv.PaymentDate__c	 = Date.today();
		cv.PaymentDateDone__c	 = Date.today();
		cv.Status__c = 'I';
		cv.Ammount__c = 1000.00;
		cv.LAT_EventActivityId__c = 10;

		LAT_ReferenceProduct__c refProd = new LAT_ReferenceProduct__c(
			Type__c='SKU',
        	ReferenceGrouping__c = cv.ProductGroup__c,
        	IsActive__c = true,
			LAT_Product__c = p.Id,
			RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ReferenceProduct__c'+'LAT_ProductPayment')
		);
		Test.startTest();

		insert refProd;
		insert new List<LAT_Payment__C>{cv};
		
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.LAT_Contract__c = con.Id;
		payGroup.LAT_EventActivityId__c = 10;
		payGroup.LAT_Producer__c = true;
		payGroup.LAT_Distributor__c = con.Account__c;
		payGroup.Finality__c = 'Condição Comercial';
		insert payGroup;

		payGroup = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from 					Investimentos_Bonifica_es_e_Pagamentos__r),
	   		LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
			CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, 					LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Contract__r.RecordType.Developername,
	   		Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   		Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payGroup.Id
	  	];

		cv = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from 					Investimentos_Bonifica_es_e_Pagamentos__r ), 
			LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
			CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Contract__r.RecordType.Developername,
			Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
			Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : cv.Id
		];

		
		try{
			LAT_BR_IMM_RestCallHandler.createFreeGoodGroupEventos(payGroup, new list<LAT_Payment__c>{cv,payGroup });
		} catch (Exception e) {}
		//
		Test.stopTest();
	}
	@isTest static void testcreateCashEventos() {

		addIMMData();
		LAT_Contract2__c con = getContract();
		con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
		insert con;

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);
		payDinero.PaymentDate__c	 = Date.today();
		payDinero.LAT_Producer__c = true;
		payDinero.LAT_Distributor__c = con.Account__c;
		payDinero.Finality__c = 'Condição Comercial';
		Test.startTest();
		insert new List<LAT_Payment__C>{payDinero};

		payDinero = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from 					Investimentos_Bonifica_es_e_Pagamentos__r ), 
			LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
			CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,LAT_Producer__c, LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.LAT_Distributor__r.Client_code_AN8__c, LAT_Contract__r.account__r.LAT_BR_RegionalClientOnPremise__c,
			Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
			Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payDinero.Id
		];

		
		try{
			LAT_BR_IMM_RestCallHandler.createCashPayment(payDinero);
		} catch (Exception e) {}
		//
		
	}

	@isTest static void testIntegrateServiceClass() {

		addIMMData();
		LAT_Contract2__c con = getContract();
		insert con;
		
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
		
		Test.startTest();
		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);

		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00
			);

		List<LAT_Payment__c> toInsert = new List<LAT_Payment__c>();
		toInsert.add(cv);
		toInsert.add(pay);
		toInsert.add(payDinero);
		insert toInsert;
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.LAT_Contract__c = con.Id;
		insert payGroup;

		payGroup = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payGroup.Id
	  ];

	  cv = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
	   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
	   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,
	   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
	   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : cv.Id
	  ];
	  LAT_Payment__c dinheropay = LAT_ContractsWS_Test.getPaymentDinhero(con.Id);

  		try{
			if(Limits.getLimitQueries() < 95){LAT_IMM_IntegrateService.send(dinheropay.Id);}
			
		} catch (Exception e) {}

		try{
			if(Limits.getLimitQueries() < 95){LAT_IMM_IntegrateService.send(payGroup.Id);}
		} catch (Exception e) {}
		

		try{
			if(Limits.getLimitQueries() < 95){LAT_IMM_IntegrateService.updatePaymentFromImm(cv.Id);}
		} catch (Exception e) {}

		try{
			if(Limits.getLimitQueries() < 95){LAT_IMM_IntegrateService.updatePaymentFromImm(payGroup.Id);}
		} catch (Exception e) {}
		
		
		try{
				/// set paymentId in params
			RestRequest req = new RestRequest(); 
			req.addParameter('paymentId', payGroup.Id);
			if(Limits.getLimitQueries() < 95){LAT_IMM_IntegrateService.updatePayment();}
		} catch (Exception e) {}

		LAT_IMM_IntegrateService.getMockFreeGoodGroup();
		LAT_IMM_IntegrateService.getMocDinheroGroup();
		//

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}

	@isTest static void testIntegrateServiceClass2() {

		System.debug('%%%. -3');
		addIMMData();
		System.debug('%%%. -2');
		LAT_Contract2__c con = getContract();
		insert con;
		Test.startTest();
		System.debug('%%%. -1.5');
		LAT_ContractDA__c conDA = new LAT_ContractDA__c(
			Contract__c = con.Id, 
			DANumber__c = 12345,
			Fiscal_Year__c = 'FY17', 
			Type__c = 'TE',
			status__c = 'Ativo'
			);
		insert conDA;
		System.debug('%%%. -1');
		
		LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(pay.ParentPayment__c);

		LAT_Payment__c payDinero = LAT_ContractsWS_Test.getPaymentDinheroWithParent(con.Id);


		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payDinero.ParentPayment__c);


		LAT_Payment__c cv = new LAT_Payment__c (
				LAT_Contract__c = con.id,
				PaymentDateDone__c = Date.today(),
				PaymentDate__c	 = Date.today(),
				RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto'),
				paymentGoals__c = '<table cellpadding="4" border="0" style="width: 100%;" cellspacing="0"><thead><tr><th colspan="1" rowspan="1" style="text-align: left;">Produto</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Previsto(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Volume Comprovado(LT)</th><th colspan="1" rowspan="1" style="text-align: left;">Meta Atingida?</th></tr></thead><tbody><tr><td colspan="1" rowspan="1"><strong>CHIVAS 12</strong></td><td colspan="1" rowspan="1">3.0</td><td colspan="1" rowspan="1">2.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>ABSOLUT REGULAR</strong></td><td colspan="1" rowspan="1">41.1</td><td colspan="1" rowspan="1">6.0</td><td colspan="1" rowspan="1">Não</td></tr><tr><td colspan="1" rowspan="1"><strong>JAMESON</strong></td><td colspan="1" rowspan="1">16.5</td><td colspan="1" rowspan="1">26.0</td><td colspan="1" rowspan="1">Sim</td></tr><tr><td colspan="1" rowspan="1"><strong>CHIVAS 18</strong></td><td colspan="1" rowspan="1">0</td><td colspan="1" rowspan="1">2.1</td><td colspan="1" rowspan="1">Não</td></tr></tbody><tfoot><tr><td colspan="1" rowspan="1"><strong>TOTAL</strong></td><td colspan="1" rowspan="1"><strong>60.6</strong></td><td colspan="1" rowspan="1"><strong>36.1</strong></td><td colspan="1" rowspan="1"></td></tr></tfoot></table>',
				Status__c = 'I',
				Ammount__c = 1000.00
			);

		
		
		LAT_Payment__c payGroup = LAT_ContractsWS_Test.getPaymentParent(con.Id);
		payGroup.ParentPayment__c = cv.id;
		payGroup.LAT_Contract__c = con.Id;

		

		System.debug('%%%. 0');
		List<LAT_Payment__c> toInsert = new List<LAT_Payment__c>();
		toInsert.add(cv);
		toInsert.add(pay);
		toInsert.add(payDinero);
		toInsert.add(payGroup);
		insert toInsert;
		System.debug('%%%. 0.5');


		payGroup = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
		   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
		   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,
		   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,Sku_at_Integration__c,
		   Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : payGroup.Id
		  ];

	 	cv = [SELECT(Select id,Sku_at_Integration__c,Finality__c,Status_IMM_Linea__c, ProductGroup__r.name, ProductGroup__c, Volumen__c, recordType.DeveloperName from Investimentos_Bonifica_es_e_Pagamentos__r),
		   LAT_Contract__r.account__r.Business_Unit__r.name, LAT_Contract__r.account__c, LAT_Contract__r.account__r.Revenue_City__r.name, LAT_Contract__r.account__r.Client_code_AN8__c, Ammount__c, ApprovedPayment__c, CNPJ_Fornecedor__c,
		   CreatedById, CreatedBy.email, CreatedDate, CurrencyIsoCode, Finality__c, GoalNotReached__c, Id, IDMe__c, integrationMessage__c, IntegrationStatus__c, IsDeleted, LastModifiedById, LastModifiedDate, LAT_Contract__c, LAT_Contract__r.name,
		   Manager__c, Name, ParentPayment__c, PaymentDateDone__c, FY__c, WF__c, WFNumber__c, PaymentDate__c, ProductGroup__c, RecordTypeId, RecordType.DeveloperName, RegionalManager__c, Status__c, SystemModstamp, Type__c, Volumen__c, ProductGroup__r.name,
		   Sku_at_Integration__c,Status_IMM_Linea__c, LAT_Contract__r.account__r.Regional__c FROM LAT_Payment__c where id = : cv.Id
		  ];

		System.debug('%%%. 1');
	  	LAT_Payment__c dinheropay = LAT_ContractsWS_Test.getPaymentDinhero(con.Id);

		//sent payment

		try{
			LAT_ContractPaymentsHandlerInterface.sendPaymentToMESync(dinheropay.Id);
		} catch (Exception e){}
		System.debug('%%%. 2');


		try{
			LAT_ContractPaymentsHandlerInterface.sendPaymentToMESync(payGroup.Id);
		} catch (Exception e){}
		System.debug('%%%. 3');

		try{
			LAT_ContractPaymentsHandlerInterface.sendPaymentToMESync(cv.Id);
		} catch (Exception e){}
		System.debug('%%%. 4');


		try{
			/// set paymentId in params
			RestRequest req = new RestRequest(); 
        	req.addParameter('paymentId', payGroup.Id);
			LAT_IMM_IntegrateService.updatePayment();
		} catch (Exception e) {}

		LAT_IMM_IntegrateService.getMockFreeGoodGroup();
		LAT_IMM_IntegrateService.getMocDinheroGroup();
		//

		//LAT_ContractPaymentsHandlerInterface.sendPaymentToME(payGroup.ParentPayment__c);
		//LAT_ContractPaymentsHandlerInterface.generateProductItems(new List<LAT_Payment__c>{pay});
		//LAT_ContractPaymentsHandlerInterface.processMoneyPayment(pay, 10000.00);
		//LAT_ContractPaymentsHandlerInterface.sendEmailNotification(pay);
		Test.stopTest();
	}
	
	@isTest static void FreeGoodiesGetReqParse() {
		String json=		'{'+
		'	"userLDAP": "JGOMES01",'+
		'	"idActivity": 1,'+
		'	"description": "Teste de Integración",'+
		'	"requestDate": "2017-10-19T18:06:28.000Z",'+
		'	"totalAmount": 200,'+
		'	"orderType": "SM",'+
		'	"phone": 551192223333,'+
		'	"contact": "Lionel Messi",'+
		'	"deliveryInstructions": "delivery Instructions",'+
		'	"indBoi": 0,'+
		'	"soldTo": {'+
		'       "id": 9968,'+
		'       "name": "CONDOMINIO SAO PAULO CORPORATE TOWERS",'+
		'       "internalClient": 0'+
		'	},'+
		'	"almacen": {'+
		'       "idAlmacen": "05",'+
		'       "name": "PR - SAO PAULO"'+
		'	},'+
		'	"conceptoGasto": {'+
		'       "idConceptoGasto": 18,'+
		'       "name": "Consumer & Shopper Insight & Analytics"'+
		'	},'+
		'	"shipTo": {'+
		'       "idAddress": 322,'+
		'       "cliente": "BAR CHARLES EDWARD PROM SHOWS MUSICAIS",'+
		'       "address1": "AV PRES JUSCELINO KUBITSCHEK",'+
		'       "address2": "ITAIM BIBI",'+
		'       "country": "BR",'+
		'       "state": "SAO PAULO",'+
		'       "city": "SP",'+
		'       "postalCode": "04543000"'+
		'	},'+
		'	"currency": {'+
		'       "idCurrency": 1,'+
		'       "name": "Brazil - Real",'+
		'       "code": "BRL"'+
		'	},'+
		'	"amount": 100,'+
		'	"status": {'+
		'       "idStatus": 5,'+
		'       "name": "C"'+
		'	},'+
		'	"skus": [{'+
		'		"sku": {'+
		'           "code": "6329",'+
		'           "description": "CHAMPAGNE PERRIER JOUET BELLEEPOQUE 2004 6X750ML"'+
		'		},'+
		'       "measureUnit": {'+
		'           "uniMed": "BT",'+
		'           "unitCost": 100'+
		'       },'+
		'       "requestedQuantity": 1,'+
		'       "totalCost": 100,'+
		'       "deliverDate": "2017-10-20T06:00:00.000Z"'+
		'       }, {'+
		'       "sku": {'+
		'           "code": "76162",'+
		'           "description": "GARRAFA VODKA WYBOROWA EXQUISITE 750ML"'+
		'       },'+
		'       "measureUnit": {'+
		'           "uniMed": "BT",'+
		'           "unitCost": 100'+
		'       },'+
		'       "requestedQuantity": 1,'+
		'       "totalCost": 100,'+
		'       "deliverDate": "2017-10-20T06:00:00.000Z"'+
		'       }'+
		'	]'+
		'}';

		LAT_BR_IMM_RestCallHandler.GenericBodyIMM gbm = new LAT_BR_IMM_RestCallHandler.GenericBodyIMM();

		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		System.debug(obj + '<<<<<<=');
		//System.assert(obj != null);
	}

	@isTest static void testParsePostFreeGoodiesResp() {
		String json=		'{'+
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
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		System.assert(obj != null);
	
	}

	@isTest static void FreeGoodiesRestResp() {
		String json=		'{';
		json +='    "id": 175,';
		json +='    "type": "CP",';
		json +='    "documentType": "CP",';
		json +='    "description": "Lorem Ipsum",';
		json +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
		json +='    "dateApproval": null,';
		json +='    "jdeStatus": "-",';
		json +='    "userName": "BSOUZA01 - Bruno Souza",';
		json +='    "login": "BSOUZA01",';
		json +='    "idErp": null,';
		json +='    "erpDocumentType": null,';
		json +='    "amount": 0,';
		json +='    "indBoi": 0,';
		json +='    "idAttachment": null,';
		json +='    "amountPending": 0,';
		json +='    "amountReceived": 0,';
		json +='    "dateAccount": null,';
		json +='    "accountBatchNumber": null,';
		json +='    "subarea": {';
		json +='        "idSubarea": 9';
		json +='    },';
		json +='    "status": {';
		json +='        "idStatus": 4,';
		json +='        "description": "CRIADO"';
		json +='    },';
		json +='    "activity": {';
		json +='        "idActivity": 1';
		json +='    },';
		json +='    "currency": {';
		json +='        "idCurrency": 1,';
		json +='        "exchangeRate": 1,';
		json +='        "currencyCode": "BRL",';
		json +='        "currencyName": "Brazil - Real"';
		json +='    },';
		json +='    "conceptoGasto": {';
		json +='        "idConceptoGasto": 207,';
		json +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
		json +='    },';
		json +='    "provider": {';
		json +='        "id": 51557,';
		json +='        "code": 16274,';
		json +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
		json +='    },';
		json +='    "almacen": {';
		json +='        "idAlmacen": 25,';
		json +='        "description": "Sao Paulo"';
		json +='    }';
		json +='}';
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		System.assert(obj != null);
	}

	@isTest static void testParseGetPaymentCashResp() {
		String json=		'{';
		json +='    "id": 175,';
		json +='    "type": "CP",';
		json +='    "documentType": "CP",';
		json +='    "description": "Lorem Ipsum",';
		json +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
		json +='    "dateApproval": null,';
		json +='    "jdeStatus": "-",';
		json +='    "userName": "BSOUZA01 - Bruno Souza",';
		json +='    "login": "BSOUZA01",';
		json +='    "idErp": null,';
		json +='    "erpDocumentType": null,';
		json +='    "amount": 0,';
		json +='    "indBoi": 0,';
		json +='    "idAttachment": null,';
		json +='    "amountPending": 0,';
		json +='    "amountReceived": 0,';
		json +='    "dateAccount": null,';
		json +='    "accountBatchNumber": null,';
		json +='    "subarea": {';
		json +='        "idSubarea": 9';
		json +='    },';
		json +='    "status": {';
		json +='        "idStatus": 4,';
		json +='        "description": "CRIADO"';
		json +='    },';
		json +='    "activity": {';
		json +='        "idActivity": 1';
		json +='    },';
		json +='    "currency": {';
		json +='        "idCurrency": 1,';
		json +='        "exchangeRate": 1,';
		json +='        "currencyCode": "BRL",';
		json +='        "currencyName": "Brazil - Real"';
		json +='    },';
		json +='    "conceptoGasto": {';
		json +='        "idConceptoGasto": 207,';
		json +='        "description": "SERVICO CRIACAO FOLHETOS SIMPLES POR PAGINA"';
		json +='    },';
		json +='    "provider": {';
		json +='        "id": 51557,';
		json +='        "code": 16274,';
		json +='        "providerName": "CIA BRASILEIRA DE DISTRIBUICAO"';
		json +='    },';
		json +='    "almacen": {';
		json +='        "idAlmacen": 25,';
		json +='        "description": "Sao Paulo"';
		json +='    }';
		json +='}';
		LAT_BR_IMM_RestCallHandler.GenericBodyIMM obj = (LAT_BR_IMM_RestCallHandler.GenericBodyIMM) System.JSON.deserialize(json, LAT_BR_IMM_RestCallHandler.GenericBodyIMM.class);
		System.assert(obj != null);
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

	public static void addIMMData(){
		LAT_IMM_Operations__c op = new LAT_IMM_Operations__c(EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', operation_Name_header__c ='GetFreeGood', Service_Name_Header__c='IMM', Name = 'GetFreeGood', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		LAT_IMM_Operations__c op2 = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'CreateCashPayment',operation_Name_header__c = 'CreateCashPayment', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		LAT_IMM_Operations__c op3 = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'GetCashPayment',operation_Name_header__c = 'GetCashPayment', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		LAT_IMM_Operations__c op4 = new LAT_IMM_Operations__c(userLDAP__c = 'BSOUZA01', idAlmacen__c = '40',Name = 'CreateAndSendFreeGood',operation_Name_header__c = 'CreateAndSendFreeGood', EndpointUrl__c='http://osbqa.pramericas.com/IMM/Proxy_Services/RestGenericCaller', Service_Name_Header__c='IMM', Http_operation__c='GET', x_Api_key__c='FzH%pH32dyPU*F3B');
		insert new List<LAT_IMM_Operations__c> {op,op2,op3,op4};

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
	        UseIMM__c = true
	    );
	    insert cred;

	}

	public static LAT_Contract2__c getContract() {


        UDC__c regional = new UDC__c(     
			Name = 'REG ON TRADE', 
            CodDefUsuario__c = '5',    
            CodProd__c     = '01',     
            CodUs__c     = '01',    
            Internal_Id__c   = '1-5-01-01',      
            RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard')     
        );
        
        insert regional;  

        insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
        Account a = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
		a.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+'LAT_Eventos_com_pagamento');
        a.Rating_segmentation_targert_market__c = 'STANDARD';
        a.Client_code_AN8__c = '123451236';
        a.Regional__C = regional.Id;
        a.LAT_BR_RegionalClientOnPremise__c = 'ON TRADE SPI';
		insert a;
		
		Account dist = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
		dist.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+'LAT_Distribucao_Com_Faturamento');
        dist.Rating_segmentation_targert_market__c = 'STANDARD';
        dist.Client_code_AN8__c = '123451231';
        dist.CNPJ__c = '01878718000148';
		dist.Regional__C = regional.Id;
        dist.LAT_BR_RegionalClientOnPremise__c = 'ON TRADE SPI';
        insert dist;
        LAT_Contract2__c con = new LAT_Contract2__c (
                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_OnTrade_CommercialConditionContract') ,
                Status__c = 'Novo Contrato',
				Account__c = a.Id,
				LAT_Distributor__c = dist.Id,
                StartDate__c = Date.today().addDays(-180),
                EndDate__C =  Date.today().addDays(180),
                ROI_Target__c = 12.0
            );
        return con;
	}
	*/
}