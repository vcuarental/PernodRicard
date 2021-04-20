/******************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck               Date:21/10/2013  *
*******************************************************************************************/
@istest
public with sharing class LAT_MX_WS01_CustomerHandlerInterfac_TEST {

    static testMethod void unitTest(){
    
        String rtOffMX = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
                    
        //String[] profileNames = = LAT_GeneralConfigDao.getValueAsStringArray('LAT_SYSADMIN_PROFILES', ' , ');
     
        Id usuarioId = UserInfo.getUserId();
        
        String rtUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard');
        
        List<UDC__c> listUdc = new List<UDC__c>();
        
        UDC__c udcCustomerPriceGroup = new UDC__c(Name = 'testCustomerPriceGroup', Internal_Id__c = '2', CodProd__c = '40', CodUs__c = 'PC', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerPriceGroup);
        UDC__c udcCustomerGeographicRegion = new UDC__c(Name = 'testCustomerGeographicRegion', Internal_Id__c = '3', CodProd__c = '01', CodUs__c = '11', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerGeographicRegion);
        UDC__c udcPaymentCondition = new UDC__c(Name = 'testPaymentCondition', Internal_Id__c = '4', CodProd__c = 'CRM', CodUs__c = 'PT', RecordTypeId = rtUDC);      
        listUDC.add(udcPaymentCondition);
        UDC__c udcPaymentInstrument = new UDC__c(Name = 'testPaymentInstrument', Internal_Id__c = '5', CodProd__c = '00', CodUs__c = 'PY', RecordTypeId = rtUDC);      
        listUDC.add(udcPaymentInstrument);
        UDC__c udcCustomerGL = new UDC__c(Name = 'testCustomerGL', Internal_Id__c = '6', CodProd__c = '55', CodUs__c = 'GL', RecordTypeId = rtUDC);      
        listUDC.add(udcCustomerGL);
        UDC__c udcABCCode = new UDC__c(Name = 'testABCCode', Internal_Id__c = '7', CodProd__c = 'H01', CodUs__c = 'A2', RecordTypeId = rtUDC);      
        listUDC.add(udcABCCode);
        UDC__c udcRouteCode = new UDC__c(Name = 'testRouteCode', Internal_Id__c = '8', CodProd__c = '42', CodUs__c = 'RT', RecordTypeId = rtUDC);      
        listUDC.add(udcRouteCode);
        UDC__c udcBatchProcess = new UDC__c(Name = 'testBatchProcess', Internal_Id__c = '9', CodProd__c = '01', CodUs__c = '30', RecordTypeId = rtUDC);      
        listUDC.add(udcBatchProcess);
        UDC__c udcZoneNumber = new UDC__c(Name = 'testZoneNumber', Internal_Id__c = '10', CodProd__c = '40', CodUs__c = 'ZN', RecordTypeId = rtUDC);      
        listUDC.add(udcZoneNumber);
        UDC__c udcChain = new UDC__c(Name = 'testChain', Internal_Id__c = '11', CodProd__c = '01', CodUs__c = '10', RecordTypeId = rtUDC);      
        listUDC.add(udcChain);
        UDC__c udcFiscalRate = new UDC__c(Name = 'testFiscalRate', Internal_Id__c = '12', CodProd__c = 'CRM', CodUs__c = 'TX', RecordTypeId = rtUDC);      
        listUDC.add(udcFiscalRate);
        UDC__c udcGroup = new UDC__c(Name = 'testGroup', Internal_Id__c = '13', CodProd__c = '01', CodUs__c = '09', RecordTypeId = rtUDC);      
        listUDC.add(udcGroup);
        
        insert listUDC;
        
        Account acc = new Account(
            OwnerId = usuarioId,
            Name = 'Test',
            Customer_Geographic_Region__c = udcCustomerGeographicRegion.Id,
            Payment_Condition__c = udcPaymentCondition.Id,
            Payment_instrument__c = udcPaymentInstrument.Id,
            Customer_GL__c = udcCustomerGL.Id,
            LAT_MX_ABCCode__c = udcABCCode.Id,
            LAT_MX_RouteCode__c = udcRouteCode.Id,
            LAT_MX_BatchProcess__c = udcBatchProcess.Id,
            LAT_MX_ZoneNumber__c = udcZoneNumber.Id,
            LAT_MX_Chain__c = udcChain.Id,
            LAT_MX_FiscalRate__c = udcFiscalRate.Id,
            LAT_MX_Group__c = udcGroup.Id,
            CNPJ__c = 'ETE9510126P1',
            AccountNumber = '1000',
            Status__c = 'Cliente cadastrado no JDE', 
            Type = 'Payer',
            Phone = '1-11-1111-1111',
            Fax = '11-1111-1111',
            LAT_MX_FiscalEntityType__c = 'Company',
            RecordTypeId = rtOffMX,
            Corporate_Name__c = 'TEST',
            Channel__c = 'WS',
            Segmentation_Type_on_trade__c = 'MOP',
            CurrencyISOCode = 'MXN'
        );
        insert acc;
                        
        LAT_MX_WS01_CustomerHandlerInterface.CustomerInterfaceJDE(acc.Id);
                
        CS001_JDEInterfaceCredentials__c cred = new CS001_JDEInterfaceCredentials__c(
            Name = 'México',
            Country__c = '12',
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
            SystemUserID__c = 'cloud2b'
        );
        
        insert cred;

        
        User admin = new User();
        admin = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
		insert admin;
        system.runas(admin){ 
            PermissionSet permission = [Select id from PermissionSet where name = 'LAT_SOA_DATA_LOAD'];
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permission.id, AssigneeId = admin.id);
            insert psa; 
        }
        
        system.runas(admin){
        
            acc.LAT_MX_FiscalEntityType__c = 'Individual';
            acc.Client_code_AN8__c = '100';
            acc.Accept_line_incompleted__c = false;
            acc.Accept_Backorder__c = true;
            acc.CNPJ__c = 'MEGA720521H92';
            
            update acc;
        }
        
        System.Test.startTest();
        
        LAT_MX_WS01_CustomerHandlerInterface.sendSuccessEmail(acc);
        
        System.Test.stopTest();

        

    }
    
}