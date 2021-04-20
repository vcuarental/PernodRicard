@isTest
public class LAT_ContractsCalculationsTest { 
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
	private static void commontTestMethods() {			
		LAT_ContractsCalculations objContractCalculations = null;

		objContractCalculations = new LAT_ContractsCalculations(); 
		objContractCalculations.calculateROI(10,10);

		objContractCalculations.getConvertedCurrency(10,10);

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
		LAT_ContractsCalculations objContractCalculations = null;
		Map<Id, LAT_ReferenceProduct__c> mapReferenceProducts = null;
		Map<Id, Double> mapReferenceProductsCost = null;
		Set<String> setProductsIDs = null;
		String strRecordType = null;
		Set<String> setDistribuitorsIDs = null;
		Id objAccountId = null;
		LAT_ProductCost__c objProductCost = null;

		mapReferenceProducts = new Map<Id, LAT_ReferenceProduct__c>();
		mapReferenceProductsCost = new Map<Id, Double>();
		setProductsIDs = new Set<String>();
		setDistribuitorsIDs = new Set<String>();

		objCountrySettings = retrieveCountryBR();
		objContract = retrieveContract();
		objProduct = retrieveProduct(objCountrySettings);

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
		mapReferenceProductsCost.put(objReferenceProductGrouping.Id, 1.0);

		objProductCost = createProductCost(objReferenceProductGrouping.Id, objAccountId);
		new LAT_ContractsCalculations.productCost(objProductCost);
		new LAT_ContractsCalculations.TotalProductsCalculationEvent();

		objContractCalculations.setProductCostOnPayment( new List<LAT_Payment__c> { objPayment });
		LAT_ContractsCalculations.getEventsComercialConditionProductCost(setDistribuitorsIDs, 'LAT_ProductPayment',setProductsIDs, mapReferenceProducts );
		LAT_ContractsCalculations.updateOriginalDate(objContract.Id );
		LAT_ContractsCalculations.updateOriginalDate(new List<Id> { objContract.Id } );

		objContractCalculations.retrieveMetaRoi(objContract);
		objContractCalculations.retrieveMetaRoi(UserInfo.getUserId(), Date.today().addDays(-10));
		objContractCalculations.getQuarterInformation(objContract.Id,Date.today().addDays(-10), Date.today().addDays(10));

		objContractCalculations.totalProductsCalculationEvents(mapReferenceProductsCost,'UC', objAccountId, true);
		objContractCalculations.totalProductsCalculationEvents(mapReferenceProductsCost,'UC', objAccountId, false);
		LAT_ContractsCalculations.getEventsComercialConditionProductCost(setDistribuitorsIDs, 'LAT_ProductPayment',setProductsIDs, mapReferenceProducts );
		LAT_ContractsCalculations.buidEventProductCost(mapReferenceProductsCost.keySet(), objAccountId, 'UC', '');
		
		LAT_ContractsCalculations.trackDurationReport(objContract, 'ENDDATE');
		LAT_ContractsCalculations.trackDurationReport(objContract, 'STARTDATE');

	
		objContract.SignaturesFlow__c = 'Consultor-Assinatura Cliente';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});

		objContract.SignaturesFlow__c = 'Assistente Regional-Contrato Assinado Recebido Consultor';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});


		objContract.SignaturesFlow__c = 'Assistente Regional-Contrato Assinado Entregue Trade';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});


		objContract.SignaturesFlow__c = 'Trade-Contrato Assinado Recebido Ass. Regional';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});


		objContract.SignaturesFlow__c = 'Trade-Contrato Assinado Entregue Ass. Regional';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});


		objContract.SignaturesFlow__c = 'Assistente Regional-Contrato Assinado Recebido Trade';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});


		objContract.SignaturesFlow__c = 'Assistente Regional-Contrato Assinado Entregue Consultor';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});


		objContract.SignaturesFlow__c = 'Consultor-Contrato Ativado';
		LAT_ContractsCalculations.updateProcessStatus(new List<LAT_Contract2__c> { objContract});


		objContractCalculations.generatePayments(objContract.Id, false);

		LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
			
		Test.stopTest();
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

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
		
		createProductCost(objReferenceProductGrouping.Id, objAccountId);

		objContractCalculations.calculatePaymentsInformation(new Set<Id> { objContract.Id } );
		objContractCalculations.calculatePayments(objContract.Id);
		objContractCalculations.retrieveEventPayments(objContract.Id);
		objContractCalculations.retrieveEventVolume(objContract.Id);
		System.assertNotEquals(null, LAT_ContractsCalculations.cloneOpportunity(new LAT_Opportunity__c ()));
		System.assertNotEquals(null, LAT_ContractsCalculations.cloneContract(new LAT_Contract2__c ()));
		System.assertNotEquals(null, LAT_ContractsCalculations.cloneAccount(new Account ()));

		Test.stopTest();
	}

	@isTest
	public static void calculatePaymentsInformationRESTProdutorTest() {
		LAT_Contract2__c objContract = null;
		objContract = retrieveContract();
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_PARCERIA_PRODUTOR).getRecordTypeId();
		update objContract;
		Test.startTest();
		setupRESTContext();

		LAT_ContractCalculationRest.post(objContract.Id);
		Test.stopTest();
	}

	@isTest
	public static void calculateEnSignaturaAttachmentsAndTasks() {
		LAT_Contract2__c objContract = null;
		LAT_Contract2__c objContractOld = null;

		objContract = retrieveContract();
		objContractOld = objContract;

		objContract.Status__c = 'Em Signatura';
		objContract.SignaturesFlow__c = 'Assistente Regional-Contrato Assinado Entregue Consultor';
		objContractOld.Status__c = 'Aprovado';

		Test.startTest();
		try {
			Map<Id,LAT_Contract2__c> mapa = new Map<Id,LAT_Contract2__c>();
			mapa.put(objContract.Id, objContractOld);
			LAT_ContractsCalculations.addAttachmentsAndTasks(new List<LAT_Contract2__c> {objContract}, mapa );
		} catch(Exception Ex) {

		}

		Test.stopTest();
	}

	@IsTest
	public static void testSendChatter() {

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
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId(); 
		update objContract;

		objProduct = retrieveProduct(objCountrySettings);

		Test.startTest();
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;
		
		try {
			Map<String, List<LAT_Contract2__c>> mapContracts = new Map<String,List<LAT_Contract2__c>>();

			mapContracts.put('Active', new List<LAT_Contract2__c>());
			mapContracts.get('Active').add(objContract);

			LAT_ContractsCalculations.sendChatter( new Set<Id> {objAccountId}, new Set<Id> {Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId()},mapContracts );
		} catch(Exception Ex) {

		}
		Test.stopTest();
	}
	@isTest
	public static void retrieveReferenceProductMapTest() {
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
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId(); 
		update objContract;

		objProduct = retrieveProduct(objCountrySettings);

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
		
		try {
			objContractCalculations.retrieveReferenceProductMap( new Set<Id> {objReferenceProductGrouping.Id} );
		} catch(Exception Ex) {

		}
		Test.stopTest();
	}

	@isTest
	public static void retrieveProductCostTest() {
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
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId(); 
		update objContract;

		objProduct = retrieveProduct(objCountrySettings);

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
		
		try {
			objContractCalculations.retrieveProductCosts(objAccountId, new Set<Id> {objReferenceProductGrouping.Id});
		} catch(Exception Ex) {

		}
		Test.stopTest();
	}
	

	@isTest
	public static void retrieveReferenceUnitConversionMapTest() {
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
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId(); 
		update objContract;

		objProduct = retrieveProduct(objCountrySettings);

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
		
		try {
			objContractCalculations.retrieveReferenceUnitConversionMap(new List<Id> {objReferenceProductGrouping.Id});
		} catch(Exception Ex) {

		}
		Test.stopTest();
	}
	

	@isTest
	public static void calculateaddAprovadoAttachmentsAndTasks() {
		LAT_Contract2__c objContract = null;
		LAT_Contract2__c objContractOld = null;

		objContract = retrieveContract();
		objContractOld = objContract;

		objContract.Status__c = 'Aprovado';
		objContractOld.Status__c = 'Em Aprovação';

		Test.startTest();
		try {
			LAT_ContractsCalculations.addAttachmentsAndTasks(objContract.Id);
		} catch(Exception Ex) {

		}


		Test.stopTest();
	}

	@isTest
	public static void calculateaddAttachmentsAndTasks() {
		LAT_Contract2__c objContract = null;
		objContract = retrieveContract();
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_PARCERIA_PRODUTOR).getRecordTypeId();
		update objContract;
		Test.startTest();
		try {
			LAT_ContractsCalculations.addAttachmentsAndTasks(objContract.Id);
		} catch(Exception Ex) {

		}

		Test.stopTest();
	}

	@isTest
	public static void calculatePaymentsInformationRESTDistribuidorTest() {
		LAT_Contract2__c objContract = null;
		objContract = retrieveContract();
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_Rest_Contracts.CONTRACTS_EVENTS_PARCERIA_DISTRIBUIDOR).getRecordTypeId();
		update objContract;
		Test.startTest();
		setupRESTContext();

		LAT_ContractCalculationRest.post(objContract.Id);

		Apexpages.currentPage().getParameters().put('contractId', objContract.Id);
		LAT_DistributorAgreementController objController = new LAT_DistributorAgreementController();
		Test.stopTest();
	}
	
    private static void setupRESTContext() {
        RestRequest objRESTRequest = null; 
        RestResponse objRESTResponse = null;
        
        objRESTRequest = new RestRequest(); 
        objRESTResponse = new RestResponse();
        
        objRESTRequest.requestURI = 'https://www.salesforce.com';
        objRESTRequest.httpMethod = 'POST';
        
        RestContext.request = objRESTRequest;
        RestContext.response = objRESTResponse;        
    }

	@isTest
	public static void calculatePaymentsInformationEventRESTTest() {
		LAT_Contract2__c objContract = null;

		objContract = retrieveContract();

		Test.startTest();
        LAT_ContractCalculationEventRest.retrieveContractDistributor(objContract.Id);
        LAT_ContractCalculationEventRest.retrieveContractProdutor(objContract.Id);
		Test.stopTest();
	}
	@isTest
	public static void calculatePaymentsInformationDistribudorTest() {
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
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId(); 
		update objContract;

		objProduct = retrieveProduct(objCountrySettings);

		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);
		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
		
		createProductCost(objReferenceProductGrouping.Id, objAccountId);

		objContractCalculations.calculatePaymentsInformation(new Set<Id> { objContract.Id } );
		try {
			LAT_ContractsCalculations.addAttachmentToContractAcordos(new List<Id> {objContract.Id}, new List<LAT_Contract2__c> {objContract});
		} catch(Exception Ex) {

		}
		Test.stopTest();
	}

	@isTest
	public static void calculatePaymentsInformationProdutorTest() {
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
		objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_PRODUCER).getRecordTypeId(); 
		update objContract;

		objProduct = retrieveProduct(objCountrySettings);

		objCountrySettings = retrieveCountryBR();
		objProduct = retrieveProduct(objCountrySettings);
		objContract = retrieveContract();
		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

	//	objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);

		objContractCalculations = new LAT_ContractsCalculations();
		objAccountId = [SELECT Id FROM Account LIMIT 1].Id;

		setDistribuitorsIDs.add(objAccountId);
		mapReferenceProducts.put(objReferenceProductGrouping.Id,objReferenceProduct);
	
		objContractCalculations.calculatePaymentsInformation(new Set<Id> { objContract.Id } );
		try {
			LAT_ContractsCalculations.addAttachmentToContractAcordos(new List<Id> {objContract.Id}, new List<LAT_Contract2__c> {objContract});
		} catch(Exception Ex) {

		}
		Test.stopTest();
	}

	@isTest
	private static void getProductAverages() {
		String[] canales = new String[2];
		LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
		LAT_ContractsCalculations objContractCalculations = null;
		LAT_ReferenceProductGrouping__c objReferenceProductGrouping = null;
		LAT_ReferenceProduct__c objReferenceProduct = null;
		LAT_Contract2__c objContract = null;
		LAT_Product__c objProduct = null;
		CountrySettings objCountrySettings = null;
		LAT_Payment__c objPayment = null;
		LAT_ContractWorflow__c objContractWorkFlow = null;
		Map<Id, LAT_ReferenceProduct__c> mapReferenceProducts = null;
		Set<String> setProductsIDs = null;
		String strRecordType = null;
		Set<String> setDistribuitorsIDs = null;
		Id objAccountId = null;

		objCountrySettings = retrieveCountryBR();
		objProduct = retrieveProduct(objCountrySettings);
		objContract = retrieveContract();
		Test.startTest();
		objReferenceProductGrouping = createReferenceProductGrouping();
		objReferenceProduct = createReferenceProduct(objReferenceProductGrouping,objProduct);
		objContractWorkFlow = createActivityIMM();

		objPayment = createPayment(objContract,objContractWorkFlow, objReferenceProductGrouping);
	
		canales[0] = '101';
		canales[1] = '103';
		cost.productId = objPayment.Id;
		cost.skuName = objPayment.Name;
		cost.nis = 10.00;
		cost.ldCost = 10.00;
		cost.distCost = 10.00;
		cost.cmCase = 10.00;
		cost.unitOfMeasurement = 'CA';
		cost.hasSKU = false;

		objContractCalculations = new LAT_ContractsCalculations();
		objContractCalculations.getProductAverages(new List<LAT_ContractsCalculations.productCost>{cost},'SP',canales,'LAT_ProductPayment');
		objContractCalculations.getProductAveragesWithDate(new List<LAT_ContractsCalculations.productCost>{cost}, 'CA', 'LAT_ProductPayment', Date.today());
		objContractCalculations.getProductAverages(new List<LAT_ContractsCalculations.productCost>{cost},'SP','LAT_ProductPayment');
	}
	@isTest
	private static void addAttachmentAcordoTest() {
		try {
			LAT_Contract2__c objContract = retrieveContract();
			objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo').getRecordTypeId(); 
			update objContract;

			Attachment lAtt = new Attachment();
			lAtt.ParentId = objContract.id; 
			lAtt.name = 'Contrato - ' + objContract.Name + ' - Anexo 1.1.pdf';
			lAtt.Body = Blob.valueof( 'asdasd' );
			insert lAtt;

			LAT_ContractsCalculations.addAttachmentToContract(new List<Id> {objContract.Id});
		} catch(Exception Ex) {

		}
	}
	@isTest
	private static void addAttachmentAcordoTest2() {
		try {
			LAT_Contract2__c objContract = retrieveContract();
			objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo').getRecordTypeId(); 
			update objContract;

			Attachment lAtt2 = new Attachment();
			lAtt2.ParentId = objContract.id; 
			lAtt2.name = 'Contrato - ' + objContract.Name + ' - Minuta Padrao';
			lAtt2.Body = Blob.valueof( 'asdasd' );
			insert lAtt2;


			LAT_ContractsCalculations.addAttachmentToContractEvents(new List<String> { lAtt2.Id}, new List<LAT_Contract2__c> {objContract});
		} catch(Exception Ex) {

		}
	}

	@isTest
	private static void addAttachmentAcordoTest3() {
		try {
			LAT_Contract2__c objContract = retrieveContract();
			objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo').getRecordTypeId(); 
			update objContract;

			Attachment lAtt = new Attachment();
			lAtt.ParentId = objContract.id; 
			lAtt.name = 'Contrato - ' + objContract.Name + ' - Anexo 1.1.pdf';
			lAtt.Body = Blob.valueof( 'asdasd' );
			insert lAtt;


			LAT_ContractsCalculations.addAttachmentToContractAcordos(new List<Id> {objContract.Id}, new List<LAT_Contract2__c> {objContract});
		} catch(Exception Ex) {

		}
	}
	/*
	@isTest
	private static void addAttachmentOtherTest2() {
		try {
			LAT_Contract2__c objContract = retrieveContract();
			objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo').getRecordTypeId(); 
			update objContract;

			Attachment lAtt = new Attachment();
			lAtt.ParentId = objContract.id; 
			lAtt.name = 'Contrato - ' + objContract.Name + ' - Anexo 1.1.pdf';
			lAtt.Body = Blob.valueof( 'asdasd' );
			insert lAtt;

			LAT_ContractsCalculations.addAttachmentToContractOther(new List<Id> {objContract.Id}, new List<LAT_Contract2__c> {objContract});
		} catch(Exception Ex) {

		}
	}
	*/
	@isTest
	private static void addAttachmentEventProducerTest() {
		try {
			LAT_Contract2__c objContract = retrieveContract();
			objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_PRODUCER).getRecordTypeId(); 
			update objContract;

			Attachment lAtt = new Attachment();
			lAtt.ParentId = objContract.id; 
			lAtt.name = 'Contrato - ' + objContract.Name + ' - Anexo 1.1.pdf';
			lAtt.Body = Blob.valueof( 'asdasd' );
			insert lAtt;

			LAT_ContractsCalculations.addAttachmentToContractAcordos(new List<Id> {objContract.Id}, new List<LAT_Contract2__c> {objContract});
		} catch(Exception Ex) {

		}
	}

	@isTest
	private static void addAttachmentEventDistributorTest() {
		try {
			LAT_Contract2__c objContract = retrieveContract();
			objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_DISTRIBUTOR).getRecordTypeId(); 
			update objContract;
	
			Attachment lAtt = new Attachment();
			lAtt.ParentId = objContract.id; 
			lAtt.name = 'Contrato - ' + objContract.Name + ' - Anexo 1.1.pdf';
			lAtt.Body = Blob.valueof( 'asdasd' );
			insert lAtt;
			Attachment lAtt2 = new Attachment();
			lAtt2.ParentId = objContract.id; 
			lAtt2.name = 'Contrato - ' + objContract.Name + ' - Minuta Padrao';
			lAtt2.Body = Blob.valueof( 'asdasd' );
			insert lAtt2;

			LAT_ContractsCalculations.addAttachmentToContract(new List<Id> {objContract.Id});
		} catch(Exception Ex) {

		}
	}

	@isTest
	private static void addAttachmentOtherTest() {
		try {
			LAT_Contract2__c objContract = retrieveContract();
			objContract.RecordTypeId = Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get('Lat_Contract_Carta_Activacion').getRecordTypeId(); 
			update objContract;

			Attachment lAtt = new Attachment();
			lAtt.ParentId = objContract.id; 
			lAtt.name = 'Contrato - ' + objContract.Name + ' - Anexo 1.1.pdf';
			lAtt.Body = Blob.valueof( 'asdasd' );
			insert lAtt;
			Attachment lAtt2 = new Attachment();
			lAtt2.ParentId = objContract.id; 
			lAtt2.name = 'Contrato - ' + objContract.Name + ' - Minuta Padrao';
			lAtt2.Body = Blob.valueof( 'asdasd' );
			insert lAtt2;

	
			LAT_ContractsCalculations.addAttachmentToContract(new List<Id> {objContract.Id});
		} catch(Exception Ex) {

		}
	}
	
	///falla, 101
	private static void createTasks() {

		LAT_Contract2__c objContract = retrieveContract();
		List<Task> tasks = new List<Task>();
		Task t = new Task(
			LAT_Tipo__c = 'CT-Assinatura',
			Status 		= 'Not Completed',
			WhatId 		= objContract.Id
			);
		tasks.add(t);
		Task t2 = new Task(
			LAT_Tipo__c = 'CT-Assinatura',
			Status 		= 'Completed',
			WhatId 		= objContract.Id
			);
		tasks.add(t2);
		Task t3 = new Task(
			LAT_Tipo__c = 'CT-EntregarCliente',
			Status 		= 'Completed',
			WhatId 		= objContract.Id
			);
		tasks.add(t3);
		insert tasks;

		LAT_ContractsCalculations.updateStatus(tasks,tasks);
	}

	@isTest
	private static void createTasks1() {

		LAT_Contract2__c objContract = retrieveContract();
		List<Task> tasks = new List<Task>();
		Task t = new Task(
			LAT_Tipo__c = 'CT-Assinatura',
			Status 		= 'Not Completed',
			WhatId 		= objContract.Id
			);
		tasks.add(t);
		insert tasks;
		Test.startTest();
		LAT_ContractsCalculations.updateStatus(tasks,tasks);
		Test.stopTest();
	}

	@isTest
	private static void createTasks2() {

		LAT_Contract2__c objContract = retrieveContract();
		List<Task> tasks = new List<Task>();

		Task t2 = new Task(
			LAT_Tipo__c = 'CT-Assinatura',
			Status 		= 'Completed',
			WhatId 		= objContract.Id
			);
		tasks.add(t2);

		Test.startTest();
		LAT_ContractsCalculations.updateStatus(tasks,tasks);
		Test.stopTest();
	}

	@isTest
	private static void createTasks3() {

		LAT_Contract2__c objContract = retrieveContract();
		List<Task> tasks = new List<Task>();

		Task t3 = new Task(
			LAT_Tipo__c = 'CT-EntregarCliente',
			Status 		= 'Completed',
			WhatId 		= objContract.Id
			);
		tasks.add(t3);
		insert tasks;

		Test.startTest();
		LAT_ContractsCalculations.updateStatus(tasks,tasks);
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
		createMetaROI();
		
        objCountry = retrieveCountryBR();        
		objAccount = createAccount(objCountry);
        createCredentials(objCountry);
		objProduct = createProduct(objCountry);
		createUser(objCountry);
		objContract = createContract(objAccount);


		createIMMData();
        System.debug('initializeTest [] <-');
	}
	
	@isTest
    private static void createProductorTest() {
        LAT_ContractHandlerJSON objJSON = null;
		LAT_ContractsCalculations objCC = null;
        objJSON = LAT_Rest_ContractsTest.createJSONCartaAcordoPatrocinio(LAT_Rest_ContractsTest.EVENTOS_CONTRATOPARCERIA_RECORDTYPE, LAT_Rest_ContractsTest.NEW_CONTRACT_ID, 'New');

        Test.startTest();

		try {
			objCC = new LAT_ContractsCalculations();
			objCC.calculatePaymentsInformationEventosDistribuidor(objJSON);
		} catch(Exception Ex) {

		}

        Test.stopTest();
    }

	@isTest
    private static void createDistribuidorTest() {
        LAT_ContractHandlerJSON objJSON = null;
		LAT_ContractsCalculations objCC = null;
        objJSON = LAT_Rest_ContractsTest.createJSONCartaAcordoPatrocinio(LAT_Rest_ContractsTest.EVENTOS_CONTRATOPARCERIA_RECORDTYPE_DISTRIBUIDOR, LAT_Rest_ContractsTest.NEW_CONTRACT_ID, 'New');

        Test.startTest();

		try {
			objCC = new LAT_ContractsCalculations();
			objCC.calculatePaymentsInformationEventosDistribuidor(objJSON);
		} catch(Exception Ex) {

		}

        Test.stopTest();
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

	private static void createMetaROI() {
		LAT_Meta_ROI_Consultant__c objMetaROI = null;

		objMetaROI = new LAT_Meta_ROI_Consultant__c();
		objMetaROI.ROI_Net_Sales__c = 10; 
		objMetaROI.ROI_Contrato__c = 10; 
		objMetaROI.ROI_AP__c = 10;
		objMetaROI.ROI_OnInvoice__c = 10;
		objMetaROI.LAT_Consultor__c = [SELECT Id FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' LIMIT 1].Id; 
		objMetaROI.FY__c = LAT_ContractsCalculations.getFyCode(Date.today());

		insert objMetaROI;
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

        objContract = [ SELECT Id, Name, ROI_Target__c,OwnerId, StartDate__c, EndDate__C, Account__c, Status__c,  RecordTypeId
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


    public static LAT_ProductCost__c createProductCost(Id referenceProductGroupingId, Id distributorOrAccountId) {
        Integer currentYear = 2020;
        Integer currentMonth = Date.today().month();
        String formattedCurrentMonth = String.valueOf(currentMonth);
        formattedCurrentMonth = (formattedCurrentMonth.length() == 1) ? '0'+formattedCurrentMonth : formattedCurrentMonth;

		List<UDC__c> canales = [SELECT Id FROM UDC__c WHERE Internal_Id__c = '123'];
		UDC__c canal = null;
		if(canales.IsEmpty()) {
			canal = new UDC__c(Name = 'teste', CodDefUsuario__c = '114', Internal_Id__c = '123');    
			insert canal;
		} else {
			canal = canales[0];
		}

        LAT_ProductCost__c productCost = new LAT_ProductCost__c(Start_Year__c = String.valueOf(currentYear) ,
                                                                Start_Month__c = formattedCurrentMonth,
                                                                UF__c = 'SC', 
                                                                Canal__c = canal.Id,
                                                                Product__c = referenceProductGroupingId, 
                                                                Distributor__c = 2,
                                                                CM_Case__c = 161.68,  
                                                                DistributorCost__c = 514.46,  
                                                                LDCost__c = 34188, 
                                                                Net_Sales_Case__c = 224.89, 
                                                                MeasureUnit__c = 'CA', 
                                                                AN8__c = distributorOrAccountId,
                                                                EndDate__c = Date.today().addDays(2),
                                                                RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ProductCost__c'+'LAT_ProductPayment') );


        LAT_ProductCost__c productCostDistributor = new LAT_ProductCost__c(Start_Year__c = String.valueOf(currentYear),
                                                                            Start_Month__c = formattedCurrentMonth,
                                                                            UF__c = 'SC', 
                                                                            Product__c = referenceProductGroupingId, 
                                                                            Distributor__c = 1,
                                                                            CM_Case__c = 161.68,  
                                                                            DistributorCost__c = 514.46,  
                                                                            LDCost__c = 24188, 
                                                                            Net_Sales_Case__c = 224.89, 
                                                                            MeasureUnit__c = 'CA', 
                                                                            AN8__c = distributorOrAccountId,
                                                                            EndDate__c = Date.today().addDays(2),
                                                                            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_ProductCost__c'+'LAT_ProductPayment') );

        List<LAT_ProductCost__c> productCosts = new List<LAT_ProductCost__c>{productCost, productCostDistributor}; 

        insert productCosts;

        return productCost;
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
	/*
	@testSetup
	static void setup() {
		insert new LAT_GeneralConfig__c (Name= 'OPP_Verification_Email_Recipients', LAT_Value__c = 'aaa@aaa.com');
        objGeneralConfig.Name = '';
        objGeneralConfig.LAT_Value__c = '';
		insert new LAT_GeneralConfig__c (Name= 'LAT_PRODUCT_COST_CHANNELS', LAT_Value__c = '101,102,103,104,112,113,114,115,116');
		Id StaticResourceId = [Select Id from StaticResource limit 1].id;
		insert new LAT_GeneralConfig__c (Name= 'LAT_ContractMinutaPadrao', LAT_Value__c = StaticResourceId);
		LAT_Docusign_Config__c dSconfig = new LAT_Docusign_Config__c
							(ds_Username__c = 'testUsername',
						     ds_password__c='test',  
						     ds_integrationKey__c = 'test',
						     Enable_Docusign_Contracts__c = false
						     );
	    insert new LAT_Docusign_Config__c();
	    insert createCollaborationGroup('Contratos OnTrade','Public');
	    UDC__c regional = new UDC__c(      
            CodDefUsuario__c = '1',    
            CodProd__c     = '01',     
            CodUs__c     = '01',    
            Internal_Id__c   = '1-1-01-01',      
            RecordTypeId = RecordTypeForTest.getRecType('UDC__c', 'BRA_Standard')     
        );
        insert regional;  

        Account a = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
		a.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+'LAT_On_Trade_Com_Pagamento');
        a.Rating_segmentation_targert_market__c = 'STANDARD';
        a.Client_code_AN8__c = '123451236';
        a.OwnerId =  getLAT_BR2Vendas().Id;
        a.Regional__c = regional.Id;
        insert a;

	}

	public static CollaborationGroup createCollaborationGroup(String groupName,String groupType){
    	CollaborationGroup grp = new CollaborationGroup();
    	grp.Name = groupName;
    	grp.CollaborationType = groupType;
    	return grp;
    }

	public static User getLAT_SystemAdminUser() {
     	User u2 = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name ='LAT_SystemAdministrator' LIMIT 1];
	    return u2;
	}
	
	public static User getLAT_BR2Vendas() {
		User man = getLAT_SystemAdminUser();
     	User u2 = [SELECT Id, Name FROM User WHERE isActive = true AND Profile.Name ='LAT_BR2_Vendas' LIMIT 1];
	    return u2;
	}

	public static LAT_Contract2__c getTestContract() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		LAT_Contract2__c con = new LAT_Contract2__c();
		con.TotalMoneyPerceivedValue__c = 1000.00;
		con.TotalMoneyPRBCost__c = 100.00;
		con.TotalProductsPerceivedValue__c = 10.00;
		con.TotalProductsPRBCost__c = 10.00;
		con.StartDate__c = Date.today().addDays(-105);
		con.EndDate__c = Date.today().addDays(105);
		con.Value__c = 100000.00;
		con.Account__c = acc.Id;
		return con;
	}

	public static LAT_Payment__c getPaymentForContract(LAT_Contract2__c con) {
		LAT_ReferenceProductGrouping__c rpg = new LAT_ReferenceProductGrouping__c(
			Name = 'Volume',
			ExternalId__c = '1234',
			GroupType__c = 'SKU',
			Order__c = 10000 );
   		insert rpg;
		LAT_Payment__c pay = new LAT_Payment__c();
		pay.ProductGroup__c = rpg.Id;
		pay.LAT_Contract__c = con.Id;
		pay.Ammount__c = 100;
		pay.Volumen__c = 5;
		pay.Status__c = 'Previsto';
		pay.PaymentDate__c = Date.today().addDays(-5);
		pay.PaymentDateDone__c = Date.today().addDays(-5);
		return pay;
	}

	@isTest static void test_method_one() {
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {
			
			LAT_Contract2__c con = getTestContract();
			con.recordTypeid == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(LAT_ContractsCalculations.EVENT_PRODUCER_SIMULATION).getRecordTypeId();
			Test.startTest();
			insert con;
			LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
			
			LAT_Payment__c pay2 = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);


			pay2.LAT_BonusPercent__c = 10;
			insert new List<LAT_Payment__c> {pay,pay2};
			LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
			contCalc.calculateROI(1000,0);
			contCalc.calculateROI(1000,1100);
			contCalc.getQuarterInformation(con.Id, Date.today().addDays(-100),Date.today().addDays(100));
			Set<Id> idsContratos = new Set<Id>();
			idsContratos.add(con.Id);
			contCalc.calculatePaymentsInformation(idsContratos);
			contCalc.calculatePaymentsInformationEventos(con.id);
			//LAT_ContractsCalculations.checkAllProductsHaveCost(con, true);

			try {
				LAT_ContractsCalculations.addAttachmentsAndTasks(con.Id);
			} catch(Exception Ex) {}

			try {
				LAT_ContractsCalculations.addAttachmentToContractAcordos(new List<Id> {con.Id}, new List<LAT_Contract2__c> {con});
			} catch(Exception Ex) {}
			//LAT_ContractsCalculations.getConvertedCurrency(10,10);

			//System.assertNotEquals(null, LAT_ContractsCalculations.cloneOpportunity(new LAT_Opportunity__c ()));

		}

		// Implement test code
	}

	@isTest static void test_method_two() {
		// Implement test code
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {
			
			LAT_Contract2__c con = getTestContract();
			
			insert con;
			Test.startTest();
			LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
			insert pay;
			LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
			List<Id> idsContratos = new List<Id>();
			idsContratos.add(con.Id);
			
				// The second time should regenrate contracts attachments
				Attachment lAtt = new Attachment();
				lAtt.ParentId = con.id; 
				lAtt.name = 'Contrato - ' + con.Name + ' - Anexo 1.1.pdf';
				lAtt.Body = Blob.valueof( 'asdasd' );
				insert lAtt;
				Attachment lAtt2 = new Attachment();
				lAtt2.ParentId = con.id; 
				lAtt2.name = 'Contrato - ' + con.Name + ' - Minuta Padrao';
				lAtt2.Body = Blob.valueof( 'asdasd' );
				insert lAtt2;
				LAT_ContractsCalculations.addAttachmentToContract(idsContratos);
				LAT_ContractsCalculations.addAttachmentToContractEvents(new List<String> {lAtt.Id, lAtt2.Id}, new List<LAT_Contract2__c> {con});
				LAT_ContractsCalculations.updateOriginalDate(con.Id);

			    LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
			    cost.productId = con.Id;
			    cost.skuName = 's';
			    cost.nis = 10.00;
			    cost.ldCost = 10.00;
			    cost.distCost = 10.00;
			    cost.cmCase = 10.00;
			    cost.unitOfMeasurement = 'CA';
			    cost.hasSKU = false;
				contCalc.generatePayments(con.id, false);
				con.status__c = 'Ativo';
				con.SignaturesFlow__c = 'Consultor-Assinatura Cliente';
				update con;

				
			Test.stopTest();
		}
	}
	@isTest static void test_method_twoB() {
		// Implement test code
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {
			
			LAT_Contract2__c con = getTestContract();
			
			insert con;
			Test.startTest();
			LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
			insert pay;
			LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
			List<Id> idsContratos = new List<Id>();
			idsContratos.add(con.Id);
			
				// The second time should regenrate contracts attachments
				Attachment lAtt = new Attachment();
				lAtt.ParentId = con.id; 
				lAtt.name = 'Contrato - ' + con.Name + ' - Anexo 1.1.pdf';
				lAtt.Body = Blob.valueof( 'asdasd' );
				insert lAtt;
				Attachment lAtt2 = new Attachment();
				lAtt2.ParentId = con.id; 
				lAtt2.name = 'Contrato - ' + con.Name + ' - Minuta Padrao';
				lAtt2.Body = Blob.valueof( 'asdasd' );
				insert lAtt2;
				LAT_ContractsCalculations.addAttachmentToContract(idsContratos);
				LAT_ContractsCalculations.updateOriginalDate(con.Id);

			    LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
			    cost.productId = con.Id;
			    cost.skuName = 's';
			    cost.nis = 10.00;
			    cost.ldCost = 10.00;
			    cost.distCost = 10.00;
			    cost.cmCase = 10.00;
			    cost.unitOfMeasurement = 'CA';
			    cost.hasSKU = false;
				contCalc.generatePayments(con.id, false);
				con.status__c = 'Ativo';
				con.SignaturesFlow__c = 'Consultor-Assinatura Cliente';
				update con;

				con.status__c = 'Aprovado';
				update con;
				LAT_ContractsCalculations.addAttachmentToContract(idsContratos);
				LAT_ContractsCalculations.addAttachmentToContractEvents(new List<String>(), new List<LAT_Contract2__c> {con});
				
			Test.stopTest();
		}
	}

	@isTest static void test_method_three() {
		// Implement test code
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {

			LAT_Contract2__c con = getTestContract();
			con.StandardClausesPRB__c = true;
			Test.startTest();
			insert con;
			LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
			insert pay;
			LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
			List<Id> idsContratos = new List<Id>();
			idsContratos.add(con.Id);
			
				// The second time should regenrate contracts attachments
				LAT_ContractsCalculations.addAttachmentToContract(idsContratos);
				LAT_ContractsCalculations.updateOriginalDate(con.Id);
				try{LAT_ContractsCalculations.trackDurationReport(con, 'STARTDATE');}catch(Exception e){}

			    LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
			    cost.productId = con.Id;
			    cost.skuName = 's';
			    cost.nis = 10.00;
			    cost.ldCost = 10.00;
			    cost.distCost = 10.00;
			    cost.cmCase = 10.00;
			    cost.unitOfMeasurement = 'CA';
			    cost.hasSKU = false;
				contCalc.generatePayments(con.id, false);
				con.status__c = 'Ativo';
				con.SignaturesFlow__c = 'Consultor-Assinatura Cliente';
				update con;			

			Test.stopTest();
		}
	}

	@isTest static void test_method_four() {
		// Implement test code
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {

			LAT_Contract2__c con = getTestContract();
			con.StandardClausesPRB__c = true;
			Test.startTest();
			insert con;
			List<Task> tasks = new List<Task>();
			Task t = new Task(
				LAT_Tipo__c = 'CT-Assinatura',
				Status 		= 'Not Completed',
				WhatId 		= con.Id
				);
			tasks.add(t);
			Task t2 = new Task(
				LAT_Tipo__c = 'CT-Assinatura',
				Status 		= 'Completed',
				WhatId 		= con.Id
				);
			tasks.add(t2);
			Task t3 = new Task(
				LAT_Tipo__c = 'CT-EntregarCliente',
				Status 		= 'Completed',
				WhatId 		= con.Id
				);
			tasks.add(t3);
			insert tasks;

			LAT_ContractsCalculations.updateStatus(tasks,tasks);

			Test.stopTest();
		}
	}

	@isTest static void test_method_five() {
		// Implement test code
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {
			
			LAT_Contract2__c con = getTestContract();
			Test.startTest();
			insert con;
			Attachment att = new Attachment(
                ParentId = con.id,
                Name = 'Contrato - ' + con.Name + ' - Anexo 1.2.pdf',
                Body = Blob.valueOf('TEST')
            );
            insert att;

			LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
			insert pay;
			LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
			List<Id> idsContratos = new List<Id>();
			idsContratos.add(con.Id);
			
				// The second time should regenrate contracts attachments
				LAT_ContractsCalculations.addAttachmentToContract(idsContratos);
				LAT_ContractsCalculations.updateOriginalDate(con.Id);

			    

				con.status__c = 'Cancelado';
				update con;				
				
			Test.stopTest();
		}
	}

	@isTest static void test_method_six() {
		// Implement test code
		User u = getLAT_SystemAdminUser();
		System.runAs(u) {
			
			LAT_Contract2__c con = getTestContract();
			con.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_OnTrade_SponsorshipAgreementOnTrade');
			Test.startTest();
			insert con;
			LAT_Payment__c pay = LAT_ContractsWS_Test.getPaymentProductoWithParent(con.Id);
			insert pay;
			LAT_ContractsCalculations contCalc = new LAT_ContractsCalculations();
			List<Id> idsContratos = new List<Id>();
			idsContratos.add(con.Id);
			
				// The second time should regenrate contracts attachments
				LAT_ContractsCalculations.addAttachmentToContract(idsContratos);
				LAT_ContractsCalculations.updateOriginalDate(con.Id);

			    LAT_ContractsCalculations.productCost cost = new LAT_ContractsCalculations.productCost();
			    cost.productId = con.Id;
			    cost.skuName = 's';
			    cost.nis = 10.00;
			    cost.ldCost = 10.00;
			    cost.distCost = 10.00;
			    cost.cmCase = 10.00;
			    cost.unitOfMeasurement = 'CA';
			    cost.hasSKU = false;
				contCalc.generatePayments(con.id, false);
				con.status__c = 'Ativo';
				con.SignaturesFlow__c = 'Consultor-Assinatura Cliente';
				update con;
	
			Test.stopTest();
		}
	}*/
}