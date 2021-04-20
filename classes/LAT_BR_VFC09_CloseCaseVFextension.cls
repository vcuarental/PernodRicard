/********************************************************************************

********************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public with sharing class LAT_BR_VFC09_CloseCaseVFextension{
 
    private Case cas;

    public LAT_BR_VFC09_CloseCaseVFextension(ApexPages.StandardController stdController) {   
        this.cas = (Case)stdController.getRecord();     
    }
    
    //MIGRATED 02/11/2016 
    public PageReference actionsButtom() {
        pageReference pgRef = new pageReference ( '/' + cas.id);
        Case cas1 = [SELECT id,Status, LAT_Contract__c,LAT_BR_RealValidityDate__c  FROM Case WHERE id=: cas.id];
        cas1.Status = 'Closed';
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