/*
 *********************************************************************************
 * Name: ASI_CRM_SG_ContractManageAll_Ctrl
 * Description: Controller class for ASI_CRM_SG_ContractManageAll_Page
 * Related Test Class: ASI_CRM_SG_ContractManageAll_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 10/11/2017       Hugo Cheung             Created
 * 27/11/2017       Wilken Lee              [WL 1.0] Add validation to prevent change Sales Case or delete target in simulation
 * 23/02/2018       Wilken Lee              [WL 2.0] Clone Contract attachment when creating cash sponsorship payment
 * 20/03/2018       Wilken Lee              [WL 3.0] P4.2 Generate remaining Back Rebate achivement upon completion
 * 2018-03-27       Vincent Lam             [VL 4.0] Fix: payment schedule can input decimal as achieved %
 * 2018-10-11       Vincent Lam             [VL 5.0] CHM118869563: generate Back Rebate based on effective price on offtake G/L date
 * 2018-11-06       Wilken Lee              [WL 6.0] Round down back rebate amount to integer
 * 2018-11-06       Wilken Lee              [WL 7.0] CHM119046938 Generate remaining specific for Martell VSOP target
                           Developer Console code to generate back rebate:
                            ASI_CRM_SG_ContractManageAll_Ctrl controller = new ASI_CRM_SG_ContractManageAll_Ctrl();
                            controller.generateBackRebatesPymtSpecificTarget('a8cM00000004ZaqIAE', '011543');
 * 2019-04-02       Jeffrey Cheung          [JC 8.0] IM004570 BR Validation blocking non-BR Offtake
 * 2019-04-12       Wilken Lee              [WL 9.0] INC0079354 Generate back rebate yields divide by zero error
 * 2019-05-22       Vincent Lam             [VL 10.0] INC0078660 Fix back rebate logic (Extract code to "ASI_CRM_SG_ContractManageAll_Ctrl VL 10.0 Code Backup.txt" in SG CRM Team site for better readability)
 * 2019-07-02       Wilson Chow              add 'isEditContractOutlets' flag to allow edit contract outlets when status is 'Contract Approved'
 * 2020-11-03       Wilken Lee              [WL 11.0] IN01248875 Calculate payment line sub-brand proportion by remaining cash sponsorship balance
 * 2021-01-25       Mark Ng                 [MN 1.0] update back rebate offtake calculation key% on negative offtake
 */
