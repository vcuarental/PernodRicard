public without sharing class EUR_CRM_ContactOwnerUpdatingBatch implements Database.Batchable<sObject> {

    private String countryCode;

    public EUR_CRM_ContactOwnerUpdatingBatch(String countryCode) {
        this.countryCode = countryCode;
    }

    public database.querylocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
                SELECT Id, OwnerId, EUR_CRM_Account__r.OwnerId
                FROM Contact
                WHERE EUR_CRM_Account__r.EUR_CRM_Country_Code__c = :countryCode
        ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> contactsForUpdating = new List<Contact>();
        for (Contact c : (List<Contact>) scope) {
            if (c.OwnerId != c.EUR_CRM_Account__r.OwnerId) {
                c.OwnerId = c.EUR_CRM_Account__r.OwnerId;
                contactsForUpdating.add(c);
            }
        }
        List<Database.SaveResult> sr = Database.update(contactsForUpdating, false);
        System.debug('SaveResult: ' + sr);
    }

    public void finish(Database.BatchableContext BC) {}

}