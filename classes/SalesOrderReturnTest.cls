@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe SalesOrderReturn.cls
* NAME: SalesOrderReturnTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 11/06/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 17/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 15/11/2016
*
********************************************************************************/
private class SalesOrderReturnTest {
    
    static testMethod void SalesOrderReturnTest() 
      {
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% empieza SalesOrderReturnTest');   
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
            User usuario                          = null;
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

            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
            
            //Recupera o catalogo de preço padrão
            List<Pricebook2> catalogoPreco = [SELECT Id, Description FROM Pricebook2 WHERE isStandard = true limit 1];
            
            //Cria novo catalogo
            pricebook = new Pricebook2();
            pricebook.Name = acc.Price_Group__c;
            pricebook.IsActive = true;
            insert pricebook;
            
            Account varAcc = [SELECT Id, Client_country_AN8__c, RecordTypeId FROM Account Where id =:acc.Id];
            System.debug('%%%%%%%%%%%%%%%%%%%%%% account '+varAcc.Client_country_AN8__c + ' RecordType '+ varAcc.RecordTypeId);
            
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
            System.debug('CARLOS=Internal_id__c= '+produto.Internal_id__c);
            
            //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            insert entradaCatalogoPreco;
            
            //Cria nova entrada de catalogo
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pricebook.Id;  
            pbe.Product2Id = produto.Id;
            pbe.UnitPrice = 100.00;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            insert pbe;
              
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
            insert opp;
            
            //Cria um novo produto da oportunidade.
            oli = new OpportunityLineItem();
            oli.PricebookEntryId = pbe.Id;
            oli.OpportunityId    = opp.Id;
            oli.UnitPrice        = 12;
            oli.Quantity         = 12;
            oli.cd_line_status__c = '500';
            
            //insert oli;
       
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
      	  String NR_order_crm = 'opp.Id';
      	  Integer NR_order_JDE = 34525;
      	  Integer customer_AN8 = 557798;
      	  Integer customer_AN8_entrega = 557798;
      	  String NR_customer_order = '1';
      	  String companyCode = '1';
      	  String DS_message1 = 'MSG1';
      	  String DS_message2 = 'MSG2';
      	  String DT_delivery = String.ValueOf(System.now());
      	  String Freight = 'C';
      	  String DT_Order = String.ValueOf(System.now());
      	  String DT_Faturamento = String.ValueOf(System.now());
      	  String CD_Order_Type = 'teste';
      	  Integer cd_order_status = 1;
      	  String CD_Deposito = '4433';
      	  String SalesOrder_Source = 'C';
      	  String priceComponents = '';
      	  integer returnCode = 0;
      	  String returnMessage = '';
      	  String purchaseOrderUntil = '';
      	  String retentionReason = '';
      	  String paymentTerm = '';
      	  List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(false);
            SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            Test.stopTest();
    }
    
