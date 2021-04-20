trigger LAT_ReferenceProductBefore on LAT_ReferenceProduct__c (before insert, before update, after insert, after update) {

	if (trigger.isBefore) {

		if (trigger.isInsert) {
			if(!LAT_ReferenceProduct.uniqueGroupByRecordType(trigger.new)) {
				return;
			}
		}
		LAT_ReferenceProduct.UniqueProduct(trigger.new, trigger.oldMap, trigger.isUpdate);
		LAT_ReferenceProduct.InsertValues(trigger.new);
		LAT_ReferenceProduct.validateGrouping(trigger.new, trigger.isUpdate);
		//LAT_ReferenceProduct.preventExistingSKU(trigger.new,trigger.oldMap,trigger.isUpdate);
		LAT_ReferenceProduct.deactivateRecords(trigger.new,trigger.oldMap,trigger.isUpdate);
		
		
	}

}