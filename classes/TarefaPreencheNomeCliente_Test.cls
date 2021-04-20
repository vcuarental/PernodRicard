@istest
public with sharing class TarefaPreencheNomeCliente_Test {

  static testMethod void unitTest() {
    User us = new User();
    us.FirstName = 'nome';
    us.LastName = 'Sobrenome';
    us.Alias = 'NSobreU';
    us.Email = 'usuarioC@sobrenome.com';
    us.Username = 'devtestusercloud2b2@cloud2b.com.br';
    us.CommunityNickname = '1234jjuuu';
    us.EmailEncodingKey = 'ISO-8859-1';
    us.TimeZoneSidKey = 'GMT';
    us.LocaleSidKey = 'en_Us';
    us.LanguageLocaleKey = 'en_Us';
    us.C_digo_JDE__c = '235';
    us.ProfileId = LAT_GlobalProfileCache.getProfileIdByName('LAT_BR2_Vendas');
    us.Country = 'BR';
    insert us; 
    
    Account acc = new Account();      
    acc.Name = 'Teste';
    acc.Rating = 'Cliente';
    acc.Status__c = 'Cliente cadastrado no JDE';
    acc.CNPJ__c = '48843971000120';      
    acc.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'Eventos');
    insert acc;

    acc.OwnerId = us.id;
    update acc;

    Task tsk = new Task(
      RecordTypeId = RecordTypeForTest.getRecType('Task', 'Revis_o_de_Planejamento_de_Visita_Semanal')
    );
    insert tsk;

    tsk.WhatId = acc.Id;
    update tsk;
  }
  
}