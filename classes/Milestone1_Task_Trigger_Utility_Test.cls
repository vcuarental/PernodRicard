/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
/**
* This Class test Task Trigger functionality  
*/

@isTest
private class Milestone1_Task_Trigger_Utility_Test {

	/**
	* Test exceeded chatter suscription
	*/
    static testMethod void chatterSubscriptionLimitExceeded() {
		// Create a poject
		Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Chatter Blow');
		insert proj;

		// Create a milestone
		Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
		insert mstone;
        
		Milestone1_Settings__c milestoneSetting = new Milestone1_Settings__c();
        milestoneSetting.Auto_Follow_Task__c = true;
        milestoneSetting.Auto_Follow_Complete_Task__c = true;
        milestoneSetting.Auto_Unfollow_Reassignment__c = true;
        insert milestoneSetting;
        
		// Add 600 tasks to the milestone to exceed chatter user subscription limit
		List<Milestone1_Task__c> lTask = new List<Milestone1_Task__c>();

		for(Integer j = 0; j < 6; j++){        	
			for(Integer i = 0; i < 100; i++){
                Milestone1_Task__c ricTask = Milestone1_Test_Utility.sampleTask(mstone.Id);
                ricTask.RIC_Type_Action__c = 'Avec Notification';
				lTask.add(ricTask);
			}
			
			try{
				insert lTask;
			}
			catch(Exception e){
				if( e.getMessage().contains( Milestone1_Task_Trigger_Utility.SUBSCRIPTION_LIMIT_EXCEEDED )){
				  //system.assert(true);
				}
				else{
					//system.assert(false, e.getMessage());
				}
			}

			lTask.clear();
		}
	}
    
    private static testMethod void testMethod2() {
        Test.startTest();
        // Create a poject
		Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProject('Chatter Blow');
		insert proj;

		// Create a milestone
		Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
		insert mstone;
        user u=new user(id=UserInfo.getUserId());
     
        Milestone1_Task__c c = new Milestone1_Task__c(); //Create new Task for Milestone b
        c.Name = 'Test Task';
        c.Project_Milestone__c = mstone.Id;
        c.RIC_Type_Action__c = 'Avec Notification'; 
        c.Due_Date__c = Date.today().addMonths(3);
        c.Assigned_To__c=u.id;
        c.RIC_Status__c='En cours';
        
        Milestone1_Task__c c2 = new Milestone1_Task__c(); //Create new Task for Milestone b
        c2.Name = 'Test Task';
        c2.Project_Milestone__c = mstone.Id;
        c2.Predecessor_Task__c = c.Id;
        c2.RIC_Type_Action__c = 'Avec Notification'; 
        c2.Due_Date__c = Date.today().addMonths(4);
        c2.RIC_Status__c='En cours';
        
        Milestone1_Task__c c3 = new Milestone1_Task__c(); //Create new Task for Milestone b
        c3.Name = 'Test Task';
        c3.Project_Milestone__c = mstone.Id;
        c3.Predecessor_Task__c = c.Id;
        c3.RIC_Type_Action__c = 'Avec Notification';
        c3.RIC_Status__c='Réalisé';
        insert new List<Milestone1_Task__c> {c,c2,c3};
        user u2 =([select id,alias from user 
                          where alias ='SpaceyA']);
        c.RIC_Date_Realisation__c = Date.today().addMonths(2);
        c.Due_Date__c = Date.today().addMonths(4);
        c.Assigned_To__c=u2.id;
        update c;
        
        c3.Start_Date__c = null;
        update c3;
        
        Test.stopTest();
    }
}