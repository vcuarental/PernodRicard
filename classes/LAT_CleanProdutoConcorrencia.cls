global class LAT_CleanProdutoConcorrencia implements Database.Batchable<sObject> {
    
    String query;
    
    /* This batch is used to delete Produto_Concorr_ncia__c object when the Checklist_de_visita__c was created
     * on the YearMonths passed as parameter and there are no other Produtos_Concorr_ncia__r asociated to Checklist_de_visita__c 
     * that does not have the Nao_se_aplica__c checked and Qtde_de_Caixas_Estoque__c == null.
     *
	 * Initialisation Example:
	 *
	 * Map<Integer, List<Integer>> YearMonth = new Map<Integer, List<Integer>>();
	 * List<Integer> months = new List<Integer>{1, 2, 3, 4};
	 * YearMonth.put(2014, months);
	 *
	 * LAT_CleanProdutoConcorrencia cpc = new LAT_CleanProdutoConcorrencia(YearMonth);
	 * Database.executeBatch(cpc, 10);	
	 */
    global LAT_CleanProdutoConcorrencia(Map<Integer, List<Integer>> YearMonths) {
        try {

        	this.query = 'SELECT Id, (SELECT Nao_se_aplica__c,Qtde_de_Caixas_Estoque__c FROM Produtos_Concorr_ncia__r) ' + 
		                    	'FROM Checklist_de_visita__c ' +
		                        'WHERE';

        	for (Integer year: YearMonths.keySet()) {
        		for (Integer month : YearMonths.get(year)) {
		            if (month > 0 && month < 13) {
		                datetime fromDate = datetime.newInstance(year, month, 01);
		                
		                datetime ToDate = fromDate.addMonths(1);
		                ToDate = ToDate.addDays(-1);

		                system.debug('FromDate ==== ' + fromDate);
		                system.debug('ToDate ==== ' + ToDate);

		                this.query += ' (CreatedDate >= ' + fromDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') +
		                                ' AND CreatedDate <= ' + ToDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') +
		                                ') OR';
		            }
		        }
	        }

	        if (this.query.contains('OR')) {
	        	this.query = this.query.substring(0, this.query.length() - 3);
	        }

	        system.debug('query === ' + this.query);
        } catch (Exception e) {
            system.debug('There was an exception. \nMessage: ' + e.getMessage() + 
                            '\nStackTrace: ' + e.getStackTraceString() + '\nLine: ' + e.getLineNumber());
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Checklist_de_visita__c> scope) {
        try {
            List<Produto_Concorr_ncia__c> PPRCToDelete = new List<Produto_Concorr_ncia__c>();
            for (Checklist_de_visita__c csv: scope) {
                Produto_Concorr_ncia__c[] PPRCList = csv.getSObjects('Produtos_Concorr_ncia__r');
                
                if (PPRCList != null) {
                    Integer iter = 0;
                    while (iter < PPRCList.size() 
                            && !PPRCList[iter].Nao_se_aplica__c 
                            && PPRCList[iter].Qtde_de_Caixas_Estoque__c == null) {
                        iter++;
                    }
                    if (iter >= PPRCList.size()) {
                        PPRCToDelete.addAll(PPRCList);
                    }
                }

            }

            system.debug('To Delete ==== ' + PPRCToDelete);
            system.debug('To Delete Size ==== ' + PPRCToDelete.size());
            delete PPRCToDelete;
        } catch (Exception e) {
            system.debug('There was an exception. \nMessage: ' + e.getMessage() + 
                            '\nStackTrace: ' + e.getStackTraceString() + '\nLine: ' + e.getLineNumber());
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}