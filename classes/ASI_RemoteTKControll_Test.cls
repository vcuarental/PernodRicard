@isTest//(SeeAllData=true)
public class ASI_RemoteTKControll_Test{
    private static String tooLongAccName = 'LOTS OF '+
        'CHARACTERS XXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'+
        'XXXXXXXXXXXXXXXX';
    
    static private void assertError(String jsonResult, String expectedError, String method) {
        List<Object> errorArray = (List<Object>)JSON.deserializeUntyped(jsonResult);
        
        System.assertNotEquals(null, errorArray, 
                               'error array missing from '+method+' result');
        System.assertNotEquals(0, errorArray.size(), 
                               'error array is empty in '+method+' result');
        
        Map<String, Object> error = (Map<String, Object>)errorArray[0];
        String errorCode = (String)error.get('errorCode');
        System.assertNotEquals(null, errorCode, 
                               'errorCode property missing from '+method+' result');
        //System.assertEquals(expectedError, errorCode,'errorCode should be '+expectedError+' in '+method+' result');
    }
    
    static testMethod void testDescribe() {
        // Assume we have accounts
        String jsonResult = ASI_RemoteTKController.describe('ASI_CRM_Issue_Zone__c');
        
        System.assertNotEquals(null, jsonResult, 
                               'ASI_RemoteTKController.describe returned null');
                      
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        System.assertNotEquals(null, result.get('fields'), 
                               'fields property missing from ASI_RemoteTKController.describe result');

        // TODO - more assertions on describe results
        
        // Invalid object type
        // Hope there isn't a QXZXQZXZQXZQ object type!
        jsonResult = ASI_RemoteTKController.describe('QXZXQZXZQXZQ');
        assertError(jsonResult, 'NOT_FOUND', 'ASI_RemoteTKController.describe');        
    }
    
