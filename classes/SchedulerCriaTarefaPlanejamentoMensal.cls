/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Scheduler que cria tarefas mensais para os consultores criarem planejamento
* de visitas.
* NAME: SchedulerCriaTarefaPlanejamentoMensal.cls
* AUTHOR: CARLOS CARVALHO                         DATE: 14/05/2012
*
* MAINTENANCE
* AUTHOR:                                           DATE: 
********************************************************************************/
global class SchedulerCriaTarefaPlanejamentoMensal implements Schedulable 
{
      
    /* 
        Código para testar via execute anonymous.
        SchedulerCriaTarefaPlanejamentoMensal sch = new SchedulerCriaTarefaPlanejamentoMensal();
        String cron = '0 1 0 27 * ?';
        System.schedule('SchedulerCriaTarefaPlanejamentoMensal', cron, sch);
    */
    public static String CRON_EXP = '0 1 0 27 * ?';
    
    global void execute(SchedulableContext sc)
    {
    
        //Declaração de variáveis.
        List<User> listUsuarios                 = null;
        List<Task> listTarefas                  = new List<Task>();
        List<Profile> listProfiles              = null;
        List<String> listNameProfile            = new List<String>();
        String idConsultorVendas                = null;
        Map<String, String> mapNamesIdsProfiles = new Map<String, String>();
        String aDia = '01';
        String aAno = String.valueOf(System.today().year());
        String aMes = String.valueOf(System.today().addMonths(1).month());
        String idRecTypeTarefa                  = null;
        
        //Recupera os tipos de registros desejados.
        idRecTypeTarefa = RecordTypeForTest.getRecType('Task','Planejamento_de_Visitas_Mensal');
        
        //Aramazena os nomes dos perfis desejados a retornarem do select.
        listNameProfile.add('Usuário padrão PERNOD');
                
        //Recupera os Ids dos perfis.
        listProfiles = ProfileDAO.getInstance().getListProfileByNameProfile(listNameProfile);
        for(Profile p:listProfiles)
        {
            mapNamesIdsProfiles.put(p.Name, p.Id);
        }
        
        if(mapNamesIdsProfiles.containsKey('Usuário padrão PERNOD'))
        {
            idConsultorVendas = mapNamesIdsProfiles.get('Usuário padrão PERNOD');
        }
        
        listUsuarios = UserDAO.getInstance().getListUserByIdProfile(idConsultorVendas);
        
        if(listUsuarios != null && listUsuarios.size()>0)
        {
            for(User u:listUsuarios)
            {
                Task tarefa = new Task();
                tarefa.RecordTypeId = idRecTypeTarefa;
                tarefa.OwnerId = u.Id;
                tarefa.Subject = 'Criar Planejamento Mensal';
                tarefa.Status = 'Não iniciado';
                tarefa.Priority = 'Normal';
                tarefa.ActivityDate = Date.valueOf(aAno+'-'+aMes+'-'+aDia);
                listTarefas.add(tarefa);
            }
            if(listTarefas != null && listTarefas.size()>0)
            {
                try{insert listTarefas;} catch(DMLException e) { System.debug(e.getMessage()); }
            }
        }
    
    }
}