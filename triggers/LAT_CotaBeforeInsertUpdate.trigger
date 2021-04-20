trigger LAT_CotaBeforeInsertUpdate on LAT_CotaMarket__c (before update, before insert) {
    LAT_Cota.validateProduct(Trigger.new);
        LAT_Cota.updateInitDate(Trigger.new);

}