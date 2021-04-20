@isTest
private class GVP_ObjectiveExpiredControllerTest {

    private static @isTest void objectiveTest() {
        gvp__Account_Objective__c obj = new gvp__Account_Objective__c(
            Closed_By_Date__c = Date.today().addDays(-1),
            gvp__Status__c = 'Not Started',
            gvp__Custom_3__c = 'CorpObjectives'
        );
        List<gvp__Account_Objective__c> results = GVP_ObjectiveExpiredController.checkObjectives(
            new List<gvp__Account_Objective__c> { obj }
        );
        System.assertEquals('Closed - Time Expired', results[0].gvp__Status__c, 'Status Set');
    }
    
    private static @isTest void getCodeCoverage() {
        GVP_ObjectiveExpiredController.getObjectives();
        GVP_ObjectiveExpiredController.updateObjectives(new List<gvp__Account_Objective__c>());
        GVP_ObjectiveExpiredController.doExecute();
    }   
}