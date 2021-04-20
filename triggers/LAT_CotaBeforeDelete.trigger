trigger LAT_CotaBeforeDelete on LAT_DetalheCotaMarket__c (before Delete) {
    Lat_Cota.cotaDeleted(Trigger.old);
}