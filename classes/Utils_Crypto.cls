public with sharing class Utils_Crypto {
    
    public static string decrypt(string encryptedString, String tmpAESKey){
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', EncodingUtil.base64Decode(tmpAESKey), EncodingUtil.base64Decode(encryptedString));
        return decryptedData.toString();
    }
    
    public static string decrypt(string encryptedString){
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', getKey(), EncodingUtil.base64Decode(encryptedString));
        return decryptedData.toString();
    }
    
    public static string encrypt(string plainString) {
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', getKey(), Blob.valueOf(plainString));
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    public static string encrypt(string plainString, String tmpAESKey) {
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', EncodingUtil.base64Decode(tmpAESKey), Blob.valueOf(plainString));
        return EncodingUtil.base64Encode(encryptedData);
    }
    
    private static Blob getKey() {
        return EncodingUtil.base64Decode(ESNPolicySecurity__c.getOrgDefaults().AESKey__c);
    }
}