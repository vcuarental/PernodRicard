/*********************************************************************************
 * Name: ASI_CRM_SG_ContractTargetSim_Controller
 * Description: Controller class for ASI_CRM_SG_ContractTargetSim_Page
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/03/2017       Hugo Cheung             Created          
 * 20/11/2017       Wilken Lee              [WL 1.0] Add validation to prevent change Sales Case or delete target in simulation
 * 2018-03-28       Vincent Lam             [VL 1.0] put RTM WS price on search SKU
*/
public class ASI_CRM_SG_ContractTargetSim_Controller {
    
    //Inner class for storing the exception
	private class ExceptionWrapper {
		private Integer lineNumber            {get; set;}
		private String errorMessage           {get; set;}
		private List<String> fieldAPINameList {get; set;}

		private ExceptionWrapper(Integer lineNumber, String errorMessage) {
			this.lineNumber         = lineNumber;
			this.errorMessage       = errorMessage;
		}

		private ExceptionWrapper(Integer lineNumber, String errorMessage, List<String> fieldAPINameList) {
			this(lineNumber, errorMessage);
			this.fieldAPINameList = fieldAPINameList;
		}
	}
    
    //Wrapper Class
    private class SKUPriceWrapper {
       	private ASI_MFM_SKU_Code__c sku {get; set;}
        private Map<String, ASI_CRM_MY_SKUPriceCost__c> skuPriceRecordTypeMap {get; set;}
        
        private SKUPriceWrapper(ASI_MFM_SKU_Code__c sku) {	
        	this.sku = sku;
            this.skuPriceRecordTypeMap = new Map<String, ASI_CRM_MY_SKUPriceCost__c>();
        }
        
        private void addSKUPrice(String recordTypeName, ASI_CRM_MY_SKUPriceCost__c skuPrice) {
            if(!skuPriceRecordTypeMap.containsKey(recordTypeName)) {
            	skuPriceRecordTypeMap.put(recordTypeName, skuPrice);
            }
        }
        
        private Boolean checkIsValidRecord() {
			/* [VL 1.0] BEGIN */
			/*
        	return skuPriceRecordTypeMap.size() == 6;
			*/
        	return skuPriceRecordTypeMap.size() == 8;
			/* [VL 1.0] END */
        }
    }
    
	//Field Map
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP         = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_TARGET_FIELD_MAP  = Schema.SObjectType.ASI_CRM_ContractTarget__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_OUTLET_FIELD_MAP  = Schema.SObjectType.ASI_CRM_Contract_Outlets__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PAYMENT_SCHEDULE_FIELD_MAP = Schema.SObjectType.ASI_CRM_Payment_Schedule__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SKU_PRICE_FIELD_MAP        = Schema.SObjectType.ASI_CRM_MY_SKUPriceCost__c.fields.getMap();
    
    //Record Type
    private final static String CONTRACT_TARGET_SG_RECORD_TYPE            = 'ASI_CRM_SG_Contract_Target';
    private final static String CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target_Simulation';
    private final static String PAYMENTSCHEDULE_RECORD_TYPE               = 'ASI_CRM_SG_Payment_Schedule';
    private final static String PAYMENTSCHEDULE_SIMULATION_RECORD_TYPE    = 'ASI_CRM_SG_Payment_Schedule_Simulation';
    private final static String CONTRACTOUTLET_RECORD_TYPE                = 'ASI_CRM_SG_Contract_Outlet';
    private final static String CONTRACTOUTLET_SIMULATION_RECORD_TYPE     = 'ASI_CRM_SG_Contract_Outlet_Simulation';
    private final static String SG_SUB_BRAND_RECORD_TYPE                  = 'ASI_CRM_SG_Sub_brand';
    private final static String SG_SKU_RECORD_TYPE                        = 'ASI_CRM_SG_SKU';
    private final static Set<String> SG_SKU_PRICE_RECORD_TYPE_SET         = new Set<String> {
    	'ASI_CRM_SG_Selling_Price_Per_Bottle_PRS_Wholesaler',
        'ASI_CRM_SG_Selling_Price_Per_Bottle_Wholesaler_On_Trade',
        'ASI_CRM_SG_IGC',
        'ASI_CRM_SG_CRM_Duty_Per_Bottle',
        'ASI_CRM_SG_CRM_FOB_Per_Bottle',
        'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle'
		/* [VL 1.0] BEGIN */
		, 'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle'
		, 'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle'
		/* [VL 1.0] END */
    };
    
    //Clone Contract Record Type Mapping
    private final static Map<String, String> contractRecordTypeMapping = new Map<String, String> {
    	'ASI_CRM_SG_Contract_Read_Only' => 'ASI_CRM_SG_Contract', 
        'ASI_CRM_SG_Proposal_Read_Only' => 'ASI_CRM_SG_Proposal'
    };
    
    //Archived Contract Record Type Mapping
    private final static Map<String, String> contractArchivedRecordTypeMapping = new Map<String, String> {
    	'ASI_CRM_SG_Contract_Read_Only' => 'ASI_CRM_SG_Contract_Archived', 
        'ASI_CRM_SG_Proposal_Read_Only' => 'ASI_CRM_SG_Proposal_Archived'
    };
    
    //Contract Status
    public static final String DRAFT_STATUS    = 'Draft';
    public static final String APPROVED_STATUS = 'Contract Approved';
    
    //Page Parameters Key
    private final static String CONTRACT_ID                       = 'id';
    private final static String SKU_NAME                          = 'skuName';
    private final static String FILTER_OUT_SKU_ID_LIST_JSON       = 'filterOutSKUIdListJson';
    private final static String IS_QUICK_SAVE                     = 'isQuickSave';
    private final static String CONTRACT_TARGET_LIST_JSON         = 'contractTargetListJson';
    private final static String UPDATE_CONTRACT_TARGET_LIST_JSON  = 'updateContractTargetListJson';
    private final static String DELETE_CONTRACT_TARGET_LIST_JSON  = 'deleteContractTargetListJson';
    private final static String UPDATE_PAYMENT_SCHEDULE_LIST_JSON = 'updatePaymentScheduleListJson';
    private final static String DELETE_PAYMENT_SCHEDULE_LIST_JSON = 'deletePaymentScheduleListJson';
    private final static String UPDATE_CONTRACT_OUTLET_LIST_JSON  = 'updateContractOutletListJson';
    private final static String DELETE_CONTRACT_OUTLET_LIST_JSON  = 'deleteContractOutletListJson';
    
