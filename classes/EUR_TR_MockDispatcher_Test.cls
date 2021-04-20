/**
 * Created by osman on 21.10.2019.
 */

@isTest(seeAllData=FALSE)
public with sharing class EUR_TR_MockDispatcher_Test implements WebServiceMock{

    public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)

    {


        /*********************   EUR_TR_Service_Customer  - SOAP API  methods  *******************************/

        // TaskIntegration(...) - used in EUR_TR_TaskTransferBatch - done
        if (request instanceof EUR_TR_Service_Customer.TaskIntegration_element) {

            EUR_TR_Service_Customer.TaskIntegrationResponse_element responseElement = new EUR_TR_Service_Customer.TaskIntegrationResponse_element();
            EUR_TR_Service_Customer.Result result = new EUR_TR_Service_Customer.Result();
            {
                result.isCompleted = TRUE;
                result.Message = 'Exception Message On Here';
                result.StackTrace = 'Trace on Here';
            }
            responseElement.TaskIntegrationResult = result;
            response.put('response_x', responseElement);

        }

        // getCustomersAuthority(...)  - dummy for coverage -done
        if (request instanceof EUR_TR_Service_Customer.getCustomersAuthority_element) {

            EUR_TR_Service_Customer.GetCustomerResult result= new EUR_TR_Service_Customer.GetCustomerResult();
            EUR_TR_Service_Customer.getCustomersAuthorityResponse_element gCustomersAuthorityResponseElement=new EUR_TR_Service_Customer.getCustomersAuthorityResponse_element();
            EUR_TR_Service_Customer.GetCustomerResult getCustomerResult = new EUR_TR_Service_Customer.GetCustomerResult();
            gCustomersAuthorityResponseElement.getCustomersAuthorityResult = getCustomerResult;
            response.put('response_x', gCustomersAuthorityResponseElement);

        }


        // InitializeCustomer(...)  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.InitializeCustomer_element) {

            EUR_TR_Service_Customer.InitializeCustomerResponse_element initializeCustomerResponseElement = new EUR_TR_Service_Customer.InitializeCustomerResponse_element();
            EUR_TR_Service_Customer.Result result=new EUR_TR_Service_Customer.Result();
            initializeCustomerResponseElement.InitializeCustomerResult = result;
            response.put('response_x', initializeCustomerResponseElement);

        }

        // UpdateCustomerDiscount(...)  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.UpdateCustomerDiscount_element) {

            EUR_TR_Service_Customer.UpdateCustomerDiscountResponse_element updateCustomerDiscountResponseElement = new EUR_TR_Service_Customer.UpdateCustomerDiscountResponse_element();
            EUR_TR_Service_Customer.Result result=new EUR_TR_Service_Customer.Result();
            updateCustomerDiscountResponseElement.UpdateCustomerDiscountResult = result;
            response.put('response_x', updateCustomerDiscountResponseElement);

        }

        // InvalidCustomerCreditHistory( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.InvalidCustomerCreditHistory_element) {

            EUR_TR_Service_Customer.InvalidCustomerCreditHistoryResponse_element invalidCustomerCreditHistoryResponseElement = new EUR_TR_Service_Customer.InvalidCustomerCreditHistoryResponse_element();
            EUR_TR_Service_Customer.Result result=new EUR_TR_Service_Customer.Result();
            invalidCustomerCreditHistoryResponseElement.InvalidCustomerCreditHistoryResult = result;
            response.put('response_x', invalidCustomerCreditHistoryResponseElement);

        }

        // CustomerLocationsWithDeletedRows( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.CustomerLocationsWithDeletedRows_element) {

            EUR_TR_Service_Customer.CustomerLocationsWithDeletedRowsResponse_element customerLocationsWithDeletedRowsResponseElement = new EUR_TR_Service_Customer.CustomerLocationsWithDeletedRowsResponse_element();
            EUR_TR_Service_Customer.ArrayOfCustomerLocationParameter customerLocationParameter=new EUR_TR_Service_Customer.ArrayOfCustomerLocationParameter();
            customerLocationsWithDeletedRowsResponseElement.CustomerLocationsWithDeletedRowsResult = customerLocationParameter;
            response.put('response_x', customerLocationsWithDeletedRowsResponseElement);

        }


        // BlockCustomer( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.BlockCustomer_element) {

            EUR_TR_Service_Customer.BlockCustomerResponse_element  blockCustomerResponseElement = new EUR_TR_Service_Customer.BlockCustomerResponse_element();
            EUR_TR_Service_Customer.Result result=new EUR_TR_Service_Customer.Result();
            blockCustomerResponseElement.BlockCustomerResult = result;
            response.put('response_x', blockCustomerResponseElement);

        }

        // UnBlockCustomer( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.UnBlockCustomer_element) {

            EUR_TR_Service_Customer.UnBlockCustomerResponse_element  unBlockCustomerResponseElement = new EUR_TR_Service_Customer.UnBlockCustomerResponse_element();
            EUR_TR_Service_Customer.Result result=new EUR_TR_Service_Customer.Result();
            unBlockCustomerResponseElement.UnBlockCustomerResult = result;
            response.put('response_x', unBlockCustomerResponseElement);

        }


        // CustomerSearch( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.CustomerSearch_element) {

            EUR_TR_Service_Customer.CustomerSearchResponse_element customerSearchResponseElement = new EUR_TR_Service_Customer.CustomerSearchResponse_element();
            EUR_TR_Service_Customer.ArrayOfCustomerParameter arrayOfCustomerParameter=new EUR_TR_Service_Customer.ArrayOfCustomerParameter();
            customerSearchResponseElement.CustomerSearchResult = arrayOfCustomerParameter;
            response.put('response_x', customerSearchResponseElement);

        }


        // UpdateCustomerItemDiscount( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.UpdateCustomerItemDiscount_element) {

            EUR_TR_Service_Customer.UpdateCustomerItemDiscountResponse_element updateCustomerItemDiscountResponseElement = new EUR_TR_Service_Customer.UpdateCustomerItemDiscountResponse_element();
            EUR_TR_Service_Customer.ArrayOfCustomerParameter arrayOfCustomerParameter = new EUR_TR_Service_Customer.ArrayOfCustomerParameter();
            EUR_TR_Service_Customer.Result result = new EUR_TR_Service_Customer.Result();
            updateCustomerItemDiscountResponseElement.UpdateCustomerItemDiscountResult = result;
            response.put('response_x', updateCustomerItemDiscountResponseElement);

        }

        // UpdateVpCustomers( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.UpdateVpCustomers_element) {

            EUR_TR_Service_Customer.UpdateVpCustomersResponse_element updateVpCustomersResponseElement = new EUR_TR_Service_Customer.UpdateVpCustomersResponse_element();
            EUR_TR_Service_Customer.Result result =new EUR_TR_Service_Customer.Result();
            updateVpCustomersResponseElement.UpdateVpCustomersResult = result;
            response.put('response_x', updateVpCustomersResponseElement);

        }


        // GetCustomer( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.GetCustomer_element ) {

            EUR_TR_Service_Customer.GetCustomerResponse_element gCustomerResponseElement = new EUR_TR_Service_Customer.GetCustomerResponse_element();
            EUR_TR_Service_Customer.CustomerParameter result=new EUR_TR_Service_Customer.CustomerParameter();
            gCustomerResponseElement.GetCustomerResult = result;
            response.put('response_x', gCustomerResponseElement);

        }


        // UpdateCustomerCreditRiskLimit( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.UpdateCustomerCreditRiskLimit_element) {

            EUR_TR_Service_Customer.UpdateCustomerCreditRiskLimitResponse_element updateCustomerCreditRiskLimitResponseElement = new EUR_TR_Service_Customer.UpdateCustomerCreditRiskLimitResponse_element();
            EUR_TR_Service_Customer.Result result=new EUR_TR_Service_Customer.Result();
            updateCustomerCreditRiskLimitResponseElement.UpdateCustomerCreditRiskLimitResult = result;
            response.put('response_x', updateCustomerCreditRiskLimitResponseElement);

        }


        // CustomerPagedSearch( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.CustomerPagedSearch_element) {

            EUR_TR_Service_Customer.CustomerPagedSearchResponse_element customerPagedSearchResponseElement = new EUR_TR_Service_Customer.CustomerPagedSearchResponse_element();
            EUR_TR_Service_Customer.PagedCustomerParameter arrayOfCustomerParameter=new EUR_TR_Service_Customer.PagedCustomerParameter();
            customerPagedSearchResponseElement.CustomerPagedSearchResult = arrayOfCustomerParameter;
            response.put('response_x', customerPagedSearchResponseElement);

        }


        // CustomerInsert( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.CustomerInsert_element) {

            EUR_TR_Service_Customer.CustomerInsertResponse_element  customerInsertResponseElement = new EUR_TR_Service_Customer.CustomerInsertResponse_element();
            EUR_TR_Service_Customer.Result customerInsertResult=new EUR_TR_Service_Customer.Result();
            customerInsertResponseElement.CustomerInsertResult = customerInsertResult;
            response.put('response_x', customerInsertResponseElement);

        }


        // CustomerRemainderSearch( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.CustomerRemainderSearch_element) {

            EUR_TR_Service_Customer.CustomerRemainderSearchResponse_element customerRemainderSearchResponseElement = new EUR_TR_Service_Customer.CustomerRemainderSearchResponse_element();
            EUR_TR_Service_Customer.ArrayOfCustomerRemainderParameter  arrayOfCustomerRemainderParameter=new EUR_TR_Service_Customer.ArrayOfCustomerRemainderParameter();
            customerRemainderSearchResponseElement.CustomerRemainderSearchResult = arrayOfCustomerRemainderParameter;
            response.put('response_x', customerRemainderSearchResponseElement);

        }


        // CustomerCreditHistoryInsert( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Customer.CustomerCreditHistoryInsert_element) {

            EUR_TR_Service_Customer.CustomerCreditHistoryInsertResponse_element  customerCreditHistoryInsertResponseElement = new EUR_TR_Service_Customer.CustomerCreditHistoryInsertResponse_element();
            EUR_TR_Service_Customer.Result result=new EUR_TR_Service_Customer.Result();
            customerCreditHistoryInsertResponseElement.CustomerCreditHistoryInsertResult = result;
            response.put('response_x', customerCreditHistoryInsertResponseElement);

        }








        /*********************   EUR_TR_Service_Authorization - SOAP API  methods  *******************************/

        // GetAuthorizationKey( ... )  -  used in EUR_TR_TaskTransferBatch - done
        if (request instanceof EUR_TR_Service_Authorization.GetAuthorizationKey_element) {

            EUR_TR_Service_Authorization.GetAuthorizationKeyResponse_element gAuthorizationKeyResponseElement = new EUR_TR_Service_Authorization.GetAuthorizationKeyResponse_element();
            gAuthorizationKeyResponseElement.GetAuthorizationKeyResult = 'DummyKeyResult';
            response.put('response_x', gAuthorizationKeyResponseElement);

        }

        // GetCurrentDateTime( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.GetCurrentDateTime_element) {

            EUR_TR_Service_Authorization.GetCurrentDateTimeResponse_element geCurrentDateTimeResponseElement = new EUR_TR_Service_Authorization.GetCurrentDateTimeResponse_element();
            geCurrentDateTimeResponseElement.GetCurrentDateTimeResult = Datetime.now();
            response.put('response_x', geCurrentDateTimeResponseElement);

        }

        // RemoveTableAndColumnCache( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.RemoveTableAndColumnCache_element) {

            EUR_TR_Service_Authorization.RemoveTableAndColumnCacheResponse_element removeTableAndColumnCacheResponseElement = new EUR_TR_Service_Authorization.RemoveTableAndColumnCacheResponse_element();
            removeTableAndColumnCacheResponseElement.RemoveTableAndColumnCacheResult = TRUE;
            response.put('response_x', removeTableAndColumnCacheResponseElement);

        }

        // SetLastRunDate( ... )  - dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.SetLastRunDate_element) {

            EUR_TR_Service_Authorization.SetLastRunDateResponse_element setLastRunDateResponseElement = new EUR_TR_Service_Authorization.SetLastRunDateResponse_element();
            EUR_TR_Service_Authorization.Result result=new EUR_TR_Service_Authorization.Result();
            setLastRunDateResponseElement.SetLastRunDateResult = result;
            response.put('response_x', setLastRunDateResponseElement);

        }


        // GetCurrentDateTimeNMinutesAgo( ... )  -  dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.GetCurrentDateTimeNMinutesAgo_element) {

            EUR_TR_Service_Authorization.GetCurrentDateTimeNMinutesAgoResponse_element gCurrentDateTimeNMinutesAgoResponseElement = new EUR_TR_Service_Authorization.GetCurrentDateTimeNMinutesAgoResponse_element();
            gCurrentDateTimeNMinutesAgoResponseElement.GetCurrentDateTimeNMinutesAgoResult = Datetime.now();
            response.put('response_x', gCurrentDateTimeNMinutesAgoResponseElement);

        }

        // GetVersionInfo( ... )  -  dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.GetVersionInfo_element) {

            EUR_TR_Service_Authorization.GetVersionInfoResponse_element gVersionInfoResponseElement = new EUR_TR_Service_Authorization.GetVersionInfoResponse_element();
            gVersionInfoResponseElement.GetVersionInfoResult = 'GetVersionInfoResult';
            response.put('response_x', gVersionInfoResponseElement);

        }

        // GetLastRunDate( ... )  -  dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.GetLastRunDate_element) {

            EUR_TR_Service_Authorization.GetLastRunDateResponse_element gLastRunDateResponseElement = new EUR_TR_Service_Authorization.GetLastRunDateResponse_element();
            gLastRunDateResponseElement.GetLastRunDateResult = Datetime.now();
            response.put('response_x', gLastRunDateResponseElement);

        }

        // RemoveErrorCache( ... )  -  dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.RemoveErrorCache_element) {

            EUR_TR_Service_Authorization.RemoveErrorCacheResponse_element removeErrorCacheResponseElement = new EUR_TR_Service_Authorization.RemoveErrorCacheResponse_element();
            removeErrorCacheResponseElement.RemoveErrorCacheResult = TRUE;
            response.put('response_x', removeErrorCacheResponseElement);

        }

        // RemoveOracleErrorCache( ... )  -  dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.RemoveOracleErrorCache_element) {

            EUR_TR_Service_Authorization.RemoveOracleErrorCacheResponse_element removeOracleErrorCacheResponseElement = new EUR_TR_Service_Authorization.RemoveOracleErrorCacheResponse_element();
            removeOracleErrorCacheResponseElement.RemoveOracleErrorCacheResult = TRUE;
            response.put('response_x', removeOracleErrorCacheResponseElement);

        }

        // GetCurrentDateTimeTwoMinutesAgo( ... )  -  dummy for coverage - done
        if (request instanceof EUR_TR_Service_Authorization.GetCurrentDateTimeTwoMinutesAgo_element) {

            EUR_TR_Service_Authorization.GetCurrentDateTimeTwoMinutesAgoResponse_element geCurrentDateTimeTwoMinutesAgoElement = new EUR_TR_Service_Authorization.GetCurrentDateTimeTwoMinutesAgoResponse_element();
            DateTime getCurrentDateTimeTwoMinutesAgoResult=Datetime.now();
            geCurrentDateTimeTwoMinutesAgoElement.GetCurrentDateTimeTwoMinutesAgoResult=getCurrentDateTimeTwoMinutesAgoResult;
            response.put('response_x', geCurrentDateTimeTwoMinutesAgoElement);

        }







    }

}