/**********************************************
 Dev: Juan Pablo Cubo       Version: 1
**********************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 16/11/2016
*
********************************************************************************/
@isTest(seeAllData=true)
public with sharing class WS05_CancelarPedido_AR_TEST {

    static testMethod void CancelarPedidoTeste() {
      
      
     //Declaração de variáveis.
        Utils.setMigrationDoneTest(false);     
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
       Id idRecTypeOpp = RecordTypeForTest.getRecType( 'Opportunity' , 'OPP_1_NewOrder_ARG' );
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
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUdc;
        insert bandeira;
        
        
        //Cria nova UDC.
        deposito = new UDC__c();
        deposito.CodDefUsuario__c = '05';
        deposito.CodProd__c     = 'CRM';
        deposito.CodUs__c     = 'DF';
        deposito.Internal_Id__c   = '876';
        deposito.RecordTypeId = idRecTypeUdc;
        insert deposito;            
        
        //Cria novo usuario.
        usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
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
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        acc.Carriers_Numbers__c = '123';
        //acc.Business_Unit__c = deposito.Id;
        
        insert acc;
        
        produto = new Product2();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.IsActive = true;
        produto.CD_Unit__c = 'UN';
        produto.Internal_id__c = '123';
        produto.QT_lead_time__c = 5;
        produto.RecordTypeId = idRecTypeProd;
        insert produto;
        
        List<Pricebook2> catalogoPreco = [SELECT Id FROM Pricebook2 WHERE IsStandard = true limit 1];
    
        PricebookEntry entradaCatalogoPreco = new PricebookEntry();
        
        entradaCatalogoPreco.Pricebook2Id = catalogoPreco[0].Id;  
        entradaCatalogoPreco.Product2Id = produto.Id;
        entradaCatalogoPreco.UnitPrice = 1000.00;
        entradaCatalogoPreco.IsActive = true;
        entradaCatalogoPreco.UseStandardPrice = false;
        insert entradaCatalogoPreco;
        
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
        insert produtosOportunidade;
          
      

        WS05_CancelarPedido_AR.RealizarCancelamento(oportunidade.id);

      
    }

    static testMethod void CancelarPedidoTesteB() {
      
      
     //Declaração de variáveis.
        Utils.setMigrationDoneTest(true);     
       Account acc                                   = null;
       UDC__c regional, bandeira, cidade, deposito   = null;
       Profile perfil                       = null;
       LAT_Opportunity__c opp                      = null;
       LAT_OpportunityLineItem__c oli,oli3         = null;
       User usuario                         = null;
       LAT_Product__c produto                     = null;
       List<RecordType> listRecType         = null;
       List<String> developerName           = null;
       Map<String, String> mapRecType       = null;
       String idAccount                     = null;
       String idOpportunity                 = null; 
       Id idRecTypeOpp = RecordTypeForTest.getRecType( 'LAT_Opportunity__c' , 'OPP_1_NewOrder_ARG' );
       Id idRecTypeUdc = RecordTypeForTest.getRecType( 'UDC__c', 'BRA_Standard' );
       Id idRecTypeProd = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard' );
       
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
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUdc;
        insert bandeira;
        
        
        //Cria nova UDC.
        deposito = new UDC__c();
        deposito.CodDefUsuario__c = '05';
        deposito.CodProd__c     = 'CRM';
        deposito.CodUs__c     = 'DF';
        deposito.Internal_Id__c   = '876';
        deposito.RecordTypeId = idRecTypeUdc;
        insert deposito;

        
        //Cria novo usuario.
        usuario = Utils_TestMethods.createUserWithProfile('Teste', 'LAT_SystemAdministrator');
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
        acc.Client_code_AN8__c = '557799';
        acc.Price_Group__c = '1';
        //acc.Customer_Flag__c = bandeira.Id;
        acc.Carriers_Numbers__c = '123';
        //acc.Business_Unit__c = deposito.Id;
        
        insert acc;
        
        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '123';
        produto.LAT_QTLeadTime__c = 5;
        produto.RecordTypeId = idRecTypeProd;
        insert produto;
        
        
        LAT_Opportunity__c oportunidade = new LAT_Opportunity__c();
        oportunidade.Name = 'Cloud2b - Oportunidade - AtualizarEventoProdutosOportunidade';
        oportunidade.LAT_Account__c = acc.Id;
        oportunidade.LAT_CloseDate__c = Date.today()+1;
        oportunidade.LAT_StageName__c = 'Novo pedido';
        oportunidade.RecordTypeId = idRecTypeOpp;
        insert oportunidade;
        
        LAT_OpportunityLineItem__c produtosOportunidade = new LAT_OpportunityLineItem__c();
        produtosOportunidade.LAT_Opportunity__c = oportunidade.Id;
        produtosOportunidade.LAT_Product__c = produto.Id;
        produtosOportunidade.LAT_Quantity__c = 1;
        produtosOportunidade.LAT_UnitPrice__c = 1000.00;
        insert produtosOportunidade;

        WS05_CancelarPedido_AR.LAT_RealizarCancelamento(oportunidade.id);

      
    }
    
}