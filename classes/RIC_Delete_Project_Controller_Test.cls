@isTest
private class RIC_Delete_Project_Controller_Test {
	
    private static testMethod void testProjectDelete() {
        Test.startTest();
            
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        p1.RIC_Coordinateur__c = UserInfo.getUserId();
        insert p1;
        
        p1.RIC_Coordinateur__c = UserInfo.getUserId();
        update p1;
        
        Milestone1_Milestone__c b = new Milestone1_Milestone__c(); //Create new Milestone for Project p1
        b.Name = 'Test Milestone';
        b.Project__c = p1.Id;
        insert b;
        
        ApexPages.StandardController std = new ApexPages.StandardController(p1);
        RIC_Delete_Project_Controller controller = new RIC_Delete_Project_Controller(std);
        controller.deleteProject();
        controller.retour();
        Test.stopTest();
        
    }
    
    private static testMethod void testErrorProjectDelete() {
        Test.startTest();
            
        Milestone1_Project__c p1 = Milestone1_Test_Utility.sampleProjectActive('Json');
        insert p1;
        
        Milestone1_Milestone__c b = new Milestone1_Milestone__c(); //Create new Milestone for Project p1
        b.Name = 'Test Milestone';
        b.Project__c = p1.Id;
        insert b;
        
        ApexPages.StandardController std = new ApexPages.StandardController(p1);
        RIC_Delete_Project_Controller controller = new RIC_Delete_Project_Controller(std);
        controller.deleteProject();
        Test.stopTest();
        
    }
}