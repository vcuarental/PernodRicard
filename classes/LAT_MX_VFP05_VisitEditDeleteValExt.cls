/********************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_MX_VFP05_VisitEditDeleteValalidation
* Descripcion: extencion de la pagina LAT_MX_VFP05_VisitEditDeleteValalidation
* Fecha: 23/12/2013 
*********************************************************************/

public with sharing class LAT_MX_VFP05_VisitEditDeleteValExt{

    public LAT_MX_VFP05_VisitEditDeleteValExt(ApexPages.StandardController controller){
    
    }

    public PageReference doValidationDelete(){
    
        String visitId = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');        
        String pageURL = ApexPages.currentPage().getURL();
        
        
        PageReference returnURL = new PageReference(retURL);

        Visitas__c visita = [SELECT Id, RecordTypeId, Planejamento__r.Status_do_Planejamento__c FROM Visitas__c WHERE Id =: visitId];
        
        if(visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit') 
            || visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisitON')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_MX_VFP05_00001));
            //LAT_MX_VFP05_00001: No se pueden modificar ni eliminar visitas cerradas.
            returnURL = null;
        }else if(visita.Planejamento__r.Status_do_Planejamento__c == 'Aguardando Aprovação' && (visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit') || visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit') || visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisitON') || visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisitON'))){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_MX_VFP05_00003));
            //LAT_MX_VFP05_00003: No se pueden eliminar Visitas si el planeamiento esta pendiente de aprobación.
            returnURL = null;        
        }else{
            try{ delete visita; }catch(DMLException e){ ApexPages.addMessages(e); return null; }
        }
       return returnURL; 
    }
    
    public PageReference doValidationEdit(){
    
        String visitId = ApexPages.currentPage().getParameters().get('id');
        String retURL = ApexPages.currentPage().getParameters().get('retURL');        
        String pageURL = ApexPages.currentPage().getURL();
        String  userID =UserInfo.getUserId();
        
        PageReference returnURL = new PageReference(retURL);

        Visitas__c visita = [SELECT Id, RecordTypeId, Planejamento__r.Status_do_Planejamento__c, Planejamento__r.OwnerId FROM Visitas__c WHERE Id =: visitId];
        
        User us = [SELECT Id, ManagerId FROM User WHERE Id =: visita.Planejamento__r.OwnerId];
                
        if(visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisit') 
            || visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_ClosedVisitON')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_MX_VFP05_00001));
            //LAT_MX_VFP05_00001: No se pueden modificar ni eliminar visitas cerradas.
            returnURL = null;
        }else if(visita.Planejamento__r.Status_do_Planejamento__c == 'Aguardando Aprovação' && visita.RecordTypeId == Global_RecordTypeCache.getRtId('Visitas__c' + 'LAT_MX_VTS_PlannedVisit') &&  us.ManagerId != UserInfo.getUserId()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_MX_VFP05_00004));
            //LAT_MX_VFP05_00004: No se pueden modificar Visitas si el planeamiento esta pendiente de aprobación.
            returnURL = null; 
            
        }else if  (Utils.isPartOfMobileCRM(userID)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_VFP30_Mobile_Permissions));
            returnUrl =  null;   
            
        
        }else{
            return new PageReference('/' + visitId + '/e?retURL=' + retURL + '&nooverride=1');
        }
       return returnURL; 
    }
}