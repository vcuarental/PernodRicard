@isTest(seeAllData=false)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do código CancelarPedido.cls 
* NAME: CancelarPedidoTest.cls
* AUTHOR:                                        DATE: 
*
* MAINTENANCE: Classe não estava executando o teste corretamente.
* AUTHOR:CARLOS CARVALHO                         DATE: 14/05/2012
*
* MAINTENANCE: Foram criados novos códigos, o que inutilizou a classe antiga.
* AUTHOR:CARLOS CARVALHO                         DATE: 25/05/2012
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS 
* OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 09/01/2013 
********************************************************************************/
private class CancelarPedidoTest {

    static testMethod void CancelarPedidoTest() {
      
      
     //Declaração de variáveis.
     
     Account acc                                   = null;
     UDC__c regional, bandeira, cidade, deposito   = null;
     Profile perfil                       = null;
     Opportunity opp                      = null;
     OpportunityLineItem oli,oli3         = null;
     User usuario                         = null;
     Product2 produto                     = null;
     Pricebook2 pricebook                 = null;
     PricebookEntry pbe                   = null;
     List<RecordType> listRecType         = null;
     List<String> developerName           = null;
     Map<String, String> mapRecType       = null;
     String idAccount                     = null;
     String idOpportunity                 = null; 
     Id idRecTypeOpp = RecordTypeForTest.getRecType( 'Opportunity' , 'Nova_oportunidade' );
     Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
     Id idRecTypeProd = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard' );
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account', 'Off_Trade');

    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '1234';
      regional.RecordTypeId = idRecTypeUdc;
      insert regional;
      
      
      //Cria nova UDC.
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '014516';
      bandeira.RecordTypeId = idRecTypeUdc;
      Database.upsert(bandeira, UDC__c.Fields.Internal_Id__c);
      
      
      //Cria nova UDC.
      deposito = new UDC__c();
      deposito.CodDefUsuario__c = '05';
      deposito.CodProd__c     = 'CRM';
      deposito.CodUs__c     = 'DF';
      deposito.Internal_Id__c   = 'CRM-DF876';
      deposito.RecordTypeId = idRecTypeUdc;
      insert deposito;


      //Recupera o ID do perfil desejado.
      
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
      acc.Carriers_Numbers__c = '123';
      acc.Business_Unit__c = deposito.Id;
      
      insert acc;
      
      produto = new Product2();
      produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
      produto.IsActive = true;
      produto.CD_Unit__c = 'UN';
      produto.Internal_id__c = '123';
      //produto.QT_lead_time__c = 5;
      produto.RecordTypeId = idRecTypeProd;
      //insert produto;
      
      //List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1];
  
      PricebookEntry entradaCatalogoPreco = new PricebookEntry();
      Id pricebookId = Test.getStandardPricebookId();
      entradaCatalogoPreco.Pricebook2Id = pricebookId;  
      entradaCatalogoPreco.Product2Id = produto.Id;
      entradaCatalogoPreco.UnitPrice = 1000.00;
      entradaCatalogoPreco.IsActive = true;
      entradaCatalogoPreco.UseStandardPrice = false;
      //insert entradaCatalogoPreco;
      
      Opportunity oportunidade = new Opportunity();
      oportunidade.Name = 'Cloud2b - Oportunidade - AtualizarEventoProdutosOportunidade';
      oportunidade.AccountId = acc.Id;
      oportunidade.CloseDate = Date.today()+1;
      oportunidade.StageName = 'Novo pedido';
      oportunidade.RecordTypeId = idRecTypeOpp;
      insert oportunidade;
      
      OpportunityLineItem produtosOportunidade = new OpportunityLineItem();
      produtosOportunidade.OpportunityId = oportunidade.Id;
      produtosOportunidade.PricebookEntryId = entradaCatalogoPreco.Id;
      produtosOportunidade.Quantity = 1;
      produtosOportunidade.UnitPrice = 1000.00;
      try{
        insert produtosOportunidade;
      } catch(Exception e){

      }
      Utils.setMigrationDoneTest(false);
      Test.startTest();
      try{
        CancelarPedido.RealizarCancelamento(oportunidade.id);
      }
      catch(Exception e)
      {
        System.debug(e.getMessage());
      }
      Test.stopTest();

    }
    static testMethod void CancelarPedidoTest2() {
      
      
     //Declaração de variáveis.
     
     Account acc                                   = null;
     UDC__c regional, bandeira, cidade, deposito   = null;
     Profile perfil                       = null;
     User usuario                         = null;
     List<RecordType> listRecType         = null;
     List<String> developerName           = null;
     Map<String, String> mapRecType       = null;
     String idAccount                     = null;
     String idOpportunity                 = null; 
     //VARIABLES MIGRACION LICENCIA
     LAT_Opportunity__c LAT_opp                      = null;
     LAT_OpportunityLineItem__c LAT_oli,LAT_oli3         = null;
     LAT_Product__c LAT_produto                     = null;
     Id LAT_idRecTypeOpp = RecordTypeForTest.getRecType( 'LAT_Opportunity__c' , 'Nova_oportunidade' );
     Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
     Id LAT_idRecTypeProd = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account', 'Off_Trade');

    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '1234';
      regional.RecordTypeId = idRecTypeUdc;
      insert regional;
      
      
      //Cria nova UDC.
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '014516';
      bandeira.RecordTypeId = idRecTypeUdc;
      Database.upsert(bandeira, UDC__c.Fields.Internal_Id__c);
      
      
      //Cria nova UDC.
      deposito = new UDC__c();
      deposito.CodDefUsuario__c = '05';
      deposito.CodProd__c     = 'CRM';
      deposito.CodUs__c     = 'DF';
      deposito.Internal_Id__c   = 'CRM-DF876';
      deposito.RecordTypeId = idRecTypeUdc;
      insert deposito;


      //Recupera o ID do perfil desejado.
      
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
      acc.Carriers_Numbers__c = '123';
      acc.Business_Unit__c = deposito.Id;
      
      insert acc;

      LAT_produto = new LAT_Product__c();
      LAT_produto.Name = 'Cloud2b - LAT_Produto - AtualizarEventoProdutosOportunidade';
      LAT_produto.LAT_IsActive__c = true;
      LAT_produto.LAT_CDUnit__c = 'UN';
      LAT_produto.LAT_ExternalID__c = '123';
      //produto.QT_lead_time__c = 5;
      LAT_produto.RecordTypeId = LAT_idRecTypeProd;

      LAT_Opportunity__c LAT_oportunidade = new LAT_Opportunity__c();
      LAT_oportunidade.Name = 'Cloud2b - LAT Oportunidade - AtualizarEventoProdutosOportunidade';
      LAT_oportunidade.LAT_Account__c = acc.Id;
      LAT_oportunidade.LAT_CloseDate__c = Date.today()+1;
      LAT_oportunidade.LAT_StageName__c = 'Novo pedido';
      LAT_oportunidade.RecordTypeId = LAT_idRecTypeOpp;
      insert LAT_oportunidade;
      
      LAT_OpportunityLineItem__c LAT_produtosOportunidade = new LAT_OpportunityLineItem__c();
      LAT_produtosOportunidade.LAT_Opportunity__c = LAT_oportunidade.Id;
      LAT_produtosOportunidade.LAT_Product__c = LAT_produto.Id;
      LAT_produtosOportunidade.LAT_Quantity__c = 1;
      LAT_produtosOportunidade.LAT_UnitPrice__c = 1000.00;



      try{
        insert LAT_produtosOportunidade;
      } catch(Exception e){

      }
      Test.startTest();
      Utils.setMigrationDoneTest(true);
      try{
        CancelarPedido.RealizarCancelamento(LAT_oportunidade.id);
      }
      catch(Exception e)
      {
        System.debug(e.getMessage());
      }

    }

}