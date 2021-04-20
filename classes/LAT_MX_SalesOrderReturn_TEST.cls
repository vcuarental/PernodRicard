/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:11/12/2013    *
*******************************************************************************/

@istest(seeAllDAta=true)
public class LAT_MX_SalesOrderReturn_TEST{
    
    static testMethod void unitTest(){
        Utils.setMigrationDoneTest(false);
        UDC__c udc = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '123456789012',
            CodUs__c = 'PT',
            CodProd__c = 'CRM'
        );
        try{insert udc;} catch(exception e){}
        
        delete [SELECT Id FROM Account WHERE CNPJ__c = 'LOZM701213E52'];
        
        Account acc = new Account();
        acc.Name = 'TEST';
        acc.AccountNumber = '1000';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_AN8__c = '12-557799';
        acc.Status__c = 'Novo cadastro';
        acc.Type = 'Payer';
        acc.Phone = '1-11-1111-1111';
        acc.Fax = '11-1111-1111';
        acc.Notes__c = 'TEST';
        acc.AddressLine1_AR__c = 'TEST';
        acc.CNPJ__c = 'LOZM701213E52';
        acc.Corporate_Name__c = 'TEST';
        acc.Channel__c = 'WS';
        acc.Segmentation_Type_on_trade__c = 'MOP';
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
        acc.Price_Group__c = '10';
        acc.Payment_Condition__c = udc.id;
        acc.CurrencyIsoCode = 'MXN';
        acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
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
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        Product2 prod1 = new Product2(
            Name = 'TestProd',
            IsActive = true,
            CD_Unit__c = 'CA',
            Internal_id__c = '12-35',
            QT_lead_time__c = 5,
            SKU__c = '5666',
            RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;

        Pricebook2 standardPB = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1]; 
        
        Pricebook2 pricebook = new Pricebook2(
            Name = '1', 
            Description = '1'
        );
        insert pricebook;
        
        PricebookEntry pbe3 = new PricebookEntry(
            Product2Id = prod1.Id,
            UnitPrice = 12,
            Pricebook2Id = standardPB.Id, 
            IsActive = true,
            CurrencyIsoCode = 'MXN',
            UseStandardPrice = false
        );
        
        insert pbe3;
        
        test.startTest();
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
        
        OpportunityLineItem oli2 = new OpportunityLineItem(
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
        
        insert listOlis;
        
        Datetime fechaHora = datetime.now();
        
        SalesOrderReturn.SalesOrderItem soi = new SalesOrderReturn.SalesOrderItem();
        soi.cd_line_status = '1';
        soi.Cd_product = '35';
        soi.CD_unit = '1';
        soi.cd_unit_bonif = '0';
        soi.NR_order_line_jde = 1;
        soi.orderLineStatusDescription = 'teste';
        soi.PC_Bonus = 1;
        soi.pc_discount = 1;
        soi.priceComponents = '1';
        soi.QT_Bonus = 0;
        soi.QT_sales = 1;
        soi.Vl_Valor = 1;
        soi.cd_payment_term = '11';
      
        List<SalesOrderReturn.SalesOrderItem> salesOI = new List<SalesOrderReturn.SalesOrderItem>();
        salesOI.add(Soi);
        Integer testInteger = 1;
        String testString = '1';
        
        UDC__c udc2 = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '12345678421342',
            CodUs__c = 'PT',
            CodDefUsuario__c = 'D57',
            CodProd__c = 'CRM'
        );
        try{insert udc2;} catch(exception e){}
        
        //Integer Country, String cd_salesman, String NR_order_crm, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, Integer NR_order_JDE, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderReturn.SalesOrderItem> listaItem
        
        Integer Country = 12;
		String cd_salesman = null;
		String NR_order_crm = opp.Id;
		Integer NR_order_JDE = 12345;
		Integer customer_AN8 = 557799;
		Integer customer_AN8_entrega = 557799;
		String NR_customer_order = '1';
		String companyCode = '1';
		String DS_message1 = 'MSG1';
		String DS_message2 = 'MSG2';
		String DT_delivery = String.ValueOf(System.now());
		String Freight = 'F';
		String DT_Order = String.ValueOf(System.now());
		String DT_Faturamento = String.ValueOf(System.now());
		String CD_Order_Type = 'teste';
		Integer cd_order_status = 1;
		String CD_Deposito = '4433';
		String SalesOrder_Source = 'F';
		String priceComponents = '';
		integer returnCode = 0;
		String returnMessage = 'Erro';
		String purchaseOrderUntil = '';
		String retentionReason = '';
		String paymentTerm = 'D57';
		List<SalesOrderReturn.SalesOrderItem> listaItem = salesOI;
        
