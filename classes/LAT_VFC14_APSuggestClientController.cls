public with sharing class LAT_VFC14_APSuggestClientController {

    public LAT_AccountInAction__c aia {get;set;}

    public LAT_VFC14_APSuggestClientController(ApexPages.StandardController controller) {
        this.aia = (LAT_AccountInAction__c)controller.getRecord();
    }

    public pageReference save() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        String paid = params.get('paid');

        if (paid != null) {
            this.aia.LAT_Status__c = 'Cliente Substituto';
            this.aia.LAT_PromotionalAction__c = paid;
            insert this.aia;
            return new PageReference('/' + this.aia.id);
        }

        return new PageReference('/' + paid);
    }

}