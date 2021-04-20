public with sharing class CCPE_SiteExtension{

    private List<String> recordTypeRisks = new List<String>{'Risks'};
    
    private List<String> recordTypeIssues = new List<String>{'Project Issues'};
    
    private ApexPages.standardController controller;

    public CCPE_SiteExtension(ApexPages.standardController controller){this.controller = controller;}

    public List<project_cloud__Project_Task__c> getProjectTasks(){String query = 'SELECT ';

    for(Schema.FieldsetMember m :SObjectType.project_cloud__Project_Task__c.FieldSets.CCPE_SiteFields.getFields()){query += m.getFieldPath() + ', ';}

    query += 'Id, Name, project_cloud__Project_Phase__r.Name FROM project_cloud__Project_Task__c WHERE project_cloud__Project_Phase__r.project_cloud__Project__c = \'' + controller.getId() + '\' ORDER BY  project_cloud__Project_Phase__c, project_cloud__Start__c ASC, project_cloud__End__c ASC '; return (List<project_cloud__Project_Task__c>)Database.query(query);

    }

    public List<project_cloud__Ticket__c> getProjectTicketsRisks(){String query = 'SELECT ';

    for(Schema.FieldsetMember m :SObjectType.project_cloud__Ticket__c.FieldSets.CCPE_SiteFieldsRisks.getFields()){query += m.getFieldPath() + ', ';}

    query += 'Id, Name, project_cloud__Ticket_Name__c,project_cloud__Project_Phase__r.Name, project_cloud__Project_Task__r.Name FROM project_cloud__Ticket__c WHERE (project_cloud__Project_Phase__r.project_cloud__Project__c = \'' + controller.getId() + '\' OR project_cloud__Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c = \'' + controller.getId() + '\' OR project_cloud__Project__c = \'' + controller.getId() + '\')'; if(recordTypeRisks.size() > 0){query += ' AND RecordType.Name IN :recordTypeRisks';}

    return (List<project_cloud__Ticket__c>)Database.query(query);
    
    }

    public List<project_cloud__Ticket__c> getProjectTicketsIssues(){String query = 'SELECT ';

    for(Schema.FieldsetMember m :SObjectType.project_cloud__Ticket__c.FieldSets.CCPE_SiteFieldsRisks.getFields()){query += m.getFieldPath() + ', ';}

    query += 'Id, Name, project_cloud__Ticket_Name__c,project_cloud__Project_Phase__r.Name, project_cloud__Project_Task__r.Name FROM project_cloud__Ticket__c WHERE (project_cloud__Project_Phase__r.project_cloud__Project__c = \'' + controller.getId() + '\' OR project_cloud__Project_Task__r.project_cloud__Project_Phase__r.project_cloud__Project__c = \'' + controller.getId() + '\' OR project_cloud__Project__c = \'' + controller.getId() + '\')'; if(recordTypeIssues.size() > 0){query += ' AND RecordType.Name IN :recordTypeIssues';}

    return (List<project_cloud__Ticket__c>)Database.query(query);
    
    }

}