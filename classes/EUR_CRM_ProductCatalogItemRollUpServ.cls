public with sharing class EUR_CRM_ProductCatalogItemRollUpServ {

//	private final Set<String> lookupFieldsToFetch = new Set<String>{
//		'EUR_CRM_SKU__c'
//	,	'EUR_CRM_Brand_Quality_Size__c'
//	,	'EUR_CRM_POS_Material__c'
//	};
    private Set<Id> skuIds = new Set<Id>();
    private Set<Id> bqsIds = new Set<Id>();
    private Set<Id> posmIds = new Set<Id>();

    private Map<String, Set<Id>> lookupFieldsToFetch = new Map<String, Set<Id>>{
            'EUR_CRM_SKU__c' => skuIds
            , 'EUR_CRM_Brand_Quality_Size__c' => bqsIds
            , 'EUR_CRM_POS_Material__c' => posmIds
    };

    private Map<String, Set<Id>> lookupFieldsToSetZeroPCIs = new Map<String, Set<Id>>{
            'EUR_CRM_SKU__c' => new Set<Id>()
            , 'EUR_CRM_Brand_Quality_Size__c' => new Set<Id>()
            , 'EUR_CRM_POS_Material__c' => new Set<Id>()
    };

    private Map<String, String> sobjByLookupField = new Map<String, String>{
            'EUR_CRM_SKU__c' => 'EUR_CRM_SKU__c'
            , 'EUR_CRM_Brand_Quality_Size__c' => 'EUR_CRM_Size__c'
            , 'EUR_CRM_POS_Material__c' => 'EUR_CRM_POS_Material__c'
    };

    private List<EUR_CRM_SKU__c> skuToUpdate = new List<EUR_CRM_SKU__c>();
    private List<EUR_CRM_Size__c> bqsToUpdate = new List<EUR_CRM_Size__c>();
    private List<EUR_CRM_POS_Material__c> posmToUpdate = new List<EUR_CRM_POS_Material__c>();

    public void updateParentsRollUpFields(List<EUR_CRM_ProductCatalogItem__c> pcis) {
        this.initProductIdsToCountPCIs(pcis);
        this.updateProductsRollUps();
    }


    public void updateParentsRollUpFields(List<EUR_CRM_ProductCatalogItem__c> pcis, Map<Id, EUR_CRM_ProductCatalogItem__c> oldPciById) {
        this.initProductIdsToCountPCIs(pcis, oldPciById);
        this.updateProductsRollUps();
    }


    //High level helpers
    private void initProductIdsToCountPCIs(List<EUR_CRM_ProductCatalogItem__c> pcis) {
        for (EUR_CRM_ProductCatalogItem__c pci : pcis) {
            for (String field : this.lookupFieldsToFetch.keySet()) {
                Id prodId = (Id) pci.get(field);
                if (prodId == null) {
                    continue;
                }
                this.lookupFieldsToFetch.get(field).add(prodId);
                if (this.isAfterDelete()) {
                    this.lookupFieldsToSetZeroPCIs.get(field).add(prodId);
                }
            }
        }
    }

    private Boolean isAfterDelete() {
        return Trigger.isDelete && Trigger.isAfter;
    }

    private void initProductIdsToCountPCIs(List<EUR_CRM_ProductCatalogItem__c> pcis, Map<Id, EUR_CRM_ProductCatalogItem__c> oldPciById) {
        for (EUR_CRM_ProductCatalogItem__c pci : pcis) {
            for (String field : this.lookupFieldsToFetch.keySet()) {
                Id prodId = (Id) pci.get(field);
                Id oldProdId = (Id) oldPciById.get(pci.Id).get(field);
                if (prodId == oldProdId) {
                    continue;
                }
                this.lookupFieldsToFetch.get(field).add(oldProdId);
                if (prodId != null) {
                    this.lookupFieldsToFetch.get(field).add(prodId);
                } else {
                    this.lookupFieldsToSetZeroPCIs.get(field).add(oldProdId);
                }

            }
        }
    }

    private void updateProductsRollUps() {
        Map<String, Map<Id, Set<Id>>> pciIdsByProductIdBySobjName = this.getPciIdsByProductIdBySobjName(this.selectPCIsWhereProductIds());
        if (pciIdsByProductIdBySobjName.size() == 0) {
            this.updateProdsWithZeroCount();
        }
        for (String sobjName : pciIdsByProductIdBySobjName.keySet()) {
            Map<Id, Set<Id>> pciIdsByProductId = pciIdsByProductIdBySobjName.get(sobjName);
            for (Id prodId : pciIdsByProductId.keySet()) {
                Integer pbiCount = pciIdsByProductId.get(prodId).size();
                if (sobjName == 'EUR_CRM_SKU__c') {
                    skuToUpdate.add(this.updateSKU(prodId, pbiCount));
                }
                if (sobjName == 'EUR_CRM_Size__c') {
                    bqsToUpdate.add(this.updateBQS(prodId, pbiCount));
                }
                if (sobjName == 'EUR_CRM_POS_Material__c') {
                    posmToUpdate.add(this.updatePOSM(prodId, pbiCount));
                }
            }
        }


        Database.update(skuToUpdate, false);
        Database.update(bqsToUpdate, false);
        Database.update(posmToUpdate, false);
    }


    private Map<String, Map<Id, Set<Id>>> getPciIdsByProductIdBySobjName(List<EUR_CRM_ProductCatalogItem__c> pcisToCount) {
        Map<String, Map<Id, Set<Id>>> pciIdsByProductIdBySobjName = new Map<String, Map<Id, Set<Id>>>();
        for (EUR_CRM_ProductCatalogItem__c pci : pcisToCount) {
            for (String field : lookupFieldsToFetch.keySet()) {
                String sobjName = sobjByLookupField.get(field);
                Id prodId = (Id) pci.get(field);
                if (prodId == null || sobjName == null) {
                    continue;
                }
                this.populateTwoLevelMap(pciIdsByProductIdBySobjName, sobjName, prodId, pci);
            }
        }
        return pciIdsByProductIdBySobjName;
    }


    //Middle level helpers
    private void populateTwoLevelMap(Map<String, Map<Id, Set<Id>>> pciIdsByProductIdBySobjName, String sobjName, Id prodId, EUR_CRM_ProductCatalogItem__c pci) {
        if (pciIdsByProductIdBySobjName.containsKey(sobjName)) {
            if (pciIdsByProductIdBySobjName.get(sobjName).containsKey(prodId)) {
                pciIdsByProductIdBySobjName.get(sobjName).get(prodId).add(pci.Id);
            } else {
                pciIdsByProductIdBySobjName.get(sobjName).
                        put(prodId, new Set<Id>{
                                pci.Id
                        });
            }
        } else {
            pciIdsByProductIdBySobjName.put(sobjName, new Map<Id, Set<Id>>{
                    prodId => new Set<Id>{
                            pci.Id
                    }
            });
        }
    }

    private void updateProdsWithZeroCount() {
        for (String sobjName : this.lookupFieldsToSetZeroPCIs.keySet()) {
            for (Id prodId : this.lookupFieldsToSetZeroPCIs.get(sobjName)) {
                if (sobjName == 'EUR_CRM_SKU__c') {
                    skuToUpdate.add(this.updateSKU(prodId, 0));
                }
                if (sobjName == 'EUR_CRM_Brand_Quality_Size__c') {
                    bqsToUpdate.add(this.updateBQS(prodId, 0));
                }
                if (sobjName == 'EUR_CRM_POS_Material__c') {
                    posmToUpdate.add(this.updatePOSM(prodId, 0));
                }
            }
        }
    }


    //Low level helpers
    private EUR_CRM_POS_Material__c updatePOSM(Id prodId, Integer pbiCount) {
        return new EUR_CRM_POS_Material__c(Id = prodId, EUR_CRM_PBI_count__c = pbiCount);
    }

    private EUR_CRM_Size__c updateBQS(Id prodId, Integer pbiCount) {
        return new EUR_CRM_Size__c(Id = prodId, EUR_CRM_PBI_count__c = pbiCount);
    }

    private EUR_CRM_SKU__c updateSKU(Id prodId, Integer pbiCount) {
        return new EUR_CRM_SKU__c(Id = prodId, EUR_CRM_PBI_count__c = pbiCount);
    }


    //Selectors
    private List<EUR_CRM_ProductCatalogItem__c> selectPCIsWhereProductIds() {
        return [
                SELECT Id
                        , EUR_CRM_SKU__c
                        , EUR_CRM_Brand_Quality_Size__c
                        , EUR_CRM_POS_Material__c
                        , EUR_CRM_Is_Active__c
                FROM EUR_CRM_ProductCatalogItem__c
                WHERE EUR_CRM_SKU__c IN :this.skuIds
                OR EUR_CRM_Brand_Quality_Size__c IN :this.bqsIds
                OR EUR_CRM_POS_Material__c IN :this.posmIds
        ];
    }
}