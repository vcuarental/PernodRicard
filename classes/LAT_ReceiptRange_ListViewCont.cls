public with sharing class LAT_ReceiptRange_ListViewCont {

    public List<LAT_Receipt_Range__c> rangesCustom {get; set;}
    public LAT_ReceiptRange_ListViewCont(ApexPages.StandardSetController controller) {
        rangesCustom = [SELECT name, firstNumber__c, nextNumber__c, limitNumber__c, user__c FROM  LAT_Receipt_Range__c ORDER BY name DESC];
    }


    public PageReference goToNuevoRango() {
        return new PageReference('/apex/LAT_AR_CreateReceiptRange');
    }
}