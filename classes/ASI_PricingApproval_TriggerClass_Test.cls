@isTest
public with sharing class ASI_PricingApproval_TriggerClass_Test {
    static testmethod void CopyRecallCommenttoRemarks_Test(){
		ASI_Pricing_Approval_Setting__c setting = new ASI_Pricing_Approval_Setting__c(Name='Change in Customer Margin', ASI_Pricing_Change_Type__c='Change in Customer Margin (Not Budgeted)', 
			ASI_Pricing_First_Approver_Username__c = UserInfo.getUserName(), ASI_Pricing_Forth_Approver_Username__c = UserInfo.getUserName(), ASI_Pricing_Second_Approver_Username__c = UserInfo.getUserName(), 
				ASI_Pricing_Third_Approver_Username__c = UserInfo.getUserName());
		
		insert setting;
		
        ASI_Pricing_Approval__c pa = new ASI_Pricing_Approval__c(Name='Test',ASI_Advanced_Pricing__c=true,ASI_Status__c='Open',ASI_Customer_Name__c='test',ASI_Approved_Level__c=1,
			ASI_Submission_Date__c=Date.today(), ASI_Pricing_Change_Type__c= 'Change in Customer Margin (Not Budgeted)'); 
        insert pa;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(pa.id);
        Approval.ProcessResult result = Approval.process(req1);
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        system.debug('result: ' + result);
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Recall Approval.');
        req2.setAction('Removed');
        //req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 = Approval.process(req2);
        system.debug('result2: ' + result2);
        
        pa.ASI_Recall__c=true;
        update pa;
        
    } 
    static testmethod void checkVoidPermission_Test(){
        ASI_PricingApproval_Cls.checkVoidPermission();
        Group g = [SELECT id FROM Group WHERE DeveloperName='ASI_Pricing_Team'];
        if (g == null){
            g = new Group(Name='ASI Pricing Team',DeveloperName='ASI_Pricing_Team');
            insert g;
        }
        GroupMember gm = new GroupMember(GroupId=g.id,UserOrGroupId=UserInfo.getUserId());
        insert gm;
        ASI_PricingApproval_Cls.checkVoidPermission();
    }
}