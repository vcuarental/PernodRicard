/**
 * Contract Push Service class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public abstract class EUR_ISP_ContractPushAbstract
{
	protected String NO_INVOICING_VALUE = 'No Invoicing';
	protected String PARTY_3D_VALUE = '3rd Party';
	protected String VENDOR_INVOICE_VALUE = 'Vendor Invoice';
	public Map<String, Id> RECORD_TYPES = new Map<String, Id>();

	public EUR_ISP_ContractPushAbstract(Map<String, Id> recordTypes)
	{
		this.RECORD_TYPES = recordTypes;
	}

	/**
	 * genereate new EUR_ISP_Spend__c
	 */
	public virtual void generateSpend(EUR_ISP_ContractPushData contractData)
	{
		contractData.theSpend = new EUR_ISP_Spend__c(
		    EUR_ISP_Contract__c = contractData.theContract.Id,
		    EUR_ISP_Start_Date__c = contractData.theContract.EUR_CRM_Start_Date__c,
		    EUR_ISP_End_Date__c = contractData.theContract.EUR_CRM_End_Date__c,
		    EUR_ISP_Account__c = contractData.theContract.EUR_CRM_Account__c,
		    CurrencyIsoCode = contractData.theContract.CurrencyIsoCode,
		    OwnerId = contractData.theContract.EUR_CRM_Budget__c != null ? contractData.theContract.EUR_CRM_Budget__r.OwnerId : UserInfo.getUserId(),
		    EUR_ISP_Amount__c = contractData.theContract.EUR_CRM_DE_Actual_Contract_Total__c,
		    EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS,
		    EUR_ISP_Phasing_Method__c = 'Pro Rata',
		    EUR_ISP_Allocation_Method__c = 'Standard',
		    EUR_ISP_Funding_Based__c = 'Other',
		    EUR_ISP_Status__c = EUR_ISP_Utils.COMMITTED_STATUS,
		    RecordTypeId = this.RECORD_TYPES.get(EUR_ISP_Utils.EUR_ISP_SPEND_API_NAME)
		);
	}

	/**
	 * genereate new EUR_ISP_Spend_Activity__c
	 */
	public virtual void generateSpendActivity(EUR_ISP_ContractPushData contractData, EUR_CRM_Contract_Activity_Item__c theActivity, Id typeId)
	{
		EUR_ISP_Spend_Activity__c theSpendActivity = this.generateSpendActivityFromContractActivity(theActivity, contractData.theSpend.Id, typeId);
		if (theActivity.EUR_CRM_Payment_Term__c != NO_INVOICING_VALUE && theActivity.EUR_CRM_Payment_Term__c != PARTY_3D_VALUE)
		{
			theSpendActivity.EUR_ISP_Settlement_Method__c = VENDOR_INVOICE_VALUE;
		}

		if (!contractData.contractActivityIdToSpendActivities.containsKey(theActivity.Id))
		{
			contractData.contractActivityIdToSpendActivities.put(theActivity.Id, new List<EUR_ISP_Spend_Activity__c>());
		}
		contractData.contractActivityIdToSpendActivities.get(theActivity.Id).add(theSpendActivity);
	}

	/**
	 * genereate new EUR_ISP_Spend_Activity__c from EUR_CRM_Contract_Activity_Item__c
	 */
	protected EUR_ISP_Spend_Activity__c generateSpendActivityFromContractActivity(EUR_CRM_Contract_Activity_Item__c theActivity, Id spendId, Id typeId)
	{
		return new EUR_ISP_Spend_Activity__c(
		           EUR_ISP_Spend__c = spendId,
		           EUR_ISP_Spend_Activity_Type__c = typeId,
		           EUR_ISP_Activity_Amount__c = theActivity.EUR_CRM_Amount__c,
		           EUR_ISP_Activity_End_Date__c = theActivity.EUR_CRM_End_Date__c,
		           EUR_ISP_Activity_Start_Date__c = theActivity.EUR_CRM_Start_Date__c,
		           EUR_ISP_Payment_Terms__c = theActivity.EUR_CRM_Payment_Term__c,
		           EUR_ISP_Description__c = theActivity.EUR_CRM_Vendor__c,
		           CurrencyIsoCode = theActivity.CurrencyIsoCode,
		           EUR_ISP_Approval_Status__c = EUR_ISP_Utils.APPROVED_APPROVAL_STATUS,
		           EUR_ISP_Status__c = EUR_ISP_Utils.COMMITTED_STATUS,
		           RecordTypeId = RECORD_TYPES.get(EUR_ISP_Utils.EUR_ISP_SPEND_ACTIVITY_API_NAME)
		       );
	}

	/**
	 * genereate new EUR_ISP_Spend_Item__c
	 */
	public virtual void generateSpendItem(EUR_ISP_ContractPushData contractData, EUR_CRM_Contract_Product_Item__c theContractItem, Id contactActivityId)
	{
		// note: for each Contract Activity can be generated more than 1 Spend Activity
		List<EUR_ISP_Spend_Activity__c> theSpendActivities = contractData.contractActivityIdToSpendActivities.get(contactActivityId);
		if (theSpendActivities != null)
		{
			// now for each Spend Activity need to generate Spend Items
			for (EUR_ISP_Spend_Activity__c theSpendActivity : theSpendActivities)
			{
				if (theSpendActivity.Id == null)
				{
					continue;
				}

				EUR_ISP_Spend_Item__c theSpendItem = this.generateSpendItemFromContractProduct(theContractItem, theSpendActivity.Id);
				contractData.theSpendItems.add(theSpendItem);
			}
		}
	}

	/**
	 * genereate new EUR_ISP_Spend_Item__c from EUR_CRM_Contract_Product_Item__c
	 */
	protected EUR_ISP_Spend_Item__c generateSpendItemFromContractProduct(EUR_CRM_Contract_Product_Item__c theContractItem, Id spendActivityId)
	{
		return new EUR_ISP_Spend_Item__c(
		           EUR_ISP_Spend_Activity__c = spendActivityId,
		           EUR_ISP_Brand__c = theContractItem.EUR_CRM_Brand__c,
		           EUR_ISP_Brand_Quality__c = theContractItem.EUR_CRM_Brand_Quality__c,
		           EUR_ISP_Brand_Quality_Size__c = theContractItem.EUR_CRM_Brand_Quality_Size__c,
		           EUR_ISP_SKU_EU__c = theContractItem.EUR_CRM_SKU__c,
		           EUR_ISP_Per_Unit_Amount__c = theContractItem.EUR_CRM_Amount__c,
		           EUR_ISP_Unit_Of_Measure__c = theContractItem.EUR_CRM_Unit__c,
		           EUR_ISP_Volume__c = theContractItem.EUR_CRM_Quantity__c
		       );
	}
}