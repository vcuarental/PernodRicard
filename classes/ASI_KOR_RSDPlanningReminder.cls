/*********************************************************************************
 * Name: ASI_KOR_RSDPlanningReminder
 * Description: Controller class for ASI_KOR_RSDPlanningReminder
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-07-24       Vincent Lam             Created          
*/
public class ASI_KOR_RSDPlanningReminder{
	
	public Id headerId = ApexPages.currentPage().getParameters().get('id');
	
	public ASI_KOR_RSDPlanningReminder(ApexPages.StandardController controller) {
        
    }
	
	public pageReference remind() {
		
		ASI_KOR_RSD_Proposal_Header__c headerObject = new ASI_KOR_RSD_Proposal_Header__c(
        	id = headerId,
            ASI_KOR_Send_Reminder__c = true
        );
        update headerObject;
		
		return new PageReference('/'+headerId);
	}
	
}