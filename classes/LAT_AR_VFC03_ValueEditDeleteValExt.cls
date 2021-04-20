/********************************************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_AR_VFP03_ValueEditDeleteVal / LAT_AR_VFP03_ValueEditVal
* Descripcion: extencion de la paginas LAT_AR_VFP03_ValuetEditDeleteVal / LAT_AR_VFP03_ValueEditVal
* Fecha: 22/05/2014 
*********************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_AR_VFC03_ValueEditDeleteValExt{

    String valueId;
    String retURL;
    PageReference returnURL;
    VLS_Values_ARG__c value;

    public LAT_AR_VFC03_ValueEditDeleteValExt(ApexPages.StandardController controller){
        
        valueId = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        returnURL = new PageReference(retURL);
        
        value = [SELECT Id, ReceiptNo_AR__r.Status_AR__c FROM VLS_Values_ARG__c WHERE Id =: valueId];
    }

    public PageReference doValidationDelete(){
        
        if(userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') &&
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') && 
            value.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC03_00001));
            //LAT_AR_VFC03_00001: No se pueden editar o eliminar valores de recibos anulados
            returnURL = null;        
        }else{
            try{
                delete value;
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
            value.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC03_00001));
            //LAT_AR_VFC03_00001: No se pueden editar o eliminar valores de recibos anulados
            returnURL = null;        
        }else{
            return new PageReference('/' + valueId + '/e?retURL=' + retURL + '&nooverride=1');
        }
       return returnURL; 
    }
}