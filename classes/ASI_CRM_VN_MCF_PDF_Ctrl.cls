/*********************************************************************************
 * Name: ASI_CRM_VN_MCF_PDF_Ctrl
 * Description: Controller for ASI_CRM_VN_MCF_PDF_Com
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/06/2017       Hugo Cheung             Created
 * 21/11/2018       Andy Zhang              Bug fix label 'Lump Sum' change to 'CS' PDF report 'CS' value not display
*/
public class ASI_CRM_VN_MCF_PDF_Ctrl {

    //Wrapper Class for storing Approval History
    public class ApprovalHistoryWrapper {
        public ProcessInstanceStep processInstanceHistory {get; set;}
        public String approvalName                           {get; set;}
        public String approvalTitle                          {get; set;}

        public ApprovalHistoryWrapper(ProcessInstanceStep processInstanceHistory) {
            this.processInstanceHistory = processInstanceHistory;
        }
    }

    private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP             = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> BOTTLE_ANALYSIS_FIELD_MAP      = Schema.SObjectType.ASI_CRM_VN_Bottle_Analysis__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONTRACT_EXPENDITURE_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract_Expenditure__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PROCESS_INSTANCE_FIELD_MAP     = Schema.SObjectType.ProcessInstanceStep.fields.getMap();

    private final static List<String> ITEM_SORTING_LIST = new List<String> {
            'CS',
            'PG & Uniform',
            'Branding (Signage)',
            'FOC Bottles',
            'VIP Rooms',
            'Glassware (Including Ice Buckets)',
            'Drink Menus',
            'Podium Stands & Glorifiers',
            'Display/Listing Fee',
            'Promotion',
            'Outlet Promotion'
    };

    public String contractId {get; set;}

    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}

    public Date printDate                                 {get {return Date.today();}}
    public Decimal totalExpenditureAmount                 {get; set;}
    public Decimal totalBottleAnalysisTargetPerMonth      {get; set;}
    public Decimal totalBottleAnalysisTotalContractTarget {get; set;}
    public Decimal totalBottleAnalysisTargetPerYear       {get; set;}
    public Decimal totalContractAmount                    {get; set;}

    public ASI_CRM_VN_Contract__c contract                                        {get; set;}
    public List<ASI_CRM_VN_Bottle_Analysis__c> bottleAnalysisList                 {get; set;}
    public Map<String, ASI_CRM_VN_Contract_Expenditure__c> contractExpenditureMap {get; set;}
    public List<ApprovalHistoryWrapper> approvalHistoryWrapperList                {get; set;}

    public Datetime lineManageApprovalDate       {get; set;}
    public Datetime regionalDirectorApprovalDate {get; set;}
    public Datetime nationalDirectorApprovalDate {get; set;}
    public String lineManageName       {get; set;}
    public String regionalDirectorName {get; set;}
    public String nationalDirectorName {get; set;}

    public List<String> itemSortingListForVFPage {get {return ITEM_SORTING_LIST;}}

    public ASI_CRM_VN_MCF_PDF_Ctrl() {
    }

    private Boolean init() {
        contract                = retrieveContract(contractId);
        bottleAnalysisList      = retrieveBottleAnalysisList(contractId);
        Map<String, ASI_CRM_VN_Contract_Expenditure__c> tempContractExpenditureMap  = new Map<String, ASI_CRM_VN_Contract_Expenditure__c>();

        totalExpenditureAmount = 0;
        totalContractAmount = 0;
        for(ASI_CRM_VN_Contract_Expenditure__c contractExpenditure : retrieveContractExpenditureList(contractId)) {
            totalExpenditureAmount += contractExpenditure.ASI_CRM_VN_Amount__c;
            if(contractExpenditure.ASI_CRM_VN_Item__c == 'Lump Sum')
            {
                contractExpenditure.ASI_CRM_VN_Item__c = 'CS';
                tempContractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure);
            }
            else {
                tempContractExpenditureMap.put(contractExpenditure.ASI_CRM_VN_Item__c, contractExpenditure);
            }
            system.debug(tempContractExpenditureMap);

            totalContractAmount += contractExpenditure.ASI_CRM_VN_Amount__c * contractExpenditure.ASI_CRM_VN_Quantity__c;
        }

        contractExpenditureMap = new Map<String, ASI_CRM_VN_Contract_Expenditure__c>();
        for(String itemName : ITEM_SORTING_LIST) {
                if (tempContractExpenditureMap.containsKey(itemName)) {
                        contractExpenditureMap.put(itemName, tempContractExpenditureMap.get(itemName));
                } else {
                    contractExpenditureMap.put(itemName, new ASI_CRM_VN_Contract_Expenditure__c());
                }



        }

        totalBottleAnalysisTargetPerMonth      = 0;
        totalBottleAnalysisTotalContractTarget = 0;
        totalBottleAnalysisTargetPerYear       = 0;
        for(ASI_CRM_VN_Bottle_Analysis__c bottleAnalysis : bottleAnalysisList) {
            totalBottleAnalysisTargetPerMonth      += bottleAnalysis.ASI_CRM_Target_Per_Month__c;
            totalBottleAnalysisTotalContractTarget += bottleAnalysis.ASI_CRM_Total_Contract_Target__c;
            totalBottleAnalysisTargetPerYear       += bottleAnalysis.ASI_CRM_Target_Per_Year_Bottle__c;
        }

        initApprovalHistory();
        for(ApprovalHistoryWrapper approvalHistoryWrapper : approvalHistoryWrapperList) {
            System.debug(approvalHistoryWrapper.processInstanceHistory.StepStatus);
        }

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
                ', Owner.Name, ASI_CRM_Outlet_WS__r.Name, ASI_CRM_Key_Brand__r.Name, RecordType.DeveloperName ' +
                'FROM ASI_CRM_VN_Contract__c ' +
                'Where Id = :contractId ';

        List<ASI_CRM_VN_Contract__c> contractList = (List<ASI_CRM_VN_Contract__c>) Database.query(query);

        return contractList.size() == 0 ? null : contractList.get(0);
    }

    private List<ASI_CRM_VN_Bottle_Analysis__c> retrieveBottleAnalysisList(Id contractId) {
        String query = 'SELECT ' + genQueryField(BOTTLE_ANALYSIS_FIELD_MAP) +
                ',ASI_CRM_VN_SKU__r.Name, RecordType.DeveloperName ' +
                'FROM ASI_CRM_VN_Bottle_Analysis__c ' +
                'Where ASI_CRM_VN_Contract__c = :contractId ';

        return (List<ASI_CRM_VN_Bottle_Analysis__c>) Database.query(query);
    }

    private List<ASI_CRM_VN_Contract_Expenditure__c> retrieveContractExpenditureList(Id contractId) {
        String query = 'SELECT ' + genQueryField(CONTRACT_EXPENDITURE_FIELD_MAP) +
                ', RecordType.DeveloperName ' +
                'FROM ASI_CRM_VN_Contract_Expenditure__c ' +
                'Where ASI_CRM_VN_Contract__c = :contractId ';

        return (List<ASI_CRM_VN_Contract_Expenditure__c>) Database.query(query);
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