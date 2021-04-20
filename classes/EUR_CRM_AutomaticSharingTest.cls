@IsTest
public class EUR_CRM_AutomaticSharingTest {
    
    public static void createData() {
        List<User> users = getUsers(3);
        
        //2 is the admin
        EUR_CRM_Region__c r = new EUR_CRM_Region__c(
            Name = 'Region',
            EUR_CRM_Region_Owner__c = users[2].Id,
            OwnerId = users[2].Id,
            EUR_CRM_Channel__c = 'ON Trade & OFF Trade',
            RecordTypeId = Schema.SObjectType.EUR_CRM_Region__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Region').getRecordTypeId()
        );
        insert r;
        
        List<EUR_CRM_Territory__c> terrs = new List<EUR_CRM_Territory__c>();
        for(User u : users) {
            terrs.add(new EUR_CRM_Territory__c(
                Name = 'Territory',
                EUR_CRM_Territory_Owner__c = u.Id,
                EUR_CRM_Region__c = r.Id,
                RecordTypeId = Schema.SObjectType.EUR_CRM_Territory__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Territory').getRecordTypeId()
            ));
        }
        insert terrs;
        
        List<EUR_CRM_Account__c> accounts = new List<EUR_CRM_Account__c>();
        Integer j = 0;
        for(Integer i=0; i<5; i++) {
            
            accounts.add(new EUR_CRM_Account__c(
            	Name = 'Account ' + i,
                EUR_CRM_Business_Type__c = 'Outlet',
                EUR_CRM_Territory__c = terrs[j].Id,
                OwnerId = terrs[j].EUR_CRM_Territory_Owner__c,
                RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_On_Trade').getRecordTypeId()
        	));
            if(i==1 || i == 3) {
                j = j+1;
            }
        }
        insert accounts;
        
    }
    @isTest
    public static void testDeletetionWithExistingAlreadyShared() {
        createData();
        List<EUR_CRM_Account__c> accs = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accs.size());
        System.assertEquals(3, users.size());
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        List<EUR_CRM_Account_in_Target_Group__c> aitgs = new List<EUR_CRM_Account_in_Target_Group__c>();
        for(Integer i=0; i<accs.size(); i++) {
            aitgs.add(createAccountInTargetGroup(accs[i].Id, atg.Id));
        }
        insert aitgs;
        
        EUR_CRM_Automatic_Sharing__c a1 = createAutomaticSharing('Share Accounts', atg.id);
        EUR_CRM_Automatic_Sharing__c a2 = createAutomaticSharing('Share Accounts 2', atg.id);
        insert new List<EUR_CRM_Automatic_Sharing__c> {a1, a2};
        
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a1.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u2 = createAutomaticSharingUser(a1.id, users[1].Id, 'Read');
       	EUR_CRM_Automatic_Sharing_User__c u3 = createAutomaticSharingUser(a2.id, users[0].Id, 'Edit');
        EUR_CRM_Automatic_Sharing_User__c u4 = createAutomaticSharingUser(a2.id, users[1].Id, 'Edit');
        insert new List<EUR_CRM_Automatic_Sharing_User__c> {u1, u2, u3, u4};
            
        a1.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        a2.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        update new List<sObject> {a1, a2};
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        a1.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_DELETE;
        update a1;
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        List<EUR_CRM_AccountGroupUser__c> agus = new List<EUR_CRM_AccountGroupUser__c>();
        
        //AGU should still be there because of a2
        agus = [SELECT EUR_CRM_AccessLevel__c, EUR_CRM_Status__c FROM EUR_CRM_AccountGroupUser__c];
        System.assertEquals(accs.size()*2, agus.size());
        for(Integer i = 0; i<accs.size(); i++) {
            System.assertEquals('Edit', agus[i].EUR_CRM_AccessLevel__c);
            System.assertEquals('New', agus[i].EUR_CRM_Status__c);
        }
        
