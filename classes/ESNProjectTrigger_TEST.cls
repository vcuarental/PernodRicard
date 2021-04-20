@isTest
private class ESNProjectTrigger_TEST {

    static testMethod void test1() {
        // Query 12 users
        List<User> users = [SELECT Id FROM User WHERE IsActive = true LIMIT 12];
        Id User1Id = users[0].Id;
        Id User2Id = users[1].Id;
        Id User3Id = users[2].Id;
        Id User4Id = users[3].Id;
        Id User5Id = users[4].Id;
        Id User6Id = users[5].Id;
        Id User7Id = users[6].Id;
        Id User8Id = users[7].Id;
        Id User9Id = users[8].Id;
        Id User10Id = users[9].Id;
        Id User11Id = users[10].Id;
        Id User12Id = users[11].Id;
        
        User userOwner = TestFactory.createUserWithProfile('User13', 'System Administrator');
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
    insert userOwner;
}
        
        /** BEFORE INSERT Test **/ 
            // Create a project with values for BEFORE INSERT
            ESNProject__c newProject = Utils_TestMethods.createProject();
            newProject.OwnerId = userOwner.Id;  
            newProject.ProjectManager__c = user1Id;
            newProject.Sponsor__c = user2Id;
            newProject.Contributor_1__c = user3Id;
            newProject.Contributor_2__c = user4Id;
            newProject.Contributor_3__c = user5Id;
            newProject.Contributor_4__c = user6Id;
            newProject.Contributor_5__c = user7Id;
            newProject.Contributor_6__c = user8Id;
            newProject.Contributor_7__c = user9Id;
            newProject.Contributor_8__c = user10Id;
            newProject.Contributor_9__c = user11Id;
            newProject.Contributor_10__c = user12Id;
            // FTR : Dates are now mandatory
            Date today = Date.today();
            newProject.StartDate__c = today;
            newProject.EndDate__c = today.addDays(30);
            // FTR : Status was added
            newProject.Status__c = 'Active';
            
        system.runas(userOwner){       
            insert newProject;
        }
        
        // count number of project share
        Integer counter = [SELECT count() FROM ESNProject__Share WHERE ParentId = :newproject.Id];    
        System.assertEquals(counter, 13);
        
        // Test one project sharing.
        List<ESNProject__Share> pShrs = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM ESNProject__Share WHERE ParentId = :newproject.Id AND UserOrGroupId= :user2Id];
        System.assertEquals(pShrs[0].AccessLevel, 'Edit');
        System.assertEquals(pShrs[0].RowCause, 'Manual');
        System.assertEquals(pShrs[0].UserOrGroupId, user2Id);
        
        /** BEFORE UPDATE Test **/ 
        
        // Update the project values
        newProject.ProjectManager__c = user12Id;
        newProject.Sponsor__c = user11Id;
        newProject.Contributor_1__c = user10Id;
        newProject.Contributor_2__c = null;      
// FTR : Solving MIXED_DML_OPERATION error
system.runas(userOwner){    
        update newProject;
}
        
        // count number of project share
        counter = [SELECT count() FROM ESNProject__Share WHERE ParentId = :newproject.Id];    
        System.assertEquals(counter, 9);
        
        /** DELETE Test **/
