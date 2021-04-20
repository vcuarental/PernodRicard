@isTest
public class  MMPJ_Ext_Vign_DocumentURL_TEST {
    
    static testmethod void test_method() {
       
        String url1 = 'https://stoprhextvignerondev.blob.core.windows.net/drupal/0037E00000TNknqQAD/calendrier-de-traitement/2017/07/1500562143.xlsx';
        String url2 = 'https://stoprhextvignerondev.blob.core.windows.net/drupal/0037E00000TNknqQAD/calendrier-de-traitement/2017/07/1500562144.xlsx';
        
        Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
        
        MMPJ_Ext_Vign_Societe__c acc1 = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
        insert acc1;

        MMPJ_Ext_Vign_Audit__c audit1 = new MMPJ_Ext_Vign_Audit__c(Name='12445',MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_Document__c=url1);
        insert audit1;

        MMPJ_Ext_Vign_Contrat__c con1 = new MMPJ_Ext_Vign_Contrat__c(Name='12445',MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_Document__c=url1);
        insert con1;

        MMPJ_Ext_Vign_Documents_Fournis__c doc1 = new MMPJ_Ext_Vign_Documents_Fournis__c(MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_Type__c = 'Brouillon de déclaration de récolte',MMPJ_Ext_Vign_Document__c=url1);
        insert doc1;

        MMPJ_Ext_Vign_Echantillon__c ech1 = new MMPJ_Ext_Vign_Echantillon__c(Name='12445',MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_Document__c=url1);
        insert ech1;

        MMPJ_Ext_Vign_Facture__c fac1 = new MMPJ_Ext_Vign_Facture__c(Name='12445',MMPJ_Ext_Vign_Societe__c=acc1.Id,MMPJ_Ext_Vign_Document__c=url1);
        insert fac1;

        MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c vol1 = new MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c(MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_Document__c=url1);
        insert vol1;

        audit1.MMPJ_Ext_Vign_Document__c = url2;
        update audit1;

        con1.MMPJ_Ext_Vign_Document__c = url2;
        update con1;

        doc1.MMPJ_Ext_Vign_Document__c = url2;
        update doc1;

        ech1.MMPJ_Ext_Vign_Document__c = url2;
        update ech1;

        fac1.MMPJ_Ext_Vign_Document__c = url2;
        update fac1;

        vol1.MMPJ_Ext_Vign_Document__c = url2;
        update vol1;

        audit1.MMPJ_Ext_Vign_Document__c = '';
        update audit1;

        con1.MMPJ_Ext_Vign_Document__c = '';
        update con1;

        doc1.MMPJ_Ext_Vign_Document__c = '';
        update doc1;

        ech1.MMPJ_Ext_Vign_Document__c = '';
        update ech1;

        fac1.MMPJ_Ext_Vign_Document__c = '';
        update fac1;

        vol1.MMPJ_Ext_Vign_Document__c = '';
        update vol1;
        
    }

    
}