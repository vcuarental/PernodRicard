public with sharing class LAT_BR_ShowSegmentationController {
	public boolean show{get;set;}
	public Account acc {get;set;}
	public Map<String, Map<String, LAT_BR_Segmentation2Params__c>> fieldMapping;
	public String value{get;set;}
    public String debug{get;set;}
    public Boolean init = false;
    public String politica {get;set;}
    public String politicaOrigin {get;set;}
    public String tbci {get;set;}
    public LAT_BR_ClientChannelSegmentation2Result__c segment{ get{
        
        if(!init){
          init(); 
        }
        return segment;
            
            
            }set;}
    


	public LAT_BR_ShowSegmentationController() {
     
	}
    
    public void init(){
        init = true;
        debug += 'Erenesto+Entro1' + value;
        
		fieldMapping = LAT_BR_SegmentationSlctNewController.LoadQuestionFieldMapping();
		List<Account> accs = [Select Id,channel__c,Type,Status__c,Rating from Account where Id = :value];
		String status = ''; 
		system.debug('Test+++' + accs);
		


	     debug += '  Erenesto+Entro2 ' ;
		if (!accs.isEmpty()){
            debug += 'Erenesto+Entro2 ' + accs[0].Rating;
			if (accs[0].Rating == 'Cliente Ativo' || accs[0].Status__c=='Aprovação Financeiro - TBCI') {
				segment = [SELECT Account__c,
									Beneficio_Fiscal__c,
									Channel__c,
									Client_type__c,
									Estrategia_comercial__c,
									FORMATO__c,
									Perfil__c,
									POLiTICA_DE_PRECO__c,
									PRIOR_DE_INVESTIMENTO__c,
									Segment__c,
									Sub_channel__c,
									Obtained_Layout__c,
									TBCI__C,
									Politica_Preco_Origin__r.Name,
									Obtained_POLiTICA_DE_PRECO_Udc__r.Name
						FROM LAT_BR_ClientChannelSegmentation2Result__c 
						WHERE Account__c = :value];
						politica = segment.Obtained_POLiTICA_DE_PRECO_Udc__r.Name;
			tbci = String.valueOf(segment.TBCI__C);
			politicaOrigin = segment.Politica_Preco_Origin__r.Name;

	debug += '  Erenesto+Entro3 ' + segment.PRIOR_DE_INVESTIMENTO__c;

			} else {

				LAT_BR_ClientChannelSegmentation2Result__c currentSegm  = [SELECT Account__c,
									Beneficio_Fiscal__c,
									Channel__c,
									Client_type__c,
									Estrategia_comercial__c,
									FORMATO__c,
									Perfil__c,
									POLiTICA_DE_PRECO__c,
									PRIOR_DE_INVESTIMENTO__c,
									Segment__c,
									Sub_channel__c,
									Obtained_Layout__c,
									TBCI__C,
									Politica_Preco_Origin__r.Name,
									Obtained_POLiTICA_DE_PRECO_Udc__r.Name
						FROM LAT_BR_ClientChannelSegmentation2Result__c 
						WHERE Account__c = :value];


			system.debug('Test+2++' + accs);
			status = (accs[0].Rating == null) ? 'Active': 'Draft';
			List<LAT_BR_ClientChannelSegmentation2__c> newSegmentation = [SELECT Id, 
										Q1_canal_negocio__c,
										Account__c,
										q2_relacao_comercial__c,
										q3_Qual_o_principal_escopo_do_neg_cio__c,
										q4_Qual_a_principal_rea_abordagem__c,
										q5_Qual_o_principal_p_blico__c,
										q6_Qual_o_formato_do_negocio__c,
										q7_Qual_modelo_de_neg_cio_do_cliente__c,
										q8_cliente_possui_benefcio_Fiscal__c,
										q9_Qual_a_importancia_do_cliente_para_PR__c
								FROM LAT_BR_ClientChannelSegmentation2__c WHERE Account__c = :value AND Status__c=:status];


		debug += '  Erenesto+Entro5 ' + newSegmentation.size();
                if (newSegmentation.size()==0){
			show = false;
			segment = new LAT_BR_ClientChannelSegmentation2Result__c();
			system.debug('Test+23++' + accs);
		} else {
            debug += '  Erenesto+Entro66 ' + newSegmentation.size();
			segment = new LAT_BR_ClientChannelSegmentation2Result__c();
			show = true;
			for (String questionName:LAT_BR_SegmentationSlctNewController.questionNameToLabel.keyset()){
				String fieldValuenow = (String) newSegmentation[0].get(questionName);
				system.debug('Test+2ww3++' + accs);
				system.debug('Ernesto+++questionName:' + questionName);
				system.debug('Ernesto+++fieldValuenow:' + fieldValuenow);
				system.debug('Ernesto+++fieldMapping.get(questionName)' + fieldMapping.get(questionName));
				system.debug('Ernesto+++questionName');
				if (String.isNotBlank(fieldValuenow)){
					segment.put(fieldMapping.get(questionName).get(fieldValuenow).RelatedApiField__c, fieldMapping.get(questionName).get(fieldValuenow).RelatedFieldValue__c);
				}
			}
			politica = currentSegm.Obtained_POLiTICA_DE_PRECO_Udc__r.Name;
			tbci = String.valueOf(currentSegm.TBCI__C);
			politicaOrigin = currentSegm.Politica_Preco_Origin__r.Name;
		}
	}
		} else {
			show = false;
		}
		
		
		
        init = true;
    }
}