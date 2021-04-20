@isTest
public class ASI_CRM_PH_ContractTestUtil {

	public static ASI_TH_CRM_Contract__c getContract() {
		return [
				select Id, Name, ASI_CRM_CN_Outlet_WS__c,
						ASI_CRM_CN_Outlet_WS__r.Name
				from ASI_TH_CRM_Contract__c
				limit 1
		];
	}

	public static List<ASI_CRM_ContractTarget__c> getContractTargets(Id contractId) {
		return [
				select Id, Name, ASI_CRM_Contract__c, ASI_CRM_SKU__c, ASI_CRM_Target_Total_Bottle__c,
						ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__r.Name,
						ASI_CRM_Target_Total_Sales__c, ASI_CRM_Total_Bottle_Rebate__c,
						ASI_CRM_Total_Staff_Incentive__c, ASI_CRM_Target_Incentive__c
				from ASI_CRM_ContractTarget__c
				where ASI_CRM_Contract__c = :contractId
		];
	}

	public static List<ASI_CRM_Payment_Schedule__c> getContractFundSchemes(Id contractId) {

		return [
				select Id, Name, ASI_CRM_Contract__c
				from ASI_CRM_Payment_Schedule__c
				where ASI_CRM_Contract__c = :contractId
				and RecordType.DeveloperName = :ASI_CRM_RecordTypeApiName.ASI_CRM_Payment_Schedule.ASI_CRM_PH_Contract_Fund.name()
		];
	}

	public static List<ASI_CRM_Payment_Schedule__c> gePurchaseIncentiveSchemes(Id contractId) {

		return [
				select Id, Name, ASI_CRM_Contract__c
				from ASI_CRM_Payment_Schedule__c
				where ASI_CRM_Contract__c = :contractId
				and RecordType.DeveloperName = :ASI_CRM_RecordTypeApiName.ASI_CRM_Payment_Schedule.ASI_CRM_PH_Purchase_Incentive.name()
		];
	}
}