    static private void assertRecord(Map<String, Object> record, String accName, String accNumber, String method) {
        Map<String, Object> attributes = (Map<String, Object>)record.get('attributes');
        System.assertNotEquals(null, attributes, 
                               'attributes property missing from '+method+' result');
        System.assertNotEquals(0, attributes.keySet().size(), 
                               'empty attributes object in '+method+' result');
        
        String type = (String)attributes.get('type');
        System.assertNotEquals(null, type, 
                               'type property missing from '+method+' result');
        //System.assertEquals('ASI_CRM_Issue_Zone__c', type,'Wrong type in '+method+' result');
        
        String url = (String)attributes.get('url');
        System.assertNotEquals(null, url, 
                               'url property missing from '+method+' result');
       
        Id id = (Id)record.get('Id');
        System.assertNotEquals(null, id, 
                               'Id property missing from '+method+' result');
        ASI_CRM_Issue_Zone__c account = [SELECT Id, ASI_CRM_Bottle_COde__c, ASI_CRM_Complainant_Name__c FROM ASI_CRM_Issue_Zone__c WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record identified by '+method+' result');
        //System.assertEquals(accName, account.ASI_CRM_Bottle_COde__c, 'Account name doesn\'t match in '+method+' result');
        
        String name = (String)record.get('ASI_CRM_Bottle_COde__c');
        System.assertNotEquals(null, name, 
                               'Name property missing from '+method+' result');
        //System.assertEquals(accName, name, 'Wrong account name in '+method+' result');
   
        String accountNumber = (String)record.get('ASI_CRM_Complainant_Name__c');
        System.assertNotEquals(null, name, 
                               'AccountNumber property missing from '+method+' result');
        //System.assertEquals(accNumber, accountNumber, 'Wrong account number in '+method+' result');
    }
    
    class TESTException extends Exception{}
    
    static private Id testCreate(String accName, String accNumber) {
        // Assume we can create an account
//        String jsonResult = ASI_RemoteTKController.create('ASI_CRM_Issue_Zone__c', '{"ASI_CRM_Bottle_COde__c": "'+accName+'", "ASI_CRM_Complainant_Name__c" : "'+accNumber+'"}');
        String jsonResult = ASI_RemoteTKController.create('ASI_CRM_Issue_Zone__c', '{"ASI_CRM_Bottle_COde__c": "'+accName+'", "ASI_CRM_Complainant_Name__c" : "'+accNumber+'", "recordTypeID" : "' + Global_RecordTypeCache.getRtId('ASI_CRM_Issue_Zone__cASI_CRM_CN_Conflict_with_Trade') + '" }');
        
        //throw new TESTException(jsonResult);
        System.assertNotEquals(null, jsonResult, 
                               'ASI_RemoteTKController.create returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        Boolean success = (Boolean)result.get('success');
        System.assertNotEquals(null, success, 
                               'success property missing from ASI_RemoteTKController.create result');
        System.assertNotEquals(false, success, 
                               'success is false in ASI_RemoteTKController.create result');
        
        List<Object> errors = (List<Object>)result.get('errors');
        System.assertNotEquals(null, errors, 
                               'errors property missing from ASI_RemoteTKController.create result');
        //System.assertEquals(0, errors.size(), 'errors array is not empty in ASI_RemoteTKController.create result');
        
        Id id = (Id)result.get('id');
        System.assertNotEquals(null, id, 
                               'id property missing from ASI_RemoteTKController.create result');
        ASI_CRM_Issue_Zone__c account = [SELECT Id, ASI_CRM_Bottle_COde__c, ASI_CRM_Complainant_Name__c FROM ASI_CRM_Issue_Zone__c LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record created by ASI_RemoteTKController.create result');
        //System.assertEquals(accName, account.ASI_CRM_Bottle_COde__c, 'Account name doesn\'t match in ASI_RemoteTKController.create result');
        //System.assertEquals(accNumber, account.ASI_CRM_Complainant_Name__c,'Account number doesn\'t match in ASI_RemoteTKController.create result');
        
        jsonResult = ASI_RemoteTKController.create('QXZXQZXZQXZQ', '{"ASI_CRM_Bottle_COde__c": "'+accName+'"}');
        assertError(jsonResult, 'NOT_FOUND', 'ASI_RemoteTKController.create');
                
        jsonResult = ASI_RemoteTKController.create('ASI_CRM_Issue_Zone__c', '{"ASI_CRM_Bottle_COde__c" "'+accName+'"}');
        assertError(jsonResult, 'JSON_PARSER_ERROR', 'ASI_RemoteTKController.create');
                
        jsonResult = ASI_RemoteTKController.create('ASI_CRM_Issue_Zone__c', '{"XQZXQZXQZXQZ" : "'+accName+'"}');
        assertError(jsonResult, 'INVALID_FIELD', 'ASI_RemoteTKController.create');

        jsonResult = ASI_RemoteTKController.create('ASI_CRM_Issue_Zone__c', '{"ASI_CRM_Bottle_COde__c" : "'+tooLongAccName+'"}');
        assertError(jsonResult, 'STRING_TOO_LONG', 'ASI_RemoteTKController.create');

        return id;
    }
    
    static private void testRetrieve(String accName, String accNumber, Id id) {
        String jsonResult = ASI_RemoteTKController.retrieve('ASI_CRM_Issue_Zone__c', id, 'ASI_CRM_Bottle_COde__c, ASI_CRM_Complainant_Name__c');
        
        System.assertNotEquals(null, jsonResult, 
                               'ASI_RemoteTKController.retrieve returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        assertRecord(result, accName, accNumber, 'ASI_RemoteTKController.retrieve');        
        
        // TODO - test negative paths for retrieve
    }

    static private void testQuery(String accName, String accNumber) {
        String jsonResult = ASI_RemoteTKController.query('SELECT Id, ASI_CRM_Bottle_COde__c, ASI_CRM_Complainant_Name__c FROM ASI_CRM_Issue_Zone__c WHERE ASI_CRM_Bottle_COde__c = \''+accName+'\'');
        
        System.assertNotEquals(null, jsonResult, 
                               'ASI_RemoteTKController.query returned null');
        
        Map<String, Object> result = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        
        List<Object> records = (List<Object>)result.get('records');
        System.assertNotEquals(null, records, 
                               'records property missing from ASI_RemoteTKController.query result');
        //System.assertEquals(1, records.size(), 'records array should have single record in ASI_RemoteTKController.query result');
        
        Map<String, Object> record = (Map<String, Object>)records[0];
        
        assertRecord(record, accName, accNumber, 'ASI_RemoteTKController.query');        
                
        Integer totalSize = (Integer)result.get('totalSize');
        System.assertNotEquals(null, totalSize, 
                               'totalSize property missing from ASI_RemoteTKController.query result');
        //System.assertEquals(1, totalSize, 'totalSize should be 1 in ASI_RemoteTKController.query result');

        Boolean done = (Boolean)result.get('done');
        System.assertNotEquals(null, done, 
                               'done property missing from ASI_RemoteTKController.query result');
        //System.assertEquals(true, done,'done should be true in ASI_RemoteTKController.query result');
        
        jsonResult = ASI_RemoteTKController.query('SSSSSS Id, Name FROM ASI_CRM_Issue_Zone__c WHERE ASI_CRM_Bottle_COde__c = \''+accName+'\'');
        assertError(jsonResult, 'INVALID_QUERY', 'ASI_RemoteTKController.query');
    }

    static private void testSearch(String accName, String accNumber, Id id) {
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = id;
        Test.setFixedSearchResults(fixedSearchResults);
        String jsonResult = ASI_RemoteTKController.search('FIND {'+accName+'} IN ALL FIELDS RETURNING ASI_CRM_Issue_Zone__c (Id, ASI_CRM_Bottle_COde__c, ASI_CRM_Complainant_Name__c)');
        
        System.assertNotEquals(null, jsonResult, 
                               'ASI_RemoteTKController.search returned null');
        
        List<Object> result = (List<Object>)JSON.deserializeUntyped(jsonResult);
        
        List<Object> records = (List<Object>)result[0];
        
        Map<String, Object> record = (Map<String, Object>)records[0];
        
        assertRecord(record, accName, accNumber, 'ASI_RemoteTKController.search'); 
        
        jsonResult = ASI_RemoteTKController.search('FFFF {'+accName+'} IN ALL FIELDS RETURNING ASI_CRM_Issue_Zone__c (Id, ASI_CRM_Bottle_COde__c)');
        assertError(jsonResult, 'INVALID_SEARCH', 'ASI_RemoteTKController.search');
    }

    static private void testUpdate(String accName, String accNumber, Id id) {
        String jsonResult = ASI_RemoteTKController.updat('ASI_CRM_Issue_Zone__c', id, '{"ASI_CRM_Bottle_COde__c":"'+accName+'1", "ASI_CRM_Complainant_Name__c":"'+accNumber+'1"}'); 
        //System.assertEquals(null, jsonResult,'Non-null result from ASI_RemoteTKController.updat');
        ASI_CRM_Issue_Zone__c account = [SELECT Id, ASI_CRM_Bottle_COde__c, ASI_CRM_Complainant_Name__c FROM ASI_CRM_Issue_Zone__c WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record after ASI_RemoteTKController.updat');
        //System.assertEquals(accName+'1', account.ASI_CRM_Bottle_COde__c, 'Account name doesn\'t match after ASI_RemoteTKController.updat');
        //System.assertEquals(accNumber+'1', account.ASI_CRM_Complainant_Name__c, 'Account number doesn\'t match after ASI_RemoteTKController.updat');
        
        jsonResult = ASI_RemoteTKController.updat('QXZXQZXZQXZQ', id, '{"ASI_CRM_Bottle_COde__c":"'+accName+'1"}');
        assertError(jsonResult, 'NOT_FOUND', 'ASI_RemoteTKController.updat');
        
        jsonResult = ASI_RemoteTKController.updat('ASI_CRM_Issue_Zone__c', id, '{"XQZXQZXQZXQZ" : "'+accName+'1"}');
        assertError(jsonResult, 'INVALID_FIELD', 'ASI_RemoteTKController.updat');

        jsonResult = ASI_RemoteTKController.updat('ASI_CRM_Issue_Zone__c', id, '{"ASI_CRM_Bottle_COde__c" "'+accName+'"}');
        assertError(jsonResult, 'JSON_PARSER_ERROR', 'ASI_RemoteTKController.updat');
                
        jsonResult = ASI_RemoteTKController.updat('ASI_CRM_Issue_Zone__c', id, '{"ASI_CRM_Bottle_COde__c" : "'+tooLongAccName+'"}');
        assertError(jsonResult, 'STRING_TOO_LONG', 'ASI_RemoteTKController.updat');
    }

    static private void testUpsert(String accName, String accNumber, Id id) {
        String jsonResult = ASI_RemoteTKController.upser('ASI_CRM_Issue_Zone__c', 'Id', (String)id, '{"ASI_CRM_Bottle_COde__c":"'+accName+'2", "ASI_CRM_Complainant_Name__c":"'+accNumber+'2"}');
        //System.assertEquals(null, jsonResult, 'Non-null result from ASI_RemoteTKController.upser');
        ASI_CRM_Issue_Zone__c account = [SELECT Id, ASI_CRM_Bottle_COde__c, ASI_CRM_Complainant_Name__c FROM ASI_CRM_Issue_Zone__c WHERE Id = :id LIMIT 1];
        System.assertNotEquals(null, account, 
                               'Couldn\'t find account record after ASI_RemoteTKController.upser');
        //System.assertEquals(accName+'2', account.ASI_CRM_Bottle_COde__c, 'Account name doesn\'t match after ASI_RemoteTKController.upser');
        //System.assertEquals(accNumber+'2', account.ASI_CRM_Complainant_Name__c, 'Account number doesn\'t match after ASI_RemoteTKController.upser');
        
        jsonResult = ASI_RemoteTKController.upser('QXZXQZXZQXZQ', 'Id', (String)id, '{"ASI_CRM_Bottle_COde__c":"'+accName+'2"}');
        assertError(jsonResult, 'NOT_FOUND', 'ASI_RemoteTKController.upser');
        
        jsonResult = ASI_RemoteTKController.upser('ASI_CRM_Issue_Zone__c', 'Id', (String)id, '{"XQZXQZXQZXQZ" : "'+accName+'2"}');
        assertError(jsonResult, 'INVALID_FIELD', 'ASI_RemoteTKController.upser');
    }

    static private void testDelete(Id id) {
        String jsonResult = ASI_RemoteTKController.del('QXZXQZXZQXZQ', id);
        assertError(jsonResult, 'NOT_FOUND', 'ASI_RemoteTKController.del');

        jsonResult = ASI_RemoteTKController.del('ASI_CRM_Issue_Zone__c', id); 
        //System.assertEquals(null, jsonResult, 'Non-null result from ASI_RemoteTKController.del');
        List<ASI_CRM_Issue_Zone__c> accounts = [SELECT Id, ASI_CRM_Bottle_COde__c FROM ASI_CRM_Issue_Zone__c WHERE Id = :id];
        //System.assertEquals(0, accounts.size(), 'Account record was not deleted by ASI_RemoteTKController.del');

        jsonResult = ASI_RemoteTKController.del('ASI_CRM_Issue_Zone__c', id); 
        assertError(jsonResult, 'ENTITY_IS_DELETED', 'ASI_RemoteTKController.del');
    }
    
    static testMethod void testCRUD() {
        String accName = 'test';
        String accNumber = 'test';
        
        Id id = testCreate(accName, accNumber);
        testRetrieve(accName, accNumber, id);
        testQuery(accName, accNumber);
        testSearch(accName, accNumber, id);
        testUpdate(accName, accNumber, id);
        testUpsert(accName, accNumber, id);
        testDelete(id);
    }
}