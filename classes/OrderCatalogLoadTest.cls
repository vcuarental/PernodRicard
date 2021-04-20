@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura da classe OrderCatalogLoad.cls
* NAME: OrderCatalogLoadTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 31/05/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 11/01/2013 
********************************************************************************/
private class OrderCatalogLoadTest
{
/*
    static testMethod void OrderCatalogLoadTest() 
    {
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade     = null;
      Profile perfil                        = null;
      Opportunity opp                       = null;
      OpportunityLineItem oli               = null;
      User usuario                          = null;
      Product2 prod                         = null;
      Pricebook2 pricebook                  = null;
      PricebookEntry pbe                    = null;
      List<RecordType> listRecType          = null;
      List<String> developerName            = null;
      Map<String, String> mapRecType        = null;
      String idAccount                      = null;
      String idOpportunity                  = null;
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
      Id idRecTypePlan = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
      Id idRecTypePC = RecordTypeForTest.getRecType( 'Produto_Concorr_ncia__c', 'BRA_Standard' );
      
      
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');
      
      //Recupera o ID do perfil desejado.
      User usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
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
      acc.Regional__c = regional.Id;
      acc.Frequency_of_Visits__c = 'Semanal';
      acc.Client_code_AN8__c = '557799';
      acc.Price_Group__c = '1';
      acc.Customer_Flag__c = bandeira.Id;
      insert acc;
      
      //Cria um novo produto
      prod = new Product2();
      prod.Country__c = 12;
      prod.customer_Group__c = 1;
      prod.Internal_id__c = '777';
      prod.cd_payment_term__c = '';
      prod.CD_Unit__c = 'UN';
      prod.CD_Wherehouse__c = '2';
      prod.QT_lead_time__c = 4;
      prod.QT_multiple__c = 5;
      prod.QT_base_bonus__c = 2;
      prod.QT_Bonus__c = 1;
      prod.PC_Bonus__c = 1;
      prod.ds_payment_term__c = '';
      prod.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
      prod.IsActive = true;
      prod.SKU__c = '444';
      prod.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
      insert prod;
      
      //Recupera o catalogo de preço padrão
      List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE Name = 'Catalogue Standard' limit 1];
  
      //Cria um pricebookEntry e adiciona o produto criado no catalogo de preço padrão.
      PricebookEntry entradaCatalogoPreco = new PricebookEntry();
      entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
      entradaCatalogoPreco.Product2Id = prod.Id;
      entradaCatalogoPreco.UnitPrice = 1000.00;
      entradaCatalogoPreco.IsActive = true;
      entradaCatalogoPreco.UseStandardPrice = false;
      insert entradaCatalogoPreco;
     
      //Recupera os IDS de tipo de registro.
      idOpportunity = RecordTypeForTest.getRecType('Opportunity','Nova_oportunidade');
      
      //Cria nova oportunidade.
      opp = new Opportunity();
      opp.Name = 'Opp TESTE COTA';
      opp.closeDate = System.today()+1;
      opp.AccountId = acc.Id;
      opp.StageName = 'Novo Pedido';
      opp.RecordTypeId = idOpportunity;
      insert opp;
      
      //Cria um novo produto da oportunidade.
      oli = new OpportunityLineItem();
      oli.PricebookEntryId = entradaCatalogoPreco.Id;
      oli.OpportunityId    = opp.Id;
      oli.UnitPrice        = 12;
      oli.Quantity         = 15;
      insert oli;
      
      OrderCatalogLoad.ETL_OrderCatalogLoad(12, 1, 777, '','UN','2', 4, 26, 4, 2, 1, 1, '', 'PROD');
      
    }*/
}