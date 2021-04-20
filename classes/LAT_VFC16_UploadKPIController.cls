public with sharing class LAT_VFC16_UploadKPIController {
	public Blob toParse {get; set;}

	public LAT_VFC16_UploadKPIController() {}

	public void upload() {
		try {
			List<List<String>> values = LAT_Utils.parseCSV(toParse.toString(), true);
			system.debug('values---->' + values);

			if(values.size() <= 0){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'O arquivo não contém dados'));
			} else {
					String paId = ApexPages.currentPage().getParameters().get('id');
					System.debug(paId);
					if (paId !=NULL && paId != '') {
							List<String> ids = new List<String>();
							for (List<String> valList: values) {
									if(valList.size() >= 1){
											ids.add(valList[0].replaceall('"',''));
									}
							}
							system.debug('ids---->'+ids);

							Map<id, LAT_ClientActionKPI__c> kpiCIUpdate = new Map<id, LAT_ClientActionKPI__c>([SELECT id, LAT_ActionKPI__c, LAT_ActionKPI__r.LAT_KPI__r.Name,
																																 LAT_AccountInAction__c, LAT_Done__c, LAT_Provided__c, LAT_RealGoal__c
																																 FROM LAT_ClientActionKPI__c WHERE LAT_AccountInAction__r.LAT_PromotionalAction__c =: paId AND id IN: ids]);
						  List<LAT_ClientActionKPI__c> kpiCUpdate = new List<LAT_ClientActionKPI__c>();
							if (!kpiCIUpdate.values().isEmpty()){
								for (List<String> valList: values) {
									if(valList.size() >= 5){
										String cakpiId = valList[0].replaceall('"','');
										if (kpiCIUpdate.get(cakpiId) != null) {
											LAT_ClientActionKPI__c caKPI = kpiCIUpdate.get(cakpiId);
											if (valList[3] != '') {
												caKPI.LAT_Done__c = formatString(valList[4]);
											}
											if (valList[4] != '') {
												caKPI.LAT_Provided__c = formatString(valList[3]);
											}
											kpiCUpdate.add(caKPI);
										}
									}
								}

								if (!kpiCUpdate.isEmpty()) {
									upsert kpiCUpdate;
								}

								/*List<LAT_AccountInAction__c> clientes = [SELECT id, Name, LAT_PromotionalAction__r.LAT_CollectData__c,
													LAT_PromotionalAction__r.LAT_ActivationMaterial__c,
													LAT_CollectData__c, LAT_RetireMaterials__c,
													LAT_PromotionalAction__r.LAT_endDate__c, LAT_Account__r.ownerId,
													LAT_PromotionalAction__r.LAT_Status__c, LAT_PromotionalAction__c
												FROM LAT_AccountInAction__c
												WHERE id =: ids];

								Map<id, LAT_ActionKPI__c> actionKPIMap = new Map<id, LAT_ActionKPI__c>([SELECT id, Name, LAT_KPI__r.Name FROM LAT_ActionKPI__c WHERE LAT_PromotionalAction__c =: paId ORDER BY LAT_KPI__r.Name]);
								if(!clientes.isEmpty() && !actionKPIMap.values().isEmpty()) {
									List<LAT_ClientActionKPI__c> kpiCInsert = new List<LAT_ClientActionKPI__c>();
									Integer actionKpiSize = actionKPIMap.values().size();
									for (List<String> strList: values) {
										Integer strListSize = strList.size();
										if(strListSize >= 1){
											String clientId = strList[0].replaceall('"','');
											if (clientId != '') {
												Integer counter = 2;

												for (LAT_ActionKPI__c acKpi: actionKPIMap.values()) {
													if (counter < strListSize) {
														LAT_ClientActionKPI__c aKpic = new LAT_ClientActionKPI__c();
														aKpic.LAT_ActionKPI__c = acKpi.id;
														aKpic.LAT_AccountInAction__c = clientId;
														if (strList[counter] != '') {
															aKpic.LAT_Done__c = strList[counter] != '' ? formatString(strList[counter]) : null;
														}
														if (strList[counter + 1] != '') {
															aKPic.LAT_Provided__c = strList[counter + 1] != '' ? formatString(strList[counter + 1]) : null;
														}
														counter = counter + 3;
														kpiCInsert.add(aKpic);
													}
												}
											}
										}
									}

									if (!kpiCInsert.isEmpty()) {
										delete [SELECT id FROM LAT_ClientActionKPI__c
															WHERE LAT_AccountInAction__c =: clientes];
										insert kpiCInsert;
									}*/
								ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Carga realizada com sucesso. <a href="/'+ paId +'">' + 'Voltar para Ação Promocional' + '</a>'));
							} else {
									ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'O arquivo não contém dados válidos.'));
							}
					} else{
							ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Inválido ação promocional.'));
					}
			}
		} catch (Exception e) {
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