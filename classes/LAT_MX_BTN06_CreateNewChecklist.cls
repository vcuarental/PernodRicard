/**********************************************************************************************************************************
*   Company:Valuenet    Developers:   Elena J. Schwarzböck                                                                        *
*   Date:30/10/2013     Descripcion:  Creates the Checklists records according on the values of Visit Type MX                     *  
***********************************************************************************************************************************/

global without sharing class LAT_MX_BTN06_CreateNewChecklist{
   
    webService static String CreateNewChecklist(String idVisita){
    
        Visitas__c visit = [SELECT Id, LAT_MX_Type__c FROM Visitas__c WHERE Id =: idVisita];
        
        List<CLV_ChecklistVisita_ARG__c> listCheck = [SELECT Id, RecordTypeId, Visit_AR__c FROM CLV_ChecklistVisita_ARG__c WHERE Visit_AR__c =: idVisita]; 
    
        list<LAT_MX_CS002_VisitTypesAndChecklists__c> listCS = [SELECT Id, Name, LAT_MX_RecordTypeNameChecklist__c, LAT_MX_Type__c FROM LAT_MX_CS002_VisitTypesAndChecklists__c];
        
        Map<String,String> mapCS = new Map<String,String>();
          
        if(!listCS.isEmpty()){
            for(LAT_MX_CS002_VisitTypesAndChecklists__c cs : listCS){
                mapCS.put(cs.LAT_MX_Type__c, cs.LAT_MX_RecordTypeNameChecklist__c);
            }
        }
        
        set<String> setRtCheckDevName = new set<String>();
        
        RecordType rt;
        
        if(!listCheck.isEmpty()){
            for(CLV_ChecklistVisita_ARG__c check: listCheck){
                rt = Global_RecordTypeCache.getRt(check.RecordTypeId);
                setRtCheckDevName.add(rt.DeveloperName);
            }
        }
        
        String[] Values;
        
        if(visit.LAT_MX_Type__c != null){  
            Values = visit.LAT_MX_Type__c.split(';');
        } else {
            return ('Error: ' + label.LAT_MX_BTN06_00001);
            //LAT_MX_BTN06_00001: No hay valores de Tipo de Visita seleccionados.  
        }
        
        Boolean NewValues = false;
        
        List<CLV_ChecklistVisita_ARG__c> listChecklistInsert = new List<CLV_ChecklistVisita_ARG__c>();
                
        for(String s : Values){
            if(mapCS.containsKey(s) && Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + mapCS.get(s)) != null){
                if(!setRtCheckDevName.contains(mapCS.get(s))){
                    CLV_ChecklistVisita_ARG__c check = new CLV_ChecklistVisita_ARG__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('CLV_ChecklistVisita_ARG__c' + mapCS.get(s)),
                        Visit_AR__c = visit.Id
                    );
                    listChecklistInsert.add(check);
                    NewValues = true;
                }
            }else{
                return ('Error: ' + label.LAT_MX_BTN06_00003);
                //LAT_MX_BTN06_00003: No hay Checklist correspondiente para uno o mas de los Tipo de Visita seleccionado. Por favor contacte al administrador del sistema.
            }
            
        }
        if(NewValues){
            if(!listChecklistInsert.isEmpty()){
                try{
                    insert listChecklistInsert;
                } catch(DMLexception e){
                    return e.getMessage();
                }
                return idVisita;
            }
        } else {
            return ('Error: ' + label.LAT_MX_BTN06_00002);
            //LAT_MX_BTN06_00002: No quedan Checklists pendientes para los tipos de visitas seleccionados.
        }
    
    return null;
    
    }   
    
}