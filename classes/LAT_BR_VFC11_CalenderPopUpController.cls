/******************************************************************************
*   Company:Valuenet    Developers:Elena Schwarzböck       Date:28/03/2014    *
*******************************************************************************/

public with sharing class LAT_BR_VFC11_CalenderPopUpController {

    public String pageRet {get;set;}      
    public Visitas__c visita {get;set;}
    public Boolean isNew {get;set;}
        
    public LAT_BR_VFC11_CalenderPopUpController(ApexPages.StandardController controller){
    
        String idVisita = Apexpages.currentPage().getParameters().get('idVisita');     
        String fecha = Apexpages.currentPage().getParameters().get('date');
        String idPlan = Apexpages.currentPage().getParameters().get('idPlan');
        
        Date fechaNew;
        List<String> horaNew = new List<String>();
        
        if(fecha != null){
            Map<String,Integer> mapMesAInteger = new Map<String,Integer>{
                'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
            };        
            List<String> partsFecha = fecha.split(' ',6);
            fechaNew = date.newInstance(integer.valueOf(partsFecha[3]),mapMesAInteger.get(partsFecha[1]),integer.valueOf(partsFecha[2]));
            horaNew = partsFecha[4].split(':',3);          
        }
        
        if(idVisita != null){
            visita = [SELECT Id, Name, Conta__c, Planejamento__c, Tipo_de_Visita__c, Data_da_Visita__c, Hora_da_Visita__c, Visita_n_o_realizada__c, Poss_veis_motivos__c, Descrever_Motivo__c FROM Visitas__c WHERE Id =: idVisita];
       }else{
           visita = new Visitas__c(
               Name = 'test',
               Planejamento__c = idPlan,
               Data_da_Visita__c = fechaNew,
               Hora_da_Visita__c = (horaNew[0] != '00' ? horaNew[0] + ':' + horaNew[1] : null)                     
           );     
       }
       
    }
    
    public PageReference doSave(){
        
        try{
            if(visita.Id != null){
                update visita;
            }else{
                insert visita;
            } 
            pageRet = '/apex/LAT_BR_VFP02_VisitasCalen?idPlanejamento=' + visita.Planejamento__c;
        }catch(DMLException e){
            ApexPages.addMessages(e);
        }
        return null;
    }
    public PageReference doGoToVisit(){
        pageRet = '/' + visita.Id;
        return null;  
    }

        
}