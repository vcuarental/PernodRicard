public without sharing virtual class EUR_CRM_CacheBatch implements Database.Batchable<SObject>, Database.Stateful {

    public static final Integer DEFAULT_BATCH_SIZE = 200;

    protected List<EUR_CRM_Cache__c> iterableCashes;

    protected virtual String getBathId() {
        //Set unique 3 latters Id
        return null;
    }

    protected virtual Integer getIterableCashesQuantity() {
        return DEFAULT_BATCH_SIZE;
    }

    public EUR_CRM_CacheBatch() {}

    public EUR_CRM_CacheBatch(List<EUR_CRM_Cache__c> iterableCashes) {
        this.iterableCashes = iterableCashes;
    }

    public void scheduleBatch(List<SObject> scheduledSObjects) {
        scheduleBatch(EUR_CRM_AccountSharingService.getParentIds(scheduledSObjects, 'Id'));
    }

    public void scheduleBatch(Set<Id> sObjIds) {
        if (String.isEmpty(getBathId()) || sObjIds == null || sObjIds.isEmpty()) return;
        System.debug('Review ERROR');
        System.debug('sObjIds - ' + sObjIds);
        putToCache(sObjIds);

        scheduleBatch();
    }

    protected virtual void scheduleBatch() {}
    protected virtual void executeNextBatch() {}

    public Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator emptyQueryLoc = Database.getQueryLocator('SELECT Id FROM Organization WHERE id = null LIMIT 1');

        if(iterableCashes == null) iterableCashes = Database.query(getCacheQuery());
        if(iterableCashes.isEmpty()) return emptyQueryLoc;

        Set<Id> iterableSObjectIds = getIdsFromCache();
        if(iterableSObjectIds == null || iterableSObjectIds.isEmpty()) return emptyQueryLoc;

        Database.QueryLocator queryLoc = getQueryForStart(iterableSObjectIds);
        if(queryLoc == null) return emptyQueryLoc;

        return queryLoc;
    }

    protected virtual Database.QueryLocator getQueryForStart(Set<Id> iterableSObjectIds) {
        return null;
    }

    public virtual void execute(Database.BatchableContext ctx, List<SObject> scope) {}

    public void finish(Database.BatchableContext ctx) {
        if(iterableCashes == null || iterableCashes.isEmpty()) return;

        Boolean isRunNextBatch = runNextOnFinish();

        if(isRunNextBatch) runNextBatch();
    }

    protected virtual Boolean runNextOnFinish() {
        return true;
    }

    private void runNextBatch() {
        Map<Id,EUR_CRM_Cache__c> iterableCashesAtThisMoment = new Map<Id, EUR_CRM_Cache__c>([SELECT Id, LastModifiedDate FROM EUR_CRM_Cache__c WHERE Id IN :iterableCashes]);

        List<EUR_CRM_Cache__c> cachesForDel = new List<EUR_CRM_Cache__c>();
        for(EUR_CRM_Cache__c cache : iterableCashes) {
            EUR_CRM_Cache__c cacheAtThisMoment = iterableCashesAtThisMoment.get(cache.Id);
            if(cacheAtThisMoment != null && cache.LastModifiedDate == cacheAtThisMoment.LastModifiedDate) {
                cachesForDel.add(cache);
            }
        }

        delete cachesForDel;
        System.debug('cachesForDel: ' + cachesForDel);

        if(hasNext()) executeNextBatch();
    }

    private Boolean hasNext() {
        List<EUR_CRM_Cache__c> cashes = Database.query(getCacheQuery());
        return !cashes.isEmpty();
    }

    private void putToCache(Set<Id> sObjIds) {
        List<EUR_CRM_Cache__c> cache = new List<EUR_CRM_Cache__c>();
        for(Id sObjId : sObjIds) {
            cache.add(new EUR_CRM_Cache__c(EUR_CRM_Record_Id__c = getCacheId(sObjId)));
        }
        Schema.SObjectField field = EUR_CRM_Cache__c.fields.EUR_CRM_Record_Id__c;
        Database.upsert(cache, field, false);
        System.debug('putToCache: ' + cache);
    }

    private String getCacheId(Id sObjId) {
        return '' + sObjId + getBathId();
    }

    private Set<Id> getIdsFromCache() {
        Set<Id> retIds = new Set<Id>();
        for(EUR_CRM_Cache__c cache : iterableCashes) {
            Id idFromCache = getIdFromCache(cache);
            if(idFromCache != null) retIds.add(idFromCache);
        }
        return retIds;
    }

    private Id getIdFromCache(EUR_CRM_Cache__c cache) {
        Id retId = null;
        try {
            retId = Id.valueOf(cache.EUR_CRM_Record_Id__c.left(18));
        } catch (Exception ex) {
            // Do nothing
        }
        return retId;
    }

    private String getCacheQuery() {
        return 'SELECT Id, EUR_CRM_Record_Id__c, LastModifiedDate ' +
            'FROM EUR_CRM_Cache__c ' +
            'WHERE EUR_CRM_Record_Id__c LIKE \'__________________' + getBathId() + '\' ' +
            'ORDER BY LastModifiedDate ' +
            'LIMIT ' + getIterableCashesQuantity();
    }

}