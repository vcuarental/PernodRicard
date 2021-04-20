global without sharing class EUR_CRM_AccountChildrenSharingBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    public static final Integer BATCH_CHILDREN_ITERATOR_SCOPE_SIZE = 1;
    public static final Integer BATCH_CHILD_SCOPE_SIZE = 200;

    public static final String CHILDREN_ACCESS_LEVEL = 'Edit';
    public static final String CHILDREN_SHARING_REASON = 'EUR_CRM_Account_Owner__c';

    public static final Map<String, String> CHILDREN_FOR_UPDATING = new Map<String, String>{
            'EUR_CRM_Visit__c'  => 'EUR_CRM_Account__c',
            'EUR_CRM_Visit_Action__c'  => 'EUR_CRM_Visit_ID__r.EUR_CRM_Account__c',
            'EUR_CRM_Competitor_Promo_Tracking__c'  => 'EUR_CRM_Account_Name__c',
            'EUR_CRM_Contract_Tracker__c'  => 'EUR_CRM_Account__c',
            'EUR_CRM_Brand_Security_Infringement__c'  => 'EUR_CRM_Outlet_Name__c',
            'EUR_CRM_GB_Objective__c'  => 'EUR_CRM_Account__c'
    };
    private static final String VISIT_IN_PROGRESS_STATUS = 'In progress';

    private List<String> countryCodes = new List<String>();
    private Set<Id> accountIds = new Set<Id>();
    private Set<String> accountChildren = new Set<String>();
    private Set<String> childrenToProcess = new Set<String>();

    public enum UpdatingProcess {ALL_CHILDREN_PER_BATCH, ONE_CHILD_PER_BATCH}
    private UpdatingProcess process;

    private Id jobId;

    public static void runForAccountsOwnerChanging(List<EUR_CRM_Account__c> accounts, Map<Id, EUR_CRM_Account__c> oldAccountById) {
        Set<Id> accountIds = new Set<Id>();
        for(EUR_CRM_Account__c acc : accounts) {
            EUR_CRM_Account__c oldAcc = oldAccountById.get(acc.Id);

            System.debug('runForAccountsOwnerChanging acc.OwnerId: ' + acc.OwnerId);
            System.debug('runForAccountsOwnerChanging oldAcc.OwnerId: ' + oldAcc.OwnerId);

            if(acc.OwnerId != oldAcc.OwnerId) {
                accountIds.add(acc.Id);
            }
        }
        runForAccounts(accountIds);
    }

    private static Boolean runOnce = false;
    public static void runForAccounts(Set<Id> accountIds) {
        if(accountIds == null || accountIds.isEmpty() || Test.isRunningTest()) return ;
        //if(runOnce == true) return;
        if ( ! System.isBatch()) {
            Database.executeBatch(new EUR_CRM_AccountChildrenSharingBatch(accountIds), BATCH_CHILDREN_ITERATOR_SCOPE_SIZE);
        } else {
            String jobName = 'EUR_CRM_AccountChildrenSharingBatch ' + (Math.round(Math.random() * 1000));
            EUR_CRM_AccountChildrenSharingBatch batch = new EUR_CRM_AccountChildrenSharingBatch(accountIds);
            System.schedule(jobName, getDateTimeFromNow(1), batch);
        }
        runOnce = true;
    }

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new EUR_CRM_AccountChildrenSharingBatch(accountIds, ctx.getTriggerId()), BATCH_CHILDREN_ITERATOR_SCOPE_SIZE);
    }

    private static String getDateTimeFromNow (Integer minutesFromNow) {
        DateTime runningTime = Datetime.now().addMinutes(minutesFromNow).addSeconds(2);
        return runningTime.format('s m H d M \'?\' yyyy');
    }

    public static void runForCountries(List<String> countryCodes) {
        if(countryCodes == null || countryCodes.isEmpty()) return ;
        Database.executeBatch(new EUR_CRM_AccountChildrenSharingBatch(new Set<Id>(), countryCodes, CHILDREN_FOR_UPDATING.keySet()), BATCH_CHILD_SCOPE_SIZE);
    }

    public EUR_CRM_AccountChildrenSharingBatch(Set<Id> accountIds) {
        this.accountIds = accountIds;
        this.process = UpdatingProcess.ALL_CHILDREN_PER_BATCH;
    }

    public EUR_CRM_AccountChildrenSharingBatch(Set<Id> accountIds, Id jobId) {
        this.accountIds = accountIds;
        this.process = UpdatingProcess.ALL_CHILDREN_PER_BATCH;
        this.jobId = jobId;
    }

    public EUR_CRM_AccountChildrenSharingBatch(Set<Id> accountIds, List<String> countryCodes, Set<String> childrenToProcess) {
        this.accountIds = accountIds;
        this.countryCodes = countryCodes;
        this.process = UpdatingProcess.ONE_CHILD_PER_BATCH;
        this.childrenToProcess = childrenToProcess;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        if(process == UpdatingProcess.ALL_CHILDREN_PER_BATCH) {
            accountChildren.addAll(CHILDREN_FOR_UPDATING.keySet());
            String fakeQuery = 'SELECT Id FROM Profile LIMIT ' + accountChildren.size();
            System.debug('start fakeQuery: ' + fakeQuery);
            return Database.getQueryLocator(fakeQuery);
        }
        if(process == UpdatingProcess.ONE_CHILD_PER_BATCH) {
            String child = (String)childrenToProcess.iterator().next();
            childrenToProcess.remove(child);
            String childQuery = getObjectQuery(child, null);
            System.debug('start childQuery: ' + childQuery);
            return Database.getQueryLocator(childQuery);
        }
        return null;
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope){
        if(process == UpdatingProcess.ALL_CHILDREN_PER_BATCH) {
            String child = (String) accountChildren.iterator().next();
            accountChildren.remove(child);
            String childQuery = getObjectQuery(child, BATCH_CHILD_SCOPE_SIZE + 1);
            System.debug('execute childQuery: ' + childQuery);
            List<SObject> childs = Database.query(childQuery);
            if(childs.size() > BATCH_CHILD_SCOPE_SIZE) {
                childrenToProcess.add(child);
                return;
            }
            recalculateSharing(childs);

        }
        if(process == UpdatingProcess.ONE_CHILD_PER_BATCH) {
            recalculateSharing(scope);
        }
    }

    global void finish(Database.BatchableContext BC){
        if(!childrenToProcess.isEmpty()) {
            Database.executeBatch(
                    new EUR_CRM_AccountChildrenSharingBatch(accountIds, countryCodes, childrenToProcess),
                    BATCH_CHILD_SCOPE_SIZE
            );
        }
        System.debug('\n jobId => ' + this.jobId + '\n');
        if (String.isNotBlank(this.jobId)) { EUR_CRM_BatchService.abortJob(this.jobId); }

        String aguSharingJobName = 'EUR_CRM_AccGroupUserSharingBatch_' + System.currentTimeMillis();
        System.scheduleBatch(new EUR_CRM_AccGroupUserSharingBatch(accountIds, true), aguSharingJobName, 1, 200);
    }

    private String getObjectQuery(String objectApiName, Integer querylimit) {
        return
                'SELECT Id, ' +  getAccFieldPath(objectApiName, 'OwnerId') + ' ' +
                    (objectApiName.equalsIgnoreCase('EUR_CRM_Visit__c') ? ' , EUR_CRM_Status__c ' : '') +
                        'FROM ' + objectApiName + ' ' +
                        'WHERE ' +
                        (this.accountIds.isEmpty() ? '' : getAccFieldPath(objectApiName, 'Id')  + ' IN :accountIds ') +
                        (this.countryCodes.isEmpty() ? '' : getAccFieldPath(objectApiName, 'EUR_CRM_Country_Code__c') + ' IN :countryCodes ') +
                        (querylimit == null ? '' : ('LIMIT ' + querylimit));
    }

    private void recalculateSharing(List<SObject> records) {
        Map<String, SObject> existingShares = getExistingShares(records);

        deleteShares(records, existingShares);
        addShares(records, existingShares);
    }

    private static void deleteShares(List<SObject> records, Map<String, SObject> existingShares) {
        Map<Id, SObject> recordsMap = new Map<Id, SObject>(records);
        List<SObject> sharesForDelete = new List<SObject>();
        for(SObject share : existingShares.values()) {
            SObject record = recordsMap.get((Id)share.get('ParentID'));
            if(record == null) continue;
            Id accOwnerId = getAccOwnerId(record);
            Id userOrGroupId = (Id)share.get('UserOrGroupId');
            if(accOwnerId != userOrGroupId) {
                sharesForDelete.add(share);
            }
        }
        System.debug('sharesForDelete: ' + sharesForDelete);
        Database.delete(sharesForDelete, false);
    }

    public static void addShares(List<SObject> records) {
        if(records == null || records.isEmpty()) return;
        String objectApiName = records[0].getSObjectType().getDescribe().getName();
        String query =
                'SELECT Id, ' +  getAccFieldPath(objectApiName, 'OwnerId') + ' ' +
                    (objectApiName.equalsIgnoreCase('EUR_CRM_Visit__c') ? ' , EUR_CRM_Status__c ' : '') +
                        'FROM ' + objectApiName + ' ' +
                        'WHERE Id IN :records' ;
        System.debug('Adding Shares Query: ' + query);
        List<SObject> preparedRecords = Database.query(query);
        addShares(preparedRecords, new Map<String, SObject>());
    }

    private static void addShares(List<SObject> records, Map<String, SObject> existingShares) {
        if(records == null || records.isEmpty()) return;
        String objectApiName = records[0].getSObjectType().getDescribe().getName();
        SObjectType objectShareType = Schema.getGlobalDescribe().get(getObjectShareApiName(objectApiName));
        List<SObject> sharesForInsert = new List<SObject>();
        for(SObject record : records) {
            if (objectApiName.equalsIgnoreCase('EUR_CRM_Visit__c')) {
                if ( ! isVisitNeedToShare(record)) { continue; }
            }
            Id accOwnerId = getAccOwnerId(record);
            if(accOwnerId == null) continue;
            SObject existingShare = existingShares.get('' + record.Id + accOwnerId);
            if(existingShare == null) {
                SObject sObj = objectShareType.newSObject();
                sObj.put('ParentID', record.Id);
                sObj.put('UserOrGroupId', accOwnerId);
                sObj.put('AccessLevel', CHILDREN_ACCESS_LEVEL);
                sObj.put('RowCause', CHILDREN_SHARING_REASON);
                sharesForInsert.add(sObj);
            }
        }
        System.debug('sharesForInsert: ' + sharesForInsert);
        System.debug(Database.insert(sharesForInsert, false));
    }

    private static Boolean isVisitNeedToShare(SObject record) {
        return record.get(EUR_CRM_Visit__c.EUR_CRM_Status__c) != VISIT_IN_PROGRESS_STATUS;
    }

    private static Map<String, SObject> getExistingShares(List<SObject> records) {
        Map<String, SObject> existingShares = new Map<String, SObject>();
        if(records == null || records.isEmpty()) return existingShares;

        String objectApiName = records[0].getSObjectType().getDescribe().getName();
        String query =
                'SELECT ParentID, UserOrGroupId ' +
                        'FROM ' + getObjectShareApiName(objectApiName) + ' ' +
                        'WHERE RowCause = :CHILDREN_SHARING_REASON AND ParentID IN :records';
        System.debug('Existing Shares Query: ' + query);
        for(SObject share : Database.query(query)) {
            existingShares.put('' + (Id)share.get('ParentID') + (Id)share.get('UserOrGroupId'), share);
        }
        return existingShares;
    }

    private static String getAccFieldPath(String objectApiName, String accField) {
        return CHILDREN_FOR_UPDATING.get(objectApiName).replace('__c', '__r') + '.' + accField;
    }

    private static String getObjectShareApiName(String objectApiName) {
        return objectApiName.replace('__c', '__Share');
    }

    private static Id getAccOwnerId(SObject record) {
        String objectApiName = record.getSObjectType().getDescribe().getName();
        String accFieldPath = getAccFieldPath(objectApiName, 'OwnerId');
        List<String> path = accFieldPath.split('\\.');
        SObject parentObj = record;
        for(Integer i = 0; i < path.size() - 1; i++) {
            String pathPart = path[i];
            parentObj = parentObj.getSObject(pathPart);
            if(parentObj == null) return null;
        }
        return (Id) parentObj.get(path[path.size() - 1]);
    }
}