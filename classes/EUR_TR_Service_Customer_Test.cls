/**
 * Created by osman on 21.10.2019.
 */

@isTest(seeAllData=FALSE)
public with sharing class EUR_TR_Service_Customer_Test {

    /* EUR_TR_Service_Customer other web service methods  */
    // SOAP API Class - EUR_TR_Service_Customers
    // EUR_TR_Service_Customer class have  one more than methods but only one method (TaskIntegration) is used  in EUR_TR_TaskTransferBatch Apexs .
    // Therefore , other methods is called for test class coverage.

    // dummy test callout - done
    @isTest
    public static void getCustomersAuthorityTest(){


        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        EUR_TR_Service_Customer.ArrayOfString arrayOfString=new EUR_TR_Service_Customer.ArrayOfString();
        Test.startTest();
        {
            EUR_TR_Service_Customer.GetCustomerResult customerResult=customerService.getCustomersAuthority('Dummy',arrayOfString);
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void initializeCustomerTest(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        String customerCode='DummyCode';
        String currencyCode='TR';
        Datetime documentDate=Datetime.now();
        Datetime paymentDate=Datetime.now();
        Decimal amount=0.0;
        EUR_TR_Service_Customer.ArrayOfString arrayOfString=new EUR_TR_Service_Customer.ArrayOfString();
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result initializedCustomer =customerService.InitializeCustomer( customerCode, currencyCode,documentDate, paymentDate, Amount,authorizationKey);
        }
        Test.stopTest();



    }

    // dummy test callout - done
    @isTest
    public static void updateCustomerDiscountTest(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        EUR_TR_Service_Customer.CustomerDiscountParameter customerDiscountParameter=new EUR_TR_Service_Customer.CustomerDiscountParameter();
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result initializedCustomer =customerService.UpdateCustomerDiscount(customerDiscountParameter,authorizationKey );
        }
        Test.stopTest();

    }

    // ***

    // dummy test callout - done
    @isTest
    public static void InvalidCustomerCreditHistory(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        String customerCode='Dummy_Customer_Code';
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result result =customerService.InvalidCustomerCreditHistory(customerCode,authorizationKey );
        }
        Test.stopTest();


    }


    // dummy test callout - done
    @isTest
    public static void CustomerLocationsWithDeletedRows(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        EUR_TR_Service_Customer.CustomerDiscountParameter customerDiscountParameter=new EUR_TR_Service_Customer.CustomerDiscountParameter();
        EUR_TR_Service_Customer.CustomerSearchParameter SearchParameter=new EUR_TR_Service_Customer.CustomerSearchParameter();
        String activeCompany='Dummy_Active_Company';
        String activeBranch='Dummy_Active_Branch';
        Test.startTest();
        {
            EUR_TR_Service_Customer.ArrayOfCustomerLocationParameter arrayOfCustomerLocationParameter =customerService.CustomerLocationsWithDeletedRows(searchParameter,authorizationKey ,activeCompany,activeBranch);
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void BlockCustomer(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        String customerCode='Dummy_Code';
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result initializedCustomer =customerService.BlockCustomer(customerCode,authorizationKey );
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void UnBlockCustomer(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        String customerCode='Dummy_Code';
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result initializedCustomer =customerService.UnBlockCustomer(customerCode,authorizationKey );
        }
        Test.stopTest();



    }

    // dummy test callout - done
    @isTest
    public static void CustomerSearch(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        String searchParameter='';
        String activeCompany='Dummy_Active_Company';
        String activeBranch='Dummy_Active_Branch';
        EUR_TR_Service_Customer.CustomerSearchParameter customerSearchParameter=new EUR_TR_Service_Customer.CustomerSearchParameter();
        Test.startTest();
        {
            EUR_TR_Service_Customer.ArrayOfCustomerParameter arrayOfCustomerParameter =customerService.CustomerSearch(customerSearchParameter,authorizationKey,activeCompany, activeBranch);
        }
        Test.stopTest();


    }



    // dummy test callout - done
    @isTest
    public static void UpdateCustomerItemDiscount(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        EUR_TR_Service_Customer.CustomerDiscountParameter customerDiscountParameter=new EUR_TR_Service_Customer.CustomerDiscountParameter();
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result initializedCustomer =customerService.UpdateCustomerItemDiscount(customerDiscountParameter,authorizationKey );
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void UpdateVpCustomers(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        String branchCode='dummy_branch_code';
        String companyCode='dummy_companyCode_code';
        EUR_TR_Service_Customer.ArrayOfEInvoiceCustomer xmlCustomerList=new EUR_TR_Service_Customer.ArrayOfEInvoiceCustomer();
        EUR_TR_Service_Customer.CustomerDiscountParameter customerDiscountParameter=new EUR_TR_Service_Customer.CustomerDiscountParameter();
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result initializedCustomer =customerService.UpdateVpCustomers(authorizationKey,xmlCustomerList,branchCode ,companyCode);
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void GetCustomer(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        String code='dummy_code';
        String activeCompany='Active_Company';
        String activeBranch='Active_Branch';
        EUR_TR_Service_Customer.CustomerDiscountParameter customerDiscountParameter=new EUR_TR_Service_Customer.CustomerDiscountParameter();
        Test.startTest();
        {
            EUR_TR_Service_Customer.CustomerParameter customerParameter =customerService.GetCustomer(code,authorizationKey,activeCompany,activeBranch);
        }
        Test.stopTest();

    }

    // dummy test callout - done
    @isTest
    public static void UpdateCustomerCreditRiskLimit(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String authorizationKey='Dummy_KEY';
        EUR_TR_Service_Customer.CustomerParameter oCustomerParam=new EUR_TR_Service_Customer.CustomerParameter();
        EUR_TR_Service_Customer.CustomerDiscountParameter customerDiscountParameter=new EUR_TR_Service_Customer.CustomerDiscountParameter();
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result initializedCustomer =customerService.UpdateCustomerCreditRiskLimit(oCustomerParam,authorizationKey);
        }
        Test.stopTest();

    }

    // dummy test callout - done
    @isTest
    public static void CustomerPagedSearch(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        EUR_TR_Service_Customer.CustomerSearchParameter SearchParameter=new EUR_TR_Service_Customer.CustomerSearchParameter();
        String authorizationKey = 'Dummy_KEY';
        String activeCompany = 'Dummy_active';
        String activeBranch='Dummy_Branch';
        Integer pageIndex=1;
        Integer pageItemCount=5;
        Test.startTest();
        {
            EUR_TR_Service_Customer.PagedCustomerParameter pagedCustomerParameter = customerService.CustomerPagedSearch(SearchParameter,authorizationKey,activeCompany ,activeBranch,pageIndex,pageItemCount);
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void CustomerInsert(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        EUR_TR_Service_Customer.CustomerParameter oCustomerParameter=new EUR_TR_Service_Customer.CustomerParameter();
        String AuthorizationKey='Dummy_KEY';
        String ActiveCompany='Active_Comp';
        String ActiveBranch='Active_Branch';
        EUR_TR_Service_Customer.CustomerDiscountParameter customerDiscountParameter=new EUR_TR_Service_Customer.CustomerDiscountParameter();
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result result =customerService.CustomerInsert(oCustomerParameter,AuthorizationKey,ActiveCompany,ActiveBranch );
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void CustomerRemainderSearch(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        EUR_TR_Service_Customer.CustomerSearchParameter searchParameter=new EUR_TR_Service_Customer.CustomerSearchParameter();
        String AuthorizationKey='Dummy_KEY';
        String ActiveCompany='Active_Comp';
        String ActiveBranch='Active_Branch';
        Test.startTest();
        {
            EUR_TR_Service_Customer.ArrayOfCustomerRemainderParameter arrayOfCustomerRemainderParameter = customerService.CustomerRemainderSearch(searchParameter,authorizationKey,ActiveCompany,ActiveBranch );
        }
        Test.stopTest();


    }

    // dummy test callout - done
    @isTest
    public static void CustomerCreditHistoryInsert(){

        Test.setMock(WebServiceMock.class, new EUR_TR_MockDispatcher_Test());
        EUR_TR_Service_Customer.CustomerServiceSoap customerService = new EUR_TR_Service_Customer.CustomerServiceSoap();
        String customerCode = 'Customer_Code';
        EUR_TR_Service_Customer.CustomerCreditHistoryParameter oCustomerCreditHistoryParam = new EUR_TR_Service_Customer.CustomerCreditHistoryParameter();
        String authorizationKey= 'Dummy_KEY';
        Test.startTest();
        {
            EUR_TR_Service_Customer.Result result = customerService.CustomerCreditHistoryInsert(customerCode,oCustomerCreditHistoryParam,authorizationKey );
        }
        Test.stopTest();


    }

}