public class ASI_CRM_CN_Customer_ApprovalCommentCtrl {
    public String PageId {set;get;}
    public List<ASI_CRM_Approval_Comment__c> lstApprovalComment {set;get;}{lstApprovalComment= new List<ASI_CRM_Approval_Comment__c> ();}
    
    public ASI_CRM_CN_Customer_ApprovalCommentCtrl(){}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    
    public ASI_CRM_CN_Customer_ApprovalCommentCtrl(ApexPages.StandardController controller) {
        PageId = ApexPages.currentPage().getParameters().get('id');
        
    }
    
    public boolean init(){
        lstApprovalComment = [SELECT id, recordtypeid,ASI_CRM_Comments__c, ASI_CRM_Customer__c FROM ASI_CRM_Approval_Comment__c  WHERE ASI_CRM_Customer__c =:PageId];  
        
        if(lstApprovalComment==null || lstApprovalComment.size()==0){
            lstApprovalComment.add(new ASI_CRM_Approval_Comment__c());
        }
        return true;   
    }
    
}