public with sharing class EUR_CRM_SalesOrderAssignManager extends EUR_CRM_TriggerAbstract  {

	public EUR_CRM_SalesOrderAssignManager() {
    	super('EUR_CRM_SalesOrderAssignManager');
	}

	private static final Set<String> SO_RT_TO_UPDATE_MANAGER = EUR_CRM_RecordTypeHelper_v2.getSettingsSet(
		EUR_CRM_SalesOrderAssignManager.class.getName(), 'SO_RT_TO_UPDATE_MANAGER');
//	private static final Set<String> SO_RT_TO_UPDATE_MANAGER = new Set<String>{
//      'EUR_ZA_Direct_Sales_Order',
//      'EUR_ZA_Free_Goods_Order',
//      'EUR_CH_Direct_Sales_Order',
//      'EUR_CH_Indirect_Sales_Order',
//      'EUR_DK_Free_Goods_Order_to_Customer'
//	};
  
	public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		Map<Id, RecordTypeInfo> rtInfoById = Schema.SObjectType.EUR_CRM_Sales_Order__c.getRecordTypeInfosById();

		List<EUR_CRM_Sales_Order__c> sos = (List<EUR_CRM_Sales_Order__c>) sObjList;
        List<EUR_CRM_Sales_Order__c> sosToUpdate = new List<EUR_CRM_Sales_Order__c>();
        
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> soIds = new Set<Id>();
        
        for(EUR_CRM_Sales_Order__c so : sos) {
        	String soRtDevName = rtInfoById.get(so.RecordtypeId).getDeveloperName();
        	if(SO_RT_TO_UPDATE_MANAGER.contains(soRtDevName) ){
        		ownerIds.add(so.CreatedById);
        		sosToUpdate.add(so);
        		soIds.add(so.id);
        	}
        }
        
        if(sosToUpdate.isEmpty()) { return; }
		List<EUR_CRM_Sales_Order__c> updatedSOs = this.updateSO(soIds, ownerIds);
		update updatedSOs;
	}

	private List<EUR_CRM_Sales_Order__c> updateSO(Set<Id> soIds, Set<Id> ownerIds) {
		List<EUR_CRM_Sales_Order__c> queriedValidSalesOrderList = this.selectSOsWhereIds(soIds);
		Map<ID, User> ownerById = this.selectUsersWhereIds(ownerIds);
		for (EUR_CRM_Sales_Order__c so : queriedValidSalesOrderList) {
			User u = ownerById.get(so.CreatedById);
			so.EUR_CRM_Manager__c = u.managerID;
		}
		return queriedValidSalesOrderList;
	}

	/* ========================================================= */
	/*      SOQL Selectors
	/* ========================================================= */
	private Map<Id, User> selectUsersWhereIds(Set<Id> ownerIDSet) {
		return new Map<ID, User>([
			SELECT Id
			,	ManagerID
			FROM User
			WHERE Id IN :ownerIDSet
		]);
	}

	private List<EUR_CRM_Sales_Order__c> selectSOsWhereIds(Set<Id> salesOrderIDSet) {
		return [
			SELECT Id
			,	Name
			,	CreatedById
			,	EUR_CRM_Manager__c
			FROM EUR_CRM_Sales_Order__c
			WHERE Id IN :salesOrderIDSet
		];
	}
}