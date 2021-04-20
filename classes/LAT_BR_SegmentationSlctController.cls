/**
 * Controller used for creating/editing new 
 *
 */
global without sharing class LAT_BR_SegmentationSlctController {
	
	public class Response {
		public Integer Code { get; set; }
		public String Message { get; set; }
	}

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
	public boolean isNewParameter{get;set;}
	public boolean isCreation{get;set;}
	public String segmentId{get;set;}
	public String retUrl{get;set;}
	public String errorMsg{get;set;}
	public boolean canCreate{get;set;}
    public boolean isAdmin{get;set;}
    public boolean isReadOnly{get;set;}

	public String cnpj_style {get;set;}

	public Account brAcc{get;set;}
	public LAT_BR_ClientChannelSegmentation2__c newSegmentation{get;set;}
	public LAT_BR_ClientChannelSegmentation2Result__c segmentResult{get;set;}

	/**
	 * Controller extension for using as "edit" from a button
	 */
	 public LAT_BR_SegmentationSlctController(ApexPages.StandardController stdController) {
	 	retURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + System.currentPageReference().getParameters().get('retURL');
	 	isReadOnly = false;
	 	isReadOnly = (System.currentPageReference().getParameters().get('readonly') != null)?
	 	 true:false;
        init();
    }

	public LAT_BR_SegmentationSlctController() {
		retURL = 'https://' + ApexPages.currentPage().getHeaders().get('Host') + System.currentPageReference().getParameters().get('retURL');
		isReadOnly = false;
	 	isReadOnly = (System.currentPageReference().getParameters().get('readonly') != null)?
	 	 true:false;
		init();
	}

	public PageReference retornar(){
		return new PageReference(retUrl);
	}
	/**
	 * Init the data, load the objects if an edition or create them in case of a new one
	 * this is identify if an Id param exist on the url
	 */
	public void init(){

		isAdmin = false;                 
        if (userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator') || userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator')) {
        	isAdmin = true;
        }

	 	canCreate = true;
		segmentId = ApexPages.currentPage().getParameters().get('id');
		isCreation = ApexPages.currentPage().getParameters().get('isNew') == 'true';

		isNew = String.isBlank(segmentId);

		if (Utils.isPartOfMobileCRM(UserInfo.getUserId()) && isNew){
			canCreate = false;
			errorMsg = 'Usuario no Permitido crear web, por favor use COMPASS';
		}

		if (!isNew){
			//load stuff

			isNewParameter = ApexPages.currentPage().getParameters().get('isNew') == 'true' ? true : false;
			newSegmentation = [SELECT Id, 
									Q1_canal_negocio__c,
									Account__c,
									Status__c,
									q2_relacao_comercial__c,
									q3_Qual_o_principal_escopo_do_neg_cio__c,
									q4_Qual_a_principal_rea_abordagem__c,
									q5_Qual_o_principal_p_blico__c,
									q6_Qual_o_formato_do_negocio__c,
									q7_Qual_modelo_de_neg_cio_do_cliente__c,
									q8_cliente_possui_benefcio_Fiscal__c,
									q9_Qual_a_importancia_do_cliente_para_PR__c
								FROM LAT_BR_ClientChannelSegmentation2__c WHERE Id = :segmentId];
			brAcc = [Select Id,channel__c,Type from Account where Id = :newSegmentation.Account__c];
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
						WHERE Account__c = :brAcc.Id];
		} else {
			brAcc = new Account();
			newSegmentation = new LAT_BR_ClientChannelSegmentation2__c();
			segmentResult = new LAT_BR_ClientChannelSegmentation2Result__c();
		}
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

		retrieveCNPJStyles();
		//answerNameToLabel = LAT_BR_SegmentationUtilV2.loadQuestionData();
	} 

	private void retrieveCNPJStyles() {
		this.cnpj_style = (isAdmin)?'col-md-10 cnpj':'col-md-12 cnpj';
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


		brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(q1Value,q2Value);
		/**if (q1Value=='OFF TRADE' && q2Value == 'COM FATURAMENTO'){
			brAcc.RecordTypeId = Global_RecordTypeCache.getRtId('Account'+  'LAT_Off_Trade_Faturamento');
			//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
		} else {
			brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);
		}*/

		if (isNew){
			//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(q1Value,q2Value);
			insert brAcc;
			newSegmentation.Account__c = brAcc.Id;
			if(String.isBlank(newSegmentation.Status__c)){
				newSegmentation.Status__c = 'Active';
			}
			newSegmentation.ClientCreationSegm__c = true;
			insert newSegmentation;
			segmentResult.Account__c = brAcc.Id;
			segmentResult.Client_Segmentation_2__c = newSegmentation.Id;
			segmentResult.Obtained_Layout__c =LAT_BR_SegmentationBehaviorHandler.getLayoutSet(q1Value,q2Value);
			segmentResult.put(q1Api, q1Value);
			segmentResult.put(q2Api, q2Value);
			insert segmentResult;
            Lat_Account__c latdata = [select Id from Lat_Account__c where LAT_Accountid__c  = :brAcc.Id];
			update new Lat_Account__c (Id = latdata.Id, LAT_BR_Segmentation__c= segmentResult.Id);
			
		} else {
			for (String questionName:questionNameToLabel.keyset()){
				String fieldValuenow = (String) newSegmentation.get(questionName);
				system.debug('Ernesto+++questionName:' + questionName);
				system.debug('Ernesto+++fieldValuenow:' + fieldValuenow);
				system.debug('Ernesto+++fieldMapping.get(questionName)' + fieldMapping.get(questionName));
				system.debug('Ernesto+++questionName');
				if (String.isNotBlank(fieldValuenow)){
					String fieldName = fieldMapping.get(questionName).get(fieldValuenow).RelatedApiField__c;
					String fieldValue = fieldMapping.get(questionName).get(fieldValuenow).RelatedFieldValue__c;
					newSegmentation.put(fieldName, fieldValue);
					if(newSegmentation.Status__c != 'Draft'){
						segmentResult.put(fieldName, fieldValue);
					}
					
				}
				segmentResult.Obtained_Layout__c = LAT_BR_SegmentationBehaviorHandler.getLayoutSet(q1Value,q2Value);
			}
				brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeID(q1Value,q2Value);
			//brAcc.RecordTypeId = LAT_BR_SegmentationBehaviorHandler.getRecordTypeBehavior(brAcc);

			update newSegmentation;
			update segmentResult;
			update brAcc;
			//return null;

		}
		String pageName = ApexPages.currentPage().getUrl().substringAfter('apex/');
		PageReference pg;
		if (pageName.containsIgnoreCase('Mobile')){
			if (isNew) {
				pg = new PageReference('/apex/LAT_BR_SegmentationSlctMobile?retURL=/apex/LAT_BR_SegmentationSlctMobile&isNew=true&sfdc.override=1&id=' + newSegmentation.Id);
				pg.getParameters().put('isNew','true');
			} else {
				pg = new PageReference('/apex/LAT_br_Edit_AccountMobilefieldsets?id='+ brAcc.Id );
				if (isNewParameter) {
					pg.getParameters().put('isNew','true');
				}
			}

		} else {
			pg = new PageReference('/'+brAcc.Id);
		}
	    pg.setRedirect(true);
	    return pg;  
	}


	@RemoteAction
	public static Response checkCNPJ(String strCNPJ, Boolean boolSaveDuplicated) {
		Set<Id> setIdsRT = null;
		List<Account> lstAccounts = null; 
		Account objAccount = null;
		Response objResponse = null;
		String strResponse = null;
		System.debug('checkCNPJ [strCNPJ : ' + strCNPJ + ' - boolSaveDuplicated : ' + boolSaveDuplicated + '] ->');
        try {		
			objResponse = new Response();				
			//Verifico que en la base de datos no haya otro CNPJ igual
			setIdsRT =  Global_RecordTypeCache.getRtIdSet('Account', AP01_Account_BR.BR_RECORDTYPES);
			lstAccounts = [ SELECT Id, NAme, CNPJ__c, OwnerId, Owner.Name, Client_code_AN8__c 
							FROM Account 
							WHERE cnpj__c = :strCNPJ 
							AND RecordTypeId IN: setIdsRT];
			System.debug('checkCNPJ [lstAccounts.size() : ' + lstAccounts.size() + ']');
		
			if (!lstAccounts.isEmpty()) {   
				objAccount = lstAccounts.get(0);
				if(boolSaveDuplicated == false) {
					objResponse.Code = 100;

					strResponse = Label.AP01_00001_AR + ' ' + objAccount.Name + ' (AN8: ' + objAccount.Client_code_AN8__c + ')  -  Proprietário: ' + objAccount.Owner.Name;
				} else {
					objResponse.Code = 0;
					strResponse = 'El CNPJ duplicara el CNPJ de la cuenta ' + objAccount.Name + ' (AN8: ' + objAccount.Client_code_AN8__c + ')  -  Proprietário: ' + objAccount.Owner.Name;
				}
			} else {
				objResponse.Code = 0;				
				strResponse = '';
			}
		
		} catch(Exception ex) {
			strResponse = ex.getMessage();
		}

		objResponse.Message = strResponse;


		System.debug('checkCNPJ [' + objResponse + '] <-');

		return objResponse;
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


	public PageReference deleteClient() {
		if(isCreation){
			delete brAcc;
        	PageReference pr = new PageReference('/apex/LAT_BR_SegmentationSlctMobile');       
        	pr.setRedirect(true);
        	return pr;
		} else {
			return retornar();
		}
        
    }


}