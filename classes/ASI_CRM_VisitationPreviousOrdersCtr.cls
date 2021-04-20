public class ASI_CRM_VisitationPreviousOrdersCtr {
    @AuraEnabled
    public static IOTSummary getPreviousOrders(Id customerId, Integer limitPerPage, Integer offset) {
        ASI_CRM_VisitationRTypeMapping__c recordTypeMapping = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		Id iotHeaderRTID = Global_RecordTypeCache.getRtId(recordTypeMapping.ASI_CRM_IOTHeaderRTypeAPI__c);
		Id iotDetailRTID = Global_RecordTypeCache.getRtId(recordTypeMapping.ASI_CRM_IOTDetailRTypeAPI__c);

        IOTSummary result = new IOTSummary();

        List<ASI_CRM_IOTHeader__c> iotHeaders = [SELECT Id, 
                                                 ASI_CRM_Customer__c, 
                                                 CreatedDate
                                                 FROM ASI_CRM_IOTHeader__c
                                                 WHERE ASI_CRM_Customer__c = :customerId
                                                 AND RecordTypeId = :iotHeaderRTID
                                                 ORDER BY CreatedDate DESC
                                                 LIMIT :limitPerPage
                                                 OFFSET :offset
                                                 ];

        Set<Id> headerIds = new Set<Id>();
        for (ASI_CRM_IOTHeader__c iotHeader : iotHeaders) 
        {
            headerIds.add(iotHeader.Id);
        }

        List<ASI_CRM_IOTLine__c> iotDetails = [SELECT
                                                ASI_CRM_IOTHeader__c,
                                                ASI_CRM_Quantity__c,
                                                ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c
                                                FROM ASI_CRM_IOTLine__c
                                                WHERE ASI_CRM_IOTHeader__c IN :headerIds
                                                AND RecordTypeId = :iotDetailRTID
        ];

        String countQuery = 'SELECT Count() '
            + 'FROM ASI_CRM_IOTHeader__c '
            + 'WHERE ASI_CRM_Customer__c = :customerId '
            + 'AND RecordTypeId = :iotHeaderRTID';

        result.total = Database.countQuery(countQuery);
        result.iotHeaders = iotHeaders;
        result.iotDetails = iotDetails;

        return result;
    }

    @AuraEnabled
    public static IOTSummary getOrderDetails(Id headerId) {
        ASI_CRM_VisitationRTypeMapping__c recordTypeMapping = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		Id iotHeaderRTID = Global_RecordTypeCache.getRtId(recordTypeMapping.ASI_CRM_IOTHeaderRTypeAPI__c);
		Id iotDetailRTID = Global_RecordTypeCache.getRtId(recordTypeMapping.ASI_CRM_IOTDetailRTypeAPI__c);

        IOTSummary result = new IOTSummary();

        result.iotHeaders = [SELECT Id, 
                             ASI_CRM_Customer__c,
                             ASI_CRM_ContactPerson__c,
                             ASI_CRM_ContactNumber__c,
                             ASI_CRM_Wholesaler__c,
                             ASI_CRM_Wholesaler__r.Name,
                             ASI_CRM_ExpectedDeliveryDate__c,
                             ASI_CRM_Remarks__c,
                             CreatedDate
                             FROM ASI_CRM_IOTHeader__c
                             WHERE RecordTypeId = :iotHeaderRTID
                             AND Id = :headerId
                             LIMIT 1
        ];

        result.iotDetails = [SELECT
                             ASI_CRM_IOTHeader__c,
                             ASI_CRM_Quantity__c,
                             ASI_CRM_SKU__r.ASI_MFM_SKU_Code__c,
                             ASI_CRM_SKU__r.Name,
                             ASI_CRM_SKU__r.ASI_HK_CRM_Base_Price__c
                             FROM ASI_CRM_IOTLine__c
                             WHERE ASI_CRM_IOTHeader__c = :headerId
                             AND RecordTypeId = :iotDetailRTID
        ];

        result.total = 1;

        return result;
    }

    public class IOTSummary {
        @AuraEnabled 
        public Integer total {get; set;}

        @AuraEnabled 
        public List<ASI_CRM_IOTHeader__c> iotHeaders {get; set;}

        @AuraEnabled 
        public List<ASI_CRM_IOTLine__c> iotDetails {get; set;}

        public IOTSummary() {
            this.total = 0;
            this.iotHeaders = new List<ASI_CRM_IOTHeader__c>();
            this.iotDetails = new List<ASI_CRM_IOTLine__c>();
        }
    }
}