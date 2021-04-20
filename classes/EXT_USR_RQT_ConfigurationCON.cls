public class EXT_USR_RQT_ConfigurationCON {

    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public EXT_USR_Config__c ExtUsrSettings;
    
    public String plainPwd {get;set;}
    
    public boolean pwdGeneDisabled {get; set;}    
    public boolean aeskeyGeneDisabled {get; set;} 
    
    public boolean pwdOk {get; set;}    
    public boolean usernamedOk {get; set;}
    
    public Integer expiryDuration {get; set;}
    public Integer expirationNotificationDelay {get; set;}
    
    public String checkPwd {get;set;}    
    public String userName {get;set;}
    public String securityToken {get;set;}
    
    public boolean allowPwdValidation {get; set;}
    public Boolean notifByEmail { get; set; }
    public Boolean isProd { get; set; }
    
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public EXT_USR_RQT_ConfigurationCON() {
        pwdGeneDisabled = false;
        usernamedOk = false;
        aeskeyGeneDisabled = false;
        allowPwdValidation = false;
        ExtUsrSettings = EXT_USR_Config__c.getOrgDefaults();
        
        isProd = ExtUsrSettings.EXT_USR_RQT_Production__c ;
        expiryDuration = (Integer)ExtUsrSettings.EXT_USR_RQT_Expiry_Duration__c ;
        expirationNotificationDelay = (Integer)ExtUsrSettings.EXT_USR_RQT_Notification_Delay__c ;
        notifByEmail = ExtUsrSettings.EXT_USR_RQT_Error_Notification_by_Email__c;
        securityToken = ExtUsrSettings.EXT_USR_RQT_Security_Token__c;
       
        if (ExtUsrSettings.EXT_USR_RQT_AES_Key__c == null) {
            ApexPages.addMessages(new MissingAESKeyException(Label.CL00015));
            pwdGeneDisabled = true;
        } else {
            pwdGeneDisabled = false;
        }
        if ((ExtUsrSettings.EXT_USR_RQT_AES_Key__c != null)&&(ExtUsrSettings.EXT_USR_RQT_Encrypted_Password__c == null)) {
            ApexPages.addMessages(new MissingAESKeyException(Label.CL00016));
        }
        if (ExtUsrSettings.EXT_USR_RQT_Encrypted_Password__c!=null) {
            allowPwdValidation  = true;
        }
        if (ExtUsrSettings.EXT_USR_RQT_Username__c == null) {
            ApexPages.addMessages(new MissingUsernameException(Label.CL00024));
        } else {
            usernamedOk = true;
            userName = ExtUsrSettings.EXT_USR_RQT_Username__c;
        }          
    }
    
    /*############################################################################
    #   M.E.T.H.O.D.S
    ##############################################################################*/  
    
    /*
     * Button : encrypt password. 
     ***/ 
    public void encryptPassword() {
        if ((plainPwd != null) && (plainPwd.length() >= 8)) {
            ExtUsrSettings.EXT_USR_RQT_Encrypted_Password__c = Utils_Crypto.encrypt(plainPwd,ExtUsrSettings.EXT_USR_RQT_AES_Key__c);        
            saveConfig();
            allowPwdValidation = false;
        } else {
            ApexPages.addMessages(new PasswordFormatException(Label.CL00020));
        }
    }

    /*
     * Button : Validate password. 
     ***/ 
    public PageReference validatePwdEntry() {         
        pwdOk = (checkPwd== Utils_Crypto.decrypt(ExtUsrSettings.EXT_USR_RQT_Encrypted_Password__c,ExtUsrSettings.EXT_USR_RQT_AES_Key__c));
        if (pwdOk) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'The password you entered is identical with the stored password');
            ApexPages.addMessage(myMsg);
        } else {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The password you entered is different with the stored password');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    

    /*
     * Validate user is active. 
     ***/ 
    public boolean validateUsernameEntry(String username) {
        //if ((userName == null) || (userName == '')) {
        //    usernamedOk == false;
        //}
        List<User> searchedUser = new List<User>();
        searchedUser = [Select Id From User Where Username = :username AND isActive= true limit 1];
        if ((searchedUser != null) && (searchedUser.size()==1)) {
            usernamedOk = true;
            return true;
        } else {
            return false;
        }
    }
    
    /*
     * Check if the AES Key is defined. 
     ***/ 
    public void enablePwdEncryption() {
        if (ExtUsrSettings.EXT_USR_RQT_AES_Key__c == null) {
            pwdGeneDisabled = false;
        }
    }
    
    /*
     * Generate the AES Key. 
     ***/ 
    public void generateAESKey() {
        //todo generate a test and ask confirmation to override if a key is already present
        Blob data = Crypto.generateAesKey(256);
        ExtUsrSettings.EXT_USR_RQT_AES_Key__c = EncodingUtil.base64Encode(data);
        
        try{
            if(ExtUsrSettings.Id == null)
                insert ExtUsrSettings;
            else
                update ExtUsrSettings;
            enablePwdEncryption();
        }catch(Exception ex){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getTypeName()+': '+ex.getMessage()+'. Cause :'+ex.getCause()+'.');
            ApexPages.addMessage(myMsg);
        }
    }
    
    /*
     * Save the config. 
     ***/ 
    public void saveConfig() {
        if (ExtUsrSettings.EXT_USR_RQT_AES_Key__c != null) {
             pwdGeneDisabled = false;
        }
        if(userName != ''){
            if (!validateUsernameEntry(userName)) {
                ApexPages.addMessages(new WrongUsernameException (Label.CL00026));
                return;
            }
            ExtUsrSettings.EXT_USR_RQT_Username__c = userName;
            ExtUsrSettings.EXT_USR_RQT_Production__c = isProd ;
            ExtUsrSettings.EXT_USR_RQT_Error_Notification_by_Email__c = notifByEmail;
            ExtUsrSettings.EXT_USR_RQT_Security_Token__c = securityToken;
            
            if(expiryDuration != null)
                ExtUsrSettings.EXT_USR_RQT_Expiry_Duration__c = (Decimal)expiryDuration;
            if(expirationNotificationDelay != null)
                ExtUsrSettings.EXT_USR_RQT_Notification_Delay__c = (Decimal)expirationNotificationDelay;
            ExtUsrSettings.EXT_USR_RQT_External_Profile_Id__c = [SELECT Id FROM Profile WHERE Name = 'Chatter External User'].get(0).Id;
        }
        try{
            update ExtUsrSettings;
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The password you entered is different with the stored password');
            ApexPages.addMessage(myMsg);
        }
    }

    public class MissingAESKeyException extends Exception{}
    
    public class MissingEncryptedException extends Exception{}
    
    public class MismatchException extends Exception{}
    
    public class MissingSettingException extends Exception{}
    
    public class PasswordFormatException extends Exception{}
    
    public class MissingUsernameException extends Exception{}
    
    public class WrongUsernameException extends Exception{}
}