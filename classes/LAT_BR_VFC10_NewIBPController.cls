/********************************************************************************
*                         Company: ValueNet                                     *
*-------------------------------------------------------------------------------*
*  Controlador del la Visualforce page LAT_BR_VFP10_NewIBP  					*
********************************************************************************/

public with sharing class LAT_BR_VFC10_NewIBPController {
	
	public Investimento_Bonificacao_e_Pagamento__c ibp {get;set;}
	public List<wrappper> listWrapper {get;set;}
	public boolean IsMessage {get;set;}
	public RecordType rType {get;set;}
	public string userName {get;set;}
	public string regId {get;set;}
	
	public class wrappper{
		public boolean isCheckbox {get;set;}
		public boolean isFirst {get;set;}
		public Investimento_Bonificacao_e_Pagamento__c libp {get;set;}
		public wrappper(){
			isCheckbox = false;
			isFirst = false;
			libp = new Investimento_Bonificacao_e_Pagamento__c();
		}
	}
	
	public LAT_BR_VFC10_NewIBPController( ApexPages.StandardController controller ){
		
		//Verifico el recordtype
		IsMessage = false;
		rType = Global_RecordTypeCache.getRt(ApexPages.currentPage().getParameters().get('RecordType'));
		if(rType == null){
			Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.ERROR, Label.LAT_BR_VFC10_00001));
			//Custom label LAT_BR_VFC10_00001 = 'No Record Type found please contact your System Administrator'
			IsMessage = true;
            return;
		}
		
		ibp = new Investimento_Bonificacao_e_Pagamento__c();
		regId = ApexPages.currentPage().getParameters().get('retURL');
		userName = userinfo.getName();
		
		regId = regId.replaceFirst('/', '');
		List<LAT_Contract__c> con = [SELECT id, Name, LAT_BR_RealValidityDate__c FROM LAT_Contract__c WHERE id=:regId];
		
		if(!con.isEmpty()){
			ibp.LAT_Contract__c = con[0].Id;
			ibp.Data_de_Encerramento__c = con[0].LAT_BR_RealValidityDate__c;
		}
		
		wrappper wa = new wrappper();
		wa.isFirst = true;
		listWrapper = new List<wrappper>{wa};
	}
	
	public PageReference doSave(){
		List<Investimento_Bonificacao_e_Pagamento__c> listBPItoInsert = new List<Investimento_Bonificacao_e_Pagamento__c>(); 
		
		//Validaciones
		Boolean isError = false;
		if(ibp.Data_de_Previsao_do_Pagamento__c == null){
			ibp.Data_de_Previsao_do_Pagamento__c.addError(Label.LAT_BR_VFC10_00002);
			//Custom label LAT_BR_VFC10_00002 = 'You must enter a value'
			isError = true;
		}
		for(wrappper wra: listWrapper){
			if(wra.libp.Finalidade__c == null){
				wra.libp.Finalidade__c.addError(Label.LAT_BR_VFC10_00002);
				//Custom label LAT_BR_VFC10_00002 = 'You must enter a value'
				isError = true;
			}
		}
		if(isError){
			return null;
		}
		
		//Salvado de registros
		for(wrappper wra: listWrapper){
			wra.libp.RecordTypeId = rType.id;
			wra.libp.OwnerId = userinfo.getUserId();
			wra.libp.Data_de_Previsao_do_Pagamento__c = ibp.Data_de_Previsao_do_Pagamento__c;
			wra.libp.Acao_Promocional__c = ibp.Acao_Promocional__c;
			wra.libp.LAT_Contract__c = ibp.LAT_Contract__c;
			wra.libp.Data_de_Encerramento__c = ibp.Data_de_Encerramento__c;
			wra.libp.Status_da_Verba__c = ibp.Status_da_Verba__c;
			listBPItoInsert.add(wra.libp);
		}
		
		try{ insert listBPItoInsert; }catch(DMLException e){ return null; }
		return new PageReference('/'+regId);
	}
	
	public PageReference doNewPaga(){
		listWrapper.add(new wrappper());
		return null;
	}
	
	public PageReference doDelete(){
		for(integer i=0; i<listWrapper.size(); i++){
			if(listWrapper[i].isCheckbox){
				listWrapper.remove(i);
				i--;
			}
		}
		return null;
	}
}