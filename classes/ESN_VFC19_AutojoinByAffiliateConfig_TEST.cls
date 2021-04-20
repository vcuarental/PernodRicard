@isTest(SeeAllData=true)
private class ESN_VFC19_AutojoinByAffiliateConfig_TEST {
    
    /* Test 1 : Save a new config */ 
	static testMethod void myUnitTest_SaveNewConfigThenDelete() {     
	    //User contextUser = TestFactory.createStandardUser('context');//UserWithProfile('context','System Administrator');  
	    User contextUser = TestFactory.createUserWithProfile('context','Chatter Only User');        
	    contextUser.BypassTriggers__c = 'Autofollow_User_InsertUpdate;ESN_User_AutojoinByAffiliates';
	    System.runAs( contextUser ) { 
	        // Create new Chatter groups //
	        CollaborationGroup group1 = TestFactory.createCollaborationGroup('ESN_VFC19_group1', 'private');
	        insert group1;
	        CollaborationGroup group2 = TestFactory.createCollaborationGroup('ESN_VFC19_group2____ESN_VFC19_group2', 'public');
	        insert group2;
	        CollaborationGroup group3 = TestFactory.createCollaborationGroup('ESN_VFC19_group3', 'private');
	        insert group3;
	        
	        // Create new configurations //
	        ESN_AutojoinByAffiliates_Config__c newConf1 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf1.Chatter_Group_ID__c = group1.Id;
	        newConf1.Affiliate__c = 'Company1';
	        newConf1.Name = 'newConf1';
	        insert newConf1;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf2 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf2.Chatter_Group_ID__c = group2.Id;
	        newConf2.Affiliate__c = 'Company2';
	        newConf2.Name = 'newConf2';
	        insert newConf2;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf3 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf3.Chatter_Group_ID__c = group3.Id;
	        newConf3.Affiliate__c = 'All';
	        newConf3.Name = 'newConf3';
	        insert newConf3;
	         
	        /* Start test */
	        Test.startTest();           
	            // Create a list of users to insert
	            List<User> newUsers = new List<User>();
	            
	            Boolean comp1or2 = false;
	            for(Integer i=0;i<20;i++){
	                User user = TestFactory.createUserWithProfile('user'+i, 'Chatter Only User');
	                user.IsActive = true;
	                if(i == 2 || i == 5 || i == 7 || i == 12)
	                    user.IsActive = false;
	                if(comp1or2){
	                	user.CompanyName = 'Company1';
	                	comp1or2 = false;
	                }else{
	                	user.CompanyName = 'Company3';
	                	comp1or2 = true;
	                }
	                newUsers.add(user);
	            }
	            insert newUsers;
	            
	            CollaborationGroupMember newCGM = new CollaborationGroupMember(MemberId = newUsers[1].Id, CollaborationGroupId = group1.Id);
	            insert newCGM;
	        
		    	Pagereference vf1 = Page.ESN_VFP19_AutojoinByAffiliateConfig;
		    	Test.setCurrentPageReference(vf1);
		        ESN_VFC19_AutojoinByAffiliateConfig con1 = new ESN_VFC19_AutojoinByAffiliateConfig();
		        con1.emailAdmin = 'test@test.fr';
		        
		        // Save a new config //
		        con1.newAffiliate = 'All';
		        con1.newChatterGroup = group2.Id; 
		        con1.saveNewConf();
		        
		        // Save a new config but already exist //
		        con1.newAffiliate = 'Company2';
		        con1.newChatterGroup = group2.Id; 
		        con1.saveNewConf();
		        
		        // Delete the selected config //
		        con1.configNameSelected = 'newConf3';
		        con1.deleteSelectedConf();
		        
	        Test.stopTest();
		}
    }
    