    //Data Storage
    public ASI_TH_CRM_Contract__c contract {get; set;}
    private List<ASI_CRM_ContractTarget__c> contractTargetList;
    private List<ASI_CRM_Payment_Schedule__c> cashPaymentScheduleList;
    private List<ASI_CRM_Payment_Schedule__c> contractPaymentScheduleList;
    private Map<String, ASI_MFM_Sub_Brand__c> subBrandNameMap;
    private List<SKUPriceWrapper> skuPriceWrapperList;
    private List<ASI_CRM_Contract_Outlets__c> contractOutletList;
    private List<ASI_CRM_AccountsAdditionalField__c> childOutletList;
    
    //Boolean to identify is simulate contract exists or not
    public Boolean isSimulate {get; set;}
    
    //Page Varaible
  	public Boolean hasError                     {get; set;}
  	public List<ExceptionWrapper> exceptionList {get; set;}
	public Boolean isParentAccount              {get; set;}
	public Decimal getInflationRate(){
		return contract.ASI_CRM_Inflation_Rate__c == null ? 0 : contract.ASI_CRM_Inflation_Rate__c;
	}           
	public Decimal getDistributionRate(){
		return contract.ASI_CRM_Distribution_Rate__c == null ? 0 : contract.ASI_CRM_Distribution_Rate__c;
	}
    
    public Decimal oldROI {get; set;}
    public Decimal newROI {get; set;}
    
