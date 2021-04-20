public with sharing class ASI_MFM_SG_Payment_PDF_PageController {
    public id paymentID {set;get;}
    public ASI_MFM_Payment__c paymentCurrent{get;set;}
    public List<ASI_MFM_Payment_Line_Item__c> paymentLineList{get;set;}
	public List<ASI_MFM_Payment_Line_Item__c> payeeList{get;set;}
    public List<List<ASI_MFM_Payment_Line_Item__c>> payment{get;set;}
    // a dummy variable to invoke init() method
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public List<ProcessInstance> prosIns{get;set;}
    
    //****** approval history: variables/constants - by Tony Ren(start) ******
    public List<ProcessInstanceHistory> processInstList {get;set;}
    public List<ASI_ApprHist_LineItem > appHistList {get;set;}
    public ASI_ApprHist_LineItem appHistSubmitter {get;set;}
    public boolean hasHistroy {get;set;}
    private final String object_ApiName = 'ASI_MFM_Payment__c';
    //****** approval history: variables/constants - by Tony Ren (end) ******
    
    public ASI_MFM_SG_Payment_PDF_PageController(){
      

    }
     public ASI_MFM_SG_Payment_PDF_PageController(ApexPages.StandardController controller) {
            this.paymentCurrent = (ASI_MFM_Payment__c)controller.getRecord();
    }    
    public boolean init(){
        
        
        //payment
        paymentCurrent = [select Name, Owner.Name, ASI_MFM_Payment_Date__c, ASI_MFM_Currency__c, ASI_MFM_Remarks__c, ASI_MFM_One_Off_Payee__c, ASI_MFM_Supplier_Name__r.Name, ASI_MFM_Payment_Amount__c,CreatedDate from ASI_MFM_Payment__c where id = :paymentID];
        
        // Payment Line 
        paymentLineList =[
            select ASI_MFM_Payee__r.Name, ASI_MFM_Invoice_Number__c, ASI_MFM_Invoice_Date__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.ASI_MFM_Plan__r.Name,
            ASI_MFM_PO_Line_Item__r.ASI_MFM_PO__r.Name, ASI_MFM_Payment_List_Item_Description__c, ASI_MFM_PO_Line_Item__r.ASI_MFM_Sub_brand_Code__r.Name, 
            ASI_MFM_PO_Line_Item__r.ASI_MFM_A_C_Code__r.ASI_MFM_A_C_Code__c, ASI_MFM_Payment_Amount__c,ASI_MFM_Payment_Amount_Distributor__c  from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentID order by ASI_MFM_Payee__c];
        
        payeeList =[
            select ASI_MFM_Payee__r.Name from ASI_MFM_Payment_Line_Item__c where ASI_MFM_Payment__c = :paymentID order by ASI_MFM_Payee__c]; 
        
        Set<String> myset = new Set<String>();
        List<String> result  = new List<String>();
        for (ASI_MFM_Payment_Line_Item__c pe :payeeList){           
            myset.add(pe.ASI_MFM_Payee__r.Name);  
        }   
        result.addAll(myset);
        for (String r: result){
            Double subtotal = 0;
            for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                if (r == p.ASI_MFM_Payee__r.Name){
                    subtotal += p.ASI_MFM_Payment_Amount__c;
                }
            }
            for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                if (r == p.ASI_MFM_Payee__r.Name){
                    p.ASI_MFM_Payment_Amount_Distributor__c = subtotal;
                }
            }
        }
        List<List<ASI_MFM_Payment_Line_Item__c>> tmplist = new List<List<ASI_MFM_Payment_Line_Item__c>>();
        for (String r: result){
            List<ASI_MFM_Payment_Line_Item__c> subList = new List<ASI_MFM_Payment_Line_Item__c>();
            for (ASI_MFM_Payment_Line_Item__c p: paymentLineList) {
                if (r == p.ASI_MFM_Payee__r.Name){
                    subList.add(p);
                }
            }
            tmplist.add(subList);
        }
        payment = tmplist;
        
        //****** generate approval history - by Tony (start) ******
        ASI_MFM_ApprovalHistoryHelper appHistHelper = new ASI_MFM_ApprovalHistoryHelper (object_ApiName , paymentID );
        // Edited by Tony Ren to include submitter and submit date
        appHistSubmitter = new ASI_ApprHist_LineItem();
        appHistSubmitter.oriActorName=paymentCurrent.Owner.Name;
        appHistSubmitter.CreatedDateString = '';
        if(paymentCurrent.CreatedDate != null)
            appHistSubmitter.CreatedDateString=paymentCurrent.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
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
        /// approval history -  End 
        return true;        
    }
    //approval history - Function
    private void addToApprHistList(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
      
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
    
     // Added by Tony Ren to include submitter and submit date
    private void addToSubmitter(ProcessInstanceHistory li)
    {
        ASI_ApprHist_LineItem tempLi = new ASI_ApprHist_LineItem();
        tempLi.id =  li.id;
        tempLi.StepStatus=  li.StepStatus;
        tempLi.Comments=  li.Comments;
        tempLi.CreatedDate=  li.CreatedDate;
        tempLi.CreatedDateString=  li.CreatedDate.format('yyyy/MM/dd HH:mm ', 'Hongkong');
      
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
        System.debug('ahh3' + queryStr);    
        appHistoryApprover = Database.query(queryStr);
        return appHistoryApprover ;
    }
}