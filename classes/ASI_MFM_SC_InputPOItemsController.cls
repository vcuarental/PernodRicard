public with sharing class ASI_MFM_SC_InputPOItemsController {
    public ASI_MFM_PO__c PO {get; private set;}
    public boolean isReadOnly {get;set;}
    
    public ASI_MFM_SC_InputPOItemsController(apexpages.standardSetController sc) {
        id pid = apexpages.currentPage().getParameters().get('id');
        PO = database.query(ASI_MFM_function.buildQuery('ASI_MFM_PO__c', 'ASI_MFM_Supplier_Name__r.ASI_MFM_Customer_Supplier_Number__c, ASI_MFM_Supplier_Name__r.name, ASI_MFM_Plan__r.ASI_MFM_Plan_Description__c, ASI_MFM_Plan__r.ownerId,ASI_MFM_Plan__r.ASI_MFM_Plan_Amount__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Balance__c') + ' where id = :pid');
        this.isReadOnly = false;
        if(PO.ASI_MFM_Status__c != 'Draft')
            this.isReadOnly = true;

        if(PO.ASI_MFM_Status__c == 'Submitted' && getCurrentApprover(pid) == userinfo.getuserid()){
            this.isReadOnly = false;
        }
    }

    public id getCurrentApprover(id TargetObjectId){
    	try{
	        ProcessInstance pi = [  SELECT CompletedDate, CreatedById, CreatedDate,Id,IsDeleted,LastActorId,
	                                LastModifiedById,LastModifiedDate,ProcessDefinitionId,Status,SubmittedById
	                                ,SystemModstamp,TargetObjectId, (SELECT ID, ProcessNodeId, StepStatus,
	                                Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending,
	                                OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate
	                                FROM StepsAndWorkitems ) FROM ProcessInstance
	                                where ProcessInstance.TargetObjectId =: TargetObjectId
	                                AND Status = 'Pending' Limit 1];
	        if(pi.StepsAndWorkitems != null){
	            return pi.StepsAndWorkitems[0].ActorId;
	        }
        }catch(Exception e){
        	
        }
        return null;
    }
}