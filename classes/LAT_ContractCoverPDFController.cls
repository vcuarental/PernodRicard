/*
* LAT_Contract2
* Author: Martin Prado (martin@zimmic.com)
* Date: 08/18/2016
*/
global with sharing class LAT_ContractCoverPDFController {
    public class ContractException extends Exception {}
    global static final String FINALITY_COMMERCIAL_CONDITION = 'Condição Comercial Off Invoice';
	private static final String CONTRATO_STATUS_APROBADO = 'Aprovado';
	private static final String CONTRATO_CATEGORY_RECORDTYPE = 'LAT_BR_Acordo_Category';
	private static final Set<String> CONTRATO_ALLOWED_PRODUCT_RECORDTYPES = new Set<String> { 'LAT_BR_Acordo_Category', 'Contrato'};
	global final Set<String> EVENT_DEVELOPER_NAMES = new Set<String>{'LAT_Eventos_Contrato_de_Parceria', 'LAT_Eventos_Contrato_de_Parceria_Distribuidor'};

    global LAT_Contract2__c contract { get{
                                            if(!init){
                                              init(); 
                                            }
                                            return contract;
                                        }set;}
    global Boolean isApproved  {get;set;}
    global Boolean annex1 {get;set;}
    global Boolean init {get;set;}
 
    global String strContrapartidas  {get;set;}

    global List<LAT_Payment__c> cashPayments {get;set;}
    global List<LAT_Payment__c> productPaymentsPaymentCondition {get;set;}
    global List<LAT_Payment__c> productPayments {get;set;}
    global List<LAT_Contract_Eventos__c> eventosContrato {get;set;}

    global boolean needsPresidentSign {get;set;}
    global boolean needsDirectorFinanciero {get;set;}
    global boolean needsDirectorComercial {get;set;}
    global boolean needsNationalTradeManager {get;set;}
    global boolean isprestige {get;set;}
	
	global boolean isAcordo {get;set;}
    global Id idContrato {get;set;}
    global Integer num {get;set;}


	public List<ProductCategory> products { get; set; }

  // Constructor
    global LAT_ContractCoverPDFController() {
        String strType = null;
        strType = System.CurrentPageReference().getParameters().get('type');
        if(String.IsNotBlank(strType) && strType == 'acordo') {
            intializeAcordo();
        } else {
            init();
        }
    }

    global void init(){
        init = true;
        System.debug('LAT_ContractCoverPDFController.%%%% idContrato : ' + idContrato);
        num = 0;
        Id contractId;
        String type;
        if(idContrato != null){   
            contractId = idContrato;
        } else {
            contractId = system.CurrentPageReference().getParameters().get('id');
            type  = system.CurrentPageReference().getParameters().get('type');
        }

        System.debug('LAT_ContractCoverPDFController contractId : ' + contractId);

        // by default is anex2
        annex1 = false;

        if(type != null && type != '') {
          annex1 = true;
        }
        isApproved = false;
        contract = new LAT_Contract2__c();



        List<LAT_Contract2__c> contractResults = [SELECT LAT_MarcasAtivadas__c,LAT_Comunicacao__c,LAT_Ativacoes__c,PRBPortfolio__c,Exlusivity__c,TotalProductsPRBCostCondComercial__c, TotalProductsPerceivedValueCondComercial__c, TotalProductsPRBCostPatrocinio__c,TotalProductsPRBCost__c, 
                TotalProductsPerceivedValuePatrocinio__c, TotalMoneyPRBCost__c, TotalEventContractPerceivedValue__c, TotalEventContractPRBCost__c,
                LAT_Digital__c, LAT_Contrapartidas__c,LAT_no_Posts__c, LAT_Distributor__r.Name, RecordType.DeveloperName,
                Owner.Name, Revenue__c, LAT_ClientRegional__c,RegionalCustomerOnPremise__c,Comments__c, (select Provider__c, CNPJ__c from LAT_Providers__r),
                (SELECT Category__c,Contract__c,CurrencyIsoCode,ExclusivityPromotional__c,Id,Name,Notes__c,Priority__c,VisualExclusivity__c FROM Acordos_Promocionales__r),
                  VodkaClubCabinets__c, WhiskyClubCabinets__c, DJBooth__c, BarsShelves__c,
                  (Select EventType__c, TotalVolume__c, ProductGroup__r.name, BoxesContract__c,BusinessCondition__c,CurrencyIsoCode,Id,LAT_Contract__c,Name,ProductGroup__c, LAT_Valor_Compre_e_Ganhe__c, LAT_BR_Category_Description__c from LAT_ContractVolumes__r),
                  Name ,  CustomerSignatory__c, CustomerSignatory__r.name, Status__c, createdBy.Name,
                  (Select LAT_BonusPercent__c, LAT_BonusQuantity__c, LAT_UOM__c, Ammount__c,Finality__c,PaymentDate__c,ProductGroup__c,RecordTypeId,Status__c,ProductGroup__r.Name,  RecordType.Name,  RecordType.DeveloperName, LAT_Producer__c, Type__c,Volumen__c from LAT_Payments__r order by PaymentDate__c asc ),
                  RecordType.Name, Account__r.regional__r.Name, Account__r.Nielsen_Area__r.Name, Account__r.Billing_Address__c, Account__r.Billing_Number__c,
                  Account__r.Revenue_City__c,  Account__r.Revenue_Postal_Code__c,  Account__r.Revenue_Address__c, Account__r.Revenue_Number__c ,
                   Account__r.Revenue_UF__c, Account__r.Billing_UF__c, Account__r.Billing_City_Code__c, Account__r.Billing_PostalCode__c,
                   Account__r.Corporate_Name__c, Account__r.name, Account__r.Revenue_City__r.name, Account__r.Sub_Channel_Rating__r.name,
                   account__r.CNPJ__c, account__r.State_Registration__c, Account__r.subType__c, StartDate__c, EndDate__c, ContractTerms__c,
                   ROI__c, TotalProductsPerceivedValue__c, TotalMoneyPerceivedValue__c,convertCurrency(ContractValue__c),
                   (SELECT Type__c, Comment__c, LAT_SocialMedia__c, LAT_Link__c FROM Contrapartidas_de_Visibilidades__r),
               (SELECT Client__c, Client__r.Name, Client__r.CNPJ__c  FROM Clientes_do_Contrato__r), OriginalContractNumber__c, OriginalContractName__c
               FROM LAT_Contract2__c where id =: contractId];
        if(contractResults.size() > 0){
            
            contract = contractResults[0];
            strContrapartidas = contract.LAT_Contrapartidas__c;

            if(EVENT_DEVELOPER_NAMES.contains(contract.RecordType.DeveloperName) || contract.RecordType.DeveloperName == 'LAT_CartaAtivacao'){
                needsNationalTradeManager = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_GERENTE_NACIONAL_ONTRADE_THAN_EVENTOS);
                annex1 = true;
            }
            if(contract.Status__c == 'Aprovado'){
                isApproved = true;
            }
            if(contract.LAT_MarcasAtivadas__c != null)
                contract.LAT_MarcasAtivadas__c = contract.LAT_MarcasAtivadas__c.replace(';',', ');
            if(contract.LAT_Comunicacao__c != null)
                contract.LAT_Comunicacao__c = contract.LAT_Comunicacao__c.replace(';',', ');
            if(contract.LAT_Ativacoes__c != null)
                contract.LAT_Ativacoes__c = contract.LAT_Ativacoes__c.replace(';',', ');

            eventosContrato = [SELECT Id,  Name, LAT_Cidade__r.Name, LAT_Estado__c, LAT_Periodo__c, LAT_No_Pessoas__c, LAT_Convites_VIP__c, LAT_Convites_Pista__c, LAT_Open_Bar__c, LAT_Micro_Regional__c FROM LAT_Contract_Eventos__c WHERE LAT_Contract__c =:contractId];

            isprestige = (contract.LAT_ClientRegional__c == 'REG NBD');
            if(EVENT_DEVELOPER_NAMES.contains(contract.RecordType.DeveloperName)) {
                needsPresidentSign = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_PRESIDENT_GREATER_THAN_EVENTOS);
                needsDirectorFinanciero = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_EVENTOS);
                needsDirectorComercial = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_EVENTOS);
 		    } else {
                if (isprestige){
                    needsPresidentSign = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_PRESIDENT_GREATER_THAN_PRESTIGE);
                    needsDirectorFinanciero = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN_PRESTIGE);
                    
                    needsDirectorComercial = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN_PRESTIGE);
                } else {
                    if(contract.RecordType.DeveloperName != 'LAT_CartaAtivacao'){
                        needsPresidentSign = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_PRESIDENT_GREATER_THAN);
                        needsDirectorFinanciero = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_FINANCIAL_DIRECTOR_GREATER_THAN);
                        needsDirectorComercial = (contract.ContractValue__c!= null && contract.ContractValue__c >= LAT_Docusign_Utils.SENT_TO_COMERCIAL_DIRECTOR_GREATER_THAN);

                    }
                    

                }
             }
            cashPayments = new List<LAT_Payment__c>();
            productPayments = new List<LAT_Payment__c>();
            productPaymentsPaymentCondition = new List<LAT_Payment__c>();
            for(LAT_Payment__c pay : contract.LAT_Payments__r) {
                System.debug('LAT_ContractCoverPDFController.%%% pay.RecordType.Name : ' + pay.RecordType.Name);
                if(pay.RecordType.DeveloperName == 'LAT_PagamentoProduto'){
                    if(pay.Finality__c == FINALITY_COMMERCIAL_CONDITION) {
                        productPaymentsPaymentCondition.add(pay);
                    } else {
                        productPayments.add(pay);
                    }
                    
                } else if(pay.RecordType.DeveloperName == 'LAT_PagamentoDinheiro') {
                    cashPayments.add(pay);
                }
            }


            system.debug('%%%%% cashPayments = ' + cashPayments.size());
            system.debug('%%%%% productPayments = ' + productPayments.size());

        }
    }

    global String getInitData(){
        init();
        return '';
    }

    private void intializeAcordo() {
        String strContractId = null;
        String strType = null;
		LAT_Contract2__c objContract = null;
		Map<Id, LAT_ContractVolume__c> mapCategories = null;
		Map<Id, List<LAT_ContractVolume__c>> mapProductsByCategory = null;
		ProductCategory objProductCategory = null;

        System.debug('LAT_ContractCoverPDFController.intializeAcordo[] ->');
        strContractId = System.CurrentPageReference().getParameters().get('id');
		
		System.debug('LAT_ContractCoverPDFController.intializeAcordo[strContractId : ' + strContractId + ']');

        if (String.isNotBlank(strContractId) && strContractId.startsWith(LAT_Contract2__c.sObjectType.getDescribe().getKeyPrefix()) && (strContractId.length() == 15 || strContractId.length() == 18)) {
            objContract = retrieveContract(strContractId);

            if(objContract != null) {
				if(objContract.LAT_ContractVolumes__r.size() > 0) {
					init = true;
					this.products = new List<ProductCategory>();

					if(objContract.Status__c == CONTRATO_STATUS_APROBADO) {
						isApproved = true;
					}

					mapCategories = new Map<Id, LAT_ContractVolume__c>();
					mapProductsByCategory = new Map<Id, List<LAT_ContractVolume__c>>();

					//pongo en un mapa las categorias
					for(LAT_ContractVolume__c objVolume : objContract.LAT_ContractVolumes__r) {				
						if(objVolume.RecordType.DeveloperName == CONTRATO_CATEGORY_RECORDTYPE) {
							if(!mapCategories.containsKey(objVolume.Id)) {
								mapCategories.put(objVolume.ProductGroup__c, objVolume);
								mapProductsByCategory.put(objVolume.ProductGroup__c, new List<LAT_ContractVolume__c>());			
							}
						}
					}

					System.debug('LAT_ContractCoverPDFController.intializeAcordo[mapCategories : ' + mapCategories + ']');					

					if(!mapCategories.IsEmpty()) {
					// vuelvo a recorrer pongo los productos
						for(LAT_ContractVolume__c objVolume : objContract.LAT_ContractVolumes__r) {				
							if(CONTRATO_ALLOWED_PRODUCT_RECORDTYPES.contains(objVolume.RecordType.DeveloperName) ) {
								if(mapCategories.containsKey(objVolume.ProductGroup__r.Parent__c)) {
									mapProductsByCategory.get(objVolume.ProductGroup__r.Parent__c).add(objVolume);
								}
							}
						}

						System.debug('LAT_ContractCoverPDFController.intializeAcordo[mapProductsByCategory : ' + mapProductsByCategory + ']');

						for(Id objCategoryId : mapProductsByCategory.keySet()) {
							if(mapCategories.containsKey(objCategoryId) && mapProductsByCategory.get(objCategoryId).size() > 0) {
								objProductCategory = new ProductCategory();
								objProductCategory.category = mapCategories.get(objCategoryId).ProductGroup__r.Name;
								objProductCategory.descripcion = mapCategories.get(objCategoryId).LAT_BR_Category_Description__c;
								objProductCategory.items = mapProductsByCategory.get(objCategoryId);

								this.products.add(objProductCategory);
								System.debug('LAT_ContractCoverPDFController.intializeAcordo[adding category group... : ' + objProductCategory + ']');
							} else {
								System.debug('LAT_ContractCoverPDFController.intializeAcordo[mapProductsByCategory.get(objCategoryId).size()... : ' + mapProductsByCategory.get(objCategoryId).size() + ']');
								System.debug('LAT_ContractCoverPDFController.intializeAcordo[mapCategories.containsKey(objCategoryId)... : ' + mapCategories.containsKey(objCategoryId) + ']');
							}
						}
						
						System.debug('LAT_ContractCoverPDFController.intializeAcordo[this.products : ' + this.products  + ']');
						contract = objContract;
					} else {
						throw new ContractException('El contrato no tiene definidas categorias de productos');
					}
				} else {
					throw new ContractException('No puede generar un contrato sin productos');
				}
            } else {
                throw new ContractException('No se ha encontrado el contrato búscado');
            }
        } else {
            throw new ContractException('Debe ingresar un identificador de contrato válido');
        }
        System.debug('LAT_ContractCoverPDFController.intializeAcordo[] <-');
    }

    private LAT_Contract2__c retrieveContract(Id strContractId) {
        List<LAT_Contract2__c> lstContracts = null;
        LAT_Contract2__c objContract = null;
        System.debug('LAT_ContractCoverPDFController.intializeAcordo[strContractId : ' + strContractId + '] ->');

        if(String.isNotBlank(strContractId)) {
            lstContracts = [SELECT  LAT_MarcasAtivadas__c, LAT_Comunicacao__c,LAT_Ativacoes__c,PRBPortfolio__c,Exlusivity__c,TotalProductsPRBCostCondComercial__c, TotalProductsPerceivedValueCondComercial__c, 
                                    TotalProductsPRBCostPatrocinio__c,TotalProductsPRBCost__c, TotalProductsPerceivedValuePatrocinio__c, TotalMoneyPRBCost__c, TotalEventContractPerceivedValue__c, TotalEventContractPRBCost__c,
                                    LAT_Digital__c, LAT_Contrapartidas__c,LAT_no_Posts__c, LAT_Distributor__r.Name, RecordType.DeveloperName,
                                    Owner.Name, Revenue__c, LAT_ClientRegional__c,RegionalCustomerOnPremise__c,Comments__c, 
                                    VodkaClubCabinets__c, WhiskyClubCabinets__c, DJBooth__c, BarsShelves__c,
                                    Name ,  CustomerSignatory__c, CustomerSignatory__r.name, Status__c, createdBy.Name,
                                    RecordType.Name, Account__r.regional__r.Name, Account__r.Nielsen_Area__r.Name, Account__r.Billing_Address__c, Account__r.Billing_Number__c,
                                    Account__r.Revenue_City__c,  Account__r.Revenue_Postal_Code__c,  Account__r.Revenue_Address__c, Account__r.Revenue_Number__c ,
                                    Account__r.Revenue_UF__c, Account__r.Billing_UF__c, Account__r.Billing_City_Code__c, Account__r.Billing_PostalCode__c,
                                    Account__r.Corporate_Name__c, Account__r.name, Account__r.Revenue_City__r.name, Account__r.Sub_Channel_Rating__r.name,
                                    account__r.CNPJ__c, account__r.State_Registration__c, Account__r.subType__c, StartDate__c, EndDate__c, ContractTerms__c,
                                    ROI__c, TotalProductsPerceivedValue__c, TotalMoneyPerceivedValue__c,convertCurrency(ContractValue__c),
                                    OriginalContractNumber__c, OriginalContractName__c,
                                    (SELECT Provider__c, CNPJ__c 
                                    FROM LAT_Providers__r),
									(SELECT Id, ProductGroup__c, ProductGroup__r.Name, ProductGroup__r.Parent__c,
											LAT_Valor_Compre_e_Ganhe__c, LAT_BR_Category_Description__c, 
											LAT_Contract__c, 
											Name, RecordType.DeveloperName 
                                    FROM LAT_ContractVolumes__r),
                                    (SELECT Type__c, Comment__c, LAT_SocialMedia__c, LAT_Link__c 
                                    FROM Contrapartidas_de_Visibilidades__r),
                                    (SELECT Client__c, Client__r.Name, Client__r.CNPJ__c  
                                    FROM Clientes_do_Contrato__r)
                        FROM LAT_Contract2__c 
                        WHERE Id =: strContractId];
            if(!lstContracts.IsEmpty()) {
                objContract = lstContracts[0];
            }
        }

        System.debug('LAT_ContractCoverPDFController.intializeAcordo['  + objContract + '] <-');
        return objContract;       
	}
	
	public class ProductCategory {
		public String category {get; set; }
		public String descripcion {get; set; }

		public List<LAT_ContractVolume__c> items {get; set; }
	}
}