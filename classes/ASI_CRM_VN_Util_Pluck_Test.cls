/***************************************************************************************************************************
 * Name:        ASI_CRM_VN_Util_Pluck_Test
 * Description: Test class for ASI_CRM_VN_Util_Pluck_
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-04-04       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

@IsTest
private class ASI_CRM_VN_Util_Pluck_Test {

    static List<Account> testData() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Foo', AnnualRevenue = 100));
        accounts.add(new Account(Name = 'Bar', AnnualRevenue = 60));
        accounts.add(new Account(Name = 'Foo', AnnualRevenue = 150));
        accounts.add(new Account(Name = 'Bar', AnnualRevenue = 150));
        return accounts;
    }
    @IsTest
    public static void testPluckDecimals() {
        List<Account> accounts = testData();
        List<Decimal> revenues = ASI_CRM_VN_Util_Pluck.decimals(accounts, Account.AnnualRevenue);
        System.assertEquals(4, revenues.size());
        System.assertEquals(100.0, revenues[0]);
        System.assertEquals(60.0, revenues[1]);
        System.assertEquals(150.0, revenues[2]);
        System.assertEquals(150.0, revenues[3]);
    }
    @IsTest
    public static void testPluckStrings() {
        List<Account> accounts = testData();
        List<String> names = ASI_CRM_VN_Util_Pluck.strings(accounts, Account.Name);
        System.assertEquals(4, names.size());
        System.assertEquals('Foo', names[0]);
        System.assertEquals('Bar', names[1]);
        System.assertEquals('Foo', names[2]);
        System.assertEquals('Bar', names[3]);
    }
}