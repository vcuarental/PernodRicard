@RestResource(UrlMapping='/EUR_TR_Middleware/*')
global with sharing class EUR_TR_MiddlewareController {
    public class customException extends Exception {
    }
    public static String SuccessMessage = 'İşlem başarıyla sona erdi.';

    global class PicklistResponseItem {
        public PicklistResponseItem(string key, string value) {
            this.Key = key;
            this.Value = value;
        }

        public string Key { get; set; }
        public string Value { get; set; }
    }

    global class PicklistRequest {
        public string Name { get; set; }
    }

    global virtual class ServiceResponse {
        public Integer Code { get; set; }
        public String Message { get; set; }
    }

    global class DmlDetail {
        public Integer DmlIndex { get; set; }
        public String DmlId { get; set; }
        public String DmlMessage { get; set; }
        public List<String> DmlFields { get; set; }
    }

    global class PostServiceResponse extends ServiceResponse {
        public List<SObject> Data { get; set; }
        public Object ExtensionData { get; set; }
        public List<PicklistResponseItem> Picklist { get; set; }
        public List<DmlDetail> DmlDetails { get; set; }
        public List<AccountParameter> AccountParameters { get; set; }
    }

    global class SMSRequest {
        public String Code { get; set; }
        public String PhoneNumber { get; set; }
    }

    global class AccountRequest {
        public List<AccountRequestParam> params { get; set; }
    }

    global class AccountRequestParam {
        public String key { get; set; }
        public String value { get; set; }
    }

    global class AccountParameter {
        public String name { get; set; }
        public List<AccountParameterDetail> values { get; set; }
    }

    global class AccountParameterDetail {
        public String key { get; set; }
        public String value { get; set; }
        public List<AccountParameterDetail> values { get; set; }
    }

    @HttpGet
    global static void getServiceExposed() {
        ServiceResponse response = new ServiceResponse();
        response.Code = -1;
        response.Message = 'Bu servis yalnızca POST yöntemi ile çağrılabilir.';
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response));
    }

    @HttpPost
    global static void postServiceExposed() {
        PostServiceResponse response = new PostServiceResponse();
        RestRequest request = RestContext.request;
        String methodName = request.params.get('MethodName');
        if (String.isBlank(methodName)) {
            response.Code = -1;
            response.Message = 'MethodName parametresi boş olamaz.';
        } else {
            try {
                response = processRequest(methodName, request.requestBody.toString());
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
            }
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(response, false));
    }

    global static PostServiceResponse processRequest(String methodName, String requestBody) {
        System.debug('methodName:' + methodName);
        System.debug('requestBody: ' + requestBody);
        /*if (methodName == 'listAccountsByLocation') {
            return listAccountsByLocation(requestBody);
        } */if (methodName == 'listContactsByRelatedAccount') {
            return listContactsByRelatedAccount(requestBody);
        } else if (methodName == 'addContactToRelatedAccount') {
            return addContactToRelatedAccount(requestBody);
        } else if (methodName == 'editContactById') {
            return editContactById(requestBody);
        } else if (methodName == 'getAccountById') {
            return getAccountById(requestBody);
        } else if (methodName == 'listRemPeopleByRelatedAccountId') {
            return listRemPeopleByRelatedAccountId(requestBody);
        } else if (methodName == 'addNoteByAccount') {
            return addNoteByAccount(requestBody);
        } else if (methodName == 'listAccountNotes') {
            return listAccountNotes(requestBody);
        } else if (methodName == 'removeNote') {
            return removeNote(requestBody);
        } else if (methodName == 'editNoteById') {
            return editNoteById(requestBody);
        } else if (methodName == 'listSettings') {
            return listSettings(requestBody);
        } else if (methodName == 'editSettings') {
            return editSettings(requestBody);
        } else if (methodName == 'listPicklistByName') {
            return listPicklistByName(requestBody);
        } else if (methodName == 'startVisitByAccount') {
            return startVisitByAccount(requestBody);
        } else if (methodName == 'endVisitById') {
            return endVisitById(requestBody);
        } else if (methodName == 'sendSMSByPhoneNumberByCode') {
            return sendSMSByPhoneNumberByCode(requestBody);
        } else if (methodName == 'listVisitsByAccountId') {
            return listVisitsByAccountId(requestBody);
        } else if (methodName == 'listDebtAgingByAccountId') {
            return listDebtAgingByAccountId(requestBody);
        } else if (methodName == 'listAgreementByAccountId') {
            return listAgreementByAccountId(requestBody);
        } else if (methodName == 'listBountyRealizationByAccountId') {
            return listBountyRealizationByAccountId(requestBody);
        } else if (methodName == 'listRepVisitByAccountId') {
            return listRepVisitByAccountId(requestBody);
        } else if (methodName == 'listRangeByAccountId') {
            return listRangeByAccountId(requestBody);
        } else if (methodName == 'listInvoiceSummaryByAccountId') {
            return listInvoiceSummaryByAccountId(requestBody);
        } else if (methodName == 'listTargetRealizationByEmployeeId') {
            return listTargetRealizationByEmployeeId(requestBody);
        } else if (methodName == 'listSalesTrendByAccountId') {
            return listSalesTrendByAccountId(requestBody);
        } else if (methodName == 'listMATReportByAccountId') {
            return listMATReportByAccountId(requestBody);
        } /*else if (methodName == 'listAccountsByParameters') {
            return listAccountsByParameters(requestBody);
        }*/ else if (methodName == 'listFilterParameters') {
            return listFilterParameters(requestBody);
        } else if (methodName == 'listSurveysByAccountId') {
            return EUR_TR_Survey.listSurveysByAccountId(requestBody);
        } else if (methodName == 'listSurveysDetailsById') {
            return EUR_TR_Survey.listSurveysDetailsById(requestBody);
        } else if (methodName == 'saveSurveyAnswers') {
            return EUR_TR_Survey.saveSurveyAnswersFromMiddleware(requestBody);
        } else if (methodName == 'commitSaveSurveyAnswers') {
            return EUR_TR_Survey.commitSaveSurveyAnswersFromMiddleware(requestBody);
        } else if (methodName == 'listTOPSKUByAccountId') {
            return listTOPSKUByAccountId(requestBody);
        } else if (methodName == 'listLast5InvByAccountId') {
            return listLast5InvByAccountId(requestBody);
        } else if (methodName == 'listSalesTrendDetailsByAccountId') {
            return listSalesTrendDetailsByAccountId(requestBody);
        } else if (methodName == 'listBrandsByOwnerId') {
            return listBrandsByOwnerId(requestBody);
        } else if (methodName == 'listBrandQualitiesByBrand') {
            return listBrandQualitiesByBrand(requestBody);
        } else if (methodName == 'listBrandQualitySizesByBrandQuality') {
            return listBrandQualitySizesByBrandQuality(requestBody);
        } else if (methodName == 'listProfitabilityByAccountId') {
            return listProfitabilityByAccountId(requestBody);
        } else if (methodName == 'listTasksByAccountIdByKind') {
            return listTasksByAccountIdByKind(requestBody);
        } else if (methodName == 'addTaskByAccountId') {
            return addTaskByAccountId(requestBody);
        } else if (methodName == 'listTRUsers') {
            return listTRUsers(requestBody);
        } else if (methodName == 'completeTaskById') {
            return completeTaskById(requestBody);
        } else if (methodName == 'listPosmByAccountId') {
            return EUR_TR_POSMController.getPOSMRecordsByAccountIdFromMiddleware(requestBody);
        } else if (methodName == 'addPosmByAccountId') {
            return addPosmByAccountId(requestBody);
        } else if (methodName == 'listRoutesByOwnerIdByFavorite') {
            return listRoutesByOwnerIdByFavorite(requestBody);
        } else if (methodName == 'addRouteByOwnerId') {
            return addRouteByOwnerId(requestBody);
        } else if (methodName == 'listAccountsByOwnerIdByRouteId') {
            return listAccountsByOwnerIdByRouteId(requestBody);
        } else if (methodName == 'addAccountToRouteByAccountIdByRouteId') {
            return addAccountToRouteByAccountIdByRouteId(requestBody);
        } else if (methodName == 'removeAccountInRouteByAccountIdByRouteId') {
            return removeAccountInRouteByAccountIdByRouteId(requestBody);
        } else if (methodName == 'listTasksByOwnerIdByKind') {
            return listTasksByOwnerIdByKind(requestBody);
        } else if (methodName == 'listTargetsByOwnerId') {
            return listTargetsByOwnerId(requestBody);
        } else if (methodName == 'removeRouteById') {
            return removeRouteById(requestBody);
        } else if (methodName == 'editRouteById') {
            return editRouteById(requestBody);
        } else if (methodName == 'listProfitabilityByAccountIdGrouped') {
            return listProfitabilityByAccountIdGrouped(requestBody);
        } else if (methodName == 'listMATReportByAccountIdByBrand') {
            return listMATReportByAccountIdByBrand(requestBody);
        } else if (methodName == 'listEmployeesByUserId') {
            return listEmployeesByUserId(requestBody);
        } else if (methodName == 'listDebtAgingSummaryByAccountId') {
            return listDebtAgingSummaryByAccountId(requestBody);
        } else if (methodName == 'listAnnouncementsByOwnerId') {
            return listAnnouncementsByOwnerId(requestBody);
        } else if (methodName == 'getAnnouncementById') {
            return getAnnouncementByIdFromMiddleware(requestBody);
        } else if (methodName == 'removeFileById') {
            return removeFileById(requestBody);
        } else if (methodName == 'getPicklistValues') {
            return getPicklistValues(requestBody);
        } else if (methodName == 'searchAccounts') {
            return EUR_TR_AccountSearchController.searchAccounts(requestBody);
        } else if (methodName == 'getPredefinedTasks') {
            return EUR_TR_BulkTaskImporter.getPredefinedTasksFromMiddleware(requestBody);
        } else if (methodName == 'listOJTQuestions') {
            return EUR_TR_OJTController.listOJTQuestionsFromMiddleware(requestBody);
        } else if (methodName == 'listSurveysByUserId') {
            return EUR_TR_Survey.listSurveysByUserId(requestBody);
        } else if (methodName == 'createOJTPlan') {
            return EUR_TR_OJTController.createOJTPlanFromMiddleware(requestBody);
        } else if (methodName == 'listOJTAccountsByRelatedPlan') {
            return EUR_TR_OJTController.listOJTAccountsByRelatedPlanFromMiddleware(requestBody);
        } else if (methodName == 'startOJTCustomerVisit') {
            return EUR_TR_OJTController.startOJTCustomerVisitFromMiddleware(requestBody);
        } else if (methodName == 'endOJTCustomerVisit') {
            return EUR_TR_OJTController.endOJTCustomerVisitFromMiddleware(requestBody);
        } else if (methodName == 'getPresellerList') {
            return EUR_TR_OJTController.getPresellerListFromMiddleware(requestBody);
        } else if (methodName == 'listOJTPlans') {
            return EUR_TR_OJTController.listOJTPlansPlansFromMiddleware(requestBody);
        } else if (methodName == 'startOJTPlan') {
            return EUR_TR_OJTController.startOJTPlanFromMiddleware(requestBody);
        } else if (methodName == 'deleteOJTPlan') {
            return EUR_TR_OJTController.deleteOJTPlanFromMiddleware(requestBody);
        } else if (methodName == 'endOJTPlan') {
            return EUR_TR_OJTController.endOJTPlanFromMiddleware(requestBody);
        } else if (methodName == 'getPresellerOJTPlanReport') {
            return EUR_TR_OJTController.getPresellerOJTPlanReportFromMiddleware(requestBody);
        } else if (methodName == 'getOJTVisitsByPlanReport') {
            return EUR_TR_OJTController.getOJTVisitsByPlanReportFromMiddleware(requestBody);
        } else if (methodName == 'getOJTVisitDetails') {
            return EUR_TR_OJTController.getOJTVisitDetailsFromMiddleware(requestBody);
        } else if (methodName == 'getOJTConfigurations') {
            return EUR_TR_OJTController.getOJTConfigurationsFromMiddleware(requestBody);
        } else if (methodName == 'makeOJTActionsAfterOJTComplete') {
            return EUR_TR_OJTController.makeOJTActionsAfterOJTComplete(requestBody);
        } else if (methodName == 'getPOSMTypes') {
            return EUR_TR_POSMDefinitionController.getPOSMTypesFromMiddleware(requestBody);
        } else if (methodName == 'getPOSMSubTypesByPOSMType') {
            return EUR_TR_POSMDefinitionController.getPOSMSubTypesByPOSMTypeFromMiddleware(requestBody);
        } else if (methodName == 'createPOSMRequest') {
            return EUR_TR_POSMApprovalController.createPOSMRequest(requestBody);
        } else if (methodName == 'handleApprovalAction') {
            return EUR_TR_POSMApprovalController.handleApprovalAction(requestBody);
        } else if (methodName == 'getPOSMApprovalRecords') {
            return EUR_TR_POSMApprovalController.getPOSMApprovalRecordsFromMiddleware(requestBody);
        } else if (methodName == 'getPOSMApprovalRecordHistory') {
            return EUR_TR_POSMApprovalController.getApprovalRecordHistoryFromMiddleware(requestBody);
        } else if (methodName == 'getPOSMDetailByApprovalId') {
            return EUR_TR_POSMApprovalController.getPOSMDetailByApprovalIdFromMiddleware(requestBody);
        } else if (methodName == 'isApprovalProcessRequiredByPOSMFields') {
            return EUR_TR_POSMApprovalController.isApprovalProcessRequiredByPOSMFields(requestBody);
        } else if (methodName == 'getApprovalActors') {
            return EUR_TR_POSMApprovalController.getApprovalActorsFromMiddleware(requestBody);
        } else if (methodName == 'getPOSMSubTypeFilterOptions') {
            return EUR_TR_POSMApprovalController.getPOSMSubTypeFilterOptionsFromMiddleware(requestBody);
        } else if (methodName == 'getOJTOrganizationScores') {
            return EUR_TR_OJTController.getOJTOrganizationScoresFromMiddleware(requestBody);
        } else if (methodName == 'getRoleAndProfileInformation') {
            return getRoleAndProfileInformation();
        } else if (methodName == 'getSalesTrendsReport') {
            return EUR_TR_Report.getSalesTrendsReportFromMiddleware(requestBody);
        } else if (methodName == 'getMATByBrandReport') {
            return EUR_TR_Report.getMATByBrandReportFromMiddleware(requestBody);
        } else if (methodName == 'getProfitabilityReport') {
            return EUR_TR_Report.getProfitabilityReportFromMiddleware(requestBody);
        } else if (methodName == 'getProfitabilityDetailReport') {
            return EUR_TR_Report.getProfitabilityDetailReportFromMiddleware(requestBody);
        } else if (methodName == 'getMATReport') {
            return EUR_TR_Report.getMATReportFromMiddleware(requestBody);
        } else if (methodName == 'startDay') {
            return EUR_TR_WorkedDayController.startDayFromMiddleware(requestBody);
        } else if (methodName == 'endDay') {
            return EUR_TR_WorkedDayController.endDayFromMiddleware(requestBody);
        } else if (methodName == 'getNotClosedVisitsByCurrentWorkedDay') {
            return EUR_TR_WorkedDayController.getNotClosedVisitsByCurrentWorkedDayFromMiddleware(requestBody);
        } else if (methodName == 'checkIsDayStarted') {
            return EUR_TR_WorkedDayController.checkIsDayStartedFromMiddleware(requestBody);
        } else if (methodName == 'createFavoriteRouteByFavoriteFilter') {
            return EUR_TR_RouteController.createFavoriteRouteByFavoriteFilterFromMiddleware(requestBody);
        } else if (methodName == 'getFavoriteRoutes') {
            return EUR_TR_RouteController.getFavoriteRoutesFromMiddleware(requestBody);
        } else if (methodName == 'deleteFavoriteRouteById') {
            return EUR_TR_RouteController.deleteFavoriteRouteByIdFromMiddleware(requestBody);
        } else if (methodName == 'updateFavoriteRouteById') {
            return EUR_TR_RouteController.updateFavoriteRouteByIdFromMiddleware(requestBody);
        } else if (methodName == 'addAccountToFavoriteRoute') {
            return EUR_TR_RouteController.addAccountToFavoriteRouteFromMiddleware(requestBody);
        } else if (methodName == 'deleteAccountFromFavoriteRoute') {
            return EUR_TR_RouteController.deleteAccountFromFavoriteRouteFromMiddleware(requestBody);
        } else if (methodName == 'createFavoriteRoute') {
            return EUR_TR_RouteController.createFavoriteRouteFromMiddleware(requestBody);
        } else if (methodName == 'getAccountsByFavoriteRoute') {
            return EUR_TR_RouteController.getAccountsByFavoriteRouteFromMiddleware(requestBody);
        } else if (methodName == 'startRoute') {
            return EUR_TR_RouteController.startRouteFromMiddleware(requestBody);
        } else if (methodName == 'getRouteReport') {
            return EUR_TR_RouteReportController.getRouteReportFromMiddleware(requestBody);
        } else if (methodName == 'getRouteReportDetailById') {
            return EUR_TR_RouteReportController.getRouteReportDetailByIdFromMiddleware(requestBody);
        } else if (methodName == 'orderAccounts') {
            return EUR_TR_AccountSearchController.OrderAccounts(requestBody);
        } else if (methodName == 'updateRouteDetailVisitOrder') {
            return EUR_TR_RouteController.UpdateFavoriteRouteDetailVisitOrder(requestBody);
        } else if (methodName == 'getCrossComplianceByAccountId') {
            return EUR_TR_CrossComplianceController.getCrossComplianceByAccountIdFromMiddleware(requestBody);
        } else if (methodName == 'getTargetReport') {
            return EUR_TR_Report.getTargetReportFromMiddleware(requestBody);
        } else if (methodName == 'createWorkedDayApprovalRequest') {
            return EUR_TR_WorkedDayApprovalController.createWorkedDayApprovalRequestFromMiddleware(requestBody);
        } else if (methodName == 'getRangeSKUAvailabilityPercentages') {
            return EUR_TR_RangeSKUAvailabilityController.getRangeSKUAvailabilityPercentagesFromMiddleware(requestBody);
        } else if (methodName == 'getSKUAvailabilityFilters') {
            return EUR_TR_RangeSKUAvailabilityController.getSKUAvailabilityFiltersFromMiddleware(requestBody);
        } else if (methodName == 'getListOfSKUByAvailabilityFilter') {
            return EUR_TR_RangeSKUAvailabilityController.getListOfSKUByAvailabilityFilterFromMiddleware(requestBody);
        } else if (methodName == 'getActiveIncentivesByAccountId') {
            return EUR_TR_IncentiveController.getActiveIncentivesByAccountIdFromMiddleware(requestBody);
        } else if (methodName == 'doNotShowMeSelectedIncentives') {
            return EUR_TR_IncentiveController.doNotShowMeSelectedIncentivesFromMiddleware(requestBody);
        } else if (methodName == 'getAllIncentivesByAccountId') {
            return EUR_TR_IncentiveController.getAllIncentivesByAccountIdFromMiddleware(requestBody);
        } else if (methodName == 'throw') {
            //added for unit testing
            throw new customException('MethodName için servis bulunamadı.');
        } else {
            PostServiceResponse response = new PostServiceResponse();
            response.Code = -1;
            response.Message = 'MethodName için servis bulunamadı.';
            return response;
        }
    }

    /*
    global static PostServiceResponse listAccountsByLocation(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_Location__Latitude__s parametresi boş olamaz';
            return response;
        } else {
            try {
                List<EUR_TR_Account__c> body = (List<EUR_TR_Account__c>) JSON.deserialize(requestBody, List<EUR_TR_Account__c>.class);
                String latitudeString = String.valueOf(body[0].EUR_TR_Location__Latitude__s);
                String longitudeString = String.valueOf(body[0].EUR_TR_Location__Longitude__s);
                if (String.isBlank(latitudeString)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_Location__Latitude__s parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(longitudeString)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_Location__Longitude__s parametresi boş olamaz';
                    return response;
                }

                AccountRequest request = new AccountRequest();
                List<AccountRequestParam> params = new List<AccountRequestParam>();
                AccountRequestParam p1 = new AccountRequestParam();
                p1.key = 'latitude';
                p1.value = String.valueOf(body[0].EUR_TR_Location__Latitude__s);

                AccountRequestParam p2 = new AccountRequestParam();
                p2.key = 'longitude';
                p2.value = String.valueOf(body[0].EUR_TR_Location__Longitude__s);

                AccountRequestParam p3 = new AccountRequestParam();
                p3.key = 'locationstatus';
                p3.value = '1';

                AccountRequestParam p4 = new AccountRequestParam();
                p4.key = 'locationrange';
                p4.value = '5';

                params.add(p1);
                params.add(p2);
                params.add(p3);
                params.add(p4);

                request.params = params;

                return listAccountsByParameters(JSON.serialize(request));
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }
    */
    global static PostServiceResponse listContactsByRelatedAccount(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            try {
                List<Contact> body = (List<Contact>) JSON.deserialize(requestBody, List<Contact>.class);
                String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
                if (String.isBlank(relatedAccount)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                    return response;
                }
                String query = 'select Id, Name, EUR_TR_RelatedAccount__r.Id, EUR_TR_RelatedAccount__r.Name, EUR_TR_MobilePhone__c, HomePhone, Phone, EUR_TR_FaxPhone__c, Email, EUR_TR_Type__c, EUR_TR_HomeAddress__c, EUR_TR_BusinessAddress__c, Department, Title from Contact where RecordType.DeveloperName = \'EUR_TR_Contact\' and EUR_TR_RelatedAccount__r.Id = :relatedAccount order by Name ';
                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = Database.query(query);
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse addContactToRelatedAccount(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            try {
                List<Contact> body = (List<Contact>) JSON.deserialize(requestBody, List<Contact>.class);
                String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
                String firstName = body[0].FirstName;
                String lastName = body[0].LastName;
                String phone = body[0].Phone;
                String email = body[0].Email;
                String type = body[0].EUR_TR_Type__c;
                String code = body[0].EUR_TR_KVKKVerificationCode__c;
                String verificationDate = String.valueOf(body[0].EUR_TR_KVKKVerificationDate__c);

                if (String.isBlank(relatedAccount)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(firstName)) {
                    response.Code = -1;
                    response.Message = 'FirstName parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(lastName)) {
                    response.Code = -1;
                    response.Message = 'LastName parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(code)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_KVKKVerificationCode__c parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(type)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_Type__c parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(verificationDate)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_KVKKVerificationDate__c parametresi boş olamaz';
                    return response;
                }

                RecordType r = [select Id from RecordType where DeveloperName = 'EUR_TR_Contact' and sObjectType = 'Contact'][0];
                Contact c = new Contact();
                c.RecordTypeId = r.Id;
                c.EUR_TR_RelatedAccount__c = relatedAccount;
                c.FirstName = firstName;
                c.LastName = lastName;
                c.Phone = phone;
                c.Email = email;
                c.EUR_TR_KVKKApproved__c = true;
                c.EUR_TR_KVKKVerificationCode__c = code;
                c.EUR_TR_KVKKVerificationDate__c = body[0].EUR_TR_KVKKVerificationDate__c;
                c.EUR_TR_Type__c = type;
                insert c;

                List<Contact> result = new List<Contact>();
                result.add(c);

                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = result;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse editContactById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Contact parametresi boş olamaz';
            return response;
        } else {
            try {
                List<Contact> body = (List<Contact>) JSON.deserialize(requestBody, List<Contact>.class);
                String id = body[0].Id;
                String firstName = body[0].FirstName;
                String lastName = body[0].LastName;
                String phone = body[0].Phone;
                String email = body[0].Email;
                String type = body[0].EUR_TR_Type__c;

                if (String.isBlank(id)) {
                    response.Code = -1;
                    response.Message = 'Id parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(firstName)) {
                    response.Code = -1;
                    response.Message = 'FirstName parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(lastName)) {
                    response.Code = -1;
                    response.Message = 'LastName parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(type)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_Type__c parametresi boş olamaz';
                    return response;
                }

                Contact c = [select Id, FirstName, LastName, Phone, Email, EUR_TR_Type__c from Contact where Id = :id limit 1][0];
                if (String.isNotBlank(firstName)) {
                    c.FirstName = firstName;
                }
                if (String.isNotBlank(lastName)) {
                    c.LastName = lastName;
                }
                if (String.isNotBlank(phone)) {
                    c.Phone = phone;
                }
                if (String.isNotBlank(email)) {
                    c.Email = email;
                }
                if (String.isNotBlank(type)) {
                    c.EUR_TR_Type__c = type;
                }
                update c;

                List<Contact> result = new List<Contact>();
                result.add(c);

                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = result;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse getAccountById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Id parametresi boş olamaz';
            return response;
        } else {
            try {
                List<EUR_TR_Account__c> body = (List<EUR_TR_Account__c>) JSON.deserialize(requestBody, List<EUR_TR_Account__c>.class);
                String id = body[0].Id;
                if (String.isBlank(id)) {
                    response.Code = -1;
                    response.Message = 'Id parametresi boş olamaz';
                    return response;
                }
                String query = 'select Id, Name, EUR_TR_AccountCode__c, EUR_TR_ActivityPoints__c, EUR_TR_ActualLimitAmount__c, EUR_TR_Address__c, EUR_TR_AttackDefense__c, EUR_TR_AttackBrand__c ';
                query += ' ,EUR_TR_AreaManagerName__c, EUR_TR_Channel__c, EUR_TR_CensusChannel__c, EUR_TR_HasCensus__c, EUR_TR_CityName__c, EUR_TR_Class__c, EUR_TR_CreditLimitAmount__c, EUR_TR_CustomerRiskAmount__c ';
                query += ' ,EUR_TR_DefaultPaymentType__c, EUR_TR_DistributorName__c, EUR_TR_Group__c, EUR_TR_InvestmentMatrix__c, EUR_TR_LocalName__c, EUR_TR_Location__c ';
                query += ' ,EUR_TR_ONTB__c, EUR_TR_OTPros__c, EUR_TR_OTSponsorship__c, EUR_TR_OTType__c, EUR_TR_PaymentTerm__c, EUR_TR_PhoneNumber__c, EUR_TR_PresellerName__c ';
                query += ' ,EUR_TR_Range__c, EUR_TR_RegisteredName__c, EUR_TR_SalesChiefName__c, EUR_TR_SalesStatus__c, EUR_TR_SponsorshipStatus__c, EUR_TR_Status__c ';
                query += ' ,EUR_TR_StatusReason__c, EUR_TR_SubType__c, EUR_TR_TAPDKNo__c, EUR_TR_Type__c, EUR_TR_GuaranteeAmount__c, EUR_TR_CensusScore__c, RecordType.DeveloperName ';
                query += ' from EUR_TR_Account__c where Id=:id ';
                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = Database.query(query);
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse listRemPeopleByRelatedAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            try {
                List<EUR_TR_RemPeople__c> body = (List<EUR_TR_RemPeople__c>) JSON.deserialize(requestBody, List<EUR_TR_RemPeople__c>.class);
                String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
                if (String.isBlank(relatedAccount)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                    return response;
                }
                String query = 'select Id, EUR_TR_RelatedAccount__c, EUR_TR_BluePassScore__c, EUR_TR_CompletedDate__c, EUR_TR_MyTequilaScore__c, EUR_TR_MyVodkaScore__c, ';
                query += ' EUR_TR_MyWhiskeyScore__c, EUR_TR_PassportAvailabilityScore__c, EUR_TR_PhotoUrls__c, EUR_TR_PlacementScore__c, EUR_TR_RemId__c, EUR_TR_WhiteCriteriaScore__c ';
                query += ' from EUR_TR_RemPeople__c where EUR_TR_RelatedAccount__c =:relatedAccount order by EUR_TR_CompletedDate__c desc ';
                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = Database.query(query);
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse addNoteByAccount(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Note parametreleri boş olamaz';
            return response;
        } else {
            try {
                List<Note> body = (List<Note>) JSON.deserialize(requestBody, List<Note>.class);
                String parentId = body[0].ParentId;
                String noteBody = body[0].Body;
                String title = body[0].Title;
                if (String.isBlank(parentId)) {
                    response.Code = -1;
                    response.Message = 'ParentId parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(noteBody)) {
                    response.Code = -1;
                    response.Message = 'Body parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(title)) {
                    response.Code = -1;
                    response.Message = 'Title parametresi boş olamaz';
                    return response;
                }

                Note n = new Note();
                n.ParentId = parentId;
                n.Body = noteBody;
                n.Title = title;
                n.IsPrivate = false;
                insert n;

                List<Note> noteList = new List<Note>();
                noteList.add(n);

                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = noteList;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse listAccountNotes(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'ParentId parametresi boş olamaz';
            return response;
        } else {
            try {
                List<Note> body = (List<Note>) JSON.deserialize(requestBody, List<Note>.class);
                String parentId = body[0].ParentId;
                if (String.isBlank(parentId)) {
                    response.Code = -1;
                    response.Message = 'ParentId parametresi boş olamaz';
                    return response;
                }

                List<Note> notes = [
                        SELECT Id, ParentId, Body, Title, CreatedDate, CreatedById
                        FROM Note
                        WHERE ParentId = :parentId
                        ORDER BY CreatedDate DESC
                ];

                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = notes;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse removeNote(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Id parametresi boş olamaz';
            return response;
        } else {
            try {
                List<Note> body = (List<Note>) JSON.deserialize(requestBody, List<Note>.class);
                String id = body[0].Id;
                if (String.isBlank(id)) {
                    response.Code = -1;
                    response.Message = 'Id parametresi boş olamaz';
                    return response;
                }

                List<Note> notes = [
                        SELECT Id, CreatedById
                        FROM Note
                        WHERE Id = :id
                ];

                if (notes[0].CreatedById != UserInfo.getUserId()) {
                    throw new CustomException('Bu not bu kullanıcıya ait değildir.');
                }

                delete notes;

                response.Code = 1;
                response.Message = SuccessMessage;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse editNoteById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Note parametreleri boş olamaz';
            return response;
        } else {
            try {
                List<Note> body = (List<Note>) JSON.deserialize(requestBody, List<Note>.class);
                String id = body[0].Id;
                String noteBody = body[0].Body;
                String title = body[0].Title;
                if (String.isBlank(id)) {
                    response.Code = -1;
                    response.Message = 'Id parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(noteBody)) {
                    response.Code = -1;
                    response.Message = 'Body parametresi boş olamaz';
                    return response;
                }
                if (String.isBlank(title)) {
                    response.Code = -1;
                    response.Message = 'Title parametresi boş olamaz';
                    return response;
                }

                Note n = [Select Id, Body, Title from Note where Id = :id][0];
                n.Body = noteBody;
                n.Title = title;
                update n;

                List<Note> noteList = new List<Note>();
                noteList.add(n);

                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = noteList;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse listSettings(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();

        List<EUR_TR_ApplicationConfiguration__c> body = (List<EUR_TR_ApplicationConfiguration__c>) JSON.deserialize(requestBody, List<EUR_TR_ApplicationConfiguration__c>.class);
        if (body != null && body.size() > 0) {
            String name = body[0].Name;
            if (String.isEmpty(name)) {
                response.Code = -1;
                response.Message = 'Name parametresi boş olamaz';
                return response;
            }
            List<EUR_TR_ApplicationConfiguration__c> configurations = [
                    select Id, Name, EUR_TR_GPSVerificationRange__c, EUR_TR_iOSTabletForceUpdate__c,
                            EUR_TR_iOSTabletVersion__c, EUR_TR_SetupUrliOSTablet__c, EUR_TR_CollectContacts__c, EUR_TR_AutoStartVisit__c
                    from EUR_TR_ApplicationConfiguration__c
                    where RecordType.DeveloperName = :name
                    limit 1
            ];
            User currentUser = [select Id, EUR_TR_AutoStartVisit__c from User where Id = :UserInfo.getUserId()][0];
            configurations[0].EUR_TR_AutoStartVisit__c = currentUser.EUR_TR_AutoStartVisit__c;

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = configurations;
            return response;
        } else {
            response.Code = -1;
            response.Message = 'Ayar parametreleri boş olamaz(2)';
            return response;
        }
    }

    global static PostServiceResponse editSettings(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();

        List<EUR_TR_ApplicationConfiguration__c> body = (List<EUR_TR_ApplicationConfiguration__c>) JSON.deserialize(requestBody, List<EUR_TR_ApplicationConfiguration__c>.class);
        if (body != null && body.size() > 0) {

            String autoStart = String.valueOf(body[0].EUR_TR_AutoStartVisit__c);
            if (String.isEmpty(body[0].Name)) {
                response.Code = -1;
                response.Message = 'Name parametresi boş olamaz';
                return response;
            }
            List<EUR_TR_ApplicationConfiguration__c> configurations = [
                    select Id, Name, EUR_TR_GPSVerificationRange__c, EUR_TR_iOSTabletForceUpdate__c,
                            EUR_TR_iOSTabletVersion__c, EUR_TR_SetupUrliOSTablet__c, EUR_TR_CollectContacts__c, EUR_TR_AutoStartVisit__c
                    from EUR_TR_ApplicationConfiguration__c
                    where RecordType.DeveloperName = :body[0].Name
                    limit 1
            ];

            if (String.isNotBlank(autoStart)) {
                User currentUser = [select Id, EUR_TR_AutoStartVisit__c from User where Id = :UserInfo.getUserId()][0];
                currentUser.EUR_TR_AutoStartVisit__c = Boolean.valueOf(autoStart);
                update currentUser;
                configurations[0].EUR_TR_AutoStartVisit__c = Boolean.valueOf(autoStart);
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = configurations;
            return response;
        } else {
            response.Code = -1;
            response.Message = 'Ayar parametreleri boş olamaz(2)';
            return response;
        }
    }

    global static PostServiceResponse listPicklistByName(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Name parametresi boş olamaz';
            return response;
        } else {
            try {
                PicklistRequest body = (PicklistRequest) JSON.deserialize(requestBody, PicklistRequest.class);
                if (String.isBlank(body.Name)) {
                    response.Code = -1;
                    response.Message = 'Name parametresi boş olamaz';
                    return response;
                }

                List<PicklistResponseItem> picklistValues = new List<PicklistResponseItem>();
                if (body.Name == 'VisitPurpose') {
                    List<Schema.PicklistEntry> reasonsPLE = EUR_TR_Visit__c.EUR_TR_VisitPurpose__c.getDescribe().getPicklistValues();
                    for (Schema.PicklistEntry f : reasonsPLE) {
                        picklistValues.add(new PicklistResponseItem(f.getValue(), f.getLabel()));
                    }
                } else if (body.Name == 'POSMBrand') {
                    List<Schema.PicklistEntry> ple = EUR_TR_Definition__c.EUR_TR_Brand__c.getDescribe().getPicklistValues();
                    for (Schema.PicklistEntry f : ple) {
                        picklistValues.add(new PicklistResponseItem(f.getValue(), f.getLabel()));
                    }
                } else if (body.Name == 'TaskStatus') {
                    List<Schema.PicklistEntry> ple = Task.Status.getDescribe().getPicklistValues();
                    for (Schema.PicklistEntry f : ple) {
                        if (f.getValue() != 'Not started' && f.getValue() != 'Completed' && f.getValue() != 'Canceled') {
                            continue;
                        }
                        picklistValues.add(new PicklistResponseItem(f.getValue(), f.getLabel()));
                    }
                }

                response.Code = 1;
                response.Message = SuccessMessage;
                response.Picklist = picklistValues;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse startVisitByAccount(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            try {

                List<EUR_TR_Visit__c> body = (List<EUR_TR_Visit__c>) JSON.deserialize(requestBody, List<EUR_TR_Visit__c>.class);

                String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
                String latitudeString = String.valueOf(body[0].EUR_TR_StartLocation__Latitude__s);
                String longitudeString = String.valueOf(body[0].EUR_TR_StartLocation__Longitude__s);
                String purpose = body[0].EUR_TR_VisitPurpose__c;

                if (String.isBlank(relatedAccount)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                    return response;
                }

                if (String.isBlank(purpose)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_VisitPurpose__c parametresi boş olamaz';
                    return response;
                }

                EUR_TR_Visit__c currentWorkedDay = EUR_TR_WorkedDayController.getCurrentWorkedDay();
                List<EUR_TR_Visit__c> routeVisits = new List<EUR_TR_Visit__c>();
                if (currentWorkedDay != null) {
                    routeVisits = [
                            SELECT id
                            FROM EUR_TR_Visit__c
                            WHERE EUR_TR_RelatedWorkedDay__c = :currentWorkedDay.Id
                            AND EUR_TR_RelatedAccount__c = :relatedAccount AND EUR_TR_VisitType__c = 'In-Route'
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                    ];
                }


                EUR_TR_Visit__c visit = new EUR_TR_Visit__c();
                if (!routeVisits.isEmpty()) {
                    visit = routeVisits.get(0);
                } else {
                    visit.EUR_TR_VisitType__c = 'Off-Route';
                }

                visit.EUR_TR_RelatedAccount__c = relatedAccount;
                if (String.isNotBlank(latitudeString)) {
                    Decimal latitude = body[0].EUR_TR_StartLocation__Latitude__s;
                    visit.EUR_TR_StartLocation__Latitude__s = latitude;
                }
                if (String.isNotBlank(longitudeString)) {
                    Decimal longitude = body[0].EUR_TR_StartLocation__Longitude__s;
                    visit.EUR_TR_StartLocation__Longitude__s = longitude;
                }
                visit.RecordTypeId = Schema.SObjectType.EUR_TR_Visit__c.getRecordTypeInfosByDeveloperName().get('EUR_TR_Visit').getRecordTypeId();
                visit.EUR_TR_StartDateTime__c = Datetime.now();
                visit.EUR_TR_VisitPurpose__c = purpose;
                if (currentWorkedDay != null) {
                    visit.EUR_TR_RelatedWorkedDay__c = currentWorkedDay.Id;
                }
                upsert visit;

                EUR_TR_Account__c account = [select Id, EUR_TR_LastVisitedDate__c from EUR_TR_Account__c where Id = :relatedAccount][0];
                account.EUR_TR_LastVisitedDate__c = Datetime.now();
                update account;

                List<EUR_TR_Visit__c> result = new List<EUR_TR_Visit__c>();
                result.add(visit);

                response.Code = 1;
                response.Message = SuccessMessage;
                response.Data = result;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse endVisitById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();

        Savepoint savepoint = Database.setSavepoint();
        try {

            List<EUR_TR_Visit__c> body = (List<EUR_TR_Visit__c>) JSON.deserialize(requestBody, List<EUR_TR_Visit__c>.class);
            String latitudeString = String.valueOf(body[0].EUR_TR_EndLocation__Latitude__s);
            String longitudeString = String.valueOf(body[0].EUR_TR_EndLocation__Longitude__s);
            String description = body[0].EUR_TR_Description__c;
            String id = body[0].Id;

            if (String.isBlank(id)) {
                response.Code = -1;
                response.Message = 'Id parametresi boş olamaz';
                return response;
            }

            EUR_TR_Visit__c visit = [
                    SELECT Id, EUR_TR_EndLocation__Latitude__s, EUR_TR_EndLocation__Longitude__s, EUR_TR_Description__c
                    FROM EUR_TR_Visit__c
                    WHERE Id = :id
            ];

            if (String.isNotBlank(latitudeString)) {
                Decimal latitude = body[0].EUR_TR_EndLocation__Latitude__s;
                visit.EUR_TR_EndLocation__Latitude__s = latitude;
            }
            if (String.isNotBlank(longitudeString)) {
                Decimal longitude = body[0].EUR_TR_EndLocation__Longitude__s;
                visit.EUR_TR_EndLocation__Longitude__s = longitude;
            }

            visit.EUR_TR_EndDateTime__c = Datetime.now();
            visit.EUR_TR_Description__c = description;
            update visit;

            List<Note> notes = [SELECT ParentId, Body, Title FROM Note WHERE ParentId = :id];
            for (Note note : notes) {
                note.Body = description;
                note.Title = 'Ziyaret sonlandırma notu';
            }
            update notes;

            List<EUR_TR_Visit__c> result = new List<EUR_TR_Visit__c>();
            result.add(visit);

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        } catch (Exception e) {
            Database.rollback(savepoint);
            response.Code = -1;
            response.Message = e.getMessage();
            return response;
        }
    }

    global static PostServiceResponse sendSMSByPhoneNumberByCode(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Input parametresi boş olamaz';
            return response;
        } else {
            SMSRequest reqBody = (SMSRequest) JSON.deserialize(requestBody, SMSRequest.class);
            if (requestBody == null) {
                response.Code = -1;
                response.Message = 'Input parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(reqBody.Code)) {
                response.Code = -1;
                response.Message = 'Code parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(reqBody.PhoneNumber)) {
                response.Code = -1;
                response.Message = 'PhoneNumber parametresi boş olamaz';
                return response;
            }

            DOM.Document doc = new DOM.Document();

            String soapNS = 'http://www.w3.org/2003/05/soap-envelope';
            String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
            String serviceNS = 'http://83.66.137.24/PgApiWs';
            String xsd = 'http://www.w3.org/2001/XMLSchema';

            Dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soap12');
            envelope.setNamespace('xsi', xsi);
            envelope.setAttribute('xmlns:xsd', xsd);

            Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
            Dom.XmlNode SmsInsert_1_N = body.addChildElement('SmsInsert_1_N', serviceNS, '');
            SmsInsert_1_N.addChildElement('Username', serviceNS, null).addTextNode('Pernodricard');
            SmsInsert_1_N.addChildElement('Password', serviceNS, null).addTextNode('Pernodricard45');

            Dom.XmlNode receipents = SmsInsert_1_N.addChildElement('Recepients', serviceNS, '');
            receipents.addChildElement('string', serviceNS, null).addTextNode(reqBody.PhoneNumber);

            SmsInsert_1_N.addChildElement('Message', serviceNS, null).addTextNode('KVKK Dogrulama Kodunuz: ' + reqBody.Code);

            System.debug(String.valueOf(doc.toXmlString()));

            EUR_TR_ApplicationConfiguration__c prefs = [
                    SELECT EUR_TR_AutoStartVisit__c,
                            EUR_TR_Census_Password__c,
                            EUR_TR_Census_Url__c,
                            EUR_TR_Census_Username__c,
                            EUR_TR_CollectContacts__c,
                            EUR_TR_GPSVerificationRange__c,
                            EUR_TR_iOSTabletForceUpdate__c,
                            EUR_TR_iOSTabletVersion__c,
                            EUR_TR_RemPeople_Password__c,
                            EUR_TR_RemPeople_Url__c,
                            EUR_TR_RemPeople_Username__c,
                            EUR_TR_SetupUrliOSTablet__c,
                            EUR_TR_SMS_Service_Url__c
                    FROM EUR_TR_ApplicationConfiguration__c
                    WHERE RecordType.DeveloperName = 'ApplicationConfiguration'
                    LIMIT 1
            ];
            String endpoint = prefs.EUR_TR_SMS_Service_Url__c + '/api_ws/smsservice.asmx?op=SmsInsert_1_N';

            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(endpoint);
            req.setHeader('Content-Type', 'text/xml');

            req.setBodyDocument(doc);

            Http http = new Http();
            try {
                HttpResponse res = http.send(req);

                System.debug('res:' + res.getStatusCode());
                System.debug('res body:' + res.getBodyDocument().toXmlString());

                if (res.getStatusCode() != 200) {
                    response.Code = -1;
                    response.Message = 'SMS gönderiminde hata oluştu.';
                    return response;
                } else {
                    response.Code = 1;
                    response.Message = SuccessMessage;
                    return response;
                }
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    global static PostServiceResponse listVisitsByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Visit__c> body = (List<EUR_TR_Visit__c>) JSON.deserialize(requestBody, List<EUR_TR_Visit__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }


            List<EUR_TR_Visit__c> result = [
                    select Id, EUR_TR_RelatedAccount__c, EUR_TR_Description__c, EUR_TR_StartDateTime__c, EUR_TR_EndDateTime__c,
                            EUR_TR_StartLocation__c, EUR_TR_EndLocation__c, toLabel(EUR_TR_VisitPurpose__c), EUR_TR_RelatedAccount__r.EUR_TR_Location__c,
                            Owner.Name, EUR_TR_TotalTime__c, EUR_TR_TotalTimeFormatted__c
                    from EUR_TR_Visit__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_Visit'
                    and EUR_TR_StartDateTime__c != null
                    order by EUR_TR_StartDateTime__c desc
                    limit 30
            ];

            for (EUR_TR_Visit__c v : result) {
                Datetime gmt = v.EUR_TR_StartDateTime__c;
                Integer offset = UserInfo.getTimezone().getOffset(gmt);
                Datetime local = gmt.addSeconds(offset / 1000);
                v.EUR_TR_StartDateTime__c = local;
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listDebtAgingByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_DebtAging__c> body = (List<EUR_TR_DebtAging__c>) JSON.deserialize(requestBody, List<EUR_TR_DebtAging__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_DebtAging__c> result = [
                    select Id, EUR_TR_InvoiceAmount__c,
                            EUR_TR_InvoiceNo__c, EUR_TR_PaymentAmount__c,
                            EUR_TR_RelatedAccount__c, EUR_TR_RemainingAmount__c,
                            EUR_TR_DueDate__c, EUR_TR_DueDay__c, EUR_TR_PlannedDueDay__c
                    from EUR_TR_DebtAging__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_DebtAging'
                    order by EUR_TR_DueDate__c
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listDebtAgingSummaryByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_DebtAgingSummary__c> body = (List<EUR_TR_DebtAgingSummary__c>) JSON.deserialize(requestBody, List<EUR_TR_DebtAgingSummary__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_DebtAgingSummary__c> result = [
                    select Id, EUR_TR_RelatedAccount__c, EUR_TR_RemainingAmount__c, EUR_TR_InvoiceAmount__c,
                            EUR_TR_OverdueAmount__c, EUR_TR_OverdueDay__c, EUR_TR_PlannedDay__c
                    from EUR_TR_DebtAgingSummary__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_DebtAgingSummary'
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listAgreementByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountAgreementBrand__c> body = (List<EUR_TR_AccountAgreementBrand__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountAgreementBrand__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_AccountAgreementBrand__c> result = [
                    select Id, EUR_TR_Absolut__c, EUR_TR_AbsolutActual__c, EUR_TR_Bfw__c, EUR_TR_BfwActual__c,
                            EUR_TR_Chivas__c, EUR_TR_ChivasActual__c, EUR_TR_Other__c,
                            EUR_TR_OtherActual__c,
                            EUR_TR_TransferDate__c, EUR_TR_RelatedAccount__c,
                            EUR_TR_SalesPercentage__c, EUR_TR_Total__c, EUR_TR_TotalActual__c, EUR_TR_TTAvlRate__c,
                            EUR_TR_TTBrandAmbassadorRate__c, EUR_TR_TTPaymentRate__c, EUR_TR_TTShelfRate__c,
                            EUR_TR_TTStyleRate__c, EUR_TR_TTTargetPaymentDay__c, EUR_TR_TTTotalRate__c, EUR_TR_TTVolumeRate__c
                    from EUR_TR_AccountAgreementBrand__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_AccountAgreementBrand'
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listBountyRealizationByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountBountyRealization__c> body = (List<EUR_TR_AccountBountyRealization__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountBountyRealization__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_AccountBountyRealization__c> result = [
                    select Id, EUR_TR_EarnedDiscount__c, EUR_TR_Quantity9Lt__c, EUR_TR_RelatedAccount__c,
                            EUR_TR_TargetAmount__c, EUR_TR_TargetPeriod__c
                    from EUR_TR_AccountBountyRealization__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_AccountBountyRealization'
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listRepVisitByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_RepVisit__c> body = (List<EUR_TR_RepVisit__c>) JSON.deserialize(requestBody, List<EUR_TR_RepVisit__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_RepVisit__c> result = [
                    select Id, EUR_TR_CommittedVisitCount__c, EUR_TR_InRouteVisitCount__c, EUR_TR_OutOfRouteVisitCount__c,
                            EUR_TR_PlannedVisitCount__c, EUR_TR_RelatedAccount__r.Id, EUR_TR_Representative__r.Id,
                            EUR_TR_Representative__r.Name, EUR_TR_VisitDate__c, EUR_TR_RelatedAccount__r.Name, EUR_TR_TotalTime__c,
                            EUR_TR_SuccessfulVisitCount__c, EUR_TR_TotalVisitCount__c, EUR_TR_TotalOrderAmount__c, EUR_TR_TotalPaymentAmount__c
                    from EUR_TR_RepVisit__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_RepVisit'
                    order by EUR_TR_VisitDate__c desc
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listRangeByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountRange__c> body = (List<EUR_TR_AccountRange__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountRange__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_AccountRange__c> result = [
                    select Id, EUR_TR_MATCluster__c, EUR_TR_MATSuccess__c, EUR_TR_RangeResult__c, EUR_TR_RangeTarget__c, EUR_TR_RelatedAccount__c
                    from EUR_TR_AccountRange__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_AccountRange'
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listInvoiceSummaryByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_InvoiceSummary__c> body = (List<EUR_TR_InvoiceSummary__c>) JSON.deserialize(requestBody, List<EUR_TR_InvoiceSummary__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_InvoiceSummary__c> result = [
                    select Id, EUR_TR_6MonthsCount__c, EUR_TR_3MonthsCount__c, EUR_TR_12MonthsCount__c, EUR_TR_RelatedAccount__c
                    from EUR_TR_InvoiceSummary__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_InvoiceSummary'
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listTargetRealizationByEmployeeId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_Representative__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_TargetRealization__c> body = (List<EUR_TR_TargetRealization__c>) JSON.deserialize(requestBody, List<EUR_TR_TargetRealization__c>.class);
            String relatedRep = body[0].EUR_TR_Representative__c;

            if (String.isBlank(relatedRep)) {
                response.Code = -1;
                response.Message = 'EUR_TR_Representative__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_TargetRealization__c> result = [
                    select Id, EUR_TR_BrandName__c, EUR_TR_CommittedQuantity9Lt__c, EUR_TR_DistributorName__c, EUR_TR_RealizationDate__c,
                            EUR_TR_Representative__c
                    from EUR_TR_TargetRealization__c
                    where EUR_TR_Representative__c = :relatedRep
                    and RecordType.DeveloperName = 'EUR_TR_TargetRealization'
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listSalesTrendByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_SalesTrend__c> body = (List<EUR_TR_SalesTrend__c>) JSON.deserialize(requestBody, List<EUR_TR_SalesTrend__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

/*List<EUR_TR_SalesTrend__c> result = [select Id, EUR_TR_Brand__c, EUR_TR_BrandQuality__c, EUR_TR_BrandQualitySize__c, EUR_TR_Channel__c,
                                    EUR_TR_LE12Amount__c, EUR_TR_LE1Amount__c, EUR_TR_LE3Amount__c, EUR_TR_LE6Amount__c,
                                    EUR_TR_LE9Amount__c, EUR_TR_LYLE12Amount__c, EUR_TR_LYLE1Amount__c, EUR_TR_LYLE3Amount__c,
                                    EUR_TR_LYLE6Amount__c, EUR_TR_LYLE9Amount__c, EUR_TR_RelatedAccount__c
                                    from EUR_TR_SalesTrend__c
                                    where EUR_TR_RelatedAccount__c=:relatedAccount
                                    and RecordType.DeveloperName = 'EUR_TR_SalesTrend'];*/

            List<AggregateResult> result = [
                    select sum(EUR_TR_LE1Amount__c) le1,
                            sum(EUR_TR_LE3Amount__c) le3,
                            sum(EUR_TR_LE6Amount__c) le6,
                            sum(EUR_TR_LE9Amount__c) le9,
                            sum(EUR_TR_LE12Amount__c) le12,
                            sum(EUR_TR_LYLE1Amount__c) ly1,
                            sum(EUR_TR_LYLE3Amount__c) ly3,
                            sum(EUR_TR_LYLE6Amount__c) ly6,
                            sum(EUR_TR_LYLE9Amount__c) ly9,
                            sum(EUR_TR_LYLE12Amount__c) ly12
                    from EUR_TR_SalesTrend__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_SalesTrend'
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listSalesTrendDetailsByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_SalesTrend__c> body = (List<EUR_TR_SalesTrend__c>) JSON.deserialize(requestBody, List<EUR_TR_SalesTrend__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
            String brand = body[0].EUR_TR_Brand__c;
            String brandQuality = body[0].EUR_TR_BrandQuality__c;
            String brandQualitySize = body[0].EUR_TR_BrandQualitySize__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }
            List<AggregateResult> result = null;
            if (String.isNotBlank(brandQualitySize) && String.isNotBlank(brandQuality) && String.isNotBlank(brand)) {
                result = [
                        select sum(EUR_TR_LE1Amount__c) le1,
                                sum(EUR_TR_LE3Amount__c) le3,
                                sum(EUR_TR_LE6Amount__c) le6,
                                sum(EUR_TR_LE9Amount__c) le9,
                                sum(EUR_TR_LE12Amount__c) le12,
                                sum(EUR_TR_LYLE1Amount__c) ly1,
                                sum(EUR_TR_LYLE3Amount__c) ly3,
                                sum(EUR_TR_LYLE6Amount__c) ly6,
                                sum(EUR_TR_LYLE9Amount__c) ly9,
                                sum(EUR_TR_LYLE12Amount__c) ly12
                        from EUR_TR_SalesTrend__c
                        where EUR_TR_RelatedAccount__c = :relatedAccount
                        and RecordType.DeveloperName = 'EUR_TR_SalesTrend'
                        and EUR_TR_Brand__c = :brand
                        and EUR_TR_BrandQuality__c = :brandQuality
                        and EUR_TR_BrandQualitySize__c = :brandQualitySize
                ];
            } else if (String.isBlank(brandQualitySize) && String.isNotBlank(brandQuality) && String.isNotBlank(brand)) {
                result = [
                        select sum(EUR_TR_LE1Amount__c) le1,
                                sum(EUR_TR_LE3Amount__c) le3,
                                sum(EUR_TR_LE6Amount__c) le6,
                                sum(EUR_TR_LE9Amount__c) le9,
                                sum(EUR_TR_LE12Amount__c) le12,
                                sum(EUR_TR_LYLE1Amount__c) ly1,
                                sum(EUR_TR_LYLE3Amount__c) ly3,
                                sum(EUR_TR_LYLE6Amount__c) ly6,
                                sum(EUR_TR_LYLE9Amount__c) ly9,
                                sum(EUR_TR_LYLE12Amount__c) ly12
                        from EUR_TR_SalesTrend__c
                        where EUR_TR_RelatedAccount__c = :relatedAccount
                        and RecordType.DeveloperName = 'EUR_TR_SalesTrend'
                        and EUR_TR_Brand__c = :brand
                        and EUR_TR_BrandQuality__c = :brandQuality
                ];
            } else if (String.isBlank(brandQualitySize) && String.isBlank(brandQuality) && String.isNotBlank(brand)) {
                result = [
                        select sum(EUR_TR_LE1Amount__c) le1,
                                sum(EUR_TR_LE3Amount__c) le3,
                                sum(EUR_TR_LE6Amount__c) le6,
                                sum(EUR_TR_LE9Amount__c) le9,
                                sum(EUR_TR_LE12Amount__c) le12,
                                sum(EUR_TR_LYLE1Amount__c) ly1,
                                sum(EUR_TR_LYLE3Amount__c) ly3,
                                sum(EUR_TR_LYLE6Amount__c) ly6,
                                sum(EUR_TR_LYLE9Amount__c) ly9,
                                sum(EUR_TR_LYLE12Amount__c) ly12
                        from EUR_TR_SalesTrend__c
                        where EUR_TR_RelatedAccount__c = :relatedAccount
                        and RecordType.DeveloperName = 'EUR_TR_SalesTrend'
                        and EUR_TR_Brand__c = :brand
                ];
            } else {
                result = [
                        select sum(EUR_TR_LE1Amount__c) le1,
                                sum(EUR_TR_LE3Amount__c) le3,
                                sum(EUR_TR_LE6Amount__c) le6,
                                sum(EUR_TR_LE9Amount__c) le9,
                                sum(EUR_TR_LE12Amount__c) le12,
                                sum(EUR_TR_LYLE1Amount__c) ly1,
                                sum(EUR_TR_LYLE3Amount__c) ly3,
                                sum(EUR_TR_LYLE6Amount__c) ly6,
                                sum(EUR_TR_LYLE9Amount__c) ly9,
                                sum(EUR_TR_LYLE12Amount__c) ly12
                        from EUR_TR_SalesTrend__c
                        where EUR_TR_RelatedAccount__c = :relatedAccount
                        and RecordType.DeveloperName = 'EUR_TR_SalesTrend'
                ];
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listMATReportByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountSalesMAT__c> body = (List<EUR_TR_AccountSalesMAT__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountSalesMAT__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
            String brand = body[0].EUR_TR_Brand__c;
            String brandQuality = body[0].EUR_TR_BrandQuality__c;
            String brandQualitySize = body[0].EUR_TR_BrandQualitySize__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            String recordType = 'EUR_TR_AccountSalesMAT';
            List<EUR_TR_AccountSalesMAT__c> result;
            String query = 'select Id, EUR_TR_Brand__c, EUR_TR_BrandQuality__c, EUR_TR_BrandQualitySize__c,';
            query += 'EUR_TR_RelatedAccount__c, EUR_TR_MAT1__c, EUR_TR_MAT2__c, EUR_TR_MAT3__c, EUR_TR_MAT4__c, EUR_TR_MAT5__c ';
            query += 'from EUR_TR_AccountSalesMAT__c where EUR_TR_RelatedAccount__c =:relatedAccount ';
            query += 'and RecordType.DeveloperName = :recordType ';
            if (String.isNotBlank(brand)) {
                query += ' and EUR_TR_Brand__c =:brand ';
            }
            if (String.isNotBlank(brandQuality)) {
                query += ' and EUR_TR_BrandQuality__c =:brandQuality ';
            }
            if (String.isNotBlank(brandQualitySize)) {
                query += ' and EUR_TR_BrandQualitySize__c =:brandQualitySize ';
            }
            query += ' order by EUR_TR_BrandQualitySize__c ';

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = Database.query(query);
            return response;
        }
    }


//    global static PostServiceResponse listAccountsByParameters(String requestBody) {
//        PostServiceResponse response = new PostServiceResponse();
//        if (String.isBlank(requestBody)) {
//            response.Code = -1;
//            response.Message = 'Input parametresi boş olamaz';
//            return response;
//        } else {
//            try {
//                AccountRequest body = (AccountRequest) JSON.deserialize(requestBody, AccountRequest.class);
//                Map<String, String> inputParameters = new Map<String, String>();
//                if (body.params != null && body.params.size() > 0) {
//                    for (AccountRequestParam p : body.params) {
//                        inputParameters.put(p.key, p.value);
//                    }
//                } else {
//                    /*
//                    response.Code = -1;
//                    response.Message = 'Parametrelerden en az bir tanesi dolu olmalıdır.';
//                    return response;
//                    */
//                }
//
//                //remove period parameter if the user selects exists-nonexists period
//                if (inputParameters.containsKey('existnonexist') && inputParameters.containsKey('matLast6')) {
//                    inputParameters.remove('period');
//                }
//
//                String bpQuery = 'select Id,EUR_TR_BluePassScore__c,EUR_TR_MyWhiskeyScore__c,EUR_TR_MyVodkaScore__c,EUR_TR_PlacementScore__c,EUR_TR_PassportAvailabilityScore__c,EUR_TR_WhiteCriteriaScore__c  from EUR_TR_RemPeople__r ';
//                String bpWhere = ' where Id != null ';
//                Boolean hasBPFilter = false;
//                if (inputParameters.containsKey('totalpoint-min') || inputParameters.containsKey('totalpoint-max')) {
//                    hasBPFilter = true;
//                }
//                if (inputParameters.containsKey('whiskey-min') || inputParameters.containsKey('whiskey-max')) {
//                    hasBPFilter = true;
//                }
//                if (inputParameters.containsKey('vodka-min') || inputParameters.containsKey('vodka-max')) {
//                    hasBPFilter = true;
//                }
//                if (inputParameters.containsKey('shelf-min') || inputParameters.containsKey('shelf-max')) {
//                    hasBPFilter = true;
//                }
//                if (inputParameters.containsKey('avl-min') || inputParameters.containsKey('avl-max')) {
//                    hasBPFilter = true;
//                }
//                if (inputParameters.containsKey('white-min') || inputParameters.containsKey('white-max')) {
//                    hasBPFilter = true;
//                }
//                bpQuery += bpWhere + ' order by EUR_TR_CompletedDate__c desc limit 1 ';
//                bpQuery = '(' + bpQuery + '),';
//
//                String rgQuery = 'select Id from EUR_TR_AccountRange__r ';
//                Boolean hasRGFilter = false;
//                if (inputParameters.containsKey('rangeCompliance')) {
//                    String rangeCompliance = inputParameters.get('rangeCompliance');
//                    System.debug('rangeCompliance: ' + rangeCompliance);
//                    rgQuery += ' where EUR_TR_MATCluster__c=\'' + rangeCompliance + '\' ';
//                    hasRGFilter = true;
//                }
//                rgQuery = '(' + rgQuery + '),';
//                Id connectedUserId = UserInfo.getUserId();
//                String query = 'select Id, Name, EUR_TR_AccountCode__c, EUR_TR_Location__Latitude__s, EUR_TR_Location__Longitude__s, EUR_TR_TAPDKLocation__Latitude__s, EUR_TR_TAPDKLocation__Longitude__s, EUR_TR_PresellerName__c, EUR_TR_SalesChiefName__c, EUR_TR_AreaManagerName__c, EUR_TR_ChannelManagerName__c, RecordType.DeveloperName, EUR_TR_Address__c, EUR_TR_TAPDKNo__c, EUR_TR_TopExManagerName__c, ';
//                query += (hasBPFilter ? bpQuery : '') + (hasRGFilter ? rgQuery : '');
//                query += ' EUR_TR_RegisteredName__c, EUR_TR_TAPDKType__c, EUR_TR_HasCensus__c, EUR_TR_CensusDate__c, EUR_TR_CensusChannel__c, EUR_TR_CensusType__c, EUR_TR_CensusScore__c, EUR_TR_CensusImageUrl__c, ';
//                query += ' EUR_TR_MATCY__c, EUR_TR_MATLY__c, EUR_TR_FavoriteCount__c, EUR_TR_LastVisitedDate__c, ';
//
//                String visitFrequencyQuery = '';
//                if (inputParameters.containsKey('visitFrequency')) {
//                    String visitFrequency = inputParameters.get('visitFrequency');
//                    if (String.isNotBlank(visitFrequency)) {
//                        List<String> visitFrequencies = visitFrequency.split(';');
//                        for (String frequency : visitFrequencies) {
//                            if (frequency.equalsIgnoreCase('Bu Hafta') || frequency.equalsIgnoreCase('+1 hafta') || frequency.equalsIgnoreCase('+2 hafta') || frequency.equalsIgnoreCase('+3 hafta') ||
//                                    frequency.equalsIgnoreCase('+1 ay') || frequency.equalsIgnoreCase('+3 ay') || frequency.equalsIgnoreCase('+6 ay')) {
//
//                                if (String.isNotBlank(visitFrequencyQuery)) {
//                                    visitFrequencyQuery += ' OR ';
//                                }
//                                if (frequency.equalsIgnoreCase('Bu Hafta')) {
//                                    visitFrequencyQuery += ' EUR_TR_VisitFrequency__c=\'Bu Hafta\'';
//                                    continue;
//                                } else if (frequency.equalsIgnoreCase('+1 hafta')) {
//                                    visitFrequencyQuery += ' EUR_TR_VisitFrequency__c=\'+1 hafta\'';
//                                    continue;
//                                } else if (frequency.equalsIgnoreCase('+2 hafta')) {
//                                    visitFrequencyQuery += ' EUR_TR_VisitFrequency__c=\'+2 hafta\'';
//                                    continue;
//                                } else if (frequency.equalsIgnoreCase('+3 hafta')) {
//                                    visitFrequencyQuery += ' EUR_TR_VisitFrequency__c=\'+3 hafta\'';
//                                    continue;
//                                } else if (frequency.equalsIgnoreCase('+1 ay')) {
//                                    visitFrequencyQuery += ' EUR_TR_VisitFrequency__c=\'+1 ay\'';
//                                    continue;
//                                } else if (frequency.equalsIgnoreCase('+3 ay')) {
//                                    visitFrequencyQuery += ' EUR_TR_VisitFrequency__c=\'+3 ay\'';
//                                    continue;
//                                } else if (frequency.equalsIgnoreCase('+6 ay')) {
//                                    visitFrequencyQuery += ' EUR_TR_VisitFrequency__c=\'+6 ay\'';
//                                    continue;
//                                }
//                            }
//                        }
//                    }
//                }
//                Set<Id> EURTRAccountIds = new Set<Id>();
//
//                if (String.isNotBlank(visitFrequencyQuery)) {
//
//                    visitFrequencyQuery = String.format(' AND ( {0} ) ', new List<String>{
//                            visitFrequencyQuery
//                    });
//                    query += ' (select EUR_TR_StartDateTime__c, EUR_TR_VisitFrequency__c from EUR_TR_Visits__r where OwnerId = :connectedUserId' + visitFrequencyQuery + 'order by EUR_TR_StartDateTime__c desc limit 1), ';
//
//                    String relatedAccountQueryToVisit = 'Select COUNT(Id),EUR_TR_RelatedAccount__c from EUR_TR_Visit__c where OwnerId=:connectedUserId' + visitFrequencyQuery + ' GROUP BY EUR_TR_RelatedAccount__c';
//                    System.debug(relatedAccountQueryToVisit);
//                    AggregateResult[] groupedResultToVisit = Database.query(relatedAccountQueryToVisit);
//                    for (AggregateResult result : groupedResultToVisit) {
//                        if (result.get('EUR_TR_RelatedAccount__c') != null) {
//                            EURTRAccountIds.add((Id) result.get('EUR_TR_RelatedAccount__c'));
//                        }
//                    }
//
//                } else {
//                    query += ' (select EUR_TR_StartDateTime__c, EUR_TR_VisitFrequency__c from EUR_TR_Visits__r where OwnerId = :connectedUserId order by EUR_TR_StartDateTime__c desc limit 1), ';
//                }
//                query += ' (select Id from EUR_TR_Route_Detail__r where EUR_TR_RelatedRoute__r.OwnerId = :connectedUserId and EUR_TR_RelatedRoute__r.EUR_TR_IsFavorite__c=true) ';
//                if (String.isNotBlank(visitFrequencyQuery) && !EURTRAccountIds.isEmpty()) {
//                    query += ' FROM EUR_TR_Account__c Where Id in :EURTRAccountIds';
//                } else if (String.isNotBlank(visitFrequencyQuery) && EURTRAccountIds.isEmpty()) {
//                    query += ' FROM EUR_TR_Account__c Where Id=null '; // we need to return empty result If there is no visits by the provided visit frequency.
//                } else {
//                    query += ' FROM EUR_TR_Account__c Where Id != null ';
//                }
//                if (inputParameters.containsKey('name')) {
//                    String name = '%' + inputParameters.get('name') + '%';
//                    String nameReplaced = name.replace('i', 'İ');
//                    query += ' and (Name like :name or Name like :nameReplaced or EUR_TR_LocalName__c like :name or EUR_TR_LocalName__c like :nameReplaced or EUR_TR_AccountCode__c like :name or EUR_TR_AccountCode__c like :nameReplaced or EUR_TR_RegisteredName__c like :name or EUR_TR_RegisteredName__c like :nameReplaced) ';
//                    System.debug('name: ' + name);
//                }
//                if (inputParameters.containsKey('type')) {
//                    String type = inputParameters.get('type');
//                    query += ' and EUR_TR_Type__c =:type';
//                    System.debug('type: ' + type);
//                }
//                if (inputParameters.containsKey('class')) {
//                    String classs = inputParameters.get('class');
//                    query += ' and EUR_TR_Class__c =:classs';
//                    System.debug('class: ' + classs);
//                }
//                if (inputParameters.containsKey('status')) {
//                    String status = inputParameters.get('status');
//                    query += ' and EUR_TR_Status__c =:status';
//                    System.debug('status: ' + status);
//                }
//                if (inputParameters.containsKey('distributor')) {
//                    String distributor = inputParameters.get('distributor');
//                    query += ' and EUR_TR_DistributorName__c =:distributor';
//                    System.debug('distributor: ' + distributor);
//                }
//                if (inputParameters.containsKey('channel')) {
//                    String channel = inputParameters.get('channel');
//                    query += ' and EUR_TR_Channel__c =:channel';
//                    System.debug('channel: ' + channel);
//                }
//                if (inputParameters.containsKey('city')) {
//                    String city = inputParameters.get('city');
//                    query += ' and EUR_TR_CityName__c =:city';
//                    System.debug('city: ' + city);
//                }
//                if (inputParameters.containsKey('district')) {
//                    String district = inputParameters.get('district');
//                    query += ' and EUR_TR_DistrictName__c =:district';
//                    System.debug('district: ' + district);
//                }
//                if (inputParameters.containsKey('range')) {
//                    String range = inputParameters.get('range');
//                    query += ' and EUR_TR_Range__c =:range';
//                    System.debug('range: ' + range);
//                }
//
//
//                //EUR_TR_AccountSalesBrand__c = customer level
//                //EUR_TR_AccountSalesHofBrand__c = brand quality (brand) level
//                //EUR_TR_AccountSales__c = brand quality (brand), brand quality size (sku) level
//
//                Boolean hasBSFilter = false;
//                String bsQuery = '';
//                Set<Id> bsAccountIds = new Set<Id>();
//                if (inputParameters.containsKey('period') && inputParameters.containsKey('brand') && inputParameters.containsKey('sku')) {
//                    String period = inputParameters.get('period');
//                    String brand = inputParameters.get('brand');
//                    String sku = inputParameters.get('sku');
//                    System.debug('period: ' + period);
//                    System.debug('brand: ' + brand);
//                    System.debug('sku: ' + sku);
//
//                    String bsWhere = 'where EUR_TR_BrandQuality__c=\'' + String.escapeSingleQuotes(brand) + '\' and EUR_TR_BrandQualitySize__c=\'' + String.escapeSingleQuotes(sku) + '\' ';
//                    String bsHaving = 'having EUR_TR_RelatedAccount__c!=null ';
//                    switch on period {
//                        when 'MAT' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_MATShare__c)>=' + brandsharemin + ' and avg(EUR_TR_MATShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_MATCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_MATCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_MATActual__c)>=' + volumemin + ' and sum(EUR_TR_MATActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'MTD' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_MTDShare__c)>=' + brandsharemin + ' and avg(EUR_TR_MTDShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_MTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_MTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_MTDActual__c)>=' + volumemin + ' and sum(EUR_TR_MTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'QTD' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_QTDShare__c)>=' + brandsharemin + ' and avg(EUR_TR_QTDShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_QTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_QTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_QTDActual__c)>=' + volumemin + ' and sum(EUR_TR_QTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'YTD' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_YTDShare__c)>=' + brandsharemin + ' and avg(EUR_TR_YTDShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_YTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_YTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_YTDActual__c)>=' + volumemin + ' and sum(EUR_TR_YTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                    }
//                    bsQuery = 'select EUR_TR_RelatedAccount__c from EUR_TR_AccountSales__c ' + bsWhere + ' group by EUR_TR_RelatedAccount__c ' + bsHaving;
//                    System.debug('bsQuery: ' + bsQuery);
//                    List<AggregateResult> allSales = Database.query(bsQuery);
//                    for (AggregateResult s : allSales) {
//                        if (!bsAccountIds.contains(Id.valueOf(String.valueOf(s.get('EUR_TR_RelatedAccount__c'))))) {
//                            bsAccountIds.add(Id.valueOf(String.valueOf(s.get('EUR_TR_RelatedAccount__c'))));
//                        }
//                    }
//                    System.debug('bsAccountIds: ' + bsAccountIds.size());
//                }
//                if (inputParameters.containsKey('period') && inputParameters.containsKey('brand') && !inputParameters.containsKey('sku')) {
//                    String period = inputParameters.get('period');
//                    String brand = inputParameters.get('brand');
//                    System.debug('period: ' + period);
//                    System.debug('brand: ' + brand);
//
//                    String bsWhere = 'where EUR_TR_RelatedAccount__c!=null ' + ' and EUR_TR_Brand_Quality__c=\'' + String.escapeSingleQuotes(brand) + '\' ';
//                    String bsHaving = 'having EUR_TR_RelatedAccount__c!=null ';
//                    switch on period {
//                        when 'MAT' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_MATShare__c)>=' + brandsharemin + ' and avg(EUR_TR_MATShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_MATCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_MATCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_MATActual__c)>=' + volumemin + ' and sum(EUR_TR_MATActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'MTD' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_MTDShare__c)>=' + brandsharemin + ' and avg(EUR_TR_MTDShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_MTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_MTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_MTDActual__c)>=' + volumemin + ' and sum(EUR_TR_MTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'QTD' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_QTDShare__c)>=' + brandsharemin + ' and avg(EUR_TR_QTDShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_QTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_QTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_QTDActual__c)>=' + volumemin + ' and sum(EUR_TR_QTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'YTD' {
//                            if (inputParameters.containsKey('brandshare-min') || inputParameters.containsKey('brandshare-max')) {
//                                Decimal brandsharemin = 0;
//                                Decimal brandsharemax = 0;
//                                if (!inputParameters.containsKey('brandshare-min')) {
//                                    brandsharemin = 0;
//                                } else {
//                                    brandsharemin = Decimal.valueOf(inputParameters.get('brandshare-min')) / 100;
//                                }
//                                if (!inputParameters.containsKey('brandshare-max')) {
//                                    brandsharemax = 1;
//                                } else {
//                                    brandsharemax = Decimal.valueOf(inputParameters.get('brandshare-max')) / 100;
//                                }
//                                bsHaving += ' and (avg(EUR_TR_YTDShare__c)>=' + brandsharemin + ' and avg(EUR_TR_YTDShare__c)<=' + brandsharemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('brandsharemin: ' + brandsharemin);
//                                System.debug('brandsharemax: ' + brandsharemax);
//                            }
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_YTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_YTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_YTDActual__c)>=' + volumemin + ' and sum(EUR_TR_YTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                    }
//                    bsQuery = 'select EUR_TR_RelatedAccount__c from EUR_TR_AccountSalesHofBrand__c ' + bsWhere + ' group by EUR_TR_RelatedAccount__c ' + bsHaving;
//                    System.debug('bsQuery: ' + bsQuery);
//                    List<AggregateResult> allSales = Database.query(bsQuery);
//                    for (AggregateResult s : allSales) {
//                        if (!bsAccountIds.contains(Id.valueOf(String.valueOf(s.get('EUR_TR_RelatedAccount__c'))))) {
//                            bsAccountIds.add(Id.valueOf(String.valueOf(s.get('EUR_TR_RelatedAccount__c'))));
//                        }
//                    }
//                    System.debug('bsAccountIds: ' + bsAccountIds.size());
//                }
//                if (inputParameters.containsKey('period') && !inputParameters.containsKey('brand') && !inputParameters.containsKey('sku')) {
//                    String period = inputParameters.get('period');
//                    System.debug('period: ' + period);
//
//                    String bsWhere = 'where EUR_TR_RelatedAccount__c!=null ';
//                    String bsHaving = 'having EUR_TR_RelatedAccount__c!=null ';
//                    switch on period {
//                        when 'MAT' {
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_MATCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_MATCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_MATActual__c)>=' + volumemin + ' and sum(EUR_TR_MATActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'MTD' {
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_MTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_MTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_MTDActual__c)>=' + volumemin + ' and sum(EUR_TR_MTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'QTD' {
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_QTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_QTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_QTDActual__c)>=' + volumemin + ' and sum(EUR_TR_QTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                        when 'YTD' {
//                            if (inputParameters.containsKey('incdecpercluster')) {
//                                String incdecpercluster = inputParameters.get('incdecpercluster');
//                                bsWhere += ' and EUR_TR_YTDCluster__c=\'' + incdecpercluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('incdecpercluster: ' + incdecpercluster);
//                            }
//                            if (inputParameters.containsKey('indeccasecluster')) {
//                                String indeccasecluster = inputParameters.get('indeccasecluster');
//                                bsWhere += ' and EUR_TR_YTDCaseCluster__c=\'' + indeccasecluster + '\' ';
//                                hasBSFilter = true;
//                                System.debug('indeccasecluster: ' + indeccasecluster);
//                            }
//                            if (inputParameters.containsKey('volume-min') || inputParameters.containsKey('volume-max')) {
//                                Decimal volumemin = 0;
//                                Decimal volumemax = 0;
//                                if (!inputParameters.containsKey('volume-min')) {
//                                    volumemin = 0;
//                                } else {
//                                    volumemin = Decimal.valueOf(inputParameters.get('volume-min'));
//                                }
//                                if (!inputParameters.containsKey('volume-max')) {
//                                    volumemax = 99999;
//                                } else {
//                                    volumemax = Decimal.valueOf(inputParameters.get('volume-max'));
//                                }
//                                bsHaving += ' and (sum(EUR_TR_YTDActual__c)>=' + volumemin + ' and sum(EUR_TR_YTDActual__c)<=' + volumemax + ') ';
//                                hasBSFilter = true;
//                                System.debug('volumemin: ' + volumemin);
//                                System.debug('volumemax: ' + volumemax);
//                            }
//                        }
//                    }
//                    bsQuery = 'select EUR_TR_RelatedAccount__c from EUR_TR_AccountSalesBrand__c ' + bsWhere + ' group by EUR_TR_RelatedAccount__c ' + bsHaving;
//                    System.debug('bsQuery: ' + bsQuery);
//                    List<AggregateResult> allSales = Database.query(bsQuery);
//                    for (AggregateResult s : allSales) {
//                        if (!bsAccountIds.contains(Id.valueOf(String.valueOf(s.get('EUR_TR_RelatedAccount__c'))))) {
//                            bsAccountIds.add(Id.valueOf(String.valueOf(s.get('EUR_TR_RelatedAccount__c'))));
//                        }
//                    }
//                    System.debug('bsAccountIds: ' + bsAccountIds.size());
//                }
//                if (inputParameters.containsKey('existnonexist') && inputParameters.containsKey('matLast6')) {
//                    String existnonexist = inputParameters.get('existnonexist');
//                    String matLast6 = inputParameters.get('matLast6');
//                    System.debug('existnonexist: ' + existnonexist);
//                    System.debug('matLast6: ' + matLast6);
//
//                    if (inputParameters.containsKey('brand') && inputParameters.containsKey('sku')) {
//                        String brand = inputParameters.get('brand');
//                        String sku = inputParameters.get('sku');
//                        System.debug('brand: ' + brand);
//                        System.debug('sku: ' + sku);
//
//                        bsQuery = 'select EUR_TR_RelatedAccount__c from EUR_TR_AccountSales__c ';
//                        String bsWhere = 'where Id != null ';
//                        if (matLast6 == 'MAT') {
//                            bsWhere += ' and EUR_TR_MAT_VARYOK__c=\'' + existnonexist + '\' and EUR_TR_BrandQuality__c = \'' + String.escapeSingleQuotes(brand) + '\' and EUR_TR_BrandQualitySize__c = \'' + String.escapeSingleQuotes(sku) + '\'';
//                            hasBSFilter = true;
//                        } else {
//                            bsWhere += ' and EUR_TR_YTD_VARYOK__c=\'' + existnonexist + '\' and EUR_TR_BrandQuality__c = \'' + String.escapeSingleQuotes(brand) + '\' and EUR_TR_BrandQualitySize__c = \'' + String.escapeSingleQuotes(sku) + '\'';
//                            hasBSFilter = true;
//                        }
//
//                        bsQuery += bsWhere;
//                        System.debug('bsQuery: ' + bsQuery);
//                        List<EUR_TR_AccountSales__c> allSales = Database.query(bsQuery);
//                        for (EUR_TR_AccountSales__c s : allSales) {
//                            if (!bsAccountIds.contains(s.EUR_TR_RelatedAccount__c)) {
//                                bsAccountIds.add(s.EUR_TR_RelatedAccount__c);
//                            }
//                        }
//                        System.debug('bsAccountIds: ' + bsAccountIds.size());
//                    }
//                    if (inputParameters.containsKey('brand') && !inputParameters.containsKey('sku')) {
//                        String brand = inputParameters.get('brand');
//                        System.debug('brand: ' + brand);
//
//                        bsQuery = 'select EUR_TR_RelatedAccount__c from EUR_TR_AccountSalesHofBrand__c ';
//                        String bsWhere = 'where Id != null ';
//                        if (matLast6 == 'MAT') {
//                            bsWhere += ' and EUR_TR_MAT_VARYOK__c=\'' + existnonexist + '\' and EUR_TR_Brand_Quality__c = \'' + String.escapeSingleQuotes(brand) + '\'';
//                            hasBSFilter = true;
//                        } else {
//                            bsWhere += ' and EUR_TR_YTD_VARYOK__c=\'' + existnonexist + '\' and EUR_TR_Brand_Quality__c = \'' + String.escapeSingleQuotes(brand) + '\'';
//                            hasBSFilter = true;
//                        }
//
//                        bsQuery += bsWhere;
//                        System.debug('bsQuery: ' + bsQuery);
//                        List<EUR_TR_AccountSalesHofBrand__c> allSales = Database.query(bsQuery);
//                        for (EUR_TR_AccountSalesHofBrand__c s : allSales) {
//                            if (!bsAccountIds.contains(s.EUR_TR_RelatedAccount__c)) {
//                                bsAccountIds.add(s.EUR_TR_RelatedAccount__c);
//                            }
//                        }
//                        System.debug('bsAccountIds: ' + bsAccountIds.size());
//                    }
//                    if (!inputParameters.containsKey('brand') && !inputParameters.containsKey('sku')) {
//                        bsQuery = 'select EUR_TR_RelatedAccount__c from EUR_TR_AccountSalesBrand__c ';
//                        String bsWhere = 'where Id != null ';
//                        if (matLast6 == 'MAT') {
//                            bsWhere += ' and EUR_TR_MAT_VARYOK__c=\'' + existnonexist + '\' ';
//                            hasBSFilter = true;
//                        } else {
//                            bsWhere += ' and EUR_TR_YTD_VARYOK__c=\'' + existnonexist + '\' ';
//                            hasBSFilter = true;
//                        }
//
//                        bsQuery += bsWhere;
//                        System.debug('bsQuery: ' + bsQuery);
//                        List<EUR_TR_AccountSalesBrand__c> allSales = Database.query(bsQuery);
//                        for (EUR_TR_AccountSalesBrand__c s : allSales) {
//                            if (!bsAccountIds.contains(s.EUR_TR_RelatedAccount__c)) {
//                                bsAccountIds.add(s.EUR_TR_RelatedAccount__c);
//                            }
//                        }
//                        System.debug('bsAccountIds: ' + bsAccountIds.size());
//                    }
//                }
//
//                Boolean hasOutOfScope = false;
//                if (inputParameters.containsKey('outofscope')) {
//                    String outofscope = inputParameters.get('outofscope');
//                    if (outofscope == '1') {
//                        hasOutOfScope = true;
//                        query += ' and RecordType.DeveloperName=\'' + 'EUR_TR_TAPDK' + '\' ';
//                        String migros = '%MIGROS%';
//                        String carrefour = '%CARREFOUR%';
//                        String metro = '%METRO%';
//                        query += ' AND ((NOT Name Like \'' + migros + '\' ) and (NOT Name Like \'' + carrefour + '\' ) and (NOT Name Like \'' + metro + '\' )) ';
//                        System.debug('query2: ' + query);
//                    } else {
//                        query += ' and RecordType.DeveloperName!=\'' + 'EUR_TR_TAPDK' + '\' ';
//                    }
//
//                    if (inputParameters.containsKey('census')) {
//                        String census = inputParameters.get('census');
//                        if (census == '1') {
//                            query += ' and EUR_TR_HasCensus__c = true ';
//                        } else {
//                            query += ' and EUR_TR_HasCensus__c = false ';
//                        }
//                        System.debug('census: ' + census);
//                    }
//                    System.debug('outofscope: ' + outofscope);
//                } else {
//                    if (inputParameters.containsKey('census')) {
//                        String census = inputParameters.get('census');
//                        if (census == '1') {
//                            query += ' and EUR_TR_HasCensus__c = true ';
//                        } else {
//                            query += ' and EUR_TR_HasCensus__c = false ';
//                        }
//                        System.debug('census: ' + census);
//                    }
//                    query += ' and RecordType.DeveloperName!=\'' + 'EUR_TR_TAPDK' + '\' ';
//                }
//
//                Boolean hasInvoiceFilter = false;
//                String invoiceQuery = '';
//                if (inputParameters.containsKey('invoiceStatus')) {
//                    String invoiceStatus = inputParameters.get('invoiceStatus');
//                    System.debug('invoiceStatus: ' + invoiceStatus);
//
//                    invoiceQuery = 'select EUR_TR_RelatedAccount__c from EUR_TR_InvoiceSummary__c ';
//                    invoiceQuery += ' where Id!=null ';
//                    if (invoiceStatus == 'Son 3 Ay') {
//                        invoiceQuery += ' and EUR_TR_3MonthsCount__c > 0';
//                    } else if (invoiceStatus == 'Son 6 Ay') {
//                        invoiceQuery += ' and EUR_TR_6MonthsCount__c > 0';
//                    } else if (invoiceStatus == 'Son 12 Ay') {
//                        invoiceQuery += ' and EUR_TR_12MonthsCount__c > 0';
//                    }
//
//                    if (inputParameters.containsKey('brand')) {
//                        String brand = inputParameters.get('brand');
//                        System.debug('brand: ' + brand);
//                        brand = String.escapeSingleQuotes(brand);
//                        invoiceQuery += ' and EUR_TR_HouseOfBrands__c= \'' + brand + '\'';
//                        System.debug('brand: N  ' + brand);
//                    }
//
//                    if (inputParameters.containsKey('sku')) {
//                        String sku = inputParameters.get('sku');
//                        sku = String.escapeSingleQuotes(sku);
//                        System.debug('sku: ' + sku);
//                        invoiceQuery += ' and EUR_TR_BrandQualitySize__c= \'' + sku + '\'';
//                    }
//                    hasInvoiceFilter = true;
//                }
//
//                if (hasBSFilter) {
//                    System.debug('hasBSFilter: ' + hasBSFilter);
//                    System.debug('bsAccountIds: ' + bsAccountIds.size());
//                    query += ' and Id in :bsAccountIds ';
//                }
//                if (hasInvoiceFilter) {
//                    query += ' and Id not in (' + invoiceQuery + ') ';
//                }
//
//                if (inputParameters.containsKey('locationstatus')) {
//                    String locationstatus = inputParameters.get('locationstatus');
//                    System.debug('locationstatus: ' + locationstatus);
//                    if (locationstatus == '1') {
//                        if (inputParameters.containsKey('latitude') && inputParameters.containsKey('longitude')) {
//                            Decimal latitude = Decimal.valueOf(String.isNotBlank(inputParameters.get('latitude')) ? inputParameters.get('latitude') : '0');
//                            Decimal longitude = Decimal.valueOf(String.isNotBlank(inputParameters.get('longitude')) ? inputParameters.get('longitude') : '0');
//                            System.debug('latitude: ' + latitude);
//                            System.debug('longitude: ' + longitude);
//                            Decimal radiusKm = 5;
//                            if (inputParameters.containsKey('locationrange')) {
//                                System.debug('locationrange: ' + inputParameters.get('locationrange'));
//                                radiusKm = Decimal.valueOf(inputParameters.get('locationrange'));
//                            }
//                            query += ' and DISTANCE(EUR_TR_Location__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'km\') < ' + radiusKm + ' ORDER BY DISTANCE(EUR_TR_Location__c, GEOLOCATION(' + latitude + ',' + longitude + '), \'km\') ';
//
//                        }
//                    } else {
//                        //query += ' order by Name ';
//                    }
//                } else {
//                    //query += ' order by Name ';
//                }
//
//                Boolean hasAnyPreFilter = hasBSFilter || hasInvoiceFilter;
//                //if (!hasAnyPreFilter && !hasOutOfScope){
//                query += ' limit 1000';
//                //}
//                System.debug('query:' + query);
//
//                List<EUR_TR_Account__c> filteredAccounts = new List<EUR_TR_Account__c>();
//                List<EUR_TR_Account__c> foundAccounts = Database.query(query);
//
//                Set<Id> filteredAccountIds = new Set<Id>();
//                Boolean hasAnyPostFilter = hasBPFilter || hasRGFilter;
//                if (hasBPFilter) {
//                    for (EUR_TR_Account__c a : foundAccounts) {
//                        if (a.EUR_TR_RemPeople__r.size() > 0) {
//                            //bluepass post filter
//                            Boolean isBPeligible = false;
//                            if (inputParameters.containsKey('totalpoint-min') || inputParameters.containsKey('totalpoint-max')) {
//                                Decimal totalpointmin = 0;
//                                Decimal totalpointmax = 0;
//                                if (!inputParameters.containsKey('totalpoint-min')) {
//                                    totalpointmin = 0;
//                                } else {
//                                    totalpointmin = Decimal.valueOf(inputParameters.get('totalpoint-min'));
//                                }
//                                if (!inputParameters.containsKey('totalpoint-max')) {
//                                    totalpointmax = 100;
//                                } else {
//                                    totalpointmax = Decimal.valueOf(inputParameters.get('totalpoint-max'));
//                                }
//                                System.debug('totalpointmin: ' + totalpointmin);
//                                System.debug('totalpointmax: ' + totalpointmax);
//                                if (a.EUR_TR_RemPeople__r[0].EUR_TR_BluePassScore__c >= totalpointmin && a.EUR_TR_RemPeople__r[0].EUR_TR_BluePassScore__c <= totalpointmax) {
//                                    isBPeligible = true;
//                                }
//                            }
//                            if (inputParameters.containsKey('whiskey-min') || inputParameters.containsKey('whiskey-max')) {
//                                Decimal whiskeymin = 0;
//                                Decimal whiskeymax = 0;
//                                if (!inputParameters.containsKey('whiskey-min')) {
//                                    whiskeymin = 0;
//                                } else {
//                                    whiskeymin = Decimal.valueOf(inputParameters.get('whiskey-min'));
//                                }
//                                if (!inputParameters.containsKey('whiskey-max')) {
//                                    whiskeymax = 100;
//                                } else {
//                                    whiskeymax = Decimal.valueOf(inputParameters.get('whiskey-max'));
//                                }
//                                System.debug('whiskeymin: ' + whiskeymin);
//                                System.debug('whiskeymax: ' + whiskeymax);
//                                if (a.EUR_TR_RemPeople__r[0].EUR_TR_MyWhiskeyScore__c >= whiskeymin && a.EUR_TR_RemPeople__r[0].EUR_TR_MyWhiskeyScore__c <= whiskeymax) {
//                                    isBPeligible = true;
//                                }
//                            }
//                            if (inputParameters.containsKey('vodka-min') || inputParameters.containsKey('vodka-max')) {
//                                Decimal vodkamin = 0;
//                                Decimal vodkamax = 0;
//                                if (!inputParameters.containsKey('vodka-min')) {
//                                    vodkamin = 0;
//                                } else {
//                                    vodkamin = Decimal.valueOf(inputParameters.get('vodka-min'));
//                                }
//                                if (!inputParameters.containsKey('vodka-max')) {
//                                    vodkamax = 100;
//                                } else {
//                                    vodkamax = Decimal.valueOf(inputParameters.get('vodka-max'));
//                                }
//                                System.debug('vodkamin: ' + vodkamin);
//                                System.debug('vodkamax: ' + vodkamax);
//                                if (a.EUR_TR_RemPeople__r[0].EUR_TR_MyVodkaScore__c >= vodkamin && a.EUR_TR_RemPeople__r[0].EUR_TR_MyVodkaScore__c <= vodkamax) {
//                                    isBPeligible = true;
//                                }
//                            }
//                            if (inputParameters.containsKey('shelf-min') || inputParameters.containsKey('shelf-max')) {
//                                Decimal shelfmin = 0;
//                                Decimal shelfmax = 0;
//                                if (!inputParameters.containsKey('shelf-min')) {
//                                    shelfmin = 0;
//                                } else {
//                                    shelfmin = Decimal.valueOf(inputParameters.get('shelf-min'));
//                                }
//                                if (!inputParameters.containsKey('shelf-max')) {
//                                    shelfmax = 100;
//                                } else {
//                                    shelfmax = Decimal.valueOf(inputParameters.get('shelf-max'));
//                                }
//                                System.debug('shelfmin: ' + shelfmin);
//                                System.debug('shelfmax: ' + shelfmax);
//                                if (a.EUR_TR_RemPeople__r[0].EUR_TR_PlacementScore__c >= shelfmin && a.EUR_TR_RemPeople__r[0].EUR_TR_PlacementScore__c <= shelfmax) {
//                                    isBPeligible = true;
//                                }
//                            }
//                            if (inputParameters.containsKey('avl-min') || inputParameters.containsKey('avl-max')) {
//                                Decimal avlmin = 0;
//                                Decimal avlmax = 0;
//                                if (!inputParameters.containsKey('avl-min')) {
//                                    avlmin = 0;
//                                } else {
//                                    avlmin = Decimal.valueOf(inputParameters.get('avl-min'));
//                                }
//                                if (!inputParameters.containsKey('avl-max')) {
//                                    avlmax = 100;
//                                } else {
//                                    avlmax = Decimal.valueOf(inputParameters.get('avl-max'));
//                                }
//                                System.debug('avlmin: ' + avlmin);
//                                System.debug('avlmax: ' + avlmax);
//                                if (a.EUR_TR_RemPeople__r[0].EUR_TR_PassportAvailabilityScore__c >= avlmin && a.EUR_TR_RemPeople__r[0].EUR_TR_PassportAvailabilityScore__c <= avlmax) {
//                                    isBPeligible = true;
//                                }
//                            }
//                            if (inputParameters.containsKey('white-min') || inputParameters.containsKey('white-max')) {
//                                Decimal whitemin = 0;
//                                Decimal whitemax = 0;
//                                if (!inputParameters.containsKey('white-min')) {
//                                    whitemin = 0;
//                                } else {
//                                    whitemin = Decimal.valueOf(inputParameters.get('white-min'));
//                                }
//                                if (!inputParameters.containsKey('white-max')) {
//                                    whitemax = 100;
//                                } else {
//                                    whitemax = Decimal.valueOf(inputParameters.get('white-max'));
//                                }
//                                System.debug('whitemin: ' + whitemin);
//                                System.debug('whitemax: ' + whitemax);
//                                if (a.EUR_TR_RemPeople__r[0].EUR_TR_WhiteCriteriaScore__c >= whitemin && a.EUR_TR_RemPeople__r[0].EUR_TR_WhiteCriteriaScore__c <= whitemax) {
//                                    isBPeligible = true;
//                                }
//                            }
//
//                            System.debug('isBPeligible: ' + isBPeligible);
//                            if (!filteredAccountIds.contains(a.Id) && isBPeligible) {
//                                filteredAccounts.add(a);
//                                filteredAccountIds.add(a.Id);
//                            }
//                        }
//                    }
//                }
//                if (hasRGFilter) {
//                    for (EUR_TR_Account__c a : foundAccounts) {
//                        if (a.EUR_TR_AccountRange__r.size() > 0) {
//                            if (!filteredAccountIds.contains(a.Id)) {
//                                filteredAccounts.add(a);
//                                filteredAccountIds.add(a.Id);
//                            }
//                        }
//                    }
//                }
//
//                System.debug('hasAnyPreFilter: ' + hasAnyPreFilter);
//                System.debug('hasAnyPostFilter: ' + hasAnyPostFilter);
//                System.debug('filteredAccounts: ' + filteredAccounts.size());
//                System.debug('foundAccounts: ' + foundAccounts.size());
//
//                List<EUR_TR_Account__c> finalResult = (hasAnyPostFilter == true ? filteredAccounts : foundAccounts);
//                Set<Id> finalResultAccountIds = new Set<Id>();
//                for (EUR_TR_Account__c a : finalResult) {
//                    if (!finalResultAccountIds.contains(a.Id)) {
//                        finalResultAccountIds.add(a.Id);
//                    }
//                }
//                Map<Id, AggregateResult> totalSalesMap = new Map<Id, AggregateResult>();
//                for (AggregateResult ar : [
//                        select EUR_TR_RelatedAccount__c, sum(EUR_TR_MAT1__c) mat1, sum(EUR_TR_MAT2__c) mat2
//                        from EUR_TR_AccountSalesMAT__c
//                        where EUR_TR_RelatedAccount__c in :finalResultAccountIds
//                        group by EUR_TR_RelatedAccount__c
//                ]) {
//                    if (!totalSalesMap.containsKey(Id.valueOf(String.valueOf(ar.get('EUR_TR_RelatedAccount__c'))))) {
//                        totalSalesMap.put(Id.valueOf(String.valueOf(ar.get('EUR_TR_RelatedAccount__c'))), ar);
//                    }
//                }
//                for (EUR_TR_Account__c a : finalResult) {
//                    Decimal cy = 0;
//                    Decimal ly = 0;
//
//                    if (totalSalesMap.get(a.Id) != null) {
//                        cy = Decimal.valueOf(String.valueOf(totalSalesMap.get(a.Id).get('mat1')));
//                        ly = Decimal.valueOf(String.valueOf(totalSalesMap.get(a.Id).get('mat2')));
//                    }
//
//                    a.EUR_TR_MATCY__c = cy;
//                    a.EUR_TR_MATLY__c = ly;
//
//                    if (a.EUR_TR_Visits__r != null) {
//                        List<EUR_TR_Visit__c> visits = a.EUR_TR_Visits__r;
//                        if (visits.size() > 0) {
//                            a.EUR_TR_LastVisitedDate__c = visits[0].EUR_TR_StartDateTime__c;
//                        } else {
//                            a.EUR_TR_LastVisitedDate__c = null;
//                        }
//                    } else {
//                        a.EUR_TR_LastVisitedDate__c = null;
//                    }
//
//                    if (a.EUR_TR_Route_Detail__r != null) {
//                        List<EUR_TR_RouteDetail__c> favorites = a.EUR_TR_Route_Detail__r;
//                        a.EUR_TR_FavoriteCount__c = favorites.size();
//                    } else {
//                        a.EUR_TR_FavoriteCount__c = 0;
//                    }
//                }
//
//                response.Code = 1;
//                response.Message = SuccessMessage;
//                response.Data = finalResult;
//                return response;
//            } catch (Exception e) {
//                response.Code = -1;
//                response.Message = e.getMessage();
//                return response;
//            }
//        }
//    }


    global static PostServiceResponse listFilterParameters(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            try {
                List<Account> body = (List<Account>) JSON.deserialize(requestBody, List<Account>.class); //added for dummy deserialize
                List<AccountParameter> result = new List<AccountParameter>();

                List<EUR_TR_District__c> districtList = [
                        select Id, Name, EUR_TR_CityName__c
                        from EUR_TR_District__c
                        where RecordType.DeveloperName = 'EUR_TR_District'
                        and Name != ''
                        order by Name
                ];

                Map<String, Set<String>> districtMap = new Map<String, Set<String>>();
                for (EUR_TR_District__c d : districtList) {
                    if (!districtMap.containsKey(d.EUR_TR_CityName__c)) {
                        Set<String> s1 = new Set<String>();
                        districtMap.put(d.EUR_TR_CityName__c, s1);
                    } else {
                        Set<String> s2 = districtMap.get(d.EUR_TR_CityName__c);
                        if (!s2.contains(d.Name)) {
                            s2.add(d.Name);
                        }
                        districtMap.put(d.EUR_TR_CityName__c, s2);
                    }
                }

                AccountParameter p1 = new AccountParameter();
                p1.name = 'cities';
                List<AccountParameterDetail> cities = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> ctys = EUR_TR_Account__c.EUR_TR_CityName__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry g : ctys) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = g.getLabel();
                    pg.value = g.getValue();
                    List<AccountParameterDetail> districts = new List<AccountParameterDetail>();
                    Set<String> s3 = districtMap.containsKey(pg.key) ? districtMap.get(pg.key) : new Set<String>();
                    for (String d : s3) {
                        AccountParameterDetail district = new AccountParameterDetail();
                        district.key = d;
                        district.value = d;
                        districts.add(district);
                    }
                    pg.values = districts;
                    cities.add(pg);
                }
                p1.values = cities;

                AccountParameter p2 = new AccountParameter();
                p2.name = 'channels';
                List<AccountParameterDetail> channels = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> chs = EUR_TR_Account__c.EUR_TR_Channel__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry g : chs) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = g.getValue();
                    pg.value = g.getLabel();
                    channels.add(pg);
                }
                p2.values = channels;

                AccountParameter p4 = new AccountParameter();
                p4.name = 'types';
                List<AccountParameterDetail> p4s = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> types = EUR_TR_Account__c.EUR_TR_Type__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry t : types) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.value = t.getLabel();
                    pg.key = t.getValue();
                    p4s.add(pg);
                }
                p4.values = p4s;

                AccountParameter p5 = new AccountParameter();
                p5.name = 'classes';
                List<AccountParameterDetail> p5s = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> classes = EUR_TR_Account__c.EUR_TR_Class__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry c : classes) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = c.getLabel();
                    pg.value = c.getValue();
                    p5s.add(pg);
                }
                p5.values = p5s;

                AccountParameter p6 = new AccountParameter();
                p6.name = 'ranges';
                List<AccountParameterDetail> p6s = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> ranges = EUR_TR_Account__c.EUR_TR_Range__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry r : ranges) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = r.getLabel();
                    pg.value = r.getValue();
                    p6s.add(pg);
                }
                p6.values = p6s;

                AccountParameter p7 = new AccountParameter();
                p7.name = 'brands';
                List<AccountParameterDetail> p7s = new List<AccountParameterDetail>();
                for (AggregateResult b : [select EUR_TR_HouseOfBrand__c from EUR_TR_SKU__c where EUR_TR_Status__c = 'Aktif' group by EUR_TR_HouseOfBrand__c order by EUR_TR_HouseOfBrand__c]) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = String.valueOf(b.get('EUR_TR_HouseOfBrand__c'));
                    pg.value = String.valueOf(b.get('EUR_TR_HouseOfBrand__c'));

                    List<AccountParameterDetail> p7sub = new List<AccountParameterDetail>();
                    for (AggregateResult hb : [
                            select EUR_TR_BrandQualitySize__c
                            from EUR_TR_SKU__c
                            where EUR_TR_Status__c = 'Aktif' and EUR_TR_HouseOfBrand__c = :pg.key
                            group by EUR_TR_BrandQualitySize__c
                            order by EUR_TR_BrandQualitySize__c
                    ]) {
                        AccountParameterDetail p7ss = new AccountParameterDetail();
                        p7ss.key = String.valueOf(hb.get('EUR_TR_BrandQualitySize__c'));
                        p7ss.value = String.valueOf(hb.get('EUR_TR_BrandQualitySize__c'));
                        p7sub.add(p7ss);
                    }
                    pg.values = p7sub;
                    p7s.add(pg);
                }
                p7.values = p7s;

                AccountParameter p9 = new AccountParameter();
                p9.name = 'distributors';
                List<AccountParameterDetail> p9s = new List<AccountParameterDetail>();
                List<EUR_TR_Distributor__c> dists = [select Id, Name from EUR_TR_Distributor__c where EUR_TR_Status__c = 'Aktif' order by Name];
                for (EUR_TR_Distributor__c d : dists) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = d.Name;
                    pg.value = d.Name;
                    p9s.add(pg);
                }
                p9.values = p9s;

                AccountParameter p13 = new AccountParameter();
                p13.name = 'statuses';
                List<AccountParameterDetail> p13s = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> statuses = EUR_TR_Account__c.EUR_TR_Status__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry d : statuses) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = d.getLabel();
                    pg.value = d.getValue();
                    p13s.add(pg);
                }
                p13.values = p13s;

                AccountParameter p14 = new AccountParameter();
                p14.name = 'period';
                List<AccountParameterDetail> p14s = new List<AccountParameterDetail>();
                AccountParameterDetail p141 = new AccountParameterDetail();
                p141.key = 'MAT';
                p141.value = 'MAT';
                p14s.add(p141);
                AccountParameterDetail p142 = new AccountParameterDetail();
                p142.key = 'YTD';
                p142.value = 'YTD';
                p14s.add(p142);
                AccountParameterDetail p143 = new AccountParameterDetail();
                p143.key = 'QTD';
                p143.value = 'QTD';
                p14s.add(p143);
                AccountParameterDetail p144 = new AccountParameterDetail();
                p144.key = 'MTD';
                p144.value = 'MTD';
                p14s.add(p144);
                p14.values = p14s;

                AccountParameter p15 = new AccountParameter();
                p15.name = 'existNonExists';
                List<AccountParameterDetail> p15s = new List<AccountParameterDetail>();
                AccountParameterDetail p151 = new AccountParameterDetail();
                p151.key = 'VAR-VAR';
                p151.value = 'VAR-VAR';
                p15s.add(p151);
                AccountParameterDetail p152 = new AccountParameterDetail();
                p152.key = 'VAR-YOK';
                p152.value = 'VAR-YOK';
                p15s.add(p152);
                AccountParameterDetail p153 = new AccountParameterDetail();
                p153.key = 'YOK-YOK';
                p153.value = 'YOK-YOK';
                p15s.add(p153);
                AccountParameterDetail p154 = new AccountParameterDetail();
                p154.key = 'YOK-VAR';
                p154.value = 'YOK-VAR';
                p15s.add(p154);
                p15.values = p15s;

                AccountParameter p16 = new AccountParameter();
                p16.name = 'invoiceStatus';
                List<AccountParameterDetail> p16s = new List<AccountParameterDetail>();
                AccountParameterDetail p161 = new AccountParameterDetail();
                p161.value = 'Son 3 Ay';
                p161.key = 'Son 3 Ay';
                p16s.add(p161);
                AccountParameterDetail p162 = new AccountParameterDetail();
                p162.value = 'Son 6 Ay';
                p162.key = 'Son 6 Ay';
                p16s.add(p162);
                AccountParameterDetail p163 = new AccountParameterDetail();
                p163.value = 'Son 12 Ay';
                p163.key = 'Son 12 Ay';
                p16s.add(p163);
                p16.values = p16s;

                AccountParameter p17 = new AccountParameter();
                p17.name = 'rangeCompliance';
                List<AccountParameterDetail> p17s = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> rgs = EUR_TR_AccountRange__c.EUR_TR_MATCluster__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry d : rgs) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = d.getLabel();
                    pg.value = d.getValue();
                    p17s.add(pg);
                }
                p17.values = p17s;

                AccountParameter p18 = new AccountParameter();
                p18.name = 'clusters';
                List<AccountParameterDetail> p18s = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> rgs2 = EUR_TR_AccountSales__c.EUR_TR_MATCluster__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry d : rgs2) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = d.getLabel();
                    pg.value = d.getValue();
                    p18s.add(pg);
                }
                p18.values = p18s;

                AccountParameter p19 = new AccountParameter();
                p19.name = 'caseClusters';
                List<AccountParameterDetail> p19s = new List<AccountParameterDetail>();
                List<Schema.PicklistEntry> rgs3 = EUR_TR_AccountSales__c.EUR_TR_MATCaseCluster__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry d : rgs3) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = d.getLabel();
                    pg.value = d.getValue();
                    p19s.add(pg);
                }
                p19.values = p19s;

                AccountParameter p20 = new AccountParameter();
                p20.name = 'alerts';
                List<AccountParameterDetail> p20s = new List<AccountParameterDetail>();
                AccountParameterDetail p201 = new AccountParameterDetail();
                p201.value = '1';
                p201.key = 'Alert 1';
                p20s.add(p201);
                AccountParameterDetail p202 = new AccountParameterDetail();
                p202.value = '2';
                p202.key = 'Alert 2';
                p20s.add(p202);
                p20.values = p20s;

                AccountParameter p21 = new AccountParameter();
                p21.name = 'matLast6';
                List<AccountParameterDetail> p21s = new List<AccountParameterDetail>();
                AccountParameterDetail p211 = new AccountParameterDetail();
                p211.value = 'MAT';
                p211.key = 'MAT';
                p21s.add(p211);
                AccountParameterDetail p212 = new AccountParameterDetail();
                p212.value = 'Last6';
                p212.key = 'Son 6 Ay';
                p21s.add(p212);
                p21.values = p21s;

                AccountParameter visitFrequency = new AccountParameter();
                visitFrequency.name = 'visitFrequency';
                visitFrequency.values = new List<EUR_TR_MiddlewareController.AccountParameterDetail>();
                visitFrequency.values.add(createAccountParameterDetail('Bu Hafta', 'Bu Hafta'));
                visitFrequency.values.add(createAccountParameterDetail('+1 hafta', '+1 hafta'));
                visitFrequency.values.add(createAccountParameterDetail('+2 hafta', '+2 hafta'));
                visitFrequency.values.add(createAccountParameterDetail('+3 hafta', '+3 hafta'));
                visitFrequency.values.add(createAccountParameterDetail('+1 ay', '+1 ay'));
                visitFrequency.values.add(createAccountParameterDetail('+3 ay', '+3 ay'));
                visitFrequency.values.add(createAccountParameterDetail('+6 ay', '+6 ay'));
                result.add(visitFrequency);

                AccountParameter p23 = new AccountParameter();
                p23.name = 'crossCompliance';
                p23.values = new List<EUR_TR_MiddlewareController.AccountParameterDetail>();
                p23.values.add(createAccountParameterDetail('EUR_TR_CR12JD__c', 'CR12JD'));
                p23.values.add(createAccountParameterDetail('EUR_TR_BFWJWRL__c', 'BFWJWRL'));
                p23.values.add(createAccountParameterDetail('EUR_TR_PassBells__c', 'PassBells'));
                p23.values.add(createAccountParameterDetail('EUR_TR_WyboCross__c', 'Wybo'));
                p23.values.add(createAccountParameterDetail('EUR_TR_AbsCross__c', 'Abs'));

                List<AccountParameterDetail> p24s = new List<AccountParameterDetail>();
                AccountParameter p24 = new AccountParameter();
                p24.name = 'attackbrands';
                List<Schema.PicklistEntry> rgs4 = EUR_TR_Account__c.EUR_TR_AttackBrand__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry d : rgs4) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = d.getLabel();
                    pg.value = d.getValue();
                    p24s.add(pg);
                }
                p24.values = p24s;


                List<AccountParameterDetail> p25s = new List<AccountParameterDetail>();
                AccountParameter p25 = new AccountParameter();
                p25.name = 'incentiveBrands';
                List<Schema.PicklistEntry> rgs5 = EUR_TR_Incentive__c.EUR_TR_Brand__c.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry d : rgs5) {
                    AccountParameterDetail pg = new AccountParameterDetail();
                    pg.key = d.getLabel();
                    pg.value = d.getValue();
                    p25s.add(pg);
                }
                p25.values = p25s;

                AccountParameter p26 = new AccountParameter();
                p26.name = 'isIncentiveAccount';
                p26.values = new List<EUR_TR_MiddlewareController.AccountParameterDetail>();
                p26.values.add(createAccountParameterDetail('Evet', 'Evet'));
                p26.values.add(createAccountParameterDetail('Hayır', 'Hayır'));

                result.add(p1);
                result.add(p2);
                result.add(p4);
                result.add(p5);
                result.add(p6);
                result.add(p7);
                result.add(p9);
                result.add(p13);
                result.add(p14);
                result.add(p15);
                result.add(p16);
                result.add(p17);
                result.add(p18);
                result.add(p19);
                result.add(p20);
                result.add(p21);
                result.add(p23);
                result.add(p24);
                result.add(p25);
                result.add(p26);

                response.Code = 1;
                response.Message = SuccessMessage;
                response.AccountParameters = result;
                return response;
            } catch (Exception e) {
                response.Code = -1;
                response.Message = e.getMessage();
                return response;
            }
        }
    }

    static AccountParameterDetail createAccountParameterDetail(String key, String value) {
        AccountParameterDetail parameterDetail = new AccountParameterDetail();
        parameterDetail.key = key;
        parameterDetail.value = value;
        return parameterDetail;
    }

    global static PostServiceResponse listTOPSKUByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountSales__c> body = (List<EUR_TR_AccountSales__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountSales__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
            String period = body[0].EUR_TR_Period__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_AccountSales__c> allSales = new List<EUR_TR_AccountSales__c>();
            String query = 'select Id, EUR_TR_Brand__c, EUR_TR_BrandQualitySize__c,  EUR_TR_RelatedAccount__c, EUR_TR_ImageUrl__c,';
            query += ' EUR_TR_YTDShare__c, EUR_TR_YTDActual__c, EUR_TR_YTDLy__c, EUR_TR_YTDCs__c, EUR_TR_YTDPer__c, EUR_TR_YTDCluster__c, EUR_TR_YTDCaseCluster__c,';
            query += ' EUR_TR_QTDShare__c, EUR_TR_QTDActual__c, EUR_TR_QTDLy__c, EUR_TR_QTDCs__c, EUR_TR_QTDPer__c, EUR_TR_QTDCluster__c, EUR_TR_QTDCaseCluster__c,';
            query += ' EUR_TR_MTDShare__c, EUR_TR_MTDActual__c, EUR_TR_MTDLy__c, EUR_TR_MTDCs__c, EUR_TR_MTDPer__c, EUR_TR_MTDCluster__c, EUR_TR_MTDCaseCluster__c,';
            query += ' EUR_TR_MATShare__c, EUR_TR_MATActual__c, EUR_TR_MATLy__c, EUR_TR_MATCs__c, EUR_TR_MATPer__c, EUR_TR_MATCluster__c, EUR_TR_MATCaseCluster__c,';
            query += ' EUR_TR_MATLyShare__c, EUR_TR_YTDLyShare__c, EUR_TR_MTDLyShare__c, EUR_TR_QTDLyShare__c ';
            query += ' from EUR_TR_AccountSales__c';
            query += ' where EUR_TR_RelatedAccount__c=:relatedAccount';
            query += ' and RecordType.DeveloperName = \'' + 'EUR_TR_AccountSales' + '\' ';
            if (period == 'MAT') {
                query += ' order by EUR_TR_MATShare__c desc limit 10';
            } else if (period == 'MTD') {
                query += ' order by EUR_TR_MTDShare__c desc limit 10';
            } else if (period == 'QTD') {
                query += ' order by EUR_TR_QTDShare__c desc limit 10';
            } else if (period == 'YTD') {
                query += ' order by EUR_TR_YTDShare__c desc limit 10';
            }
            allSales = Database.query(query);

            switch on period {
                when 'MAT' {
                    for (EUR_TR_AccountSales__c a : allSales) {
                        a.EUR_TR_YTDShare__c = a.EUR_TR_MATShare__c;
                        a.EUR_TR_YTDActual__c = a.EUR_TR_MATActual__c;
                        a.EUR_TR_YTDLy__c = a.EUR_TR_MATLy__c;
                        a.EUR_TR_YTDCs__c = a.EUR_TR_MATCs__c;
                        a.EUR_TR_YTDPer__c = a.EUR_TR_MATPer__c;
                        a.EUR_TR_YTDCluster__c = a.EUR_TR_MATCluster__c;
                        a.EUR_TR_YTDCaseCluster__c = a.EUR_TR_MATCaseCluster__c;
                        a.EUR_TR_YTDLyShare__c = a.EUR_TR_MATLyShare__c;
                    }
                }
                when 'MTD' {
                    for (EUR_TR_AccountSales__c a : allSales) {
                        a.EUR_TR_YTDShare__c = a.EUR_TR_MTDShare__c;
                        a.EUR_TR_YTDActual__c = a.EUR_TR_MTDActual__c;
                        a.EUR_TR_YTDLy__c = a.EUR_TR_MTDLy__c;
                        a.EUR_TR_YTDCs__c = a.EUR_TR_MTDCs__c;
                        a.EUR_TR_YTDPer__c = a.EUR_TR_MTDPer__c;
                        a.EUR_TR_YTDCluster__c = a.EUR_TR_MTDCluster__c;
                        a.EUR_TR_YTDCaseCluster__c = a.EUR_TR_MTDCaseCluster__c;
                        a.EUR_TR_YTDLyShare__c = a.EUR_TR_MTDLyShare__c;
                    }
                }
                when 'QTD' {
                    for (EUR_TR_AccountSales__c a : allSales) {
                        a.EUR_TR_YTDShare__c = a.EUR_TR_QTDShare__c;
                        a.EUR_TR_YTDActual__c = a.EUR_TR_QTDActual__c;
                        a.EUR_TR_YTDLy__c = a.EUR_TR_QTDLy__c;
                        a.EUR_TR_YTDCs__c = a.EUR_TR_QTDCs__c;
                        a.EUR_TR_YTDPer__c = a.EUR_TR_QTDPer__c;
                        a.EUR_TR_YTDCluster__c = a.EUR_TR_QTDCluster__c;
                        a.EUR_TR_YTDCaseCluster__c = a.EUR_TR_QTDCaseCluster__c;
                        a.EUR_TR_YTDLyShare__c = a.EUR_TR_QTDLyShare__c;
                    }
                }
            }

            List<EUR_TR_SKU__c> allSKUs = [select EUR_TR_BrandQualitySize__c, EUR_TR_ImageUrl__c from EUR_TR_SKU__c where EUR_TR_Status__c = 'Aktif'];
            Map<String, String> hofBrandWithURL = new Map<String, String>();
            for (EUR_TR_SKU__c e : allSKUs) {
                if (!hofBrandWithURL.containsKey(e.EUR_TR_BrandQualitySize__c)) {
                    hofBrandWithURL.put(e.EUR_TR_BrandQualitySize__c, e.EUR_TR_ImageUrl__c);
                }
            }
/*hofBrandWithURL.put('100 PIPERS', 'https://assets.pernod-ricard.com/marque_bouteille_principale/100piper.png');
hofBrandWithURL.put('ABERLOUR 12 YO', 'https://s3-eu-west-1.amazonaws.com/aberlour.com/prod/ProductToMarket/1438/largeBottle/1/largeBottle_276x822.png');
hofBrandWithURL.put('ABERLOUR 16 YO', 'https://s3-eu-west-1.amazonaws.com/aberlour.com/prod/ProductToMarket/1437/largeBottle/1/largeBottle_276x822.png');
hofBrandWithURL.put('ABERLOUR 18 YO', 'https://s3-eu-west-1.amazonaws.com/aberlour.com/prod/ProductToMarket/1436/largeBottle/1/largeBottle_276x822.png');
hofBrandWithURL.put('ABERLOUR A BUNADH', 'https://s3-eu-west-1.amazonaws.com/aberlour.com/prod/ProductToMarket/1435/largeBottle/1/largeBottle_276x822.png');
hofBrandWithURL.put('ABSOLUT APEACH VODKA', 'https://assets.pernod-ricard.com/nz/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/absolut_apeach_700ml.png');
hofBrandWithURL.put('ABSOLUT CITRON VODKA', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/absolut-citron_0.png');
hofBrandWithURL.put('ABSOLUT ELYX VODKA', 'https://assets.pernod-ricard.com/nz/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/absolut_elyx_700ml.png');
hofBrandWithURL.put('ABSOLUT EXTRAKT', 'https://assets.pernod-ricard.com/fr/ricard2/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/previewmedium-absolut_extrakt_1l_black_0.png');
hofBrandWithURL.put('ABSOLUT FACET VODKA', 'urlhere');
hofBrandWithURL.put('ABSOLUT LIME VODKA', 'https://assets.pernod-ricard.com/nz/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/absolut_lime.png');
hofBrandWithURL.put('ABSOLUT MANDRIN VODKA', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/absolut-mandrin_0.png');
hofBrandWithURL.put('ABSOLUT ORIENT APPLE VODKA', 'urlhere');
hofBrandWithURL.put('ABSOLUT PEARS VODKA', 'https://assets.pernod-ricard.com/nz/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/absolut_pears_700ml.png');
hofBrandWithURL.put('ABSOLUT RASPBERRI VODKA', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/absolut-raspberri_0.png');
hofBrandWithURL.put('ABSOLUT RUBY RED VODKA', 'urlhere');
hofBrandWithURL.put('ABSOLUT VANILIA VODKA', 'https://assets.pernod-ricard.com/nz/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/vanilia.png');
hofBrandWithURL.put('ABSOLUT VODKA', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/absolut-black.png');
hofBrandWithURL.put('AVION TEQUILA ANEJO', 'https://tequilaavion.com/user/pages/product/anejo-bottle.png');
hofBrandWithURL.put('AVION TEQUILA REPOSADO', 'https://tequilaavion.com/user/pages/product/Reposado-Bottle.png');
hofBrandWithURL.put('AVION TEQUILA SILVER', 'https://tequilaavion.com/user/pages/product/Silver-Bottle.png');
hofBrandWithURL.put('BAKER`S FIELD', 'urlhere');
hofBrandWithURL.put('BALLANTINES 12 YO', 'https://s3-eu-west-1.amazonaws.com/ballantines.com/prod/ProductToMarket/936/largeBottle/1/largeBottle_400x1027.png');
hofBrandWithURL.put('BALLANTINES 17 YO', 'https://s3-eu-west-1.amazonaws.com/ballantines.com/prod/ProductToMarket/938/largeBottle/2/largeBottle_400x1027.png');
hofBrandWithURL.put('BALLANTINES 21 YO', 'https://s3-eu-west-1.amazonaws.com/ballantines.com/prod/ProductToMarket/996/largeBottle/1/largeBottle_400x1027.png');
hofBrandWithURL.put('BALLANTINES FINEST', 'https://s3-eu-west-1.amazonaws.com/ballantines.com/prod/ProductToMarket/934/largeBottle/1/largeBottle_400x1027.png');
hofBrandWithURL.put('BEEFEATER 24', 'https://s3-eu-west-1.amazonaws.com/beefeater.com/stage/ProductToMarket/2176/productBottle/4/productBottle_195x700.png');
hofBrandWithURL.put('BEEFEATER GIN', 'https://s3-eu-west-1.amazonaws.com/beefeater.com/stage/ProductToMarket/2174/productBottle/2/productBottle_181x783.png');
hofBrandWithURL.put('BEEFEATER PINK', 'https://s3-eu-west-1.amazonaws.com/beefeater.com/stage/ProductToMarket/2175/productBottle/3/productBottle_195x700.png');
hofBrandWithURL.put('BORZOI VODKA', 'urlhere');
hofBrandWithURL.put('CACHAÇA JANEIRO', 'urlhere');
hofBrandWithURL.put('CAFE DE PARIS', 'https://assets.pernod-ricard.com/fr/pernod/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/cafe_de_paris_brut.png');
hofBrandWithURL.put('CAFE DE PARIS ROSE', 'https://assets.pernod-ricard.com/fr/pernod/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/cafe_de_paris_rose.png');
hofBrandWithURL.put('CANADIAN SPECIAL OLD', 'http://cdn.pernod-ricard.cz/brand_data//1429881000-canadian-special-old-0-7l.png');
hofBrandWithURL.put('CHIVAS 18 YO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/chivas-18_0.png');
hofBrandWithURL.put('CHIVAS 25 YO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/chivas-25_0.png');
hofBrandWithURL.put('CHIVAS EXTRA', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/chivas-extra_0.png');
hofBrandWithURL.put('CHIVAS REGAL 12 YO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/chivas_0.png');
hofBrandWithURL.put('CHIVAS REGAL AURUM XV', 'https://media.danmurphys.com.au/dmo/product/808371-1.png');
hofBrandWithURL.put('CHIVAS REGAL ICON WHISKY', 'urlhere');
hofBrandWithURL.put('CHIVAS REGAL MIZUNARA', 'https://assets.pernod-ricard.com/nz/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/mizunara.png');
hofBrandWithURL.put('CHIVAS REGAL ULTIS', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/chivas-ultis_0.png');
hofBrandWithURL.put('DOMECQ 1820', 'urlhere');
hofBrandWithURL.put('GARRONE BIANCO', 'urlhere');
hofBrandWithURL.put('GARRONE BITTER', 'urlhere');
hofBrandWithURL.put('GARRONE DRY', 'urlhere');
hofBrandWithURL.put('GARRONE PROSECCO', 'urlhere');
hofBrandWithURL.put('GARRONE ROSSO', 'urlhere');
hofBrandWithURL.put('GARRONE SPRITZ', 'urlhere');
hofBrandWithURL.put('GLENLIVET 12 YO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/the_glenlivet.png');
hofBrandWithURL.put('GLENLIVET 15 YO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/the-glenlivet-15.png');
hofBrandWithURL.put('GLENLIVET 18 YO', 'https://s3-eu-west-1.amazonaws.com/theglenlivet.com/stage/ProductToMarket/992/largeBottle/1/largeBottle_320x1030.png');
hofBrandWithURL.put('GLENLIVET FOUNDERS RESERVE', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/the-glenlivet-foundersreserve.png');
hofBrandWithURL.put('HAVANA CLUB 3 YO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/havanaclub-3year_0.png');
hofBrandWithURL.put('HAVANA CLUB 7 ANS', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/havana-club.png');
hofBrandWithURL.put('HAVANA CLUB ANEJO BLANCO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/havanaclub-especial_0.png');
hofBrandWithURL.put('HAVANA CLUB SELECCION DE MAESTROS', 'urlhere');
hofBrandWithURL.put('JAMESON', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/jameson.png');
hofBrandWithURL.put('JAMESON BLACK BARREL', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/jameson-black-barrel.png');
hofBrandWithURL.put('JAMESON CASKMATES', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/jameson-caskmates.png');
hofBrandWithURL.put('JOINT BOURBON WHISKEY', 'urlhere');
hofBrandWithURL.put('KAHLUA COFFEE LIQ.', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/kahlua_original.png');
hofBrandWithURL.put('LIMONCELLO', 'urlhere');
hofBrandWithURL.put('LONG JOHN', 'urlhere');
hofBrandWithURL.put('LUKSUSOWA VODKA', 'http://www.luksusowavodka.com/en/wp-content/themes/wp-bootstrap-gulp/dist/images/butelka-luksusowa-eng.png');
hofBrandWithURL.put('MALIBU', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/malibu-original.png');
hofBrandWithURL.put('MARIACHI BLANCO', 'urlhere');
hofBrandWithURL.put('MARTELL VS', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/martell_vs.png');
hofBrandWithURL.put('MARTELL VSOP', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/martell_vsop_png.png');
hofBrandWithURL.put('MARTELL XO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/martell_xo.png');
hofBrandWithURL.put('MONKEY 47 DRY GIN', 'urlhere');
hofBrandWithURL.put('MONTILLA RUM', 'urlhere');
hofBrandWithURL.put('MUMM CORDON ROUGE BRUT', 'https://www.mumm.com/sites/default/files/styles/376x840/public/images/product/champagne/376x840_0002_mumm_cordonrouge_75cl_new_rvb.png');
hofBrandWithURL.put('MUMM CORDON ROUGE NIGHT EDITION GOLD', 'urlhere');
hofBrandWithURL.put('MUMM ROSE', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/mumm_rose.png');
hofBrandWithURL.put('OLMECA ALTOS', 'https://www.altostequila.com/sites/default/files/plata_0.png');
hofBrandWithURL.put('OLMECA BLANCO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/olmeca_blanco.png');
hofBrandWithURL.put('OLMECA DARK CHOCOLATE', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/olmeca_chocolate.png');
hofBrandWithURL.put('OLMECA GOLD', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/olmeca_gold.png');
hofBrandWithURL.put('PASSPORT', 'https://assets.pernod-ricard.com/marque_bouteille_principale/passport.png?yjM25LLdldDm57I5CpLk8mepJv1sQvck');
hofBrandWithURL.put('PERRIER JOUET BELLE EPOQUE', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/perrierjouet-rose-fd-blanc.png');
hofBrandWithURL.put('PLYMOUTH GIN', 'https://s3-eu-west-1.amazonaws.com/plymouthgin.com/stage/ProductToMarket/2791/thumbnail/5/thumbnail_800x1278.png');
hofBrandWithURL.put('RAMAZZOTTI AMARO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/ramazzotti_amaro.png');
hofBrandWithURL.put('RAMAZZOTTI APERITIVO ROSATO', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/ramazzotti_rosato.png');
hofBrandWithURL.put('RAMAZZOTTI SAMBUCA', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/ramazzotti_sambuca.png');
hofBrandWithURL.put('RICARD', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/marque_gamme/ricard.png');
hofBrandWithURL.put('ROYAL SALUTE', 'https://assets.pernod-ricard.com/styles/marque_mini_carrosselbreakpoints_theme_pernodricard_desktop_1x/s3/royalsalute_3.png');
hofBrandWithURL.put('SCAPA GLANSA', 'urlhere');
hofBrandWithURL.put('SCAPA SKIEREN', 'urlhere');
hofBrandWithURL.put('SOHO LITCHI', 'urlhere');
hofBrandWithURL.put('SORAU BRANDY', 'urlhere');
hofBrandWithURL.put('STAMFORD GIN', 'urlhere');
hofBrandWithURL.put('TRİPLE SEC DU ORANGE', 'https://www.luxardo.it/wp-content/uploads/2018/11/luxardo_triplum.png');
hofBrandWithURL.put('WYBOROWA VODKA', 'https://assets.pernod-ricard.com/marque_bouteille_principale/wyborowa.png?FZHBJZjvF9xUpOO1SFEL4l_0dPbygCQp');*/

            for (EUR_TR_AccountSales__c s : allSales) {
                if (hofBrandWithURL.containsKey(s.EUR_TR_BrandQualitySize__c)) {
                    String url = hofBrandWithURL.get(s.EUR_TR_BrandQualitySize__c);
                    s.EUR_TR_ImageUrl__c = url;
                }
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = allSales;
            return response;
        }
    }

    global static PostServiceResponse listLast5InvByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Invoice__c> body = (List<EUR_TR_Invoice__c>) JSON.deserialize(requestBody, List<EUR_TR_Invoice__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_Invoice__c> result = [
                    select Id, Name, EUR_TR_DocumentDate__c, EUR_TR_GrossAmount__c, EUR_TR_RelatedAccount__c, (
                            select Id, Name, EUR_TR_Brand__c, EUR_TR_BrandQuality__c, EUR_TR_BrandQualitySize__c, EUR_TR_QuantityLiter__c, EUR_TR_QuantityBottle__c, EUR_TR_AmountVATExcluded__c, EUR_TR_AmountVATIncluded__c, EUR_TR_AmountDiscount__c,
                                    EUR_TR_AmountGross__c
                            from EUR_TR_Invoice_Detail__r
                            order by EUR_TR_BrandQualitySize__c
                    )
                    from EUR_TR_Invoice__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    and RecordType.DeveloperName = 'EUR_TR_Invoice'
                    order by EUR_TR_LastN__c asc
            ];

            for (EUR_TR_Invoice__c i : result) {
                Decimal total = 0;
                if (i.EUR_TR_Invoice_Detail__r != null) {

                    for (EUR_TR_InvoiceDetail__c d : i.EUR_TR_Invoice_Detail__r) {
                        total += d.EUR_TR_AmountVATIncluded__c;
                        d.EUR_TR_BrandQuality__c = d.Name;
                    }
                }
                i.EUR_TR_GrossAmount__c = total;
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listBrandsByOwnerId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_SKU__c> body = (List<EUR_TR_SKU__c>) JSON.deserialize(requestBody, List<EUR_TR_SKU__c>.class);
/*String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

if (String.isBlank(relatedAccount)){
    response.Code = -1;
    response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
    return response;
}*/

            List<AggregateResult> result = [
                    select EUR_TR_Brand__c
                    from EUR_TR_SKU__c
                    where EUR_TR_Status__c = 'Aktif'
                    group by EUR_TR_Brand__c
                    order by EUR_TR_Brand__c asc
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listBrandQualitiesByBrand(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_Brand__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_SKU__c> body = (List<EUR_TR_SKU__c>) JSON.deserialize(requestBody, List<EUR_TR_SKU__c>.class);
            String relatedBrand = body[0].EUR_TR_Brand__c;

            if (String.isBlank(relatedBrand)) {
                response.Code = -1;
                response.Message = 'EUR_TR_Brand__c parametresi boş olamaz';
                return response;
            }

            List<AggregateResult> result = [
                    select EUR_TR_BrandQuality__c
                    from EUR_TR_SKU__c
                    where EUR_TR_Status__c = 'Aktif'
                    and EUR_TR_Brand__c = :relatedBrand
                    group by EUR_TR_BrandQuality__c
                    order by EUR_TR_BrandQuality__c asc
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listBrandQualitySizesByBrandQuality(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_BrandQuality__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_SKU__c> body = (List<EUR_TR_SKU__c>) JSON.deserialize(requestBody, List<EUR_TR_SKU__c>.class);
            String relatedBrand = body[0].EUR_TR_BrandQuality__c;

            if (String.isBlank(relatedBrand)) {
                response.Code = -1;
                response.Message = 'EUR_TR_BrandQuality__c parametresi boş olamaz';
                return response;
            }

            List<AggregateResult> result = [
                    select EUR_TR_BrandQualitySize__c
                    from EUR_TR_SKU__c
                    where EUR_TR_Status__c = 'Aktif'
                    and EUR_TR_BrandQuality__c = :relatedBrand
                    group by EUR_TR_BrandQualitySize__c
                    order by EUR_TR_BrandQualitySize__c asc
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listProfitabilityByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountProfitability__c> body = (List<EUR_TR_AccountProfitability__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountProfitability__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_AccountProfitability__c> result = [
                    select EUR_TR_RelatedAccount__c, EUR_TR_Year__c, EUR_TR_Quarter__c, EUR_TR_TotalAmount__c, EUR_TR_ProfitAmount__c
                    from EUR_TR_AccountProfitability__c
                    where RecordType.DeveloperName = 'EUR_TR_AccountProfitability'
                    and EUR_TR_RelatedAccount__c = :relatedAccount
                    order by EUR_TR_Year__c, EUR_TR_Quarter__c
            ];


            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listProfitabilityByAccountIdGrouped(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountProfitability__c> body = (List<EUR_TR_AccountProfitability__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountProfitability__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<AggregateResult> result = [
                    select EUR_TR_Year__c, sum(EUR_TR_TotalAmount__c) total, sum(EUR_TR_ProfitAmount__c) profit
                    from EUR_TR_AccountProfitability__c
                    where RecordType.DeveloperName = 'EUR_TR_AccountProfitability'
                    and EUR_TR_RelatedAccount__c = :relatedAccount
                    group by EUR_TR_Year__c
            ];
            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listTasksByAccountIdByKind(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'WhatId parametresi boş olamaz';

            return response;
        }

        TaskRequest taskRequest = (TaskRequest) JSON.deserialize(requestBody, TaskRequest.class);
        Task task = taskRequest.task;
        String relatedAccount = task.WhatId;
        String kind = task.PR_Activity_Type__c;

        if (String.isBlank(relatedAccount)) {
            response.Code = -1;
            response.Message = 'WhatId parametresi boş olamaz';
            return response;
        }
        if (String.isBlank(kind)) {
            response.Code = -1;
            response.Message = 'PR_Activity_Type__c parametresi boş olamaz';
            return response;
        }

        List<Task> result = [
                SELECT Id, Subject, What.Name, WhatId, CreatedById, CreatedBy.Name, CreatedDate, ActivityDate, Owner.Name, OwnerId, PR_Activity_Type__c,
                        Description, Status, Priority, Cliente__c, (
                        SELECT ContentDocumentId, FileType
                        FROM AttachedContentDocuments
                )
                FROM Task
                WHERE RecordType.DeveloperName = 'EUR_TR_Task'
                AND PR_Activity_Type__c = :kind
                AND WhatId = :relatedAccount
                ORDER BY ActivityDate DESC
                LIMIT :taskRequest.pageSize
                OFFSET :taskRequest.pageSize * (taskRequest.pageNumber - 1)
        ];

        Map<Id, EUR_TR_Employee__c> userToRelatedEmployeeMap = new Map<Id, EUR_TR_Employee__c>();
        List<EUR_TR_Employee__c> relatedEmployeesByOwnerIds = getEmployeesByTaskOwner(result);
        List<TaskResultWrapper> resultWrappers = new List<TaskResultWrapper>();

        for (EUR_TR_Employee__c employee : relatedEmployeesByOwnerIds) {
            if (employee.EUR_TR_RelatedUser__c != null) {
                userToRelatedEmployeeMap.put(employee.EUR_TR_RelatedUser__c, employee);
            }
        }

        resultWrappers = prepareResultWrapperListWithEmployeeTitle(userToRelatedEmployeeMap, result);

        response.Code = 1;
        response.Message = SuccessMessage;
        response.ExtensionData = resultWrappers;

        return response;

    }

    global static PostServiceResponse listTasksByOwnerIdByKind(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'PR_Activity_Type__c parametresi boş olamaz';
            return response;
        }

        TaskRequest taskRequest = (TaskRequest) JSON.deserialize(requestBody, TaskRequest.class);
        Task task = taskRequest.task;
        String relatedOwner = task.OwnerId;
        String kind = task.PR_Activity_Type__c;
        String type = String.valueOf(task.RecurrenceInterval);

        if (String.isBlank(relatedOwner)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        }
        if (String.isBlank(kind)) {
            response.Code = -1;
            response.Message = 'PR_Activity_Type__c parametresi boş olamaz';
            return response;
        }
        if (String.isBlank(type)) {
            response.Code = -1;
            response.Message = 'RecurrenceInterval parametresi boş olamaz';
            return response;
        }

        List<Task> result = new List<Task>();
        List<TaskResultWrapper> resultWrappers = new List<TaskResultWrapper>();
        Map<Id, EUR_TR_Employee__c> userToRelatedEmployeeMap = new Map<Id, EUR_TR_Employee__c>();
        if (type == '1') {
// Benim Atadıklarım = Owner.Name => Atananlar
            result = [
                    SELECT Id, Subject, What.Name, WhatId, CreatedDate, ActivityDate, Owner.Name, OwnerId,
                            PR_Activity_Type__c, Description, Status, Priority, CreatedById, CreatedBy.Name, Cliente__c, (
                            SELECT ContentDocumentId, FileType
                            FROM AttachedContentDocuments
                    )
                    FROM Task
                    WHERE RecordType.DeveloperName = 'EUR_TR_Task'
                    AND PR_Activity_Type__c = :kind
                    AND CreatedById = :relatedOwner
                    ORDER BY CreatedDate DESC
                    LIMIT :taskRequest.pageSize
                    OFFSET :taskRequest.pageSize * (taskRequest.pageNumber - 1)
            ];

            List<EUR_TR_Employee__c> relatedEmployeesByOwnerIds = getEmployeesByTaskOwner(result);
            for (EUR_TR_Employee__c employee : relatedEmployeesByOwnerIds) {
                if (employee.EUR_TR_RelatedUser__c != null) {
                    userToRelatedEmployeeMap.put(employee.EUR_TR_RelatedUser__c, employee);
                }
            }

            resultWrappers = prepareResultWrapperListWithEmployeeTitle(userToRelatedEmployeeMap, result);


        } else if (type == '2') {
// Banan Atananlar = Owner.Name => atayanlar
            result = [
                    SELECT Id, Subject, What.Name, WhatId, CreatedDate, ActivityDate, Owner.Name, OwnerId,
                            PR_Activity_Type__c, Description, Status, Priority, CreatedById, CreatedBy.Name, Cliente__c, (
                            SELECT ContentDocumentId, FileType
                            FROM AttachedContentDocuments
                    )
                    FROM Task
                    WHERE RecordType.DeveloperName = 'EUR_TR_Task'
                    AND PR_Activity_Type__c = :kind
                    AND OwnerId = :relatedOwner
                    ORDER BY CreatedDate DESC
                    LIMIT :taskRequest.pageSize
                    OFFSET :taskRequest.pageSize * (taskRequest.pageNumber - 1)
            ];

            List<EUR_TR_Employee__c> relatedEmployeesByOwnerIds = getEmployeesByTaskOwner(result);

            for (EUR_TR_Employee__c employee : relatedEmployeesByOwnerIds) {
                if (employee.EUR_TR_RelatedUser__c != null) {
                    userToRelatedEmployeeMap.put(employee.EUR_TR_RelatedUser__c, employee);
                }
            }

            resultWrappers = prepareResultWrapperListWithEmployeeTitle(userToRelatedEmployeeMap, result);

        } else if (type == '3') {
// Ekibime atananlar;
// Atayan : CreatedBy.Name
// Atanan : Owner.Name

            List<UserRole> currentUserRole = [
                    SELECT Id, DeveloperName
                    FROM UserRole
                    WHERE Id = :UserInfo.getUserRoleId()
            ];

            EUR_TR_Employee__c currentUserEmployeeRecord = [
                    SELECT Id, EUR_TR_RelatedUser__c,
                            RecordType.Developername
                    FROM EUR_TR_Employee__c
                    WHERE EUR_TR_RelatedUser__c = :UserInfo.getUserId()
            ];

            Map<Id, EUR_TR_Employee__c> salesChiefMap = new Map<Id, EUR_TR_Employee__c>();
            Map<Id, EUR_TR_Employee__c> areaManagerMap = new Map<Id, EUR_TR_Employee__c>();
            Map<Id, EUR_TR_Employee__c> preSellerMap = new Map<Id, EUR_TR_Employee__c>();

            if (currentUserRole[0].DeveloperName == 'EUR_TR_TopEx') {

                areaManagerMap = new Map<Id, EUR_TR_Employee__c>([
                        SELECT Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c, EUR_TR_Title__c
                        FROM EUR_TR_Employee__c
                        WHERE RecordType.DeveloperName = 'EUR_TR_AreaManager'
                ]);

                salesChiefMap = new Map<Id, EUR_TR_Employee__c>([
                        SELECT Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c, EUR_TR_Title__c
                        FROM EUR_TR_Employee__c
                        WHERE RecordType.DeveloperName = 'EUR_TR_SalesChief'
                        AND EUR_TR_ReportsTo_AreaManager__c = :areaManagerMap.keySet()
                ]);

                preSellerMap = new Map<Id, EUR_TR_Employee__c>([
                        SELECT Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c, EUR_TR_Title__c
                        FROM EUR_TR_Employee__c
                        WHERE RecordType.DeveloperName = 'EUR_TR_Preseller'
                        AND EUR_TR_ReportsTo_Chief__c = :salesChiefMap.keySet()
                ]);

            } else {

                if (currentUserEmployeeRecord.RecordType.DeveloperName.contains('EUR_TR_Area')) {

                    salesChiefMap = new Map<Id, EUR_TR_Employee__c>([
                            SELECT Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c, EUR_TR_Title__c
                            FROM EUR_TR_Employee__c
                            WHERE RecordType.DeveloperName = 'EUR_TR_SalesChief'
                            AND EUR_TR_ReportsTo_AreaManager__c = :currentUserEmployeeRecord.Id
                    ]);

                    preSellerMap = new Map<Id, EUR_TR_Employee__c>([
                            SELECT Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c, EUR_TR_Title__c
                            FROM EUR_TR_Employee__c
                            WHERE RecordType.DeveloperName = 'EUR_TR_Preseller'
                            AND EUR_TR_ReportsTo_Chief__c = :salesChiefMap.keySet()
                    ]);

                } else if (currentUserEmployeeRecord.RecordType.DeveloperName == 'EUR_TR_SalesChiefs') {

                    preSellerMap = new Map<Id, EUR_TR_Employee__c>([
                            SELECT Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c, EUR_TR_Title__c
                            FROM EUR_TR_Employee__c
                            WHERE RecordType.DeveloperName = 'EUR_TR_Preseller'
                            AND EUR_TR_ReportsTo_Chief__c = :currentUserEmployeeRecord.Id
                    ]);


                }
            }

            for (EUR_TR_Employee__c areaManager : areaManagerMap.values()) {
                if (areaManager.EUR_TR_RelatedUser__c != null) {
                    userToRelatedEmployeeMap.put(areaManager.EUR_TR_RelatedUser__c, areaManager);
                }
            }

            for (EUR_TR_Employee__c salesChief : salesChiefMap.values()) {
                if (salesChief.EUR_TR_RelatedUser__c != null) {
                    userToRelatedEmployeeMap.put(salesChief.EUR_TR_RelatedUser__c, salesChief);
                }
            }

            for (EUR_TR_Employee__c preSeller : preSellerMap.values()) {
                if (preSeller.EUR_TR_RelatedUser__c != null) {
                    userToRelatedEmployeeMap.put(preSeller.EUR_TR_RelatedUser__c, preSeller);
                }
            }

            result = [
                    SELECT Id, Subject, CreatedBy.Name, What.Name, WhatId, CreatedDate, ActivityDate, Owner.Name, OwnerId,
                            PR_Activity_Type__c, Description, Status, Priority, CreatedById, Cliente__c, (
                            SELECT ContentDocumentId, FileType
                            FROM AttachedContentDocuments
                    )
                    FROM Task
                    WHERE RecordType.DeveloperName = 'EUR_TR_Task'
                    AND PR_Activity_Type__c = :kind
                    AND OwnerId = :userToRelatedEmployeeMap.keySet()
                    ORDER BY CreatedDate DESC
                    LIMIT :taskRequest.pageSize
                    OFFSET :taskRequest.pageSize * (taskRequest.pageNumber - 1)
            ];

            resultWrappers = prepareResultWrapperListWithEmployeeTitle(userToRelatedEmployeeMap, result);


        }

        response.Code = 1;
        response.Message = SuccessMessage;
        response.ExtensionData = resultWrappers;
        return response;
    }

    private static List<TaskResultWrapper> prepareResultWrapperListWithEmployeeTitle(Map<Id, EUR_TR_Employee__c> userToRelatedEmployeeMap, List<Task> result) {
        List<TaskResultWrapper> resultWrappers = new List<TaskResultWrapper>();
        TaskResultWrapper wrapper = new TaskResultWrapper();

        Set<Id> accIds = new Set<Id>();
        for (Task tsk : result) {
            if (tsk.WhatId != null) {
                accIds.add(tsk.WhatId);
            }
        }
        Map<Id,EUR_TR_Account__c> accopuntMap = new Map<Id, EUR_TR_Account__c>();
        if (accIds.size() > 0) {
            List<EUR_TR_Account__c> Accounts= [SELECT Id, EUR_TR_PresellerName__c FROM EUR_TR_Account__c WHERE Id IN :accIds];
            for (EUR_TR_Account__c acc : Accounts){
                if (!accopuntMap.containsKey(acc.Id)){
                    accopuntMap.put(acc.Id, acc);
                }
            }
        }
        for (Task tsk : result) {
            wrapper = new TaskResultWrapper();
            wrapper.task = tsk;
            if (userToRelatedEmployeeMap.containsKey(tsk.OwnerId) && userToRelatedEmployeeMap.get(tsk.OwnerId).EUR_TR_Title__c != null) {
                wrapper.ownerTitle = userToRelatedEmployeeMap.get(tsk.OwnerId).EUR_TR_Title__c;
            }
            if (userToRelatedEmployeeMap.containsKey(tsk.CreatedById) && userToRelatedEmployeeMap.get(tsk.CreatedById).EUR_TR_Title__c != null) {
                wrapper.createdByTitle = userToRelatedEmployeeMap.get(tsk.CreatedById).EUR_TR_Title__c;
            }
            if (wrapper.ownerTitle == null) {
                wrapper.ownerTitle = '';
            }
            if (wrapper.createdByTitle == null) {
                wrapper.createdByTitle = '';
            }
            if (accopuntMap.containsKey(tsk.WhatId) && accopuntMap.get(tsk.WhatId).EUR_TR_PresellerName__c != null) {
                wrapper.presellerName = accopuntMap.get(tsk.WhatId).EUR_TR_PresellerName__c;
            }
            if (wrapper.presellerName == null) {
                wrapper.presellerName = '';
            }
            resultWrappers.add(wrapper);
        }
        return resultWrappers;
    }

    private static List<EUR_TR_Employee__c> getEmployeesByTaskOwner(List<Task> result) {

        Set<Id> ownerIds = new Set<Id>();
        for (Task tsk : result) {
            if (tsk.OwnerId != null) {
                ownerIds.add(tsk.OwnerId);
            }
            if (tsk.CreatedById != null) {
                ownerIds.add(tsk.CreatedById);
            }
        }

        List<EUR_TR_Employee__c> relatedEmployeesByOwnerIds = [
                SELECT Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c, EUR_TR_Title__c
                FROM EUR_TR_Employee__c
                WHERE EUR_TR_RelatedUser__c = :ownerIds
        ];

        return relatedEmployeesByOwnerIds;
    }

    global static PostServiceResponse addTaskByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'WhatId parametresi boş olamaz';
            return response;
        }

        Task task = (Task) JSON.deserialize(requestBody, Task.class);

        if (String.isBlank(task.WhatId)) {
            response.Code = -1;
            response.Message = 'WhatId parametresi boş olamaz';
            return response;
        }
        if (String.isBlank(task.PR_Activity_Type__c)) {
            response.Code = -1;
            response.Message = 'PR_Activity_Type__c parametresi boş olamaz';
            return response;
        }
        if (String.isBlank(task.Description)) {
            response.Code = -1;
            response.Message = 'Description parametresi boş olamaz';
            return response;
        }
        if (task.ActivityDate == null) {
            response.Code = -1;
            response.Message = 'ActivityDate parametresi boş olamaz';
            return response;
        }
        if (task.PR_Activity_Type__c == 'Salesforce') {
            if (String.isBlank(task.OwnerId)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';
                return response;
            }
        }

        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_Account__c relatedAccount = [SELECT Id, OwnerId, RecordType.DeveloperName FROM EUR_TR_Account__c WHERE Id = :task.WhatId];
            if (task.PR_Activity_Type__c != 'Salesforce' && relatedAccount.RecordType.DeveloperName == 'EUR_TR_TAPDK'){
                response.Code = -1;
                response.Message = 'Müşteri kapsam dışı olduğundan görev atanacak bir temsilci bulunmamaktadır!';
                return response;
            }

            task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('EUR_TR_Task').getRecordTypeId();
            task.Subject = 'Other';
            task.Status = 'Not started';
            task.Priority = 'Normal';
            task.OwnerId = task.PR_Activity_Type__c == 'Salesforce' ? task.OwnerId : relatedAccount.OwnerId;

            insert task;

            Task result = [
                    SELECT Id, Subject, What.Name, WhatId, CreatedDate, ActivityDate, Owner.Name, OwnerId, PR_Activity_Type__c,
                            Description, Status, Priority, Cliente__c
                    FROM Task
                    WHERE Id = :task.Id
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.ExtensionData = result;
        } catch (Exception exc) {
            System.debug(exc);
            Database.rollback(savepoint);

            response.Code = -1;
            response.Message = exc.getMessage();
        }

        return response;
    }

    global static PostServiceResponse listTRUsers(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        EUR_TR_Account__c requestAccount = (EUR_TR_Account__c) JSON.deserialize(requestBody, EUR_TR_Account__c.class);

        if (String.isBlank(requestAccount.Id)) {
            throw new customException('Id parametresi boş olamaz.');
        }

        EUR_TR_Account__c account = [
                SELECT Id,
                        EUR_TR_SalesChiefName__c,
                        EUR_TR_AreaManagerName__c,
                        EUR_TR_ChannelManagerName__c,
                        EUR_TR_TopExManagerName__c
                FROM EUR_TR_Account__c
                WHERE Id = :requestAccount.Id
        ];

        // Queried names from EUR_TR_Employee__c instead of User. Because Names in User table are not written with Turkish characters.
        List<EUR_TR_Employee__c> employees = [
                SELECT EUR_TR_RelatedUser__c
                FROM EUR_TR_Employee__c
                WHERE Name IN (
                        :account.EUR_TR_SalesChiefName__c,
                        :account.EUR_TR_AreaManagerName__c
                )
                AND Name != NULL
        ];

        Set<Id> relatedUserIds = new Set<Id>();
        for (EUR_TR_Employee__c employee : employees) {
            relatedUserIds.add(employee.EUR_TR_RelatedUser__c);
        }

        List<User> users = [
                SELECT Id,
                        Name,
                        UserRole.Name,
                        UserRole.DeveloperName,
                        Title
                FROM User
                WHERE IsActive = TRUE
                AND (
                        Profile.Name = 'EUR TR Trade Tool Admin'
                        OR Id IN :relatedUserIds
                        OR Name IN (
                                :account.EUR_TR_ChannelManagerName__c,
                                :account.EUR_TR_TopExManagerName__c
                        )
                )
        ];

        response.Code = 1;
        response.Message = SuccessMessage;
        response.Data = users;

        return response;
    }

    global static PostServiceResponse completeTaskById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Id parametresi boş olamaz';

            return response;
        }

        Savepoint savepoint = Database.setSavepoint();

        try {
            Task task = (Task) JSON.deserialize(requestBody, Task.class);

            if (String.isBlank(task.Id)) {
                response.Code = -1;
                response.Message = 'Id parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(task.PR_Achievement_Detail__c)) {
                response.Code = -1;
                response.Message = 'PR_Achievement_Detail__c parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(task.Status)) {
                response.Code = -1;
                response.Message = 'Status parametresi boş olamaz';
                return response;
            }

            Task readOnlyTask = [SELECT Id, Status, PR_Achievement_Detail__c, OwnerId FROM Task WHERE Id = :task.Id];
            if (readOnlyTask.OwnerId != UserInfo.getUserId()) {
                List<PermissionSetAssignment> permissionSets = [
                        SELECT Id
                        FROM PermissionSetAssignment
                        WHERE AssigneeId = :UserInfo.getUserId()
                        AND PermissionSet.Name = 'EUR_TR_TradeTool_Admin_WOL'
                ];

                if (permissionSets.isEmpty()) {
                    response.Code = -1;
                    response.Message = 'Görevler yalnızca atama yapılan kişiler tarafından tamamlanabilir.';

                    return response;
                }
            }

            update task;

            Task result = [
                    SELECT Id, Subject, What.Name, WhatId, CreatedDate, ActivityDate, Owner.Name, OwnerId, PR_Activity_Type__c,
                            Description, Status, Priority, PR_Achievement_Detail__c, Cliente__c
                    FROM Task
                    WHERE Id = :task.Id
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.ExtensionData = result;
        } catch (Exception exc) {
            System.debug(exc);
            Database.rollback(savepoint);

            response.Code = -1;
            response.Message = exc.getMessage();
        }

        return response;
    }

    global static PostServiceResponse listPosmByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_POSM__c> body = (List<EUR_TR_POSM__c>) JSON.deserialize(requestBody, List<EUR_TR_POSM__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_POSM__c> result = [
                    select Id, EUR_TR_ApprovalStatus__c, EUR_TR_Brand__c, EUR_TR_BrandOther__c, EUR_TR_Budget__c, EUR_TR_PlacementDate__c, EUR_TR_POSMType__c,
                            EUR_TR_RelatedAccount__c, CreatedDate, OwnerId, Owner.Name, CurrencyIsoCode, (
                            SELECT Id, Name,
                                    EUR_TR_Approver__r.Name, EUR_TR_Submitter__r.Name,
                                    EUR_TR_ApprovalStatus__c, EUR_TR_ApprovalReason__c, EUR_TR_ApprovalProcessType__c
                            FROM EUR_TR_POSM_Approvals__r
                            WHERE RecordType.DeveloperName = 'EUR_TR_POSMApproval'
                            ORDER BY CreatedDate DESC
                            LIMIT 1
                    )
                    from EUR_TR_POSM__c
                    where RecordType.DeveloperName = 'EUR_TR_POSM'
                    and EUR_TR_RelatedAccount__c = :relatedAccount
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse addPosmByAccountId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_POSM__c> body = (List<EUR_TR_POSM__c>) JSON.deserialize(requestBody, List<EUR_TR_POSM__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
            String type = body[0].EUR_TR_POSMType__c;
            String placementDate = String.valueOf(body[0].EUR_TR_PlacementDate__c);
            String brand = body[0].EUR_TR_Brand__c;
            String brandOther = body[0].EUR_TR_BrandOther__c;
            String budget = String.valueOf(body[0].EUR_TR_Budget__c);

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(type)) {
                response.Code = -1;
                response.Message = 'EUR_TR_POSMType__c parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(placementDate)) {
                response.Code = -1;
                response.Message = 'EUR_TR_PlacementDate__c parametresi boş olamaz';
                return response;
            }
/*if (String.isBlank(brand)){
    response.Code = -1;
    response.Message = 'EUR_TR_POSMBrand__c parametresi boş olamaz';
    return response;
}*/
            if (brand == 'Other') {
                if (String.isBlank(brandOther)) {
                    response.Code = -1;
                    response.Message = 'EUR_TR_BrandOther__c parametresi boş olamaz';
                    return response;
                }
            }

            RecordType rt = [select Id from RecordType where DeveloperName = 'EUR_TR_POSM' and sObjectType = 'EUR_TR_POSM__c'][0];
            EUR_TR_POSM__c t = new EUR_TR_POSM__c();
            t.RecordTypeId = rt.Id;
            t.EUR_TR_RelatedAccount__c = relatedAccount;
            t.EUR_TR_POSMType__c = type;
            t.EUR_TR_PlacementDate__c = body[0].EUR_TR_PlacementDate__c;

            if (String.isNotBlank(brand))
                t.EUR_TR_Brand__c = brand;

            if (String.isNotBlank(brandOther))
                t.EUR_TR_BrandOther__c = brandOther;

            t.EUR_TR_Budget__c = body[0].EUR_TR_Budget__c;
            insert t;

            List<EUR_TR_POSM__c> result = [
                    select Id, EUR_TR_Brand__c, EUR_TR_BrandOther__c, EUR_TR_Budget__c, EUR_TR_PlacementDate__c, EUR_TR_POSMType__c,
                            EUR_TR_RelatedAccount__c, CreatedDate, OwnerId, Owner.Name, CurrencyIsoCode
                    from EUR_TR_POSM__c
                    where RecordType.DeveloperName = 'EUR_TR_POSM'
                    and Id = :t.Id
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listRoutesByOwnerIdByFavorite(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Route__c> body = (List<EUR_TR_Route__c>) JSON.deserialize(requestBody, List<EUR_TR_Route__c>.class);
            String owner = body[0].OwnerId;
            String favorite = String.valueOf(body[0].EUR_TR_IsFavorite__c);

            if (String.isBlank(owner)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(favorite)) {
                response.Code = -1;
                response.Message = 'EUR_TR_IsFavorite__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_Route__c> result = [
                    select Id, Name, EUR_TR_IsFavorite__c, EUR_TR_SelectedFilters__c
                    from EUR_TR_Route__c
                    where RecordType.DeveloperName = 'EUR_TR_RouteTemplate'
                    and OwnerId = :owner
                    and EUR_TR_IsFavorite__c = :body[0].EUR_TR_IsFavorite__c
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse addRouteByOwnerId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Route__c> body = (List<EUR_TR_Route__c>) JSON.deserialize(requestBody, List<EUR_TR_Route__c>.class);
            String owner = body[0].OwnerId;
            String favorite = String.valueOf(body[0].EUR_TR_IsFavorite__c);
            String name = body[0].Name;
            String filters = body[0].EUR_TR_SelectedFilters__c;

            if (String.isBlank(name)) {
                response.Code = -1;
                response.Message = 'Name parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(owner)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(favorite)) {
                response.Code = -1;
                response.Message = 'EUR_TR_IsFavorite__c parametresi boş olamaz';
                return response;
            }

            RecordType rt = [select Id from RecordType where DeveloperName = 'EUR_TR_RouteTemplate' and sObjectType = 'EUR_TR_Route__c'][0];
            EUR_TR_Route__c t = new EUR_TR_Route__c();
            t.RecordTypeId = rt.Id;
            t.Name = name;
            t.EUR_TR_IsFavorite__c = body[0].EUR_TR_IsFavorite__c;
            t.OwnerId = owner;
            if (String.isNotBlank(filters)) {
                t.EUR_TR_SelectedFilters__c = filters;
            }
            insert t;

            List<EUR_TR_Route__c> result = [
                    select Id, Name, EUR_TR_IsFavorite__c, OwnerId, EUR_TR_SelectedFilters__c
                    from EUR_TR_Route__c
                    where RecordType.DeveloperName = 'EUR_TR_RouteTemplate'
                    and Id = :t.Id
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse editRouteById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Id parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Route__c> body = (List<EUR_TR_Route__c>) JSON.deserialize(requestBody, List<EUR_TR_Route__c>.class);
            String routeId = body[0].Id;
            String favorite = String.valueOf(body[0].EUR_TR_IsFavorite__c);
            String name = body[0].Name;
            String filters = body[0].EUR_TR_SelectedFilters__c;

            if (String.isBlank(name)) {
                response.Code = -1;
                response.Message = 'Name parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(favorite)) {
                response.Code = -1;
                response.Message = 'EUR_TR_IsFavorite__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_Route__c> foundRoute = [
                    select Id, Name, EUR_TR_IsFavorite__c, OwnerId, EUR_TR_SelectedFilters__c
                    from EUR_TR_Route__c
                    where RecordType.DeveloperName = 'EUR_TR_RouteTemplate'
                    and Id = :routeId
            ];

            foundRoute[0].Name = name;
            foundRoute[0].EUR_TR_IsFavorite__c = body[0].EUR_TR_IsFavorite__c;
            if (String.isNotBlank(filters)) {
                foundRoute[0].EUR_TR_SelectedFilters__c = filters;
            }

            update foundRoute[0];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = foundRoute;
            return response;
        }
    }

    global static PostServiceResponse removeRouteById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'Id parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Route__c> body = (List<EUR_TR_Route__c>) JSON.deserialize(requestBody, List<EUR_TR_Route__c>.class);
            String routeId = body[0].Id;

            if (String.isBlank(routeId)) {
                response.Code = -1;
                response.Message = 'Id parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_Route__c> result = [
                    select Id, Name, EUR_TR_IsFavorite__c, OwnerId, EUR_TR_SelectedFilters__c
                    from EUR_TR_Route__c
                    where RecordType.DeveloperName = 'EUR_TR_RouteTemplate'
                    and Id = :routeId
            ];

            delete result;

            response.Code = 1;
            response.Message = SuccessMessage;
            return response;
        }
    }

    global static PostServiceResponse listAccountsByOwnerIdByRouteId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Route__c> body = (List<EUR_TR_Route__c>) JSON.deserialize(requestBody, List<EUR_TR_Route__c>.class);
            String owner = body[0].OwnerId;
            String id = body[0].Id;

            if (String.isBlank(owner)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(id)) {
                response.Code = -1;
                response.Message = 'Id parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_RouteDetail__c> result = [
                    select Id, EUR_TR_RelatedAccount__c, EUR_TR_RelatedAccount__r.Name,
                            EUR_TR_RelatedAccount__r.EUR_TR_Location__Latitude__s,
                            EUR_TR_RelatedAccount__r.EUR_TR_Location__Longitude__s, EUR_TR_VisitOrder__c,
                            EUR_TR_IsVisitedInToday__c, EUR_TR_VisitDateTime__c,
                            EUR_TR_RelatedAccount__r.EUR_TR_MATCY__c, EUR_TR_RelatedAccount__r.EUR_TR_MATLY__c,
                            EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c, EUR_TR_RelatedAccount__r.EUR_TR_FavoriteCount__c,
                            EUR_TR_RelatedAccount__r.EUR_TR_LastVisitedDate__c
                    from EUR_TR_RouteDetail__c
                    where RecordType.DeveloperName = 'EUR_TR_RouteDetailTemplate'
                    and EUR_TR_RelatedRoute__r.Owner.Id = :owner
                    and EUR_TR_RelatedRoute__c = :id
                    order by EUR_TR_VisitOrder__c
            ];

            Set<Id> accountIds = new Set<Id>();
            for (EUR_TR_RouteDetail__c e : result) {
                if (!accountIds.contains(e.EUR_TR_RelatedAccount__c)) {
                    accountIds.add(e.EUR_TR_RelatedAccount__c);
                }
            }

            String query = '';
            query += 'select Id, EUR_TR_MATCY__c, EUR_TR_MATLY__c, EUR_TR_LastVisitedDate__c, EUR_TR_FavoriteCount__c, ';
            query += '(select EUR_TR_StartDateTime__c from EUR_TR_Visits__r where OwnerId = :owner order by EUR_TR_StartDateTime__c desc limit 1), ';
            query += '(select Id from EUR_TR_Route_Detail__r where EUR_TR_RelatedRoute__r.OwnerId = :owner and EUR_TR_RelatedRoute__r.EUR_TR_IsFavorite__c=true)';
            query += 'FROM EUR_TR_Account__c Where Id in :accountIds';
            List<EUR_TR_Account__c> accounts = Database.query(query);

            Map<Id, AggregateResult> totalSalesMap = new Map<Id, AggregateResult>();
            for (AggregateResult ar : [
                    select EUR_TR_RelatedAccount__c, sum(EUR_TR_MAT1__c) mat1, sum(EUR_TR_MAT2__c) mat2
                    from EUR_TR_AccountSalesMAT__c
                    where EUR_TR_RelatedAccount__c in :accountIds
                    group by EUR_TR_RelatedAccount__c
            ]) {
                Id relatedAccount = String.valueOf(ar.get('EUR_TR_RelatedAccount__c'));
                if (!totalSalesMap.containsKey(relatedAccount)) {
                    totalSalesMap.put(relatedAccount, ar);
                }
            }

            Map<Id, EUR_TR_Account__c> accountMap = new Map<Id, EUR_TR_Account__c>();

            for (EUR_TR_Account__c a : accounts) {
                Decimal cy = 0;
                Decimal ly = 0;

                if (totalSalesMap.get(a.Id) != null) {
                    cy = Decimal.valueOf(String.valueOf(totalSalesMap.get(a.Id).get('mat1')));
                    ly = Decimal.valueOf(String.valueOf(totalSalesMap.get(a.Id).get('mat2')));
                }

                a.EUR_TR_MATCY__c = cy;
                a.EUR_TR_MATLY__c = ly;

                if (a.EUR_TR_Visits__r != null) {
                    List<EUR_TR_Visit__c> visits = a.EUR_TR_Visits__r;
                    if (visits.size() > 0) {
                        a.EUR_TR_LastVisitedDate__c = visits[0].EUR_TR_StartDateTime__c;
                    } else {
                        a.EUR_TR_LastVisitedDate__c = null;
                    }
                } else {
                    a.EUR_TR_LastVisitedDate__c = null;
                }

                if (a.EUR_TR_Route_Detail__r != null) {
                    List<EUR_TR_RouteDetail__c> favorites = a.EUR_TR_Route_Detail__r;
                    a.EUR_TR_FavoriteCount__c = favorites.size();
                } else {
                    a.EUR_TR_FavoriteCount__c = 0;
                }

                if (!accountMap.containsKey(a.Id)) {
                    accountMap.put(a.Id, a);
                }
            }

            for (EUR_TR_RouteDetail__c a : result) {
                if (accountMap.containsKey(a.EUR_TR_RelatedAccount__c)) {
                    a.EUR_TR_RelatedAccount__r.EUR_TR_MATCY__c = accountMap.get(a.EUR_TR_RelatedAccount__c).EUR_TR_MATCY__c;
                    a.EUR_TR_RelatedAccount__r.EUR_TR_MATLY__c = accountMap.get(a.EUR_TR_RelatedAccount__c).EUR_TR_MATLY__c;
                    a.EUR_TR_RelatedAccount__r.EUR_TR_FavoriteCount__c = accountMap.get(a.EUR_TR_RelatedAccount__c).EUR_TR_FavoriteCount__c;
                    a.EUR_TR_RelatedAccount__r.EUR_TR_LastVisitedDate__c = accountMap.get(a.EUR_TR_RelatedAccount__c).EUR_TR_LastVisitedDate__c;
                }
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse addAccountToRouteByAccountIdByRouteId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedRoute__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_RouteDetail__c> body = (List<EUR_TR_RouteDetail__c>) JSON.deserialize(requestBody, List<EUR_TR_RouteDetail__c>.class);
            String relatedRoute = body[0].EUR_TR_RelatedRoute__c;
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;
            Decimal visitOrder = body[0].EUR_TR_VisitOrder__c;

            if (String.isBlank(relatedRoute)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedRoute__c parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            RecordType rt = [select Id from RecordType where DeveloperName = 'EUR_TR_RouteDetailTemplate' and sObjectType = 'EUR_TR_RouteDetail__c'][0];
            List<EUR_TR_RouteDetail__c> result = new List<EUR_TR_RouteDetail__c>();

            List<EUR_TR_RouteDetail__c> existingLists = [select Id from EUR_TR_RouteDetail__c where EUR_TR_RelatedRoute__c = :relatedRoute and EUR_TR_RelatedAccount__c = :relatedAccount];
            if (existingLists.isEmpty()) {
                EUR_TR_Account__c account = [select Id, EUR_TR_FavoriteCount__c from EUR_TR_Account__c where Id = :relatedAccount][0];
                account.EUR_TR_FavoriteCount__c = String.isBlank(String.valueOf(account.EUR_TR_FavoriteCount__c)) ? 1 : account.EUR_TR_FavoriteCount__c + 1;
                update account;

                EUR_TR_RouteDetail__c t = new EUR_TR_RouteDetail__c();
                t.RecordTypeId = rt.Id;
                t.EUR_TR_RelatedRoute__c = relatedRoute;
                t.EUR_TR_RelatedAccount__c = relatedAccount;
                t.EUR_TR_VisitOrder__c = visitOrder;
                insert t;

                result = [
                        select Id, Name, EUR_TR_RelatedRoute__c, EUR_TR_RelatedAccount__c, EUR_TR_VisitOrder__c, EUR_TR_RelatedAccount__r.Name,
                                EUR_TR_RelatedAccount__r.EUR_TR_Location__Latitude__s,
                                EUR_TR_RelatedAccount__r.EUR_TR_Location__Longitude__s
                        from EUR_TR_RouteDetail__c
                        where RecordType.DeveloperName = 'EUR_TR_RouteDetailTemplate'
                        and Id = :t.Id
                ];
            } else {
                result = [
                        select Id, Name, EUR_TR_RelatedRoute__c, EUR_TR_RelatedAccount__c, EUR_TR_VisitOrder__c, EUR_TR_RelatedAccount__r.Name,
                                EUR_TR_RelatedAccount__r.EUR_TR_Location__Latitude__s,
                                EUR_TR_RelatedAccount__r.EUR_TR_Location__Longitude__s
                        from EUR_TR_RouteDetail__c
                        where RecordType.DeveloperName = 'EUR_TR_RouteDetailTemplate'
                        and EUR_TR_RelatedAccount__c = :relatedAccount
                        and EUR_TR_RelatedRoute__c = :relatedRoute
                ];
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse removeAccountInRouteByAccountIdByRouteId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedRoute__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_RouteDetail__c> body = (List<EUR_TR_RouteDetail__c>) JSON.deserialize(requestBody, List<EUR_TR_RouteDetail__c>.class);
            String relatedRoute = body[0].EUR_TR_RelatedRoute__c;
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedRoute)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedRoute__c parametresi boş olamaz';
                return response;
            }
            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            EUR_TR_Account__c account = [select Id, EUR_TR_FavoriteCount__c from EUR_TR_Account__c where Id = :relatedAccount][0];
            account.EUR_TR_FavoriteCount__c = String.isBlank(String.valueOf(account.EUR_TR_FavoriteCount__c)) ? 1 : account.EUR_TR_FavoriteCount__c - 1;
            update account;

            EUR_TR_RouteDetail__c t = [select Id from EUR_TR_RouteDetail__c where Id = :relatedRoute and EUR_TR_RelatedAccount__c = :relatedAccount][0];
            delete t;

            response.Code = 1;
            response.Message = SuccessMessage;
            return response;
        }
    }

    global static PostServiceResponse listTargetsByOwnerId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Target__c> body = (List<EUR_TR_Target__c>) JSON.deserialize(requestBody, List<EUR_TR_Target__c>.class);
            String relatedOwner = body[0].OwnerId;

            if (String.isBlank(relatedOwner)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';
                return response;
            }

            List<User> allUsers = [select Id from User where Id = :relatedOwner];
            List<EUR_TR_Target__c> result = new List<EUR_TR_Target__c>();
            if (!allUsers.isEmpty()) {
                result = [
                        select Id, EUR_TR_Period__c, EUR_TR_RelatedEmployee__c, EUR_TR_RelatedEmployee__r.Name, EUR_TR_EmployeeName__c,
                                EUR_TR_Brand__c, EUR_TR_TargetAmount__c, EUR_TR_ExternalId__c, EUR_TR_ActualAmount__c, EUR_TR_RemainingAmount__c, EUR_TR_TargetPercentage__c
                        from EUR_TR_Target__c
                        where RecordType.DeveloperName = 'EUR_TR_Target'
                        and EUR_TR_RelatedEmployee__r.EUR_TR_RelatedUser__c = :relatedOwner
                        order by EUR_TR_CustomSortOrder__c
                ];
            } else {
                result = [
                        select Id, EUR_TR_Period__c, EUR_TR_RelatedEmployee__c, EUR_TR_RelatedEmployee__r.Name, EUR_TR_EmployeeName__c,
                                EUR_TR_Brand__c, EUR_TR_TargetAmount__c, EUR_TR_ExternalId__c, EUR_TR_ActualAmount__c, EUR_TR_RemainingAmount__c, EUR_TR_TargetPercentage__c
                        from EUR_TR_Target__c
                        where RecordType.DeveloperName = 'EUR_TR_Target'
                        and EUR_TR_RelatedEmployee__c = :relatedOwner
                        order by EUR_TR_CustomSortOrder__c
                ];
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listMATReportByAccountIdByBrand(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_AccountSalesMAT__c> body = (List<EUR_TR_AccountSalesMAT__c>) JSON.deserialize(requestBody, List<EUR_TR_AccountSalesMAT__c>.class);
            String relatedAccount = body[0].EUR_TR_RelatedAccount__c;

            if (String.isBlank(relatedAccount)) {
                response.Code = -1;
                response.Message = 'EUR_TR_RelatedAccount__c parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_AccountSalesMAT__c> result = new List<EUR_TR_AccountSalesMAT__c>();

/*String query = 'select Id, EUR_TR_BrandQualitySize__c,';
query += 'EUR_TR_RelatedAccount__c, EUR_TR_MAT1__c, EUR_TR_MAT2__c, EUR_TR_MAT3__c, EUR_TR_MAT4__c, EUR_TR_MAT5__c ';
query += 'from EUR_TR_AccountSalesMAT__c where EUR_TR_RelatedAccount__c =:relatedAccount ';
query += 'and RecordType.DeveloperName = :recordType ';
query += ' order by EUR_TR_MAT1__c desc limit 6 ';*/

            List<AggregateResult> resultNew = [
                    select max(Id) id, EUR_TR_Brand__c, max(EUR_TR_RelatedAccount__c) acc,
                            sum(EUR_TR_MAT1__c) t1, sum(EUR_TR_MAT2__c) t2, sum(EUR_TR_MAT3__c) t3, sum(EUR_TR_MAT4__c) t4, sum(EUR_TR_MAT5__c) t5
                    from EUR_TR_AccountSalesMAT__c
                    where EUR_TR_RelatedAccount__c = :relatedAccount
                    group by EUR_TR_Brand__c
                    order by sum(EUR_TR_MAT1__c) desc
                    limit 6
            ];

            for (AggregateResult r : resultNew) {
                EUR_TR_AccountSalesMAT__c r1 = new EUR_TR_AccountSalesMAT__c();
                r1.Id = Id.valueOf(String.valueOf(r.get('id')));
                r1.EUR_TR_BrandQualitySize__c = String.valueOf(r.get('EUR_TR_Brand__c'));
                r1.EUR_TR_RelatedAccount__c = String.valueOf(r.get('acc'));
                r1.EUR_TR_MAT1__c = Decimal.valueOf(String.valueOf(r.get('t1')));
                r1.EUR_TR_MAT2__c = Decimal.valueOf(String.valueOf(r.get('t2')));
                r1.EUR_TR_MAT3__c = Decimal.valueOf(String.valueOf(r.get('t3')));
                r1.EUR_TR_MAT4__c = Decimal.valueOf(String.valueOf(r.get('t4')));
                r1.EUR_TR_MAT5__c = Decimal.valueOf(String.valueOf(r.get('t5')));
                result.add(r1);
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }

    global static PostServiceResponse listEmployeesByUserId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Employee__c> body = (List<EUR_TR_Employee__c>) JSON.deserialize(requestBody, List<EUR_TR_Employee__c>.class);
            String relatedOwner = body[0].OwnerId;

            if (String.isBlank(relatedOwner)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';
                return response;
            }

            List<User> currentUser = [select Id, Profile.Name, UserRoleId from User where Id = :UserInfo.getUserId()];
            List<UserRole> currentUserRole = [select DeveloperName, Id from UserRole where Id = :UserInfo.getUserRoleId()];

            List<EUR_TR_Employee__c> employees = new List<EUR_TR_Employee__c>();
            system.debug('relatedOwner: ' + relatedOwner);
            system.debug('UserInfo.getUserId(): ' + UserInfo.getUserId());

            if (currentUserRole[0].DeveloperName == 'EUR_TR_TopEx' && relatedOwner == UserInfo.getUserId()) {
                employees = [
                        select Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c
                        from EUR_TR_Employee__c
                        where RecordType.DeveloperName = 'EUR_TR_AreaManager'
                ];
            } else {
                List<User> allUsers = [select Id from USer where Id = :relatedOwner];
                List<EUR_TR_Employee__c> selectedEmployee = new List<EUR_TR_Employee__c>();
                if (!allUsers.isEmpty()) {
                    selectedEmployee = [select Id, EUR_TR_RelatedUser__c, RecordType.Developername from EUR_TR_Employee__c where EUR_TR_RelatedUser__c = :relatedOwner];
                } else {
                    selectedEmployee = [select Id,EUR_TR_RelatedUser__c, RecordType.Developername from EUR_TR_Employee__c where Id = :relatedOwner];
                }

                if (selectedEmployee[0].RecordType.DeveloperName == 'EUR_TR_AreaManager') {
                    employees = [
                            select Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c
                            from EUR_TR_Employee__c
                            where RecordType.DeveloperName = 'EUR_TR_SalesChief'
                            and EUR_TR_ReportsTo_AreaManager__c = :selectedEmployee[0].Id
                    ];
                } else if (selectedEmployee[0].RecordType.DeveloperName == 'EUR_TR_SalesChief') {
                    employees = [
                            select Id, Name, RecordType.DeveloperName, EUR_TR_RelatedUser__c
                            from EUR_TR_Employee__c
                            where RecordType.DeveloperName = 'EUR_TR_Preseller'
                            and EUR_TR_ReportsTo_Chief__c = :selectedEmployee[0].Id
                    ];
                }
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = employees;
            return response;
        }
    }

    global static PostServiceResponse listAnnouncementsByOwnerId(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();
        if (String.isBlank(requestBody)) {
            response.Code = -1;
            response.Message = 'OwnerId parametresi boş olamaz';
            return response;
        } else {
            List<EUR_TR_Announcement__c> body = (List<EUR_TR_Announcement__c>) JSON.deserialize(requestBody, List<EUR_TR_Announcement__c>.class);
            String relatedOwner = body[0].OwnerId;

            if (String.isBlank(relatedOwner)) {
                response.Code = -1;
                response.Message = 'OwnerId parametresi boş olamaz';
                return response;
            }

            List<EUR_TR_Announcement__c> result = [
                    select EUR_TR_RelatedAnnouncement__r.Id, EUR_TR_RelatedAnnouncement__r.Name, EUR_TR_RelatedAnnouncement__r.CreatedDate,
                            EUR_TR_RelatedAnnouncement__r.EUR_TR_AnnouncementText__c,
                            EUR_TR_IsRead__c, EUR_TR_ReadedDate__c,
                            EUR_TR_POSMRelatedApproval__r.Id,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_ApprovalStatus__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_ApprovalReason__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_ApprovalProcessType__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_Submitter__r.Name,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_Approver__r.Name,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.Name,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.EUR_TR_Brand__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.EUR_TR_BrandOther__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.EUR_TR_Budget__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.EUR_TR_PlacementDate__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.EUR_TR_POSMType__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.EUR_TR_ApprovalStatus__c,
                            EUR_TR_POSMRelatedApproval__r.EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__r.Name,
                            EUR_TR_RelatedSurvey__c,
                            EUR_TR_RelatedSurvey__r.EUR_TR_TargetRelatedTemplate__c
                    from EUR_TR_Announcement__c
                    where RecordType.DeveloperName = 'EUR_TR_AnnouncementTarget'
                    and EUR_TR_RelatedAnnouncement__c != null
                    and OwnerId = :relatedOwner
                    order by EUR_TR_RelatedAnnouncement__r.CreatedDate desc
            ];

            response.Code = 1;
            response.Message = SuccessMessage;
            response.Data = result;
            return response;
        }
    }


    global static PostServiceResponse getAnnouncementByIdFromMiddleware(String requestBody) {

        PostServiceResponse response = new PostServiceResponse();
        try {

            if (String.isBlank(requestBody)) {
                response.Code = -1;
                response.Message = 'Bildirim Id boş bırakılamaz';
                return response;
            }

            EUR_TR_Announcement__c targetAnnouncement = (EUR_TR_Announcement__c) JSON.deserialize(requestBody, EUR_TR_Announcement__c.class);

            if (String.isBlank(targetAnnouncement.EUR_TR_RelatedAnnouncement__c)) {
                response.Code = -1;
                response.Message = 'Bildirim Id boş bırakılamaz';
                return response;
            }

            response.Code = 1;
            response.Message = SuccessMessage;
            response.ExtensionData = getAnnouncementById(targetAnnouncement.EUR_TR_RelatedAnnouncement__c);

        } catch (Exception ex) {
            response.Code = -1;
            response.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return response;

    }

    @AuraEnabled
    global static EUR_TR_Announcement__c getAnnouncementById(Id announcementId) {

        List<EUR_TR_Announcement__c> targets = [
                select Id, EUR_TR_IsRead__c
                from EUR_TR_Announcement__c
                where EUR_TR_RelatedAnnouncement__c = :announcementId
                and OwnerId = :UserInfo.getUserId()
        ];

        targets[0].EUR_TR_IsRead__c = true;
        targets[0].EUR_TR_ReadedDate__c = Datetime.now();

        update targets[0];


        return [
                select Id, Name, EUR_TR_AnnouncementType__c, EUR_TR_AnnouncementAudience__c, EUR_TR_AnnouncementURL__c,
                        EUR_TR_AnnouncementText__c
                from EUR_TR_Announcement__c
                where Id = :announcementId
        ][0];
    }

    @AuraEnabled
    public static List<ContentDocumentLink> getFilesByLinkedEntityId(Id entityId) {
        return [select ContentDocumentId from ContentDocumentLink where LinkedEntityId = :entityId];
    }

    public static PostServiceResponse removeFileById(String requestBody) {
        PostServiceResponse response = new PostServiceResponse();

        try {
            ContentDocument fileToDelete = (ContentDocument) JSON.deserialize(requestBody, ContentDocument.class);

            if (String.isBlank(fileToDelete.Id)) {
                response.Code = -1;
                response.Message = 'Id parametresi boş olamaz';

                return response;
            }

            delete fileToDelete;

            response.Code = 1;
            response.Message = SuccessMessage;
        } catch (Exception exc) {
            response.Code = -1;
            response.Message = exc.getMessage();
        }

        return response;
    }

    public static PostServiceResponse getPicklistValues(String requestBody) {
        PostServiceResponse serviceResponse = new PostServiceResponse();
        RequestPicklist requestPicklist = (RequestPicklist) JSON.deserialize(requestBody, RequestPicklist.class);

        serviceResponse.Code = 1;
        serviceResponse.Message = SuccessMessage;
        serviceResponse.ExtensionData = Schema.getGlobalDescribe().get(requestPicklist.objectName).getDescribe().fields.getMap().get(requestPicklist.fieldName).getDescribe().getPicklistValues();

        return serviceResponse;
    }

    public static PostServiceResponse getRoleAndProfileInformation() {
        PostServiceResponse serviceResponse = new PostServiceResponse();

        serviceResponse.Code = 1;
        serviceResponse.Message = SuccessMessage;
        serviceResponse.Data = [
                SELECT Id,
                        UserRole.Id,
                        UserRole.Name,
                        UserRole.DeveloperName,
                        Profile.Id,
                        Profile.Name
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];

        return serviceResponse;
    }

    public class TaskRequest {
        public Task task {
            get;
            set;
        }
        public Integer pageSize {
            get;
            set;
        }
        public Integer pageNumber {
            get;
            set;
        }
    }

    public class RequestPicklist {
        public String objectName { get; set; }
        public String fieldName {
            get;
            set;
        }
    }

    public class TaskResultWrapper {
        public String ownerTitle {
            get;
            set;
        }
        public String createdByTitle {
            get;
            set;
        }
        public String presellerName {
            get;
            set;
        }
        public Task task {
            get;
            set;
        }
    }
}