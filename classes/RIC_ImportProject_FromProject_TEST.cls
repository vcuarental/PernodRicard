@isTest
private class RIC_ImportProject_FromProject_TEST {

    private static testMethod void controllerTest() {
        
        Test.startTest();
            
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        p1.RIC_Coordinateur__c = UserInfo.getUserId();
        insert p1;
        
        PageReference pageRef = Page.RIC_ImportProject_FromProject;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', p1.Id);
        ApexPages.StandardController std = new ApexPages.StandardController(p1);
		RIC_ImportProject_FromProject_Controller controller = new RIC_ImportProject_FromProject_Controller(std);
        controller.currentRecordId = p1.Id;
        controller.search();
        controller.choose();
        controller.clear();
        controller.exportImport();
        
        Test.stopTest();
    }
}