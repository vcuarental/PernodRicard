@isTest
private class AME_project_cloud_Triggers_TEST {
    
   /* static testMethod void testIncidentAfterConfiguration() {
        BMCServiceDesk__SYSTemplate__c template = new BMCServiceDesk__SYSTemplate__c(
            Name = 'AME Demand Management Incident',
            BMCServiceDesk__templateFor__c = 'Incident'
        );
        insert template;
        BMCServiceDesk__SRM_RequestDefinition__c requestDefinition = new BMCServiceDesk__SRM_RequestDefinition__c(
            Name = 'AME New demand',
            BMCServiceDesk__serviceRequestTitle__c = 'AME New demand'
        );
        insert requestDefinition;
        BMCServiceDesk__Category__c kategory = new BMCServiceDesk__Category__c(
            Name='Incident Auto Create Ticket Category',
            BMCServiceDesk__AvailableForIncidents__c=true
        );
        insert kategory;
        List<BMCServiceDesk__Incident__c> incidents = new List<BMCServiceDesk__Incident__c> {
            new BMCServiceDesk__Incident__c(
                Summary__c = 'A. Incident That wil have a ticket Created',
                BMCServiceDesk__FKTemplate__c = template.Id,
                BMCServiceDesk__FKRequestDefinition__c = requestDefinition.Id,
                BMCServiceDesk__FKCategory__c = kategory.Id
            ),
            new BMCServiceDesk__Incident__c(
                Summary__c = 'B. Incident with no ticket  created',
                BMCServiceDesk__FKTemplate__c = template.Id
            )
        };
        insert incidents;
        incidents = refreshIncidents(incidents);
        System.assertEquals(2, incidents.size());
        System.assertEquals(1, incidents[0].Tickets__r.size());
        System.assertEquals(0, incidents[1].Tickets__r.size());
        
        incidents[1].BMCServiceDesk__FKRequestDefinition__c = requestDefinition.Id;
        incidents[1].BMCServiceDesk__FKCategory__c = kategory.Id;
        update incidents[1];
        incidents = refreshIncidents(incidents);
        System.assertEquals(2, incidents.size());
        System.assertEquals(1, incidents[0].Tickets__r.size());
        System.assertEquals(1, incidents[1].Tickets__r.size());
    }

    static testMethod void testTicketAfterConfiguration() {
        BMCServiceDesk__Status__c resolvedStatus = new BMCServiceDesk__Status__c(Name='RESOLVED', BMCServiceDesk__appliesToIncident__c = true, BMCServiceDesk__inactive__c = false);
        insert resolvedStatus;
        project_cloud.TestHelper helper = new project_cloud.TestHelper();
        project_cloud.TestHelper.ProjectPhaseTask ppt = new project_cloud.TestHelper.ProjectPhaseTask('Ticket Effort Project', new List<Integer> { 2 }, true);
        List<project_cloud__Ticket__c> tickets = new List<project_cloud__Ticket__c> {
            helper.newTicket('Ticket 1.', project_cloud__Ticket__c.project_cloud__Project__c, ppt.project.Id, false),
            helper.newTicket('Ticket 2.', project_cloud__Ticket__c.project_cloud__Project_Task__c, ppt.tasks[0].Id, false),
            helper.newTicket('Ticket 3.', project_cloud__Ticket__c.project_cloud__Project_Task__c, ppt.tasks[1].Id, false)
        };
        tickets[0].AME_project_cloud_Effort_in_man_days__c = 1.01;
        tickets[1].AME_project_cloud_Effort_in_man_days__c = 1.02;
        tickets[2].AME_project_cloud_Effort_in_man_days__c = 1.03;

        insert tickets;
        ppt.refresh(new Set<Schema.SObjectField> { project_cloud__Project__c.AME_project_cloud_Effort_in_man_days__c }, null, null, true);
        System.assertEquals(1.01 + 1.02 + 1.03, ppt.project.AME_project_cloud_Effort_in_man_days__c);
        tickets[2].AME_project_cloud_Effort_in_man_days__c = 200.03;

        update tickets;
        ppt.refresh(new Set<Schema.SObjectField> { project_cloud__Project__c.AME_project_cloud_Effort_in_man_days__c }, null, null, true);
        System.assertEquals(1.01 + 1.02 + 200.03, ppt.project.AME_project_cloud_Effort_in_man_days__c);

        delete tickets[2];
        ppt.refresh(new Set<Schema.SObjectField> { project_cloud__Project__c.AME_project_cloud_Effort_in_man_days__c }, null, null, true);
        System.assertEquals(1.01 + 1.02, ppt.project.AME_project_cloud_Effort_in_man_days__c);
        
        //Test incident update
        BMCServiceDesk__SYSTemplate__c template = new BMCServiceDesk__SYSTemplate__c(
            Name = 'AME Demand Management Incident',
            BMCServiceDesk__templateFor__c = 'Incident'
        );
        insert template;
        BMCServiceDesk__SRM_RequestDefinition__c requestDefinition = new BMCServiceDesk__SRM_RequestDefinition__c(
            Name = 'AME New demand',
            BMCServiceDesk__serviceRequestTitle__c = 'AME New demand'
        );
        insert requestDefinition;
        BMCServiceDesk__Category__c kategory = new BMCServiceDesk__Category__c(
            Name='Incident Auto Create Ticket Category',
            BMCServiceDesk__AvailableForIncidents__c=true
        );
        insert kategory;
        BMCServiceDesk__Incident__c incident = new BMCServiceDesk__Incident__c(
            Summary__c = 'A. Incident That wil have a ticket Created',
            BMCServiceDesk__FKTemplate__c = template.Id,
            BMCServiceDesk__FKRequestDefinition__c = requestDefinition.Id,
            BMCServiceDesk__FKCategory__c = kategory.Id
        );
        insert incident;
        project_cloud__Ticket__c ticket = [SELECT Id, Name, RecordTypeId, AME_project_cloud_Portfolio_Type__c FROM project_cloud__Ticket__c WHERE AME_project_cloud_Incident__c = :incident.Id LIMIT 1];
        ticket.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'project_cloud__Ticket__c' AND Name = 'Demand (Configuration)'].Id;
        ticket.project_cloud__Status__c = 'Closed';
        update ticket;
        
        incident = [
            SELECT
                Id,
                BMCServiceDesk__FKStatus__c,
                BMCServiceDesk__incidentResolution__c,
                BMCServiceDesk__ClosureCategory__c
                
            FROM
                BMCServiceDesk__Incident__c
            LIMIT 1];
        //Check that incident fields were updated correctly
        System.assert(incident.BMCServiceDesk__FKStatus__c == resolvedStatus.Id, 'Status not set correctly for the incident');
        System.assert(incident.BMCServiceDesk__incidentResolution__c == 'Completed as ' + ticket.AME_project_cloud_Portfolio_Type__c, 'Resolution not set correctly for the incident');
        System.assert(incident.BMCServiceDesk__ClosureCategory__c == 'Request Fullfilled', 'Closure Category not set correctly for the incident');
    }

    static testMethod void testProjectBudgetBeforeConfiguration() {
        insert (new BMCServiceDesk__Status__c(Name='RESOLVED'));
        project_cloud.TestHelper helper = new project_cloud.TestHelper();
        project_cloud__Project__c project = helper.newProject('Budget Project', true);
        AME_project_cloud_Project_Charter__c charter = newProjectCharter('Budget Charter', project.Id, true);
        AME_project_cloud_Project_Budget__c budget = new AME_project_cloud_Project_Budget__c(
            AME_project_cloud_Project_Charter__c = charter.Id
        );
        insert budget;
        budget = [
            SELECT
                Id,
                Name,
                AME_project_cloud_Project_Charter__c,
                AME_project_cloud_Project__c
            FROM
                AME_project_cloud_Project_Budget__c
            WHERE
                Id = :budget.Id];
        System.assertEquals(project.Id, budget.AME_project_cloud_Project__c);
        budget.AME_project_cloud_Project_Charter__c = null;
        update budget;
        budget = [
            SELECT
                Id,
                Name,
                AME_project_cloud_Project_Charter__c,
                AME_project_cloud_Project__c
            FROM
                AME_project_cloud_Project_Budget__c
            WHERE
                Id = :budget.Id];
        System.assertEquals(null, budget.AME_project_cloud_Project__c);
    }

    static testMethod void testSuccessCriteriaBeforeConfiguration() {
        insert (new BMCServiceDesk__Status__c(Name='RESOLVED'));
        project_cloud.TestHelper helper = new project_cloud.TestHelper();
        project_cloud__Project__c project = helper.newProject('Success Critera Project', true);
        AME_project_cloud_Project_Charter__c charter = newProjectCharter('Success Critera Charter', project.Id, true);
        AME_project_cloud_Success_Criteria__c criteria = new AME_project_cloud_Success_Criteria__c(
            AME_project_cloud_Project_Charter__c = charter.Id
        );
        insert criteria;
        criteria = [
            SELECT
                Id,
                Name,
                AME_project_cloud_Project_Charter__c,
                AME_project_cloud_Project__c
            FROM
                AME_project_cloud_Success_Criteria__c
            WHERE
                Id = :criteria.Id];
        System.assertEquals(project.Id, criteria.AME_project_cloud_Project__c);
        criteria.AME_project_cloud_Project_Charter__c = null;
        update criteria;
        criteria = [
            SELECT
                Id,
                Name,
                AME_project_cloud_Project_Charter__c,
                AME_project_cloud_Project__c
            FROM
                AME_project_cloud_Success_Criteria__c
            WHERE
                Id = :criteria.Id];
        System.assertEquals(null, criteria.AME_project_cloud_Project__c);
    }

    static testMethod void testTicketBeforeConfiguration() {
        insert (new BMCServiceDesk__Status__c(Name='RESOLVED'));
        project_cloud.TestHelper helper = new project_cloud.TestHelper();
        project_cloud__Project__c project = helper.newProject('Ticket Project', true);
        AME_project_cloud_Project_Charter__c charter = newProjectCharter('Ticket Charter', project.Id, true);
        project_cloud__Ticket__c ticket = helper.newTicket('Charter Ticket', project_cloud__Ticket__c.AME_project_cloud_Project_Charter__c, charter.Id, true);
        ticket = [
            SELECT
                Id,
                Name,
                AME_project_cloud_Project_Charter__c,
                project_cloud__Project__c
            FROM
                project_cloud__Ticket__c
            WHERE
                Id = :ticket.Id];
        System.assertEquals(project.Id, ticket.project_cloud__Project__c);
        ticket.AME_project_cloud_Project_Charter__c = null;
        update ticket;
        ticket = [
            SELECT
                Id,
                Name,
                AME_project_cloud_Project_Charter__c,
                project_cloud__Project__c
            FROM
                project_cloud__Ticket__c
            WHERE
                Id = :ticket.Id];
        System.assertEquals(null, ticket.project_cloud__Project__c);
    }
    
    static testMethod void testProjectPostConfiguration() {
        //Initial inserts
        BMCServiceDesk__Status__c resolvedStatus = new BMCServiceDesk__Status__c(Name='RESOLVED', BMCServiceDesk__appliesToIncident__c = true, BMCServiceDesk__inactive__c = false);
        insert resolvedStatus;
        BMCServiceDesk__SYSTemplate__c template = new BMCServiceDesk__SYSTemplate__c(
            Name = 'AME Demand Management Incident',
            BMCServiceDesk__templateFor__c = 'Incident'
        );
        insert template;
        BMCServiceDesk__SRM_RequestDefinition__c requestDefinition = new BMCServiceDesk__SRM_RequestDefinition__c(
            Name = 'AME New demand',
            BMCServiceDesk__serviceRequestTitle__c = 'AME New demand'
        );
        insert requestDefinition;
        BMCServiceDesk__Category__c kategory = new BMCServiceDesk__Category__c(
            Name='Incident Auto Create Ticket Category',
            BMCServiceDesk__AvailableForIncidents__c=true
        );
        insert kategory;
        BMCServiceDesk__Incident__c incident = new BMCServiceDesk__Incident__c(
            Summary__c = 'A. Incident That wil have a ticket Created',
            BMCServiceDesk__FKTemplate__c = template.Id,
            BMCServiceDesk__FKRequestDefinition__c = requestDefinition.Id,
            BMCServiceDesk__FKCategory__c = kategory.Id
        );
        insert incident;
        
        Id demandRType = [SELECT Id FROM RecordType WHERE SObjectType = 'project_cloud__Ticket__c' AND Name='Demand' LIMIT 1].Id;
        project_cloud.TestHelper helper = new project_cloud.TestHelper();
        
        //Project to be updated
        project_cloud__Project__c project = [SELECT Id, Name, project_cloud__Ticket__c FROM project_cloud__Project__c LIMIT 1];
        
        //Ticket this project was 'created' from
        project_cloud__Ticket__c parentTicket = [SELECT Id, RecordTypeId FROM project_cloud__Ticket__c WHERE AME_project_cloud_Incident__c = :incident.Id LIMIT 1];
        parentTicket.RecordTypeId = demandRType;
        update parentTicket;
        project.project_cloud__Ticket__c = parentTicket.Id;
        update project;
        
        //Another ticket related to project
        project_cloud__Ticket__c childTicket = helper.newTicket('Test Child Ticket', project_cloud__Ticket__c.project_cloud__Project__c, project.Id, true);
        childTicket.RecordTypeId = demandRType;
        update childTicket;
        
        //Update project status
        project.AME_project_cloud_Status__c = 'Completed';
        update project;
        
        //Check that child ticket has status updated correctly
        childTicket = [SELECT Id, project_cloud__Status__c FROM project_cloud__Ticket__c WHERE Id = :childTicket.Id LIMIT 1];
        System.assert(childTicket.project_cloud__Status__c == 'Closed', 'Ticket status should have changed to \'Closed\'');
        
        //Check that related incident (via parent ticket) is updated correctly
        incident = [
            SELECT
                Id,
                BMCServiceDesk__FKStatus__c,
                BMCServiceDesk__incidentResolution__c,
                BMCServiceDesk__ClosureCategory__c
                
            FROM
                BMCServiceDesk__Incident__c
            LIMIT 1];
        System.assert(incident.BMCServiceDesk__FKStatus__c == resolvedStatus.Id, 'Status not set correctly for the incident');
        System.assert(incident.BMCServiceDesk__incidentResolution__c == 'Completed as part of ' + project.Name, 'Resolution not set correctly for the incident');
        System.assert(incident.BMCServiceDesk__ClosureCategory__c == 'Request Fullfilled', 'Closure Category not set correctly for the incident');
    }


    private static AME_project_cloud_Project_Charter__c newProjectCharter(String name, Id projectId, Boolean isInsert) {
        AME_project_cloud_Project_Charter__c charter = new AME_project_cloud_Project_Charter__c(
            Name=name,
            AME_project_cloud_Project__c=projectId
        );
        if(isInsert) {
            insert charter;
        }
        return charter;
    }

    private static List<BMCServiceDesk__Incident__c> refreshIncidents(List<BMCServiceDesk__Incident__c> incidents) {
        incidents = [
            SELECT
                Id,
                Summary__c,
                BMCServiceDesk__FKTemplate__r.Name,
                BMCServiceDesk__FKRequestDefinition__r.Name,
                BMCServiceDesk__FKCategory__c,
                (
                    SELECT
                        Id,
                        Name
                    FROM
                        Tickets__r
                )
            FROM
                BMCServiceDesk__Incident__c
            WHERE
                Id IN :incidents
            ORDER BY
                Summary__c];
        return incidents;
    }*/
}