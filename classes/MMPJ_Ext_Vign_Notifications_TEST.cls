@isTest
public class MMPJ_Ext_Vign_Notifications_TEST {
    static testmethod void test_method() {
        Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
        
        MMPJ_Ext_Vign_Societe__c acc1 = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
        insert acc1;
        MMPJ_Ext_Vign_Societe__c acc2 = new MMPJ_Ext_Vign_Societe__c(Name='Test2',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
        insert acc2;

        Account accCognac = new Account(Name='Test');
        insert accCognac;

        Contact con1 = new Contact(LastName='Test1',AccountId=accCognac.Id);
        insert con1;
        Contact con2 = new Contact(LastName='Test2',AccountId=accCognac.Id);
        insert con2;
        Contact con3 = new Contact(LastName='Test3',AccountId=accCognac.Id);
        insert con3;

        Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;
        try {
            //Si les manuals steps de déploiement n'ont pas été réalisé, MMPJ_Ext_Vign_ContactBeforeInsert risque de planter
            Contact con4 = new Contact(LastName='Test4',MMPJ_Ext_Vign_NUMERO_LIEN__c='999444',RecordTYpeId=rtCon);
            Contact con5 = new Contact(LastName='Test4',MMPJ_Ext_Vign_Id_Apport__c='666444',RecordTYpeId=rtCon);
            insert con4;
            insert con5;
        } catch(Exception ex) {}

        MMPJ_Ext_Vign_Societe_Contact__c sCon1 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con1.id,MMPJ_Ext_Vign_Societe__c=acc1.Id);
        MMPJ_Ext_Vign_Societe_Contact__c sCon2 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con2.id,MMPJ_Ext_Vign_Societe__c=acc1.Id);
        MMPJ_Ext_Vign_Societe_Contact__c sCon3 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con3.id,MMPJ_Ext_Vign_Societe__c=acc2.Id, MMPJ_Ext_Vign_Contact_Principal__c=true);

        insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{scon1,scon2,scon3};

        MMPJ_Ext_Vign_Audit__c audit1 = new MMPJ_Ext_Vign_Audit__c(Name='12445',MMPJ_Ext_Vign_Livreur__c=acc1.Id);
        MMPJ_Ext_Vign_Audit__c audit2 = new MMPJ_Ext_Vign_Audit__c(Name='3455',MMPJ_Ext_Vign_Livreur__c=acc2.Id);
        insert new List<MMPJ_Ext_Vign_Audit__c>{audit1,audit2};

        MMPJ_Ext_Vign_Documents_Fournis__c doc1 = new MMPJ_Ext_Vign_Documents_Fournis__c(MMPJ_Ext_Vign_Livreur__c=acc1.Id,MMPJ_Ext_Vign_Type__c = 'Brouillon de déclaration de récolte');
        MMPJ_Ext_Vign_Documents_Fournis__c doc2 = new MMPJ_Ext_Vign_Documents_Fournis__c(MMPJ_Ext_Vign_Livreur__c=acc2.Id,MMPJ_Ext_Vign_Type__c = 'Brouillon de déclaration de récolte');
        insert new List<MMPJ_Ext_Vign_Documents_Fournis__c>{doc1,doc2};

        MMPJ_Ext_Vign_Echantillon__c ech1 = new MMPJ_Ext_Vign_Echantillon__c(Name='12445',MMPJ_Ext_Vign_Livreur__c=acc1.Id);
        MMPJ_Ext_Vign_Echantillon__c ech2 = new MMPJ_Ext_Vign_Echantillon__c(Name='3455',MMPJ_Ext_Vign_Livreur__c=acc2.Id);
        insert new List<MMPJ_Ext_Vign_Echantillon__c>{ech1,ech2};

        MMPJ_Ext_Vign_Facture__c fac1 = new MMPJ_Ext_Vign_Facture__c(Name='12445',MMPJ_Ext_Vign_Societe__c=acc1.Id);
        MMPJ_Ext_Vign_Facture__c fac2 = new MMPJ_Ext_Vign_Facture__c(Name='3455',MMPJ_Ext_Vign_Societe__c=acc2.Id);
        insert new List<MMPJ_Ext_Vign_Facture__c>{fac1,fac2};

        MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c vol1 = new MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c(MMPJ_Ext_Vign_Livreur__c=acc1.Id);
        MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c vol2 = new MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c(MMPJ_Ext_Vign_Livreur__c=acc2.Id);
        insert new List<MMPJ_Ext_Vign_Volume_en_BF_mis_en_stock__c>{vol1,vol2};

        Id rt = [select id from RecordType where SObjectType='Campaign' and DeveloperName='MMPJ_Ext_Vign_Campaign' LIMIT 1].Id;
        Campaign camp = new Campaign(Name='Test',RecordTypeId=rt);
        insert camp;

        CampaignMember campM1 = new CampaignMember(ContactId=con1.Id,CampaignId=camp.Id,Status='Sent');
        CampaignMember campM3 = new CampaignMember(ContactId=con3.Id,CampaignId=camp.Id,Status='Sent');
        insert new List<CampaignMember>{campM1,campM3};
        
    }
}