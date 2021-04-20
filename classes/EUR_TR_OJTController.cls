/**
 * Created by osman on 18.09.2020.
 */

public with sharing class EUR_TR_OJTController {

    private static final Map<String, Schema.RecordTypeInfo> OJT_RT_MAP = Schema.SObjectType.EUR_TR_OJT__c.getRecordTypeInfosByDeveloperName();
    private static final String QUERY_TEMPLATE = 'SELECT {0} FROM {1} WHERE {2} ORDER BY {3} {4}';

    public static List<EUR_TR_OJT__c> listOJTQuestions() {

        return [
                SELECT
                        Id
                        ,EUR_TR_QuestionText__c
                        ,EUR_TR_QuestionOrder__c
                        ,EUR_TR_IsActive__c
                        ,EUR_TR_MinScore__c
                        ,EUR_TR_QuestionDescription__c
                        , (
                        SELECT
                                Id
                                ,EUR_TR_ControlClauseRelatedQuestion__c
                                ,EUR_TR_ControlClauseDescription__c
                        FROM EUR_TR_QuestionControlClauses__r
                )
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_Question' AND EUR_TR_IsActive__c = TRUE
        ];

    }

    public static EUR_TR_MiddlewareController.PostServiceResponse listOJTQuestionsFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        serviceResponse.Code = 1;
        serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        serviceResponse.Data = listOJTQuestions();
        return serviceResponse;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPresellerListFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        serviceResponse.Code = 1;
        serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
        serviceResponse.Data = getPresellerList();

        return serviceResponse;
    }

    public static List<EUR_TR_Employee__c> getPresellerList() {
        return [
                SELECT Id, Name, EUR_TR_EmployeeNumber__c
                FROM EUR_TR_Employee__c
                WHERE EUR_TR_ReportsTo_Chief__r.EUR_TR_RelatedUser__c = :UserInfo.getUserId()
        ];
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse createOJTPlanFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;

            createOJTPlan(ojtRequest);
        } catch (Exception exc) {
            System.debug(exc);
            Database.rollback(savepoint);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static void createOJTPlan(EUR_TR_OJT__c ojtDay) {
        System.debug('ojtDay: ' + ojtDay);

        validateOJTPlanningDates(ojtDay);

        ojtDay.RecordTypeId = OJT_RT_MAP.get('EUR_TR_OJTDay').getRecordTypeId();
        ojtDay.EUR_TR_Status__c = 'Planlandı';

        insert ojtDay;
    }

    public static void validateOJTPlanningDates(EUR_TR_OJT__c ojtDay) {
        if (ojtDay.EUR_TR_PlanedStartTime__c == null || ojtDay.EUR_TR_PlanedEndTime__c == null) {
            throw new OJTException('Planlama tarihlerini kontrol ediniz.');
        } else if (ojtDay.EUR_TR_PlanedStartTime__c > ojtDay.EUR_TR_PlanedEndTime__c) {
            throw new OJTException('Planlama bitiş tarihi başlangıç tarihinden sonra olmalıdır.');
        } else if (ojtDay.EUR_TR_PlanedStartTime__c.date() < Date.today()) {
            throw new OJTException('Geçmiş tarihe planlama yapılamaz.');
        } else if (ojtDay.EUR_TR_PlanedStartTime__c.date() != ojtDay.EUR_TR_PlanedEndTime__c.date()) {
            throw new OJTException('Planlama aynı gün içerisinde yapılmalıdır.');
        } else if (String.isBlank(ojtDay.EUR_TR_Preseller__c)) {
            throw new OJTException('Plasiyer bilgisi boş bırakılamaz.');
        }

        List<EUR_TR_OJT__c> existingOjtDaysWithPreseller = [
                SELECT Id
                FROM EUR_TR_OJT__c
                WHERE OwnerId = :UserInfo.getUserId()
                AND DAY_ONLY(EUR_TR_PlanedStartTime__c) = :ojtDay.EUR_TR_PlanedStartTime__c.date()
                AND EUR_TR_Preseller__c = :ojtDay.EUR_TR_Preseller__c
                AND RecordType.DeveloperName = 'EUR_TR_OJTDay'
        ];
        if (!existingOjtDaysWithPreseller.isEmpty()) {
            throw new OJTException('Belirtmiş olduğunuz plasiyerle bu tarihte planınız bulunmaktadır.');
        }

        EUR_TR_Definition__c ojtConfiguration = [
                SELECT Id, EUR_TR_OJTDayCheckInterval__c, EUR_TR_OJTDayCheckIntervalForFuture__c
                FROM EUR_TR_Definition__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OJT'
                AND EUR_TR_OJTDayCheckInterval__c != NULL
                LIMIT 1
        ];

        Integer dayCheckInterval = -Integer.valueOf(ojtConfiguration.EUR_TR_OJTDayCheckInterval__c);
        Integer dayCheckIntervalForFuture = Integer.valueOf(ojtConfiguration.EUR_TR_OJTDayCheckIntervalForFuture__c);

        Date dateForCompletedOJTs = Date.today().addDays(dayCheckInterval);
        Date dateForPlannedOJTS = Date.today().addDays(dayCheckIntervalForFuture);

        if (ojtDay.EUR_TR_PlanedStartTime__c.date() > dateForPlannedOJTS) {
            throw new OJTException(
                    String.format('En geç {0} gün sonrası olan {1} tarihine kadar planlama yapabilirsiniz.',
                            new List<String>{
                                    String.valueOf(dayCheckIntervalForFuture),
                                    dateForPlannedOJTS.format()
                            })
            );
        }

        Integer existingOjtCount = [
                SELECT COUNT()
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OJTDay'
                AND EUR_TR_Preseller__c = :ojtDay.EUR_TR_Preseller__c
                AND (
                        (
                                DAY_ONLY(EUR_TR_ActualStartTime__c) >= :dateForCompletedOJTs
                                AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= TODAY
                                AND EUR_TR_Status__c = 'Tamamlandı'
                        )
                        OR
                        (
                                DAY_ONLY(EUR_TR_PlanedStartTime__c) >= TODAY
                                AND DAY_ONLY(EUR_TR_PlanedEndTime__c) <= :dateForPlannedOJTS
                                AND EUR_TR_Status__c = 'Planlandı'
                        )
                )
        ];

        if (existingOjtCount > 0) {
            Integer numberOfPreseller = [
                    SELECT COUNT()
                    FROM EUR_TR_Employee__c
                    WHERE EUR_TR_ReportsTo_Chief__r.EUR_TR_RelatedUser__c = :UserInfo.getUserId()
            ];

            if (numberOfPreseller == 0) {
                throw new OJTException('Bu kullanıcıya bağlı hiçbir Satış Temsilcisi yok.');
            }

            List<AggregateResult> aggregateResults = [
                    SELECT EUR_TR_Preseller__c
                    FROM EUR_TR_OJT__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_OJTDay'
                    AND OwnerId = :UserInfo.getUserId()
                    AND (
                            (
                                    DAY_ONLY(EUR_TR_ActualStartTime__c) >= :dateForCompletedOJTs
                                    AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= TODAY
                                    AND EUR_TR_Status__c = 'Tamamlandı'
                            )
                            OR
                            (
                                    DAY_ONLY(EUR_TR_PlanedStartTime__c) >= TODAY
                                    AND DAY_ONLY(EUR_TR_PlanedEndTime__c) <= :dateForPlannedOJTS
                                    AND EUR_TR_Status__c = 'Planlandı'
                            )
                    )
                    GROUP BY EUR_TR_Preseller__c
                    HAVING COUNT(Id) = :existingOjtCount
                    OR COUNT(Id) = :(existingOjtCount + 1)
            ];
            Integer numberOfOJTSByChief = aggregateResults.size();

            if (numberOfOJTSByChief != numberOfPreseller) {
                throw new OJTException('Bu planı oluşturmak için gerekli kriterler sağlanmıyor.');
            }
        }
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse listOJTPlansPlansFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            OJTRequest ojtRequest = (OJTRequest) JSON.deserialize(requestBody, OJTRequest.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.Data = listOJTPlans(ojtRequest);
        } catch (Exception exc) {
            System.debug(exc);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static List<EUR_TR_OJT__c> listOJTPlans(OJTRequest ojtRequest) {
        return [
                SELECT Id,
                        EUR_TR_Score__c,
                        EUR_TR_PercentageScore__c,
                        EUR_TR_Status__c,
                        EUR_TR_ActualStartTime__c,
                        EUR_TR_ActualEndTime__c,
                        EUR_TR_PlanedStartTime__c,
                        EUR_TR_PlanedEndTime__c,
                        EUR_TR_Preseller__r.Id,
                        EUR_TR_Preseller__r.Name,
                        Owner.Id,
                        Owner.Name
                FROM EUR_TR_OJT__c
                WHERE OwnerId = :UserInfo.getUserId()
                AND RecordType.DeveloperName = 'EUR_TR_OJTDay'
                ORDER BY EUR_TR_PlanedEndTime__c DESC
                LIMIT :ojtRequest.pageSize
                OFFSET :ojtRequest.pageSize * (ojtRequest.pageNumber - 1)
        ];
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse startOJTPlanFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            startOJTPlan(ojtRequest);
        } catch (Exception exc) {
            System.debug(exc);
            Database.rollback(savepoint);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static void startOJTPlan(EUR_TR_OJT__c ojtRequest) {
        EUR_TR_OJT__c ojtDay = [
                SELECT Id, EUR_TR_PlanedStartTime__c, EUR_TR_Status__c
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtRequest.Id
        ];

        if (ojtDay.EUR_TR_Status__c != 'Planlandı') {
            throw new OJTException('Sadece Planlandı durumundaki planlar başlatılabilir.');
        } else if (ojtDay.EUR_TR_PlanedStartTime__c.date() != Date.today()) {
            throw new OJTException('Sadece aynı gün için planlanmış olan planlar başlatılabilir.');
        }

        ojtDay.EUR_TR_Status__c = 'Başlatıldı';
        ojtDay.EUR_TR_ActualStartTime__c = Datetime.now();

        update ojtDay;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse deleteOJTPlanFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            deleteOJTPlan(ojtRequest);
        } catch (Exception exc) {
            System.debug(exc);
            Database.rollback(savepoint);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static void deleteOJTPlan(EUR_TR_OJT__c ojtRequest) {
        EUR_TR_OJT__c ojtDay = [
                SELECT Id, EUR_TR_PlanedStartTime__c, EUR_TR_Status__c
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtRequest.Id
                AND RecordType.DeveloperName = 'EUR_TR_OJTDay'
        ];
        if (ojtDay.EUR_TR_Status__c != 'Planlandı') {
            throw new OJTException('Başlatılan planlar silinemez.');
        }

        delete ojtDay;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse listOJTAccountsByRelatedPlanFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            OJTRequest ojtRequest = (OJTRequest) JSON.deserialize(requestBody, OJTRequest.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.Data = listOJTAccountsByRelatedPlan(ojtRequest);
        } catch (Exception exc) {
            System.debug(exc);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static List<EUR_TR_OJT__c> listOJTAccountsByRelatedPlan(OJTRequest request) {
        EUR_TR_OJT__c ojtData = request.data;
        System.debug('ojtData: ' + ojtData);

        if (String.isBlank(ojtData.EUR_TR_RelatedDay__c)) {
            throw new OJTException('Plan seçimi yapılmış olmalıdır.');
        }

        EUR_TR_OJT__c ojtDay = [
                SELECT Id,
                        OwnerId,
                        EUR_TR_Preseller__r.Id,
                        EUR_TR_Preseller__r.Name
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtData.EUR_TR_RelatedDay__c
        ];

        List<EUR_TR_OJT__c> ojtDetails = Database.query(generateOjtDetailsQuery(request, ojtDay));

        Set<Id> accountsWithOJT = new Set<Id>();
        for (EUR_TR_OJT__c ojtDetail : ojtDetails) {
            accountsWithOJT.add(ojtDetail.EUR_TR_Account__r.Id);
        }

        List<EUR_TR_Account__c> accountsWithoutOJT = Database.query(generateAccountsWithoutOjtQuery(request, ojtDay, accountsWithOJT));

        for (EUR_TR_Account__c account : accountsWithoutOJT) {
            EUR_TR_OJT__c ojtDetail = new EUR_TR_OJT__c();

            ojtDetail.RecordTypeId = OJT_RT_MAP.get('EUR_TR_OJTDetail').getRecordTypeId();
            ojtDetail.EUR_TR_Account__r = account;
            ojtDetail.EUR_TR_Account__c = account.Id;
            ojtDetail.EUR_TR_RelatedDay__c = ojtDay.Id;

            ojtDetails.add(ojtDetail);
        }

        List<EUR_TR_OJT__c> returnList = new List<EUR_TR_OJT__c>();
        for (Integer index = request.pageSize * (request.pageNumber - 1); index < ojtDetails.size() && index < request.pageSize * request.pageNumber; index++) {
            returnList.add(ojtDetails[index]);
        }

        return returnList;
    }

    public static String generateOjtDetailsQuery(OJTRequest request, EUR_TR_OJT__c ojtDay) {
        List<String> selectQuery = new List<String>{
                'Id',
                'OwnerId',
                'EUR_TR_Status__c',
                'EUR_TR_Score__c',
                'EUR_TR_PercentageScore__c',
                'EUR_TR_RelatedDay__c',
                'EUR_TR_ActualStartTime__c',
                'EUR_TR_ActualEndTime__c',
                'EUR_TR_Account__r.Id',
                'EUR_TR_Account__r.Name',
                'EUR_TR_Account__r.EUR_TR_Status__c',
                'EUR_TR_Account__r.EUR_TR_AccountCode__c',
                'EUR_TR_Account__r.EUR_TR_Location__c',
                'EUR_TR_Account__r.EUR_TR_Location__Latitude__s',
                'EUR_TR_Account__r.EUR_TR_Location__Longitude__s'
        };

        List<String> whereQuery = new List<String>{
                'RecordType.DeveloperName = \'EUR_TR_OJTDetail\'',
                'EUR_TR_RelatedDay__c = \'' + ojtDay.Id + '\''
        };

        if (String.isNotBlank(request.searchTerm)) {
            List<String> searchFields = new List<String>{
                    'EUR_TR_Account__r.Name LIKE \'%' + request.searchTerm + '%\'',
                    'EUR_TR_Account__r.EUR_TR_AccountCode__c LIKE \'%' + request.searchTerm + '%\''
            };

            whereQuery.add(String.format('({0})', new List<String>{
                    String.join(searchFields, ' OR ')
            }));
        }

        String orderBy;
        String orderDirection;

        switch on request.orderBy {
            when location {
                if (request.latitude == null || request.longitude == null) {
                    throw new OJTException('Konuma göre sıralama için koordinatlar gönderilmiş olmalıdır.');
                }

                orderBy = String.format(
                        'DISTANCE(EUR_TR_Account__r.EUR_TR_Location__c, GEOLOCATION({0}, {1}), \'\'km\'\')', new List<Decimal>{
                                request.latitude,
                                request.longitude
                        });
            }
            when name {
                orderBy = 'EUR_TR_Account__r.Name';
            }
            when else {
                orderBy = 'CreatedDate DESC';
            }
        }

        switch on request.orderDirection {
            when ascending {
                orderDirection = 'ASC NULLS LAST';
            }
            when descending {
                orderDirection = 'DESC NULLS LAST';
            }
            when else {
                orderDirection = '';
            }
        }

        String query = String.format(QUERY_TEMPLATE, new List<String>{
                String.join(selectQuery, ', '),
                'EUR_TR_OJT__c',
                String.join(whereQuery, ' AND '),
                orderBy,
                orderDirection
        });
        System.debug('query: ' + query);

        return query;
    }

    public static String generateAccountsWithoutOjtQuery(OJTRequest request, EUR_TR_OJT__c ojtDay, Set<Id> accountsWithOJT) {
        List<String> selectQuery = new List<String>{
                'Id',
                'Name',
                'EUR_TR_AccountCode__c',
                'EUR_TR_Status__c',
                'EUR_TR_Location__c',
                'EUR_TR_Location__Latitude__s',
                'EUR_TR_Location__Longitude__s'
        };

        List<String> whereQuery = new List<String>{
                'OwnerId = \'' + ojtDay.OwnerId + '\'',
                'EUR_TR_PresellerName__c = \'' + ojtDay.EUR_TR_Preseller__r.Name + '\'',
                'Id NOT IN :accountsWithOJT'
        };

        if (String.isNotBlank(request.searchTerm)) {
            List<String> searchFields = new List<String>{
                    'Name LIKE \'%' + request.searchTerm + '%\'',
                    'EUR_TR_AccountCode__c LIKE \'%' + request.searchTerm + '%\''
            };

            whereQuery.add(String.format('({0})', new List<String>{
                    String.join(searchFields, ' OR ')
            }));
        }

        String orderBy;
        String orderDirection;

        switch on request.orderBy {
            when location {
                if (request.latitude == null || request.longitude == null) {
                    throw new OJTException('Konuma göre sıralama için koordinatlar gönderilmiş olmalıdır.');
                }

                orderBy = String.format(
                        'DISTANCE(EUR_TR_Location__c, GEOLOCATION({0}, {1}), \'\'km\'\')', new List<Decimal>{
                                request.latitude,
                                request.longitude
                        });
            }
            when name {
                orderBy = 'Name';
            }
            when else {
                orderBy = 'CreatedDate DESC';
            }
        }

        switch on request.orderDirection {
            when ascending {
                orderDirection = 'ASC NULLS LAST';
            }
            when descending {
                orderDirection = 'DESC NULLS LAST';
            }
            when else {
                orderDirection = '';
            }
        }

        String query = String.format(QUERY_TEMPLATE, new List<String>{
                String.join(selectQuery, ', '),
                'EUR_TR_Account__c',
                String.join(whereQuery, ' AND '),
                orderBy,
                orderDirection
        });
        System.debug('query: ' + query);

        return query;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse startOJTCustomerVisitFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = startOJTCustomerVisit(ojtRequest);
        } catch (Exception exc) {
            System.debug('exc: ' + exc);
            Database.rollback(savepoint);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static EUR_TR_OJT__c startOJTCustomerVisit(EUR_TR_OJT__c ojtRequest) {
        if (String.isBlank(ojtRequest.EUR_TR_RelatedDay__c)) {
            throw new OJTException('EUR_TR_RelatedDay__c boş olamaz.');
        } else if (String.isBlank(ojtRequest.EUR_TR_Account__c)) {
            throw new OJTException('EUR_TR_Account__c boş olamaz.');
        }

        EUR_TR_OJT__c relatedDay = [
                SELECT Id, EUR_TR_PlanedStartTime__c, EUR_TR_Status__c, EUR_TR_Preseller__c
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtRequest.EUR_TR_RelatedDay__c
        ];
        if (relatedDay.EUR_TR_Status__c != 'Başlatıldı') {
            throw new OJTException('Bu işlem sadece başlatılmış durumdaki planlar için yapılabilir.');
        } else if (relatedDay.EUR_TR_PlanedStartTime__c.date() != Date.today()) {
            throw new OJTException('Sadece aynı gün içerisinde başlatabilirsiniz.');
        }

        List<EUR_TR_OJT__c> existingOJTVisits = [
                SELECT Id
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OJTDetail'
                AND OwnerId = :UserInfo.getUserId()
                AND EUR_TR_Preseller__c = :relatedDay.EUR_TR_Preseller__c
                AND EUR_TR_Account__c = :ojtRequest.EUR_TR_Account__c
                AND EUR_TR_RelatedDay__c = :ojtRequest.EUR_TR_RelatedDay__c
        ];
        if (!existingOJTVisits.isEmpty()) {
            throw new OJTException('Belirtmiş olduğunuz planda bu müşteri mevcut.');
        }

        ojtRequest.RecordTypeId = OJT_RT_MAP.get('EUR_TR_OJTDetail').getRecordTypeId();
        ojtRequest.EUR_TR_Status__c = 'Başlatıldı';
        ojtRequest.EUR_TR_ActualStartTime__c = Datetime.now();

        insert ojtRequest;
        return ojtRequest;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse endOJTCustomerVisitFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = endOJTCustomerVisit(ojtRequest);
        } catch (Exception exc) {
            System.debug('exc: ' + exc);
            Database.rollback(savepoint);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static EUR_TR_OJT__c endOJTCustomerVisit(EUR_TR_OJT__c ojtDetail) {
        if (String.isBlank(ojtDetail.Id)) {
            throw new OJTException('Id parametresi boş olamaz.');
        }

        EUR_TR_OJT__c ojtVisit = [
                SELECT Id, EUR_TR_ActualStartTime__c, EUR_TR_Status__c
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtDetail.Id
        ];
        if (ojtVisit.EUR_TR_ActualStartTime__c.date() != Date.today()) {
            throw new OJTException('Aynı gün içerisinde tamamlanmamış veriler kaydedilemez.');
        } else if (ojtVisit.EUR_TR_Status__c == 'Tamamlandı') {
            throw new OJTException('Bu kayıt zaten tamamlanmış durumda.');
        }

        for (EUR_TR_OJT__c answer : ojtDetail.EUR_TR_Answers__r) {
            if (String.isBlank(answer.EUR_TR_RelatedQuestion__c)) {
                throw new OJTException(answer.EUR_TR_QuestionOrder__c + '. cevabın EUR_TR_RelatedQuestion__c parametresi boş bırakılmış.');
            } else if (answer.EUR_TR_Score__c == null) {
                throw new OJTException(answer.EUR_TR_QuestionOrder__c + '. cevabın EUR_TR_Score__c parametresi boş bırakılmış.');
            }

            answer.RecordTypeId = OJT_RT_MAP.get('EUR_TR_Answer').getRecordTypeId();
            answer.EUR_TR_RelatedDetail__c = ojtVisit.Id;
        }

        insert ojtDetail.EUR_TR_Answers__r;

        Decimal totalScore = 0;

        for (EUR_TR_OJT__c answer : ojtDetail.EUR_TR_Answers__r) {
            totalScore += answer.EUR_TR_Score__c;
        }

        ojtDetail.RecordTypeId = OJT_RT_MAP.get('EUR_TR_OJTDetail').getRecordTypeId();
        ojtDetail.EUR_TR_ActualEndTime__c = Datetime.now();
        ojtDetail.EUR_TR_Status__c = 'Tamamlandı';
        ojtDetail.EUR_TR_Score__c = totalScore;
        ojtDetail.EUR_TR_PercentageScore__c = (totalScore / (ojtDetail.EUR_TR_Answers__r.size() * 10)) * 100;

        update ojtDetail;
        return ojtDetail;
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse endOJTPlanFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.Data = endOJTPlan(ojtRequest);
        } catch (Exception exc) {
            System.debug('exc: ' + exc);
            Database.rollback(savepoint);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static List<EUR_TR_OJT__c> endOJTPlan(EUR_TR_OJT__c ojtRequest) {
        if (String.isBlank(ojtRequest.Id)) {
            throw new OJTException('Id parametresi boş olamaz.');
        }

        EUR_TR_OJT__c ojtDay = [
                SELECT Id, EUR_TR_ActualStartTime__c, EUR_TR_Status__c, EUR_TR_Preseller__c, OwnerId
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtRequest.Id
        ];
        if (ojtDay.EUR_TR_Status__c != 'Başlatıldı') {
            throw new OJTException('Sadece başlatılan planlar bitirilebilir.');
        } else if (ojtDay.EUR_TR_ActualStartTime__c.date() != Date.today()) {
            throw new OJTException('Başlamış olan planlar sadece aynı gün içerisinde bitirilebilir.');
        }

        List<EUR_TR_OJT__c> ojtVisits = [
                SELECT Id, EUR_TR_Account__c, EUR_TR_Score__c, EUR_TR_PercentageScore__c,
                (
                        SELECT Id, EUR_TR_RelatedQuestion__c, EUR_TR_Score__c
                        FROM EUR_TR_Answers__r
                )
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OJTDetail'
                AND EUR_TR_RelatedDay__c = :ojtDay.Id
                AND EUR_TR_Status__c = 'Tamamlandı'
        ];

        Map<Id, Decimal> averageScoreFromQuestionId = new Map<Id, Decimal>();
        Set<Id> questionIds = new Set<Id>();

        Decimal dayAverageScore = 0;
        Decimal dayAveragePercentageScore = 0;

        for (EUR_TR_OJT__c ojtVisit : ojtVisits) {
            dayAverageScore += ojtVisit.EUR_TR_Score__c / ojtVisits.size();
            dayAveragePercentageScore += ojtVisit.EUR_TR_PercentageScore__c / ojtVisits.size();

            for (EUR_TR_OJT__c answer : ojtVisit.EUR_TR_Answers__r) {
                questionIds.add(answer.EUR_TR_RelatedQuestion__c);

                Decimal currentAverage;
                if (averageScoreFromQuestionId.containsKey(answer.EUR_TR_RelatedQuestion__c)) {
                    currentAverage = averageScoreFromQuestionId.get(answer.EUR_TR_RelatedQuestion__c) + (answer.EUR_TR_Score__c / ojtVisits.size());
                } else {
                    currentAverage = answer.EUR_TR_Score__c / ojtVisits.size();
                }

                averageScoreFromQuestionId.put(answer.EUR_TR_RelatedQuestion__c, currentAverage);
            }
        }

        Map<Id, EUR_TR_OJT__c> questionsMap = new Map<Id, EUR_TR_OJT__c>([
                SELECT Id, EUR_TR_MinScore__c,
                (
                        SELECT EUR_TR_ActionDescription__c
                        FROM EUR_TR_QuestionActions__r
                )
                FROM EUR_TR_OJT__c
                WHERE Id IN :questionIds
        ]);

        List<Task> tasks = new List<Task>();
        for (Id questionId : questionsMap.keySet()) {
            EUR_TR_OJT__c question = questionsMap.get(questionId);

            if (averageScoreFromQuestionId.get(question.Id) < question.EUR_TR_MinScore__c) {
                for (EUR_TR_OJT__c questionAction : question.EUR_TR_QuestionActions__r) {
                    Task task = new Task();

                    task.Description = questionAction.EUR_TR_ActionDescription__c;
                    task.PR_Activity_Type__c = 'Preseller';
                    task.ActivityDate = Date.today();
                    task.WhatId = ojtDay.Id;
                    task.Cliente__c = 'OJT';

                    tasks.add(task);
                }
            }
        }

        insert tasks;

        ojtDay.EUR_TR_Status__c = 'Tamamlandı';
        ojtDay.EUR_TR_ActualEndTime__c = Datetime.now();
        ojtDay.EUR_TR_Score__c = dayAverageScore;
        ojtDay.EUR_TR_PercentageScore__c = dayAveragePercentageScore;

        update ojtDay;

        return [
                SELECT Id,
                        EUR_TR_Score__c,
                        EUR_TR_PercentageScore__c,
                        EUR_TR_Status__c,
                        EUR_TR_ActualStartTime__c,
                        EUR_TR_ActualEndTime__c,
                        EUR_TR_PlanedStartTime__c,
                        EUR_TR_PlanedEndTime__c,
                        EUR_TR_Preseller__r.Id,
                        EUR_TR_Preseller__r.Name,
                        Owner.Id,
                        Owner.Name,
                (
                        SELECT Id, Description
                        FROM Tasks
                )
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OJTDay'
                AND EUR_TR_Status__c = 'Tamamlandı'
                AND EUR_TR_Preseller__c = :ojtDay.EUR_TR_Preseller__c
                AND OwnerId = :ojtDay.OwnerId
                ORDER BY EUR_TR_ActualEndTime__c DESC
                LIMIT 2
        ];
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse sendOJTEmailFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            OJTRequest ojtRequest = (OJTRequest) JSON.deserialize(requestBody, OJTRequest.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            sendOJTEmail(ojtRequest);
        } catch (Exception exc) {
            System.debug('exc: ' + exc);

            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    //@Future(Callout=true)
    public static void sendOJTEmail(OJTRequest ojtRequest) {
        if (String.isBlank(ojtRequest.emailAddress)) {
            throw new OJTException('Email adresi boş olamaz.');
        } else if (String.isBlank(ojtRequest.data.Id)) {
            throw new OJTException('Plan boş bırakılamaz.');
        }

        EUR_TR_OJT__c ojtDay = [
                SELECT Id, EUR_TR_Preseller__r.EUR_TR_EmailAddress__c
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtRequest.data.Id
        ];

        PageReference zoomEmailPageReference = Page.EUR_TR_OJTEmailTemplate;

        zoomEmailPageReference.getParameters().put('id', ojtDay.Id);
        String emailBody = Test.isRunningTest() ? 'getContentNotSupportedOnTest' : zoomEmailPageReference.getContent().toString();

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        email.setHtmlBody(emailBody);
        email.setToAddresses(new List<String>{
                ojtRequest.emailAddress
        });
        email.setSubject('OJT Sonuçları');

        Messaging.SendEmailResult result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                email
        })[0];
        if (!result.isSuccess()) {
            throw new OJTException(result.errors.toString());
        }
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPresellerOJTPlanReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            OJTRequest ojtRequest = (OJTRequest) JSON.deserialize(requestBody, OJTRequest.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getPresellerOJTPlanReport(ojtRequest);
        } catch (Exception exc) {
            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static OJTOrganizationScoresResponse getPresellerOJTPlanReport(OJTRequest ojtRequest) {
        if (ojtRequest.data == null || String.isBlank(ojtRequest.data.EUR_TR_Preseller__c)) {
            throw new OJTException('EUR_TR_Preseller__c parametresi boş bırakılamaz.');
        }

        OJTOrganizationScoresResponse scoresAndData = new OJTOrganizationScoresResponse();

        scoresAndData.countryAvgScore = getCountryAverageByDate(ojtRequest.queryStartDate, ojtRequest.queryEndDate);
        scoresAndData.userAvgScore = getPresellerAverageByDate(ojtRequest.data.EUR_TR_Preseller__c, ojtRequest.queryStartDate, ojtRequest.queryEndDate);
        scoresAndData.data = [
                SELECT Id,
                        EUR_TR_Score__c,
                        EUR_TR_PercentageScore__c,
                        EUR_TR_Status__c,
                        EUR_TR_ActualStartTime__c,
                        EUR_TR_ActualEndTime__c,
                        EUR_TR_PlanedStartTime__c,
                        EUR_TR_PlanedEndTime__c,
                        EUR_TR_Preseller__r.Id,
                        EUR_TR_Preseller__r.Name,
                        Owner.Id,
                        Owner.Name,
                        EUR_TR_Note__c
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OJTDay'
                AND EUR_TR_Preseller__c = :ojtRequest.data.EUR_TR_Preseller__c
                AND EUR_TR_Status__c = 'Tamamlandı'
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) >= :ojtRequest.queryStartDate
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= :ojtRequest.queryEndDate
                ORDER BY EUR_TR_ActualEndTime__c DESC
                LIMIT :ojtRequest.pageSize
                OFFSET :ojtRequest.pageSize * (ojtRequest.pageNumber - 1)
        ];

        return scoresAndData;
    }

    public static Decimal getCountryAverageByDate(Date queryStartDate, Date queryEndDate) {
        List<AggregateResult> aggregateResult = [
                SELECT AVG(EUR_TR_PercentageScore__c) EUR_TR_PercentageScore__c
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OjtDay'
                AND EUR_TR_Status__c = 'Tamamlandı'
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) >= :queryStartDate
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= :queryEndDate
        ];

        return (Decimal) aggregateResult[0].get('EUR_TR_PercentageScore__c');
    }

    public static Decimal getPresellerAverageByDate(Id presellerId, Date queryStartDate, Date queryEndDate) {
        List<AggregateResult> aggregateResult = [
                SELECT AVG(EUR_TR_PercentageScore__c) EUR_TR_PercentageScore__c
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OjtDay'
                AND EUR_TR_Status__c = 'Tamamlandı'
                AND EUR_TR_Preseller__c = :presellerId
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) >= :queryStartDate
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= :queryEndDate
        ];

        return (Decimal) aggregateResult[0].get('EUR_TR_PercentageScore__c');
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getOJTVisitsByPlanReportFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getOJTVisitsByPlanReport(ojtRequest);
        } catch (Exception exc) {
            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static EUR_TR_OJT__c getOJTVisitsByPlanReport(EUR_TR_OJT__c ojtRequest) {
        return [
                SELECT Id,
                        EUR_TR_Score__c,
                        EUR_TR_PercentageScore__c,
                        EUR_TR_Status__c,
                        EUR_TR_ActualStartTime__c,
                        EUR_TR_ActualEndTime__c,
                        EUR_TR_PlanedStartTime__c,
                        EUR_TR_PlanedEndTime__c,
                        EUR_TR_Preseller__r.Id,
                        EUR_TR_Preseller__r.Name,
                        Owner.Id,
                        Owner.Name, (
                        SELECT Id, Description
                        FROM Tasks
                ), (
                        SELECT Id,
                                EUR_TR_Status__c,
                                EUR_TR_Score__c,
                                EUR_TR_PercentageScore__c,
                                EUR_TR_ActualStartTime__c,
                                EUR_TR_ActualEndTime__c,

                                EUR_TR_Account__r.Id,
                                EUR_TR_Account__r.Name,
                                EUR_TR_Account__r.EUR_TR_AccountCode__c,
                                EUR_TR_Account__r.EUR_TR_Location__c,
                                EUR_TR_Account__r.EUR_TR_Location__Latitude__s,
                                EUR_TR_Account__r.EUR_TR_Location__Longitude__s
                        FROM EUR_TR_DayDetails__r
                        WHERE EUR_TR_Status__c = 'Tamamlandı'
                        ORDER BY EUR_TR_ActualEndTime__c DESC
                )
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtRequest.Id
        ];
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getOJTVisitDetailsFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            EUR_TR_OJT__c ojtRequest = (EUR_TR_OJT__c) JSON.deserialize(requestBody, EUR_TR_OJT__c.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getOJTVisitDetails(ojtRequest);
        } catch (Exception exc) {
            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static EUR_TR_OJT__c getOJTVisitDetails(EUR_TR_OJT__c ojtRequest) {
        return [
                SELECT Id,
                        EUR_TR_Status__c,
                        EUR_TR_Score__c,
                        EUR_TR_PercentageScore__c,
                        EUR_TR_ActualStartTime__c,
                        EUR_TR_ActualEndTime__c,

                        EUR_TR_Account__r.Id,
                        EUR_TR_Account__r.Name,
                        EUR_TR_Account__r.EUR_TR_AccountCode__c,
                        EUR_TR_Account__r.EUR_TR_Location__c,
                        EUR_TR_Account__r.EUR_TR_Location__Latitude__s,
                        EUR_TR_Account__r.EUR_TR_Location__Longitude__s, (
                        SELECT Id,
                                EUR_TR_QuestionText__c,
                                EUR_TR_Score__c,
                                EUR_TR_PercentageScore__c
                        FROM EUR_TR_Answers__r
                )
                FROM EUR_TR_OJT__c
                WHERE Id = :ojtRequest.Id
        ];
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getOJTConfigurationsFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = [
                    SELECT Id, EUR_TR_MinimumRequiredOJTVisit__c
                    FROM EUR_TR_Definition__c
                    WHERE RecordType.DeveloperName = 'EUR_TR_OJT'
                    LIMIT 1
            ];
        } catch (Exception exc) {
            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }

    public static Id getUserIdFromEmployeeId(Id employeeId) {
        return [
                SELECT EUR_TR_RelatedUser__c
                FROM EUR_TR_Employee__c
                WHERE Id = :employeeId
        ].EUR_TR_RelatedUser__c;
    }

    //Start getOJTOrganizationScores
    public static EUR_TR_MiddlewareController.PostServiceResponse getOJTOrganizationScoresFromMiddleware(String requestBody) {
        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();

        try {
            OJTRequest ojtRequest = (OJTRequest) JSON.deserialize(requestBody, OJTRequest.class);

            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getOJTOrganizationScores(ojtRequest.queryStartDate, ojtRequest.queryEndDate);
        } catch (Exception exc) {
            serviceResponse.Code = -1;
            serviceResponse.Message = exc.getMessage();
        }

        return serviceResponse;
    }


    public static EUR_TR_MiddlewareController.PostServiceResponse makeOJTActionsAfterOJTComplete(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        Savepoint savepoint = Database.setSavepoint();
        try {

            OJTActionRequestAfterOJTComplete ojtActionRequestAfterOJTComplete = (OJTActionRequestAfterOJTComplete) JSON.deserialize(requestBody, OJTActionRequestAfterOJTComplete.class);
            serviceResponse.Code = 1;
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;

            if (ojtActionRequestAfterOJTComplete.addNote != null && ojtActionRequestAfterOJTComplete.addNote) {
                addNoteToRelatedOJT(ojtActionRequestAfterOJTComplete.data);
            }
            if (ojtActionRequestAfterOJTComplete.sendEmail != null && ojtActionRequestAfterOJTComplete.sendEmail) {
                EUR_TR_OJTController.sendOJTEmail(ojtActionRequestAfterOJTComplete);
            }

        } catch (Exception ex) {
            Database.rollback(savepoint);
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }


    public static EUR_TR_OJT__c addNoteToRelatedOJT(EUR_TR_OJT__c ojt) {

        if (ojt == null) {
            throw new EUR_TR_OJTController.OJTException('Not parametreleri boş bırakılamaz');
        } else if (String.isBlank(ojt.Id)) {
            throw new EUR_TR_OJTController.OJTException('OJT Id boş bırakılamaz');
        } else if (String.isBlank(ojt.EUR_TR_Note__c)) {
            throw new EUR_TR_OJTController.OJTException('Not boş bırakılamaz.');
        } else if (ojt.EUR_TR_Note__c.length() > 1000) {
            throw new EUR_TR_OJTController.OJTException('1000 karakterden fazla not girilemez');
        }

        List<EUR_TR_OJT__c> relatedOJT = [
                SELECT Id
                FROM EUR_TR_OJT__c
                WHERE Id = :ojt.Id AND RecordType.DeveloperName = 'EUR_TR_OJTDay'
                LIMIT 1
        ];

        if (relatedOJT.isEmpty()) {
            throw new OJTException('İlgili OJT kaydı bulunamadı');
        }

        update ojt;

        return ojt;

    }


    @AuraEnabled
    public static List<OJTOrganizationScoresResponse> getOJTOrganizationScores(Date queryStartDate, Date queryEndDate) {
        if (queryStartDate == null && queryEndDate == null) {
            queryStartDate = Date.newInstance(Datetime.now().year(), Datetime.now().month(), 1);
            queryEndDate = Date.newInstance(Datetime.now().year(), Datetime.now().month(), Date.daysInMonth(Datetime.now().year(), Datetime.now().month()));
        }

        List<OJTOrganizationScoresResponse> response = new List<OJTOrganizationScoresResponse>();
        List<AggregateResult> countryResults = [
                SELECT AVG(EUR_TR_PercentageScore__c) EUR_TR_PercentageScore__c
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OjtDay'
                AND EUR_TR_Status__c = 'Tamamlandı'
                AND DAY_ONLY(EUR_TR_ActualStartTime__c) >= :queryStartDate
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= :queryEndDate
        ];
        Decimal countryAvgScore = (Decimal) countryResults[0].get('EUR_TR_PercentageScore__c');

        List<AggregateResult> ojtCountsGroupedByPreseller = [
                SELECT COUNT(Id) ojtCount,
                        EUR_TR_Preseller__c EUR_TR_Preseller__c
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OJTDay'
                AND EUR_TR_Status__c = 'Tamamlandı'
                AND DAY_ONLY(EUR_TR_ActualStartTime__c) >= :queryStartDate
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= :queryEndDate
                GROUP BY EUR_TR_Preseller__c
        ];

        Map<Id, Integer> ojtCountsByPreseller = new Map<Id, Integer>();
        for (AggregateResult aggregateResult : ojtCountsGroupedByPreseller) {
            Integer ojtCount = (Integer) aggregateResult.get('ojtCount');
            Id presellerId = (Id) aggregateResult.get('EUR_TR_Preseller__c');

            ojtCountsByPreseller.put(presellerId, ojtCount);
        }

        User currentUser = [SELECT Id, Name,UserRole.DeveloperName FROM User WHERE Id = :UserInfo.getUserId()];
        if (currentUser.UserRole.DeveloperName == 'EUR_TR_SalesChiefs') {
            EUR_TR_Employee__c salesChiefEmployee = getEmployeeFromUserId(currentUser.Id);
            Map<String, EUR_TR_Employee__c> preSellersMap = getPreSellersMap(new Set<String>{
                    salesChiefEmployee.Id
            });

            Map<String, Decimal> preSellersScoresMap = getPreSellersScoresMap(preSellersMap.keySet(), queryStartDate, queryEndDate);

            Map<String, List<OJTOrganizationScoresResponse>> preSellersOfSalesChiefMap = getPreSellersOfSalesChiefMap(preSellersMap, preSellersScoresMap, countryAvgScore, ojtCountsByPreseller);

            OJTOrganizationScoresResponse salesChiefResponse = new OJTOrganizationScoresResponse();
            salesChiefResponse.countryAvgScore = countryAvgScore;
            salesChiefResponse.employeeId = salesChiefEmployee.Id;
            salesChiefResponse.userName = currentUser.Name;
            salesChiefResponse.userRole = salesChiefEmployee.RecordType.DeveloperName;
            salesChiefResponse.userAvgScore = calculateAvgScore(preSellersOfSalesChiefMap.get(salesChiefEmployee.Id));
            salesChiefResponse.subHierarchies.addAll(preSellersOfSalesChiefMap.get(salesChiefEmployee.Id));

            response.add(salesChiefResponse);

        } else if (currentUser.UserRole.DeveloperName.contains('EUR_TR_Area')) {
            EUR_TR_Employee__c areaManagerEmployee = getEmployeeFromUserId(currentUser.Id);
            Map<String, EUR_TR_Employee__c> salesChiefsMap = getSalesChiefsMap(new Set<String>{
                    areaManagerEmployee.Id
            });

            Map<String, EUR_TR_Employee__c> preSellersMap = getPreSellersMap(salesChiefsMap.keySet());

            Map<String, Decimal> preSellersScoresMap = getPreSellersScoresMap(preSellersMap.keySet(), queryStartDate, queryEndDate);

            Map<String, List<OJTOrganizationScoresResponse>> preSellersOfSalesChiefMap = getPreSellersOfSalesChiefMap(preSellersMap, preSellersScoresMap, countryAvgScore, ojtCountsByPreseller);

            Map<String, List<OJTOrganizationScoresResponse>> salesChiefsOfAreaManagerMap = getSalesChiefsOfAreaManagerMap(salesChiefsMap, preSellersOfSalesChiefMap, countryAvgScore);

            OJTOrganizationScoresResponse aresManagerResponse = new OJTOrganizationScoresResponse();
            aresManagerResponse.countryAvgScore = countryAvgScore;
            aresManagerResponse.employeeId = areaManagerEmployee.Id;
            aresManagerResponse.userName = currentUser.Name;
            aresManagerResponse.userRole = areaManagerEmployee.RecordType.DeveloperName;
            aresManagerResponse.userAvgScore = calculateAvgScore(salesChiefsOfAreaManagerMap.get(areaManagerEmployee.Id));
            aresManagerResponse.subHierarchies.addAll(salesChiefsOfAreaManagerMap.get(areaManagerEmployee.Id));

            response.add(aresManagerResponse);
        } else {
            Map<String, EUR_TR_Employee__c> areaManagersMap = getAreaManagersMap();

            Map<String, EUR_TR_Employee__c> salesChiefsMap = getSalesChiefsMap(areaManagersMap.keySet());

            Map<String, EUR_TR_Employee__c> preSellersMap = getPreSellersMap(salesChiefsMap.keySet());

            Map<String, Decimal> preSellersScoresMap = getPreSellersScoresMap(preSellersMap.keySet(), queryStartDate, queryEndDate);

            Map<String, List<OJTOrganizationScoresResponse>> preSellersOfSalesChiefMap = getPreSellersOfSalesChiefMap(preSellersMap, preSellersScoresMap, countryAvgScore, ojtCountsByPreseller);

            Map<String, List<OJTOrganizationScoresResponse>> salesChiefsOfAreaManagerMap = getSalesChiefsOfAreaManagerMap(salesChiefsMap, preSellersOfSalesChiefMap, countryAvgScore);

            for (String areaManagerId : areaManagersMap.keySet()) {
                List<OJTOrganizationScoresResponse> salesChiefs = salesChiefsOfAreaManagerMap.get(areaManagerId);
                if (salesChiefs != null && !salesChiefs.isEmpty()) {
                    OJTOrganizationScoresResponse aresManagerResponse = new OJTOrganizationScoresResponse();
                    aresManagerResponse.countryAvgScore = countryAvgScore;
                    aresManagerResponse.employeeId = areaManagersMap.get(areaManagerId).Id;
                    aresManagerResponse.userName = areaManagersMap.get(areaManagerId).Name;
                    aresManagerResponse.userRole = areaManagersMap.get(areaManagerId).RecordType.DeveloperName;
                    aresManagerResponse.userAvgScore = calculateAvgScore(salesChiefs);
                    aresManagerResponse.subHierarchies.addAll(salesChiefs);

                    response.add(aresManagerResponse);
                }
            }
        }

        setHierarchicOjtCounts(response);
        setManagersOfEmployeeRecords(response);

        return response;
    }

    private static void setManagersOfEmployeeRecords(List<OJTOrganizationScoresResponse> employeeRecords) {
        if (employeeRecords == null) {
            return;
        }

        for (OJTOrganizationScoresResponse employee : employeeRecords) {
            setManagerOfEmployeeRecord(employee);
        }
    }

    private static void setManagerOfEmployeeRecord(OJTOrganizationScoresResponse employee) {
        if (employee.subHierarchies == null || employee.subHierarchies.isEmpty()) {
            return;
        }

        OJTOrganizationScoresResponse manager = new OJTOrganizationScoresResponse(employee);

        for (OJTOrganizationScoresResponse managedEmployee : employee.subHierarchies) {
            managedEmployee.manager = manager;
        }

        setManagersOfEmployeeRecords(employee.subHierarchies);
    }

    private static void setHierarchicOjtCounts(List<OJTOrganizationScoresResponse> employeeRecords) {
        if (employeeRecords == null) {
            return;
        }
        
        for (OJTOrganizationScoresResponse employee : employeeRecords) {
            setHierarchicOjtCounts(employee);
        }
    }

    private static Integer setHierarchicOjtCounts(OJTOrganizationScoresResponse employee) {
        if (employee.subHierarchies == null || employee.subHierarchies.isEmpty()) {
            return employee.ojtCount;
        }

        Integer total = 0;

        for (OJTOrganizationScoresResponse subEmployee : employee.subHierarchies) {
            total += setHierarchicOjtCounts(subEmployee);
        }

        employee.ojtCount += total;

        return employee.ojtCount;
    }

    //getOJTOrganizationScores private methods
    private static Map<String, List<OJTOrganizationScoresResponse>> getSalesChiefsOfAreaManagerMap(Map<String, EUR_TR_Employee__c> salesChiefsMap,
            Map<String, List<OJTOrganizationScoresResponse>> preSellersOfSalesChiefMap,
            Decimal countryAvgScore) {
        Map<String, List<OJTOrganizationScoresResponse>> salesChiefsOfAreaManagerMap = new Map<String, List<OJTOrganizationScoresResponse>>();
        for (String salesChiefId : salesChiefsMap.keySet()) {
            List<OJTOrganizationScoresResponse> preSellers = preSellersOfSalesChiefMap.get(salesChiefId);
            if (preSellers != null && !preSellers.isEmpty()) {
                OJTOrganizationScoresResponse salesChiefResponse = new OJTOrganizationScoresResponse();
                salesChiefResponse.countryAvgScore = countryAvgScore;
                salesChiefResponse.employeeId = salesChiefsMap.get(salesChiefId).Id;
                salesChiefResponse.userName = salesChiefsMap.get(salesChiefId).Name;
                salesChiefResponse.userRole = salesChiefsMap.get(salesChiefId).RecordType.DeveloperName;
                salesChiefResponse.userAvgScore = calculateAvgScore(preSellers);
                salesChiefResponse.subHierarchies.addAll(preSellers);

                String areaMangerId = salesChiefsMap.get(salesChiefId).EUR_TR_ReportsTo_AreaManager__c;
                if (salesChiefsOfAreaManagerMap.containsKey(areaMangerId)) {
                    List<OJTOrganizationScoresResponse> salesChiefResponses = salesChiefsOfAreaManagerMap.get(areaMangerId);
                    salesChiefResponses.add(salesChiefResponse);
                    salesChiefsOfAreaManagerMap.put(areaMangerId, salesChiefResponses);
                } else {
                    List<OJTOrganizationScoresResponse> salesChiefResponses = new List<OJTOrganizationScoresResponse>();
                    salesChiefResponses.add(salesChiefResponse);
                    salesChiefsOfAreaManagerMap.put(areaMangerId, salesChiefResponses);
                }
            }
        }
        return salesChiefsOfAreaManagerMap;
    }

    private static Map<String, List<OJTOrganizationScoresResponse>> getPreSellersOfSalesChiefMap(Map<String, EUR_TR_Employee__c> preSellersMap,
            Map<String, Decimal> preSellersScoresMap,
            Decimal countryAvgScore,
            Map<Id, Integer> ojtCountsByPreseller) {
        Map<String, List<OJTOrganizationScoresResponse>> preSellersOfSalesChiefMap = new Map<String, List<OJTOrganizationScoresResponse>>();
        for (String preSellerId : preSellersMap.keySet()) {
            OJTOrganizationScoresResponse preSellerResponse = new OJTOrganizationScoresResponse();
            preSellerResponse.countryAvgScore = countryAvgScore;
            preSellerResponse.employeeId = preSellersMap.get(preSellerId).Id;
            preSellerResponse.userName = preSellersMap.get(preSellerId).Name;
            preSellerResponse.userRole = preSellersMap.get(preSellerId).RecordType.DeveloperName;
            preSellerResponse.userAvgScore = preSellersScoresMap.get(preSellerId) == null ? 0 : preSellersScoresMap.get(preSellerId);
            preSellerResponse.ojtCount = ojtCountsByPreseller.get(preSellerId) == null ? 0 : ojtCountsByPreseller.get(preSellerId);

            String chiefId = preSellersMap.get(preSellerId).EUR_TR_ReportsTo_Chief__c;
            if (preSellersOfSalesChiefMap.containsKey(chiefId)) {
                List<OJTOrganizationScoresResponse> preSellerResponses = preSellersOfSalesChiefMap.get(chiefId);
                preSellerResponses.add(preSellerResponse);
                preSellersOfSalesChiefMap.put(chiefId, preSellerResponses);
            } else {
                List<OJTOrganizationScoresResponse> preSellerResponses = new List<OJTOrganizationScoresResponse>();
                preSellerResponses.add(preSellerResponse);
                preSellersOfSalesChiefMap.put(chiefId, preSellerResponses);
            }
        }
        return preSellersOfSalesChiefMap;
    }

    private static Map<String, Decimal> getPreSellersScoresMap(Set<String> preSellerIds, Date queryStartDate, Date queryEndDate) {
        List<AggregateResult> preSellersScoreResults = [
                SELECT EUR_TR_Preseller__c,AVG(EUR_TR_PercentageScore__c) EUR_TR_PercentageScore__c
                FROM EUR_TR_OJT__c
                WHERE RecordType.DeveloperName = 'EUR_TR_OjtDay'
                AND EUR_TR_Status__c = 'Tamamlandı'
                AND EUR_TR_Preseller__c IN:preSellerIds
                AND DAY_ONLY(EUR_TR_ActualStartTime__c) >= :queryStartDate
                AND DAY_ONLY(EUR_TR_ActualEndTime__c) <= :queryEndDate
                GROUP BY EUR_TR_Preseller__c
        ];
        Map<String, Decimal> preSellersScoresMap = new Map<String, Decimal>();
        for (AggregateResult aggResult : preSellersScoreResults) {
            preSellersScoresMap.put((String) aggResult.get('EUR_TR_Preseller__c'), (Decimal) aggResult.get('EUR_TR_PercentageScore__c'));
        }
        return preSellersScoresMap;
    }

    private static Map<String, EUR_TR_Employee__c> getAreaManagersMap() {
        List<EUR_TR_Employee__c> areaManagers = [
                SELECT
                        Name
                        ,Id
                        ,RecordType.DeveloperName
                FROM EUR_TR_Employee__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AreaManager'
        ];
        Map<String, EUR_TR_Employee__c> areaManagersMap = new Map<String, EUR_TR_Employee__c>();
        for (EUR_TR_Employee__c areaManager : areaManagers) {
            areaManagersMap.put(areaManager.Id, areaManager);
        }
        return areaManagersMap;
    }

    private static Map<String, EUR_TR_Employee__c> getSalesChiefsMap(Set<String> areaManagerIds) {
        List<EUR_TR_Employee__c> areaManagers = [
                SELECT
                        Name
                        , Id
                        , (SELECT Id, Name, RecordType.DeveloperName, EUR_TR_ReportsTo_AreaManager__c FROM EUR_TR_Employee1__r)
                FROM EUR_TR_Employee__c
                WHERE RecordType.DeveloperName = 'EUR_TR_AreaManager'
                AND Id IN:areaManagerIds
        ];
        Map<String, EUR_TR_Employee__c> salesChiefsMap = new Map<String, EUR_TR_Employee__c>();
        for (EUR_TR_Employee__c areaManager : areaManagers) {
            for (EUR_TR_Employee__c salesChief : areaManager.EUR_TR_Employee1__r) {
                salesChiefsMap.put(salesChief.Id, salesChief);
            }
        }
        return salesChiefsMap;
    }

    private static Map<String, EUR_TR_Employee__c> getPreSellersMap(Set<String> salesChiefIds) {
        List<EUR_TR_Employee__c> salesChiefs = [
                SELECT Id,Name
                        , (SELECT Id,Name,RecordType.DeveloperName,EUR_TR_ReportsTo_Chief__c FROM EUR_TR_Employee__r)
                FROM EUR_TR_Employee__c
                WHERE RecordType.DeveloperName = 'EUR_TR_SalesChief'
                AND Id IN:salesChiefIds
        ];
        Map<String, EUR_TR_Employee__c> preSellersMap = new Map<String, EUR_TR_Employee__c>();
        for (EUR_TR_Employee__c salesChief : salesChiefs) {
            for (EUR_TR_Employee__c preSeller : salesChief.EUR_TR_Employee__r) {
                preSellersMap.put(preSeller.Id, preSeller);
            }
        }
        return preSellersMap;
    }

    private static EUR_TR_Employee__c getEmployeeFromUserId(Id userId) {
        return [
                SELECT Id,RecordType.DeveloperName
                FROM EUR_TR_Employee__c
                WHERE EUR_TR_RelatedUser__c = :userId
                LIMIT 1
        ];
    }
    private static Decimal calculateAvgScore(List<OJTOrganizationScoresResponse> responses) {
        Decimal total = 0;
        Decimal count = 0;

        for (OJTOrganizationScoresResponse response : responses) {
            if (response.userAvgScore != 0) {
                total += response.userAvgScore;
                count++;
            }
        }

        return count != 0 ? total / count : 0;
    }
    // End getOJTOrganizationScores

    //Models
    public class OJTOrganizationScoresResponse {
        public List<OJTOrganizationScoresResponse> subHierarchies { get; set; }
        public String userName { get; set; }
        public String employeeId { get; set; }
        public String userRole { get; set; }
        public Decimal userAvgScore { get; set; }
        public Decimal countryAvgScore { get; set; }
        public Integer ojtCount { get; set; }
        public List<EUR_TR_OJT__c> data { get; set; }
        public OJTOrganizationScoresResponse manager { get; set; }

        OJTOrganizationScoresResponse() {
            subHierarchies = new List<OJTOrganizationScoresResponse>();
            this.ojtCount = 0;
        }

        OJTOrganizationScoresResponse(OJTOrganizationScoresResponse cloneWithoutHierarchy) {
            this.countryAvgScore = cloneWithoutHierarchy.countryAvgScore;
            this.data = cloneWithoutHierarchy.data;
            this.employeeId = cloneWithoutHierarchy.employeeId;
            this.userAvgScore = cloneWithoutHierarchy.userAvgScore;
            this.userName = cloneWithoutHierarchy.userName;
            this.userRole = cloneWithoutHierarchy.userRole;
            this.ojtCount = cloneWithoutHierarchy.ojtCount;
        }
    }

    public enum OrderByFields {
        name, location
    }

    public enum OrderDirections { ascending, descending }

    public virtual class OJTRequest {
        public Integer pageSize { get; set; }
        public Integer pageNumber { get; set; }
        public EUR_TR_OJT__c data { get; set; }
        public String emailAddress { get; set; }
        public String searchTerm { get; set; }
        public OrderByFields orderBy { get; set; }
        public OrderDirections orderDirection { get; set; }
        public Decimal latitude { get; set; }
        public Decimal longitude { get; set; }

        // getOJTOrganizationScoresFromMiddleware
        public Date queryStartDate { get; set; }
        public Date queryEndDate { get; set; }

        public OJTRequest() {
            if (pageSize == null || pageSize < 0) {
                this.pageSize = 20;
            }

            if (pageNumber == null || pageNumber < 0) {
                this.pageNumber = 1;
            }
        }
    }

    public class OJTActionRequestAfterOJTComplete extends OJTRequest {
        public Boolean sendEmail { get; set; }
        public Boolean addNote { get; set; }
    }

    public class OJTException extends Exception {
    }
}