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
@isTest
private class RIC_XML_Import_Utility_Test {  
   
    static TestMethod void  testSOQLQueries(){
      Milestone1_XML_Export_Utility m1exportutility = new Milestone1_XML_Export_Utility();
       
      Milestone1_Project__c testProject = Milestone1_Test_Utility.sampleProject('UNIT TEST PROJECT NAME ABC123XYZ UNIQUE' + System.now());
        testProject.RIC_MAD_Date__c = Date.today().addDays(100);
        insert testProject;
        //testProject = [select Id, Name from Milestone1_Project__c where Name = :testProject.Name limit 1];
      
      Milestone1_Milestone__c testPredecessorMilestone = Milestone1_Test_Utility.testSampleMilestone(testProject.Id,null,'UNIT_TEST_PREDECESSOR_MILESTONE_NAME_ACB123XYZ_UNIQUE' + System.now());
        insert testPredecessorMilestone;
        //testPredecessorMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testPredecessorMilestone.Name limit 1];
        
        Milestone1_Milestone__c testSuccessorMilestone = Milestone1_Test_Utility.testSampleMilestone(testProject.Id,testPredecessorMilestone.Id,'UNIT_TEST_SUCCESSOR_MILESTONE_1_NAME_ACB123XYZ_UNIQUE' + System.now());
        insert testSuccessorMilestone;
        //testSuccessorMilestone = [select Id, Name from Milestone1_Milestone__c where Name = :testSuccessorMilestone.Name limit 1];
        
        Milestone1_Task__c predecessorTask = Milestone1_Test_Utility.sampleTask(testPredecessorMilestone.Id,null,Date.today(),Date.today().addDays(1));
        predecessorTask.RIC_Type_Action__c = 'Avec Notification';
        insert predecessorTask;
        
        Milestone1_Task__c successorTask = Milestone1_Test_Utility.sampleTask(testPredecessorMilestone.Id,predecessorTask.Id,Date.today().addDays(2),Date.today().addDays(3));
        successorTask.RIC_Type_Action__c = 'Avec Notification';
        insert successorTask;
        system.debug('Successor Task'+successorTask);
        
        Milestone1_Task__c task1 = Milestone1_Test_Utility.sampleTask(testPredecessorMilestone.Id);
        task1.RIC_Type_Action__c = 'Avec Notification';
        insert task1;
        
       test.startTest();
        String xmlString = m1exportutility.buildProjectXmlString(testProject.Id);
       
        RIC_XML_Import_Utility importXMLUtility = new RIC_XML_Import_Utility();
        importXMLUtility.importProject(xmlString, testProject);
        test.stopTest();
        System.assertNotEquals(xmlString, null);
        
    
    }
    
  
}