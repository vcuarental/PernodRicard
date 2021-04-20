public with sharing class ASI_KOR_CustomSettingGenerator {
	
	private static final Map<String, Integer> acctGradeToVisitCountMap = new Map<String, Integer>{
		'A' => 5
		, 'B' => 4
		, 'C' => 3
		, 'D' => 2
		, 'E' => 1
	};
	
	public static void initAcctGradeVisitCountMapping() {
		List<ASI_KOR_AcctGradeVisitCountMapping__c> settings = new List<ASI_KOR_AcctGradeVisitCountMapping__c>();
		Set<String> grades = acctGradeToVisitCountMap.keySet();
		for (String grade : grades) {
			settings.add(new ASI_KOR_AcctGradeVisitCountMapping__c(
				Name = grade
				, ASI_KOR_No_of_Required_Visitation__c = acctGradeToVisitCountMap.get(grade)
			));
		}
		insert settings;
	}
	
	public static void initMassCreateAndUpdateSetting() {
	}
	
	public static void initOldRecordDeletion() {
		List<ASI_KOR_Old_Record_Deletion__c> settings = new List<ASI_KOR_Old_Record_Deletion__c>();
		Set<String> includedObjs = new Set<String>{'Account'};
		for (String objAPIName : includedObjs) {
			settings.add(new ASI_KOR_Old_Record_Deletion__c(
				Name = objAPIName
				, ASI_KOR_Keeping_Period__c = 365
			));
		}
		insert settings;
	}
}