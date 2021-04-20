/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | ESN Policy			                                                             |
|     - Description     | Test class of VFC02_USRProfileWS            										 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 25/07/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         | 							                                                         |
+-----------------------+------------------------------------------------------------------------------------+
*/
@isTest(seeAllData=true)
private class VFC02_USRProfileWS_TEST {
    
    /* Test 1 : User CN */
    static testMethod void test_CN() {
    	User userTest = TestFactory.createStandardUser('test1');
    	userTest.LanguageLocaleKey = 'zh_CN';
        insert userTest;
        
        System.runAs(userTest){
	        VFC02_USRProfileWS c = new VFC02_USRProfileWS();
			c.testCases = 2;
	        c.setAcknowledge();
	        System.assert( c.testIsSuccess == true);
	        System.assert( c.getIsChinese() == true);
        }
    }
    
    /* Test 2 : Exception */
    static testMethod void test_ackn1() {
    	User userTest = TestFactory.createStandardUser('test1');
    	userTest.LanguageLocaleKey = 'fr';
        insert userTest;
        
        System.runAs(userTest){
	         VFC02_USRProfileWS c = new VFC02_USRProfileWS();
	         // test 1 : Exception
			 c.testCases = 1;
	         c.setAcknowledge();
	         System.assert( c.testIsSuccess == false);
        }
    }
    
    /* Test 3 : User EN */
    static testMethod void test_ackn3() {
         VFC02_USRProfileWS c = new VFC02_USRProfileWS();
         // test 3 : Success
		   c.testCases = 2;
         c.setAcknowledge();
         System.assert( c.testIsSuccess == true);
        System.assert( c.getIsEnglish() == true);
    }
    
    /* Test 4 : User FR */
    static testMethod void test_fr() {
    	User userTest = TestFactory.createStandardUser('test1');
    	userTest.LanguageLocaleKey = 'fr';
        insert userTest;
        
        System.runAs(userTest){
	        VFC02_USRProfileWS c = new VFC02_USRProfileWS();
			c.testCases = 2;
	        c.setAcknowledge();
	        System.assert( c.testIsSuccess == true);
	        System.assert( c.getIsFrench() == true);
        }
    }
    
    /* Test 5 : User ES */
    static testMethod void test_es() {
    	User userTest = TestFactory.createStandardUser('test1');
    	userTest.LanguageLocaleKey = 'es';
        insert userTest;
        
        System.runAs(userTest){
	        VFC02_USRProfileWS c = new VFC02_USRProfileWS();
			c.testCases = 2;
	        c.setAcknowledge();
	        System.assert( c.testIsSuccess == true);
	        System.assert( c.getIsSpanish() == true);
        }
    }
    
    /* Test 6 : User PT_br */
    static testMethod void test_PT_br() {
    	User userTest = TestFactory.createStandardUser('test1');
    	userTest.LanguageLocaleKey = 'PT_br';
        insert userTest;
        
        System.runAs(userTest){
	        VFC02_USRProfileWS c = new VFC02_USRProfileWS();
			c.testCases = 2;
	        c.setAcknowledge();
	        System.assert( c.testIsSuccess == true);
	        System.assert( c.getIsBrasil() == true);
        }
    }
}