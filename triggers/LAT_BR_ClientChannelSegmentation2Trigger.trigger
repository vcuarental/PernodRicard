trigger LAT_BR_ClientChannelSegmentation2Trigger on LAT_BR_ClientChannelSegmentation2__c (before update) {
	Map<Id,LAT_BR_ClientChannelSegmentation2Result__c> resultByQuestionaire =new Map<Id,LAT_BR_ClientChannelSegmentation2Result__c>();

		List<LAT_BR_ClientChannelSegmentation2Result__c> restoupdate = new List<LAT_BR_ClientChannelSegmentation2Result__c>();
		List<LAT_BR_ClientChannelSegmentation2Result__c> segmResults =	[SELECT Account__c,
									Beneficio_Fiscal__c,
									Channel__c,
									Client_type__c,
									Estrategia_comercial__c,
									FORMATO__c,
									Perfil__c,
									POLiTICA_DE_PRECO__c,
									PRIOR_DE_INVESTIMENTO__c,
									Segment__c,
									Client_Segmentation_2__c,
									Sub_channel__c,
									Obtained_Layout__c
						FROM LAT_BR_ClientChannelSegmentation2Result__c 
						WHERE Client_Segmentation_2__c IN :trigger.new];
	for(LAT_BR_ClientChannelSegmentation2Result__c res:segmResults){
		resultByQuestionaire.put(RES.Client_Segmentation_2__c, res);
	}
	for (LAT_BR_ClientChannelSegmentation2__c segm:trigger.new){
		if(segm.Status__c == 'Active' && trigger.newMap.get(segm.Id).Status__c != 'Active'){
			if(resultByQuestionaire.get(segm.Id)!=null){
				AP01_Account_BR.activateSegmentation(segm,resultByQuestionaire.get(segm.Id),null);
				
			}
			
		}
		update restoupdate;

	}
}