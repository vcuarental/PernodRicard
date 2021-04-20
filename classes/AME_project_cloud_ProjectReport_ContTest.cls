@isTest
public class AME_project_cloud_ProjectReport_ContTest {
    static testMethod void testProjectReportCreation() {
        insert (new BMCServiceDesk__Status__c(Name='RESOLVED'));
        project_cloud.TestHelper helper = new project_cloud.TestHelper();
        project_cloud__Project__c project = [SELECT Id, Name, project_cloud__Ticket__c FROM project_cloud__Project__c LIMIT 1];
        project_cloud__Ticket__c ticket = helper.newTicket('Test Ticket', project_cloud__Ticket__c.project_cloud__Project__c, project.Id, false);
        insert ticket;
        AME_project_cloud_Project_Charter__c charter = new AME_project_cloud_Project_Charter__c(Name='Test Charter', AME_project_cloud_Project__c = project.Id, AME_project_cloud_Strat_Classification__c = 'Execute the business');
        insert charter;
        project.project_cloud__Ticket__c = ticket.Id;
        update project;
        System.debug([SELECT Id, Name FROM project_cloud__Ticket__c]);
        System.debug([SELECT Id, Name FROM project_cloud__Project__c]);
        
        AME_project_cloud_ProjectReport_Cont controller = new AME_project_cloud_ProjectReport_Cont();
        System.assert(controller.projects.size() == 1, 'A single project should have been created');
        System.assert(controller.charters.size() == 1, 'A single charter should be mapped to the single project');
        System.assert(controller.areasAffected.size() == 1, 'A single \'Affected Area\' should be mapped to the single project');
        System.debug(controller.charters.get(project.Id));
        System.assert(controller.charters.get(project.Id) == 'Execute the business', 'Charter classification set incorrectly');
        System.assert(controller.areasAffected.get(project.Id) == '', 'Affected Areas not formatted correctly');
        
        delete charter;
        ticket.AME_project_cloud_Business_Area_Affected__c = 'Finance;Marketing';
        update ticket;
        controller = new AME_project_cloud_ProjectReport_Cont();
        System.assert(controller.projects.size() == 1, 'A single project should have been created');
        System.assert(controller.charters.size() == 1, 'A single charter should be mapped to the single project');
        System.assert(controller.areasAffected.size() == 1, 'A single \'Affected Area\' should be mapped to the single project');
        System.assert(controller.charters.get(project.Id) == '', 'Charter classification set incorrectly');
        System.assert(controller.areasAffected.get(project.Id) == 'Finance,\nMarketing', 'Affected Areas not formatted correctly');
    }
}