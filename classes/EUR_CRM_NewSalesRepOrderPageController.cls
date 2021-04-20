public without sharing class EUR_CRM_NewSalesRepOrderPageController {
   private static final Set<String> URL_PARAM_EXCLUDE = new Set<String> {
        'sfdc.override'
        , 'save_new'
    };
    
    public PageReference assignDefaultAndRedirect(){
        String sObjKeyPrefix = this.sObjType.getDescribe().getKeyPrefix();
        PageReference  redirectPage = new PageReference('/' + sObjKeyPrefix + '/e');
        for(String key  : ApexPages.currentPage().getParameters().keySet()){
            if (!URL_PARAM_EXCLUDE.contains(key))
            redirectPage.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));
        }
        redirectPage.getParameters().put('nooverride','1');
        redirectPage.getParameters().put('Name','['+Label.EUR_CRM_AutoAssignDoNotChange+']');
        return redirectPage;
    }
    private Schema.SObjectType sObjType;
    public EUR_CRM_NewSalesRepOrderPageController (ApexPages.StandardController stdCon) { 
        sObject sObj = stdCon.getRecord();
        this.sObjType = sObj.getSObjectType();
    }
}