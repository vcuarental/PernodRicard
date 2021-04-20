/**
 * Created by osman on 25.09.2020.
 */

public with sharing class EUR_TR_POSMController {

    public class EUR_TR_POSMControllerException extends Exception {
    }

    public static EUR_TR_MiddlewareController.PostServiceResponse getPOSMRecordsByAccountIdFromMiddleware(String requestBody) {

        EUR_TR_MiddlewareController.PostServiceResponse serviceResponse = new EUR_TR_MiddlewareController.PostServiceResponse();
        serviceResponse.Code = 1;

        try {
            if (String.isBlank(requestBody)) {
                throw new EUR_TR_POSMControllerException('EUR_TR_RelatedAccount__c parametresi boş olamaz');
            }
            POSMFilterModel body = (POSMFilterModel) JSON.deserialize(requestBody, POSMFilterModel.class);
            serviceResponse.Message = EUR_TR_MiddlewareController.SuccessMessage;
            serviceResponse.ExtensionData = getPOSMRecordsByAccountId(body);
        } catch (Exception ex) {
            serviceResponse.Code = -1;
            serviceResponse.Message = ex.getMessage();
            System.debug(ex.getMessage());
            System.debug(ex.getLineNumber());
            System.debug(ex.getStackTraceString());
        }

        return serviceResponse;

    }

    public static POSMResult getPOSMRecordsByAccountId(POSMFilterModel filterModel) {

        if (filterModel == null) {
            throw new EUR_TR_POSMControllerException('Filtre boş gönderilemez');
        } else if (filterModel.relatedAccount != null && String.isBlank(filterModel.relatedAccount.Id)) {
            throw new EUR_TR_POSMControllerException('EUR_TR_RelatedAccount__c parametresi boş olamaz');
        } else if (filterModel.pageSize == null && filterModel.pageNumber == null) {
            throw new EUR_TR_POSMControllerException('Kayıt sayısı ve sayfa numarası boş gönderilemez');
        }

        Integer offset = filterModel.pageSize * (filterModel.pageNumber - 1);
        Integer rowLimit = filterModel.pageSize;

        Set<Id> POSMIdsByApprovalFilter = getPOSMIdsByApprovalFilter(filterModel);

        Id relatedAccountId = filterModel.relatedAccount.Id;
        String querySelect = '' +
                'SELECT Id' +
                ',Name' +
                ',EUR_TR_ApprovalStatus__c' +
                ',EUR_TR_Brand__c' +
                ',EUR_TR_BrandOther__c' +
                ',EUR_TR_Budget__c' +
                ',EUR_TR_PlacementDate__c' +
                ',EUR_TR_POSMType__c' +
                ',EUR_TR_RelatedAccount__c' +
                ',EUR_TR_RelatedAccount__r.Name' +
                ',EUR_TR_RelatedAccount__r.EUR_TR_AccountCode__c' +
                ',EUR_TR_POSMQuantity__c' +
                ',CreatedDate' +
                ',OwnerId' +
                ',Owner.Name' +
                ',EUR_TR_UnitPrice__c' +
                ',EUR_TR_RelatedPOSMSubType__c' +
                ',EUR_TR_RelatedPOSMSubType__r.Name' +
                ',EUR_TR_RelatedPOSMSubType__r.EUR_TR_UnitPrice__c' +
                ',EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c' +
                ',EUR_TR_RelatedPOSMSubType__r.EUR_TR_IsCarpenterPOSMType__c ';

        String queryFrom = 'FROM EUR_TR_POSM__c ';
        String queryWhere = 'WHERE RecordType.DeveloperName=\'EUR_TR_POSM\' and EUR_TR_RelatedAccount__c=: relatedAccountId ';

        if (!POSMIdsByApprovalFilter.isEmpty()) {
            queryWhere += 'AND  Id IN :POSMIdsByApprovalFilter ';
        }

        if (filterModel.startDate != null) {
            Date starDate = filterModel.startDate;
            queryWhere += 'AND DAY_ONLY(convertTimezone(CreatedDate)) >= :starDate ';
        }

        if (filterModel.endDate != null) {
            Date endDate = filterModel.endDate;
            queryWhere += 'AND DAY_ONLY(convertTimezone(CreatedDate)) <= :endDate ';
        }

        if (filterModel.POSMTypes != null && !filterModel.POSMTypes.isEmpty()) {
            List<String> POSMTypes = filterModel.POSMTypes;
            if (POSMTypes != null && !POSMTypes.isEmpty()) {
                queryWhere += 'AND EUR_TR_POSMType__c  IN:POSMTypes ';
            }
        }

        if (filterModel.POSMSubTypes != null && !filterModel.POSMSubTypes.isEmpty()) {
            List<String> POSMSubTypes = filterModel.POSMSubTypes;
            if (POSMSubTypes != null && !POSMSubTypes.isEmpty()) {
                queryWhere += 'AND EUR_TR_RelatedPOSMSubType__r.Name  IN:POSMSubTypes ';
            }
        }

        if (filterModel.approvalStatuses != null && !filterModel.approvalStatuses.isEmpty()) {
            List<String> approvalStatus = filterModel.approvalStatuses;
            if (approvalStatus != null && !approvalStatus.isEmpty()) {
                queryWhere += 'AND EUR_TR_ApprovalStatus__c  IN:approvalStatus ';
            }
        }

        if (filterModel.brands != null && !filterModel.brands.isEmpty()) {
            List<String> brands = filterModel.brands;
            if (brands != null && !brands.isEmpty()) {
                queryWhere += 'AND EUR_TR_Brand__c  IN:brands ';
            }
        }

        if (filterModel.minBudget != null) {
            Decimal minBudget = filterModel.minBudget;
            queryWhere += 'AND EUR_TR_Budget__c >=:minBudget ';
        }

        if (filterModel.maxBudget != null) {
            Decimal maxBudget = filterModel.maxBudget;
            queryWhere += 'AND EUR_TR_Budget__c <=:maxBudget ';
        }

        String queryOrderDirection = filterModel.orderDirection == OrderDirection.ascending ? 'ASC' : 'DESC';
        String queryOrderBy = '';
        if (filterModel.orderBy == POSMOrderBy.createdDate) {
            queryOrderBy += 'ORDER BY CreatedDate ';
        } else {
            queryOrderBy += 'ORDER BY CreatedDate ';
        }


        String queryOffSetLimit = 'LIMIT :rowLimit OFFSET :offset ';

        String query = String.format('{0} {1} {2} {3} {4} {5} {6}', new List<String>{
                querySelect,
                queryFrom,
                queryWhere,
                queryOrderBy,
                queryOrderDirection,
                'NULLS LAST',
                queryOffsetLimit
        });

        String countQuery = String.format('SELECT COUNT(ID) Total FROM EUR_TR_POSM__c {0} ', new List<String>{
                queryWhere
        });

        System.debug(query);
        System.debug(countQuery);


        Map<Id, EUR_TR_POSM__c> posmMap = new Map<Id, EUR_TR_POSM__c>((EUR_TR_POSM__c[]) Database.query(query));

        List<EUR_TR_Approval__c> approvals = [
                SELECT
                        Id,
                        Name,
                        EUR_TR_RelatedPOSM__c,
                        EUR_TR_Approver__r.Name,
                        EUR_TR_Submitter__r.Name,
                        EUR_TR_ApprovalStatus__c,
                        EUR_TR_ApprovalReason__c,
                        EUR_TR_ApprovalProcessType__c
                FROM EUR_TR_Approval__c
                WHERE EUR_TR_RelatedPOSM__c in :posmMap.keySet() AND RecordType.DeveloperName = 'EUR_TR_POSMApproval'
                ORDER BY CreatedDate DESC
        ];

        Map<Id, EUR_TR_Approval__c> posmToApprovalMap = new Map<Id, EUR_TR_Approval__c>();
        for (EUR_TR_Approval__c approval : approvals) {
            if (approval.EUR_TR_RelatedPOSM__c != null) {
                posmToApprovalMap.put(approval.EUR_TR_RelatedPOSM__c, approval);
            }
        }

        Integer totalRecordSize = Integer.valueOf(Database.query(countQuery).get(0).get('Total'));

        List<POSMWrapper> wrappers = new List<POSMWrapper>();
        POSMWrapper wrapper = null;

        Set<String> relatedPOSMSubTypeDefinitionNames = new Set<String>();
        for (EUR_TR_POSM__c POSMRecord : posmMap.values()) {
            if (POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name != null) {
                relatedPOSMSubTypeDefinitionNames.add(POSMRecord.EUR_TR_RelatedPOSMSubType__r.Name);
            }
        }

        Map<String, EUR_TR_Definition__c> activeRelatedPOSMSubTypeNameToDefinitionMap = new Map<String, EUR_TR_Definition__c>();

        for (EUR_TR_Definition__c definition : [
                SELECT Id,Name,EUR_TR_UnitPrice__c,EUR_TR_POSMType__c,EUR_TR_IsCarpenterPOSMType__c
                FROM EUR_TR_Definition__c
                WHERE Name = :relatedPOSMSubTypeDefinitionNames AND RecordType.DeveloperName = 'EUR_TR_POSMType' AND EUR_TR_POSMTypeStatus__c = 'Aktif'
        ]) {
            activeRelatedPOSMSubTypeNameToDefinitionMap.put(definition.Name, definition);
        }


        for (EUR_TR_POSM__c eurTrPosm : posmMap.values()) {
            wrapper = new POSMWrapper();
            wrapper.POSMRecord = eurTrPosm;
            if (posmToApprovalMap.containsKey(eurTrPosm.Id)) {
                wrapper.approval = posmToApprovalMap.get(eurTrPosm.Id);
                wrapper.actions = EUR_TR_POSMApprovalController.getActionsByPOSMApprovalRecord(wrapper.approval);
            } else {
                wrapper.actions = EUR_TR_POSMApprovalController.getActionsByPOSMRecord(eurTrPosm);
            }
            if (wrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c != null && wrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c == 'Aktif') {
                wrapper.activePOSMSubTypeDefinition = eurTrPosm.EUR_TR_RelatedPOSMSubType__r;
            } else if (wrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c != null && wrapper.POSMRecord.EUR_TR_RelatedPOSMSubType__r.EUR_TR_POSMTypeStatus__c == 'Pasif') {
                if (activeRelatedPOSMSubTypeNameToDefinitionMap != null && !activeRelatedPOSMSubTypeNameToDefinitionMap.isEmpty() && eurTrPosm.EUR_TR_RelatedPOSMSubType__r.Name != null) {
                    if (activeRelatedPOSMSubTypeNameToDefinitionMap.containsKey(eurTrPosm.EUR_TR_RelatedPOSMSubType__r.Name)) {
                        EUR_TR_Definition__c activeRelatedPOSMSubDefinition = activeRelatedPOSMSubTypeNameToDefinitionMap.get(eurTrPosm.EUR_TR_RelatedPOSMSubType__r.Name);
                        wrapper.activePOSMSubTypeDefinition = activeRelatedPOSMSubDefinition;
                    } else {
                        wrapper.activePOSMSubTypeDefinition = null;
                    }
                }
            } else {
                wrapper.activePOSMSubTypeDefinition = null;
            }
            wrappers.add(wrapper);
        }

        POSMResult result = new POSMResult();
        result.records = wrappers;
        result.totalRecordSize = totalRecordSize;
        return result;

    }

    public static Set<Id> getPOSMIdsByApprovalFilter(POSMFilterModel filterModel) {

        Set<Id> POSMRecordIDs = new Set<Id>();
        Id relatedAccountId = filterModel.relatedAccount.Id;
        Integer offset = filterModel.pageSize * (filterModel.pageNumber - 1);
        Integer rowLimit = filterModel.pageSize;

        String querySelect = '' +
                'SELECT Id,EUR_TR_RelatedPOSM__c ' +
                'FROM EUR_TR_Approval__c ';
        String queryWhere = '' +
                'WHERE EUR_TR_RelatedPOSM__r.EUR_TR_RelatedAccount__c = :relatedAccountId ' +
                'AND RecordType.DeveloperName = \'EUR_TR_POSMApproval\' ' ;
        String queryLimit = '' +
                'LIMIT :rowLimit ' +
                'OFFSET :offset';

        Boolean filterIsExist = false;

        if (filterModel.actorIds != null && !filterModel.actorIds.isEmpty()) {
            List<Id> actorIds = filterModel.actorIds;
            System.debug(actorIds);
            queryWhere += 'AND (EUR_TR_Approver__c in :actorIds OR EUR_TR_Submitter__c in :actorIds) ';
            filterIsExist = true;
        }

        if (filterModel.approvalProcessTypes != null && !filterModel.approvalProcessTypes.isEmpty()) {
            filterIsExist = true;
            List<String> approvalProcessTypes = filterModel.approvalProcessTypes;
            queryWhere += 'AND (EUR_TR_ApprovalProcessType__c in :approvalProcessTypes ) ';
        }

        if (filterIsExist) {
            String query = '{0} {1} {2} ';
            query = String.format(query, new List<String>{
                    querySelect,
                    queryWhere,
                    queryLimit
            });

            System.debug(query);

            List<EUR_TR_Approval__c> approvalsToObtainPOSMIds = Database.query(query);
            for (EUR_TR_Approval__c approval : approvalsToObtainPOSMIds) {
                if (approval.EUR_TR_RelatedPOSM__c != null) {
                    POSMRecordIDs.add(approval.EUR_TR_RelatedPOSM__c);
                }
            }

        }

        return POSMRecordIDs;

    }

    public class POSMWrapper {
        public EUR_TR_POSM__c POSMRecord { get; set; }
        public EUR_TR_Approval__c approval { get; set; }
        public List<EUR_TR_POSMApprovalController.ButtonAction> actions { get; set; }
        public EUR_TR_Definition__c activePOSMSubTypeDefinition { get; set; }
    }

    public class POSMResult {
        public Integer totalRecordSize { get; set; }
        public List<POSMWrapper> records { get; set; }
    }

    public virtual class POSMFilterModel {
        public Integer pageSize { get; set; }
        public Integer pageNumber { get; set; }
        public List<String> approvalStatuses { get; set; }
        public List<String> brands { get; set; }
        public List<String> POSMTypes { get; set; }
        public List<String> POSMSubTypes { get; set; }
        public Integer minBudget { get; set; }
        public Integer maxBudget { get; set; }
        public List<Id> actorIds { get; set; }
        public Date startDate { get; set; }
        public Date endDate { get; set; }
        public List<String> approvalProcessTypes { get; set; }
        public POSMOrderBy orderBy { get; set; }
        public OrderDirection orderDirection { get; set; }
        public EUR_TR_Account__c relatedAccount { get; set; }
    }

    public enum OrderDirection {
        ascending, descending
    }

    public enum POSMOrderBy {
        createdDate, approvalType, approvalStatus
    }


}