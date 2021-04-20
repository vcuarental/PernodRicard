public class ASI_eForm_ITCRFEmailController{
    public List<ASI_eForm_IT_Change_Request_Item__c> items;
    public ASI_eForm_IT_Change_Request__c request;
    public List<ApprovalHistory> approvalHistoryList;
    public String itChangeRequestId {get; set;}
    private List<ASI_eForm_ITCRF_Attachment__c> attachments;
    
    public ASI_eForm_ITCRFEmailController(){
    
    } 
    
    public List<ASI_eForm_IT_Change_Request_Item__c> getItems(){
     system.debug('yy id: ' +itChangeRequestId  );
        if(this.items == null && itChangeRequestId != null){
            system.debug('zz id: ' +itChangeRequestId  );
            this.items = [select id, name,ASI_eForm_Context__r.name,ASI_eForm_IT_Handle_By__r.name,
            ASI_eForm_IT_Remarks__c, ASI_eForm_Responsible_By__c,ASI_eForm_External_Email__c from ASI_eForm_IT_Change_Request_Item__c where
                        ASI_eForm_IT_Change_Request__c =: itChangeRequestId ];
        
        }    
        return this.items;
    }
    
    public ASI_eForm_IT_Change_Request__c getRequest(){
        if(this.request == null && itChangeRequestId != null){
            request = [select id, name, CreatedBy.name, owner.name, LastModifiedBy.name,CreatedDate,LastModifiedDate,
             ASI_eForm_Change_Authorizer__r.name ,
             ASI_eForm_Country__c,ASI_eForm_Position__c,ASI_eForm_Department__c,ASI_eForm_Company__c,
             ASI_eForm_Status__c,ASI_eForm_Preview_Approver__r.name,ASI_eForm_High_Level_Authorizer__r.name,
             ASI_eForm_Further_Authorizer__r.name,ASI_eForm_Change_Request_No__c,ASI_eForm_Project_Name__c,
             ASI_eForm_CN_Change_Authorizer__r.Name,
             ASI_eForm_Project_Implementer__r.name,ASI_eForm_Project_Coordinator__r.name,ASI_eForm_Change_Type__c,
             ASI_eForm_Change_Category__c,ASI_eForm_Emergency_Change_Permanent__c,ASI_eForm_Problem_Ticket_No__c,
             ASI_eForm_Date_Needed__c,ASI_eForm_Description__c,ASI_eForm_Reason__c, ASI_eForm_FCost_absorbed_by_IT__c, ASI_eForm_Cost_of_Enhancement__c,
             (Select Id, StepStatus, ActorId,OriginalActorId, Comments, CreatedDate From ProcessSteps order by CreatedDate DESC)
             from ASI_eForm_IT_Change_Request__c          
             where id =: itChangeRequestId];
        }
        
        return this.request;
        
    }
       
    public List<ApprovalHistory> getApprovalHistoryList(){    
        if(this.approvalHistoryList == null && itChangeRequestId != null){
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
    
    public List<ASI_eForm_ITCRF_Attachment__c> getAttachments()
    {
      if (itChangeRequestId != null && attachments == null)
      {
        
        attachments  = [Select id, Name,
        ASI_eForm_Attach_in_Approval_Email__c, 
        ASI_eForm_Category__c,
        ASI_eForm_File_Name__c,
        LastModifiedBy.Name,
        LastModifiedDate,
        ASI_eForm_IT_Change_Request__c,
        SystemModstamp
        from ASI_eForm_ITCRF_Attachment__c 
        where ASI_eForm_Attach_in_Approval_Email__c = true and ASI_eForm_IT_Change_Request__c = :itChangeRequestId];         
       }
     return attachments;   
    }
    /*
    public List<NoteAndAttachment> noteAndAttachments;
    
    public List<NoteAndAttachment> getNoteAndAttachments(){
    
        if(noteAndAttachments == null && itChangeRequestId != null){
            noteAndAttachments = new List<NoteAndAttachment>();
            Set<String> uId = new Set<String>();
            List<Attachment> attachList = [Select Name,ownerid,Description from Attachment Where ParentID =:itChangeRequestId ];
            
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
            List<Note> noteList = [Select Title,ownerid,body from Note Where ParentID =:itChangeRequestId ];
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
   
    public PageReference getPrintScreen(){
        PageReference page = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/aADM00000008OiD/p?retURL=%2FaADM00000008OiD&inline=1' );
        page.setRedirect(true);
        return page;
    }
   
    public String getContent1(){
        PageReference page1 = Page.ASI_eForm_ITCRFPdfTemplate;
        page1.getParameters().put('id','aAIM00000008OW7');
        page1.setRedirect(true);
        String x = page1.getContent().toString();
        
        //x = x.substringAfter('<html class="">');
        //x = x.substringBefore('</html');
       // x = x + '</html>;
       //x = '<table> hello </table>';
        return x;
    }
    */
}