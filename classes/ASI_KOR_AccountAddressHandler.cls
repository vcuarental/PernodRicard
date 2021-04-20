public with sharing class ASI_KOR_AccountAddressHandler extends ASI_KOR_TriggerAbstract {

	public ASI_KOR_AccountAddressHandler() {
		super('ASI_KOR_AccountAddressHandler');
	}
	
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		final Set<String> validRTDevNameSet = new Set<String>{
			'ASI_KOR_Venue'
			, 'ASI_KOR_Wholesaler'
		};
		if (tAction == TriggerAction.BEFORE_UPDATE) {
			List<RecordType> validRTList = [SELECT Id FROM RecordType WHERE DeveloperName IN :validRTDevNameSet AND SobjectType = 'Account'];
			Set<ID> validRTIdsSet = new Set<ID>();
			for (RecordType rt : validRTList) validRTIdsSet.add(rt.Id);
			
			// Delete the coordinate if address is changed to empty;
			List<Account> acctList = (List<Account>)sObjList;
			for (Account acct : acctList) {
				if (isBypass(acct) || acct.RecordTypeId == null || !validRTIdsSet.contains(acct.RecordTypeId)) {
					continue;
				} else {
					if (acct.ASI_KOR_Address__c == null || acct.ASI_KOR_Address__c.trim() == ''
						|| ((Account)oldMap.get(acct.Id)).ASI_KOR_Address__c != acct.ASI_KOR_Address__c) {
						// Set to null to prevent incorrect coordinate
						acct.ASI_KOR_Sys_Primary_Latitude__c = null;
						acct.ASI_KOR_Sys_Primary_Longtitude__c = null;
					}
				}
			}
		} else if (tAction == TriggerAction.AFTER_INSERT || tAction == TriggerAction.AFTER_UPDATE) {
			List<RecordType> validRTList = [SELECT Id FROM RecordType WHERE DeveloperName IN :validRTDevNameSet AND SobjectType = 'Account'];
			Set<ID> validRTIdsSet = new Set<ID>();
			for (RecordType rt : validRTList) validRTIdsSet.add(rt.Id);
			
			// Find the coordinate
			Set<ID> newAddressAcctIdSet = new Set<ID>();
			List<Account> acctList = (List<Account>)sObjList;
			for (Account acct : acctList) {
				if (isBypass(acct) || acct.RecordTypeId == null || !validRTIdsSet.contains(acct.RecordTypeId)) {
					continue;
				} else if (tAction == TriggerAction.AFTER_INSERT) {
					newAddressAcctIdSet.add(acct.Id);
				} else { // if (tAction == TriggerAction.AFTER_UPDATE)
					Account oldAcct = (Account)oldMap.get(acct.Id);
					if (acct.ASI_KOR_Address__c != null && oldAcct.ASI_KOR_Address__c != acct.ASI_KOR_Address__c) {
						newAddressAcctIdSet.add(acct.Id);
					}
				}
			}
			// Start requesting the coordinate of account address
			if (newAddressAcctIdSet.size() > 0) {
				Integer calloutLimit = Limits.getLimitCallouts();
				if (calloutLimit == 0) calloutLimit = 1;
				List<ID> newAddressAcctIdList = new List<ID>(newAddressAcctIdSet);
				Integer acctIdSize = newAddressAcctIdList.size();
				Integer acctIdIndex = 0;
				Integer nextHandleAcctIdIndex = 0;
				try {
					for (acctIdIndex = 0; acctIdIndex < acctIdSize;) {
						Set<ID> acctIds = new Set<ID>();
						nextHandleAcctIdIndex = acctIdIndex;
						for (Integer j = 0; j < calloutLimit && acctIdIndex < acctIdSize; j++) {
							acctIds.add(newAddressAcctIdList.get(acctIdIndex));
							acctIdIndex++;
						}
						ASI_KOR_AccountAddressHandler.requestLatLntOfAccounts(acctIds);
					}
				} catch (Exception e) {
					System.debug(e);
					for (Integer i = nextHandleAcctIdIndex; i < acctIdSize; i++) {
						Account tempAcct = (Account)newMap.get(newAddressAcctIdList.get(i));
						tempAcct.addError(e);
					}
				}
			}
		}
	}
	
	@future (callout=true)
	public static void requestLatLntOfAccounts(Set<ID> acctIds) {
		List<Account> acctList = [SELECT Id, ASI_KOR_Address__c, ASI_KOR_Sys_Primary_Latitude__c, ASI_KOR_Sys_Primary_Longtitude__c FROM Account WHERE Id IN :acctIds];
		List<List<String>> latLngList = new List<List<String>>();
		for (Account acct : acctList) {
			String address = acct.ASI_KOR_Address__c;
			if (address != null && address.trim() != '') {
				try {
					String[] latLng = ASI_KOR_GoogleMapHelper.getLatLngByAddressStr(address);
					acct.ASI_KOR_Sys_Primary_Latitude__c = latLng[0];
					acct.ASI_KOR_Sys_Primary_Longtitude__c = latLng[1];
					acct.ASI_KOR_SYS_NeedRefreshGeolocation__c = false;
				} catch (ASI_KOR_CustomException ce) {
					if (ce.getMessage() == ASI_KOR_GoogleMapHelper.STATUS_OVER_QUERY_LIMIT) {
						acct.ASI_KOR_SYS_NeedRefreshGeolocation__c = true;
					} else {
						acct.ASI_KOR_SYS_NeedRefreshGeolocation__c = false;
					}
				}
			}
		}
		System.Savepoint sp = database.setSavepoint();
		try {
			update acctList;
		} catch (Exception e) {
			database.rollback(sp);
			throw e;
		}
	}
	
	private Boolean isBypass(Account acct) {
		return (acct.ASI_KOR_Bypass_Triggers__c != null && (';' + acct.ASI_KOR_Bypass_Triggers__c + ';').contains(';ASI_KOR_AccountAddressHandler;'));
	}

}