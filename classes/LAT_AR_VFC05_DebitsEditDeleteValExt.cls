/********************************************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_AR_VFP05_DebitEditDeleteVal / LAT_AR_VFP05_DebitEditVal
* Descripcion: extencion de la paginas LAT_AR_VFP05_DebitEditDeleteVal / LAT_AR_VFP05_DebitEditVal
* Fecha: 22/05/2014 
*********************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_AR_VFC05_DebitsEditDeleteValExt{

    String debitId;
    String retURL;
    PageReference returnURL;
    DBT_Debit_ARG__c debit;

    public LAT_AR_VFC05_DebitsEditDeleteValExt(ApexPages.StandardController controller){
        
        debitId = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        returnURL = new PageReference(retURL);
        
        debit = [SELECT Id, ReceiptNo_AR__r.Status_AR__c FROM DBT_Debit_ARG__c WHERE Id =: debitId];
    }

    public PageReference doValidationDelete(){
        
        if(userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') &&
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') &&
             debit.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC05_00001));
            //LAT_AR_VFC05_00001: No se pueden editar o eliminar débitos de recibos anulados
            returnURL = null;        
        }else{
            try{
                delete debit;
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
            debit.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC05_00001));
            //LAT_AR_VFC05_00001: No se pueden editar o eliminar débitos de recibos anulados
            returnURL = null;        
        }else{
            return new PageReference('/' + debitId + '/e?retURL=' + retURL + '&nooverride=1');
        }
       return returnURL; 
    }
}