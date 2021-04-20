/******************************************************************************************
 *   Company:Valuenet    Developers: Elena J. Schwarzböck                 Date:11/12/2013 *
 ******************************************************************************************/
 /********************************************************************************
*
* MIGRACION LICENCIAS
* AUTHOR: ZIMMIC                     DATE: 11/11/2016
*
********************************************************************************/

@istest
public class LAT_MX_WS02_PriceCalculateInterface_TEST{

    @testSetup
    static void Setup() {
        insert createProcessingVersionXCountry('1');
        insert createProcessingVersionXCountry('12');
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(name ='MX_IndexMarca_Notification_Users', LAT_Value__C = '1');
        insert cfg;
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(name ='MX_DEFAULT_INDEX_MARGIN', LAT_Value__C = '2');
        insert cfg1;
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@zimmic.com');
        insert cfg2;
        LAT_CHATTER_POST_BODY__c cpb = new LAT_CHATTER_POST_BODY__c();
        cpb.Name = 'LAT_MX_ProductoSinIndexMarca';
        cpb.Body__c = 'Tests';
        insert cpb;
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;
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
            EndPoint_Customer_Credit_Status__c = 'http://crm.test.pernod-ricard.com.br/SFDC/CreditStatus/GetCustomerCreditStatusSFDCReq',
            RemoteHostIP__c = '200.200.10.10',
            Endpoint_GetStock__c = 'https://osbqa.pramericas.com/Secure/SFDC/Inventory/GetStock?wsdl',
            System__c = 'X',
            Exec_new_Price_Calc__c = false,
            SystemUserID__c = 'cloud2b'
        );

