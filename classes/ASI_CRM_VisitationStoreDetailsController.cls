public class ASI_CRM_VisitationStoreDetailsController {
    @AuraEnabled
    public static CustomerDetail getCustomerProsSegmentation(String recordId) {
        CustomerDetail result = new CustomerDetail();
        
        ASI_CRM_VisitationPlanSetting__c setting = ASI_CRM_VisitationPlanSetting__c.getInstance();
        Set<String> custFieldSet = new Set<String>();
        Set<String> prosFieldSet = new Set<String>();
        List<String> labelList = new List<String>();
        List<String> fieldList = new List<String>();

        custFieldSet.add('ID');
        custFieldSet.add('Name');
        custFieldSet.add(setting.ASI_CRM_Customer_Address__c);
        custFieldSet.add(setting.ASI_CRM_Customer_Phone__c);
        custFieldSet.add('ASI_CRM_CN_GPS_info__Latitude__s');
        custFieldSet.add('ASI_CRM_CN_GPS_info__Longitude__s');
        
        for (Integer i = 1; i <= 10; i++)
        {
            String fieldSetting = String.valueOf(setting.get('ASI_CRM_Customer_Detail_Field_' + i + '__c'));

            if (fieldSetting != null)
            {
                String[] fieldArr = fieldSetting.split('\\|');
                String field = fieldArr[1];

                labelList.add(fieldArr[0]);
                fieldList.add(field);

                if (field.contains('ASI_CRM_AccountsAdditionalField__c'))
                {
                    custFieldSet.add(field.remove('ASI_CRM_AccountsAdditionalField__c.'));
                }
                else if (field.contains('ASI_CRM_Pros_Segmentation__c'))
                {
                    prosFieldSet.add(field.remove('ASI_CRM_Pros_Segmentation__c.'));
                }
            }
        }

        String custField = '';
        String prosField = '';

        if (custFieldSet.size() > 0)
        {
            custField = String.join((Iterable<String>)custFieldSet, ', ');
        }

        if (prosFieldSet.size() > 0)
        {
            prosFieldSet.add('ID');
            prosFieldSet.add('Name');
            prosField = String.join((Iterable<String>)prosFieldSet, ', ');
        }

        string custQuery = 'select '
                            + custField
                            + ' from ASI_CRM_AccountsAdditionalField__c'
                            + ' where Id = :recordId'
                            + ' limit 1';

        List<ASI_CRM_AccountsAdditionalField__c> custList = database.query(custQuery);

        if (custList.size() > 0) {
            result.detail = custList[0];
            result.custAddress = String.valueOf(result.detail.get(setting.ASI_CRM_Customer_Address__c));
            result.custPhone = String.valueOf(result.detail.get(setting.ASI_CRM_Customer_Phone__c));
            
            if (prosFieldSet.size() > 0)
            {
                string prosQuery = 'select '
                                    + prosField
                                    + ' from ASI_CRM_Pros_Segmentation__c'
                                    + ' where ASI_CRM_SG_Customer__c =: recordId'
                                    + ' limit 1';
                
                List<ASI_CRM_Pros_Segmentation__c> prosList = database.query(prosQuery);

                if (prosList.size() > 0)
                {
                    result.pros = prosList[0];
                }
            }
        }

        result.fields = new List<DetailField>();

        for (Integer i = 0; i < labelList.size(); i++)
        {
            String label = labelList[i];
            String[] field = fieldList[i].split('\\.');

            DetailField dField = new DetailField();
            dField.label = label;

            if (field[0] == 'ASI_CRM_AccountsAdditionalField__c' && result.detail != null)
            {
                if (field.size() == 3 && result.detail.getSObject(field[1]) != null)
                {
                    dField.value = String.valueOf(result.detail.getSObject(field[1]).get(field[2]));
                }
                else if (field.size() == 2)
                {
                    dField.value = String.valueOf(result.detail.get(field[1]));
                }
            }
            else if (field[0] == 'ASI_CRM_Pros_Segmentation__c' && result.pros != null)
            {
                if (field.size() == 3 && result.pros.getSObject(field[1]) != null)
                {
                    dField.value = String.valueOf(result.pros.getSObject(field[1]).get(field[2]));
                }
                else if (field.size() == 2)
                {
                    dField.value = String.valueOf(result.pros.get(field[1]));
                }
            }

            result.fields.add(dField);
        }
        
        return result;
    }

    public class DetailField {
        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public String value { get; set; }
    }

    public class CustomerDetail {
        @AuraEnabled 
        public ASI_CRM_AccountsAdditionalField__c detail { get; set; }

        @AuraEnabled 
        public ASI_CRM_Pros_Segmentation__c pros { get; set; }

        @AuraEnabled 
        public String custAddress { get; set; }

        @AuraEnabled 
        public String custPhone { get; set; }

        @AuraEnabled 
        public List<DetailField> fields { get; set; }
    }
}