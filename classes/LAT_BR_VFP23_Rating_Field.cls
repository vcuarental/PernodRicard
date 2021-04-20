/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
public with sharing class LAT_BR_VFP23_Rating_Field {

	public Boolean isOther{get;set;}
	public Account tmpAccount{get;set;}
	public String errorText{get;set;}


	public LAT_BR_VFP23_Rating_Field(ApexPages.StandardController controller) {
		Set<Id> setAdminsId = new Set<Id>();
        errorText = null;

        setAdminsId.add(LAT_GlobalProfileCache.getStandardAdminProfileId());
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('Business administrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('PR BRAZIL System Administrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('System Administrator'));

		List<Account> lst = [Select id,type,rating,Reason_for_Inactivation__c from Account where id =: controller.getRecord().Id limit 1];
		if(!lst.isEmpty()){
			tmpAccount = lst[0];
			String vendasId;
			if(!Utils.wasMigrationDone('1')){
				 vendasId = LAT_GlobalProfileCache.getProfileIdByName('Vendas');
			}
			//MIGRATED 05/12/2016
			else {
				vendasId = LAT_GlobalProfileCache.getProfileIdByName('LAT_BR2_Vendas');
			}
			Boolean isVendas = vendasId == UserInfo.getProfileId();
			Boolean isAdmin =  setAdminsId.contains(UserInfo.getProfileId());
			isOther = (lst[0].type == 'Outros' && isVendas) || isAdmin;
		}
	}

	public void saveCliente(){
		try{
			update tmpAccount;
			errorText = null;
		}catch(Exception e){
			errorText = e.getMessage();
			if(tmpAccount.Rating == 'Cliente Inativo' && tmpAccount.Reason_for_Inactivation__c == null){
				errorText = 'Informar um Motivo de Inativação';
			}else{
				errorText = 'Validar o valor da Classificação.';
			}
		}
	}
}