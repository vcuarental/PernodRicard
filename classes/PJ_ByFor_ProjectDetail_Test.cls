@isTest
public class PJ_ByFor_ProjectDetail_Test {
    
    static testmethod void PJ_ByFor_ProjectDetail_Test1(){
        
        Test.startTest();
        
        	PJ_ByFor_Experience__c experience = new PJ_ByFor_Experience__c();
        	PageReference pageRef1 = Page.PJ_ByFor_ProjectDetail;
			Test.setCurrentPage(pageRef1);
        	PJ_ByFor_ProjectDetail myPage = new PJ_ByFor_ProjectDetail(new ApexPages.StandardController(experience));
        	myPage.getExperienceHistory();
 
        
      Test.stopTest();   
    }

}