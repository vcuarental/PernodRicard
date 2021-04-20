/**********************************************************************************
 * Name : ASI_eForm_PreFillApproversHandler
 * Revision History:
 * Related Test Class: ASI_eForm_PrefillTest
 * 1. 2018-02-21 - [WL 1.0] Fix Default Manager lookup problem for user with two words in First Name
 **********************************************************************************/
public class ASI_eForm_PreFillApproversHandler{
    
    public final static String IT_CHANGE_REQUEST = 'IT Change Request';
    public final static String PRE_TRIP_APPROVAL = 'Pre-Trip Approval';
    public final static String IT_PROC_SERVICE_REQUEST = 'Procurement & Service Request';
    public final static String USER_ID_REQUEST = 'User ID Request';
  
    public final static String PREVIEW_APPROVER= 'Preview Approver';
    public final static String APPROVER= 'Approver';
    public final static String CHANGE_AUTHORIZER= 'Change Authorizer';
    public final static String FURTHER_AUTHORIZER= 'Further Authorizer';
    public final static String HIGH_LEVEL_AUTHORIZER= 'High-Level Authorizer';    
    public final static String FINANCE_DIRECTOR= 'Finance Approver';
    public final static String CIO = 'CIO Approver';
    
    public Map<String,User> approvers {get;set;}
    
    private ASI_eForm_Route_Type__c routeType;
    private List<ASI_eForm_Route_Rule_Details__c> routeRuleDetails;
    private User currentUser;
    private String department;
    private String country;
    private String company;
    private String formType;
    private String recordType;
    private Map<Id, User> users;
    
    public ASI_eForm_PreFillApproversHandler(String recordType, String formType,User currentUser){
        system.debug('currentUser: ' + currentUser);
		
        department = currentUser.Department;
        country = currentUser.ASI_MFM_Country__c;
        company = currentUser.CompanyName;
        this.recordType = recordType;
        this.formType = formType;
        system.debug('XXX Dept:' + department + ' country: ' + country + ' company: ' + company + ' formType: ' + formType);
        this.currentUser = currentUser;        
        approvers = new Map<String,User>();         
       
               
    }
    
    public static string parseInvalidStringNames(User u)
    {
    	String firstname = u.firstName;
    	String lastName = u.lastName;
    	String name = u.name;
    	
    	if (lastName.contains(' ') && name.startsWith(lastName))
    		name = lastName + ',' + firstname;
 
		/*[WL 1.0] BEGIN*/
		system.debug('Name: ' + name + 'First Name: ' + firstname + ' Last Name: ' + lastName);
		if (firstname.contains(' ') && name.startsWith(firstname)){
			List<String> firstNameSplit = firstname.split(' ');
			
			String newFirstName = '';
			
			for (String s:firstNameSplit)
				newFirstName = newFirstName + s;
				
			name = newFirstName.replace(',','')	+ ' ' + lastName;			
			
			system.debug('New Formatted Name: ' + name);
		}
		/*[WL 1.0] END*/
    	return name;
    }
    
    private void prePopulateApprovers(){
		system.debug('Comapny: ' + company + ' Department: ' + department + 'formType: ' + formType);
		List<ASI_eForm_Route_Type__c> routeTypes = [select id from ASI_eForm_Route_Type__c
			where
			ASI_eForm_Company__c =:company and
			//ASI_eForm_Country__c =:country and
			ASI_eForm_Department__c =:department and
			ASI_eForm_Form_Type__c =:formType];
			
		if(routeTypes.size() > 0){
			
			routeRuleDetails = [select ASI_eForm_Approver__c, ASI_eForm_Preview_Approver__c, ASI_eForm_Note__c
			from ASI_eForm_Route_Rule_Details__c
			where ASI_eForm_Route_Type__c =: routeTypes.get(0).id];
			
			Set<Id> userIds = new Set<Id>();
			
			for(ASI_eForm_Route_Rule_Details__c routeRuleDetail : routeRuleDetails){
				userIds.add(routeRuleDetail.ASI_eForm_Approver__c);
			}
			
			users = new Map<Id,User>([select id, name, firstname, lastname from user where id in : userIds]);
		}       
    }
    
    
    private void prePopulateApproversWithRecordType(){
 
            List<ASI_eForm_Route_Type__c> routeTypes = [select id from ASI_eForm_Route_Type__c
                where
                ASI_eForm_Company__c =:company and
                ASI_eForm_Department__c =:department and
                ASI_eForm_Form_Type__c =:formType and
                ASI_eForm_Form_Record_Type__c =:recordType
                ];
                
            if(routeTypes.size() > 0){
                
                routeRuleDetails = [select ASI_eForm_Approver__c, ASI_eForm_Preview_Approver__c,ASI_eForm_Note__c
                from ASI_eForm_Route_Rule_Details__c
                where ASI_eForm_Route_Type__c =: routeTypes.get(0).id];
                
                Set<Id> userIds = new Set<Id>();
                
                for(ASI_eForm_Route_Rule_Details__c routeRuleDetail : routeRuleDetails){
                    userIds.add(routeRuleDetail.ASI_eForm_Approver__c);
                }
                
                users = new Map<Id,User>([select id, firstname, lastname, name from user where id in : userIds]);
            }       
    }
    
