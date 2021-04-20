@IsTest
public class EUR_CRM_StubListTest {

	public String get(Integer index) {
		return 'fred';
	}

	public Boolean isEmpty() {
		return true;
	}

	public String get2(Integer index, String value) {
		return 'mary';
	}

	public String get3(Object index, Object value) {
		return 'mary';
	}

}