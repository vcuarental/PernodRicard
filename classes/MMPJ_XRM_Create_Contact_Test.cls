@isTest
public class MMPJ_XRM_Create_Contact_Test {
    static testMethod void testMyController(){
        Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
        MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Champagne',RecordTypeId=rtAcc);
        insert societe;

        Account accCHamp = new Account(Name='Test');
        insert accCHamp;
        Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;
        Contact contact = new Contact(AccountId=accCHamp.Id,RecordTypeId=rtCon, LastName='Person2', FirstName='TATA', MMPJ_Ext_Vign_Contact_Segmentation__c='Champagne');
        insert contact;
        
        MMPJ_Ext_Vign_Societe_Contact__c societeContact = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Societe__c=societe.Id, MMPJ_Ext_Vign_Contact__c=contact.Id);
        insert societeContact;

        Test.startTest();
        PageReference pageRef = Page.MMPJ_XRM_Create_contact;
        pageRef.getParameters().put('Idsociete', String.valueOf(societe.Id));
        Test.setCurrentPage(pageRef);
        Contact c = new Contact();
        MMPJ_XRM_Create_contact_ctrl controller = new MMPJ_XRM_Create_contact_ctrl(new ApexPages.StandardController(c));
        controller.con.LastName = 'Test';
        controller.con.FirstName = 'test';
        //System.debug('###'+pageRef+'###');
        controller.DoSaveToContact();
        controller.DoSaveAndReturn();
        controller.DoAnnuler();
        Test.stopTest();
    }
}