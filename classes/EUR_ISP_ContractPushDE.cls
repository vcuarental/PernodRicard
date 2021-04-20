/**
 * Contract Push Service class for iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public class EUR_ISP_ContractPushDE extends EUR_ISP_ContractPushAbstract
{
	private Map<Id, EUR_CRM_Contract_Activity_Item__c> theContractActivitiesMap = new Map<Id, EUR_CRM_Contract_Activity_Item__c>();
	private Map<String, EUR_ISP_Spend_Activity__c> contractActivityPeriodToSpendActivity = new Map<String, EUR_ISP_Spend_Activity__c>();
	private Map<String, String> PAYMENT_TERMS_MAPPING = new Map<String, String>
	{
		'Nach Umsetzung' => 'After implementation',
		'Nach Vertragsabschluss (einmalig)' => 'Beginning of contract',
		'Zu Beginn der Vertragsposition' => 'Beginning of Contract item period',
		'Halbjährlich nach Leistungserfüllung' => 'Half-Yearly After Implementation',
		'Keine Abrechnung' => 'No Invoicing',
		'Jährlich nach Leistungserfüllung' => 'Yearly after implementation',
		'Abrechnung durch Dritte' => '3rd party invoicing'
	};

	public static final Set<String> MECH_TYPES_NO_NEED_TO_CREATE_CPPP = new Set<String> {
			'EUR_DE_Listing'
		,	'EUR_DE_House_Pouring'
	};

	/**
	 * see @EUR_CRM_ContractPaymentPlanPeriodHandler.cls to get correct values.
	 */
	public EUR_ISP_ContractPushDE(Map<String, Id> recordTypes)
	{
		super(recordTypes);
		this.theContractActivitiesMap.clear();
		this.contractActivityPeriodToSpendActivity.clear();
	}

	/**
	 * genereate new EUR_ISP_Spend_Activity__c
	 */
	public override void generateSpendActivity(EUR_ISP_ContractPushData contractData, EUR_CRM_Contract_Activity_Item__c theActivity, Id typeId)
	{
		if (theActivity.Contract_Payment_Plan_Periods__r.isEmpty() && ( ! MECH_TYPES_NO_NEED_TO_CREATE_CPPP.contains(theActivity.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c)))
		{
			EUR_ISP_LogService.addError('Contract Payment Plan Period can not be found for Contract Activity Item Record',
			                            'EUR_ISP_ContractPushService:generateSpendActivity', theActivity.Id);
			return;
		}

		Id spendId = contractData.theSpend.Id;

		for (EUR_CRM_Contract_Payment_Plan_Period__c activityPlanPeriod : theActivity.Contract_Payment_Plan_Periods__r)
		{
			String periodKey = this.getPlanPeriodKey(theActivity.Id, activityPlanPeriod.EUR_CRM_Payment_Period_Start_Date__c);
			// prevent the Spend Activity duplication. we already have the same Activity for this period
			// if payment terms = no invoicing => skip activity creation
			// i hate the contract builder page!
			String paymentTermsValue = activityPlanPeriod.EUR_CRM_CPPP_Payment_Term__c;
			if (String.isNotBlank(paymentTermsValue) && PAYMENT_TERMS_MAPPING.containsKey(paymentTermsValue))
			{
				paymentTermsValue = PAYMENT_TERMS_MAPPING.get(paymentTermsValue);
			}
			if (this.contractActivityPeriodToSpendActivity.containsKey(periodKey) || NO_INVOICING_VALUE.equalsIgnoreCase(paymentTermsValue))
			{
				continue;
			}

			EUR_ISP_Spend_Activity__c theSpendActivity = this.generateSpendActivityFromContractActivity(theActivity, spendId, typeId);
			theSpendActivity.EUR_ISP_Activity_Amount__c = activityPlanPeriod.EUR_CRM_Contract_Product_Item__c == null ? activityPlanPeriod.EUR_CRM_CPPP_Amount__c : null;
			theSpendActivity.EUR_ISP_Activity_End_Date__c = activityPlanPeriod.EUR_CRM_Payment_Period_End_Date__c;
			theSpendActivity.EUR_ISP_Activity_Start_Date__c = activityPlanPeriod.EUR_CRM_Payment_Period_Start_Date__c;
			theSpendActivity.EUR_ISP_Payment_Terms__c = paymentTermsValue;
			this.contractActivityPeriodToSpendActivity.put(periodKey, theSpendActivity);

			if (!this.theContractActivitiesMap.containsKey(theActivity.Id))
			{
				this.theContractActivitiesMap.put(theActivity.Id, theActivity);
			}

			if (!contractData.contractActivityIdToSpendActivities.containsKey(theActivity.Id))
			{
				contractData.contractActivityIdToSpendActivities.put(theActivity.Id, new List<EUR_ISP_Spend_Activity__c>());
			}
			contractData.contractActivityIdToSpendActivities.get(theActivity.Id).add(theSpendActivity);
		}
	}

	/**
	 * genereate new EUR_ISP_Spend_Item__c
	 * For pouring activity we have 1 Activity for N products divided to N periods.
	 * 1 activity
	 * 		period 1
	 * 			prod 1
	 * 			prod 2
	 * 		period 2
	 * 			prod 1
	 * 			prod 2
	 * 	For all other activities the old functionality
	 */
	public override void generateSpendItem(EUR_ISP_ContractPushData contractData, EUR_CRM_Contract_Product_Item__c theContractItem, Id contactActivityId)
	{

		System.debug('\n theContractActivitiesMap.size() => ' + theContractActivitiesMap.size() + '\n');
		System.debug('\n theContractActivitiesMap => ' + JSON.serializePretty(theContractActivitiesMap) + '\n');
		// note: for each Contract Activity can be generated more than 1 Spend Activity
		if (!this.theContractActivitiesMap.containsKey(contactActivityId))
		{
			return;
		}

		EUR_CRM_Contract_Activity_Item__c theActivity = this.theContractActivitiesMap.get(contactActivityId);
		for (EUR_CRM_Contract_Payment_Plan_Period__c activityPlanPeriod : theActivity.Contract_Payment_Plan_Periods__r)
		{
			String periodKey = this.getPlanPeriodKey(theActivity.Id, activityPlanPeriod.EUR_CRM_Payment_Period_Start_Date__c);
			// now for each Spend Activity need to generate Spend Items
			EUR_ISP_Spend_Activity__c theSpendActivity = this.contractActivityPeriodToSpendActivity.get(periodKey);
			if (theSpendActivity == null || theSpendActivity.Id == null)
			{
				continue;
			}

			// if we don't have correct Payment period for this records => use base mapping?
			if (theContractItem.Contract_Payment_Plan_Periods_EU__r.isEmpty())
			{
				EUR_ISP_Spend_Item__c theSpendItem = this.generateSpendItemFromContractProduct(theContractItem, theSpendActivity.Id);
				contractData.theSpendItems.add(theSpendItem);
				continue;
			}

			// skip period for another Item than incoming theContractItem
			if (activityPlanPeriod.EUR_CRM_Contract_Product_Item__c != theContractItem.Id)
			{
				continue;
			}

			// find out correct Payment Plan Period
			for (EUR_CRM_Contract_Payment_Plan_Period__c productPlanPeriod : theContractItem.Contract_Payment_Plan_Periods_EU__r)
			{
				String productKey = this.getPlanPeriodKey(theActivity.Id, productPlanPeriod.EUR_CRM_Payment_Period_Start_Date__c);
				if (productKey.equalsIgnoreCase(periodKey))
				{
					EUR_ISP_Spend_Item__c theSpendItem = this.generateSpendItemFromContractProduct(theContractItem, theSpendActivity.Id);
					if (theActivity.EUR_CRM_Payment_Term__c != NO_INVOICING_VALUE && theActivity.EUR_CRM_Payment_Term__c != PARTY_3D_VALUE)
					{
						theSpendActivity.EUR_ISP_Settlement_Method__c = VENDOR_INVOICE_VALUE;
					}
					theSpendItem.EUR_ISP_Per_Unit_Amount__c = productPlanPeriod.EUR_CRM_CPPP_Rate__c;
					theSpendItem.EUR_ISP_Volume__c = productPlanPeriod.EUR_CRM_CPPP_Volume__c;
					contractData.theSpendItems.add(theSpendItem);
				}
			}
		}
	}

	private String getPlanPeriodKey(Id theActivityId, Date startDate)
	{
		return theActivityId + (startDate != null ? String.valueOf(startDate) : '');
	}
}