    public void processPreTripApprovalApprovers(){
        prePopulateApprovers();
        User manager = null;
        try{
             manager = [select id, firstname, lastname, name from User where id =: currentUser.managerId];
        }catch(Exception e){
            system.debug('');
        }
        if(manager != null)
            approvers.put(APPROVER,manager);
                
        if(routeRuleDetails != null){            
            for(ASI_eForm_Route_Rule_Details__c routeRuleDetail : routeRuleDetails){           
             
             if (routeRuleDetail.ASI_eForm_Preview_Approver__c)
             {
              approvers.put(PREVIEW_APPROVER, users.get(routeRuleDetail.ASI_eForm_Approver__c));
             } else {
              approvers.put(routeRuleDetail.ASI_eForm_Note__c, users.get(routeRuleDetail.ASI_eForm_Approver__c));
              }
              
              
            }            
        }
    }
    
    public void processItChangeRequestApprovers(){
        prePopulateApprovers();
        User manager = null;
        try{
             manager = [select id, firstName, Lastname, name from User where id =: currentUser.managerId];
             approvers.put(CHANGE_AUTHORIZER, manager);
        }catch(Exception e){
            system.debug('');
        }
        
        if(routeRuleDetails != null){
            
            List<User> tempUserList = new List<User>();
            
            for(ASI_eForm_Route_Rule_Details__c routeRuleDetail : routeRuleDetails){            
              if (routeRuleDetail.ASI_eForm_Preview_Approver__c)
             {
              approvers.put(PREVIEW_APPROVER, users.get(routeRuleDetail.ASI_eForm_Approver__c));
             } else {
              approvers.put(routeRuleDetail.ASI_eForm_Note__c, users.get(routeRuleDetail.ASI_eForm_Approver__c));
              }
            }            
        }
    }
    
    public void processItProcServiceRequestApprovers(){
    prePopulateApproversWithRecordType();
    User manager = null;
        try{
             manager = [select id, firstName, lastName, name from User where id =: currentUser.managerId];
             approvers.put(APPROVER, manager);
        }catch(Exception e){
            system.debug('');
        }
        
        if(routeRuleDetails != null){            
            for(ASI_eForm_Route_Rule_Details__c routeRuleDetail : routeRuleDetails){            
              if (routeRuleDetail.ASI_eForm_Preview_Approver__c)
             {
              approvers.put(PREVIEW_APPROVER, users.get(routeRuleDetail.ASI_eForm_Approver__c));
             } else {
              approvers.put(routeRuleDetail.ASI_eForm_Note__c, users.get(routeRuleDetail.ASI_eForm_Approver__c));
              }
            }            
        }
    }
    
    public  void processUserIdRequestApprovers(){
    prePopulateApproversWithRecordType();
    User manager = null;
        try{
             manager = [select id, firstName, lastName, name from User where id =: currentUser.managerId];
             approvers.put(APPROVER, manager);
        }catch(Exception e){
            system.debug('');
        }
        
        if(routeRuleDetails != null){            
            for(ASI_eForm_Route_Rule_Details__c routeRuleDetail : routeRuleDetails){            
              if (routeRuleDetail.ASI_eForm_Preview_Approver__c)
             {
              approvers.put(PREVIEW_APPROVER, users.get(routeRuleDetail.ASI_eForm_Approver__c));
             } else {
              approvers.put(routeRuleDetail.ASI_eForm_Note__c, users.get(routeRuleDetail.ASI_eForm_Approver__c));
              }
            }            
        }    
    }
     
    
}