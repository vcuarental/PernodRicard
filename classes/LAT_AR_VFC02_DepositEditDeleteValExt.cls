/********************************************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_AR_VFP02_DepositEditDeleteVal / LAT_AR_VFP02_DeposittEditVal
* Descripcion: extencion de la paginas LAT_AR_VFP02_DepositEditDeleteVal / LAT_AR_VFP02_DepositEditVal
* Fecha: 22/05/2014 
*********************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_AR_VFC02_DepositEditDeleteValExt{

    String depositId;
    String retURL;
    PageReference returnURL;
    DPT_Deposit_ARG__c deposit;

    public LAT_AR_VFC02_DepositEditDeleteValExt(ApexPages.StandardController controller){
        
        depositId = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        returnURL = new PageReference(retURL);
        
        deposit = [SELECT Id, ReceiptNo_AR__r.Status_AR__c FROM DPT_Deposit_ARG__c WHERE Id =: depositId];
    }

    public PageReference doValidationDelete(){
        
        if(userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') &&
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') &&
             deposit.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC02_00001));
            //LAT_AR_VFC02_00001: No se pueden editar o eliminar depositos de recibos anulados
            returnURL = null;        
        }else{
            try{
                delete deposit;
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
            deposit.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC02_00001));
            //LAT_AR_VFC02_00001: No se pueden editar o eliminar depositos de recibos anulados
            returnURL = null;        
        }else{
            return new PageReference('/' + depositId + '/e?retURL=' + retURL + '&nooverride=1');
        }
       return returnURL; 
    }
}