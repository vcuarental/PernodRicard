/*********************************************************************************
 * Name: ASI_KOR_BMPaymentReminder
 * Description: Controller class for ASI_KOR_BMPaymentReminder
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-07-24       Vincent Lam             Created          
*/
public class ASI_KOR_BMPaymentReminder{
	
	public Id headerId = ApexPages.currentPage().getParameters().get('id');
	
	public ASI_KOR_BMPaymentReminder(ApexPages.StandardController controller) {
        
    }
	
	public pageReference remind() {
		
		ASI_KOR_BM_Payment_Settlement_Header__c headerObject = new ASI_KOR_BM_Payment_Settlement_Header__c(
        	id = headerId,
            ASI_KOR_Send_Reminder__c = true
        );
        update headerObject;
		
		return new PageReference('/'+headerId);
	}
	
}