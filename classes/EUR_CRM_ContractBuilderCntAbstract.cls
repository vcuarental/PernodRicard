public interface EUR_CRM_ContractBuilderCntAbstract {
	void processComponentCallbackAdd(String componentId , String mechanicName, List<sObject> addedDataList);
	void processComponentCallbackRemove(String componentId, String mechanicName, List<sObject> removedDataList);
}