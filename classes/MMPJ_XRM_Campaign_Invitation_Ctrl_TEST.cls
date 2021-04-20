@isTest
public class MMPJ_XRM_Campaign_Invitation_Ctrl_TEST {
    static testmethod void campagneSegmentationTest(){
    	Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
		MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert societe;

		Account accCognac = new Account(Name='Test');
		insert accCognac;

		Id rtCon = [select id from RecordType where SObjectType='Contact' and DeveloperName='MMPJ_Ext_Vign_Contact' LIMIT 1].Id;

		Contact con1 = new Contact(LastName='Test1',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
		Contact con2 = new Contact(LastName='Test2',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
		Contact con3 = new Contact(LastName='Test3',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Champagne',RecordTYpeId=rtCon);
		insert new List<Contact>{con1,con2,con3};

		MMPJ_Ext_Vign_Societe_Contact__c sCon1 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con1.id,MMPJ_Ext_Vign_Societe__c=societe.Id,MMPJ_Ext_Vign_Fonction__c='GERANT');
		MMPJ_Ext_Vign_Societe_Contact__c sCon2 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con2.id,MMPJ_Ext_Vign_Societe__c=societe.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sCon3 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con3.id,MMPJ_Ext_Vign_Societe__c=societe.Id);
		insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{scon1,scon2,scon3};

		Id rtCamp = [select id from RecordType where SObjectType='Campaign' and DeveloperName='MMPJ_Ext_Vign_Campaign' LIMIT 1].Id;

		Campaign camp = new Campaign(Name='Test',RecordTYpeId=rtCamp);
		insert camp;

		PageReference pageRef1 = Page.MMPJ_XRM_CampaignInvitation;
		pageRef1.getParameters().put('id',camp.Id);
        Test.setCurrentPage(pageRef1);

        MMPJ_XRM_Campaign_Invitation_Ctrl controller1 = new MMPJ_XRM_Campaign_Invitation_Ctrl();
        controller1.insertMembers();

		Test.startTest();

		PageReference pageRef2 = Page.MMPJ_XRM_CampaignInvitation;
		pageRef2.getParameters().put('id',camp.Id);
		pageRef2.getParameters().put('segmentation','Cognac');
        Test.setCurrentPage(pageRef2);

        MMPJ_XRM_Campaign_Invitation_Ctrl controller2 = new MMPJ_XRM_Campaign_Invitation_Ctrl();
        controller2.insertMembers();
        controller2.insertMembers();

		Test.stopTest();
    }
}