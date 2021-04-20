/**
 * Contract Push Service class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public class EUR_ISP_ContractPushData
{
	public EUR_CRM_Contract__c theContract {get; set;}
	public EUR_ISP_Spend__c theSpend {get; set;}
	//for 1 Contact Activity can be created several Spend Activities so we have Map
	public Map<Id, List<EUR_ISP_Spend_Activity__c>> contractActivityIdToSpendActivities {get; set;}
	public List<EUR_ISP_Spend_Item__c> theSpendItems {get; set;}

	public EUR_ISP_ContractPushData(EUR_CRM_Contract__c theContract)
	{
		this.theContract = theContract;
		this.contractActivityIdToSpendActivities = new Map<Id, List<EUR_ISP_Spend_Activity__c>>();
		this.theSpendItems = new List<EUR_ISP_Spend_Item__c>();
	}
}