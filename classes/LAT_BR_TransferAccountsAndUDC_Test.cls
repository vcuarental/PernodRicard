@isTest
private class LAT_BR_TransferAccountsAndUDC_Test {
    private static String USERNAME_MANAGER = 'manager@pernod-ricard.com';
    private static String USERNAME_1 = 'user1@pernod-ricard.com';
    private static String USERNAME_2 = 'user2@pernod-ricard.com';
    private static String UDC_CODE_1 = 'TT';
    private static String UDC_CODE_2 = 'PY';
    @TestSetup
    private static void setupTest() {
        User objUser = null;
        Account objAccount = null;

        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];   

        createGeneralConfigSettings();
        createJDECredentials();
        createPoliticaPrecios();
        objUser = createUser();

        objAccount = createAccount(objUser);
        createOpportunity(objUser, objAccount);
        createContact(objUser, objAccount);

        createUDC('01','02', objUser.C_digo_JDE__c, 'Blanco','1-01-02-' + UDC_CODE_1, 'BRA_Standard');
    }

    private static void createPoliticaPrecios() {
        LAT_BR_PoliticaPrecoConfig__c  objConfig = null;

        objConfig = new LAT_BR_PoliticaPrecoConfig__c();

        objConfig.Beneficio_Fiscal__c = '';
        objConfig.Channel__c = '1';
        objConfig.Client_type__c  = '12';
        objConfig.Estrategia_comercial__c = '7';
        objConfig.Formato__c  = '17';
        //objConfig.Perfil_Codigo_Demantra__c   = '101A-RJ',
        objConfig.Perfil_Desc_Demantra__c ='101A-RJ';
        // objConfig.Perfil_Portfolio__c  = '1',
        objConfig.Politica_de_Preco__c    = '1IO';
        //objConfig.Prioridade_de_Investimento__c = '12',   
        objConfig.Segment__c  = '116';
        objConfig.Sub_channel__c  = '11';
        objConfig.UF__c = 'GO';

        insert objConfig;
    }

    private static void createJDECredentials() {
        List<CS001_JDEInterfaceCredentials__c> lstCredentials = null;
        CS001_JDEInterfaceCredentials__c objCredential = null;
        Map<String,String> mapCountry = null;

        mapCountry = new Map<String,String>();
        mapCountry.put('Argentina', '6');
        mapCountry.put('Brasil', '1');
        mapCountry.put('Uruguay', '5');
        mapCountry.put('Mexico', '12');

        lstCredentials = new List<CS001_JDEInterfaceCredentials__c>();
        for(String strCountry : mapCountry.keySet()) {
            objCredential = new CS001_JDEInterfaceCredentials__c();
            objCredential.Name = strCountry;
            objCredential.UserName__c = 'admin@username.com'; 
            objCredential.Country__c = mapCountry.get(strCountry);
            objCredential.EndPoint_CustomerHandler__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerHandlerReq?WSDL';
            objCredential.EndPoint_CustomerVerify__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerVerifyReq?WSDL';
            objCredential.EndPoint_PriceCalculation__c = 'http://osbdev.pramericas.com/SFDC/Price/PriceCalculationReq?WSDL'; 
            objCredential.EndPoint_SalesOrderHandler__c = 'http://osbdev.pramericas.com/SFDC/SalesOrder/AsyncSalesOrderHandlerReq?WSDL'; 
            objCredential.RemoteHostIP__c = '200.200.10.10';
            objCredential.SystemUserID__c = 'cloud2b';
            objCredential.EndPoint_BalanceCheck__c = 'X';
            objCredential.EndPoint_ContractManager__c = 'X'; 
            objCredential.EndPoint_PaymentManager__c = 'X';
            objCredential.EndPoint_RVManager__c = 'X';
            objCredential.EndPoint_GetStock__c='https://osbdev.pramericas.com/JDE9/Inventory/GetStock?wsdl'; 
            
            lstCredentials.add(objCredential);
        }

        insert lstCredentials;        
    }

    private static void createGeneralConfigSettings() {
        List<LAT_GeneralConfig__c>  lstGeneralConfig = null;

        lstGeneralConfig = new List<LAT_GeneralConfig__c>();
        lstGeneralConfig.add(createGeneralConfigSetting('POLITICA_PRECO_MAPPING','Channel__c'));
        lstGeneralConfig.add(createGeneralConfigSetting('POLITICA_PRECO_MAPPING1','Sub_channel__c'));
        lstGeneralConfig.add(createGeneralConfigSetting('POLITICA_PRECO_MAPPING2','Segment__c'));
        lstGeneralConfig.add(createGeneralConfigSetting('POLITICA_PRECO_MAPPING3','Uf__c'));
        lstGeneralConfig.add(createGeneralConfigSetting('POLITICA_PRECO_MAPPING4','Estrategia_comercial__c'));
        lstGeneralConfig.add(createGeneralConfigSetting('AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF','LAT_AR2_Vendedor'));
        lstGeneralConfig.add(createGeneralConfigSetting('OPP_Verification_Email_Recipients','test@zimmic.com,test@zimmic.com'));
        lstGeneralConfig.add(createGeneralConfigSetting('LAT_ACCOUNT_VERIFICATION_QUERY','SELECT Id, Name FROM Account LIMIT 1'));
        lstGeneralConfig.add(createGeneralConfigSetting('OPP_Verification_StatusToCheck','Novo Pedido'));
        lstGeneralConfig.add(createGeneralConfigSetting('APPROVAL_SLA_OBJECTS','\'Account\',\'LAT_Contract2__c\''));
        lstGeneralConfig.add(createGeneralConfigSetting('LAT_BR_FlexEDI_Enabled','true'));

        insert lstGeneralConfig;
    }

    private static LAT_GeneralConfig__c createGeneralConfigSetting(String strName, String strValue) {
        LAT_GeneralConfig__c objSetting = null;

        objSetting = new LAT_GeneralConfig__c();
        objSetting.Name = strName;
        objSetting.LAT_Value__c =  strValue;

        return objSetting;
    }

    private static Account createAccount(User objUser) {
        Account objAccount = null;

        System.runAs(objUser) {
            objAccount = LAT_Account_TestFactory.getAccountOnTradeBraComplete();
            objAccount.Type = 'COM PAGAMENTO';
            objAccount.CNPJ__c = '91370573000162';
            objAccount.OwnerId = objUser.Id;
            objAccount.Client_code_AN8__c = '123451237';
            objAccount.Status__c = 'Cliente cadastrado no JDE';
            objAccount.Rating = 'Cliente';  
            objAccount.Client_country_AN8__c = '1-' + objAccount.Client_code_AN8__c;  
        
            insert objAccount;        
        }

        return objAccount;
    }

    private static void createOpportunity(User objUser, Account objAccount) {
        Lat_opportunity__c objOpportunity = null;
        
        System.runAs(objUser) {
            objOpportunity = new Lat_opportunity__c();
            objOpportunity.Name = 'Test Opp';
            objOpportunity.LAT_Account__c = objAccount.Id; 
            objOpportunity.LAT_CloseDate__c = Date.today(); 
            objOpportunity.LAT_StageName__c = 'Novo pedido'; 
            objOpportunity.CurrencyISOCode = 'BRL';
            
            insert objOpportunity;    
        }
    }

    private static void createContact(User objUser, Account objAccount) {
        Contact objContact = null;
        
        System.runAs(objUser) {
            objContact = new Contact();
            objContact.LastName = 'test';
            objContact.AccountId = objAccount.Id;
            
            insert objContact;
        }
    }

    private static User createUser() {
        Profile objProfile = null;
        User objUser1 = null;
        User objUser2 = null;

        objProfile = retrieveProfile();
        objUser1 = createUser(null, objProfile, USERNAME_1);
        insert objUser1;

        objUser2 = createUser(null, objProfile, USERNAME_2);
        insert objUser2;
    
        return objUser1;
    }

    private static Profile retrieveProfile() {
        Profile objProfile = null;

        objProfile = [SELECT Id FROM Profile WHERE Name = 'LAT_BR2_Vendas']; 

        return objProfile;
    }

    private static User createUser(User objManager, Profile objProfile, String strUserName) {
        User objUser = null;

        System.debug('retrieveUser [objManager : ' + objManager + ' - objProfile : ' + objProfile + ' - strUserName : ' + strUserName + '] ->');
        
        objUser = new User();
        objUser.Alias = 'standt';
        objUser.Email = 'testudc@zimmic.com';
        objUser.EmailEncodingKey = 'UTF-8'; 
        objUser.LastName = 'Testing';
        objUser.LanguageLocaleKey = 'en_US'; 
        objUser.LocaleSidKey = 'en_US'; 
        objUser.ProfileId = objProfile.Id;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.UserName = strUsername;
        objUser.c_digo_jde__c = 'TT';
        
        if(objManager != NULL) {
            objUser.ManagerId = objManager.Id;
            objUser.Gerente_Regional__c = objManager.Id;
            objUser.gerente_de_area__c = objManager.Id;
        }

        System.debug('retrieveUser [' + objUser + '] <-');

        return objUser;
    }

    private static UDC__c createUDC(String strCodProd, String strCodUs, String strCodDefUsuario, String strName, String strInternalId, String strRecorType) {
        UDC__c objUDC = null;

        System.debug('createUDC [strCodUs : ' + strCodUs + ' - strCodProd : ' + strCodProd + ' - strName : ' + strName + ' - strInternalId : ' + strInternalId + ' - strRecorType : ' + strRecorType + '] ->');
        objUDC = new UDC__c();

        objUDC.CodUs__c = strCodUs;
        objUDC.CodProd__c = strCodProd;
        objUDC.Name = strName;
        objUDC.CodDefUsuario__c = strCodDefUsuario;
        //objUDC.LAT_MX_FilterKey__c = 'PY-00-AR';
        objUDC.Internal_Id__c = strInternalId;
        objUDC.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + strRecorType);
        
        insert objUDC;

        System.debug('createUDC [' + objUDC + '] <-');

        return objUDC;
    }

    @IsTest
    private static void getAccountsPerUserTest() {
        User objUser1 = null;
        Account objAccount = null;        
        LAT_BR_TransferAccountsAndUDC objTransfer = null;

        Test.startTest();
        objUser1 = [SELECT Id FROM User WHERE UserName =: USERNAME_1];
        objAccount = [SELECT OwnerId FROM Account WHERE OwnerId =: objUser1.Id ];

        objTransfer = new LAT_BR_TransferAccountsAndUDC();
        objTransfer.accOldLookup = objAccount;
        objTransfer.sortExpression = 'Name';
        objTransfer.setSortDirection('DESC');
        objTransfer.getAccountsPerUser();
        Test.stopTest();

        System.assertEquals(1, objTransfer.listInnerAccount.size());
    }

    @IsTest
    private static void transferAccountsTest() {
        User objUser1 = null;
        User objUser2 = null;
        Account objAccount = null;     
        List<LAT_ACCOUNT__c> lstLATAccounts = null;   
        LAT_BR_TransferAccountsAndUDC objTransfer = null;
        UDC__c objUDC1 = null;
        UDC__c objUDC2 = null;
        String strInternalCode = null;
        Test.startTest();

        strInternalCode = '1-01-02-' + UDC_CODE_1;
        objUser1 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_1];
        objUser2 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_2];

        objAccount = [SELECT OwnerId FROM Account WHERE OwnerId =: objUser1.Id ];
        objUDC1 = [SELECT Id FROM UDC__c WHERE Internal_Id__c =: strInternalCode];        
        objUDC2 = createUDC('01','02', objUser2.C_digo_JDE__c, 'Blanco','1-00-00-' + UDC_CODE_2, 'BRA_Standard');

        objTransfer = new LAT_BR_TransferAccountsAndUDC();
        objTransfer.accOldLookup = objAccount;
        objTransfer.sortExpression = 'Name';
        objTransfer.setSortDirection('DESC');
        objTransfer.getAccountsPerUser(); 

        lstLATAccounts = [SELECT LAT_UDCZonaVendedor__c FROM LAT_Account__c WHERE LAT_AccountId__r.OwnerId =: objUser1.Id];
        for(LAT_Account__c objLATAccount : lstLATAccounts) {
            objLATAccount.LAT_UDCZonaVendedor__c = objUDC1.Id;
            objLATAccount.LAT_ID_Status__c = 'Activo';
        }

        update lstLATAccounts;
 
        if(objTransfer.listInnerAccount.size() > 0){
            for(LAT_BR_TransferAccountsAndUDC.AccountInner objInnerAccount : objTransfer.listInnerAccount) {
                objInnerAccount.isSelected = true;
            }
        }
        objTransfer.dummyOpp.LAT_DTDelivery__c = Date.today().addDays(-1);
        objTransfer.dummyOpp.LAT_MX_PurchaseOrderUntil__c = Date.today().addDays(1);
        
        objTransfer.transferContacts = true;
        objTransfer.transferOpps = true;
        objTransfer.mantainVendorCode = false;
        objTransfer.useNewVendorCode = true;
        objTransfer.accNewLookup.OwnerId = objUser2.Id;
        objTransfer.udcNewLookup.LAT_JDEZoneUDC__c = objUDC2.Id;
        objTransfer.shareOption = 'Read';

        objTransfer.transferAccounts();

        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM Account WHERE OwnerId =: objUser2.Id].size());
        System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId =: objUser2.Id].size());
        System.assertEquals(1, [SELECT Id FROM LAT_Opportunity__c WHERE OwnerId =: objUser2.Id].size());
    }

    @IsTest
    private static void shareAccountsTest() {
        User objUser1 = null;
        User objUser2 = null;
        Account objAccount = null;     
        LAT_BR_TransferAccountsAndUDC objTransfer = null;
        Test.startTest();

        objUser1 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_1];
        objUser2 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_2];

        objAccount = [SELECT OwnerId FROM Account WHERE OwnerId =: objUser1.Id ];

        objTransfer = new LAT_BR_TransferAccountsAndUDC();
        objTransfer.accOldLookup = objAccount;
        objTransfer.getAccountsPerUser(); 
 
        if(objTransfer.listInnerAccount.size() > 0){
            for(LAT_BR_TransferAccountsAndUDC.AccountInner objInnerAccount : objTransfer.listInnerAccount) {
                objInnerAccount.isSelected = true;
            }
        }
        
        objTransfer.accNewLookup.OwnerId = objUser2.Id;
        objTransfer.shareOption = 'Read';
        objTransfer.transferContacts = true;
        objTransfer.transferOpps = true;
        
        objTransfer.shareAccounts();

        Test.stopTest();
    }

    @IsTest
    private static void assignUDCsTest() {
        User objUser1 = null;
        User objUser2 = null;
        Account objAccount = null;     
        List<LAT_ACCOUNT__c> lstLATAccounts = null;   
        LAT_BR_TransferAccountsAndUDC objTransfer = null;
        UDC__c objUDC1 = null;
        UDC__c objUDC2 = null;
        String strInternalCode = null;
        Test.startTest();

        strInternalCode = '1-01-02-' + UDC_CODE_1;
        objUser1 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_1];
        objUser2 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_2];

        objAccount = [SELECT OwnerId FROM Account WHERE OwnerId =: objUser1.Id ];
        objUDC1 = [SELECT Id FROM UDC__c WHERE Internal_Id__c =: strInternalCode];        
        objUDC2 = createUDC('01','02', objUser2.C_digo_JDE__c, 'Blanco','1-00-00-' + UDC_CODE_2, 'BRA_Standard');

        objTransfer = new LAT_BR_TransferAccountsAndUDC();
        objTransfer.accOldLookup = objAccount;
        objTransfer.getAccountsPerUser(); 

        lstLATAccounts = [SELECT LAT_UDCZonaVendedor__c FROM LAT_Account__c WHERE LAT_AccountId__r.OwnerId =: objUser1.Id];
        for(LAT_Account__c objLATAccount : lstLATAccounts) {
            objLATAccount.LAT_UDCZonaVendedor__c = objUDC1.Id;
            objLATAccount.LAT_ID_Status__c = 'Activo';
        }

        update lstLATAccounts;
 
        if(objTransfer.listInnerAccount.size() > 0){
            for(LAT_BR_TransferAccountsAndUDC.AccountInner objInnerAccount : objTransfer.listInnerAccount) {
                objInnerAccount.isSelected = true;
            }
        }
        
        objTransfer.udcNewLookup.LAT_UDCZonaVendedor__c = objUDC2.Id;        
        objTransfer.assignUDCs();

        Test.stopTest();
    }
    @IsTest
    private static void executeBatchTest() { 
        LAT_BR_TransferAccounts_Batch objBatch = null;
        Account objAccount = null;
        User objUser1 = null;
        User objUser2 = null;
        
        Test.startTest();
        objUser1 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_1];
        objUser2 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_2];

        objAccount = [SELECT OwnerId FROM Account WHERE OwnerId =: objUser1.Id ];
        objBatch = new LAT_BR_TransferAccounts_Batch(new Set<Id> {objAccount.Id} , objUser2.Id);
        Database.executeBatch(objBatch);
        Test.stopTest();
        System.assertEquals(0, [SELECT OwnerId FROM Account WHERE OwnerId =: objUser1.Id ].size());
        System.assertEquals(1, [SELECT OwnerId FROM Account WHERE OwnerId =: objUser2.Id ].size());
    }

    @IsTest
    private static void executeBatchErrorTest() { 
        LAT_BR_TransferAccounts_Batch objBatch = null;
        Account objAccount = null;
        User objUser1 = null;
        User objUser2 = null;
        
        Test.startTest();
        objUser1 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_1];
        objUser2 = [SELECT Id, C_digo_JDE__c FROM User WHERE UserName =: USERNAME_2];

        objAccount = [SELECT OwnerId FROM Account WHERE OwnerId =: objUser1.Id ];
        objBatch = new LAT_BR_TransferAccounts_Batch(new Set<Id> {objAccount.Id} , objUser2.Id);
        objBatch.errors = 'Ha ocurrido un error en la operacion';
        Database.executeBatch(objBatch);
        Test.stopTest();
    }

    @IsTest
    private static void commmonMethodsTest() {
        LAT_BR_TransferAccountsAndUDC objTransfer = null;
        Test.startTest();
        objTransfer = new LAT_BR_TransferAccountsAndUDC();
        objTransfer.setSortDirection('DESC');
        System.assertEquals('DESC', objTransfer.getSortDirection());
        System.assertNotEquals(0, objTransfer.getShareOptions().size());
        Test.stopTest();
    }
    
