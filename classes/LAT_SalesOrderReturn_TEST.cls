/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:11/12/2013    *
*******************************************************************************/
@istest
public with sharing class LAT_SalesOrderReturn_TEST {

    public static Boolean addErrorList;

    @testSetup
    public static void setup(){
        LAT_BR_PoliticaPrecoConfig__c config = new LAT_BR_PoliticaPrecoConfig__c(
              Beneficio_Fiscal__c = '',
              Channel__c = '1',
              Client_type__c  = '12',
              Estrategia_comercial__c = '7',
              Formato__c  = '17',
              //Perfil_Codigo_Demantra__c   = '101A-RJ',
              Perfil_Desc_Demantra__c ='101A-RJ',
             // Perfil_Portfolio__c  = '1',
              Politica_de_Preco__c    = '1IO',
              //Prioridade_de_Investimento__c = '12',   
              Segment__c  = '116',
              Sub_channel__c  = '11',
              UF__c = 'GO'
        );
        insert config;


        List<LAT_GeneralConfig__c>  generalConfigs= new List<LAT_GeneralConfig__c> ();
        generalConfigs.add( new LAT_GeneralConfig__c(
                          Name = 'POLITICA_PRECO_MAPPING',
                          LAT_Value__c = 'Channel__c'));
        generalConfigs.add( new LAT_GeneralConfig__c(
                          Name = 'POLITICA_PRECO_MAPPING1',
                          LAT_Value__c = 'Sub_channel__c'));
        generalConfigs.add( new LAT_GeneralConfig__c(
                          Name = 'POLITICA_PRECO_MAPPING2',
                          LAT_Value__c = 'Segment__c'));
        generalConfigs.add( new LAT_GeneralConfig__c(
                          Name = 'POLITICA_PRECO_MAPPING3',
                          LAT_Value__c = 'Uf__c'));
        generalConfigs.add( new LAT_GeneralConfig__c(
                          Name = 'POLITICA_PRECO_MAPPING4',
                          LAT_Value__c = 'Estrategia_comercial__c'));
        generalConfigs.add(new LAT_GeneralConfig__c(
              Name = 'AR_CANT_UPDATE_BASIC_INFO_FIELDS_PROF',
                    LAT_Value__c = 'LAT_AR2_Vendedor'));
        User vendas = [SELECT Id FROM User WHERE Profile.Name = 'LAT_BR2_Vendas' AND IsActive = true LIMIT 1];
        User admin = [SELECT Id, Username FROM User WHERE Profile.Name = 'LAT_SystemAdministrator' AND IsActive = true LIMIT 1];
        
        delete [SELECT Id FROM PRH_Iconic_Account_Trigger__c];
        insert new CS001_JDEInterfaceCredentials__c(Name='Argentina', UserName__c = admin.Username, Country__c = '6', EndPoint_CustomerHandler__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerHandlerReq?WSDL',
            EndPoint_CustomerVerify__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerVerifyReq?WSDL', EndPoint_PriceCalculation__c = 'http://osbdev.pramericas.com/SFDC/Price/PriceCalculationReq?WSDL', 
            EndPoint_SalesOrderHandler__c = 'http://osbdev.pramericas.com/SFDC/SalesOrder/AsyncSalesOrderHandlerReq?WSDL', RemoteHostIP__c = '200.200.10.10', SystemUserID__c = 'cloud2b', EndPoint_BalanceCheck__c = 'X',
            EndPoint_ContractManager__c = 'X', EndPoint_PaymentManager__c = 'X', EndPoint_RVManager__c = 'X',EndPoint_GetStock__c='https://osbdev.pramericas.com/JDE9/Inventory/GetStock?wsdl'); 

        insert new CS001_JDEInterfaceCredentials__c(Name='Brasil', UserName__c = admin.Username, Country__c = '1', EndPoint_CustomerHandler__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerHandlerReq?WSDL',
            EndPoint_CustomerVerify__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerVerifyReq?WSDL', EndPoint_PriceCalculation__c = 'http://osbdev.pramericas.com/SFDC/Price/PriceCalculationReq?WSDL', 
            EndPoint_SalesOrderHandler__c = 'http://osbdev.pramericas.com/SFDC/SalesOrder/AsyncSalesOrderHandlerReq?WSDL', RemoteHostIP__c = '200.200.10.10', SystemUserID__c = 'cloud2b', EndPoint_BalanceCheck__c = 'X',
            EndPoint_ContractManager__c = 'X', EndPoint_PaymentManager__c = 'X', EndPoint_RVManager__c = 'X',EndPoint_GetStock__c='https://osbdev.pramericas.com/JDE9/Inventory/GetStock?wsdl'); 

        insert new CS001_JDEInterfaceCredentials__c(Name='Uruguay', UserName__c = admin.Username, Country__c = '5', EndPoint_CustomerHandler__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerHandlerReq?WSDL',
            EndPoint_CustomerVerify__c = 'http://osbdev.pramericas.com/SFDC/Customer/CustomerVerifyReq?WSDL', EndPoint_PriceCalculation__c = 'http://osbdev.pramericas.com/SFDC/Price/PriceCalculationReq?WSDL', 
            EndPoint_SalesOrderHandler__c = 'http://osbdev.pramericas.com/SFDC/SalesOrder/AsyncSalesOrderHandlerReq?WSDL', RemoteHostIP__c = '200.200.10.10', SystemUserID__c = 'cloud2b', EndPoint_BalanceCheck__c = 'X',
            EndPoint_ContractManager__c = 'X', EndPoint_PaymentManager__c = 'X', EndPoint_RVManager__c = 'X',EndPoint_GetStock__c='https://osbdev.pramericas.com/JDE9/Inventory/GetStock?wsdl'); 
        
        generalConfigs.add(new LAT_GeneralConfig__c(
            name = 'OPP_Verification_Email_Recipients',
            lat_value__c = 'test@zimmic.com,test@zimmic.com'));

        generalConfigs.add(new LAT_GeneralConfig__c(
            name = 'LAT_ACCOUNT_VERIFICATION_QUERY',
            lat_value__c = 'SELECT Id, Name FROM Account LIMIT 1'));
 
        generalConfigs.add( new LAT_GeneralConfig__c(
            name = 'OPP_Verification_StatusToCheck',
            lat_value__c = 'Novo Pedido'));

        generalConfigs.add(new LAT_GeneralConfig__c(
                      Name = 'APPROVAL_SLA_OBJECTS',
                    LAT_Value__c = '\'Account\',\'LAT_Contract2__c\''));
        generalConfigs.add(new LAT_GeneralConfig__c(
                      Name = 'LAT_BR_FlexEDI_Enabled',
                    LAT_Value__c = 'true'));
        
        insert generalConfigs;
        
        System.runAs(vendas){
            Account acc = new Account(
                RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade'), 
                CNPJ__c = '91370573000162',
                Name = 'testAccount',
                Overdue__c = false,
                Type = 'Prospect_ARG',
                Corporate_Name__c = 'test',
                Channel_Type__c = 'Direto',
                Sub_Channel__c = 'Delicatessen',
                AddressLine1_AR__c= 'test',
                Shipping_Neighbourhood__c = 'test',
                Revenue_Neighbourhood__c = 'test',
                Billing_Neighbourhood__c ='test',
                Shipping_Country__c ='test',
                Revenue_Country__c ='test',
                Billing_Country__c ='test',
                Status__c = 'Cliente cadastrado no JDE',
                CurrencyISOCode = 'BRL',
                Price_Group__c = '602037025',
                Client_country_AN8__c = '1-8899',
                Client_code_AN8__c = '8899'
            );
        insert acc;//}catch(Exception e){
        }       
    }

    @istest
    static void SalesOrderReturnTestDen(){
      
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Opportunity opp = loadData(1, acc);
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
    
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 34525;
        Integer customer_AN8_entrega = 34525;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        LAT_SalesOrderReturn.loadData(new List<OpportunityLineItem>());
        LAT_SalesOrderReturn.devolverCota(opp, new OpportunityLineItem());
        LAT_SalesOrderReturn.usarCota(opp, new OpportunityLineItem());
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestDenB(){
        Utils.setMigrationDoneTest(true); 
              //Declaração de variáveis.
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true); 
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
    
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 34525;
        Integer customer_AN8_entrega = 34525;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        Test.stopTest();
    }
 
    @istest
    static void SalesOrderReturnTestwaa1(){
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        
        Opportunity opp = loadData(1, acc);
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        lSoi.Cd_product = '35';
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 34525;
        Integer customer_AN8_entrega = 34525;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
  
        listaItem[0].orderLineStatusDescription = 'Cancelado';
    
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[0].orderLineStatusDescription = 'Aprovação';
      
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
       	acc.Status__c = 'Em análise - Crédito e Cobrança';
        try{update acc;}catch(Exception e){}
        
        Test.stopTest();
    }
 @istest
    static void SalesOrderReturnTestwaa11(){
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        
        Opportunity opp = loadData(1, acc);
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        lSoi.Cd_product = '35';
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 34525;
        Integer customer_AN8_entrega = 34525;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
  
        listaItem[0].orderLineStatusDescription = 'Cancelado';
    
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[0].orderLineStatusDescription = 'Aprovação';
      
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
       	acc.Status__c = 'Em análise - Customer Service';
        try{update acc;}catch(Exception e){}
        
        Test.stopTest();
    }
    @istest
    static void SalesOrderReturnTestwaa1B(){
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true); 
        
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        lSoi.Cd_product = '35';
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 34525;
        Integer customer_AN8_entrega = 34525;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        listaItem[0].orderLineStatusDescription = 'Cancelado';
    
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[0].orderLineStatusDescription = 'Aprovação';
      
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
 
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestwaa() {
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Opportunity opp = loadData(1, acc);
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = '35';
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 34525;
        Integer customer_AN8_entrega = 34525;
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
          
        listaItem[0].orderLineStatusDescription = 'Cancelado';
       
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);  

        listaItem[0].orderLineStatusDescription = 'Aprovação';
       
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestwaaB() {
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true); 
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
           
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = '35';
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 34525;
        Integer customer_AN8_entrega = 34525;
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[0].orderLineStatusDescription = 'Cancelado';
       
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[0].orderLineStatusDescription = 'Aprovação';
       
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        Test.stopTest();
    }

    private static Opportunity loadData(Integer pais, Account acc) {
        //Recupera os IDS de tipo de registro.

        String countryName = '';
        
        if(pais == 1){
            countryName = 'BRA_Standard';
        }else if(pais == 5){
            countryName = 'Standard_UY';
        }else if(pais == 6){
            countryName = 'Standard_AR';
        }  
      
        UDC__c regional, bandeira    = null;
        SKU__c sku                            = null;
        Criterio_nacional_de_cota__c critN    = null;
        Cota_nacional__c cotaN                = null;
        Opportunity opp                       = null;
        OpportunityLineItem oli               = null;
        Product2 produto                      = null;
        Pricebook2 pricebook, pricebook2      = null;
        PricebookEntry pbe,pbe2               = null;

        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
      
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = 'Brasil'+'V00'+'-CRM-PT';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;
      
        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;
            
        //Cria novo catalogo
        pricebook = new Pricebook2();
        //pricebook.Name = acc.Price_Group__c;
        pricebook.IsActive = true;
        pricebook.Description = 'This is a test';
        pricebook.Id = Test.getStandardPricebookId();
        upsert pricebook;
   
        //Cria um novo produto
        produto = new Product2();
        produto.Name = 'Cloud2b';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';      
        produto.SKU__c = '35';
        produto.Country__c = pais;
        produto.Group__c = acc.Price_Group__c;
        produto.Internal_id__c = produto.Group__c+'-'+produto.SKU__c;//+'-'+produto.cd_payment_term__c;
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2' , countryName);//'BRA_Standard'
     
        insert produto;
      
        PricebookEntry entradaCatalogoPreco = new PricebookEntry();
        entradaCatalogoPreco.Pricebook2Id = pricebook.Id;  
        entradaCatalogoPreco.Product2Id = produto.Id;
        entradaCatalogoPreco.UnitPrice = 1000.00;
        entradaCatalogoPreco.IsActive = true;
        entradaCatalogoPreco.UseStandardPrice = false;
      
        insert entradaCatalogoPreco;
      
        //Cria novo sku.
        sku = new SKU__c();
        sku.Name = produto.SKU__c ;
        sku.Nome_do_produto__c = 'TESTE';
        sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
        insert sku;
      
        //Cria novo critério nacional.
        critN = new Criterio_nacional_de_cota__c();
        critN.SKU__c = sku.Id;
        critN.Cota__c = 500;
        critN.Canal__c = true;
        critN.Bandeira__c = true;
        critN.Regional__c = true;
        critN.Subcanal__c = true;
        critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard' );
        insert critN;
      
         //Cria nova cota nacional.
        cotaN = new Cota_nacional__c();
        cotaN.Cota__c = 100;
        cotaN.Canal__c = 'On Trade';
        cotaN.Sub_canal__c = 'Atacadista';
        cotaN.Regional__c = regional.Id;
        cotaN.Bandeira__c = bandeira.Id;
        cotaN.Criterio_nacional_de_cota__c = critN.Id;
        cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
        insert cotaN;
      
        //Cria nova oportunidade.
        opp = new Opportunity();
        opp.Name = 'Opp TESTE COTA';
        opp.closeDate = System.today()+1;
        opp.AccountId = acc.Id;
        opp.StageName = 'Novo Pedido';
        opp.NR_customer_order__c = '34525';
        opp.Freight__c = 'F';
        opp.NR_order_JDE__c = '12345';
        opp.CD_order_status__c = 1;
        opp.OwnerId = acc.OwnerId;
        opp.RecordTypeId = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
        opp.NR_order_JDE__c = pais+'-223-59-1';
        opp.Type = SalesOrderReturn.getOrderType(1, 'teste');
        insert opp;

        oli = new OpportunityLineItem();
        oli.PricebookEntryId = entradaCatalogoPreco.Id;
        oli.OpportunityId    = opp.Id;
        oli.UnitPrice        = 12;
        oli.Quantity         = 12;
        oli.cd_line_status__c = '500';
          
        insert oli;  

     
        return opp;
    }

    private static LAT_Opportunity__c LAT_loadData(Integer pais, Account acc) {

        String countryName = '';
        
        if(pais == 1){
            countryName = 'BRA_Standard';
        }else if(pais == 5){
            countryName = 'Standard_UY';
        }else if(pais == 6){
            countryName = 'Standard_AR';
        }  

        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
      
        //Cria nova UDC.
        UDC__c regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = 'Brasil'+'V00'+'-CRM-PT';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;
      
        //Cria nova UDC.
        UDC__c bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;
      
        //Cria um novo produto
        LAT_Product__c produto = new LAT_Product__c();
        produto.Name = 'Cloud2b';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';      
        produto.LAT_Sku__c = '35';
        produto.LAT_Country__c = pais;
        produto.LAT_Group__c = acc.Price_Group__c;
        produto.LAT_ExternalId__c = produto.LAT_Group__c+'-'+produto.LAT_SKU__c;//+'-'+produto.LAT_CdPaymentTerm__c;
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c' , countryName);//'BRA_Standard'
     
        insert produto;

        //Cria novo sku.
        SKU__c sku = new SKU__c();
        sku.Name = produto.LAT_Sku__c ;
        sku.Nome_do_produto__c = 'TESTE';
        sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
        insert sku;
      
        //Cria novo critério nacional.
        Criterio_nacional_de_cota__c critN = new Criterio_nacional_de_cota__c();
        critN.SKU__c = sku.Id;
        critN.Cota__c = 500;
        critN.Canal__c = true;
        critN.Bandeira__c = true;
        critN.Regional__c = true;
        critN.Subcanal__c = true;
        critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard' );
        insert critN;
      
        //Cria nova cota nacional.
        Cota_nacional__c cotaN = new Cota_nacional__c();
        cotaN.Cota__c = 100;
        cotaN.Canal__c = 'On Trade';
        cotaN.Sub_canal__c = 'Atacadista';
        cotaN.Regional__c = regional.Id;
        cotaN.Bandeira__c = bandeira.Id;
        cotaN.Criterio_nacional_de_cota__c = critN.Id;
        cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
        insert cotaN;

        LAT_Opportunity__c opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        opp.LAT_NRCustomerOrder__c = '34525';
        opp.LAT_Freight__c = 'F';
        opp.LAT_NROrderJDE__c = '12345';
        opp.LAT_CDOrderStatus__c = 1;
        opp.OwnerId = acc.OwnerId;
        opp.RecordTypeId = RecordTypeForTest.getRecType('LAT_Opportunity__c','Nova_oportunidade');
        opp.LAT_NROrderJDE__c = pais+'-223-59-1';
        opp.LAT_Type__c = SalesOrderReturn.getOrderType(1, 'teste');
        insert opp;

        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c    = opp.Id;
        oli.LAT_UnitPrice__c        = 12;
        oli.LAT_Quantity__c         = 12;
        oli.LAT_CdLineStatus__c = '500';
      
        insert oli;  
     
        return opp;
    }
    
    @istest
    static void SalesOrderReturnTestDeliveryDate7(){
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        
        Opportunity opp = loadData(1, acc);
        
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        lSoi.cd_payment_term = 'V00';
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
           
        listaItem[1].realDeliveryDate = null;
        listaItem[0].orderLineStatusDescription = 'Cancelado';
        listaItem[0].realDeliveryDate = null;
        listaItem[1].orderLineStatusDescription = 'Cancelado';
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
       
        Test.stopTest();
    } 

    @istest
    static void SalesOrderReturnTestDeliveryDate7B(){
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true);  
        
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
         
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        lSoi.cd_payment_term = 'V00';
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
           
        listaItem[1].realDeliveryDate = null;
        listaItem[0].orderLineStatusDescription = 'Cancelado';
        listaItem[0].realDeliveryDate = null;
        listaItem[1].orderLineStatusDescription = 'Cancelado';
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
       
        Test.stopTest();
    } 

    @istest
    static void SalesOrderReturnTestDeliveryDate(){
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false);
        
        Opportunity opp = loadData(1, acc);
  
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        lSoi.cd_payment_term = 'V00';
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[1].realDeliveryDate = null;
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[1].realDeliveryDate = String.valueOf(Date.today());
        listaItem[0].orderLineStatusDescription = 'Faturado';
        listaItem[0].realDeliveryDate = String.valueOf(Date.today());
  
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
    }    

    @istest
    static void SalesOrderReturnTestDeliveryDateB(){
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true);
        
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
        
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        lSoi.cd_payment_term = 'V00';
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[1].realDeliveryDate = null;
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[1].realDeliveryDate = String.valueOf(Date.today());
        listaItem[0].orderLineStatusDescription = 'Faturado';
        listaItem[0].realDeliveryDate = String.valueOf(Date.today());
  
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
    }  

    @istest
    static void SalesOrderReturnTestDeliveryDate2()  {
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false);
        Opportunity opp = loadData(1, acc);
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
       
        
        listaItem[0].orderLineStatusDescription = 'Cancelado';
        listaItem[1].orderLineStatusDescription = 'Cancelado';
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[0].orderLineStatusDescription = 'Aprovação';
        listaItem[1].orderLineStatusDescription = 'Aprovação';
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
    }    

    @istest
    static void SalesOrderReturnTestDeliveryDate2B()  {
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true);
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
        //Cria novo Account.
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
       
        listaItem[0].orderLineStatusDescription = 'Cancelado';
        listaItem[1].orderLineStatusDescription = 'Cancelado';
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        listaItem[0].orderLineStatusDescription = 'Aprovação';
        listaItem[1].orderLineStatusDescription = 'Aprovação';
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestDeliveryDate3(){
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId, CurrencyIsoCode FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Opportunity opp = loadData(1, acc);
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());

        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;

        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);

        SalesOrder_Source = 'C';
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_4_HeaderBlocked_URU' );
        update opp;

        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_3_HeaderBlocked_ARG' );
        update opp;

        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestDeliveryDate3B(){
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId, CurrencyIsoCode FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true);
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());

        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;

        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);

        SalesOrder_Source = 'C';
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_4_HeaderBlocked_URU' );
        opp.CurrencyIsoCode = acc.CurrencyIsoCode;
        update opp;

        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_3_HeaderBlocked_ARG' );
        update opp;

        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestDeliveryDate5(){
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId, Client_code_AN8__c, CurrencyIsoCode FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Opportunity opp = loadData(1, acc);
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = Integer.valueOf(acc.Client_code_AN8__c);
        Integer customer_AN8_entrega =  Integer.valueOf(acc.Client_code_AN8__c);
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'E';//E
        String priceComponents = '';
        Integer returnCode = 1;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
       
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
      
        SalesOrder_Source = 'C';
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_4_HeaderBlocked_URU' );
        update opp;
  
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('Opportunity'+'OPP_3_HeaderBlocked_ARG' );
        update opp;
  
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestDeliveryDate5B(){
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId, Client_code_AN8__c, CurrencyIsoCode FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true); 
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = Integer.valueOf(acc.Client_code_AN8__c);
        Integer customer_AN8_entrega =  Integer.valueOf(acc.Client_code_AN8__c);
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'E';//E
        String priceComponents = '';
        Integer returnCode = 1;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
       
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
      
        SalesOrder_Source = 'C';
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_4_HeaderBlocked_URU' );
        opp.CurrencyISOCode = acc.CurrencyISOCode;
        update opp;
  
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        opp.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Opportunity__c'+'OPP_3_HeaderBlocked_ARG' );
        opp.CurrencyISOCode = acc.CurrencyISOCode;
        update opp;
  
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestDeliveryDate4(){
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        /*
        //Cria novo Account.
        LAT_WS_CustomerHandlerInterface_Test.testSetup();
        acc = AP01_Account_BR_TEST.createAccountFromScratch();
       
        //Recupera o catalogo de preço padrão
       
        
        //Cria novo catalogo
        pricebook = new Pricebook2();
        pricebook.IsActive = true;
        pricebook.Id = Test.getStandardPricebookId();
        upsert pricebook;
        
        //Cria um novo produto
        produto = new Product2();
        produto.Name = 'Cloud2b';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '35';
        produto.Country__c = 1;
        produto.Group__c = acc.Price_Group__c;
        //produto.cd_payment_term__c = 'V00';
        produto.Internal_id__c = produto.Group__c+'-'+produto.SKU__c;//+'-'+produto.cd_payment_term__c;
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2' , 'BRA_Standard' );
        insert produto;
      
        
        //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
        PricebookEntry entradaCatalogoPreco = new PricebookEntry();
        entradaCatalogoPreco.Pricebook2Id = pricebook.Id;  
        entradaCatalogoPreco.Product2Id = produto.Id;
        entradaCatalogoPreco.UnitPrice = 1000.00;
        entradaCatalogoPreco.IsActive = true;
        entradaCatalogoPreco.UseStandardPrice = false;
        insert entradaCatalogoPreco;
        
        //Cria nova entrada de catalogo
        //pbe = new PricebookEntry();
        //pbe.Pricebook2Id = pricebook.Id;  
        //pbe.Product2Id = produto.Id;
        //pbe.UnitPrice = 100.00;
        //pbe.IsActive = true;
        //pbe.UseStandardPrice = false;
        //insert pbe;
          
        //Cria novo sku.
        sku = new SKU__c();
        sku.Name = produto.SKU__c ;
        sku.Nome_do_produto__c = 'TESTE';
        sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
        insert sku;
        
        //Cria novo critério nacional.
        critN = new Criterio_nacional_de_cota__c();
        critN.SKU__c = sku.Id;
        critN.Cota__c = 500;
        critN.Canal__c = true;
        critN.Bandeira__c = true;
        critN.Regional__c = true;
        critN.Subcanal__c = true;
        critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard' );
        insert critN;
        
        //Cria nova cota nacional.
        cotaN = new Cota_nacional__c();
        cotaN.Cota__c = 100;
        cotaN.Canal__c = 'On Trade';
        cotaN.Sub_canal__c = 'Atacadista';
        cotaN.Regional__c = regional.Id;
        cotaN.Bandeira__c = bandeira.Id;
        cotaN.Criterio_nacional_de_cota__c = critN.Id;
        cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
        insert cotaN;
        
        Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
        Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
        
        List< Criterio_de_cota_regional__c > lCritList = [ SELECT id 
                                            FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                            AND RecordTypeId =: idRecTypeCCR limit 1 ];
        
        lCritList[0].Cliente__c = true;
        update lCritList[0];
        
        cotaR = new Cota_regional__c();
        cotaR.Cliente__c = acc.id;
        cotaR.Cota__c = 80;
        cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
        COTAr.RecordTypeId = idRecTypeCr;
        insert cotaR;
        
        //Inicializa as listas e maps.
        idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
        
        //Cria nova oportunidade.
        opp = new Opportunity();
        opp.Name = 'Opp TESTE COTA';
        opp.closeDate = System.today()+1;
        opp.AccountId = acc.Id;
        opp.StageName = 'Novo Pedido';
        opp.NR_customer_order__c = '34525';
        opp.Freight__c = 'F';
        opp.NR_order_JDE__c = '12345';
        opp.CD_order_status__c = 1;
        opp.OwnerId = usuario.Id;
        opp.RecordTypeId = idOpportunity;
        opp.NR_order_JDE__c = '1-223-59-1';
        opp.Type = SalesOrderReturn.getOrderType(1, 'teste');
        try{insert opp;}catch(Exception e){}
        */
        //Cria um novo produto da oportunidade.
        Opportunity opp = loadData(1, acc);
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
        
        Utils.setMigrationDoneTest(false); 
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = '122112';//opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 1212;//Integer.valueOf(acc.Client_code_AN8__c);
        Integer customer_AN8_entrega =  1212;//Integer.valueOf(acc.Client_code_AN8__c);
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'E';//E
        String priceComponents = '';
        Integer returnCode = 1;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
       
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
     
        listaItem[0].orderLineStatusDescription = 'Faturado';  
        listaItem[1].orderLineStatusDescription = 'Faturado'; 
         
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
    }   

    @istest
    static void  SalesOrderReturnTestDeliveryDate4B(){
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
               
        /*
        //Recupera o catalogo de preço padrão
        //Cria um novo produto
        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        //produto.QT_lead_time__c = 5;
        produto.LAT_Sku__c = '35';
        produto.LAT_Country__c = 1;
        produto.LAT_Group__c = acc.Price_Group__c;
        //produto.cd_payment_term__c = 'V00';
        produto.LAT_ExternalId__c = produto.LAT_Group__c+'-'+produto.LAT_Sku__c;//+'-'+produto.cd_payment_term__c;
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c' , 'BRA_Standard' );
        insert produto;
      
   
        
        //Cria nova entrada de catalogo
        //pbe = new PricebookEntry();
        //pbe.Pricebook2Id = pricebook.Id;  
        //pbe.Product2Id = produto.Id;
        //pbe.UnitPrice = 100.00;
        //pbe.IsActive = true;
        //pbe.UseStandardPrice = false;
        //insert pbe;
          
        //Cria novo sku.
        sku = new SKU__c();
        sku.Name = produto.LAT_Sku__c ;
        sku.Nome_do_produto__c = 'TESTE';
        sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
        insert sku;
        
        //Cria novo critério nacional.
        critN = new Criterio_nacional_de_cota__c();
        critN.SKU__c = sku.Id;
        critN.Cota__c = 500;
        critN.Canal__c = true;
        critN.Bandeira__c = true;
        critN.Regional__c = true;
        critN.Subcanal__c = true;
        critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard' );
        insert critN;
        
        //Cria nova cota nacional.
        cotaN = new Cota_nacional__c();
        cotaN.Cota__c = 100;
        cotaN.Canal__c = 'On Trade';
        cotaN.Sub_canal__c = 'Atacadista';
        cotaN.Regional__c = regional.Id;
        cotaN.Bandeira__c = bandeira.Id;
        cotaN.Criterio_nacional_de_cota__c = critN.Id;
        cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
        insert cotaN;
        
        Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
        Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
        
        List< Criterio_de_cota_regional__c > lCritList = [ SELECT id 
                                            FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                            AND RecordTypeId =: idRecTypeCCR limit 1 ];
        
        lCritList[0].Cliente__c = true;
        update lCritList[0];
        
        cotaR = new Cota_regional__c();
        cotaR.Cliente__c = acc.id;
        cotaR.Cota__c = 80;
        cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
        COTAr.RecordTypeId = idRecTypeCr;
        insert cotaR;
        
        //Inicializa as listas e maps.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','Nova_oportunidade');
        
        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        opp.LAT_NRCustomerOrder__c = '34525';
        opp.LAT_Freight__c = 'F';
        opp.LAT_NROrderJDE__c = '12345';
        opp.LAT_CDOrderStatus__c = 1;
        opp.OwnerId = usuario.Id;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_NROrderJDE__c = '1-223-59-1';
        opp.LAT_Type__c = SalesOrderReturn.getOrderType(1, 'teste');
        opp.LAT_isAdmin__c = true;
        insert opp;
        
        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c    = opp.Id;
        oli.LAT_UnitPrice__c        = 12;
        oli.LAT_Quantity__c       = 12;
        oli.LAT_CdLineStatus__c = '500';
        
        //insert oli;
        */

        Test.startTest();
        LAT_Opportunity__c opp = LAT_loadData(1, acc);

        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
        Utils.setMigrationDoneTest(true); 
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 12121;//Integer.valueOf(acc.Client_code_AN8__c);
        Integer customer_AN8_entrega =  12121;//Integer.valueOf(acc.Client_code_AN8__c);
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'E';//E
        String priceComponents = '';
        Integer returnCode = 1;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
     
        listaItem[0].orderLineStatusDescription = 'Faturado';  
        listaItem[1].orderLineStatusDescription = 'Faturado'; 
         
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
      }  
    
    @istest
    static void SalesOrderReturnTestDeliveryDate8() {
        
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Opportunity opp = loadData(1, acc);

        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        lSoi.cd_payment_term = 'V00';
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
     
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
    }   

    @istest
    static void SalesOrderReturnTestDeliveryDate8B(){
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true);
        LAT_Opportunity__c opp = LAT_loadData(1, acc);

        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        lSoi.cd_payment_term = 'V00';
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
       
        
        Integer Country = 1;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega = 8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
     
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
  
        Test.stopTest();
    }   

    @istest
    static void SalesOrderReturnTestDeliveryDateUY1() {
        Utils.setMigrationDoneTest(false);   

        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        Opportunity opp = loadData(5, acc);
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
  
        Integer Country = 5;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega =  8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        SalesOrder_Source = 'F';
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        Test.stopTest();
    }

    @istest
    static void SalesOrderReturnTestDeliveryDateUY1B() {
        Utils.setMigrationDoneTest(true); 
        Account acc = [SELECT Id, Name, Price_Group__c, OwnerId FROM Account LIMIT 1];
        
        Test.startTest();
        Utils.setMigrationDoneTest(true);
        LAT_Opportunity__c opp = LAT_loadData(5, acc);
       
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'Aprovação';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        SalesOrderReturn.SalesOrderItem lSoi2 = new SalesOrderReturn.SalesOrderItem();
        lSoi2.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi2.Cd_product = string.valueof(35);
        lSoi2.CD_unit = '1';
        lSoi2.cd_unit_bonif = '0';
        lSoi2.NR_order_line_jde = 1;
        lSoi2.orderLineStatusDescription = 'Faturado';
        lSoi2.PC_Bonus = 1;
        lSoi2.pc_discount = 1;
        lSoi2.priceComponents = '1';
        lSoi2.QT_Bonus = 0;
        lSoi2.QT_sales = 1;
        lSoi2.Vl_Valor = 1;
        lSoi2.realDeliveryDate = String.valueOf(Date.today());
  
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        lSalesOI.add(lSoi2);
  
        Integer Country = 5;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega =  8899;
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
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
  
        LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        SalesOrder_Source = 'F';
        
        SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        Test.stopTest();
    }

    
    static testMethod void SalesOrderReturnTestDeliveryDateAR(){
        Utils.setMigrationDoneTest(false); 
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
        
        //Declaração de variáveis.
        UDC__c regional, bandeira, cidade, deposito     = null;
        Profile perfil                        = null;
        SKU__c sku                            = null;
        Criterio_nacional_de_cota__c critN    = null;
        Cota_nacional__c cotaN                = null;
        Cota_regional__c cotaR                = null;
        Opportunity opp                       = null;
        OpportunityLineItem oli               = null;
        User usuario                          = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'LAT_UY2_Vendedor' LIMIT 1];
        Product2 produto                      = null;
        Pricebook2 pricebook, pricebook2      = null;
        PricebookEntry pbe,pbe2               = null;
        List<RecordType> listRecType          = null;
        List<String> developerName            = null;
        Map<String, String> mapRecType        = null;
        String idAccount                      = null;
        String idOpportunity                  = null;
        
        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
      
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;
        
        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;
        
        //Cria nova UDC.
        deposito = new UDC__c();
        deposito.CodDefUsuario__c = '4433';
        deposito.CodProd__c     = 'CRM';
        deposito.CodUs__c     = 'DF';
        deposito.Internal_Id__c   = '4433'+'CRM'+'DF';
        deposito.RecordTypeId = idRecTypeUDC;
        insert deposito;
        
        //Cria novo Account.
        //Recupera o catalogo de preço padrão
        List<Pricebook2> catalogoPreco = [SELECT Id, Description FROM Pricebook2 WHERE isStandard = true limit 1];
        
        //Cria novo catalogo
        pricebook = new Pricebook2();
        //pricebook.Name = acc.Price_Group__c;
        pricebook.IsActive = true;
        pricebook.Id = Test.getStandardPricebookId();
        upsert pricebook;
        
        //Cria um novo produto
        produto = new Product2();
        produto.Name = 'Cloud2b';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '35';
        produto.Country__c = 6;
        produto.Group__c = '602037025';
        //produto.cd_payment_term__c = 'V00';
        produto.Internal_id__c = produto.Country__c+'-'+string.valueof(35);//+'-'+produto.cd_payment_term__c;
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2' , 'Standard_AR' );
        insert produto;
        System.debug('CARLOS=Internal_id__c= '+produto.Internal_id__c);
        
        //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
   
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = produto.Id, UnitPrice = 12, Pricebook2Id = Test.getStandardPricebookId(), IsActive =true);
         
        insert pbe1;
                
        //Cria novo sku.
        sku = new SKU__c();
        sku.Name = produto.SKU__c ;
        sku.Nome_do_produto__c = 'TESTE';
        sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
        insert sku;
        
        //Cria novo critério nacional.
        critN = new Criterio_nacional_de_cota__c();
        critN.SKU__c = sku.Id;
        critN.Cota__c = 500;
        critN.Canal__c = true;
        critN.Bandeira__c = true;
        critN.Regional__c = true;
        critN.Subcanal__c = true;
        critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard');
        insert critN;
        
        //Cria nova cota nacional.
        cotaN = new Cota_nacional__c();
        cotaN.Cota__c = 100;
        cotaN.Canal__c = 'On Trade';
        cotaN.Sub_canal__c = 'Atacadista';
        cotaN.Regional__c = regional.Id;
        cotaN.Bandeira__c = bandeira.Id;
        cotaN.Criterio_nacional_de_cota__c = critN.Id;
        cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
        insert cotaN;
        
        Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
        Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
        
        List< Criterio_de_cota_regional__c > lCritList = [ SELECT id 
                                            FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                            AND RecordTypeId =: idRecTypeCCR limit 1 ];
        
        lCritList[0].Cliente__c = true;
        update lCritList[0];

        Test.startTest();
        Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '6-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.OwnerId = usuario.Id;
        insert acc;
       
        
        
        cotaR = new Cota_regional__c();
        cotaR.Cliente__c = acc.id;
        cotaR.Cota__c = 80;
        cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
        COTAr.RecordTypeId = idRecTypeCr;
        insert cotaR;
        
        //Inicializa as listas e maps.
        idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
        
        //Cria nova oportunidade.
        opp = new Opportunity();
        opp.Name = 'Opp TESTE COTA';
        opp.closeDate = System.today()+1;
        opp.AccountId = acc.Id;
        opp.StageName = 'Novo Pedido';
        opp.NR_customer_order__c = '34525';
        opp.Freight__c = 'F';
        opp.NR_order_JDE__c = '12345';
        opp.CD_order_status__c = 1;
        opp.OwnerId = usuario.Id;
        opp.RecordTypeId = idOpportunity;
        opp.NR_order_JDE__c = '6-223-59-1';
        //opp.Type = SalesOrderReturn.getOrderType(6, 'teste');
        insert opp;
  
        //Cria um novo produto da oportunidade.
        oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe1.Id;
        oli.OpportunityId    = opp.Id;
        oli.UnitPrice        = 12;
        oli.Quantity         = 12;
        oli.cd_line_status__c = '500';
        
        //insert oli;
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
        Utils.setMigrationDoneTest(false); 
        
        Integer Country = 6;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega =  8899;
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        SalesOrder_Source = 'F';
        
        SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        Test.stopTest();
    }    

    static testMethod void SalesOrderReturnTestDeliveryDateARB() {
        Utils.setMigrationDoneTest(true); 
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
        
             //Declaração de variáveis.
        UDC__c regional, bandeira, cidade, deposito     = null;
        Profile perfil                        = null;
        SKU__c sku                            = null;
        Criterio_nacional_de_cota__c critN    = null;
        Cota_nacional__c cotaN                = null;
        Cota_regional__c cotaR                = null;
        LAT_Opportunity__c opp                = null;
        LAT_OpportunityLineItem__c oli               = null;
        LAT_Product__c produto                      = null;
        List<RecordType> listRecType          = null;
        List<String> developerName            = null;
        Map<String, String> mapRecType        = null;
        String idAccount                      = null;
        String idOpportunity                  = null;
        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
      
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;
        
        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;
        
        //Cria nova UDC.
        deposito = new UDC__c();
        deposito.CodDefUsuario__c = '4433';
        deposito.CodProd__c     = 'CRM';
        deposito.CodUs__c     = 'DF';
        deposito.Internal_Id__c   = '4433'+'CRM'+'DF';
        deposito.RecordTypeId = idRecTypeUDC;
        insert deposito;
        //Cria um novo produto
        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        //produto.QT_lead_time__c = 5;
        produto.LAT_Sku__c = '35';
        produto.LAT_Country__c = 6;
        produto.LAT_Group__c = '602037025';
        produto.LAT_ExternalId__c = produto.LAT_Country__c+'-'+string.valueof(35);//+'-'+produto.cd_payment_term__c;
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c' , 'Standard_AR' );
        insert produto;
        //Cria novo sku.
        sku = new SKU__c();
        sku.Name = produto.LAT_Sku__c ;
        sku.Nome_do_produto__c = 'TESTE';
        sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
        insert sku;
        
        //Cria novo critério nacional.
        critN = new Criterio_nacional_de_cota__c();
        critN.SKU__c = sku.Id;
        critN.Cota__c = 500;
        critN.Canal__c = true;
        critN.Bandeira__c = true;
        critN.Regional__c = true;
        critN.Subcanal__c = true;
        critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard');
        insert critN;
        
        //Cria nova cota nacional.
        cotaN = new Cota_nacional__c();
        cotaN.Cota__c = 100;
        cotaN.Canal__c = 'On Trade';
        cotaN.Sub_canal__c = 'Atacadista';
        cotaN.Regional__c = regional.Id;
        cotaN.Bandeira__c = bandeira.Id;
        cotaN.Criterio_nacional_de_cota__c = critN.Id;
        cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
        insert cotaN;
        
        Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
        Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
        
        List< Criterio_de_cota_regional__c > lCritList = [ SELECT id 
                                            FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                            AND RecordTypeId =: idRecTypeCCR limit 1 ];
        User usuario = [SELECT id FROM User WHERE IsActive = true AND Profile.Name = 'LAT_AR2_Vendedor' LIMIT 1];
      
        //Cria novo Account.
        Test.startTest();

        Account acc = LAT_Account_TestFactory.getAccountOffTradeArg();
        acc.Price_Group__c = '602037025';
        acc.Client_country_AN8__c = '6-8899';
        acc.Client_code_AN8__c = '8899';
        acc.Status__c = 'Cliente cadastrado no JDE';
        insert acc;
      

              
      
        lCritList[0].Cliente__c = true;
        update lCritList[0];
        
        cotaR = new Cota_regional__c();
        cotaR.Cliente__c = acc.id;
        cotaR.Cota__c = 80;
        cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
        COTAr.RecordTypeId = idRecTypeCr;
        insert cotaR;
  
         //Inicializa as listas e maps.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','Nova_oportunidade');
        
        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        opp.LAT_NRCustomerOrder__c = '34525';
        opp.LAT_Freight__c = 'F';
        opp.LAT_NROrderJDE__c = '12345';
        opp.LAT_CDOrderStatus__c = 1;
        opp.OwnerId = usuario.Id;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_NROrderJDE__c = '6-223-59-1';
        //opp.LAT_Type__c = SalesOrderReturn.getOrderType(1, 'teste');
        insert opp;
        
        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c    = opp.Id;
        oli.LAT_UnitPrice__c        = 12;
        oli.LAT_Quantity__c       = 12;
        oli.LAT_CdLineStatus__c = '500';
        
        //insert oli;
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
        Utils.setMigrationDoneTest(true); 
        
        Integer Country = 6;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega =  8899;
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        SalesOrder_Source = 'F';
        
        try{SalesOrderReturn.ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);}catch(Exception e){}
        
        Test.stopTest();
    }  

    static testMethod void SalesOrderReturnTestDeliveryDateUY(){
        Utils.setMigrationDoneTest(false); 
        Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
        
        //Declaração de variáveis.
        Account acc                           = null;
        UDC__c regional, bandeira, cidade, deposito     = null;
        Profile perfil                        = null;
        SKU__c sku                            = null;
        Criterio_nacional_de_cota__c critN    = null;
        Cota_nacional__c cotaN                = null;
        Cota_regional__c cotaR                = null;
        Opportunity opp                       = null;
        OpportunityLineItem oli               = null;
        Product2 produto                      = null;
        Pricebook2 pricebook, pricebook2      = null;
        PricebookEntry pbe,pbe2               = null;
        List<RecordType> listRecType          = null;
        List<String> developerName            = null;
        Map<String, String> mapRecType        = null;
        String idAccount                      = null;
        String idOpportunity                  = null;
      
        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c     = '01';
        regional.CodUs__c     = '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;
      
        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c     = '01';
        bandeira.CodUs__c     = '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;
      
        //Cria nova UDC.
        deposito = new UDC__c();
        deposito.CodDefUsuario__c = '4433';
        deposito.CodProd__c     = 'CRM';
        deposito.CodUs__c     = 'DF';
        deposito.Internal_Id__c   = '4433'+'CRM'+'DF';
        deposito.RecordTypeId = idRecTypeUDC;
        insert deposito;
      
        //Cria novo Account.
        Test.startTest();
        User vendas = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'LAT_UY2_Vendedor' LIMIT 1];
      
        System.runAs(vendas){
            acc = LAT_Account_TestFactory.getAccountOffTradeArg();
            acc.Price_Group__c = '602037025';
            acc.Client_country_AN8__c = '6-8899';
            acc.Client_code_AN8__c = '8899';
            acc.Status__c = 'Cliente cadastrado no JDE';
            insert acc;
        }
      
      
        //Cria novo catalogo
        pricebook = new Pricebook2();
        //pricebook.Name = acc.Price_Group__c;
        pricebook.IsActive = true;
        pricebook.Id = Test.getStandardPricebookId();  
        upsert pricebook;
        List< Pricebook2 > priceL = [select id from Pricebook2 where isStandard = true];
        System.debug('#######################################################  priceL ' + priceL);
  
        //Cria um novo produto
        produto = new Product2();
        produto.Name = 'Cloud2b';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        //produto.QT_lead_time__c = 5;
        produto.SKU__c = '35';
        produto.Country__c = 5;
        produto.Group__c = acc.Price_Group__c;
        //produto.cd_payment_term__c = 'V00';
        produto.Internal_id__c = produto.Country__c+'-'+string.valueof(35);//+'-'+produto.cd_payment_term__c;
        produto.RecordTypeId = RecordTypeForTest.getRecType( 'Product2' , 'Standard_UY' );
        insert produto;
        System.debug('CARLOS=Internal_id__c= '+produto.Internal_id__c);
        
        //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
   
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = produto.Id, UnitPrice = 12, Pricebook2Id = Test.getStandardPricebookId(), IsActive =true, UseStandardPrice = false);
         
        insert pbe1;
        //Cria nova entrada de catalogo
        //pbe = new PricebookEntry();
        //pbe.Pricebook2Id = Test.getStandardPricebookId(); 
        //pbe.Product2Id = produto.Id;
        //pbe.UnitPrice = 100.00;
        //pbe.IsActive = true;
        // pbe.UseStandardPrice = false;
        //insert pbe;
          
        //Cria novo sku.
        sku = new SKU__c();
        sku.Name = produto.SKU__c ;
        sku.Nome_do_produto__c = 'TESTE';
        sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
        insert sku;
        
        //Cria novo critério nacional.
        critN = new Criterio_nacional_de_cota__c();
        critN.SKU__c = sku.Id;
        critN.Cota__c = 500;
        critN.Canal__c = true;
        critN.Bandeira__c = true;
        critN.Regional__c = true;
        critN.Subcanal__c = true;
        critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard');
        insert critN;
      
        //Cria nova cota nacional.
        cotaN = new Cota_nacional__c();
        cotaN.Cota__c = 100;
        cotaN.Canal__c = 'On Trade';
        cotaN.Sub_canal__c = 'Atacadista';
        cotaN.Regional__c = regional.Id;
        cotaN.Bandeira__c = bandeira.Id;
        cotaN.Criterio_nacional_de_cota__c = critN.Id;
        cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
        insert cotaN;
        
        Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
        Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
        
        List< Criterio_de_cota_regional__c > lCritList = [ SELECT id 
                                            FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                            AND RecordTypeId =: idRecTypeCCR limit 1 ];
        
        lCritList[0].Cliente__c = true;
        update lCritList[0];
       
        cotaR = new Cota_regional__c();
        cotaR.Cliente__c = acc.id;
        cotaR.Cota__c = 80;
        cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
        CotaR.RecordTypeId = idRecTypeCr;
        insert cotaR;
        
        //Inicializa as listas e maps.
        idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
        
        //Cria nova oportunidade.
        opp = new Opportunity();
        opp.Name = 'Opp TESTE COTA';
        opp.closeDate = System.today()+1;
        opp.AccountId = acc.Id;
        opp.StageName = 'Novo Pedido';
        opp.NR_customer_order__c = '34525';
        opp.Freight__c = 'F';
        opp.NR_order_JDE__c = '12345';
        opp.CD_order_status__c = 1;
        opp.OwnerId = vendas.Id;
        opp.RecordTypeId = idOpportunity;
        opp.NR_order_JDE__c = '5-223-59-1';
        //opp.Type = SalesOrderReturn.getOrderType(6, 'teste');
        insert opp;
  
        //Cria um novo produto da oportunidade.
        oli = new OpportunityLineItem();
        oli.PricebookEntryId = pbe1.Id;
        oli.OpportunityId    = opp.Id;
        oli.UnitPrice        = 12;
        oli.Quantity         = 12;
        oli.cd_line_status__c = '500';
        
        //insert oli;
   
        SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
        lSoi.cd_line_status = '1';
        //lSoi.cd_payment_term = produto.cd_payment_term__c;
        lSoi.Cd_product = string.valueof(35);
        lSoi.CD_unit = '1';
        lSoi.cd_unit_bonif = '0';
        lSoi.NR_order_line_jde = 1;
        lSoi.orderLineStatusDescription = 'teste';
        lSoi.PC_Bonus = 1;
        lSoi.pc_discount = 1;
        lSoi.priceComponents = '1';
        lSoi.QT_Bonus = 0;
        lSoi.QT_sales = 1;
        lSoi.Vl_Valor = 1;
        lSoi.realDeliveryDate = null;
        
        List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
        lSalesOI.add(lSoi);
        
          Utils.setMigrationDoneTest(false); 
        
        Integer Country = 6;
        String cd_salesman = null;
        String NR_order_crm = opp.Id;
        Integer NR_order_JDE = 59;
        Integer customer_AN8 = 8899;
        Integer customer_AN8_entrega =  8899;
        String NR_customer_order = '1';
        String companyCode = '1';
        String DS_message1 = 'MSG1';
        String DS_message2 = 'MSG2';
        String DT_delivery = String.ValueOf(System.now());
        String Freight = 'F';
        String DT_Order = String.ValueOf(System.now());
        String DT_Faturamento = String.ValueOf(System.now());
        String CD_Order_Type = '223';
        Integer cd_order_status = 1;
        String CD_Deposito = '4433';
        String SalesOrder_Source = 'C';
        String priceComponents = '';
        integer returnCode = 0;
        String returnMessage = 'Erro';
        String purchaseOrderUntil = '';
        String retentionReason = '';
        String paymentTerm = '';
        List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
        
        LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
  
        //SalesOrder_Source = 'F';
        
        //SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
          //DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
        
        Test.stopTest();
    }   


    static testMethod void SalesOrderReturnTestDeliveryDateUYB(){
      Utils.setMigrationDoneTest(true); 
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' );
          //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade, deposito     = null;
      Profile perfil                        = null;
      SKU__c sku                            = null;
      Criterio_nacional_de_cota__c critN    = null;
      Cota_nacional__c cotaN                = null;
      Cota_regional__c cotaR                = null;
      LAT_Opportunity__c opp                = null;
      LAT_OpportunityLineItem__c oli               = null;
      User usuario                          = [SELECT Id FROM User WHERE IsActive = true AND Profile.Name = 'LAT_UY2_Vendedor' LIMIT 1];
      LAT_Product__c produto                      = null;
      List<RecordType> listRecType          = null;
      List<String> developerName            = null;
      Map<String, String> mapRecType        = null;
      String idAccount                      = null;
      String idOpportunity                  = null;
      
      
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '1234';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      //Cria nova UDC.
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '1236';
      bandeira.RecordTypeId = idRecTypeUDC;
      insert bandeira;
      
      //Cria nova UDC.
      deposito = new UDC__c();
      deposito.CodDefUsuario__c = '4433';
      deposito.CodProd__c     = 'CRM';
      deposito.CodUs__c     = 'DF';
      deposito.Internal_Id__c   = '4433'+'CRM'+'DF';
      deposito.RecordTypeId = idRecTypeUDC;
      insert deposito;
      
      //Cria novo Account.
      Test.startTest();
      acc = LAT_Account_TestFactory.getAccountOffTradeArg();
      acc.Price_Group__c = '602037025';
      acc.Client_country_AN8__c = '6-8899';
      acc.Client_code_AN8__c = '8899';
      acc.Status__c = 'Cliente cadastrado no JDE';
      insert acc;
     
      //Recupera o catalogo de preço padrão
      //List<Pricebook2> catalogoPreco = [SELECT Id, Description FROM Pricebook2 WHERE isStandard = true limit 1];
            //Cria um novo produto
      produto = new LAT_Product__c();
      produto.Name = 'Cloud2b';
      produto.LAT_IsActive__c = true;
      produto.LAT_CDUnit__c = 'UN';
      //produto.QT_lead_time__c = 5;
      produto.LAT_Sku__c = '35';
      produto.LAT_Country__c = 5;
      produto.LAT_Group__c = acc.Price_Group__c;
      //produto.cd_payment_term__c = 'V00';
      produto.LAT_ExternalId__c = produto.LAT_Country__c+'-'+string.valueof(35);//+'-'+produto.cd_payment_term__c;
      produto.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c' , 'Standard_UY' );
      insert produto;
      
      //Cria nova entrada de catalogo
      //pbe = new PricebookEntry();
      //pbe.Pricebook2Id = Test.getStandardPricebookId(); 
      //pbe.Product2Id = produto.Id;
      //pbe.UnitPrice = 100.00;
      //pbe.IsActive = true;
     // pbe.UseStandardPrice = false;
      //insert pbe;
        
      //Cria novo sku.
      sku = new SKU__c();
      sku.Name = produto.LAT_Sku__c ;
      sku.Nome_do_produto__c = 'TESTE';
      sku.RecordTypeId = RecordTypeForTest.getRecType( 'SKU__c' , 'BRA_Standard' );
      insert sku;
      
      //Cria novo critério nacional.
      critN = new Criterio_nacional_de_cota__c();
      critN.SKU__c = sku.Id;
      critN.Cota__c = 500;
      critN.Canal__c = true;
      critN.Bandeira__c = true;
      critN.Regional__c = true;
      critN.Subcanal__c = true;
      critN.RecordTypeId = RecordTypeForTest.getRecType( 'Criterio_nacional_de_cota__c' , 'BRA_Standard');
      insert critN;
    
      //Cria nova cota nacional.
      cotaN = new Cota_nacional__c();
      cotaN.Cota__c = 100;
      cotaN.Canal__c = 'On Trade';
      cotaN.Sub_canal__c = 'Atacadista';
      cotaN.Regional__c = regional.Id;
      cotaN.Bandeira__c = bandeira.Id;
      cotaN.Criterio_nacional_de_cota__c = critN.Id;
      cotaN.RecordTypeId = RecordTypeForTest.getRecType( 'Cota_nacional__c' , 'BRA_Standard' );
      insert cotaN;
      
      Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c' , 'BRA_Standard' );
      Id idRecTypeCr = RecordTypeForTest.getRecType( 'Cota_regional__c' , 'BRA_Standard' );
      
      List< Criterio_de_cota_regional__c > lCritList = [ SELECT id 
                                          FROM Criterio_de_cota_regional__c WHERE Cota_nacional__c =:cotaN.id 
                                          AND RecordTypeId =: idRecTypeCCR limit 1 ];
      
      lCritList[0].Cliente__c = true;
      update lCritList[0];
     
      cotaR = new Cota_regional__c();
      cotaR.Cliente__c = acc.id;
      cotaR.Cota__c = 80;
      cotaR.Criterio_regional_de_cota__c = lCritList[0].id;
      CotaR.RecordTypeId = idRecTypeCr;
      insert cotaR;

         //Inicializa as listas e maps.
      idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','Nova_oportunidade');
      
      //Cria nova oportunidade.
      opp = new LAT_Opportunity__c();
      opp.Name = 'Opp TESTE COTA';
      opp.LAT_CloseDate__c = System.today()+1;
      opp.LAT_Account__c = acc.Id;
      opp.LAT_StageName__c = 'Novo Pedido';
      opp.LAT_NRCustomerOrder__c = '34525';
      opp.LAT_Freight__c = 'F';
      opp.LAT_NROrderJDE__c = '12345';
      opp.LAT_CDOrderStatus__c = 1;
      opp.OwnerId = usuario.Id;
      opp.RecordTypeId = idOpportunity;
      opp.LAT_NROrderJDE__c = '5-223-59-1';
      opp.LAT_Type__c = SalesOrderReturn.getOrderType(1, 'teste');
      insert opp;
      
      //Cria um novo produto da oportunidade.
      oli = new LAT_OpportunityLineItem__c();
      oli.LAT_Product__c = produto.Id;
      oli.LAT_Opportunity__c    = opp.Id;
      oli.LAT_UnitPrice__c        = 12;
      oli.LAT_Quantity__c       = 12;
      oli.LAT_CdLineStatus__c = '500';
 
      SalesOrderReturn.SalesOrderItem lSoi = new SalesOrderReturn.SalesOrderItem();
      lSoi.cd_line_status = '1';
      //lSoi.cd_payment_term = produto.cd_payment_term__c;
      lSoi.Cd_product = string.valueof(35);
      lSoi.CD_unit = '1';
      lSoi.cd_unit_bonif = '0';
      lSoi.NR_order_line_jde = 1;
      lSoi.orderLineStatusDescription = 'teste';
      lSoi.PC_Bonus = 1;
      lSoi.pc_discount = 1;
      lSoi.priceComponents = '1';
      lSoi.QT_Bonus = 0;
      lSoi.QT_sales = 1;
      lSoi.Vl_Valor = 1;
      lSoi.realDeliveryDate = null;
      
      List<SalesOrderReturn.SalesOrderItem> lSalesOI = new List<SalesOrderReturn.SalesOrderItem>();
      lSalesOI.add(lSoi);
      
      Utils.setMigrationDoneTest(true); 
      
      Integer Country = 6;
      String cd_salesman = null;
      String NR_order_crm = opp.Id;
      Integer NR_order_JDE = 59;
      Integer customer_AN8 = 8899;
      Integer customer_AN8_entrega =  8899;
      String NR_customer_order = '1';
      String companyCode = '1';
      String DS_message1 = 'MSG1';
      String DS_message2 = 'MSG2';
      String DT_delivery = String.ValueOf(System.now());
      String Freight = 'F';
      String DT_Order = String.ValueOf(System.now());
      String DT_Faturamento = String.ValueOf(System.now());
      String CD_Order_Type = '223';
      Integer cd_order_status = 1;
      String CD_Deposito = '4433';
      String SalesOrder_Source = 'C';
      String priceComponents = '';
      integer returnCode = 0;
      String returnMessage = 'Erro';
      String purchaseOrderUntil = '';
      String retentionReason = '';
      String paymentTerm = '';
      List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
      
      LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
        DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
      

      //SalesOrder_Source = 'F';
      
      //SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, 
        //DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
      
      Test.stopTest();
    }   
 
    @istest
    static void calcularOriginalNisAmountNewJDELineTest(){
        Account acc = [SELECT Id, OwnerId, Client_code_An8__c, Price_Group__c, Name FROM Account LIMIT 1];
        User vendas = [SELECT Id FROM User WHERE id = :acc.OwnerId];
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
        
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = prod1.Id;
        oli.LAT_UnitPrice__c        = 12;
        oli.LAT_Quantity__c         = 12;
        oli.LAT_CdLineStatus__c = '500';
        oli.LAT_SkuTExt__C = '5666';
      
        LAT_OpportunityHandlerJSON pedido = LAT_REST_OpportunityFlex_Test.createPedidoJSON(acc, prod1, paymentCondition);
        LAT_SalesOrdeRreturn.calcularOriginalNisAmountNewJDELine(pedido, new List<LAT_OpportunityLineItem__c>{oli});
        LAT_SalesOrdeRreturn.shouldhaveException = true;
        addErrorList = true;
        LAT_SalesOrdeRreturn.calcularOriginalNisAmountNewJDELine(pedido, new List<LAT_OpportunityLineItem__c>{oli});
        Test.stopTest();
    }


    @istest
    static void calcularOriginalNisAmountNewJDELineTest2(){
        Account acc = [SELECT Id, OwnerId, Client_code_An8__c, Price_Group__c, Name FROM Account LIMIT 1];
        User vendas = [SELECT Id FROM User WHERE id = :acc.OwnerId];
        LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', LAT_IsActive__c = true, LAT_CDUnit__c = 'CA', LAT_ExternalID__c = '444', LAT_QTLeadTime__c = 5, LAT_Sku__c = '5666', RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
        insert prod1;

        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'BRA_Standard');
        UDC__c paymentCondition = new UDC__c(CodDefUsuario__c='V42',   CodProd__c='CRM', CodUs__c='PT', Internal_Id__c='1-V42-CRM-PT',  RecordTypeId = idRecTypeUDC);
        insert paymentCondition;
        Test.startTest();
        LAT_Opportunity__c opp = LAT_loadData(1, acc);
        
        LAT_OpportunityLineItem__c oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = prod1.Id;
        oli.LAT_UnitPrice__c        = 12;
        oli.LAT_Quantity__c         = 12;
        oli.LAT_CdLineStatus__c = '500';
        oli.LAT_SkuTExt__C = '5666';
      
        LAT_OpportunityHandlerJSON pedido = LAT_REST_OpportunityFlex_Test.createPedidoJSON(acc, prod1, paymentCondition);
        LAT_SalesOrdeRreturn.calcularOriginalNisAmountNewJDELine(pedido, new List<LAT_OpportunityLineItem__c>{oli});
        LAT_SalesOrdeRreturn.shouldhaveException = true;
        addErrorList = false;
        LAT_SalesOrdeRreturn.calcularOriginalNisAmountNewJDELine(pedido, new List<LAT_OpportunityLineItem__c>{oli});
        Test.stopTest();
    }

    public static LAT_BR_PriceCalculation.priceCatalogueHeaderOutput getMockResponse(){
        LAT_BR_PriceCalculation.priceCatalogueHeaderOutput response = new LAT_BR_PriceCalculation.priceCatalogueHeaderOutput();
        response.businessUnit = 'test';
        response.company = 'test';
        LAT_BR_PriceCalculation.priceCatalogueDetailsOutput test123 = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput();
        response.priceCatalogueDetails = new LAT_BR_PriceCalculation.priceCatalogueDetailsOutput[]{test123};
        response.priceCatalogueDetails[0].amountDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].amountExcise = 55;
        response.priceCatalogueDetails[0].amountExclusiveDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].amountGross = 55;
        response.priceCatalogueDetails[0].amountTax = 55;
        response.priceCatalogueDetails[0].amountTaxable = 55;
        response.priceCatalogueDetails[0].description1 = 'test';
        response.priceCatalogueDetails[0].description2= 'test';
        response.priceCatalogueDetails[0].exciseRate = 55;
        response.priceCatalogueDetails[0].itemNumberShort= 55;
        response.priceCatalogueDetails[0].ordinalNumber = 55;
        response.priceCatalogueDetails[0].paymentTerms = 'test';
        response.priceCatalogueDetails[0].quantityOrdered = 55;
        response.priceCatalogueDetails[0].quantityFree = 55;
        response.priceCatalogueDetails[0].ratePercentCashDiscount = 55;
        response.priceCatalogueDetails[0].ratePercentDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].secondItemNumber = 'test';
        response.priceCatalogueDetails[0].taxRate = 55;
        response.priceCatalogueDetails[0].unitPrice = 4;
        response.priceCatalogueDetails[0].unitPriceExclusiveDiscountsAndCharges= 4;
        response.priceCatalogueDetails[0].unitPriceGross =4;
        response.priceCatalogueDetails[0].unitofMeasure = 'ca';
        response.priceCatalogueDetails[0].paymentTerms = 'test';
        response.priceCatalogueDetails[0].quantityOrdered = 55;
        response.priceCatalogueDetails[0].quantityFree = 55;
        response.priceCatalogueDetails[0].ratePercentCashDiscount = 55;
        response.priceCatalogueDetails[0].ratePercentDiscountsAndCharges = 55;
        response.priceCatalogueDetails[0].secondItemNumber = 'test';
        response.priceCatalogueDetails[0].taxRate = 55;
        response.priceCatalogueDetails[0].unitPrice = 4;
        response.priceCatalogueDetails[0].unitPriceExclusiveDiscountsAndCharges= 4;
        response.priceCatalogueDetails[0].unitPriceGross =4;
        response.priceCatalogueDetails[0].unitofMeasure = 'ca';
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discountAndChargeDetails = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        discountAndChargeDetails.discountOrChargeGroup = 'NBASE3';
        discountAndChargeDetails.discountOrChargeType  = 'D';
        discountAndChargeDetails.discountOrChargeGroupDescription   = 'TEST';
        discountAndChargeDetails.discountOrChargeType              = 'D';
        discountAndChargeDetails.ratePercentDiscountsAndCharges     = 10;    
        discountAndChargeDetails.unitDiscountOrCharge               = 10;
        discountAndChargeDetails.amountDiscountOrCharge            = 100;   
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discountAndChargeDetails2 = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        discountAndChargeDetails2.discountOrChargeGroup = 'ICMS';
        discountAndChargeDetails2.discountOrChargeType  = 'D';
        discountAndChargeDetails2.discountOrChargeGroupDescription   = 'TEST';
        discountAndChargeDetails2.discountOrChargeType              = 'D';
        discountAndChargeDetails2.ratePercentDiscountsAndCharges     = 10;    
        discountAndChargeDetails2.unitDiscountOrCharge               = 10;
        discountAndChargeDetails2.amountDiscountOrCharge            = 100;   
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discountAndChargeDetails3 = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        discountAndChargeDetails3.discountOrChargeGroup = 'PIS';
        discountAndChargeDetails3.discountOrChargeType  = 'D';
        discountAndChargeDetails3.discountOrChargeGroupDescription   = 'TEST';
        discountAndChargeDetails3.discountOrChargeType              = 'D';
        discountAndChargeDetails3.ratePercentDiscountsAndCharges     = 10;    
        discountAndChargeDetails3.unitDiscountOrCharge               = 10;
        discountAndChargeDetails3.amountDiscountOrCharge            = 100;   
        LAT_BR_PriceCalculation.discountAndChargeDetailsOutput discountAndChargeDetails4 = new LAT_BR_PriceCalculation.discountAndChargeDetailsOutput();
        discountAndChargeDetails4.discountOrChargeGroup = 'COFINS';
        discountAndChargeDetails4.discountOrChargeType  = 'D';
        discountAndChargeDetails4.discountOrChargeGroupDescription   = 'TEST';
        discountAndChargeDetails4.discountOrChargeType              = 'D';
        discountAndChargeDetails4.ratePercentDiscountsAndCharges     = 10;    
        discountAndChargeDetails4.unitDiscountOrCharge               = 10;
        discountAndChargeDetails4.amountDiscountOrCharge            = 100;   
        response.priceCatalogueDetails[0].discountAndChargeDetails = new List<LAT_BR_PriceCalculation.discountAndChargeDetailsOutput>{discountAndChargeDetails,discountAndChargeDetails2,discountAndChargeDetails3,discountAndChargeDetails4};
        response.shipTo = 5;
        response.soldTo = 5;
        response.taxArea = 'area';
        response.taxExplanation = 'test';
        if(addErrorList){
            response.errorRecords = new LAT_BR_PriceCalculation.errorRecords[]{new LAT_BR_PriceCalculation.errorRecords()};
            response.errorRecords[0].errorCode = '5';
            response.errorRecords[0].errorDescription = '5';
        }
        return response;
    }
    
}