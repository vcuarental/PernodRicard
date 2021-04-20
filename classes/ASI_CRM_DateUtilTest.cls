@isTest
public class ASI_CRM_DateUtilTest {

	@isTest
	static void testParseDate() {
		Date d = ASI_CRM_DateUtil.parseDate('20151010', ASI_CRM_DateUtil.DATE_FORMAT_YYYYMMDD);

		System.assertEquals(d.day(), 10);
		System.assertEquals(d.month(), 10);
		System.assertEquals(d.year(), 2015);

		System.assertEquals(null, ASI_CRM_DateUtil.parseDate('20151010', null));

		try {
			ASI_CRM_DateUtil.parseDate('invalid date', ASI_CRM_DateUtil.DATE_FORMAT_YYYYMMDD);
		} catch (Exception e) {
			System.assert(e.getTypeName().contains('DateParseException'));
		}
	}

}