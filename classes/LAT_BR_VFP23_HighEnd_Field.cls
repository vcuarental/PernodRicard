/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
public with sharing class LAT_BR_VFP23_HighEnd_Field {
	public Boolean isEspecializado{get;set;}
	public LAT_Account__c tmpAccount{get;set;}
	public String errorText{get;set;}


	public LAT_BR_VFP23_HighEnd_Field(ApexPages.StandardController controller) {
		Set<Id> setAdminsId = new Set<Id>();
        errorText = null;

        setAdminsId.add(LAT_GlobalProfileCache.getStandardAdminProfileId());
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('Business administrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('PR BRAZIL System Administrator'));
        setAdminsId.add(LAT_GlobalProfileCache.getProfileIdByName('System Administrator'));

		List<LAT_Account__c> lst = [Select id,LAT_HighEnd__c,LAT_Accountid__r.Rating_segmentation_targert_market__c from LAT_Account__c where LAT_Accountid__c =: controller.getRecord().Id limit 1];
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
			isEspecializado = (lst[0].LAT_Accountid__r.Rating_segmentation_targert_market__c == 'ESPECIALIZADO') || isAdmin;
		}
	}

	public void saveCliente(){
		try{
			update tmpAccount;
			errorText = null;
		}catch(Exception e){
			errorText = e.getMessage();
		}
	}
}