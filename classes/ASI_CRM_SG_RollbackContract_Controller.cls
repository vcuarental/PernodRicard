/*********************************************************************************
 * Name:ASI_CRM_SG_RollbackContract_Controller
 * Description: Handle the rollback contract when user delete contract
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-01-19       Laputa: Hugo Cheung     Created
*********************************************************************************/
public class ASI_CRM_SG_RollbackContract_Controller {
	
    public static final String ARCHIVED_STATUS = 'Archived';
    public static final String APPROVED_STATUS = 'Contract Approved';
    public static final String REJECTED_STATUS = 'Contract Rejected';

	public static final String CONTRACT_SNAPSHOT_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Archived');
    public static final String PROPOSAL_SNAPSHOT_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Archived');

    public static final String CONTRACT_READONLY_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only');
    public static final String PROPOSAL_READONLY_RECORD_TYPE_ID = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Proposal_Read_Only');

    public static final Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP         = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> CONTRACT_OUTLET_FIELD_MAP  = Schema.SObjectType.ASI_CRM_Contract_Outlets__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> PAYMENT_SCHEDULE_FIELD_MAP = Schema.SObjectType.ASI_CRM_Payment_Schedule__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> CONTRACT_TARGET_FIELD_MAP  = Schema.SObjectType.ASI_CRM_ContractTarget__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> PAYMENT_REQUEST_FIELD_MAP  = Schema.SObjectType.ASI_TH_CRM_PaymentRequest__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> FOC_FIELD_MAP = Schema.SObjectType.ASI_FOC_Free_Goods_Request__c.fields.getMap();
    public static final Map<String, Schema.SObjectField> OFFTAKE_FIELD_MAP  = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c.fields.getMap();

    public ASI_CRM_SG_RollbackContract_Controller() {
    }
    
