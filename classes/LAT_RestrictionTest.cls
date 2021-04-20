/**
 * @author: ercarval - topi
 */
@isTest
private class LAT_RestrictionTest { //NOPMD

    @isTest
    static void itShouldBuildWhereConstrants() { //NOPMD

        DateTime now = DateTime.now();
        DateTime yesterday = now - 1;


        String expextedDateTime = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
        String expextedYesterdayDateTime = yesterday.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');


        System.assertEquals( 'Name = \'Value\'' , LAT_Restriction.eq ('Name', 'Value') );
        System.assertEquals( 'Name = true' , LAT_Restriction.eq ('Name', true) );
        System.assertEquals( 'Name = 10.0' , LAT_Restriction.eq ('Name', 10.0D) );
        System.assertEquals( 'Name = 10' , LAT_Restriction.eq ('Name', 10) );
        System.assertEquals( 'name = \'Value\'' , LAT_Restriction.eq ('Name', new LAT_QueryMapping ('name', 'Value') ) );
        System.assertEquals( 'name = \'Value\'' , LAT_Restriction.eq ( new LAT_QueryMapping ('name', 'Value') ) );

        System.assertEquals( 'name = true' , LAT_Restriction.booleanEq ( new LAT_QueryMapping ('name', 'true') ) );

        System.assertEquals( 'name != \'Value\'' , LAT_Restriction.notEq ( new LAT_QueryMapping ('name', 'Value') ) );
        System.assertEquals( 'Name != \'Value\'' , LAT_Restriction.notEq ('Name', 'Value') );
        System.assertEquals( 'Name != 10' , LAT_Restriction.notEq ('Name', 10) );

        System.assertEquals( 'name < \'10\'' , LAT_Restriction.lt ( new LAT_QueryMapping ('name', '10') ) );
        System.assertEquals( 'Name < \'10\'' , LAT_Restriction.lt ('Name', '10') );

        System.assertEquals( 'name <= \'10\'' , LAT_Restriction.le ( new LAT_QueryMapping ('name', '10') ) );
        System.assertEquals( 'Name <= \'10\'' , LAT_Restriction.le ('Name', '10') );

        System.assertEquals( 'name > \'10\'' , LAT_Restriction.gt ( new LAT_QueryMapping ('name', '10') ) );
        System.assertEquals( 'Name > \'10\'' , LAT_Restriction.gt ('Name', '10') );

        System.assertEquals( 'name >= \'10\'' , LAT_Restriction.ge ( new LAT_QueryMapping ('name', '10') ) );
        System.assertEquals( 'Name >= \'10\'' , LAT_Restriction.ge ('Name', '10') );

        System.assertEquals( 'createdDate < ' + expextedDateTime , LAT_Restriction.lt ('createdDate', now) );
        System.assertEquals( 'createdDate <= ' + expextedDateTime , LAT_Restriction.le ('createdDate', now) );
        System.assertEquals( 'createdDate > ' + expextedDateTime , LAT_Restriction.gt ('createdDate', now) );
        System.assertEquals( 'createdDate >= ' + expextedDateTime , LAT_Restriction.ge ('createdDate', now) );

        System.assertEquals( 'createdDate >= ' + expextedDateTime + ' and createdDate <= ' + expextedYesterdayDateTime
                             , LAT_Restriction.between('createdDate' , now,  yesterday ) );

        System.assertEquals( 'price >= \'9\' and price <= \'10\'' , LAT_Restriction.between('price' , '9',  '10') );

        System.assertEquals( 'name = \'Value\'' , LAT_Restriction.eqOrLike ( new LAT_QueryMapping ('name', 'Value') ) );
        System.assertEquals( 'name like \'Value%\'' , LAT_Restriction.eqOrLike ( new LAT_QueryMapping ('name', 'Value*') ) );
        System.assertEquals( 'name like \'Value%\'' , LAT_Restriction.isLike ( 'name' , new LAT_QueryMapping ('name', 'Value%') ) );

        System.debug( 'Not Null ----  |' + LAT_Restriction.isNotNull (  'name', 'null' ) + '|'  );

        System.assertEquals( 'name != null ' , LAT_Restriction.isNotNull (  'name', 'null' ) );
        System.assertEquals( 'name != null ' , LAT_Restriction.isNotNull ( 'name' ) );

        System.assertEquals( 'name = null ' , LAT_Restriction.isNull (  'name', 'null' ) );
        System.assertEquals( 'name = null ' , LAT_Restriction.isNull ( 'name' ) );

        System.assertEquals( 'name = null ' , LAT_Restriction.isNull (  'name', 'null' ) );
        System.assertEquals( 'name = null ' , LAT_Restriction.isNull ( new LAT_QueryMapping ('name', 'Value')  ) );

        System.assertEquals( 'name in ( \'34234*\',\'Val2\',\'val3\' )' , LAT_Restriction.isIn('name' , new String[] {'34234*', 'Val2', 'val3'}) );

        System.assertEquals( 'name not in ( \'34234*\',\'Val2\',\'val3\' )' , LAT_Restriction.isNotIn('name' , new String[] {'34234*', 'Val2', 'val3'}) );

        System.assertEquals( 'id in (select conta__c from Account where id = 1)' , LAT_Restriction.isInSubQuery (  'id', 'select conta__c from Account where id = 1' ) );

        System.assertEquals( ' order by conta__c' , LAT_Restriction.orderBy ('conta__c' ) );
        System.assertEquals( ' limit 1' , LAT_Restriction.addLimit ( 1 ) );


        System.assertEquals( 'id in (select conta__c from Account where id = 1)'
                             ,  LAT_Restriction.isIn('id',
                                     new LAT_Criteria ('select conta__c from Account')
                                     .add( LAT_Restriction.eq('id', 1) ) ) );

        System.assertEquals( 'id not in (select conta__c from Account where id = 1)'
                             ,  LAT_Restriction.isNotIn('id',
                                     new LAT_Criteria ('select conta__c from Account')
                                     .add( LAT_Restriction.eq('id', 1) ) ) );



        LAT_QueryListMapping objMapping = new LAT_QueryListMapping('hola');
        objMapping.setValues(new List<String> {'ttt'});
        objMapping.getValues();
    }


}