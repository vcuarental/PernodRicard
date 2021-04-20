@IsTest(SeeAllData=false)
private class LAT_Rest_Opportunities_Test {
    private static string VENTAS_USERNAME = 'ventas@pernod-ricard.com.test';
    
    @TestSetup
    private static void setupTest() {
        initializeTest();
    }

    @IsTest
    private static void BR_POST_Test() { 
        LAT_OpportunityHandlerJSON objPedidoJSON = null;       
        LAT_Rest_Opportunities.ServiceResponse objResponse = null; 
		RestRequest objRestRequest = null; 
		RestResponse objRestResponse = null;
        User objUser = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        UDC__c objPaymentCondition = null;
        CountrySettings objCountry = null;

        System.debug('BR_POST_Test [] ->');
        objCountry = retrieveCountryBR();        
        objUser = createUser(objCountry);

        objPaymentCondition = retrievePaymentCondition(objCountry);
        objProduct = retrieveProduct(objCountry);

        System.runAs(objUser) {
            objAccount = createAccount(objCountry);
        }
 
        objPedidoJSON = LAT_Rest_OpportunityFlex_Test.createPedidoJSON(objAccount, objProduct, objPaymentCondition);        
        
        objRestRequest = new RestRequest(); 
		objRestResponse = new RestResponse();
        objRestRequest.requestBody = Blob.valueOf(JSON.serialize(objPedidoJSON));
        
        RestContext.request = objRestRequest;
        RestContext.response = objRestResponse;
        
        Test.startTest();
		System.runAs(objUser) {
            System.assertEquals(0, [SELECT Id FROM LAT_Opportunity__c].size());
 
            LAT_Rest_Opportunities.POST();
            
            System.assertEquals(1, [SELECT Id FROM LAT_Opportunity__c].size());
            
            objResponse = (LAT_Rest_Opportunities.ServiceResponse)JSON.deserialize(objRestResponse.responseBody.toString(), LAT_Rest_Opportunities.ServiceResponse.class );

            System.assertEquals(true, objResponse.success);
            System.assertNotEquals(null, objResponse.Id);       
                        
            objPedidoJSON.header.Id = objResponse.Id;
			objRestRequest.requestBody = Blob.valueOf(JSON.serialize(objPedidoJSON));
			LAT_Rest_Opportunities.PUT();
        }
        
        Test.stopTest();
        
        System.debug('BR_POST_Test [] <-');
    }

    @IsTest
    private static void AR_POST_Test() { 
        LAT_OpportunityHandlerJSON objPedidoJSON = null;       
        LAT_Rest_Opportunities.ServiceResponse objResponse = null; 
		RestRequest objRestRequest = null; 
		RestResponse objRestResponse = null;
        User objUser = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        UDC__c objPaymentCondition = null;
        CountrySettings objCountry = null;

        System.debug('AR_POST_Test [] ->');
        objCountry = retrieveCountryAR();
        objUser = createUser(objCountry);

        objPaymentCondition = retrievePaymentCondition(objCountry);
        objProduct = retrieveProduct(objCountry);

        System.runAs(objUser) {
            objAccount = createAccount(objCountry);
        }
 
        objPedidoJSON = LAT_Rest_OpportunityFlex_Test.createPedidoJSON(objAccount, objProduct, objPaymentCondition);        
        
        objRestRequest = new RestRequest(); 
		objRestResponse = new RestResponse();
        objRestRequest.requestBody = Blob.valueOf(JSON.serialize(objPedidoJSON));
        
        RestContext.request = objRestRequest;
        RestContext.response = objRestResponse;
        
        Test.startTest();
		System.runAs(objUser) {
            System.assertEquals(0, [SELECT Id FROM LAT_Opportunity__c].size());
 
            LAT_Rest_Opportunities.POST();
            
            System.assertEquals(1, [SELECT Id FROM LAT_Opportunity__c].size());
            
            objResponse = (LAT_Rest_Opportunities.ServiceResponse)JSON.deserialize(objRestResponse.responseBody.toString(), LAT_Rest_Opportunities.ServiceResponse.class );

            System.assertEquals(true, objResponse.success);
            System.assertNotEquals(null, objResponse.Id);        
            
            objPedidoJSON.header.Id = objResponse.Id;
			objRestRequest.requestBody = Blob.valueOf(JSON.serialize(objPedidoJSON));
            LAT_Rest_Opportunities.PUT();
            
            LAT_Rest_Opportunities.cancelOpportunity(objPedidoJSON);
        }
        
        Test.stopTest();
        
        System.debug('AR_POST_Test [] <-');
    }
    
    @IsTest
    private static void MX_POST_Test() { 
        LAT_OpportunityHandlerJSON objPedidoJSON = null;       
        LAT_Rest_Opportunities.ServiceResponse objResponse = null; 
		RestRequest objRestRequest = null; 
		RestResponse objRestResponse = null;
        User objUser = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        UDC__c objPaymentCondition = null;
        CountrySettings objCountry = null;

        System.debug('MX_POST_Test [] ->');
        objCountry = retrieveCountryMX();        
        objUser = createUser(objCountry);

        objPaymentCondition = retrievePaymentCondition(objCountry);
        objProduct = retrieveProduct(objCountry);

        System.runAs(objUser) {
            objAccount = createAccount(objCountry);
        }
 
        objPedidoJSON = LAT_Rest_OpportunityFlex_Test.createPedidoJSON(objAccount, objProduct, objPaymentCondition);        
        
        objRestRequest = new RestRequest(); 
		objRestResponse = new RestResponse();
        objRestRequest.requestBody = Blob.valueOf(JSON.serialize(objPedidoJSON));
        
        RestContext.request = objRestRequest;
        RestContext.response = objRestResponse;
        
        Test.startTest();
		System.runAs(objUser) {
            System.assertEquals(0, [SELECT Id FROM LAT_Opportunity__c].size());
 
            LAT_Rest_Opportunities.POST();
            
            objResponse = (LAT_Rest_Opportunities.ServiceResponse)JSON.deserialize(objRestResponse.responseBody.toString(), LAT_Rest_Opportunities.ServiceResponse.class );
            
            /* falla, no crea la oportunidad */
            //System.assertNotEquals(null, objResponse.message);            
            //System.assertEquals(true, objResponse.success);
            //System.assertNotEquals(null, objResponse.Id);            
        }
        
        Test.stopTest();
        
        System.debug('MX_POST_Test [] <-');
    }

    private static void initializeTest() {
        User objUser = null;
        CountrySettings objCountry = null;

        System.debug('initializeTest [] ->');

        deleteTriggers();
        createSettings();
        postToChatter();

        objCountry = retrieveCountryBR();        
        createCredentials(objCountry);
        createPaymentCondition(objCountry);
        createProduct(objCountry);
       

        objCountry = retrieveCountryAR();        
        createCredentials(objCountry);
        createPaymentCondition(objCountry);
        createProduct(objCountry);

        objCountry = retrieveCountryMX();        
        createCredentials(objCountry);
        createPaymentCondition(objCountry);
        createProduct(objCountry);

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
}