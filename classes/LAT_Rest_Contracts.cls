@RestResource(urlMapping='/LAT_Rest_Contracts/*')
global without sharing class LAT_Rest_Contracts {
    public static LAT_Contract2__c objContract = null;
    public static final String FINALITY_COMMERCIAL_CONDITION = 'Condição Comercial Off Invoice';
    public static final String CONTRACTS_EVENTS_PARCERIA_DISTRIBUIDOR = 'LAT_Eventos_Contrato_de_Parceria_Distribuidor';
    public static final String CONTRACTS_EVENTS_PARCERIA_PRODUTOR = 'LAT_Eventos_Contrato_de_Parceria';
    public static final String CONTRACTS_EVENTS_SIMULACION_PRODUTOR = 'Simulacao_Contrato';
    public static final String CONTRACTS_EVENTS_SIMULACION_DISTRIBUIDOR = 'Simula_o_Contrato_Distribuidor';


    public static final String CONTRACTS_PAYMENT_DINHEIRO = 'LAT_PagamentoDinheiro';
    public static final String CONTRACTS_PAYMENT_PRODUCT = 'LAT_PagamentoProduto';
    public static final String CONTRACTS_PAYMENT_GROUP = 'LAT_PaymentGroup';

    private static final String ONTRADE_CARTAACTIVACION_RECORDTYPE = 'LAT_CartaAtivacao';

    @HttpPost
    global static void POST() {
        LAT_ContractHandlerJSON objContractJSON = null;
        RestRequest objRequest = RestContext.request;
        String strReturn = null;

        System.debug('LAT_Rest_Contracts.POST [] ->');
        objRequest = RestContext.request;
        
        if(objRequest.requestBody != NULL ) {
            try {
                System.debug('LAT_Rest_Contracts.POST [request : ' + objRequest.requestBody.toString() + ']');
                objContractJSON = (LAT_ContractHandlerJSON)System.JSON.deserialize(objRequest.requestBody.toString(), LAT_ContractHandlerJSON.class);

                System.debug('objContractJSON.freightDistributor : ' + objContractJSON.freightDistributor);
                strReturn = doUpsert(objContractJSON);                
                System.debug('LAT_Rest_Contracts.POST [strReturn : ' + strReturn + ']');
                createResponse(strReturn);
            } catch(RestContractException Ex) {
                createResponse(Ex);
            } catch(Exception Ex) {
                System.debug('LAT_Rest_Contracts.POST [Ex : ' + Ex + ']');                
                createResponse(Ex);
            }
        } else {
            createResponse(new RestContractException('O requisito inserido é nulo'));
        }


        System.debug('LAT_Rest_Contracts.POST [] <-');
	}

    @HttpPut
    global static void PUT() {
        LAT_ContractHandlerJSON objContractJSON = null;
        RestRequest objRequest = RestContext.request;
        String strReturn = null;

        System.debug('LAT_Rest_Contracts.PUT [] ->');
        objRequest = RestContext.request;
        
        if(objRequest.requestBody != NULL ) {
            try {
                System.debug('LAT_Rest_Contracts.PUT [request : ' + objRequest.requestBody.toString() + ']');
                objContractJSON = (LAT_ContractHandlerJSON)System.JSON.deserialize(objRequest.requestBody.toString(), LAT_ContractHandlerJSON.class);

                strReturn = doUpsert(objContractJSON);
                System.debug('LAT_Rest_Contracts.PUT [strReturn : ' + strReturn + ']');

                createResponse(strReturn);
            } catch(RestContractException Ex) {
                createResponse(Ex);
            } catch(Exception Ex) {
                System.debug('LAT_Rest_Contracts.PUT [Ex : ' + Ex + ']');                
                createResponse(Ex);
            }
        } else {
            createResponse(new RestContractException('O requisito inserido é nulo'));
        }

        System.debug('LAT_Rest_Contracts.PUT [] <-');
    }

    public static void createResponse(Exception Ex) {
        Boolean boolSuccess = false;
        String strContractId = null;
        ServiceResponseError objResponse = null;

        System.debug('LAT_Rest_Contracts.createResponse [Ex : ' + Ex + '] ->');

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(new ServiceResponseError(Ex)));
        RestContext.response.statusCode = 400;

        System.debug('LAT_Rest_Contracts.createResponse [RestContext.response.responseBody : ' + RestContext.response.responseBody + ']');
        System.debug('LAT_Rest_Contracts.createResponse [RestContext.response.statusCode : ' + RestContext.response.statusCode + ']');
        System.debug('LAT_Rest_Contracts.createResponse [] <-');        
    }

    public static void createResponse(String strReturn) {
        Boolean boolSuccess = false;
        String strContractId = null;
        ServiceResponse objResponse = null;

        System.debug('LAT_Rest_Contracts.createResponse [strReturn : ' + strReturn + '] ->');

        if (String.isBlank(strReturn)) {
            boolSuccess = true;
            strContractId = objContract.Id;
        }

        objResponse = new ServiceResponse(strContractId, strReturn, boolSuccess);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(objResponse));

        if (objResponse.success) {
            RestContext.response.statusCode = 200;
        } else {
            RestContext.response.statusCode = 400;
        }        
        System.debug('LAT_Rest_Contracts.createResponse [RestContext.response.responseBody : ' + RestContext.response.responseBody + ']');
        System.debug('LAT_Rest_Contracts.createResponse [RestContext.response.statusCode : ' + RestContext.response.statusCode + ']');
        System.debug('LAT_Rest_Contracts.createResponse [] <-');        
    }

	public static String doUpsert(LAT_ContractHandlerJSON objContractJSON) {
		String strReturn = null;
        SavePoint objSavePoint = null;
        LAT_ContractsCalculations objContractCalculations = null;
		try {
            System.debug('LAT_Rest_Contracts.doUpsert[objContractJSON : ' + objContractJSON + '] ->');
            objSavePoint = Database.setSavepoint();

            objContract = insertContract(objContractJSON);

            processRelatedRecods(objContractJSON, objContract);

            System.debug('LAT_Rest_Contracts.processRelatedRecodsOther[objContract.RecordTypeId : ' + objContract.RecordTypeId + ']');
            System.debug('LAT_Rest_Contracts.processRelatedRecodsOther[objContract.RecordTypeId : ' + objContract.RecordTypeId + ']');

        
            if (objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(CONTRACTS_EVENTS_PARCERIA_DISTRIBUIDOR).getRecordTypeId() ||  objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(CONTRACTS_EVENTS_PARCERIA_PRODUTOR).getRecordTypeId() ||  objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(CONTRACTS_EVENTS_SIMULACION_PRODUTOR).getRecordTypeId() || objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(CONTRACTS_EVENTS_SIMULACION_DISTRIBUIDOR).getRecordTypeId()) {
                System.debug('LAT_Rest_Contracts.processRelatedRecodsOther[persisting calculations : ' + objContract.RecordTypeId + ']');
                objContractCalculations = new LAT_ContractsCalculations();
                objContractCalculations.calculatePaymentsInformation(new Set<Id> {objContract.Id}, true); 
            }  

		} catch (DMLException Ex){
            System.debug('LAT_Rest_Contracts.doUpsert[Ex [DMLException]: ' + Ex + ']');
            System.debug('LAT_Rest_Contracts.doUpsert[Ex [DMLException] Stacktrace: ' + Ex.getStackTraceString() + ']');
            System.debug('LAT_Rest_Contracts.doUpsert[Ex [DMLException] Message: ' + Ex.getMessage() + ']');
            System.debug('LAT_Rest_Contracts.doUpsert[Ex [DMLException] Cause : ' + Ex.getCause() + ']');

            Database.rollback(objSavePoint);

            if(Ex.getMessage().indexOf('LAT_Rest_Contracts.RestContractException') > 0) {
                //Eso se hace asi porque la excepcion orignal viene nula (Ex.getCause()).
                strReturn = Ex.getMessage().substring(Ex.getMessage().indexOf('LAT_Rest_Contracts.RestContractException: ') + 'LAT_Rest_Contracts.RestContractException: '.length(), Ex.getMessage().indexOf('Class',Ex.getMessage().indexOf('LAT_Rest_Contracts.RestContractException: ')));
            
                System.debug('LAT_Rest_Contracts.doUpsert[strReturn : ' + strReturn + ']');

                throw new RestContractException(999, strReturn);
            } else {
                strReturn = Ex.getMessage();
                
                if(strReturn.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    strReturn = strReturn.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
                    throw new RestContractException(999, strReturn);
                } else {
                    throw Ex;
                }
            }
        } catch(RestContractException Exc2) {
            System.debug('LAT_Rest_Contracts.doUpsert[Exc2 [RestContractException]: ' + Exc2 + ']');
            Database.rollback(objSavePoint);            
            throw(Exc2);
        } catch (Exception Exc) {
            Database.rollback(objSavePoint);

            System.debug('LAT_Rest_Contracts.doUpsert[Ex[Exception]: ' + Exc + ']');
            System.debug('LAT_Rest_Contracts.doUpsert[Ex[Exception]: ' + Exc.getStackTraceString() + ']');
            System.debug('LAT_Rest_Contracts.doUpsert[Ex[Exception]: ' + Exc.getMessage() + ']');
            System.debug('LAT_Rest_Contracts.doUpsert[Ex[Exception]: ' + Exc.getCause() + ']');

            throw Exc;
		}

        System.debug('LAT_Rest_Contracts.doUpsert[' + strReturn + '] <-');
		return strReturn;
	}

    private static LAT_Contract2__c insertContract(LAT_ContractHandlerJSON objContractJSON) {                
        LAT_Contract2__c objContract = null;
        Database.UpsertResult objUpsertResult = null;
        Database.SaveResult objSaveResult = null;
        Schema.SObjectField objExternalId = null;
        String strMessage = null;

        System.debug('LAT_Rest_Contracts.insertContract [objContractJSON : ' + objContractJSON + '] ->');
        
        objContract = objContractJSON.toContract();
        System.debug('LAT_Rest_Contracts.insertContract [FreightDistributor__c: ' + objContract.FreightDistributor__c + '] ->');

        if(String.IsBlank(objContract.Id)) {
            if(validateRequest(objContract)) { 
                if(String.IsNotBlank(objContract.External_Id__c)) {
                    objExternalId = LAT_Contract2__c.Fields.External_Id__c;
                    objUpsertResult = Database.upsert(objContract, objExternalId, false);        
                } else if(String.IsNotBlank(objContract.Id)) {
                    objSaveResult = Database.update(objContract, false);
                } else {
                    objSaveResult = Database.insert(objContract, false);
                }

                if(objUpsertResult != NULL && !objUpsertResult.isSuccess()) {
                    if(objUpsertResult.getErrors() != NULL && objUpsertResult.getErrors().size() > 0) {
                        strMessage = '';
                        for(Database.Error objError : objUpsertResult.getErrors()) {
                            strMessage += objError.getMessage();
                        }
                        throw new RestContractException(100,strMessage);      
                    } else {
                        throw new RestContractException(110, 'Ocorreu um erro ao tentar criar o contrato');
                    }
                } else if(objSaveResult != NULL && !objSaveResult.isSuccess()) {
                    if(objSaveResult.getErrors() != NULL && objSaveResult.getErrors().size() > 0) {
                        strMessage = '';
                        for(Database.Error objError : objSaveResult.getErrors()) {
                            strMessage += objError.getMessage();
                        }
                        throw new RestContractException(120, strMessage);      
                    } else {
                        throw new RestContractException(130, 'Ocorreu um erro ao tentar criar o contrato');
                    }
                }
            } else {
                throw new RestContractException(140,'As informações fornecidas não são válidas');
            }
        } else {  
                if (!Approval.IsLocked(objContract.id) || objContract.Status__c ==  'Em Distrato') {
                update objContract;
            } else {
                throw new RestContractException(150,'Você não pode modificar o acordo, ele está em processo de aprovação');
            }
        }    
        
        System.debug('LAT_Rest_Contracts.insertContract [objContractJSON : ' + objContract + '] <-');
        return objContract;
    }

    private static void processRelatedRecods(LAT_ContractHandlerJSON objContractJSON, LAT_Contract2__c objContract) {
        System.debug('LAT_Rest_Contracts.processRelatedRecods [objContractJSON : ' + objContractJSON + ' - objContract : ' + objContract + '] ->');        
    
        if(objContract != NULL && String.IsNotBlank(objContract.Id)) {
            System.debug('LAT_Rest_Contracts.processRelatedRecods [objContract.RecordTypeId : ' + objContract.RecordTypeId + ']');        
            System.debug('LAT_Rest_Contracts.processRelatedRecods [objContractJSON : ' + objContractJSON + ' - objContract : ' + objContract + '] ->');        
            if(objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo').getRecordTypeId()) {
                processRelatedRecodsAcordos(objContractJSON, objContract);
            } else {
                processRelatedRecodsOther(objContractJSON, objContract);
            }
        }

        System.debug('LAT_Rest_Contracts.processRelatedRecods [] <-');        
    }

    private static void processRelatedRecodsAcordos(LAT_ContractHandlerJSON objContractJSON, LAT_Contract2__c objContract) {
        System.debug('LAT_Rest_Contracts.processRelatedRecodsAcordos [objContractJSON : ' + objContractJSON + ' - objContract : ' + objContract + '] ->');        
        
        insertVolumesAcordos(objContractJSON.listVolume);
		insertContractProviders(objContractJSON.listProviders);
        		
        System.debug('LAT_Rest_Contracts.processRelatedRecodsAcordos [] <-');        
    }

    private static void processRelatedRecodsOther(LAT_ContractHandlerJSON objContractJSON, LAT_Contract2__c objContract) {
        System.debug('LAT_Rest_Contracts.processRelatedRecodsOther [objContractJSON : ' + objContractJSON + ' - objContract : ' + objContract + '] ->');        
        insertVolumes(objContractJSON.listVolume);
                
        if (objContract.RecordTypeId != Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(CONTRACTS_EVENTS_PARCERIA_DISTRIBUIDOR).getRecordTypeId()) {
            System.debug('LAT_Rest_Contracts.processRelatedRecodsOther[adding payments.... not distribuidor : ' + objContractJSON.listPayment + ']');

            insertPayments(objContractJSON.listPayment);
        }   
        
        insertContractDetails(objContractJSON.listContractDetail);
        insertPromotionAgreements(objContractJSON.listPromotionAgreement);
        insertContractClients(objContractJSON.listClientContract);
        insertContractProviders(objContractJSON.listProviders);
        insertVisibilities(objContractJSON.listVisibilityCounterPart);
        
        insertContractEvents(objContractJSON.listContractEvent);

        System.debug('LAT_Rest_Contracts.processRelatedRecodsOther [] <-');        
    }

    private static void insertVolumesAcordos(LAT_ContractHandlerJSON.ListVolume lstVolumes) {
        List<LAT_ContractVolume__c> lstInsert = null;
        List<LAT_ContractVolume__c> lstUpdate = null;
        List<LAT_ContractVolume__c> lstDelete = null;
        LAT_ContractVolume__c objContractVolume = null;
        Set<Id> setVolumes = null;
		Set<Id> setProducts = null;
		Map<String, Id> mapRecordType = null;

        System.debug('LAT_Rest_Contracts.insertVolumesAcordos [lstVolumes : ' + lstVolumes + '] ->');

		mapRecordType = new Map<String, Id>();
		mapRecordType.put('LAT_BR_Acordo_Category', Schema.SObjectType.LAT_ContractVolume__c.getRecordTypeInfosByDeveloperName().get('LAT_BR_Acordo_Category').getRecordTypeId());
		mapRecordType.put('Contrato', Schema.SObjectType.LAT_ContractVolume__c.getRecordTypeInfosByDeveloperName().get('Contrato').getRecordTypeId());
		
        System.debug('LAT_Rest_Contracts.insertVolumesAcordos [mapRecordType : ' + mapRecordType + ']');

        lstInsert = new List<LAT_ContractVolume__c>();
        lstUpdate= new List<LAT_ContractVolume__c>();
        lstDelete = new List<LAT_ContractVolume__c>();
		setVolumes = new Set<Id>();
		setProducts = new Set<Id>();

    	for (LAT_ContractHandlerJSON.Volume objVolumen : lstVolumes.volume) {
			objContractVolume = new LAT_ContractVolume__c();

			if (objVolumen.toDelete == NULL || objVolumen.toDelete != true) { 
				objContractVolume.LAT_Contract__c = objContract.Id; 
				objContractVolume.Producer__c = (objVolumen.producer != NULL)?objVolumen.producer:false;
				
				if(String.IsBlank(objVolumen.categoryid)) {
					if(String.IsNotBlank(objVolumen.product)) {
						if(objVolumen.valorCompreGane != NULL && objVolumen.valorCompreGane >= 0.0) {
							objContractVolume.ProductGroup__c = objVolumen.product;
							objContractVolume.RecordTypeId = mapRecordType.get('Contrato');
							objContractVolume.LAT_Valor_Compre_e_Ganhe__c = objVolumen.valorCompreGane;
						} else {
							throw new RestContractException(160,'A valor compre gane para o produto ' + objVolumen.product + ' não é válido');
						}					
					} else {
						throw new RestContractException(170,'O produto inserido não pode ser nulo.');
					}
				} else {
					objContractVolume.ProductGroup__c = objVolumen.categoryid;
					objContractVolume.RecordTypeId = mapRecordType.get('LAT_BR_Acordo_Category');
                    if(String.IsBlank(objVolumen.description) || objVolumen.description.length() <= SObjectType.LAT_ContractVolume__c.Fields.LAT_BR_Category_Description__c.Length ) {
                        objContractVolume.LAT_BR_Category_Description__c = objVolumen.description;
                    } else {
						throw new RestContractException(180,'A descrição inserida excede o comprimento permitido. [' + SObjectType.LAT_ContractVolume__c.Fields.LAT_BR_Category_Description__c.Length  + ' chars]');
					}
				}

				if (String.isNotBlank(objVolumen.Id) && objVolumen.Id.startsWith(LAT_ContractVolume__c.sObjectType.getDescribe().getKeyPrefix())) {
					objContractVolume.Id = objVolumen.Id;
					lstUpdate.add(objContractVolume);
				} else {
					lstInsert.add(objContractVolume);
				}

				if(!setProducts.contains(objContractVolume.ProductGroup__c)) {
					setProducts.add(objContractVolume.ProductGroup__c);
				} else {
					throw new RestContractException(190,'O produto '+ objContractVolume.ProductGroup__c +' já foi inserido no contrato');
				}
			}
        }
        
        System.debug('LAT_Rest_Contracts.insertVolumesAcordos [lstInsert : ' + lstInsert + ']');
		System.debug('LAT_Rest_Contracts.insertVolumesAcordos [lstUpdate : ' + lstUpdate + ']');
		
        if (lstInsert.size() > 0) {
            insert lstInsert;
        } 

        if (lstUpdate.size() > 0) {
            update lstUpdate;
		} 
		
		for(LAT_ContractVolume__c objUpdateVolume : lstUpdate) {
			setVolumes.add(objUpdateVolume.Id);
		}

		for(LAT_ContractVolume__c objInsertVolume : lstInsert) {
			setVolumes.add(objInsertVolume.Id);
		}

		delete [SELECT Id FROM LAT_ContractVolume__c WHERE Id NOT IN :setVolumes AND LAT_Contract__c =: objContract.Id ];


        System.debug('LAT_Rest_Contracts.insertVolumesAcordos [] <-');
    }

    private static void insertVolumes(LAT_ContractHandlerJSON.ListVolume lstVolumes) {
        List<LAT_ContractVolume__c> lstInsert = null;
        List<LAT_ContractVolume__c> lstUpdate = null;
        List<LAT_ContractVolume__c> lstDelete = null;
        LAT_ContractVolume__c objContractVolume = null;
        Set<Id> setVolumes = null;
		Set<String> setProducts = null;
		Map<String, Id> mapRecordType = null;
        String strProductKey = null;

        System.debug('LAT_Rest_Contracts.insertVolumes [lstVolumes : ' + lstVolumes + '] ->');

        lstInsert = new List<LAT_ContractVolume__c>();
        lstUpdate= new List<LAT_ContractVolume__c>();
        lstDelete = new List<LAT_ContractVolume__c>();
		setVolumes = new Set<Id>();
		setProducts = new Set<String>();

        if (lstVolumes != null && lstVolumes.volume != null && !lstVolumes.volume.IsEmpty()) {
            for (LAT_ContractHandlerJSON.Volume objVolumen : lstVolumes.volume) {
                objContractVolume = new LAT_ContractVolume__c();

                if (objVolumen.toDelete == NULL || objVolumen.toDelete != true) { 
                    objContractVolume.LAT_Contract__c = objContract.Id; 				
                    objContractVolume.ProductGroup__c = objVolumen.product;
                    objContractVolume.Producer__c = (objVolumen.producer != NULL)?objVolumen.producer:false;
                    objContractVolume.PurchaseVolumeGF__c = objVolumen.purchaseVolumeGF;
                    objContractVolume.BonusVolumeGF__c = objVolumen.bonusVolumeGF;
                    objContractVolume.EventType__c = objVolumen.eventType;
                    objContractVolume.Finality__c = objVolumen.finality;
                    objContractVolume.LAT_RealizedVolumeGF__c = objVolumen.realizedVolumenGF; 
                    objContractVolume.LAT_Valor_Compre_e_Ganhe__c = objVolumen.valorCompreGane;
        
                    if (!String.isEmpty(objVolumen.estimatedBoxesMaximum)) objContractVolume.LAT_EstimatedBoxesContract__c = Decimal.valueOf(objVolumen.estimatedBoxesMaximum);
                    if (!String.isEmpty(objVolumen.boxesMaximum)) objContractVolume.BoxesContract__c = Decimal.valueOf(objVolumen.boxesMaximum);
                    if (!String.isEmpty(objVolumen.businessCondition)) objContractVolume.BusinessCondition__c = Decimal.valueOf(objVolumen.businessCondition);
                    if (!String.isEmpty(objVolumen.recordType)) objContractVolume.RecordTypeId = objVolumen.RecordType;
                    if (objVolumen.volumenGF != null) objContractVolume.LAT_BottleVolumen__c = objVolumen.volumenGF;
                    if (objVolumen.bonusQuantity != null) objContractVolume.LAT_BonusQuantity__c = objVolumen.bonusQuantity;
                    if (objVolumen.bonusPercent != null) objContractVolume.LAT_BonusPercent__c = objVolumen.bonusPercent;
        

                    if (String.isNotBlank(objVolumen.Id) && objVolumen.Id.startsWith(LAT_ContractVolume__c.sObjectType.getDescribe().getKeyPrefix())) {
                        objContractVolume.Id = objVolumen.Id;
                        lstUpdate.add(objContractVolume);
                    } else {
                        lstInsert.add(objContractVolume);
                    }

                    strProductKey = String.format('{0}{1}{2}', new String[] { objContractVolume.ProductGroup__c, objContractVolume.EventType__c, String.valueOf(objContractVolume.Producer__c) });

                    if(!setProducts.contains(strProductKey)) {
                        setProducts.add(strProductKey);
                    } else {
                        //throw new RestContractException('El producto ' + objContractVolume.ProductGroup__c + ' ya fue ingresado en el contrato');
                    }
                }
            }
            
            System.debug('LAT_Rest_Contracts.insertVolumes [lstInsert : ' + lstInsert + ']');
            System.debug('LAT_Rest_Contracts.insertVolumes [lstUpdate : ' + lstUpdate + ']');
            
            if (lstInsert.size() > 0) {
                insert lstInsert;
            } 

            if (lstUpdate.size() > 0) {
                update lstUpdate;
            } 
            
            for(LAT_ContractVolume__c objUpdateVolume : lstUpdate) {
                setVolumes.add(objUpdateVolume.Id);
            }

            for(LAT_ContractVolume__c objInsertVolume : lstInsert) {
                setVolumes.add(objInsertVolume.Id);
            }

            delete [SELECT Id FROM LAT_ContractVolume__c WHERE Id NOT IN :setVolumes AND LAT_Contract__c =: objContract.Id ];
        }

        System.debug('LAT_Rest_Contracts.insertVolumes [] <-');
    }

    private static void insertContractEvents(LAT_ContractHandlerJSON.ListContractEvent lstEvents) {
        List<LAT_Contract_Eventos__c> lstInsert = null;
        List<LAT_Contract_Eventos__c> lstDelete = null;
        LAT_Contract_Eventos__c objContractEvent = null;
        Map<Integer, LAT_ContractHandlerJSON.ListVolume> mapVolumesToInsertByIndex = null;
        Map<Integer, LAT_ContractHandlerJSON.ListPayment> mapPaymentsToInsertByIndex = null;
        Map<Id, LAT_ContractHandlerJSON.ListVolume> mapVolumesToInsertByEventId = null;
        Map<Id, LAT_ContractHandlerJSON.ListPayment> mapPaymentsByEventId = null;
        List<Database.UpsertResult> lstSaveResult = null;
        Integer intIndex = null;

        System.debug('LAT_Rest_Contracts.insertContractEvents[lstEvents : ' + lstEvents + '] ->');

        if (lstEvents != null && lstEvents.contractEvent != null && !lstEvents.contractEvent.IsEmpty()) {
            lstInsert = new List<LAT_Contract_Eventos__c>();
            lstDelete = new List<LAT_Contract_Eventos__c>();
            mapVolumesToInsertByEventId = new Map<Id, LAT_ContractHandlerJSON.ListVolume>();
            mapPaymentsByEventId = new Map<Id, LAT_ContractHandlerJSON.ListPayment>();
            mapVolumesToInsertByIndex = new Map<Integer, LAT_ContractHandlerJSON.ListVolume>();
            mapPaymentsToInsertByIndex = new Map<Integer, LAT_ContractHandlerJSON.ListPayment>();

            intIndex = 0;
            for (LAT_ContractHandlerJSON.ContractEvent objEvent : lstEvents.contractEvent) {   
                System.debug('LAT_Rest_Contracts.insertContractEvents[processing event...: ' + objEvent + ']');
             
                objContractEvent = new LAT_Contract_Eventos__c();

                if (objEvent.Id != null && objEvent.Id.startsWith(LAT_Contract_Eventos__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objContractEvent.Id = objEvent.Id;

                    if (objEvent.toDelete == true) {
                        lstDelete.add(objContractEvent);

                        System.debug('LAT_Rest_Contracts.insertContractEvents[deleting...: ' + objContractEvent + ']');
                        continue;
                    } 
                } else {
                    objContractEvent.LAT_Contract__c = objContract.Id;
                } 
                
                objContractEvent.LAT_Cidade__c = objEvent.cidade;
                objContractEvent.LAT_Micro_Regional__c = objEvent.microRegional;                
                objContractEvent.LAT_Open_Bar__c = objEvent.openBar;
                objContractEvent.LAT_Perfil__c = objEvent.perfil;
                objContractEvent.LAT_Periodo__c = objEvent.periodo;
                objContractEvent.LAT_Tipo_de_Evento__c = String.isNotBlank(objEvent.tipoEvento)?objEvent.tipoEvento:'A&P';
                objContractEvent.LAT_Tipo_de_Verba__c = String.isNotBlank(objEvent.tipoVerba)?objEvent.tipoVerba:'A&P';
                objContractEvent.LAT_Classe_Social__c = objEvent.classeSocial;
                objContractEvent.LAT_Comunicacao__c = objEvent.comunicacaoes;
                objContractEvent.LAT_Estilo_Musical__c = objEvent.estilosMusicales;
                objContractEvent.LAT_Faixa_Etaria__c = objEvent.faixaEtarias;
                objContractEvent.LAT_Motivo__c = objEvent.motivo;
                objContractEvent.LAT_Motivo_Comentarios__c = objEvent.motivoComentarios;
                objContractEvent.LAT_Status__c = objEvent.status;
                objContractEvent.Valor_Ingresso__c = objEvent.valorIngresso;
                objContractEvent.LAT_Ativacoes__c = objEvent.ativacoes;
                objContractEvent.LAT_MarcasAtivadas__c = objEvent.marcasActivadas;
                objContractEvent.LAT_MarcasAtivadasSR__c = objEvent.marcasActivadasSR;
                objContractEvent.LAT_Comments__c = objEvent.comments;
                objContractEvent.Name = objEvent.eventName;
                objContractEvent.LAT_Category__c = objEvent.category;
                objContractEvent.LAT_PredictedROI__c = (String.isNotBlank(objEvent.PredictedROI))?Double.valueOf(objEvent.PredictedROI):null;

                //PredictedROI

                if (objEvent.Id != null && !objEvent.Id.startsWith(LAT_Contract_Eventos__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objContractEvent.LAT_External_Id__c = objEvent.Id;
                }
                objContractEvent.LAT_Tipo_Investimento__c = objEvent.tipoInvestimento;
                
                if (!String.isEmpty(objEvent.Investimento)) objContractEvent.LAT_BR_Investimento__c = Decimal.valueOf(objEvent.Investimento);
                if (!String.isEmpty(objEvent.convitesPista)) objContractEvent.LAT_Convites_Pista__c = Decimal.valueOf(objEvent.convitesPista);
                if (!String.isEmpty(objEvent.convitesVIP)) objContractEvent.LAT_Convites_VIP__c = Decimal.valueOf(objEvent.convitesVIP);    
                if (!String.isEmpty(objEvent.nroPessoas)) objContractEvent.LAT_No_Pessoas__c = Decimal.valueOf(objEvent.nroPessoas);
                
                if (!String.isEmpty(objEvent.dataEvento)) objContractEvent.LAT_Data_Evento__c = Date.valueOf(objEvent.dataEvento);
                if (!String.isEmpty(objEvent.postsRedes)) objContractEvent.lat_no_posts__c = Decimal.valueOf(objEvent.postsRedes);
                
                
                if (objEvent.toDelete != true) {
                    lstInsert.add(objContractEvent);

                    if (objEvent.listVolume != null) {
                        mapVolumesToInsertByIndex.put(intIndex, objEvent.listVolume);
                    }

                    if (objEvent.listPayment != null) { 
                        mapPaymentsToInsertByIndex.put(intIndex, objEvent.listPayment);                    
                    }
                    intIndex++;
                }
            }

            if (lstDelete.size() > 0) {
                delete lstDelete;
            } 
            if (lstInsert.size() > 0) {
                lstSaveResult = Database.upsert(lstInsert);
                System.debug('LAT_Rest_Contracts.insertContractEvents[upserting...: ' + lstInsert + ']');

                intIndex = 0;
                for(Database.UpsertResult objUpsertResult : lstSaveResult) {
                    if(mapVolumesToInsertByIndex.containsKey(intIndex)) {
                        mapVolumesToInsertByEventId.put(objUpsertResult.getId(),mapVolumesToInsertByIndex.get(intIndex));
                    }
    
                    if(mapPaymentsToInsertByIndex.containsKey(intIndex)) {
                        mapPaymentsByEventId.put(objUpsertResult.getId(),mapPaymentsToInsertByIndex.get(intIndex));
                    }
    
                    intIndex++;
                }
    
                insertEventVolumes(mapVolumesToInsertByEventId);
                insertEventPayments(mapPaymentsByEventId);    
            }
        } else {
            System.debug('LAT_Rest_Contracts.insertContractEvents[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertContractEvents[] <-');    
    }

    private static void insertEventVolumes(Map<Id, LAT_ContractHandlerJSON.ListVolume> mapVolumesByEventId) {
        List<LAT_EventVolume__c> lstInsert = null;
        List<LAT_EventVolume__c> lstDelete = null;
        LAT_EventVolume__c objEventVolumeC = null;

        System.debug('LAT_Rest_Contracts.insertEventVolumes[mapVolumesByEventId : ' + mapVolumesByEventId + '] ->');

        if (mapVolumesByEventId != null && !mapVolumesByEventId.IsEmpty()) {
            lstInsert = new List<LAT_EventVolume__c>();
            lstDelete = new List<LAT_EventVolume__c>();

            for (Id strEventId : mapVolumesByEventId.keySet()) {            
                System.debug('LAT_Rest_Contracts.insertEventVolumes[processing event...: ' + strEventId + ']');
   
                if (mapVolumesByEventId.get(strEventId).volume != null) {
                    for (LAT_ContractHandlerJSON.Volume objEventVolume : mapVolumesByEventId.get(strEventId).volume) {
                        System.debug('LAT_Rest_Contracts.insertEventVolumes[processing event payment...: ' + objEventVolume + ']');

                        objEventVolumeC = new LAT_EventVolume__c();

                        //Esto es porque compass utiliza sus propios ids
                        if (objEventVolume.Id != null && objEventVolume.Id.startsWith(LAT_EventVolume__c.sObjectType.getDescribe().getKeyPrefix())){
                            objEventVolumeC.Id = objEventVolume.id;
                            if (objEventVolume.toDelete  == true) {
                                lstDelete.add(objEventVolumeC);

                                System.debug('LAT_Rest_Contracts.insertEventVolumes[deleting...: ' + objEventVolumeC + ']');
                                continue;
                            }
                        } else {
                            objEventVolumeC.LAT_ContractEvent__c = strEventId;
                        }

                        //objEventVolumeC.LAT_ContractEvent__c = contractEventId;
                        objEventVolumeC.LAT_ProductGroup__c = objEventVolume.product;
                        objEventVolumeC.Finality__c = objEventVolume.finality;
                        objEventVolumeC.LAT_RealizedVolumeGF__c = objEventVolume.realizedVolumenGF; 

                        if (!String.isEmpty(objEventVolume.boxesMaximum)) objEventVolumeC.LAT_BoxesContract__c = Decimal.valueOf(objEventVolume.boxesMaximum);
                        if (!String.isEmpty(objEventVolume.estimatedBoxesMaximum)) objEventVolumeC.LAT_EstimatedBoxesContract__c = Decimal.valueOf(objEventVolume.estimatedBoxesMaximum);
                        if (!String.isEmpty(objEventVolume.businessCondition)) objEventVolumeC.LAT_BusinessCondition__c = Decimal.valueOf(objEventVolume.businessCondition);
                        if (objEventVolume.volumenGF != null) objEventVolumeC.LAT_Volume__c = objEventVolume.volumenGF;
                        if (objEventVolume.bonusQuantity != null) objEventVolumeC.LAT_BonusQuantity__c = objEventVolume.bonusQuantity;
                        if (objEventVolume.bonusPercent != null) objEventVolumeC.LAT_BonusPercent__c = objEventVolume.bonusPercent;

                        if (objEventVolume.toDelete != true) {
                            lstInsert.add(objEventVolumeC);

                            System.debug('LAT_Rest_Contracts.insertEventVolumes[upserting...: ' + objEventVolumeC + ']');
                        }
                    }
                }

            }
            if (!lstDelete.IsEmpty()) {
                delete lstDelete;
            }
            
            if (!lstInsert.IsEmpty()) {
                upsert lstInsert;
            } 
        } else {
            System.debug('LAT_Rest_Contracts.insertEventPayments[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertEventPayments[] <-');    
    }

    private static void insertEventPayments(Map<Id, LAT_ContractHandlerJSON.ListPayment> mapPaymentsByEventId) {
        List<LAT_EventPayment__c> lstInsert = null;
        List<LAT_EventPayment__c> lstDelete = null;
        LAT_EventPayment__c objEventPaymentC = null;

        System.debug('LAT_Rest_Contracts.insertEventPayments[mapPaymentsByEventId : ' + mapPaymentsByEventId + '] ->');

        if (mapPaymentsByEventId != null && !mapPaymentsByEventId.IsEmpty()) {
            lstInsert = new List<LAT_EventPayment__c>();
            lstDelete = new List<LAT_EventPayment__c>();
            for (Id strEventId : mapPaymentsByEventId.keySet()) {
                System.debug('LAT_Rest_Contracts.insertEventPayments[processing event...: ' + strEventId + ']');

                if (mapPaymentsByEventId.get(strEventId).payment != null) {
                    for (LAT_ContractHandlerJSON.Payment objEventPayment : mapPaymentsByEventId.get(strEventId).payment) {
                        System.debug('LAT_Rest_Contracts.insertEventPayments[processing event payment...: ' + objEventPayment + ']');
                        objEventPaymentC = new LAT_EventPayment__c();

                        if (objEventPayment.Id != null && objEventPayment.id.startsWith(LAT_EventPayment__c.sObjectType.getDescribe().getKeyPrefix())){                                
                            objEventPaymentC.Id = objEventPayment.id;

                            if (objEventPayment.toDelete  == true) {
                                lstDelete.add(objEventPaymentC);
                                System.debug('LAT_Rest_Contracts.insertEventPayments[deleting...: ' + objEventPaymentC + ']');
                                continue;
                            }
                        } else {
                            objEventPaymentC.LAT_ContractEvent__c = strEventId;
                        }

                        objEventPaymentC.LAT_ProductGroup__c = objEventPayment.productGroup;
                        objEventPaymentC.LAT_Finality__c = objEventPayment.finality;
                        objEventPaymentC.LAT_EventType__c = objEventPayment.eventType;
                        objEventPaymentC.RecordTypeId = objEventPayment.recordType;
                        objEventPaymentC.LAT_Ammount__c = objEventPayment.ammount;

                        if (objEventPayment.volumenGF != null) {
                            objEventPaymentC.LAT_VolumeGF__c = objEventPayment.volumenGF;
                        }
                        if (objEventPayment.bonusQuantity != null) {
                            objEventPaymentC.LAT_BonusQuantity__c = objEventPayment.bonusQuantity;
                        }
                        if (objEventPayment.bonusPercent != null) {
                            objEventPaymentC.LAT_BonusPercent__c = objEventPayment.bonusPercent;
                        }
                        
                        if (objEventPayment.toDelete != true) {
                            lstInsert.add(objEventPaymentC);

                            System.debug('LAT_Rest_Contracts.insertEventPayments[upserting...: ' + objEventPaymentC + ']');
                        }
                    }
                }
            }
            if (!lstDelete.IsEmpty()) {
                delete lstDelete;
            }
            
            if (!lstInsert.IsEmpty()) {
                upsert lstInsert;
            } 
        } else {
            System.debug('LAT_Rest_Contracts.insertEventPayments[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertEventPayments[] <-');    
    }
    
    private static void insertPayments(LAT_ContractHandlerJSON.ListPayment lstPayments) {
        List<LAT_Payment__c> lstInsert = null;
        List<LAT_Payment__c> lstDelete = null;
        LAT_Payment__c objPaymentC = null;
        Integer intBonusQuantity = null;
        Set<Id> setEventRecordTypes = null;

        System.debug('LAT_Rest_Contracts.insertPayments[lstContractDetails : ' + lstPayments + '] ->');

        if (lstPayments != null && lstPayments.payment != null && !lstPayments.payment.IsEmpty()){
            lstInsert = new List<LAT_Payment__c>();
            lstDelete = new List<LAT_Payment__c>();

            for (LAT_ContractHandlerJSON.Payment objPayment : lstPayments.payment) {
                System.debug('LAT_Rest_Contracts.insertPayments[processing...: ' + objPayment + ']');

                objPaymentC = new LAT_Payment__c();
    
                if (objPayment.Id != null && objPayment.id.startsWith(LAT_Payment__c.sObjectType.getDescribe().getKeyPrefix())) {                   
                    objPaymentC.Id = objPayment.id;
    
                    if (objPayment.toDelete == true) {
                        lstDelete.add(objPaymentC);
                        System.debug('LAT_Rest_Contracts.insertPayments[deleting...: ' + objPaymentC + ']');
                        continue;
                    } 
                } else {
                    objPaymentC.LAT_Contract__c = objContract.Id;
                }

                if (objPayment.EventPaymentCreatedAfterSigning == null) {
                    objPayment.EventPaymentCreatedAfterSigning = false;
                }
                
                objPaymentC.Finality__c = objPayment.finality;
                objPaymentC.ProductGroup__c = objPayment.productGroup;
                objPaymentC.RecordTypeId = objPayment.recordType;
                objPaymentC.Volumen__c = objPayment.volumen;
                objPaymentC.Status__c = objPayment.status;
                objPaymentC.ReleaseReason__c = objPayment.releaseReason;
                objPaymentC.Ammount__c = objPayment.ammount;
                objPaymentC.LAT_BonusPercent__c = objPayment.bonusPercent;
                objPaymentC.LAT_EventValue__c = objPayment.valorEventoTotal;
                objPaymentC.LAT_EventCashValue__c = objPayment.valorEventoCash;
                objPaymentC.LAT_EventProductValue__c = objPayment.valorEventoProuto;
                objPaymentC.LAT_EventBoxQuantity__c = objPayment.cajasProduto;
                objPaymentC.EventPaymentCreatedAfterSigning__c = objPayment.EventPaymentCreatedAfterSigning;
                objPaymentC.EventType__c = objPayment.eventType;
                objPaymentC.LAT_Send_to_Approval__c = true;

                if (!String.isEmpty(objPayment.paymentDate)) {
                    objPaymentC.PaymentDate__c = Date.valueOf(objPayment.paymentDate);
                }
                
                if (!String.isEmpty(objPayment.paymentDateDone)) {
                    objPaymentC.PaymentDateDone__c = Date.valueOf(objPayment.paymentDateDone);
                }
    
                if (objPayment.imposto != null) {
                    objPaymentC.LAT_Taxes__c = objPayment.imposto;
                }
                
                if (objPayment.bonusQuantity != null) {
                    //NO SE ENTIENDE QUE HACE ESTO.
                    // A - INT(A) > 0? -> INCREMENTAR A -> GUARDAR a.
                    // Pero bonus quantity es int. a - int(a) es cero,
                    //Finalmente 
                    intBonusQuantity = objPayment.bonusQuantity.intValue();
        
                    if ((objPayment.bonusQuantity - intBonusQuantity) > 0) {
                        intBonusQuantity++;
                    }
                    
                    objPaymentC.LAT_BonusQuantity__c = intBonusQuantity;

                    if (objPaymentC.LAT_BonusQuantity__c != null) {
                        setEventRecordTypes = getEventRecordTypes();
        
                        if(objPayment.EventPaymentCreatedAfterSigning && objPaymentC.Finality__c == FINALITY_COMMERCIAL_CONDITION && setEventRecordTypes.contains(objContract.RecordTypeId) ) {
                            objPaymentC.LAT_BonusQuantity__c  = objPaymentC.LAT_BonusQuantity__c * 10;
                        } 
                    }
                }
    
                if (String.isNotBlank(objPayment.distribuitorId)) {
                    objPaymentC.LAT_Distributor__c = objPayment.distribuitorId;
                }
                if (objPayment.producer != null ) {
                    objPaymentC.LAT_Producer__c = objPayment.producer;  
                } 
                   
                if (objPayment.toDelete != true) {
                    if (objPayment.Id != null){
                        if (objPayment.Id.startsWith(LAT_Payment__c.sObjectType.getDescribe().getKeyPrefix())){
                            if (!Approval.IsLocked(objPayment.id) || objPaymentC.Status__c ==  'Em Distrato') {
                                lstInsert.add(objPaymentC);
                                System.debug('LAT_Rest_Contracts.insertPayments[upserting (not locked)...: ' + objPaymentC + ']');
                            }
                        } else {
                            lstInsert.add(objPaymentC);
                            System.debug('LAT_Rest_Contracts.insertPayments[upserting(not payment)...: ' + objPaymentC + ']');
                        }
                    } else {
                        lstInsert.add(objPaymentC);
                        System.debug('LAT_Rest_Contracts.insertPayments[upserting(inserting)...: ' + objPaymentC + ']');
                    }                    
                }
            }

            if (!lstDelete.IsEmpty()) {
                delete lstDelete;
            }
            
            if (!lstInsert.IsEmpty()) {
                upsert lstInsert;
            } 
        } else {
            System.debug('LAT_Rest_Contracts.insertPayments[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertPayments[] <-');       
    }

    private static void insertContractDetails(LAT_ContractHandlerJSON.ListContractDetail lstContractDetails) {
        List<LAT_ContractDetails__c> lstInsert = null;
        List<LAT_ContractDetails__c> lstDelete = null;
        LAT_ContractDetails__c objContractDetailsC = null;

        System.debug('LAT_Rest_Contracts.insertContractDetails[lstContractDetails : ' + lstContractDetails + '] ->');

        if (lstContractDetails != null && lstContractDetails.contractDetail != null && !lstContractDetails.contractDetail.IsEmpty()){
            lstInsert = new List<LAT_ContractDetails__c>();
            lstDelete = new List<LAT_ContractDetails__c>();

            for (LAT_ContractHandlerJSON.ContractDetail objContractDetail : lstContractDetails.contractDetail) {
                System.debug('LAT_Rest_Contracts.insertContractDetails[processing...: ' + objContractDetail + ']');
                objContractDetailsC = new LAT_ContractDetails__c();

                if (objContractDetail.id != null && objContractDetail.id.startsWith(LAT_ContractDetails__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objContractDetailsC.Id = objContractDetail.id;

                    if (objContractDetail.toDelete == true) {
                        lstDelete.add(objContractDetailsC);
                        System.debug('LAT_Rest_Contracts.insertContractDetails[deleting...: ' + objContractDetailsC + ']');
                        continue;
                    } 
                } else {
                    objContractDetailsC.LAT_Contract__c = objContract.Id;
                }

                if (String.isNotBlank(objContractDetail.date_Z)) {
                    objContractDetailsC.Date__c = Date.valueOf(objContractDetail.date_Z);
                }
                
                if (objContractDetail.recordType != null) {
                    objContractDetailsC.RecordTypeId = objContractDetail.recordType;
                }

                objContractDetailsC.Brand__c = objContractDetail.brand;
                objContractDetailsC.Local__c = objContractDetail.local;
                

                if (objContractDetail.toDelete != true) {
                    lstInsert.add(objContractDetailsC);
                    System.debug('LAT_Rest_Contracts.insertContractDetails[upserting...: ' + objContractDetailsC + ']');
                }
            }

            if (!lstDelete.IsEmpty()) {
                delete lstDelete;
            }
            
            if (!lstInsert.IsEmpty()) {
                upsert lstInsert;
            } 
        } else {
            System.debug('LAT_Rest_Contracts.insertContractDetails[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertContractDetails[] <-');
    }

    private static void insertPromotionAgreements(LAT_ContractHandlerJSON.ListPromotionAgreement lstPromotionAgreement) {
        List<LAT_PromotionalAgreement__c> lstInsert = null;
        List<LAT_PromotionalAgreement__c> lstDelete = null;
        LAT_PromotionalAgreement__c objPromotionAgreementC = null;
    
        System.debug('LAT_Rest_Contracts.insertPromotionAgreements[lstPromotionAgreement : ' + lstPromotionAgreement + '] ->');

        if (lstPromotionAgreement != null && lstPromotionAgreement.promotionAgreement != null && !lstPromotionAgreement.promotionAgreement.IsEmpty()){
            lstInsert = new List<LAT_PromotionalAgreement__c>();
            lstDelete = new List<LAT_PromotionalAgreement__c>();
            
            for (LAT_ContractHandlerJSON.PromotionAgreement objPromotionAgreement : lstPromotionAgreement.promotionAgreement) {
                System.debug('LAT_Rest_Contracts.insertPromotionAgreements[processing...: ' + objPromotionAgreement + ']');
                objPromotionAgreementC = new LAT_PromotionalAgreement__c();                
                if (objPromotionAgreement.Id != null && objPromotionAgreement.id.startsWith(LAT_PromotionalAgreement__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objPromotionAgreementC.Id = objPromotionAgreement.id;


                    if (objPromotionAgreement.toDelete == true) {
                        lstDelete.add(objPromotionAgreementC);  
                        System.debug('LAT_Rest_Contracts.insertPromotionAgreements[deleting...: ' + objPromotionAgreementC + ']');
                        continue;
                    }                
                } else {
                    objPromotionAgreementC.Contract__c = objContract.Id;
                }

        		objPromotionAgreementC.Category__c = objPromotionAgreement.category;
        		objPromotionAgreementC.ExclusivityPromotional__c = objPromotionAgreement.exclusivityPromotional;
        		objPromotionAgreementC.VisualExclusivity__c = objPromotionAgreement.visualExclusivity;
        		objPromotionAgreementC.Notes__c = objPromotionAgreement.notes;
        		objPromotionAgreementC.Priority__c = objPromotionAgreement.priority;
                
                if (objPromotionAgreement.toDelete != true) {
                    lstInsert.add(objPromotionAgreementC);
                    System.debug('LAT_Rest_Contracts.insertPromotionAgreements[upserting...: ' + objPromotionAgreementC + ']');
                }                 
            }
            if (!lstDelete.IsEmpty()) {
                delete lstDelete;
            }
            
            if (!lstInsert.IsEmpty()) {
                upsert lstInsert;
            } 
        } else {
            System.debug('LAT_Rest_Contracts.insertPromotionAgreements[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertPromotionAgreements[] <-');
    }

    private static void insertContractClients(LAT_ContractHandlerJSON.ListClientContract lstClientContracts) {
        List<LAT_ContractClient__c> lstInsert = null;
        List<LAT_ContractClient__c> lstDelete = null;
        LAT_ContractClient__c objContractClientC = null;

        System.debug('LAT_Rest_Contracts.insertContractProviders[lstClientContracts : ' + lstClientContracts + '] ->');
       
        if (lstClientContracts != null && lstClientContracts.clientContract != null && !lstClientContracts.clientContract.IsEmpty()) {        
            lstInsert = new List<LAT_ContractClient__c>();
            lstDelete = new List<LAT_ContractClient__c>();

            for (LAT_ContractHandlerJSON.ClientContract objClientContract : lstClientContracts.clientContract) {
                System.debug('LAT_Rest_Contracts.insertContractClients[processing...: ' + objClientContract + ']');

                objContractClientC = new LAT_ContractClient__c();
                
                if (objClientContract.Id != null && objClientContract.Id.startsWith(LAT_ContractClient__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objContractClientC.Id = objClientContract.Id;
                    
                    if (objClientContract.toDelete == true) {
                        lstDelete.add(objContractClientC);
                        System.debug('LAT_Rest_Contracts.insertContractClients[deleting...: ' + objClientContract + ']');
                        continue;
                    }                         
                } else {
                    objContractClientC.Contract__c = objContract.Id;
                }

                objContractClientC.Client__c = objClientContract.client;
                if (objClientContract.toDelete != true) {
                    lstInsert.add(objContractClientC);
                    System.debug('LAT_Rest_Contracts.insertContractClients[upserting...: ' + objContractClientC + ']');
                }
            }
			
			if (!lstDelete.IsEmpty()) {
                delete lstDelete;
			} 
			
            if (!lstInsert.IsEmpty()) {
                upsert lstInsert;
            } 
        } else {
            System.debug('LAT_Rest_Contracts.insertContractClients[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertContractClients[] <-');
    }

    private static void insertContractProviders(LAT_ContractHandlerJSON.ListProviders lstProviders) {
		List<LAT_Provider__c> lstInsert = null;		
		List<LAT_Provider__c> lstUpdate = null;
		LAT_Provider__c objProviderC = null;
		Set<Id> setProviders = null;
		Set<String> setCNPJs = null;

        System.debug('LAT_Rest_Contracts.insertContractProviders[lstProviders : ' + lstProviders + '] ->');

        if (lstProviders != null && lstProviders.Provider != null && !lstProviders.Provider.IsEmpty()){
			lstInsert = new List<LAT_Provider__c>();
			lstUpdate = new List<LAT_Provider__c>();

			setProviders = new Set<Id>();
			setCNPJs = new Set<String>();
    
            for (LAT_ContractHandlerJSON.Provider objProvider : lstProviders.Provider) {
                System.debug('LAT_Rest_Contracts.insertContractProviders[processing...: ' + objProvider + ']');

                objProviderC = new LAT_Provider__c();

				if (objProvider.toDelete == NULL || objProvider.toDelete != true) { 
					if(String.IsNotBlank(objProvider.cnpj) && !setCNPJs.contains(objProvider.cnpj)) {
						objProviderC.Contract__c = objContract.Id;
						objProviderC.Provider__c = objProvider.provider; 
						objProviderC.CNPJ__c = objProvider.cnpj; 	
	
						setCNPJs.add(objProviderC.CNPJ__c);
						
						if (objProvider.Id != null && objProvider.Id.startsWith(LAT_Provider__c.sObjectType.getDescribe().getKeyPrefix())) {
							objProviderC.Id = objProvider.id;    
							
							lstUpdate.add(objProviderC);
						} else {
							lstInsert.add(objProviderC);
						}						
						System.debug('LAT_Rest_Contracts.insertContractProviders[upserting...: ' + objProviderC + ']');
					} else {
						throw new RestContractException(200,'El CNPJ [' + objProvider.cnpj + '] es nulo o ya fue ingresado en el contrato');
					}
				}                
            }
            
            if (!lstUpdate.IsEmpty()) {
				update lstUpdate;
			} 
			
			if (!lstInsert.IsEmpty()) {
				insert lstInsert;
			}

			for(LAT_Provider__c objProvider : lstUpdate) {
				setProviders.add(objProvider.Id);
			}

			for(LAT_Provider__c objProvider : lstInsert) {
				setProviders.add(objProvider.Id);
			}
		
			delete [SELECT Id FROM LAT_Provider__c WHERE Id NOT IN :setProviders AND Contract__c =: objContract.Id ];
        } else {
            System.debug('LAT_Rest_Contracts.insertContractProviders[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertContractProviders[] <-');
    }

    private static void insertVisibilities(LAT_ContractHandlerJSON.ListVisibilityCounterPart lstVisibilities) {
    	List<LAT_VisibilityCounterparts__c> lstInsert = null;
        List<LAT_VisibilityCounterparts__c> lstDelete = null;
        LAT_VisibilityCounterparts__c objVisibilityCounterparts = null;

        System.debug('LAT_Rest_Contracts.insertVisibilities[lstVisibilities : ' + lstVisibilities + '] ->');

        if (lstVisibilities != null && lstVisibilities.VisibilityCounterPart != null && !lstVisibilities.VisibilityCounterPart.IsEmpty()) {
            lstInsert = new List<LAT_VisibilityCounterparts__c>();
            lstDelete = new List<LAT_VisibilityCounterparts__c>();
    
        	for (LAT_ContractHandlerJSON.VisibilityCounterPart objVisibility : lstVisibilities.VisibilityCounterPart) {
                System.debug('LAT_Rest_Contracts.insertVisibilities[processing...: ' + objVisibility + ']');
                objVisibilityCounterparts = new LAT_VisibilityCounterparts__c();
                
                if (objVisibility.Id != null && objVisibility.Id.startsWith(LAT_VisibilityCounterparts__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objVisibilityCounterparts.Id = objVisibility.Id;    

                    if (objVisibility.toDelete == true) {
                        lstDelete.add(objVisibilityCounterparts);
                        System.debug('LAT_Rest_Contracts.insertVisibilities[deleting...: ' + objVisibilityCounterparts + ']');
                        continue;
                    } 
                } else {
                    objVisibilityCounterparts.Contract__c = objContract.Id; 
                }

        		objVisibilityCounterparts.Comment__c = objVisibility.comment; 
        		objVisibilityCounterparts.Type__c = objVisibility.type_Z;
        		objVisibilityCounterparts.LAT_SocialMedia__c = objVisibility.socialMedia; 
        		objVisibilityCounterparts.LAT_Link__c = objVisibility.link; 
                    
                if (objVisibility.toDelete != true) {
                    System.debug('LAT_Rest_Contracts.insertVisibilities[upserting...: ' + objVisibilityCounterparts + ']');
                    lstInsert.add(objVisibilityCounterparts);
                } 
            }

            if (!lstDelete.IsEmpty()) {
                delete lstDelete;
            }
            
            if (!lstInsert.IsEmpty()) {
                upsert lstInsert;
            } 
        } else {
            System.debug('LAT_Rest_Contracts.insertVisibilities[nothing to proccess]');
        }

        System.debug('LAT_Rest_Contracts.insertVisibilities[] <-');
    }

    @testVisible
    private static Set<Id> getEventRecordTypes() {
        Id strEventPartnerRecordTypeId = null;
        Id strEventDistributorRecordTypeId = null;
        Set<Id> setRecordTypes = null;

        System.debug('LAT_Rest_Contracts.getEventRecordTypes[] ->');

        setRecordTypes = new Set<Id>();
        strEventPartnerRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria');
        strEventDistributorRecordTypeId = Global_RecordTypeCache.getRtId('LAT_Contract2__c'+'LAT_Eventos_Contrato_de_Parceria_Distribuidor');

        setRecordTypes.add(strEventPartnerRecordTypeId);
        setRecordTypes.add(strEventDistributorRecordTypeId);

        System.debug('LAT_Rest_Contracts.getEventRecordTypes[' + setRecordTypes + '] <-');

        return setRecordTypes;
    }

    @testVisible
    private static void setContract(LAT_Contract2__c objContractC) {
        objContract = objContractC;
    } 

    private static Boolean validateRequest(LAT_Contract2__c objContract) {
        Boolean boolIsValid = false;
        Set<Id> setRecordTypesId = null;
        
        System.debug('LAT_Rest_Contracts.validateRequest[objContract : ' + objContract + '] ->');

        setRecordTypesId = retrieveAllowedRecordTypes('LAT_Contract2__c');

        if(setRecordTypesId.contains(objContract.RecordTypeId)) {
            if(objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(CONTRACTS_EVENTS_SIMULACION_PRODUTOR).getRecordTypeId() || objContract.RecordTypeId == Schema.SObjectType.LAT_Contract2__c.getRecordTypeInfosByDeveloperName().get(CONTRACTS_EVENTS_SIMULACION_DISTRIBUIDOR).getRecordTypeId()) {
                boolIsValid = true;
            } else {
                //if(String.IsNotBlank(objContract.Account__c)) {
                    if(objContract.StartDate__c != NULL) {
                        if(objContract.EndDate__c != NULL) {
                            if(objContract.StartDate__c <= objContract.EndDate__c) {
                                if(String.IsNotBlank(objContract.ProcessStatus__c) && (objContract.ProcessStatus__c == 'Em Elaboração' || objContract.ProcessStatus__c == 'Contrato em Alteração')) {
                                    //Ativo = aditivo 0121i000000cBwUAAU
                                    if(String.IsNotBlank(objContract.Status__c) && ( objContract.Status__c == 'Novo Contrato' || objContract.Status__c == 'Ativo' ) ) {
                                        if(String.IsNotBlank(objContract.Source__c) && objContract.Source__c == 'Mobile') {
                                            boolIsValid = true;
                                        } else {
                                            throw new RestContractException(210,'El origen del contrato no es válido');
                                        }
                                    } else {
                                        throw new RestContractException(220,'El estado del contrato no es válido');
                                    }
                                } else {
                                    throw new RestContractException(230,'El estado del proceso no es válido');
                                } 
                            } else {
                                throw new RestContractException(240,'La fecha de inicio no puede ser mayor a la fecha de fin del contrato');
                            }
                        } else {
                            throw new RestContractException(250,'La fecha de inicio del contrato no puede ser anterior al dia de la fecha');
                        }
                    } else {
                        throw new RestContractException(260,'La fecha de inicio del contrato no puede ser anterior al dia de la fecha');
                    }                
                // } else {
                //     throw new RestContractException(270,'Debe ingresar una cuenta para el contrato.');
                // }
            } 
        } else{
            throw new RestContractException(280,'El tipo de registro del contrato no es válido.');
        }
        System.debug('LAT_Rest_Contracts.validateRequest[' + boolIsValid + '] <-');
        return boolIsValid;
    }

    private static Set<Id> retrieveAllowedRecordTypes(String strSObject) {
        Schema.DescribeSObjectResult objSObjectResult = null;
        List<Schema.RecordTypeInfo> lstRecordTypeInfo = null;
        Set<Id> setRecordType = null;

        System.debug('LAT_Rest_Contracts.retrieveAllowedRecordTypes [strSObject : ' + strSObject + '] ->');

        objSObjectResult = Schema.getGlobalDescribe().get(strSObject).getDescribe();
        lstRecordTypeInfo = objSObjectResult.getRecordTypeInfos();
        setRecordType = new Set<Id>();

        for(Schema.RecordTypeInfo objRecordType : lstRecordTypeInfo){
            setRecordType.add(objRecordType.getRecordTypeId());
        }

        System.debug('LAT_Rest_Contracts.retrieveAllowedRecordTypes [' + setRecordType + '] <-');

        return setRecordType;
    }

    /*
    private static String generateGUID() {
		Blob objBlob = null;
		String strHexa = null;
		String strGUID = null;

		System.debug('generateGUID [] ->');
		objBlob = Crypto.GenerateAESKey(128);
		strHexa = EncodingUtil.ConvertTohex(objBlob);
		strGUID = strHexa.SubString(0,8) + '-' + strHexa.SubString(8,12) + '-' + strHexa.SubString(12,16) + '-' + strHexa.SubString(16,20) + '-' + strHexa.substring(20);
		
		System.debug('generateGUID [' + strGUID + '] <-');

		return strGUID;
	}
    */
    public class RestContractException extends Exception {
        public Integer errorCode { get; set; }
        public String code { get; set; }
        public String message { get; set; }
        public String stacktrace { get; set; }
        public String label_message { get; set; }

        public RestContractException(Integer intErrorCode, String strMessage) {
            this(strMessage);

            System.debug('RestContractException [intErrorCode : ' + intErrorCode + ' - strMessage : ' + strMessage + '] ->');

            this.errorCode = intErrorCode;
            this.code = String.valueOf(intErrorCode);
            this.message = strMessage;
            this.stacktrace = '';
            this.label_message = strMessage;

            System.debug('RestContractException [] <-');
        }

        public RestContractException(Integer intErrorCode, String strProductGroupId, String strAccountId, String strMessage) { 
            this(strMessage);
            List<Account> lstAccount = null;
            List<LAT_ReferenceProductGrouping__c> lstProducts = null;
            Account objAccount = null;
            LAT_ReferenceProductGrouping__c objProduct = null;

            System.debug('RestContractException [intErrorCode : ' + intErrorCode + ' - strMessage : ' + strMessage + ' - strProductGroupId : ' + strProductGroupId + ' - strAccountId : ' + strAccountId + '] ->');

            try {
                if(String.isNotBlank(strAccountId)) {
                    lstAccount = [SELECT Id, Name, Client_code_AN8__c FROM Account WHERE Id =: strAccountId];
                }

                if(String.IsNotBlank(strProductGroupId)) {
                    lstProducts = [SELECT Id, Name, (SELECT ID, NAME, SKURef__r.SKU__c FROM LAT_ReferenceProducts__r WHERE IsActive__c = TRUE) FROM LAT_ReferenceProductGrouping__c WHERE Id =: strProductGroupId];
                }

                if(lstAccount != null && !lstAccount.IsEmpty()) {
                    objAccount = lstAccount[0];
                }

                if(lstProducts != null && !lstProducts.IsEmpty()) {
                    objProduct = lstProducts[0];
                }

                System.debug('RestContractException [objAccount : ' + objAccount + ']');
                System.debug('RestContractException [objProduct : ' + objProduct + ']');

                if(objProduct != null && objAccount != null) {
                    if(!objProduct.LAT_ReferenceProducts__r.IsEmpty() && objProduct.LAT_ReferenceProducts__r[0].SKURef__r != null && String.IsNotBlank(objProduct.LAT_ReferenceProducts__r[0].SKURef__r.SKU__c)) {
                        strMessage = String.format('Nenhum custo para o produto {0} ({1}) foi encontrado para a conta {2} ({3}). (Id CRM do produto: {4})', new String[] {objProduct.Name, objProduct.LAT_ReferenceProducts__r[0].SKURef__r.SKU__c, objAccount.Name, objAccount.Client_code_AN8__c, objProduct.Id}); 
                    } else {
                        strMessage = String.format('Nenhum custo para o produto {0} foi encontrado para a conta {1} ({2}). (Id CRM do produto: {3})', new String[] { objProduct.Name, objAccount.Name, objAccount.Client_code_AN8__c, objProduct.Id}); 
                    }
                } else if(objProduct != null) {
                    if(!objProduct.LAT_ReferenceProducts__r.IsEmpty() && objProduct.LAT_ReferenceProducts__r[0].SKURef__r != null && String.IsNotBlank(objProduct.LAT_ReferenceProducts__r[0].SKURef__r.SKU__c)) {
                        strMessage = String.format('Nenhum custo para o produto {0} ({1}) foi encontrado. (Id CRM do produto: {2})', new String[] {objProduct.Name, objProduct.LAT_ReferenceProducts__r[0].SKURef__r.SKU__c, objProduct.Id}); 
                    } else {
                        strMessage = String.format('Nenhum custo para o produto {0} foi encontrado. (Id CRM do produto: {2})', new String[] { objProduct.Name, objProduct.Id}); 
                    }
                }
                System.debug('RestContractException [strMessage : ' + strMessage + ']');
                
                this.errorCode = intErrorCode;
                this.code = String.valueOf(intErrorCode);
                this.message = strMessage;
                this.stacktrace = '';
                this.label_message = strMessage;

                this.setMessage(strMessage);
            } catch(Exception Ex) {
                System.debug('RestContractException [We fail at failing]');

                System.debug('RestContractException [Ex : '  + Ex + ']');
                System.debug('RestContractException [Ex : '  + Ex.getStackTraceString() + ']');
            }
            System.debug('RestContractException [] <-');
        }        
    }

    public class ServiceResponseError {
        public Integer errorCode { get; set; }
        public String code { get; set; }
        public String message { get; set; }
        public String stacktrace { get; set; }
        public String label_message { get; set; }

        public ServiceResponseError(Exception Ex) {
            this.errorCode = 999;
            this.code = String.valueOf(999);
            this.message = Ex.getMessage();
            this.stacktrace = Ex.getStackTraceString();
            this.label_message = 'DONDE APARECE ESTE MENSAJE';
        }
    }

    public class ServiceResponse {
        public String Id { get; set; }
        public Boolean success { get; set; }
        public String message { get; set; }
        public String errorCode { get; set; }

        public ServiceResponse(String strContractId, String strMessage, Boolean boolIsSuccess) {
            this.success = boolIsSuccess;
            this.message = strMessage;
            this.Id = strContractId;
        }
    }
}