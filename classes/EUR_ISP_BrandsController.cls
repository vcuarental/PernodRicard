/**
 * Apex Controller for Brands component of iSPend APP
 *
 * @author afi
 * @copyright PARX
 */
public without sharing class EUR_ISP_BrandsController
{
	@AuraEnabled
	public static List<EUR_CRM_Brand__c> getBrands(String spendId)
	{
		Id accountId = EUR_ISP_BrandsController.getAccountIdIfRecTypeCommercialPlan(spendId);
		if (accountId == null)
		{
			return EUR_ISP_BrandsController.getAvailableBrands();
		}

		List<EUR_CRM_Brand__c> output = new List<EUR_CRM_Brand__c>();
		for (EUR_CRM_SKU__c theSku : EUR_ISP_BrandsController.getAvailableSKURecords(accountId))
		{
			EUR_CRM_Size__c theQualitySize = theSKU.EUR_CRM_Brand_Quality_Size__r;
			if (theQualitySize != null && theQualitySize.EUR_CRM_Active__c)
			{
				EUR_CRM_Quality__c theQuality = theQualitySize.EUR_CRM_Brand_Quality__r;
				if (theQuality != null && theQuality.EUR_CRM_Active__c)
				{
					EUR_CRM_Brand__c theBrand = theQuality.EUR_CRM_Brand__r;
					if (theBrand != null && theBrand.EUR_CRM_Active__c)
					{
						output.add(theBrand);

					}
				}
			}
		}
		return output;
	}

	@AuraEnabled
	public static List<EUR_CRM_Quality__c> getBrandsQuality(String spendId)
	{
		Id accountId = EUR_ISP_BrandsController.getAccountIdIfRecTypeCommercialPlan(spendId);
		if (accountId == null)
		{
			List<EUR_CRM_Brand__c> theBrands = EUR_ISP_BrandsController.getAvailableBrands();
			return [SELECT Id, Name FROM EUR_CRM_Quality__c
			        WHERE EUR_CRM_Active__c = true AND EUR_CRM_Brand__c IN : theBrands ORDER BY Name ASC];
		}

		List<EUR_CRM_Quality__c> output = new List<EUR_CRM_Quality__c>();
		for (EUR_CRM_SKU__c theSku : EUR_ISP_BrandsController.getAvailableSKURecords(accountId))
		{
			EUR_CRM_Size__c theQualitySize = theSKU.EUR_CRM_Brand_Quality_Size__r;
			if (theQualitySize != null && theQualitySize.EUR_CRM_Active__c)
			{
				EUR_CRM_Quality__c theQuality = theQualitySize.EUR_CRM_Brand_Quality__r;
				if (theQuality != null && theQuality.EUR_CRM_Active__c)
				{
					output.add(theQuality);
				}
			}

		}
		return output;
	}

	@AuraEnabled
	public static List<EUR_CRM_Size__c> getBrandsQualitySizes(String spendId)
	{
		Id accountId = EUR_ISP_BrandsController.getAccountIdIfRecTypeCommercialPlan(spendId);
		if (accountId == null)
		{
			List<EUR_CRM_Brand__c> theBrands = EUR_ISP_BrandsController.getAvailableBrands();
			return [SELECT Id, Name
			        FROM EUR_CRM_Size__c
			        WHERE EUR_CRM_Brand_Quality__c IN
			        (SELECT Id FROM EUR_CRM_Quality__c
			         WHERE EUR_CRM_Brand__c IN : theBrands AND EUR_CRM_Active__c = true) AND EUR_CRM_Active__c = true ORDER BY Name ASC];
		}

		List<EUR_CRM_Size__c> output = new List<EUR_CRM_Size__c>();
		for (EUR_CRM_SKU__c theSku : EUR_ISP_BrandsController.getAvailableSKURecords(accountId))
		{
			EUR_CRM_Size__c theQualitySize = theSKU.EUR_CRM_Brand_Quality_Size__r;
			if (theQualitySize != null && theQualitySize.EUR_CRM_Active__c)
			{
				output.add(theQualitySize);
			}
		}
		return output;
	}

	@AuraEnabled
	public static List<EUR_CRM_Wine_Spirits__c> getBrandFamily(String spendId)
	{
		Set<Id> theIds = new Set<Id>();
		Id accountId = EUR_ISP_BrandsController.getAccountIdIfRecTypeCommercialPlan(spendId);
		if (accountId == null)
		{
			//return [SELECT Id, Name FROM EUR_CRM_Wine_Spirits__c ORDER BY Name ASC];
			List<EUR_CRM_Wine_Spirits__c> theBranFamilies = new List<EUR_CRM_Wine_Spirits__c>();
			for (EUR_CRM_Brand__c theBrand : EUR_ISP_BrandsController.getAvailableBrands())
			{
				if (theBrand.EUR_CRM_Category__c != null && theBrand.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits__c != null)
				{
					theIds.add(theBrand.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits__c);
				}
			}
			return [SELECT Id, Name FROM EUR_CRM_Wine_Spirits__c WHERE Id IN: theIds ORDER BY Name ASC];
		}


		for (EUR_CRM_SKU__c theSku : EUR_ISP_BrandsController.getAvailableSKURecords(accountId))
		{
			EUR_CRM_Size__c theQualitySize = theSKU.EUR_CRM_Brand_Quality_Size__r;
			if (theQualitySize != null && theQualitySize.EUR_CRM_Active__c)
			{
				EUR_CRM_Quality__c theQuality = theQualitySize.EUR_CRM_Brand_Quality__r;
				if (theQuality != null && theQuality.EUR_CRM_Active__c)
				{
					EUR_CRM_Brand__c theBrand = theQuality.EUR_CRM_Brand__r;
					if (theBrand != null && theBrand.EUR_CRM_Active__c)
					{
						if (theBrand.EUR_CRM_Category__c != null && theBrand.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits__c != null)
						{
							theIds.add(theBrand.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits__c);
						}
					}
				}
			}
		}
		return [SELECT Id, Name FROM EUR_CRM_Wine_Spirits__c WHERE Id IN: theIds ORDER BY Name ASC];
	}

	@AuraEnabled
	public static List<EUR_CRM_SKU__c> getBrandSKU(String spendId)
	{
		Id accountId = EUR_ISP_BrandsController.getAccountIdIfRecTypeCommercialPlan(spendId);
		if (accountId == null)
		{
			List<EUR_CRM_Brand__c> theBrands = EUR_ISP_BrandsController.getAvailableBrands();
			List<EUR_CRM_Size__c> theBrandsQuality = [SELECT Id, Name
			        FROM EUR_CRM_Size__c
			        WHERE EUR_CRM_Brand_Quality__c IN
			        (SELECT Id FROM EUR_CRM_Quality__c
			         WHERE EUR_CRM_Brand__c IN : theBrands AND EUR_CRM_Active__c = true) AND EUR_CRM_Active__c = true ORDER BY Name ASC];
			return [SELECT Id, Name FROM EUR_CRM_SKU__c WHERE EUR_CRM_Brand_Quality_Size__c IN :theBrandsQuality AND EUR_CRM_Active__c = true ORDER BY Name ASC];
		}

		return EUR_ISP_BrandsController.getAvailableSKURecords(accountId);
	}

	private static List<EUR_CRM_SKU__c> getAvailableSKURecords(String accountId)
	{
		List<EUR_CRM_SKU__c> outputResults = new List<EUR_CRM_SKU__c>();
		for (EUR_ISP_AccountSku__c theSkuToAccount : [SELECT Id,
		        // SKUs
		        EUR_ISP_SKU__c,
		        EUR_ISP_SKU__r.Id,
		        EUR_ISP_SKU__r.Name,
		        EUR_ISP_SKU__r.EUR_CRM_Active__c,

		        // Brand Quality Size
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__c,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.Id,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.Name,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Active__c,

		        // Brand Quality
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__c,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.Id,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.Name,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Active__c,

		        // Brand
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Id,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.Name,
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Active__c,

		        // Wine/Spirits
		        EUR_ISP_SKU__r.EUR_CRM_Brand_Quality_Size__r.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits__c
		        FROM EUR_ISP_AccountSku__c
		        WHERE EUR_ISP_Account__c = : accountId AND EUR_ISP_Active__c = true AND EUR_ISP_SKU__r.EUR_CRM_Is_Competitor__c = false])
		{
			EUR_CRM_SKU__c theSku = (EUR_CRM_SKU__c)theSkuToAccount.getSObject('EUR_ISP_SKU__r');
			if (theSku.EUR_CRM_Active__c)
			{
				outputResults.add(theSku);
			}
		}
		return outputResults;
	}

	private static List<EUR_CRM_Brand__c> getAvailableBrands()
	{
		List<EUR_CRM_Brand__c> theBrands = new List<EUR_CRM_Brand__c>();
		for (EUR_ISP_UserBrand__c userToBrand : [SELECT Id, EUR_ISP_Brand__r.Id, EUR_ISP_Brand__r.Name,
		        EUR_ISP_Brand__r.EUR_CRM_Category__r.EUR_CRM_Wine_Spirits__c
		        FROM EUR_ISP_UserBrand__c
		        WHERE EUR_ISP_User__c = : UserInfo.getUserId() AND EUR_ISP_Brand__r.EUR_CRM_Active__c = true AND EUR_ISP_Brand__r.EUR_CRM_Is_Competitor__c = false
		                                ORDER BY EUR_ISP_Brand__r.Name ASC])
		{
			EUR_CRM_Brand__c theBrand = (EUR_CRM_Brand__c)userToBrand.getSobject('EUR_ISP_Brand__r');
			theBrands.add(theBrand);
		}
		return theBrands;
	}

	private static Id getAccountIdIfRecTypeCommercialPlan(String spendId)
	{
		if (String.isBlank(spendId))
		{
			return null;
		}

		spendId = String.escapeSingleQuotes(spendId);
		List<EUR_ISP_Spend__c> theSpendRecords = [
		            SELECT Id, EUR_ISP_Account__c
		            FROM EUR_ISP_Spend__c
		            WHERE Id = : spendId AND
		                       RecordType.DeveloperName = : EUR_ISP_Utils.EUR_ISP_SPEND_COMMERCIAL_RT_NAME
		        ];

		return !theSpendRecords.isEmpty() ? theSpendRecords.get(0).EUR_ISP_Account__c : null;
	}
}