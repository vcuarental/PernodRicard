public with sharing class EUR_DOC_DocServerModulePicklistValue {

    @AuraEnabled
    public String value {get;set;}

    @AuraEnabled
    public String label {get;set;}

    public EUR_DOC_DocServerModulePicklistValue(String v, String l) {
        this.value = v;
        this.label = l;
    }
}