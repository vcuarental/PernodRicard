public class ASI_MFM_PO_ApprHist_PDF_PageController {
    public List<ProcessInstanceHistory> processInstList {get;set;}
    public List<ASI_HK_ApprHist_LineItem > appHistList {get;set;}
    public boolean hasHistroy {get;set;}
    private final ASI_MFM_PO__c PO;
    private final String object_ApiName = 'ASI_MFM_PO__c';
   
    
    public ASI_MFM_PO_ApprHist_PDF_PageController(ApexPages.StandardController stdController){
        
        this.PO = (ASI_MFM_PO__c)stdController.getRecord();
        
        ASI_ApprovalHistoryHelper appHistHelper = new ASI_ApprovalHistoryHelper (object_ApiName , PO.Id );
        if (appHistHelper.appHistorySObjList != null){
            this.processInstList = appHistHelper.appHistorySObjList;
            hasHistroy=true;
            appHistList  = new List<ASI_HK_ApprHist_LineItem >();
             for (ProcessInstanceHistory li : this.processInstList ) {
                  ASI_HK_ApprHist_LineItem tempLi = new ASI_HK_ApprHist_LineItem();
                  tempLi.id =  li.id;
                  tempLi.StepStatus=  li.StepStatus;
                  tempLi.Comments=  li.Comments;
                  tempLi.CreatedDate=  li.CreatedDate;
                  tempLi.CreatedDateString=  li.CreatedDate.format('yyyy-MM-dd HH:mm:ss', 'Hongkong');
                  
                  tempLi.oriActorId =  li.OriginalActor.Id;
                  User oriApprover = getApprDetailInfo(li.OriginalActor.Id);
                  tempLi.oriActorName =  oriApprover .Name;
                  tempLi.oriActorTitle =  oriApprover .Title;
                  
                  tempLi.actActorId =  li.Actor.Id;
                  User actApprover = getApprDetailInfo(li.Actor.Id);
                  tempLi.actActorName =  actApprover.Name;
                  tempLi.actActorTitle =  actApprover.Title;
                  tempLi.actActorDepartment = actApprover.Department;
                  appHistList.add(tempLi);
             }
             if (appHistList.size() <=0)
              hasHistroy=false;
        }
        else
        {
            hasHistroy=false;
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'my error msg');
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'No Approval History in this record'));
        }
    }
    public static User getApprDetailInfo(String userId){
        String queryStr = '';
        User appHistoryApprover = new User();
        queryStr = 'select id, name, title, department from user ';
        queryStr += ' where id =\'' +userId+ '\'';
        System.debug('ahh3' + queryStr);    
        appHistoryApprover = Database.query(queryStr);
        return appHistoryApprover ;
     }
    public class ASI_HK_ApprHist_LineItem {
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
}