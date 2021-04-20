@isTest
private class AP03_EmailServices_DocToChatter_TEST {
    /* Test 1 : no hashtag in the email subject */
    static testMethod void test_noHashtag(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {       
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create an email which is not already defined for an existing User 
            String userEmail = 'testChatter@test.fr';
    
            // Set common values in the email
            email.subject = 'my first test';
            email.plainTextBody = 'my first Body test';
            email.fromAddress = userEmail;
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.startTest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env);
            Test.stopTest();  
            
            // Verify the test result
            System.assert(result.success == false);
            System.assert(result.message.contains('We cannot access to your demand. Indeed, a hashtag in the email subject is needed.'));
        }
    }

    /* Test 2 : User doesn't exist */
    static testMethod void test_noUser(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create an email which is not already defined for an existing User 
            String userEmail = 'testChatter@test.fr';
    
            // Set common values in the email
            email.subject = 'my second test #help';
            email.plainTextBody = 'my second Body test';
            email.fromAddress = userEmail;
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.startTest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env);
            Test.stopTest();  
            
            // Verify the test result
            System.assert(result.success == false);
            System.assert(result.message.contains('We cannot access to your demand. Your email address hasn’t been found in Pernod'));
        }
    }

    /* Test 3 : hashtag #group in the email subject but the group does not exist. */
    static testMethod void test_HashtagGroup_NotExist(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create a Standard User 
            User currUser = TestFactory.createUserWithProfile('testDTC', 'Chatter Only User');
            currUser.Email = 'testChatter@test.fr';     
            insert currUser;
            
            // Create a group name which not exist
            String groupName = 'He Who Must Not Be Named';
    
            // Set common values in the email
            email.subject = 'my third test #group '+groupName;
            email.plainTextBody = 'my third Body test';
            email.fromAddress = currUser.Email;
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.starttest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env );
            Test.stoptest(); 
    
            // Verify the test result
            System.assert(result.success == false);
            System.assert(result.message.contains('We cannot access to your demand. The group name '+groupName));
        }       
    }     

    /* Test 4 : hashtag #group in the email subject but the user is not a member of this group. */
    static testMethod void test_HashtagGroup_NotMember(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create a Standard User 
            User currUser = TestFactory.createUserWithProfile('testDTC', 'Chatter Only User');
            currUser.Email = 'testChatter@test.fr';     
            insert currUser;
            User anotherUser = TestFactory.createStandardUser('toto');
            anotherUser.Email = 'toto@test.fr'; 
            insert anotherUser;
            
            // Create a group name which not exist
            CollaborationGroup newGroup = new CollaborationGroup();
            newGroup.Name = 'He Who Must Not Be Named';
            newGroup.CollaborationType = 'Private';
            insert newGroup;
            
            CollaborationGroupMember newGroupMember = new CollaborationGroupMember();
            newGroupMember.CollaborationRole = 'Standard';
            newGroupMember.MemberId = anotherUser.Id;
            newGroupMember.CollaborationGroupId = newGroup.Id;
            insert newGroupMember;
            
    
            // Set common values in the email
            email.subject = 'my third test #group '+newGroup.Name;
            email.plainTextBody = 'my third Body test';
            email.fromAddress = currUser.Email;
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.starttest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env );
            Test.stoptest(); 
    
            // Verify the test result
            System.assert(result.success == false);
            System.assert(result.message.contains('We cannot access to your demand. You’re not a member of the group: '+newGroup.Name));
        }       
    } 
        
    /* Test 5 : hashtag #group in the email subject and success. No PJ*/
    static testMethod void test_HashtagGroup_Success_noPJ(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create a Standard User 
            User currUser = TestFactory.createUserWithProfile('testDTC', 'Chatter Only User');
            currUser.Email = 'testChatter@test.fr';     
            insert currUser;
            User anotherUser = TestFactory.createStandardUser('toto');
            anotherUser.Email = 'toto@test.fr'; 
            insert anotherUser;
            
            // Create a group name which not exist
            CollaborationGroup newGroup = new CollaborationGroup();
            newGroup.Name = 'He Who Must Not Be Named';
            newGroup.CollaborationType = 'Private';
            insert newGroup;
            
            CollaborationGroupMember anotherGroupMember = new CollaborationGroupMember();
            anotherGroupMember.CollaborationRole = 'Standard';
            anotherGroupMember.MemberId = anotherUser.Id;
            anotherGroupMember.CollaborationGroupId = newGroup.Id;
            insert anotherGroupMember;
            
            CollaborationGroupMember newGroupMember = new CollaborationGroupMember();
            newGroupMember.CollaborationRole = 'Standard';
            newGroupMember.MemberId = currUser.Id;
            newGroupMember.CollaborationGroupId = newGroup.Id;
            insert newGroupMember;
            
            // Set common values in the email and add attachments (case without body)
            email.subject = 'my third test #group '+newGroup.Name;
            email.plainTextBody = '';
            email.fromAddress = currUser.Email;
            
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.starttest();
            Messaging.InboundEmailResult result1 = currTest.handleInboundEmail(email, env );
            for(Integer i=0;i<51;i++)
                email.plainTextBody += 'test email to chatter,';
            Messaging.InboundEmailResult result2 = currTest.handleInboundEmail(email, env );
            Test.stoptest(); 
            
            // Verify the test result
            System.assert(result1.success == true);
            System.assert(result1.message.contains('Your post has been successfully added to the group: '+newGroup.Name));  
            System.assert(result2.success == true);
            System.assert(result2.message.contains('Your post has been successfully added to the group: '+newGroup.Name));
        }       
    }
    
    /* Test 6 : hashtag #group in the email subject and success : 2 binary attachments and 2 text atachments */
    static testMethod void test_HashtagGroup_Success_PJ_b_t(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create a Standard User 
            User currUser = TestFactory.createUserWithProfile('testDTC', 'Chatter Only User');
            currUser.Email = 'testChatter@test.fr';     
            insert currUser;
            User anotherUser = TestFactory.createStandardUser('toto');
            anotherUser.Email = 'toto@test.fr'; 
            insert anotherUser;
            
            // Create a group name which not exist
            CollaborationGroup newGroup = new CollaborationGroup();
            newGroup.Name = 'He Who Must Not Be Named';
            newGroup.CollaborationType = 'Private';
            insert newGroup;
            
            CollaborationGroupMember anotherGroupMember = new CollaborationGroupMember();
            anotherGroupMember.CollaborationRole = 'Standard';
            anotherGroupMember.MemberId = anotherUser.Id;
            anotherGroupMember.CollaborationGroupId = newGroup.Id;
            insert anotherGroupMember;
            
            CollaborationGroupMember newGroupMember = new CollaborationGroupMember();
            newGroupMember.CollaborationRole = 'Standard';
            newGroupMember.MemberId = currUser.Id;
            newGroupMember.CollaborationGroupId = newGroup.Id;
            insert newGroupMember;
     
            // create Text and Binary attachments
            Messaging.InboundEmail.BinaryAttachment AttachmentBIN = TestFactory.createEmailBinaryAttachment('my new binary attachment');
            Messaging.InboundEmail.Textattachment AttachmentTXT = TestFactory.createEmailTextAttachment('my new text attachment');
            
            // Set common values in the email and add attachments
            email.subject = 'my third test #group '+newGroup.Name;
            email.plainTextBody = 'my third Body test';
            email.fromAddress = currUser.Email;
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { AttachmentBIN };
            email.TextAttachments = new Messaging.inboundEmail.Textattachment[] { AttachmentTXT };
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.starttest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env );
            Test.stoptest(); 
    
            // Verify the test result
            System.assert(result.success == true);
            System.debug('##### Result : '+result.message);
            System.assert(result.message.contains('Your post has been successfully added to the group: '+newGroup.Name));
        }       
    } 

    /* Test 7 : hashtag #group in the email subject and success. */
    static testMethod void test_HashtagGroup_Success_PJ_2t(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create a Standard User 
            User currUser = TestFactory.createUserWithProfile('testDTC', 'Chatter Only User');
            currUser.Email = 'testChatter@test.fr';     
            insert currUser;
            User anotherUser = TestFactory.createStandardUser('toto');
            anotherUser.Email = 'toto@test.fr'; 
            insert anotherUser;
            
            // Create a group name which not exist
            CollaborationGroup newGroup = new CollaborationGroup();
            newGroup.Name = 'He Who Must Not Be Named';
            newGroup.CollaborationType = 'Private';
            insert newGroup;
            
            CollaborationGroupMember anotherGroupMember = new CollaborationGroupMember();
            anotherGroupMember.CollaborationRole = 'Standard';
            anotherGroupMember.MemberId = anotherUser.Id;
            anotherGroupMember.CollaborationGroupId = newGroup.Id;
            insert anotherGroupMember;
            
            CollaborationGroupMember newGroupMember = new CollaborationGroupMember();
            newGroupMember.CollaborationRole = 'Standard';
            newGroupMember.MemberId = currUser.Id;
            newGroupMember.CollaborationGroupId = newGroup.Id;
            insert newGroupMember;
            
            //Create 2 Text Attachment  
            Messaging.InboundEmail.Textattachment AttachmentTXT1 = TestFactory.createEmailTextAttachment('my new text attachment 1');
            Messaging.InboundEmail.Textattachment AttachmentTXT2 = TestFactory.createEmailTextAttachment('my new text attachment 2');
            
            // Set common values in the email and add attachments
            email.subject = 'my third test #group '+newGroup.Name;
            email.plainTextBody = '';
            email.fromAddress = currUser.Email;
            email.TextAttachments = new Messaging.inboundEmail.Textattachment[] { AttachmentTXT1,AttachmentTXT2 };
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.starttest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env );
            for(Integer i=0;i<51;i++)
                email.plainTextBody += 'test email to chatter,';
            Messaging.InboundEmailResult result2 = currTest.handleInboundEmail(email, env );
            Test.stoptest(); 
    
            // Verify the test result
            System.assert(result.success == true);
            System.debug('##### Result : '+result.message);
            System.assert(result.message.contains('Your post has been successfully added to the group: '+newGroup.Name));
            System.assert(result2.success == true);
            System.debug('##### Result2 : '+result2.message);
            System.assert(result2.message.contains('Your post has been successfully added to the group: '+newGroup.Name));
        }
    } 
        
    /* Test 8 : hashtag #group in the email subject and success. */
    static testMethod void test_HashtagGroup_Success_PJ_2b(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail();
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create a Standard User 
            User currUser = TestFactory.createUserWithProfile('testDTC', 'Chatter Only User');
            currUser.Email = 'testChatter@test.fr';     
            insert currUser;
            User anotherUser = TestFactory.createStandardUser('toto');
            anotherUser.Email = 'toto@test.fr'; 
            insert anotherUser;
            
            // Create a group name which not exist
            CollaborationGroup newGroup = new CollaborationGroup();
            newGroup.Name = 'He Who Must Not Be Named';
            newGroup.CollaborationType = 'Private';
            insert newGroup;
            
            CollaborationGroupMember anotherGroupMember = new CollaborationGroupMember();
            anotherGroupMember.CollaborationRole = 'Standard';
            anotherGroupMember.MemberId = anotherUser.Id;
            anotherGroupMember.CollaborationGroupId = newGroup.Id;
            insert anotherGroupMember;
            
            CollaborationGroupMember newGroupMember = new CollaborationGroupMember();
            newGroupMember.CollaborationRole = 'Standard';
            newGroupMember.MemberId = currUser.Id;
            newGroupMember.CollaborationGroupId = newGroup.Id;
            insert newGroupMember;
            
            //Create 2 Binary Attachments
            Messaging.InboundEmail.BinaryAttachment AttachmentBIN1 = TestFactory.createEmailBinaryAttachment('my new bin attachment 1');
            Messaging.InboundEmail.BinaryAttachment AttachmentBIN2 = TestFactory.createEmailBinaryAttachment('my new bin attachment 2');
            
            // Set common values in the email and add attachments
            email.subject = 'my third test #group '+newGroup.Name;
            email.plainTextBody = 'null';
            email.fromAddress = currUser.Email;
            email.Binaryattachments = new Messaging.inboundEmail.Binaryattachment[] { AttachmentBIN1,AttachmentBIN2 };
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.starttest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env );
            for(Integer i=0;i<51;i++)
                email.plainTextBody += 'test email to chatter,';
            Messaging.InboundEmailResult result2 = currTest.handleInboundEmail(email, env );
            Test.stoptest(); 
    
            // Verify the test result
            System.assert(result.success == true);
            System.debug('##### Result : '+result.message);
            System.assert(result.message.contains('Your post has been successfully added to the group: ')); 
            System.assert(result2.success == true);
            System.debug('##### Result2 : '+result2.message);
            System.assert(result2.message.contains('Your post has been successfully added to the group: '));
        }   
    }
    
    /* Test 9 : hashtag #help in the email subject */
    static testMethod void test_HashtagHelp(){
        // Context User
        User u = TestFactory.createUserWithProfile('admin', 'System Administrator');      
            
        System.runAs(u) {   
            // Create a new email and envelope object
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
    
            // Create a Standard User 
            User currUser = TestFactory.createUserWithProfile('testDTC', 'Chatter Only User');
            currUser.Email = 'testChatter@test.fr'; 
            insert currUser;
            
            // Set common values in the email
            email.subject = 'my third test #help';
            email.plainTextBody = 'my third Body test';
            email.fromAddress = currUser.Email;
    
            // call the class and test it with the data in the testMethod
            AP03_EmailServices_DocToChatter currTest = new AP03_EmailServices_DocToChatter();
    
            Test.starttest();
            Messaging.InboundEmailResult result = currTest.handleInboundEmail(email, env );
            Test.stoptest(); 
    
            // Verify the test result
            System.assert(result.success == true);
            System.debug('##### Result : '+result.message);
            System.assert(result.message.contains('What does this service allow you to do in Pernod Ricard Chatter®?'));
        }       
    }
}