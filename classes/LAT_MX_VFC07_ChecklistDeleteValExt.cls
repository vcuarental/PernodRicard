/********************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_MX_VFP07_ChecklistDeleteValidation
* Descripcion: extencion de la pagina LAT_MX_VFP07_ChecklistDeleteValidation
* Fecha: 14/03/2014 
*********************************************************************/

public with sharing class LAT_MX_VFC07_ChecklistDeleteValExt{

    public LAT_MX_VFC07_ChecklistDeleteValExt(ApexPages.StandardController controller){
    
    }

    public PageReference doValidationDelete(){
    
        String checkId = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');        
        String pageURL = ApexPages.currentPage().getURL();
        
        PageReference returnURL = new PageReference(retURL);

        CLV_ChecklistVisita_ARG__c check = [SELECT Id, RecordTypeId, Visit_AR__r.RecordTypeId FROM CLV_ChecklistVisita_ARG__c WHERE Id =: checkId];
        
        if(check.Visit_AR__r.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_MX_VFP07_00001));
            //LAT_MX_VFP07_00001: No se puede eliminar el checklist si la visita esta cerrada.
            returnURL = null;   
        }else{
            try{
                delete check;
            }catch(DMLException e){
                ApexPages.addMessages(e);
                return null;
            }
        }
       return returnURL; 
    }

}