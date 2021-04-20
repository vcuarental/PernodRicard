/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       |                                                                                   |
|     - Description     | Test class of ESN_VFC27_StreamGanttChart                             |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 30/08/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest
private class ESN_VFC27_StreamGanttChart_TEST{

    static testMethod void myUnitTest() {
    /* Create a context user */
      User contextUsr = TestFactory.createUserWithProfile('ctxUsr', 'ESN SSO User');
      insert contextUsr;
        
        /* Query the permission set "Project Management" */
        List<PermissionSet> searchList = [SELECT Id FROM PermissionSet WHERE Name = 'Project_Tab_Permission_Set'];
        String permId = searchList[0].Id;
        
        /* Assign the permission set to the user */
        PermissionSetAssignment permAssign = new PermissionSetAssignment( AssigneeId = contextUsr.Id, PermissionSetId = permId );
        insert permAssign;
            
      	System.runas(contextUsr){               
            // Create a project with usr1 as owner //
            ESNProject__c proj1 = new ESNProject__c(
                Name = 'proj1',
                Priority__c = 'low',
                StartDate__c = Date.today(),
                EndDate__c = Date.today().addMonths(2),
                OwnerId = contextUsr.Id
            );
            insert proj1;
        
            // Create a stream Parent //
            ESNStream__c stream1 = new ESNStream__c(
                Name = 'stream1',
                Project__c = proj1.Id,
                StartDate__c = Date.today(),
                EndDate__c = Date.today().addMonths(2)
            );
            insert stream1;
            
            // Create a stream Parent //
            ESNStream__c stream2 = new ESNStream__c(
                Name = 'stream1',
                Project__c = proj1.Id,
                StartDate__c = Date.today(),
                ParentStream__c = stream1.Id,
                EndDate__c = Date.today().addMonths(2)
            );
            insert stream2;
            
            /* Create new instance of Visualforce Page */
            Pagereference vf = Page.ESN_VFP27_StreamGanttChart;
            vf.getParameters().put('Id', stream1.Id);
            Test.setCurrentPageReference(vf);
            ESN_VFC27_StreamGanttChart con = new ESN_VFC27_StreamGanttChart(new ApexPages.StandardController(stream1));    
      }
    }
}