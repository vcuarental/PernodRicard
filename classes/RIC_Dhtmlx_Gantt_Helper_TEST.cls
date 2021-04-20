@isTest
private class RIC_Dhtmlx_Gantt_Helper_TEST {
	
    static testMethod void testController() {
        Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Basic Sample For Test' + DateTime.now().getTime());
        insert proj;
        
        ApexPages.StandardController stc = new ApexPages.StandardController(proj);
        RIC_Dhtmlx_Gantt_Helper cont = new RIC_Dhtmlx_Gantt_Helper(stc);
        System.assert(cont.myId != null);
    }
}