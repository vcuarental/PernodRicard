@isTest
public class ASI_CRM_CN_Approval_Test {
    
    static testMethod void ASI_CRM_CN_ApprovalListController_TEST() {
        
        ASI_CRM_Region__c region = new ASI_CRM_Region__c (Name='TEST');
        insert region;
        
        ASI_CRM_Division__c division = new ASI_CRM_Division__c(Name='TEST', ASI_CRM_Region__c=region.Id);
        insert division;
        
        ASI_CRM_CN_Area__c area = new ASI_CRM_CN_Area__c(Name='TEST', ASI_CRM_English_Name__c='TEST', ASI_CRM_Division__c=division.Id);
        insert area;
        
        ASI_CRM_City__c city = new ASI_CRM_City__c(Name='TEST', ASI_CRM_CN_Area__c=area.Id);
        insert city;
        
        ASI_CRM_CN_Channel__c channel = new ASI_CRM_CN_Channel__c(ASI_CRM_CN_On_Off__c='ON');
        insert channel;
        
        ASI_MFM_Sub_Channel__c subChannel = new ASI_MFM_Sub_Channel__c(ASI_CRM_CN_Channel__c=channel.Id);
        insert subChannel;
        
        Id rtWS = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_CN_WS');
        Id rtOutlet = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_Outlet_CN');
        
        ASI_CRM_AccountsAdditionalField__c a2 = new ASI_CRM_AccountsAdditionalField__c(
            RecordTypeId=rtWS,
            Name='TEST', 
            ASI_CRM_CN_Image__c='Iconic',
            ASI_CRM_CN_CCity__c=city.Id,
            ASI_CRM_CN_Sub_Channel__c=subChannel.Id);
        insert a2;
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(a2.Id);
        Approval.process(req1);
        
        test.startTest();
        
        ASI_CRM_CN_ApprovalListController con = new ASI_CRM_CN_ApprovalListController();
        con.getStatusItems();
        con.init();
        con.Beginning();
        con.Previous();
        con.Next();
        con.End();
        con.getDisablePrevious();
        con.getDisableNext();
        con.getTotal_size();
        con.getPageNumber();
        con.total_size = 20;
        con.getTotalPages();
        con.total_size = 21;
        con.getTotalPages();
        con.changeStatus();
        con.statusSelected = 'Pending';
        con.queryRec();
        con.statusSelected = 'Approved';
        con.queryRec();
        con.statusSelected = 'Rejected';
        con.queryRec();
        
        ASI_CRM_CN_ApprovalListController.ApprovalRecord r;
        r = new ASI_CRM_CN_ApprovalListController.ApprovalRecord();
        r = new ASI_CRM_CN_ApprovalListController.ApprovalRecord((ProcessInstanceWorkitem)null);
        r = new ASI_CRM_CN_ApprovalListController.ApprovalRecord((ProcessInstanceStep)null);
        
        test.stopTest();
    }
}