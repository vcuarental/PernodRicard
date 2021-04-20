/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Goal            | Using for factoring code                                                           |
|     - Description     | containing methods used by many classes                                            |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 22/01/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest(seeAllData=true)
public class Utils_UsefulMethods_TEST {
    
    static testMethod void test() {
        User userTest = TestFactory.createStandardUser('testUser');
        userTest.Email = 'testUser@yopmail.com';
        insert userTest;
        
        String email = Utils_UsefulMethods.emailFromUsernameEntry(userTest.Username);
        Utils_UsefulMethods.emailFromUsernameEntry('toto');
        try{
            Integer i = 10/0;
        }catch(Exception e){            
            Utils_UsefulMethods.notifyAdminException(email, 'Test class', 'context', e);
        }
        Utils_UsefulMethods.notifyAdminMsg(email, 'Test class', 'context', 'my error message' );
    }
    
    public static testMethod void Test15_to_18_a() {
        // For the test methods, I've taken three values where I manually calculated the additional 3 chars expected
        
        String orig1 = '001A0000006Vm9r';
        System.AssertEquals(orig1+'IAC',Utils_UsefulMethods.sfdc15To18(orig1));
        
        String orig2 = '003A0000005QB3A';
        System.AssertEquals(orig2+'IAW',Utils_UsefulMethods.sfdc15To18(orig2));
        
        String orig3 = '003A0000008qb1s';
        System.AssertEquals(orig3+'IAA',Utils_UsefulMethods.sfdc15To18(orig3));
    
    }
}