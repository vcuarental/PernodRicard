/*********************************************************************************
 * Name: ASI_CRM_VN_MCF_Capsule_PDF_Ctrl
 * Description: Controller for ASI_CRM_MCF_Capsule_PDF_Com
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 25/07/2017       Hugo Cheung             Created
 * 21/12/2018       Andy Zhang              Achieved save as decimal
*/
public class ASI_CRM_VN_MCF_Capsule_PDF_Ctrl {
    
    //Wrapper Class for storing Approval History
    public class ApprovalHistoryWrapper {
        public ProcessInstanceStep processInstanceHistory {get; set;}
        public String approvalName                           {get; set;}
        public String approvalTitle                          {get; set;}
        
        public ApprovalHistoryWrapper(ProcessInstanceStep processInstanceHistory) {
            this.processInstanceHistory = processInstanceHistory;
        }
    }
    
    //Wrapper Class for Actual Offtake
    public class ActualOfftakeWrapper {
        public ASI_TH_CRM_Actual_Offtake__c actualOfftake {get; set;}
        public Decimal convertedQty {get; set;}

        public ActualOfftakeWrapper(ASI_TH_CRM_Actual_Offtake__c actualOfftake, Decimal convertedQty) {
            this.actualOfftake = actualOfftake;
            this.convertedQty  = convertedQty;
        }
    }
    
    private final static Set<String> OUTLET_RECORD_TYPE_SET = new Set<String> {
    	'ASI_CRM_VN_Outlet',
        'ASI_CRM_VN_Outlet_Inactive',
        'ASI_CRM_VN_PG_Outlets',
        'ASI_CRM_VN_Inactive_Off_Trade_Outlet',
        'ASI_CRM_VN_Off_Trade_Outlet'
    };
    
    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP             = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PROCESS_INSTANCE_FIELD_MAP     = Schema.SObjectType.ProcessInstanceStep.fields.getMap();
    private final static Map<String, Schema.SObjectField> ACTUAL_OFFTAKE_FIELD_MAP       = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> BOTTLE_ANALYSIS_FIELD_MAP      = Schema.SObjectType.ASI_CRM_VN_Bottle_Analysis__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONVERSION_FACTOR_FIELD_MAP    = Schema.SObjectType.ASI_CRM_VN_Sub_Brand_Conversion_Factor__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> SKU_FIELD_MAP                  = Schema.SObjectType.ASI_MFM_SKU_Code__c.fields.getMap();

    private final static String ACTUAL_OFFTAKE_RECORD_TYPE = 'ASI_CRM_VN_Actual_Offtake';

    public String contractId {get; set;}
    
    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public Date printDate                                 {get {return Date.today();}}
    public Decimal totalExpenditureAmount                 {get; set;}
    
    public ASI_CRM_VN_Contract__c contract                                  {get; set;}
    public ASI_GiftBox_Request_Header__c requestHeader                      {get; set;}
	public List<ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureList {get; set;}
    public List<ApprovalHistoryWrapper> approvalHistoryWrapperList          {get; set;}
    public List<ActualOfftakeWrapper> actualOfftakeWrapperList              {get; set;}

    public Datetime lineManageApprovalDate       {get; set;}
    public Datetime regionalDirectorApprovalDate {get; set;}
    public Datetime nationalDirectorApprovalDate {get; set;}
    public String lineManageName       {get; set;}
    public String regionalDirectorName {get; set;}
    public String nationalDirectorName {get; set;}

    public Decimal targetBottle {get; set;}
    public Decimal actualBottle {get; set;}
    public Decimal achieved {get; set;}

    public ASI_CRM_VN_MCF_Capsule_PDF_Ctrl() {
    }
    
    public Boolean init() {
        contract                = retrieveContract(contractId);
        contractExpenditureList = retrieveContractExpenditureList(contractId);
        requestHeader = retrieveRequestHeader(contractId);

        targetBottle = 0;
        actualBottle = 0;
        achieved = 0;
        calculateBottlesByContract();

        totalExpenditureAmount = 0;
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : contractExpenditureList) {
        	totalExpenditureAmount += contractExpenditure.ASI_CRM_VN_Total_Amount__c;
        }
       
        initApprovalHistory();
        if(approvalHistoryWrapperList.size() >= 4 && 
           approvalHistoryWrapperList.get(3).processInstanceHistory.StepStatus != 'Started' && 
           approvalHistoryWrapperList.get(3).processInstanceHistory.StepStatus != 'Submitted') {
        	nationalDirectorName = approvalHistoryWrapperList.get(3).approvalName;
        	nationalDirectorApprovalDate = approvalHistoryWrapperList.get(3).processInstanceHistory.SystemModstamp;
        }
        
        if(approvalHistoryWrapperList.size() >= 3) {
            regionalDirectorName = approvalHistoryWrapperList.get(2).approvalName;
            regionalDirectorApprovalDate = approvalHistoryWrapperList.get(2).processInstanceHistory.SystemModstamp;
        }
        
