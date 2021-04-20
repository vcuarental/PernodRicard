/*********************************************************************************
 * Name: ASI_CRM_VN_ContractCtrl
 * Description: Controller for ASI_CRM_VN_ContractPage
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/06/2017       Hugo Cheung             Created
 * 7/12/2018        Andy Zhang              Calculate achieved and CTD bottle
*/
public class ASI_CRM_VN_ContractCtrl {
    
	//Field Map
	private final static Map<String, Schema.SObjectField> CONTRACT_FIELD_MAP = Schema.SObjectType.ASI_CRM_VN_Contract__c.fields.getMap();
    
    //Marketing Contract User Permission Set Name
    private final static String MARKETING_CONTRACT_USER_PERMISSION_SET = 'ASI CRM VN Marketing Contract User';
    
    //System Admin Profile
    private final static String SYSTEM_ADMIN_PROFILE = 'System Administrator';
    
    //Standard Variable
    private final static String DRAFT_STATUS          = 'Draft';
    private final static String PENDING_STATUS        = 'Pending Verification';
    private final static String APPROVED_STATUS       = 'Approved';
    private final static Set<String> CLOSE_STATUS_SET = new Set<String> {
    	'Closed', 
 		'Closed(Terminated)'
    };
    //Wrapper Class for Actual Offtake
    /*
    public class ActualOfftakeWrapper {
        public ASI_TH_CRM_Actual_Offtake__c actualOfftake {get; set;}
        public Decimal convertedQty {get; set;}

        public ActualOfftakeWrapper(ASI_TH_CRM_Actual_Offtake__c actualOfftake, Decimal convertedQty) {
            this.actualOfftake = actualOfftake;
            this.convertedQty  = convertedQty;
        }
    }*/
    
    public String contractId {get; set;}
    
    //Page Control Flag
    public Boolean isEditable         {get; set;}
    public Boolean isMarketingUser    {get; set;}
    public Boolean isAdmin            {get; set;}
    public Boolean needApproval       {get; set;}
    public Boolean needVerificate     {get; set;}
    public Boolean needSetDraft       {get; set;}
    public Boolean allowCreateRequest {get; set;}
    public Boolean allowExtendClose   {get; set;}
    public Boolean showPDFButton      {get; set;}
    //public List<ActualOfftakeWrapper> actualOfftakeWrapperList              {get; set;}
    private final static Map<String, Schema.SObjectField> ACTUAL_OFFTAKE_FIELD_MAP       = Schema.SObjectType.ASI_TH_CRM_Actual_Offtake__c.fields.getMap();
    private final static Map<String, Schema.SObjectField> CONVERSION_FACTOR_FIELD_MAP    = Schema.SObjectType.ASI_CRM_VN_Sub_Brand_Conversion_Factor__c.fields.getMap();
    /*
    public Decimal targetBottle {get; set;}
    public Decimal actualBottle {get; set;}
    public Integer achieved {get; set;} */
    private final static Set<String> OUTLET_RECORD_TYPE_SET = new Set<String> {
            'ASI_CRM_VN_Outlet',
            'ASI_CRM_VN_Outlet_Inactive',
            'ASI_CRM_VN_PG_Outlets',
            'ASI_CRM_VN_Inactive_Off_Trade_Outlet',
            'ASI_CRM_VN_Off_Trade_Outlet',
            'ASI_CRM_VN_Value_Off_Trade_Outlet',
            'ASI_CRM_VN_Value_Off_Trade_Outlet_Inactive',
            'ASI_CRM_VN_Value_On_Trade_Outlet',
            'ASI_CRM_VN_Value_On_Trade_Outlet_Inactive'
    };
    private final static String ACTUAL_OFFTAKE_RECORD_TYPE = 'ASI_CRM_VN_Actual_Offtake';

    public ASI_CRM_VN_ContractCtrl(ApexPages.StandardController standardController) {
        contractId = standardController.getId();
        initPage(retrieveContract(contractId));
    }
    