    static testMethod void SalesOrderReturnTestB() 
      {
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
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
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
            

            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  

            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
            
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
            System.debug('CARLOS=LAT_ExternalId__c= '+produto.LAT_ExternalId__c);
   
              
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
            insert opp;
            
            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            oli.LAT_CdLineStatus__c = '500';
            
            //insert oli;
       
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
              Integer NR_order_JDE = 557798;
              Integer customer_AN8 = 557798;
              Integer customer_AN8_entrega = 557798;
              String NR_customer_order = '1';
              String companyCode = '1';
              String DS_message1 = 'MSG1';
              String DS_message2 = 'MSG2';
              String DT_delivery = String.ValueOf(System.now());
              String Freight = 'C';
              String DT_Order = String.ValueOf(System.now());
              String DT_Faturamento = String.ValueOf(System.now());
              String CD_Order_Type = 'teste';
              Integer cd_order_status = 1;
              String CD_Deposito = '4433';
              String SalesOrder_Source = 'C';
              String priceComponents = '';
              integer returnCode = 0;
              String returnMessage = '';
              String purchaseOrderUntil = '';
              String retentionReason = '';
              String paymentTerm = '';
              List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(true);
            SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            Test.stopTest();
    }
    static testMethod void SalesOrderReturnTest2() 
    {
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
            User usuario                          = null;
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

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
          
            
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
            
            //Recupera o catalogo de preço padrão
            List<Pricebook2> catalogoPreco = [SELECT Id, Description FROM Pricebook2 WHERE isStandard = true limit 1];
            
            //Cria novo catalogo
            pricebook = new Pricebook2();
            pricebook.Name = acc.Price_Group__c;
            pricebook.IsActive = true;
            insert pricebook;
            
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
            System.debug('CARLOS=Internal_id__c= '+produto.Internal_id__c);
            
            //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            insert entradaCatalogoPreco;
            
            //Cria nova entrada de catalogo
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pricebook.Id;  
            pbe.Product2Id = produto.Id;
            pbe.UnitPrice = 100.00;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            insert pbe;
              
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
            insert opp;
            
            //Cria um novo produto da oportunidade.
            oli = new OpportunityLineItem();
            oli.PricebookEntryId = pbe.Id;
            oli.OpportunityId    = opp.Id;
            oli.UnitPrice        = 12;
            oli.Quantity         = 12;
            oli.cd_line_status__c = '600';
            
            //insert oli;
       
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
      	  Integer NR_order_JDE = 557799;
      	  Integer customer_AN8 = 34525;
      	  Integer customer_AN8_entrega = 34525;
      	  String NR_customer_order = '1';
      	  String companyCode = '1';
      	  String DS_message1 = 'MSG1';
      	  String DS_message2 = 'MSG2';
      	  String DT_delivery = String.ValueOf(System.now());
      	  String Freight = 'C';
      	  String DT_Order = String.ValueOf(System.now());
      	  String DT_Faturamento = String.ValueOf(System.now());
      	  String CD_Order_Type = 'teste';
      	  Integer cd_order_status = 1;
      	  String CD_Deposito = '4433';
      	  String SalesOrder_Source = 'C';
      	  String priceComponents = '';
      	  integer returnCode = 0;
      	  String returnMessage = '';
      	  String purchaseOrderUntil = '';
      	  String retentionReason = '';
      	  String paymentTerm = '';
      	  List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(false);  
            SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            Test.stopTest();
    }
    
    static testMethod void SalesOrderReturnTest2B() 
    {
      System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% empieza SalesOrderReturnTest2B');   

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
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
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

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
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
            System.debug('CARLOS=LAT_ExternalId__c= '+produto.LAT_ExternalId__c);
            
              
            //Cria novo sku.
            sku = new SKU__c();
            sku.Name = produto.LAT_SKU__c ;
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
            insert opp;
            

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            oli.LAT_CdLineStatus__c = '600';
       
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
              Integer NR_order_JDE = 557799;
              Integer customer_AN8 = 34525;
              Integer customer_AN8_entrega = 34525;
              String NR_customer_order = '1';
              String companyCode = '1';
              String DS_message1 = 'MSG1';
              String DS_message2 = 'MSG2';
              String DT_delivery = String.ValueOf(System.now());
              String Freight = 'C';
              String DT_Order = String.ValueOf(System.now());
              String DT_Faturamento = String.ValueOf(System.now());
              String CD_Order_Type = 'teste';
              Integer cd_order_status = 1;
              String CD_Deposito = '4433';
              String SalesOrder_Source = 'C';
              String priceComponents = '';
              integer returnCode = 0;
              String returnMessage = '';
              String purchaseOrderUntil = '';
              String retentionReason = '';
              String paymentTerm = '';
              List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(true);  
            SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            Test.stopTest();
    }

