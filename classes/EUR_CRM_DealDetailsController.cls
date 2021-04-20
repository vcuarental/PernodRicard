/**
 * Created by V. Kamenskyi on 19.07.2018.
 */

public with sharing class EUR_CRM_DealDetailsController {

    private static EUR_CRM_DealDetailsService.Selector selector = new EUR_CRM_DealDetailsService.Selector();
    private static EUR_CRM_DealDetailsService.Data data = new EUR_CRM_DealDetailsService.Data();

    public class Model implements EUR_CRM_AuraNestable {
        @AuraEnabled
        public EUR_CRM_Deal__c deal {get; set;}
        @AuraEnabled
        public List<Map<String, String>> discountTypes {get; set;}
        @AuraEnabled
        public List<EUR_CRM_Product_In_Deal__c> productsInDeal {get; set;}
        @AuraEnabled
        public List<EUR_CRM_ProductCatalogItemGrouping__c> freeProductGroupings {get; set;}
        @AuraEnabled
        public List<EUR_CRM_ProductCatalogItemGrouping__c> posmGroupings {get; set;}
        @AuraEnabled
        public Map<Id, RecordType> dealRecordTypesByIds {get; set;}
        @AuraEnabled
        public User currentUser {
            get {
                return [
                        SELECT Id
                                , Country
                                , EUR_CRM_Country_Code__c
                                , EUR_CRM_Affiliate_Code_Picklist__c
                        FROM User
                        WHERE Id = :UserInfo.getUserId()
                ];
            } set;
        }
        @AuraEnabled
        public Map<String, String> productLevelByOrderType {
            get {
                List<EUR_CRM_CTM_Product_Catalog_Level__mdt> indirect = [
                        SELECT Id, EUR_CRM_Order_Type__c, EUR_CRM_Product_Level__c
                        FROM EUR_CRM_CTM_Product_Catalog_Level__mdt
                        WHERE EUR_CRM_Country__c IN :this.currentUser.EUR_CRM_Affiliate_Code_Picklist__c.split(';')
                        AND EUR_CRM_Order_Type__c LIKE '%indirect%'
                ];
                List<EUR_CRM_CTM_Product_Catalog_Level__mdt> direct = [
                        SELECT Id, EUR_CRM_Order_Type__c, EUR_CRM_Product_Level__c
                        FROM EUR_CRM_CTM_Product_Catalog_Level__mdt
                        WHERE EUR_CRM_Country__c IN :this.currentUser.EUR_CRM_Affiliate_Code_Picklist__c.split(';')
                        AND EUR_CRM_Order_Type__c LIKE '%direct%'
                    	AND (NOT EUR_CRM_Order_Type__c LIKE '%indirect%')
                ];
                // AND (NOT EUR_CRM_Order_Type__c LIKE '%indirect%')
                return new Map<String, String>{
                        EUR_CRM_DealDetailsService.INDIRECT_ORDER => indirect.isEmpty() ? 'EUR_CRM_BQS__c' : indirect[0].EUR_CRM_Product_Level__c,
                        EUR_CRM_DealDetailsService.DIRECT_ORDER => direct.isEmpty() ? 'EUR_CRM_SKU__c' : direct[0].EUR_CRM_Product_Level__c
                };
            } set;
        }
        @AuraEnabled
        public Map<String, List<PicklistEntry>> picklistEntries {
            get {
                List<PicklistEntry> orderTypes = new List<PicklistEntry>();
                for (Schema.PicklistEntry ple : EUR_CRM_Deal__c.EUR_CRM_OrderType__c.getDescribe().getPicklistValues()) {
                    orderTypes.add(new PicklistEntry(ple.getValue(), ple.getLabel()));
                }
                return new Map<String, List<PicklistEntry>>{
                        'orderTypes' => orderTypes
                };
            } set;
        }
        @AuraEnabled
        public Map<String, Map<String, Object>> labels {
            get {
                return new Map<String, Map<String, Object>>{
                        'entities' => new Map<String, Object>{
                                'EUR_CRM_Deal__c' => new Map<String, Object>{
                                        'label' => EUR_CRM_Deal__c.SObjectType.getDescribe().getLabel(),
                                        'fields' => new Map<String, String>{
                                                'EUR_CRM_OrderType__c' => EUR_CRM_Deal__c.EUR_CRM_OrderType__c.getDescribe().getLabel()
                                        }
                                }
                        }
                };
            } set;
        }
    }

    public class PicklistEntry implements EUR_CRM_AuraNestable{
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public String label {get; set;}

        public PicklistEntry(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    @AuraEnabled
    public static EUR_CRM_DealDetailsController.Model getModel(Id recordId) {
        EUR_CRM_DealDetailsController.Model model = data.constructModel(recordId);
//        System.debug('MODEL : ' + JSON.serializePretty(model));
        return model;
    }

    @AuraEnabled
    public static String doUpsert(String view) {
        return data.doUpsert((Model) JSON.deserialize(view, Model.class));
    }

    @AuraEnabled
    public static String doDelete(String recordId) {
        Database.DeleteResult dr = data.doDelete(recordId);
        return dr != null ? JSON.serialize(dr) : null;
    }

}