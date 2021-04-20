/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Faz o teste de cobertura da classe ContratoMarcaPrimeiroPagamento
* NAME: ContratoMarcaPrimeiroPagamentoTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 13/09/2012
*
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 14/01/2013 
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/
@isTest
private class ContratoMarcaPrimeiroPagamentoTest {
    //MIGRATED 21/11/2016
    static testMethod void myUnitTest() {
      //Recupera os IDS de tipo de registro.
      Utils.setMigrationDoneTest(false); 
      Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
      Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

      Profile perfil =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];     
     

      User gerente = new User();
      gerente.FirstName           = 'Nome';
      gerente.LastName            = 'SobrenomeC';
      gerente.Alias               = 'NSobreC';
      gerente.Email               = 'gerenteC@sobrenome.com';
      gerente.Username            = 'devtestusercloud2b@cloud2b.com.br';
      gerente.CommunityNickname   = '123jjjuuu';
      gerente.EmailEncodingKey    = 'ISO-8859-1';
      gerente.TimeZoneSidKey      = 'GMT';
      gerente.LocaleSidKey        = 'en_Us';
      gerente.LanguageLocaleKey   = 'en_Us';
      gerente.C_digo_JDE__c       = '234';
      gerente.ProfileId           = perfil.Id;
      gerente.Country = 'BR';
        
      insert gerente;
      User usuario = new User();
      usuario.FirstName = 'nome';
      usuario.LastName = 'Sobrenome';
      usuario.Alias = 'NSobreU';
      usuario.Email = 'usuarioC@sobrenome.com';
      usuario.Username = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname = '1234jjuuu';
      usuario.EmailEncodingKey = 'ISO-8859-1';
      usuario.TimeZoneSidKey = 'GMT';
      usuario.LocaleSidKey = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c = '235';
      usuario.ProfileId = perfil.Id;
      usuario.Country = 'BR';
      usuario.Gerente_de_area__c  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;

    
      insert usuario;

      Account acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'Conta teste Trigger';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.Status__c = 'Cliente cadastrado no CRM';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      acc.Segmentation_Type_on_trade__c  = 'Bar';
      acc.Area_Manager__c = gerente.Id;
      acc.Regional_Manager__c = gerente.Id;   
      
      insert acc;       

