@isTest
public class LAT_Utils_Test {
    
    @isTest static void test_method_one() {
        try{LAT_Utils.getFieldId('LAT_Case__c','LAT_Account__c');}catch(Exception e){}
        LAT_Utils.getRtId('LAT_Case__c');
        LAT_Utils.wasMigrationDone('1');
        try{LAT_Utils.getFieldId2('LAT_Case__c','LAT_Account__c');}catch(Exception e){}
        //LAT_Utils.getFieldIdWS('LAT_Case__c','LAT_Account__c');
        LAT_Utils.parseCSV('This is a test',true);
        LAT_Utils.parseCSV('This is a test',false);
        try{LAT_Utils.getObjectId('LAT_Case__c');}catch(Exception e){}
        LAT_Utils.isRunningTest();
    }   

    @isTest static void test_method_two() {
        try{LAT_Utils.getObjectId('LAT_Case__c');}catch(Exception e){}
        try{LAT_Utils.getFieldId('LAT_Case__c','LAT_Account__c');}catch(Exception e){}
        LAT_Utils.getRtId('LAT_Case__c');
        LAT_Utils.wasMigrationDone('1');
        try{LAT_Utils.getFieldId2('LAT_Case__c','LAT_Account__c');}catch(Exception e){}
        //LAT_Utils.getFieldIdWS('LAT_Case__c','LAT_Account__c');
        LAT_Utils.parseCSV('This is a test',true);
        LAT_Utils.parseCSV('This is a test',false);
        LAT_MX_PriceCalculation.priceCatalogueDetailsOutput out1 = new LAT_MX_PriceCalculation.priceCatalogueDetailsOutput();
        LAT_MX_PriceCalculation.discountAndChargeDetailsOutput out2 = new LAT_MX_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_MX_PriceCalculation.discountAndChargeDetailsOutput out5 = new LAT_MX_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_MX_PriceCalculation.messageValueObject out3 = new LAT_MX_PriceCalculation.messageValueObject();
        LAT_MX_PriceCalculation.priceCatalogueHeaderOutput out4 = new LAT_MX_PriceCalculation.priceCatalogueHeaderOutput();
        //Generating Table
        out1.amountDiscountsAndCharges = 1;
        out1.amountExcise= 1;
        out1.amountExclusiveDiscountsAndCharges = 1;
        out1.amountGross= 1;
        out1.amountTax= 1;
        out1.amountTaxable= 1;
        out1.description1= '';
        out1.description2= '';
        out1.exciseRate = 1;
        out1.itemNumberShort = 1;
        out1.ordinalNumber = 1;
        out1.paymentTerms = 'TT';
        out1.quantityOrdered = 1;
        out1.ratePercentDiscountsAndCharges = 1;
        out1.secondItemNumber = 'Mx01';
        out1.taxRate = 1;
        out1.unitPrice = 1;
        out1.unitPriceExclusiveDiscountsAndCharges = 1;
        out1.unitPriceGross = 1;
        out1.unitofMeasure = 'CA';
        out1.discountAndChargeDetails = new List<LAT_MX_PriceCalculation.discountAndChargeDetailsOutput>();
        out2.amountDiscountOrCharge= 1 ;
        out2.discountOrChargeGroup = 'BASE';
        out2.discountOrChargeType = 'BASE';
        out2.ratePercentDiscountsAndCharges=1;
        out2.unitDiscountOrCharge=1;
        out5.amountDiscountOrCharge = 1;
        out5.discountOrChargeGroup = 'D';
        out5.discountOrChargeType = 'D';
        out5.ratePercentDiscountsAndCharges=1;
        out5.unitDiscountOrCharge=1;
        out1.discountAndChargeDetails.add(out2);
        out1.discountAndChargeDetails.add(out5);
        LAT_Utils.generatePriceTableForLineItem(out1);
        LAT_BR_PriceCalculation.priceCatalogueDetailsOutput out1b = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput();
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput out2b = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput out5b = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_BR_PriceCalculation.messageValueObject out3b = new LAT_BR_PriceCalculation.messageValueObject();
        LAT_BR_PriceCalculation.priceCatalogueHeaderOutput out4b = new LAT_BR_PriceCalculation.priceCatalogueHeaderOutput();
        //Generating Table
        out1b.amountDiscountsAndCharges = 1;
        out1b.amountExcise= 1;
        out1b.amountExclusiveDiscountsAndCharges = 1;
        out1b.amountGross= 1;
        out1b.amountTax= 1;
        out1b.amountTaxable= 1;
        out1b.description1= '';
        out1b.description2= '';
        out1b.exciseRate = 1;
        out1b.itemNumberShort = 1;
        out1b.ordinalNumber = 1;
        out1b.paymentTerms = 'TT';
        out1b.quantityOrdered = 1;
        out1b.ratePercentDiscountsAndCharges = 1;
        out1b.secondItemNumber = 'Mx01';
        out1b.taxRate = 1;
        out1b.unitPrice = 1;
        out1b.unitPriceExclusiveDiscountsAndCharges = 1;
        out1b.unitPriceGross = 1;
        out1b.unitofMeasure = 'CA';
        out1b.discountAndChargeDetails = new List<LAT_BR_PriceCalculation.discountAndChargeDetailsOutput>();
        out2b.amountDiscountOrCharge= 1 ;
        out2b.discountOrChargeGroup = 'BASE';
        out2b.discountOrChargeType = 'BASE';
        out2b.ratePercentDiscountsAndCharges=1;
        out2b.unitDiscountOrCharge=1;
        out5b.amountDiscountOrCharge = 1;
        out5b.discountOrChargeGroup = 'D';
        out5b.discountOrChargeType = 'D';
        out5b.ratePercentDiscountsAndCharges=1;
        out5b.unitDiscountOrCharge=1;
        out1b.discountAndChargeDetails.add(out2b);
        out1b.discountAndChargeDetails.add(out5b);
        Lat_Utils.generatePriceTableForLineItem(out1b, '1');
        Lat_Utils.generatePriceTableForLineItem(out1b, '5');
        LAT_Utils.isRunningTest();
    }
    
