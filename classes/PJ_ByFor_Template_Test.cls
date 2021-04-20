@isTest
public class PJ_ByFor_Template_Test {
	
            static testmethod void PJ_ByFor_Template_Test1 () {

        
       Test.startTest();
    
            PageReference pageRef1 = Page.PJ_ByFor_Template;
			Test.setCurrentPage(pageRef1);
        	PJ_ByFor_Template myPage = new PJ_ByFor_Template();
            myPage.getIsAdmin();
    		myPage.language='toto';
    
      	Test.stopTest(); 
        
     }
}