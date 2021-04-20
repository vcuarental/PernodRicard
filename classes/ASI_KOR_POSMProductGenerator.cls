public with sharing class ASI_KOR_POSMProductGenerator {
	public static final String DEF_VALUE_BRAND_NAME = 'Test POSM Brand';
	public static final String DEF_VALUE_BRAND_CODE = 'POSMB0001';
	public static final String DEF_VALUE_SB_NAME = 'Test POSM Sub-Brand';
	public static final String DEF_VALUE_SB_CODE = 'POSMSB0001';
	public static final String DEF_VALUE_PD_NAME = 'Test POSM Product';
	public static final String DEF_VALUE_PD_CODE = 'POSMPD0001';
	public static Integer recordCountBrand = 1;
	public static Integer recordCountSb = 1;
	public static Integer recordCountPd = 1;
	
	public ASI_KOR_POSM_Product_Brand__c generateBasicBrand() {
		return new ASI_KOR_POSM_Product_Brand__c(
			Name = DEF_VALUE_BRAND_NAME + (recordCountBrand)
			, ASI_KOR_Brand_Code__c = DEF_VALUE_BRAND_CODE + (recordCountBrand++)
		);
	}

	public ASI_KOR_POSM_Product_Brand__c generateBrand() {
		return generateBasicBrand();
	}
	
	public ASI_KOR_POSM_Product_Sub_Brand__c generateBasicSubBrand(ASI_KOR_POSM_Product_Brand__c brand) {
		return new ASI_KOR_POSM_Product_Sub_Brand__c(
			ASI_KOR_POSM_Product_Brand__c = brand.Id
			, Name = DEF_VALUE_SB_NAME + (recordCountSb)
			, ASI_KOR_Sub_Brand_Code__c = DEF_VALUE_SB_CODE + (recordCountSb++)
		);
	}

	public ASI_KOR_POSM_Product_Sub_Brand__c generateSubBrand(ASI_KOR_POSM_Product_Brand__c brand) {
		return generateBasicSubBrand(brand);
	}
	
	public ASI_KOR_POSM_Product__c generateBasicProduct(ASI_KOR_POSM_Product_Sub_Brand__c sb) {
		return new ASI_KOR_POSM_Product__c(
			//ASI_KOR_Sub_Brand__c = sb.Id,
			 Name = DEF_VALUE_PD_NAME + (recordCountPd)
			, ASI_KOR_Item_Code__c = DEF_VALUE_PD_CODE + (recordCountPd++)
		);
	}

	public ASI_KOR_POSM_Product__c generateProduct(ASI_KOR_POSM_Product_Sub_Brand__c sb) {
		return generateBasicProduct(sb);
	}
}