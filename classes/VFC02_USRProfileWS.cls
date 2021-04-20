/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | ESN Policy                                                                                 |
|     - Description     | Pop-up invited PR Employee to sign the ESN Policy before access to Chatter.        |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 25/07/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         | Add translation handling.                                                          |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class VFC02_USRProfileWS {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public String json {get;set;}     
    private Id uid;    
    private String emailAdmin;
    public Integer testCases {get;set;} // only for test
    public boolean testIsSuccess {get;set;} // only for test
    
    private boolean isFrench {get;set;}
    private boolean isEnglish {get;set;}
    private boolean isSpanish {get;set;}
    private boolean isBrasil {get;set;}
    private boolean isChinese {get;set;}
    
    /*############################################################################
    #   G.E.T.T.E.R.S..A.N.D..S.E.T.T.E.R.S
    ##############################################################################*/ 
    public void setFrench() {
        isFrench = true;
        isEnglish = false;
        isSpanish =false;
        isBrasil =false;
        isChinese = false;
    }    
    public void setEnglish () {
        isFrench = false;
        isEnglish = true;
        isSpanish =false;
        isBrasil =false;
        isChinese = false;
    }       
    public void setSpanish() {
        isFrench = false;
        isEnglish = false;
        isBrasil = false;
        isSpanish = true;
        isChinese = false;
    }
    public void setBrasil() {
        isFrench = false;
        isEnglish = false;
        isBrasil = true;
        isSpanish = false;
        isChinese = false;
    }
    public void setChinese() {
        isFrench = false;
        isEnglish = false;
        isBrasil = false;
        isSpanish = false;
        isChinese = true;
    }
     
    public boolean getIsEnglish() { return isEnglish; }    
    public boolean getIsFrench() { return isFrench; }   
    public boolean getIsSpanish() { return isSpanish ; }
    public boolean getIsBrasil() { return isBrasil ; }
    public boolean getIsChinese() { return isChinese ; }
        
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/ 
    public VFC02_USRProfileWS() {                
        uid = UserInfo.getUserId();
        emailAdmin = Utils_UsefulMethods.emailFromUsernameEntry(ESNPolicySecurity__c.getOrgDefaults().Username__c);
        
        // handle of multiples translations        
        isFrench = false;
        isEnglish = true;
        isSpanish = false;  
        isBrasil = false; 
        
        if(UserInfo.getLanguage() == 'es')
            setSpanish();
        else if(UserInfo.getLanguage() == 'fr')
            setFrench();
        else if(UserInfo.getLanguage() == 'PT_br')
            setBrasil();
        else if(UserInfo.getLanguage() == 'zh_TW' || UserInfo.getLanguage() == 'zh_CN')
            setChinese();
        else 
            setEnglish();
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/  
    
    /*
     * Modify the User profile to the target profile retrieve by delete the "Non-Ackn" in the current profile, using webservice. 
     ***/
    public PageReference setAcknowledge() {    
        json='';      
        User endu = [SELECT Id FROM User where Id=:uid limit 1];        
        partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
        if (!ESNPolicySecurity__c.getOrgDefaults().Production__c) {
            sp.endpoint_x = 'https://test.salesforce.com/services/Soap/u/25.0';
        }
        try {   
            partnerSoapSforceCom.LoginResult loginResult;
            
            if(!Test.isRunningTest())
                loginResult = sp.login(ESNPolicySecurity__c.getOrgDefaults().Username__c, Utils_Crypto.decrypt(ESNPolicySecurity__c.getOrgDefaults().EncryptedPassword__c));        
                else
                loginResult = new partnerSoapSforceCom.LoginResult();
                        
            System.debug('### : ' + loginResult.serverUrl);            
            String urlBase='';
            if(!Test.isRunningTest()){
                urlBase = loginResult.serverUrl.substring(0, loginResult.serverUrl.indexOf('/u/'));
            }else if(Test.isRunningTest() && testCases == 1){
                urlBase = loginResult.serverUrl.substring(0, loginResult.serverUrl.indexOf('/u/'));             
            }else{
                urlBase='';
            }
            
            //Using the split method we will get Instance name.           
            if(!Test.isRunningTest() || testCases == 2){
                UpdateUserProfileWebServiceConnector.UpdateUserProfileWebService ws = new UpdateUserProfileWebServiceConnector.UpdateUserProfileWebService();           
                ws.endpoint_x =urlBase +'/class/UpdateUserProfileWebService';
                ws.SessionHeader = new UpdateUserProfileWebServiceConnector.SessionHeader_element();
                ws.SessionHeader.sessionId = loginResult.sessionId;
                String updateUserId = ws.modifyUserProfile(uid);   
            }
        } catch (Exception ex) {
            System.debug('#### Exception : ' + ex.getTypeName() + ', ' + ex.getMessage() + ', ' + ex.getCause() );
            if (ESNPolicySecurity__c.getOrgDefaults().ErrorNotificationEmail__c )
                Utils_UsefulMethods.notifyAdminException(emailAdmin, 'VFC02_USRProfileWS', 'Exception during execute the webservice.',ex);
            PageReference error = Page.VFP02_ESNPolicyError;
            error.setRedirect(true);
            testIsSuccess = false;
            return error;            
        }
        json='{result:"ok"}';                
        PageReference success = Page.VFP02_ESNPolicySuccess;
        success.setRedirect(true);
        testIsSuccess = true;
        return success ;
    }
}