    /* Test 2 : Run a config type 'All' */ 
    static testMethod void myUnitTest_RunOnceAll() {     
	    User contextUser = TestFactory.createStandardUser('context');//UserWithProfile('context','System Administrator');      
	    contextUser.BypassTriggers__c = 'Autofollow_User_InsertUpdate;ESN_User_AutojoinByAffiliates';
	    System.runAs( contextUser ) { 
	        // Create new Chatter groups //
	        CollaborationGroup group1 = TestFactory.createCollaborationGroup('ESN_VFC19_group1', 'private');
	        insert group1;
	        CollaborationGroup group2 = TestFactory.createCollaborationGroup('ESN_VFC19_group2____ESN_VFC19_group2', 'public');
	        insert group2;
	        CollaborationGroup group3 = TestFactory.createCollaborationGroup('ESN_VFC19_group3', 'private');
	        insert group3;
	        
	        // Create new configurations //
	        ESN_AutojoinByAffiliates_Config__c newConf1 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf1.Chatter_Group_ID__c = group1.Id;
	        newConf1.Affiliate__c = 'Company1';
	        newConf1.Name = 'newConf1';
	        insert newConf1;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf2 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf2.Chatter_Group_ID__c = group2.Id;
	        newConf2.Affiliate__c = 'Company2';
	        newConf2.Name = 'newConf2';
	        insert newConf2;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf3 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf3.Chatter_Group_ID__c = group3.Id;
	        newConf3.Affiliate__c = 'All';
	        newConf3.Name = 'newConf3';
	        insert newConf3;
	         
	        /* Start test */
	        Test.startTest();           
	            // Create a list of users to insert
	            List<User> newUsers = new List<User>();
	            
	            Boolean comp1or2 = false;
	            for(Integer i=0;i<20;i++){
	                User user = TestFactory.createUserWithProfile('user'+i, 'Chatter Only User');
	                user.IsActive = true;
	                if(i == 2 || i == 5 || i == 7 || i == 12)
	                    user.IsActive = false;
	                if(comp1or2){
	                	user.CompanyName = 'Company1';
	                	comp1or2 = false;
	                }else{
	                	user.CompanyName = 'Company3';
	                	comp1or2 = true;
	                }
	                newUsers.add(user);
	            }
	            insert newUsers;
	            
	            CollaborationGroupMember newCGM = new CollaborationGroupMember(MemberId = newUsers[1].Id, CollaborationGroupId = group1.Id);
	            insert newCGM;
	        
		    	Pagereference vf1 = Page.ESN_VFP19_AutojoinByAffiliateConfig;
		    	Test.setCurrentPageReference(vf1);
		        ESN_VFC19_AutojoinByAffiliateConfig con1 = new ESN_VFC19_AutojoinByAffiliateConfig();
		        con1.emailAdmin = 'test@test.fr';
		        		        		        
		        // Run batch once for the selected config //
		        con1.configNameSelected = 'newConf3';
		        con1.runOnce();
	        Test.stopTest();
		}
    }
    
    /* Test 2 : Run a config type Affiliate */ 
    static testMethod void myUnitTest_RunOnceAffiliate() {     
	    User contextUser = TestFactory.createUserWithProfile('context','Chatter Only User');  
	    contextUser.BypassTriggers__c = 'Autofollow_User_InsertUpdate;ESN_User_AutojoinByAffiliates';
	    System.runAs( contextUser ) { 
	        // Create new Chatter groups //
	        CollaborationGroup group1 = TestFactory.createCollaborationGroup('ESN_VFC19_group1', 'private');
	        insert group1;
	        CollaborationGroup group2 = TestFactory.createCollaborationGroup('ESN_VFC19_group2____ESN_VFC19_group2', 'public');
	        insert group2;
	        CollaborationGroup group3 = TestFactory.createCollaborationGroup('ESN_VFC19_group3', 'private');
	        insert group3;
	        
	        // Create new configurations //
	        ESN_AutojoinByAffiliates_Config__c newConf1 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf1.Chatter_Group_ID__c = group1.Id;
	        newConf1.Affiliate__c = 'Company1';
	        newConf1.Name = 'newConf1';
	        insert newConf1;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf2 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf2.Chatter_Group_ID__c = group2.Id;
	        newConf2.Affiliate__c = 'Company2';
	        newConf2.Name = 'newConf2';
	        insert newConf2;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf3 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf3.Chatter_Group_ID__c = group3.Id;
	        newConf3.Affiliate__c = 'All';
	        newConf3.Name = 'newConf3';
	        insert newConf3;
	         
	        /* Start test */
	        Test.startTest();           
	            // Create a list of users to insert
	            List<User> newUsers = new List<User>();
	            
	            Boolean comp1or2 = false;
	            for(Integer i=0;i<20;i++){
	                User user = TestFactory.createUserWithProfile('user'+i, 'Chatter Only User');
	                user.IsActive = true;
	                if(i == 2 || i == 5 || i == 7 || i == 12)
	                    user.IsActive = false;
	                if(comp1or2){
	                	user.CompanyName = 'Company1';
	                	comp1or2 = false;
	                }else{
	                	user.CompanyName = 'Company3';
	                	comp1or2 = true;
	                }
	                newUsers.add(user);
	            }
	            insert newUsers;
	            
	            CollaborationGroupMember newCGM = new CollaborationGroupMember(MemberId = newUsers[1].Id, CollaborationGroupId = group1.Id);
	            insert newCGM;
	        
		    	Pagereference vf1 = Page.ESN_VFP19_AutojoinByAffiliateConfig;
		    	Test.setCurrentPageReference(vf1);
		        ESN_VFC19_AutojoinByAffiliateConfig con1 = new ESN_VFC19_AutojoinByAffiliateConfig();
		        con1.emailAdmin = 'test@test.fr';
		        		        		        
		        // Run batch once for the selected config //		        
		        con1.configNameSelected = 'newConf2';
		        con1.runOnce();		        
	        Test.stopTest();
		}
    }
    
