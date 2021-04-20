@isTest
public class LAT_VerifyPendingOpportunities_Test {
	
	static testMethod void UnitTest1(){
        
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;
        
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
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        insert acc;
        
        acc.Client_code_AN8__c = '100';
        update acc;
        
        Test.startTest();
        
        LAT_GeneralConfig__c cfg = new LAT_GeneralConfig__c(
			name = 'OPP_Verification_Email_Recipients',
			lat_value__c = 'test@zimmic.com,test@zimmic.com');
		insert cfg;
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(
			name = 'LAT_ACCOUNT_VERIFICATION_QUERY',
			lat_value__c = 'SELECT Id, Name FROM Account LIMIT 1');
		insert cfg2;
        String[] mails  = LAT_GeneralConfigDao.getValueAsStringArray('OPP_Verification_Email_Recipients',',');
        System.debug('%%%%% mails : '+mails);
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
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
        
       	opp.LAT_IsAdmin__c = true;
        opp.LAT_StageName__c = 'Pedido enviado para o JDE';
        update opp;
        
        LAT_VerifyPendingOpportunities myClass = new LAT_VerifyPendingOpportunities();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        Test.stopTest();
	}
	
}