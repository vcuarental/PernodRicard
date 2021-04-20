/**
* @author fabiosuenaga - topi
*/
@isTest
private class LAT_JunctionTest {

    @isTest
    public static void testJunction(){
            JunctionMock mock = new JunctionMock();
            mock.add('OR');
            mock.add('');
            mock.toString();
            //mock.add(mock);
    }

    public class JunctionMock extends LAT_Junction {
            public JunctionMock(){
                    super('OR');
            }
    }
}