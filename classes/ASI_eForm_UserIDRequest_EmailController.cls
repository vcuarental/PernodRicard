public class ASI_eForm_UserIDRequest_EmailController{
    public List<ASI_eForm_User_ID_Request_Item__c> items;
    public ASI_eForm_User_ID_Request__c request;
    public List<ApprovalHistory> approvalHistoryList;
    public String request_Id {get; set;}
    
    public ASI_eForm_UserIDRequest_EmailController(){
    
    } 
    
    public List<ASI_eForm_User_ID_Request_Item__c> getItems(){
        if(this.items == null && request_Id != null){
            this.items = [select id, name,
                 ASI_eForm_IT_Handle_By__r.name,
                 ASI_eForm_IT_Action__c,
                 ASI_eForm_Permission_Action__c,
                 ASI_eForm_Permission_TypeN__r.Name,
                 ASI_eForm_BO_Additional_Remarks__c,
                 ASI_eForm_PR_System__c,
                 ASI_eForm_PR_System__r.name,
                 ASI_eForm_Remarks__c                 
                 from ASI_eForm_User_ID_Request_Item__c where
                        ASI_eForm_User_ID_Request__c =: request_Id ];
        
        }    
        return this.items;
    }
    
    public ASI_eForm_User_ID_Request__c getRequest(){
        if(this.request == null && request_Id != null){
            request = [select id, name, CreatedBy.name,CreatedDate,LastModifiedDate, owner.name, LastModifiedBy.name,
             RecordType.name,
             RecordType.developername,
             ASI_eForm_Company__c,
             ASI_eForm_Department__c,
             ASI_eForm_Country__c,
             ASI_eForm_Effective_Date__c,
             ASI_eForm_HR_Business_Department_Manager__r.name,
             ASI_eForm_IT_Action__c,
             ASI_eForm_Last_Name__c,
             ASI_eForm_Line_Manager__r.name,
             ASI_eForm_Position__c,
             ASI_eForm_PR_Email__c,
             ASI_eForm_Preview_Approver__r.name,
             ASI_eForm_Reason__c,
             ASI_eForm_Service_Account__c,
             ASI_eForm_First_Name__c,
             ASI_eForm_Service_Period_From__c,
             ASI_eForm_Service_Period_To__c,
             ASI_eForm_Special_Requirement__c,
             ASI_eForm_Status__c,
             ASI_eForm_User_Alias__c,
             ASI_eForm_User_Company__c,
             ASI_eForm_User_Country__c ,
             ASI_eForm_User_Department__c,
             ASI_eForm_User_Position__c,
             ASI_eForm_Sys_User_Permission_Applied__c,
             ASI_eForm_User_Profile_Name__r.name,
             (Select Id, StepStatus, ActorId,OriginalActorId, Comments, CreatedDate From ProcessSteps order by CreatedDate DESC)
             from ASI_eForm_User_ID_Request__c          
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
}