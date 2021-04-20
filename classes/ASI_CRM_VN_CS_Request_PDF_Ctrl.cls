/*********************************************************************************
 * Name: ASI_CRM_VN_CS_Request_PDF_Ctrl
 * Description: Controller for ASI_CRM_VN_CS_Request_PDF_Com
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/07/2017       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_CS_Request_PDF_Ctrl {
    
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
    private final static Map<String, Schema.SObjectField> REQUEST_FIELD_MAP              = Schema.SObjectType.ASI_GiftBox_Request_Header__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> PROCESS_INSTANCE_FIELD_MAP     = Schema.SObjectType.ProcessInstanceStep.fields.getMap();
    
    public String requestId {get; set;}
    
    //Page Parameters
    public Boolean isPageInit {get { if(isPageInit != true) {isPageInit = init();} return isPageInit;} set;}
    
    public Date printDate                 {get {return Date.today();}}           
    
    public ASI_CRM_VN_Contract__c contract                                  {get; set;}
    public ASI_GiftBox_Request_Header__c requestHeader                      {get; set;}
    public List<ApprovalHistoryWrapper> approvalHistoryWrapperList          {get; set;}
    
    public Datetime lineManageApprovalDate       {get; set;}
    public Datetime regionalDirectorApprovalDate {get; set;}
    public Datetime nationalDirectorApprovalDate {get; set;}
    public String lineManageName       {get; set;}
    public String regionalDirectorName {get; set;}
    public String nationalDirectorName {get; set;}
    
    public ASI_CRM_VN_CS_Request_PDF_Ctrl() {
    }
    
    private Boolean init() {
        requestHeader           = retrieveRequest(requestId);
        contract                = retrieveContract(requestHeader.ASI_CRM_VN_Contract__c);
        
        initApprovalHistory(requestId);
        if(approvalHistoryWrapperList.size() >= 4) {
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
    
    private void initApprovalHistory(Id headerId) {
        approvalHistoryWrapperList = new List<ApprovalHistoryWrapper>();
        
        List<Id> userIdList = new List<Id>();
        for(ProcessInstanceStep processInstanceHistory : retrieveApprovalHistory(headerId)) {
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
    
    private ASI_GiftBox_Request_Header__c retrieveRequest(Id requestId) {
    	String query = 'SELECT ' + genQueryField(REQUEST_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_GiftBox_Request_Header__c ' + 
                       'Where Id = :requestId ';
        
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