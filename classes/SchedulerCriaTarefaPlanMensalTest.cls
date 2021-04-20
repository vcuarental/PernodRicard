@isTest(seeAllData=true)
/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Realiza teste de cobertura do scheduler SchedulerCriaTarefaPlanejamentoMensal.cls
* NAME: SchedulerCriaTarefaPlanMensalTest.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 05/06/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
private class SchedulerCriaTarefaPlanMensalTest 
{

    static testMethod void SchedulerCriaTarefaPlanMensalTest() 
    {
    
        Test.startTest(); 
      //Declaração de variáveis.
      Profile perfil                        = null;
      User usuario                          = null;

      usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR');                                                       
      insert usuario;
      
      String CRON_EXP = '0 1 0 27 * ?';
      /*Agenda o SCHEDULER de teste.*/
      //String jobId = 
      SchedulerCriaTarefaPlanejamentoMensal sch = new SchedulerCriaTarefaPlanejamentoMensal();
      System.schedule('SchedulerCriaTarefaPlanejamentoMensalTest', CRON_EXP, sch);
    
      Test.stopTest();
    }

}