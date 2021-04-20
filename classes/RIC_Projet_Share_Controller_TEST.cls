@isTest
private class RIC_Projet_Share_Controller_TEST {
	
    private static testMethod void myTestMethod() {
        Test.startTest();
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        ApexPages.StandardController std = new ApexPages.StandardController(p1);
        RIC_Projet_Share_Controller controller = new RIC_Projet_Share_Controller(std);
        controller.redirectToSharingPage();
        controller.retour();
        Test.stopTest();
    }
}