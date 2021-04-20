@isTest(seeAllData=true)
/*******************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* REALIZA TESTE DE COBERTURA DO CÓDIGO: PlanejamentoFechaTarefaRelacionada.cls
*
* NAME: PlanejamentoFechaTarefaRelacionadaTeste.cls
* AUTHOR: CARLOS CARVALHO                          DATE: 
*
*
* AUTHOR: CARLOS CARVALHO                          DATE: 16/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*******************************************************************************/
private class PlanejamentoFechaTarefaRelacionadaTeste 
{

    static testMethod void PlanejamentoFechaTarefaRelacionadaTeste() 
    {
        //Declração de variaveis.
        Task taskMensal = null;
        Task taskRevisao = null;
        Planejamento__c plan = null;
        String idRecTypeTask = null;
        Profile perfil = null;
          
        //Recupera o ID do perfil desejado.//
        // perfil = [Select Id From Profile Where Name=:'Usuário padrão PERNOD'];
        User usuario = new User();
        usuario = LAT_TestUserAdmin.userWithAdminPorf ('Nome2','Sobrenome2','NSobre2','nome2@sobrenome.com','PriceCalculationInterface@mail.com','123jjjuuu2','ISO-8859-1','GMT','en_Us','en_Us','234','BR'); 
        insert usuario;  
        
        
        //Recupera os tipos de registros desejados.
        idRecTypeTask = RecordTypeForTest.getRecType('Task','Planejamento_de_Visitas_Mensal');
          
        //Cria nova tarefa.
        taskMensal = new Task();
        taskMensal.RecordTypeId = idRecTypeTask;
        taskMensal.Subject = 'Tarefa Mensal';
        taskMensal.ActivityDate = System.today();
        taskMensal.OwnerId = usuario.Id;
        
        insert taskMensal;
        
        //ID rectype revisão
        idRecTypeTask = RecordTypeForTest.getRecType('Task','Revis_o_de_Planejamento_de_Visita_Semanal');
          
        //Cria nova tarefa.
        taskRevisao = new Task();
        taskRevisao.RecordTypeId = idRecTypeTask;
        taskRevisao.Subject = 'Tarefa Revisão';
        taskRevisao.ActivityDate = System.today();
        taskRevisao.OwnerId = usuario.Id;
        
        insert taskRevisao;
        
        //Cria novo planejamento.
        plan = new Planejamento__c();
        plan.OwnerId = usuario.Id;
        plan.Name = 'Planejamento de Visitas';
        plan.M_s_de_Ref_rencia__c = 'Junho';
        plan.Ano_de_Referencia__c = '2012';
        plan.RecordTypeId = RecordTypeForTest.getRecType( 'Planejamento__c', 'BRA_Standard' );
        insert plan;
        
        //Atualiza planejamento com primeira revisão.
        /*plan.Aprovado_semana_1__c = true;
        
        update plan;
        
        //Atualiza planejamento com segunda revisão.
        plan.Aprovado_semana_2__c = true;
        
        update plan;*/
    }
}