/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

@istest
public with sharing class LAT_BR_UpdatesKeyOfPPC_TEST {

   static testMethod void unitTest() {
               
        Utils.setMigrationDoneTest(false); 
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario; 
    
      UDC__c regional = new UDC__c(
          CodDefUsuario__c = '4546',
          CodProd__c     = '01',
          CodUs__c     = '01',
          Internal_Id__c   = '1234',
          RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
      );
      insert regional;
      
      UDC__c bandeira = new UDC__c(
          CodDefUsuario__c = '179',
          CodProd__c     = '01',
          CodUs__c     = '06',
          Internal_Id__c   = '1236',
          RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
      );
      insert bandeira;

      Account acc = new Account(
          OwnerId = usuario.Id,
          Name = 'ProdutosOppVerificaCotaExistenteTeste',
          CNPJ__c = '48843971000120',
          Type = 'Outros',
          RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
          Status__c = 'Cliente cadastrado no JDE',
          Agency__c = '000',
          Checking_account__c = '000',
          Current_account__c = '0',
          Corporate_Name__c = 'Teste',
          Channel__c = 'Off Trade',
          //Regional__c = regional.Id,
          Frequency_of_Visits__c = 'Semanal',
          Channel_Type__c = 'Direto',
          Client_code_AN8__c = '557799',
          Price_Group__c = '1'
          //Customer_Flag__c = bandeira.Id
      );
      insert acc;
      
      test.startTest();
      Utils.setMigrationDoneTest(false); 
      Planejamento__c plan = new Planejamento__c(
          Ano_de_Referencia__c = '2012',
          M_s_de_Ref_rencia__c = 'Fevereiro',
          Name = 'Teste',
          OwnerId = usuario.Id,
          RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard')
      );
      
      insert plan;

      Visitas__c visita = new Visitas__c(
          Name = 'Teste',
          Data_da_Visita__c = System.today(),
          Hora_da_Visita__c = '08:00',
          Planejamento__c = plan.Id,
          Tipo_de_Visita__c = 'Execução',
          Conta__c = acc.Id,
          Status__c = 'Planejada',
          RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'),
          Resumo_da_Visita__c = 'teste'
      );
      insert visita;

      Checklist_de_visita__c check = new Checklist_de_visita__c(
          Visita__c = visita.Id,
          RecordTypeId = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade'),
          LAT_BR_ValidOnTradeChecklist__c = true
      );
      insert check;

      Product2 prod = new Product2(
          Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade',
          IsActive = true,
          CD_Unit__c = 'UN',
          Internal_id__c = '123',
          LAT_BR_BrandGrouping__c = 'ABSOLUT',
          //QT_lead_time__c = 5,
          RecordTypeId = Global_RecordTypeCache.getRtId('Product2' + 'BRA_Standard')
      );
      insert prod;
                  
      Produto_Concorr_ncia__c prodC = new Produto_Concorr_ncia__c(
          Checklist_de_visita__c = check.Id,
          RecordTypeId = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard'),
          Qtde_de_Caixas_Estoque__c = 10,
          Produto_PERNOD__c = prod.id
      );
      
      try{insert prodC;} catch(exception e){}
      
      LAT_BR_UpdatesKeyOfPPC.updatesKeyOfPPC(new set<Id>{prodC.Id});
      
      test.stopTest();
   
   }  

   //MIGRATED 21/11/2016 
   static testMethod void unitTestB() {
               
        Utils.setMigrationDoneTest(true); 
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario; 
    
      UDC__c regional = new UDC__c(
          CodDefUsuario__c = '4546',
          CodProd__c     = '01',
          CodUs__c     = '01',
          Internal_Id__c   = '1234',
          RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
      );
      insert regional;
      
      UDC__c bandeira = new UDC__c(
          CodDefUsuario__c = '179',
          CodProd__c     = '01',
          CodUs__c     = '06',
          Internal_Id__c   = '1236',
          RecordTypeId = Global_RecordTypeCache.getRtId('UDC__c' + 'BRA_Standard')
      );
      insert bandeira;

      Account acc = new Account(
          OwnerId = usuario.Id,
          Name = 'ProdutosOppVerificaCotaExistenteTeste',
          CNPJ__c = '48843971000120',
          Type = 'Outros',
          RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'On_Trade'),
          Status__c = 'Cliente cadastrado no JDE',
          Agency__c = '000',
          Checking_account__c = '000',
          Current_account__c = '0',
          Corporate_Name__c = 'Teste',
          Channel__c = 'Off Trade',
          //Regional__c = regional.Id,
          Frequency_of_Visits__c = 'Semanal',
          Channel_Type__c = 'Direto',
          Client_code_AN8__c = '557799',
          Price_Group__c = '1'
          //Customer_Flag__c = bandeira.Id
      );
      insert acc;
      
      test.startTest();
      Utils.setMigrationDoneTest(true); 
      Planejamento__c plan = new Planejamento__c(
          Ano_de_Referencia__c = '2012',
          M_s_de_Ref_rencia__c = 'Fevereiro',
          Name = 'Teste',
          OwnerId = usuario.Id,
          RecordTypeId = Global_RecordTypeCache.getRtId('Planejamento__c' + 'BRA_Standard')
      );
      
      insert plan;

      Visitas__c visita = new Visitas__c(
          Name = 'Teste',
          Data_da_Visita__c = System.today(),
          Hora_da_Visita__c = '08:00',
          Planejamento__c = plan.Id,
          Tipo_de_Visita__c = 'Execução',
          Conta__c = acc.Id,
          Status__c = 'Planejada',
          RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'BRA_Standard'),
          Resumo_da_Visita__c = 'teste'
      );
      insert visita;

      Checklist_de_visita__c check = new Checklist_de_visita__c(
          Visita__c = visita.Id,
          RecordTypeId = Global_RecordTypeCache.getRtId('Checklist_de_visita__c' + 'On_Trade'),
          LAT_BR_ValidOnTradeChecklist__c = true
      );
      insert check;

      LAT_Product__c prod = new LAT_Product__c(
          Name = 'Cloud2b - Produto - AtualizarEventoProdutosOportunidade',
          LAT_IsActive__c = true,
          LAT_CDUnit__c = 'UN',
          LAT_ExternalID__c = '123',
          LAT_BR_BrandGrouping__c = 'ABSOLUT',
          //QT_lead_time__c = 5,
          RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard')
      );
      insert prod;
                  
      Produto_Concorr_ncia__c prodC = new Produto_Concorr_ncia__c(
          Checklist_de_visita__c = check.Id,
          RecordTypeId = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard'),
          Qtde_de_Caixas_Estoque__c = 10,
          LAT_Product__c = prod.id
      );
      
      try{insert prodC;} catch(exception e){}
      
      LAT_BR_UpdatesKeyOfPPC.updatesKeyOfPPC(new set<Id>{prodC.Id});
      
      test.stopTest();
   
   } 


}