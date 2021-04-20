/*
*  A utility class to ease test data creation
*  by providing preset defaults for sObject.
*
*
*  Usage:
*
*   instantiate a desired sObject, fill non-default fields:
*
*       User newUser = new User(Phone = '123-12-13', MobilePhone = null);
*
*   call default filling method:
*
*       User tempUser = (User) TestDataFactory.createsObject(newUser,true);
*
*  tempUser.Phone = '123-12-13';
*  tempUser.Name = 'Name from defaults';
*
*/
@IsTest
public class EUR_CRM_TestDataFactory {


    /**
     * Inserts the number of sObjectType' records with preset fields-values.
     *
     *  @param sObjectType  - type of the SObject
     *  @param fieldsMap    - map of fields values
     *  @param size         - the number of records to insert
     *  @return List<SObject> list of the inserted records
     */
    public static List<SObject> doInsert(String sObjectType, Map<String, Object> fieldsMap, Integer size) {
        Type t = Type.forName(sObjectType);
        List<SObject> result = new List<SObject>();
        for (Integer i = 0; i < size; i++) {
            SObject o = (SObject) t.newInstance();
            if (fieldsMap != null && !fieldsMap.isEmpty()) {
                for (String f : fieldsMap.keySet()) {
                    if (f == 'Name' && fieldsMap.get(f) instanceof String) {
                        o.put(f, String.valueOf(fieldsMap.get(f)) + ' #' + getIndex(i));
                    } else if (f == 'LastName') {
                        o.put(f, String.valueOf(fieldsMap.get(f)) + ' #' + String.valueOf(i));
                    } else if (f == 'ExternalSAPId__c') {
                        o.put(f, String.valueOf(fieldsMap.get(f)) + ' #' + String.valueOf(i));
                    } else {
                        o.put(f, fieldsMap.get(f));
                    }
                }
            }
            result.add(o);
        }
        //System.debug(result);
        insert result;
        return result;
    }

    @Future
    public static void createUsersInFuture(Integer recordsSize) {
        EUR_CRM_TestDataFactory.createSObjectList(new User(), recordsSize, 'TestDataFactory.UserDefaults', true);
    }

    private static String getIndex(Integer i) {
        String s = String.valueOf(i);
        return '0'.repeat(4 - s.length()) + s;
    }
    /**
     * Simulates Id in proper format for the SObject Type
     *
     *  @param sobjectType     - SObject Type
     *  @return String         - spoofed id in proper format
     */
    public static String getGeneratedId(sObjectType sobjectType) {
        return getGeneratedId(String.valueOf(sobjectType));
    }
    /**
     * Simulates Id in proper format for the SObject Type
     *
     *  @param sot     - SObject Type
     *  @return String - spoofed id in proper format
     */
    public static String getGeneratedId(String sobjectType) {
        Type t = Type.forName(sobjectType);
        if (t == null) return null;
        SObject so = (SObject) t.newInstance();
        String result = String.valueOf(genRndStrFast(5));
        return so.getSObjectType().getDescribe().getKeyPrefix() +
            '0'.repeat(12-result.length()) + result;
    }
    /**
     * Simulates Id in proper format for the SObject Type
     *
     *  @param sot  - SObject Type
     *  @param s_num - number to generate at the end of the Id string
     */
    public static String getFakeId(String sobjectType, Integer s_num) {
        Type t = Type.forName(sobjectType);
        if (t == null) return null;
        SObject so = (SObject) t.newInstance();
        String result = String.valueOf(s_num++);
        return so.getSObjectType().getDescribe().getKeyPrefix() +
            '0'.repeat(12-result.length()) + result;
    }

    // static var for generating random a-zA-Z0-9 strings
    static Integer[] charset;
    // static initialization brace for random string generation
    static {
        charset = new Integer[0];
        for(Integer i = 48; i < 58; i++) charset.add(i);
        for(Integer i = 65; i < 91; i++) charset.add(i);
        for(Integer i = 97; i < 123; i++) charset.add(i);
    }

    /* A utility method for returning a randomized
    *  a-zA-Z0-9 strings of specified length
    *
    *  @param  len    - requested string length
    *  @return String - randomized string
    */
    public static String genRndStrFast(Integer len) {
        Integer[] chars = new Integer[len];
        Integer key, size = charset.size();

        for(Integer idx = 0; idx < len; idx++) {
            chars[idx] = charset[Math.mod(Math.abs(Crypto.getRandomInteger()), size)];
        }

        return String.fromCharArray(chars);
    }
    // dummy user for test user creation
    private static User dummyUser {
        get {
            if (dummyUser==null) {
                dummyUser = [select TimeZoneSidKey, LocaleSidKey,
                    EmailEncodingKey, ProfileId, LanguageLocaleKey
                from User WHERE isActive = true limit 1];
            }
            System.assertNotEquals(null, dummyUser);
            return dummyUser ;
        }
        set {
            System.assert(true);
        }
    }