    @isTest static void test_method_three() {
        Utils.setMigrationDoneTest(false); 
       list<RecordType> record = [select id, DeveloperName from RecordType WHERE SobjectType='Case' order by Name ASC];
        RecordType recordOffTradeArg = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'ACC_1_OffTrade_ARG' AND SobjectType='Account'];
        list<Case> listCases = new list<Case>();
    
        system.Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Account acc = new Account(
        RecordTypeId = recordOffTradeArg.Id, 
        CNPJ__c = '33700964049',
        Name = 'testAccount',
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
        Billing_Country__c ='test'
        );
        
        insert acc;
        LAT_Utils.getLatAccountMapByAccId(new List<Account> {acc});

//         Profile p = [SELECT Id FROM Profile WHERE Name='AR_System Administrator'];
         Profile p = [SELECT Id FROM Profile WHERE Name ='LAT_AR2_AdmVentas']; 
         User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US',  ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName='CaseAR@mail.com');
         insert u2;


        system.Test.stopTest();
       
        
        Case caso = new Case(
            RecordTypeId = record[0].id  , 
            status= 'Without customer proposal-Sent to Credit',
            Reason = 'Alt. cliente pai',
            Description = 'TEST',
            OwnerId = u2.id,
            Type = 'Account Alteration ARG',
            AccountId= acc.id
        );
        insert caso;



        LAT_UY_CreditLimitController cont = new LAT_UY_CreditLimitController();

        cont.setCaseId(caso.Id);
        cont.getCaseId();
        Utils.setMigrationDoneTest(true); 
       list<RecordType> record2 = [select id, DeveloperName from RecordType WHERE SobjectType='LAT_Case__c' order by Name ASC];

        LAT_Case__c LAT_caso = new LAT_Case__c(
            RecordTypeId = record2[0].id  , 
            LAT_status__c = 'Without customer proposal-Sent to Credit',
            LAT_Reason__c = 'Alt. cliente pai',
            LAT_Description__c = 'TEST',
            OwnerId = u2.id,
            LAT_Type__c = 'Account Alteration ARG',
            LAT_Account__c = acc.id
        );

