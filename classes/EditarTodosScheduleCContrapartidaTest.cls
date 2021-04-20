@isTest
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do código:  EditarTodosScheduleCContrapartida
* NAME: EditarTodosScheduleCContrapartidaTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                         DATE: 14/01/2013 
********************************************************************************/
private class EditarTodosScheduleCContrapartidaTest {

    static testMethod void EditarTodosScheduleCContrapartidaTest() 
    {
      //Declaração de variáveis.
      Account acc                           = null;
      UDC__c regional, bandeira             = null;
      Profile perfil                        = null;
      User usuario                          = null;
      String idAccount                      = null;
      Planejamento__c plan                  = null;
      Visitas__c visita                     = null;
      Checklist_de_visita__c checklistV     = null;
      Checklist__c check                    = null;
      
      Id idRecTypeUDC = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard');
      Id idRecTypePlan = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard');
      Id idRecTypePC = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard');
      Id idRecTypeCheck = Global_RecordTypeCache.getRtId('Checklist__c' + 'BRA_Standard');
      
      //Recupera os IDS de tipo de registro.
      idAccount = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');      
      
      //Recupera o ID do perfil desejado.
      usuario = new User();
      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
      insert usuario;  
    
      //Cria nova UDC.
      regional = new UDC__c();
      regional.CodDefUsuario__c = '4546';
      regional.CodProd__c     = '01';
      regional.CodUs__c     = '01';
      regional.Internal_Id__c   = '01-01';
      regional.RecordTypeId = idRecTypeUDC;
      insert regional;
      
      //delete [SELECT id FROM UDC__c WHERE Internal_Id__c = '01-06' AND RecordTypeId =: idRecTypeUDC];
      
      //Cria nova UDC.
      bandeira = new UDC__c();
      bandeira.CodDefUsuario__c = '179';
      bandeira.CodProd__c     = '01';
      bandeira.CodUs__c     = '06';
      bandeira.Internal_Id__c   = '01-06';
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

      //Cria novo planejamento.
      plan = new Planejamento__c();
      plan.Ano_de_Referencia__c = '2012';
      plan.M_s_de_Ref_rencia__c = 'Fevereiro';
      plan.Name = 'Teste';
      plan.OwnerId = usuario.Id;
      plan.RecordTypeId = idRecTypePlan;
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
      visita.RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard');
      visita.Resumo_da_Visita__c = 'teste';
      test.startTest();
      insert visita;
      
      
      
      Id idRecTypeCheckV = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade');
      
      //Cria novo checklist de viaita
      checklistV = new Checklist_de_visita__c();
      checklistV.Visita__c = visita.Id;
      checklistV.RecordTypeId = idRecTypeCheckV;
      
      insert checklistV;
      
      //Cria novo checklist de contrapartida
      check = new Checklist__c();
      check.Checklist_de_visita__c = checklistV.Id;
      check.Schedule_C__c = 'Produto de Quantidade';
      check.Secao_Contrapartidas__c = ChecklistVisitaCria.secao_contrapartida[ 5 ];
      insert check;
      
      List<Checklist_de_visita__c> listCheckListVisita = new List< Checklist_de_visita__c >();
      listCheckListVisita.add( checklistV );
      
      List<Checklist__c> listChecklist = new List< Checklist__c >();
      listChecklist.add( check );
      
      //Executa a pagina visual force
      PageReference pageRef = Page.Editar_todos_schedule_c_contrapartida;
      Test.setCurrentPageReference(pageRef);
      
      //Excuta o standard controller
      ApexPages.StandardSetController sc = new ApexPages.StandardSetController(listChecklist);
      
      //Seleciona os itens (Serve para as caixas de seleção de visita)
      sc.setSelected(listChecklist);
      
      //Executa o controller customizado e seus métodos
      EditarTodosScheduleCContrapartida edit = new EditarTodosScheduleCContrapartida(sc);
      edit.getAcordo();
      edit.getContrapartida();
      edit.getDetalhamento();
      edit.getPotifolio();
      edit.getVisibilidade();
      edit.save();
      
      test.stopTest();
    }
}