@isTest
public class ASI_GetApprovalComments_Cmpnt_Ctrl_Test{
    static testMethod void ASI_GetApprovalComments_TEST() {
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        //Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(ASI_CRM_CN_City_Code__c='TEST');
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        list<ASI_CRM_AccountsAdditionalField__c> a2s = new list<ASI_CRM_AccountsAdditionalField__c>();
        a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtWS, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id, ASI_CRM_CN_Status_T1__c='Draft'));
        //a2s.add(new ASI_CRM_AccountsAdditionalField__c(RecordTypeId=rtOutlet, ASI_CRM_CN_CCity__c=city.Id, ASI_CRM_CN_Sub_Channel__c=subChannel.Id));
        insert a2s;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(a2s[0].id);
        Approval.ProcessResult result = Approval.process(req1);
        
        test.startTest();
        {   
            ASI_GetApprovalComments_Cmpnt_Ctrl compnt = new ASI_GetApprovalComments_Cmpnt_Ctrl();
            compnt.objids = a2s[0].id;
            compnt.getApprovalSteps();
        }
        test.stopTest();
    }
}