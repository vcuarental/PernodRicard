public with sharing class LAT_PromotionalActionDetailController {

    LAT_PromotionalAction__c pa = new LAT_PromotionalAction__c();

    public LAT_PromotionalActionDetailController(ApexPages.StandardController controller) {
        this.pa = (LAT_PromotionalAction__c)controller.getRecord();
    }

    public pageReference redirect() {
        Schema.DescribeSObjectResult r = LAT_PromotionalAction__c.sObjectType.getDescribe();
        String paPrefix = r.getKeyPrefix();

        Id recordTypeId = Global_RecordTypeCache.getRtId('LAT_PromotionalAction__c'+'Registrada_no_sistema');

        return new PageReference('/' + paPrefix + '/e?retURL=%2F' + paPrefix + '&RecordType=' + recordTypeId
                                                + '&cancelURL=%2F' + paPrefix + '&nooverride=1');
    }

}