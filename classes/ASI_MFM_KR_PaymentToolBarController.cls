//test : ASI_MFM_KR_SubmitApprlToolBar_TestClass
public class ASI_MFM_KR_PaymentToolBarController {
    
    public ASI_MFM_Payment__c header              	{set;get;}
    public Id headerId                                          {set;get;}
    public Set<String>  brandGroups                             {set;get;}
    public List<String> brandGroupNames                         {set;get;}
    public Boolean checkAttachNeed                              {set;get;} 
    public Set<String> brandSet;
    public ASI_MFM_KR_PaymentToolBarController (ApexPages.StandardController controller) {
        this.header = (ASI_MFM_Payment__c)controller.getRecord();
        this.headerId = this.header.Id;
        this.brandGroups = new Set<String>();
        this.brandGroupNames = new List<String>();
        this.brandSet = new Set<String>();
        
    }
    
    public void init(){
        
        checkAttachNeed = false;
        header = [Select id , ASI_MFM_Status__c, ASI_MFM_PO__c , Name, ASI_MFM_Need_Attachment__c,	ASI_MFM_Is_Direct_Payment__c, ASI_MFM_Pre_payment__c,ASI_MFM_Venue_Loan_Payment__c, ASI_MFM_Offset_Payment__c  from ASI_MFM_Payment__c where id=: this.headerId];
        checkAttachNeed = header.ASI_MFM_Need_Attachment__c;
        List<Attachment> noOfAttachment = new List<Attachment>();
        noOfAttachment = [Select id from Attachment where parentId =: headerId];
        if(checkAttachNeed  && (noOfAttachment == null || noOfAttachment.size()==0)){
            checkAttachNeed = true;
        } else {
            checkAttachNeed = false;   
        }       
        
    }
    
    
}