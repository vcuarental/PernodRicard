@isTest
private class RIC_Batch_UpdateEcheance_Test {
    static testMethod void testPrimaryAddressBatch(){
        user u=new user(id=UserInfo.getUserId());
        u.alias = 'jmsal';
        update u;
        RIC_Brand__c marque = new RIC_Brand__c(RIC_Code_Marque__c='123',Name='test',RIC_Prefixe__c='123');
        insert marque;
        Milestone1_Project__c proj =new Milestone1_Project__c(Name='test',RIC_Brand__c=marque.Id,RIC_Status__c='En cours');
        insert proj;
        Milestone1_Milestone__c phase =new Milestone1_Milestone__c( Name='test',Project__c=proj.Id);
        insert phase;
        Milestone1_Task__c task = new Milestone1_Task__c(Name='test', Assigned_To__c=u.id,Project_Milestone__c=phase.Id,RIC_Status__c='En cours',Start_Date__c=date.newInstance(2017, 10, 2017),Due_Date__c=date.newInstance(2017, 10, 2017) );
        insert task;
        update task;
        
        Database.executeBatch(new RIC_Batch_UpdateEcheance());
        
    }
}