/*
	public static Account retAccount (User u) {
		Test.startTest();

   		Account accoHijo= new Account();
		
	   	accoHijo.Name = 'AccountTest2';
	    accoHijo.CNPJ__c = '30713131500';
	    accoHijo.Client_code_AN8__c = '123451237';
	    accoHijo.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_BR_LAC_Standard');
	    accoHijo.OwnerId = u.Id;
	    accoHijo.Status__c = 'Cliente cadastrado no JDE';
	    accoHijo.Rating = 'Cliente';    

	    insert accoHijo;

	    LAT_Account__c latAcc = [SELECT id, LAT_ID_Status__c FROM LAT_Account__c WHERE LAT_Accountid__c = :accoHijo.Id];
	    latAcc.LAT_ID_Status__c = 'Activo';
	    update latAcc;
		
		LAT_GeneralConfig__c mailSetting = new LAT_GeneralConfig__c(name = 'ACCOUNT_NOTIFY_ERROR_MAIL', LAT_Value__c = 'test@gmail.com;');
	    
	    insert mailSetting;

	    Test.stopTest();
	    return accoHijo;
	    
 	}
	
	@isTest static void  test1() {
        Account accOpp = [
			SELECT Id, CNPJ__c
			FROM Account
			WHERE CNPJ__c = '91370573000162'
        ];
        
		createUDC('PY','00','234', 'Blanco','6-00-00-PY', 'BRA_Standard');

        User u = new User();
        u = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        u.profileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_BR2_Vendas');
        
            insert u;
            
        User u3 = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 1];

        //Account acc = retAccount(u3);
        LAT_BR_TransferAccounts_Batch.CustomerInterfaceJDESync(null);
	}

	@isTest static void  test2() {
        Account acc = [
			SELECT Id, CNPJ__c, OwnerId,Client_country_AN8__c, LAT_BR_RegionalClientOnPremise__c
			FROM Account
			WHERE CNPJ__c = '91370573000162'
        ];
		
        List<User> us =[SELECT Id, C_digo_JDE__c FROM User Where Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true AND Manager.Manager.ManagerId <> null LIMIT 2];
        createUDC('PY','00',us[0].C_digo_JDE__c, 'Blanco','6-00-00-PY', 'BRA_Standard');
		
   		
   		
		User u3 = [SELECT Id FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true AND Manager.Manager.ManagerId <> null LIMIT 1];
   		
   		System.runAs(u3) {
			UDC__c udc = LAT_Utils_test.createUDC('02','01','Blanco','6-00-01-02', 'BRA_Standard');
			UDC__c clon = udc.clone();
			clon.CodDefUsuario__c = us[1].C_digo_JDE__c;
			clon.Internal_Id__c = '6-'+ us[1].C_digo_JDE__c +'-01-02';
			UDC__c clon3 = udc.clone();
			clon3.CodDefUsuario__c = 'NOT_FOUND';
			clon3.Internal_Id__c = '6-NOT_FOUND-01-02';
			UDC__c clon2 = udc.clone();
			clon2.CodDefUsuario__c = us[0].C_digo_JDE__c;
			clon2.Internal_Id__c = '6-'+ us[0].C_digo_JDE__c +'-01-02';
			insert new List<UDC__c> {clon};
			System.debug('%%%% UDCS: '+ [select Recordtype.Developername, CodProd__c, CodUs__c,CodDefUsuario__c, id FROM UDC__c ]);
   			//Account acc = retAccount(us[0]);
            LAT_BR_TransferAccountsAndUDC cont = new LAT_BR_TransferAccountsAndUDC();
			cont.accOldLookup.OwnerId = acc.OwnerId;

			cont.getAccountsPerUser();
			LAT_BR_TransferAccountsAndUDC.AccountInner acInn = new LAT_BR_TransferAccountsAndUDC.AccountInner();
			acInn.isSelected = true;
			acInn.accId = acc.Id;
			acInn.ownerId = acc.OwnerId;
			cont.listInnerAccount.add(acInn);
			cont.accNewLookup.OwnerId = us[1].Id;

			Lat_opportunity__c opp = new Lat_opportunity__c(name='Test Opp', lat_account__c=acc.Id, LAT_CloseDate__c =Date.today(), LAT_StageName__c='Novo pedido', CurrencyISOCode = 'BRL');
			insert opp;

			Contact con = new Contact(lastname='test', accountid=acc.id);
			insert con;

			cont.udcNewLookup.LAT_JDEZoneUDC__c = udc.Id;
			cont.transferContacts = true;
	    	cont.transferOpps = true;
	    	cont.shareOption = 'Read';
			
			cont.transferAccounts();
			cont.assignUDCs();
			cont.getSortDirection();
            cont.setSortDirection('ASC');
            cont.sortExpression = 'ASC';
            cont.sortExpression = 'DESC';

			LAT_BR_TransferAccounts_Batch batch = new LAT_BR_TransferAccounts_Batch(new Set<Id>{acc.Id}, us[1].Id);
			LAT_BR_TransferAccounts_Batch.getAccount(new Set<Id>{acc.Id});
            batch.execute(null, new List<Account> { acc });
            
			List<SelectOption> shareOptions = cont.getShareOptions();

			cont.shareAccounts();
   		}
		
	}
        //Esto es una payment condintion o algo asi
        public static UDC__c createUDC(String strCodUs, String strCodProd,String strCodDefUsuario, String strName, String strInternalId, String strRecorType) {
            UDC__c objUDC = null;
    
            System.debug('createUDC [strCodUs : ' + strCodUs + ' - strCodProd : ' + strCodProd + ' - strName : ' + strName + ' - strInternalId : ' + strInternalId + ' - strRecorType : ' + strRecorType + '] ->');
            objUDC = new UDC__c();
    
            objUDC.CodUs__c = strCodUs;
            objUDC.CodProd__c = strCodProd;
            objUDC.Name = strName;
            objUDC.CodDefUsuario__c = strCodDefUsuario;
            //objUDC.LAT_MX_FilterKey__c = 'PY-00-AR';
            objUDC.Internal_Id__c = strInternalId;
            objUDC.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + strRecorType);
            
            insert objUDC;
    
            System.debug('createUDC [' + objUDC + '] <-');
    
            return objUDC;
        }
        */
}