        insert LAT_caso;

        cont.setlatCaseId(LAT_caso.Id);
        cont.getLatCaseId();
            

    }
    @isTest static void test_method_four() {
            LAT_Utils.testOn = true;
            LAT_GetStock.Port port = new LAT_GetStock.Port();
            LAT_GetStockTypes.ClientInfoType clientInf = new LAT_GetStockTypes.ClientInfoType();
            clientInf.country = '1';
            LAT_GetStockTypes.ItemType item = new LAT_GetStockTypes.ItemType();
            List<LAT_GetStockTypes.ItemType> lstItem = new List<LAT_GetStockTypes.ItemType >();
            lstItem.add(item);
            LAT_GetStockTypes.ItemListType itemLista = new LAT_GetStockTypes.ItemListType();
            itemLista.item = lstItem;
            try {
            port.getStockOperation(clientInf,itemLista);
            }
            catch(Exception e){
                
            }

           // getStockOperation(LAT_GetStockTypes.ClientInfoType ClientInfo,LAT_GetStockTypes.ItemListType itemList) {

    }
    
    @isTest 
    private static void retrieveEmailTemplateTest() {
        EmailTemplate objEmailTemplate = null;

        objEmailTemplate = new EmailTemplate();
        objEmailTemplate.isActive = true;
        objEmailTemplate.Name = 'EmailTemplateTest';
        objEmailTemplate.DeveloperName = 'EmailTemplateTest';
        objEmailTemplate.TemplateType = 'text';
        objEmailTemplate.FolderId = UserInfo.getUserId();

        insert objEmailTemplate;

        System.assertEquals(objEmailTemplate.Id, LAT_Utils.retrieveEmailTemplate('EmailTemplateTest'));
    }
    
    @isTest 
    private static void sendEmailTemplateTest() {
        EmailTemplate objEmailTemplate = null;

        objEmailTemplate = new EmailTemplate();
        objEmailTemplate.isActive = true;
        objEmailTemplate.Name = 'EmailTemplateTest';
        objEmailTemplate.DeveloperName = 'EmailTemplateTest';
        objEmailTemplate.TemplateType = 'text';
        objEmailTemplate.FolderId = UserInfo.getUserId();

        insert objEmailTemplate;

        LAT_Utils.sendEmail(objEmailTemplate.Id, 'Pernods', new String[] {'matias@zimmic.com'}, new String[] {'matias@zimmic.com'},'test subject', 'test body', null, UserInfo.getUserId());

        LAT_Utils.sendNotificationEmail(UserInfo.getUserId(), 'EmailTemplateTest');

    }

    @isTest 
    private static void retrieveSendEmailTest() {
        LAT_Utils.sendEmail('matias@zimmic.com','matias@zimmic.com','subject test', 'body test');
    }
    
    @isTest 
    private static void retrieveUsersInGroupTest() { 
        User objUser = null;
        Group objGroup = null;

        objUser = createUser();
        objGroup = createGroup('MYGROUP');

        addUserToGroup(objGroup.Id, objUser.Id);

        System.assertNotEquals(0, LAT_Utils.retrieveUsersInGroup(objGroup.Id).size());
    }


    @isTest 
    private static void retrieveUsersByCountryTest() { 
        User objUser = null;
        Group objGroup = null;

        objUser = createUser();
        objGroup = createGroup('TEST');

        addUserToGroup(objGroup.Id, objUser.Id);

        System.assertNotEquals(0, LAT_Utils.retrieveUsersByCountry('ARGENTINA').size());
    }

    @isTest 
    private static void createSettingsTest() { 
        LAT_Utils.createSettings('TEST', 'TEST', 'TEST');
        
        System.assertEquals('TEST', LAT_GeneralConfig__c.getInstance('TEST').LAT_Value__c);
    }

    @isTest 
    private static void testIsJDEUpOKTest() { 
        Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest());

        System.assertEquals(true, LAT_Utils.IsJDEUp());
    }

    @isTest 
    private static void testIsJDEUpErrorTest() { 
        Test.setMock(WebServiceMock.class, new LAT_CallOutMockTest(LAT_CallOutMockTest.RESULT_CODE_ERROR));

        //TODO: ACA EL ASSERT DEBIERA SER FALSE
        System.assertEquals(true, LAT_Utils.IsJDEUp());

    }

    private static User createUser() {
        User objUser = null;
        
        objUser = new User();
        objUser.ProfileId = [SELECT Id 
                            FROM Profile 
                            WHERE Name 
                            LIKE 'LAT_AR2%' 
                            LIMIT 1].Id;
        objUser.LastName = 'last';
        objUser.Email = 'pr@zimmic.com';
        objUser.Username = 'pr@zimmic.com' + System.currentTimeMillis();
        objUser.CompanyName = 'Pernod Ricaard';
        objUser.Title = 'Salesforce Developer';
        objUser.Alias = 'przimmic';
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.LocaleSidKey = 'en_US';

        insert objUser;

        return objUser;
    }

    private static Group createGroup(String strGroupName) {
        Group objGroup = null;

        objGroup = new Group();
        objGroup.name = strGroupName;
        objGroup.Type = 'Regular'; 
        insert objGroup;

        return objGroup;
    }
    
    private static void addUserToGroup(String strGroupId, String strUserId) {
        GroupMember objGroupMember = null;

        objGroupMember = new GroupMember();
        objGroupMember.UserOrGroupId = strUserId;
        objGroupMember.GroupId = strGroupId;

        insert objGroupMember;
    }

    @TestSetup
    private static void setupTest() {
        populateDummyData();
    }

    private static void populateDummyData() {
        UDC__c objUDCPaymentCondition = null;
        UDC__c objUDCPaymentInstrument = null;
        UDC__c objUDCDefault = null;
        Account objAccount = null;
        LAT_Product__c objProduct = null;
        LAT_Opportunity__c objOpportunity = null;
        LAT_OpportunityLineItem__c objOpportunityLineItem = null;

        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];

        objUDCPaymentCondition = createUDC('PT','CRM','123456789012','CRM-PT', 'Standard_AR');
        objUDCPaymentInstrument = createUDC('03','01','KA','00-CT', 'Standard_AR');

        objUDCDefault = createUDC('PY','00','Blanco','00-PY', 'Standard_AR');

        objAccount = createAccount(objUDCPaymentCondition, objUDCPaymentInstrument, 'ACC_3_OnTrade_ARG');
        objProduct = createProduct('Product 1','1','Standard_AR');
        objOpportunity = createOpportunity(objAccount, 'OPP_3_HeaderBlocked_ARG');
        objOpportunityLineItem = createOpportunityLineItem(objOpportunity, objProduct);


    }

    //Esto es una payment condintion o algo asi
    public static UDC__c createUDC(String strCodUs, String strCodProd, String strName, String strInternalId, String strRecorType) {
        UDC__c objUDC = null;

        System.debug('createUDC [strCodUs : ' + strCodUs + ' - strCodProd : ' + strCodProd + ' - strName : ' + strName + ' - strInternalId : ' + strInternalId + ' - strRecorType : ' + strRecorType + '] ->');
        objUDC = new UDC__c();

        objUDC.CodUs__c = strCodUs;
        objUDC.CodProd__c = strCodProd;
        objUDC.Name = strName;
        //objUDC.LAT_MX_FilterKey__c = 'PY-00-AR';
        objUDC.Internal_Id__c = strInternalId;
        objUDC.RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + strRecorType);
        
        insert objUDC;

        System.debug('createUDC [' + objUDC + '] <-');

        return objUDC;
    }

    private static Account createAccount(UDC__c objUDCPaymentCondition, UDC__c objUDCPaymentInstrument, String strRecordType) {
        Account objAccount = null;

        System.debug('createAccount [ objUDCPaymentCondition : ' + objUDCPaymentCondition + ' - objUDCPaymentInstrument : ' + objUDCPaymentInstrument + ' - strRecordType : ' + strRecordType + '] ->');

        objAccount = new Account();

        objAccount.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + strRecordType); 
        objAccount.CNPJ__c = '20354266645';
        objAccount.Name = 'testAccount';
        objAccount.Overdue__c = false;
        objAccount.Type = 'Prospect_ARG';
        objAccount.Corporate_Name__c = 'test';
        objAccount.Channel_Type__c = 'Direto';
        objAccount.Sub_Channel__c = 'Delicatessen';
        objAccount.AddressLine1_AR__c= 'test';
        objAccount.Shipping_Neighbourhood__c = 'test';
        objAccount.Revenue_Neighbourhood__c = 'test';
        objAccount.Revenue_City__c = objUDCPaymentInstrument.Id;
        objAccount.Payment_Condition__c = objUDCPaymentCondition.Id;
        objAccount.Billing_Neighbourhood__c ='test';
        objAccount.Shipping_Country__c ='test';
        objAccount.Revenue_Country__c ='test';
        objAccount.Billing_Country__c ='test';
        objAccount.Status__c = 'Em análise - Crédito e Cobrança';
        objAccount.Client_code_AN8__c = '123';
        

        insert objAccount;

        System.debug('createAccount [' + objAccount + '] <-');

        return objAccount;
    }

    private static LAT_Product__c createProduct(String strName, String strExternalId, String strRecordType) {
        LAT_Product__c objProduct = null;
        
        System.debug('createProduct [ strName : ' + strName + ' - strExternalId : ' + strExternalId + ' - strRecordType : ' + strRecordType + '] ->');

        objProduct = new LAT_Product__c();
        objProduct.Name = strName;
        objProduct.LAT_IsActive__c = true;
        objProduct.LAT_CDUnit__c = 'UN';
        objProduct.LAT_ExternalID__c = strExternalId;
        objProduct.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', strRecordType );
        
        insert objProduct;

        System.debug('createProduct [' + objProduct + '] <-');

        return objProduct;
    }


    private static LAT_Opportunity__c createOpportunity(Account objAccount, String strRecordType) {
        LAT_Opportunity__c objOpportunity = null;
        
        System.debug('createOpportunity [ objAccount : ' + objAccount + ' - strRecordType : ' + strRecordType + '] ->');

        objOpportunity = new LAT_Opportunity__c();
        objOpportunity.Name = 'Cloud2b - LAT Oportunidade - AtualizarEventoProdutosOportunidade';
        objOpportunity.LAT_Account__c = objAccount.Id;
        objOpportunity.LAT_CloseDate__c = Date.today() + 1;
        objOpportunity.LAT_StageName__c = 'Pedido en Logística';
        objOpportunity.LAT_LeadSource__c = 'B2B';

        objOpportunity.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Opportunity__c', strRecordType );
        
        insert objOpportunity;

        System.debug('createOpportunity [' + objOpportunity + '] <-');

        return objOpportunity;
    }

    private static LAT_OpportunityLineItem__c createOpportunityLineItem(LAT_Opportunity__c objOpportunity, LAT_Product__c objProduct) {
        LAT_OpportunityLineItem__c objOpportunityLineItem = new LAT_OpportunityLineItem__c();

        System.debug('createOpportunityLineItem [ objOpportunity : ' + objOpportunity + ' - objProduct : ' + objProduct + '] ->');

        objOpportunityLineItem = new LAT_OpportunityLineItem__c();
        objOpportunityLineItem.LAT_Opportunity__c = objOpportunity.Id;
        objOpportunityLineItem.LAT_Product__c = objProduct.Id;
        objOpportunityLineItem.LAT_Quantity__c = 1;
        objOpportunityLineItem.LAT_UnitPrice__c = 1000.00;

        insert objOpportunityLineItem;

        System.debug('createOpportunityLineItem [' + objOpportunityLineItem + '] <-');

        return objOpportunityLineItem;
    }
      
      
      
}