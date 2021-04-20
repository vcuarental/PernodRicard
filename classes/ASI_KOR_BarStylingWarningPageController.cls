/***************************************************************************************************************************
* Name:        ASI_KOR_BarStylingWarningPageController
* Description: Controller for ASI_KOR_BarStylingWarningPage
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    --------------------------------------------------------------------------------
* 2018-12-07       Alan Lau                Created
****************************************************************************************************************************/
public class ASI_KOR_BarStylingWarningPageController {

	private final static Map<String, ASI_KOR_Branches__c> branchCustomSetting = ASI_KOR_Branches__c.getAll();

	public ASI_KOR_POSM_Order_Request__c posmHeader {
		get; set;
	}

	public Boolean isVolumeForcastSmallerThanMinMonthlyAvgVol {
		get; set;
	}

	public ASI_KOR_BarStylingWarningPageController(ApexPages.StandardController controller) {
		String posmHeaderId = ApexPages.currentPage().getParameters().get('Id');
		this.posmHeader = [
				SELECT Id,
						Name,
						ASI_KOR_Sub_brand__c,
						ASI_MFM_Sales_Branch__c,
						ASI_KOR_Volume_Forecast__c
				FROM ASI_KOR_POSM_Order_Request__c
				WHERE Id = :posmHeaderId
				LIMIT 1
		];
	}

	public void init() {
		validateVolumeForecast();
	}

	private void validateVolumeForecast() {
		final String keyFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Branch_Code__c';
		final String valueFieldForMapOfBranchCodeToRegionCode = 'ASI_KOR_Region_Code__c';

		Map<String, String> mapOfBranchCodeToRegionCode = ASI_KOR_CommonUtils.getMapFromCustomSetting(branchCustomSetting, keyFieldForMapOfBranchCodeToRegionCode, valueFieldForMapOfBranchCodeToRegionCode);

		ASI_KOR_Minimum_Volume_Setting__c minimumVolumeSetting = getMinimumVolumeSetting(
				mapOfBranchCodeToRegionCode.get(this.posmHeader.ASI_MFM_Sales_Branch__c.substring(0, this.posmHeader.ASI_MFM_Sales_Branch__c.indexOf('-'))),
				this.posmHeader.ASI_KOR_Sub_brand__c
		);

		if (this.posmHeader.ASI_KOR_Volume_Forecast__c != null
				&& minimumVolumeSetting != null
				&& (this.posmHeader.ASI_KOR_Volume_Forecast__c < minimumVolumeSetting.ASI_KOR_Minimum_Monthly_Average_Volume__c)) {
			this.isVolumeForcastSmallerThanMinMonthlyAvgVol = true;
		}

	}

	private ASI_KOR_Minimum_Volume_Setting__c getMinimumVolumeSetting(String regionCode, String subBrand) {
		ASI_KOR_Minimum_Volume_Setting__c minimumVolumeSetting = [
				SELECT ASI_KOR_Minimum_Monthly_Average_Volume__c,
						ASI_KOR_Region_Code__c,
						ASI_KOR_Sub_brand__c
				FROM ASI_KOR_Minimum_Volume_Setting__c
				WHERE ASI_KOR_Region_Code__c = :regionCode
				AND ASI_KOR_Sub_brand__c = :subBrand
				AND ASI_KOR_Minimum_Monthly_Average_Volume__c != NULL
				LIMIT 1
		];

		return minimumVolumeSetting;

	}
}