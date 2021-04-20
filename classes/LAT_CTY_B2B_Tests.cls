@istest
private with sharing class LAT_CTY_B2B_Tests {
    private static String PROFILE_COMMUNITY = 'LAT_CTY_B2B_CommunityUser';
    private static String USERNAME_1 = 'user1@pernod-ricard.com';


    @testSetup 
    private static void setupTest() {        
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];

        createGeneralConfigSettings();
        createUDCs();
        createUsers();
    }

    //LAT MY ACCOUNT CONTROLLER
    @IsTest
    private static void updateUserEmailPreferencesTest() {
        User objUser  = null;
        
        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];

        System.runAs(objUser) {
            Test.startTest();
            System.assertEquals(false, LAT_CTY_B2B_MyAccountController.getUserEmailPreferences());

            LAT_CTY_B2B_MyAccountController.updateUserEmailPreferences(true);

            System.assertEquals(true, LAT_CTY_B2B_MyAccountController.getUserEmailPreferences());

            Test.stopTest();
        }
    }

    @IsTest
    private static void getAccountIdFromUserTest() {
        User objUser  = null;
        Account objAccount = null;
        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        objAccount = [SELECT Id FROM Account];
        System.runAs(objUser) {
            Test.startTest();
            System.assertEquals(objAccount.Id, LAT_CTY_B2B_MyAccountController.getAccountIdFromUser());
            Test.stopTest();
        }
    }

    @IsTest
    private static void commonFunctionsTest() { 
        User objUser  = null;

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        System.runAs(objUser) {
            System.assertEquals(1, LAT_CTY_B2B_MyAccountController.getTitulosListViewNames().size());
            System.assertNotEquals(null, LAT_CTY_B2B_MyAccountController.getAccountDetail());
            System.assertNotEquals(null, LAT_CTY_B2B_MyAccountController.getCaseAccountRegistrationRTId());
        }
    }

    @IsTest
    private static void getLastOpportunityTest() { 
        User objUser  = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        UDC__c objPayment = null;
        LAT_Account_product_payment__c objAccountProductPayment = null;
        LAT_Opportunity__c objOpportunity = null;
        LAT_OpportunityLineItem__c objOpportunityLineItem = null;

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        objAccount = [SELECT Id,Client_country_AN8__c, CurrencyIsoCode FROM Account];
        objPayment = [SELECT Id, CodUs__c,CodProd__c, Name, CodDefUsuario__c, Internal_Id__c  FROM UDC__c LIMIT 1];
        objProduct = createProduct();
        insert objProduct;

        objAccountProductPayment = createAccountProductPayment(objAccount, objProduct, objPayment);
        insert objAccountProductPayment;
        System.runAs(objUser) {
            objOpportunity = createOpportunity(objAccount);
            insert objOpportunity;

            objOpportunityLineItem = createOpportunityLineItem(objOpportunity, objProduct);
            insert objOpportunityLineItem;
       
            System.assertNotEquals(null, LAT_CTY_B2B_MyAccountController.getLastOpportunity());
        }
    }
    
    @IsTest
    private static void getRelatedContactsTest() { 
        User objUser  = null;

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];

        System.runAs(objUser) {
            System.assertEquals(1, LAT_CTY_B2B_MyAccountController.getRelatedContacts().size());
        }
    }

    //LAT CTY B2B ORDER CONTROLLER
    @IsTest
    private static void commonFunctionsOrderControllerTest() { 
        User objUser  = null;

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        System.runAs(objUser) {
            System.assertNotEquals(0, LAT_CTY_B2B_OrderController.getAllCategories().size());
            System.assertEquals(false, LAT_CTY_B2B_OrderController.getChartBlocked());
            System.assertEquals(0, LAT_CTY_B2B_OrderController.getMinimunPrice());
            System.assertEquals('LAT_CTY_B2B_AR_BlockingComments', LAT_CTY_B2B_OrderController.getBlockingComments().Name);
        }
    }

    @IsTest
    private static void getAccountDetailTest() { 
        User objUser  = null;

        try {
            LAT_CTY_B2B_OrderController.getAccountDetail();
        } catch (Exception Ex) {
            System.assertNotEquals(null,Ex);
        }

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];

        System.runAs(objUser) {
            System.assertNotEquals(null, LAT_CTY_B2B_OrderController.getAccountDetail());
        }
    }

    @IsTest
    private static void getAccountDetailIdTest() { 
        User objUser  = null;
        Account objAccount = null;

        try {
            LAT_CTY_B2B_OrderController.getAccountIdFromUser();
        } catch (Exception Ex) {
            System.assertNotEquals(null,Ex);
        }
        try {
            LAT_CTY_B2B_OrderController.getAccountId();
        } catch (Exception Ex) {
            System.assertNotEquals(null,Ex);
        }

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        objAccount = [SELECT Id,Client_country_AN8__c, CurrencyIsoCode FROM Account];

        System.runAs(objUser) {
            System.assertEquals(objAccount.Id, LAT_CTY_B2B_OrderController.getAccountIdFromUser());
            System.assertEquals(objAccount.Id, LAT_CTY_B2B_OrderController.getAccountId());            
        }
    }

    @IsTest
    private static void getBlockedClientTest() {
        User objUser  = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        UDC__c objPayment = null;
        LAT_Account_product_payment__c objAccountProductPayment = null;
        LAT_Opportunity__c objOpportunity = null;
        LAT_OpportunityLineItem__c objOpportunityLineItem = null;
        LAT_FiscalNote__c objFiscalNote = null;
        Attachment objAttachment = null;

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        objAccount = [SELECT Id,Client_country_AN8__c, CurrencyIsoCode FROM Account];
        objPayment = [SELECT Id, CodUs__c,CodProd__c, Name, CodDefUsuario__c, Internal_Id__c  FROM UDC__c LIMIT 1];
        objProduct = createProduct();
        insert objProduct;

        objAccountProductPayment = createAccountProductPayment(objAccount, objProduct, objPayment);
        insert objAccountProductPayment;

        System.runAs(objUser) {
            objOpportunity = createOpportunity(objAccount);
            insert objOpportunity;

            Test.startTest();
            System.assertEquals(false, LAT_CTY_B2B_OrderController.getBlockedClient());           
            
            objFiscalNote = createFiscalNote(objAccount, objOpportunity, 'A pagar', false);
            insert objFiscalNote;
            System.assertEquals(false, LAT_CTY_B2B_OrderController.getBlockedClient());            

            objFiscalNote = createFiscalNote(objAccount, objOpportunity, 'A pagar', true);
            insert objFiscalNote;
            System.assertEquals(true, LAT_CTY_B2B_OrderController.getBlockedClient());   
            Test.stopTest();         
        }
    }


    @IsTest
    private static void getCommunityOrdersEmptyTest() { 
        User objUser  = null;
        Account objAccount = null;


        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];

        System.runAs(objUser) {
            System.assertEquals(0, LAT_CTY_B2B_OrderController.getCommunityOrders().size());
        }
    }


    @IsTest
    private static void getCommunityOrdersTest() { 
        User objUser  = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        UDC__c objPayment = null;
        LAT_Account_product_payment__c objAccountProductPayment = null;
        LAT_Opportunity__c objOpportunity = null;
        LAT_OpportunityLineItem__c objOpportunityLineItem = null;
        LAT_FiscalNote__c objFiscalNote = null;
        Attachment objAttachment = null;

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        objAccount = [SELECT Id,Client_country_AN8__c, CurrencyIsoCode FROM Account];
        objPayment = [SELECT Id, CodUs__c,CodProd__c, Name, CodDefUsuario__c, Internal_Id__c  FROM UDC__c LIMIT 1];
        objProduct = createProduct();
        insert objProduct;

        objAccountProductPayment = createAccountProductPayment(objAccount, objProduct, objPayment);
        insert objAccountProductPayment;
        
        Test.startTest();
        //sin fiscal notess
        System.runAs(objUser) {
            System.assertEquals(0, LAT_CTY_B2B_OrderController.getCommunityOrders().size());
            try {
                LAT_CTY_B2B_OrderController.getlastOrder();
            } catch(AuraHandledException Ex) {
                System.assertNotEquals(null, Ex);
            }
            objOpportunity = createOpportunity(objAccount);
            insert objOpportunity;
    
            objOpportunityLineItem = createOpportunityLineItem(objOpportunity, objProduct);
            insert objOpportunityLineItem;
    
            objOpportunity.LAT_StageName__c = 'Pedido Procesado no JDE';
            update objOpportunity;

            System.assertEquals(1, LAT_CTY_B2B_OrderController.getCommunityOrders().size());
            try {
                LAT_CTY_B2B_OrderController.getlastOrder();
            } catch(AuraHandledException Ex) {
                System.assertNotEquals(null, Ex);
            }
                //con fiscal notes
            objFiscalNote = createFiscalNote(objAccount, objOpportunity, 'A pagar', false);
            insert objFiscalNote;

            objAttachment = createLegalInvoice(objFiscalNote);
            insert objAttachment;

            System.assertEquals(1, LAT_CTY_B2B_OrderController.getCommunityOrders().size());
            System.assertEquals(objOpportunity.Id, LAT_CTY_B2B_OrderController.getlastOrder().Id);   
        }
        Test.stopTest();
    }

    @IsTest
    private static void getOpenOrderTest() { 
        User objUser  = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        UDC__c objPayment = null;
        LAT_Account_product_payment__c objAccountProductPayment = null;
        LAT_Opportunity__c objOpportunity = null;
        LAT_OpportunityLineItem__c objOpportunityLineItem = null;
        LAT_FiscalNote__c objFiscalNote = null;
        Attachment objAttachment = null;

        objUser = [SELECT Id FROM User WHERE Profile.Name =: PROFILE_COMMUNITY AND Username =: USERNAME_1];
        objAccount = [SELECT Id,Client_country_AN8__c, CurrencyIsoCode FROM Account];
        objPayment = [SELECT Id, CodUs__c,CodProd__c, Name, CodDefUsuario__c, Internal_Id__c  FROM UDC__c LIMIT 1];
        objProduct = createProduct();
        insert objProduct;

        objAccountProductPayment = createAccountProductPayment(objAccount, objProduct, objPayment);
        insert objAccountProductPayment;
        
        Test.startTest();
        //sin fiscal notess
        System.runAs(objUser) {
            //LA PRIMER VEZ QUQE LLAMO A OPEN ORDER LA CREA SI NO EXISTE
            try {
                objOpportunity = LAT_CTY_B2B_OrderController.getOpenOrder();
            
                System.assertNotEquals(null, objOpportunity.Id );

                objOpportunityLineItem = createOpportunityLineItem(objOpportunity, objProduct);
                insert objOpportunityLineItem;
                objFiscalNote = createFiscalNote(objAccount, objOpportunity, 'A pagar', false);
                insert objFiscalNote;
                //LA SEGUNDA VEZ ME DEBE TRAER LA OPEN ORDEN CREADA SI EXISTE
                System.assertNotEquals(objOpportunity.Id, LAT_CTY_B2B_OrderController.getOpenOrder().Id );            
            } catch (Exception Ex) {
                //
            }
        }

        Test.stopTest();
    }

    private static void createUsers() {
        createCommunityUser();
    }

    private static void createGeneralConfigSettings() {
        List<LAT_GeneralConfig__c>  lstGeneralConfig = null;

        lstGeneralConfig = new List<LAT_GeneralConfig__c>();
        lstGeneralConfig.add(createGeneralConfigSetting('LAT_CTY_B2B_AR_ChartIsBlocked','false'));
        lstGeneralConfig.add(createGeneralConfigSetting('AR_B2B_OrderNumer','500'));
        
        insert lstGeneralConfig;
    }

    private static LAT_GeneralConfig__c createGeneralConfigSetting(String strName, String strValue) {
        LAT_GeneralConfig__c objSetting = null;

        objSetting = new LAT_GeneralConfig__c();
        objSetting.Name = strName;
        objSetting.LAT_Value__c =  strValue;

        return objSetting;
    }

    private static void createUDCs() { 
        List<UDC__c> lstUDCs = null;
        UDC__c objUDC = null;

        lstUDCs = new List<UDC__c>();

        //REGIONAL
        objUDC = createUDC('01', '03', '4586', 'Subcanal', '01-4586-01-03', 'Standard_AR');
        lstUDCs.add(objUDC);
        
        //REGIONAL
        objUDC = createUDC('01', '01', '4546', 'Regional', '1111', 'Standard_AR');
        lstUDCs.add(objUDC);
        //REGIONAL
        objUDC = createUDC('01', '06', '179', 'Customer Flag', '2222', 'Standard_AR');
        lstUDCs.add(objUDC);

        //REGIONAL
        objUDC = createUDC('CRM', 'DF', '05', 'Bussiness Unit', '3333', 'Standard_AR');
        lstUDCs.add(objUDC);

        //REGIONAL
        objUDC = createUDC('CRM', 'DF', '06', 'Payment Condition', '4444', 'Standard_AR');
        lstUDCs.add(objUDC);

        insert lstUDCs;
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
        
        System.debug('createUDC [' + objUDC + '] <-');

        return objUDC;    
    }

    private static User createCommunityUser() {
        Profile objProfile = null;
        Account objAccount = null;
        Contact objContact = null;
        User objUser = null;

        objProfile = retrieveProfile(PROFILE_COMMUNITY);
        objAccount = createAccount();
        objContact = createContact(objAccount);

        objUser = createUser(null, objProfile, USERNAME_1, objContact);
        insert objUser;

        return objUser; 
    }

    private static Profile retrieveProfile(String strProfile) {
        Profile objProfile = null;

        objProfile = [SELECT Id FROM Profile WHERE Name = :strProfile]; 

        return objProfile;
    }

    private static Account createAccount() {
        Account objAccount = null;
        
        objAccount = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        objAccount.Name = 'Cuenta de prueba'; 
        objAccount.Status__c = 'Cliente cadastrado no JDE';
        objAccount.Frequency_of_Visits__c = 'Semanal';
        objAccount.Client_code_AN8__c = '557799';
        objAccount.Client_country_an8__c = '6-557799';
        objAccount.Corporate_Name__c = 'Teste';
        objAccount.Checking_account__c = '000';
        objAccount.Carriers_Numbers__c = '123';
        objAccount.LAT_BR_RegionalClientOnPremise__c = 'B2B';
        objAccount.Current_account__c = '0';
        objAccount.Channel__c = 'Off Trade';
        objAccount.Price_Group__c = '1';
        objAccount.Agency__c = '000';
        objAccount.Type = 'Outros';
        objAccount.CurrencyIsoCode = 'ARS';
        objAccount.Sub_Channel_Rating__c = [SELECT Id FROM UDC__c WHERE CodProd__c = '01' AND CodUs__c = '03'].Id;
        insert objAccount;

        return objAccount;
    }

    private static Contact createContact(Account objAccount) {
        Contact objContact = null;

        objContact = new Contact();
        objContact.FirstName = 'John';
        objContact.LastName = 'Doe';
        objContact.AccountId = objAccount.Id;
        objContact.RecordtypeId = Global_RecordTypeCache.getRtId('Contact'+'CTC_Standard_AR');

        insert objContact;

        return objContact;
    }

    private static User createUser(User objManager, Profile objProfile, String strUserName, Contact objContact) {
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
        objUser.CurrencyISOCode = 'ARS';
        objUser.UserName = strUsername;
        objUser.c_digo_jde__c = 'TT';
       
        if(objContact != NULL) {
            objUser.ContactId = objContact.Id;
        }
        
        if(objManager != NULL) {
            objUser.ManagerId = objManager.Id;
            objUser.Gerente_Regional__c = objManager.Id;
            objUser.gerente_de_area__c = objManager.Id;
        }

        System.debug('retrieveUser [' + objUser + '] <-');

        return objUser;
    }

    private static LAT_Opportunity__c createOpportunity(Account objAccount){        
        LAT_Opportunity__c objOpportunity = null;

        objOpportunity = new LAT_Opportunity__c();
        objOpportunity.Name = 'Opp TESTE COTA';
        objOpportunity.LAT_CloseDate__c = Date.today().addDays(1);
        objOpportunity.LAT_Account__c = objAccount.Id;
        objOpportunity.CurrencyIsoCode = objAccount.CurrencyIsoCode;
        objOpportunity.LAT_StageName__c = 'Novo Pedido';
        objOpportunity.LAT_LeadSource__c = 'B2B';
 
        objOpportunity.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_1_NewOrder_ARG');
   
        return objOpportunity;
    }

    private static LAT_OpportunityLineItem__c createOpportunityLineItem(LAT_Opportunity__c objOpportunity, LAT_Product__c objProduct){
        LAT_OpportunityLineItem__c objOpportunityLineItem = null;
        
        objOpportunityLineItem = new LAT_OpportunityLineItem__c();
        objOpportunityLineItem.LAT_Product__c = objProduct.Id;
        objOpportunityLineItem.LAT_Opportunity__c = objOpportunity.Id;
        objOpportunityLineItem.LAT_UnitPrice__c = 12;
        objOpportunityLineItem.LAT_Quantity__c = 12;

        return objOpportunityLineItem;
    }

    private static LAT_Product__c createProduct() {
        LAT_Product__c objProduct = null;
       
        objProduct = new LAT_Product__c();
        objProduct.Name = 'TestProd';
        objProduct.LAT_IsActive__c = true;
        objProduct.LAT_CDUnit__c = 'UN';
        objProduct.LAT_ExternalId__c = '444';
        objProduct.LAT_IsRefactorProduct__c = 'Y';        
        objProduct.LAT_Sku__c = '5666';
        objProduct.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_AR' );
       
        return objProduct;
    } 

    private static LAT_Account_product_payment__c createAccountProductPayment(Account objAccount, LAT_Product__c objProduct, UDC__c objPayment){
        LAT_Account_product_payment__c objAccountProductPayment = null;
        
        objAccountProductPayment = new LAT_Account_product_payment__c();
        objAccountProductPayment.PaymentConditionDescription__c = objPayment.Name;
        objAccountProductPayment.PaymentCondition__c = objPayment.CodDefUsuario__c;
        objAccountProductPayment.Account__c = objAccount.Id;
        objAccountProductPayment.LAT_Product__c = objProduct.Id;
        objAccountProductPayment.Payment__c = objPayment.Id;
        objAccountProductPayment.ProductExternalId__c = objProduct.LAT_ExternalId__c;
        objAccountProductPayment.CustomerCountryAN8Code__c = objAccount.Client_country_AN8__c;           
        objAccountProductPayment.PaymentConditionExternalId__c = objPayment.Internal_Id__c;

        return objAccountProductPayment;   
    }

    private static LAT_FiscalNote__c createFiscalNote(Account objAccount, LAT_Opportunity__c objOpportunity, String strStatus, Boolean boolIsOverdue){
        LAT_FiscalNote__c objFiscalNote = new LAT_FiscalNote__c();

        objFiscalNote.Name = 'Test';
        objFiscalNote.LAT_Client__c = objAccount.id;
        objFiscalNote.LAT_Opportunity__c = objOpportunity.Id;
        objFiscalNote.LAT_LegalInvoice__c = 'test';
        objFiscalNote.LAT_AR_B2B_Status__c = strStatus;
        if(boolIsOverdue) {
            objFiscalNote.LAT_BillingDate__c = Date.today().addMonths(-13);
            objFiscalNote.LAT_DueDate__c = Date.today().addMonths(-13);
            objFiscalNote.LAT_Balance__c = 1000;
        } else {
            objFiscalNote.LAT_BillingDate__c = Date.today().addMonths(-13);
            objFiscalNote.LAT_DueDate__c = Date.today().addMonths(13);
            objFiscalNote.LAT_Balance__c = 1000;
        }
        
        return objFiscalNote;
    }

    private static Attachment createLegalInvoice(LAT_FiscalNote__c objFiscalNote) {
        Attachment objAttachment = null;

        objAttachment = new Attachment();
        objAttachment.ParentId = objFiscalNote.Id;
        objAttachment.Name = objFiscalNote.LAT_LegalInvoice__c;
        objAttachment.Body = Blob.valueOf('test');

        return objAttachment;        
    }

    
    @istest static void updateUserEmailPreferencesTest_OLD(){
        LAT_CTY_B2B_MyAccountController.updateUserEmailPreferences(true);
        LAT_CTY_B2B_MyAccountController.getTitulosListViewNames();
        LAT_CTY_B2B_MyAccountController.Opportunity opp =  new LAT_CTY_B2B_MyAccountController.Opportunity ('TEST', 10);
    }
    
    @isTest static void getUserEmailPreferencesTest_OLD(){
        LAT_CTY_B2B_MyAccountController.getUserEmailPreferences();
    }
    
    @isTest static void getAccountIdFromUserTest_OLD(){
        
        User u = getCommunityUser();
        Account acc = getAccount();
        Test.startTest();

        contact c = new Contact();
        c.Id = u.contactid;
        c.AccountId =acc.Id;
        update c;
        system.debug('TEST USER>>>>>>> ' + u);
        
        System.runAs(u) {
           LAT_CTY_B2B_MyAccountController.getAccountIdFromUser(); 
        }
        Test.stopTest();
    }
    
    @isTest static void getAccountDetailTest_OLD(){
        
        
        User u = getCommunityUser();
        system.debug('TEST USER>>>>>>> ' + u);
        Account acc = getAccount();

        LAT_Opportunity__c opp = getOpportunity(acc);
        insert opp;
        LAT_FiscalNote__c fn = getFiscalNote(acc);
        fn.LAT_AR_B2B_Status__c = 'A Pagar';
        fn.LAT_LegalInvoice__c = '4444433322';
        fn.LAT_Opportunity__c = opp.Id;
        insert fn;
        Test.startTest();
        contact c = new Contact();
        c.Id = u.contactid;
        c.AccountId =acc.Id;
        update c;//
        System.runAs(u) {
            try{LAT_CTY_B2B_OrderController.getOpenOrder();}catch(Exception e){}
            try{LAT_CTY_B2B_OrderController.getOpenOrder();}catch(Exception e){}
            LAT_CTY_B2B_MyAccountController.getAccountDetail(); 
            try{LAT_CTY_B2B_OrderController.getAccountDetail();}catch(Exception e){}
            try{LAT_CTY_B2B_OrderController.getAccountIdFromUser();}catch(Exception e){}
            LAT_CTY_B2B_OrderController.getPendingFiscalNotes();
            LAT_CTY_B2B_OrderController.getSemaforoStatus();
            LAT_CTY_B2B_OrderController.getBlockedClient();
            LAT_CTY_B2B_OrderController.sendOpportunityDispachedEmail(fn.Id);
            LAT_CTY_B2B_OrderController.getBlockedClient();
                  
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetProducts_OLD(){
        User u = getCommunityUser();
        system.debug('TEST USER>>>>>>> ' + u);
        Account acc = getAccount();
        Test.startTest();
        try{LAT_CTY_B2B_MyAccountController.getRelatedContacts();}catch(Exception e){}
        LAT_Product__c prod = getProduct();
        insert prod;
        insertAccProdPayment(acc, prod);
        LAT_Opportunity__c opp = getOpportunity(acc);
        insert opp;
        LAT_OpportunityLineItem__c oli = getOpportunityLineItem(opp, prod);
        insert oli;
        System.runAs(u) {
            try{LAT_CTY_B2B_OrderController.getProduct(prod.Id); }catch(Exception e){}
        try {
                LAT_CTY_B2B_OrderController.getProducts(20);
        } catch(Exception e) { 

        }
            //try{LAT_CTY_B2B_OrderController.getProductsFake();}catch(Exception e){}
            try{LAT_CTY_B2B_OrderController.getProductsDynamic('Absol');}catch(Exception e){}
            //try{LAT_CTY_B2B_OrderController.getHighlightedProducts(0);}catch(Exception e){}
            //try{LAT_CTY_B2B_OrderController.getHighlightedProductsFake(prod.Id);}catch(Exception e){}
            try{LAT_CTY_B2B_MyAccountController.getLastOpportunity();}catch(Exception e){}
            try{LAT_CTY_B2B_OrderController.getOpenOrder();}catch(Exception e){}
            try{LAT_CTY_B2B_OrderController.getOpenOrder();}catch(Exception e){}
                  
        }
        Test.stopTest();
    
    }
    @isTest
    Static void test_getContact_OLD(){
        User u = getCommunityUser();
    system.debug('TEST USER>>>>>>> ' + u);
        Account acc = getAccount();
        Test.startTest();
        contact c = new Contact();
        c.Id = u.contactid;
        c.AccountId =acc.Id;
        update c;
        System.runAs(u) {
            LAT_CTY_B2B_MyAccountController.getCaseAccountRegistrationRTId();
            LAT_CTY_B2B_MyAccountController.getContact();
        }
        Test.stopTest();

    }

    @isTest 
    static void getChartBlockedTest_OLD(){
  
        LAT_CTY_B2B_OrderController.getChartBlocked();
        LAT_CTY_B2B_OrderController.getMinimunPrice();
        LAT_CTY_B2B_OrderController.getMinimunPrice();
    }
    
    @isTest 
    static void getAllCategoriesTest_OLD(){
        LAT_CTY_B2B_OrderController.getAllCategories();
    }
    
    @isTest static void getBlockingCommentsTest_OLD(){
        LAT_CTY_B2B_OrderController.getBlockingComments();
    }
    
    
    @isTest static void updateLineItemTest_OLD(){
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        LAT_Opportunity__c opp = getOpportunity(acc);
        insert opp;
        LAT_OpportunityLineItem__c oli = getOpportunityLineItem(opp, prod);
        insert oli;
        Test.startTest();
        LAT_CTY_B2B_OrderController.updateLineItem(oli);
        LAT_CTY_B2B_OrderController.setCommentarios(opp.Id, 'TEST');
        LAT_CTY_B2B_OrderController.saveOpportunity(getOpportunity(acc), new List<LAT_OpportunityLineItem__c>{getOpportunityLineItem(opp, prod)});
        try{LAT_CTY_B2B_OrderController.getOrder(opp.Id);}catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest static void insertLineItemTest_OLD(){
        
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        LAT_Opportunity__c opp = getOpportunity(acc);
        insert opp;
        LAT_OpportunityLineItem__c oli = getOpportunityLineItem(opp, prod);
        LAT_CTY_B2B_OrderController.insertLineItem(oli);
        LAT_CTY_B2B_OrderController.deleteProductItem(oli);
        LAT_CTY_B2B_OrderController.sendConfirmationEmail(opp.Id);
        LAT_CTY_B2B_OrderController.sendOpportunityCancelledEmail(opp.Id);
        
    }
    @isTest
    static void testCloneOrderTest(){ 
        System.assertNotEquals(null, LAT_CTY_B2B_OrderController.cloneOpportunity(new LAT_Opportunity__c ()));
    }

    @isTest
    static void testReorder_OLD(){
 
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        LAT_Opportunity__c opp = getOpportunity(acc);
        insert opp;
        LAT_OpportunityLineItem__c oli = getOpportunityLineItem(opp, prod);
        insert oli;
        LAT_CTY_B2B_OrderController.reOrderOppty(opp.Id);
        
        
    }
    @isTest 
    static void getCommunityOrdersTest_OLD(){
        User u = getCommunityUser();
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        Test.startTest();
        LAT_Opportunity__c opp = getOpportunity(acc);
        opp.OwnerId = u.Id;
        LAT_Opportunity__c opp2 = getOpportunity(acc);
        opp2.OwnerId = u.Id;
        opp2.LAT_StageName__c = 'Pedido Procesado no JDE';
        insert new List<LAT_Opportunity__c>{opp, opp2};
         System.runAs(u){
            
       
            LAT_CTY_B2B_OrderController.getCommunityOrders();
            try{LAT_CTY_B2B_OrderController.getlastOrder();}catch(Exception e){}
        }
        Test.stopTest();
    }

    @isTest 
    static void test_integrateToJDE_OLD(){
        User u = getCommunityUser();
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        Test.startTest();
        LAT_Opportunity__c opp = getOpportunity(acc);
        opp.OwnerId = u.Id;
        LAT_Opportunity__c opp2 = getOpportunity(acc);
        opp2.OwnerId = u.Id;
        opp2.LAT_StageName__c = 'Pedido Procesado no JDE';
        insert new List<LAT_Opportunity__c>{opp, opp2};
        System.runAs(u){
            LAT_CTY_B2B_OrderController.getTrackingFiscalNotes();
            try{LAT_CTY_B2B_OrderController.integrateToJDE(opp.Id);}catch(Exception e){}
            try{LAT_CTY_B2B_OrderController.integrateToJDE(opp.Id, 'TEST');}catch(Exception e){}
        } 
        Test.stopTest();
    }

    @isTest
    static void test_checkStockOnline_OLD(){
        User u = getCommunityUser();
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
        LAT_Opportunity__c opp = getOpportunity(acc);
        opp.OwnerId = u.Id;
        insert new List<LAT_Opportunity__c>{opp};
        LAT_OpportunityLineItem__c oli = getOpportunityLineItem(opp, prod);
        insert oli;
        System.runAs(u){
            try{LAT_CTY_B2B_OrderController.checkStockOnline(opp.Id);}catch(Exception e){}
        }
        Test.stopTest();
    }
    @isTest
    static void test_actualizarPim_OLD(){
        User u = getCommunityUser();
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
        
        System.runAs(u){
            LAT_CTY_B2B_PendingFiscalNotesCont.getMinimunPrice();
        	LAT_Price_Channel_ARG__c priceChannel = getPriceChannel(acc.Sub_Channel_Rating__c);
            Decimal monto = LAT_CTY_B2B_PendingFiscalNotesCont.getMinimunPrice();
            
            //System.assertEquals(monto, 2345);

            LAT_CTY_B2B_PendingFiscalNotesCont.updateMinimunPrice(200);
            LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked();
            LAT_CTY_B2B_PendingFiscalNotesCont.getChartBlocked();
            LAT_CTY_B2B_PendingFiscalNotesCont.getBlockingComments();
            LAT_CTY_B2B_PendingFiscalNotesCont.getBlockingComments();
            LAT_CTY_B2B_PendingFiscalNotesCont.hablitarCarrito();
            LAT_CTY_B2B_PendingFiscalNotesCont.OperationResult res = LAT_CTY_B2B_PendingFiscalNotesCont.scheduleBlock(DateTime.now(), DateTime.now().addDays(1), 'Test bloqueo');
            LAT_CTY_B2B_UtilsController.retrieveSiteStatus();
            LAT_CTY_B2B_PendingFiscalNotesCont.listBlocks(Date.today(), Date.today().addDays(1), true);
            LAT_CTY_B2B_PendingFiscalNotesCont.updateStatus(res.Id, true);
            try{LAT_CTY_B2B_PendingFiscalNotesCont.actualizarPim();}catch(Exception e){}
            LAT_CTY_B2B_PendingFiscalNotesCont.getTrackingFiscalNotes();
        }
        Test.stopTest();
    }
    @isTest
    static void test_getFiscalNotes_OLD(){
        User u = getCommunityUser();
        system.debug('TEST USER>>>>>>> ' + u);
        Account acc = getAccount();
        LAT_FiscalNote__c fn = getFiscalNote(acc);
        fn.LAT_AR_B2B_Status__c = 'A Pagar';
        fn.LAT_LegalInvoice__c = '4444433322';
        fn.LAT_Balance__c = 12;
        insert fn;
        update fn;
        LAT_FiscalNote__c fn2 = getFiscalNote(acc);
        fn2.LAT_LegalInvoice__c = '4444433322';
        insert fn2;
        Test.startTest();
        contact c = new Contact();
        c.Id = u.contactid;
        c.AccountId =acc.Id;
        update c;
        System.runAs(u) {

            LAT_CTY_B2B_PendingFiscalNotesCont.getPaidFiscalNotes();
            LAT_CTY_B2B_PendingFiscalNotesCont.getPendingFiscalNotes();
            
        }
        Test.stopTest();
    }

    @isTest
    static void test_createPayment_OLD(){
        User u = getCommunityUser();
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
        
        System.runAs(u){
            LAT_CTY_B2B_PendingFiscalNotesCont.createB2BPayment();
            LAT_CTY_B2B_Payment__c pay = [SELECT Id FROM LAT_CTY_B2B_Payment__c LIMIT 1];
            LAT_CTY_B2B_PendingFiscalNotesCont.getPaymentsList();
            LAT_CTY_B2B_PendingFiscalNotesCont.getNotasDeCredito();
            LAT_CTY_B2B_PendingFiscalNotesCont.getInformedPayments();
            LAT_CTY_B2B_PendingFiscalNotesCont.getProcessedPayments();
            LAT_CTY_B2B_PendingFiscalNotesCont.getB2BPayment(pay.Id);
            try{LAT_CTY_B2B_PendingFiscalNotesCont.cancelarPago(pay.Id, 'TEST');}catch(Exception e){}
            try{LAT_CTY_B2B_PendingFiscalNotesCont.procesarPago(pay.Id);}catch(Exception e){}
            LAT_CTY_B2B_PendingFiscalNotesCont.deleteB2BPayment(pay.Id);
            try{LAT_CTY_B2B_PendingFiscalNotesCont.deleteAttachment(pay.Id);}catch(Exception e){}
        }
        Test.stopTest();
    }
    @isTest
    static void test_updatePayment_OLD(){
        User u = getCommunityUser();
        Account acc = getAccount();
        LAT_Product__c prod = getProduct();
        insert prod;
        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
        
        System.runAs(u){
            LAT_CTY_B2B_PendingFiscalNotesCont.createB2BPayment();
            LAT_CTY_B2B_Payment__c pay = [SELECT Id FROM LAT_CTY_B2B_Payment__c LIMIT 1];
            try{LAT_CTY_B2B_PendingFiscalNotesCont.updatePayment(pay.Id, '200', '', true, '');}catch(Exception e){}
        }
        Test.stopTest();
    }

    @isTest
    static void test_LAT_CTY_B2B_ProcessBlock_Schedulable_OLD(){
        test.startTest();
        LAT_CTY_B2B_ProcessBlock_Schedulable.updateSiteStatus();
        test.stopTest();
    }

    @isTest
    static void test_Update_URL_Calico_Trigger_OLD() {
        User u = getCommunityUser();
        Account acc = getAccount();
        LAT_Opportunity__c opp = getOpportunity(acc);
        insert opp;
        
        test.startTest();
        LAT_FiscalNote__c fn = getFiscalNote(acc);
        fn.LAT_B2B_URL_Calico__c = 'http://pernod.com';
        fn.LAT_Opportunity__c = opp.Id;
        insert fn;
        test.stopTest();
        opp = [Select ID, LAT_CTY_B2B_URL_Calico__c From LAT_Opportunity__c where id = :opp.id];
        System.assertEquals(opp.LAT_CTY_B2B_URL_Calico__c, fn.LAT_B2B_URL_Calico__c);
    }

    public static LAT_Product__c getProduct(){
        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'TestProd';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '444';
        produto.LAT_IsRefactorProduct__c = 'Y';        
        produto.LAT_Sku__c = '5666';
        produto.RecordTypeId = Global_RecordTypeCache.getRtId( 'LAT_Product__c'+'Standard_AR' );
       
        return produto;
    }   

    public static LAT_Opportunity__c getOpportunity(Account acc){
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = Date.today().addDays(1);
        opp.LAT_Account__c = acc.Id;
        opp.CurrencyIsoCode = acc.CurrencyIsoCode;
        opp.LAT_StageName__c = 'Novo Pedido';
        opp.LAT_leadSource__C = 'B2B';
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_1_NewOrder_ARG');
   
        return opp;
    }

    public static LAT_OpportunityLineItem__c getOpportunityLineItem(LAT_Opportunity__c opp, LAT_Product__c produto){
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c =opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;

        return oli;
    }
    
    public static void insertAccProdPayment(Account acc, LAT_Product__c prod){
        UDC__c paymentCondition = new UDC__c(
            Name = 'test paymentConditionA',
            CodDefUsuario__c='06', 
            CodProd__c='CRM', 
            CodUs__c='DF', 
            Internal_Id__c='1237 CRM-PT', 
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
        );
        insert paymentCondition;
        LAT_Account_product_payment__c app = new LAT_Account_product_payment__c(
            PaymentConditionDescription__c = paymentCondition.Name,
            PaymentCondition__c = paymentCondition.CodDefUsuario__c,
            Account__c = acc.Id,
            LAT_Product__c = prod.Id,
            Payment__c = paymentCondition.Id,
            ProductExternalId__c = prod.LAT_ExternalId__c,
            CustomerCountryAN8Code__c = acc.Client_country_AN8__c,           
            PaymentConditionExternalId__c = paymentCondition.Internal_Id__c
        );
        insert app;   
    }

    public static LAT_FiscalNote__c getFiscalNote(Account acc){
        LAT_FiscalNote__c fn = new LAT_FiscalNote__c( 
            Name = 'Test', 
            LAT_BillingDate__c = Date.today().addMonths(-13),
            LAT_Client__c = acc.id );
        return fn;
    }
    public static User getCommunityUser(){
        return [SELECT id, Name, profileId, contactid, CurrencyIsoCode from User where UserName = :USERNAME_1 Order By Name limit 1]; 
    }
    public static Account getAccount(){
        return [SELECT id, CurrencyIsoCode, Client_country_AN8__c, Channel__c, Sub_Channel__c, Sub_Channel_Rating__c FROM Account WHERE Channel__c != null LIMIT 1]; 
    }

    public static LAT_Price_Channel_ARG__c getPriceChannel(Id objSubchannelId) {
        LAT_Price_Channel_ARG__c priceChannel = new LAT_Price_Channel_ARG__c();
        //priceChannel.Channel__c = channel;
        //priceChannel.Sub_Channel__c = subChannel;
        priceChannel.Monto__c = 2345;
        priceChannel.LAT_SubChannel__c = objSubchannelId;
        priceChannel.LAT_Cliente_Patron__c = [SELECT Id FROM Account LIMIT 1].Id;
        insert priceChannel;
        return priceChannel;
    }
    
}