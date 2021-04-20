@isTest
private class VFC98_StreamsDisplay_TEST {

    static testMethod void myUnitTest() {
        
        /* Create a Project  */
        ESNProject__c Project = Utils_TestMethods.createProject();
// FTR : Dates are now mandatory
Date today = Date.today();
Project.StartDate__c = today;
Project.EndDate__c = today.addDays(30);
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        insert Project ;
}
        
        /* Create a Stream  */
        ESNStream__c parentStream = Utils_TestMethods.createStream(Project.id);
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        insert parentStream ;
}
        
        /* Create a child Stream */
        ESNStream__c childStream1 = Utils_TestMethods.createStream(Project.id);
        childStream1.Project__c = Project.Id;
        childStream1.ParentStream__c = parentStream.Id;
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        insert childStream1 ;
}
        
        ESNStream__c childStream2 = Utils_TestMethods.createStream(Project.id);
        childStream2.Project__c = Project.Id;
        childStream2.ParentStream__c = parentStream.Id;
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        insert childStream2 ;
}
        
        ESNStream__c childStream3 = Utils_TestMethods.createStream(Project.id);
        childStream3.Project__c = Project.Id;
        childStream3.ParentStream__c = parentStream.Id;
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        insert childStream3 ;
}
        
        /* Create new instance of Visualforce Page */
        Pagereference vf = Page.VFP98_StreamsDisplay;
        vf.getParameters().put('Id', Project.Id);
        Test.setCurrentPageReference(vf);
        VFC98_StreamsDisplay con = new VFC98_StreamsDisplay(new ApexPages.StandardController(Project));
        List<ESNStream__c> listStreams = new List<ESNStream__c>();
        listStreams.add(childStream1);
        listStreams.add(parentStream);
        listStreams.add(childStream2);
        listStreams.add(childStream3);
        con.buildRelationStreamParent2Child(listStreams);
    }
}