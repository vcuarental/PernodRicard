/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* FECHA UMA TAREFA RELACIONADA AO PLANEJAMENTO ASSIM QUE O PLANEJAMENTO É APROVADO.
* NAME: PlanejamentoFechaTarefaRelacionada.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 21/05/2012 
*
*
* MAINTENANCE: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                               DATE: 08/01/2013 
********************************************************************************/
trigger PlanejamentoFechaTarefaRelacionada on Planejamento__c (after update) {

//    Check if this trigger is bypassed by SESAME (data migration Brazil)
if((UserInfo.getProfileId()!='00eM0000000QNYPIA4') && (UserInfo.getProfileId()!= '00eD0000001AnFlIAK')) {
    
  //Declaração de variáveis.
  Map<String, String> mapRecType           = new Map<String, String>();
  String idRecTypeTarefaMensal             = null;
  String idRecTypeTarefaRevisao            = null;
  List<String> developerName               = new List<String>();
  List<RecordType> listRecType             = new List<RecordType>();
  List<String> listIdOwnerPlanPrimeiraApro = new List<String>();
  List<String> listIdOwnerPlanRevisao      = new List<String>();
  List<Task> listTask                      = new List<Task>();
  List<Task> listTaskUpdate               = new List<Task>();
  Id idRecTypePlan = Global_RecordTypeCache.getRtId('Planejamento__c'+'BRA_Standard');
  
  //Recupera os tipos de registros desejados.
  idRecTypeTarefaMensal = Global_RecordTypeCache.getRtId('Task'+'Planejamento_de_Visitas_Mensal');
  idRecTypeTarefaRevisao = Global_RecordTypeCache.getRtId('Task'+'Revis_o_de_Planejamento_de_Visita_Semanal');
  
  for(Planejamento__c plan:trigger.new)
  {
    if( plan.RecordTypeId != idRecTypePlan ) continue;
    
    if(plan.Aprovado_semana_1__c && !Trigger.oldMap.get(plan.Id).Aprovado_semana_1__c)
    {
      listIdOwnerPlanPrimeiraApro.add(plan.OwnerId);
    }
    else if((plan.Aprovado_semana_2__c && !Trigger.oldMap.get(plan.Id).Aprovado_semana_2__c)|| (plan.Aprovado_semana_3__c  && !Trigger.oldMap.get(plan.Id).Aprovado_semana_3__c) || (plan.Aprovado_semana_4__c && !Trigger.oldMap.get(plan.Id).Aprovado_semana_4__c))
    {
      listIdOwnerPlanRevisao.add(plan.OwnerId);
    }
  }
  
  if(!listIdOwnerPlanPrimeiraApro.isEmpty()){
  	listTask = TarefaDAO.getInstance().getTaskByRecordTypeAndOwner(idRecTypeTarefaMensal, listIdOwnerPlanPrimeiraApro);
	if(listTask != null && listTask.size()>0)
	{
	  for(Task task : listTask)
	  {
	    task.Status = 'Concluído';
	    listTaskUpdate.add(task);
	  }
	}
  }
  
  
  if(!listIdOwnerPlanRevisao.isEmpty()){
    listTask = new List<Task>();
    listTask = TarefaDAO.getInstance().getTaskByRecordTypeAndOwner(idRecTypeTarefaRevisao, listIdOwnerPlanRevisao);
    if(listTask != null && listTask.size()>0)
    {
      for(Task task:listTask)
      {
        task.Status = 'Concluído';
        listTaskUpdate.add(task);
      }
    }
  }
  
  if(listTaskUpdate != null && listTaskUpdate.size()>0)
  {
    try{update listTaskUpdate;} catch(DMLException e){ System.debug(e.getMessage()); }
  }
 }
}