        a2.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_DELETE;
        update a2;
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        agus = [SELECT EUR_CRM_AccessLevel__c, EUR_CRM_Status__c FROM EUR_CRM_AccountGroupUser__c];
        //agus to be deleted now
        System.assertEquals(10, agus.size());
        for(Integer i = 0; i<accs.size(); i++) {
            System.assertEquals('To Delete', agus[i].EUR_CRM_Status__c);
        }
    }
    
    @isTest
    public static void testHeadOfficeRule() {
        createData();
        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accounts.size());
        System.assertEquals(3, users.size());
        
        
        //PARENT ACCOUNT
        EUR_CRM_Account__c headoffice = [SELECT Id FROM EUR_CRM_Account__c WHERE OwnerId = :users[0].Id LIMIT 1];
        headoffice.EUR_CRM_Business_Type__c = 'Head Office';
        update headoffice;
        
        //OUTLET ACCOUNT
       	EUR_CRM_Account__c outlet = [SELECT Id FROM EUR_CRM_Account__c WHERE OwnerId = :users[1].Id LIMIT 1];
        outlet.EUR_CRM_Parent_Account__c = headoffice.Id;
        update outlet;
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        List<EUR_CRM_Account_in_Target_Group__c> aitgs = new List<EUR_CRM_Account_in_Target_Group__c>();
        for(Integer i=0; i<accounts.size(); i++) {
            aitgs.add(createAccountInTargetGroup(accounts[i].Id, atg.Id));
        }
        insert aitgs;
        
        EUR_CRM_Automatic_Sharing__c a = createAutomaticSharing('Share Accounts', atg.id);
        insert a;
        
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a.id, users[0].Id, 'Edit');
        insert u1;
        
       	a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        
        update a;
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        List<EUR_CRM_AccountGroupUser__c> agus = null;
        agus = [
            SELECT Id, EUR_CRM_AccessLevel__c, EUR_CRM_Status__c, EUR_CRM_AccountGroup__r.EUR_CRM_Account__c 
            FROM EUR_CRM_AccountGroupUser__c 
            WHERE EUR_CRM_User__c = :u1.EUR_CRM_User__c 
            AND EUR_CRM_AccountGroup__r.EUR_CRM_Account__c = :outlet.Id
        ];
		System.assertEquals(1, agus.size());
        System.assertEquals('New', agus[0].EUR_CRM_Status__c);
		System.assertEquals('Edit', agus[0].EUR_CRM_AccessLevel__c);        
            
            
        a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_DELETE;
        update a;
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        //Should trigger workflow and move the related AS to waiting for batch
        //Plus u1 is owner of parent account, so it AGU should not be removed, and pass to READ
        agus = [
            SELECT Id, EUR_CRM_AccessLevel__c, EUR_CRM_Status__c, EUR_CRM_AccountGroup__r.EUR_CRM_Account__c 
            FROM EUR_CRM_AccountGroupUser__c 
            WHERE EUR_CRM_User__c = :u1.EUR_CRM_User__c 
            AND EUR_CRM_AccountGroup__r.EUR_CRM_Account__c = :outlet.id
        ];
        
		System.assertEquals(2, agus.size());
        for(Integer i = 0; i<2; i++) {
            if(agus[i].EUR_CRM_Status__c == 'To Delete') {
                //Old one is about to be removed
                System.assertEquals('Edit', agus[i].EUR_CRM_AccessLevel__c);
            } else {
                //New one will be read
                System.assertEquals('New', agus[i].EUR_CRM_Status__c);
                System.assertEquals('Read', agus[i].EUR_CRM_AccessLevel__c);
            }
            
        }  
    }
    
    
    @isTest
    public static void runSchedule() {
        createData();
        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accounts.size());
        System.assertEquals(3, users.size());
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        List<EUR_CRM_Account_in_Target_Group__c> aitgs = new List<EUR_CRM_Account_in_Target_Group__c>();
        for(Integer i=0; i<accounts.size(); i++) {
            aitgs.add(createAccountInTargetGroup(accounts[i].Id, atg.Id));
        }
        insert aitgs;
        
        EUR_CRM_Automatic_Sharing__c a = createAutomaticSharing('Share Accounts', atg.id);
        EUR_CRM_Automatic_Sharing__c a2 = createAutomaticSharing('Share Accounts 2', atg.id);
        insert new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u2 = createAutomaticSharingUser(a.id, users[1].Id, 'Edit');
        EUR_CRM_Automatic_Sharing_User__c u3 = createAutomaticSharingUser(a2.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u4 = createAutomaticSharingUser(a2.id, users[1].Id, 'Read');
        insert new List<EUR_CRM_Automatic_Sharing_User__c> {u1, u2, u3, u4};
        
       	a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        a2.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
		
        update new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        //Just for coverage, we test the real functionnality in the method 'batchTest' below
        Test.startTest();
        EUR_CRM_AutomaticSharingSchedule ass = new EUR_CRM_AutomaticSharingSchedule();
        ass.execute(null);
        
        Test.stopTest();
    }

    @isTest
    public static void runBatch() {
        createData();
        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accounts.size());
        System.assertEquals(3, users.size());
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        List<EUR_CRM_Account_in_Target_Group__c> aitgs = new List<EUR_CRM_Account_in_Target_Group__c>();
        for(Integer i=0; i<accounts.size(); i++) {
            aitgs.add(createAccountInTargetGroup(accounts[i].Id, atg.Id));
        }
        insert aitgs;
        
        EUR_CRM_Automatic_Sharing__c a = createAutomaticSharing('Share Accounts', atg.id);
        EUR_CRM_Automatic_Sharing__c a2 = createAutomaticSharing('Share Accounts 2', atg.id);
        insert new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u2 = createAutomaticSharingUser(a.id, users[1].Id, 'Edit');
        EUR_CRM_Automatic_Sharing_User__c u3 = createAutomaticSharingUser(a2.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u4 = createAutomaticSharingUser(a2.id, users[1].Id, 'Read');
        insert new List<EUR_CRM_Automatic_Sharing_User__c> {u1, u2, u3, u4};
        
       	a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        a2.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
		
        update new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        //Just for coverage, we test the real functionnality in the method 'batchTest' below
        Test.startTest();
        EUR_CRM_AutomaticSharingBatch asb = new EUR_CRM_AutomaticSharingBatch();
        Database.executeBatch(asb);
        
        Test.stopTest();
    }

     
    @isTest
    public static void validateStatusControl() {
        createData();
        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accounts.size());
        System.assertEquals(3, users.size());
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        EUR_CRM_Automatic_Sharing__c a = createAutomaticSharing('Share Accounts', atg.id);
        insert a;
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u2 = createAutomaticSharingUser(a.id, users[1].Id, 'Edit');
        insert new List<EUR_CRM_Automatic_Sharing_User__c> {u1, u2};
            
       	a.EUR_CRM_Status__c = 'Account Groups Created';
        try {
            update a;
            System.assert(false);
        } catch(Exception e) {
            
            System.assertEquals('Update failed. First exception on row 0 with id ' + a.id + '; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' + EUR_CRM_AutomaticSharing.ERROR_STATUS_SHARED + ': []', e.getMessage());
        }
        a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        update a;
        
                
    }
    
    /*
     * In this method we want to test that:
     * - account ATG is created/dated/deleted the batch is starting again
     * - the AGU are maked as deleted for the removed account
     * - the agu created
     */
    @isTest static void batchTestRemovalInATG() {
        createData();
        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accounts.size());
        System.assertEquals(3, users.size());
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        List<EUR_CRM_Account_in_Target_Group__c> aitgs = new List<EUR_CRM_Account_in_Target_Group__c>();
        for(Integer i=0; i<accounts.size(); i++) {
            aitgs.add(createAccountInTargetGroup(accounts[i].Id, atg.Id));
        }
        insert aitgs;
        
        EUR_CRM_Automatic_Sharing__c a = createAutomaticSharing('Share Accounts', atg.id);
        EUR_CRM_Automatic_Sharing__c a2 = createAutomaticSharing('Share Accounts 2', atg.id);
        insert new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u2 = createAutomaticSharingUser(a.id, users[1].Id, 'Edit');
        EUR_CRM_Automatic_Sharing_User__c u3 = createAutomaticSharingUser(a2.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u4 = createAutomaticSharingUser(a2.id, users[1].Id, 'Read');
        insert new List<EUR_CRM_Automatic_Sharing_User__c> {u1, u2, u3, u4};
        
       	a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        a2.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        update new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        delete aitgs[0];
        EUR_CRM_AutomaticSharingSchedule.runOperation();
    }
    
    @isTest static void test_PrioritizeSharingRules() {
        createData();
        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accounts.size());
        System.assertEquals(3, users.size());
        
        
        List<EUR_CRM_AccountGroup__c> ags = new List<EUR_CRM_AccountGroup__c>();
        for(EUR_CRM_Account__c a : accounts) {
            ags.add(new EUR_CRM_AccountGroup__c(EUR_CRM_Account__c = a.Id, EUR_CRM_Status__c = 'Normal'));
        }
        insert ags;
        
        EUR_CRM_AccountGroupUser__c agu1 = new EUR_CRM_AccountGroupUser__c(
        	EUR_CRM_User__c = users[0].Id,
            EUR_CRM_AccessLevel__c = 'Edit',
            EUR_CRM_Status__c = 'New',
            EUR_CRM_AccountGroup__c = ags[0].Id
        );
        EUR_CRM_AccountGroupUser__c agu2 = new EUR_CRM_AccountGroupUser__c(
        	EUR_CRM_User__c = users[0].Id,
            EUR_CRM_AccessLevel__c = 'Edit',
            EUR_CRM_Status__c = 'New',
            EUR_CRM_AccountGroup__c = ags[1].Id
        );
        insert new List<EUR_CRM_AccountGroupUser__c> {agu1, agu2};
        
        agu2.EUR_CRM_Status__c = 'Record shared';
        update agu2;
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        List<EUR_CRM_Account_in_Target_Group__c> aitgs = new List<EUR_CRM_Account_in_Target_Group__c>();
        for(Integer i=0; i<accounts.size(); i++) {
            aitgs.add(createAccountInTargetGroup(accounts[i].Id, atg.Id));
        }
        insert aitgs;
        
        EUR_CRM_Automatic_Sharing__c a = createAutomaticSharing('Share Accounts', atg.id);
        EUR_CRM_Automatic_Sharing__c a2 = createAutomaticSharing('Share Accounts 2', atg.id);
        insert new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u2 = createAutomaticSharingUser(a.id, users[1].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u3 = createAutomaticSharingUser(a2.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u4 = createAutomaticSharingUser(a2.id, users[1].Id, 'Edit');
        insert new List<EUR_CRM_Automatic_Sharing_User__c> {u1, u2, u3, u4};
        
       	a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        a2.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        update new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        List<EUR_CRM_AccountGroupUser__c> agus = [
            SELECT Id, EUR_CRM_AccessLevel__c 
            FROM EUR_CRM_AccountGroupUser__c 
            WHERE EUR_CRM_User__c = :users[1].Id
        ];
        
        System.assertEquals(5, agus.size());
        for(Integer i=0; i<agus.size(); i++) {
            System.assertEquals('Edit', agus[i].EUR_CRM_AccessLevel__c);
        }
        
        //Now check what happen if someone mark it as TO Delete
        agus[0].EUR_CRM_Status__c = 'To delete';
        update agus[0];
        
        a.EUR_CRM_Status__c = 'Waiting for batch';
        update a;
        
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
    }
    
    @isTest
    public static void batchTest() {
        createData();
        List<EUR_CRM_Account__c> accounts = [SELECT Id FROM EUR_CRM_Account__c];
        List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT OwnerId FROM EUR_CRM_Account__c)];
        System.assertEquals(5, accounts.size());
        System.assertEquals(3, users.size());
        
        EUR_CRM_Account_Target_Group__c atg = createATG('ATG');
        insert atg;
        List<EUR_CRM_Account_in_Target_Group__c> aitgs = new List<EUR_CRM_Account_in_Target_Group__c>();
        for(Integer i=0; i<accounts.size(); i++) {
            aitgs.add(createAccountInTargetGroup(accounts[i].Id, atg.Id));
        }
        insert aitgs;
        
        EUR_CRM_Automatic_Sharing__c a = createAutomaticSharing('Share Accounts', atg.id);
        EUR_CRM_Automatic_Sharing__c a2 = createAutomaticSharing('Share Accounts 2', atg.id);
        insert new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        EUR_CRM_Automatic_Sharing_User__c u1 = createAutomaticSharingUser(a.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u2 = createAutomaticSharingUser(a.id, users[1].Id, 'Edit');
        EUR_CRM_Automatic_Sharing_User__c u3 = createAutomaticSharingUser(a2.id, users[0].Id, 'Read');
        EUR_CRM_Automatic_Sharing_User__c u4 = createAutomaticSharingUser(a2.id, users[1].Id, 'Read');
        insert new List<EUR_CRM_Automatic_Sharing_User__c> {u1, u2, u3, u4};
        
       	a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        a2.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_WAITING;
        update new List<EUR_CRM_Automatic_Sharing__c> {a, a2};
        EUR_CRM_AutomaticSharingSchedule.runOperation();        
        System.debug('AITGS: ' + [SELECT Id FROM EUR_CRM_Account_in_Target_Group__c].size());
        
        delete aitgs[0];
        
        System.debug('AITGS: ' + [SELECT Id FROM EUR_CRM_Account_in_Target_Group__c].size());
        
        u1.EUR_CRM_To_Be_Deleted__c = true;
        update u1;
        
        
        
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        a.EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_DELETE;
        update a;
        
        undelete aitgs[0];
        
        EUR_CRM_AutomaticSharingSchedule.runOperation();
        
        
    }
    
    
    public static EUR_CRM_Automatic_Sharing__c createAutomaticSharing(String name, Id atgId) {
        return new EUR_CRM_Automatic_Sharing__c(
       		Name = name,
            EUR_CRM_ATG__c = atgId,
            EUR_CRM_Country_Code__c = 'KE',
            EUR_CRM_Status__c = EUR_CRM_AutomaticSharing.STATUS_DRAFT
        );
    }
    public static EUR_CRM_Automatic_Sharing_User__c createAutomaticSharingUser(Id asId, Id userId, String access) {
        return new EUR_CRM_Automatic_Sharing_User__c(
            EUR_CRM_AS__c = asId,
       		EUR_CRM_User__c = userId,
            EUR_CRM_Access_Level__c = access
        );
    }
    public static EUR_CRM_Account_Target_Group__c createATG(String name) {
        return new EUR_CRM_Account_Target_Group__c(
            Name = name,
            RecordTypeId = Schema.SObjectType.EUR_CRM_Account_Target_Group__c.getRecordTypeInfosByDeveloperName().get('EUR_KE_Account_Target_Group').getRecordTypeId()
        );
    }
    
    public static List<User> getUsers(Integer nb) {
        return [SELECT Id FROM User WHERE Profile.Name LIKE 'EUR KE%' AND IsActive = true LIMIT :nb];
    }
    public static EUR_CRM_Account_in_Target_Group__c createAccountInTargetGroup(Id accId, Id atgId) {
        return new EUR_CRM_Account_in_Target_Group__c(
        	EUR_CRM_Account__c = accId,
            EUR_CRM_Account_Target_Group__c = atgId
        );
    }
}