    static testMethod void SalesOrderReturnTest3() 
    {
      System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% empieza SalesOrderReturnTest3');   

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
            User usuario                          = null;
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

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario;  
            
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
            
            //Recupera o catalogo de preço padrão
            List<Pricebook2> catalogoPreco = [SELECT Id, Description FROM Pricebook2 WHERE isStandard = true limit 1];
            
            //Cria novo catalogo
            pricebook = new Pricebook2();
            pricebook.Name = acc.Price_Group__c;
            pricebook.IsActive = true;
            insert pricebook;
            
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
            System.debug('CARLOS=Internal_id__c= '+produto.Internal_id__c);
            
            //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            insert entradaCatalogoPreco;
            
            //Cria nova entrada de catalogo
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pricebook.Id;  
            pbe.Product2Id = produto.Id;
            pbe.UnitPrice = 100.00;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            insert pbe;
              
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
            insert opp;
            
            //Cria um novo produto da oportunidade.
            oli = new OpportunityLineItem();
            oli.PricebookEntryId = pbe.Id;
            oli.OpportunityId    = opp.Id;
            oli.UnitPrice        = 12;
            oli.Quantity         = 12;
            oli.cd_line_status__c = '600';
            
            //insert oli;
       
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
      	  Integer NR_order_JDE = 557799;
      	  Integer customer_AN8 = 34525;
      	  Integer customer_AN8_entrega = 34525;
      	  String NR_customer_order = '1';
      	  String companyCode = '1';
      	  String DS_message1 = 'MSG1';
      	  String DS_message2 = 'MSG2';
      	  String DT_delivery = String.ValueOf(System.now());
      	  String Freight = 'C';
      	  String DT_Order = String.ValueOf(System.now());
      	  String DT_Faturamento = String.ValueOf(System.now());
      	  String CD_Order_Type = 'teste';
      	  Integer cd_order_status = 1;
      	  String CD_Deposito = '4433';
      	  String SalesOrder_Source = 'C';
      	  String priceComponents = '';
      	  integer returnCode = 0;
      	  String returnMessage = '';
      	  String purchaseOrderUntil = '';
      	  String retentionReason = '';
      	  String paymentTerm = '';
      	  List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(false); 
            try{
              SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }catch(Exception e){
              System.debug('ERRO: '+e.getMessage());
            }
            Test.stopTest();
    }
    
    static testMethod void SalesOrderReturnTest3B() 
    {
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% empieza SalesOrderReturnTest3B');   

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
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
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

            //Recupera o ID do perfil desejado.
            usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
            insert usuario; 
            
            //Cria novo Account.
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
            
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
            System.debug('CARLOS=LAT_ExternalId__c= '+produto.LAT_ExternalId__c);

  
              
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
            insert opp;


            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            oli.LAT_CdLineStatus__c = '600';
       
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
              Integer NR_order_JDE = 557799;
              Integer customer_AN8 = 34525;
              Integer customer_AN8_entrega = 34525;
              String NR_customer_order = '1';
              String companyCode = '1';
              String DS_message1 = 'MSG1';
              String DS_message2 = 'MSG2';
              String DT_delivery = String.ValueOf(System.now());
              String Freight = 'C';
              String DT_Order = String.ValueOf(System.now());
              String DT_Faturamento = String.ValueOf(System.now());
              String CD_Order_Type = 'teste';
              Integer cd_order_status = 1;
              String CD_Deposito = '4433';
              String SalesOrder_Source = 'C';
              String priceComponents = '';
              integer returnCode = 0;
              String returnMessage = '';
              String purchaseOrderUntil = '';
              String retentionReason = '';
              String paymentTerm = '';
              List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(true); 
            try{
              SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }catch(Exception e){
              System.debug('ERRO: '+e.getMessage());
            }
            Test.stopTest();
    }

