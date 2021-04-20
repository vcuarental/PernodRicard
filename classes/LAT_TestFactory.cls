@isTest
public class LAT_TestFactory {
	
	public static CS001_JDEInterfaceCredentials__c createCS001_JDECredentials(String countryName, String countryNumber) {
		
		return new CS001_JDEInterfaceCredentials__c(
            Name = countryName,
            Country__c = countryNumber,
            EndPoint_BalanceCheck__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/BalanceCheck/BalanceCheckProxy',
            EndPoint_ContractManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/ContractManager/ContractManagerProxy',
            EndPoint_CustomerHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerHandlerReq',
            EndPoint_CustomerVerify__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Customer/CustomerVerifyReq',
            EndPoint_PaymentManager__c = 'http://crm.test.pernod-ricard.com.br/PernodRicard/PaymentManager/PaymentManagerProxy',
            EndPoint_PriceCalculation__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Price/PriceCalculationReq',
            EndPoint_RVManager__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/RVManager/RVManagerProxy',
            EndPoint_SalesOrderHandler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/SalesOrder/AsyncSalesOrderHandlerReq',
            EndPoint_ReceiptHandeler__c = 'http://crm.test.pernod-ricard.com.br/SFDC/Collection/CollectionManagerSFDCReq',
            Endpoint_GetStock__c = 'https://osbqa.pramericas.com/Secure/SFDC/Inventory/GetStock?wsdl',
            RemoteHostIP__c = '200.200.10.10',
            System__c = 'X',
            SystemUserID__c = 'cloud2b',
            Exec_new_Price_Calc__c = true,
            Bridge_API_Key__c = 'test-key',
            Bridge_Password__c  = 'test-pass',
            Bridge_Username__c  = 'test-user',
            LAT_CheckStock__c  = false,
            LAT_JDE_Password__c  = 'test-pass',
            LAT_JDE_Username__c  = 'test-user',
            LAT_NewSalesOrderHandlerEndpoint__c = 'http://crm.test.pernod-ricard.com.br/SalesForce/ContractManager/ContractManagerProxy',
            PriceCalcProcessingVersionParam__c = 'BR000001',
            PriceCalcCompanyParam__c = '00100'
        );
	}
	
}