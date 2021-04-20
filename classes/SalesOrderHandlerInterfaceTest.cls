@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe SalesOrderHandlerInterface.cls
* NAME: SalesOrderHandlerInterfaceTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 05/06/2012
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

private class SalesOrderHandlerInterfaceTest 
{

    static testMethod void SalesOrderHandlerInterfaceTest() 
    {
      Utils.setMigrationDoneTest(false);    
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade     = null;
      Id ProfileId                          = null;
      Opportunity opp                       = null;
      Profile perfil                        = null;
      OpportunityLineItem oli               = null;
      User usuario                          = null;
      Product2 produto                      = null;
      Pricebook2 pricebook                  = null;
      String idAccount                      = null;
      String idOpportunity                  = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
      
      //Recupera os IDS de tipo de registro.
      idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
      
      
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
    
      //Recupera o ID do perfil desejado.
      //ProfileId = LAT_GlobalProfileCache.getStandardAdminProfileId();
      //Cria novo usuario.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
    
      //Cria novo Account.
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      //acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      //acc.Customer_Flag__c = bandeira.Id;
      insert acc;
      
      test.startTest();
      Utils.setMigrationDoneTest(false);       
      //produto = [Select Id, Name, Sku__c From Product2 Where Sku__c = '146' AND Qtlimit 1];
      
      produto = new Product2();
      produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
      produto.IsActive = true;
      produto.CD_Unit__c = 'UN';
      produto.Internal_id__c = '146';
      //produto.QT_lead_time__c = 5;
      produto.SKU__c = '444';
      produto.RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard');
      insert produto;
      
      //Recupera o catalogo de preço padrão
      List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];
  
      //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
      PricebookEntry entradaCatalogoPreco = new PricebookEntry();
      entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
      entradaCatalogoPreco.Product2Id = produto.Id;
      entradaCatalogoPreco.UnitPrice = 1000.00;
      entradaCatalogoPreco.IsActive = true;
      entradaCatalogoPreco.UseStandardPrice = false;
      insert entradaCatalogoPreco;
        
     //Recupera os IDS de tipo de registro.
      idOpportunity = Global_RecordTypeCache.getRtId('Opportunity' + 'Nova_oportunidade');
      
      //Cria nova oportunidade.
      opp = new Opportunity();
      opp.Name = 'Opp TESTE COTA';
      opp.closeDate = System.today()+1;
      opp.RecordTypeId = idOpportunity;
      opp.AccountId = acc.Id;
      opp.StageName = 'Novo Pedido';
      
      insert opp;

      String lIdOpp = opp.Id;
      
      SalesOrderHandlerInterface.SalesOrderInterface(lIdOpp);
      SalesOrderHandlerInterface.getConnectionParameter();

      //Cria um novo produto da oportunidade.
      oli = new OpportunityLineItem();
      oli.PricebookEntryId = entradaCatalogoPreco.Id;
      oli.OpportunityId    = opp.Id;
      oli.UnitPrice        = 12;
      oli.Quantity         = 12;
      insert oli;
      
      SalesOrderHandlerInterface.SalesOrderInterface(lIdOpp);
      SalesOrderHandlerInterface.getConnectionParameter();
      
