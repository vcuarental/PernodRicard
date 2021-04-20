@isTest
private class ESN_VFC14_BP_Display_TEST {
	
    static testMethod void myUnitTest() {
    	/* Create documents to test */
    	Folder myFolder = [SELECT Id FROM Folder WHERE DeveloperName = 'Embiez_13_Best_Practices' LIMIT 1];
    	
	    Document docPDF = TestFactory.createDocumentPDF('ESN_VFC14_BP_Display_TEST_Doc1', myFolder.Id);
	    insert docPDF;
	    
	    Document docImg = TestFactory.createDocumentImage('ESN_VFC14_BP_Display_TEST_Img1', myFolder.Id);
	    insert docImg;
    	
    	/* Create a set of Best practices */
    	ESN_Best_Practice__c bp1 = TestFactory.createBestPractices('ESN_VFC14_BP_Display_TEST_1', ''+docPDF.Id, ''+docImg.Id);
    	insert bp1;
    	ESN_Best_Practice__c bp2 = TestFactory.createBestPractices('ESN_VFC14_BP_Display_TEST_2', ''+docPDF.Id+';'+docImg.Id, ''+docImg.Id);
    	insert bp2;
    	ESN_Best_Practice__c bp3 = TestFactory.createBestPractices('ESN_VFC14_BP_Display_TEST_3', ''+docPDF.Id+';', ''+docImg.Id);
    	insert bp3;
    	ESN_Best_Practice__c bp4 = TestFactory.createBestPractices('ESN_VFC14_BP_Display_TEST_4', '', ''+docImg.Id);
    	insert bp4;
    	
        /* Create new instance of Visualforce Page */
        /* Test 1 : search category */
    	Pagereference vf1 = Page.ESN_VFP14_BP_Display;
    	vf1.getParameters().put('category', 'My test category');
    	vf1.getParameters().put('Id', bp1.Id);
    	Test.setCurrentPageReference(vf1);
		ApexPages.StandardController sc1 = new ApexPages.standardController(bp1);
        ESN_VFC14_BP_Display con1 = new ESN_VFC14_BP_Display(sc1);
        
        /* Test 2 : search sub-category */
    	Pagereference vf2 = Page.ESN_VFP14_BP_Display;
    	vf2.getParameters().put('subcategory', 'My test subcategory');
    	vf2.getParameters().put('Id', bp2.Id);
    	Test.setCurrentPageReference(vf2);
		ApexPages.StandardController sc2 = new ApexPages.standardController(bp2);
        ESN_VFC14_BP_Display con2 = new ESN_VFC14_BP_Display(sc2);
        
        /* Test 3 : search benefit */
    	Pagereference vf3 = Page.ESN_VFP14_BP_Display;
    	vf3.getParameters().put('benefit', 'My cool benefit 1');
    	vf3.getParameters().put('Id', bp3.Id);
    	Test.setCurrentPageReference(vf3);
		ApexPages.StandardController sc3 = new ApexPages.standardController(bp3);
        ESN_VFC14_BP_Display con3 = new ESN_VFC14_BP_Display(sc3);
        
        /* Test 4 : search free search */
    	Pagereference vf4 = Page.ESN_VFP14_BP_Display;
    	vf4.getParameters().put('search', 'test');
    	vf4.getParameters().put('Id', bp4.Id);
    	Test.setCurrentPageReference(vf4);
		ApexPages.StandardController sc4 = new ApexPages.standardController(bp4);
        ESN_VFC14_BP_Display con4 = new ESN_VFC14_BP_Display(sc4);
        
        /* Test 5 : no search */
    	Pagereference vf5 = Page.ESN_VFP14_BP_Display;
    	vf5.getParameters().put('Id', bp4.Id);
    	Test.setCurrentPageReference(vf5);
		ApexPages.StandardController sc5 = new ApexPages.standardController(bp4);
        ESN_VFC14_BP_Display con5 = new ESN_VFC14_BP_Display(sc5);
    }
}