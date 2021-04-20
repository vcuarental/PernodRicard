public with sharing class ASI_MFM_Approval_History_ComController {
    public id InputID {set;get;}
    //public ASI_MFM_Payment__c paymentCurrent{get;set;}
    public List<ProcessInstanceHistory> processInstList {get;set;}
    public List<ASI_ApprHist_LineItem > appHistList {get;set;}
    public ASI_ApprHist_LineItem appHistSubmitter {get;set;}
    public boolean hasHistroy {get;set;}
    public String InputObject {get;set;}
    private String soql {get;set;}
    private final String object_ApiName = 'ASI_MFM_Payment__c';
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_MFM_Approval_History_ComController(){
      

    }
     public ASI_MFM_Approval_History_ComController(ApexPages.StandardController controller) {
     //       this.paymentCurrent = (ASI_MFM_Payment__c)controller.getRecord();
    } 
    public boolean init(){
       
        soql='select Owner.Name,CreatedDate from '+InputObject+' where id = :  InputID'; //paymentCurrent = [select Name, Owner.Name,CreatedDate from ASI_MFM_Payment__c where id = :InputID];
        DateTime CreateTime;
        sObject  MFMObject;
        try {
            MFMObject  = Database.query(soql);
            
            CreateTime=DateTime.valueOf( MFMObject.get('CreatedDate'));
            System.debug(CreateTime+'NowSoQL'+soql+':nOWMFMObject:'+MFMObject);
        } catch (Exception e) {
            CreateTime=Date.today();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records Found, Please Check your search input' + e));
        }
        
        //****** generate approval history - by Tony (start) ******
        ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper ( InputObject, InputID );//  object_ApiName
        
        // Edited by Tony Ren to include submitter and submit date
        appHistSubmitter = new ASI_ApprHist_LineItem();
        if(MFMObject!=null){
            appHistSubmitter.oriActorName= String.valueOf( MFMObject.getSObject('Owner').get('Name') );  //appHistSubmitter.oriActorName=paymentCurrent.Owner.Name;
        }
        appHistSubmitter.CreatedDateString = '';
        if(MFMObject.get('CreatedDate') != null)
            appHistSubmitter.CreatedDateString=CreateTime.format('yyyy/MM/dd HH:mm ', 'Hongkong');
        if (appHistHelper.appHistorySObjList != null) {
            this.processInstList = appHistHelper.appHistorySObjList;
            hasHistroy=true;
            appHistList  = new List<ASI_ApprHist_LineItem >();
            Boolean isExit = false;
            for (ProcessInstanceHistory li : this.processInstList ) {
                //---- check is included in the approval history list ----
                addToApprHistList(li); // Daniel WONG 20121212
            }
            for (ProcessInstanceHistory li : this.processInstList ) {
                if(li.StepStatus == 'Started'){
                    addToSubmitter(li);
                    break;
                }
            }
            if (appHistList.size() <=0)
                hasHistroy=false;
        }
        else
        {
            hasHistroy=false;
        }
         return true; 
    }
    
    private void addToApprHistList(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd HH:mm ');
      
        tempLi.oriActorId =  li.OriginalActor.Id;
        User oriApprover = getApprDetailInfo(li.OriginalActor.Id);
        tempLi.oriActorName =  oriApprover .Name;
        tempLi.oriActorTitle =  oriApprover .Title;
      
        tempLi.actActorId =  li.Actor.Id;
        User actApprover = getApprDetailInfo(li.Actor.Id);
        tempLi.actActorName =  actApprover.Name;
        tempLi.actActorTitle =  actApprover.Title;
        tempLi.actActorDepartment = actApprover.Department;
        if (appHistList.size() <=0)
            appHistList.add(tempLi);
        else
            appHistList.add(0, tempLi);
    }
    
     // Added by Tony Ren 15Sep2014 to include submitter and submit date
    private void addToSubmitter(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd HH:mm ');
      
        tempLi.oriActorId =  li.OriginalActor.Id;
        User oriApprover = getApprDetailInfo(li.OriginalActor.Id);
        tempLi.oriActorName =  oriApprover .Name;
        tempLi.oriActorTitle =  oriApprover .Title;
      
        tempLi.actActorId =  li.Actor.Id;
        User actApprover = getApprDetailInfo(li.Actor.Id);
        tempLi.actActorName =  actApprover.Name;
        tempLi.actActorTitle =  actApprover.Title;
        tempLi.actActorDepartment = actApprover.Department;
        appHistSubmitter = tempLi; 
    }
    
    public class ASI_ApprHist_LineItem {
        public String id { get; set; }
        public String StepStatus{ get; set; }
        public String Comments{ get; set; }
        public DateTime CreatedDate{ get; set; }
        public String CreatedDateString{ get; set; }
        public String oriActorId { get; set; }
        public String oriActorName { get; set; }
        public String oriActorTitle { get; set; }
        public String oriActorDepartment { get; set; }
        public String actActorId { get; set; }
        public String actActorName { get; set; }
        public String actActorTitle { get; set; }
        public String actActorDepartment { get; set; }
        
    }
    
    public static User getApprDetailInfo(String userId) {
        String queryStr = '';
        User appHistoryApprover = new User();
        queryStr = 'select id, name, title, department from user ';
        queryStr += ' where id =\'' +userId+ '\'';  
        appHistoryApprover = Database.query(queryStr);
        return appHistoryApprover ;
    }
}