    public String contractTargetRecordTypeId     {get {return Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target_Simulation');}}
    public String paymentSponsorshipRecordTypeId {get {return Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule_Simulation');}}
    public String contractOutletRecordTypeId     {get {return Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet_Simulation');}}
	
    //JSON String for VF Page
    public String contractTargetListJson          {get {return toJsonString(contractTargetList);}}
    public String cashPaymentScheduleListJson     {get {return toJsonString(cashPaymentScheduleList);}}
    public String contractPaymentScheduleListJson {get {return toJsonString(contractPaymentScheduleList);}}
    public String subBrandNameListJson            {get {return toJsonString(subBrandNameMap.keySet());}}
    public String skuPriceWrapperListJson         {get {return toJsonString(skuPriceWrapperList);}}
    public String exceptionListJson               {get {return toJsonString(exceptionList);}}
    public String contractContractOutletListJson  {get {return toJsonString(contractOutletList);}}
    public String childOutletListJson             {get {return toJsonString(childOutletList);}}
    
    public ASI_CRM_SG_ContractTargetSim_Controller(ApexPages.StandardController standardController) {
        String contractId = ApexPages.currentPage().getParameters().get('id');
        init(contractId);
    }
    
    /***************
    Data Init Function
    ***************/
    private void init(String contractId) {
        contract           = retrieveContract(contractId);
    	contractTargetList = retrieveContractTarget(contractId);
        subBrandNameMap    = retrieveSubBrand();
		childOutletList    = retrieveChildOutlet(contract.ASI_CRM_CN_Outlet_WS__c);
		contractOutletList = retrieveOutlet(contractId);
		isParentAccount    = childOutletList.size() > 0 ? true : false;
        
		isSimulate = false;
		
        cashPaymentScheduleList     = new List<ASI_CRM_Payment_Schedule__c>();
        contractPaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = retrievePaymentSchedule(contractId);
        for(ASI_CRM_Payment_Schedule__c paymentSchedule : paymentScheduleList) {
            if(paymentSchedule.ASI_CRM_Type__c == 'Cash Sponsorship') {
                cashPaymentScheduleList.add(paymentSchedule);
            } else if(paymentSchedule.ASI_CRM_Type__c == 'Contract Sponsorship') {
                contractPaymentScheduleList.add(paymentSchedule);
            }
        }
        
        if(contractTargetList.size() > 0 &&
           contractTargetList.get(0).RecordType.DeveloperName == CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE) {
        	isSimulate = true;
        }
    }
    /***************
    Page Function
    ***************/
    public void searchSKU() {
        Map<String, String> params      = ApexPages.currentPage().getParameters();
        String skuName                  = params.get(SKU_NAME);
        Set<String> filterOutSKUIdList  = (Set<String>) fromJsonString(params.get(FILTER_OUT_SKU_ID_LIST_JSON), Set<String>.class);
        
        Map<Id, ASI_MFM_SKU_Code__c> skuMap           = new Map<Id, ASI_MFM_SKU_Code__c>(retrieveSKU(skuName));
        List<ASI_CRM_MY_SKUPriceCost__c> skuPriceList = retrieveSKUPrice(skuMap.keySet(), contract.ASI_TH_CRM_Start_Date__c);
        
        Map<Id, SKUPriceWrapper> skuPriceWrapperMap = new Map<Id, SKUPriceWrapper>();
        
        Set<Id> existingSKUSet = new Set<Id>();
        for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
            if(String.isBlank(contractTarget.ASI_CRM_SKU__c)) {
            	existingSKUSet.add(contractTarget.ASI_CRM_Subbrand__r.ASI_CRM_Representative_SKU__c);
            } else {
        		existingSKUSet.add(contractTarget.ASI_CRM_SKU__c);
            }
        }
        
        for(Id skuId : skuMap.keySet()) {
            if(!existingSKUSet.contains(skuId) && !filterOutSKUIdList.contains(String.valueOf(skuId))) {
            	skuPriceWrapperMap.put(skuId, new SKUPriceWrapper(skuMap.get(skuId)));
            } 
        }
        
        for(ASI_CRM_MY_SKUPriceCost__c skuPrice : skuPriceList) {
            if(skuPriceWrapperMap.containsKey(skuPrice.ASI_CRM_SKU__c)) {
                SKUPriceWrapper tempSKUPriceWrapper = skuPriceWrapperMap.get(skuPrice.ASI_CRM_SKU__c);
                tempSKUPriceWrapper.addSKUPrice(skuPrice.RecordType.DeveloperName, skuPrice);
                skuPriceWrapperMap.put(skuPrice.ASI_CRM_SKU__c, tempSKUPriceWrapper);
            }
        }

        skuPriceWrapperList = new List<SKUPriceWrapper>();
        for(SKUPriceWrapper skuPriceWrapper : skuPriceWrapperMap.values()) {
            if(skuPriceWrapper.checkIsValidRecord()) {
        		skuPriceWrapperList.add(skuPriceWrapper);
            }
        }
    }
    
    public void calculateROI() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String contractTargetListJson = params.get(CONTRACT_TARGET_LIST_JSON);
        
        List<ASI_CRM_ContractTarget__c> contractList;
        
        try {
            contractTargetList = (List<ASI_CRM_ContractTarget__c>) fromJsonString(contractTargetListJson, List<ASI_CRM_ContractTarget__c>.class);
            if(contractTargetList != null && contractTargetList.size() > 0) {
                oldROI = contract.ASI_CRM_ROI__c.setScale(2);
            	newROI = calculateROI(contractTargetList).setScale(2);
            }
        } catch(Exception e) {
            System.debug('Page (ASI_CRM_SG_ContractTargetSim_Controller) Error ' + e.getMessage());
        }
    }
    
    public PageReference saveSimulation() {
   		hasError = false;
        
        Map<String, String> params           = ApexPages.currentPage().getParameters();
        Boolean isQuickSave                  = String.isBlank(params.get('IS_QUICK_SAVE')) ? false : Boolean.valueOf(params.get('IS_QUICK_SAVE'));
	    String upsertContractTargetDataJson  = params.get(UPDATE_CONTRACT_TARGET_LIST_JSON);
	    String removeContractTargetDataJson  = params.get(DELETE_CONTRACT_TARGET_LIST_JSON);
        String upsertPaymentScheduleDataJson = params.get(UPDATE_PAYMENT_SCHEDULE_LIST_JSON);
        String removePaymentScheduleDataJson = params.get(DELETE_PAYMENT_SCHEDULE_LIST_JSON);
        String upsertContractOutletDataJson  = params.get(UPDATE_CONTRACT_OUTLET_LIST_JSON);
        String removeContractOutletDataJson  = params.get(DELETE_CONTRACT_OUTLET_LIST_JSON);
        
        List<ASI_CRM_ContractTarget__c> upsertContractTargetList;
        List<String> removeContractTargetIdList;
        
        List<ASI_CRM_Payment_Schedule__c> upsertPaymentScheduleList;
       	List<String> removePaymentScheduleIdList;
        
        List<ASI_CRM_Contract_Outlets__c> upsertContractOutletList;
       	List<String> removeContractOutletIdList;
        
	    System.Savepoint databaseSavepoint = Database.setSavepoint();
        //try {
        
            upsertContractTargetList    = (List<ASI_CRM_ContractTarget__c>) fromJsonString(upsertContractTargetDataJson, List<ASI_CRM_ContractTarget__c>.class);
            removeContractTargetIdList  = (List<String>) fromJsonString(removeContractTargetDataJson, List<String>.class);
            
            upsertPaymentScheduleList   = (List<ASI_CRM_Payment_Schedule__c>) fromJsonString(upsertPaymentScheduleDataJson, List<ASI_CRM_Payment_Schedule__c>.class);
            removePaymentScheduleIdList = (List<String>) fromJsonString(removePaymentScheduleDataJson, List<String>.class);
            
            upsertContractOutletList    = (List<ASI_CRM_Contract_Outlets__c>) fromJsonString(upsertContractOutletDataJson, List<ASI_CRM_Contract_Outlets__c>.class);
            removeContractOutletIdList  = (List<String>) fromJsonString(removeContractOutletDataJson, List<String>.class);
            
            if(removeContractTargetIdList != null && removeContractTargetIdList.size() > 0 && isSimulate) {
                List<ASI_CRM_ContractTarget__c> removeDataList = new List<ASI_CRM_ContractTarget__c>();
                for(String removeDataId : removeContractTargetIdList) {
                	removeDataList.add(new ASI_CRM_ContractTarget__c(Id = removeDataId));
                }
                Database.delete(removeDataList);
            }
            
            if(removePaymentScheduleIdList != null && removePaymentScheduleIdList.size() > 0 && isSimulate) {
            	List<ASI_CRM_Payment_Schedule__c> removeDataList = new List<ASI_CRM_Payment_Schedule__c>();
                for(String removeDataId : removePaymentScheduleIdList) {
                	removeDataList.add(new ASI_CRM_Payment_Schedule__c(Id = removeDataId));
                }
                Database.delete(removeDataList);
            }
            
            if(removeContractOutletIdList != null && removeContractOutletIdList.size() > 0 && isSimulate) {
            	List<ASI_CRM_Contract_Outlets__c> removeDataList = new List<ASI_CRM_Contract_Outlets__c>();
                for(String removeDataId : removeContractOutletIdList) {
                	removeDataList.add(new ASI_CRM_Contract_Outlets__c(Id = removeDataId));
                }
                Database.delete(removeDataList);
            }
            
            if(upsertContractTargetList != null && upsertContractTargetList.size() > 0) {
                
                for(ASI_CRM_ContractTarget__c contractTarget : upsertContractTargetList) {
                    contractTarget.ASI_CRM_SKU__r = null;
                    if(subBrandNameMap.containsKey(contractTarget.ASI_CRM_Subbrand__c)) {
                		contractTarget.ASI_CRM_Subbrand__c = subBrandNameMap.get(contractTarget.ASI_CRM_Subbrand__c).Id;
                    }
                }
                
                for(ASI_CRM_Contract_Outlets__c contractOutlet : upsertContractOutletList) {
                    contractOutlet.ASI_CRM_SG_Customer__r = null;
                }
                
				system.debug(upsertPaymentScheduleList);
            	if(isSimulate) {
                	Database.upsert(upsertContractTargetList); 
                    Database.upsert(upsertPaymentScheduleList);
                    Database.upsert(upsertContractOutletList);
                } else {
                    List<ASI_CRM_ContractTarget__c> insertContractTargetList = new List<ASI_CRM_ContractTarget__c>();
                	for(ASI_CRM_ContractTarget__c upsertData : upsertContractTargetList) {
                        ASI_CRM_ContractTarget__c tempContractTarget;
                        if (upsertData.id==null){
                            tempContractTarget = upsertData;
                        } else {
                            tempContractTarget = upsertData.clone(false, true, false, false);
                        }
                        tempContractTarget.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__c' + CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE); 
                        insertContractTargetList.add(tempContractTarget);
                    }
                    Database.insert(insertContractTargetList);
                    
                    List<ASI_CRM_Payment_Schedule__c> insertPaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
                    for(ASI_CRM_Payment_Schedule__c upsertData : upsertPaymentScheduleList) {
                        ASI_CRM_Payment_Schedule__c tempPaymentSchedule;
                        if (upsertData.id==null){
                            tempPaymentSchedule = upsertData;
                        } else {
                            tempPaymentSchedule = upsertData.clone(false, true, false, false);
                        }
                        tempPaymentSchedule.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__c' + PAYMENTSCHEDULE_SIMULATION_RECORD_TYPE); 
                        insertPaymentScheduleList.add(tempPaymentSchedule);
                    }
                    Database.insert(insertPaymentScheduleList);
                    
                    List<ASI_CRM_Contract_Outlets__c> insertContractOutletList = new List<ASI_CRM_Contract_Outlets__c>();
                    for(ASI_CRM_Contract_Outlets__c upsertData : upsertContractOutletList) {
                        ASI_CRM_Contract_Outlets__c tempContractOutlet;
                        if (upsertData.id==null){
                            tempContractOutlet = upsertData;
                        } else {
                            tempContractOutlet = upsertData.clone(false, true, false, false);
                        }
                        tempContractOutlet.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__c' + CONTRACTOUTLET_SIMULATION_RECORD_TYPE); 
                        insertContractOutletList.add(tempContractOutlet);
                    }
                    Database.insert(insertContractOutletList);
                } 
            }
            /*
        } catch(Exception e) {
            exceptionList = new List<ExceptionWrapper>();
	      	if(e.getTypeName() == 'System.DmlException') {
	      		DmlException dmlException = (DmlException) e;
	      		for(Integer i = 0 ; i < dmlException.getNumDml() ; i++) {
	      			ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
	      			exceptionList.add(exceptionWrapper);
	      		}
	      	} else {
	      		ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
	      		exceptionList.add(exceptionWrapper);
	      	}
	      	hasError = true;
            
        	Database.rollback(databaseSavepoint);
            System.debug('Page (ASI_CRM_SG_ContractTargetSim_Controller) Error ' + e.getMessage());
            return null;
        }
        */
        
        if(isQuickSave) {
            //Init the page if is quick save
            init(contract.Id);
        	return null;
        }
        
        PageReference pageRef = new PageReference('/' + contract.Id);
	    pageRef.setRedirect(true);
	    return pageRef;
    }
    
    public PageReference deleteSimulation() {
        if(isSimulate) {
        	delete contractTargetList;
            if (cashPaymentScheduleList.size()>0) delete cashPaymentScheduleList;
            if (contractPaymentScheduleList.size()>0) delete contractPaymentScheduleList;
			if (contractOutletList.size()>0) delete contractOutletList;
        }
        
    	PageReference pageRef = new PageReference('/' + contract.Id);
	    pageRef.setRedirect(true);
	    return pageRef;
    }
    
    public PageReference reviseContract() {
        Id originalContractId;
        String originalContractName;
        Decimal originalContractROI;
        
        //Clone a new contract for backup  
        ASI_TH_CRM_Contract__c tempContract  = contract.clone(false, true, false, false);
        tempContract.ASI_CRM_Contract_Period_Req_To_Extend__c = false;
        
		/*
        if(contract.ASI_CRM_Original_Version__c == null) {
        	tempContract.Name = contract.Name;
        } else {
        	originalContractId   = contract.ASI_CRM_Original_Version__c;
            originalContractName = contract.ASI_CRM_Original_Version__r.Name;
            
            Integer version = retrievePreviousContractSize(contract.Id, originalContractName, contract.RecordType.DeveloperName);
            tempContract.Name = originalContractName + ' Rev. ' + version;
            tempContract.ASI_CRM_Version__c = String.valueOf(version);
        }
        tempContract.ASI_TH_CRM_Contract_Status__c = APPROVED_STATUS;
		*/
        
        Database.insert(tempContract);
        
        //Update current contract
        contract.ASI_TH_CRM_Contract_Status__c = DRAFT_STATUS;
        
       	originalContractId   = contract.ASI_CRM_Original_Version__c == null ? tempContract.Id : contract.ASI_CRM_Original_Version__c;
        originalContractName = contract.ASI_CRM_Original_Version__c == null ? tempContract.Name : contract.ASI_CRM_Original_Version__r.Name;
        originalContractROI  = contract.ASI_CRM_Original_Version__c == null ? tempContract.ASI_CRM_ROI__c : contract.ASI_CRM_Original_Version__r.ASI_CRM_ROI__c;
        
        Integer version = retrievePreviousContractSize(contract.Id, originalContractName, contractArchivedRecordTypeMapping.get(contract.RecordType.DeveloperName));
        contract.ASI_CRM_Original_Version__c = contract.ASI_CRM_Original_Version__c == null ? tempContract.Id : contract.ASI_CRM_Original_Version__c;
        contract.Name = originalContractName + ' Rev. ' + version;
        contract.ASI_CRM_Version__c = String.valueOf(version);
        contract.ASI_CRM_ROI__c = originalContractROI;
        contract.RecordTypeId = contractRecordTypeMapping.containsKey(contract.RecordType.DeveloperName) 
                              ? Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__c' + contractRecordTypeMapping.get(contract.RecordType.DeveloperName))
                              : contract.RecordTypeId; 
        contract.ASI_CRM_Revising__c = true;
        contract.ASI_CRM_Alerted_30_Days_Before_End__c = false;
       	contract.ASI_CRM_Alerted_60_Days_Before_End__c = false;
        
        Database.update(contract);
        
        contract.ASI_CRM_Revising__c = false;
        Database.update(contract);
        
        //Clone Child
        List<ASI_CRM_Contract_Outlets__c> originalContractOutletList = retrieveOutletForRevise(contract.Id);
        List<ASI_CRM_Contract_Outlets__c> clonedContractOutletList = new List<ASI_CRM_Contract_Outlets__c>();
        for(ASI_CRM_Contract_Outlets__c contractOutlet : originalContractOutletList) {
            ASI_CRM_Contract_Outlets__c tempContractOutlet = contractOutlet.clone(false, true, false, false);
            tempContractOutlet.ASI_CRM_SG_Contract__c = tempContract.Id;
            clonedContractOutletList.add(tempContractOutlet);
        }
        
        List<ASI_CRM_Payment_Schedule__c> originalPaymentScheduleList = retrievePaymentScheduleForRevise(contract.Id);
        List<ASI_CRM_Payment_Schedule__c> clonedPaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
        for(ASI_CRM_Payment_Schedule__c paymentSchedule : originalPaymentScheduleList) {
            ASI_CRM_Payment_Schedule__c tempPaymentSchedule = paymentSchedule.clone(false, true, false, false);
            tempPaymentSchedule.ASI_CRM_Contract__c = tempContract.Id;
            clonedPaymentScheduleList.add(tempPaymentSchedule);
        }
        
        List<ASI_CRM_ContractTarget__c> originalContractTargetList = retrieveContractTargetForRevise(contract.Id);
        List<ASI_CRM_ContractTarget__c> clonedContractTargetList = new List<ASI_CRM_ContractTarget__c>();
        for(ASI_CRM_ContractTarget__c contractTarget : originalContractTargetList) {
        	ASI_CRM_ContractTarget__c tempContractTarget = contractTarget.clone(false, true, false, false);
            tempContractTarget.ASI_CRM_Contract__c = tempContract.Id;
            clonedContractTargetList.add(tempContractTarget);
        }
        
       	Database.insert(clonedContractOutletList);
       	Database.insert(clonedPaymentScheduleList);
       	Database.insert(clonedContractTargetList);
        
        if(isSimulate) {
            Database.delete(originalContractTargetList);
          	for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
                contractTarget.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__c' + CONTRACT_TARGET_SG_RECORD_TYPE); 
            }
            Database.update(contractTargetList);
            
            if (originalPaymentScheduleList.size()>0) Database.delete(originalPaymentScheduleList);
            List<ASI_CRM_Payment_Schedule__c> estimatePaymentScheduleList = new List<ASI_CRM_Payment_Schedule__c>();
          	for(ASI_CRM_Payment_Schedule__c paymentSchedule : cashPaymentScheduleList) {
                paymentSchedule.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__c' + PAYMENTSCHEDULE_RECORD_TYPE); 
                estimatePaymentScheduleList.add(paymentSchedule);
            }
          	for(ASI_CRM_Payment_Schedule__c paymentSchedule : contractPaymentScheduleList) {
                paymentSchedule.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__c' + PAYMENTSCHEDULE_RECORD_TYPE); 
                estimatePaymentScheduleList.add(paymentSchedule);
            }
            if (estimatePaymentScheduleList.size()>0) Database.update(estimatePaymentScheduleList);
            
            if (originalContractOutletList.size()>0) Database.delete(originalContractOutletList);
            List<ASI_CRM_Contract_Outlets__c> estimateContractOutletList = new List<ASI_CRM_Contract_Outlets__c>();
          	for(ASI_CRM_Contract_Outlets__c contractOutlet : estimateContractOutletList) {
                contractOutlet.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__c' + CONTRACTOUTLET_RECORD_TYPE); 
                estimateContractOutletList.add(contractOutlet);
            }
            if (estimateContractOutletList.size()>0) Database.update(estimateContractOutletList);
        }
        
        List<ASI_TH_CRM_PaymentRequest__c> paymentHeaderList = retrievePaymentHeader(contract.Id);
        List<ASI_FOC_Free_Goods_Request__c> focHeaderList    = retrieveFOCHeader(contract.Id);
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = retrieveActualOfftake(contract.Id);
        
        for(ASI_TH_CRM_PaymentRequest__c paymentHeader : paymentHeaderList) {
        	if(paymentHeader.ASI_CRM_Contract_No_Original__c == null) {
            	paymentHeader.ASI_CRM_Contract_No_Original__c = tempContract.Name;
            }
            paymentHeader.ASI_TH_CRM_Contract__c = tempContract.Id;
        }
        
        for(ASI_FOC_Free_Goods_Request__c focHeader : focHeaderList) {
            if(focHeader.ASI_CRM_Contract_No_Original__c == null) {
                focHeader.ASI_CRM_Contract_No_Original__c = tempContract.Name;
            }
            focHeader.ASI_CRM_Contract__c = tempContract.Id;
        }
        
        for(ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {
            actualOfftake.ASI_CRM_Contract__c = tempContract.Id;
        }
        
        if(paymentHeaderList.size() > 0) update paymentHeaderList;
        if(focHeaderList.size() > 0) update focHeaderList;
        if(actualOfftakeList.size() > 0) update actualOfftakeList;
        
        PageReference pageRef = new PageReference('/' + contract.Id);
	    pageRef.setRedirect(true);
	    return pageRef;
    }
    
    public PageReference cancel() {
    	PageReference pageRef = new PageReference('/' + contract.Id);
	    pageRef.setRedirect(true);
	    return pageRef;
    }
    
    /***************
    Business Logic Function
    ***************/
    public Decimal calculateROI(List<ASI_CRM_ContractTarget__c> contractTargetList) {
        Decimal totalReturnOnInvestment = 0;
        Decimal totalNetSales           = 0;
        for(ASI_CRM_ContractTarget__c contractTarget : contractTargetList) {
            Decimal tradeAPTotalPRS             = 0;
            Decimal totalManagementIncentives   = 0;
            Decimal targetSalesCaseFOC          = 0;
            Decimal distributionCost            = 0;
            Decimal totalFreeGoodsCase          = 0;
            Decimal costOfSales                 = 0;
            Decimal compensationForWSPriceDif   = 0;
            Decimal wholesalerMarginTotal       = 0;
            Decimal freeGoods                   = 0;
            Decimal totalAllowancesAndDiscounts = 0;
            Decimal grossSales                  = 0;
            Decimal netSales                    = 0;
            Decimal grossMargin                 = 0;
            Decimal returnOnInvestment          = 0;
            
            tradeAPTotalPRS = (contractTarget.ASI_CRM_SG_Events__c == null ? 0 : contractTarget.ASI_CRM_SG_Events__c)
                            + (contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c)
                            + (contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c == null ? 0 : contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c)
                            + (contractTarget.ASI_CRM_SG_Product_Branding_Display__c == null ? 0 : contractTarget.ASI_CRM_SG_Product_Branding_Display__c)
                            + (contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c == null ? 0 : contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c)
                            + (contractTarget.ASI_CRM_SG_Ad_hoc_Others_Total__c == null ? 0 : contractTarget.ASI_CRM_SG_Ad_hoc_Others_Total__c)
                            + ((contractTarget.ASI_CRM_SG_Events_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_SG_Events_Free_Bottles__c)
                               + (contractTarget.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c == null ? 0 : contractTarget.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c)
                               + (contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c)
                               + (contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c)) 
                            * (contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c == null ? 0 : contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c)
                            + (contractTarget.ASI_CRM_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_Advertising_Spot__c);
            
            Decimal contractPeriod = (contract.ASI_TH_CRM_Start_Date__c.daysBetween(contract.ASI_TH_CRM_End_Date__c)) / 30;
            totalManagementIncentives = (contractTarget.ASI_CRM_SG_Management_Incentives__c == null ? 0 : contractTarget.ASI_CRM_SG_Management_Incentives__c)
                                      * contractPeriod.round();
            
            if(contractTarget.ASI_CRM_SG_FOC_Calculation__c == 'By Sub-Brand') {
                targetSalesCaseFOC = (contractTarget.ASI_CRM_SG_Target_Sales_Sub_B_Wine_Cat__c == null ? 0 : contractTarget.ASI_CRM_SG_Target_Sales_Sub_B_Wine_Cat__c);
            } else {
            	targetSalesCaseFOC = (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c);
            }
            
            totalFreeGoodsCase = (contractTarget.ASI_CRM_SG_Sales_Incentive__c == null ? 0 : contractTarget.ASI_CRM_SG_Sales_Incentive__c)
                               * targetSalesCaseFOC
                               / (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c)
                               + totalManagementIncentives
                               + (contractTarget.ASI_CRM_SG_Others__c == null ? 0 : contractTarget.ASI_CRM_SG_Others__c)
                               + (contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c == null ? 0 : contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c);
           
            grossSales = (totalFreeGoodsCase 
                          + (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c))
                       * (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c)
                       * (contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c);
            
            distributionCost = -(grossSales * (contract.ASI_CRM_Distribution_Rate__c == null ? 0 : contract.ASI_CRM_Distribution_Rate__c) / 100);
            
            costOfSales = - (((contractTarget.ASI_CRM_FOB_Per_Bottle__c == null ? 0 : contractTarget.ASI_CRM_FOB_Per_Bottle__c)
                              + (contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c == null ? 0 : contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c))
                              * (1 + (contract.ASI_CRM_Inflation_Rate__c == null ? 0 : (contract.ASI_CRM_Inflation_Rate__c / 100))) 
                             + (contractTarget.ASI_CRM_Duty_Per_Bottle__c == null ? 0 : contractTarget.ASI_CRM_Duty_Per_Bottle__c))
                        * ((contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c)
                           + totalFreeGoodsCase)
                        * (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c)
                        + distributionCost;
            
            if(contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c == null || contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c == 0 || 
               contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c > contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c) {
                compensationForWSPriceDif = 0;
            } else {
            	compensationForWSPriceDif = (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c)
                                          * (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c)
                                          * ((contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c)
                                          - (contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c == null ? 0 : contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
            }
            
            wholesalerMarginTotal = (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c)
                                  * (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c)
                                  * (contractTarget.ASI_CRM_SG_Wholesaler_Margin__c == null ? 0 : contractTarget.ASI_CRM_SG_Wholesaler_Margin__c);
            
            freeGoods = - (contractTarget.ASI_CRM_SG_Total_Free_Goods_Cases__c == null ? 0 : contractTarget.ASI_CRM_SG_Total_Free_Goods_Cases__c)
                      * (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c)
                      * (contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c);
            
            totalAllowancesAndDiscounts = freeGoods
                                        - wholesalerMarginTotal
                                        - compensationForWSPriceDif
                                        - (contractTarget.ASI_CRM_SG_Good_in_Kinds__c == null ? 0 : contractTarget.ASI_CRM_SG_Good_in_Kinds__c)
                                        - (contractTarget.ASI_CRM_SG_Cash__c == null ? 0 : contractTarget.ASI_CRM_SG_Cash__c)
                                        - ((contractTarget.ASI_CRM_Bottle_Incentive__c == null ? 0 : contractTarget.ASI_CRM_Bottle_Incentive__c)
                                           * (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c)
                                           * (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c));
            
        	netSales = grossSales + totalAllowancesAndDiscounts;
            
            grossMargin = netSales + costOfSales;
            
            returnOnInvestment = grossMargin - tradeAPTotalPRS;
            
            totalReturnOnInvestment += returnOnInvestment;
            totalNetSales += netSales;
        }
        
        return (totalNetSales == 0 || totalReturnOnInvestment == 0) ? 0 : (totalReturnOnInvestment / totalNetSales * 100);
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private ASI_TH_CRM_Contract__c retrieveContract(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_Original_Version__r.Name, ASI_CRM_Original_Version__r.ASI_CRM_ROI__c ' + 
                       'FROM ASI_TH_CRM_Contract__c ' +
                       'WHERE Id = :contractId ';
        List<ASI_TH_CRM_Contract__c> contractList = (List<ASI_TH_CRM_Contract__c>) Database.query(query);
        return contractList.size() > 0 ? contractList.get(0) : null;
    }
    
    private Integer retrievePreviousContractSize(Id contractId, String contractName, String contractRecordType) {
        String query = 'SELECT count() ' + 
                       'FROM ASI_TH_CRM_Contract__c ' +
                       'WHERE Name like \'' + contractName + '%\' ' + 
                       'AND ASI_TH_CRM_Contract_Status__c = \'Archived\' ' + 
                       'AND RecordType.DeveloperName = :contractRecordType ' + 
                       'AND id <> :contractId';
        return Database.countQuery(query) + 1;
    }
    
    private List<ASI_CRM_ContractTarget__c> retrieveContractTarget(Id contractId) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_TARGET_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_SKU__r.Name, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_Representative_SKU__c ' + 
                       'FROM ASI_CRM_ContractTarget__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ' + 
                       'AND RecordType.DeveloperName = :CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE ' + 
                       'order by ASI_CRM_Sequence_No__c ';
        
        //Return simulate contract target list
        List<ASI_CRM_ContractTarget__c> contractTargetList = (List<ASI_CRM_ContractTarget__c>) Database.query(query);
        if(contractTargetList.size() > 0) {
        	return contractTargetList;
        }
        
        //Retrieve the current contract target if simulate contract target not find
        query = 'SELECT ' + genQueryField(CONTRACT_TARGET_FIELD_MAP) + 
                ', RecordType.DeveloperName, ASI_CRM_SKU__r.Name, ASI_CRM_Subbrand__r.Name, ASI_CRM_Subbrand__r.ASI_CRM_Representative_SKU__c ' + 				
                'FROM ASI_CRM_ContractTarget__c ' +
                'WHERE ASI_CRM_Contract__c = :contractId ' + 
                'AND RecordType.DeveloperName = :CONTRACT_TARGET_SG_RECORD_TYPE ' + 
                'order by ASI_CRM_Sequence_No__c ';
				
		/*[WL 1.0] BEGIN*/
        //return (List<ASI_CRM_ContractTarget__c>) Database.query(query);
		system.debug('query: ' + query);
		List<ASI_CRM_ContractTarget__c> contractTargetListApproved = (List<ASI_CRM_ContractTarget__c>) Database.query(query);

		for (ASI_CRM_ContractTarget__c target:contractTargetListApproved)
			target.ASI_CRM_Block_Delete__c = true;
			
		return contractTargetListApproved;        
		/*[WL 1.0] END*/
    }
    
    private List<ASI_CRM_MY_SKUPriceCost__c> retrieveSKUPrice(Set<Id> skuIdSet, Date contractStartDate) {
    	String query = 'SELECT ASI_CRM_SKU__c, ASI_CRM_SG_IGC_Cost_Per_9Lc__c, ASI_CRM_Price__c, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c' + 
                       ', RecordType.DeveloperName ' +
                       'FROM ASI_CRM_MY_SKUPriceCost__c ' +
                       'WHERE RecordType.DeveloperName in :SG_SKU_PRICE_RECORD_TYPE_SET ' + 
                       'AND ASI_CRM_EffectiveDate__c != NULL ' + 
                       'AND ASI_CRM_SKU__c in :skuIdSet ';
       	if(contractStartDate != null) {
            query += 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate ';
        }
        query += 'Order By ASI_CRM_EffectiveDate__c DESC';
       	return (List<ASI_CRM_MY_SKUPriceCost__c>) Database.query(query);
    }
    
    private List<ASI_MFM_SKU_Code__c> retrieveSKU(String skuName) {
    	String query = 'SELECT Id, Name, ASI_MFM_Sub_brand__c, ASI_HK_CRM_Packaging_Size__c, ASI_HK_CRM_Std_Bottle_Size__c ' + 
                       ', ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c, ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c, ASI_CRM_SG_IGC_Cost_Per_case__c, ASI_CRM_SG_IGC_Cost_Per_9Lc__c ' + 
                       ', ASI_MFM_Sub_brand__r.Name ' + 
                       'FROM ASI_MFM_SKU_Code__c ' + 
                       'WHERE RecordType.DeveloperName = :SG_SKU_RECORD_TYPE ' + 
                       'AND ASI_HK_CRM_IsPOSProduct__c = false ';
        
        if(String.isNotBlank(skuName)) {
            query += 'AND Name like \'%' + skuName.trim() + '%\' ';
        }
        
        query += 'Order By Name LIMIT 100';
        
       	return (List<ASI_MFM_SKU_Code__c>) Database.query(query);
    }
    
    private Map<String, ASI_MFM_Sub_Brand__c> retrieveSubBrand() {
    	String query = 'SELECT Id, Name, ASI_CRM_Representative_SKU__c ' + 
                       'FROM ASI_MFM_Sub_Brand__c ' + 
                       'WHERE RecordType.DeveloperName = :SG_SUB_BRAND_RECORD_TYPE ';
    	
        Map<String, ASI_MFM_Sub_Brand__c> subBrandNameMap = new Map<String, ASI_MFM_Sub_Brand__c>();    
        List<ASI_MFM_Sub_Brand__c> subBrandList = (List<ASI_MFM_Sub_Brand__c>) Database.query(query);
        for(ASI_MFM_Sub_Brand__c subBrand : subBrandList) {
        	subBrandNameMap.put(subBrand.Name, subBrand);
        }
        return subBrandNameMap;     
    }
    
    private List<ASI_CRM_ContractTarget__c> retrieveContractTargetForRevise(Id contractId) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_TARGET_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_SKU__r.Name, ASI_CRM_Subbrand__r.Name ' + 
                       'FROM ASI_CRM_ContractTarget__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ' + 
                       'AND RecordType.DeveloperName = :CONTRACT_TARGET_SG_RECORD_TYPE ';
        return (List<ASI_CRM_ContractTarget__c>) Database.query(query);
    }
    
    private List<ASI_TH_CRM_Actual_Offtake__c> retrieveActualOfftake(Id contractId) {
    	String query = 'SELECT Id, ASI_CRM_Contract__c ' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_TH_CRM_Actual_Offtake__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ';
        return (List<ASI_TH_CRM_Actual_Offtake__c>) Database.query(query);
    }
    
    private List<ASI_TH_CRM_PaymentRequest__c> retrievePaymentHeader(Id contractId) {
    	String query = 'SELECT Id, ASI_CRM_Contract_No_Original__c' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_TH_CRM_PaymentRequest__c ' +
                       'WHERE ASI_TH_CRM_Contract__c = :contractId ';
        return (List<ASI_TH_CRM_PaymentRequest__c>) Database.query(query);
    }
    
    private List<ASI_FOC_Free_Goods_Request__c> retrieveFOCHeader(Id contractId) {
    	String query = 'SELECT Id, ASI_CRM_Contract_No_Original__c' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_FOC_Free_Goods_Request__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ';
        return (List<ASI_FOC_Free_Goods_Request__c>) Database.query(query);
    }
    
    private List<ASI_TH_CRM_Actual_Offtake__c> retrieveOfftake(Id contractId) {
    	String query = 'SELECT Id' + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_TH_CRM_Actual_Offtake__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ';
        return (List<ASI_TH_CRM_Actual_Offtake__c>) Database.query(query);
    }
    
    private List<ASI_CRM_Contract_Outlets__c> retrieveOutlet(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_OUTLET_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_SG_Customer__r.Name ' + 
                       'FROM ASI_CRM_Contract_Outlets__c ' +
                       'WHERE ASI_CRM_SG_Contract__c = :contractId ' +
            			'AND RecordType.DeveloperName = :CONTRACTOUTLET_SIMULATION_RECORD_TYPE ';
        //Return simulate contract outlet list
        List<ASI_CRM_Contract_Outlets__c> contractOutletList = (List<ASI_CRM_Contract_Outlets__c>) Database.query(query);
        if(contractOutletList.size() > 0) {
          return contractOutletList;
        }
        
        //Retrieve the current payment schedule if simulate payment schedule not find
        query = 'SELECT ' + genQueryField(CONTRACT_OUTLET_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_SG_Customer__r.Name ' + 
                       'FROM ASI_CRM_Contract_Outlets__c ' +
                       'WHERE ASI_CRM_SG_Contract__c = :contractId ' +
            			'AND RecordType.DeveloperName = :CONTRACTOUTLET_RECORD_TYPE ';
        return (List<ASI_CRM_Contract_Outlets__c>) Database.query(query);
        
    }
    
    private List<ASI_CRM_Contract_Outlets__c> retrieveOutletForRevise(Id contractId) {
        //Retrieve the current payment schedule if simulate payment schedule not find
        String query = 'SELECT ' + genQueryField(CONTRACT_OUTLET_FIELD_MAP) + 
                       ', RecordType.DeveloperName, ASI_CRM_SG_Customer__r.Name ' + 
                       'FROM ASI_CRM_Contract_Outlets__c ' +
                       'WHERE ASI_CRM_SG_Contract__c = :contractId ' +
            			'AND RecordType.DeveloperName = :CONTRACTOUTLET_RECORD_TYPE ';
        return (List<ASI_CRM_Contract_Outlets__c>) Database.query(query);
        
    }
    
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveChildOutlet(Id parentId) {
        String query = 'SELECT Id, Name ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' +
                       'WHERE ASI_CRM_CN_Parent_Outlet__c  = :parentId ';
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
        
    }
    
    private List<ASI_CRM_Payment_Schedule__c> retrievePaymentSchedule(Id contractId) {
        String query = 'SELECT ' + genQueryField(PAYMENT_SCHEDULE_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_Payment_Schedule__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ' +
            			'AND RecordType.DeveloperName = :PAYMENTSCHEDULE_SIMULATION_RECORD_TYPE ';
        
        //Return simulate payment schedule list
        List<ASI_CRM_Payment_Schedule__c> paymentScheduleList = (List<ASI_CRM_Payment_Schedule__c>) Database.query(query);
        if(paymentScheduleList.size() > 0) {
          return paymentScheduleList;
        }
        
        //Retrieve the current payment schedule if simulate payment schedule not find
        query = 'SELECT ' + genQueryField(PAYMENT_SCHEDULE_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_Payment_Schedule__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ' +
            			'AND RecordType.DeveloperName = :PAYMENTSCHEDULE_RECORD_TYPE ';
        return (List<ASI_CRM_Payment_Schedule__c>) Database.query(query);
    }
    
    private List<ASI_CRM_Payment_Schedule__c> retrievePaymentScheduleForRevise(Id contractId) {
        String query = 'SELECT ' + genQueryField(PAYMENT_SCHEDULE_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_Payment_Schedule__c ' +
                       'WHERE ASI_CRM_Contract__c = :contractId ' +
            			'AND RecordType.DeveloperName = :PAYMENTSCHEDULE_RECORD_TYPE ';
        
        return (List<ASI_CRM_Payment_Schedule__c>) Database.query(query);
    }
    
    /***************
	Tools Function
	***************/
    private String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
          queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }
}