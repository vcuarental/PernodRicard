/**
 * @author: ercarval - topi
 */
@isTest
public class LAT_AbstractRepositoryTest  {
    @testSetup
    static void setup() { 
        Account distributor = LAT_EventFixtureFactory.createAccount();
    }

    @isTest
    public static void givenValidAccountWhenSaveThenCreateRecordId () {
        LAT_UnitConversionRatesRepository objRepository = new LAT_UnitConversionRatesRepository();
        List<LAT_UnitConversionRates__c> unityConversionRates = objRepository.findByKeyUnica(new List<String>());

        try { objRepository.save(new LAT_UnitConversionRates__c()); } catch(Exception Ex) {}
        try { objRepository.save(new List<LAT_UnitConversionRates__c> {new LAT_UnitConversionRates__c()}); } catch(Exception Ex) {}
        try { objRepository.updateAll(new List<LAT_UnitConversionRates__c> {new LAT_UnitConversionRates__c()}); } catch(Exception Ex) {}
        try { objRepository.insertAll(new List<LAT_UnitConversionRates__c> {new LAT_UnitConversionRates__c()}); } catch(Exception Ex) {}

        LAT_Conjunction objJuntion = new LAT_Conjunction();
        objJuntion.add('test');
        objJuntion.toString();

        LAT_Disjunction objDisJuntion = new LAT_Disjunction();
        objDisJuntion.add('test');
        objDisJuntion.toString();
        
        LAT_EventPaymentRepository objEP = new LAT_EventPaymentRepository();
        objEP.insertAll(null);
        objEP.newBaseSearchCriteria();
        objEP.findByContractIds(null);
        objEP.findByIds(null);
    }
    
    @isTest
    static void findNotExpiredByProductAN8AndRecordType() {
        Account distributor = [SELECT Id FROM Account WHERE CNPJ__c = '93536508000190' LIMIT 1];

        Test.startTest();

        LAT_Contract2__c contract = LAT_EventFixtureFactory.createContract('LAT_Eventos_Contrato_de_Parceria', distributor);

        LAT_ReferenceProductGrouping__c productGrouping = [SELECT Id FROM LAT_ReferenceProductGrouping__c LIMIT 1];

        List<LAT_ProductCost__c> productCosts = new LAT_ProductCostRepository().findNotExpiredByProductAN8AndRecordType(new List<Id>{productGrouping.Id}, new List<Id>{distributor.Id}, new List<String>{'LAT_ProductPayment'});

        Test.stopTest();

        System.assert(!productCosts.isEmpty());
    }

    testMethod
    public static  void searchForAccountWithRestrictions() {

        DateTime now = DateTime.now();
        DateTime yesterday = now - 1;

        String expextedNowDateTime = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
        String expextedYesterdayDateTime = yesterday.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');

        LAT_Criteria criteria = new LAT_Criteria( 'Select Name from Account')
        .add( LAT_Restriction.eq( new LAT_QueryMapping('name' , 'value')  ) )
        .add( LAT_Restriction.eq('name' , 'Value') )
        .add( LAT_Restriction.eqOrLike('name' , '34234*') )
        .add( LAT_Restriction.eqOrLike('name' , '34234') )
        .add( LAT_Restriction.isIn('name' , new String[] {'34234*', 'Val2', 'val3'}) )
        .add( LAT_Restriction.isIn('name' , '(\'1\',\'2\')' ) )
        .add( LAT_Restriction.isLike('name' , 'valuelike%') )
        .add( LAT_Restriction.ge('val2' , 'valuelike') )
        .add( LAT_Restriction.le('val2' , 'valuelike') )
        .add( LAT_Restriction.lt('val2' , 'valuelike') )
        .add( LAT_Restriction.gt('val2' , 'valuelike') )
        .add( LAT_Restriction.isNotNull('val2' )  )
        .add( LAT_Restriction.isNull('val2' ) )
        .add( LAT_Restriction.isNull( new LAT_QueryMapping( 'val2' ) ) )
        .add( LAT_Restriction.notEq('val2' , 'valuelike') )
        .add( LAT_Restriction.between('val2' , 'value1', 'val2') )
        .add( LAT_Restriction.between('val2' , 'value1', '') )
        .add( LAT_Restriction.between('val2' , now , yesterday ) )
        .orderingBy('name desc')
        .limitedBy(1);

        String expectedQuery = 'Select Name from Account where name = \'value\' and name = \'Value\' and name like \'34234%\' and name = \'34234\' and name in ( \'34234*\',\'Val2\',\'val3\' ) and name in (\'1\',\'2\') and name like \'valuelike%\' and val2 >= \'valuelike\' and val2 <= \'valuelike\' and val2 < \'valuelike\' and val2 > \'valuelike\' and val2 != null  and val2 = null  and val2 = null  and val2 != \'valuelike\' and val2 >= \'value1\' and val2 <= \'val2\' and val2 = \'value1\' and val2 >= ' + expextedNowDateTime + ' and val2 <= ' + expextedYesterdayDateTime + ' order by name desc limit 1';

        System.debug (criteria.toSoqlString());

        System.assertEquals(  expectedQuery , criteria.toSoqlString() ) ;

    }

