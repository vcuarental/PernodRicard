@isTest
private class VFC10_StreamsDisplayOnStream_TEST {

    static testMethod void myUnitTest() {
        
        /* Create a context user */
        User contextUsr = TestFactory.createUserWithProfile('ctxUsr', 'ESN SSO User');
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        insert contextUsr;
}
        
        /* Query the permission set "Project Management" */
        List<PermissionSet> searchList = [SELECT Id FROM PermissionSet WHERE Name = 'Project_Tab_Permission_Set'];
        if(searchList.size() != 0){
            String permId = searchList[0].Id;
            
            /* Assign the permission set to the user */
            PermissionSetAssignment permAssign = new PermissionSetAssignment( AssigneeId = contextUsr.Id, PermissionSetId = permId );
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert permAssign;
}
        }
            
        System.runas(contextUsr){  
        
            /* Create a Project  */
            ESNProject__c Project = Utils_TestMethods.createProject();
// FTR : Dates are now mandatory
Date today = Date.today();
Project.StartDate__c = today;
Project.EndDate__c = today.addDays(30);
            insert Project ;
            
            /* Create a Stream  */
            ESNStream__c parentStream = Utils_TestMethods.createStream(Project.id);
            insert parentStream ;
            
            /* Create a child Stream */
            ESNStream__c childStream1 = Utils_TestMethods.createStream(Project.id);
            childStream1.Project__c = Project.Id;
            childStream1.ParentStream__c = parentStream.Id;
            insert childStream1 ;
            
            ESNStream__c childStream2 = Utils_TestMethods.createStream(Project.id);
            childStream2.Project__c = Project.Id;
            childStream2.ParentStream__c = parentStream.Id;
            insert childStream2 ;
            
            ESNStream__c childStream3 = Utils_TestMethods.createStream(Project.id);
            childStream3.Project__c = Project.Id;
            childStream3.ParentStream__c = parentStream.Id;
            insert childStream3 ;
            
            /* Create a sub-child Stream */
            ESNStream__c subChildStream1 = Utils_TestMethods.createStream(Project.id);
            subChildStream1.Project__c = Project.Id;
            subChildStream1.ParentStream__c = childStream3.Id;
            insert subChildStream1 ;
            
            ESNStream__c subChildStream2 = Utils_TestMethods.createStream(Project.id);
            subChildStream2.Project__c = Project.Id;
            subChildStream2.ParentStream__c = childStream3.Id;
            insert subChildStream2 ;    
            
            ESNStream__c subChildStream3 = Utils_TestMethods.createStream(Project.id);
            subChildStream3.Project__c = Project.Id;
            subChildStream3.ParentStream__c = childStream2.Id;
            insert subChildStream3 ;
            
            
            /* Create new instance of Visualforce Page */
            Pagereference vf = Page.VFP10_StreamsDisplayOnStream;
            vf.getParameters().put('Id', Project.Id);
            Test.setCurrentPageReference(vf);
            VFC10_StreamsDisplayOnStream con = new VFC10_StreamsDisplayOnStream(new ApexPages.StandardController(parentStream));
            List<ESNStream__c> listStreams = new List<ESNStream__c>();
            listStreams.add(childStream1);
            listStreams.add(subChildStream1);
            listStreams.add(childStream2);
            listStreams.add(subChildStream2);
            listStreams.add(childStream3);
            listStreams.add(subChildStream3);
            listStreams.add(parentStream);
            con.buildRelationStreamParent2Child(listStreams);
        }
    }
}