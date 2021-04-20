public with sharing class EUR_CRM_ObjPromoSelectAccTarGroupCtrl {

    private static EUR_CRM_ObjAndPromoConfigPageService.Selector selector = new EUR_CRM_ObjAndPromoConfigPageService.Selector();
    private static EUR_CRM_ObjAndPromoConfigPageService.Data data = new EUR_CRM_ObjAndPromoConfigPageService.Data();

    public class Model implements EUR_CRM_AuraNestable {
        @AuraEnabled
        public EUR_CRM_Objectives_Promotions__c promo {get; set;}
        @AuraEnabled
        public EUR_CRM_Account_Target_Group__c accountGroup {get; set;}
        @AuraEnabled
        public List<EUR_CRM_Account_In_Target_Group__c> accountsInTargetGroup {get; set;}
    }

    @AuraEnabled
    public static EUR_CRM_ObjPromoSelectAccTarGroupCtrl.Model getModel(Id promoId) {
        return data.constructModel(promoId);
    }

    @AuraEnabled
    public static List<EUR_CRM_Account__c> getAccountsByIds(List<String> idSet) {
        if (idSet == null || idSet.isEmpty()) {
            throw new AuraHandledException('Wrong parameters are provided to select products by Ids');
        }
        return selector.selectAccountsByIds(idSet);
    }

}