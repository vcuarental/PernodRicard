@isTest
public class MMPJ_XRM_Segmentation_Controller_TEST {
	static testmethod void test_method() {

		Id rtAcc = [select id from RecordType where SObjectType='MMPJ_Ext_Vign_Societe__c' and DeveloperName='MMPJ_Ext_Vign_Viticulteur' LIMIT 1].Id;
		
		MMPJ_Ext_Vign_Societe__c top1 = new MMPJ_Ext_Vign_Societe__c(Name='Top1',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert top1;


		MMPJ_Ext_Vign_Societe__c societe = new MMPJ_Ext_Vign_Societe__c(Name='Test',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc,MMPJ_XRM_Societe_Chapeau__c=top1.Id);
		insert societe;
		MMPJ_Ext_Vign_Societe__c societe2 = new MMPJ_Ext_Vign_Societe__c(Name='Test2',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert societe2;

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
		MMPJ_Ext_Vign_Societe_Contact__c sCon4 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=con1.id,MMPJ_Ext_Vign_Societe__c=societe2.Id);
		insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{scon1,scon2,scon3,scon4};


		MMPJ_Ext_Vign_Societe__c accLie1 = new MMPJ_Ext_Vign_Societe__c(Name='Lie1',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert accLie1;

		MMPJ_Ext_Vign_Societe__c accLie2 = new MMPJ_Ext_Vign_Societe__c(Name='Lie2',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc);
		insert accLie2;

		Contact conLie1 = new Contact(LastName='Test1',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
		Contact conLie2 = new Contact(LastName='Test2',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
		insert new List<Contact>{conLie1,conLie2};

		MMPJ_Ext_Vign_Societe_Contact__c sconLie1 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=conLie1.id,MMPJ_Ext_Vign_Societe__c=accLie1.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sconLie2 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=conLie2.id,MMPJ_Ext_Vign_Societe__c=accLie2.Id);
		insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{sconLie1,sconLie2};

		MMPJ_XRM_RelationSociete__c relLie1 = new MMPJ_XRM_RelationSociete__c(MMPJ_XRM_Livreur__c=societe.Id,MMPJ_XRM_Societe_liee__c=accLie1.Id);
		MMPJ_XRM_RelationSociete__c relLie2 = new MMPJ_XRM_RelationSociete__c(MMPJ_XRM_Livreur__c=accLie2.Id,MMPJ_XRM_Societe_liee__c=societe2.Id);
		insert new List<MMPJ_XRM_RelationSociete__c>{relLie1,relLie2};


		

		MMPJ_Ext_Vign_Societe__c top2 = new MMPJ_Ext_Vign_Societe__c(Name='Top2',MMPJ_Ext_Vign_Societe_Segmentation__c='Cognac',RecordTypeId=rtAcc,MMPJ_XRM_Societe_Chapeau__c=societe.Id);
		insert top2;

		Contact conTop1 = new Contact(LastName='Test2',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
		Contact conTop2 = new Contact(LastName='Test3',AccountId=accCognac.Id,MMPJ_Ext_Vign_Contact_Segmentation__c='Cognac',RecordTYpeId=rtCon);
		insert new List<Contact>{conTop1,conTop2};

		MMPJ_Ext_Vign_Societe_Contact__c sconTop1 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=conTop1.id,MMPJ_Ext_Vign_Societe__c=top1.Id);
		MMPJ_Ext_Vign_Societe_Contact__c sconTop2 = new MMPJ_Ext_Vign_Societe_Contact__c(MMPJ_Ext_Vign_Contact__c=conTop2.id,MMPJ_Ext_Vign_Societe__c=top2.Id);
		insert new List<MMPJ_Ext_Vign_Societe_Contact__c>{sconTop1,sconTop2};


		Id rt = [select id from RecordType where SObjectType='Campaign' and DeveloperName='MMPJ_Ext_Vign_Campaign' LIMIT 1].Id;
		Campaign camp = new Campaign(Name='Test 1',RecordTypeId=rt);
		insert camp;
		CampaignMember campM1 = new CampaignMember(ContactId=con1.Id,CampaignId=camp.Id,Status='Sent');
		CampaignMember campM3 = new CampaignMember(ContactId=con3.Id,CampaignId=camp.Id,Status='Sent');
		insert new List<CampaignMember>{campM1,campM3};

		MMPJ_Ext_Vign_Contrat__c contrat1 = new MMPJ_Ext_Vign_Contrat__c(Name='12445',MMPJ_Ext_Vign_Livreur__c=societe.Id,MMPJ_Ext_Vign_Contrat_Segmentation__c='Cognac',MMPJ_Ext_Vign_Cru__c='FB');
		insert contrat1;


		Campaign camp2 = new Campaign(Name='Test Segmentation',RecordTypeId=rt);
		insert camp2;
		CampaignMember campM21 = new CampaignMember(ContactId=con2.Id,CampaignId=camp2.Id,Status='Sent');
		insert campM21;

		PageReference pageRef1 = Page.MMPJ_XRM_Segmentation;
        Test.setCurrentPage(pageRef1);
        //Add parameters to page URL

	
        Test.startTest();

        MMPJ_XRM_Segmentation_Controller myPage = new MMPJ_XRM_Segmentation_Controller(new ApexPages.StandardController(camp2)); 
		myPage.addSearchCriterias();
		myPage.searchCriteriasDeleted = 0;
		myPage.removeSearchCriterias();
		myPage.searchCriteriasModified = 0;
		myPage.lookForSearchInput();
		mypage.reload();
		myPage.addSearchCriterias();
		myPage.addSearchCriterias();
		myPage.addSearchCriterias();
		myPage.addSearchCriterias();
		myPage.addSearchCriterias();
		myPage.addSearchCriterias();
		myPage.searchCriterias[0].selectedCritere = '001';
		myPage.searchCriterias[0].selectedOperateur = 'NotEqual';
		myPage.searchCriterias[0].searchText = 'Champagne';
		myPage.searchCriterias[1].selectedCritere = '101';
		myPage.searchCriterias[1].selectedOperateur = 'StartWith';
		myPage.searchCriterias[1].searchText = 'Test';
		myPage.searchCriterias[2].selectedCritere = '201';
		myPage.searchCriterias[2].selectedOperateur = 'Equal';
		myPage.searchCriterias[2].searchText = 'FB';
		myPage.searchCriterias[3].selectedCritere = '301';
		myPage.searchCriterias[3].selectedOperateur = 'Equal';
		myPage.searchCriterias[3].searchText = 'GERANT';
		myPage.searchCriterias[4].selectedCritere = '402';
		myPage.searchCriterias[4].selectedOperateur = 'Equal';
		myPage.searchCriterias[4].searchText = 'Test 1';
		myPage.searchCriterias[5].selectedCritere = '501';
		myPage.searchCriterias[5].selectedOperateur = 'Equal';
		myPage.searchCriterias[5].searchText = 'Sent';
		myPage.querySubAccount = true;
		myPage.queryTopAccount = true;
		myPage.search();
		mypage.orderField = 'FirstName';
		mypage.reorder();
		myPage.gethasPrevious();
		myPage.gethasnext();
		myPage.globalCheck = false;
		mypage.getTotalContacts();
		mypage.checkAll();
		myPage.addToCampaign();

		Test.stopTest();
	

		MMPJ_XRM_Segmentation_Controller myPage2 = new MMPJ_XRM_Segmentation_Controller(new ApexPages.StandardController(camp2));
		myPage2.seeCampaignMembers();
		mypage2.getContextString();
		myPage2.contacts[0].isSelected = false;
		
		}
	
}