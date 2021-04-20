public with sharing class ASI_KOR_BrandGenerator {
	
	public static final String DEF_VALUE_NAME = 'Test Brand';
	public static final String DEF_VALUE_CODE = 'BC0001';
	
	public ASI_KOR_Brand__c generateBasicBrand() {
		return new ASI_KOR_Brand__c(
			Name = DEF_VALUE_NAME
			, ASI_KOR_Brand_Code__c = DEF_VALUE_CODE
		);
	}

	public ASI_KOR_Brand__c generateBrand() {
		return generateBasicBrand();
	}

	/*public ASI_KOR_Brand__c generateBrand(String bName, String bCode) {
		ASI_KOR_Brand__c result = generateBasicBrand();
		result.Name = bName;
		result.ASI_KOR_Brand_Code__c = bCode;
		return result;
	}*/
	
}