/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
@isTest
private class LAT_MX2_BatchAccountProductPayment_TEST {
	
static testMethod void unitTest1() {
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '12-444',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = 'MX-5666',
            LAT_IsRefactorProduct__c = 'Y',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        insert prod1;
        
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Name = '12 Dias MX - Test',
            Internal_Id__c = '12-123-CRM-PT',
            CodUs__c = 'PT',
            CodProd__c = 'CRM',
            CodDefUsuario__c = 'test'
        );
        insert udc;
                    
        Account acc = new Account(
            Name = 'TEST',
            AccountNumber = '1000', 
            Status__c = 'Novo cadastro',
            Type = 'Payer',
            Client_code_AN8__c = '100',
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        
        Test.startTest();
        LAT_MX2_BatchAccountProductPayment batch = new LAT_MX2_BatchAccountProductPayment();
        
        batch.accounts = new List<Account>{acc};
        batch.udcs = new List<UDC__c>{udc};
        
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
	
}