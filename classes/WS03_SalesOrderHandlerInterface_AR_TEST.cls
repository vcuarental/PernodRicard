/**********************************************
 Dev: Juan Pablo Cubo Version: 1
**********************************************/
 /********************************************************************************
*
* MIGRACION LICENCIAS
* AUTHOR: ZIMMIC                     DATE: 16/11/2016
*
********************************************************************************/

@isTest(seeAllData=true)
public with sharing class WS03_SalesOrderHandlerInterface_AR_TEST {
    
    static testMethod void SalesOrderHandlerInterfaceTestB(){
      Utils.setMigrationDoneTest(true);
      //Declaração de variáveis.
      Account acc = null;
      UDC__c regional, bandeira, cidade = null;
      Profile perfil = null;
      LAT_Opportunity__c opp = null;
      LAT_OpportunityLineItem__c oli = null;
      User usuario = null;
      LAT_Product__c produto = null;
      List<RecordType> listRecType = null;
      List<String> developerName = null;
      Map<String, String> mapRecType = null;
      String idAccount = null;
      String idOpportunity = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

      User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

      System.runAs(thisUser){
        //Recupera o ID do perfil desejado.
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
      }

      System.runAs(usuario){
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c= '01';
        regional.CodUs__c= '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c= '01';
        bandeira.CodUs__c= '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;

        acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        insert acc;

        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '146';
        produto.LAT_QTLeadTime__c = 5;
        produto.LAT_Sku__c = '444';
        produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
        insert produto;

        //Recupera os IDS de tipo de registro.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        insert opp;
        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c = opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        oli.LAT_AR_Discount__c = 21;
        oli.LAT_AR_MaxDiscount__c = 5;
        insert oli;
        String lIdOpp = opp.Id;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        opp.LAT_Type__c = 'SJ - Ofrecidos de Ventas por Acuerdos';
        opp.RecordTypeId = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_2_NewOrder_URU');
        opp.LAT_StageName__c = 'Pedido Ofrecido en aprobación';
        System.Test.startTest();
        update opp;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
      
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.getConnectionParameter('Argentina');
      
        Utils.setMigrationDoneTest(true);
        WS03_SalesOrderHandlerInterface_AR.SalesOrderInterfaceFuture(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.SalesOrderInterface(lIdOpp);
        System.Test.stopTest();
      }
    }

    static testMethod void SalesOrderHandlerInterfaceTest14(){
      try{
        Utils.setMigrationDoneTest(true);
        //Declaração de variáveis.
        Account acc = null;
        UDC__c regional, bandeira, cidade = null;
        Profile perfil = null;
        LAT_Opportunity__c opp = null;
        LAT_OpportunityLineItem__c oli = null;
        User usuario = null;
        LAT_Product__c produto = null;
        List<RecordType> listRecType = null;
        List<String> developerName = null;
        Map<String, String> mapRecType = null;
        String idAccount = null;
        String idOpportunity = null;
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

        //Recupera os IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(thisUser){
          //Recupera o ID do perfil desejado.
          usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
        }

        System.runAs(usuario){
          //Cria nova UDC.
          regional = new UDC__c();
          regional.CodDefUsuario__c = '4546';
          regional.CodProd__c= '01';
          regional.CodUs__c= '01';
          regional.Internal_Id__c   = '1234';
          regional.RecordTypeId = idRecTypeUDC;
          insert regional;

          //Cria nova UDC.
          bandeira = new UDC__c();
          bandeira.CodDefUsuario__c = '179';
          bandeira.CodProd__c= '01';
          bandeira.CodUs__c= '06';
          bandeira.Internal_Id__c   = '1236';
          bandeira.RecordTypeId = idRecTypeUDC;
          insert bandeira;

          acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
          acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
          acc.Status__c = 'Cliente cadastrado no JDE';
          acc.Frequency_of_Visits__c = 'Semanal';
          acc.Client_code_AN8__c = '557799';
          acc.Client_country_an8__c = '6-557799';
          acc.Corporate_Name__c = 'Teste';
          acc.Checking_account__c = '000';
          acc.Carriers_Numbers__c = '123';
          insert acc;

          produto = new LAT_Product__c();
          produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
          produto.LAT_IsActive__c = true;
          produto.LAT_CDUnit__c = 'UN';
          produto.LAT_ExternalId__c = '146';
          produto.LAT_QTLeadTime__c = 5;
          produto.LAT_Sku__c = '444';
          produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
          insert produto;

          //Recupera os IDS de tipo de registro.
          idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');
          System.Test.startTest();
          //Cria nova oportunidade.
          opp = new LAT_Opportunity__c();
          opp.Name = 'Opp TESTE COTA';
          opp.LAT_CloseDate__c = System.today()+1;
          opp.RecordTypeId = idOpportunity;
          opp.LAT_Account__c = acc.Id;
          opp.LAT_StageName__c = 'Mobile Order';
          opp.LAT_OrderOrigin__c = 'APP';
          insert opp;
          //Cria um novo produto da oportunidade.
          oli = new LAT_OpportunityLineItem__c();
          oli.LAT_Product__c = produto.Id;
          oli.LAT_Opportunity__c = opp.Id;
          oli.LAT_UnitPrice__c = 12;
          oli.LAT_Quantity__c = 12;
          oli.LAT_AR_Discount__c = 21;
          oli.LAT_AR_MaxDiscount__c = 5;
          insert oli;
          String lIdOpp = opp.Id;
          try{WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);}catch(Exception e){}
          
          Utils.setMigrationDoneTest(true);
          System.Test.stopTest();
        }
      }catch(Exception e) {}
    }
    
    static testMethod void SalesOrderHandlerInterfaceTest14Uru(){
      try{
        Utils.setMigrationDoneTest(true);
        Account acc = null;
        UDC__c regional, bandeira, cidade = null;
        Profile perfil = null;
        LAT_Opportunity__c opp = null;
        LAT_OpportunityLineItem__c oli = null;
        User usuario = null;
        LAT_Product__c produto = null;
        List<RecordType> listRecType = null;
        List<String> developerName = null;
        Map<String, String> mapRecType = null;
        String idAccount = null;
        String idOpportunity = null;
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

        //Recupera los IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(thisUser){
          //Recupera el ID do perfil deseado.
          usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
        }

        System.runAs(usuario){
          regional = new UDC__c();
          regional.CodDefUsuario__c = '4546';
          regional.CodProd__c= '01';
          regional.CodUs__c= '01';
          regional.Internal_Id__c   = '1234';
          regional.RecordTypeId = idRecTypeUDC;
          insert regional;

          bandeira = new UDC__c();
          bandeira.CodDefUsuario__c = '179';
          bandeira.CodProd__c= '01';
          bandeira.CodUs__c= '06';
          bandeira.Internal_Id__c   = '1236';
          bandeira.RecordTypeId = idRecTypeUDC;
          insert bandeira;

          acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
          acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
          acc.Status__c = 'Cliente cadastrado no JDE';
          acc.Frequency_of_Visits__c = 'Semanal';
          acc.Client_code_AN8__c = '557799';
          acc.Client_country_an8__c = '6-557799';
          acc.Corporate_Name__c = 'Teste';
          acc.Checking_account__c = '000';
          acc.Carriers_Numbers__c = '123';
          insert acc;

          produto = new LAT_Product__c();
          produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
          produto.LAT_IsActive__c = true;
          produto.LAT_CDUnit__c = 'UN';
          produto.LAT_ExternalId__c = '146';
          produto.LAT_QTLeadTime__c = 5;
          produto.LAT_Sku__c = '444';
          produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
          insert produto;

          //Recupera los IDS de tipo de registro.
          idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_2_NewOrder_URU');
            
          System.Test.startTest();
          opp = new LAT_Opportunity__c();
          opp.Name = 'Opp TEST COTA';
          opp.LAT_CloseDate__c = System.today()+1;
          opp.RecordTypeId = idOpportunity;
          opp.LAT_Account__c = acc.Id;
          opp.LAT_StageName__c = 'Mobile Order';
          opp.LAT_OrderOrigin__c = 'APP';
          insert opp;
          
          oli = new LAT_OpportunityLineItem__c();
          oli.LAT_Product__c = produto.Id;
          oli.LAT_Opportunity__c = opp.Id;
          oli.LAT_UnitPrice__c = 12;
          oli.LAT_Quantity__c = 12;
          oli.LAT_AR_Discount__c = 21;
          oli.LAT_AR_MaxDiscount__c = 5;
          insert oli;
            
          String lIdOpp = opp.Id;
          try{WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);}catch(Exception e){}
          
          Utils.setMigrationDoneTest(true);
          System.Test.stopTest();
        }
      } catch(Exception e) {}
    }
  
    static testMethod void SalesOrderHandlerInterfaceTest4Uru(){
      try{
        Utils.setMigrationDoneTest(true);
        Account acc = null;
        UDC__c regional, bandeira, cidade = null;
        Profile perfil = null;
        LAT_Opportunity__c opp = null;
        LAT_OpportunityLineItem__c oli = null;
        User usuario = null;
        LAT_Product__c produto = null;
        List<RecordType> listRecType = null;
        List<String> developerName = null;
        Map<String, String> mapRecType = null;
        String idAccount = null;
        String idOpportunity = null;
        Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

        //Recupera los IDS de tipo de registro.
        idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs(thisUser){
          //Recupera el ID do perfil deseado.
          usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','UY');
        }

        System.runAs(usuario){
          regional = new UDC__c();
          regional.CodDefUsuario__c = '4546';
          regional.CodProd__c= '01';
          regional.CodUs__c= '01';
          regional.Internal_Id__c   = '1234';
          regional.RecordTypeId = idRecTypeUDC;
          insert regional;

          bandeira = new UDC__c();
          bandeira.CodDefUsuario__c = '179';
          bandeira.CodProd__c= '01';
          bandeira.CodUs__c= '06';
          bandeira.Internal_Id__c   = '1236';
          bandeira.RecordTypeId = idRecTypeUDC;
          insert bandeira;

          acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
          acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
          acc.Status__c = 'Cliente cadastrado no JDE';
          acc.Frequency_of_Visits__c = 'Semanal';
          acc.Client_code_AN8__c = '557799';
          acc.Client_country_an8__c = '6-557799';
          acc.Corporate_Name__c = 'Teste';
          acc.Checking_account__c = '000';
          acc.Carriers_Numbers__c = '123';
          insert acc;

          produto = new LAT_Product__c();
          produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
          produto.LAT_IsActive__c = true;
          produto.LAT_CDUnit__c = 'UN';
          produto.LAT_ExternalId__c = '146';
          produto.LAT_QTLeadTime__c = 5;
          produto.LAT_Sku__c = '444';
          produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
          insert produto;

          //Recupera los IDS de tipo de registro.
          idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_2_NewOrder_URU');
            
          System.Test.startTest();
          opp = new LAT_Opportunity__c();
          opp.Name = 'Opp TEST COTA';
          opp.LAT_CloseDate__c = System.today()+1;
          opp.RecordTypeId = idOpportunity;
          opp.LAT_Account__c = acc.Id;
          opp.LAT_StageName__c = 'Mobile Order';
          opp.LAT_OrderOrigin__c = 'APP';
          opp.LAT_Type__c = 'SV';
          insert opp;
          
          oli = new LAT_OpportunityLineItem__c();
          oli.LAT_Product__c = produto.Id;
          oli.LAT_Opportunity__c = opp.Id;
          oli.LAT_UnitPrice__c = 12;
          oli.LAT_Quantity__c = 12;
          oli.LAT_AR_Discount__c = 21;
          oli.LAT_AR_MaxDiscount__c = 5;
          insert oli;
            
          String lIdOpp = opp.Id;
          try {
            WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
          } catch(Exception e){}
          
          Utils.setMigrationDoneTest(true);
          System.Test.stopTest();
        }
      } catch(Exception e) {}
    }
  
    static testMethod void SalesOrderHandlerInterfaceTest2B(){

      Utils.setMigrationDoneTest(true);
      //Declaração de variáveis.
      Account acc = null;
      UDC__c regional, bandeira, cidade = null;
      Profile perfil = null;
      LAT_Opportunity__c opp = null;
      LAT_OpportunityLineItem__c oli = null;
      User usuario = null;
      LAT_Product__c produto = null;
      List<RecordType> listRecType = null;
      List<String> developerName = null;
      Map<String, String> mapRecType = null;
      String idAccount = null;
      String idOpportunity = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

      User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

      System.runAs(thisUser){
        //Recupera o ID do perfil desejado.
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
      }

      System.runAs(usuario){
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c= '01';
        regional.CodUs__c= '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c= '01';
        bandeira.CodUs__c= '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;

        acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        insert acc;

        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '146';
        produto.LAT_QTLeadTime__c = 5;
        produto.LAT_Sku__c = '444';
        produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'Standard_AR');
        insert produto;

        //Recupera os IDS de tipo de registro.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        insert opp;

        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_AR_SentToApproveDiscount__c = true;
        oli.LAT_Opportunity__c = opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        oli.LAT_AR_Discount__c = 21;
        oli.LAT_AR_MaxDiscount__c = 5;
        insert oli;

        String lIdOpp = opp.Id;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.getConnectionParameter('Argentina');
        System.Test.startTest();
        Utils.setMigrationDoneTest(true);
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(lIdOpp);
        System.Test.stopTest();
      }
    }

    static testMethod void SalesOrderHandlerInterfaceTest3B(){

      Utils.setMigrationDoneTest(true);
      //Declaração de variáveis.
      Account acc = null;
      UDC__c regional, bandeira, cidade = null;
      Profile perfil = null;
      LAT_Opportunity__c opp = null;
      LAT_OpportunityLineItem__c oli = null;
      User usuario = null;
      LAT_Product__c produto = null;
      List<RecordType> listRecType = null;
      List<String> developerName = null;
      Map<String, String> mapRecType = null;
      String idAccount = null;
      String idOpportunity = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

      User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

      System.runAs(thisUser){
        //Recupera o ID do perfil desejado.
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
      }

      System.runAs(usuario){
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c= '01';
        regional.CodUs__c= '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c= '01';
        bandeira.CodUs__c= '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;

        acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        insert acc;

        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '146';
        produto.LAT_QTLeadTime__c = 5;
        produto.LAT_Sku__c = '444';
        produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'Standard_AR');
        insert produto;

        //Recupera os IDS de tipo de registro.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        insert opp;

        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_AR_SentToApproveDiscount__c = true;
        oli.LAT_Opportunity__c = opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        oli.LAT_CDAction__c = 'a';
        oli.LAT_NROrderLine__c = '1';
        oli.LAT_SkuText__c = '123';
        oli.LAT_AR_Discount__c = 21;
        oli.LAT_AR_MaxDiscount__c = 5;
        insert oli;

        String lIdOpp = opp.Id;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.getConnectionParameter('Argentina');
        System.Test.startTest();
        Utils.setMigrationDoneTest(true);
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(lIdOpp);
        System.Test.stopTest();
      }
    }

    static testMethod void SalesOrderHandlerInterfaceTest5B(){
      Utils.setMigrationDoneTest(true);
      //Declaração de variáveis.
      Account acc = null;
      UDC__c regional, bandeira, cidade = null;
      Profile perfil = null;
      LAT_Opportunity__c opp = null;
      LAT_OpportunityLineItem__c oli = null;
      User usuario = null;
      LAT_Product__c produto = null;
      List<RecordType> listRecType = null;
      List<String> developerName = null;
      Map<String, String> mapRecType = null;
      String idAccount = null;
      String idOpportunity = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

      User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

      System.runAs(thisUser){
        //Recupera o ID do perfil desejado.
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
      }

      System.runAs(usuario){
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c= '01';
        regional.CodUs__c= '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c= '01';
        bandeira.CodUs__c= '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;

        acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        insert acc;

        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '146';
        produto.LAT_QTLeadTime__c = 5;
        produto.LAT_Sku__c = '444';
        produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'Standard_AR');
        insert produto;

        System.Test.startTest();

        //Recupera os IDS de tipo de registro.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Mobile Order';
        opp.LAT_OrderOrigin__c = 'APP';
        insert opp;

        opp.LAT_StageName__c = 'Approved';
        WS03_SalesOrderHandlerInterface_AR.isProcessing = false;
        update opp;

        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_AR_SentToApproveDiscount__c = false;
        oli.LAT_Opportunity__c = opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        oli.LAT_CDAction__c = 'a';
        oli.LAT_NROrderLine__c = '1';
        oli.LAT_SkuText__c = '123';
        oli.LAT_AR_Discount__c = 21;
        oli.LAT_AR_MaxDiscount__c = 5;
        insert oli;

        String lIdOpp = opp.Id;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.getConnectionParameter('Argentina');
        Utils.setMigrationDoneTest(true);
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(lIdOpp);
        System.Test.stopTest();
      }
    }

    static testMethod void SalesOrderHandlerInterfaceTest6B(){

      Utils.setMigrationDoneTest(true);
      //Declaração de variáveis.
      Account acc = null;
      UDC__c regional, bandeira, cidade = null;
      Profile perfil = null;
      LAT_Opportunity__c opp = null;
      LAT_OpportunityLineItem__c oli = null;
      User usuario = null;
      LAT_Product__c produto = null;
      List<RecordType> listRecType = null;
      List<String> developerName = null;
      Map<String, String> mapRecType = null;
      String idAccount = null;
      String idOpportunity = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

      User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

      System.runAs(thisUser){
        //Recupera o ID do perfil desejado.
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');
      }

      System.runAs(usuario){
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c= '01';
        regional.CodUs__c= '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c= '01';
        bandeira.CodUs__c= '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;

        acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        insert acc;

        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '146';
        produto.LAT_QTLeadTime__c = 5;
        produto.LAT_Sku__c = '444';
        produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'Standard_AR');
        insert produto;

        System.Test.startTest();

        //Recupera os IDS de tipo de registro.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Mobile Order';
        opp.LAT_OrderOrigin__c = 'APP';

        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        LAT_Opportunity__c opp2 = new LAT_Opportunity__c();
        opp2.Name = 'Opp TESTE COTA';
        opp2.LAT_CloseDate__c = System.today()+1;
        opp2.RecordTypeId = RecordTypeForTest.getRecType('LAT_Opportunity__c','Nova_oportunidade');
        opp2.LAT_Account__c = acc.Id;
        opp2.LAT_StageName__c = 'Mobile Order';
        opp2.LAT_OrderOrigin__c = 'APP';

        insert new List<LAT_Opportunity__c>{opp,opp2};

        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_AR_SentToApproveDiscount__c = true;
        oli.LAT_Opportunity__c = opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        oli.LAT_CDAction__c = 'a';
        oli.LAT_NROrderLine__c = '1';
        oli.LAT_SkuText__c = '123';
        oli.LAT_AR_Discount__c = 21;
        oli.LAT_AR_MaxDiscount__c = 5;

        LAT_OpportunityLineItem__c oli2 = new LAT_OpportunityLineItem__c();
        oli2.LAT_Product__c = produto.Id;
        oli2.LAT_AR_SentToApproveDiscount__c = true;
        oli2.LAT_Opportunity__c = opp2.Id;
        oli2.LAT_UnitPrice__c = 12;
        oli2.LAT_Quantity__c = 12;
        oli2.LAT_CDAction__c = 'a';
        oli2.LAT_NROrderLine__c = '1';
        oli2.LAT_SkuText__c = '123';
        oli2.LAT_AR_Discount__c = 2;
        oli2.LAT_AR_MaxDiscount__c = 5;
      
        insert new List<LAT_OpportunityLineItem__c>{oli,oli2};
        WS03_SalesOrderHandlerInterface_AR.isProcessing = false;

        opp2.LAT_CancelOrder__c = true;
        update opp2;

        String lIdOpp = opp.Id;
        WS03_SalesOrderHandlerInterface_AR.isProcessing = null;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.isProcessing = false;
        WS03_SalesOrderHandlerInterface_AR.getConnectionParameter('Argentina');
        Utils.setMigrationDoneTest(true);
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterfaceFuture(lIdOpp);
        System.Test.stopTest();
      }
    }

    static testMethod void SalesOrderHandlerInterfaceTest11(){
      Utils.setMigrationDoneTest(true);
      //Declaração de variáveis.
      Account acc = null;
      UDC__c regional, bandeira, cidade = null;
      Profile perfil = null;
      LAT_Opportunity__c opp = null;
      LAT_OpportunityLineItem__c oli = null;
      User usuario = null;
      LAT_Product__c produto = null;
      List<RecordType> listRecType = null;
      List<String> developerName = null;
      Map<String, String> mapRecType = null;
      String idAccount = null;
      String idOpportunity = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

      //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      User thisUser = [SELECT Id FROM User WHERE isactive=true and profile.name ='LAT_SystemAdministrator' LIMIT 1];

      System.runAs(thisUser){
        //Recupera o ID do perfil desejado.
        usuario = [SELECT Id FROM User WHERE isActive=true AND Profile.Name = 'LAT_AR2_Vendedor' LIMIT 1];      
      }

      System.runAs(usuario){
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c= '01';
        regional.CodUs__c= '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c= '01';
        bandeira.CodUs__c= '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;

        acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
        
        insert acc;
      
        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '146';
        produto.LAT_QTLeadTime__c = 5;
        produto.LAT_Sku__c = '444';
        produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
        insert produto;

        //Recupera os IDS de tipo de registro.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        insert opp;
        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c = opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        oli.LAT_AR_Discount__c = 21;
        oli.LAT_AR_MaxDiscount__c = 5;
        insert oli;
        String lIdOpp = opp.Id;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        opp.LAT_Type__c = 'SJ - Sin Cargo Acción Mensual';
        opp.RecordTypeId = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_2_NewOrder_URU');
        opp.LAT_StageName__c = 'Novo pedido';
        System.Test.startTest();
        update opp;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
      
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.getConnectionParameter('Argentina');
      
        Utils.setMigrationDoneTest(true);
        WS03_SalesOrderHandlerInterface_AR.SalesOrderInterfaceFuture(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.SalesOrderInterface(lIdOpp);
        System.Test.stopTest();
      }
    }

    static testMethod void SalesOrderHandlerInterfaceTest12(){
      Utils.setMigrationDoneTest(true);
      //Declaração de variáveis.
      Account acc = null;
      UDC__c regional, bandeira, cidade = null;
      Profile perfil = null;
      LAT_Opportunity__c opp = null;
      LAT_OpportunityLineItem__c oli = null;
      User usuario = null;
      LAT_Product__c produto = null;
      List<RecordType> listRecType = null;
      List<String> developerName = null;
      Map<String, String> mapRecType = null;
      String idAccount = null;
      String idOpportunity = null;
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c'+'Standard_AR');

      //Recupera os IDS de tipo de registro.
      idAccount = RecordTypeForTest.getRecType('Account','Off_Trade');

      //User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      User thisUser = [SELECT Id FROM User WHERE isactive=true and profile.name ='LAT_SystemAdministrator' LIMIT 1];

      System.runAs(thisUser){
        //Recupera o ID do perfil desejado.
        usuario = [SELECT Id FROM User WHERE isActive=true AND Profile.Name = 'LAT_AR2_Vendedor' LIMIT 1];      
      }

      System.runAs(usuario){
        //Cria nova UDC.
        regional = new UDC__c();
        regional.CodDefUsuario__c = '4546';
        regional.CodProd__c= '01';
        regional.CodUs__c= '01';
        regional.Internal_Id__c   = '1234';
        regional.RecordTypeId = idRecTypeUDC;
        insert regional;

        //Cria nova UDC.
        bandeira = new UDC__c();
        bandeira.CodDefUsuario__c = '179';
        bandeira.CodProd__c= '01';
        bandeira.CodUs__c= '06';
        bandeira.Internal_Id__c   = '1236';
        bandeira.RecordTypeId = idRecTypeUDC;
        insert bandeira;

        acc = LAT_Account_TestFactory.getAccountOffTradeArgComplete();
        acc.Name = 'ProdutosOppVerificaCotaExistenteTeste';
        acc.Status__c = 'Cliente cadastrado no JDE';
        acc.Frequency_of_Visits__c = 'Semanal';
        acc.Client_code_AN8__c = '557799';
        acc.Client_country_an8__c = '6-557799';
        acc.Corporate_Name__c = 'Teste';
        acc.Checking_account__c = '000';
        acc.Carriers_Numbers__c = '123';
          
        insert acc;
      
        produto = new LAT_Product__c();
        produto.Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade';
        produto.LAT_IsActive__c = true;
        produto.LAT_CDUnit__c = 'UN';
        produto.LAT_ExternalId__c = '146';
        produto.LAT_QTLeadTime__c = 5;
        produto.LAT_Sku__c = '444';
        produto.RecordTypeId = RecordTypeForTest.getRecType('LAT_Product__c', 'BRA_Standard');
        insert produto;

        //Recupera os IDS de tipo de registro.
        idOpportunity = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_1_NewOrder_ARG');

        //Cria nova oportunidade.
        opp = new LAT_Opportunity__c();
        opp.Name = 'Opp TESTE COTA';
        opp.LAT_CloseDate__c = System.today()+1;
        opp.RecordTypeId = idOpportunity;
        opp.LAT_Account__c = acc.Id;
        opp.LAT_StageName__c = 'Novo Pedido';
        insert opp;
        //Cria um novo produto da oportunidade.
        oli = new LAT_OpportunityLineItem__c();
        oli.LAT_Product__c = produto.Id;
        oli.LAT_Opportunity__c = opp.Id;
        oli.LAT_UnitPrice__c = 12;
        oli.LAT_Quantity__c = 12;
        oli.LAT_AR_Discount__c = 21;
        oli.LAT_AR_MaxDiscount__c = 5;
        insert oli;
        String lIdOpp = opp.Id;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        opp.LAT_Type__c = 'SH - Ofrecidos de Ventas por Acuerdos Comerciales';
        opp.RecordTypeId = RecordTypeForTest.getRecType('LAT_Opportunity__c','OPP_2_NewOrder_URU');
        opp.LAT_StageName__c = 'Novo pedido';
        System.Test.startTest();
        update opp;
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
      
        WS03_SalesOrderHandlerInterface_AR.LAT_SalesOrderInterface(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.getConnectionParameter('Argentina');
      
        Utils.setMigrationDoneTest(true);
        WS03_SalesOrderHandlerInterface_AR.SalesOrderInterfaceFuture(lIdOpp);
        WS03_SalesOrderHandlerInterface_AR.SalesOrderInterface(lIdOpp);
        System.Test.stopTest();
      }
    }
}