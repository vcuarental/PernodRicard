/**
 * Created by V. Kamenskyi on 19.07.2018.
 */

public with sharing class EUR_CRM_DealDetailsService {

    public static final String DIRECT_ORDER = 'EUR_Direct';
    public static final String INDIRECT_ORDER = 'EUR_Indirect';

    public class Data {

        private final EUR_CRM_DealDetailsService.Selector selector;
        private final Map<EUR_CRM_DmlAction, List<SObject>> relatedRecordByDmlAction;

        public Data() {
            this.selector = new EUR_CRM_DealDetailsService.Selector();
            this.relatedRecordByDmlAction = new Map<EUR_CRM_DmlAction, List<SObject>>{
                    EUR_CRM_DmlAction.DO_INSERT => new List<SObject>()
                    , EUR_CRM_DmlAction.DO_UPDATE => new List<SObject>()
                    , EUR_CRM_DmlAction.DO_DELETE => new List<SObject>()
            };
        }

        public EUR_CRM_DealDetailsController.Model constructModel(Id dealId) {
            EUR_CRM_DealDetailsController.Model m = new EUR_CRM_DealDetailsController.Model();
            if (String.isNotEmpty(dealId)) {
                m.deal = this.selector.selectDealById(dealId);
                m.productsInDeal = this.selector.selectProductsInDeal(dealId);
                m.freeProductGroupings = this.selector.selectFreeProductGroupings(dealId);
                m.posmGroupings = this.selector.selectPOSMGroupings(dealId);
            } else {
                m.deal = new EUR_CRM_Deal__c(EUR_CRM_Country__c = m.currentUser.EUR_CRM_Affiliate_Code_Picklist__c);
            }
            m.discountTypes = getDiscountTypes(m.deal.EUR_CRM_Country__c);
//            m.dealRecordTypesByIds = EUR_CRM_RecordTypeHelper_v2.getObjectRts('EUR_CRM_Deal__c');
            m.dealRecordTypesByIds = EUR_CRM_RecordTypeHelper_v2.getAvailableObjectRecordTypes('EUR_CRM_Deal__c');
            return m;
        }

        public String doUpsert(EUR_CRM_DealDetailsController.Model view) {
            String result;
            Savepoint sp = Database.setSavepoint();
            try {
                Boolean isCreate = String.isEmpty(view.deal.Id);
                Database.UpsertResult sr = Database.upsert(view.deal);
                this.upsertProductsInDeal(sr.getId(), view.productsInDeal, isCreate);
                this.upsertFreeGroupings(sr.getId(), view.freeProductGroupings, isCreate);
                this.upsertPosmGroupings(sr.getId(), view.posmGroupings, isCreate);
                if (!this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_INSERT).isEmpty()) insert this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_INSERT);
                if (!this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_UPDATE).isEmpty()) update this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_UPDATE);
                if (!this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_DELETE).isEmpty()) delete this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_DELETE);
                result = JSON.serialize(sr);
            } catch(Exception ex) {
                Database.rollback(sp);
                throw new AuraHandledException(ex.getMessage());
            }
            return result;
        }

        public Database.DeleteResult doDelete(Id recordId) {
            Database.DeleteResult result;
            Savepoint sp = Database.setSavepoint();
            try {
                delete this.selector.selectProductsInDeal(recordId);
                delete this.selector.selectFreeProductGroupings(recordId);
                delete this.selector.selectPOSMGroupings(recordId);
                result = Database.delete(recordId);
            } catch (Exception ex) {
                throw new AuraHandledException(ex.getMessage());
            }
            return result;
        }

        private void upsertProductsInDeal(Id dealId, List<EUR_CRM_Product_in_Deal__c> viewRecords, Boolean isCreate) {
            List<EUR_CRM_Product_in_Deal__c> pidList = this.selector.selectProductsInDeal(dealId);
            if (viewRecords != null && !isCreate) {
                this.setRelatedRecordsByDmlAction(viewRecords, pidList);
            } else if (viewRecords != null && isCreate) {
                for (EUR_CRM_Product_in_Deal__c pid : viewRecords) {
                    pid.EUR_CRM_AnimationID__c = dealId;
                }
                this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_INSERT).addAll(viewRecords);
            }
        }

        private void upsertFreeGroupings(Id dealId, List<EUR_CRM_ProductCatalogItemGrouping__c> viewRecords, Boolean isCreate) {
            if (viewRecords != null && !isCreate) {
                this.setRelatedRecordsByDmlAction(viewRecords, this.selector.selectFreeProductGroupings(dealId));
            } else if (viewRecords != null && isCreate) {
                for (EUR_CRM_ProductCatalogItemGrouping__c free : viewRecords) {
                    free.EUR_CRM_AnimationID__c = dealId;
                }
                this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_INSERT).addAll(viewRecords);
            }
        }

        private void upsertPosmGroupings(Id dealId, List<EUR_CRM_ProductCatalogItemGrouping__c> viewRecords, Boolean isCreate) {
            if (viewRecords != null && !isCreate) {
                this.setRelatedRecordsByDmlAction(viewRecords, this.selector.selectPOSMGroupings(dealId));
            } else if (viewRecords != null && isCreate) {
                for (EUR_CRM_ProductCatalogItemGrouping__c free : viewRecords) {
                    free.EUR_CRM_AnimationID__c = dealId;
                }
                this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_INSERT).addAll(viewRecords);
            }
        }

        private void setRelatedRecordsByDmlAction(List<SObject> viewRecords, List<SObject> relatedRecords) {
            Map<Id, SObject> relatedMap = new Map<Id, SObject>(relatedRecords);
            List<SObject> toUpd = new List<SObject>();
            List<SObject> toIns = new List<SObject>();
            for (SObject pid : viewRecords) {
                if (String.isNotEmpty(pid.Id)) {
                    toUpd.add(pid);
                    relatedMap.remove(pid.Id);
                } else {
                    toIns.add(pid);
                }
            }
            this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_UPDATE).addAll(toUpd);
            this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_INSERT).addAll(toIns);
            this.relatedRecordByDmlAction.get(EUR_CRM_DmlAction.DO_DELETE).addAll(relatedMap.values());
        }

        private List<Map<String, String>> getDiscountTypes(String country) {
            List<Map<String, String>> result = new List<Map<String, String>>();
            List<EUR_CRM_Deal_Available_Sections__mdt> sections = [
                    SELECT EUR_CRM_Available_Sections__c
                    FROM EUR_CRM_Deal_Available_Sections__mdt
                    WHERE EUR_CRM_Country__c = :country
            ];
            if (!sections.isEmpty() && String.isNotEmpty(sections[0].EUR_CRM_Available_Sections__c)) {
                for (String sectionName : sections[0].EUR_CRM_Available_Sections__c.split(',')) {
                    result.add(new Map<String, String>{
                            'label' => getSectionLabel(sectionName)
                            , 'id' => sectionName
                    });
                }
            }
            return result;
        }

        private String getSectionLabel(String name) {
            return name == 'Discount'
                    ? Label.EUR_CRM_Product_Conditions
                    : name == 'Free Product'
                            ? Label.EUR_CRM_Free_Products
                            : name == 'Free POSM'
                                    ? Label.EUR_CRM_POS_Materials : '';
        }
    }


    public class Selector {

        public EUR_CRM_Deal__c selectDealById(Id dealId) {
            List<EUR_CRM_Deal__c> deals = [
                    SELECT Id
                            , RecordTypeId
                            , RecordType.DeveloperName
                            , Name
                            , EUR_CRM_Objectives_Promotions__c
                            , EUR_CRM_Country__c
                            , EUR_CRM_Deal_logic__c
                            , EUR_CRM_Multiply__c
                            , EUR_CRM_OrderType__c
                    FROM EUR_CRM_Deal__c
                    WHERE Id = :dealId
            ];
            return deals.isEmpty() ? null : deals[0];
        }

        public List<EUR_CRM_Product_in_Deal__c> selectProductsInDeal(Id dealId) {
            return [
                    SELECT Id
                            , EUR_CRM_AnimationID__c
                            , EUR_CRM_SKU__c
                            , EUR_CRM_BQS__c
                            , EUR_CRM_Discount__c
                            , EUR_CRM_Quantity__c
                    FROM EUR_CRM_Product_in_Deal__c
                    WHERE EUR_CRM_AnimationID__c = :dealId
            ];
        }

        public List<EUR_CRM_ProductCatalogItemGrouping__c> selectFreeProductGroupings(Id dealId) {
            return [
                    SELECT Id
                            , EUR_CRM_SKU__c
                            , EUR_CRM_BQS__c
                            , EUR_CRM_Quantity__c
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :dealId
                    AND EUR_CRM_POS_Material__c = NULL
            ];
        }

        public List<EUR_CRM_ProductCatalogItemGrouping__c> selectPOSMGroupings(Id dealId) {
            return [
                    SELECT Id
//                            , EUR_CRM_SKU__c
                            , EUR_CRM_POS_Material__c
                            , EUR_CRM_Quantity__c
                    FROM EUR_CRM_ProductCatalogItemGrouping__c
                    WHERE EUR_CRM_AnimationID__c = :dealId
                    AND EUR_CRM_POS_Material__c <> NULL
            ];
        }

    }
}