        if(approvalHistoryWrapperList.size() >= 2) {
            lineManageName = approvalHistoryWrapperList.get(1).approvalName;
            lineManageApprovalDate = approvalHistoryWrapperList.get(1).processInstanceHistory.SystemModstamp;
        }
        
        return true;
    }

    public void calculateBottlesByContract() {
        actualOfftakeWrapperList = new List<ActualOfftakeWrapper>();
            
        Set<Id> customerIdSet = new Set<Id>();
        
        ASI_CRM_VN_OutletHierarchy outletHierarchyHelper = new ASI_CRM_VN_OutletHierarchy(retrieveCustomerList());
        for(ASI_CRM_AccountsAdditionalField__c customer : outletHierarchyHelper.getAllOutlet(contract.ASI_CRM_Outlet_WS__c)) {
        	customerIdSet.add(customer.Id);
        }
        
        List<ASI_TH_CRM_Actual_Offtake__c> actualOfftakeList = retrieveActualOfftakeList(
            customerIdSet,
            contract.ASI_CRM_Start_Date__c.toStartOfMonth(),
            contract.ASI_CRM_End_Date__c.addMonths(1).toStartOfMonth().addDays(-1)
        );
        
        //Step 5 : Retrieve related SKU & Actual Offtake record & Conversion Factor record
        Set<String> toSubBrandIdSet = new Set<String>();
        toSubBrandIdSet.add(contract.ASI_CRM_Key_Brand__c);

        //Step 7 : get conversionFactorMap
        Map<String, ASI_CRM_VN_Sub_Brand_Conversion_Factor__c> conversionFactorMap = new Map<String, ASI_CRM_VN_Sub_Brand_Conversion_Factor__c>();
        for (ASI_CRM_VN_Sub_Brand_Conversion_Factor__c conversionFactor : retrieveConversionFactorList(toSubBrandIdSet)) {
            conversionFactorMap.put(conversionFactor.ASI_CRM_VN_Sub_brand_From__c + '_' + conversionFactor.ASI_CRM_VN_Sub_brand_To__c, conversionFactor);
        }

        Id keyBrandId = contract.ASI_CRM_Key_Brand__c;

        targetBottle = contract.ASI_CRM_Converted_Total_Sales_Target__c;
        
        // calculate actualBottle
        for (ASI_TH_CRM_Actual_Offtake__c actualOfftake : actualOfftakeList) {
            Decimal convertedQty = 0;
            if (actualOfftake.ASI_TH_CRM_Sub_brand__c == keyBrandId) {
                actualBottle += actualOfftake.ASI_TH_CRM_Quantity__c;
                convertedQty = actualOfftake.ASI_TH_CRM_Quantity__c;
            } else {
                if(conversionFactorMap.containsKey(actualOfftake.ASI_TH_CRM_Sub_brand__c + '_' + keyBrandId) == false) {
                    continue;
                }
                
                ASI_CRM_VN_Sub_Brand_Conversion_Factor__c conversionFactor = conversionFactorMap.get(actualOfftake.ASI_TH_CRM_Sub_brand__c + '_' + keyBrandId);
                actualBottle += actualOfftake.ASI_TH_CRM_Quantity__c * conversionFactor.ASI_CRM_VN_Conversion_Factor__c;
                convertedQty = actualOfftake.ASI_TH_CRM_Quantity__c * conversionFactor.ASI_CRM_VN_Conversion_Factor__c;
            }
            
            actualOfftakeWrapperList.add(new ActualOfftakeWrapper(actualOfftake, convertedQty));
        }
		
        if(targetBottle != null && actualBottle != null) 
        	achieved = (actualBottle / targetBottle * 100).setScale(2, RoundingMode.HALF_UP);
        actualBottle = contract.ASI_CRM_Contract_Vol_CTD_Bottle__c;
        //achieved = contract.ASI_CRM_Contract_Achieved__c;

        System.debug('targetBottle' + targetBottle);
        System.debug('actualBottle' + actualBottle);
        System.debug('achieved' + achieved);
    }

    private void initApprovalHistory() {
        approvalHistoryWrapperList = new List<ApprovalHistoryWrapper>();
        
        List<Id> userIdList = new List<Id>();
        for(ProcessInstanceStep processInstanceHistory : retrieveApprovalHistory(contractId)) {
        	approvalHistoryWrapperList.add(new ApprovalHistoryWrapper(processInstanceHistory));
            userIdList.add(processInstanceHistory.ActorId);
        }
        
        Map<Id, User> userMap = new Map<Id, User>(retrieveUser(userIdList));
        for(ApprovalHistoryWrapper approvalHistoryWrapper : approvalHistoryWrapperList) {
            Id userId = approvalHistoryWrapper.processInstanceHistory.ActorId;
            if(userMap.containsKey(userId)) {
                User tempUser = userMap.get(userId);
                approvalHistoryWrapper.approvalName  = tempUser.Name;
                approvalHistoryWrapper.approvalTitle = tempUser.Title;
            }
        }
    }
    
    /***************
  	Data Retrievement Function
  	***************/
    private ASI_CRM_VN_Contract__c retrieveContract(Id contractId) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', Owner.Name, ASI_CRM_Outlet_WS__r.Name, RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'Where Id = :contractId ';
        
        List<ASI_CRM_VN_Contract__c> contractList = (List<ASI_CRM_VN_Contract__c>) Database.query(query);
        
    	return contractList.size() == 0 ? null : contractList.get(0);
  	}
    
    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Id contractId) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) + 
                       ', ASI_CRM_Sub_Brand__r.Name, ASI_CRM_VN_SKU__r.name, RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract_Expenditure__c ' + 
                       'Where ASI_CRM_VN_Contract__c = :contractId ';
        
    	return (List<ASI_CRM_VN_Contract_Expenditure__c>) Database.query(query);
    }

    private ASI_GiftBox_Request_Header__c retrieveRequestHeader(Id contractId) {
        String query = 'SELECT ASI_CRM_Vol_YTD_Bottle__c, ASI_CRM_Achieved__c' +
                ', RecordType.DeveloperName ' +
                'FROM ASI_GiftBox_Request_Header__c ' +
                'Where ASI_CRM_VN_Contract__c = :contractId ';

        List<ASI_GiftBox_Request_Header__c> requestList = (List<ASI_GiftBox_Request_Header__c>) Database.query(query);

        return requestList.size() == 0 ? null : requestList.get(0);
    }

    private List<ProcessInstanceStep> retrieveApprovalHistory(Id contractId) {
        String query = 'SELECT ' + genQueryField(PROCESS_INSTANCE_FIELD_MAP) + ' ' + 
                       'FROM ProcessInstanceStep ' + 
                       'WHERE ProcessInstance.TargetObjectId = :contractId ' + 
                       'AND ProcessInstance.Status = \'Approved\' ' + 
                       'ORDER BY SystemModstamp ASC';
        return (List<ProcessInstanceStep>) Database.query(query);
    }
    
    private List<User> retrieveUser(List<Id> userIdList) {
        String query = 'SELECT Id, Name, Title ' + 
                       'FROM User ' + 
                       'WHERE id in :userIdList ';
        return (List<User>) Database.query(query);
    }

    private List<ASI_TH_CRM_Actual_Offtake__c> retrieveActualOfftakeList(Set<Id> customerIdSet, Date offtakeStartDate, Date offtakeEndDate) {
        String query = 'SELECT ' + genQueryField(ACTUAL_OFFTAKE_FIELD_MAP) +
                ', RecordType.DeveloperName, ASI_CRM_SG_Customer__r.Name, ASI_TH_CRM_Sub_brand__r.Name ' +
                'FROM ASI_TH_CRM_Actual_Offtake__c ' +
                'WHERE ASI_CRM_SG_Customer__c in :customerIdSet ' +
                'AND ASI_TH_CRM_Offtake_G_L_Date__c >= :offtakeStartDate ' +
                'AND ASI_TH_CRM_Offtake_G_L_Date__c <= :offtakeEndDate ' +
                'AND RecordType.DeveloperName = :ACTUAL_OFFTAKE_RECORD_TYPE ';

        return (List<ASI_TH_CRM_Actual_Offtake__c>) Database.query(query);
    }

    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList() {
        String query = 'SELECT Id, ASI_CRM_CN_Parent_Outlet__c ' + 
                       'FROM ASI_CRM_AccountsAdditionalField__c ' + 
                       'WHERE RecordType.DeveloperName in :OUTLET_RECORD_TYPE_SET ';
        
        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }

    private List<ASI_CRM_VN_Sub_Brand_Conversion_Factor__c> retrieveConversionFactorList(Set<String> toSubBrandIdSet) {
        String query = 'SELECT ' + genQueryField(CONVERSION_FACTOR_FIELD_MAP) +
                ', RecordType.DeveloperName ' +
                'FROM ASI_CRM_VN_Sub_Brand_Conversion_Factor__c ' +
                'WHERE ASI_CRM_VN_Sub_brand_To__c in :toSubBrandIdSet ' +
                'AND ASI_CRM_VN_Active_Flag__c = true';

        return (List<ASI_CRM_VN_Sub_Brand_Conversion_Factor__c>) Database.query(query);
    }

    private List<ASI_MFM_SKU_Code__c> retrieveSKUList(Set<Id> skuIdSet) {
        String query = 'SELECT ' + genQueryField(SKU_FIELD_MAP) +
                ', ASI_MFM_Sub_brand__r.ASI_CRM_BottleSize__c ' +
                ', RecordType.DeveloperName ' +
                'FROM ASI_MFM_SKU_Code__c ' +
                'Where Id in :skuIdSet ';

        return (List<ASI_MFM_SKU_Code__c>) Database.query(query);
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
}