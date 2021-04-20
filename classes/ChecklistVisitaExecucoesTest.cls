@isTest(seeAllData=true)
/******************************************************************************************
*                         Copyright 2012 - Cloud2b
*******************************************************************************************
* Responsável pelo teste de cobertura do seguinte código: ChecklistVisitaExecucoes.trigger
*
* NAME: ContractReservaIBP.trigger
* AUTHOR: CARLOS CARVALHO                           DATE: 22/10/2012
*
* MAINTENANCE 
* AUTHOR: CARLOS CARVALHO                           DATE: 09/01/2013 
* DESC: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
*
* AUTHOR: CARLOS CARVALHO                           DATE: 22/01/2013 
* DESC: INSERIDOS NOVOS CAMPOS PARA COBERTURA DAS REGRAS DE VALIDAÇÃO DE VISITA.
******************************************************************************************/
private class ChecklistVisitaExecucoesTest {

    static testMethod void myUnitTest() {
      Id idRecTypeAcc = RecordTypeForTest.getRecType('Account', 'Off_Trade');
      Id idRecTypePla = RecordTypeForTest.getRecType('Planejamento__c', 'BRA_Standard');
      Id idRecTypeVis = RecordTypeForTest.getRecType('Visitas__c', 'BRA_Standard');
      Id idRecTypeCh = RecordTypeForTest.getRecType('Checklist_de_visita__c', 'Off_Trade');

      Account lAcc = new Account();
      lAcc.Name = 'Teste';
      lAcc.Corporate_Name__c = 'Teste';
      lAcc.RecordTypeId = idRecTypeAcc;
      /*
      lAcc.Thursday_1st_period_begin_Time__c = '08:00';
      lAcc.Thursday_1st_period_End_Time__c = '12:00';
      lAcc.Thursday__c = true;
      */
      //insert lAcc;
      try{insert lAcc;}catch(Exception e){}
      
      Planejamento__c lPlan = new Planejamento__c();
      lPlan.Ano_de_Referencia__c = '2012';
      lPlan.M_s_de_Ref_rencia__c = 'Dezembro';
      lPlan.Name = 'Teste';
      lPlan.RecordTypeId = idRecTypePla;
      //insert lPlan;
      try{insert lPlan;}catch(Exception e){}
      
      Visitas__c lVisita = new Visitas__c();
      lVisita.Conta__c = lAcc.Id;
      lVisita.Name = 'Planejamento de visitas - ' + lAcc.Name; 
      lVisita.Planejamento__c = lPlan.id;
      lVisita.RecordTypeId = idRecTypeVis;
      lVisita.Trigger_on__c = true;
      lVisita.Data_da_Visita__c = Date.newInstance(2013, 01, 22);
      lVisita.Hora_da_Visita__c = '10:00';
      lVisita.Resumo_da_Visita__c = 'teste';
      //insert lVisita;
      try{insert lVisita;}catch(Exception e){}
      
      Checklist_de_visita__c lCheck = new Checklist_de_visita__c();
      lCheck.Visita__c = lVisita.id;
      lCheck.recordTypeId = idRecTypeCh;
      //Database.Saveresult[] resultsCheck = Database.insert( new Checklist_de_visita__c[]{lCheck}, false);
      Database.Saveresult[] resultsCheck;
      try{resultsCheck = Database.insert( new Checklist_de_visita__c[]{lCheck}, false);}catch(Exception e){}
    }
}