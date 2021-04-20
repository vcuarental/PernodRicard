global class LAT_BR_TraficLightBatch implements Database.Batchable<sObject>, Database.Stateful {

	String query;
	Integer Month;
	String textMonth;
	String textYear;
	Integer bStep;
	Integer eStep;
	Integer Year;

	Map<String, LAT_BR_TrafficLight__c> traficMap;
	Map<String, LAT_BR_Vacations__c> vacationsMap;
	List<LAT_BR_TL_CamposPreenchidos__c> campos;
	Set<String> modifiedToday;
	Set <String> mapKeyset;
	String stringClienteInactivo = 'Cliente Inativo';
	String rtIdOnTrade = Global_RecordTypeCache.getRtId('Account' + 'On_Trade');
	String rtIdOffTrade = Global_RecordTypeCache.getRtId('Account' + 'Off_Trade');
	Map<String,String> mapMonths = new Map<String,String> {
                '1' => 'Janeiro', '2' => 'Fevereiro', '3' => 'Março', '4' => 'Abril', '5' => 'Maio', '6' => 'Junho', '7' => 'Julho',
                '8' => 'Agosto', '9' => 'Setembro', '10' => 'Outubro', '11' => 'Novembro', '12' => 'Dezembro'
            };


	// The constructor receives a string that determinates the KPI that
	// will calculated on the current run
	// 1 - Active Accounts
	global LAT_BR_TraficLightBatch(Integer batchStep, Integer endStep, Integer monthParam, Integer yearParam) {

		// Variable initialization
		this.Month = (monthParam != null && monthParam > 0 && monthParam <= 12)
						? monthParam : Date.today().month();
		this.Year = (yearParam != 0 && yearParam != null) ? yearParam : Date.today().year();
		this.textMonth = mapMonths.get(String.valueOf(this.Month));
		this.textYear = String.valueOf(this.year);

		this.bStep = batchStep;
		this.eStep = endStep != null ? endStep : 6;
		this.traficMap = this.getTraficLightObjects(String.valueOf(this.Month), this.Year);
		this.vacationsMap = this.getVacations(String.valueOf(this.Month), this.Year);
		this.modifiedToday = new Set<String>();


		// Depending on the step the KPI that is executed
		if (batchStep == 1) {
			this.query = 'SELECT id, OwnerId, Owner.ManagerId, Owner.Gerente_regional__c, ' +
							   ' Owner.Regional_de_vendas__c, Rating, RecordTypeId, Channel__c '+
						 ' FROM Account ' +
						 ' WHERE (RecordTypeId =:rtIdOnTrade OR RecordTypeId =:rtIdOffTrade)';
		} else if(batchStep == 2){
			Set<String> fieldsAdded = new Set<String>();
			campos = [Select LAT_BR_Field__c,LAT_BR_Type__c,LAT_BR_Conditions__c from LAT_BR_TL_CamposPreenchidos__c];
			if(campos != null && campos.size() > 0){
				this.query = 'Select id,status__c,type,Reason_for_Inactivation__c,rating,RecordTypeId,OwnerId,Channel__c';
				for(LAT_BR_TL_CamposPreenchidos__c str : campos){
					if(!fieldsAdded.contains(str.LAT_BR_Field__c)){
						this.query += ',' + str.LAT_BR_Field__c;
						fieldsAdded.add(str.LAT_BR_Field__c);
					}
				}
				this.query += ' FROM Account WHERE (RecordTypeId =:rtIdOnTrade OR RecordTypeId =:rtIdOffTrade)';
			}else{
				this.query = '';
			}
		} else if(batchStep == 3){
			this.query = 'SELECT id,Status__c,Planejamento__r.ownerId,LAT_BR_CustomerAgreed__c,LAT_BR_HasAttachment__c,Visita_n_o_realizada__c,LAT_MX_GoalAchieved__c,Data_da_Visita__c,Conta__r.ownerId,Conta__r.RecordTypeId,Conta__r.owner.Regional_de_vendas__c,Conta__r.owner.ManagerId, Conta__r.owner.Gerente_regional__c '+
						 ' FROM Visitas__c ' +
						 ' WHERE (Conta__r.RecordTypeId =:rtIdOnTrade OR Conta__r.RecordTypeId =:rtIdOffTrade) AND Data_da_Visita__c != null';
		} else if(batchStep == 4){
			this.query = 'SELECT id,LAT_BR_Client__r.RecordTypeId,LAT_BR_VisitPlanning__r.ownerId,LAT_BR_ActionPlan__c,LAT_BR_Client__r.Owner.ManagerId,LAT_BR_Client__r.Owner.Regional_de_vendas__c,LAT_BR_Client__r.Owner.Gerente_regional__c  ' +
						 ' FROM LAT_BR_CPO_ClientPortfolio__c ' +
						 ' WHERE (LAT_BR_Client__r.RecordTypeId =:rtIdOnTrade OR LAT_BR_Client__r.RecordTypeId =:rtIdOffTrade) ' +
						 ' AND LAT_BR_VisitPlanning__r.M_s_de_Ref_rencia__c =: textMonth AND LAT_BR_VisitPlanning__r.Ano_de_Referencia__c =: textYear';
		}  else if (batchStep == 5) {
		  mapKeyset = this.traficMap.keySet();
			system.debug('upserted on  mapKeyset ---> ' + mapKeyset);
			this.query = 'SELECT Id, LastLoginDate, IsActive FROM User WHERE Id IN :mapKeyset';
		} else if (batchStep == 6) {
			mapKeyset = this.traficMap.keySet();
			system.debug('upserted on  mapKeyset ---> ' + mapKeyset);
			this.query = 'SELECT Id, OwnerId, Account.ownerId,account.RecordTypeId,account.Owner.ManagerId,account.Owner.Regional_de_vendas__c,account.Owner.Gerente_regional__c FROM Contact WHERE (account.RecordTypeId =:rtIdOnTrade OR account.RecordTypeId =:rtIdOffTrade)' +
			' AND Account.Rating <> :stringClienteInactivo';
		}

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if (bStep == 1) {
				this.processActiveAccounts((List<Account>) scope);
		} else if (bStep == 2) {
				this.processCamposPreenchidos((List<Account>) scope);
		} else if(bStep == 3) {
				this.processVisitas((List<Visitas__c>) scope);
		} else if (bStep == 4) {
				this.processPlanejamentos((List<LAT_BR_CPO_ClientPortfolio__c>) scope);
		} else if (bStep == 5) {
				this.processLogins((List<User>) scope);
		} else if (bStep == 6) {
				this.processContatosCadastrados((List<Contact>) scope);
		}
	}

	private void processContatosCadastrados(List<Contact> contaScope){

		List<LAT_BR_TrafficLight__c> toUpsert = new List<LAT_BR_TrafficLight__c>(); //a job for peluca's
		Set<String> addedIds = new Set<String>();

		for (Contact cont: contaScope) {
			LAT_BR_TrafficLight__c tl = this.traficMap.get(cont.account.ownerId);
			String channel = (cont.account.RecordTypeId == this.rtIdOnTrade) ? 'On Trade' : 'Off Trade';

			if (tl != null) {
				if (!this.modifiedToday.contains('activeAccoutns' + tl.ownerId)){
					
					tl = this.updateTrafficLigthFields(tl, String.valueOf(cont.Account.Owner.ManagerId), cont.Account.Owner.Regional_de_vendas__c,String.valueOF(cont.Account.Owner.Gerente_regional__c));
					
					tl.LAT_BR_TL_CountContactos__c = 1;

					this.modifiedToday.add('activeAccoutns' + tl.ownerId);
				}else{
					tl.LAT_BR_TL_CountContactos__c += 1;
				}
			}else{

				tl = initTrafficLightObject(String.valueOf(cont.account.ownerId), false, cont.account.Owner.ManagerId,channel, cont.account.Owner.Regional_de_vendas__c,cont.account.Owner.Gerente_regional__c) ;
				tl.LAT_BR_TL_CountContactos__c = 1;

				this.modifiedToday.add('activeAccoutns' + tl.ownerId);
				this.traficMap.put(tl.OwnerId, tl);
			}
			if (!addedIds.contains(cont.account.ownerId)) {
				toUpsert.add(tl);
				addedIds.add(cont.account.ownerId);
			}
		}
		system.debug('upserted--->' + toUpsert);
		upsert toUpsert;


	}


	private void processLogins(List<User> planLogin){
		List<LAT_BR_TrafficLight__c> toUpsert = new List<LAT_BR_TrafficLight__c>();
		Set<String> addedIds = new Set<String>();

		for (User u: planLogin) {
			LAT_BR_TrafficLight__c tl = this.traficMap.get(u.Id);

			if (tl != null) {
				if (!Test.isRunningTest() && u.lastloginDate != null) {
					if (Math.abs(Date.today().daysBetween(u.LastLoginDate.date())) > 6){
						tl.LAT_BR_TL_PercentLogins__c = 0;
					} else if (Math.abs(Date.today().daysBetween(u.LastLoginDate.date())) > 4) {
							tl.LAT_BR_TL_PercentLogins__c = 75;
					}	else {
							tl.LAT_BR_TL_PercentLogins__c = 100;
					}
					tl.LAT_BR_TL_IsActive__c = u.IsActive;
					toUpsert.add(tl);
				} else {
						tl.LAT_BR_TL_PercentLogins__c = 0;
				}	
			}
		system.debug('upserted on  Login ---> ' + toUpsert);

		upsert toUpsert;
	}
}

	@TestVisible
	private void processPlanejamentos(List<LAT_BR_CPO_ClientPortfolio__c> planScope){
		List<LAT_BR_TrafficLight__c> toUpsert = new List<LAT_BR_TrafficLight__c>();
		Set<String> addedIds = new Set<String>();

		List<String> userIds = new List<String>();
		for (LAT_BR_CPO_ClientPortfolio__c cli: planScope) {
			userIds.add(cli.LAT_BR_VisitPlanning__r.ownerId);
		}
		Map<Id,User> usersMap = new Map<Id,User>([Select id,ManagerId,Gerente_regional__c,Regional_de_vendas__c from User where id in: userIds]);


		for (LAT_BR_CPO_ClientPortfolio__c a: planScope) {
			LAT_BR_TrafficLight__c tl = this.traficMap.get(a.LAT_BR_VisitPlanning__r.ownerId);
			String channel = (a.LAT_BR_Client__r.RecordTypeId == this.rtIdOnTrade) ? 'On Trade' : 'Off Trade';

			if (tl != null) {
				if (!this.modifiedToday.contains('activeAccoutns' + tl.ownerId)){
					User planOwner = usersMap.get(a.LAT_BR_VisitPlanning__r.ownerId);
					tl = this.updateTrafficLigthFields(tl, String.valueOf(planOwner.ManagerId), planOwner.Regional_de_vendas__c,String.valueOF(planOwner.Gerente_regional__c));
					
					tl.LAT_BR_TL_CountPlanejamento__c = 0;
					if(hasPlanAction(a))tl.LAT_BR_TL_CountPlanejamento__c = 1;

					this.modifiedToday.add('activeAccoutns' + tl.ownerId);
				}else{
					if(hasPlanAction(a))tl.LAT_BR_TL_CountPlanejamento__c += 1;
				}
			}else{
				User planOwner = usersMap.get(a.LAT_BR_VisitPlanning__r.ownerId);

				tl = initTrafficLightObject(String.valueOf(a.LAT_BR_VisitPlanning__r.ownerId), false,String.valueOf(planOwner.ManagerId),channel, planOwner.Regional_de_vendas__c,String.valueOF(planOwner.Gerente_regional__c)) ;
				if(hasPlanAction(a))tl.LAT_BR_TL_CountPlanejamento__c = 1;

				this.modifiedToday.add('activeAccoutns' + tl.ownerId);
				this.traficMap.put(tl.OwnerId, tl);
			}
			if (!addedIds.contains(a.LAT_BR_VisitPlanning__r.ownerId)) {
				toUpsert.add(tl);
				addedIds.add(a.LAT_BR_VisitPlanning__r.ownerId);
			}
		}
		upsert toUpsert;
		system.debug('upserted--->' + toUpsert);

	}

	@TestVisible
	private void processVisitas(List<Visitas__c> accScope) {
		List<LAT_BR_TrafficLight__c> toUpsert = new List<LAT_BR_TrafficLight__c>();
		Set<String> addedIds = new Set<String>();

		List<String> userIds = new List<String>();
		for (Visitas__c vis: accScope) {
			userIds.add(vis.Planejamento__r.ownerId);
		}

		Map<Id,User> usersMap = new Map<Id,User>([Select id,ManagerId,Gerente_regional__c,Regional_de_vendas__c from User where id in: userIds]);

		for (Visitas__c a: accScope) {
			LAT_BR_TrafficLight__c tl = this.traficMap.get(a.Planejamento__r.ownerId);
			String channel = (a.Conta__r.RecordTypeId == this.rtIdOnTrade) ? 'On Trade' : 'Off Trade';
			system.debug('ernesto++' + a);
			if (tl != null) {
				if (!this.modifiedToday.contains('activeAccoutns' + tl.ownerId)){
					User planOwner = usersMap.get(a.Planejamento__r.ownerId);
					tl = this.updateTrafficLigthFields(tl, planOwner.ManagerId, planOwner.Regional_de_vendas__c,planOwner.Gerente_regional__c);
					tl.LAT_BR_TL_CountVisitasEncerradas__c = 0;
					tl.LAT_BR_TL_CountVisitasNRealizada__c = 0;
					tl.LAT_BR_TL_CountVisitasTRealizada__c = 0;
					tl.LAT_BR_TL_CountVisitasPRealizada__c = 0;
					tl.LAT_BR_TL_CountVisitasAcordo__c = 0;
					tl.LAT_BR_TL_CountVisitasAtt__c = 0;
					tl.LAT_BR_TL_CountVisitasMes__c = 0;

					tl.LAT_BR_TL_CountVisitas__c = 1;
					system.debug('Ernesto+++++Visitadata + ' + a.Data_da_Visita__c +thisMonth(a.Data_da_Visita__c) );
					if(thisMonth(a.Data_da_Visita__c)){
						if(encerrada(a))tl.LAT_BR_TL_CountVisitasEncerradas__c = 1;
						if(a.Visita_n_o_realizada__c)tl.LAT_BR_TL_CountVisitasNRealizada__c = 1;
						if(totallyAchieved(a))tl.LAT_BR_TL_CountVisitasTRealizada__c = 1;
						if(partiallyAchieved(a))tl.LAT_BR_TL_CountVisitasPRealizada__c = 1;
						if(customerAgreed(a))tl.LAT_BR_TL_CountVisitasAcordo__c = 1;
						if(hasAttachment(a))tl.LAT_BR_TL_CountVisitasAtt__c = 1;
						tl.LAT_BR_TL_CountVisitasMes__c = 1;
					}

					this.modifiedToday.add('activeAccoutns' + tl.ownerId);
				}else{
					tl.LAT_BR_TL_CountVisitas__c += 1;
					system.debug('Ernesto+++++Visitadata + ' + a.Data_da_Visita__c +thisMonth(a.Data_da_Visita__c) );
					if(thisMonth(a.Data_da_Visita__c)){
						if(encerrada(a))tl.LAT_BR_TL_CountVisitasEncerradas__c += 1;
						if(a.Visita_n_o_realizada__c)tl.LAT_BR_TL_CountVisitasNRealizada__c += 1;
						if(totallyAchieved(a))tl.LAT_BR_TL_CountVisitasTRealizada__c += 1;
						if(partiallyAchieved(a))tl.LAT_BR_TL_CountVisitasPRealizada__c += 1;
						if(customerAgreed(a))tl.LAT_BR_TL_CountVisitasAcordo__c += 1;
						if(hasAttachment(a))tl.LAT_BR_TL_CountVisitasAtt__c += 1;
						tl.LAT_BR_TL_CountVisitasMes__c +=1;
					}
				}

			}else {
				// If no traffic light object is created then we need to create a new one

				User planOwner = usersMap.get(a.Planejamento__r.ownerId);
				tl = initTrafficLightObject(a.Planejamento__r.ownerId, false,planOwner.ManagerId,channel, planOwner.Regional_de_vendas__c,planOwner.Gerente_regional__c) ;
				tl.LAT_BR_TL_CountVisitas__c = 1;
				system.debug('Ernesto+++++Visitadata + ' + a.Data_da_Visita__c +thisMonth(a.Data_da_Visita__c) );
				if(thisMonth(a.Data_da_Visita__c)){
					if(encerrada(a))tl.LAT_BR_TL_CountVisitasEncerradas__c = 1;
					if(a.Visita_n_o_realizada__c)tl.LAT_BR_TL_CountVisitasNRealizada__c = 1;
					if(totallyAchieved(a))tl.LAT_BR_TL_CountVisitasTRealizada__c = 1;
					if(partiallyAchieved(a))tl.LAT_BR_TL_CountVisitasPRealizada__c = 1;
					if(customerAgreed(a))tl.LAT_BR_TL_CountVisitasAcordo__c = 1;
					if(hasAttachment(a))tl.LAT_BR_TL_CountVisitasAtt__c = 1;
					tl.LAT_BR_TL_CountVisitasMes__c = 1;
				}
				this.traficMap.put(tl.OwnerId, tl);
				this.modifiedToday.add('activeAccoutns' + tl.ownerId);
			}

			if (!addedIds.contains(a.Planejamento__r.ownerId)) {
				toUpsert.add(tl);
				addedIds.add(a.Planejamento__r.ownerId);
			}
		}
		system.debug('upserted--->' + toUpsert);
		DataBase.upsert(toUpsert,false);


	}
	
    @testVisible
	private boolean hasPlanAction(LAT_BR_CPO_ClientPortfolio__c plan){
        Boolean retorno = plan.LAT_BR_ActionPlan__c != '' && plan.LAT_BR_ActionPlan__c != null;
		return retorno;
	}

	private Boolean thisMonth(Date d){
		return this.Year == d.year() && this.Month == d.month();
	}

	@testVisible
	private boolean encerrada(Visitas__c visita){
        Boolean retorno;
        String expected = 'Encerrada';
        retorno = visita.Status__c == expected;
		return retorno;
	}
	
    @testVisible
	private Boolean totallyAchieved(Visitas__c visita){
        String expected = 'Yes';
        Boolean retorno =  visita.LAT_MX_GoalAchieved__c == expected;
		return retorno;
	}
	
    @testVisible
	private Boolean partiallyAchieved(Visitas__c visita){
        String expected = 'Partially';
        Boolean retorno = visita.LAT_MX_GoalAchieved__c == expected;
		return retorno;
	}
	
    @testVisible
	private Boolean customerAgreed(Visitas__c visita){
        Boolean retorno = visita.LAT_BR_CustomerAgreed__c;
		return retorno;
	}
	
    @testVisible
	private Boolean hasAttachment(Visitas__c visita){
        Boolean retorno = visita.LAT_BR_HasAttachment__c;
		return retorno;
	}

	private void processCamposPreenchidos(List<Account> accScope) {
		List<LAT_BR_TrafficLight__c> toUpsert = new List<LAT_BR_TrafficLight__c>();
		Set<String> addedIds = new Set<String>();
		for (Account a: accScope) {

			if (a.Rating != 'Cliente Inativo' && (a.Status__c == 'Cliente cadastrado no CRM' || a.Status__c == 'Cliente cadastrado no JDE')) {
				//Boolean estadoCorrecto = (a.status__c == 'Em aprovação  - Comercial' || a.status__c == 'Em aprovação - Financeiro' || a.status__c == 'Em análise - Customer Service' || a.status__c == 'Em análise - Crédito e Cobrança' || a.status__c == 'Não Aprovado' || a.status__c == 'Novo Cadastro');
				String channel = (a.RecordTypeId == this.rtIdOnTrade) ? 'On Trade' : 'Off Trade';
				Boolean vacations = this.vacationsMap.get(a.OwnerId) != null ? true : false;
				//Boolean status = (a.status__c == 'cliente cadastrado no crm'  ? false : (a.Reason_for_Inactivation__c == null ? !estadoCorrecto : false));
				
				LAT_BR_TrafficLight__c tl = this.traficMap.get(a.OwnerId);
				if (tl != null) {
					if (!this.modifiedToday.contains('activeAccoutns' + tl.OwnerId)){
						tl.LAT_BR_TL_TotalCampos__c = 0;
						tl.LAT_BR_TL_CamposPreenchidos__c = 0;
						this.modifiedToday.add('activeAccoutns' + tl.OwnerId);
					}

					//system.debug('44444 ' + status);
					/*for(LAT_BR_TL_CamposPreenchidos__c cam : campos){
						tl.LAT_BR_TL_TotalCampos__c += 1;
						//if(status){
							if(validateValue(cam,a) || getConditions(cam,a)){
								tl.LAT_BR_TL_CamposPreenchidos__c += 1;
							}
						//}
					}*/

					for(LAT_BR_TL_CamposPreenchidos__c cam : campos){
						if (getConditions(cam,a)) {
							tl.LAT_BR_TL_TotalCampos__c += 1;
							if(validateValue(cam,a)){
								tl.LAT_BR_TL_CamposPreenchidos__c += 1;
							}
						}
					}
				}else {
					// If no traffic light object is created then we need to create a new one
					tl = initTrafficLightObject(a.OwnerId, vacations, a.Owner.ManagerId,channel, a.Owner.Regional_de_vendas__c,a.Owner.Gerente_regional__c);

					/*for(LAT_BR_TL_CamposPreenchidos__c cam : campos){
						tl.LAT_BR_TL_TotalCampos__c += 1;
						//if(status){
							if(validateValue(cam,a) || getConditions(cam,a)){
								tl.LAT_BR_TL_CamposPreenchidos__c += 1;
							}
						//}
					}*/
					for(LAT_BR_TL_CamposPreenchidos__c cam : campos){
						if (getConditions(cam,a)) {
							tl.LAT_BR_TL_TotalCampos__c += 1;
							if(validateValue(cam,a)){
								tl.LAT_BR_TL_CamposPreenchidos__c += 1;
							}
						}
					}
					this.traficMap.put(tl.OwnerId, tl);
					this.modifiedToday.add('activeAccoutns' + tl.OwnerId);
				}

				if (!addedIds.contains(a.OwnerId)) {
					toUpsert.add(tl);
					addedIds.add(a.OwnerId);
				}
			}
		}
		upsert toUpsert;
		system.debug('upserted--->' + toUpsert);

	}

	private boolean validateValue(LAT_BR_TL_CamposPreenchidos__c campo, Account acc){
		if(campo.LAT_BR_Type__c == 'Number')return (Decimal)acc.get(campo.LAT_BR_Field__c) > 0;
		if(campo.LAT_BR_Type__c == 'Text')return acc.get(campo.LAT_BR_Field__c) != '' && acc.get(campo.LAT_BR_Field__c) != null;
		if(campo.LAT_BR_Type__c == 'Boolean')return (Boolean)acc.get(campo.LAT_BR_Field__c);
		return false;
	}


	private boolean getConditions(LAT_BR_TL_CamposPreenchidos__c tl, Account acc){
		if(tl.LAT_BR_Conditions__c == null || tl.LAT_BR_Conditions__c == '')return true;
		for(String str : tl.LAT_BR_Conditions__c.split(',', 0)){
			List<String> fieldValue = str.split(':',0);
			if(fieldValue.size() == 2){
				String field = str.split(':',0)[0];
				String value = str.split(':',0)[1];
				if(acc.get(field) == value)return true;
			}
		}
		return false;
	}


	private void processActiveAccounts(List<Account> accScope) {
		List<LAT_BR_TrafficLight__c> toUpsert = new List<LAT_BR_TrafficLight__c>();
		Set<String> addedIds = new Set<String>();
		for (Account a: accScope) {
			// Active accounts KPI
			if (a.Rating != 'Cliente Inativo') {
				// Check if there is a traffic light object created for the accountOwner
				String channel = (a.RecordTypeId == this.rtIdOnTrade) ? 'On Trade' : 'Off Trade';
				Boolean vacations = this.vacationsMap.get(a.OwnerId) != null ? true : false;


				LAT_BR_TrafficLight__c tl = this.traficMap.get(a.OwnerId);
				if (tl != null) {
					// Checks was already modified today for this KPI, if it was then we just nead
					// to add 1 to the KPI field, otherwise we need to reset the count to 1

					tl.LAT_BR_TL_VacationsMonth__c = vacations;
					tl.LAT_BR_TL_FilterDate__c = Date.newInstance(this.Year, this.Month, 1);
					//tl.LAT_BR_TL_Channel__c = channel;
					tl.LAT_BR_TL_Region__c = a.Owner.Regional_de_vendas__c;
					system.debug('aaaaa ' + modifiedToday);
					system.debug('abbbbb '+ tl.OwnerId);
					if (this.modifiedToday.contains('activeAccoutns' + tl.OwnerId)) {
						tl.LAT_BR_TL_CountActiveClients__c = tl.LAT_BR_TL_CountActiveClients__c + 1;
					} else {
						tl.LAT_BR_TL_CountActiveClients__c = 1;
						this.modifiedToday.add('activeAccoutns' + tl.OwnerId);
					}
				} else {
					// If no traffic light object is created then we need to create a new one
					tl = initTrafficLightObject(a.OwnerId, vacations, a.Owner.ManagerId,channel, a.Owner.Regional_de_vendas__c,a.Owner.Gerente_regional__c);

					tl.LAT_BR_TL_CountActiveClients__c = 1;
					this.traficMap.put(tl.OwnerId, tl);
					this.modifiedToday.add('activeAccoutns' + tl.OwnerId);
				}

				if (!addedIds.contains(a.OwnerId)) {
					toUpsert.add(tl);
					addedIds.add(a.OwnerId);
				}
			}
		}
		upsert toUpsert;
		system.debug('upserted--->' + toUpsert);
	}

	private LAT_BR_TrafficLight__c updateTrafficLigthFields (LAT_BR_TrafficLight__c tl, String ManagerId, String RegionalId, String gerenteRegional) {
		if ((this.Month == null && this.Year == null) 
			|| (this.Month == Date.today().month() && this.Year == Date.today().year())) {
			tl.LAT_BR_TL_IsActive__c = tl.Owner.IsActive;
			tl.LAT_BR_TL_RegionalManager__c = gerenteRegional;
			tl.LAT_BR_TL_AreaManager__c = ManagerId;
			tl.LAT_BR_TL_Region__c = RegionalId;
		}
		return tl;
	}


	public LAT_BR_TrafficLight__c initTrafficLightObject(String OwnerId, Boolean vacations, String ManagerId, String Channel, String RegionalId, String gerenteRegional){
		LAT_BR_TrafficLight__c tl = new LAT_BR_TrafficLight__c();
		tl.OwnerId = OwnerId;
		tl.LAT_BR_TL_VacationsMonth__c = vacations;
		tl.LAT_BR_TL_AreaManager__c = ManagerId;
		tl.LAT_BR_TL_Channel__c = channel;
		tl.LAT_BR_TL_Month__c = String.valueOf(this.Month);
		tl.LAT_BR_TL_Year__c = this.Year;
		tl.LAT_BR_TL_Region__c = RegionalId;
		tl.LAT_BR_TL_RegionalManager__c = gerenteRegional;
		tl.LAT_BR_TL_SalesExecutive__c = OwnerId;
		tl.LAT_BR_TL_ModifiedDate__c = Date.today();
		tl.LAT_BR_TL_CountActiveClients__c = 0;
		tl.LAT_BR_TL_TotalCampos__c = 0;
		tl.LAT_BR_TL_CamposPreenchidos__c = 0;
		tl.LAT_BR_TL_CountVisitasEncerradas__c = 0;
		tl.LAT_BR_TL_CountVisitasNRealizada__c = 0;
		tl.LAT_BR_TL_CountVisitas__c = 0;
		tl.LAT_BR_TL_CountVisitasTRealizada__c = 0;
		tl.LAT_BR_TL_CountVisitasPRealizada__c = 0;
		tl.LAT_BR_TL_CountVisitasAcordo__c = 0;
		tl.LAT_BR_TL_CountVisitasAtt__c = 0;
		tl.LAT_BR_TL_CountVisitasMes__c = 0;
		tl.LAT_BR_TL_CountPlanejamento__c = 0;
		tl.LAT_BR_TL_FilterDate__c = Date.newInstance(this.Year, this.Month, 1);
		return tl;
	}

	// Used to get the Traffic Light objects. This objects are used to store KPI information
	// per Executive
	private Map<String, LAT_BR_TrafficLight__c> getTraficLightObjects(String Month, Integer Year) {
		List<LAT_BR_TrafficLight__c> tlList = [SELECT id,LAT_BR_TL_CountVisitasAtt__c,LAT_BR_TL_CountVisitasAcordo__c,LAT_BR_TL_CountVisitasPRealizada__c,LAT_BR_TL_CountVisitasTRealizada__c,LAT_BR_TL_CountVisitasNRealizada__c,LAT_BR_TL_CountVisitas__c,LAT_BR_TL_CountVisitasEncerradas__c,LAT_BR_TL_CountVisitasMes__c, LAT_BR_TL_TotalCampos__c,LAT_BR_TL_CamposPreenchidos__c, LAT_BR_TL_AreaManager__c, LAT_BR_TL_CountActiveClients__c,
														LAT_BR_TL_Month__c, LAT_BR_TL_Region__c, LAT_BR_TL_RegionalManager__c,
														LAT_BR_TL_SalesExecutive__c, LAT_BR_TL_Year__c, LAT_BR_TL_ModifiedDate__c,
														OwnerId, LAT_BR_TL_VacationsMonth__c, LAT_BR_TL_Channel__c, LAT_BR_TL_FilterDate__c, LAT_BR_TL_IsActive__c, Owner.IsActive
												FROM LAT_BR_TrafficLight__c
												WHERE LAT_BR_TL_Month__c =: Month AND LAT_BR_TL_Year__c =: Year];

		Map<String, LAT_BR_TrafficLight__c> mapUserTraficLight = new Map<String, LAT_BR_TrafficLight__c>();
		for (LAT_BR_TrafficLight__c tl: tlList) {
			mapUserTraficLight.put(tl.OwnerId, tl);
		}

		return mapUserTraficLight;
	}

	// Gets vacations records to be use to determine if the executive have been on vacations
	// on the current month
	private Map<String, LAT_BR_Vacations__c> getVacations(String Month, Integer Year) {
		List<LAT_BR_Vacations__c> vList = [SELECT id, LAT_BR_VAC_Executive__c, LAT_BR_VC_Year__c, LAT_BR_VC_Month__c
												FROM LAT_BR_Vacations__c
												WHERE LAT_BR_VC_Month__c =:Month AND LAT_BR_VC_Year__c =: Year];

		Map<String, LAT_BR_Vacations__c> mapUserVacations = new Map<String, LAT_BR_Vacations__c>();
		for (LAT_BR_Vacations__c v: vList) {
			mapUserVacations.put(v.LAT_BR_VAC_Executive__c, v);
		}

		return mapUserVacations;
	}

	global void finish(Database.BatchableContext BC) {
		if (this.bStep < this.eStep) {
			this.bStep = this.bStep + 1;
			LAT_BR_TraficLightBatch tlb = new LAT_BR_TraficLightBatch(this.bStep, this.eStep, Integer.valueOf(this.Month), this.Year);
			Database.executeBatch(tlb, 100);
		}
	}

}