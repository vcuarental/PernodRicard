/******************************************************************************************
*   Company:Valuenet    Developers:   Denis Aranda                       Date:15/05/2014  *
*******************************************************************************************/
global without sharing class LAT_AR_BTN01_ReceiptValidateType {
	
	webService static String ReceiptValidateType(String idReceipt){
		Boolean isArg = false;
		RCP_Receipt_ARG__c rec = [SELECT Id, Name, LAT_AR_DepositAccountType__c, Account_AR__r.RecordType.DeveloperName FROM RCP_Receipt_ARG__c WHERE Id =: idReceipt];
		if(rec.Account_AR__r.RecordType.DeveloperName == 'ACC_5_Events_ARG' || rec.Account_AR__r.RecordType.DeveloperName == 'ACC_1_OffTrade_ARG' || rec.Account_AR__r.RecordType.DeveloperName == 'ACC_3_OnTrade_ARG'){
			isArg = true;
		}
		
		String idCampoReceiptNo =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='ReceiptNo_AR__c' AND ObjectApiName__c='DPT_Deposit_ARG__c'].FieldId__c;
		String idCampoAccType =[SELECT Id, FieldId__c FROM CS002_FIeldsIds__c WHERE FieldApiName__c='AccType_AR__c' AND ObjectApiName__c='DPT_Deposit_ARG__c'].FieldId__c;
		
		//if(rec.LAT_AR_DepositAccountType__c == null){
		//	return Label.LAT_AR_BTN01_00001;
			//Label.LAT_AR_BTN01_00001 = "The field 'AR Deposit Account Type' has to be completed in order to create a Deposit"
		//}else{
			string AccountType;
			String depRtId;
			
			if(rec.LAT_AR_DepositAccountType__c == 'C'){
				AccountType = 'Bank Account';
			}else{
				AccountType = 'Collection Bank Account';
			}
			
			if(isArg){
	        	depRtId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_AR');
	        }else{
	        	depRtId = Global_RecordTypeCache.getRtId('DPT_Deposit_ARG__c' + 'DPT_Standard_UY');
	        }
			String prefixObj = DPT_Deposit_ARG__c.SObjectType.getDescribe().getKeyPrefix();
			
	        String urlReturn = '/' + prefixObj + '/e?';
	        urlReturn += '&RecordType=' + depRtId;
	        urlReturn += '&' + idCampoReceiptNo + '=' + EncodingUtil.urlEncode(rec.Name,'UTF-8');
	        urlReturn += '&' + idCampoReceiptNo + '_lkid=' + rec.id;
	        urlReturn += '&' + idCampoAccType + '=' + AccountType;
	        urlReturn += '&retURL=%2F' + rec.id;
	        
	        return urlReturn;
		//}
	}
}