      test.stopTest(); 
    
    }

    static testMethod void SalesOrderHandlerInterfaceTestB() 
    {
      Utils.setMigrationDoneTest(false);    
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade     = null;
      Id ProfileId                          = null;
      LAT_Opportunity__c opp                       = null;
      Profile perfil                        = null;
      LAT_OpportunityLineItem__c oli               = null;
      User usuario                          = null;
      LAT_Product__c produto                      = null;
      String idAccount                      = null;
      String idOpportunity                  = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
      
      //Recupera os IDS de tipo de registro.
      idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
      
      //Recupera o ID do perfil desejado.
      //ProfileId = LAT_GlobalProfileCache.getStandardAdminProfileId();

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

      //Cria novo usuario.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
    
    
      //Cria novo Account.
      acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.RecordTypeId = idAccount;
      acc.Status__c = 'Cliente cadastrado no JDE';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.Channel__c = 'Off Trade';
      //acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      //acc.Customer_Flag__c = bandeira.Id;
      insert acc;
      
      test.startTest();
      Utils.setMigrationDoneTest(false);       
      //produto = [Select Id, Name, Sku__c From Product2 Where Sku__c = '146' AND Qtlimit 1];
      
      produto = new LAT_Product__c();
      produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
      produto.LAT_IsActive__c = true;
      produto.LAT_CDUnit__c = 'UN';
      produto.LAT_ExternalId__c = '146';
      //produto.QT_lead_time__c = 5;
      produto.LAT_Sku__c = '444';
      produto.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard');
      insert produto;
      
        
     //Recupera os IDS de tipo de registro.
      idOpportunity = Global_RecordTypeCache.getRtId('LAT_Opportunity__c' + 'Nova_oportunidade');
      
      //Cria nova oportunidade.
      opp = new LAT_Opportunity__c();
      opp.Name = 'Opp TESTE COTA';
      opp.LAT_CloseDate__c = System.today()+1;
      opp.RecordTypeId = idOpportunity;
      opp.LAT_Account__c = acc.Id;
      opp.LAT_StageName__c = 'Novo Pedido';
      
      insert opp;
      
      String lIdOpp = opp.Id;
      
      SalesOrderHandlerInterface.LAT_SalesOrderInterface(lIdOpp);
      SalesOrderHandlerInterface.getConnectionParameter();

      //Cria um novo produto da oportunidade.
      oli = new LAT_OpportunityLineItem__c();
      oli.LAT_Product__c = produto.Id;
      oli.LAT_Opportunity__c    = opp.Id;
      oli.LAT_UnitPrice__c        = 12;
      oli.LAT_Quantity__c         = 12;
      insert oli;
      
      SalesOrderHandlerInterface.LAT_SalesOrderInterface(lIdOpp);
      SalesOrderHandlerInterface.getConnectionParameter();
      
      test.stopTest(); 
    
    }    
    
    static testMethod void SalesOrderHandlerInterfaceTest2() 
    {
    
        SalesOrderHandlerTypes.SalesOrderItemResponseType l1 = new SalesOrderHandlerTypes.SalesOrderItemResponseType();
        l1.lineNumber = 1;
        l1.orderLineStatus = '';
        l1.orderLineStatusDescription = '';
        l1.priceComponents = '';
        l1.salesPriceValue = 0;
        l1.sku = '0';
        
        SalesOrderHandlerTypes.SalesOrderHandlerResponseType l2 = new SalesOrderHandlerTypes.SalesOrderHandlerResponseType();
        l2.returnCode = 0;
        
        SalesOrderHandlerTypes.SalesOrderHeaderResponseType l3 = new SalesOrderHandlerTypes.SalesOrderHeaderResponseType();
        l3.customerBuyOrder = '';
        l3.customerCode = 0;
        l3.customerShippingCode = 0;
        l3.orderNumber = 0;
        l3.orderNumberForeign = 0;
        l3.orderStatus = 0;
        l3.orderType = '';
        l3.priceComponents = '';
        l3.returnCode = 0;
        
        test.startTest();
        
        SalesOrderHandlerTypes.SalesOrderItemRequestType l4 = new SalesOrderHandlerTypes.SalesOrderItemRequestType();
        l4.actionCode = '';
        l4.billedTotalQuantity = 0;
        l4.bonusPercentual = 0;
        l4.bonusQuantity = 0;
        l4.bonusUnit = '';
        l4.lineNumber = 0;
        l4.orderLineStatus = '';
        l4.paymentTerm = '';
        l4.percentualDiscount = 0;
        l4.salesUOM = '';
        l4.sku = '0';
        
        SalesOrderHandlerTypes.SalesOrderHeaderRequestType l5 = new SalesOrderHandlerTypes.SalesOrderHeaderRequestType();
        l5.actionCode = '';
        l5.businessUnit = '';
        l5.customerBuyOrder = '';
        l5.customerCode = 0;
        l5.customerShippingCode = 0;
        l5.freightType = '';
        l5.invoiceDate = system.today();
        l5.note1 = '';
        l5.note2 = '';
        l5.orderNumber = 0;
        l5.orderNumberForeign = '';
        l5.orderRequestDate = system.today();
        l5.orderRequestTime = 0;
        l5.orderStatus = 0;
        l5.orderType = '';
        l5.promisedDate = system.today();
        l5.salesman = '';
        
        SalesOrderHandlerTypes.SalesOrderHandlerFaultType l6 = new SalesOrderHandlerTypes.SalesOrderHandlerFaultType();
        l6.faultCode = '';
        l6.faultMessage = '';
        
        test.stopTest(); 
    
    }

}