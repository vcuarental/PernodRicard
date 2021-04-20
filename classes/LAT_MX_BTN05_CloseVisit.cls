/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que funciona con el boton "Cerrar Visita" en el objeto Visita
*******************************************************************************/
global class LAT_MX_BTN05_CloseVisit {
    
    webservice static string closeVisit(string IdVisita){
        
        string cerrar = 'Encerrada';
        
        Visitas__c visita = [SELECT id, Name, Conta__r.RecordTypeId, Status__c, LAT_MX_PedingChecklist__c, LAT_MX_GoalAchieved__c,
                                     LAT_MX_Type__c, LAT_MX_IsChecklistMandatory__c FROM Visitas__c WHERE id =: IdVisita];
                            
        List<CLV_ChecklistVisita_ARG__c> listCheck = [SELECT Id, Visit_AR__c FROM CLV_ChecklistVisita_ARG__c WHERE Visit_AR__c =: IdVisita];
        
        String[] Values;
        if(visita.LAT_MX_Type__c != null){
            Values = visita.LAT_MX_Type__c.split(';');
        }
        
        if(visita.Status__c == cerrar){
            return Label.VF_VTS_00042_AR;
            //Label.VF_VTS_00042_AR says "No se puede cerrar, la visita ya esta cerrada!"
        }else if((listCheck.isEmpty() || (listCheck.size() != Values.size())) && visita.LAT_MX_IsChecklistMandatory__c){
            return Label.LAT_MX_BTN05_00003;
            //Label.LAT_MX_BTN05_00003 says "A visit cannot be closed if the one or more checklists where not created."            
        }else if (visita.LAT_MX_PedingChecklist__c != 0 && visita.LAT_MX_IsChecklistMandatory__c){
            return Label.LAT_MX_BTN05_00001;
            //Label.LAT_MX_BTN05_00001 says "Please resolve all the Pending checklist to continue"
        }else if(visita.LAT_MX_GoalAchieved__c == null ){
            return Label.LAT_MX_BTN05_00002;
            //Label.LAT_MX_BTN05_00002 says "Please complete the field "Goal Achieved" to continue"
        }else{
            visita.Status__c = cerrar ;
            String rtAccountOn = Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade');
            
            if (visita.Conta__r.RecordTypeId == rtAccountOn) {
                visita.RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisitON');
            } else {
                visita.RecordTypeId = Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit');
            }
            try{update visita;}catch (DMLException e){return e.getMessage();}
        } 
        return 'ok'; 
    }
}