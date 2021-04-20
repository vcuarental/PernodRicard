public without sharing class LAT_VFC11_PAExportPaymentsController {

    public List<rowWrapper> rows {get; set;}

    public LAT_VFC11_PAExportPaymentsController() {
        Map<String,String> params = ApexPages.currentPage().getParameters();
        String paid = params.get('id');

        rows = new List<rowWrapper>();

        if ( paid != null) {
            List<LAT_AccountInAction__c> clientes = [SELECT id, Name, LAT_PromotionalAction__r.LAT_CollectData__c,
                                                        LAT_PromotionalAction__r.LAT_ActivationMaterial__c,
                                                        LAT_CollectData__c, LAT_RetireMaterials__c,
                                                        LAT_PromotionalAction__r.LAT_endDate__c, LAT_Account__r.ownerId,
                                                        LAT_PromotionalAction__r.LAT_Status__c, LAT_PromotionalAction__c,
																												LAT_Account__r.Name
                                                    FROM LAT_AccountInAction__c
                                                    WHERE LAT_PromotionalAction__c =: paid AND
                                                      (LAT_Status__c = 'Ação aprovada pelo cliente' OR LAT_status__c = 'Ação Finalizada')];

            if (!clientes.isEmpty()) {
                List<LAT_ActionClientPayment__c> acpList = [SELECT id, LAT_AccountInAction__c, LAT_AccountInAction__r.Name,
                                                                (Select id, LAT_ActionClientPayment__c, LAT_Description__c,
                                                                        LAT_Value__c FROM ActionClientPaymentLines__r)
                                                            FROM LAT_ActionClientPayment__c
                                                            WHERE LAT_AccountInAction__c IN: clientes];

                Map<String, LAT_ActionClientPayment__c> acpMap = new Map<String, LAT_ActionClientPayment__c>();
                for (LAT_ActionClientPayment__c acp: acpList) {
                    acpMap.put(acp.LAT_AccountInAction__c, acp);
                }

                //Header
                rows.add(new rowWrapper('ID CLIENTE', 'CLIENTE', 'Descrição 1', 'Valor/Quantidade 1',
                                        'Descrição 2', 'Valor/Quantidade 2',
                                        'Descrição 3', 'Valor/Quantidade 3',
                                        'Descrição 4', 'Valor/Quantidade 4'));

                for (LAT_AccountInAction__c aia: clientes) {
                    String description1 = '';
                    String value1 = '';

                    String description2 = '';
                    String value2 = '';

                    String description3 = '';
                    String value3 = '';

                    String description4 = '';
                    String value4 = '';

                    if (acpMap.get(aia.id) != null) {

                        integer counter = 1;
                        for (LAT_ActionClientPaymentLine__c acpl: acpMap.get(aia.id).ActionClientPaymentLines__r) {
                            if (counter == 1) {
                                description1 = acpl.LAT_Description__c;
                                value1 = String.valueOf(acpl.LAT_Value__c);
                            } else if (counter == 2) {
                                description2 = acpl.LAT_Description__c;
                                value2 = String.valueOf(acpl.LAT_Value__c);
                            } else if (counter == 3) {
                                description3 = acpl.LAT_Description__c;
                                value3 = String.valueOf(acpl.LAT_Value__c);
                            } else if (counter == 4) {
                                description4 = acpl.LAT_Description__c;
                                value4 = String.valueOf(acpl.LAT_Value__c);
                            }

                            counter++;
                        }
                    }
                    rows.add(new rowWrapper(aia.id, aia.LAT_Account__r.Name, description1, value1, description2, value2,
                                            description3, value3, description4, value4));
                }
            }


        }

    }

    public class rowWrapper {
        public String clientId {get; set;}
        public String clientName {get; set;}

        public String description1 {get;Set;}
        public String value1 {get;Set;}

        public String description2 {get;Set;}
        public String value2 {get;Set;}

        public String description3 {get;Set;}
        public String value3 {get;Set;}

        public String description4 {get;Set;}
        public String value4 {get;Set;}

        public rowWrapper (String clientId, String clientName, String description1, String value1,
                                    String description2, String value2,
                                    String description3, String value3,
                                    String description4, String value4){
            this.clientId = clientId;
            this.clientName = clientName;

            this.description1 = description1;
            this.value1 = value1;

            this.description2 = description2;
            this.value2 = value2;

            this.description3 = description3;
            this.value3 = value3;

            this.description4 = description4;
            this.value4 = value4;
        }
    }
}