    /*
    *  Low level utility method to connect sObject <=> field defaults
    *
    *   @param sObj             - sObject to replicate
    *   @param defaultClassName - string name of the object holding defaults
    *   @return SObject         - the object that was created
    */
    public static SObject createSObject(SObject sObj, String defaultClassName) {
        // Create an instance of the defaults class so we can get the Map of field defaults
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            throw new TestFactoryException('No test data defaults found');
        }
        // instantiating field defaults for this object
        FieldDefaults defaults = (FieldDefaults)t.newInstance();
        // putting defaults into the sObject deep clone
        sObject tempObj = sObj.clone(true,true,true,true);
        addFieldDefaults(tempObj, defaults.getFieldDefaults());
        System.assert(true);
        return tempObj;
    }
    /*
    *  Low level utility method to fill sObject with field defaults
    *
    *   @param sObj         - sObject to replicate
    *   @param defaults     - string name of the object holding defaults
    *   @return SObject     - the user that was created
    */
    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
        // Loop through the map of fields and if they are null on the object, fill them.
        for (String field : defaults.keySet()) {
            if (sObj.get(field) == null) {
                sObj.put(field, defaults.get(field));
            }
        }
        System.assert(true);
    }

    /*
    *  Utility method to create a new generic sObject
    *
    *   @param sObj           - sObject to replicate
    *   @return SObject       - the user that was created
    */
    public static SObject createSObject(SObject sObj) {
        // Check what type of object we are creating and add any defaults that are needed.
        String objectName = String.valueOf(sObj.getSObjectType());
        // Construct the default values class. Salesforce doesn't allow '__' in class names
        List<String> nameSegs = objectName.split('__');
        if(nameSegs.size() >= 3){
            //have namespace
            objectName = nameSegs.get(1);
            // append __c back
            objectName = objectName + nameSegs.get(2);
        } else {
            // no namespace
            objectName = nameSegs.get(0);
            if(nameSegs.size() == 2){
                // custom object
                // append __c back
                objectName = objectName + '__'+nameSegs.get(1);
            }
        }
        // replace the custom object suffix for single underscore
        // to differentiate custom obj from standard ex. Account__c and Account
        String defaultClassName = 'EUR_CRM_TestDataFactory.' + objectName.replace('__c', '_') + 'Defaults';

        // If there is a class that exists for the default values, then use them
        if (Type.forName(defaultClassName) != null) {

            sObj = createSObject(sObj, defaultClassName);

        }
        System.assert(true);
        return sObj;
    }
    /*
    *  Utility method to create a new generic sObject
    *  and insert it if required
    *
    *   @param sObj           - sObject to replicate
    *   @param doInsert       - flag indicating whether to insert the sObj
    *   @return SObject       - the object that was created
    */
    public static SObject createSObject(SObject sObj, Boolean doInsert) {
        SObject retObject = createSObject(sObj);
        if (doInsert) {
            insert retObject;
        }
        System.assertNotEquals(null, retObject);

        return retObject;
    }
    /*
    *  Utility method to create list of generic sObjects
    *
    *
    *   @param sObj                  - sObject to replicate
    *   @param numberOfObjects       - number of times to replicate
    *   @return SObject[]            - list of replicated sObjects
    */
    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects,Boolean doInsert) {
        return createSObjectList(sObj,numberOfObjects,null,doInsert);
    }
    /*
    *  Utility method to create list of generic sObjects
    *
    *
    *   @param sObj                  - sObject to replicate
    *   @param numberOfObjects       - number of times to replicate
    *   @param defaultClassName      - the string identifying the defaults implementation
    *   @return SObject[]            - list of replicated sObjects
    */
    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
        SObject[] sObjs = new SObject[] {};

        // Recreate the object the number of times requested
        for (Integer i = 0; i < numberOfObjects; i++) {
            // clone original passed in object to avoid duplicate objects in returned list
            sObject cln = sObj.clone(false,true,false,false);

            SObject newObj;
            if (defaultClassName == null) {
                newObj = createSObject(cln);
            } else {
                newObj = createSObject(cln, defaultClassName);
            }
            sObjs.add(newObj);
        }
        System.assert(true);
        return sObjs;
    }
    /*
    *  Utility method to handle insertion
    *  of a list of generic sObjects
    *
    *
    *   @param sObj                  - sObject to replicate
    *   @param numberOfObjects       - number of times to replicate
    *   @param defaultClassName      - the string identifying the defaults implementation
    *   @param doInsert              - boolean flag to indicate the need to insert replicated data
    *   @return SObject[]            - list of replicated sObjects
    */
    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
        if (doInsert) {
            insert retList;
        }
        System.assert(true);
        return retList;
    }

    /*
    *  Interface for sObj field standard values
    *
    */
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults();
    }
    /*
    *  User standard values
    *
    */
    public class UserDefaults implements FieldDefaults {
        String lastName = genRndStrFast(10);
        String email = lastName+'@hotmail.com';
        String alias = genRndStrFast(5);
        String nick = genRndStrFast(5);
        Profile standartProfile = [SELECT ID FROM Profile WHERE Name='Standard User' LIMIT 1];
        public Map<String, Object> getFieldDefaults() {

            return new Map<String, Object> {
                'FirstName' => 'TestFName',
                'LastName' => lastName,
                'Email' => email,
                'Username' => email,
                'ProfileId' => standartProfile.ID,
                'Alias' => alias,
                'CommunityNickname' => nick,
                'TimeZoneSidKey' => (String)dummyUser.get('TimeZoneSidKey'),
                'LocaleSidKey' => dummyUser.LocaleSidKey,
                'EmailEncodingKey' => dummyUser.EmailEncodingKey,
                'LanguageLocaleKey' => dummyUser.LanguageLocaleKey
            };
        }
    }
    /*
    *  Opportunity standard values
    *
    */
    public class OpportunityDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7),
                'StageName' => 'Discovery',
                'CloseDate' => System.now().date().addDays(1)
            };
        }
    }
    /*
    *  Contact standard values
    *
    */
    public class ContactDefaults implements FieldDefaults {
        String lastName = genRndStrFast(10);
        String email = lastName+'@hotmail.com';

        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'FirstName' => 'First',
                'LastName' => lastName,
                'Email' => email
            };
        }
    }
    /*
    *  Lead standard values
    *
    */
    public class LeadDefaults implements FieldDefaults {
        String lastName = genRndStrFast(10);
        String email = lastName+'@hotmail.com';
        String company = genRndStrFast(10);
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'FirstName' => 'First',
                'LastName' => lastName,
                'Email' => email,
                'Company' => company
            };
        }
    }
    /*
    *  Account standard values
    *
    */
    public class AccountDefaults implements FieldDefaults {

        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)

            };
        }
    }
    public class Change_Request_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {


            };
        }
    }
    /* Fill basic mapping for Change Requests
    *
    *
    */
    public class cr_mapping_Defaults implements FieldDefaults {

        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Mapping_object__c' => 'Account',
                'Name' => genRndStrFast(5)
            };
        }
    }
    /* Fill basic mapping for succession cloning
    *
    *
    */
    public class Account_Succession_Cloning_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(5)
            };
        }
    }
    /* Fill basic mapping for CTCPG__Activity
    *
    *
    */
    public class Activity_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'CTCPG__StartDate__c' => Date.today(),
                'CTCPG__EndDate__c' => Date.today().addDays(1)
            };
        }
    }
    /* Fill basic mapping for CTCPG__Objective
    *
    *
    */
    public class Objective_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'CTCPG__IsActive__c' => true,
                'CTCPG__Description__c' => genRndStrFast(10)
            };
        }
    }
    /* Fill basic mapping for SerialMasterFile
    *
    *
    */
    public class Serial_Master_File_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name_of_the_Meeting__c' => genRndStrFast(10),
                'Start_date__c' => Date.today(),
                'End_date__c' => Date.today().addDays(300),
                'CurrencyIsoCode' => 'EUR'
            };
        }
    }
    /* Fill basic mapping for Budget_line
    *
    *
    */
    public class Budget_line_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(10)

            };
        }
    }
    /* Fill basic mapping for Service_contract
    *
    *
    */
    public class Service_contract_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Contract_Name__c' => genRndStrFast(10)

            };
        }
    }

    /* Fill basic mapping for CNO
    *
    *
    */
    public class CNO_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(10),
                'Declaration_date__c' => Date.today()
            };
        }
    }
    /* Fill basic mapping for Materials
    *
    *
    */
    public class Materials_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(10)
            };
        }
    }
    /* Fill basic mapping for Surveys
    *
    *
    */
    public class Survey_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(10),
                'StartDate__c' => Date.today(),
                'EndDate__c' => Date.today().addDays(300)
            };
        }
    }
    /* Fill basic mapping for SurveyQuestions
    *
    *
    */
    public class SurveyQuestion_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Type__c' => 'picklist',
                'Answers__c' => genRndStrFast(10)
            };
        }
    }
    /* Fill basic mapping for custom Price Books
    *
    *
    */
    public class Price_Book_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
            };
        }
    }

    /* Fill basic mapping for Account Price Book
    *
    *
    */
    public class Account_Price_Book_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                //  'Name' => genRndStrFast(7)
            };
        }
    }

    public class CT_Product_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
                , 'ExternalSAPId__c' => genRndStrFast(7)
            };
        }
    }

    /* Fill basic mapping for Territory Model
    *
    *
    */
    public class TerritoryModel_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7),
                'StartDate__c' => Date.today(),
                'EndDate__c' => Date.today().addDays(30),
                'Status__c' => 'Active',
                'Country__c' => 'FR'
            };
        }
    }

