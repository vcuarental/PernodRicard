public with sharing class EUR_CRM_ObjAndPromoConfigPageService {

    public class Data {

        private final EUR_CRM_ObjAndPromoConfigPageService.Selector selector = new EUR_CRM_ObjAndPromoConfigPageService.Selector();

        public EUR_CRM_ObjPromoSelectAccTarGroupCtrl.Model constructModel(Id promoId) {
            EUR_CRM_ObjPromoSelectAccTarGroupCtrl.Model m = new EUR_CRM_ObjPromoSelectAccTarGroupCtrl.Model();
            if (String.isNotEmpty(promoId)) {

                m.promo = selector.selectPromotionsById(promoId);
                m.accountGroup = String.isNotEmpty(m.promo.EUR_CRM_Account_Target_Group__c)
                        ? selector.selectAccountGroupById(m.promo.EUR_CRM_Account_Target_Group__c)
                        : null;
                m.accountsInTargetGroup = String.isNotEmpty(m.promo.EUR_CRM_Account_Target_Group__c)
                        ? selector.selectAccountInGroupByAccountGroupId(m.promo.EUR_CRM_Account_Target_Group__c)
                        : null;
            }
            return m;
        }
    }

    public class Selector {
        public EUR_CRM_Objectives_Promotions__c selectPromotionsById(Id promoId) {
            List<EUR_CRM_Objectives_Promotions__c> promos = [
                    SELECT Id
                            , EUR_CRM_Account_Target_Group__c
                    FROM EUR_CRM_Objectives_Promotions__c
                    WHERE Id = :promoId
            ];
            return promos.isEmpty() ? new EUR_CRM_Objectives_Promotions__c() : promos.get(0);
        }

        public EUR_CRM_Account_Target_Group__c selectAccountGroupById(Id groupId) {
            return [
                    SELECT Id
                            , Name
                            , EUR_CRM_Criteria__c
                            , EUR_CRM_IsDynamic__c
//                            , (
//                            SELECT Id
//                                    , EUR_CRM_Account__r.Id
//                                    , EUR_CRM_Account__r.Name
//                                    , EUR_CRM_Account__r.Owner.Name
//                                    , EUR_CRM_Account__r.EUR_CRM_Channel__c
//                                    , EUR_CRM_Account__r.EUR_CRM_Address__c
//                                    , EUR_CRM_Account__r.EUR_CRM_Street__c
//                                    , EUR_CRM_Account__r.EUR_CRM_City__c
//                                    , EUR_CRM_Account__r.EUR_CRM_Account_Code__c
//                            FROM Account_in_Target_Groups__r
//                            ORDER BY EUR_CRM_Account__r.Name ASC
//                            LIMIT 2000
//                    )
                    FROM EUR_CRM_Account_Target_Group__c
                    WHERE Id = :groupId
            ];
        }

        public List<EUR_CRM_Account_in_Target_Group__c> selectAccountInGroupByAccountGroupId(Id groupId) {
            return [
                    SELECT Id
                        , EUR_CRM_Account__r.Id
                        , EUR_CRM_Account__r.Name
                        , EUR_CRM_Account__r.Owner.Name
                        , EUR_CRM_Account__r.EUR_CRM_Channel__c
                        , EUR_CRM_Account__r.EUR_CRM_Address__c
                        , EUR_CRM_Account__r.EUR_CRM_Street__c
                        , EUR_CRM_Account__r.EUR_CRM_City__c
                        , EUR_CRM_Account__r.EUR_CRM_Account_Code__c
                        , EUR_CRM_Account_Target_Group__c
                        , EUR_CRM_Account_Target_Group__r.Name
                        , EUR_CRM_Account_Target_Group__r.EUR_CRM_Criteria__c
                        , EUR_CRM_Account_Target_Group__r.EUR_CRM_IsDynamic__c
                    FROM EUR_CRM_Account_in_Target_Group__c
                    WHERE EUR_CRM_Account_Target_Group__c =: groupId
                    ORDER BY EUR_CRM_Account__r.Name ASC
                    LIMIT 2000
            ];
        }

        public List<EUR_CRM_Account__c> selectAccountsByIds(List<String> idSet) {
            return [
                    SELECT Id
                            , Name
                            , Owner.Name
                            , EUR_CRM_Channel__c
                            , EUR_CRM_Address__c
                            , EUR_CRM_Street__c
                            , EUR_CRM_City__c
                            , EUR_CRM_Account_Code__c

                    FROM EUR_CRM_Account__c
                    WHERE Id IN :idSet
                    ORDER BY Name ASC
                    LIMIT 2000
            ];
        }

    }

    public class GroupSelector {

        public List<SObject> selectAccountGroups(String promoId) {
            return [
                SELECT Id
                        , Name
                        , EUR_CRM_Criteria__c
                        , EUR_CRM_IsDynamic__c
                        , (
                        SELECT Id
                                , EUR_CRM_Account__r.Id
                                , EUR_CRM_Account__r.Name
                                , EUR_CRM_Account__r.Owner.Name
                                , EUR_CRM_Account__r.EUR_CRM_Channel__c
                                , EUR_CRM_Account__r.EUR_CRM_Address__c
                                , EUR_CRM_Account__r.EUR_CRM_Street__c
                                , EUR_CRM_Account__r.EUR_CRM_City__c
                                , EUR_CRM_Account__r.EUR_CRM_Account_Code__c
                        FROM Account_in_Target_Groups__r
                        ORDER BY EUR_CRM_Account__r.Name ASC
                        LIMIT 2000
                )
                FROM EUR_CRM_Account_Target_Group__c
                ORDER BY Name ASC
                LIMIT 2000
            ];
        }
    }

}