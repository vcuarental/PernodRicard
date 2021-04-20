/**
 * Controller used for creating/editing new 
 *
 */
global without sharing class LAT_BR_SegmentationSlctNewController {
	
	// TODO:  move setting/labe
	public static Map<String,String> questionNameToLabel = new Map<String, String>{
  'q1_canal_negocio__c' => 'Qual canal de atuação se destina o negócio?',
  'q2_relacao_comercial__c' => 'Qual a nossa relação comercial com o negócio?',
  'q3_Qual_o_principal_escopo_do_neg_cio__c' => 'Qual o principal escopo do negócio?',
  'q4_Qual_a_principal_rea_abordagem__c' => 'Qual a principal área/abordagem de atuação do negócio?',
  'q5_Qual_o_principal_p_blico__c' => 'Qual o principal público que se destina o negócio?',
  'q6_Qual_o_formato_do_negocio__c' => 'Qual o formato do negócio?',
  'q7_Qual_modelo_de_neg_cio_do_cliente__c' => 'Qual modelo de negócio do cliente?',
  'q8_cliente_possui_benefcio_Fiscal__c' => 'O cliente possui algum benefício Fiscal?',
  'q9_Qual_a_importancia_do_cliente_para_PR__c' => 'Qual a importância do cliente para PRB?'};


	public static Map<String,String> questionNameToNumber  = new Map<String, String>{
		'q1' => 'q1_canal_negocio__c',
		'q2' => 'q2_relacao_comercial__c',
		'q3' => 'q3_Qual_o_principal_escopo_do_neg_cio__c',
		'q4' => 'q4_Qual_a_principal_rea_abordagem__c',
		'q5' => 'q5_Qual_o_principal_p_blico__c',
		'q6' => 'q6_Qual_o_formato_do_negocio__c',
		'q7' => 'q7_Qual_modelo_de_neg_cio_do_cliente__c',
		'q8' => 'q8_cliente_possui_benefcio_Fiscal__c',
		'q9' => 'q9_Qual_a_importancia_do_cliente_para_PR__c'};


	public static Map<String,String> obtainedLayout  = new Map<String, String>{
		'Cliente no qual emitimos pedidos e pagamentos (Dinheiro e "ou" Produtos).' => 'COMPLETO',
		'PDV que apenas mantemos relação de atendimento, sem emissão de pedidos e pagamentos (Dinheiro e "ou" Produtos).' => 'SIMPLES',
		'Cliente no qual emitimos pedidos de VENDA DIRETA. Ou seja, fazemos a venda de nossos produtos sem o uso de distribuidores/atacados.' => 'COMPLETO',
		'Cliente que apenas mantemos relação de atendimento, sem emissão de pagamentos (Em Dinheiro e "ou" Produtos).' => 'SIMPLES',
		'Cliente no qual emitimos pagamentos (Dinheiro e "ou" Produto).' => 'COMPLETO'};

	public  Map<String,String>	question1Map{get;set;}
	public  Map<String,String>	question2Map{get;set;}
	public  Map<String,String>	question3Map{get;set;}
	public  Map<String,String>	question4Map{get;set;}
	public  Map<String,String>	question5Map{get;set;}
	public  Map<String,String>	question6Map{get;set;}
	public  Map<String,String>	question7Map{get;set;}
	public  Map<String,String>	question8Map{get;set;}
	public  Map<String,String>	question9Map{get;set;}
	public string question1Lbl{get;set;}
	public string question2lbl{get;set;}
	public string question3Lbl{get;set;}
	public string question4lbl{get;set;}
	public string question5Lbl{get;set;}
	public string question6lbl{get;set;}
	public string question7Lbl{get;set;}
	public string question8lbl{get;set;}
	public string question9lbl{get;set;}
	public string question1MapJson{get;set;}
	public string question2MapJson{get;set;}
	public string question3MapJson{get;set;}
	public string question4MapJson{get;set;}
	public string question5MapJson{get;set;}
	public string question6MapJson{get;set;}
	public string question7MapJson{get;set;}
	public string question8MapJson{get;set;}
	public string question9MapJson{get;set;}
	public Map<String, Map<String, LAT_BR_Segmentation2Params__c>> fieldMapping;
	public static Map<String,String> answerNameToLabel;
	public boolean isNew{get;set;}
	public String segmentId{get;set;}
	public LAT_BR_ClientChannelSegmentation2__c stdObj{get;set;}
	public String retUrl{get;set;}
	public String errorMsg{get;set;}
	public boolean canCreate{get;set;}
	public boolean userBann{get;set;}
	public boolean redirect {get;set;}
	public Id accId {get;set;}


	public Account brAcc{get;set;}
	public LAT_BR_ClientChannelSegmentation2__c newSegmentation{get;set;}
	public LAT_BR_ClientChannelSegmentation2Result__c segmentResult{get;set;}


	/**
	 * Controller extension for using as "edit" from a button
	 */
	 public LAT_BR_SegmentationSlctNewController(ApexPages.StandardController stdController) {
	 	system.debug('const1');
	 	this.stdObj = (LAT_BR_ClientChannelSegmentation2__c)stdController.getRecord();
	 	retURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + System.currentPageReference().getParameters().get('retURL');
	 	system.debug('AccId++++' + accId);
	 	accId = System.currentPageReference().getParameters().get('accId');
	 	if (String.isNotBlank(accId)){
	 		this.stdObj.Account__c = accId;
	 	}
	 	redirect = false;
        init();
    }

	public LAT_BR_SegmentationSlctNewController() {
		system.debug('const2');
		redirect = false;
		this.stdObj = new LAT_BR_ClientChannelSegmentation2__c();
		retURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + System.currentPageReference().getParameters().get('retURL');
		accId = System.currentPageReference().getParameters().get('accId');
		this.stdObj.Account__c = accId;
		system.debug('AccId++++' + accId);
	 	redirect = false;
		init();
	}

	public PageReference retornar(){
		canCreate = false;
		return new PageReference(retUrl);
	}

	/**
	 * Init the data, load the objects if an edition or create them in case of a new one
	 * this is identify if an Id param exist on the url
	 */
	public void init(){
		canCreate = true;
		userBann = false;
		Id accId = stdObj.Account__c;
		system.debug('AccId++++' + accId);
		brAcc = [Select Id,channel__c,Type,Status__c,Lat_Account__c, Rating from Account where Id = :accId];
		List<LAT_BR_ClientChannelSegmentation2__c> currentDrafts = [select id,name from LAT_BR_ClientChannelSegmentation2__c where Account__c=:accId AND Status__c = 'Draft'];
		if (brAcc.status__c != 'Cliente cadastrado no JDE'  && brAcc.status__c != 'Cliente cadastrado no CRM' && brAcc.status__c != 'Reprovado' && brAcc.Rating != 'Cliente Inativo'){
			system.debug('Error1++++');
			canCreate = false;
			errorMsg = 'Somente é permitido criar uma nova Segmentação para clientes com Status "Cadastrado no JDE" ou Cadastrado no CRM"';
		} else if (currentDrafts.size() == 1) {
			system.debug('Error2++++');
			canCreate = false;
			errorMsg = 'Já existe uma Segmentação Em Preenchimento. Favor editar a mesma para seguir.';
		} else {
			system.debug('NoError1++++');
			canCreate = true;
		}

		if (Utils.isPartOfMobileCRM(UserInfo.getUserId()) && !Apexpages.currentPage().getUrl().contains('Mobile')){
			system.debug('Error3++++');
			userBann = true;
			canCreate = false;
			errorMsg = 'Usuario no Permitido crear web, por favor use COMPASS';
		}
		system.debug('çan create+++' + canCreate + errorMsg);
		system.debug('Error1++++');
		

		newSegmentation = new LAT_BR_ClientChannelSegmentation2__c();
		segmentResult = [SELECT Account__c,
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
									Obtained_Layout__c
						FROM LAT_BR_ClientChannelSegmentation2Result__c 
						WHERE Account__c = :accId];

		/*if (!isNew){
			//load stuff

			newSegmentation = [SELECT Id, 
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
								FROM LAT_BR_ClientChannelSegmentation2__c WHERE Id = :segmentId];
			brAcc = [Select Id,channel__c,Type,Status__c from Account where Id = :newSegmentation.Account__c];
			segmentResult = [SELECT Account__c,
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
									Obtained_Layout__c
						FROM LAT_BR_ClientChannelSegmentation2Result__c 
						WHERE Client_Segmentation_2__c = :newSegmentation.Id];
			canCreate = (brAcc.status__c == 'Cliente cadastrado no JDE'  || brAcc.status__c == 'Cliente cadastrado no CRM');
		} else {
			brAcc = new Account();
			newSegmentation = new LAT_BR_ClientChannelSegmentation2__c();
			segmentResult = new LAT_BR_ClientChannelSegmentation2Result__c();
		}*/
		// TODO: REFACTOR ONE QUERY IMPORTANT!
		question1Map = getAnswerMap('q1_canal_negocio__c');
		system.debug('q1Map' + question1Map);
		question2Map = getAnswerMap('q2_relacao_comercial__c');
		question3Map = getAnswerMap('q3_Qual_o_principal_escopo_do_neg_cio__c');
		question4Map = getAnswerMap('q4_Qual_a_principal_rea_abordagem__c');
		question5Map = getAnswerMap('q5_Qual_o_principal_p_blico__c');
		question6Map = getAnswerMap('q6_Qual_o_formato_do_negocio__c');
		question7Map = getAnswerMap('q7_Qual_modelo_de_neg_cio_do_cliente__c');
		question8Map = getAnswerMap('q8_cliente_possui_benefcio_Fiscal__c');
		question9Map = getAnswerMap('q9_Qual_a_importancia_do_cliente_para_PR__c');
		question1Lbl = questionNameToLabel.get('q1_canal_negocio__c');
		question2Lbl = questionNameToLabel.get('q2_relacao_comercial__c');
		question3Lbl = questionNameToLabel.get('q3_Qual_o_principal_escopo_do_neg_cio__c');
		question4Lbl = questionNameToLabel.get('q4_Qual_a_principal_rea_abordagem__c');
		question5Lbl = questionNameToLabel.get('q5_Qual_o_principal_p_blico__c');
		question6Lbl = questionNameToLabel.get('q6_Qual_o_formato_do_negocio__c');
		question7Lbl = questionNameToLabel.get('q7_Qual_modelo_de_neg_cio_do_cliente__c');
		question8Lbl = questionNameToLabel.get('q8_cliente_possui_benefcio_Fiscal__c');
		question9Lbl = questionNameToLabel.get('q9_Qual_a_importancia_do_cliente_para_PR__c');
		


		question1MapJson = JSON.serialize(question1Map);
		question2MapJson = JSON.serialize(question2Map);
		question3MapJson = JSON.serialize(question3Map);
		question4MapJson = JSON.serialize(question4Map);
		question5MapJson = JSON.serialize(question5Map);
		question6MapJson = JSON.serialize(question6Map);
		question7MapJson = JSON.serialize(question7Map);
		question8MapJson = JSON.serialize(question8Map);
		question9MapJson = JSON.serialize(question9Map);

		//answerNameToLabel = LAT_BR_SegmentationUtilV2.loadQuestionData();
	} 



	/**
	 * Save the Client, create segment Result and segmentation objects, or uptdates
	 * them in case of an edition
	 */
	public PageReference CreateClient(){
		fieldMapping = LoadQuestionFieldMapping();
		String q1Api = fieldMapping.get('q1_canal_negocio__c').get(newSegmentation.q1_canal_negocio__c).RelatedApiField__c;
		system.debug('Ernesto+++' );
		String q1Value = fieldMapping.get('q1_canal_negocio__c').get(newSegmentation.q1_canal_negocio__c).RelatedFieldValue__c;
		String q2Api = fieldMapping.get('q2_relacao_comercial__c').get(newSegmentation.q2_relacao_comercial__c).RelatedApiField__c;
		String q2Value = fieldMapping.get('q2_relacao_comercial__c').get(newSegmentation.q2_relacao_comercial__c).RelatedFieldValue__c;
		brAcc.put('channel__c', q1Value);
		brAcc.put('type', q2Value);

		// TODO: keep adding record types
		system.debug('canal++: ' + q1Value);
		system.debug('type++: ' + q2Value);


		
		/**if (q1Value=='OFF TRADE' && q2Value == 'COM FATURAMENTO'){
			brAcc.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+  'LAT_Off_Trade_Faturamento');
			//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
		} else {
			brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
		}*/

		//if (isNew){
			
			//insert brAcc;
			for (String questionName:questionNameToLabel.keyset()){
				String fieldValuenow = (String) newSegmentation.get(questionName);
				system.debug('Ernesto+++questionName:' + questionName);
				system.debug('Ernesto+++fieldValuenow:' + fieldValuenow);
				system.debug('Ernesto+++fieldMapping.get(questionName)' + fieldMapping.get(questionName));
				system.debug('Ernesto+++questionName');
				if (String.isNotBlank(fieldValuenow)){
					newSegmentation.put(fieldMapping.get(questionName).get(fieldValuenow).RelatedApiField__c, fieldMapping.get(questionName).get(fieldValuenow).RelatedFieldValue__c);
				}
				//segmentResult.Obtained_Layout__c = obtainedLayout.get(newSegmentation.q2_relacao_comercial__c);
			}
			newSegmentation.Account__c = brAcc.Id;
			newSegmentation.Status__c = 'Draft';
			system.debug('Ernesto+++q2Value:' + q2Value);
			system.debug('Ernesto+++q2Value:' + q1Value);
			//if ((segmentResult.Client_type__c == 'SEM FATURAMENTO' || segmentResult.Client_type__c == 'SEM PAGAMENTO') && (q2Value == 'COM PAGAMENTO' || q2Value =='COM FATURAMENTO' || q2Value =='VENDA DIRETA')){
				 
				system.debug('Ernesto+++cambia recordType de +++ ' + brAcc.RecordTypeId);
				system.debug('Ernesto+++aaaaa recordType de +++ ' + LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(q1Value,q2Value));
				
				update new Lat_Account__c (Id = brAcc.Lat_Account__c, 
				                  LAT_Approval_Revert_RecordType__c = true, LAT_RtId_Before_Approval__c = brAcc.RecordTypeId, LAT_Status_Before_Approval__c = brAcc.Status__c);
				brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(q1Value,q2Value);
				brAcc.Status__c = 'Novo cadastro';
				update brAcc;

			//}
			insert newSegmentation;


			/*for (String questionName:questionNameToLabel.keyset()){
				String fieldValuenow = (String) newSegmentation.get(questionName);
				system.debug('Ernesto+++questionName:' + questionName);
				system.debug('Ernesto+++fieldValuenow:' + fieldValuenow);
				system.debug('Ernesto+++fieldMapping.get(questionName)' + fieldMapping.get(questionName));
				system.debug('Ernesto+++questionName');
				if (String.isNotBlank(fieldValuenow)){
					segmentResult.put(fieldMapping.get(questionName).get(fieldValuenow).RelatedApiField__c, fieldMapping.get(questionName).get(fieldValuenow).RelatedFieldValue__c);
				}
				segmentResult.Obtained_Layout__c = obtainedLayout.get(newSegmentation.q2_relacao_comercial__c);
			}
			if (q1Value=='OFF TRADE' && q2Value == 'COM FATURAMENTO'){
				brAcc.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+  'LAT_Off_Trade_Faturamento');
			//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
			} else {
				brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(q1Value,q2Value);
				//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
			}
			update segmentResult;*/
			
		/*} else {
			for (String questionName:questionNameToLabel.keyset()){
				String fieldValuenow = (String) newSegmentation.get(questionName);
				system.debug('Ernesto+++questionName:' + questionName);
				system.debug('Ernesto+++fieldValuenow:' + fieldValuenow);
				system.debug('Ernesto+++fieldMapping.get(questionName)' + fieldMapping.get(questionName));
				system.debug('Ernesto+++questionName');
				if (String.isNotBlank(fieldValuenow)){
					segmentResult.put(fieldMapping.get(questionName).get(fieldValuenow).RelatedApiField__c, fieldMapping.get(questionName).get(fieldValuenow).RelatedFieldValue__c);
				}
				segmentResult.Obtained_Layout__c = obtainedLayout.get(newSegmentation.q2_relacao_comercial__c);
			}
			if (q1Value=='OFF TRADE' && q2Value == 'COM FATURAMENTO'){
				brAcc.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+  'LAT_Off_Trade_Faturamento');
			//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
			} else {
				brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(q1Value,q2Value);
				//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
			}
			update brAcc;
			update newSegmentation;
			update segmentResult;
			//return null;

		}*/
		PageReference pg;
		if (Apexpages.currentPage().getUrl().contains('Mobile')){
			pg = new PageReference('/apex/LAT_BR_Edit_AccountMobileFieldSets?id=' + brAcc.Id);
		} else {
			pg = new PageReference('/'+brAcc.Id);
		}
	    pg.setRedirect(true);
	    return pg;  
	}


	/**
	 * 
	 *
	 */
	 @remoteaction
	global static Map<String, String> getAnswerMap(String questionNumber) {
		Map<String, String> retMap = new Map<STring, String>();


		List<LAT_BR_Segmentation2Params__c> params= 
		[SELECT Id,
				Name,
				Longdescription__c,
				QuestionNumber__c, 
				RelatedApiField__c,
				RelatedFieldValue__c,
				ShortValue__c  
		FROM LAT_BR_Segmentation2Params__c WHERE QuestionNumber__c = :questionNumber];

		for (LAT_BR_Segmentation2Params__c setting:params){
			//test
			retMap.put(setting.ShortValue__c, setting.Longdescription__c);
		}

		return retMap;
	}

	/**
	 * 
	 *
	 */
	 @remoteaction
	global static String getObtainedField(String questionNumber, String selectedAnswer) {
		String qname = questionNameToNumber.get(questionNumber);

		List<LAT_BR_Segmentation2Params__c> params= 
		[SELECT Id,
				Name,
				Longdescription__c,
				QuestionNumber__c, 
				RelatedApiField__c,
				RelatedFieldValue__c,
				ShortValue__c  
		FROM LAT_BR_Segmentation2Params__c WHERE QuestionNumber__c = :qname AND ShortValue__c =:selectedAnswer];

		return params[0].RelatedFieldValue__c;
	}




	global static Map<String, Map<String, LAT_BR_Segmentation2Params__c>> LoadQuestionFieldMapping() {
		
		Map<String, Map<String, LAT_BR_Segmentation2Params__c>> retMap = new Map<String, Map<String, LAT_BR_Segmentation2Params__c>>();


		List<LAT_BR_Segmentation2Params__c> params= 
		[SELECT Id,
				Name,
				Longdescription__c,
				QuestionNumber__c, 
				RelatedApiField__c,
				RelatedFieldValue__c,
				ShortValue__c  
		FROM LAT_BR_Segmentation2Params__c];

		for (LAT_BR_Segmentation2Params__c setting:params){
			//test
			if (retMap.get(setting.QuestionNumber__c) == null){
				retMap.put(setting.QuestionNumber__c,new Map<String, LAT_BR_Segmentation2Params__c>());
			}
			retMap.get(setting.QuestionNumber__c).put(setting.ShortValue__c, setting);
		}

		return retMap;
	}





}