      System.runAs(usuario){     
         Utils.setMigrationDoneTest(false); 
         LAT_Contract__c lContract = new LAT_Contract__c();
         lContract.OwnerId = usuario.Id;
         lContract.Account__c = acc.Id;
         lContract.Status__c = 'Em elaboração';
         lContract.StartDate__c = System.today();
         lContract.ContractTerm__c = 12;
         lContract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade');
         lContract.Motivo_de_cancelamento_do_contrato__c = 'Fechamento da casa';
         lContract.Status_do_processo__c = 'Solicitação de cancelamento de contrato';
         insert lContract;

        
        Product2 lProd = new Product2();
        lProd.Description = 'Cachaca';
        lProd.Name = 'Cachaca';
        lProd.Internal_id__c = 'asdad';
        lProd.RecordTypeId = RecordTypeForTest.getRecType( 'Product2', 'BRA_Standard');
        insert lProd;

        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.LAT_Contract__c = lContract.id;
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
        ibp.Valor_R__c = 100;
        ibp.Perc_de_Rateio__c = 30;
        ibp.Valor_Percebido__c = 120.32;
        ibp.Custo_Bonificado__c = 89;
        ibp.Produto_Bonificado__c = lProd.id;
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.CasoEspecial__c = true;
      
        insert ibp;
               
        lContract.Status__c = 'Em aprovação';
    
        Test.startTest();
        Utils.setMigrationDoneTest(false); 
        lContract.Status__c = 'Ativo';
        update lContract;
        Test.stopTest();
      }    
    }
    //MIGRATED 21/11/2016
    static testMethod void myUnitTestB() {
      //Recupera os IDS de tipo de registro.
      Utils.setMigrationDoneTest(true); 
      Id idRecTypeAcc = RecordTypeForTest.getRecType('Account','On_Trade');
      Id idrecTypeLatCon = RecordTypeForTest.getRecType( 'LAT_Contract__c' , 'Assinatura_de_contrato' );

      Profile perfil =  [SELECT Id, Name, Description FROM Profile WHERE UserType = 'Standard' AND PermissionsAuthorApex = true AND name != 'System Administrator SESAME'  LIMIT 1];     
     

      User gerente = new User();
      gerente.FirstName           = 'Nome';
      gerente.LastName            = 'SobrenomeC';
      gerente.Alias               = 'NSobreC';
      gerente.Email               = 'gerenteC@sobrenome.com';
      gerente.Username            = 'devtestusercloud2b@cloud2b.com.br';
      gerente.CommunityNickname   = '123jjjuuu';
      gerente.EmailEncodingKey    = 'ISO-8859-1';
      gerente.TimeZoneSidKey      = 'GMT';
      gerente.LocaleSidKey        = 'en_Us';
      gerente.LanguageLocaleKey   = 'en_Us';
      gerente.C_digo_JDE__c       = '234';
      gerente.ProfileId           = perfil.Id;
      gerente.Country = 'BR';
        
      insert gerente;
      User usuario = new User();
      usuario.FirstName = 'nome';
      usuario.LastName = 'Sobrenome';
      usuario.Alias = 'NSobreU';
      usuario.Email = 'usuarioC@sobrenome.com';
      usuario.Username = 'devtestusercloud2b2@cloud2b.com.br';
      usuario.CommunityNickname = '1234jjuuu';
      usuario.EmailEncodingKey = 'ISO-8859-1';
      usuario.TimeZoneSidKey = 'GMT';
      usuario.LocaleSidKey = 'en_Us';
      usuario.LanguageLocaleKey = 'en_Us';
      usuario.C_digo_JDE__c = '235';
      usuario.ProfileId = perfil.Id;
      usuario.Country = 'BR';
      usuario.Gerente_de_area__c  = gerente.Id;
      usuario.Gerente_regional__c = gerente.Id;

    
      insert usuario;

      Account acc = new Account();
      acc.OwnerId = usuario.Id;
      acc.Name = 'Conta teste Trigger';
      acc.CNPJ__c = '48843971000120';
      acc.Type = 'Outros';
      acc.Status__c = 'Cliente cadastrado no CRM';
      acc.Agency__c = '000';
      acc.Checking_account__c = '000';
      acc.Current_account__c = '0';
      acc.Corporate_Name__c = 'Teste';
      acc.RecordTypeId = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      acc.Segmentation_Type_on_trade__c  = 'Bar';
      acc.Area_Manager__c = gerente.Id;
      acc.Regional_Manager__c = gerente.Id;   
      
      insert acc;       

      System.runAs(usuario){     

         LAT_Contract__c lContract = new LAT_Contract__c();
         lContract.OwnerId = usuario.Id;
         lContract.Account__c = acc.Id;
         lContract.Status__c = 'Em elaboração';
         lContract.StartDate__c = System.today();
         lContract.ContractTerm__c = 12;
         lContract.RecordTypeId = RecordTypeForTest.getRecType('LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade');
         lContract.Motivo_de_cancelamento_do_contrato__c = 'Fechamento da casa';
         lContract.Status_do_processo__c = 'Solicitação de cancelamento de contrato';
         insert lContract;

        
        LAT_Product__c lProd = new LAT_Product__c();
        lProd.LAT_Description__c = 'Cachaca';
        lProd.Name = 'Cachaca';
        lProd.LAT_ExternalID__c = 'asdad';
        lProd.RecordTypeId = RecordTypeForTest.getRecType( 'LAT_Product__c', 'BRA_Standard');
        insert lProd;


        Investimento_Bonificacao_e_Pagamento__c ibp = new Investimento_Bonificacao_e_Pagamento__c();
        ibp.LAT_Contract__c = lContract.id;
        ibp.RecordTypeId = RecordTypeForTest.getRecType( 'Investimento_Bonificacao_e_Pagamento__c', 'Bonificacao_Produtos' );
        ibp.Valor_R__c = 100;
        ibp.Perc_de_Rateio__c = 30;
        ibp.Valor_Percebido__c = 120.32;
        ibp.Custo_Bonificado__c = 89;
        ibp.LAT_Product__c = lProd.id;
        ibp.Data_de_Previsao_do_Pagamento__c = system.today() + 10;
        ibp.CasoEspecial__c = true;
      
        insert ibp;
               
        lContract.Status__c = 'Em aprovação';
    
        Test.startTest();
        Utils.setMigrationDoneTest(true); 
        lContract.Status__c = 'Ativo';
        update lContract;
        Test.stopTest();
      }    
    }     

}