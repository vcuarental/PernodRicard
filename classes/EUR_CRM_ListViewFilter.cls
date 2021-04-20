public with sharing class EUR_CRM_ListViewFilter {
	
	private Apexpages.StandardSetController setController;
	private Integer pageNumber = 1;
	
	public EUR_CRM_ListViewFilter(Apexpages.StandardSetController stdSetCon){
		setController = stdSetCon;
	}

/*
	public List<Account> getAccountListByFilter(){
		List<Account> acctList = new List<Account>();
		
		List<SObject> objlist = new List<SObject>();
		setController.setPageSize(pageSize);
		do{
			setController.setPageNumber(pageNumber);
			System.debug(pageNumber);
			objlist.addAll(setController.getRecords());
			pageNumber++;
		}while(setController.getHasNext());
		
		System.debug('size of list:' + objlist.size());
		
		Set<Id> euAcctIdSet = new Set<Id>();
		Map<Id, Account> acctMap = new Map<Id, Account>();
		for(SObject s : objlist){
			euAcctIdSet.add(s.Id);
		}
		if(!euAcctIdSet.isEmpty()){
			for(EUR_CRM_Account__c eua : [Select EUR_CRM_Account__c From EUR_CRM_Account__c Where Id in: euAcctIdSet]){
				acctMap.put(eua.EUR_CRM_Account__c, new Account(Id=eua.EUR_CRM_Account__c));
			}
			if(!acctMap.isEmpty()){
				acctList = acctMap.values();
			}
		}
		
		return acctList;
	}
*/	
	public List<EUR_CRM_Account__c> getEURAccountListByFilter(){
		system.debug('standard set controller count after filter: '+setController.getResultSize());
		List<SObject> objlist = new List<SObject>();
		do{
			setController.setPageNumber(pageNumber);
			System.debug(pageNumber);
			objlist.addAll(setController.getRecords());
			pageNumber++;
		}while(setController.getHasNext());
		List<EUR_CRM_Account__c> acctlist = (List<EUR_CRM_Account__c>) objlist;
		system.debug('size of list: '+acctlist.size());
		system.debug('standard set controller count after filter: '+setController.getResultSize());
		return acctlist;
	}
}