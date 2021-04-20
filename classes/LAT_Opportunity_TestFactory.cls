/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 07/11/2016
*
********************************************************************************/


public with sharing class LAT_Opportunity_TestFactory {
    public LAT_Opportunity_TestFactory() {
        
    }


    public static RecordType getRecordType(String name){
            
        return Global_RecordTypeCache.getRtRec('Opportunity' + name);

    }
    //MIGRATED 07/11/2016
    public static RecordType LAT_getRecordType(String name){
            
        return Global_RecordTypeCache.getRtRec('LAT_Opportunity__c' + name);

    }

    
    public static Opportunity getCRMOppty(String accId){
        String idOpportunity = getRecordType('Nova_oportunidade').id; 
        //Cria nova oportunidade.      
        Opportunity Opp = new Opportunity();      
        Opp.Name = 'Opp TESTE COTA';      
        Opp.closeDate = Date.today() + 2;      
        Opp.AccountId = accId;      
        Opp.StageName = 'Novo pedido';      
        Opp.RecordTypeId = idOpportunity;  
        opp.Origem_do_pedido__c = 'CRM';
        return Opp;   
    } 
    //MIGRATED 07/11/2016
    public static LAT_Opportunity__c LAT_getCRMOppty(String accId){
        String idOpportunity = LAT_getRecordType('Nova_oportunidade').id; 
        //Cria nova oportunidade.      
        LAT_Opportunity__c Opp = new LAT_Opportunity__c();      
        Opp.Name = 'Opp TESTE COTA';      
        Opp.LAT_CloseDate__c = Date.today() + 2;      
        Opp.LAT_Account__c = accId;      
        Opp.LAT_StageName__c = 'Novo pedido';      
        Opp.RecordTypeId = idOpportunity;  
        opp.LAT_OrderOrigin__c = 'CRM';
        return Opp;   
    } 
    
}