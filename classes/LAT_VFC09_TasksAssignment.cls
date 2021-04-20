public with sharing class LAT_VFC09_TasksAssignment {

	public List<Visitas__c> visitsList {get; set;}
	public List<Task> tasksSelected {get;set;}
	public List<Task> tasksToSelect {get;set;}
	public String urlSalesforce {get;set;}



	//PLanejamento Data 
	public Planejamento__c planejamento {get;set;}
	public Date dateConvertedFrom {get;set;}
	public Date dateConvertedTo {get;set;}


	public LAT_VFC09_TasksAssignment() {


		tasksToSelect = [Select id, Subject from task where LAT_Visita__c = NULL and ownerId =: Userinfo.getUserId()];
	    
	    urlSalesforce = URL.getSalesforceBaseUrl().toExternalForm();
		visitsList = [Select id,name,Conta__c,Data_da_Visita__c 
					  from Visitas__c 
					  where Planejamento__r.ownerId =: UserInfo.getUserID() 
					  order by Data_da_Visita__c limit 10 ];
	}

	public Date getPlanejamentData(){

		String pId = ApexPages.currentPage().getParameters().get('pId');
		Planejamento__c planejamento = [Select Id,Ano_de_Referencia__c,M_s_de_Ref_rencia__c From Planejamento__c Where Id = :pId];
		Date dateConvertedFrom =  Date.newInstance(integer.valueOf(planejamento.Ano_de_Referencia__c), PlanejamentoVisitasCriaVisitasAux.getMonth(planejamento.M_s_de_Ref_rencia__c), 1);
		return dateConvertedFrom;
	}


	public String getVisitNotAssigned (){
		tasksToSelect = [Select id, Subject 
						from Task 
						where LAT_Visita__c = NULL AND ownerId =: Userinfo.getUserId()];
		return JSON.serialize(tasksToSelect);
	}

	@RemoteAction
	public static List<Task> obtainVisitUnAssigned (){
		return [Select id, Subject 
				from Task 
				where LAT_Visita__c = NULL and ownerId =: Userinfo.getUserId()];
		//return JSON.serialize(tasksToSelect);
	}

  	@RemoteAction 
	public static List<Visitas__c>  loadVisitTableData (String dateTemp, String dateTemp2){

		String[] dateStringFrom = dateTemp.split('/');
		String mmFrom =  dateStringFrom[0];
		String ddFrom = dateStringFrom[1];
		String yyFrom = dateStringFrom[2];
		Date dateConvertedFrom =  Date.newInstance(integer.valueOf(yyFrom), integer.valueOf(mmFrom), integer.valueOf(ddFrom));

		String[] dateStringTo = dateTemp2.split('/');
		String mmTo =  dateStringTo[0];
		String ddTo = dateStringTo[1];
		String yyTo = dateStringTo[2];
		Date dateConvertedTo =  Date.newInstance(integer.valueOf(yyTo), integer.valueOf(mmTo), integer.valueOf(ddTo));

		//WE MUST CHANGE THE HARDCODED ID to USERNFO GET ID
		List<Visitas__c> visitsList = [Select id,name,Conta__c,Conta__r.Name,Status__c,Tipo_de_Visita__c,Data_da_Visita__c 
									  from Visitas__c 
									  where Planejamento__r.ownerId =: Userinfo.getUserId()
									  AND Data_da_Visita__c >= :dateConvertedFrom 
									  AND Data_da_Visita__c <= :dateConvertedTo
									  order by Data_da_Visita__c ];
		return visitsList;
	}

  	@RemoteAction 
	public static List<TaskInner> loadTaskAssignedRemote (String visitId){

		List<TaskInner> listTaskInner = new List<TaskInner>();
        for(Task t : [Select id, Subject from task where LAT_Visita__c = :visitId and ownerId =: Userinfo.getUserId()])
        	listTaskInner.add(new TaskInner(t.Id,t.Subject));
		return listTaskInner;
	}


	@RemoteAction 
	public static void saveListOfTasks (String taskId , String visitId){

		Task t = [Select Id, LAT_Visita__c From Task Where Id = :taskId Limit 1];
	    t.LAT_Visita__c = visitId != null ? visitId : null;
	    try{

	    	if(t != null) update t;
	    }catch(Exception e ){
	    	system.debug('Error --- > Update Visit' + e.getMessage());
	    }
	}

	public class TaskInner {

		public String taskId {get;set;}
		public String subject {get;set;}

		public TaskInner(String tId , String s){
			this.taskId = tId;
			this.subject = s;
		}
	}

}