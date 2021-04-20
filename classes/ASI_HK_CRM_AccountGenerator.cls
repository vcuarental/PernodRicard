public with sharing class ASI_HK_CRM_AccountGenerator {
    public static final String DEF_VALUE_NAME = 'Test Account {0}';
    public static final String DEF_VALUE_CUST_CODE = 'HK_{0}';
    public static final String DEF_VALUE_JDE_CUST_NUM = '{0}';
    public static final String DEF_VALUE_GRADE = 'C';
    public static final String DEF_VALUE_CHANNEL = '1JS - Japanese Store';
    public static final String DEF_VALUE_LOCAL_CHANNEL = 'F12 - Japanese Store';
    public static final String RT_JDE_CREDIT = 'ASI_HK_CRM_Outlet';
    public static final String RT_CASH = 'ASI_HK_CRM_JDE_Salesman_Cash_Account';
    public static final String RT_POTENTIAL = 'ASI_HK_CRM_Potential_Account';
    public static final String RT_POTENTIAL_PRESTIGE = 'ASI_HK_CRM_Potential_Account_Prestige';
    public static final String RT_LUXURY_ACC_FIRST = 'ASI_Luxury_Account_HK_First_Contact';
    public static final String RT_LUXURY_ACC_SECOND = 'ASI_Luxury_Account_HK_Second_Contact';
    public static final String RT_LUXURY_ACC_POTENTIAL = 'ASI_Luxury_Account_HK_Potential';
    public static Set<String> RTDEVNAME_ALL { get {
            RTDEVNAME_ALL = new Set<String> {
                RT_JDE_CREDIT
                , RT_CASH
                , RT_POTENTIAL
                , RT_POTENTIAL_PRESTIGE
            }; return RTDEVNAME_ALL;
        } private set;
    }
    
    
    public static Set<String> RTDEVNAME_ACCT_HAVE_CUST_PRICE { get {
            RTDEVNAME_ACCT_HAVE_CUST_PRICE = new Set<String> {
                RT_JDE_CREDIT
            }; return RTDEVNAME_ACCT_HAVE_CUST_PRICE;
        } private set;
    }
    public static Set<String> RTDEVNAME_ACCT_IS_HK_LUX { get {
            RTDEVNAME_ACCT_IS_HK_LUX = new Set<String> {
                RT_LUXURY_ACC_FIRST ,
                RT_LUXURY_ACC_SECOND,
                RT_LUXURY_ACC_POTENTIAL  
            }; return RTDEVNAME_ACCT_IS_HK_LUX ;
        } private set;
    }
    /*
    public static Set<String> RTDEVNAME_ACCT_HAVE_CUST_PRICE_A { get {
            Set<String> RTDEVNAME_ALL_m = new Set<String> {
                RT_JDE_CREDIT
            }; return RTDEVNAME_ALL_m;
        } private set;
    }
    */
    public static Integer countAll = 1;

    private static Map<String, RecordType> RTMap {
        get {
            if (RTMap == null) {
                List<RecordType> RTList = [SELECT Id, Name, DeveloperName, IsActive, SobjectType, NamespacePrefix, BusinessProcessId FROM RecordType WHERE SobjectType = 'Account'];
                RTMap = new Map<String, RecordType>();
                for (RecordType rt : RTList) {
                    RTMap.put(rt.DeveloperName, rt);
                }
            }
            return RTMap;
        }
        set;
    }

    public static RecordType getRecordTypeByDevName(String devName) { return RTMap.get(devName); }
    
    public Account generateBasicAccount() {
        nextCount();
        return new Account(
            Name = curName()
            , ASI_HK_CRM_Grade__c = DEF_VALUE_GRADE
            , ASI_HK_CRM_Channel__c = DEF_VALUE_CHANNEL
            , ASI_HK_CRM_Local_Channel__c = DEF_VALUE_LOCAL_CHANNEL
        );
    }

    public Account generateAccount(ID rtID) {
        Account result = generateBasicAccount();
        result.RecordTypeId = rtID;
        if (rtID == getRecordTypeByDevName(RT_JDE_CREDIT).Id) {
            result.ASI_KOR_Customer_Code__c = curCode();
            result.ASI_HK_CRM_JDE_Account_Number__c = curJDENum();
        }
        return result;
    }

    public Account generateAccount(String rtDevName) {
        return generateAccount(getRecordTypeByDevName(rtDevName).Id);
    }

    public Account generateCreditDAAccount(Account acctParent) {
        Account result = generateAccount(getRecordTypeByDevName(RT_JDE_CREDIT).Id);
        result.ParentId = acctParent != null ? acctParent.Id : null;
        return result;
    }
    
    public static Integer nextCount() { return ++countAll; }
    public static String curName() { return String.format(DEF_VALUE_NAME, new String[] {String.valueOf(countAll)}); }
    public static String curCode() { return String.format(DEF_VALUE_CUST_CODE, new String[] {String.valueOf(countAll)}); }
    public static String curJDENum() { return String.format(DEF_VALUE_JDE_CUST_NUM, new String[] {String.valueOf(countAll)}); }

}