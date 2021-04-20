@isTest
public class ESN_VFC17_CustomLookupGroup_TEST {
	/* Test 1 : Save a new config */ 
	static testMethod void myUnitTest() {     
	    User contextUser = TestFactory.createStandardUser('context');        
	    contextUser.BypassTriggers__c = '';
	    
	    // Create new Chatter groups //
        CollaborationGroup group1 = TestFactory.createCollaborationGroup('ESN_VFC17_group1', 'private');
        insert group1;
        CollaborationGroup group2 = TestFactory.createCollaborationGroup('ESN_VFC17_group2', 'public');
        insert group2;
        CollaborationGroup group3 = TestFactory.createCollaborationGroup('ESN_VFC17_group3', 'private');
        insert group3;
        CollaborationGroup group4 = TestFactory.createCollaborationGroup('ESN_VFC17_group4', 'private');
        insert group4;
        CollaborationGroup group5 = TestFactory.createCollaborationGroup('ESN_VFC17_group5', 'private');
        insert group5;
        CollaborationGroup group6 = TestFactory.createCollaborationGroup('ESN_VFC17_group6', 'private');
        insert group6;
        CollaborationGroup group7 = TestFactory.createCollaborationGroup('ESN_VFC17_group7', 'public');
        insert group7;
        CollaborationGroup group8 = TestFactory.createCollaborationGroup('ESN_VFC17_group8', 'private');
        insert group8;
        CollaborationGroup group9 = TestFactory.createCollaborationGroup('ESN_VFC17_group9', 'private');
        insert group9;
        CollaborationGroup group10 = TestFactory.createCollaborationGroup('ESN_VFC17_group10', 'private');
        insert group10;
        CollaborationGroup group11 = TestFactory.createCollaborationGroup('ESN_VFC17_group11', 'private');
        insert group11;
        CollaborationGroup group12 = TestFactory.createCollaborationGroup('ESN_VFC17_group12', 'private');
        insert group12;
        CollaborationGroup group13 = TestFactory.createCollaborationGroup('ESN_VFC17_group13', 'private');
        insert group13;
        CollaborationGroup group14 = TestFactory.createCollaborationGroup('ESN_VFC17_group14', 'private');
        insert group14;
        CollaborationGroup group15 = TestFactory.createCollaborationGroup('ESN_VFC17_group15', 'private');
        insert group15;
        CollaborationGroup group16 = TestFactory.createCollaborationGroup('ESN_VFC17_group16', 'private');
        insert group16;
        CollaborationGroup group17 = TestFactory.createCollaborationGroup('ESN_VFC17_group17', 'private');
        insert group17;
        CollaborationGroup group18 = TestFactory.createCollaborationGroup('ESN_VFC17_group18', 'private');
        insert group18;
        CollaborationGroup group19 = TestFactory.createCollaborationGroup('ESN_VFC17_group19', 'private');
        insert group19;
        CollaborationGroup group20 = TestFactory.createCollaborationGroup('ESN_VFC17_group20', 'private');
        insert group20;
        CollaborationGroup group21 = TestFactory.createCollaborationGroup('ESN_VFC17_group21', 'private');
        insert group21;
        
	    System.runAs( contextUser ) {
	    	Pagereference vf1 = Page.ESN_VFP17_CustomLookupGroup;
	    	Test.setCurrentPageReference(vf1);
	        ESN_VFC17_CustomLookupGroup con1 = new ESN_VFC17_CustomLookupGroup();
	        // all results
	        con1.queryName = '';
	        con1.runQuery();
	        con1.getCurrGroup();
	        con1.getDisplay();
	        // too much results
	        con1.queryName = 'VFC17';
	        con1.runQuery();
	        // no results
	        con1.queryName = 'VFC19';
	        con1.runQuery();
	    }
	}
}