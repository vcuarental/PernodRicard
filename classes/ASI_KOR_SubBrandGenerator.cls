public with sharing class ASI_KOR_SubBrandGenerator {

	public static final String DEF_VALUE_NAME = 'Test Sub-Brand {0}';
	public static final String DEF_VALUE_CODE = 'SBC{0}';
	public static Integer countCode = 1;
	public static Integer countName = 1;
	
	public ASI_KOR_Sub_Brand__c generateBasicSubBrand(ASI_KOR_Brand__c brand) {
		String code = nextCode();
		return new ASI_KOR_Sub_Brand__c(
			Name = nextName()
			, ASI_KOR_Brand_Code__c = code
			, ASI_KOR_Sub_Brand_Code__c = code
			, ASI_KOR_Brand__c = brand.Id
		);
	}

	public ASI_KOR_Sub_Brand__c generateSubBrand(ASI_KOR_Brand__c brand) {
		return generateBasicSubBrand(brand);
	}
	
	public String nextCode() { return String.format(DEF_VALUE_CODE, new String[] {String.valueOf(countCode++)}); }
	public String nextName() { return String.format(DEF_VALUE_NAME, new String[] {String.valueOf(countName++)}); }
	
}