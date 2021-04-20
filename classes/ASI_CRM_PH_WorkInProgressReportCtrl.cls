public with sharing class ASI_CRM_PH_WorkInProgressReportCtrl {

    public static final Set<String> PH_RECORD_TYPE_DEV_NAME_LIST = new Set<String> {
        'ASI_CRM_PH_Customer',
        'ASI_CRM_PH_Potential_Outlet'
    };

    public static final Date TODAY = Date.today();

    public ASI_CRM_PH_WorkInProgressReportCtrl() {
    }

    @AuraEnabled
    public static List<CustomerDataSet> getCustomerDataSet() {
        List<ASI_CRM_AccountsAdditionalField__c> customerList = getCustomerList();

        Set<Id> customerIdSet = new Set<Id>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) 
            customerIdSet.add(customer.Id);

        Map<Id, Contact> customerIdContactMap = getCustomerIdContactMap(customerIdSet);
        Set<Id> contractedCustomerIdSet = getContractedCustomerIdSet(customerIdSet);
        Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c> customerIdLatestVisitationPlanDetailMap = getCustomerIdLatestVisitationPlanDetailMap(customerIdSet);
    
        List<CustomerDataSet> customerDataSetList = new List<CustomerDataSet>();
        for(ASI_CRM_AccountsAdditionalField__c customer : customerList) {
            Contact contact = customerIdContactMap.get(customer.Id);

            ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail = customerIdLatestVisitationPlanDetailMap.get(customer.Id);

            if(visitationPlanDetail != null && visitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c != null) 
                customer.ASI_CRM_Last_Visit_Date__c = visitationPlanDetail.ASI_TH_CRM_Visit_Date_Time_From__c.date();
            else if(visitationPlanDetail != null)
                customer.ASI_CRM_Last_Visit_Date__c = visitationPlanDetail.ASI_HK_CRM_Visit_Date__c;

            CustomerDataSet customerDataSet = new CustomerDataSet(customer, 
                contact != null ? contact.Name + ' ' + contact.Phone : '', 
                visitationPlanDetail,
                contractedCustomerIdSet.contains(customer.Id) ? 'Contracted' : 'No Contract');

            customerDataSetList.add(customerDataSet);
        }

        return customerDataSetList;
    }

    private static List<ASI_CRM_AccountsAdditionalField__c> getCustomerList() {
        String queryStr = 'SELECT Id, '
                        + 'Name, '
                        + 'ASI_CRM_SG_Area__c, '
                        + 'ASI_CRM_Last_Visit_Date__c, '
                        + 'OwnerId, '
                        + 'Owner.Name '
                        + 'FROM ASI_CRM_AccountsAdditionalField__c '
                        + 'WHERE RecordType.DeveloperName in :PH_RECORD_TYPE_DEV_NAME_LIST '
                        + 'AND ASI_CRM_CN_Inactive_Flag__c = false ';

        List<ASI_CRM_AccountsAdditionalField__c> customerList = [SELECT Id,
            Name, 
            ASI_CRM_SG_Area__c,
            ASI_CRM_Last_Visit_Date__c, 
            OwnerId,
            Owner.Name
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE RecordType.DeveloperName in :PH_RECORD_TYPE_DEV_NAME_LIST
            AND ASI_CRM_CN_Inactive_Flag__c = false
        ];

        return customerList;
    }

    private static Map<Id, Contact> getCustomerIdContactMap(Set<Id> customerIdSet) {
        List<Contact> contactList = [SELECT Id, 
            Name, 
            Phone,
            ASI_CRM_AccountAdditionalField__c
            FROM Contact
            WHERE ASI_CRM_AccountAdditionalField__c in :customerIdSet];
        
        Map<Id, Contact> customerIdContactMap = new Map<Id, Contact>();
        for(Contact contact : contactList) {
            customerIdContactMap.put(contact.ASI_CRM_AccountAdditionalField__c, contact);
        }
        
        return customerIdContactMap;
    }

    private static Set<Id> getContractedCustomerIdSet(Set<Id> customerIdSet) {
        List<ASI_TH_CRM_Contract__c> contractList = [SELECT Id,
            Name,
            ASI_CRM_CN_Outlet_WS__c,
            ASI_CRM_CN_Approval_Status__c,
            ASI_TH_CRM_Start_Date__c,
            ASI_TH_CRM_End_Date__c
            FROM ASI_TH_CRM_Contract__c
            WHERE ASI_CRM_CN_Outlet_WS__c in :customerIdSet
            AND ASI_TH_CRM_Start_Date__c <= TODAY
            AND ASI_TH_CRM_End_Date__c >= TODAY
            AND ASI_CRM_CN_Approval_Status__c = 'Approved'
            ];

        Set<Id> contractedCustomerIdSet = new Set<Id>();
        for(ASI_TH_CRM_Contract__c contract : contractList) {
            contractedCustomerIdSet.add(contract.ASI_CRM_CN_Outlet_WS__c);
        }

        return contractedCustomerIdSet;
    }

    private static Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c> getCustomerIdLatestVisitationPlanDetailMap(Set<Id> customerIdSet) {
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = [SELECT Id, 
            Name, 
            ASI_HK_CRM_Visit_Date__c,
            ASI_CRM_MY_Customer__c,
            ASI_CRM_Menu_Listing__c, 
            ASI_CRM_On_Going_Promotion__c,
            ASI_CRM_Pouring__c,
            ASI_CRM_Next_Step__c,
            ASI_TH_CRM_Visit_Date_Time_From__c
            FROM ASI_HK_CRM_Visitation_Plan_Detail__c
            WHERE ASI_CRM_MY_Customer__c in :customerIdSet 
            AND ASI_HK_CRM_Visit_Date__c = LAST_90_DAYS
            AND ASI_HK_CRM_Status__c = 'Achieved'
            ORDER BY ASI_HK_CRM_Visit_Date__c DESC];

        Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c> customerIdLatestVisitationPlanDetailMap = new Map<Id, ASI_HK_CRM_Visitation_Plan_Detail__c>();
        for(ASI_HK_CRM_Visitation_Plan_Detail__c visitationPlanDetail : visitationPlanDetailList) {
            if(customerIdLatestVisitationPlanDetailMap.containsKey(visitationPlanDetail.ASI_CRM_MY_Customer__c)) 
                continue;
            else 
                customerIdLatestVisitationPlanDetailMap.put(visitationPlanDetail.ASI_CRM_MY_Customer__c, visitationPlanDetail);
        }

        return customerIdLatestVisitationPlanDetailMap;
    }

    public class CustomerDataSet {
        @AuraEnabled  
        public ASI_CRM_AccountsAdditionalField__c customer;
        @AuraEnabled  
        public String contact;
        @AuraEnabled  
        public ASI_HK_CRM_Visitation_Plan_Detail__c latestVisitationPlanDetail;
        @AuraEnabled  
        public String status;

        public CustomerDataSet(ASI_CRM_AccountsAdditionalField__c customer, 
            String contact,
            ASI_HK_CRM_Visitation_Plan_Detail__c latestVisitationPlanDetail, 
            String status) {
            this.customer                   = customer;
            this.contact                    = contact;
            this.latestVisitationPlanDetail = latestVisitationPlanDetail;
            this.status                     = status;
        }
    }

}