/*********************************************************************************
 * Name:ASI_CRM_SG_RevisedContract_Approve
 * Description: Handle the revised contract when management approve it
 * Test Class: ASI_CRM_SG_RevisedContract_ApproveTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-18       Laputa: Vincent     	Created: main structure copy from ASI_CRM_SG_RevisedContract_Handler
 * 2018-04-05       Wilken Lee     			[WL 1.0] Auto relink outlet's offtake when proposal is converted or contract is approved
 * 2018-04-07       Laputa: Vincent			[VL 1.0] No need to update Adjustment = true because linking offtakes to contract will do the same calculation
*********************************************************************************/
public with sharing class ASI_CRM_SG_RevisedContract_Approve extends ASI_CRM_SG_TriggerAbstract {

    public static final String ARCHIVED_STATUS = 'Archived';
    public static final String APPROVED_STATUS_CONTRACT = 'Contract Approved';
    public static final String APPROVED_STATUS_PROPOSAL = 'Proposal Approved';
    public static final String REJECTED_STATUS = 'Contract Rejected';
    public static final String DRAFT_STATUS = 'Draft';
    public static final String SUBMITTED_STATUS = 'Submitted';

    public static final String CONTRACT_SNAPSHOT_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Archived');
    public static final String PROPOSAL_SNAPSHOT_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Archived');

    public static final String CONTRACT_READONLY_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only');
    public static final String PROPOSAL_READONLY_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');

    public static final String CONTRACT_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract');
    public static final String PROPOSAL_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal');

    public static final Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP         = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> CONTRACT_OUTLET_FIELD_MAP  = Schema.SObjectType.ASI_CRM_Contract_Outlets__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> PAYMENT_SCHEDULE_FIELD_MAP = Schema.SObjectType.ASI_CRM_Payment_Schedule__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> CONTRACT_TARGET_FIELD_MAP  = Schema.SObjectType.ASI_CRM_ContractTarget__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> PAYMENT_REQUEST_FIELD_MAP  = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> FOC_FIELD_MAP = Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> OFFTAKE_FIELD_MAP  = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c.fields.getMap();
    
    

  public ASI_CRM_SG_RevisedContract_Approve() {
    super('ASI_CRM_SG_RevisedContract_Approve');
  }
  
  /*[WL 1.0] BEGIN*/
  public static void relinkOfftakeToContract (List<ASI_TH_CRM_Contract__c> newContractList, Map<ID, ASI_TH_CRM_Contract__c> newMap, Map<ID, ASI_TH_CRM_Contract__c> oldContractMap){
	Set<Id> custIDSet = new Set<Id>();
	List<String> custIDStrList = new List<String>();
	Set<Id> contractIDSet = new Set<Id>();
	Set<String> contractIdStrSet = new Set<String>();
	
	//Check for Converted Proposal and Approved Revision Contract to relink offtake
	for (ASI_TH_CRM_Contract__c contract:newContractList){
		system.debug('contract status: ' + contract.ASI_TH_CRM_Contract_Status__c + ' oldContractMap: ' + oldContractMap);
		if (contract.ASI_TH_CRM_Contract_Status__c == APPROVED_STATUS_CONTRACT){
			if (oldContractMap == null || (oldContractMap != null && oldContractMap.get(contract.Id) != null && oldContractMap.get(contract.Id).ASI_TH_CRM_Contract_Status__c == SUBMITTED_STATUS)){
				custIDSet.add(contract.ASI_CRM_CN_Outlet_WS__c);
				custIDStrList.add(String.ValueOf(contract.ASI_CRM_CN_Outlet_WS__c));
				contractIDSet.add(contract.Id);
				contractIdStrSet.add(String.ValueOf(contract.Id));
			}
		}
	}
	
	//Check for Contract Child Outlet to relink offtake as well
	if (contractIDSet != null){
		for (ASI_CRM_Contract_Outlets__c cOutlet:[SELECT ASI_CRM_SG_Customer__c FROM ASI_CRM_Contract_Outlets__c WHERE ASI_CRM_SG_Contract__c in :contractIDSet]){
			custIDSet.add(cOutlet.ASI_CRM_SG_Customer__c);
			custIDStrList.add(String.ValueOf(cOutlet.ASI_CRM_SG_Customer__c));
		}
	}
	
	system.debug('custIDSet: ' + custIDSet + ' contractIdStrSet:' + contractIdStrSet);
	if (custIDSet != null){
        /* [VL 1.0] BEGIN */
        /*
		List<ASI_TH_CRM_Actual_Offtake__c>  offtakeToRelinkList = [SELECT Id, ASI_CRM_Adjustment__c FROM ASI_TH_CRM_Actual_Offtake__c 
																	WHERE ASI_CRM_SG_Customer__c IN :custIDSet AND ASI_CRM_Contract__c = ''];

		system.debug('offtakeToRelinkList size: ' + offtakeToRelinkList.size());
		
		for (ASI_TH_CRM_Actual_Offtake__c o:offtakeToRelinkList)
			o.ASI_CRM_Adjustment__c = true;

		update offtakeToRelinkList;
        */
        /* [VL 1.0] END */
		
		system.debug('custIDStrList: ' + custIDStrList);
		for (String custIDStr:custIDStrList)
			Database.executeBatch(new ASI_CRM_SG_AssignContractToOfftake_Batch(custIDStr), 200);
        /* [VL 1.0] END */
		
	}
	/*[WL 1.0] END*/
  }

  public override void executeTriggerAction (TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    Map<Id, ASI_TH_CRM_Contract__c> oldContractMap = (Map<Id, ASI_TH_CRM_Contract__c>) oldMap;
      List<ASI_TH_CRM_Contract__c> contractList = oldContractMap.values();
      Map<Id, ASI_TH_CRM_Contract__c> newContractMap = (Map<Id, ASI_TH_CRM_Contract__c>) newMap;

    //Filter the contract that find out the which contract is approved or rejected
    Set<String> possibleContractNameSet = new Set<String>();
    Set<id> toBeDeleteContractIdSet = new Set<id>();
    Map<string, ASI_TH_CRM_Contract__c> possibleContractMap = new Map<string, ASI_TH_CRM_Contract__c>();

    //Get the original contract id, approved contract, rejected contract
    for(ASI_TH_CRM_Contract__c contract : contractList) {
      if(String.isNotBlank(contract.ASI_CRM_Original_Version__c) &&
         (newContractMap.get(contract.Id).ASI_TH_CRM_Contract_Status__c.equalsIgnoreCase(APPROVED_STATUS_CONTRACT) || newContractMap.get(contract.Id).ASI_TH_CRM_Contract_Status__c.equalsIgnoreCase(APPROVED_STATUS_PROPOSAL)) &&
          contract.ASI_TH_CRM_Contract_Status__c.equalsIgnoreCase(SUBMITTED_STATUS)) {
              if (contract.RecordTypeId == CONTRACT_RECORD_TYPE_ID) {
                possibleContractNameSet.add(contract.name.substring(0,15));
        		possibleContractMap.put(contract.name.substring(0,15), contract);
                  toBeDeleteContractIdSet.add(contract.id);
              } else {
                possibleContractNameSet.add(contract.name.substring(0,17));
        		possibleContractMap.put(contract.name.substring(0,17), contract);
                  toBeDeleteContractIdSet.add(contract.id);
              }
              
      }
    }

    //Execute if the contract fulfill the criteria
    if(possibleContractNameSet.size() > 0) {

      //Get the origianl contract (Map<Origianl Contract Id, Latest Revised Contract))
      Map<String, ASI_TH_CRM_Contract__c> originalContractMap = getOriginalContractMap(possibleContractNameSet, toBeDeleteContractIdSet);
        
      Map<ASI_TH_CRM_Contract__c, ASI_TH_CRM_Contract__c> finalContractMap = new Map<ASI_TH_CRM_Contract__c, ASI_TH_CRM_Contract__c>();
        
        for (string cName : originalContractMap.keySet()){
            if (possibleContractMap.containsKey(cName)){
                finalContractMap.put(possibleContractMap.get(cName),originalContractMap.get(cName));
            }
        }
      if(finalContractMap.size() > 0) {
        handleApproveRevisedContract(finalContractMap);
      } 

    }
  }

  
  //Handle the rejected contract
  private void handleApproveRevisedContract(Map<ASI_TH_CRM_Contract__c,ASI_TH_CRM_Contract__c> finalContractMap) {
    //Get all old/current contract child records (Contract Outlet, Payment Schedule, Contract Target)
    Set<Id> contractIdSet = new Set<Id>();

    for(ASI_TH_CRM_Contract__c contract : finalContractMap.keySet()) {
      contractIdSet.add(contract.Id);
    }

    //Get the old contract child records (Contract Outlet, Payment Schedule, Contract Target)
    Set<Id> originalContractIdSet = new Set<Id>();

    for(ASI_TH_CRM_Contract__c contract : finalContractMap.values()) {
      originalContractIdSet.add(contract.Id);
    }

    List<ASI_TH_CRM_PaymentRequest__c> paymentRequestList  = getPaymentRequestList(originalContractIdSet);
    List<ASI_FOC_Free_Goods_Request__c> focList = getFOCList(originalContractIdSet);
    List<ASI_TH_CRM_Actual_Offtake__c> offtakeList    = getOfftakeList(originalContractIdSet);
      
      Map<Id, List<ASI_TH_CRM_PaymentRequest__c>> paymentRequestMap  = new Map<Id, List<ASI_TH_CRM_PaymentRequest__c>>();
    Map<Id, List<ASI_FOC_Free_Goods_Request__c>> focMap = new Map<Id, List<ASI_FOC_Free_Goods_Request__c>>();
    Map<Id, List<ASI_TH_CRM_Actual_Offtake__c>> offtakeMap    = new Map<Id, List<ASI_TH_CRM_Actual_Offtake__c>>();

    for(ASI_TH_CRM_PaymentRequest__c paymentRequest : paymentRequestList) {
        List<ASI_TH_CRM_PaymentRequest__c> tempList = new List<ASI_TH_CRM_PaymentRequest__c>();
        if(paymentRequestMap.containsKey(paymentRequest.ASI_TH_CRM_Contract__c)) {
          tempList = paymentRequestMap.get(paymentRequest.ASI_TH_CRM_Contract__c);
        }
        tempList.add(paymentRequest);
        paymentRequestMap.put(paymentRequest.ASI_TH_CRM_Contract__c, tempList);
    }

    for(ASI_FOC_Free_Goods_Request__c foc : focList) {
        List<ASI_FOC_Free_Goods_Request__c> tempList = new List<ASI_FOC_Free_Goods_Request__c>();
        if(focMap.containsKey(foc.ASI_CRM_Contract__c)) {
          tempList = focMap.get(foc.ASI_CRM_Contract__c);
        }
        tempList.add(foc);
        focMap.put(foc.ASI_CRM_Contract__c, tempList);
    }

    for(ASI_TH_CRM_Actual_Offtake__c offtake : offtakeList) {
        List<ASI_TH_CRM_Actual_Offtake__c> tempList = new List<ASI_TH_CRM_Actual_Offtake__c>();
        if(offtakeMap.containsKey(offtake.ASI_CRM_Contract__c)) {
          tempList = offtakeMap.get(offtake.ASI_CRM_Contract__c);
        }
        tempList.add(offtake);
        offtakeMap.put(offtake.ASI_CRM_Contract__c, tempList);
    }

    //Update the child records that must be linked to current contract
    //Copy the old contract data to current contract
    //Delete the old contract
    List<ASI_TH_CRM_Contract__c> updateContractList = new List<ASI_TH_CRM_Contract__c>();
    List<ASI_TH_CRM_Contract__c> deleteContractList = new List<ASI_TH_CRM_Contract__c>();

    List<ASI_TH_CRM_PaymentRequest__c> updatePaymentRequestList    = new List<ASI_TH_CRM_PaymentRequest__c>();
    List<ASI_FOC_Free_Goods_Request__c> updateFOCList    = new List<ASI_FOC_Free_Goods_Request__c>();
    List<ASI_TH_CRM_Actual_Offtake__c> updateOfftakeList    = new List<ASI_TH_CRM_Actual_Offtake__c>();
      

    for(ASI_TH_CRM_Contract__c contract : finalContractMap.keySet()) {
      //if(originalContractMap.containsKey(contract.ASI_CRM_Original_Version__c)) {
        ASI_TH_CRM_Contract__c tempContract = finalContractMap.get(contract);

        if(paymentRequestMap.containsKey(tempContract.Id)) {
          for(ASI_TH_CRM_PaymentRequest__c paymentRequest : paymentRequestMap.get(tempContract.Id)) {
            ASI_TH_CRM_PaymentRequest__c tempRecord = paymentRequest;
            tempRecord.ASI_TH_CRM_Contract__c = contract.Id;
            updatePaymentRequestList.add(tempRecord);
          }
        }

        if(focMap.containsKey(tempContract.Id)) {
          for(ASI_FOC_Free_Goods_Request__c foc : focMap.get(tempContract.Id)) {
            ASI_FOC_Free_Goods_Request__c tempRecord = foc;
            tempRecord.ASI_CRM_Contract__c = contract.Id;
            updateFOCList.add(tempRecord);
          }
        }

        if(offtakeMap.containsKey(tempContract.Id)) {
          for(ASI_TH_CRM_Actual_Offtake__c offtake : offtakeMap.get(tempContract.Id)) {
            ASI_TH_CRM_Actual_Offtake__c tempRecord = offtake;
            tempRecord.ASI_CRM_Contract__c = contract.Id;
            updateOfftakeList.add(tempRecord);
          }
        }

          
        if(tempContract.RecordTypeId == CONTRACT_READONLY_RECORD_TYPE_ID) {
          tempContract.RecordTypeId = CONTRACT_SNAPSHOT_RECORD_TYPE_ID;
        } else if(tempContract.RecordTypeId == PROPOSAL_READONLY_RECORD_TYPE_ID) {
          tempContract.RecordTypeId = PROPOSAL_SNAPSHOT_RECORD_TYPE_ID;
        }
        tempContract.ASI_TH_CRM_Contract_Status__c = ARCHIVED_STATUS;
          
        updateContractList.add(tempContract);
      //}
    }

    update updateContractList;
    
      update updatePaymentRequestList;
      update updateFOCList;
      update updateOfftakeList;
      
      
  }

  /********************
  Functions for collecting records
  ********************/

  private Map<string, ASI_TH_CRM_Contract__c> getOriginalContractMap(Set<string> possibleContractName, Set<id> toBeDeleteContractIdSet) {
    String queryStr = 'SELECT ';
    queryStr += genQueryField(CONTRACT_FIELD_MAP);
    queryStr += ' FROM ASI_TH_CRM_Contract__c';
    queryStr += ' WHERE ASI_TH_CRM_Contract_Status__c in  (\'' + APPROVED_STATUS_CONTRACT + '\',\'' + APPROVED_STATUS_PROPOSAL + '\')';
    queryStr += ' AND recordtypeid in (\'' + CONTRACT_READONLY_RECORD_TYPE_ID + '\',\'' + PROPOSAL_READONLY_RECORD_TYPE_ID + '\')';
    queryStr += ' AND id not in :toBeDeleteContractIdSet ';
    queryStr += ' AND (';
      for (string cName : possibleContractName){
          queryStr += 'name like \'' + cName + '%\' or ';
      }
    queryStr = queryStr.subString(0, queryStr.length() - 3);
    queryStr += ')';
      //system.debug(queryStr);
      

    List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(queryStr);
    Map<string, ASI_TH_CRM_Contract__c> contractMap = new Map<string, ASI_TH_CRM_Contract__c>();

    for(ASI_TH_CRM_Contract__c contract : contractList) {
      if(contract.RecordTypeId == CONTRACT_READONLY_RECORD_TYPE_ID) {
        contractMap.put(contract.name.substring(0,15), contract);
      } else {
        contractMap.put(contract.name.substring(0,17), contract);
      }
    }

    return contractMap;
  }

  private List<ASI_TH_CRM_PaymentRequest__c> getPaymentRequestList(Set<Id> contractIdSet) {
    String queryStr = 'SELECT ';
    queryStr += genQueryField(PAYMENT_REQUEST_FIELD_MAP);
    queryStr += ' FROM ASI_TH_CRM_PaymentRequest__c';
    queryStr += ' WHERE ASI_TH_CRM_Contract__c in :contractIdSet';
    
    return (List<ASI_TH_CRM_PaymentRequest__c>) Database.query(queryStr);
  }

  private List<ASI_FOC_Free_Goods_Request__c> getFOCList(Set<Id> contractIdSet) {
    String queryStr = 'SELECT ';
    queryStr += genQueryField(FOC_FIELD_MAP);
    queryStr += ' FROM ASI_FOC_Free_Goods_Request__c';
    queryStr += ' WHERE ASI_CRM_Contract__c in :contractIdSet';
    
    return (List<ASI_FOC_Free_Goods_Request__c>) Database.query(queryStr);
  }

  private List<ASI_TH_CRM_Actual_Offtake__c> getOfftakeList(Set<Id> contractIdSet) {
    String queryStr = 'SELECT ';
    queryStr += genQueryField(OFFTAKE_FIELD_MAP);
    queryStr += ' FROM ASI_TH_CRM_Actual_Offtake__c';
    queryStr += ' WHERE ASI_CRM_Contract__c in :contractIdSet';
    
    return (List<ASI_TH_CRM_Actual_Offtake__c>) Database.query(queryStr);
  }

  private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
      String queryField = '';
      for(String field : fieldMap.keySet()) {
        queryField += field + ',';
      }
      return queryField.subString(0, queryField.length() - 1);
    }

}