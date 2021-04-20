global without sharing class EUR_CRM_AccountUpdatingBatch extends EUR_CRM_BatchVirtualClass implements Database.Batchable<sObject> {

    private String countryCode;
    private String fieldToSet;
    private Object valueToSet;
    private String soqlWhereCondition;

    public enum ProcessType {DELETING}
    private ProcessType type;

    public EUR_CRM_AccountUpdatingBatch(String countryCode, String fieldToSet, Object valueToSet, String soqlWhereCondition) {
        this.countryCode = countryCode;
        this.fieldToSet = fieldToSet;
        this.valueToSet = valueToSet;
        this.soqlWhereCondition = soqlWhereCondition;
    }

    public EUR_CRM_AccountUpdatingBatch(ProcessType type, String countryCode, String soqlWhereCondition) {
        this.countryCode = countryCode;
        this.type = type;
        this.soqlWhereCondition = soqlWhereCondition;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query =
            'SELECT Id ' +
            'FROM EUR_CRM_Account__c ' +
                'WHERE EUR_CRM_Country_Code__c = :countryCode AND ' +
            '('+ soqlWhereCondition +')';

        System.debug('EUR_CRM_AccountUpdatingBatch start query: ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope){
        List<EUR_CRM_Account__c> accounts = this.selectAccountsWhereIds(scope);
        if(type == ProcessType.DELETING) {
            this.deleteRecords(accounts);
        } else {
            for (EUR_CRM_Account__c acc : accounts) {
                acc.put(fieldToSet, valueToSet);
            }
            this.upsertRecords(accounts);
        }
    }

    global override void finish(Database.BatchableContext bc) {
        super.finish(bc);
    }

    private List<EUR_CRM_Account__c> selectAccountsWhereIds(List<EUR_CRM_Account__c> accs) {
        String query =
            'SELECT Id ' +
                'FROM EUR_CRM_Account__c ' +
                'WHERE EUR_CRM_Country_Code__c = :countryCode AND ' +
                '('+ soqlWhereCondition +') AND Id IN : accs FOR UPDATE';

        return Database.query(query);

    }

}