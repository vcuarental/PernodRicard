public with sharing class EUR_DOC_CompoundObject implements Comparable {

    @AuraEnabled
    public String Id {get;set;}

    @AuraEnabled
    public String salesName {get;set;}

    @AuraEnabled
    public String accountName {get;set;}

    @AuraEnabled
    public String accountAddress {get;set;}

    @AuraEnabled
    public String module {get;set;}

    @AuraEnabled
    public String pictureUrl {get;set;}

    @AuraEnabled
    public String region {get;set;}

    @AuraEnabled
    public String territory {get;set;}

    @AuraEnabled
    public String createdDate {get;set;}

    public DateTime originalDate;

    @AuraEnabled
    public boolean dlCheckbox {get;set;}

    
    public String getValue(SObject o, String field) {
        List<String> fields = field.split('\\.');

        if(fields.size() == 1) {
            return (o.get(field) == null ? '' : (String) o.get(field));
        } else {
            //recursive call
            String relation = fields.remove(0);
            System.debug('RELATION: ' + relation);
            SObject o2 = o.getSObject(relation);
            if(o2 == null) {
                return '';
            } else {
                return this.getValue(o2, String.join(fields, '.'));
            }
        }
    }
    private EUR_DOC_CompoundObject(Attachment att, SObject o, String accPrefix, String module) {
        this.createdDate = att.CreatedDate.formatGMT('MMM d, yyyy');
        this.originalDate = att.CreatedDate;
        this.pictureUrl = att.Id;
        this.salesName = att.Owner.Name;
        this.dlCheckbox = false;
        this.Id = (String) this.getValue(o, accPrefix + 'Id');
        this.accountName = this.getValue(o, accPrefix + 'Name');
        this.accountAddress = this.getValue(o, accPrefix + 'EUR_CRM_Street__c') + ' ' + this.getValue(o, accPrefix + 'EUR_CRM_City__c');
        this.module = module;
        this.region = this.getValue(o, accPrefix + 'EUR_CRM_Region__c');
        this.territory = this.getValue(o, accPrefix + 'EUR_CRM_Territory__r.Name');
    }

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_Account__c acc) {
        this(att, acc, '', 'ACC');
    }

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_Menu_Feature__c menu) {
        this(att, menu, 'EUR_CRM_Account__r.', 'MENU');
    }
    
    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_GB_Objective__c po) {
        this(att, po, 'EUR_CRM_Account__r.', 'PO');
    }

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_OP_VIsit_Action__c op) {
        this(att, op, 'EUR_CRM_OP_Account_in_Promo__r.EUR_CRM_Account__r.', 'OP');
    }

    

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_POSM_Audit_Item__c posm) {
        this(att, posm, 'EUR_CRM_POSM_Audit__r.EUR_CRM_Account__r.', 'POSM');
    }
    
    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_Competitor_Promo_Tracking_Item__c cpt) {
        this(att, cpt, 'EUR_CRM_Competitor_Promo_Tracking__r.EUR_CRM_Account_Name__r.', 'CPT');
    }

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_Brand_Security_Infringement__c bs) {
        this(att, bs, 'EUR_CRM_Visit_ID__r.EUR_CRM_Account__r.', 'BS');
    }

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_Sales_Order__c so) {
        this(att, so, 'EUR_CRM_Account__r.', 'SO');
        
    }

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_Visit_Action__c va) {
        this(att, va, 'EUR_CRM_Visit_ID__r.EUR_CRM_Account__r.', 'VA');
    }

    public EUR_DOC_CompoundObject(Attachment att, EUR_CRM_Visit_Sub_Action__c vsa) {
        this(att, vsa, 'EUR_CRM_Visit_Action__r.EUR_CRM_Visit_ID__r.EUR_CRM_Account__r.', 'VA');
    }

    public Integer compareTo(Object compareTo) {
        EUR_DOC_CompoundObject compareToRecord = (EUR_DOC_CompoundObject) compareTo;
        Integer returnValue = 0;
        if (originalDate > compareToRecord.originalDate) {
            returnValue = -1;
        } else if (originalDate < compareToRecord.originalDate) {
            returnValue = 1;
        }
        return returnValue;       
    }

} //end of class