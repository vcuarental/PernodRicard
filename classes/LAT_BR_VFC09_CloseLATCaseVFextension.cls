/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/
public with sharing class LAT_BR_VFC09_CloseLATCaseVFextension {
	
    private LAT_Case__c latCase;

    public LAT_BR_VFC09_CloseLATCaseVFextension(ApexPages.StandardController stdController) {   
        this.latCase = (LAT_Case__c)stdController.getRecord();     
    }
    
    //MIGRATED 02/11/2016 
    public PageReference actionsButtom() { 
        pageReference pgRef = new pageReference ( '/' + latCase.id);
        LAT_Case__c cas1 = [SELECT id,LAT_Status__c, LAT_Contract__c,LAT_BR_RealValidityDate__c  FROM LAT_Case__c WHERE id=: latCase.id];
        cas1.LAT_Status__c = 'Closed';
        update cas1;
    
        list<LAT_Contract__c> con = [SELECT id, Status__c,LAT_BR_RealValidityDate__c FROM LAT_Contract__c WHERE id=: cas1.LAT_Contract__c LIMIT 1];
        if(con.size() > 0){
            con[0].Status__c = 'Contrato Prorrogado';
            con[0].LAT_BR_RealValidityDate__c = Cas1.LAT_BR_RealValidityDate__c;
            update con[0];
        }         
        return pgRef;    
    }
}