/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto Planejamento__c
*******************************************************************************/

public with sharing class AP01_Planejamento_AR {
    
    /*****************************************************************************************
    * Nombre del metodo: translatePicklist
    * Descripcion: 
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void translatePicklist(List<Planejamento__c> newTrigger){
        Schema.DescribeFieldResult F = Planejamento__c.Status_do_Planejamento__c.getDescribe();
        List <Schema.PicklistEntry> picklistValues = F.getPicklistValues();
        
        for(Planejamento__c plan :newTrigger){
            for(Schema.PicklistEntry entry :picklistValues){
                if(entry!=null){
                    if(plan.Status_do_Planejamento__c==entry.getValue()){
                        plan.Planning_Status_Translate__c=entry.getLabel();
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: changeNametoPlanejamento
    * Descripcion: Cambia el nombre del planejamiento según la siguiente estructura: ‘Nombre del Usuario que ejecuta el proceso’ + guion + 'M_s_de_Ref_rencia__c/Ano_de_Referencia__c’
    * Desarrollador: Nicolas Javier Romero
    * Fecha: 29/05/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void changeNametoPlanejamento(List<Planejamento__c> newTrigger){

        map<String, String> mapPickValueTraslate = new map<String, String>();
        Schema.DescribeFieldResult F = Planejamento__c.M_s_de_Ref_rencia__c.getDescribe();
        List <Schema.PicklistEntry> picklistValues = F.getPicklistValues();
    
        for(Schema.PicklistEntry entry :picklistValues){
            if(entry!=null){
                mapPickValueTraslate.put(entry.getValue(), entry.getLabel());
            }
        }
    
        for(Planejamento__c reg :newTrigger){
			reg.Name = userInfo.getFirstName()+' '+userInfo.getLastName()+' - '+mapPickValueTraslate.get(reg.M_s_de_Ref_rencia__c)+'/'+reg.Ano_de_Referencia__c;
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: verifyClosedVisits
    * Descripcion: Verifica que no haya visitas sin cerrar del mes anterior cuando se envia un planeamiento a aprobar
    * Desarrollador: Waldemar Mayo
    * Fecha: 05/02/2014
    * Modo: before update
    *****************************************************************************************/
    public static void verifyClosedVisits(list<Planejamento__c> triggerNew, map<Id, Planejamento__c> triggerOldMap){
        
        //sets para despues llamar a planejamientos del mes anterior
        set<Date> setPrevMonth = new set<Date>();
        set<String> setUser = new set<String>();
        
        for(Planejamento__c plan: triggerNew){
        	if(plan.Status_do_Planejamento__c == 'Aguardando Aprovação' && (triggerOldMap.get(plan.id).Status_do_Planejamento__c != plan.Status_do_Planejamento__c)){
        		if(plan.LAT_MonthYear__c != null){
	                setPrevMonth.add(plan.LAT_MonthYear__c.addMonths(-1));
	                setUser.add(plan.OwnerId);
	            }else{
	                plan.addError(label.LAT_BR_AP01_00001);
	                //Label.LAT_BR_AP01_00001 = One or more fields are missing
	            }
        	}
        }
        
        //Guardo en el mapa si hay visitas sin cerrar para los meses anteriores
        map<string, Visitas__c> setPlaningWithVisitsNotClosed = new map<string, Visitas__c>(); 
        for(Planejamento__c plan: [SELECT id, Name, OwnerId, LAT_MonthYear__c,  (SELECT Id, Name, Status__c, Planejamento__c FROM Visitas__r) FROM Planejamento__c WHERE LAT_MonthYear__c IN: setPrevMonth AND OwnerId IN: setUser]){
            for(Visitas__c vis: plan.Visitas__r){
                if(vis.Status__c != 'Encerrada'){
                    setPlaningWithVisitsNotClosed.put(plan.LAT_MonthYear__c+'-'+plan.OwnerId, vis);
                    break;
                }
            }
        }
        
        for(Planejamento__c plan: triggerNew){
            if(plan.Status_do_Planejamento__c == 'Aguardando Aprovação' && (triggerOldMap.get(plan.id).Status_do_Planejamento__c != plan.Status_do_Planejamento__c)){
                if(setPlaningWithVisitsNotClosed.containsKey(plan.LAT_MonthYear__c.addMonths(-1)+'-'+plan.OwnerId)){
                	plan.addError(label.LAT_BR_AP01_00002+': "'+setPlaningWithVisitsNotClosed.get(plan.LAT_MonthYear__c.addMonths(-1)+'-'+plan.OwnerId).Name+'"');
                    //Label.LAT_BR_AP01_00002 = Visits are open in previous month
                }
            }
        }
    }
    
}