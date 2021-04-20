/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Scheduler que cria tarefas semanais para todos os Usuário com planejamentos que 
* ainda não tiveram a última aprovação
* NAME: SchedulerCriaTarefaRevisaoPlanejamento.CLS
* AUTHOR: CARLOS CARVALHO                         DATE: 14/05/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
global class SchedulerCriaTarefaRevisaoPlanejamento implements Schedulable
{
    /** 
        Código para agendar via execute anonymous.
        SchedulerCriaTarefaRevisaoPlanejamento sch = new SchedulerCriaTarefaRevisaoPlanejamento();
        String cron = '0 1 1 ? * WED';
        System.schedule('SchedulerCriaTarefaRevisaoPlanejamento', cron, sch);
    */ 
    
    public static String CRON_EXP = '0 1 1 ? * WED';
        
    global void execute(SchedulableContext sc)
    {
    	
        //Declaração de variáveis.
        List<User> listUsuarios                 = null;
        List<Task> listTarefas                  = new List<Task>();
        List<String> listIdUser                 = new List<String>();
        List<Planejamento__c> listPlanejamento  = null;
        Map<String, String> mapPlanejamentos    = new Map<String, String>();
        String idRecTypeTarefa                  = null;
        
        //Recupera os tipos de registros desejados.
        idRecTypeTarefa = RecordTypeForTest.getRecType('Task','Revis_o_de_Planejamento_de_Visita_Semanal');
        
        
        //Recupera todos os planejamentos que ainda não passaram por todas as aprovações.
        listPlanejamento = PlanejamentoDAO.getInstance().getListPlanejamentoEmAndamento();
        
        
        /* Para cada planejamento recuperado é atribuído os IDS dos Owner em uma lista e é feito um 
         * map de OwnerId com Id do planejamento.
        */
        
        for(Planejamento__c p:listPlanejamento)
        {
            listIdUser.add(p.OwnerId);
            mapPlanejamentos.put(p.OwnerId, p.Id);
        }
        
        //Verifica se existe uma lista de IDS para iniciar o select.
        if(listIdUser != null && listIdUser.size()>0)
        {
            //Recupera todos os usuários.
            listUsuarios = UserDAO.getInstance().getListUserById(listIdUser);
            
            if(listUsuarios != null && listUsuarios.size()>0)
            {
                for(User u:listUsuarios)
                {
                    Task tarefa = new Task();
                    tarefa.RecordTypeId = idRecTypeTarefa;
                    tarefa.OwnerId = u.Id;
                    tarefa.WhatId = mapPlanejamentos.get(u.Id);
                    tarefa.Subject = 'Revisar Planejamento Mensal';
                    tarefa.Status = 'Não iniciado';
                    tarefa.Priority = 'Normal';
                    tarefa.ActivityDate = System.today();
                    
                    //Adiciona a nova tarefa na lista.
                    listTarefas.add(tarefa);
                }
                if(listTarefas != null && listTarefas.size()>0)
                {
                    try {insert listTarefas;} catch(DMLException e) { System.debug(e.getMessage()); }
                }
            }
        }      
         
    }
    
}