//    /* Fill basic mapping for Territory
//  *
//  *
//  */
//    public class Territory_Defaults implements FieldDefaults {
//        public Map<String, Object> getFieldDefaults() {
//            return new Map<String, Object> {
//                'Name' => genRndStrFast(7),
//                'StartDate__c' => Date.today(),
//                'EndDate__c' => Date.today().addDays(30),
//                'Brand__c' => Territory__c.SObjectType.Brand__c.getDescribe().getPicklistValues()[0].value
//            };
//        }
//    }

    /* Fill basic mapping for Animation
    *
    *
    */
    public class Animation_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Code__c' => genRndStrFast(3)
            };
        }
    }

    /* Fill basic mapping for AccountGroup
    *
    *
    */
    public class AccountGroup_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
            };
        }
    }

    /* Fill basic mapping for ProductGroup
    *
    *
    */
    public class ProductGroup_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
            };
        }
    }

    /* Fill basic mapping for ProductCatalog
    *
    *
    */
    public class ProductCatalog_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
            };
        }
    }

    /* Fill basic mapping for AccountPriceBook
    *
    *
    */
    public class AccountPriceBook_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
            };
        }
    }

    /* Fill basic mapping for Challenges
    *
    *
    */
    public class Challenges_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
            };
        }
    }

    /* Fill basic mapping for AccountInAnimation
    *
    *
    */
    public class AccountInAnimation_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {};
        }
    }

    /* Fill basic mapping for custom Product
    *
    *
    */
    public class Product_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7),
                'ExternalSAPId__c' => genRndStrFast(40)
            };
        }
    }
    /* Fill basic mapping for SKU product level
    *
    *
    */
    public class EUR_CRM_SKU_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
                ,String.valueOf(EUR_CRM_SKU__c.EUR_CRM_External_ID__c) => genRndStrFast(40)
                ,String.valueOf(EUR_CRM_SKU__c.EUR_CRM_Active__c) => true  
            };
        }
    }
    /* Fill basic mapping for BQS product level
    *
    *
    */
    public class EUR_CRM_Size_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
                ,String.valueOf(EUR_CRM_Size__c.EUR_CRM_External_ID__c) => genRndStrFast(40)
                ,String.valueOf(EUR_CRM_Size__c.EUR_CRM_Active__c) => true  
            };
        }
    }
    /* Fill basic mapping for brand product level
    *
    *
    */
    public class EUR_CRM_Brand_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
                ,String.valueOf(EUR_CRM_Brand__c.EUR_CRM_External_ID__c) => genRndStrFast(40)
                ,String.valueOf(EUR_CRM_Brand__c.EUR_CRM_Active__c) => true
            };
        }
    }
    /* Fill basic mapping for posm product level
    *
    *
    */
    public class EUR_CRM_POS_Material_Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
                ,String.valueOf(EUR_CRM_POS_Material__c.EUR_CRM_External_ID__c) => genRndStrFast(40)
                ,String.valueOf(EUR_CRM_POS_Material__c.EUR_CRM_Active__c) => true
            };
        }
    }
    /* Fill basic mapping for custom account
    *
    *
    */
    public class EUR_CRM_Account_Defaults implements FieldDefaults {
        
        private RecordType rt {
            private get{
                if(this.rt == null){
                    this.rt = [SELECT Id FROM RecordType WHERE sObjectType = 'EUR_CRM_Account__c' AND Name = 'LT Direct - On Trade' LIMIT 1];
                }
                return this.rt;
            }
            private set;
        }
        
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => genRndStrFast(7)
                ,String.valueOf(EUR_CRM_Account__c.EUR_CRM_Postal_Code__c) => '12345'
                ,String.valueOf(EUR_CRM_Account__c.EUR_CRM_3_Most_Pop_Prod_Categories__c) => 'Vodka;Rum;Beer'
                ,String.valueOf(EUR_CRM_Account__c.RecordTypeId) => this.rt.Id
                //,String.valueOf(EUR_CRM_POS_Material__c.EUR_CRM_Active__c) => true
            };
        }
    }
    /*
    *  Exception types
    *
    */
    public class TestFactoryException extends Exception {}


}