    /* Test 2 : Run a config type Affiliate */ 
    static testMethod void myUnitTest_RunOnceAffiliate_6times() {     
	    User contextUser = TestFactory.createStandardUser('context');//UserWithProfile('context','System Administrator');   
	    contextUser.BypassTriggers__c = 'Autofollow_User_InsertUpdate;ESN_User_AutojoinByAffiliates';
	    System.runAs( contextUser ) { 
	        // Create new Chatter groups //
	        CollaborationGroup group1 = TestFactory.createCollaborationGroup('ESN_VFC19_group1', 'private');
	        insert group1;
	        CollaborationGroup group2 = TestFactory.createCollaborationGroup('ESN_VFC19_group2____ESN_VFC19_group2', 'public');
	        insert group2;
	        CollaborationGroup group3 = TestFactory.createCollaborationGroup('ESN_VFC19_group3', 'private');
	        insert group3;
	        
	        // Create new configurations //
	        ESN_AutojoinByAffiliates_Config__c newConf1 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf1.Chatter_Group_ID__c = group1.Id;
	        newConf1.Affiliate__c = 'Company1';
	        newConf1.Name = 'newConf1';
	        insert newConf1;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf2 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf2.Chatter_Group_ID__c = group2.Id;
	        newConf2.Affiliate__c = 'Company2';
	        newConf2.Name = 'newConf2';
	        insert newConf2;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf3 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf3.Chatter_Group_ID__c = group3.Id;
	        newConf3.Affiliate__c = 'All';
	        newConf3.Name = 'newConf3';
	        insert newConf3;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf4 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf4.Chatter_Group_ID__c = group3.Id;
	        newConf4.Affiliate__c = 'Company4';
	        newConf4.Name = 'newConf4';
	        insert newConf4;
	        
	        ESN_AutojoinByAffiliates_Config__c newConf5 = new ESN_AutojoinByAffiliates_Config__c();
	        newConf5.Chatter_Group_ID__c = group3.Id;
	        newConf5.Affiliate__c = 'Company4';
	        newConf5.Name = 'newConf5';
	        insert newConf5;
	        
	        /* Start test */
	        Test.startTest();           
	            // Create a list of users to insert
	            List<User> newUsers = new List<User>();
	            Boolean comp1or2 = false;
	            for(Integer i=0;i<20;i++){
	                User user = TestFactory.createUserWithProfile('user'+i, 'Chatter Only User');
	                user.IsActive = true;
	                if(i == 2 || i == 5 || i == 7 || i == 12)
	                    user.IsActive = false;
	                if(comp1or2){
	                	user.CompanyName = 'Company1';
	                	comp1or2 = false;
	                }else{
	                	user.CompanyName = 'Company3';
	                	comp1or2 = true;
	                }
	                newUsers.add(user);
	            }
	            insert newUsers;
	            
	            CollaborationGroupMember newCGM = new CollaborationGroupMember(MemberId = newUsers[1].Id, CollaborationGroupId = group1.Id);
	            insert newCGM;
	        
		    	Pagereference vf1 = Page.ESN_VFP19_AutojoinByAffiliateConfig;
		    	Test.setCurrentPageReference(vf1);
		        ESN_VFC19_AutojoinByAffiliateConfig con1 = new ESN_VFC19_AutojoinByAffiliateConfig();
		        con1.emailAdmin = 'test@test.fr';
		        		        		        
		        // Run batch once for the selected config //		        
		        con1.configNameSelected = 'newConf3';
		        con1.runOnce();		        	        
		        con1.configNameSelected = 'newConf1';
		        con1.runOnce();			        
		        con1.configNameSelected = 'newConf2';
		        con1.runOnce();			        
		        con1.configNameSelected = 'newConf4';
		        con1.runOnce();			        
		        con1.configNameSelected = 'newConf5';
		        con1.runOnce();		
	        Test.stopTest();
	    }
    }
}