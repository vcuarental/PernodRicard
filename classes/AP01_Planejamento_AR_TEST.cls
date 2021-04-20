/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene el test de AP01_Planejamento_AR
*******************************************************************************/
@isTest
public with sharing class AP01_Planejamento_AR_TEST {

    static testmethod void unitTest1(){
    
        Planejamento__c planejamiento = new Planejamento__c();
        
        planejamiento.Ano_de_Referencia__c='2013';
        planejamiento.Name='Test 1';
        try{
            planejamiento.RecordTypeid=[SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName='PLV_Standard_AR' limit 1].Id;
        }catch(Exception e){
            planejamiento.RecordTypeid=[SELECT Id FROM RecordType limit 1].Id;
        }
        planejamiento.M_s_de_Ref_rencia__c='Abril';
        
        insert planejamiento;
    }

}