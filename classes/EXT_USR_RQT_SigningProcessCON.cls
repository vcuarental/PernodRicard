/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | External User Request                                                              |
|     - Description     | External Page where the external user invited can accept the ESN policy            |
|                       | and the NDA to access Chatter                                                      |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 03/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public without sharing class EXT_USR_RQT_SigningProcessCON {
    
    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public Boolean extUserAlreadyExist {get;set;}
    public External_User_Request__c currRequest {get;set;}
    public User currExtUser {get;set;}
    private ApexPages.StandardController stdcon {get;set;}
    public Boolean checkESNPolicySign {get;set;}
    public Boolean checkNDASign {get;set;}
    public string msg {get;set;}
    private String emailAdmin;
    public Integer testCase {get;set;}
    
        
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public EXT_USR_RQT_SigningProcessCON(ApexPages.StandardController controller) {
        stdcon = controller;
        emailAdmin = Utils_UsefulMethods.emailFromUsernameEntry(EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Username__c);
    }
        
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/
    
    /*
     * Verify that the user has the good access to the page.
     ***/ 
    public Pagereference guestAccessVerification(){
        currExtUser = new User();
        Pagereference redirect;
        checkNDASign = false;
        checkESNPolicySign = false;
        
        /* If no parameters in URL or if the 'Id' parameter is  null, redirect the user to an error Page */
        if(ApexPages.currentPage().getParameters() == null || ApexPages.currentPage().getParameters().get('Id') == ' ' || ApexPages.currentPage().getParameters().get('Id') == null || ApexPages.currentPage().getParameters().get('Id') == '' ){   
            return Page.EXT_USR_RQT_ExceptionInvalidURL;
        }else{          
            try{
            // Store the request in a variable
                currRequest = [SELECT EXT_USR_RQT_Status__c,EXT_USR_RQT_Group_ID__c,EXT_USR_RQT_Company__c,EXT_USR_RQT_Acceptance_Date__c,EXT_USE_RQT_Expiry_Date__c,EXT_USR_RQT_Email__c,EXT_USR_RQT_Alias__c,EXT_USR_RQT_Username__c,EXT_USR_RQT_Community_Nickname__c,EXT_USR_RQT_First_Name__c,EXT_USR_RQT_Last_Name__c,EXT_USR_RQT_Created_By_s_Manager__c
                                FROM  External_User_Request__c WHERE Id =: ApexPages.currentPage().getParameters().get('Id') LIMIT 1];
            }catch (Exception e){
                Utils_UsefulMethods.notifyAdminException(emailAdmin, 'EXT_USR_RQT_SigningProcessCON', 'query the External User Request with ID ['+ApexPages.currentPage().getParameters().get('Id')+'].',e);
                return Page.EXT_USR_RQT_Exception;
            }       
            extUserAlreadyExist = false;
            
            /* request is valide (not Refused or closed) or has expired ? */
            if(currRequest.EXT_USR_RQT_Status__c == 'closed' || currRequest.EXT_USR_RQT_Status__c == 'Refused' || currRequest.EXT_USE_RQT_Expiry_Date__c < DateTime.now()){
                return Page.EXT_USR_RQT_ExceptionInvalidRequest;
            }else{
                /* External User already exist ? */
                try{
                    List<User> searchUser = [SELECT Id FROM User WHERE Email =: currRequest.EXT_USR_RQT_Email__c];
                    if(searchUser.size() != 0){
                        extUserAlreadyExist = true;
                        currExtUser = searchUser.get(0);
                    }
                    return null;
                }catch(Exception e){
                    Utils_UsefulMethods.notifyAdminException(emailAdmin, 'EXT_USR_RQT_SigningProcessCON', 'Exception during query the current external user [Email:'+currRequest.EXT_USR_RQT_Email__c+'/Request Id:'+currRequest.Id+'].',e);
                    return Page.EXT_USR_RQT_Exception;
                }
            }
        }
    }
    
    /*
     * Verify that the user has signed the 2 documents then call the method "addUserToGroup".
     ***/ 
    public Pagereference signThenCreateExtUser(){
        /* Documents signed ? */
        if(checkNDASign && checkESNPolicySign){ // sign 
            /* Call the Webservice which create or update the new External User, add him to the group and Update the request */
            List<EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn> listCodeReturn = new List<EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn>();
            listCodeReturn = addUserToGroup();
            
            if(listCodeReturn.size() == 1 && listCodeReturn.get(0).code == 'OK'){
                return Page.EXT_USR_RQT_success;
            }else{
                String msgErr = '';
                Integer compt = 1;
                for(EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn item : listCodeReturn){
                    msgErr += 'Error '+compt+' : ['+item.code+'] ' + item.error+'. \n';
                }
                system.debug('#### '+msgErr);
                Utils_UsefulMethods.notifyAdminMsg(emailAdmin, 'EXT_USR_RQT_SigningProcessCON', 'Error during execute the webservice. [Request Id:'+currRequest.Id+']', msgErr);
                return Page.EXT_USR_RQT_Exception;
            }
            return null;
        }else{  // not sign
            /* Request suspended, user redirect to specific page */
            currRequest.EXT_USR_RQT_Status__c = 'Suspended';
            
            try{
                update currRequest;
                return Page.EXT_USR_RQT_ExceptionNotSign;
            }catch(Exception e){
                Utils_UsefulMethods.notifyAdminException(emailAdmin, 'EXT_USR_RQT_SigningProcessCON','Exception during update the request [User not sign]. [Request Id:'+currRequest.Id+']',e);
                return Page.EXT_USR_RQT_Exception;
            }
        }
    }
    
    /*
     * Webservice which create or update the new External User, add him to the group and Update the request.
     ****/
    public List<EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn> addUserToGroup() {
        boolean testIsSuccess;
        List<EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn> listCodeReturn = new List<EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn>();
        
        partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
        
        if (!EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Production__c) {
            sp.endpoint_x = 'https://test.salesforce.com/services/Soap/u/36.0';
        }
        try {
            /* Log into SFDC with credentials in custom setting */
            partnerSoapSforceCom.LoginResult loginResult;
            if(!Test.isRunningTest()){
                loginResult = sp.login(EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Username__c, Utils_Crypto.decrypt(EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Encrypted_Password__c,EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_AES_Key__c) + EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_Security_Token__c );
            }else{
                loginResult = new partnerSoapSforceCom.LoginResult();
            }
                     
            String urlBase='';
            if(!Test.isRunningTest()){
                urlBase = loginResult.serverUrl.substring(0, loginResult.serverUrl.indexOf('/u/'));
            }
            
            /* Using the split method we will get Instance name. */           
            EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_AddUserGroupWS ws = new EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_AddUserGroupWS();   
            ws.endpoint_x =urlBase +'/class/EXT_USR_RQT_AddUserGroupWS';
            ws.SessionHeader = new EXT_USR_RQT_AddUserGroupWSConnector.SessionHeader_element();
            ws.SessionHeader.sessionId = loginResult.sessionId;
            
            /* Create the Wrapper object which contains all informations needed to do the stuff. */
            EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_Wrapper myRqt = new EXT_USR_RQT_AddUserGroupWSConnector.EXT_USR_RQT_Wrapper();
            myRqt.Alias = currRequest.EXT_USR_RQT_Alias__c;
            myRqt.Company = currRequest.EXT_USR_RQT_Company__c;
            myRqt.Email = currRequest.EXT_USR_RQT_Email__c;
            myRqt.ExpiryDate = currRequest.EXT_USE_RQT_Expiry_Date__c;
            myRqt.FirstName = currRequest.EXT_USR_RQT_First_Name__c;
            myRqt.groupID = currRequest.EXT_USR_RQT_Group_ID__c;
            myRqt.LastName = currRequest.EXT_USR_RQT_Last_Name__c;
            myRqt.Nickname = currRequest.EXT_USR_RQT_Community_Nickname__c;
            myRqt.requestID = currRequest.Id;
            myRqt.Username = currRequest.EXT_USR_RQT_Username__c;
            
            if(extUserAlreadyExist){                
                myRqt.ExtUserID = currExtUser.Id;
            }
            
            /* Call the WS. */
            if(testCase == 2){
                EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn cr = new EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn();
                cr.code = 'OK';
                cr.error = 'Test';
                listCodeReturn.add(cr);
            }else{
                listCodeReturn = ws.addUserToGroup(myRqt);    
            }
            
            for(EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn cr : listCodeReturn){
                System.debug('#### code return : ['+cr.code+'] '+cr.error);
            }
            return listCodeReturn;
        } catch(Exception ex) {
            EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn cr = new EXT_USR_RQT_AddUserGroupWSConnector.CodeReturn();
            cr.code = 'KO';
            cr.error = 'Exception during call the webservice [Request Id:'+currRequest.Id+']: '+ ex.getMessage()+ ', Error :=' + ex.getTypeName();
            listCodeReturn.add(cr);
            return listCodeReturn;
        }
    }
}