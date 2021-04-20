/*********************************************************************************
 * Name: ASI_CRM_SG_SubmitApprovalController
 * Description: 
 * Test Class: ASI_CRM_SG_SubmitApproval_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-11-24       Vincent Lam             Created          
 * 2018-04-24       Wilken Lee              [WL 1.0] CHM117802599 Add mandatory comment before complete        
*/
public class ASI_CRM_SG_SubmitApprovalController {
    public string id;
    public string comment {get; set;}
    
	/*[WL 1.0] BEGIN*/
	public ASI_TH_CRM_Contract__c contract;
	public Boolean isComplete {get; set;}
	/*[WL 1.0] END*/
	
    public ASI_CRM_SG_SubmitApprovalController(){
        id = apexpages.currentpage().getparameters().get('id');
		
		/*[WL 1.0] BEGIN*/
		contract = [SELECT ASI_TH_CRM_Contract_Status__c, ASI_CRM_Requesting_To_Complete__c  FROM ASI_TH_CRM_Contract__c WHERE Id = :id];
		if (contract.ASI_TH_CRM_Contract_Status__c == 'Contract Approved')
			isComplete = true;
		else 
			isComplete = false;
		/*[WL 1.0] END*/
    }
    
    public PageReference submit(){
		/*[WL 1.0] BEGIN*/
		if (isComplete){
			contract.ASI_CRM_Requesting_To_Complete__c = true;
			update contract;
		}
		/*[WL 1.0] END*/
		
        
        if(String.isNotEmpty(id)){
            try {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(id);
                req1.setSubmitterId(UserInfo.getUserId());
                req1.setComments(comment);
                Approval.ProcessResult result = Approval.process(req1);
               
                if (!result.isSuccess()){
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Record failed to submit for approval.');
                    ApexPages.addMessage(myMsg);
                    return null;
                }
            }
            catch (System.DmlException e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getDmlMessage(0));
                System.debug(myMsg);
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
        return new PageReference('/'+id);
    }    
    
    
    public PageReference back(){
        return new PageReference('/'+id);
    }   
}