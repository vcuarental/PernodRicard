/*******************************************************************************
*                     Copyright (C) 2012 - Cloud2b
*-------------------------------------------------------------------------------
*
* Scheduler que recupera as informações do cliente
* NAME: SchedulerCustomerVerifyTest.cls
* AUTHOR: ROGERIO ALVARENGA                         DATE: 26/06/2012
*
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 11/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
@isTest
private class SchedulerCustomerVerifyTest {

    static testMethod void myUnitTest() {
      
      Id idRecTypeUDC = RecordTypeForTest.getRecType( 'UDC__c' , 'BRA_Standard' ); 
      
      Test.startTest();
      
      UDC__c lUdc1 = new UDC__c();
      lUdc1.Name ='REG SP';
      lUdc1.Internal_Id__c = '01-01';
      lUdc1.CodProd__c = '01';
      lUdc1.CodUs__c = '01';
      lUdc1.RecordTypeId = idRecTypeUDC;
      insert lUdc1;
      
      UDC__c lUdc2 = new UDC__c();
      lUdc2.Name ='SAO PAULO';
      lUdc2.Internal_Id__c = '00-CT';
      lUdc2.CodProd__c = '00';
      lUdc2.CodUs__c = 'CT';
      lUdc2.RecordTypeId = idRecTypeUDC;
      insert lUdc2;
      
      Account lAcc = new Account();
      lAcc.RecordTypeId = RecordTypeForTest.getRecType( 'Account', 'On_Trade' );
      lAcc.Name = 'Teste';
      lAcc.CNPJ__c = '65922018000196';
      lAcc.Corporate_Name__c = 'Teste';
      lAcc.Type = 'Venda';
      lAcc.Channel_Type__c = 'Direto';
      lAcc.Sub_Channel__c = 'Atacadista';
      lAcc.Regional__c = lUdc1.id;
      lAcc.Revenue_Address__c = 'Endereço';
      lAcc.Revenue_Number__c = '123';
      lAcc.Revenue_Neighbourhood__c = 'Alto';
      lAcc.Revenue_City__c = lUdc2.id;
      lAcc.Revenue_UF__c = '';
      lAcc.Revenue_Country__c = '';
      lAcc.Revenue_Postal_Code__c = '05463010';
      lAcc.Status__c = 'Aprovado - Aguardando retorno do JDE';
      insert lAcc;
      
      //Agenda o SCHEDULER de teste.
      String jobId = System.schedule('SchedulerCustomerVerifyTest', SchedulerCustomerVerify.CRON_EXP, new SchedulerCustomerVerify());
      
      Test.stopTest();
     
    }
}