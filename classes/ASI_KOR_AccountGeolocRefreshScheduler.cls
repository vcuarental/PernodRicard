public without sharing class ASI_KOR_AccountGeolocRefreshScheduler implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        for (List<Account> accts : [SELECT Id FROM Account WHERE ASI_KOR_SYS_NeedRefreshGeolocation__c = TRUE]) {
            if (accts.size() > 0) {
                Integer calloutLimit = Limits.getLimitCallouts();
                if (calloutLimit == 0) calloutLimit = 1;
                Integer acctSize = accts.size();
                Integer acctIndex = 0;
                try {
                    for (acctIndex = 0; acctIndex < acctSize;) {
                        Set<ID> acctIds = new Set<ID>();
                        for (Integer j = 0; j < calloutLimit && acctIndex < acctSize; j++) {
                            acctIds.add(accts.get(acctIndex).Id);
                            acctIndex++;
                        }
                        ASI_KOR_AccountAddressHandler.requestLatLntOfAccounts(acctIds);
                    }
                } catch (Exception e) {
                    System.debug(e);
                    throw e;
                }
            }
        }
    }
    
   
}