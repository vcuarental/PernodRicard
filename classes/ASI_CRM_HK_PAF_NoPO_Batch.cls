/*
List<ASI_HK_CRM_Pre_Approval_Form__c> PAFList=[ select id,ASI_CRM_HK_No_PO_Sent_Date__c from ASI_HK_CRM_Pre_Approval_Form__c where ASI_CRM_HK_No_PO_Sent_Date__c !=null limit 50 ];
for(ASI_HK_CRM_Pre_Approval_Form__c paf:PAFList ){
    paf.ASI_CRM_HK_No_PO_Sent_Date__c = null;
}

update PAFList;
   Id jobId = Database.executeBatch(new ASI_CRM_HK_PAF_NoPO_Batch(), 50);
*/



global without sharing class ASI_CRM_HK_PAF_NoPO_Batch implements Database.Batchable<sObject>, Database.Stateful{   
    private Set<ID> ids = new Set<ID>();
    private String body;
    
    //Import from Scheduler
    private static Integer checkDays = 30;
    private static String objectName = 'ASI_HK_CRM_Pre_Approval_Form__c';
    private static Set<ID> pafRTIDset = new Set<ID>{
        Global_recordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form'),
            Global_recordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form_Date_Adjustment'),
            Global_recordTypeCache.getRtId('ASI_HK_CRM_Pre_Approval_Form__cASI_HK_Pre_Approval_Form_Read_Only')
            };
                private static final String MAIL_RECEIVER_PUBLIC_GROUP_LABEL = 'ASI HK CRM Sales Admin';
    
    List<ID> mailReceiverUserIds = new List<ID>();
    
    
    public ASI_CRM_HK_PAF_NoPO_Batch()
    {
        //this.ids = ids;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Datetime checkDate = Datetime.now().addDays(-checkDays);
        String query = 'SELECT ID, Name, (SELECT id FROM POs__r) FROM ASI_HK_CRM_Pre_Approval_Form__c WHERE RecordTypeId in :pafRTIDSet AND ASI_HK_CRM_Is_Final_Approved__c = true AND (ASI_CRM_HK_No_PO_Sent_Date__c = null OR ASI_CRM_HK_No_PO_Sent_Date__c < :checkDate)';
        if(Test.isRunningTest())
        	query = 'SELECT ID, Name, (SELECT id FROM POs__r) FROM ASI_HK_CRM_Pre_Approval_Form__c Limit 1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ASI_HK_CRM_Pre_Approval_Form__c> scope)
    {
        //Prepare set of PAF (without PO in related list) ID
        for (ASI_HK_CRM_Pre_Approval_Form__c pafNoPo : scope){
            if(pafNoPO.POs__r.size()==0){
                ids.add(pafNoPO.id);
            }
        }
        
        List<ASI_HK_CRM_Pre_Approval_Form__c> pafContent = [SELECT ID, Name, ASI_CRM_HK_No_PO_Sent_Date__c, ASI_HK_CRM_PAF_Start_Date__c, ASI_HK_CRM_PAF_End_Date__c, ASI_HK_CRM_PAF_No_of_Months__c, ASI_HK_CRM_PAF_Volume_Commitment__c, ASI_HK_CRM_PAF_Contract_Requirement__c,ASI_HK_CRM_PAF_Version_No__c,ASI_HK_CRM_PAF_Raised_Date__c FROM ASI_HK_CRM_Pre_Approval_Form__c where ID IN :ids];
        
        Datetime sentDate = Datetime.now();
        this.body = '';
        
        for (ASI_HK_CRM_Pre_Approval_Form__c paf : pafContent)
        {
            this.body += 'PAF#: ' + paf.Name + '\n';
            this.body +=  URL.getSalesforceBaseUrl().toExternalForm()+'/'+ String.valueof(paf.ID)+'\n' ;
            this.body += 'Start Date: ' + paf.ASI_HK_CRM_PAF_Start_Date__c + '\n';
            this.body += 'End Date:: ' + paf.ASI_HK_CRM_PAF_End_Date__c +'\n';
            this.body += 'No. of Months: ' + paf.ASI_HK_CRM_PAF_No_of_Months__c + '\n';
            this.body += 'Volume Commitment: ' + paf.ASI_HK_CRM_PAF_Volume_Commitment__c+ '\n';
            this.body += 'Contract Requirement: ' + paf.ASI_HK_CRM_PAF_Contract_Requirement__c + '\n';
            this.body += 'Version No.: ' + paf.ASI_HK_CRM_PAF_Version_No__c + '\n';
            this.body += 'Raised Date: ' + paf.ASI_HK_CRM_PAF_Raised_Date__c + '\n\n';
            
            paf.ASI_CRM_HK_No_PO_Sent_Date__c = sentDate;
        }
        
        if (this.body != '')
        {
            this.body = 'Please find below active PAFs with no PO created.\n\n' + this.body;
            update pafContent;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        if (this.body != ''){
            
            List<GroupMember> profiles = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =:MAIL_RECEIVER_PUBLIC_GROUP_LABEL];
            for (GroupMember p : profiles) {
                mailReceiverUserIds.add(p.UserOrGroupId);
            }
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //email.setTargetObjectId(UserInfo.getUserId());
            email.toAddresses = mailReceiverUserIds;
            
            email.setSaveAsActivity(false);
            email.setSenderDisplayName('Salesforce Support');
            email.setSubject('Active PAF with no PO created!');
            
            if (Test.isRunningTest())
            {
                email.setPlainTextBody('Testing');
            }
            else
            {
                email.setPlainTextBody(this.body);
            }
            if(!test.isRunningTest())
            {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
    }
}