        insert cred;
    }



    public static LAT_PriceCalculationProcessingVersion__c createProcessingVersionXCountry(String country) {
        LAT_PriceCalculationProcessingVersion__c csPV = new LAT_PriceCalculationProcessingVersion__c(
            Name = 'test'+country,
            Country__c = country,
            Order_Type__c = 'SO',
            Processing_Version__c = 'ABC123');

        return csPV;
    }

    public static LAT_PriceCalculationProcessingVersion__c createProcessingVersionXCountry(String country, String orderType) {
        LAT_PriceCalculationProcessingVersion__c csPV = new LAT_PriceCalculationProcessingVersion__c(
            Name = 'test'+country,
            Country__c = country,
            Order_Type__c = orderType,
            Processing_Version__c = 'ABC123');

        return csPV;
    }
    /**
     * test to init all wrapper classes to achieve coverage
     */
    @istest
    static  void test(){
          
        LAT_BR_PriceCalculation.e1Message e1 = new LAT_BR_PriceCalculation.e1Message();
        LAT_BR_PriceCalculation.errorRecords err1 = new LAT_BR_PriceCalculation.errorRecords();
        LAT_BR_PriceCalculation.priceCatalogueDetailsInput in1 = new LAT_BR_PriceCalculation.priceCatalogueDetailsInput();
        LAT_BR_PriceCalculation.e1MessageList msg1 = new LAT_BR_PriceCalculation.e1MessageList();
        LAT_BR_PriceCalculation.BusinessServiceException_x bse1 = new LAT_BR_PriceCalculation.BusinessServiceException_x();
        LAT_BR_PriceCalculation.valueObject val1 = new LAT_BR_PriceCalculation.valueObject();
        LAT_BR_PriceCalculation.priceCatalogueHeaderInput hin1 = new LAT_BR_PriceCalculation.priceCatalogueHeaderInput();
        LAT_BR_PriceCalculation.ClientInfoType cit1 = new LAT_BR_PriceCalculation.ClientInfoType();
        LAT_BR_PriceCalculation.UsernameToken tok = new LAT_BR_PriceCalculation.UsernameToken('test','test');
        LAT_BR_PriceCalculation.SecurityHeaderType tok2 = new LAT_BR_PriceCalculation.SecurityHeaderType('test','test');
        LAT_BR_PriceCalculation.priceCatalogueDetailsOutput out1 = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput();
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput out2 = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput out5 = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_BR_PriceCalculation.messageValueObject out3 = new LAT_BR_PriceCalculation.messageValueObject();
        LAT_BR_PriceCalculation.priceCatalogueHeaderOutput out4 = new LAT_BR_PriceCalculation.priceCatalogueHeaderOutput();
        CS001_JDEInterfaceCredentials__c cred = [SELECT Country__c, RemoteHostIP__c, System__c, SystemUserID__c FROM CS001_JDEInterfaceCredentials__c LIMIT 1];

        LAT_BR_PriceCalculation.getClientInfoData(cred);
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
        out1.discountAndChargeDetails = new List<LAT_BR_PriceCalculation.discountAndChargeDetailsOutput>();
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
        Lat_Utils.generatePriceTableForLineItem(out1, '1');
        PriceCalculationInterface.getBaseDiscount(out1);
        LAT_Log__c vt1 = PriceCalculationInterface.logAsRegistry;
        LAT_DebugUtil debug1 = PriceCalculationInterface.debug;
        boolean shouldhaveError1 = PriceCalculationInterface.shouldhaveError;
        boolean shouldhaveException1 = PriceCalculationInterface.shouldhaveException;

        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');

        RestContext.response = new RestResponse();
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));

        LAT_BR_PriceCalculation.PriceCatalogueManagerPort port = new LAT_BR_PriceCalculation.PriceCatalogueManagerPort();
        port.getPriceCatalogue('05','SO','V00',new List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput>{in1},DateTime.now(),123,123,DateTime.now(),'1');
        //port.getPriceCatalogue('SO','05','SO','V00',new List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput>{in1},DateTime.now(),123,123,DateTime.now(),'1');

        Test.stopTest();

}
    @istest
    static  void test2(){
          
        LAT_BR_PriceCalculation.e1Message e1 = new LAT_BR_PriceCalculation.e1Message();
        LAT_BR_PriceCalculation.errorRecords err1 = new LAT_BR_PriceCalculation.errorRecords();
        LAT_BR_PriceCalculation.priceCatalogueDetailsInput in1 = new LAT_BR_PriceCalculation.priceCatalogueDetailsInput();
        LAT_BR_PriceCalculation.e1MessageList msg1 = new LAT_BR_PriceCalculation.e1MessageList();
        LAT_BR_PriceCalculation.BusinessServiceException_x bse1 = new LAT_BR_PriceCalculation.BusinessServiceException_x();
        LAT_BR_PriceCalculation.valueObject val1 = new LAT_BR_PriceCalculation.valueObject();
        LAT_BR_PriceCalculation.priceCatalogueHeaderInput hin1 = new LAT_BR_PriceCalculation.priceCatalogueHeaderInput();
        LAT_BR_PriceCalculation.ClientInfoType cit1 = new LAT_BR_PriceCalculation.ClientInfoType();
        LAT_BR_PriceCalculation.UsernameToken tok = new LAT_BR_PriceCalculation.UsernameToken('test','test');
        LAT_BR_PriceCalculation.SecurityHeaderType tok2 = new LAT_BR_PriceCalculation.SecurityHeaderType('test','test');
        LAT_BR_PriceCalculation.priceCatalogueDetailsOutput out1 = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput();
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput out2 = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput out5 = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_BR_PriceCalculation.messageValueObject out3 = new LAT_BR_PriceCalculation.messageValueObject();
        LAT_BR_PriceCalculation.priceCatalogueHeaderOutput out4 = new LAT_BR_PriceCalculation.priceCatalogueHeaderOutput();
        CS001_JDEInterfaceCredentials__c cred = [SELECT Country__c, RemoteHostIP__c, System__c, SystemUserID__c FROM CS001_JDEInterfaceCredentials__c LIMIT 1];

        LAT_BR_PriceCalculation.getClientInfoData(cred);
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
        out1.discountAndChargeDetails = new List<LAT_BR_PriceCalculation.discountAndChargeDetailsOutput>();
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
        Lat_Utils.generatePriceTableForLineItem(out1, '1');
        PriceCalculationInterface.getBaseDiscount(out1);
        LAT_Log__c vt1 = PriceCalculationInterface.logAsRegistry;
        LAT_DebugUtil debug1 = PriceCalculationInterface.debug;
        boolean shouldhaveError1 = PriceCalculationInterface.shouldhaveError;
        boolean shouldhaveException1 = PriceCalculationInterface.shouldhaveException;

        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');

        RestContext.response = new RestResponse();
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
        Test.stopTest();
        LAT_BR_PriceCalculation.PriceCatalogueManagerPort port = new LAT_BR_PriceCalculation.PriceCatalogueManagerPort();
        //port.getPriceCatalogue('05','SO','V00',new List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput>{in1},DateTime.now(),123,123,DateTime.now(),'1');
        port.getPriceCatalogue('SO','05','SO','V00',new List<LAT_BR_PriceCalculation.priceCatalogueDetailsInput>{in1},DateTime.now(),123,123,DateTime.now(),'1');

       

}
/*
    static testMethod void unitTest(){
        
        Utils.setMigrationDoneTest(false);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000',
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Client_code_AN8__c = '100',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );

        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'test',
            NR_customer_order__c = '100',
            CloseDate = date.today(),
            Type = 'Replenish',
            DS_Message1__c = 'test',
            DS_Message2__c = 'test',
            StageName = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );

        insert opp;

        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '444',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );

        insert prod1;

        test.startTest();
        //Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        id standardPB = Test.getStandardPricebookId();
        Pricebook2 pricebook = new Pricebook2(
            Name = '1',
            Description = '1'
        );
        insert pricebook;

        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB,
            IsActive = true,
            UseStandardPrice = false
        );

        insert pbe3;

        Utils.setMigrationDoneTest(false);
        OpportunityLineItem oli1 = new OpportunityLineItem(
            Remover__c = false,
            Quantity = 200,
            UOM_AR__c = 'CA',
            LAT_SkuText__c = '100',
            PriceBookEntryId = pbe3.Id,
            UnitPrice = 10,
            OpportunityId = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );

        List<OpportunityLineItem> listOlis = new List<OpportunityLineItem>{oli1};

        insert oli1;

        LAT_MX_WS02_PriceCalculateInterface.execute(opp.Id, listOlis);

        LAT_MX_WS02_PriceCalculateInterface.PriceCalculation(opp.Id, listOlis);

        PriceCalculationInterface.getConnectionParameter();

        test.stopTest();
    }

    static testMethod void unitTest2(){

        Utils.setMigrationDoneTest(true);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000',
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            Client_code_AN8__c = '100',
            LAT_MX_FiscalEntityType__c = 'Individual',
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );

        insert acc;

        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__C = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );

        insert opp;

        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );

        insert prod1;

        test.startTest();
        Utils.setMigrationDoneTest(false);
        LAT_OpportunityLineItem__c oli1 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );

        List<LAT_OpportunityLineItem__c> listOlis = new List<LAT_OpportunityLineItem__c>{oli1};

        insert oli1;

        LAT_MX_WS02_PriceCalculateInterface.execute(opp.Id, listOlis);

        LAT_MX_WS02_PriceCalculateInterface.LAT_PriceCalculation(opp.Id, listOlis);
        LAT_MX_WS02_PriceCalculateInterface.LAT_MX_NewPriceCalculation(opp.Id, listOlis);

        PriceCalculationInterface.getConnectionParameter();

        test.stopTest();
    }

    static testMethod void newPriceCalculation(){

        Utils.setMigrationDoneTest(true);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}

        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000',
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            Notes__c = 'TEST',
            AddressLine1_AR__c = 'TEST',
            CNPJ__c = 'LOZM701213E52',
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Client_code_AN8__c = '100',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );

        insert acc;

        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__C = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );

        insert opp;

        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );

        insert prod1;

        test.startTest();
        Utils.setMigrationDoneTest(false);
        LAT_OpportunityLineItem__c oli1 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );

        List<LAT_OpportunityLineItem__c> listOlis = new List<LAT_OpportunityLineItem__c>{oli1};

        insert oli1;

        LAT_MX_WS02_PriceCalculateInterface.execute(opp.Id, listOlis);

        LAT_MX_WS02_PriceCalculateInterface.LAT_PriceCalculation(opp.Id, listOlis);

        PriceCalculationInterface.getConnectionParameter();

        test.stopTest();
    }

    /**
     * test to init all wrapper classes to achieve coverage
     */
