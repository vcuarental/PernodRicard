public class ASI_eForm_ITSRFEmailController{
    public List<ASI_eForm_IT_Procurement_Service_Item__c> items;
    public ASI_eForm_IT_Procurement_Service_Request__c request;
    public List<ApprovalHistory> approvalHistoryList;
    public String request_Id{get; set;}
    private List<ASI_eForm_ITPSR_Attachment__c> attachments;
    
    public ASI_eForm_ITSRFEmailController(){
    
    } 
    
    public List<ASI_eForm_IT_Procurement_Service_Item__c> getItems(){
     system.debug('yy id: ' +request_Id);
        if(this.items == null && request_Id != null){
            system.debug('zz id: ' +request_Id);
            this.items = [select id, name,ASI_eForm_ITSRF_Category__c,ASI_eForm_Specification__c,
            ASI_eForm_Request_Date__c,ASI_eForm_Item__c,ASI_eForm_Duration__c,ASI_eForm_Quantity__c,
            ASI_eForm_Unit_Price__c,
            ASI_eForm_Delivery_Location__c,
            ASI_eForm_Total_Amount__c,
            ASI_eForm_HASRF_Category__c
            from ASI_eForm_IT_Procurement_Service_Item__c 
            where ASI_eForm_IT_Procurement_Service_Request__c =: request_Id ];
        
        }    
        return this.items;
    }
    
 public List<ASI_eForm_ITPSR_Attachment__c> getAttachments()
 {
   if (request_Id != null && attachments == null)
   {
    /*
    Map<Id,ASI_eForm_ITPSR_Attachment__c> attachmentDocIds = new Map<Id,ASI_eForm_ITPSR_Attachment__c>([Select id, 
    ASI_eForm_IT_Procurement_Service_Request__c
    from ASI_eForm_ITPSR_Attachment__c 
    where ASI_eForm_Attach_in_Approval_Email__c = true and ASI_eForm_IT_Procurement_Service_Request__c = :request_Id ]);                             
    */    
    attachments  = [Select id, Name,
    ASI_eForm_Attach_in_Approval_Email__c, 
    ASI_eForm_Category__c,
    ASI_eForm_File_Name__c,
    LastModifiedBy.Name,
    LastModifiedDate,
    ASI_eForm_IT_Procurement_Service_Request__c,
    SystemModstamp
    from ASI_eForm_ITPSR_Attachment__c 
    where ASI_eForm_Attach_in_Approval_Email__c = true and ASI_eForm_IT_Procurement_Service_Request__c = :request_Id];
    /*
    [SELECT Id, Type, ParentId, ContentFileName, 
    ContentType From ASI_eForm_Attachment__Feed where Type = 'ContentPost' and ParentId IN :attachmentDocIds.keySet() and id != null];           
   */ 
   }
    return attachments;   
 }
    
    public ASI_eForm_IT_Procurement_Service_Request__c getRequest(){
        if(this.request == null && request_Id != null){
            request = [select id, name, CreatedBy.name, owner.name, LastModifiedBy.name,recordtype.name,CreatedDate,LastModifiedDate,
                ASI_eForm_Approver__r.name,ASI_eForm_CIO__r.name,ASI_eForm_Company__c ,ASI_eForm_Country__c,
                ASI_eForm_Department__c,ASI_eForm_Finance_Director__r.name,ASI_eForm_IT_Action__c,ASI_eForm_Position__c,
                ASI_eForm_Preferred_Vendor__c,ASI_eForm_Preview_Approver__r.name,ASI_eForm_Reason_of_Requisition__c,
                ASI_eForm_Requirements__c, ASI_eForm_Status__c,
             (Select Id, StepStatus, ActorId,OriginalActorId, Comments, CreatedDate From ProcessSteps order by CreatedDate DESC)
             from ASI_eForm_IT_Procurement_Service_Request__c 
             where id =: request_Id];
        }
        
        return this.request;
        
    }
    
    
    public List<ApprovalHistory> getApprovalHistoryList(){    
        if(this.approvalHistoryList == null && request_Id != null){
            approvalHistoryList = new List<ApprovalHistory>();
            Set<String> uId = new Set<String>();
            List<SoBject> tempList = getRequest().ProcessSteps;
            if(tempList != null && tempList.size() > 0){
                for(SObject o : tempList){
                    ProcessInstanceHistory p = (ProcessInstanceHistory) o;
                    ApprovalHistory history = new ApprovalHistory();
                    history.cDate = p.createdDate.format('MM/dd/yyyy hh:mm a');
                    history.status = p.StepStatus;
                    history.assignedTo= p.OriginalActorId;
                    history.actualApprover = p.ActorId;
                    history.comments = p.comments ;
                    uId.add(p.OriginalActorId);
                    uId.add(p.ActorId);
                    approvalHistoryList.add(history);
                }
                Map<Id,User> uMap = new Map<Id,User>([select id, name from User where id in: uId]);
                for(ApprovalHistory history : approvalHistoryList ){
                     history.assignedTo= (uMap.get(history.assignedTo)).name;
                     history.actualApprover = (uMap.get(history.actualApprover )).name;
                }
            }
        }
        return approvalHistoryList;
    }
    public class ApprovalHistory{
        public String status {get;set;}        
        public String assignedTo{get;set;}
        public String actualApprover {get;set;}
        public String comments {get;set;}
        public String cDate {get;set;}
    
    }
 /*
    public List<NoteAndAttachment> noteAndAttachments;
    
    public List<NoteAndAttachment> getNoteAndAttachments(){
    
        if(noteAndAttachments == null && request_Id!= null){
            noteAndAttachments = new List<NoteAndAttachment>();
            Set<String> uId = new Set<String>();
            List<Attachment> attachList = [Select Name,ownerid,Description from Attachment Where ParentID =:request_Id];
            
            if(attachList != null && attachList.size() > 0)
                for(Attachment a : attachList){
                    NoteAndAttachment temp = new NoteAndAttachment();
                    temp.type = 'Attachment';
                    temp.lastmodifiedby = a.ownerid;
                    temp.description = a.Description;
                    temp.filename = a.name;
                    uId.add(a.ownerid);
                    noteAndAttachments.add(temp);
                }
            List<Note> noteList = [Select Title,ownerid,body from Note Where ParentID =:request_Id];
            if(noteList != null && noteList.size() > 0)
                for(Note a : noteList ){
                    NoteAndAttachment temp = new NoteAndAttachment();
                    temp.type = 'Note';
                    temp.lastmodifiedby = a.ownerid;
                    temp.description = a.body;
                    temp.filename = a.Title;
                    uId.add(a.ownerid);
                    noteAndAttachments.add(temp);
                }            
            Map<Id,User> uMap = new Map<Id,User>([select id, name from User where id in: uId]);
            for(NoteAndAttachment temp: noteAndAttachments){
                     temp.lastmodifiedby =  (uMap.get(temp.lastmodifiedby)).name;
                   
            }       
        }
        return noteAndAttachments;
    }
    public class NoteAndAttachment{
        public String filename {get; set;}
        public String lastmodifiedby {get; set;}
        public String description {get; set;}
        public String type {get; set;} 
    }
 */    
}