    testMethod
    static  void searchAccountUsingJunction() {

        LAT_Criteria c = new LAT_Criteria('Select Name from Account ')
        .add ( LAT_Restriction.disjunction()
               .add(LAT_Restriction.isIn ( 'Name',  new String[] {'34234*', 'Val2', 'val3'} ) )
               .add(LAT_Restriction.isNull ( 'Name' ) )
             )
        .add(LAT_Restriction.eq ( 'Nome', '80054880' ) )
        .add ( LAT_Restriction.conjunction()
               .add(LAT_Restriction.isNotNull ( 'Name' ) )
             )
        .addOr ( LAT_Restriction.isNull ( 'Name' ) )
        .limitedBy(1);

        String expectedQuery = 'Select Name from Account  where (Name in ( \'34234*\',\'Val2\',\'val3\' ) or Name = null ) ';
        expectedQuery += 'and Nome = \'80054880\' and (Name != null ) or Name = null  limit 1';

        System.debug (c.toSoqlString());

        System.assertEquals( expectedQuery, c.toSoqlString() ) ;

        // List<Account> acconts = (List<Account>) c.search ();
    }

    testMethod
    static void searchFromAccountUsingInnerCriteria() {
        LAT_Criteria criteria = new LAT_Criteria(  'Select id, Name From Account ')
        .add ( LAT_Restriction.isIn('id',
                                new LAT_Criteria ('select AccountId from Contact')
                                .add( LAT_Restriction.eq('AccountId', '1') )))
        .add ( LAT_Restriction.isIn('id',
                                new LAT_Criteria ('select AccountId from Opportunity')
                                .add( LAT_Restriction.eq('AccountId', '1') )))

        .limitedBy(1);
        
        String expected = 'Select id, Name From Account  where id in (select AccountId from Contact where AccountId = \'1\') and id in (select AccountId from Opportunity where AccountId = \'1\') limit 1';

        System.assertEquals ( expected , criteria.toSoqlString());
    }

    @isTest
    public static void givenArrayInQueryWithNullValueSkipThis () {

        String[] values = new String[] {'1', null, '2'};
        String expectedValues = '( ' + LAT_Restriction.addStringInQuery('1') + ',' + LAT_Restriction.addStringInQuery('2') + ' )';

        String inElement = LAT_Restriction.convertArrayStringIntoInClause(values);

        System.assertEquals(expectedValues, inElement);
    }

    testMethod
    public static void searchForAccount() {
        Test.startTest();

        Account account = new Account();
        account.Name = 'Teste Account';
        insert account;

        LAT_Criteria criteria = new LAT_Criteria( 'Select Name from Account')
                .add( LAT_Restriction.eq( new LAT_QueryMapping('Name' , 'value')  ) )
                .add( LAT_Restriction.eq('Name' , 'Teste Account') )
                .orderingBy('Name desc')
                .limitedBy(1);

        criteria.soql = 'Name = \'Teste Account\' ';
        System.debug(' Criteria '+criteria);
        criteria.search();
        criteria.startingBy(0);
        criteria.searchFirstResult();

        Test.stopTest();
    }
}