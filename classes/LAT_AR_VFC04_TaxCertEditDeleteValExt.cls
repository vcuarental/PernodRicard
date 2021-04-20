/********************************************************************************************************
* Company: Valuenet 
* Desarrollador: Elena J. Schwarzböck
* Nombre del pagina: LAT_AR_VFP04_TaxCertEditDeleteVal / LAT_AR_VFP04_TaxCertEditVal
* Descripcion: extencion de la paginas LAT_AR_VFP04_TaxCertEditDeleteVal / LAT_AR_VFP04_TaxCertEditVal
* Fecha: 22/05/2014 
*********************************************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public with sharing class LAT_AR_VFC04_TaxCertEditDeleteValExt{

    String taxCertId;
    String retURL;
    PageReference returnURL;
    TXC_TaxCertificates_ARG__c taxCert;

    public LAT_AR_VFC04_TaxCertEditDeleteValExt(ApexPages.StandardController controller){
        
        taxCertId = ApexPages.currentPage().getParameters().get('id');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        returnURL = new PageReference(retURL);
        
        taxCert = [SELECT Id, ReceiptNo_AR__r.Status_AR__c FROM TXC_TaxCertificates_ARG__c WHERE Id =: taxCertId];
    }

    public PageReference doValidationDelete(){
        
        if(userInfo.getProfileId() != LAT_GlobalProfileCache.getStandardAdminProfileId() && 
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('AR_System Administrator') &&
            userInfo.getProfileId() != LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator') &&
             taxCert.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC04_00001));
            //LAT_AR_VFC04_00001: No se pueden editar o eliminar retenciones de recibos anulados.
            returnURL = null;        
        }else{
            try{
                delete taxCert;
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
            taxCert.ReceiptNo_AR__r.Status_AR__c == 'Receipt cancelled'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, label.LAT_AR_VFC04_00001));
            //LAT_AR_VFC04_00001: No se pueden editar o eliminar retenciones de recibos anulados.
            returnURL = null;        
        }else{
            return new PageReference('/' + taxCertId + '/e?retURL=' + retURL + '&nooverride=1');
        }
       return returnURL; 
    }
}