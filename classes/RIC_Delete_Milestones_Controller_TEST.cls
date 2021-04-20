@isTest
private class RIC_Delete_Milestones_Controller_TEST {
	
    private static testmethod void testDeleteMilestones() {
        Test.startTest();
            
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        p1.RIC_Coordinateur__c = UserInfo.getUserId();
        insert p1;
        
        Milestone1_Milestone__c b = new Milestone1_Milestone__c(); //Create new Milestone for Project p1
        b.Name = 'Test Milestone';
        b.Project__c = p1.Id;
        insert b;
        
        List<Milestone1_Milestone__c> listMilestones = new List<Milestone1_Milestone__c> {b};
        ApexPages.StandardSetController std = new ApexPages.StandardSetController(listMilestones);
        
        PageReference pageRef = Page.RIC_Delete_Milestones;
		Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', p1.Id);
		RIC_Delete_Milestones_Controller controller = new RIC_Delete_Milestones_Controller(std);
        
        controller.deleteMilestones();
        controller.retour();
        Test.stopTest();
    }
}