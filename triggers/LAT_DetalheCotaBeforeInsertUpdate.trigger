trigger LAT_DetalheCotaBeforeInsertUpdate on LAT_DetalheCotaMarket__c (before update, before insert) {
    LAT_DetalheCota.validateDetalhe(Trigger.new);
    LAT_DetalheCota.updateDetalhe(Trigger.new);

    if(Trigger.isUpdate){
    LAT_DetalheCota.negativeConsumptionNotification(Trigger.new, Trigger.oldMap);
	}
}