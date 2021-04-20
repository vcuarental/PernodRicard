/********************************************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_AR_VFP01_ReceiptEditDeleteVal / LAT_AR_VFP01_ReceiptEditVal
* Descripcion: extencion de la paginas LAT_AR_VFP01_ReceiptEditDeleteVal / LAT_AR_VFP01_ReceiptEditVal
* Fecha: 22/05/2014 
*********************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_AR_VFC01_ReceiptEditDeleteValExt{

    String receiptId;
    String retURL;
    PageReference returnURL;
    RCP_Receipt_ARG__c receipt;

    public LAT_AR_VFC01_ReceiptEditDeleteValExt(ApexPages.StandardController controller){
        
        receiptId = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        returnURL = new PageReference(retURL);
        
        receipt = [SELECT Id, RecordTypeId, Status_AR__c FROM RCP_Receipt_ARG__c WHERE Id =: receiptId];
    }

    public PageReference doValidationDelete(){

        if(userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') &&
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') &&
             receipt.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC01_00002));
            //LAT_AR_VFC01_00002: No se pueden editar o eliminar recibos anulados.
            returnURL = null;        
        }else{
            try{
                delete receipt;
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
             receipt.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC01_00002));
            //LAT_AR_VFC01_00002: No se pueden editar o eliminar recibos anulados.
            returnURL = null;        
        }else{
            return new PageReference('/' + receiptId + '/e?retURL=' + retURL + '&nooverride=1');
        }
       return returnURL; 
    }
}