public with sharing class EUR_CRM_ContrActivItemService {

	public class ContractProductItemsWorker {

		public void deleteCpiForLumpSumCai(List<EUR_CRM_Contract_Activity_Item__c> cais, Map<Id, EUR_CRM_Contract_Activity_Item__c> oldCaiById) {

			List<EUR_CRM_Contract_Activity_Item__c> caisToDeleteCpi = this.getCaisWithChangedAmount(cais, oldCaiById);

			List<Database.DeleteResult> deleteResults = Database.delete(this.selectCpisWhereCais(caisToDeleteCpi), false);
			this.logErrors(deleteResults);
		}


		//private methods
		private List<EUR_CRM_Contract_Activity_Item__c> getCaisWithChangedAmount(List<EUR_CRM_Contract_Activity_Item__c> cais, Map<Id, EUR_CRM_Contract_Activity_Item__c> oldCaiById) {
			List<EUR_CRM_Contract_Activity_Item__c> caisToDeleteCpi = new List<EUR_CRM_Contract_Activity_Item__c>();
			for (EUR_CRM_Contract_Activity_Item__c cai : cais) {
				if (this.isValidCai(cai, oldCaiById.get(cai.Id))) {
					caisToDeleteCpi.add(cai);
				}
			}

			return caisToDeleteCpi;
		}

		private Boolean isValidCai(EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Activity_Item__c oldCai) {
			return this.isAmountChanged(cai,oldCai)
			&& this.isAmountBlank(cai);
		}

		private Boolean isAmountChanged(EUR_CRM_Contract_Activity_Item__c cai, EUR_CRM_Contract_Activity_Item__c oldCai) {
			return cai.EUR_CRM_Amount__c != oldCai.EUR_CRM_Amount__c;
		}

		private Boolean isAmountBlank(EUR_CRM_Contract_Activity_Item__c cai) {
			return cai.EUR_CRM_Amount__c == 0 || cai.EUR_CRM_Amount__c == null;
		}

		private List<EUR_CRM_Contract_Product_Item__c> selectCpisWhereCais(List<EUR_CRM_Contract_Activity_Item__c> cais) {
			return [
				SELECT Id
				FROM EUR_CRM_Contract_Product_Item__c
				WHERE EUR_CRM_Contract_Activity_Item__c IN :cais
			];
		}

		private void logErrors(List<Database.DeleteResult> deleteResults) {
			for (Database.DeleteResult dr : deleteResults) {
				if (!dr.isSuccess()) {
					this.logErrors(dr.getErrors());
				}
			}
		}

		private void logErrors(List<Database.Error> errors) {
			for (Database.Error err : errors) {
				System.debug('-----------------------------------------------------------');
				System.debug('The following error has occurred.');
				System.debug(err.getStatusCode() + ': ' + err.getMessage());
				System.debug('-----------------------------------------------------------');
			}
		}

	}
}