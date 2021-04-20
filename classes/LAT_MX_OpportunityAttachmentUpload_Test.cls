@isTest
public with sharing  class LAT_MX_OpportunityAttachmentUpload_Test {
	@testSetup
    public static void testSetup() {
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        LAT_GeneralConfig__c cfg2 = new LAT_GeneralConfig__c(name ='MX_UnitConvRates_Notification_Users', LAT_Value__C = 'test@test.com');
        insert cfg2;
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
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='06',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='123456789013',  RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'));
        
        insert udc;
        insert paymentCondition;

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
            SaveDuplicatedFiscalID_AR__c = true,
            Payment_Condition__c = udc.id,
            Client_code_AN8__c = '100',
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
    }

   	@isTest
   	static void unitTestb() {
        Utils.setMigrationDoneTest(true);
        
        Account acc = [SELECT Id FROM Account LIMIT 1];

        LAT_Account__c latAcc = [SELECT Id, LAT_ID_Status__c FROM LAT_Account__c LIMIT 1];
        latAcc.LAT_ID_Status__c = 'Activo';
        update latAcc;

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
        
        Test.startTest();
        insert opp;
       

        LAT_MX_OpportunityAttachmentUpload cont = new LAT_MX_OpportunityAttachmentUpload();
        LAT_MX_OpportunityAttachmentUpload.salir();
        LAT_MX_OpportunityAttachmentUpload.OppWrapper wrapper = new LAT_MX_OpportunityAttachmentUpload.OppWrapper(opp);
        cont.buscarOpportunities();
        cont.dummyOpp = opp;
        cont.buscarOpportunities();
        cont.opportunitiesFound[0].isSelected = true;
        cont.upload();
        cont.agregarOpportunities();
        
        try{cont.quitarPedidoDeSeleccion();}catch (Exception e){}

        
        Test.stopTest();   
       
    }





}