/****************************************************
 Dev: Waldemar Mayo  Version: 1  Consulting: Valuenet
****************************************************/

@IsTest
public with sharing class LAT_GlobalProfileCache_TEST {
	
	static testMethod void UnitTest(){
		Profile prof = [SELECT Id, Name FROM Profile LIMIT 1];
		LAT_GlobalProfileCache.getProfileById(UserInfo.getProfileId());
		LAT_GlobalProfileCache.getProfileNameById(UserInfo.getProfileId());
		LAT_GlobalProfileCache.getProfileByName(prof.Name);
		LAT_GlobalProfileCache.getProfileIdByName(prof.Name);
		LAT_GlobalProfileCache.getAllProfiles();
	}
	
}