    static testMethod void SalesOrderReturnTest4() 
    {       
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%% empieza SalesOrderReturnTest4');      
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
            User usuario                          = null;
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
            
            //Recupera o ID do perfil desejado.
            perfil = [Select Id From Profile Where Name=:'System Administrator' OR Name = 'Administrador do sistema'];
            
            //Cria novo usuario.
            usuario = new User();
            usuario.FirstName       = 'Nome';
            usuario.LastName      = 'Sobrenome';
            usuario.Alias       = 'NSobre';
            usuario.Email         = 'nome@sobrenome.com';
            usuario.Username      = 'devtestusercloud2b@cloud2b.com.br';
            usuario.CommunityNickname   = '123jjjuuu';
            usuario.EmailEncodingKey  = 'ISO-8859-1';
            usuario.TimeZoneSidKey    = 'GMT';
            usuario.LocaleSidKey    = 'en_Us';
            usuario.LanguageLocaleKey = 'en_Us';
            usuario.C_digo_JDE__c   = '234';
            usuario.ProfileId       = perfil.Id;
            usuario.Country = 'BR';
            insert usuario;
          
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
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
            
            Account varAcc = [SELECT Id, Client_country_AN8__c, RecordTypeId FROM Account Where id =:acc.Id];
            System.debug('%%%%%%%%%%%%%%%%%%%%%% account '+varAcc.Client_country_AN8__c + ' RecordType '+ varAcc.RecordTypeId);
            //Recupera o catalogo de preço padrão
            List<Pricebook2> catalogoPreco = [SELECT Id, Description FROM Pricebook2 WHERE isStandard = true limit 1];
            
            //Cria novo catalogo
            pricebook = new Pricebook2();
            pricebook.Name = acc.Price_Group__c;
            pricebook.IsActive = true;
            insert pricebook;
            
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
            System.debug('CARLOS=Internal_id__c= '+produto.Internal_id__c);
            
            //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
            PricebookEntry entradaCatalogoPreco = new PricebookEntry();
            entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
            entradaCatalogoPreco.Product2Id = produto.Id;
            entradaCatalogoPreco.UnitPrice = 1000.00;
            entradaCatalogoPreco.IsActive = true;
            entradaCatalogoPreco.UseStandardPrice = false;
            insert entradaCatalogoPreco;
            
            //Cria nova entrada de catalogo
            pbe = new PricebookEntry();
            pbe.Pricebook2Id = pricebook.Id;  
            pbe.Product2Id = produto.Id;
            pbe.UnitPrice = 100.00;
            pbe.IsActive = true;
            pbe.UseStandardPrice = false;
            insert pbe;
              
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
            insert opp;
            
            //Cria um novo produto da oportunidade.
            oli = new OpportunityLineItem();
            oli.PricebookEntryId = pbe.Id;
            oli.OpportunityId    = opp.Id;
            oli.UnitPrice        = 12;
            oli.Quantity         = 12;
            oli.cd_line_status__c = '600';
            
            //insert oli;
       
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
      	  Integer NR_order_JDE = 34525;
      	  Integer customer_AN8 = 557798;
      	  Integer customer_AN8_entrega = 557798;
      	  String NR_customer_order = '1';
      	  String companyCode = '1';
      	  String DS_message1 = 'MSG1';
      	  String DS_message2 = 'MSG2';
      	  String DT_delivery = String.ValueOf(System.now());
      	  String Freight = 'D';
      	  String DT_Order = String.ValueOf(System.now());
      	  String DT_Faturamento = String.ValueOf(System.now());
      	  String CD_Order_Type = 'teste';
      	  Integer cd_order_status = 1;
      	  String CD_Deposito = '4433';
      	  String SalesOrder_Source = 'D';
      	  String priceComponents = '';
      	  integer returnCode = 0;
      	  String returnMessage = '';
      	  String purchaseOrderUntil = '';
      	  String retentionReason = '';
      	  String paymentTerm = '';
      	  List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(false);
            try{
                  List<PricebookEntry> pbeList =new List<PricebookEntry>();
                  pbeList.add(pbe);
              SalesOrderReturn.activatesPricebookEntrys(pbeList);
              SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }catch(Exception e){
              system.debug('ERRO: '+e.getMessage());
            }
            Test.stopTest();
    }