/*    static testMethod void MxPriceCalcTypes(){
        
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
        out2.discountOrChargeGroup = 'IVA';
        out2.discountOrChargeType = 'IVA';
        out2.ratePercentDiscountsAndCharges=1;
        out2.unitDiscountOrCharge=1;
        out5.amountDiscountOrCharge = 1;
        out5.discountOrChargeGroup = 'IEPS';
        out5.discountOrChargeType = 'IEPS';
        out5.ratePercentDiscountsAndCharges=1;
        out5.unitDiscountOrCharge=1;
        out1.discountAndChargeDetails.add(out2);
        out1.discountAndChargeDetails.add(out5);
        Lat_Utils.generatePriceTableForLineItem(out1);
    }


    static testMethod void PriceCalculationInterfaceTest2(){
        
        PriceCalculationTypes.PriceCalculationFaultType l1 = new PriceCalculationTypes.PriceCalculationFaultType();
        l1.faultCode = '0';
        l1.faultMessage = '';

        PriceCalculationTypes.PriceCalculationHeaderResponseType l2 = new PriceCalculationTypes.PriceCalculationHeaderResponseType();
        l2.customerCode = 0;

        PriceCalculationTypes.PriceCalculationHeaderRequestType l3 = new PriceCalculationTypes.PriceCalculationHeaderRequestType();
        l3.businessUnit = '';
        l3.customerCode = 0;
        l3.freightType = '';
        l3.promisedDate = system.today();
        l3.salesman = '0';

        PriceCalculationTypes.PriceCalculationItemResponseType l4 = new PriceCalculationTypes.PriceCalculationItemResponseType();
        l4.priceComponents = '';
        l4.salesPriceValue = 0;
        l4.sku = '0';

        PriceCalculationTypes.PriceCalculationItemRequestType l5 = new PriceCalculationTypes.PriceCalculationItemRequestType();
        l5.billedTotalQuantity = 0;
        l5.bonusPercentual = 0;
        l5.bonusQuantity = 0;
        l5.bonusUnit = '';
        l5.paymentTerm = '';
        l5.percentualDiscount = 0;
        l5.salesUOM = '';
        l5.sku = '0';
    }
*/

}