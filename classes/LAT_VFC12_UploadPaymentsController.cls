public with sharing class LAT_VFC12_UploadPaymentsController {
	public Blob toParse {get; set;}

	public LAT_VFC12_UploadPaymentsController() {}

	 // Carga Csv
    public void upload() {

        try{
            List<List<String>> values = LAT_Utils.parseCSV(toParse.toString(), true);
            system.debug('values---->' + values);

            if(values.size() <= 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'O arquivo não contém dados'));
            } else {

                String webURL = ApexPages.currentPage().getParameters().get('id');
                System.debug(webURL);
                if(webURL !=NULL && webURL != ''){
                    List<String> ids = new List<String>();
                    for (List<String> valList: values) {
                        if(valList.size() >= 1){
                            ids.add(valList[0].replaceall('"',''));
                        }
                    }
                    system.debug('ids---->'+ids);
                    List<LAT_AccountInAction__c> clientes = [SELECT id, Name, LAT_PromotionalAction__r.LAT_CollectData__c,
	    												LAT_PromotionalAction__r.LAT_ActivationMaterial__c,
	    												LAT_CollectData__c, LAT_RetireMaterials__c,
	    												LAT_PromotionalAction__r.LAT_endDate__c, LAT_Account__r.ownerId,
	    												LAT_PromotionalAction__r.LAT_Status__c, LAT_PromotionalAction__c
	    											FROM LAT_AccountInAction__c
	    											WHERE id =: ids];

                    if(clientes != null && clientes.size() > 0){

                        Map<String, LAT_ActionClientPayment__c> acpMap = new Map<String, LAT_ActionClientPayment__c>();
                        Map<String, List<LAT_ActionClientPaymentLine__c>> acplMap = new Map<String, List<LAT_ActionClientPaymentLine__c>>();

                        for (List<String> valList: values) {
                        	String description1 = '';
					    						String value1 = '';

							    				String description2 = '';
							    				String value2 = '';

							    				String description3 = '';
							    				String value3 = '';

							    				String description4 = '';
							    				String value4 = '';

							    				if (valList[0] != '') {
							    					String clientId = valList[0].replaceall('"','');

							    					if(valList.size() >= 10){
	                            	if (valList[2] != '' && valList[3] != '') {
	                            		description1 = valList[2].replaceall('"','');
	                            		value1 = valList[3].replaceall('"','');
	                            	}
	                            	if (valList[4] != '' && valList[5] != '') {
	                            		description2 = valList[4].replaceall('"','');
	                            		value2 = valList[5].replaceall('"','');
	                            	}
	                            	if (valList[6] != '' && valList[7] != '') {
	                            		description3 = valList[6].replaceall('"','');
	                            		value3 = valList[7].replaceall('"','');
	                            	}
	                            	if (valList[8] != '' && valList[9] != '') {
	                            		description4 = valList[8].replaceall('"','');
	                            		value4 = valList[9].replaceall('"','');
	                            	}
	                        	}

	                        	List<LAT_ActionClientPaymentLine__c> acplList = new List<LAT_ActionClientPaymentLine__c>();
	                        	if (description1 != '' && value1 != '') {
	                        		LAT_ActionClientPaymentLine__c acpl1 = new LAT_ActionClientPaymentLine__c();
	                        		acpl1.LAT_Description__c = description1;
	                        		acpl1.LAT_Value__c = formatString(value1);
	                        		acplList.add(acpl1);
	                        	}
	                        	if (description2 != '' && value2 != '') {
	                        		LAT_ActionClientPaymentLine__c acpl2 = new LAT_ActionClientPaymentLine__c();
	                        		acpl2.LAT_Description__c = description2;
	                        		acpl2.LAT_Value__c = formatString(value2);
	                        		acplList.add(acpl2);
	                        	}
	                        	if (description3 != '' && value3 != '') {
	                        		LAT_ActionClientPaymentLine__c acpl3 = new LAT_ActionClientPaymentLine__c();
	                        		acpl3.LAT_Description__c = description3;
	                        		acpl3.LAT_Value__c = formatString(value3);
	                        		acplList.add(acpl3);
	                        	}
	                        	if (description4 != '' && value4 != '') {
	                        		LAT_ActionClientPaymentLine__c acpl4 = new LAT_ActionClientPaymentLine__c();
	                        		acpl4.LAT_Description__c = description4;
	                        		acpl4.LAT_Value__c = formatString(value4);
	                        		acplList.add(acpl4);
	                        	}

	                        	if (!acplList.isEmpty()) {
	                        		acpMap.put(clientId, new LAT_ActionClientPayment__c(LAT_AccountInAction__c = clientId));
	                        		acplMap.put(clientId, acplList);
	                        	}
	                        }
												}

												if (!acpMap.keySet().isEmpty()) {
													//Reset Payments
													delete [SELECT id FROM LAT_ActionClientPayment__c WHERE LAT_AccountInAction__c IN: clientes];
													insert acpMap.values();

													List<LAT_ActionClientPaymentLine__c> finalAcplList = new List<LAT_ActionClientPaymentLine__c>();
													for (LAT_ActionClientPayment__c acp: acpMap.values()) {
														if (acplMap.get(acp.LAT_AccountInAction__c) != null) {
															for (LAT_ActionClientPaymentLine__c acpl: acplMap.get(acp.LAT_AccountInAction__c)) {
																acpl.LAT_ActionClientPayment__c = acp.id;
																finalAcplList.add(acpl);
															}
														}
													}
													insert finalAcplList;
												}

                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Carga realizada com sucesso. <a href="/'+ webURL +'">' + 'Voltar para Ação Promocional' + '</a>'));
                    } else {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'O arquivo não contém dados válidos.'));
                    }
                } else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Inválido ação promocional.'));
                }
            }
        } catch(exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

		public PageReference cancel() {
			String webURL = ApexPages.currentPage().getParameters().get('id');
			return new PageReference('/' + webURL);
		}

		public static Decimal formatString(String s) {
			Decimal result = 0;
			List<String> splited = s.split(',');
			if (splited.size() == 2) {
				result = Decimal.valueOf(s.replaceAll(',','.'));
			} else {
				result = Decimal.valueOf(s);
			}
			return result;
		}
}