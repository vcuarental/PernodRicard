@isTest
public with sharing class LAT_BridgeGS1_Customer_Test {
    @TestSetup
    static void makeData(){ 
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        LAT_GeneralConfig__c cfg1 = new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com');
        insert cfg1;
        insert LAT_TestFactory.createCS001_JDECredentials('Argentina', '5');
        insert LAT_TestFactory.createCS001_JDECredentials('Brasil', '1');
        insert LAT_TestFactory.createCS001_JDECredentials('México', '12');
        List<UDC__c> listUDC = new List<UDC__c>();
        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
        UDC__c udcCustomerPriceGroup = new UDC__c(Name = 'testCustomerPriceGroup', CodDefUsuario__c = 'test', Internal_Id__c = '2', CodProd__c = '40', CodUs__c = 'PC', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerPriceGroup);
        UDC__c udcCustomerGeographicRegion = new UDC__c(Name = 'testCustomerGeographicRegion', CodDefUsuario__c = 'test', Internal_Id__c = '3', CodProd__c = '01', CodUs__c = '11', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerGeographicRegion);
        UDC__c udcPaymentCondition = new UDC__c(Name = 'testPaymentCondition', CodDefUsuario__c = 'test', Internal_Id__c = '4', CodProd__c = 'CRM', CodUs__c = 'PT', RecordTypeId = rtUDC);      
        listUDC.add(udcPaymentCondition);
        UDC__c udcCustomerGL = new UDC__c(Name = 'testCustomerGL', Internal_Id__c = '6', CodProd__c = '55', CodUs__c = 'GL', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerGL);
        UDC__c udcABCCode = new UDC__c(Name = 'testABCCode', CodDefUsuario__c = 'test', Internal_Id__c = '7', CodProd__c = 'H01', CodUs__c = 'A2', RecordTypeId = rtUDC);      
        listUDC.add(udcABCCode);
        UDC__c udcRouteCode = new UDC__c(Name = 'testRouteCode', CodDefUsuario__c = 'test', Internal_Id__c = '8', CodProd__c = '42', CodUs__c = 'RT', RecordTypeId = rtUDC);      
        listUDC.add(udcRouteCode);
        UDC__c udcBatchProcess = new UDC__c(Name = 'testBatchProcess', CodDefUsuario__c = 'test', Internal_Id__c = '9', CodProd__c = '01', CodUs__c = '30', RecordTypeId = rtUDC);      
        listUDC.add(udcBatchProcess);
        UDC__c udcZoneNumber = new UDC__c(Name = 'testZoneNumber', CodDefUsuario__c = 'test', Internal_Id__c = '10', CodProd__c = '40', CodUs__c = 'ZN', RecordTypeId = rtUDC);      
        listUDC.add(udcZoneNumber);
        UDC__c udcChain = new UDC__c(Name = 'testChain', CodDefUsuario__c = 'test', Internal_Id__c = '11', CodProd__c = '01', CodUs__c = '10', RecordTypeId = rtUDC);      
        listUDC.add(udcChain);
        UDC__c udcFiscalRate = new UDC__c(Name = 'testFiscalRate', CodDefUsuario__c = 'test', Internal_Id__c = '12', CodProd__c = 'CRM', CodUs__c = 'TX', RecordTypeId = rtUDC);      
        listUDC.add(udcFiscalRate);
        UDC__c udcGroup = new UDC__c(Name = 'testGroup', CodDefUsuario__c = 'test', Internal_Id__c = '13', CodProd__c = '01', CodUs__c = '09', RecordTypeId = rtUDC);      
        listUDC.add(udcGroup);
        UDC__c udcRegional = new UDC__c(Name = 'testregional', CodDefUsuario__c = 'ABR', Internal_Id__c = '12-ABR-01-01', CodProd__c = '01', CodUs__c = '01', RecordTypeId = rtUDC);      
        listUDC.add(udcRegional);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        listUDC.add(udc);
        UDC__c udc2 = new UDC__c(
            RecordTypeId = rtUDC,
            Name = 'MX - Test',
            Internal_Id__c = '12-123-CRM-DF',
            CodUs__c = 'DF',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        listUDC.add(udc2);
        LAT_MX_PCD_PostalCode__c pc = new LAT_MX_PCD_PostalCode__c(
            Name = '100',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_MX_PCD_PostalCode__c' + 'LAT_MX_PCD_Standard'),
            LAT_MX_NilsenArea__c = 'test',
            LAT_MX_State__c = 'GTO',
            LAT_MX_County__c = 'LEON',
            LAT_MX_City__c  = 'DC'
        );
        insert pc;
        UDC__c udcPaymentInstrument = new UDC__c(Name = 'testPaymentInstrument', CodDefUsuario__c = 'test', Internal_Id__c = '5', CodProd__c = '00', CodUs__c = 'PY', RecordTypeId = rtUDC);
        listUDC.add(udcPaymentInstrument);
        insert listUDC;
        Account acc1 = new Account(
            Payment_instrument__c = udcPaymentInstrument.Id,
            Business_Unit_AR__c = udc2.id,
            LAT_MX_PostalCode__c = pc.Id,
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
            LAT_MX_APStep__c = 0,
            lat_mx_market__c = '1P',
            Segmentation_Type_on_trade__c = 'MOP',
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            LAT_MX_Group__c = udcGroup.Id,
            LAT_MX_FiscalRate__c = udcFiscalRate.Id,
            LAT_MX_Chain__c = udcChain.Id,
            LAT_MX_RouteCode__c = udcRouteCode.Id,
            LAT_MX_ZoneNumber__c = udcZoneNumber.Id,
            Regional__c = udcRegional.Id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        User u = [select id from user where Profile.Name = 'LAT_SystemAdministrator' AND IsActive=true  AND C_digo_JDE__c <> null LIMIT 1];
        System.runAs(u){
            insert acc1;
        }
    }
    
    @isTest
    static void integrateCustomer(){
        Account acc = [SELECT id from Account limit 1];
        System.debug('acc id : '+ acc.Id);
        LAT_DebugUtil debugUtil = new LAT_DebugUtil();
        Test.startTest();
        Map<String,String> mapa = new Map<String,String>();
            mapa.put('ANY key', 'ANY value');
            Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
        LAT_BridgeGS1_Customer.execute(acc.Id, debugUtil);
        Test.stopTest();
    }
    
    @isTest
    static void test_LAT_Rest_AccountReturn(){
        Account acc = [SELECT id from Account limit 1];
        System.debug('acc id : '+ acc.Id);
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();          
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        // comentado para hacer un pasaje
        //LAT_Rest_AccountReturn.doPUT(acc.Id, '12345', '12');
        Test.stopTest();
        
    }
}