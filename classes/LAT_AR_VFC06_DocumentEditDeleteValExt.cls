/********************************************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_AR_VFP06_DocumentEditDeleteVal / LAT_AR_VFP06_DocumentEditVal
* Descripcion: extencion de la paginas LAT_AR_VFP06_DocumentEditDeleteVal / LAT_AR_VFP06_DocumentEditVal
* Fecha: 22/05/2014 
*********************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_AR_VFC06_DocumentEditDeleteValExt{

    String documentId;
    String retURL;
    PageReference returnURL;
    DCM_Documents_ARG__c document;

    public LAT_AR_VFC06_DocumentEditDeleteValExt(ApexPages.StandardController controller){
        
        documentId = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        returnURL = new PageReference(retURL);
        
        document = [SELECT Id, ReceiptNo_AR__r.Status_AR__c FROM DCM_Documents_ARG__c WHERE Id =: documentId];
    }

    public PageReference doValidationDelete(){
        
        if(userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') &&
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') &&
             document.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC06_00001));
            //LAT_AR_VFC06_00001: No se pueden editar o eliminar comprobantes de recibos anulados
            returnURL = null;        
        }else{
            try{
                delete document;
            }catch(DMLException e){
                ApexPages.addMessages(e);
                return null;
            }
        }
       return returnURL; 
    }
    
    public PageReference doValidationEdit(){
    
        if(userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') &&
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') && 
            document.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC06_00001));
            //LAT_AR_VFC06_00001: No se pueden editar o eliminar comprobantes de recibos anulados
            returnURL = null;        
        }else{
            return new PageReference('/' + documentId + '/e?retURL=' + retURL + '&nooverride=1');
        }
       return returnURL; 
    }
}