    static testMethod void SalesOrderReturnTest4B() 
    {
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
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            List<RecordType> listRecType          = null;
            List<String> developerName            = null;
            Map<String, String> mapRecType        = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            
            //Recupera os IDS de tipo de registro.
            idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
            
            //Recupera o ID do perfil desejado.
            perfil = [Select Id From Profile Where Name=:'System Administrator' OR Name = 'Administrador do sistema'];
            
            //Cria novo usuario.
            usuario = new User();
            usuario.FirstName       = 'Nome';
            usuario.LastName      = 'Sobrenome';
            usuario.Alias       = 'NSobre';
            usuario.Email         = 'nome@sobrenome.com';
            usuario.Username      = 'devtestusercloud2b@cloud2b.com.br';
            usuario.CommunityNickname   = '123jjjuuu';
            usuario.EmailEncodingKey  = 'ISO-8859-1';
            usuario.TimeZoneSidKey    = 'GMT';
            usuario.LocaleSidKey    = 'en_Us';
            usuario.LanguageLocaleKey = 'en_Us';
            usuario.C_digo_JDE__c   = '234';
            usuario.ProfileId       = perfil.Id;
            usuario.Country = 'BR';
            insert usuario;
          
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
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;
            


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
            System.debug('CARLOS=LAT_ExternalId__c= '+produto.LAT_ExternalId__c);

              
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
            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            oli.LAT_CdLineStatus__c = '600';
       
       
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
              Integer NR_order_JDE = 557799;
              Integer customer_AN8 = 34525;
              Integer customer_AN8_entrega = 34525;
              String NR_customer_order = '1';
              String companyCode = '1';
              String DS_message1 = 'MSG1';
              String DS_message2 = 'MSG2';
              String DT_delivery = String.ValueOf(System.now());
              String Freight = 'C';
              String DT_Order = String.ValueOf(System.now());
              String DT_Faturamento = String.ValueOf(System.now());
              String CD_Order_Type = 'teste';
              Integer cd_order_status = 1;
              String CD_Deposito = '4433';
              String SalesOrder_Source = 'C';
              String priceComponents = '';
              integer returnCode = 0;
              String returnMessage = '';
              String purchaseOrderUntil = '';
              String retentionReason = '';
              String paymentTerm = '';
              List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(true);
            try{
              SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }catch(Exception e){
              system.debug('ERRO: '+e.getMessage());
            }
            Test.stopTest();
    }


    static testMethod void SalesOrderReturnTest5B() 
    {
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
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            List<RecordType> listRecType          = null;
            List<String> developerName            = null;
            Map<String, String> mapRecType        = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            
            //Recupera os IDS de tipo de registro.
            idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
            
            //Recupera o ID do perfil desejado.
            perfil = [Select Id From Profile Where Name=:'System Administrator' OR Name = 'Administrador do sistema'];
            
            //Cria novo usuario.
            usuario = new User();
            usuario.FirstName       = 'Nome';
            usuario.LastName      = 'Sobrenome';
            usuario.Alias       = 'NSobre';
            usuario.Email         = 'nome@sobrenome.com';
            usuario.Username      = 'devtestusercloud2b@cloud2b.com.br';
            usuario.CommunityNickname   = '123jjjuuu';
            usuario.EmailEncodingKey  = 'ISO-8859-1';
            usuario.TimeZoneSidKey    = 'GMT';
            usuario.LocaleSidKey    = 'en_Us';
            usuario.LanguageLocaleKey = 'en_Us';
            usuario.C_digo_JDE__c   = '234';
            usuario.ProfileId       = perfil.Id;
            usuario.Country = 'BR';
            insert usuario;
          
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
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;

            


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
            System.debug('CARLOS=LAT_ExternalId__c= '+produto.LAT_ExternalId__c);

              
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
            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            oli.LAT_CdLineStatus__c = '600';
       
       
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
              Integer NR_order_JDE = 557799;
              Integer customer_AN8 = 25;
              Integer customer_AN8_entrega = 34525;
              String NR_customer_order = '1';
              String companyCode = '1';
              String DS_message1 = 'MSG1';
              String DS_message2 = 'MSG2';
              String DT_delivery = String.ValueOf(System.now());
              String Freight = 'C';
              String DT_Order = String.ValueOf(System.now());
              String DT_Faturamento = String.ValueOf(System.now());
              String CD_Order_Type = 'teste';
              Integer cd_order_status = 1;
              String CD_Deposito = '4433';
              String SalesOrder_Source = 'C';
              String priceComponents = '';
              integer returnCode = 0;
              String returnMessage = '';
              String purchaseOrderUntil = '';
              String retentionReason = '';
              String paymentTerm = '';
              List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(true);
            try{
              SalesOrderReturn.convertToDateTime('12-12-2016 14:23');
              SalesOrderReturn.convertToDate('12-12-2016');
              SalesOrderReturn.getOrderType(1,CD_Order_Type);
              SalesOrderReturn.getOrderSigno(1,CD_Order_Type);
              SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }catch(Exception e){
              system.debug('ERRO: '+e.getMessage());
            }
            Test.stopTest();
    }

