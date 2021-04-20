public with sharing class ASI_KOR_ItemGroupGenerator {
	public static final String DEF_VALUE_NAME = 'Test Item Group {0}';
	public static final String DEF_VALUE_CODE = 'IG{0}';
	public static Integer countCode = 1;
	public static Integer countName = 1;
	
	public ASI_KOR_Item_Group__c generateBasicItemGroup(ASI_KOR_Sub_Brand__c sb) {
		String code = nextCode();
		return new ASI_KOR_Item_Group__c(
			Name = code
			, ASI_KOR_Sub_Brand__c = sb.Id
			, ASI_KOR_Item_Group_Code__c = code
			, ASI_KOR_Item_Group_Name__c = nextName()
			, ASI_KOR_Active__c = true
		);
	}

	public ASI_KOR_Item_Group__c generateItemGroup(ASI_KOR_Sub_Brand__c sb) {
		ASI_KOR_Item_Group__c result = generateBasicItemGroup(sb);
		return result;
	}
	
	public String nextCode() { return String.format(DEF_VALUE_CODE, new String[] {String.valueOf(countCode++)}); }
	public String nextName() { return String.format(DEF_VALUE_NAME, new String[] {String.valueOf(countName++)}); }
	
}