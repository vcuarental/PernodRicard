@IsTest (IsParallel=true)
public with sharing class EUR_CRM_QueryBuilderTest {

    @TestSetup
    public static void init() {
        createAccount(1);
    }

    @IsTest
    public static void testFrom1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder('Account')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom2() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom3() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom4() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(new Account().getSObjectType())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom5() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder()
                .qbFrom('Account')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom6() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder()
                .qbFrom(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom7() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder()
                .qbFrom(new Account().getSObjectType())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom8() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder()
                .qbFrom(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom9() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(new List<Account>())
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testFrom10() {
        List<Account> accountsResult = (List<Account>) new EUR_CRM_QueryBuilder('Account')
                .qbField('Name')
                .toList();
        createAccount(2);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(accountsResult)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testField1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbField('Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testField2() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbField(Account.Name)
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testField3() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbField('Id, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields(new Account(Name='test'))
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields21() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields('Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields22() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields('Id, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields23() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields('Name, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields31() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields(new List<String>{'Name'})
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields32() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields(new List<String>{'Id', 'Name'})
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields33() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields(new List<String>{'Name', 'Name'})
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields4() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFields(new Set<String>{'Name'})
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields5() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFieldsAll()
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields6() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbFieldsAll('Account')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFields7() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbAllCreatableFields()
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testConditionManager() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.SimpleCondition())
                .preview()
                .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testSimpleCondition1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.SimpleCondition('Name = \'Account-1\''))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testSimpleCondition2() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.SimpleCondition())
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testNullCondition1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.NullCondition('Name').isNull())
                    .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testNullCondition12() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.NullCondition(Account.Name).isNull())
                .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testNullCondition2() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.NullCondition(Account.Name).notNull())
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareCondition1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-1'))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareCondition12() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.CompareCondition(Account.Name).eq('Account-1'))
                .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareCondition2() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.CompareCondition('Name').ne('Account-1'))
                    .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition3() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.CompareCondition('NumberOfEmployees').eq(1))
                .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition31() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.CompareCondition('NumberOfEmployees').ne(0))
                .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition32() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.CompareCondition('NumberOfEmployees').gt(0))
                .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition33() {
        System.debug([SELECT Id, NumberOfEmployees FROM Account]);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.CompareCondition('NumberOfEmployees').gte(1))
                .endCondition()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition34() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.CompareCondition('NumberOfEmployees').lt(0))
                .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareCondition35() {
        System.debug([SELECT Id, NumberOfEmployees FROM Account]);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.CompareCondition('NumberOfEmployees').lte(-1))
                .endCondition()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testLikeCondition1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.LikeCondition('Name').likeAnyBoth('ccount-'))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition12() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.LikeCondition(Account.Name).likeAnyBoth('ccount-'))
                .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition2() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.LikeCondition('Name').likeAnyLeft('ccount-1'))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition3() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.LikeCondition('Name').likeAnyRight('Account-'))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition01() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.InCondition('Id').inCollection(new Set<Id>()))
                .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testInCondition02() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.InCondition('Id').inCollection(new List<Id>()))
                .endCondition()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testInCondition1() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.InCondition('Name').inCollection(new List<String> {'Account-1'}))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition12() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.InCondition(Account.Name).inCollection(new List<String> {'Account-1'}))
                .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition2() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.InCondition('Name').inCollection(new Set<String> {'Account-1'}))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition3() {
        Set<Id> accIds = new EUR_CRM_QueryBuilder('Account').toIdSet();
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.InCondition('Id').inCollection(accIds))
                .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition31() {
        List<String> accIds = new List<Id>(new EUR_CRM_QueryBuilder('Account').toIdSet());
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(new EUR_CRM_QueryBuilder.InCondition('Id').inCollection(accIds))
                .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition0() {
        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        System.assertEquals('', complex.toString());
    }

    @IsTest
    public static void testComplexCondition1() {
        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        complex.startCondition(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(complex)
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition2() {
        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        complex.andCondition(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(complex)
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition3() {
        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        complex.orCondition(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(complex)
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition4() {
        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.NullCondition('Name').notNull())
                    .add(complex)
                    .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition5() {
        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        complex.andCondition(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.NullCondition('Name').notNull())
                    .add(complex)
                    .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition6() {
        Id accId = new EUR_CRM_QueryBuilder('Account').toSObject().Id;
        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        complex.andCondition(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-1'));
        complex.andCondition(new EUR_CRM_QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(complex)
                .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition7() {
        Id accId = new EUR_CRM_QueryBuilder('Account').toSObject().Id;
        createAccount(2);

        EUR_CRM_QueryBuilder.ComplexCondition complex = new EUR_CRM_QueryBuilder.ComplexCondition();
        complex.andCondition(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-2'));
        complex.orCondition(new EUR_CRM_QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                .add(complex)
                .endCondition()
                .toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testRecordTypeCondition() {
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.RecordTypeCondition('EUR CRM General'))
                    .endCondition()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLimit1() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .setLimit(-1)
                .toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testLimit2() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .setLimit(1)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testOrder1() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbField('Name')
                .orderAsc('Name')
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }

    @IsTest
    public static void testOrder2() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbField('Name')
                .orderDesc('Name')
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrder3() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbField('Name')
                .orderAsc('Name')
                .orderAsc('Id')
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }

    @IsTest
    public static void testOrder4() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new EUR_CRM_QueryBuilder(Account.class)
                .qbField('Name')
                .orderDesc('Name')
                .orderDesc('Id')
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testPreview() {
        new EUR_CRM_QueryBuilder(Account.class)
                .preview();
    }

    @IsTest
    public static void testPreviewCount() {
        new EUR_CRM_QueryBuilder(Account.class)
                .previewCount();
    }

    @IsTest
    public static void testToString() {
        String queryString = new EUR_CRM_QueryBuilder(Account.class)
                .toString();
        System.assertEquals('SELECT Id FROM Account', queryString);
    }

    @IsTest
    public static void testToCountString() {
        String queryString = new EUR_CRM_QueryBuilder(Account.class)
                .toCountString();
        System.debug(queryString);
        System.assertEquals('SELECT count() FROM Account', queryString);
    }

    @IsTest
    public static void testToCountString2() {
        String queryString = new EUR_CRM_QueryBuilder(Account.class)
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.CompareCondition('Name').eq('Account-1'))
                    .endCondition()
                .toCountString();
        System.debug(queryString);
        System.assertEquals('SELECT count() FROM Account WHERE Name = \'Account-1\'', queryString);
    }

    @IsTest
    public static void testResetResult() {
        EUR_CRM_QueryBuilder accountQueryBuilder = new EUR_CRM_QueryBuilder('Account');
        List<Account> accounts = (List<Account>) accountQueryBuilder
                .toList();
        System.assertEquals(1, accounts.size());

        createAccount(2);
        accounts = (List<Account>)accountQueryBuilder.toList();
        System.assertEquals(1, accounts.size());

        accountQueryBuilder.resetQuery();
        accounts = (List<Account>)accountQueryBuilder.toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testToMap1() {
        Map<Id, SObject> accounts = new EUR_CRM_QueryBuilder('Account')
                .qbField('Name')
                .toMap();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToMap2() {
        Map<Id, Account> accounts = new Map<Id, Account>();
        new EUR_CRM_QueryBuilder('Account')
                .qbField('Name')
                .toMap(accounts);
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToSobject() {
        Account account = (Account) new EUR_CRM_QueryBuilder('Account')
                .toSObject();
        System.assertNotEquals(null, account);
    }

    @IsTest
    public static void testToSobject2() {
        SObject account = (Account) new EUR_CRM_QueryBuilder('Account')
                .qbCondition()
                    .add(new EUR_CRM_QueryBuilder.NullCondition('Name').isNull())
                    .endCondition()
                .toSObject();
        System.assertEquals(null, account);
    }

    @IsTest
    public static void testToIdSet() {
        Set<Id> accountIds = new EUR_CRM_QueryBuilder('Account')
                .toIdSet();
        System.assertEquals(1, accountIds.size());
    }

    @IsTest
    public static void testExtractIds() {
        final Id ACCOUNT_ID = new EUR_CRM_QueryBuilder('Account').toSObject().Id;
        createContact(ACCOUNT_ID);
        Set<Id> extractedIds = new EUR_CRM_QueryBuilder('Contact')
                .qbField('AccountId')
                .extractIds('AccountId');
        System.assertEquals(1, extractedIds.size());
        System.assert(extractedIds.contains(ACCOUNT_ID));
    }

    @IsTest
    public static void testUpdater1() {
        EUR_CRM_QueryBuilder builder = new EUR_CRM_QueryBuilder(Account.class)
                .qbFields('Name');

        builder.qbUpdater()
                .add(new EUR_CRM_QueryBuilder.FieldUpdate('Name').set('Account-11'))
                .performUpdate();

        List<Account> accounts = (List<Account>) builder.toList();
        System.assertEquals(1, accounts.size());
        System.assertEquals('Account-11', accounts[0].Name);
    }

    @IsTest
    public static void testUpdater2() {
        EUR_CRM_QueryBuilder builder = new EUR_CRM_QueryBuilder(Account.class)
                .qbFields('Name');

        builder.qbUpdater()
                .add(new EUR_CRM_QueryBuilder.FieldUpdate(Account.Name).set('Account-11'))
                .performUpdate();

        List<Account> accounts = (List<Account>) builder.toList();
        System.assertEquals(1, accounts.size());
        System.assertEquals('Account-11', accounts[0].Name);
    }

    @IsTest
    public static void testClone1() {
        EUR_CRM_QueryBuilder qb1 = new EUR_CRM_QueryBuilder('Account');
        System.assertEquals('SELECT Id FROM Account', qb1.toString());

        EUR_CRM_QueryBuilder qb2 = qb1.cloneQueryBuilder();
        qb2.qbField('Name');

        qb1.resetQuery();
        System.assertEquals('SELECT Id FROM Account', qb1.toString());
        System.assertEquals('SELECT Name FROM Account', qb2.toString());
    }

    @IsTest
    public static void testClone2() {
        EUR_CRM_QueryBuilder qb1 = new EUR_CRM_QueryBuilder('Account');
        qb1.toList();

        EUR_CRM_QueryBuilder qb2 = qb1.cloneQueryBuilder(true);
        createAccount(2);

        System.assertEquals(qb1.toList(), qb2.toList());
    }

    private static Account createAccount (Integer i) {
        Account result = new Account();
        result.Name = 'Account-' + i;
        result.RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('EUR_CRM_General').getRecordTypeId();
        result.NumberOfEmployees = 0;
        insert result;
        return result;
    }

    private static Contact createContact (Id accId) {
        Contact result = new Contact();
        result.LastName = 'Contact-' + accId;
        result.AccountId = accId;
        result.Email = 'email' + accId + '@example.com';
        insert result;
        return result;
    }
}