    static testMethod void SalesOrderReturnTest6B() 
    {
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
            LAT_Opportunity__c opp                       = null;
            LAT_OpportunityLineItem__c oli               = null;
            User usuario                          = null;
            LAT_Product__c produto                      = null;
            List<RecordType> listRecType          = null;
            List<String> developerName            = null;
            Map<String, String> mapRecType        = null;
            String idAccount                      = null;
            String idOpportunity                  = null;
            
            //Recupera os IDS de tipo de registro.
            idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
            
            //Recupera o ID do perfil desejado.
            perfil = [Select Id From Profile Where Name=:'System Administrator' OR Name = 'Administrador do sistema'];
            
            //Cria novo usuario.
            usuario = new User();
            usuario.FirstName       = 'Nome';
            usuario.LastName      = 'Sobrenome';
            usuario.Alias       = 'NSobre';
            usuario.Email         = 'nome@sobrenome.com';
            usuario.Username      = 'devtestusercloud2b@cloud2b.com.br';
            usuario.CommunityNickname   = '123jjjuuu';
            usuario.EmailEncodingKey  = 'ISO-8859-1';
            usuario.TimeZoneSidKey    = 'GMT';
            usuario.LocaleSidKey    = 'en_Us';
            usuario.LanguageLocaleKey = 'en_Us';
            usuario.C_digo_JDE__c   = '234';
            usuario.ProfileId       = perfil.Id;
            usuario.Country = 'BR';
            insert usuario;
          
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
            acc = new Account();
            acc.OwnerId = usuario.Id;
            acc.Name = 'CONTA';
            acc.CNPJ__c = '48843971000120';
            acc.Type = 'Outros';
            acc.RecordTypeId = idAccount;
            acc.Status__c = 'Cliente cadastrado no JDE';
            acc.Agency__c = '000';
            acc.Checking_account__c = '000';
            acc.Current_account__c = '0';
            acc.Corporate_Name__c = 'Teste';
            acc.Channel__c = 'On Trade';
            //acc.Regional__c = regional.Id;
            acc.Frequency_of_Visits__c = 'Semanal';
            acc.Client_code_AN8__c = '557798';
            acc.Price_Group__c = 'zz';
            acc.Sub_Channel__c = 'Atacadista';
            //acc.Customer_Flag__c = bandeira.Id;
            
            insert acc;

            


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
            System.debug('CARLOS=LAT_ExternalId__c= '+produto.LAT_ExternalId__c);

              
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
            insert opp;

            //Cria um novo produto da oportunidade.
            oli = new LAT_OpportunityLineItem__c();
            oli.LAT_Product__c = produto.Id;
            oli.LAT_Opportunity__c    = opp.Id;
            oli.LAT_UnitPrice__c        = 12;
            oli.LAT_Quantity__c         = 12;
            oli.LAT_CdLineStatus__c = '600';
       
       
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
              String NR_order_crm = 'Test on False';
              Integer NR_order_JDE = 557799;
              Integer customer_AN8 = 25;
              Integer customer_AN8_entrega = 34525;
              String NR_customer_order = '1';
              String companyCode = '1';
              String DS_message1 = 'MSG1';
              String DS_message2 = 'MSG2';
              String DT_delivery = String.ValueOf(System.now());
              String Freight = 'C';
              String DT_Order = String.ValueOf(System.now());
              String DT_Faturamento = String.ValueOf(System.now());
              String CD_Order_Type = 'test not';
              Integer cd_order_status = 1;
              String CD_Deposito = '4433';
              String SalesOrder_Source = 'C';
              String priceComponents = '';
              integer returnCode = 0;
              String returnMessage = '';
              String purchaseOrderUntil = '';
              String retentionReason = '';
              String paymentTerm = '';
              List<SalesOrderReturn.SalesOrderItem> listaItem = lSalesOI;
            
            Test.startTest();
            Utils.setMigrationDoneTest(true);
            try{
              SalesOrderReturn.convertToDateTime('12-12-2016 14:23');
              SalesOrderReturn.convertToDate('12-12-2016');
              SalesOrderReturn.getOrderType(1,CD_Order_Type);
              SalesOrderReturn.getOrderSigno(1,CD_Order_Type);
              SalesOrderReturn.ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }catch(Exception e){
              system.debug('ERRO: '+e.getMessage());
            }
            Test.stopTest();
    }

    
}