    public PageReference rollback() {
    	String contractId = ApexPages.CurrentPage().GetParameters().get('id');

    	if(String.isNotBlank(contractId)) {
    		ASI_TH_CRM_Contract__c contract = [SELECT Id, ASI_CRM_Original_Version__c
    		                                   FROM ASI_TH_CRM_Contract__c
    		                                   WHERE Id = :contractId];

    		if(String.isNotBlank(contract.ASI_CRM_Original_Version__c)) {
    			Map<Id, ASI_TH_CRM_Contract__c> originalContractMap = getOriginalContractMap(contractId, contract.ASI_CRM_Original_Version__c);

    			Savepoint sp = Database.setSavepoint();
    			try {
    				handleRollbackContract(contract, originalContractMap);
    			} catch(Exception e) {
					Database.rollback(sp);
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Fatal, e.getMessage()));
    			}
    		}

    	}

        return new PageReference('/' + contractId);
    }
    
    //Handle the rollback contract
	private void handleRollbackContract(ASI_TH_CRM_Contract__c contract, Map<Id, ASI_TH_CRM_Contract__c> originalContractMap) {
		//Get all old/current contract child records (Contract Outlet, Payment Schedule, Contract Target)
		//Get the old contract child records (Contract Outlet, Payment Schedule, Contract Target)
		Set<Id> originalContractIdSet = new Set<Id>();

		for(ASI_TH_CRM_Contract__c originalContract : originalContractMap.values()) {
			originalContractIdSet.add(originalContract.Id);
		}

		originalContractIdSet.add(contract.Id);

		List<ASI_CRM_Contract_Outlets__c> contractOutletList  = getContractOutletList(originalContractIdSet);
		List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = getPaymentScheduleList(originalContractIdSet);
		List<ASI_CRM_ContractTarget__c> contractTargetList    = getContractTargetList(originalContractIdSet);
		List<ASI_TH_CRM_PaymentRequest__c> paymentRequestList = getPaymentRequestList(originalContractIdSet);
    	List<ASI_FOC_Free_Goods_Request__c> focList           = getFOCList(originalContractIdSet);
    	List<ASI_TH_CRM_Actual_Offtake__c> offtakeList        = getOfftakeList(originalContractIdSet);


		//Retrieve current contract child records
		List<ASI_CRM_Contract_Outlets__c> deleteContractOutletList  = new List<ASI_CRM_Contract_Outlets__c>();
		List<ASI_CRM_Payment_Schedule__c> deletePaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
		List<ASI_CRM_ContractTarget__c> deleteContractTargetList    = new List<ASI_CRM_ContractTarget__c>();

		//Convert the child records to a Map<Old contract id, List<Child records>>
		Map<Id, List<ASI_CRM_Contract_Outlets__c>> contractOutletMap          = new Map<Id, List<ASI_CRM_Contract_Outlets__c>>();
		Map<Id, List<ASI_CRM_Payment_Schedule__c>> contractPaymentMap         = new Map<Id, List<ASI_CRM_Payment_Schedule__c>>();
		Map<Id, List<ASI_CRM_ContractTarget__c>> contractTargetMap            = new Map<Id, List<ASI_CRM_ContractTarget__c>>();
		Map<Id, List<ASI_TH_CRM_PaymentRequest__c>> contractPaymentRequestMap = new Map<Id, List<ASI_TH_CRM_PaymentRequest__c>>();
    	Map<Id, List<ASI_FOC_Free_Goods_Request__c>> contractFOCMap           = new Map<Id, List<ASI_FOC_Free_Goods_Request__c>>();
    	Map<Id, List<ASI_TH_CRM_Actual_Offtake__c>> contractOfftakeMap        = new Map<Id, List<ASI_TH_CRM_Actual_Offtake__c>>();

		for(ASI_CRM_Contract_Outlets__c contractOutlet : contractOutletList) {
			if(contract.Id == contractOutlet.ASI_CRM_SG_Contract__c) {
				deleteContractOutletList.add(contractOutlet);
			} else {
				List<ASI_CRM_Contract_Outlets__c> tempContractOutletList = new List<ASI_CRM_Contract_Outlets__c>();
				if(contractOutletMap.containsKey(contractOutlet.ASI_CRM_SG_Contract__c)) {
					tempContractOutletList = contractOutletMap.get(contractOutlet.ASI_CRM_SG_Contract__c);
				}
				tempContractOutletList.add(contractOutlet);
				contractOutletMap.put(contractOutlet.ASI_CRM_SG_Contract__c, tempContractOutletList);
			}
		}

		for(ASI_CRM_Payment_Schedule__c paymentSchedule : paymentScheduleList) {
			if(contract.Id == paymentSchedule.ASI_CRM_Contract__c) {
				deletePaymentScheduleList.add(paymentSchedule);
			} else {
				List<ASI_CRM_Payment_Schedule__c> tempPaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
				if(contractPaymentMap.containsKey(paymentSchedule.ASI_CRM_Contract__c)) {
					tempPaymentScheduleList = contractPaymentMap.get(paymentSchedule.ASI_CRM_Contract__c);
				}
				tempPaymentScheduleList.add(paymentSchedule);
				contractPaymentMap.put(paymentSchedule.ASI_CRM_Contract__c, tempPaymentScheduleList);
			} 
		}

		for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
			if(contract.Id == contractTarget.ASI_CRM_Contract__c) {
				deleteContractTargetList.add(contractTarget);
			} else {
				List<ASI_CRM_ContractTarget__c> tempContractTargetList = new List<ASI_CRM_ContractTarget__c>();
				if(contractTargetMap.containsKey(contractTarget.ASI_CRM_Contract__c)) {
					tempContractTargetList = contractTargetMap.get(contractTarget.ASI_CRM_Contract__c);
				}
				tempContractTargetList.add(contractTarget);
				contractTargetMap.put(contractTarget.ASI_CRM_Contract__c, tempContractTargetList);
			}
		}

		for(ASI_TH_CRM_PaymentRequest__c paymentRequest : paymentRequestList) {
			if(contract.Id != paymentRequest.ASI_TH_CRM_Contract__c) {
		        List<ASI_TH_CRM_PaymentRequest__c> tempList = new List<ASI_TH_CRM_PaymentRequest__c>();
		        if(contractPaymentRequestMap.containsKey(paymentRequest.ASI_TH_CRM_Contract__c)) {
		          tempList = contractPaymentRequestMap.get(paymentRequest.ASI_TH_CRM_Contract__c);
		        }
		        tempList.add(paymentRequest);
		        contractPaymentRequestMap.put(paymentRequest.ASI_TH_CRM_Contract__c, tempList);
	    	}
	    }

	    for(ASI_FOC_Free_Goods_Request__c foc : focList) {
			if(contract.Id != foc.ASI_CRM_Contract__c) {
		        List<ASI_FOC_Free_Goods_Request__c> tempList = new List<ASI_FOC_Free_Goods_Request__c>();
		        if(contractFOCMap.containsKey(foc.ASI_CRM_Contract__c)) {
		          tempList = contractFOCMap.get(foc.ASI_CRM_Contract__c);
		        }
		        tempList.add(foc);
		        contractFOCMap.put(foc.ASI_CRM_Contract__c, tempList);
	    	}
	    }

	    for(ASI_TH_CRM_Actual_Offtake__c offtake : offtakeList) {
			if(contract.Id != offtake.ASI_CRM_Contract__c) {
		        List<ASI_TH_CRM_Actual_Offtake__c> tempList = new List<ASI_TH_CRM_Actual_Offtake__c>();
		        if(contractOfftakeMap.containsKey(offtake.ASI_CRM_Contract__c)) {
		          tempList = contractOfftakeMap.get(offtake.ASI_CRM_Contract__c);
		        }
		        tempList.add(offtake);
		        contractOfftakeMap.put(offtake.ASI_CRM_Contract__c, tempList);
	    	}
	    }

		//Update the child records that must be linked to current contract
		//Copy the old contract data to current contract
		//Delete the old contract
		List<ASI_TH_CRM_Contract__c> updateContractList = new List<ASI_TH_CRM_Contract__c>();
		List<ASI_TH_CRM_Contract__c> deleteContractList = new List<ASI_TH_CRM_Contract__c>();

		List<ASI_CRM_Contract_Outlets__c> insertContractOutletList  = new List<ASI_CRM_Contract_Outlets__c>();
		List<ASI_CRM_Payment_Schedule__c> insertPaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
		List<ASI_CRM_ContractTarget__c> insertContractTargetList    = new List<ASI_CRM_ContractTarget__c>();

    	List<ASI_TH_CRM_PaymentRequest__c> updatePaymentRequestList = new List<ASI_TH_CRM_PaymentRequest__c>();
    	List<ASI_FOC_Free_Goods_Request__c> updateFOCList           = new List<ASI_FOC_Free_Goods_Request__c>();
    	List<ASI_TH_CRM_Actual_Offtake__c> updateOfftakeList        = new List<ASI_TH_CRM_Actual_Offtake__c>();

		if(originalContractMap.containsKey(contract.ASI_CRM_Original_Version__c)) {
			ASI_TH_CRM_Contract__c tempContract = originalContractMap.get(contract.ASI_CRM_Original_Version__c);

			if(contractOutletMap.containsKey(tempContract.Id)) {
				for(ASI_CRM_Contract_Outlets__c contractOutlet : contractOutletMap.get(tempContract.Id)) {
					ASI_CRM_Contract_Outlets__c tempContractOutlet = contractOutlet.clone(false, true, false, false);
					tempContractOutlet.ASI_CRM_SG_Contract__c = contract.Id;
					insertContractOutletList.add(tempContractOutlet);
				}
			}

			if(contractPaymentMap.containsKey(tempContract.Id)) {
				for(ASI_CRM_Payment_Schedule__c paymentSchedule : contractPaymentMap.get(tempContract.Id)) {
            		ASI_CRM_Payment_Schedule__c tempPaymentSchedule = paymentSchedule.clone(false, true, false, false);
					tempPaymentSchedule.ASI_CRM_Contract__c = contract.Id;
					insertPaymentScheduleList.add(tempPaymentSchedule);
				}
			}

			if(contractTargetMap.containsKey(tempContract.Id)) {
				for(ASI_CRM_ContractTarget__c contractTarget : contractTargetMap.get(tempContract.Id)) {
					ASI_CRM_ContractTarget__c tempContractTarget = contractTarget.clone(false, true, false, false);
					tempContractTarget.ASI_CRM_Contract__c = contract.Id;
					insertContractTargetList.add(tempContractTarget);
				}
			}

			if(contractPaymentRequestMap.containsKey(tempContract.Id)) {
				for(ASI_TH_CRM_PaymentRequest__c paymentRequest : contractPaymentRequestMap.get(tempContract.Id)) {
		            ASI_TH_CRM_PaymentRequest__c tempRecord = paymentRequest;
		            tempRecord.ASI_TH_CRM_Contract__c = contract.Id;
		            updatePaymentRequestList.add(tempRecord);
		          }
			}

			if(contractFOCMap.containsKey(tempContract.Id)) {
				for(ASI_FOC_Free_Goods_Request__c foc : contractFOCMap.get(tempContract.Id)) {
		            ASI_FOC_Free_Goods_Request__c tempRecord = foc;
		            tempRecord.ASI_CRM_Contract__c = contract.Id;
		            updateFOCList.add(tempRecord);
		       	}
			}

			if(contractOfftakeMap.containsKey(tempContract.Id)) {
				for(ASI_TH_CRM_Actual_Offtake__c offtake : contractOfftakeMap.get(tempContract.Id)) {
		            ASI_TH_CRM_Actual_Offtake__c tempRecord = offtake;
		            tempRecord.ASI_CRM_Contract__c = contract.Id;
		            updateOfftakeList.add(tempRecord);
		        }
			}

			ASI_TH_CRM_Contract__c rollbackContract = new ASI_TH_CRM_Contract__c();
			for(String field : CONTRACT_FIELD_MAP.keySet()) {
				if(CONTRACT_FIELD_MAP.get(field).getDescribe().isUpdateable()) {
					rollbackContract.put(field, tempContract.get(field));
				}
			}
			if(rollbackContract.RecordTypeId == CONTRACT_SNAPSHOT_RECORD_TYPE_ID) {
				rollbackContract.RecordTypeId = CONTRACT_READONLY_RECORD_TYPE_ID;
			} else if(rollbackContract.RecordTypeId == PROPOSAL_SNAPSHOT_RECORD_TYPE_ID) {
				rollbackContract.RecordTypeId = PROPOSAL_READONLY_RECORD_TYPE_ID;
			}
			rollbackContract.Id = contract.Id;

			deleteContractList.add(tempContract);
			updateContractList.add(rollbackContract);
		}

		/*
		if(deleteContractList.size() > 0) delete deleteContractList;

		if(deleteContractOutletList.size() > 0) delete deleteContractOutletList;
		if(deletePaymentScheduleList.size() > 0) delete deletePaymentScheduleList;
		if(deleteContractTargetList.size() > 0) delete deleteContractTargetList;

		if(updateContractList.size() > 0) update updateContractList;

		if(updatePaymentRequestList.size() > 0) update updatePaymentRequestList;
      	if(updateFOCList.size() > 0) update updateFOCList;
      	if(updateOfftakeList.size() > 0) update updateOfftakeList;
		*/
		if(updateContractList.size() > 0) update updateContractList;

		if(updatePaymentRequestList.size() > 0) update updatePaymentRequestList;
      	if(updateFOCList.size() > 0) update updateFOCList;
      	if(updateOfftakeList.size() > 0) update updateOfftakeList;
		
		if(deleteContractList.size() > 0) delete deleteContractList;

		if(deleteContractOutletList.size() > 0) delete deleteContractOutletList;
		if(deletePaymentScheduleList.size() > 0) delete deletePaymentScheduleList;
		if(deleteContractTargetList.size() > 0) delete deleteContractTargetList;

		if(insertContractOutletList.size() > 0) insert insertContractOutletList;
		if(insertPaymentScheduleList.size() > 0) insert insertPaymentScheduleList;
		if(insertContractTargetList.size() > 0) insert insertContractTargetList;
	}

	/********************
	Functions for collecting records
	********************/
	private Map<Id, ASI_TH_CRM_Contract__c> getOriginalContractMap(Id contractId, Id originalContractId) {
		String queryStr = 'SELECT ';
		queryStr += genQueryField(CONTRACT_FIELD_MAP);
		queryStr += ' FROM ASI_TH_CRM_Contract__c';
		queryStr += ' WHERE (Id = :originalContractId OR ASI_CRM_Original_Version__c = :originalContractId)';
		queryStr += ' AND ASI_TH_CRM_Contract_Status__c != \'' + ARCHIVED_STATUS + '\'';
		queryStr += ' AND Id != :contractId';

		List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(queryStr);
		Map<Id, ASI_TH_CRM_Contract__c> contractMap = new Map<Id, ASI_TH_CRM_Contract__c>();

		for(ASI_TH_CRM_Contract__c contract : contractList) {
			if(String.isNotBlank(contract.ASI_CRM_Original_Version__c)) {
				contractMap.put(contract.ASI_CRM_Original_Version__c, contract);
			} else {
				contractMap.put(contract.Id, contract);
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

	private List<ASI_CRM_Contract_Outlets__c> getContractOutletList(Set<Id> contractIdSet) {
		String queryStr = 'SELECT ';
		queryStr += genQueryField(CONTRACT_OUTLET_FIELD_MAP);
		queryStr += ' FROM ASI_CRM_Contract_Outlets__c';
		queryStr += ' WHERE ASI_CRM_SG_Contract__c in :contractIdSet';

		return (List<ASI_CRM_Contract_Outlets__c>) Database.query(queryStr);
	}

	private List<ASI_CRM_Payment_Schedule__c> getPaymentScheduleList(Set<Id> contractIdSet) {
		String queryStr = 'SELECT ';
		queryStr += genQueryField(PAYMENT_SCHEDULE_FIELD_MAP);
		queryStr += ' FROM ASI_CRM_Payment_Schedule__c';
		queryStr += ' WHERE ASI_CRM_Contract__c in :contractIdSet';
		
		return (List<ASI_CRM_Payment_Schedule__c>) Database.query(queryStr);                                                        
	}

	private List<ASI_CRM_ContractTarget__c> getContractTargetList(Set<Id> contractIdSet) {
		String queryStr = 'SELECT ';
		queryStr += genQueryField(CONTRACT_TARGET_FIELD_MAP);
		queryStr += ' FROM ASI_CRM_ContractTarget__c';
		queryStr += ' WHERE ASI_CRM_Contract__c in :contractIdSet';
		
		return (List<ASI_CRM_ContractTarget__c>) Database.query(queryStr);
	}

	private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
	    String queryField = '';
	    for(String field : fieldMap.keySet()) {
	      queryField += field + ',';
	    }
	    return queryField.subString(0, queryField.length() - 1);
  	}

}