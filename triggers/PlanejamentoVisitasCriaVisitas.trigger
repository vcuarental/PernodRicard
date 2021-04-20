/*******************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Automatiza a criação de visitas mediante a criação de um planejamento Mensal 
* e a periodicidade cadatrada em cada cliente(conta).
*
* NAME: PlanejamentoVisitasCriaVisitas.trigger
* AUTHOR: CARLOS CARVALHO                          DATE: 06/05/2012 
*
* MAINTENANCE
* AUTHOR: ROGERIO ALVARENGA                        DATE: 09/05/2012
* DESC: ALTERADA ESTRUTURA E REGRAS DE NEGÓCIO DO CÓDIGO.
*
* AUTHOR: MARCOS DOBROWOLSKI                       DATE: 26/12/2012
* DESC: Alterado para Before Insert. Alteração de inclusão do Gerente 
* Regional da conta pai no KAM_01...KAM_10.
*
* AUTHOR: CARLOS CARVALHO                          DATE: 08/01/2013
* DESC: INSERIDO FUNCIONALIDADE QUE VALIDA O ID DO TIPO DE REGISTRO DOS OBJETOS.
*
* AUTHOR: CARLOS CARVALHO                          DATE: 21/01/2013
* DESC: INSERIDO TRIGGER ON.
*
* AUTHOR: MARCOS DOBROWOLSKI                       DATE: 13/03/2013
* DESC: EF: Especificacao_Funcional__Pernod_hierarquias_ANEXO1_V2.pdf
*       - Inclusão do SubCanal 'Varejo Regional'
*       - Exclusão da mensagem de erro quando excendente o 10º KAM
*
* AUTHOR: MARCOS DOBROWOLSKI                       DATE: 21/03/2013
* DESC: Removida atribuição de KAM. Funcionalidade a cargo da trigger 
*       PlanejamentoAtribuiKAM
*
* AUTHOR: WALDEMAR MAYO                            DATE: 08/10/2013
* DESC: Se agrego la creacion de visitas con dia y horario para BR 
********************************************************************************/

