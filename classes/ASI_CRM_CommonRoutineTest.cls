@isTest
public class ASI_CRM_CommonRoutineTest {

	@isTest
	static void testCustomException() {

		Test.startTest();
		ASI_CRM_CommonRoutine cr = new ASI_CRM_CommonRoutine();
		ASI_CRM_CommonRoutine.CustomException ce = new ASI_CRM_CommonRoutine.CustomException('Exception message');
		Test.stopTest();
		try {
			throw new ASI_CRM_CommonRoutine.CustomException('Test');
		} catch (Exception e) {
			System.assert(e.getMessage().equals('Test'));
		}
	}

	@isTest
	static void testParseException() {

		Test.startTest();
		ASI_CRM_CommonRoutine.ParseException ce = new ASI_CRM_CommonRoutine.ParseException('Exception message');
		Test.stopTest();
		try {
			throw new ASI_CRM_CommonRoutine.ParseException('Test');
		} catch (Exception e) {
			System.assert(e.getMessage().equals('Test'));
		}
	}

	@isTest
	static void testCustomWarningException() {

		Test.startTest();
		ASI_CRM_CommonRoutine.CustomWarningException ce = new ASI_CRM_CommonRoutine.CustomWarningException('Exception message');
		Test.stopTest();
		try {
			throw new ASI_CRM_CommonRoutine.CustomWarningException('Test');
		} catch (Exception e) {
			System.assert(e.getMessage().equals('Test'));
		}
	}

}