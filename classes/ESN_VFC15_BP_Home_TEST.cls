@isTest
public with sharing class ESN_VFC15_BP_Home_TEST {
	
	static testMethod void myUnitTest() {
    	/* Create documents to test */
    	Folder myFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'Embiez_13_Best_Practices' LIMIT 1];
    	
	    Document docPDF = TestFactory.createDocumentPDF('ESN_VFC14_BP_Display_TEST_Doc1', myFolder.Id);
	    insert docPDF;
	    
	    Document docImg = TestFactory.createDocumentImage('ESN_VFC14_BP_Display_TEST_Img1', myFolder.Id);
	    insert docImg;
    	
    	/* Create a set of Best practices */
    	ESN_Best_Practice__c bp1 = TestFactory.createBestPractices('ESN_VFC15_BP_Home_TEST_1', ''+docPDF.Id, ''+docImg.Id);
    	bp1.ESN_BP_Subcategory__c = '';
    	insert bp1;
    	ESN_Best_Practice__c bp2 = TestFactory.createBestPractices('ESN_VFC15_BP_Home_TEST_2', ''+docPDF.Id+';'+docImg.Id, ''+docImg.Id);
    	insert bp2;
    	ESN_Best_Practice__c bp3 = TestFactory.createBestPractices('ESN_VFC15_BP_Home_TEST_3', ''+docPDF.Id+';', ''+docImg.Id);
    	insert bp3;
    	ESN_Best_Practice__c bp4 = TestFactory.createBestPractices('ESN_VFC15_BP_Home_TEST_4', '', ''+docImg.Id);
    	insert bp4;
    	
        /* Create new instance of Visualforce Page */
        /* Test 1 : search category */
    	Pagereference vf1 = Page.ESN_VFP15_BP_Home;
    	Test.setCurrentPageReference(vf1);
		ApexPages.StandardController sc1 = new ApexPages.standardController(new ESN_Best_Practice__c());
        ESN_VFC15_BP_Home con1 = new ESN_VFC15_BP_Home(sc1);
        con1.buildBenefitsList();
        con1.freeSearch = 'test';
        con1.clearSearch();
        con1.freeSearch = 'test';
        con1.submitSearch();
        
        /* Test 2 : search sub-category */
    	Pagereference vf2 = Page.ESN_VFP15_BP_Home;
    	Test.setCurrentPageReference(vf2);
		ApexPages.StandardController sc2 = new ApexPages.standardController(new ESN_Best_Practice__c());
        ESN_VFC15_BP_Home con2 = new ESN_VFC15_BP_Home(sc2);
        con2.buildBenefitsList();
        con2.submitSearch();
    }
}