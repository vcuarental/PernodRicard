public class ASI_CRM_JP_DataService {

	public static User getUserById(Id userId) {
		return [
				SELECT Id, Name, ASI_MFM_CN_Staff_No__c
				FROM User
				WHERE Id = :userId
		];
	}

	public static Id getReportIdByApiName(String reportApiName) {
        system.debug('----reportname ---'+reportApiName);
        
		final Report purchaseContractLineItemSearchReport = [
				SELECT Id, DeveloperName
				FROM Report
				WHERE DeveloperName = :reportApiName
				LIMIT 1
		];

		if (purchaseContractLineItemSearchReport == null) return null;

		return purchaseContractLineItemSearchReport.Id;
	}

	public static List<ASI_CRM_Purchase_Contract_Line_Item__c> getPurchaseContractLineItemsByName(
			Set<String> purchaseContractLineItemNames) {
		return [
				SELECT Id, Name
				FROM ASI_CRM_Purchase_Contract_Line_Item__c
				WHERE Name IN :purchaseContractLineItemNames
		];
	}

	public static List<ASI_CRM_Purchase_Contract__c> getPurchaseContractsByName(Set<String> purchaseContractNames) {
		return [
				SELECT Id, Name, RecordTypeId, RecordType.DeveloperName
				FROM ASI_CRM_Purchase_Contract__c
				WHERE Name IN :purchaseContractNames
		];
	}

	public static Set<Id> getPurchaseContractIdsByItemIds(Set<Id> purchaseContractLineItemIds) {

		final Set<Id> purchaseContractIds = new Set<Id>();
		for (
				ASI_CRM_Purchase_Contract_Line_Item__c purchaseContractLineItem
				:
		[
				SELECT Id, ASI_CRM_Purchase_Contract__c
				FROM ASI_CRM_Purchase_Contract_Line_Item__c
				WHERE Id IN :purchaseContractLineItemIds
		]) {
			purchaseContractIds.add(purchaseContractLineItem.ASI_CRM_Purchase_Contract__c);
		}

		return purchaseContractIds;
	}

	public static List<ASI_CRM_Pay_To__c> getPayTosByNameOrNumber(Set<String> payToNamesOrNumbers) {
		return [
				SELECT Id, Name, ASI_CRM_Pay_to_No__c
				FROM ASI_CRM_Pay_To__c
				WHERE (Name IN :payToNamesOrNumbers OR ASI_CRM_Pay_to_No__c IN :payToNamesOrNumbers)
		];
	}

	public static List< ASI_MFM_Item_Group__c> getItemGroupsByNameOrCode(Set<String> itemGroupNamesOrCodes) {
		return [
				SELECT Id, Name, ASI_MFM_Item_Group_Code__c
				FROM ASI_MFM_Item_Group__c
				WHERE (Name IN :itemGroupNamesOrCodes OR ASI_MFM_Item_Group_Code__c IN :itemGroupNamesOrCodes)
				AND RecordType.DeveloperName = 'ASI_CRM_JP_Item_Group'
		];
	}

	public static ASI_MFM_Item_Group__c getItemGroupById(Id itemGroupId) {
		return [
				SELECT Id, Name
				FROM ASI_MFM_Item_Group__c
				WHERE Id = :itemGroupId
		];
	}

	public static ASI_CRM_AccountsAdditionalField__c getRetailerById(Id retailerId) {
		return [
				SELECT Id, Name
				FROM ASI_CRM_AccountsAdditionalField__c
				WHERE Id = :retailerId
		];
	}

	public static ASI_CRM_Purchase_Contract_Line_Item__c getPurchaseContractLineItemById(
			Id purchaseContractLineItemId) {
		return [
				SELECT Id, Name,
						ASI_CRM_Rebate_Type__c, ASI_CRM_Remaining_Balance__c, ASI_CRM_Quantity__c,
						ASI_CRM_Purchase_Contract__c, ASI_CRM_Target_Volume__c, ASI_CRM_Unit_Price__c,
						ASI_CRM_BS_Retailer_Ship_To__c, ASI_CRM_Outlet__c, ASI_CRM_Item_Group__r.Name,
						ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c, ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c,
						ASI_CRM_Sys_AP_Code__c
				FROM ASI_CRM_Purchase_Contract_Line_Item__c
				WHERE Id = :purchaseContractLineItemId
		];
	}

	public static List<ASI_CRM_Purchase_Contract_Line_Item__c> getPurchaseContractLineItemByIds(
			List<Id> purchaseContractLineItemIds) {
		return [
				SELECT Id, Name,
						ASI_CRM_Rebate_Type__c, ASI_CRM_Remaining_Balance__c, ASI_CRM_Quantity__c,
						ASI_CRM_Purchase_Contract__c, ASI_CRM_Target_Volume__c, ASI_CRM_Unit_Price__c,
						ASI_CRM_BS_Retailer_Ship_To__c, ASI_CRM_Outlet__c, ASI_CRM_Item_Group__r.Name,
						ASI_CRM_Item_Group__r.ASI_CRM_Representative_SKU__c, ASI_CRM_Item_Group__r.ASI_CRM_Alternative_SKU__c,
						ASI_CRM_Sys_AP_Code__c
				FROM ASI_CRM_Purchase_Contract_Line_Item__c
				WHERE Id in :purchaseContractLineItemIds
		];
	}

	public static Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c> getIdPurchaseContractLIneItemMap(
			List<Id> purchaseContractLineItemIds
			) {
		final Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c> idPurchaseContractLIneItemMap =
				new Map<Id, ASI_CRM_Purchase_Contract_Line_Item__c>();

		for (
				ASI_CRM_Purchase_Contract_Line_Item__c item
				:
		getPurchaseContractLineItemByIds(purchaseContractLineItemIds)
		) {
			idPurchaseContractLIneItemMap.put(item.Id, item);
		}
		return idPurchaseContractLIneItemMap;
	}

	public static ASI_CRM_Payment_Invoice__c getPaymentInvoiceById(Id paymentInvoiceId) {
		return [
				SELECT Id, Name, ASI_CRM_Status__c, RecordType.DeveloperName, ASI_CRM_Pay_To__c, ASI_CRM_Pay_To__r.Name,
						ownerid, recordtypeid, ASI_CRM_Total_Invoice_Amount__c, ASI_CRM_Total_Taxable_Amount__c,
						ASI_CRM_Invoice_No__c, ASI_CRM_Invoice_Date__c, ASI_CRM_Payment_Date__c, ASI_CRM_Tax_Rate__c,
						ASI_CRM_Journal_Voucher__c, ASI_CRM_Remarks__c, ASI_CRM_From_Month__c, ASI_CRM_To_Month__c,
						ASI_CRM_Owner__c
				FROM ASI_CRM_Payment_Invoice__c
				where id = :paymentInvoiceId
		];
	}
}