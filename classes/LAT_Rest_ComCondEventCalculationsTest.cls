/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_Rest_ComCondEventCalculationsTest {
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
    private static void restComCondEventTest() {
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
        Id objPaymentRecordTypeId = null;
        String strJSON = null;

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
		
		LAT_ContractsCalculationsTest.createProductCost(objReferenceProductGrouping.Id, objAccountId);
        objPaymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');

        strJSON = getContractStringBody(objPaymentRecordTypeId, objReferenceProductGrouping.Id, objContract.Id, objAccountId);
        RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'http://salesforce.com/LAT_Rest_ComCondEventCalculations';
        RestContext.request.requestBody = Blob.valueOf(strJSON);
        RestContext.response = new RestResponse();
        try {
            LAT_Rest_ComCondEventCalculations.PUT();            
        } catch (Exception Ex) {
        }
        
        Test.stopTest();
    }
    
    /*
    @isTest
    static void put() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);

        Test.startTest();

        LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
        LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
        List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);

        Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
        List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
        Id productGroupId = productCosts.get(0).Product__c;

        String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);

        RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'http://salesforce.com/LAT_Rest_ComCondEventCalculations';
        RestContext.request.requestBody = Blob.valueOf(jsonBody);
        RestContext.response = new RestResponse();

        String error = '';
        try {
            LAT_Rest_ComCondEventCalculations.PUT();            
        } catch (Exception ex) {
            error = ex.getMessage();
        }
        
        Test.stopTest();
        
        System.assert(String.isBlank(error));        
    }    

*/
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
        Integer currentYear = Date.today().year();
        Integer currentMonth = Date.today().month();
        String formattedCurrentMonth = String.valueOf(currentMonth);
        formattedCurrentMonth = (formattedCurrentMonth.length() == 1) ? '0'+formattedCurrentMonth : formattedCurrentMonth;

        UDC__c canal = new UDC__c(Name = 'teste', CodDefUsuario__c = '114', Internal_Id__c = '123');
        insert canal;

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
    

    public static string getContractStringBody(String paymentRecordTypeId, String productGroupId, String contractId, String distribuitorId) {
		return   
		'                {'+
		'                    "id": "IDPRODUCTPAYMENTCHILD",'+
		'                    "ammount": 1000,'+
		'                    "finality": "Contrato",'+
		'                    "contract": "'+contractId+'",'+
		'                    "paymentDate": "2018-09-21",'+
		'                    "productGroup": "'+productGroupId+'",'+
        '                    "recordType": "'+paymentRecordTypeId+'",'+
        '                    "distribuitorId": "'+distribuitorId+'",'+
		'                    "volumen": 10,'+
		'                    "paymentDateDone": null,'+
		'                    "status": "P",'+
		'                    "parentPayment": "test",'+
		'                    "releaseReason": "test"'+
		'                }';
    }
    // @isTest
    // static void doCalc() {
    //     Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

    //     Test.startTest();

    //     LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
    //     LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
    //     LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
    //     List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);

    //     Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
    //     List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
    //     Id productGroupId = productCosts.get(0).Product__c;

    //     String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);

    //     LAT_ContractHandlerJSON.Payment payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(jsonBody, LAT_ContractHandlerJSON.Payment.class);

    //     LAT_Rest_ComCondEventCalculations.doCalc(payment, 'SC', 10.00, contract);

    //     Test.stopTest();
    // }
/*
    @isTest
    static void doCalcWithoutContract() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
        LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
        List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);

        Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
        List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
        Id productGroupId = productCosts.get(0).Product__c;

        String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);

        RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'http://salesforce.com/LAT_Rest_ComCondEventCalculations';
        RestContext.request.requestBody = Blob.valueOf(jsonBody);

        String error = '';
        try {
            LAT_Rest_ComCondEventCalculations.PUT();            
        } catch (Exception ex) {
            error = ex.getMessage();
        }
        
        Test.stopTest();

        System.assert(error == 'Attempt to de-reference a null object');      
    }

    @isTest
    static void setResponse() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
        LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
        List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);

        Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
        List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
        Id productGroupId = productCosts.get(0).Product__c;

        String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);

        RestContext.request = new RestRequest();
        RestContext.request.requestURI = 'http://salesforce.com/LAT_Rest_ComCondEventCalculations';
        RestContext.request.requestBody = Blob.valueOf(jsonBody);

        RestContext.response = new RestResponse();

        //LAT_Rest_ComCondEventCalculations.setResponse('teste', 200); 

        Test.stopTest();
    }


    @isTest
    static void serviceResponse() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
        LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
        List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);

        Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
        List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
        Id productGroupId = productCosts.get(0).Product__c;

        String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);

        LAT_ContractHandlerJSON.Payment payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(jsonBody, LAT_ContractHandlerJSON.Payment.class);

        LAT_Rest_ComCondEventCalculations.ServiceResponse serviceResponse = new LAT_Rest_ComCondEventCalculations.ServiceResponse(payment); 

        Test.stopTest();    
    }

    // @isTest
    // static void setTotalValue() {
    //     Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

    //     Test.startTest();
    
    //     LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
    //     LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
    //     LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
    //     List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);
    
    //     Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
    //     List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
    //     Id productGroupId = productCosts.get(0).Product__c;
    
    //     String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);
    
    //     LAT_ContractHandlerJSON.Payment payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(jsonBody, LAT_ContractHandlerJSON.Payment.class);
    
    //     LAT_Rest_ComCondEventCalculations.setTotalValue(payment, 'SC', 1, contract);
    
    //     Test.stopTest();  
    // }

    // @isTest
    // static void setProductValue() {
    //     Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

    //     Test.startTest();
    
    //     LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
    //     LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
    //     LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
    //     List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);
    //     payments = new LAT_PaymentRepository().findByContractIds(new List<Id>{contract.Id}); 
    
    //     Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
    //     List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
    //     Id productGroupId = productCosts.get(0).Product__c;
    
    //     String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);
    
    //     LAT_ContractHandlerJSON.Payment payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(jsonBody, LAT_ContractHandlerJSON.Payment.class);
    
    //     LAT_Rest_ComCondEventCalculations.setProductValue(payment, 'SC', 1, contract);
    
    //     Test.stopTest();  
    // }
/*
    @isTest
    static void setCashValue() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);
        LAT_Product__c product = [SELECT Id FROM LAT_Product__c LIMIT 1];
        LAT_UnitConversionRates__c unitConversionRate = LAT_EventFixtureFactory.createUnitConversionRate(product);
        List<LAT_Payment__c> payments = LAT_EventFixtureFactory.createPayment(contract);

        Id paymentRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Payment__c'+'LAT_PagamentoProduto');
        List<LAT_ProductCost__c> productCosts = [SELECT Id, Product__c, AN8__c, RecordType.DeveloperName, EndDate__c FROM LAT_ProductCost__c];
        Id productGroupId = productCosts.get(0).Product__c;

        String jsonBody = getContractStringBody(paymentRecordTypeId, productGroupId, contract.Id, distributor.Id);

        LAT_ContractHandlerJSON.Payment payment = (LAT_ContractHandlerJSON.Payment)System.JSON.deserialize(jsonBody, LAT_ContractHandlerJSON.Payment.class);

        LAT_Rest_ComCondEventCalculations.setCashValue(payment); 

        Test.stopTest();      
    }


    */
}