        LAT_MX_SalesOrderReturn.LAT_ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);

        LAT_MX_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
        DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
      
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
        
        delete [SELECT Id FROM Account WHERE CNPJ__c = 'LOZM701213E52'];
        
        Account acc = new Account();
        acc.Name = 'TEST';
        acc.AccountNumber = '1000';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_AN8__c = '12-557799';
        acc.Status__c = 'Novo cadastro';
        acc.Type = 'Payer';
        acc.Phone = '1-11-1111-1111';
        acc.Fax = '11-1111-1111';
        acc.Notes__c = 'TEST';
        acc.AddressLine1_AR__c = 'TEST';
        acc.CNPJ__c = 'LOZM701213E52';
        acc.Corporate_Name__c = 'TEST';
        acc.Channel__c = 'WS';
        acc.Segmentation_Type_on_trade__c = 'MOP';
        acc.LAT_MX_FiscalEntityType__c = 'Individual';
        acc.Price_Group__c = '10';
        acc.Payment_Condition__c = udc.id;
        acc.CurrencyIsoCode = 'MXN';
        acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade');
        insert acc;
                
        LAT_Opportunity__c opp = new LAT_Opportunity__c(
            LAT_Account__c = acc.Id,
            Name = 'test',
            LAT_NRCustomerOrder__c = '100',
            LAT_CloseDate__c = date.today(),
            LAT_Type__c = 'Replenish',
            LAT_DSMessage1__c = 'test',
            LAT_DSMessage2__c = 'test',
            LAT_StageName__c = 'Novo pedido',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'LAT_MX_OPP_NewOrder')
        );
        
        insert opp;
        
        LAT_Product__c prod1 = new LAT_Product__c(
            Name = 'TestProd',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '12-35',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5666',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod1;
        
        LAT_Product__c prod2 = new LAT_Product__c(
            Name = 'TestProd2',
            LAT_IsActive__c = true,
            LAT_CDUnit__c = 'CA',
            LAT_ExternalId__c = '13-35',
            LAT_QTLeadTime__c = 5,
            LAT_Sku__c = '5667',
            CurrencyIsoCode = 'MXN',
            RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'LAT_MX_PRD_Standard')
        );
        
        insert prod2;
        
        test.startTest();
        Utils.setMigrationDoneTest(true);                
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
        
        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c(
            LAT_Remover__c = false,
            LAT_Quantity__c = 100,
            LAT_AR_UOM__c = 'CA',
            LAT_SkuText__c = '101',
            LAT_Product__c = prod2.Id,
            LAT_UnitPrice__c = 12,
            LAT_Opportunity__c = opp.Id,
            LAT_MX_KAMPromisedDate__c = date.today()
        );
                
        List<LAT_OpportunityLineItem__c> listOlis = new List<LAT_OpportunityLineItem__c>{oli1, oli2};
        
        insert listOlis;
        
        Datetime fechaHora = datetime.now();
        
        SalesOrderReturn.SalesOrderItem soi = new SalesOrderReturn.SalesOrderItem();
        soi.cd_line_status = '1';
        soi.Cd_product = '35';
        soi.CD_unit = '1';
        soi.cd_unit_bonif = '0';
        soi.NR_order_line_jde = 1;
        soi.orderLineStatusDescription = 'teste';
        soi.PC_Bonus = 1;
        soi.pc_discount = 1;
        soi.priceComponents = '1';
        soi.QT_Bonus = 0;
        soi.QT_sales = 1;
        soi.Vl_Valor = 1;
        soi.cd_payment_term = '11';
      
        List<SalesOrderReturn.SalesOrderItem> salesOI = new List<SalesOrderReturn.SalesOrderItem>();
        salesOI.add(Soi);
        Integer testInteger = 1;
        String testString = '1';
        
        UDC__c udc2 = new UDC__c(
            RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'LAT_MX_UDC_Standard'),
            Internal_Id__c = '12345678421342',
            CodUs__c = 'PT',
            CodDefUsuario__c = 'D57',
            CodProd__c = 'CRM'
        );
        try{insert udc2;} catch(exception e){}
        
        //Integer Country, String cd_salesman, String NR_order_crm, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, Integer NR_order_JDE, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderReturn.SalesOrderItem> listaItem
        
        Integer Country = 12;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 12345;
        Integer customer_AN8 = 557799;
        Integer customer_AN8_entrega = 557799;
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = 'teste';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'F';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = 'D57';
        List<SalesOrderReturn.SalesOrderItem> listaItem = salesOI;
        
        LAT_MX_SalesOrderReturn.LAT_ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
          

        LAT_MX_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
        DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
      
        test.stopTest();     
    }

}