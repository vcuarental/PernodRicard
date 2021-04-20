public with sharing class ASI_HK_CRM_PreApprovalFormGenerator {
	
	public static final String RT_Default = 'TODO: Add record type';

	private static Map<String, RecordType> RTMap {
		get {
			if (RTMap == null) {
				List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'ASI_HK_CRM_Pre_Approval_Form__c'];
				RTMap = new Map<String, RecordType>();
				for (RecordType rt : RTList) {
					RTMap.put(rt.DeveloperName, rt);
				}
			}
			return RTMap;
		}
		set;
	}

	public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
	
	public ASI_HK_CRM_Pre_Approval_Form__c generateBasicPreApprovalForm(Account acct) {
		return new ASI_HK_CRM_Pre_Approval_Form__c(
			ASI_HK_CRM_PAF_Customer__c = acct.Id
		);
	}

	public ASI_HK_CRM_Pre_Approval_Form__c generatePreApprovalForm(Account acct, ID rtID) {
		ASI_HK_CRM_Pre_Approval_Form__c result = generateBasicPreApprovalForm(acct);
		//result.RecordTypeId = rtID;
		return result;
	}

	public ASI_HK_CRM_Pre_Approval_Form__c generatePreApprovalForm(Account acct, String rtDevName) {
		return generatePreApprovalForm(acct, getRecordTypeByDevName(rtDevName).Id);
	}
	
}