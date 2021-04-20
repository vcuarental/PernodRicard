public with sharing class LAT_VFC13_APClientPaymentController {

    public List<LAT_ActionClientPaymentLine__c> acpList {get; set;}
    public LAT_ActionClientPayment__c acp {get; set;}
    public boolean isEdit {get; set;}
    public boolean onlyDisplay {get; set;}

    public LAT_VFC13_APClientPaymentController(ApexPages.StandardController controller) {
				if (!Test.isRunningTest()) {
					controller.addFields(new LIST<String> {'LAT_Status__c'});
				}
	      String accId = controller.getId();
        LAT_AccountInAction__c aiac = (LAT_AccountInAction__c)controller.getRecord();
        List<LAT_ActionClientPayment__c> acpList = [SELECT id, LAT_AccountInAction__c, LAT_AccountInAction__r.Name, LAT_Contact__c,
                                                        (Select id, LAT_ActionClientPayment__c, LAT_Description__c,
                                                                LAT_Value__c FROM ActionClientPaymentLines__r)
                                                    FROM LAT_ActionClientPayment__c
                                                    WHERE LAT_AccountInAction__c =: accId];

        this.isEdit = false;
        this.onlyDisplay = false;
        if (aiac.LAT_Status__c == 'Pagamentos Autorizados') {
            this.onlyDisplay = true;
        }
        if (!acpList.isEmpty()) {
            this.acp = acpList.get(0);
            this.acpList = acp.ActionClientPaymentLines__r;
            if (acpList.size() <= 4) {
                for (Integer i = acpList.size(); i <= 4; i++) {
                    this.acpList.add(new LAT_ActionClientPaymentLine__c(LAT_ActionClientPayment__c = acp.id));
                }
            }
        } else {
            this.acpList = new List<LAT_ActionClientPaymentLine__c>();
            this.acpList.add(new LAT_ActionClientPaymentLine__c());
            this.acpList.add(new LAT_ActionClientPaymentLine__c());
            this.acpList.add(new LAT_ActionClientPaymentLine__c());
            this.acpList.add(new LAT_ActionClientPaymentLine__c());
            this.acp = new LAT_ActionClientPayment__c();
            this.acp.LAT_AccountInAction__c = accId;
        }
    }

    public pageReference showEdit() {
        this.isEdit = true;
        return null;
    }

    public void save() {
        List<LAT_ActionClientPaymentLine__c> toUpser = new List<LAT_ActionClientPaymentLine__c>();
        if (this.acp.id != null) {
            update acp;
            for (LAT_ActionClientPaymentLine__c acpl: acpList) {
                if (acpl.id != null) {
                    toUpser.add(acpl);
                }
            }
        } else {
            upsert this.acp;
            for (LAT_ActionClientPaymentLine__c acpl: acpList) {
                if (acpl.LAT_Description__c != null && acpl.LAT_Value__c != null) {
                    acpl.LAT_ActionClientPayment__c = this.acp.id;
                    toUpser.add(acpl);
                }
            }
        }

        if (!toUpser.isEmpty()) {
            upsert toUpser;
        }
        this.isEdit = false;
    }

}