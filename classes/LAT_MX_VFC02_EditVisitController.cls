/*************************************************************************************************
*                                         Company: ValueNet                                      *
*------------------------------------------------------------------------------------------------*
*  Controlador del la Visualforce page LAT_MX_VFP02_EditVisit al apretar el boton "Edit Visita"  *
**************************************************************************************************/

public with sharing class LAT_MX_VFC02_EditVisitController {
        
	public List<Visitas__c> visitas {get;set;}
    
    public LAT_MX_VFC02_EditVisitController(ApexPages.StandardSetController controller){
    	
    	String whereCondition;
    	
    	set<String> idsVisSelected = new set<String>();
        if(ApexPages.currentPage().getParameters().containsKey('idsVis')){
        	idsVisSelected.addAll(ApexPages.currentPage().getParameters().get('idsVis').split(','));
        	whereCondition = 'id IN: idsVisSelected';
        }else{
        	whereCondition = 'Planejamento__c = \'' + ApexPages.currentPage().getParameters().get('idPlan') + '\'';
        }
        
        visitas = DataBase.query('SELECT LAT_MX_ClienteChannel__c, Conta__c, Descrever_Motivo__c, Conta__r.name, LAT_MX_Type__c, Resumo_da_Visita__c, Data_da_Visita__c, Hora_da_Visita__c, Visita_n_o_realizada__c, Poss_veis_motivos__c, LAT_MX_GoalAchieved__c FROM Visitas__c WHERE '+whereCondition+' ORDER BY Conta__r.name');
    }
    
    public PageReference save(){
        try{
            update visitas;
        }catch(DMLException e){
            ApexPages.addMessages(e);
            return null;
        }
        return new PageReference('/'+ApexPages.currentPage().getParameters().get('idPlan'));
    }
}