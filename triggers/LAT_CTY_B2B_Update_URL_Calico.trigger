trigger LAT_CTY_B2B_Update_URL_Calico on LAT_FiscalNote__c (before insert, before update) {
  List<LAT_Opportunity__c> orders = new List<LAT_Opportunity__c>();
  Map<Id, LAT_FiscalNote__c> orderFiscalNoteMap = new Map<Id, LAT_FiscalNote__c>();
  // Relation LAT_Opportunity__c - LAT_FiscalNote__c (1 - 1)
  for (LAT_FiscalNote__c fiscalNote : Trigger.New) {
    orderFiscalNoteMap.put(fiscalNote.LAT_Opportunity__c, fiscalNote);
  }
  Map<Id, LAT_Opportunity__c> ordersMap = new Map<Id, LAT_Opportunity__c>([Select Id, LAT_CTY_B2B_URL_Calico__c From LAT_Opportunity__c Where Id = :orderFiscalNoteMap.keySet()]);
  for (LAT_Opportunity__c order : ordersMap.values()) {
    order.LAT_CTY_B2B_URL_Calico__c = orderFiscalNoteMap.get(order.Id).LAT_B2B_URL_Calico__c;
    orders.add(order);
  }
  update orders;

}