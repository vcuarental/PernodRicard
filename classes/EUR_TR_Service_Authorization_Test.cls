/**
 * Created by osman on 21.10.2019.
 */

@isTest(seeAllData=FALSE)
public with sharing class EUR_TR_Service_Authorization_Test {

    /* EUR_TR_Service_Authorization other web service methods  */
    // SOAP API Class - EUR_TR_Service_Authorization
    // EUR_TR_Service_Authorization class have  one more than methods but only one method (TaskIntegration) is used  in EUR_TR_TaskTransferBatch Apex .
    // Therefore , other methods is called for test class coverage.


    // dummy test callout - done
    @isTest
    public static void GetCurrentDateTime() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        Test.startTest();
        {
            DateTime currentDatetime = authService.GetCurrentDateTime();
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void RemoveTableAndColumnCache() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        String userName = 'dummy_user_name';
        String password = 'dummy_password';
        Test.startTest();
        {
            boolean isRemoved = authService.RemoveTableAndColumnCache(userName, password);
        }
        Test.stopTest();


    }


    // dummy test callout - done
    @isTest
    public static void SetLastRunDate() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        String authorizationKey = 'Dummy_Auth';
        String methodName = 'Dummy_Method_Name';
        String branchCode = 'Dummy_Code';
        DateTime nowDateTime = Datetime.now();
        Test.startTest();
        {
            EUR_TR_Service_Authorization.Result result = authService.SetLastRunDate(authorizationKey, methodName, branchCode, nowDateTime);
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void GetCurrentDateTimeNMinutesAgo() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        Integer minutes = 30;
        Test.startTest();
        {
            DateTime currentDatetime = authService.GetCurrentDateTimeNMinutesAgo(minutes);
        }
        Test.stopTest();


    }


    // dummy test callout - done
    @isTest
    public static void GetVersionInfo() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        Test.startTest();
        {
            String versionInfo = authService.GetVersionInfo();
        }
        Test.stopTest();


    }


    // dummy test callout - done
    @isTest
    public static void GetLastRunDate() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        String authorizationKey = 'Dummy_Auth';
        String methodName = 'Dummy_Method_Name';
        String branchCode = 'Dummy_Code';
        Test.startTest();
        {
            DateTime getLastDatetime = authService.GetLastRunDate(authorizationKey, methodName, branchCode);
        }
        Test.stopTest();


    }


    // dummy test callout - done
    @isTest
    public static void RemoveErrorCache() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        String userName = 'dummy_user_name';
        String password = 'dummy_password';
        Test.startTest();
        {
            Boolean isRemoved = authService.RemoveErrorCache(userName, password);
        }
        Test.stopTest();


    }


    // dummy test callout - done
    @isTest
    public static void RemoveOracleErrorCache() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        String userName = 'dummy_user_name';
        String password = 'dummy_password';
        Test.startTest();
        {
            Boolean isRemoved = authService.RemoveOracleErrorCache(userName, password);
        }
        Test.stopTest();


    }


    // dummy test callout - done
    @isTest
    public static void GetCurrentDateTimeTwoMinutesAgo() {

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Authorization.AuthServiceSoap authService = new EUR_TR_Service_Authorization.AuthServiceSoap();
        Test.startTest();
        {
            DateTime currentDatetimeTwoMinutesAgo = authService.GetCurrentDateTimeTwoMinutesAgo();
        }
        Test.stopTest();


    }

}