@isTest
public with sharing class ESN_VFC16_BP_Results_TEST {

	static testMethod void myUnitTest() {
    	/* Create documents to test */
    	Folder myFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'Embiez_13_Best_Practices' LIMIT 1];
    	
	    Document docPDF = TestFactory.createDocumentPDF('ESN_VFC14_BP_Display_TEST_Doc1', myFolder.Id);
	    insert docPDF;
	    
	    Document docImg = TestFactory.createDocumentImage('ESN_VFC14_BP_Display_TEST_Img1', myFolder.Id);
	    insert docImg;
    	
    	/* Create a set of Best practices */
    	ESN_Best_Practice__c bp1 = TestFactory.createBestPractices('ESN_VFC16_BP_Results_TEST_1', ''+docPDF.Id, ''+docImg.Id);
    	bp1.ESN_BP_Subcategory__c = '';
    	insert bp1;
    	ESN_Best_Practice__c bp2 = TestFactory.createBestPractices('ESN_VFC16_BP_Results_TEST_2', ''+docPDF.Id+';'+docImg.Id, ''+docImg.Id);
    	insert bp2;
    	ESN_Best_Practice__c bp3 = TestFactory.createBestPractices('ESN_VFC16_BP_Results_TEST_3', ''+docPDF.Id+';', ''+docImg.Id);
    	insert bp3;
    	ESN_Best_Practice__c bp4 = TestFactory.createBestPractices('ESN_VFC16_BP_Results_TEST_4', '', ''+docImg.Id);
    	insert bp4;
    	
        /* Create new instance of Visualforce Page */
        /* Test 1 : search category */
    	Pagereference vf1 = Page.ESN_VFP16_BP_Results;
    	vf1.getParameters().put('category', 'My test category');
    	Test.setCurrentPageReference(vf1);
        ESN_VFC16_BP_Results con1 = new ESN_VFC16_BP_Results();
        con1.searchFree = 'test';
        con1.clearSearch();
        con1.searchFree = 'test';
        con1.submitSearch();
        
        /* Test 2 : search sub-category */
    	Pagereference vf2 = Page.ESN_VFP16_BP_Results;
    	vf2.getParameters().put('subcategory', 'My test subcategory');
    	Test.setCurrentPageReference(vf2);
        ESN_VFC16_BP_Results con2 = new ESN_VFC16_BP_Results();
        con2.submitSearch();
        
        /* Test 3 : search benefit */
    	Pagereference vf3 = Page.ESN_VFP16_BP_Results;
    	vf3.getParameters().put('benefit', 'My cool benefit 1');
    	Test.setCurrentPageReference(vf3);
        ESN_VFC16_BP_Results con3 = new ESN_VFC16_BP_Results();
        
        /* Test 4 : search free search */
    	Pagereference vf4 = Page.ESN_VFP16_BP_Results;
    	vf4.getParameters().put('search', 'super testeur');
    	Test.setCurrentPageReference(vf4);
        ESN_VFC16_BP_Results con4 = new ESN_VFC16_BP_Results();
        
        /* Test 5 : no search */
    	Pagereference vf5 = Page.ESN_VFP16_BP_Results;
    	Test.setCurrentPageReference(vf5);
        ESN_VFC16_BP_Results con5 = new ESN_VFC16_BP_Results();
    }
}