trigger LAT_MX_RFCBeforeUpdate on LAT_RFC__c (before update) {
    LAT_MX_RFC.createUpdateRFC(Trigger.new);
}