/*******************************************************************************
*                     Copyright (C) 2013 - Cloud2b
*-------------------------------------------------------------------------------
*
* Excuta teste do controlador EditarTodasAsVisitas.
* NAME: EditarTodasAsVisitasTest.cls
* AUTHOR: CARLOS CARVALHO                            DATE: 28/05/2012
*
*******************************************************************************/

@isTest
private class EditarTodasAsVisitasTest {
    
    static testMethod void EditarTodasAsVisitasTest() {
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade     = null;
      Profile perfil                        = null;
      User usuario                          = null;
      String idAccount                      = null;
      Planejamento__c plan                  = null;
      Visitas__c visita                     = null;
      String idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
      Id idRecTypeVis = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
      
      //Recupera os IDS de tipo de registro.
      idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
      
      //Recupera o ID do perfil desejado.
      
      
      //Cria novo usuario.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUdc;
      insert regional;
      
      //Cria nova UDC.
      Delete [SELECT id FROM UDC__c WHERE Internal_Id__c   = '01-06'];
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '01-06';
      bandeira.RecordTypeId = idRecTypeUdc;
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
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      acc.Customer_Flag__c = bandeira.Id;
      insert acc;
      
      test.startTest();

      //Cria novo planejamento.
      plan = new Planejamento__c();
      plan.Ano_de_Referencia__c = '2012';
      plan.M_s_de_Ref_rencia__c = 'Fevereiro';
      plan.Name = 'Teste';
      plan.OwnerId = usuario.Id;
      plan.RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
      insert plan;
      
      //Cria nova visita
      visita = new Visitas__c();
      visita.Name = 'Teste';
      visita.Data_da_Visita__c = System.today();
      visita.Hora_da_Visita__c = '08:00';
      visita.Planejamento__c = plan.Id;
      visita.Tipo_de_Visita__c = 'Execução';
      visita.Conta__c = acc.Id;
      visita.Status__c = 'Planejada';
      visita.RecordTypeId = idRecTypeVis;
      visita.Resumo_da_Visita__c = 'TEste';
      insert visita;
      
      List<Visitas__c> listVisitas = new List<Visitas__c>();
      listVisitas.add(visita); 
      
      //Executa a pagina visual force
      PageReference pageRef = Page.Editar_todas_as_visitas;
      Test.setCurrentPageReference(pageRef);
      
      //Excuta o standard controller
      ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listVisitas);
      
      //Seleciona os itens (Serve para as caixas de seleção de visita)
      sc.setSelected(listVisitas);
      
      //Executa o controller customizado e seus métodos
      EditarTodasAsVisitas con = new EditarTodasAsVisitas(sc);
      con.getVisitas();
      con.save();
      
      test.stopTest();
    }
    static testMethod void EditarTodasAsVisitasTest2() {
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira, cidade     = null;
      Profile perfil                        = null;
      User usuario                          = null;
      String idAccount                      = null;
      Planejamento__c plan                  = null;
      Visitas__c visita                     = null;
      String idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
      Id idRecTypeVis = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
      
      //Recupera os IDS de tipo de registro.
      idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
      
      //Recupera o ID do perfil desejado.
      
      
      //Cria novo usuario.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUdc;
      insert regional;
      
      //Cria nova UDC.
      Delete [SELECT id FROM UDC__c WHERE Internal_Id__c   = '01-06'];
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '01-06';
      bandeira.RecordTypeId = idRecTypeUdc;
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
      acc.Client_code_AN8__c = '557798';
      acc.Price_Group__c = '1';
      acc.Customer_Flag__c = bandeira.Id;
      insert acc;
      
      test.startTest();

      //Cria novo planejamento.
      plan = new Planejamento__c();
      plan.Ano_de_Referencia__c = '2012';
      plan.M_s_de_Ref_rencia__c = 'Fevereiro';
      plan.Name = 'Teste';
      plan.OwnerId = usuario.Id;
      plan.RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
      insert plan;
      
      //Cria nova visita
      visita = new Visitas__c();
      visita.Name = 'Teste';
      visita.Data_da_Visita__c = System.today();
      visita.Hora_da_Visita__c = '08:00';
      visita.Planejamento__c = plan.Id;
      visita.Tipo_de_Visita__c = 'Execução';
      visita.Conta__c = acc.Id;
      visita.Status__c = 'Planejada';
      visita.RecordTypeId = idRecTypeVis;
      visita.Resumo_da_Visita__c = 'TEste';
      insert visita;
      
      List<Visitas__c> listVisitas = new List<Visitas__c>();
      
      
      //Executa a pagina visual force
      PageReference pageRef = Page.Editar_todas_as_visitas;
      Test.setCurrentPageReference(pageRef);
      
      //Excuta o standard controller
      ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listVisitas);
      
      //Seleciona os itens (Serve para as caixas de seleção de visita)
      sc.setSelected(listVisitas);
      
      //Executa o controller customizado e seus métodos
      EditarTodasAsVisitas con = new EditarTodasAsVisitas(sc);
      con.getVisitas();
      con.save();
      
      test.stopTest();
    }
}