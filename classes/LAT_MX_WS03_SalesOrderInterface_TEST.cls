/****************************************************************************
 *   Company:Valuenet  Developers: Elena J. Schwarzböck   Date:11/12/2013   *
 ****************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 11/11/2016
*
********************************************************************************/


@istest(seeAllDAta=false)
public class LAT_MX_WS03_SalesOrderInterface_TEST{
    
    @testSetup
    static void setup() {
        LAT_CHATTER_POST_BODY__c lg = new LAT_CHATTER_POST_BODY__c();
        lg.Name = 'LAT_MX_OPP_Integrada_JDE';
        lg.Body__c = 'xx_KAM_NAME_xx ha creado el pedido CRM xx_PEDIDO_LINK_xx y pedido JDE xx_NR_JDE_xx para el cliente xx_AN8_AND_CLIENT_NAME__xx con fecha deseada de entrega xx_EXPECTED_DATE__xx.';
        insert lg;
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
    }

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
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;

        System.Test.startTest();                    
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
            Campo_de_formatacao__c = 'test',
            LAT_MX_KAMPromisedDate__c = date.today()
        );
                
        insert oli1;
        
        
        LAT_MX_WS03_SalesOrderHandlerInterface.SalesOrderInterfaceFuture(opp.Id);
        
        System.Test.stopTest();
        
    }
    
    static testMethod void unitTest2(){
        Utils.setMigrationDoneTest(true);
        createGeneralConfigSettings();
        
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
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
	
		LAT_ACCOUNT__c objAccount = [SELECT LAT_ID_Status__c FROM LAT_ACCOUNT__c WHERE LAT_AccountId__c =: acc.Id];
        objAccount.LAT_ID_Status__c = 'Activo';
        update objAccount;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            LAT_IsAdmin__c = true,
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

        System.Test.startTest();
        Utils.setMigrationDoneTest(true);
                
        
        LAT_OpportunityLineItem__c oli1 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_FormatField__c = 'test',
            LAT_MX_KAMPromisedDate__c = date.today()
        );
                
        insert oli1;
        
        
        LAT_MX_WS03_SalesOrderHandlerInterface.SalesOrderInterfaceFuture(opp.Id);
        
        System.Test.stopTest();
        
    }
    
    static testMethod void unitTest3(){
        insert createGeneralConfigSetting('MX_USE_BRIDGE_IN_SALESORDER','true');
        
        Utils.setMigrationDoneTest(true);
        createGeneralConfigSettings();
        
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
            Payment_Condition__c = udc.id,
            RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')
        );
        
        insert acc;
	
		LAT_ACCOUNT__c objAccount = [SELECT LAT_ID_Status__c FROM LAT_ACCOUNT__c WHERE LAT_AccountId__c =: acc.Id];
        objAccount.LAT_ID_Status__c = 'Activo';
        update objAccount;
        
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            LAT_IsAdmin__c = true,
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

        System.Test.startTest();
        Utils.setMigrationDoneTest(true);
                
        
        LAT_OpportunityLineItem__c oli1 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 200,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '100',
            LAT_Product__c = prod1.Id,
            LAT_UnitPrice__c = 10,
            LAT_Opportunity__c = opp.Id,
            LAT_FormatField__c = 'test',
            LAT_MX_KAMPromisedDate__c = date.today()
        );
                
        insert oli1;
        
        
        LAT_MX_WS03_SalesOrderHandlerInterface.SalesOrderInterfaceFuture(opp.Id);
        
        System.Test.stopTest();
        
    }
    
    private static void createGeneralConfigSettings() {
        List<LAT_GeneralConfig__c>  lstGeneralConfig = null;

        lstGeneralConfig = new List<LAT_GeneralConfig__c>();
        lstGeneralConfig.add(createGeneralConfigSetting('LAT_MX_Opp_Status_for_Fill_Rate','535'));
        lstGeneralConfig.add(createGeneralConfigSetting('LAT_MX_Cancelation_Reasons','test'));
        lstGeneralConfig.add(createGeneralConfigSetting('LAT_MX_Opp_Billed_Status','test'));
        
        insert lstGeneralConfig; 
    }

    private static LAT_GeneralConfig__c createGeneralConfigSetting(String strName, String strValue) {
        LAT_GeneralConfig__c objSetting = null;

        objSetting = new LAT_GeneralConfig__c();
        objSetting.Name = strName;
        objSetting.LAT_Value__c =  strValue;

        return objSetting;
    }
}