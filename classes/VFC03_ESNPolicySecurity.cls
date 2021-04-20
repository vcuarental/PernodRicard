public class VFC03_ESNPolicySecurity {

    private ESNPolicySecurity__c policySettings;
    
    public String plainPwd {get;set;}
    
    public boolean pwdGeneDisabled {get; set;}
    
    public boolean aeskeyGeneDisabled {get; set;} 
    
    public boolean pwdOk {get; set;}
    
    public boolean usernamedOk {get; set;}
    
    public String checkPwd {get;set;}
    
    public String userName {get;set;}
    
    public boolean allowPwdValidation {get; set;}
    
    public VFC03_ESNPolicySecurity () {              
         pwdGeneDisabled = false;
         usernamedOk = false;
         aeskeyGeneDisabled = false;
         allowPwdValidation = false;
        //policySettings = ESNPolicySecurity__c.getOrgDefaults(); 
        List<ESNPolicySecurity__c> configs = new List<ESNPolicySecurity__c>();
        configs = [Select Id, AESKey__c,EncryptedPassword__c,Username__c From ESNPolicySecurity__c Where name = 'Profile WS' limit 1];
        if (configs.size() == 0) {
           pwdGeneDisabled = true;
           aeskeyGeneDisabled = true;
           ApexPages.addMessages(new  MissingSettingException(Label.CL00019));
           return; 
        }
        
        policySettings = configs[0]; 
        
       
        if (policySettings.AESKey__c == null) {
            ApexPages.addMessages(new MissingAESKeyException(Label.CL00015));
            pwdGeneDisabled = true;
        } else {
            pwdGeneDisabled = false;
        }
        if ((policySettings.AESKey__c != null)&&(policySettings.EncryptedPassword__c == null)) {
            ApexPages.addMessages(new MissingAESKeyException(Label.CL00016));
        }
        if (policySettings.EncryptedPassword__c!=null) {
            allowPwdValidation  = true;
        }
        if (policySettings.Username__c == null) {
            ApexPages.addMessages(new MissingUsernameException(Label.CL00024));
        } else {
            usernamedOk = true;
            userName = policySettings.Username__c;
        }  
    }

    public void encryptPassword() {
        if ((plainPwd != null) && (plainPwd.length() >= 8)) {
            policySettings.EncryptedPassword__c= Utils_Crypto.encrypt(plainPwd,policySettings.AESKey__c);                
            update policySettings;
        } else {
            ApexPages.addMessages(new PasswordFormatException(Label.CL00020));
        }
    }

    public void validatePwdEntry() {         
        pwdOk = (checkPwd== Utils_Crypto.decrypt(policySettings.EncryptedPassword__c));
        if (pwdOk) {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'The password you entered is identical with the stored password');
            ApexPages.addMessage(myMsg);
        } else {
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'The password you entered is different with the stored password');
            ApexPages.addMessage(myMsg);
        }    
    }
    
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
    
    public void enablePwdEncryption() {
        if (policySettings.AESKey__c == null) {
            pwdGeneDisabled = false;
        }
    }
    
    public void generateAESKey() {
        //todo generate a test and ask confirmation to override if a key is already present
        Blob data = Crypto.generateAesKey(256);
        policySettings.AESKey__c = EncodingUtil.base64Encode(data);
        //update policySettings;
        //saveConfig();
    }
    
    public void saveConfig() {
        if (policySettings.AESKey__c != null) {
             pwdGeneDisabled = false;
        }
        if (!validateUsernameEntry(userName)) {
            ApexPages.addMessages(new WrongUsernameException (Label.CL00026));
            return;
        }
        policySettings.Username__c = userName;
        update policySettings;
    }

    public class MissingAESKeyException extends Exception{}
    
    public class MissingEncryptedException extends Exception{}
    
    public class MismatchException extends Exception{}
    
    public class MissingSettingException extends Exception{}
    
    public class PasswordFormatException extends Exception{}
    
    public class MissingUsernameException extends Exception{}
    
    public class WrongUsernameException extends Exception{}
}