trigger PlanejamentoVisitasCriaVisitas on Planejamento__c (after insert) {
    
    //FILTRO DE RECORDTYPES LATAM
    List<Planejamento__c> LAT_triggerNew = new List<Planejamento__c>();
    set<Id> recordTypesPlanejamento = Global_RecordTypeCache.getRtIdSet('Planejamento__c', new set<String>{'BRA_Standard', 'PLV_Standard_AR', 'PLV_Standard_UY'});
    
    for(Planejamento__c plan : trigger.new){
    	if(recordTypesPlanejamento.contains(plan.RecordTypeId)){
    		LAT_triggerNew.add(plan);
    	}
    }
    
    //Check if this trigger is bypassed by SESAME (data migration Brazil)
    if( (!LAT_triggerNew.isEmpty()) && UserInfo.getProfileId()!='00eM0000000QNYPIA4' && UserInfo.getProfileId()!= '00eD0000001AnFlIAK'){
        
        Map<String, Date> monthYearFirstMonday = new Map<String, Date>();
        Map<String, String> mapIdRTPlanIdRTVisita = new Map<String, String>();
        Map<String, Id> mapVisit = new Map<String, Id>();
        Map<String, Id> mapPlan = new Map<String, Id>();
        List<String> listPlanOwnerIds = new List<String>();
        Date startOfWeek = Date.today();
        
        //Guardo la relacion de RTs correspondientes entre Planeamientos y visitas
        mapIdRTPlanIdRTVisita.put(Global_RecordTypeCache.getRtId('Planejamento__c'+'BRA_Standard'),    Global_RecordTypeCache.getRtId('Visitas__c'+'BRA_Standard'));
        mapIdRTPlanIdRTVisita.put(Global_RecordTypeCache.getRtId('Planejamento__c'+'PLV_Standard_AR'), Global_RecordTypeCache.getRtId('Visitas__c'+'VTS_Standard_AR'));
        mapIdRTPlanIdRTVisita.put(Global_RecordTypeCache.getRtId('Planejamento__c'+'PLV_Standard_UY'), Global_RecordTypeCache.getRtId('Visitas__c'+'VTS_Standard_UY'));
        
        for(Planejamento__c plan : LAT_triggerNew){
            //Guardo en el primer dia del mes para cada Ano/Mes
            monthYearFirstMonday.put((plan.M_s_de_Ref_rencia__c+'-'+plan.Ano_de_Referencia__c), Date.newInstance(Integer.valueOf(plan.Ano_de_Referencia__c), PlanejamentoVisitasCriaVisitasAux.getMonth(plan.M_s_de_Ref_rencia__c), 1));
            listPlanOwnerIds.add(plan.OwnerId);
        }
        
        if(listPlanOwnerIds.isEmpty()){
        	return;
        }
        
        //Recupera todas as contas que possuem proprietarios que estão dentro da lista de proprietarios dos planejamentos.
        //Filtrar se a conta é desse planejamento
        Map<Id, list<Account>> mapOwnerAccount = new Map<Id, list<Account>>();
        Set<id> setIdAccounts = new Set<id>();

        for(Account acc: AccountDAO.getInstance().getListAccountByIdsOwners(listPlanOwnerIds)){
            if(mapOwnerAccount.containsKey(acc.OwnerId)){
                mapOwnerAccount.get(acc.OwnerId).add(acc);
            }else{
                mapOwnerAccount.put(acc.OwnerId, new list<Account>{acc});
            }
            setIdAccounts.add(acc.Id);
        }
        
        if(mapOwnerAccount.isEmpty()){
        	return;
        }
        

        //Actualizo el mapa para encontrar el primer Lunes del Mes
        for(String myfd : monthYearFirstMonday.keySet()){
            for(Integer i=1; i<8; i++){
                //Si es lunes se guarda la fecha
                startOfWeek = PlanejamentoVisitasCriaVisitasAux.getStartOfWeek(monthYearFirstMonday.get(myfd));
                if(startOfWeek.daysBetween(monthYearFirstMonday.get(myfd)) == 0){
                    break;
                }else{
                    monthYearFirstMonday.put(myfd, monthYearFirstMonday.get(myfd).addDays(1));
                }
            }
        }
        
        //Cargo los 2 primeros Dia/Horario de la frecuencia del Cliente
        Map<String, Integer> mapIdAccFirstAndSecAvailableDay = new Map<String, Integer>();
        Map<String, String> mapIdAccFirstAndSecAvailableTime = new Map<String, String>();
        Map<Id, LAT_CWH_ClientWorkHour__c> ConectionAccToCWH = new Map<Id, LAT_CWH_ClientWorkHour__c>();

        for(LAT_CWH_ClientWorkHour__c CWH: [SELECT id, Account__c, Name, Friday__c, Monday__c, Saturday__c, Sunday__c, Thursday__c, Tuesday__c, Wednesday__c, Friday_1st_period_begin_Time__c, Monday_1st_period_begin_Time__c, Saturday_1st_period_begin_Time__c, Sunday_1st_period_begin_Time__c, Thursday_1st_period_begin_Time__c, Tuesday_1st_period_begin_Time__c, Wednesday_1st_period_begin_Time__c, Friday_2nd_period_begin_Time__c, Monday_2nd_period_begin_Time__c, Saturday_2nd_period_begin_Time__c, Sunday_2nd_period_begin_Time__c, Thursday_2nd_period_begin_Time__c, Tuesday_2nd_period_begin_Time__c, Wednesday_2nd_period_begin_Time__c FROM LAT_CWH_ClientWorkHour__c WHERE Account__c IN: setIdAccounts] ){
            ConectionAccToCWH.put(CWH.Account__c, CWH);
        }
        for(String idOwner: mapOwnerAccount.keySet()){
            for(Account acc: mapOwnerAccount.get(idOwner)){
                
                Integer primerDia = null;
                Integer segundoDia = null;
                String primerHorario = null;
                String segundoHorario = null;
                
                if(ConectionAccToCWH.containsKey(acc.Id)){
                    
                    //Se busca dia x dia para agregar los 2 primeros
                    if(ConectionAccToCWH.get(acc.Id).Monday__c==true && (ConectionAccToCWH.get(acc.Id).Monday_1st_period_begin_Time__c!=null || ConectionAccToCWH.get(acc.Id).Monday_2nd_period_begin_Time__c!=null)){
                        primerDia = 0;
                        if(ConectionAccToCWH.get(acc.Id).Monday_1st_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Monday_1st_period_begin_Time__c;}else
                        if(ConectionAccToCWH.get(acc.Id).Monday_2nd_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Monday_2nd_period_begin_Time__c;}
                    }
                    if(ConectionAccToCWH.get(acc.Id).Tuesday__c==true && (ConectionAccToCWH.get(acc.Id).Tuesday_1st_period_begin_Time__c!=null || ConectionAccToCWH.get(acc.Id).Tuesday_2nd_period_begin_Time__c!=null)){
                        if(primerDia==null){
                            primerDia = 1;
                            if(ConectionAccToCWH.get(acc.Id).Tuesday_1st_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Tuesday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Tuesday_2nd_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Tuesday_2nd_period_begin_Time__c;}
                        }else if(segundoDia==null){
                            segundoDia = 1;
                            if(ConectionAccToCWH.get(acc.Id).Tuesday_1st_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Tuesday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Tuesday_2nd_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Tuesday_2nd_period_begin_Time__c;}
                        }
                    }
                    if(ConectionAccToCWH.get(acc.Id).Wednesday__c==true && (ConectionAccToCWH.get(acc.Id).Wednesday_1st_period_begin_Time__c!=null || ConectionAccToCWH.get(acc.Id).Wednesday_2nd_period_begin_Time__c!=null)){
                        if(primerDia==null){
                            primerDia = 2;
                            if(ConectionAccToCWH.get(acc.Id).Wednesday_1st_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Wednesday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Wednesday_2nd_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Wednesday_2nd_period_begin_Time__c;}
                        }else if(segundoDia==null){
                            segundoDia = 2;
                            if(ConectionAccToCWH.get(acc.Id).Wednesday_1st_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Wednesday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Wednesday_2nd_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Wednesday_2nd_period_begin_Time__c;}
                        }
                    }
                    if(ConectionAccToCWH.get(acc.Id).Thursday__c==true && (ConectionAccToCWH.get(acc.Id).Thursday_1st_period_begin_Time__c!=null || ConectionAccToCWH.get(acc.Id).Thursday_2nd_period_begin_Time__c!=null)){
                        if(primerDia==null){
                            primerDia = 3;
                            if(ConectionAccToCWH.get(acc.Id).Thursday_1st_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Thursday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Thursday_2nd_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Thursday_2nd_period_begin_Time__c;}
                        }else if(segundoDia==null){
                            segundoDia = 3;
                            if(ConectionAccToCWH.get(acc.Id).Thursday_1st_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Thursday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Thursday_2nd_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Thursday_2nd_period_begin_Time__c;}
                        }
                    }
                    if(ConectionAccToCWH.get(acc.Id).Friday__c==true && (ConectionAccToCWH.get(acc.Id).Friday_1st_period_begin_Time__c!=null || ConectionAccToCWH.get(acc.Id).Friday_2nd_period_begin_Time__c!=null)){
                        if(primerDia==null){
                            primerDia = 4;
                            if(ConectionAccToCWH.get(acc.Id).Friday_1st_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Friday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Friday_2nd_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Friday_2nd_period_begin_Time__c;}
                        }else if(segundoDia==null){
                            segundoDia = 4;
                            if(ConectionAccToCWH.get(acc.Id).Friday_1st_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Friday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Friday_2nd_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Friday_2nd_period_begin_Time__c;}
                        }
                    }
                    if(ConectionAccToCWH.get(acc.Id).Saturday__c==true && (ConectionAccToCWH.get(acc.Id).Saturday_1st_period_begin_Time__c!=null || ConectionAccToCWH.get(acc.Id).Saturday_2nd_period_begin_Time__c!=null)){
                        if(primerDia==null){
                            primerDia = 5;
                            if(ConectionAccToCWH.get(acc.Id).Saturday_1st_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Saturday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Saturday_2nd_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Saturday_2nd_period_begin_Time__c;}
                        }else if(segundoDia==null){
                            segundoDia = 5;
                            if(ConectionAccToCWH.get(acc.Id).Saturday_1st_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Saturday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Saturday_2nd_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Saturday_2nd_period_begin_Time__c;}
                        }
                    }
                    if(ConectionAccToCWH.get(acc.Id).Sunday__c==true && (ConectionAccToCWH.get(acc.Id).Sunday_1st_period_begin_Time__c!=null || ConectionAccToCWH.get(acc.Id).Sunday_2nd_period_begin_Time__c!=null)){
                        if(primerDia==null){
                            primerDia = 6;
                            if(ConectionAccToCWH.get(acc.Id).Sunday_1st_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Sunday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Sunday_2nd_period_begin_Time__c!=null){primerHorario = ConectionAccToCWH.get(acc.Id).Sunday_2nd_period_begin_Time__c;}
                        }else if(segundoDia==null){
                            segundoDia = 6;
                            if(ConectionAccToCWH.get(acc.Id).Sunday_1st_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Sunday_1st_period_begin_Time__c;}else
                            if(ConectionAccToCWH.get(acc.Id).Sunday_2nd_period_begin_Time__c!=null){segundoHorario = ConectionAccToCWH.get(acc.Id).Sunday_2nd_period_begin_Time__c;}
                        }
                    }
                }
                
                //Guardo los 2 primeros dias habilitados. Si no tiene 2do dia se guarda null
                if(primerDia != null){
                    mapIdAccFirstAndSecAvailableDay.put(acc.Id+'1', primerDia);
                    mapIdAccFirstAndSecAvailableTime.put(acc.Id+'1', primerHorario);
                    mapIdAccFirstAndSecAvailableDay.put(acc.Id+'2', segundoDia);
                    mapIdAccFirstAndSecAvailableTime.put(acc.Id+'2', segundoHorario);
                }
            }
        }
        
        //Creacion de visitas
        List<Visitas__c> lVisitaList = new List<Visitas__c>();
        for(Planejamento__c plan : LAT_triggerNew){
            
            //Se recorren todos los account del owner del planejamento y por cada uno se crean un conjunto de visitas
            for(Account lAcc: mapOwnerAccount.get(plan.OwnerId)){
                Integer lMonth = PlanejamentoVisitasCriaVisitasAux.getMonth(plan.M_s_de_Ref_rencia__c);
                Integer lNumVisitas = PlanejamentoVisitasCriaVisitasAux.getPeriodicity(lAcc.Frequency_of_Visits__c, integer.ValueOf(plan.Ano_de_Referencia__c), lMonth);
                
                Map<String, Date> mapIdAccFirstAndSecDate = new Map<String, Date>();
                Date firstDayOnMonth = date.newInstance(integer.valueOf(plan.Ano_de_Referencia__c), lMonth, 1);
                Date firstMon = monthYearFirstMonday.get(plan.M_s_de_Ref_rencia__c+'-'+plan.Ano_de_Referencia__c);

                system.debug('firstMon---->' + firstMon);
                
                system.debug('TOKEN lAcc.Name: '+lAcc.Name);
                system.debug('TOKEN lAcc.Frequency_of_Visits__c: '+lAcc.Frequency_of_Visits__c);
                system.debug('TOKEN withHours: '+mapIdAccFirstAndSecAvailableDay.containsKey(lAcc.Id+'1'));
                
                //Se crean las visitas segun la cantidad correspondiente a la frecuencia del cliente
                for(Integer i=0; i<=lNumVisitas-1; i++ ){
                    
                    Visitas__c vis = new Visitas__c();
                    String nome = 'Planejamento de visitas - '+ lAcc.Name;
                    vis.Name = nome.length()>80?nome.substring(0,79):nome;
                    vis.Planejamento__c = plan.Id;
                    vis.Conta__c = lAcc.Id;
                    vis.RecordTypeId = mapIdRTPlanIdRTVisita.get(plan.RecordTypeId);
                    vis.Trigger_on__c = true;
                    
                    //Configurar el Dia/Horario
                    //Si las visitas son diarias se crean una para cada dia menos los sab y dom
                    if(lAcc.Frequency_of_Visits__c == 'Diária'){
                        vis.Hora_da_Visita__c = '08:00';
                        Date finalDate = firstDayOnMonth.addDays(i);
                        startOfWeek = PlanejamentoVisitasCriaVisitasAux.getStartOfWeek(finalDate);

                        if((startOfWeek.daysBetween(finalDate) != 6) && (startOfWeek.daysBetween(finalDate) != 7)){
                            system.debug('--------->' + startOfWeek.daysBetween(finalDate));
                            vis.Data_da_Visita__c = finalDate;
                        }else{
                            //Si es sab o dom se deja nula para que no se inserte
                            vis = null;
                            lNumVisitas++;
                        }
                    }else{
                        if(!mapIdAccFirstAndSecAvailableDay.containsKey(lAcc.Id+'1')){
                            //Codigo para cuentas sin horarios
                            if(lAcc.Frequency_of_Visits__c == '2 x Semana'){
                                integer semC = i;
                                if(math.mod(i,2)!=0 && i!=0){semC--;}
                                vis.Data_da_Visita__c = firstMon.addDays((semC/2)*7);
                                vis.Hora_da_Visita__c = '08:00';
                            }else if(lAcc.Frequency_of_Visits__c == 'Semanal'){
                                vis.Data_da_Visita__c = firstMon.addDays(i*7);
                                vis.Hora_da_Visita__c = '08:00';
                            }else if(lAcc.Frequency_of_Visits__c == 'Quinzenal'){
                                vis.Data_da_Visita__c = firstMon.addDays(i*14);
                                vis.Hora_da_Visita__c = '08:00';
                            }else if(lAcc.Frequency_of_Visits__c == 'Mensal' || lAcc.Frequency_of_Visits__c == 'Seasonal'){
                                vis.Data_da_Visita__c = firstMon;
                                vis.Hora_da_Visita__c = '08:00';
                            }
                        }else{
                            //Codigo para cuentas con horarios
                            
                            //Cargo la primer fecha habilitada para el cliente y el planeamiento
                            mapIdAccFirstAndSecDate.put(lAcc.Id+'1', Date.newInstance(Integer.ValueOf(plan.Ano_de_Referencia__c), lMonth, 1));
                            if(PlanejamentoVisitasCriaVisitasAux.getStartOfWeek(mapIdAccFirstAndSecDate.get(lAcc.Id+'1')).daysBetween(mapIdAccFirstAndSecDate.get(lAcc.Id+'1')) != mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+'1') ){
                                for(Integer e=1; e<8; e++){
                                    Date finalD = mapIdAccFirstAndSecDate.get(lAcc.Id+'1').addDays(1);
                                    mapIdAccFirstAndSecDate.put(lAcc.Id+'1', finalD);
                                    startOfWeek = PlanejamentoVisitasCriaVisitasAux.getStartOfWeek(finalD);
                                    if(startOfWeek.daysBetween(finalD) == mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+'1') ){
                                        break;
                                    }
                                }
                            }
                            //Cargo la segunda fecha habilitada para el cliente y el planeamiento
                            if(mapIdAccFirstAndSecAvailableDay.containsKey(lAcc.Id+'2') && mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+'2')!=null){
                                mapIdAccFirstAndSecDate.put(lAcc.Id+'2', Date.newInstance(Integer.ValueOf(plan.Ano_de_Referencia__c), lMonth, 1));
                                if(PlanejamentoVisitasCriaVisitasAux.getStartOfWeek(mapIdAccFirstAndSecDate.get(lAcc.Id+'2')).daysBetween(mapIdAccFirstAndSecDate.get(lAcc.Id+'2')) != mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+'2') ){
                                    for(Integer e=1; e<8; e++){
                                        Date finalD = mapIdAccFirstAndSecDate.get(lAcc.Id+'2').addDays(1);
                                        mapIdAccFirstAndSecDate.put(lAcc.Id+'2', finalD);
                                        startOfWeek = PlanejamentoVisitasCriaVisitasAux.getStartOfWeek(finalD);
                                        if(startOfWeek.daysBetween(finalD) == mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+'2') ){
                                            break;
                                        }
                                    }
                                }
                            }
                            system.debug('TOKEN mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+1): '+mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+'1'));
                            system.debug('TOKEN mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+1): '+mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+'1'));
                            system.debug('TOKEN mapIdAccFirstAndSecDate.get(lAcc.Id+1): '+mapIdAccFirstAndSecDate.get(lAcc.Id+'1'));
                            system.debug('TOKEN mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+2): '+mapIdAccFirstAndSecAvailableDay.get(lAcc.Id+'2'));
                            system.debug('TOKEN mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+2): '+mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+'2'));
                            system.debug('TOKEN mapIdAccFirstAndSecDate.get(lAcc.Id+2): '+mapIdAccFirstAndSecDate.get(lAcc.Id+'2'));
                            
                            if(lAcc.Frequency_of_Visits__c == '2 x Semana'){
                                integer semC = i;
                                Boolean useFirst = true;
                                if(math.mod(i,2)!=0 && i!=0){
                                    semC--;
                                    useFirst = false;
                                }
                                if(useFirst){
                                    vis.Data_da_Visita__c = mapIdAccFirstAndSecDate.get(lAcc.Id+'1').addDays((semC/2)*7);
                                    vis.Hora_da_Visita__c = mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+'1');
                                }else{
                                    String getOf = mapIdAccFirstAndSecDate.containsKey(lAcc.Id+'2') && mapIdAccFirstAndSecDate.get(lAcc.Id+'2') != null? '2' : '1';
                                    vis.Data_da_Visita__c = mapIdAccFirstAndSecDate.get(lAcc.Id+getOf).addDays((semC/2)*7);
                                    vis.Hora_da_Visita__c = mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+getOf);
                                }
                            }else if(lAcc.Frequency_of_Visits__c == 'Semanal'){
                                vis.Data_da_Visita__c = mapIdAccFirstAndSecDate.get(lAcc.Id+'1').addDays(i*7);
                                vis.Hora_da_Visita__c = mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+'1');
                            }else if(lAcc.Frequency_of_Visits__c == 'Quinzenal'){
                                vis.Data_da_Visita__c = mapIdAccFirstAndSecDate.get(lAcc.Id+'1').addDays(i*14);
                                vis.Hora_da_Visita__c = mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+'1');
                            }else if(lAcc.Frequency_of_Visits__c == 'Mensal' || lAcc.Frequency_of_Visits__c == 'Seasonal'){
                                vis.Data_da_Visita__c = mapIdAccFirstAndSecDate.get(lAcc.Id+'1');
                                vis.Hora_da_Visita__c = mapIdAccFirstAndSecAvailableTime.get(lAcc.Id+'1');
                            }
                        }
                    }
                    
                    system.debug('TOKEN vis: '+vis);
                    if(vis!=null){
                        system.debug('TOKEN vis.Data_da_Visita__c: '+vis.Data_da_Visita__c);
                        system.debug('TOKEN vis.Hora_da_Visita__c: '+vis.Hora_da_Visita__c);
                    }
                    
                    if(vis!=null){lVisitaList.add(vis);}
                }
            }
        }
        system.debug('aaaaa ' + lVisitaList);
        //Verifica se existe visitas para serem inseridas no ambiente.
        if(lVisitaList.size() > 0){
            try{
                insert lVisitaList;
            } catch(DmlException e){
                for(Planejamento__c plan : LAT_triggerNew){
                    plan.addError('Erro ao criar visitas: '+e.getDmlMessage(0));
                }
                return;
            }
        }
    }
}