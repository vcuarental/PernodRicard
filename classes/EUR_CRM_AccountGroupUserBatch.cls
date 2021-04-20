global class EUR_CRM_AccountGroupUserBatch implements Database.Batchable<sObject> {

    public static final List<String> COUNTRY_CODES = new List<String>{
            'NL', 'IDL', 'DB', 'DE', 'AT', 'SE', 'IT'
    };

    EUR_CRM_AccountGroupUserService service = new EUR_CRM_AccountGroupUserService();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT Id, EUR_CRM_AccessLevel__c, EUR_CRM_User__c, EUR_CRM_AccountGroup__c ' +
                        'FROM EUR_CRM_AccountGroupUser__c ' +
                        'WHERE EUR_CRM_AccountGroup__r.EUR_CRM_Account__r.EUR_CRM_Country_Code__c IN : COUNTRY_CODES'
        );
    }

    global void execute(Database.BatchableContext bc, List<EUR_CRM_AccountGroupUser__c> records) {
        service.populateAccounts(records, EUR_CRM_AccountGroupUserService.ADD);
    }

    global void finish(Database.BatchableContext bc) {
        // ignore
    }
}