// FTR : Solving MIXED_DML_OPERATION error
system.runas(userOwner){       
        delete newProject;
}
    }
    
    static testMethod void test2() {
        // Query 12 users
        List<User> users = [SELECT Id FROM User WHERE IsActive = true LIMIT 12];
        Id User1Id = users[0].Id;
        Id User2Id = users[1].Id;
        Id User3Id = users[2].Id;
        Id User4Id = users[3].Id;
        Id User5Id = users[4].Id;
        Id User6Id = users[5].Id;
        Id User7Id = users[6].Id;
        Id User8Id = users[7].Id;
        Id User9Id = users[8].Id;
        Id User10Id = users[9].Id;
        Id User11Id = users[10].Id;
        Id User12Id = users[11].Id;
        
        User userOwner = TestFactory.createUserWithProfile('User13', 'System Administrator');
// FTR : Solving MIXED_DML_OPERATION error
System.runAs ( new User(Id = UserInfo.getUserId()) ) {
        insert userOwner;
}
        
        /** BEFORE INSERT Test **/ 
        
        // Create a project with values for BEFORE INSERT
        ESNProject__c newProject = Utils_TestMethods.createProject();
        // FTR : Dates are now mandatory
        Date today = Date.today();
        newProject.StartDate__c = today;
        newProject.EndDate__c = today.addDays(30);
        // FTR : Status was added
        newProject.Status__c = 'Active';
        
        newProject.OwnerId = userOwner.Id;
// FTR : Solving MIXED_DML_OPERATION error      
system.runas(userOwner){        
        insert newProject;
}
        
        // count number of project share
        Integer counter = [SELECT count() FROM ESNProject__Share WHERE ParentId = :newproject.Id];    
        System.assertEquals(counter, 1);        
         
        /** BEFORE UPDATE Test **/ 
        
        // Update only one field
        newProject.ProjectManager__c = user12Id;
// FTR : Solving MIXED_DML_OPERATION error      
system.runas(userOwner){        
        update newProject;
}
        
        // count number of project share
        counter = [SELECT count() FROM ESNProject__Share WHERE ParentId = :newproject.Id];    
        System.assertEquals(counter, 2);
        
        // Test one project sharing.
        List<ESNProject__Share> pShrs = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM ESNProject__Share WHERE ParentId = :newproject.Id AND UserOrGroupId= :user12Id];
        System.assertEquals(pShrs[0].AccessLevel, 'Edit');
        System.assertEquals(pShrs[0].RowCause, 'Manual');
        System.assertEquals(pShrs[0].UserOrGroupId, user12Id);
        
        // Update only one field with the OwnerID value
        newProject.ProjectManager__c = userOwner.Id; 
// FTR : Solving MIXED_DML_OPERATION error      
system.runas(userOwner){        
        update newProject;
}
        
        // count number of project share
        counter = [SELECT count() FROM ESNProject__Share WHERE ParentId = :newproject.Id];    
        System.assertEquals(counter, 1);
        
        // Update all field
        newProject.ProjectManager__c = user1Id;
        newProject.Sponsor__c = user2Id;
        newProject.Contributor_1__c = userOwner.Id;
        newProject.Contributor_2__c = user3Id;
        newProject.Contributor_3__c = user5Id;
        newProject.Contributor_4__c = user6Id;
        newProject.Contributor_5__c = user7Id;
        newProject.Contributor_6__c = user8Id;
        newProject.Contributor_7__c = user9Id;
        newProject.Contributor_8__c = user10Id;
        newProject.Contributor_9__c = user11Id;
        newProject.Contributor_10__c = user12Id;
// FTR : Solving MIXED_DML_OPERATION error      
system.runas(userOwner){        
        update newProject;
}        
        
        // count number of project share
        counter = [SELECT count() FROM ESNProject__Share WHERE ParentId = :newproject.Id];    
        System.assertEquals(counter, 12);
        
        // Test one project sharing.
        List<ESNProject__Share> pShrs2 = [SELECT Id, UserOrGroupId, AccessLevel, RowCause FROM ESNProject__Share WHERE ParentId = :newproject.Id AND UserOrGroupId= :user1Id];
        System.assertEquals(pShrs2.size(),1);
        System.assertEquals(pShrs2[0].AccessLevel, 'Edit');
        System.assertEquals(pShrs2[0].RowCause, 'Manual');
        System.assertEquals(pShrs2[0].UserOrGroupId, user1Id);
        
        /** DELETE Test **/
// FTR : Solving MIXED_DML_OPERATION error
system.runas(userOwner){    
        delete newProject;
}       
    }
}