global class ASI_CRM_SG_ContractManageAll_Ctrl {

    //Inner class for storing the exception
    private class ExceptionWrapper {
        private Integer lineNumber {
            get;
            set;
        }
        private String errorMessage {
            get;
            set;
        }
        private List < String > fieldAPINameList {
            get;
            set;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage) {
            this.lineNumber = lineNumber;
            this.errorMessage = errorMessage;
        }

        private ExceptionWrapper(Integer lineNumber, String errorMessage, List < String > fieldAPINameList) {
            this(lineNumber, errorMessage);
            this.fieldAPINameList = fieldAPINameList;
        }
    }

    //Wrapper Class
    private class SKUPriceWrapper {
        private ASI_MFM_SKU_Code__c sku {
            get;
            set;
        }
        private Map < String, ASI_CRM_MY_SKUPriceCost__c > skuPriceRecordTypeMap {
            get;
            set;
        }

        private SKUPriceWrapper(ASI_MFM_SKU_Code__c sku) {
            this.sku = sku;
            this.skuPriceRecordTypeMap = new Map < String, ASI_CRM_MY_SKUPriceCost__c > ();
        }

        private void addSKUPrice(String recordTypeName, ASI_CRM_MY_SKUPriceCost__c skuPrice) {
            if (!skuPriceRecordTypeMap.containsKey(recordTypeName)) {
                skuPriceRecordTypeMap.put(recordTypeName, skuPrice);
            }
        }

        private Boolean checkIsValidRecord() {
            return skuPriceRecordTypeMap.size() == 7;
        }
    }

    //Field Map
    private final static Map < String, Schema.SObjectField > CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_TH_CRM_Contract__c.fields.getMap();
    private final static Map < String, Schema.SObjectField > CONTRACT_TARGET_FIELD_MAP = Schema.SObjectType.ASI_CRM_ContractTarget__c.fields.getMap();
    private final static Map < String, Schema.SObjectField > CONTRACT_OUTLET_FIELD_MAP = Schema.SObjectType.ASI_CRM_Contract_Outlets__c.fields.getMap();
    private final static Map < String, Schema.SObjectField > PAYMENT_SCHEDULE_FIELD_MAP = Schema.SObjectType.ASI_CRM_Payment_Schedule__c.fields.getMap();

    //Record Type Developer Name
    private final static String CONTRACT_TARGET_SG_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target';
    private final static String CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE = 'ASI_CRM_SG_Contract_Target_Simulation';
    private final static String PAYMENTSCHEDULE_RECORD_TYPE = 'ASI_CRM_SG_Payment_Schedule';
    private final static String PAYMENTSCHEDULE_SIMULATION_RECORD_TYPE = 'ASI_CRM_SG_Payment_Schedule_Simulation';
    private final static String CONTRACTOUTLET_RECORD_TYPE = 'ASI_CRM_SG_Contract_Outlet';
    private final static String CONTRACTOUTLET_SIMULATION_RECORD_TYPE = 'ASI_CRM_SG_Contract_Outlet_Simulation';
    private final static String SG_SKU_RECORD_TYPE = 'ASI_CRM_SG_SKU';
    private final static String CONTRACT_RECORD_TYPE_READ_ONLY = 'ASI_CRM_SG_Contract_Read_Only';
  
  //RecordTypeId
  private final static String RTID_ACTUALOFFTAKE = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake');

    //Clone Contract Record Type Mapping
    private final static Map < String, String > contractRecordTypeMapping = new Map < String, String > {
        'ASI_CRM_SG_Contract_Read_Only' => 'ASI_CRM_SG_Contract',
        'ASI_CRM_SG_Proposal_Read_Only' => 'ASI_CRM_SG_Proposal'
    };

    //Archived Contract Record Type Mapping
    private final static Map < String, String > contractArchivedRecordTypeMapping = new Map < String, String > {
        'ASI_CRM_SG_Contract_Read_Only' => 'ASI_CRM_SG_Contract_Archived',
        'ASI_CRM_SG_Proposal_Read_Only' => 'ASI_CRM_SG_Proposal_Archived'
    };

    private final static Set < String > SG_SKU_PRICE_RECORD_TYPE_SET = new Set < String > {
        'ASI_CRM_SG_RTM_Wholesaler_Price_Per_Bottle',
        'ASI_CRM_SG_Open_Outlet_Price_Per_Bottle',
        'ASI_CRM_SG_IGC',
        'ASI_CRM_SG_CRM_Duty_Per_Bottle',
        'ASI_CRM_SG_CRM_FOB_Per_Bottle',
        'ASI_CRM_SG_CRM_Handling_Cost_Per_Bottle',
        'ASI_CRM_SG_CRM_Incentive_Price_Per_Bottle'
    };
  
  private Map<String, ASI_CRM_Payment_Schedule__c> allPaymentScheduleCashMap = new Map<String, ASI_CRM_Payment_Schedule__c>();

    //Contract Status
    public static final String DRAFT_STATUS = 'Draft';
    public static final String APPROVED_STATUS = 'Contract Approved';

    //Page Parameters Key
    private final static String SKU_NAME = 'skuName';
    private final static String FILTER_OUT_SKU_ID_LIST_JSON = 'filterOutSKUIdListJson';
    private final static String IS_QUICK_SAVE = 'isQuickSave';
    private final static String CONTRACT_TARGET_LIST_JSON = 'contractTargetListJson';
    private final static String UPDATE_CONTRACT_TARGET_LIST_JSON = 'updateContractTargetListJson';
    private final static String DELETE_CONTRACT_TARGET_LIST_JSON = 'deleteContractTargetListJson';
    private final static String UPDATE_PAYMENT_SCHEDULE_LIST_JSON = 'updatePaymentScheduleListJson';
    private final static String DELETE_PAYMENT_SCHEDULE_LIST_JSON = 'deletePaymentScheduleListJson';
    private final static String UPDATE_CONTRACT_OUTLET_LIST_JSON = 'updateContractOutletListJson';
    private final static String DELETE_CONTRACT_OUTLET_LIST_JSON = 'deleteContractOutletListJson';

    //Data Storage
    public ASI_TH_CRM_Contract__c contract {
        get;
        set;
    }
    private List < ASI_CRM_ContractTarget__c > contractTargetList;
    private List < ASI_CRM_Payment_Schedule__c > cashPaymentScheduleList;
    private List < ASI_CRM_Contract_Outlets__c > contractOutletList;
    private List < ASI_CRM_AccountsAdditionalField__c > childOutletList;
    private List < SKUPriceWrapper > skuPriceWrapperList;

  /*[WL 7.0] BEGIN*/
  private Boolean specificTargetBackRebate;
  private String targetSKUCode;
  /*[WL 7.0] END*/
  
    //Page Varaible
    public Boolean isReadOnly {
        get;
        set;
    }
    public Boolean showHeader {
        get;
        set;
    }
    public Boolean isDraftContract {
        get;
        set;
    }
  /*[WL 3.0] BEGIN*/
  public Boolean isCompleteContract {
        get;
        set;
    }
  /*[WL 3.0] END*/
    public Boolean isSimulation {
        get;
        set;
    }
    public Boolean isAlreadySimulated {
        get;
        set;
    }
    public Boolean isSimulatingContract {
        get;
        set;
    }
    public Boolean isApprovedContract {
        get;
        set;
    }
    public Boolean isConfirmRevise {
        get;
        set;
    }
    public Boolean hasError {
        get;
        set;
    }
    public List < ExceptionWrapper > exceptionList {
        get;
        set;
    } {        exceptionList = new List < ExceptionWrapper > ();}
    private string REQUESTEDPAYMENTID = '';
    public String REQUESTEDPAYMENTID_VF          {get {return REQUESTEDPAYMENTID;}}

    // 20190702 Wilson Chow
    public Boolean isEditContractOutlets {
        get;
        set;
    }
    // 20190702 Wilson Chow

    // for generate payment
    public String paymentScheduleId {get; set;}
    public ASI_TH_CRM_PaymentRequest__c paymentRequestInstance {get; set;}
    //Map<Id, Decimal> mapSubBrandId_CotractTargetCash = new Map<Id, Decimal>();  //WL 11.0 This variable is not used anywhere
    private final static String REQUEST_LINE_TYPE = 'Cash - Target Achieved';
    private final static String REQUEST_LINE_TYPE_UPFRONT = 'Cash - Upfront';

    public Decimal getInflationRate() {
        return contract.ASI_CRM_Inflation_Rate__c == null ? 0 : contract.ASI_CRM_Inflation_Rate__c;
    }
    public Decimal getDistributionRate() {
        return contract.ASI_CRM_Distribution_Rate__c == null ? 0 : contract.ASI_CRM_Distribution_Rate__c;
    }

    public Decimal oldROI {
        get;
        set;
    }
    public Decimal newROI {
        get;
        set;
    }

    public String contractTargetRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target');
        }
    }
    public String contractTargetSimulationRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__cASI_CRM_SG_Contract_Target_Simulation');
        }
    }
    public String paymentSponsorshipRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule');
        }
    }
    public String paymentSponsorshipSimulationRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__cASI_CRM_SG_Payment_Schedule_Simulation');
        }
    }
    public String contractOutletRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet');
        }
    }
    public String contractOutletSimulationRecordTypeId {
        get {
            return Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__cASI_CRM_SG_Contract_Outlet_Simulation');
        }
    }

    //JSON String for VF Page
    public String contractTargetListJson {
        get {
            return toJsonString(contractTargetList);
        }
    }
    public String cashPaymentScheduleListJson {
        get {
            return toJsonString(cashPaymentScheduleList);
        }
    }
    public String contractContractOutletListJson {
        get {
            return toJsonString(contractOutletList);
        }
    }
    public String childOutletListJson {
        get {
            return toJsonString(childOutletList);
        }
    }
    public String skuPriceWrapperListJson {
        get {
            return toJsonString(skuPriceWrapperList);
        }
    }
    public String exceptionListJson {
        get {
            return toJsonString(exceptionList);
        }
    }
    public String backRebatesPaymentResult {
        get;
        set;
    }

    public ASI_CRM_SG_ContractManageAll_Ctrl(ApexPages.StandardController standardController) {
        String contractId = String.valueOf(standardController.getRecord().get('Id'));
        Map < String, String > pageParameters = ApexPages.currentPage().getParameters();
        isReadOnly = Boolean.valueOf(pageParameters.containsKey('isReadOnly') ? pageParameters.get('isReadOnly') : 'true');
        showHeader = Boolean.valueOf(pageParameters.containsKey('showHeader') ? pageParameters.get('showHeader') : 'false');
        isSimulation = Boolean.valueOf(pageParameters.containsKey('isSimulation') ? pageParameters.get('isSimulation') : 'false');
        isEditContractOutlets = Boolean.valueOf(pageParameters.containsKey('isEditContractOutlets') ? pageParameters.get('isEditContractOutlets') : 'false');
    isAlreadySimulated = false;
    isSimulatingContract = false;
    isApprovedContract = false;
        init(contractId);

        isDraftContract = contract.ASI_TH_CRM_Contract_Status__c == 'Draft';
    isCompleteContract = contract.ASI_TH_CRM_Contract_Status__c == 'Completed';  //[WL 3.0]    
    specificTargetBackRebate = false; //[WL 7.0]
    }

    /***************
    Data Init Function
    ***************/
    private void init(String contractId) {
        contract = retrieveContract(contractId);
        // 20190702 Wilson Chow
        /*
        if (isSimulation) {
            contractTargetList = retrieveContractTargetList(contractId, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE + '\' ');
            cashPaymentScheduleList = retrievePaymentScheduleList(contractId, 'AND ASI_CRM_Type__c = \'Cash Sponsorship\' AND RecordType.DeveloperName = \'' + PAYMENTSCHEDULE_SIMULATION_RECORD_TYPE + '\' ');
            contractOutletList = retrieveContractOutletList(contractId, 'AND RecordType.DeveloperName = \'' + CONTRACTOUTLET_SIMULATION_RECORD_TYPE + '\' ');
        }
        */
        if (isSimulation || isEditContractOutlets) {
            if(isSimulation) {
                contractTargetList = retrieveContractTargetList(contractId, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE + '\' ');
                cashPaymentScheduleList = retrievePaymentScheduleList(contractId, 'AND ASI_CRM_Type__c = \'Cash Sponsorship\' AND RecordType.DeveloperName = \'' + PAYMENTSCHEDULE_SIMULATION_RECORD_TYPE + '\' ');
            }
            if (isSimulation || isEditContractOutlets) {
                contractOutletList = retrieveContractOutletList(contractId, 'AND RecordType.DeveloperName = \'' + CONTRACTOUTLET_SIMULATION_RECORD_TYPE + '\' ');
            }
        }
        // 20190702 Wilson Chow

        if (!isSimulation || contractTargetList.size() == 0){
      system.debug('isSimulation: ' + isSimulation);
            contractTargetList = retrieveContractTargetList(contractId, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_RECORD_TYPE + '\' ');
    }

        if (!isSimulation || cashPaymentScheduleList.size() == 0)
            cashPaymentScheduleList = retrievePaymentScheduleList(contractId, 'AND ASI_CRM_Type__c = \'Cash Sponsorship\' AND RecordType.DeveloperName = \'' + PAYMENTSCHEDULE_RECORD_TYPE + '\' ');

        if (!isSimulation || contractOutletList.size() == 0)
            contractOutletList = retrieveContractOutletList(contractId, 'AND RecordType.DeveloperName = \'' + CONTRACTOUTLET_RECORD_TYPE + '\' ');

        Set < Id > existingOutletIdSet = new Set < Id > ();
        for (ASI_CRM_Contract_Outlets__c contractOutlet: contractOutletList) {
            existingOutletIdSet.add(contractOutlet.ASI_CRM_SG_Customer__c);
        }

        childOutletList = new List < ASI_CRM_AccountsAdditionalField__c > ();
        for (ASI_CRM_AccountsAdditionalField__c outlet: retrieveChildOutlet(contract.ASI_CRM_CN_Outlet_WS__c)) {
            if (existingOutletIdSet.contains(outlet.Id) == false) childOutletList.add(outlet);
        }
    
    if(contractTargetList.size() > 0 &&
           contractTargetList.get(0).RecordType.DeveloperName == CONTRACT_TARGET_SG_SIMULATION_RECORD_TYPE) {
           isAlreadySimulated = true;
        }
    
    if(isSimulation &&
      contract.recordtype.developername == CONTRACT_RECORD_TYPE_READ_ONLY
    ){
      isSimulatingContract = true;
    }
    
    if(contract.recordtype.developername == CONTRACT_RECORD_TYPE_READ_ONLY){
      isApprovedContract = true;
    }
    
    /*[WL 1.0] BEGIN*/
    if(contractTargetList.size() > 0 &&
           contractTargetList.get(0).RecordType.DeveloperName == CONTRACT_TARGET_SG_RECORD_TYPE
      && !isAlreadySimulated
      && isSimulatingContract) {
         
      for (ASI_CRM_ContractTarget__c target:contractTargetList){
        target.ASI_CRM_Block_Delete__c = true;
        target.ASI_CRM_Entitle_Back_Rebates_Original__c = target.ASI_CRM_Entitle_Back_Rebates__c;
      }
        }  
    /*[WL 1.0] END*/
    
    for (ASI_CRM_Payment_Schedule__c p : cashPaymentScheduleList){
      allPaymentScheduleCashMap.put(p.id, p);
    }
    
    }

    /***************
    Page Function
    ***************/
  /*[WL 7.0] BEGIN*/
  public ASI_CRM_SG_ContractManageAll_Ctrl(){
  }

  public void generateBackRebatesPymtSpecificTarget(string contractId, string skuCode) {
    contract = retrieveContract(contractId);
    
    specificTargetBackRebate = true;
    targetSKUCode = skuCode;
    generateBackRebatesPaymentRemain();
  }
  
  /*[WL 7.0] END*/

  /*[WL 3.0] BEGIN*/
  public void generateBackRebatesPaymentRemain() {
  
        backRebatesPaymentResult = '';
    
    /*[WL 7.0] BEGIN*/
        List < ASI_CRM_ContractTarget__c > ctList = new List < ASI_CRM_ContractTarget__c >();
        if (!validateBeforeGenerateBackRebates(ctList)) {
            return;
        }
    
    if (specificTargetBackRebate)
      ctList = retrieveContractTargetList(contract.Id, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_RECORD_TYPE + '\' AND ASI_CRM_SKUCode__c = \'' + targetSKUCode + '\' ');  //[WL 7.0]
    else 
      ctList = retrieveContractTargetList(contract.Id, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_RECORD_TYPE + '\' ');
    /*[WL 7.0] END*/
        String formattedDate = datetime.now().format('YYYYMMdd', UserInfo.getTimeZone().getID());

        String paymentRequestRT = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request');
        String paymentRequestLineItemRT = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail');

        ASI_TH_CRM_PaymentRequest__c paymentRequestInstance = new ASI_TH_CRM_PaymentRequest__c(
            RecordTypeId = paymentRequestRT,
            OwnerId = UserInfo.getUserId(),
            ASI_TH_CRM_Contract__c = contract.id,
            ASI_CRM_CN_OutletWS__c = contract.ASI_CRM_CN_Outlet_WS__c,
            ASI_TH_CRM_Status__c = 'Draft',
            ASI_CRM_SG_Invoice_No__c = contract.name + '-' + formattedDate,
            ASI_CRM_SG_Invoice_Date__c = date.today() - 1,
            ASI_CRM_System_Generated__c = true
        );

        List < ASI_CRM_ContractTarget__c > list_contractTargetToUpdate = new List < ASI_CRM_ContractTarget__c > ();

    /* [VL 5.0] BEGIN */
    map<string, map<integer, backRebateWrapper>> map_backRebateMatrix = getBackRebateMatrix(ctList);
    map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_offtakeToUpdate = new map<string, list<ASI_TH_CRM_Actual_Offtake__c>>();
    map<ASI_TH_CRM_PaymentRequestLineItem__c, string> map_paymentLineToCT = new map<ASI_TH_CRM_PaymentRequestLineItem__c, string>();
    /* [VL 5.0] END */

        List < ASI_TH_CRM_PaymentRequestLineItem__c > lineItems = new List < ASI_TH_CRM_PaymentRequestLineItem__c > ();
        for (ASI_CRM_ContractTarget__c ct: ctList) {
            if (ct.ASI_CRM_Entitle_Back_Rebates__c) {
        //Issue actual remaining achivement upon Contract Completion        
                /* [VL 5.0] BEGIN */
        /*
                Decimal backRebatesAmount = ct.ASI_CRM_Bottle_Incentive_Total__c * (ct.ASI_CRM_Till_Date_Sales_Percent_Bottle__c - ct.ASI_CRM_Back_Rebates_Issued_Percent__c) / 100;
        */
        Decimal backRebatesAmount = 0;
        Decimal backRebatesBottle = 0;
        Decimal contributionFrom = ct.ASI_CRM_Back_Rebates_Issued_Percent__c;
        Decimal contributionTo = ct.ASI_CRM_Till_Date_Sales_Percent_Bottle__c;
        Integer issuedBottle = Integer.valueOf(ct.ASI_CRM_Back_Rebates_Issued_Bottle__c);
        integer targetBottle = Integer.valueOf(ct.ASI_CRM_Target_Bottle__c);
        integer achievedBottle = Integer.valueOf(ct.ASI_CRM_Till_Date_Sales_Bottle__c);
        if(ct.ASI_CRM_Back_Rebates_Adjusted__c){
                    System.debug('ct.ASI_CRM_Bottle_Incentive__c ' + ct.ASI_CRM_Bottle_Incentive__c);
                    System.debug('achievedBottle ' + achievedBottle);
                    System.debug('issuedBottle ' + issuedBottle);
          backRebatesAmount = ct.ASI_CRM_Bottle_Incentive__c * (achievedBottle - issuedBottle);
        }
        if(map_backRebateMatrix.containsKey(ct.Id)){
          map<integer, backRebateWrapper> map_result = map_backRebateMatrix.get(ct.Id);
          if(map_result != null && !map_result.isEmpty()){
                if(contributionFrom < 25 /*&& contributionTo >= 25*/ && map_result.containsKey(25)){
                    backRebateWrapper backRebateWrapper = map_result.get(25);
                    map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                    if(map_result_bottle_amount.get('bottle') <= 0) continue;

                    if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                        backRebatesAmount += map_result_bottle_amount.get('amount');
                    }
                    backRebatesBottle += map_result_bottle_amount.get('bottle');
                    if(backRebateWrapper.list_offtake.size()>0){
                        list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                        list_a.addall(backRebateWrapper.list_offtake);
                        map_offtakeToUpdate.put(ct.Id, list_a);
                    }
                }
                if(contributionFrom < 50 /*&& contributionTo >= 50*/ && map_result.containsKey(50)){
                    backRebateWrapper backRebateWrapper = map_result.get(50);
                    map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                    if(map_result_bottle_amount.get('bottle') <= 0) continue;

                    if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                        backRebatesAmount += map_result_bottle_amount.get('amount');
                    }
                    backRebatesBottle += map_result_bottle_amount.get('bottle');
                    if(backRebateWrapper.list_offtake.size()>0){
                        list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                        list_a.addall(backRebateWrapper.list_offtake);
                        map_offtakeToUpdate.put(ct.Id, list_a);
                    }
                }
                if(contributionFrom < 75 /*&& contributionTo >= 75*/ && map_result.containsKey(75)){
                    backRebateWrapper backRebateWrapper = map_result.get(75);
                    map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                    if(map_result_bottle_amount.get('bottle') <= 0) continue;

                    if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                        backRebatesAmount += map_result_bottle_amount.get('amount');
                    }
                    backRebatesBottle += map_result_bottle_amount.get('bottle');
                    if(backRebateWrapper.list_offtake.size()>0){
                        list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                        list_a.addall(backRebateWrapper.list_offtake);
                        map_offtakeToUpdate.put(ct.Id, list_a);
                    }
                }
                if(contributionFrom < 100 /*&& contributionTo >= 100*/ && map_result.containsKey(100)){
                    backRebateWrapper backRebateWrapper = map_result.get(100);
                    map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                    if(map_result_bottle_amount.get('bottle') <= 0) continue;

                    if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                        backRebatesAmount += map_result_bottle_amount.get('amount');
                    }
                    backRebatesBottle += map_result_bottle_amount.get('bottle');
                    if(backRebateWrapper.list_offtake.size()>0){
                        list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                        list_a.addall(backRebateWrapper.list_offtake);
                        map_offtakeToUpdate.put(ct.Id, list_a);
                    }
                }
                if(contributionFrom <= 100 /*&& contributionTo > 100*/ && map_result.containsKey(101)){
                    backRebateWrapper backRebateWrapper = map_result.get(101);
                    map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                    if(map_result_bottle_amount.get('bottle') <= 0) continue;

                    if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                        backRebatesAmount += map_result_bottle_amount.get('amount');
                    }
                    backRebatesBottle += map_result_bottle_amount.get('bottle');
                    if(backRebateWrapper.list_offtake.size()>0){
                        list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                        list_a.addall(backRebateWrapper.list_offtake);
                        map_offtakeToUpdate.put(ct.Id, list_a);
                    }
                }
                if(/*contributionFrom > 100 && */contributionTo > 100 && map_result.containsKey(102)){
                    backRebateWrapper backRebateWrapper = map_result.get(102);
                    map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                    if(map_result_bottle_amount.get('bottle') <= 0) continue;

                    if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                        backRebatesAmount += map_result_bottle_amount.get('amount');
                    }
                    backRebatesBottle += map_result_bottle_amount.get('bottle');
                    if(backRebateWrapper.list_offtake.size()>0){
                        list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                        list_a.addall(backRebateWrapper.list_offtake);
                        map_offtakeToUpdate.put(ct.Id, list_a);
                    }
                }

                system.debug('map_offtakeToUpdate');
                system.debug(map_offtakeToUpdate);

          }
        }
                /* [VL 5.0] END */
                if (backRebatesAmount > 0) {
                    ASI_TH_CRM_PaymentRequestLineItem__c lineItem = new ASI_TH_CRM_PaymentRequestLineItem__c(
                        RecordTypeId = paymentRequestLineItemRT,
                        ASI_CRM_SKU__c = ct.ASI_CRM_SKU__c,
                        ASI_CRM_SG_Sub_brand__c = ct.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,
                        ASI_CRM_SG_Type__c = 'Back Rebates',
            /* [VL 5.0] BEGIN */
            /*
                        ASI_CRM_Contribution_To__c = backRebatesAmount * 100 / ct.ASI_CRM_Bottle_Incentive_Total__c + ct.ASI_CRM_Back_Rebates_Issued_Percent__c,
                        ASI_CRM_Contribution_From__c = ct.ASI_CRM_Back_Rebates_Issued_Percent__c,
            */
                        ASI_CRM_Contribution_To__c = contributionTo,
                        ASI_CRM_Contribution_From__c = contributionFrom,
                        ASI_CRM_CN_Offtake_Vol__c = backRebatesBottle,
            /* [VL 5.0] BEGIN */
                        ASI_TH_CRM_Amount__c = backRebatesAmount.round(System.RoundingMode.DOWN)  //[WL 6.0]
                    );

                    lineItems.add(lineItem);

                    ct.ASI_CRM_Back_Rebates_Issued_Total__c = ct.ASI_CRM_Back_Rebates_Issued_Total__c == null ? backRebatesAmount : ct.ASI_CRM_Back_Rebates_Issued_Total__c + backRebatesAmount;
                    /* [VL 5.0] BEGIN */
                    ct.ASI_CRM_Back_Rebates_Issued_Bottle__c = ct.ASI_CRM_Back_Rebates_Issued_Bottle__c == null ? backRebatesBottle : ct.ASI_CRM_Back_Rebates_Issued_Bottle__c + backRebatesBottle;
          map_paymentLineToCT.put(lineItem, ct.Id);
          /* [VL 5.0] END */
                    list_contractTargetToUpdate.add(ct);
                }
            }
        }

        if (lineItems.size() > 0) {
            insert paymentRequestInstance;
            for (ASI_TH_CRM_PaymentRequestLineItem__c l: lineItems) {
                l.ASI_TH_CRM_Payment_Request__c = paymentRequestInstance.id;
            }
            insert lineItems;
            update list_contractTargetToUpdate;
      
      /* [VL 5.0] BEGIN */
      list<ASI_TH_CRM_Actual_Offtake__c> list_offtakeToUpdate = new list<ASI_TH_CRM_Actual_Offtake__c>();
            for (ASI_TH_CRM_PaymentRequestLineItem__c l: lineItems) {
                if(map_paymentLineToCT.containsKey(l)){
          string ctId = map_paymentLineToCT.get(l);
          if(map_offtakeToUpdate.containsKey(ctId)){
            for(ASI_TH_CRM_Actual_Offtake__c a : map_offtakeToUpdate.get(ctId)){
              a.ASI_CRM_Payment_Request_Line_Item__c = l.Id;
              list_offtakeToUpdate.add(a);
            }
          }
        }
            }
      if(list_offtakeToUpdate.size()>0){
        update list_offtakeToUpdate;
      }
      /* [VL 5.0] END */
      
            backRebatesPaymentResult = paymentRequestInstance.Id;
        } else {
            exceptionList.add(new ExceptionWrapper(0, 'No back rebates is generated.'));
        }
  
    }
  /*[WL 3.0] END*/
  
    public void generateBackRebatesPayment() {
        backRebatesPaymentResult = '';
System.debug('entered  method generateBackRebatesPayment');
    /*[WL 9.0] BEGIN*/
        //List < ASI_CRM_ContractTarget__c > ctList = retrieveContractTargetList(contract.Id, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_RECORD_TYPE + '\' ');
    List < ASI_CRM_ContractTarget__c > ctList = retrieveContractTargetList(contract.Id, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_RECORD_TYPE + '\' AND ASI_CRM_Entitle_Back_Rebates__c = true ');
    /*[WL 9.0] END*/
        if (!validateBeforeGenerateBackRebates(ctList)) {
            return;
        }

        String formattedDate = datetime.now().format('YYYYMMdd', UserInfo.getTimeZone().getID());

        String paymentRequestRT = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request');
        String paymentRequestLineItemRT = Global_RecordTypeCache.getRtId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail');

        ASI_TH_CRM_PaymentRequest__c paymentRequestInstance = new ASI_TH_CRM_PaymentRequest__c(
            RecordTypeId = paymentRequestRT,
            OwnerId = UserInfo.getUserId(),
            ASI_TH_CRM_Contract__c = contract.id,
            ASI_CRM_CN_OutletWS__c = contract.ASI_CRM_CN_Outlet_WS__c,
            ASI_TH_CRM_Status__c = 'Draft',
            ASI_CRM_SG_Invoice_No__c = contract.name + '-' + formattedDate,
            ASI_CRM_SG_Invoice_Date__c = date.today() - 1,
            ASI_CRM_System_Generated__c = true
        );

        List < ASI_CRM_ContractTarget__c > list_contractTargetToUpdate = new List < ASI_CRM_ContractTarget__c > ();
    
    /* [VL 5.0] BEGIN */
    map<string, map<integer, backRebateWrapper>> map_backRebateMatrix = getBackRebateMatrix(ctList);
    map<string, list<ASI_TH_CRM_Actual_Offtake__c>> map_offtakeToUpdate = new map<string, list<ASI_TH_CRM_Actual_Offtake__c>>();
    map<string, string> map_paymentLineToCT = new map<string, string>();
    /* [VL 5.0] END */

        List < ASI_TH_CRM_PaymentRequestLineItem__c > lineItems = new List < ASI_TH_CRM_PaymentRequestLineItem__c > ();
        for (ASI_CRM_ContractTarget__c ct: ctList) {
            if (ct.ASI_CRM_Entitle_Back_Rebates__c) {
                /* [VL 5.0] BEGIN */
        /*
                Decimal backRebatesAmount = calculateBackRebatesAmount(ct.ASI_CRM_Bottle_Incentive_Total__c, ct.ASI_CRM_Till_Date_Sales_Percent_Bottle__c, ct.ASI_CRM_Back_Rebates_Issued_Percent__c);
                */
                Decimal backRebatesAmount = 0;
                Decimal backRebatesBottle = 0;
                Decimal contributionFrom = ct.ASI_CRM_Back_Rebates_Issued_Percent__c;
                Decimal contributionTo = getRealAchievedPercent(ct.ASI_CRM_Till_Date_Sales_Percent_Bottle__c);
                Integer issuedBottle = Integer.valueOf(ct.ASI_CRM_Back_Rebates_Issued_Bottle__c);
                integer targetBottle = Integer.valueOf(ct.ASI_CRM_Target_Bottle__c);
                if(ct.ASI_CRM_Back_Rebates_Adjusted__c){
                  backRebatesAmount = calculateBackRebatesAmount(ct.ASI_CRM_Bottle_Incentive_Total__c, ct.ASI_CRM_Till_Date_Sales_Percent_Bottle__c, ct.ASI_CRM_Back_Rebates_Issued_Percent__c);
                }
                if(map_backRebateMatrix.containsKey(ct.Id)){
                  map<integer, backRebateWrapper> map_result = map_backRebateMatrix.get(ct.Id);
                  if(map_result != null && !map_result.isEmpty()){
                    
                    if(contributionFrom < 25 && contributionTo >= 25 && map_result.containsKey(25)){    //Up to 25% achievement
                        backRebateWrapper backRebateWrapper = map_result.get(25);
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        if(map_result_bottle_amount.get('bottle') <= 0) continue;

                        if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                            backRebatesAmount += map_result_bottle_amount.get('amount');
                        }
                        backRebatesBottle += map_result_bottle_amount.get('bottle');
                        if(backRebateWrapper.list_offtake.size()>0){
                            list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                            list_a.addall(backRebateWrapper.list_offtake);
                            map_offtakeToUpdate.put(ct.Id, list_a);
                        }
System.debug('sku='+ct.ASI_CRM_SKUCode__c+', backRebatesAmount='+backRebatesAmount);
                    }
                    if(contributionFrom < 50 && contributionTo >= 50 && map_result.containsKey(50)){    //Up to 50% achievement
                        backRebateWrapper backRebateWrapper = map_result.get(50);
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        if(map_result_bottle_amount.get('bottle') <= 0) continue;

                        if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                            backRebatesAmount += map_result_bottle_amount.get('amount');
                        }
                        backRebatesBottle += map_result_bottle_amount.get('bottle');
                        if(backRebateWrapper.list_offtake.size()>0){
                            list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                            list_a.addall(backRebateWrapper.list_offtake);
                            map_offtakeToUpdate.put(ct.Id, list_a);
                        }
                        system.debug('Executed map_result.containsKey(50). Amount increment: ' + map_result_bottle_amount.get('amount') + ' Quantity increment: ' + map_result_bottle_amount.get('bottle'));
System.debug('sku='+ct.ASI_CRM_SKUCode__c+', backRebatesAmount='+backRebatesAmount);                        
                    }
                    if(contributionFrom < 75 && contributionTo >= 75 && map_result.containsKey(75)){    //Up to 75% achievement
                        backRebateWrapper backRebateWrapper = map_result.get(75);
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        if(map_result_bottle_amount.get('bottle') <= 0) continue;

                        if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                            backRebatesAmount += map_result_bottle_amount.get('amount');
                        }
                        backRebatesBottle += map_result_bottle_amount.get('bottle');
                        if(backRebateWrapper.list_offtake.size()>0){
                            list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                            list_a.addall(backRebateWrapper.list_offtake);
                            map_offtakeToUpdate.put(ct.Id, list_a);
                        }
System.debug('sku='+ct.ASI_CRM_SKUCode__c+', backRebatesAmount='+backRebatesAmount);                        
                    }
                    if(contributionFrom < 100 && contributionTo >= 100 && map_result.containsKey(100)){ //Up to 100% achievement
                        backRebateWrapper backRebateWrapper = map_result.get(100);
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        if(map_result_bottle_amount.get('bottle') <= 0) continue;

                        if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                            backRebatesAmount += map_result_bottle_amount.get('amount');
                        }
                        backRebatesBottle += map_result_bottle_amount.get('bottle');
                        if(backRebateWrapper.list_offtake.size()>0){
                            list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                            list_a.addall(backRebateWrapper.list_offtake);
                            map_offtakeToUpdate.put(ct.Id, list_a);
                        }
System.debug('sku='+ct.ASI_CRM_SKUCode__c+', backRebatesAmount='+backRebatesAmount);                        
                    }
                    if(contributionFrom <= 100 && contributionTo > 100 && map_result.containsKey(101)){ //Up to over 100% achievement
                        backRebateWrapper backRebateWrapper = map_result.get(101);
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        if(map_result_bottle_amount.get('bottle') <= 0) continue;

                        if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                            backRebatesAmount += map_result_bottle_amount.get('amount');
                        }
                        backRebatesBottle += map_result_bottle_amount.get('bottle');
                        if(backRebateWrapper.list_offtake.size()>0){
                            list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                            list_a.addall(backRebateWrapper.list_offtake);
                            map_offtakeToUpdate.put(ct.Id, list_a);
                        }
System.debug('sku='+ct.ASI_CRM_SKUCode__c+', backRebatesAmount='+backRebatesAmount);                        
                    }
                    if(/*contributionFrom > 100 && */contributionTo > 100 && map_result.containsKey(102)){  //Subsequent payments after over 100% achivement has been paid
                        backRebateWrapper backRebateWrapper = map_result.get(102);
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        if(map_result_bottle_amount.get('bottle') <= 0) continue;

                        if(!ct.ASI_CRM_Back_Rebates_Adjusted__c){
                            backRebatesAmount += map_result_bottle_amount.get('amount');
                        }
                        backRebatesBottle += map_result_bottle_amount.get('bottle');
                        if(backRebateWrapper.list_offtake.size()>0){
                            list<ASI_TH_CRM_Actual_Offtake__c> list_a = map_offtakeToUpdate.containsKey(ct.Id) ? map_offtakeToUpdate.get(ct.Id) : new list<ASI_TH_CRM_Actual_Offtake__c>();
                            list_a.addall(backRebateWrapper.list_offtake);
                            map_offtakeToUpdate.put(ct.Id, list_a);
                        }
System.debug('sku='+ct.ASI_CRM_SKUCode__c+', backRebatesAmount='+backRebatesAmount);                        
                    }
                  }
                }
                        /* [VL 5.0] END */
                        if (backRebatesAmount > 0) {
                            ASI_TH_CRM_PaymentRequestLineItem__c lineItem = new ASI_TH_CRM_PaymentRequestLineItem__c(
                                RecordTypeId = paymentRequestLineItemRT,
                                ASI_CRM_SKU__c = ct.ASI_CRM_SKU__c,
                                ASI_CRM_SG_Sub_brand__c = ct.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,
                                ASI_CRM_SG_Type__c = 'Back Rebates',
                                /* [VL 5.0] BEGIN */
                                /*
                                ASI_CRM_Contribution_To__c = backRebatesAmount * 100 / ct.ASI_CRM_Bottle_Incentive_Total__c + ct.ASI_CRM_Back_Rebates_Issued_Percent__c,
                                ASI_CRM_Contribution_From__c = ct.ASI_CRM_Back_Rebates_Issued_Percent__c,
                                */
                                ASI_CRM_Contribution_To__c = contributionTo,
                                ASI_CRM_Contribution_From__c = contributionFrom,
                                ASI_CRM_CN_Offtake_Vol__c = backRebatesBottle,
                    /* [VL 5.0] BEGIN */
                                ASI_TH_CRM_Amount__c = backRebatesAmount.round(System.RoundingMode.DOWN) //[WL 6.0]
                            );

                            lineItems.add(lineItem);

                            ct.ASI_CRM_Back_Rebates_Issued_Total__c = ct.ASI_CRM_Back_Rebates_Issued_Total__c == null ? backRebatesAmount : ct.ASI_CRM_Back_Rebates_Issued_Total__c + backRebatesAmount;
                  /* [VL 5.0] BEGIN */
                            ct.ASI_CRM_Back_Rebates_Issued_Bottle__c = ct.ASI_CRM_Back_Rebates_Issued_Bottle__c == null ? backRebatesBottle : ct.ASI_CRM_Back_Rebates_Issued_Bottle__c + backRebatesBottle;
                  map_paymentLineToCT.put(ct.ASI_CRM_SKU__c, ct.Id);
                  /* [VL 5.0] END */
                            list_contractTargetToUpdate.add(ct);
                        }
            }
        }

        if (lineItems.size() > 0) {
            insert paymentRequestInstance;
            for (ASI_TH_CRM_PaymentRequestLineItem__c l: lineItems) {
                l.ASI_TH_CRM_Payment_Request__c = paymentRequestInstance.id;
            }
            insert lineItems;
            update list_contractTargetToUpdate;
      
      /* [VL 5.0] BEGIN */
      list<ASI_TH_CRM_Actual_Offtake__c> list_offtakeToUpdate = new list<ASI_TH_CRM_Actual_Offtake__c>();
            for (ASI_TH_CRM_PaymentRequestLineItem__c l: lineItems) {
                if(map_paymentLineToCT.containsKey(l.ASI_CRM_SKU__c)){
          string ctId = map_paymentLineToCT.get(l.ASI_CRM_SKU__c);
          if(map_offtakeToUpdate.containsKey(ctId)){
            for(ASI_TH_CRM_Actual_Offtake__c a : map_offtakeToUpdate.get(ctId)){
              if(!list_offtakeToUpdate.contains(a)){
                a.ASI_CRM_Payment_Request_Line_Item__c = l.Id;
                list_offtakeToUpdate.add(a);
              }
            }
          }
        }
            }
      if(list_offtakeToUpdate.size()>0){
        update list_offtakeToUpdate;
      }
      /* [VL 5.0] END */
      
            backRebatesPaymentResult = paymentRequestInstance.Id;
        } else {
            exceptionList.add(new ExceptionWrapper(0, 'No back rebates is generated.'));
        }
    }

    /**
     * Validate the following.
     * 1. Prompt error if Contract Target “Back Rebates – Issued Bottle” is blank or 0 if there is existing Back Rebate Payment of that SKU
     * 2. Prompt error if there is Offtake of the SKU that is Back Rebate Entitled, but the offtake “Back Rebate Price” is blank or 0
     *
     * @param contractTargets
     *
     * @return
     */
    public Boolean validateBeforeGenerateBackRebates(List<ASI_CRM_ContractTarget__c> contractTargets) {
        exceptionList = new List<ExceptionWrapper>();

        Set<Id> skuIds = new Set<Id>();
        for (ASI_CRM_ContractTarget__c contractTarget : contractTargets) {
            if (contractTarget.ASI_CRM_Entitle_Back_Rebates__c && (contractTarget.ASI_CRM_Back_Rebates_Issued_Bottle__c == null || contractTarget.ASI_CRM_Back_Rebates_Issued_Bottle__c == 0)) {
                skuIds.add(contractTarget.ASI_CRM_SKU__c);
            }
        }
        List<ASI_TH_CRM_PaymentRequestLineItem__c> paymentRequestLineItems = [
            SELECT
                Id
            FROM ASI_TH_CRM_PaymentRequestLineItem__c
            WHERE ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contract.Id
            AND ASI_CRM_SKU__c IN :skuIds
            AND ASI_CRM_SG_Type__c = 'Back Rebates'
            AND RecordType.DeveloperName IN ('ASI_CRM_SG_Payment_Request_Detail')
        ];

        if (paymentRequestLineItems.size() > 0) {
            exceptionList.add(new ExceptionWrapper(0, 'There is contract target with empty Back Rebates – Issued Bottle but has payment.'));
            return false;
        }

        Map<String, String> skuMappingMap = getSKUMapping();
        Map<String, String> map_ctId = new Map<String, String>();
        for(ASI_CRM_ContractTarget__c ct : contractTargets){
      /*[JC 8.0] BEGIN*/
            // Only check contract target that generates back rebates
            if (!ct.ASI_CRM_Entitle_Back_Rebates__c) {
                continue;
            }
      /*[JC 8.0] END*/

            String latestSkuId = skuMappingMap.containsKey(ct.ASI_CRM_SKU__c) ? skuMappingMap.get(ct.ASI_CRM_SKU__c) : ct.ASI_CRM_SKU__c;
            map_ctId.put(latestSkuId, ct.Id);
            if(ct.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
                String subBrandId = ct.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
                if(!map_ctId.containsKey(subBrandId)){
                    map_ctId.put(subBrandId, ct.Id);
                }
            }
        }

        List<String> emptyOfftakeNames = new List<String>();
    /*[JC 8.0] BEGIN*/
        for (ASI_TH_CRM_Actual_Offtake__c offtake : [
            SELECT
                ASI_CRM_SKU__c,
                ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c,
                ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c,
                Id,
                Name
            FROM ASI_TH_CRM_Actual_Offtake__c
            WHERE ASI_CRM_Contract__c = :contract.Id
            AND (ASI_CRM_Open_Outlet_Price__c = NULL OR ASI_CRM_Incentive_Price__c = NULL)
        ]) {
            String latestSkuId = skuMappingMap.containsKey(offtake.ASI_CRM_SKU__c) ? skuMappingMap.get(offtake.ASI_CRM_SKU__c) : offtake.ASI_CRM_SKU__c;
            String subBrandId = offtake.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
            if (map_ctId.containsKey(latestSkuId) || (offtake.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c && map_ctId.containsKey(subBrandId))) {
                emptyOfftakeNames.add(offtake.Name);
            }
        }
    /*[JC 8.0] END*/

        if (emptyOfftakeNames.size() > 0) {
            exceptionList.add(new ExceptionWrapper(0, 'Offtakes ' + String.join(emptyOfftakeNames, ', ') + ' have empty Back Rebate Price.'));
            return false;
        }

        return true;
    }

    public Decimal calculateBackRebatesAmount(Decimal amount, Decimal achieved, Decimal issued) {
    /* [VL 5.0] BEGIN */
    /*
        // if <100, find the smallest and closest in these values: 0, 25, 50, 75
        Decimal realAchieved = achieved < 100 ? achieved.divide(25, 0, System.RoundingMode.DOWN) * 25 : achieved;
        return amount * (realAchieved - issued) / 100;
    */
    return amount * (getRealAchievedPercent(achieved) - issued) / 100;
    /* [VL 5.0] END */
    }
  
  /* [VL 5.0] BEGIN */
  private decimal getRealAchievedPercent(Decimal achieved){
        // if <100, find the smallest and closest in these values: 0, 25, 50, 75
    return achieved < 100 ? getThresholdAchievedPercent(achieved) : achieved;
  }
  private decimal getThresholdAchievedPercent(Decimal achieved){
        // if <100, find the smallest and closest in these values: 0, 25, 50, 75
    return getRoundDown25(achieved) * 25;
  }
  private decimal getRoundDown25(Decimal achieved){
        // if <100, find the smallest and closest in these values: 0, 25, 50, 75
    return achieved.divide(25, 0, System.RoundingMode.DOWN);
  }
    private boolean isMulitpleOfBase(decimal cumulatedOfftakeQty, Decimal threshold){
        return threshold == cumulatedOfftakeQty || threshold * 2 == cumulatedOfftakeQty || threshold * 3 == cumulatedOfftakeQty || threshold * 4 == cumulatedOfftakeQty;
    }
  private integer getBackRebateNewKey(decimal cumulatedOfftakeQty, Decimal threshold){
        boolean isMulitpleOfThreshold = isMulitpleOfBase(cumulatedOfftakeQty, threshold);
        return Integer.valueOf(cumulatedOfftakeQty < 0 ? 0 : (cumulatedOfftakeQty / threshold <= 4 ? (cumulatedOfftakeQty.divide(threshold, 0, System.RoundingMode.DOWN) - (isMulitpleOfThreshold ? 1 : 0) + 1) * 25 : 101));
    }
  private integer getBackRebateNewKey(integer cumulatedOfftakeQty, Decimal threshold){
        return getBackRebateNewKey((Decimal)cumulatedOfftakeQty, threshold);
    }
  
  public class backRebateWrapper{
    // map<string (type: amount, bottle), decimal (how many/much)>
    public map<string, decimal> map_value {get;set;}
    public list<ASI_TH_CRM_Actual_Offtake__c> list_offtake {get;set;}
    
    public backRebateWrapper(){
      map_value = new map<string, decimal>();
      list_offtake = new list<ASI_TH_CRM_Actual_Offtake__c>();
    }
  }
  
  // map<string (contract target Id), map<integer (threshold: 0, 25, 50...), backRebateWrapper>>
  //Iterate each offtake record to calculate 
    private map<string, map<integer, backRebateWrapper>> getBackRebateMatrix(List<ASI_CRM_ContractTarget__c> list_ct){
        map<string, map<integer, backRebateWrapper>> map_backRebateMatrix = new map<string, map<integer, backRebateWrapper>>();
        map<string, string> map_ctId = new map<string, string>();   //Map that contains Contract Target latest SKU and sub-brand as key, Contract Target as value
        map<string, ASI_CRM_ContractTarget__c> map_ct = new map<string, ASI_CRM_ContractTarget__c>();
        map<string, integer> map_offtakeQty = new map<string, integer>();
        map<string, integer> map_ct_issuedBottle = new map<string, integer>();
        map<string, integer> map_ct_stopAtThreshold = new map<string, integer>();
        
        Map<String, String> skuMappingMap = getSKUMapping();
        
        for(ASI_CRM_ContractTarget__c ct : list_ct){      
            map_backRebateMatrix.put(ct.Id, new map<integer, backRebateWrapper>());
            map_offtakeQty.put(ct.Id, 0); 
          
            string lastestSkuId = skuMappingMap.containsKey(ct.ASI_CRM_SKU__c) ? skuMappingMap.get(ct.ASI_CRM_SKU__c) : ct.ASI_CRM_SKU__c;
            map_ctId.put(lastestSkuId, ct.Id);
            
          if(ct.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c){
            String subBrandId = ct.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
            if(!map_ctId.containsKey(subBrandId)){
              map_ctId.put(subBrandId, ct.Id);
            }
          }
          
          map_ct.put(ct.Id, ct);
          integer issuedBottle = Integer.valueOf(ct.ASI_CRM_Back_Rebates_Issued_Bottle__c != null ? ct.ASI_CRM_Back_Rebates_Issued_Bottle__c : 0);
          map_ct_issuedBottle.put(ct.Id, issuedBottle);
          map_ct_stopAtThreshold.put(ct.Id, -1);
        }
        
        for(ASI_TH_CRM_Actual_Offtake__c a : [
            select ASI_CRM_SKU__c, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c, ASI_CRM_Back_Rebate_Price__c,ASI_TH_CRM_Quantity__c, ASI_TH_CRM_Offtake_G_L_Date__c, ASI_CRM_Payment_Request_Line_Item__c
                from ASI_TH_CRM_Actual_Offtake__c
                    where recordtypeid = :RTID_ACTUALOFFTAKE and ASI_CRM_Contract__c = :contract.id order by ASI_TH_CRM_Offtake_G_L_Date__c]){
                        
            string lastestSkuId = skuMappingMap.containsKey(a.ASI_CRM_SKU__c) ? skuMappingMap.get(a.ASI_CRM_SKU__c) : a.ASI_CRM_SKU__c;
            String subBrandId = a.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
            string ctId = map_ctId.containsKey(lastestSkuId) ? map_ctId.get(lastestSkuId) : 
                  ((a.ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c && map_ctId.containsKey(subBrandId)) ? map_ctId.get(subBrandId) : null);
                  
            if(ctId != null){   //Only count offtake's volume if offtake SKU matches contract target SKU by SKU mapping, or Offtake SKU is of standard size and match contract target SKU's Sub-brand
                Boolean actualHasPutToUpdateList = false;
                ASI_CRM_ContractTarget__c ct = map_ct.get(ctId);
                decimal targetBottle = ct.ASI_CRM_Target_Bottle__c;
                decimal threshold = targetBottle / 4;
                integer cumulatedOfftakeQty = map_offtakeQty.get(ctId); //Start with 0 for each contract target
                integer key = getBackRebateNewKey(cumulatedOfftakeQty, threshold);
                integer issuedBottle = map_ct_issuedBottle.get(ctId);
                integer issuedKey = getBackRebateNewKey(issuedBottle, threshold);
                decimal thisOfftakeQty = a.ASI_TH_CRM_Quantity__c;
                map<integer, backRebateWrapper> map_result = map_backRebateMatrix.containsKey(ctId) ? map_backRebateMatrix.get(ctId) : new map<integer, backRebateWrapper>();
            
                if(thisOfftakeQty >= 0){    //For +ve quantity offtake, increase payment amount
                    for(integer i=0; i<thisOfftakeQty; i++){
                        integer oldKey = getBackRebateNewKey(cumulatedOfftakeQty, threshold); 
                        integer newKey = getBackRebateNewKey(cumulatedOfftakeQty + 1, threshold);
                        if(newKey != oldKey && !isMulitpleOfBase(cumulatedOfftakeQty, threshold)){
                            newKey = oldKey;
                        }
                        if(issuedBottle <= cumulatedOfftakeQty && newKey == 101){
                            newKey = 102;
                        }

                        backRebateWrapper backRebateWrapper = map_result.containsKey(newKey) ? map_result.get(newKey) : new backRebateWrapper();
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        decimal backRebatesAmount = map_result_bottle_amount.containsKey('amount') ? map_result_bottle_amount.get('amount') : 0;
                        backRebatesAmount += a.ASI_CRM_Back_Rebate_Price__c;    //Calculated by Open Outlet Price - Incentive Price
                        map_result_bottle_amount.put('amount', backRebatesAmount);
                        decimal backRebatesBottle = map_result_bottle_amount.containsKey('bottle') ? map_result_bottle_amount.get('bottle') : 0;
                        backRebatesBottle += 1;
                        map_result_bottle_amount.put('bottle', backRebatesBottle);
                        if(a.ASI_CRM_Payment_Request_Line_Item__c == null && !actualHasPutToUpdateList) {
                            a.ASI_CRM_BackRebateTargetBtl__c = ct.ASI_CRM_Target_Bottle__c;
                            backRebateWrapper.list_offtake.add(a);
                            actualHasPutToUpdateList = true;
                        }
                        map_result.put(newKey, backRebateWrapper);
                        cumulatedOfftakeQty ++;
                    }
                } 
                else {  //For -ve quantity offtake, decrease payment amount
                    for(integer i=-1; i>=thisOfftakeQty; i--){
                        integer oldKey = getBackRebateNewKey(cumulatedOfftakeQty , threshold); // MN 1.0  removed -2
                        integer newKey = getBackRebateNewKey(cumulatedOfftakeQty - 1, threshold);
                        if(newKey != oldKey && !isMulitpleOfBase(cumulatedOfftakeQty, threshold)){
                            newKey = oldKey;
                        }
                        if(issuedBottle <= (cumulatedOfftakeQty - 1) && newKey == 101){
                            newKey = 102;
                        }
                        /*
                        // if the new offtake is negative, leading the issued achievement fall below threshold, then will not affect the issued achievement
                        if(newKey < key && key <= issuedKey){
                            a
                        }
                        */
                        backRebateWrapper backRebateWrapper = map_result.containsKey(newKey) ? map_result.get(newKey) : new backRebateWrapper();
                        map<string, decimal> map_result_bottle_amount = backRebateWrapper.map_value;
                        decimal backRebatesAmount = map_result_bottle_amount.containsKey('amount') ? map_result_bottle_amount.get('amount') : 0;
                        backRebatesAmount -= a.ASI_CRM_Back_Rebate_Price__c;
                        map_result_bottle_amount.put('amount', backRebatesAmount);
                        decimal backRebatesBottle = map_result_bottle_amount.containsKey('bottle') ? map_result_bottle_amount.get('bottle') : 0;
                        backRebatesBottle -= 1;
                        map_result_bottle_amount.put('bottle', backRebatesBottle);
                        if(a.ASI_CRM_Payment_Request_Line_Item__c == null && !actualHasPutToUpdateList) {
                            a.ASI_CRM_BackRebateTargetBtl__c = ct.ASI_CRM_Target_Bottle__c;
                            backRebateWrapper.list_offtake.add(a);
                            actualHasPutToUpdateList = true;
                        }
                        map_result.put(newKey, backRebateWrapper);
                        cumulatedOfftakeQty --;
                    }
                }
                
                map_offtakeQty.put(ctId, cumulatedOfftakeQty);
                map_backRebateMatrix.put(ctId, map_result);
            }
        }
        
        system.debug('map_backRebateMatrix' + map_backRebateMatrix);
        for(string ctid : map_backRebateMatrix.keySet()){
            system.debug('ctid ' + ctid);
            map<integer, backRebateWrapper> m = map_backRebateMatrix.get(ctid);
            for(integer threshold : m.keySet()){
                system.debug('threshold ' + threshold);
                system.debug('m.get(threshold) ' + m.get(threshold));
                system.debug('m.get(threshold).list_offtake ' + m.get(threshold).list_offtake);
            }
        }
        
        return map_backRebateMatrix;
    }
  
    private Map<String, String> getSKUMapping() {
        Map<String, String> skuMappingMap = new Map<String, String>();
        String sgSKUMappingRecordType = Global_RecordTypeCache.getRTId('ASI_CRM_SKU_Mapping__cSG_SKU_Mapping');

        for(ASI_CRM_SKU_Mapping__c skuMapping : [SELECT ASI_CRM_SKU__c, ASI_CRM_New_SKU__c FROM ASI_CRM_SKU_Mapping__c WHERE RecordTypeId = :sgSKUMappingRecordType]) {
            skuMappingMap.put(skuMapping.ASI_CRM_SKU__c, skuMapping.ASI_CRM_New_SKU__c);
        }

        for(String skuId : skuMappingMap.keySet()) {
            String tempSKUId = skuMappingMap.get(skuId);

            while(skuMappingMap.containsKey(tempSKUId)) {
                tempSKUId = skuMappingMap.get(tempSKUId);
            }
            skuMappingMap.put(skuId, tempSKUId);
        }
    
    for(String skuId : skuMappingMap.values()) {
            skuMappingMap.put(skuId, skuId);
        }
        return skuMappingMap;
    }
    /* [VL 5.0] END */

    public void searchSKU() {
        Map < String, String > params = ApexPages.currentPage().getParameters();
        String skuName = params.get(SKU_NAME);
        Set < String > filterOutSKUIdList = (Set < String > ) fromJsonString(params.get(FILTER_OUT_SKU_ID_LIST_JSON), Set < String > .class);
        Map < Id, ASI_MFM_SKU_Code__c > skuMap = new Map < Id, ASI_MFM_SKU_Code__c > (retrieveSKU(skuName));
        Map < Id, SKUPriceWrapper > skuPriceWrapperMap = new Map < Id, SKUPriceWrapper > ();

        for (Id skuId: skuMap.keySet()) {
            if (!filterOutSKUIdList.contains(String.valueOf(skuId))) {
                skuPriceWrapperMap.put(skuId, new SKUPriceWrapper(skuMap.get(skuId)));
            }
        }

        for (ASI_CRM_MY_SKUPriceCost__c skuPrice: retrieveSKUPrice(skuMap.keySet(), contract.ASI_TH_CRM_Start_Date__c)) {
            if (skuPriceWrapperMap.containsKey(skuPrice.ASI_CRM_SKU__c)) {
                SKUPriceWrapper tempSKUPriceWrapper = skuPriceWrapperMap.get(skuPrice.ASI_CRM_SKU__c);
                tempSKUPriceWrapper.addSKUPrice(skuPrice.RecordType.DeveloperName, skuPrice);
                skuPriceWrapperMap.put(skuPrice.ASI_CRM_SKU__c, tempSKUPriceWrapper);
            }
        }

        skuPriceWrapperList = new List < SKUPriceWrapper > ();
        for (SKUPriceWrapper skuPriceWrapper: skuPriceWrapperMap.values()) {
            if (skuPriceWrapper.checkIsValidRecord()) {
                skuPriceWrapperList.add(skuPriceWrapper);
            }
        }
    }

    public void calculateROI() {
        Map < String, String > params = ApexPages.currentPage().getParameters();
        String contractTargetListJson = params.get(CONTRACT_TARGET_LIST_JSON);

        List < ASI_CRM_ContractTarget__c > contractList;

        try {
            contractTargetList = (List < ASI_CRM_ContractTarget__c > ) fromJsonString(contractTargetListJson, List < ASI_CRM_ContractTarget__c > .class);
            if (contractTargetList != null && contractTargetList.size() > 0) {
                oldROI = contract.ASI_CRM_ROI__c.setScale(2);
                newROI = calculateROI(contractTargetList).setScale(2);
            }
        } catch (Exception e) {
            System.debug('Page (ASI_CRM_SG_ContractTargetSim_Controller) Error ' + e.getMessage());
        }
    }

    public PageReference saveRecord() {
        //Init current page error 
        hasError = false;
        exceptionList = new List < ExceptionWrapper > ();

        //Collect Json String from VisualForce Page
        Map < String, String > params = ApexPages.currentPage().getParameters();
        Boolean isQuickSave = String.isBlank(params.get('IS_QUICK_SAVE')) ? false : Boolean.valueOf(params.get('IS_QUICK_SAVE'));
        isConfirmRevise = String.isBlank(params.get('IS_CONFIRM_REVISE')) ? false : Boolean.valueOf(params.get('IS_CONFIRM_REVISE'));
        String upsertContractTargetDataJson = params.get(UPDATE_CONTRACT_TARGET_LIST_JSON); system.debug(upsertContractTargetDataJson);
        String removeContractTargetDataJson = params.get(DELETE_CONTRACT_TARGET_LIST_JSON);
        String upsertPaymentScheduleDataJson = params.get(UPDATE_PAYMENT_SCHEDULE_LIST_JSON);
        String removePaymentScheduleDataJson = params.get(DELETE_PAYMENT_SCHEDULE_LIST_JSON);
        String upsertContractOutletDataJson = params.get(UPDATE_CONTRACT_OUTLET_LIST_JSON);
        String removeContractOutletDataJson = params.get(DELETE_CONTRACT_OUTLET_LIST_JSON);

        List < ASI_CRM_ContractTarget__c > upsertContractTargetList;
        List < String > removeContractTargetIdList;

        List < ASI_CRM_Payment_Schedule__c > upsertPaymentScheduleList;
        List < String > removePaymentScheduleIdList;

        List < ASI_CRM_Contract_Outlets__c > upsertContractOutletList;
        List < String > removeContractOutletIdList;

        //Convert Json String -> List<SObject>
        try {
            upsertContractTargetList = (List < ASI_CRM_ContractTarget__c > ) fromJsonString(upsertContractTargetDataJson, List < ASI_CRM_ContractTarget__c > .class);
            removeContractTargetIdList = (List < String > ) fromJsonString(removeContractTargetDataJson, List < String > .class);

            upsertPaymentScheduleList = (List < ASI_CRM_Payment_Schedule__c > ) fromJsonString(upsertPaymentScheduleDataJson, List < ASI_CRM_Payment_Schedule__c > .class);
            removePaymentScheduleIdList = (List < String > ) fromJsonString(removePaymentScheduleDataJson, List < String > .class);

            upsertContractOutletList = (List < ASI_CRM_Contract_Outlets__c > ) fromJsonString(upsertContractOutletDataJson, List < ASI_CRM_Contract_Outlets__c > .class);
            removeContractOutletIdList = (List < String > ) fromJsonString(removeContractOutletDataJson, List < String > .class);
        } catch (Exception e) {
            hasError = true;
            ExceptionWrapper exceptionWrapper = new ExceptionWrapper(0, 'Convert Json String Error, Please contact support.' + e.getMessage());
            exceptionList.add(exceptionWrapper);
            return null;
        }

        //Upsert data / Delete data
        System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {
            List < sObject > removeContractTragetList = convertIdToSObject(removeContractTargetIdList, 'ASI_CRM_ContractTarget__c');
            List < sObject > removePaymentScheduleList = convertIdToSObject(removePaymentScheduleIdList, 'ASI_CRM_Payment_Schedule__c');
            List < sObject > removeContractOutletList = convertIdToSObject(removeContractOutletIdList, 'ASI_CRM_Contract_Outlets__c');

            if (removeContractTragetList != null) Database.delete(removeContractTragetList);
            if (removePaymentScheduleList != null) Database.delete(removePaymentScheduleList);
            if (removeContractOutletList != null) Database.delete(removeContractOutletList);

            if (upsertContractTargetList != null && upsertContractTargetList.size() > 0) {
                //Clear relation field to prevent error occur
                for (ASI_CRM_ContractTarget__c contractTarget: upsertContractTargetList) {
                    contractTarget.ASI_CRM_SKU__r = null;
                  if(isSimulation && !isAlreadySimulated) {
            contractTarget.RecordTypeId = contractTargetSimulationRecordTypeId;
            contractTarget.id = null;
          }
                }
                Database.upsert(upsertContractTargetList);
            }

            if (upsertPaymentScheduleList != null && upsertPaymentScheduleList.size() > 0) {
                for(ASI_CRM_Payment_Schedule__c paymentSchedule : upsertPaymentScheduleList) {
                    if(isSimulation && !isAlreadySimulated) {
            paymentSchedule.RecordTypeId = paymentSponsorshipSimulationRecordTypeId;
            paymentSchedule.id = null;
          }
                }
                Database.upsert(upsertPaymentScheduleList);
            }

            if (upsertContractOutletList != null && upsertContractOutletList.size() > 0) {
                //Clear relation field to prevent error occur
                for (ASI_CRM_Contract_Outlets__c contractOutlet: upsertContractOutletList) {
                    contractOutlet.ASI_CRM_SG_Customer__r = null;

                     if(isSimulation && !isAlreadySimulated) {
            contractOutlet.RecordTypeId = contractOutletSimulationRecordTypeId;
            contractOutlet.id = null;
          }
                }
                Database.upsert(upsertContractOutletList);
            }
      
      isAlreadySimulated = true;

        } catch (Exception e) {
            hasError = true;
            Database.rollback(databaseSavepoint);

            if (e.getTypeName() == 'System.DmlException') {
                DmlException dmlException = (DmlException) e;
                for (Integer i = 0; i < dmlException.getNumDml(); i++) {
                    ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
                    exceptionList.add(exceptionWrapper);
                }
            } else {
                ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
                exceptionList.add(exceptionWrapper);
            }

            return null;
        }

        //Refresh page / Back to contract page
        PageReference pageRef;
        if (isQuickSave) {
            init(contract.Id);
        } else {
            pageRef = new PageReference('/' + contract.Id);
            pageRef.setRedirect(true);
        }

        return pageRef;
    }

    public PageReference deleteSimulation() {
        if (contractTargetList.size() > 0 && contractTargetList.get(0).RecordTypeId == contractTargetSimulationRecordTypeId) delete contractTargetList;
        if (cashPaymentScheduleList.size() > 0 && cashPaymentScheduleList.get(0).RecordTypeId == paymentSponsorshipSimulationRecordTypeId) delete cashPaymentScheduleList;
        if (contractOutletList.size() > 0 && contractOutletList.get(0).RecordTypeId == contractOutletSimulationRecordTypeId) delete contractOutletList;

        PageReference pageRef = new PageReference('/' + contract.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference reviseContract() {
        Id originalContractId;
        String originalContractName;
        Decimal originalContractROI;

        //Clone a new contract for backup  
        ASI_TH_CRM_Contract__c tempContract = contract.clone(false, true, false, false);
        tempContract.ASI_CRM_Contract_Period_Req_To_Extend__c = false;

        Database.insert(tempContract);

        //Update current contract
        contract.ASI_TH_CRM_Contract_Status__c = DRAFT_STATUS;

        originalContractId = contract.ASI_CRM_Original_Version__c == null ? tempContract.Id : contract.ASI_CRM_Original_Version__c;
        originalContractName = contract.ASI_CRM_Original_Version__c == null ? tempContract.Name : contract.ASI_CRM_Original_Version__r.Name;
        originalContractROI = contract.ASI_CRM_Original_Version__c == null ? tempContract.ASI_CRM_ROI__c : contract.ASI_CRM_Original_Version__r.ASI_CRM_ROI__c;

        Integer version = retrievePreviousContractSize(contract.Id, originalContractName, contractArchivedRecordTypeMapping.get(contract.RecordType.DeveloperName));
        contract.ASI_CRM_Original_Version__c = contract.ASI_CRM_Original_Version__c == null ? tempContract.Id : contract.ASI_CRM_Original_Version__c;
        contract.Name = originalContractName + ' Rev. ' + version;
        contract.ASI_CRM_Version__c = String.valueOf(version);
        contract.ASI_CRM_ROI__c = originalContractROI;
        contract.RecordTypeId = contractRecordTypeMapping.containsKey(contract.RecordType.DeveloperName) ?
            Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__c' + contractRecordTypeMapping.get(contract.RecordType.DeveloperName)) :
            contract.RecordTypeId;
        contract.ASI_CRM_Revising__c = true;
        contract.ASI_CRM_Alerted_30_Days_Before_End__c = false;
        contract.ASI_CRM_Alerted_60_Days_Before_End__c = false;

        Database.update(contract);

        contract.ASI_CRM_Revising__c = false;
        Database.update(contract);

        //Clone Child
        List < ASI_CRM_Contract_Outlets__c > originalContractOutletList = retrieveContractOutletList(contract.Id, 'AND RecordType.DeveloperName = \'' + CONTRACTOUTLET_RECORD_TYPE + '\' ');
        List < ASI_CRM_Contract_Outlets__c > clonedContractOutletList = new List < ASI_CRM_Contract_Outlets__c > ();
        for (ASI_CRM_Contract_Outlets__c contractOutlet: originalContractOutletList) {
            ASI_CRM_Contract_Outlets__c tempContractOutlet = contractOutlet.clone(false, true, false, false);
            tempContractOutlet.ASI_CRM_SG_Contract__c = tempContract.Id;
            clonedContractOutletList.add(tempContractOutlet);
        }

        List < ASI_CRM_Payment_Schedule__c > originalPaymentScheduleList = retrievePaymentScheduleList(contract.Id, 'AND ASI_CRM_Type__c = \'Cash Sponsorship\' AND RecordType.DeveloperName = \'' + PAYMENTSCHEDULE_RECORD_TYPE + '\' ');
        List < ASI_CRM_Payment_Schedule__c > clonedPaymentScheduleList = new List < ASI_CRM_Payment_Schedule__c > ();
        for (ASI_CRM_Payment_Schedule__c paymentSchedule: originalPaymentScheduleList) {
            ASI_CRM_Payment_Schedule__c tempPaymentSchedule = paymentSchedule.clone(false, true, false, false);
            tempPaymentSchedule.ASI_CRM_Contract__c = tempContract.Id;
            clonedPaymentScheduleList.add(tempPaymentSchedule);
        }

        List < ASI_CRM_ContractTarget__c > originalContractTargetList = retrieveContractTargetList(contract.Id, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_RECORD_TYPE + '\' ');
        List < ASI_CRM_ContractTarget__c > clonedContractTargetList = new List < ASI_CRM_ContractTarget__c > ();
        for (ASI_CRM_ContractTarget__c contractTarget: originalContractTargetList) {
            ASI_CRM_ContractTarget__c tempContractTarget = contractTarget.clone(false, true, false, false);
            tempContractTarget.ASI_CRM_Contract__c = tempContract.Id;
            clonedContractTargetList.add(tempContractTarget);
        }

        Database.insert(clonedContractOutletList);
        Database.insert(clonedPaymentScheduleList);
        Database.insert(clonedContractTargetList);

        if (contractTargetList.size() > 0 && contractTargetList.get(0).RecordTypeId == contractTargetSimulationRecordTypeId) {
            Database.delete(originalContractTargetList);
            for (ASI_CRM_ContractTarget__c contractTarget: contractTargetList) {
                contractTarget.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_ContractTarget__c' + CONTRACT_TARGET_SG_RECORD_TYPE);
            }
            Database.update(contractTargetList);
        }

        if(cashPaymentScheduleList.size() > 0 && cashPaymentScheduleList.get(0).RecordTypeId == paymentSponsorshipSimulationRecordTypeId) {
            if (originalPaymentScheduleList.size() > 0) Database.delete(originalPaymentScheduleList);
            for (ASI_CRM_Payment_Schedule__c paymentSchedule: cashPaymentScheduleList) {
                paymentSchedule.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Payment_Schedule__c' + PAYMENTSCHEDULE_RECORD_TYPE);
            }
            Database.update(cashPaymentScheduleList);
        }

        if(contractOutletList.size() > 0 && contractOutletList.get(0).RecordTypeId == contractOutletSimulationRecordTypeId) {
            if (originalContractOutletList.size() > 0) Database.delete(originalContractOutletList);
            for (ASI_CRM_Contract_Outlets__c contractOutlet: contractOutletList) {
                contractOutlet.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Contract_Outlets__c' + CONTRACTOUTLET_RECORD_TYPE);
            }
            Database.update(contractOutletList);
        }

        List < ASI_TH_CRM_PaymentRequest__c > paymentHeaderList = retrievePaymentHeader(contract.Id);
        List < ASI_FOC_Free_Goods_Request__c > focHeaderList = retrieveFOCHeader(contract.Id);
        List < ASI_TH_CRM_Actual_Offtake__c > actualOfftakeList = retrieveActualOfftake(contract.Id);

        for (ASI_TH_CRM_PaymentRequest__c paymentHeader: paymentHeaderList) {
            if (paymentHeader.ASI_CRM_Contract_No_Original__c == null) {
                paymentHeader.ASI_CRM_Contract_No_Original__c = tempContract.Name;
            }
            paymentHeader.ASI_TH_CRM_Contract__c = tempContract.Id;
        }

        for (ASI_FOC_Free_Goods_Request__c focHeader: focHeaderList) {
            if (focHeader.ASI_CRM_Contract_No_Original__c == null) {
                focHeader.ASI_CRM_Contract_No_Original__c = tempContract.Name;
            }
            focHeader.ASI_CRM_Contract__c = tempContract.Id;
        }

        for (ASI_TH_CRM_Actual_Offtake__c actualOfftake: actualOfftakeList) {
            actualOfftake.ASI_CRM_Contract__c = tempContract.Id;
        }

        if (paymentHeaderList.size() > 0) update paymentHeaderList;
        if (focHeaderList.size() > 0) update focHeaderList;
        if (actualOfftakeList.size() > 0) update actualOfftakeList;

        PageReference pageRef = new PageReference('/' + contract.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference cancel() {
        PageReference pageRef = new PageReference('/' + contract.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
  
    public void requestPayment() {
        //Init current page error 
        hasError = false;
        exceptionList = new List < ExceptionWrapper > ();

        REQUESTEDPAYMENTID = '';
        
        List<ASI_TH_CRM_PaymentRequestLineItem__c> lstPaymentRequestLines =
            new List<ASI_TH_CRM_PaymentRequestLineItem__c>();

        paymentScheduleId = ApexPages.currentPage().getParameters().get('scheduleId');

        ASI_CRM_Payment_Schedule__c currentPaymentSchedule = allPaymentScheduleCashMap.get((Id)paymentScheduleId);
        
        Boolean isZeroAchieved = false;
        Decimal paymentScheduleAmount = currentPaymentSchedule.ASI_CRM_Sponsorship__c != null ? currentPaymentSchedule.ASI_CRM_Sponsorship__c : 0;

    if(String.isNotBlank(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c) && currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c.equals('0')) {
            isZeroAchieved = true;
        } 
        Map<Id, Decimal> mapSubBrandId_CalculatedAmount = calculateAmountsBySubBrand(paymentScheduleAmount);
    
        System.Savepoint preRecordCreationState = Database.setSavepoint();
        try {
            // Formatting date
            Datetime dateInstance = Datetime.newInstance(
                Date.today().year(),
                Date.today().month(),
                Date.today().day());

            String formattedDate = dateInstance.format('YYYYMMdd', UserInfo.getTimeZone().getID());

            // Payment Request Record Creation
            paymentRequestInstance = new ASI_TH_CRM_PaymentRequest__c(
                RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequest__cASI_CRM_SG_Payment_Request'),
                OwnerId = UserInfo.getUserId(),
                ASI_TH_CRM_Contract__c = contract.id,
                ASI_CRM_CN_OutletWS__c = contract.ASI_CRM_CN_Outlet_WS__c,
                ASI_TH_CRM_Status__c = 'Draft',
                ASI_TH_CRM_GL_Date__c = Date.today(),
                ASI_CRM_SG_Invoice_No__c = contract.name + '-' + formattedDate,
                ASI_CRM_CN_Description__c = currentPaymentSchedule.ASI_CRM_Schedule_Date__c != NULL ? 
                                        (
                                            'Pymt upon '
                                          + currentPaymentSchedule.ASI_CRM_Schedule_Date__c.format()
                                        ) : ( 
                                            currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c == '0' ? 
                                            'Upfront Payment Upon Signing' : 
                                            (
                        /* [VL 4.0] BEGIN */
                        /*
                                                Integer.valueOf(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c) == 101 ? 
                        */
                                                Decimal.valueOf(currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c) == 101 ? 
                        /* [VL 4.0] END */
                        'Pymt upon timely completion' :
                        (
                          'Pymt upon '
                          + currentPaymentSchedule.ASI_CRM_Percentof_achieved_Sales_Target__c
                          + '% sales achieved'
                        )
                                            )
                                        ),
                ASI_CRM_System_Generated__c = true
            );

            Integer counter = 0;
      Decimal lineItemAmountTotal = 0;
            
            Map<ASI_TH_CRM_PaymentRequestLineItem__c, ID> map_line_contractID = new Map<ASI_TH_CRM_PaymentRequestLineItem__c, ID>();

            for(Id subBrandId : mapSubBrandId_CalculatedAmount.keySet()) {
                if(mapSubBrandId_CalculatedAmount.get(subBrandId) > 0.0) {
                    counter++;
                    ASI_TH_CRM_PaymentRequestLineItem__c paymentLine = new ASI_TH_CRM_PaymentRequestLineItem__c(
                            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_TH_CRM_PaymentRequestLineItem__cASI_CRM_SG_Payment_Request_Detail'),
                            ASI_CRM_SG_Sub_brand__c = subBrandId,
                            ASI_CRM_SG_Type__c = isZeroAchieved ? REQUEST_LINE_TYPE_UPFRONT : REQUEST_LINE_TYPE,
                            ASI_TH_CRM_Amount__c = mapSubBrandId_CalculatedAmount.get(subBrandId).setScale(2),
                            ASI_TH_CRM_Payment_Request__c = paymentRequestInstance.id
                        );
                        
                    lineItemAmountTotal += mapSubBrandId_CalculatedAmount.get(subBrandId).setScale(2);
                    lstPaymentRequestLines.add(paymentLine);
                    map_line_contractID.put(paymentLine, contract.id);
                }
            }

      system.debug('Payment Schedule Amount: ' + paymentScheduleAmount + ' Payment Request Amount: ' + lineItemAmountTotal);
      if (paymentScheduleAmount <> lineItemAmountTotal && lstPaymentRequestLines.size() > 0){
        lstPaymentRequestLines.get(0).ASI_TH_CRM_Amount__c += paymentScheduleAmount - lineItemAmountTotal;
      }
      
            system.debug('paymentRequestInstance: '+paymentRequestInstance);
            system.debug('lstPaymentRequestLines: '+lstPaymentRequestLines);

            ASI_CRM_SG_Payment_ValidationHelper_V2 validator = 
                new ASI_CRM_SG_Payment_ValidationHelper_V2(true, paymentRequestInstance, lstPaymentRequestLines, map_line_contractID);

            String validateAmount = validator.validateAmountExceed();

            if(String.isNotBlank(validateAmount)) {
        hasError = true;
        ExceptionWrapper exceptionWrapper = new ExceptionWrapper(1, validateAmount);
        exceptionList.add(exceptionWrapper);
                REQUESTEDPAYMENTID = '';

        return ;
            }

            insert paymentRequestInstance;
            ApexPages.currentPage().getParameters().put('pymtReqId', paymentRequestInstance.Id);

            for(ASI_TH_CRM_PaymentRequestLineItem__c lineIterator : lstPaymentRequestLines) {
                lineIterator.ASI_TH_CRM_Payment_Request__c = paymentRequestInstance.Id;
            }

            insert lstPaymentRequestLines;

            ASI_CRM_Payment_Schedule__c scheduleInstance = new ASI_CRM_Payment_Schedule__c(
                Id = paymentScheduleId,
                ASI_CRM_Payment_Issued__c = true
            );

            update scheduleInstance;

      /*[WL 2.0] BEGIN*/
      Attachment[] attList = [select id, name, body from Attachment where ParentId = :contract.id];
      Attachment[] insertAttList = new Attachment[]{}; 

      for(Attachment a: attList){
               Attachment att = new Attachment(name = a.name, body = a.body, parentid = paymentRequestInstance.id);
               insertAttList.add(att);
      }
      
      if(insertAttList.size() > 0){
        insert insertAttList;
      }          
      /*[WL 2.0] BEGIN*/
      
            REQUESTEDPAYMENTID = paymentRequestInstance.Id;

        } catch(Exception e) {
            
            hasError = true;
            if(preRecordCreationState != NULL) {
                Database.rollback(preRecordCreationState);
            }

            if (e.getTypeName() == 'System.DmlException') {
                DmlException dmlException = (DmlException) e;
                for (Integer i = 0; i < dmlException.getNumDml(); i++) {
                    ExceptionWrapper exceptionWrapper = new ExceptionWrapper(dmlException.getDmlIndex(i), dmlException.getDmlMessage(i), dmlException.getDmlFieldNames(i));
                    exceptionList.add(exceptionWrapper);
                }
            } else {
                ExceptionWrapper exceptionWrapper = new ExceptionWrapper(e.getLineNumber(), e.getMessage());
                exceptionList.add(exceptionWrapper);
            }

            return ;
      
        }

    }

    private Map<Id, Decimal> calculateAmountsBySubBrand(Decimal pSponsorship) {
        
        List < ASI_CRM_ContractTarget__c > ctList = retrieveContractTargetList(contract.Id, 'AND RecordType.DeveloperName = \'' + CONTRACT_TARGET_SG_RECORD_TYPE + '\' ');
        Map<Id, Decimal> mapSubBrandId_WeightPercent = new Map<Id, Decimal>();
        Decimal ctCash = 0.0, weightedPercent = 0.0;
        
        /*[WL 11.0] BEGIN*/
        List <ASI_TH_CRM_PaymentRequestLineItem__c> paymentLineList = [select ASI_CRM_SG_Sub_brand__c, ASI_TH_CRM_Amount__c from ASI_TH_CRM_PaymentRequestLineItem__c where ASI_TH_CRM_Payment_Request__r.ASI_TH_CRM_Contract__c = :contract.Id and ASI_CRM_SG_Type__c in ('Cash - Target Achieved','Cash - Upfront')];
        Map<Id, decimal> sbPaymentAmountMap = new Map<Id, decimal>();
        decimal totalPaidAmount = 0;
        
        for (ASI_TH_CRM_PaymentRequestLineItem__c pLine:paymentLineList){
            totalPaidAmount+= pLine.ASI_TH_CRM_Amount__c;
            
            if (sbPaymentAmountMap.get(pLine.ASI_CRM_SG_Sub_brand__c) == null)
                sbPaymentAmountMap.put(pLine.ASI_CRM_SG_Sub_brand__c, pLine.ASI_TH_CRM_Amount__c);
            else 
                sbPaymentAmountMap.put(pLine.ASI_CRM_SG_Sub_brand__c, sbPaymentAmountMap.get(pLine.ASI_CRM_SG_Sub_brand__c) + pLine.ASI_TH_CRM_Amount__c);
        }
        system.debug('Actual Payment Amount by Sub-brand: ' + sbPaymentAmountMap + ' totalPaidAmount: ' + totalPaidAmount);
        /*[WL 11.0] END*/
        
        for(ASI_CRM_ContractTarget__c c : ctList){ 
            ID finalSubBrandID = c.ASI_CRM_Subbrand__c != NULL ? c.ASI_CRM_Subbrand__c : c.ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c;
            ctCash = c.ASI_CRM_SG_Cash__c == NULL ? 0.0 : c.ASI_CRM_SG_Cash__c;
            //mapSubBrandId_CotractTargetCash.put(finalSubBrandID, (mapSubBrandId_CotractTargetCash.containsKey(finalSubBrandID) ? (mapSubBrandId_CotractTargetCash.get(finalSubBrandID) + ctCash) : ctCash));  //WL 11.0 This variable is not used anywhere
          
            /*[WL 11.0] BEGIN*/
            //weightedPercent = c.ASI_CRM_Weighted_percentof_Cash_Sponsor__c == NULL ? 0.0 : c.ASI_CRM_Weighted_percentof_Cash_Sponsor__c;
            if (c.ASI_CRM_SG_Cash__c != null){
                Decimal actualPaidAmountBySB = sbPaymentAmountMap.containsKey(finalSubBrandID) ? sbPaymentAmountMap.get(finalSubBrandID) : 0;
                
                weightedPercent = (c.ASI_CRM_SG_Cash__c - actualPaidAmountBySB) / (c.ASI_CRM_Contract__r.ASI_CRM_Total_Cash_Sponsorship_Cash__c - totalPaidAmount);
                mapSubBrandId_WeightPercent.put(finalSubBrandID, (mapSubBrandId_WeightPercent.containsKey(finalSubBrandID) ? (mapSubBrandId_WeightPercent.get(finalSubBrandID) + weightedPercent) : weightedPercent)); 
            }
            /*[WL 11.0] END*/     
        }
    
        Map<Id, Decimal> mapSubBrandId_AmountWithDate = new Map<Id, Decimal>();

        for(Id subBrandId : mapSubBrandId_WeightPercent.keySet()) {
            mapSubBrandId_AmountWithDate.put(
                subBrandId,
                pSponsorship * mapSubBrandId_WeightPercent.get(subBrandId)
            );
        }
        
        system.debug('mapSubBrandId_AmountWithDate: ' + mapSubBrandId_AmountWithDate);

        return mapSubBrandId_AmountWithDate;
    }

    /***************
      Business Logic Function
      ***************/
    public Decimal calculateROI(List < ASI_CRM_ContractTarget__c > contractTargetList) {
        Decimal totalReturnOnInvestment = 0;
        Decimal totalNetSales = 0;
        for (ASI_CRM_ContractTarget__c contractTarget: contractTargetList) {
            Decimal tradeAPTotalPRS = 0;
            Decimal totalManagementIncentives = 0;
            Decimal targetSalesCaseFOC = 0;
            Decimal distributionCost = 0;
            Decimal totalFreeGoodsCase = 0;
            Decimal costOfSales = 0;
            Decimal compensationForWSPriceDif = 0;
            Decimal wholesalerMarginTotal = 0;
            Decimal freeGoods = 0;
            Decimal totalAllowancesAndDiscounts = 0;
            Decimal grossSales = 0;
            Decimal netSales = 0;
            Decimal grossMargin = 0;
            Decimal returnOnInvestment = 0;

            tradeAPTotalPRS = (contractTarget.ASI_CRM_SG_Events__c == null ? 0 : contractTarget.ASI_CRM_SG_Events__c) +
                (contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_SG_Signages_Advertising_Spot__c) +
                (contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c == null ? 0 : contractTarget.ASI_CRM_SG_Trade_Incentive_Trips__c) +
                (contractTarget.ASI_CRM_SG_Product_Branding_Display__c == null ? 0 : contractTarget.ASI_CRM_SG_Product_Branding_Display__c) +
                (contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c == null ? 0 : contractTarget.ASI_CRM_SG_Ad_hoc_Promotions__c) +
                (contractTarget.ASI_CRM_SG_Ad_hoc_Others_Total__c == null ? 0 : contractTarget.ASI_CRM_SG_Ad_hoc_Others_Total__c) +
                ((contractTarget.ASI_CRM_SG_Events_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_SG_Events_Free_Bottles__c) +
                    (contractTarget.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c == null ? 0 : contractTarget.ASI_CRM_SG_Signages_Ad_Spot_Free_Btl__c) +
                    (contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_SG_Anniversary_Free_Bottles__c) +
                    (contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c == null ? 0 : contractTarget.ASI_CRM_Advertising_Spot_Free_Bottles__c)) *
                (contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c == null ? 0 : contractTarget.ASI_CRM_SG_IGC_Cost_Per_case__c) +
                (contractTarget.ASI_CRM_Advertising_Spot__c == null ? 0 : contractTarget.ASI_CRM_Advertising_Spot__c);

            Decimal contractPeriod = (contract.ASI_TH_CRM_Start_Date__c.daysBetween(contract.ASI_TH_CRM_End_Date__c)) / 30;
            totalManagementIncentives = (contractTarget.ASI_CRM_SG_Management_Incentives__c == null ? 0 : contractTarget.ASI_CRM_SG_Management_Incentives__c) *
                contractPeriod.round();

            if (contractTarget.ASI_CRM_SG_FOC_Calculation__c == 'By Sub-Brand') {
                targetSalesCaseFOC = (contractTarget.ASI_CRM_SG_Target_Sales_Sub_B_Wine_Cat__c == null ? 0 : contractTarget.ASI_CRM_SG_Target_Sales_Sub_B_Wine_Cat__c);
            } else {
                targetSalesCaseFOC = (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c);
            }

            totalFreeGoodsCase = (contractTarget.ASI_CRM_SG_Sales_Incentive__c == null ? 0 : contractTarget.ASI_CRM_SG_Sales_Incentive__c) *
                targetSalesCaseFOC /
                (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c) +
                totalManagementIncentives +
                (contractTarget.ASI_CRM_SG_Others__c == null ? 0 : contractTarget.ASI_CRM_SG_Others__c) +
                (contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c == null ? 0 : contractTarget.ASI_CRM_SG_Cont_Sponsor_Target_Incentive__c);

            grossSales = (totalFreeGoodsCase +
                    (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c)) *
                (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c) *
                (contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c);

            distributionCost = -(grossSales * (contract.ASI_CRM_Distribution_Rate__c == null ? 0 : contract.ASI_CRM_Distribution_Rate__c) / 100);

            costOfSales = -(((contractTarget.ASI_CRM_FOB_Per_Bottle__c == null ? 0 : contractTarget.ASI_CRM_FOB_Per_Bottle__c) +
                        (contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c == null ? 0 : contractTarget.ASI_CRM_Handling_Cost_Per_Bottle__c)) *
                    (1 + (contract.ASI_CRM_Inflation_Rate__c == null ? 0 : (contract.ASI_CRM_Inflation_Rate__c / 100))) +
                    (contractTarget.ASI_CRM_Duty_Per_Bottle__c == null ? 0 : contractTarget.ASI_CRM_Duty_Per_Bottle__c)) *
                ((contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c) +
                    totalFreeGoodsCase) *
                (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c) +
                distributionCost;

            if (contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c == null || contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c == 0 ||
                contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c > contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c) {
                compensationForWSPriceDif = 0;
            } else {
                compensationForWSPriceDif = (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c) *
                    (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c) *
                    ((contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c) -
                        (contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c == null ? 0 : contractTarget.ASI_CRM_SG_Consumer_Price_Offer__c));
            }

            wholesalerMarginTotal = (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c) *
                (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c) *
                (contractTarget.ASI_CRM_SG_Wholesaler_Margin__c == null ? 0 : contractTarget.ASI_CRM_SG_Wholesaler_Margin__c);

            freeGoods = -(contractTarget.ASI_CRM_SG_Total_Free_Goods_Cases__c == null ? 0 : contractTarget.ASI_CRM_SG_Total_Free_Goods_Cases__c) *
                (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c) *
                (contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c == null ? 0 : contractTarget.ASI_CRM_SG_Selling_Price_Btl_PRS_WS__c);

            totalAllowancesAndDiscounts = freeGoods -
                wholesalerMarginTotal -
                compensationForWSPriceDif -
                (contractTarget.ASI_CRM_SG_Good_in_Kinds__c == null ? 0 : contractTarget.ASI_CRM_SG_Good_in_Kinds__c) -
                (contractTarget.ASI_CRM_SG_Cash__c == null ? 0 : contractTarget.ASI_CRM_SG_Cash__c) -
                ((contractTarget.ASI_CRM_Bottle_Incentive__c == null ? 0 : contractTarget.ASI_CRM_Bottle_Incentive__c) *
                    (contractTarget.ASI_CRM_SG_Btls_Per_Case__c == null ? 0 : contractTarget.ASI_CRM_SG_Btls_Per_Case__c) *
                    (contractTarget.ASI_CRM_TargetCase__c == null ? 0 : contractTarget.ASI_CRM_TargetCase__c));

            netSales = grossSales + totalAllowancesAndDiscounts;

            grossMargin = netSales + costOfSales;

            returnOnInvestment = grossMargin - tradeAPTotalPRS;

            totalReturnOnInvestment += returnOnInvestment;
            totalNetSales += netSales;
        }

        return (totalNetSales == 0 || totalReturnOnInvestment == 0) ? 0 : (totalReturnOnInvestment / totalNetSales * 100);
    }
  
  @RemoteAction
    global static String validateAmountExceedRTMContract(Id headerId, boolean isSimulation){
    return ASI_CRM_SG_Payment_ValidationHelper_V2.validateAmountExceedRTMContract(headerId, isSimulation);
  }

    /***************
    Data Retrievement Function
    ***************/
    private ASI_TH_CRM_Contract__c retrieveContract(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) +
            ', RecordType.DeveloperName, ASI_CRM_Original_Version__r.Name, ASI_CRM_Original_Version__r.ASI_CRM_ROI__c ' +
            'FROM ASI_TH_CRM_Contract__c ' +
            'WHERE Id = :contractId ';

        List < ASI_TH_CRM_Contract__c > contractList = (List < ASI_TH_CRM_Contract__c > ) Database.query(query);
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

    private List < ASI_CRM_ContractTarget__c > retrieveContractTargetList(Id contractId, String whereClause) {
        String query = 'SELECT ' + genQueryField(CONTRACT_TARGET_FIELD_MAP) +
            ', RecordType.DeveloperName, ASI_CRM_SKU__r.Name, ASI_CRM_SKU__r.ASI_MFM_Sub_brand__c, ASI_CRM_SKU__r.ASI_CRM_Preset__c , ASI_CRM_SKU__r.ASI_CRM_Allow_Back_Rebates__c, ASI_CRM_SKU__r.ASI_CRM_Regular_Size__c ' +
            ', ASI_CRM_Contract__r.ASI_CRM_Total_Cash_Sponsorship_Cash__c ' + //WL 11.0
            'FROM ASI_CRM_ContractTarget__c ' +
            'WHERE ASI_CRM_Contract__c = :contractId ' +
      whereClause +
            'ORDER BY ASI_CRM_Sequence_No__c ';
      
      List < ASI_CRM_ContractTarget__c > list_ct = Database.query(query);
      
        return list_ct;
    }

    private List < ASI_CRM_Payment_Schedule__c > retrievePaymentScheduleList(Id contractId, String whereClause) {
        String query = 'SELECT ' + genQueryField(PAYMENT_SCHEDULE_FIELD_MAP) +
            ', RecordType.DeveloperName ' +
            'FROM ASI_CRM_Payment_Schedule__c ' +
            'WHERE ASI_CRM_Contract__c = :contractId ';

        if (String.isNotBlank(whereClause)) query += whereClause;
    
    query += 'ORDER BY ASI_CRM_Schedule_Date__c asc NULLS FIRST, ASI_CRM_Percent_Achieved__c asc';
        return (List < ASI_CRM_Payment_Schedule__c > ) Database.query(query);
    }

    private List < ASI_CRM_Contract_Outlets__c > retrieveContractOutletList(Id contractId, String whereClause) {
        String query = 'SELECT ' + genQueryField(CONTRACT_OUTLET_FIELD_MAP) +
            ', RecordType.DeveloperName, ASI_CRM_SG_Customer__r.Name ' +
            'FROM ASI_CRM_Contract_Outlets__c ' +
            'WHERE ASI_CRM_SG_Contract__c = :contractId ' +
      whereClause;

        return (List < ASI_CRM_Contract_Outlets__c > ) Database.query(query);
    }

    @TestVisible
    private List < ASI_CRM_AccountsAdditionalField__c > retrieveChildOutlet(Id parentId) {
        if(parentId == null){
            return new List <ASI_CRM_AccountsAdditionalField__c>();
        }
            
        String query = 'SELECT Id, Name ' +
            'FROM ASI_CRM_AccountsAdditionalField__c ' +
            'WHERE ASI_CRM_CN_Parent_Outlet__c  = :parentId ';
        return (List < ASI_CRM_AccountsAdditionalField__c > ) Database.query(query);
    }

    private List < ASI_MFM_SKU_Code__c > retrieveSKU(String skuName) {
        String query = 'SELECT Id, Name, ASI_MFM_Sub_brand__c, ASI_HK_CRM_Packaging_Size__c, ASI_HK_CRM_Std_Bottle_Size__c, ASI_CRM_Minimum_Sales_Cases__c, ASI_CRM_Preset__c, ASI_CRM_Allow_Back_Rebates__c ' +
            ', ASI_CRM_SG_Selling_Price_Per_Btl_PRS_WS__c, ASI_CRM_SG_Selling_Price_Per_Btl_WS_On__c, ASI_CRM_SG_IGC_Cost_Per_case__c, ASI_CRM_SG_IGC_Cost_Per_9Lc__c ' +
            ', ASI_MFM_Sub_brand__r.Name ' +
            'FROM ASI_MFM_SKU_Code__c ' +
            'WHERE RecordType.DeveloperName = :SG_SKU_RECORD_TYPE ' +
            'AND ASI_HK_CRM_IsPOSProduct__c = false ';

        if (String.isNotBlank(skuName)) {
            query += 'AND Name like \'%' + skuName.trim() + '%\' ';
        }

        query += 'Order By Name LIMIT 100';

        return (List < ASI_MFM_SKU_Code__c > ) Database.query(query);
    }

    private List < ASI_CRM_MY_SKUPriceCost__c > retrieveSKUPrice(Set < Id > skuIdSet, Date contractStartDate) {
        String query = 'SELECT ASI_CRM_SKU__c, ASI_CRM_SG_IGC_Cost_Per_9Lc__c, ASI_CRM_Price__c, ASI_CRM_Cost__c, ASI_CRM_EffectiveDate__c' +
            ', RecordType.DeveloperName ' +
            'FROM ASI_CRM_MY_SKUPriceCost__c ' +
            'WHERE RecordType.DeveloperName in :SG_SKU_PRICE_RECORD_TYPE_SET ' +
            'AND ASI_CRM_EffectiveDate__c != NULL ' +
            'AND ASI_CRM_SKU__c in :skuIdSet ';
        if (contractStartDate != null) {
            query += 'AND ASI_CRM_EffectiveDate__c <= :contractStartDate ';
        }
        query += 'Order By ASI_CRM_EffectiveDate__c DESC';
        return (List < ASI_CRM_MY_SKUPriceCost__c > ) Database.query(query);
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
    
    /***************
    Tools Function
    ***************/
    private List < sObject > convertIdToSObject(List < String > sObjIdList, String sObjType) {
        if (sObjIdList == null || sObjIdList.size() == 0) return null;

        Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sObjType);

        List < sObject > removeDataList = new List < sObject > ();
        for (String sObjId: sObjIdList) {
            removeDataList.add(convertIdToSObject(sObjId, convertType));
        }
        return removeDataList;
    }

    private sObject convertIdToSObject(String sObjId, Schema.SObjectType convertType) {
        sObject sObj = convertType.newSObject();
        sObj.put('Id', sObjId);
        return sObj;
    }

    private String genQueryField(Map < String, Schema.SObjectField > fieldMap) {
        String queryField = '';
        for (String fields: fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }

    private String toJsonString(Object obj) {
        return System.JSON.serialize(obj);
    }

    private Object fromJsonString(String jsonString, System.Type apexType) {
        if (String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }
}