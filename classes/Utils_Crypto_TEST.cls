@isTest
private class Utils_Crypto_TEST {

    static testMethod void testEncryption() {
        Blob data = Crypto.generateAesKey(256);
        ESNPolicySecurity__c policySetting = new ESNPolicySecurity__c();
        policySetting.AESKey__c = EncodingUtil.base64Encode(data);
        policySetting.EncryptedPassword__c= Utils_Crypto.encrypt('plainPwd',policySetting.AESKey__c);
        policySetting.name='sample';
        insert policySetting;
        
        System.assertEquals(Utils_Crypto.decrypt(policySetting.EncryptedPassword__c),'plainPwd');
        System.assertEquals(Utils_Crypto.decrypt(Utils_Crypto.encrypt('plainPwd')),Utils_Crypto.decrypt(policySetting.EncryptedPassword__c));
    }
    
    
}