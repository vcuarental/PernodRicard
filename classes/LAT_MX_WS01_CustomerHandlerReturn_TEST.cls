/****************************************************
 Dev: Waldemar Mayo  Version: 1  Consulting: Valuenet
****************************************************/
@isTest

public with sharing class LAT_MX_WS01_CustomerHandlerReturn_TEST {
	
	static testmethod void unitTest(){
		UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        insert udc;
		
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
            LAT_MX_FiscalEntityType__c = 'Individual',
            Payment_Condition__c = udc.id,
            Client_code_AN8__c = '100',
            Client_country_AN8__c = '12-100',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        
        LAT_WS01_CustomerHandlerReturn.Customer cust = new LAT_WS01_CustomerHandlerReturn.Customer();
        cust.country = 12;
        cust.customer_AN8 = 100;
        cust.credCollStatus = 'C1';
        LAT_MX_WS01_CustomerHandlerReturn.updateClientByAN8(cust);
        
        LAT_WS01_CustomerHandlerReturn.Customer cust2 = new LAT_WS01_CustomerHandlerReturn.Customer();
        cust2.country = 12;
        cust2.customer_AN8 = 101;
        cust2.credCollStatus = 'C1';
        LAT_MX_WS01_CustomerHandlerReturn.updateClientByAN8(cust2);
	}
}