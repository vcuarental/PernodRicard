@isTest
private class MMPJ_XRM_BatchCompteContrat_Test {
    
    static testMethod void MMPJ_XRM_BatchCompteContrat_Test(){
        System.Debug('## >>>>> testing class BatchCompteContrat_Test <<<<<');
        Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Vigneron' LIMIT 1].Id;
        
        List<MMPJ_Ext_Vign_Societe__c> societes = new List<MMPJ_Ext_Vign_Societe__c>();
        for(Integer i=0;i<200;i++)
        {
            MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
            societes.add(societe);
        }    
        insert societes;
        
        
        String RT_Id = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Contrat__c' and DeveloperName='MMPJ_Ext_Vign_Appro_Press' LIMIT 1].Id;
        
        List<MMPJ_Ext_Vign_Contrat__c> contrats = new List<MMPJ_Ext_Vign_Contrat__c>();
        for(Integer i=0;i<100;i++)
        {
            MMPJ_Ext_Vign_Contrat__c con = new MMPJ_Ext_Vign_Contrat__c(Name = '88888',RecordTypeId=RT_Id, 
                        MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(-2), MMPJ_Ext_Vign_Date_de_fin_du_contrat__c=Date.today().addMonths(12), MMPJ_Ext_Vign_Livreur__c=societes[i].id);
            contrats.add(con);
        }

        for(Integer i=100;i<200;i++)
        {
            MMPJ_Ext_Vign_Contrat__c con = new MMPJ_Ext_Vign_Contrat__c(Name = '777',RecordTypeId=RT_Id, 
                        MMPJ_Ext_Vign_Date_de_debut_du_contrat__c=Date.today().addMonths(24), MMPJ_Ext_Vign_Date_de_fin_du_contrat__c=Date.today().addMonths(-12), MMPJ_Ext_Vign_Livreur__c=societes[i].id);
            contrats.add(con);
        }
        
        insert contrats;

        Test.startTest();
        
        MMPJ_XRM_BatchCompteContrat batchClass = new MMPJ_XRM_BatchCompteContrat();
        batchClass.querySegmentation = batchClass.querySegmentation + ' LIMIT 200';
        ID batchprocessid = Database.executeBatch(batchClass);
        
        Test.stopTest();
            
        System.Debug('## >>>>> end of test : class BatchCompteContrat <<<<<');
    }   
}