/****************************************************
 Dev: Waldemar Mayo  Version: 1  Consulting: Valuenet
****************************************************/

@IsTest
public with sharing class Global_RecordTypeCache_TEST {
	
	static testMethod void UnitTest(){
		RecordType rt = [SELECT Id, SobjectType, DeveloperName FROM RecordType LIMIT 1];
		Global_RecordTypeCache.getRt(rt.Id);
		Global_RecordTypeCache.getRtRec(rt.SobjectType+rt.DeveloperName);
		Global_RecordTypeCache.getRtId(rt.SobjectType+rt.DeveloperName);
		Global_RecordTypeCache.getRtIdSet(rt.SobjectType, new set<String>{rt.DeveloperName});
		Global_RecordTypeCache.getRtList(rt.SobjectType);
	}
	
}