    private void initPage(ASI_CRM_VN_Contract__c contract) {
		if(contract == null) {
        	return;
        }
        
        User owner       = retrieveUser(contract.ownerId);
        User currentUser = retrieveUser(UserInfo.getUserId());
        
        isMarketingUser = checkIsUserHasPermissionSet(UserInfo.getUserId(), MARKETING_CONTRACT_USER_PERMISSION_SET);
        isAdmin         = checkIsSystemAdmin(UserInfo.getUserId(), SYSTEM_ADMIN_PROFILE);
        
        if(contract.ASI_CRM_Contract_Status__c == DRAFT_STATUS) {
        	isEditable = true;
        } else {
        	isEditable = false;
        }
        
        if(contract.ASI_CRM_Contract_Status__c == DRAFT_STATUS) {
        	needApproval = true;
        } else {
        	needApproval = false;
        }
        
        if(contract.ASI_CRM_Contract_Status__c == PENDING_STATUS &&
           isMarketingUser) {
        	needVerificate = true;
        } else {
        	needVerificate = false;
        }
        
        if(CLOSE_STATUS_SET.contains(contract.ASI_CRM_Contract_Status__c) || 
           contract.ASI_CRM_Contract_Status__c == APPROVED_STATUS) {
        	allowCreateRequest = true;
        } else {
        	allowCreateRequest = false;
        }
        
        if(contract.ASI_CRM_Contract_Status__c == APPROVED_STATUS) {
        	allowExtendClose = true;
        } else {
        	allowExtendClose = false;
        }
        
        if(CLOSE_STATUS_SET.contains(contract.ASI_CRM_Contract_Status__c) || 
           contract.ASI_CRM_Contract_Status__c == APPROVED_STATUS) {
        	showPDFButton = true;
        } else {
            showPDFButton = false;
        }
        
        if(contract.ASI_CRM_Contract_Status__c == APPROVED_STATUS && 
           owner.ManagerId == UserInfo.getUserId()) {
        	needSetDraft = true; 
        } else if(contract.ASI_CRM_Contract_Status__c == PENDING_STATUS && 
                  isMarketingUser){
        	needSetDraft = true;
        } else {
        	needSetDraft = false;
        }
    }
    

    /***************
  	Data Retrievement Function
  	***************/
    private ASI_CRM_VN_Contract__c retrieveContract(Id contractId) {
    	String query = 'SELECT ' + genQueryField(CONTRACT_FIELD_MAP) + 
                       ', RecordType.DeveloperName ' + 
                       'FROM ASI_CRM_VN_Contract__c ' + 
                       'Where Id = :contractId ';
        
        List<ASI_CRM_VN_Contract__c> contractList = (List<ASI_CRM_VN_Contract__c>) Database.query(query);
        
    	return contractList.size() == 0 ? null : contractList.get(0);
  	}
/*
    private List<ASI_CRM_AccountsAdditionalField__c> retrieveCustomerList() {
        String query = 'SELECT Id, ASI_CRM_CN_Parent_Outlet__c ' +
                'FROM ASI_CRM_AccountsAdditionalField__c ' +
                'WHERE RecordType.DeveloperName in :OUTLET_RECORD_TYPE_SET ';

        return (List<ASI_CRM_AccountsAdditionalField__c>) Database.query(query);
    }
*/

    private User retrieveUser(Id userId) {
    	String query = 'SELECT Id, FirstName, ManagerId ' + 
                       'FROM User ' + 
                       'WHERE Id = :userId ';
        
        List<User> userList = (List<User>) Database.query(query);
        return userList.size() == 0 ? null : userList.get(0);
    }
    
    private Boolean checkIsUserHasPermissionSet(Id userId, String permissionName) {
    	String query = 'SELECT AssigneeId ' + 
                       'FROM PermissionSetAssignment ' + 
                       'WHERE AssigneeId = :userId ' + 
                       'AND PermissionSet.Label = :permissionName';
        List<PermissionSetAssignment> permissionSetAssignmentList = (List<PermissionSetAssignment>) Database.query(query);
        if(permissionSetAssignmentList.size() > 0) {
        	return true;
        } else {
        	return false;
        }   
    }
    
    private Boolean checkIsSystemAdmin(Id userId, String profileName) {
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1].Id;
        System.debug('Profile : ' + profileId);
        String query = 'SELECT profileId ' + 
                       'FROM User ' + 
                       'WHERE Id = :userId ' + 
                       'AND profileId = :profileId ';
        List<User> userList = (List<User>) Database.query(query);
        System.debug('User List : ' + userList);
        if(userList.size() > 0) {
        	return true;
        } else {
        	return false;
        }
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