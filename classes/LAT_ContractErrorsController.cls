/*
* LAT_ContractErrorsController
* Author: Martin Prado (martin@zimmic.com)
* Date: 28/11/2016
*/
public with sharing class LAT_ContractErrorsController {

    private final LAT_Contract2__c contract;
    public List<String> errors {get;set;}
    public final String LETTEROFAGREEMENT = 'On Trade – Carta Acordo';

    /**
    * LAT_ContractErrorsController Constructor
    */
    public LAT_ContractErrorsController(ApexPages.StandardController controller) {
        errors = new List<String>();
        this.contract = (LAT_Contract2__c)controller.getRecord();
        if(this.contract.ProductsErrorCount__c != null) {

            List<LAT_ContractError__c> lce = [Select Id, LAT_Type__c, LAT_ProductGroup__r.Name, LAT_Comments__c from LAT_ContractError__c where LAT_Contract__c =:this.contract.id];
            for(LAT_ContractError__c err : lce) {
                String comment = (err.LAT_Comments__c!=null)  ? ' ('+err.LAT_Comments__c+')' : '';
                errors.add(err.LAT_ProductGroup__r.Name + ': ' + err.LAT_Type__c + comment);
            }
        }
    }


    /**
    * letterOfAgreementValidation
    * @param recordTypeName
    */
    public static void letterOfAgreementValidation(List<LAT_Contract2__c> triggerNew ){

        Set<Id> rTypesIds = new Set<Id>();
        for (LAT_Contract2__c con: triggerNew) {
            rTypesIds.add(con.recordtypeid);
        }

        Map<Id,RecordType> recordTypeName = new Map<Id,RecordType>([SELECT DeveloperName From recordtype WHERE id in :rTypesIds]);

        for (LAT_Contract2__c con: triggerNew) {
            con.LAT_ErrorMessages__c = '';
            //Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosById().get(con.recordtypeid).getname();
            //We only check the value if record type is 'On Trade – Carta Acordo'
            if(recordTypeName.get(con.recordtypeid).DeveloperName == 'LAT_OnTrade_LetterAgreementCommercialCondition'){
                String[] cartaMaxVal = LAT_GeneralConfigDao.getValueAsStringArray('LAT_CONTRACT_CARTA_ACORDO_MAX_VALUE', ',');
                // If custom setting is not set we skip the validation
                if(cartaMaxVal.size()>0){

                    String maxVal = cartaMaxVal[0];
                    Double doubleMaxVal = Double.ValueOf(maxVal);

                    if(con.TotalMoneyPerceivedValue__c != null && con.TotalProductsPerceivedValue__c != null ) {
                        if((con.TotalMoneyPerceivedValue__c + con.TotalProductsPerceivedValue__c) > doubleMaxVal  ) {
                            // errors.add('Carta Acordo somente é permitida para contratos com valor total abaixo de '+maxVal);
                            con.LAT_ErrorMessages__c = 'Carta Acordo somente é permitida para contratos com valor total abaixo de '+maxVal;
                        }
                    }
                }
            }

        }




    }



}