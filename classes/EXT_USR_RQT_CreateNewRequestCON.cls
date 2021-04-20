public class EXT_USR_RQT_CreateNewRequestCON {
    public ApexPages.StandardController stdcontroller {get;set;}
    public External_User_Request__c newRequest {get;set;}
    private String groupName {get;set;}
    private String groupID {get;set;}
    public User currUser {get;set;}
    public boolean isAdmin {get;set;}

    public EXT_USR_RQT_CreateNewRequestCON(ApexPages.StandardController controller) {
        stdcontroller = controller;
        checkUserIsAdmin();
        newRequest = new External_User_Request__c();
        groupName = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('groupName'), 'UTF-8');
        groupID = ApexPages.currentPage().getParameters().get('groupID'); 
        setCommonValues();
    }
    
    public boolean checkUserIsAdmin() {
        isAdmin = false;
        User thisUser;
            Profile currProfile = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
            if(currProfile.Name.containsIgnoreCase('admin'))
                isAdmin = true;
        return isAdmin;
    }
    
    private void setCommonValues(){
        newRequest.EXT_USR_RQT_Group_Name__c = groupName;
        newRequest.OwnerId= UserInfo.getUserId();
        newRequest.EXT_USR_RQT_Group_ID__c= groupID;
        newRequest.EXT_USR_RQT_Status__c = 'Open';
        newRequest.EXT_USR_RQT_Expiry_Duration__c = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Expiry_Duration__c;
        
        newRequest.EXT_USR_RQT_Username__c = '';
        newRequest.EXT_USR_RQT_Alias__c = '';
        newRequest.EXT_USR_RQT_Community_Nickname__c = '';
        calculateExpiryDate();
    }
    
    public void calculateExpiryDate() {
        newRequest.EXT_USE_RQT_Expiry_Date__c = DateTime.now().addDays((Integer)newRequest.EXT_USR_RQT_Expiry_Duration__c);
    }
    
    private Boolean checkExternalUserExist() {
        List<User> searchUser = [SELECT Id FROM User WHERE Email =: newRequest.EXT_USR_RQT_Email__c AND isActive = true];
        if(searchUser.size() != 0){
            return true;
        }else{
            return false;
        }
    }
        
    public PageReference saveRequest() {
        Boolean extUserExist = checkExternalUserExist();
        
        try{
            if(!extUserExist){
                insert newRequest;
                Pagereference recordView = new Pagereference('/'+newRequest.Id);
                recordView.setRedirect(true);
                return recordView;  
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.EXT_USR_RQT_ErrUserAlreadyExists);
                ApexPages.addMessage(myMsg);
                return null;
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getTypeName()+': '+ex.getMessage()+'. Cause :'+ex.getCause()+'.');
            ApexPages.addMessage(myMsg);
            return null;
        }              
    }
    
    public PageReference saveAndNew() {  
        Boolean extUserExist = checkExternalUserExist();
          
        try{
            if(!extUserExist){
                insert newRequest;
                Pagereference newRecord = new Pagereference('/apex/EXT_USR_RQT_CreateNewRequest?groupName='+groupName+'&groupID='+groupId+'&retURL=/apex/EXT_USR_RQT_GroupChoice');
                newRecord.setRedirect(true);
                return newRecord;  
            } else {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.EXT_USR_RQT_ErrUserAlreadyExists);
                ApexPages.addMessage(myMsg);
                return null;
            }
        } catch (Exception ex) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getTypeName()+': '+ex.getMessage()+'. Cause :'+ex.getCause()+'.');
            ApexPages.addMessage(myMsg);
            return null;
        }              
    }
    
}