public with sharing class ASI_MFM_SC_MgAll_PaymentController {
    
    public ASI_MFM_Payment__c Payment { get; private set; }
    
    public boolean isReadOnly { get; set; }
    public boolean isFinanceOnlyView { get; set; }
    
    public ASI_MFM_SC_MgAll_PaymentController(ApexPages.StandardSetController controller) {

        id pid = apexpages.currentPage().getParameters().get('id');
        
        this.Payment = [
            SELECT 
            	name, 
            	recordtypeid, 
            	ASI_MFM_Status__c, 
            	ASI_MFM_SC_Supplier_Name__c,
            	ASI_MFM_Currency__c,
            	ASI_MFM_Payment_Type__c,
            	ASI_MFM_Exchange_Rate__c,
            	ASI_MFM_Invoice_Number__c,
            	ASI_MFM_Payment_Amount__c,
            	ASI_MFM_Invoice_Date__c,
            	ASI_MFM_PO__c
            FROM
	            ASI_MFM_Payment__c
            WHERE
            	id = :pid
        ];

        this.isReadOnly = false;
        if(Payment.ASI_MFM_Status__c != 'Draft')
            this.isReadOnly = true;

        if(Payment.ASI_MFM_Status__c == 'Submitted' && getCurrentApprover(pid) == userinfo.getuserid()){
            this.isReadOnly = false;
        }
        
        boolean isFinanceGroup = retrieveFinanceState(new List<string>{'ASI_MFM_SC_Finance','ASI_MFM_HKSC_Approver'});
        this.isFinanceOnlyView = isFinanceGroup;        
    }
    
    private Boolean retrieveFinanceState(List<String> pGroupDevName){
        String userId = UserInfo.getUserId();
        Boolean financeView = false;
           
        for(GroupMember grpM :[Select Id, UserOrGroupId From GroupMember Where GroupId in (Select Id From Group Where DeveloperName in : pGroupDevName)]){
            if(grpM.UserOrGroupId == userId){
                financeView = true;
            }
        }
        
        return financeView;
    }
    
    public id getCurrentApprover(id TargetObjectId){
        try{
        	ProcessInstance processInstance = [
                SELECT (SELECT ID, ActorId FROM StepsAndWorkitems)
                FROM ProcessInstance
                WHERE ProcessInstance.TargetObjectId =: TargetObjectId AND Status = 'Pending'
                Limit 1
            ];
            
	        if(processInstance.StepsAndWorkitems != null){
	            return processInstance.StepsAndWorkitems[0].ActorId;
	        }
        }catch(Exception e){
        	
        }
        
        return null;
    }
}