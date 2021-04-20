@isTest
public class MMPJ_XRM_Export_Excel_Controller_TEST {
    static testmethod void exportExcelTest(){
      Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
    MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
    MMPJ_Ext_Vign_Societe__c societe2 = new MMPJ_Ext_Vign_Societe__c(Name='Test2',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
    MMPJ_Ext_Vign_Societe__c societe3 = new MMPJ_Ext_Vign_Societe__c(Name='Test3',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
    insert new List<MMPJ_Ext_Vign_Societe__c>{societe,societe2,societe3};

    Account accCognac = new Account(Name='Test');
    insert accCognac;

    Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;

    Contact con1 = new Contact(LastName='Test1',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
    Contact con2 = new Contact(LastName='Test2',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
    Contact con3 = new Contact(LastName='Test3',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
    insert new List<Contact>{con1,con2,con3};

    MMPJ_Ext_Vign_Societe_Contact__c sCon1 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con1.id,MMPJ_Ext_Vign_Societe__c=societe.Id,MMPJ_Ext_Vign_Fonction__c='GERANT');
    MMPJ_Ext_Vign_Societe_Contact__c sCon2 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con2.id,MMPJ_Ext_Vign_Societe__c=societe.Id);
    MMPJ_Ext_Vign_Societe_Contact__c sCon3 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con3.id,MMPJ_Ext_Vign_Societe__c=societe.Id);
    insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{scon1,scon2,scon3};

    MMPJ_XRM_RelationSociete__c relLie1 = new MMPJ_XRM_RelationSociete__c(MMPJ_XRM_Livreur__c=societe.Id,MMPJ_XRM_Societe_liee__c=societe3.Id);
    MMPJ_XRM_RelationSociete__c relLie2 = new MMPJ_XRM_RelationSociete__c(MMPJ_XRM_Livreur__c=societe.Id,MMPJ_XRM_Societe_liee__c=societe2.Id);
    insert new List<MMPJ_XRM_RelationSociete__c>{relLie1,relLie2};

    String params = '0|001|Equal|Test';
    
    Test.startTest();

    PageReference pageRef1 = Page.MMPJ_XRM_Export_Excel;
    
    pageRef1.getParameters().put('search0',params);
    pageRef1.getParameters().put('querySubAccount','false');
    pageRef1.getParameters().put('queryTopAccount','false');
        Test.setCurrentPage(pageRef1);

        MMPJ_XRM_Export_Excel_Controller controller = new MMPJ_XRM_Export_Excel_Controller();

    Test.stopTest();
    }
}