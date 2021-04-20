/****************************************************
 Dev: Denis Aranda  Version: 1  Consulting: Valuenet
****************************************************/

public with sharing class LAT_BR_AP01_Planejamento {    
    private static map <string, string> previousMonths = new map <string, string>{'Janeiro' => 'Dezembro', 'Fevereiro' => 'Janeiro', 'Março' => 'Fevereiro', 'Abril' => 'Março', 'Maio' => 'Abril', 'Junho' => 'Maio', 'Julho' => 'Junho', 'Agosto' => 'Julho', 'Setembro' => 'Agosto', 'Outubro' => 'Setembro', 'Novembro' => 'Outubro', 'Dezembro' => 'Novembro'};
    
    public static void PlanejamentoVerificaSegunda(list<Planejamento__c> triggerNew, map<Id, Planejamento__c> triggerOldMap){
        
        Date hoy = date.today();
        
        //set de ids de la primera semana
        set<id> planId = new set<id>();
        
        //Mapa que contiene id del planejamiento y Visitas
        map<id, list<Visitas__c>> mapPlaVis = new map<id, list<Visitas__c>>();
        
        //sets para despues llamar a planejamientos del mes anterior
        set<String> setPrevMonth = new set<String>();
        set<string> setYear = new set<string>();
        set<String> setUser = new set<String>();
        
        for(Planejamento__c plan: triggerNew){
            if(plan.Solicitar_aprova_o_para__c == 'Planejamento mensal (+semana 1)'){
                // si es semana 1 lo manda al metodo de abajo
                if(mapKeyCreater(plan.M_s_de_Ref_rencia__c, plan.Ano_de_Referencia__c, plan.OwnerId)== null){
                    // tira erros si regresa null
                    plan.addError(label.LAT_BR_AP01_00001);
                }else{
                    //llena los sets
                    setPrevMonth.add(mapKeyCreater(plan.M_s_de_Ref_rencia__c, plan.Ano_de_Referencia__c, plan.OwnerId).split('\\$')[0]);
                    setYear.add(mapKeyCreater(plan.M_s_de_Ref_rencia__c, plan.Ano_de_Referencia__c, plan.OwnerId).split('\\$')[1]);
                    setUser.add(mapKeyCreater(plan.M_s_de_Ref_rencia__c, plan.Ano_de_Referencia__c, plan.OwnerId).split('\\$')[2]);
                }
            }else{
                //si no es de la primera semana llena otro set
                planId.add(plan.id);
            }
        }
        
        map<string, Boolean> mapMYUHaveVisEnc = NEW map<string, Boolean>(); 
        System.debug('%%% setPrevMonth : ' + setPrevMonth); 
        System.debug('%%% setYear : ' + setYear);
        System.debug('%%% setUser : ' + setUser);
        list<Planejamento__c> prevMonthPlan = [SELECT id, Name, OwnerId, Month_Year_User__c, M_s_de_Ref_rencia__c, Ano_de_Referencia__c,  (SELECT Id, Status__c, Planejamento__c FROM Visitas__r   WHERE Createddate >=LAST_N_MONTHS:6) FROM Planejamento__c Where M_s_de_Ref_rencia__c IN: setPrevMonth AND Ano_de_Referencia__c IN: setYear AND OwnerId IN: setUser AND Createddate >=LAST_N_MONTHS:6];
        for(Planejamento__c pla: prevMonthPlan){
            //lleno el mapa y mefijo si ahi visitas en encerrada
            Boolean enc = false;
            for(Visitas__c vis: pla.Visitas__r){
                if(vis.Status__c != 'Encerrada'){
                    enc = true;
                }
            }
            mapMYUHaveVisEnc.put((pla.M_s_de_Ref_rencia__c+pla.Ano_de_Referencia__c+pla.OwnerId), enc); 
        }
        
        if(!planId.IsEmpty()){
            for(Visitas__c vis: [SELECT Id, Name, Planejamento__c, Status__c, Data_da_Visita__c FROM Visitas__c WHERE Planejamento__c IN: planId AND Data_da_Visita__c <: hoy]){
                //Cargo el mapa
                if(mapPlaVis.containskey(vis.Planejamento__c)){
                    mapPlaVis.get(vis.Planejamento__c).add(vis);
                }else{
                    mapPlaVis.put(vis.Planejamento__c, new List<Visitas__c>{vis});  
                }
            }
        }
        
        
        for(Planejamento__c pla: triggerNew){
            if(pla.Status_do_Planejamento__c == 'Aguardando Aprovação' && (triggerOldMap.get(pla.id).Status_do_Planejamento__c != pla.Status_do_Planejamento__c)){
                if(pla.Solicitar_aprova_o_para__c == 'Planejamento mensal (+semana 1)'){
                    //llamo el mapa y consulto solo si es semana 1
                    String thekey = mapKeyCreater(pla.M_s_de_Ref_rencia__c, pla.Ano_de_Referencia__c, pla.OwnerId).replace('$','');
                    if(mapMYUHaveVisEnc.containskey(thekey)){
                        if(mapMYUHaveVisEnc.get(thekey)){
                            pla.addError(label.LAT_BR_AP01_00002);
                        }
                    }
                }else{
                    //NO semana 1
                    if(mapPlaVis.containskey(pla.Id)){
                        for(Visitas__c vis: mapPlaVis.get(pla.Id)){
                            if(vis.Status__c !='Encerrada'){
                                pla.addError(label.LAT_BR_AP01_00003);
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: nameCreater
    * Descripcion: Completa el nombre de los Planejamento__c
    * Desarrollador: Denis Aranda
    * Fecha: 20/03/2014
    * Modo: before insert
    *****************************************************************************************/
    public static void nameCreater(list<Planejamento__c> triggerNew){
        Map<String, String> ownersNames = new Map<String, String>();
        List<String> ownersIds = new List<String>();

        for(Planejamento__c plan: triggerNew){
            ownersIds.add(plan.ownerId);
        }

        for(User us : [Select id,firstName,lastName from User where id in: ownersIds]){
            ownersNames.put(us.id, us.firstName + ' ' + us.lastName);
        }

        for(Planejamento__c plan: triggerNew){
            plan.Name = LAT_BR_AP01_Planejamento.generateName(plan, ownersNames.get(plan.ownerId)); 
        }
     }

    /*****************************************************************************************
    * Nombre del metodo: checkPlansExists
    * Descripcion: Valida si ya existe un plan para ese vendedor en ese mes y año
    * Desarrollador: Zimmic
    * Fecha: 14/03/2016
    * Modo: before insert,Update
    *****************************************************************************************/

    public static void checkPlansExists(list<Planejamento__c> triggerNew){
        List<String> names = new List<String>();
        Map<String, Planejamento__c> createdPlans = new Map<String, Planejamento__c>();
        
        Map<String, String> ownersNames = new Map<String, String>();
        List<String> ownersIds = new List<String>();

        for(Planejamento__c plan: triggerNew){
            ownersIds.add(plan.ownerId);
        }

        for(User us : [Select id,firstName,lastName from User where id in: ownersIds]){
            ownersNames.put(us.id, us.firstName + ' ' + us.lastName);
        }

        for(Planejamento__c plan : triggerNew){
            names.add(LAT_BR_AP01_Planejamento.generateName(plan, ownersNames.get(plan.ownerId)));
        }

        for(Planejamento__c plan : [Select id,name,Plan_Name__c  from Planejamento__c where Plan_Name__c in: names]){
            createdPlans.put(plan.name, plan);
        }

         for(Planejamento__c plan : triggerNew){
            String planName = LAT_BR_AP01_Planejamento.generateName(plan,ownersNames.get(plan.ownerId));
            if(createdPlans.get(planName) != null && createdPlans.get(planName).id != plan.id){
                plan.addError(Label.LAT_BR_AP01_00007);
            }
        }
    }

    public static String generateName(Planejamento__c plan, String ownerName){
        return 'PVP-' + ownerName + '-' + plan.M_s_de_Ref_rencia__c + '-' + plan.Ano_de_Referencia__c;
    }

     
     /*****************************************************************************************
    * Nombre del metodo: clientPortfolioCreater
    * Descripcion: Creates a Client Portfolio for every client.
    * Desarrollador: Denis Aranda
    * Fecha: 20/03/2014
    * Modo: after insert
    *****************************************************************************************/
     public static void clientPortfolioCreater(list<Planejamento__c> triggerNew){
        Set<String> setOfOwnerId = new Set<String>(); 
        List<LAT_BR_CPO_ClientPortfolio__c> listOfPortInsert = new List<LAT_BR_CPO_ClientPortfolio__c>(); 

        for(Planejamento__c pla: triggerNew){
            setOfOwnerId.add(pla.OwnerId);
        }
        
        List<Account> acc = [SELECT Id, Name, OwnerId, Client_code_AN8__c, Revenue_Neighbourhood__c, Frequency_of_Visits__c, Revenue_City__c, Revenue_City__r.Name 
                            FROM Account WHERE Recordtype.DeveloperName IN :AP01_Account_BR.BR_RECORDTYPES  
                            AND Status__c != 'Não aprovado' AND Status__c != 'Novo cadastro'  AND Rating != 'Cliente inativo' AND OwnerId IN: setOfOwnerId];
        
        for(Planejamento__c pla: triggerNew){
            for(Account ac: acc){
                if(pla.OwnerId == ac.OwnerId){
                    LAT_BR_CPO_ClientPortfolio__c port = new LAT_BR_CPO_ClientPortfolio__c();
                    port.LAT_BR_City__c = ac.Revenue_City__r.Name;
                    port.LAT_BR_Client__c = ac.Id;
                    port.LAT_BR_ClientCodeAN8__c = ac.Client_code_AN8__c;
                    port.LAT_BR_Neighbourhood__c = ac.Revenue_Neighbourhood__c;
                    port.LAT_BR_VisitsFrequency__c = ac.Frequency_of_Visits__c;
                    port.LAT_BR_VisitPlanning__c = pla.Id;
                    listOfPortInsert.add(port);
                }
            }
        }
        try { 
            insert listOfPortInsert;
        } catch(exception e){ 
            system.debug('Exception:' + e.getMessage() + 
                            ' Line: ' + e.getLineNumber() + 
                            ' Cause: ' + e.getCause()); 
            
            LAT_DebugUtil debugUtil = new LAT_DebugUtil();
            debugUtil.addData('Exception:' + e.getMessage() + 
                            ' Line: ' + e.getLineNumber() + 
                            ' Cause: ' + e.getCause());
            debugUtil.setOrigin('LAT_BR_AP01_Planejamento');
            debugUtil.insertDebug();
        }
     }
     
    
    //return el mes año y owner id del planejamiento del mes anterior
    public static string mapKeyCreater(String setPrevMonth, String setYear, String setUser){
        string premonth;
        string theYear;
        if(setPrevMonth != null && setYear != null && setUser != null){
            premonth = previousMonths.get(setPrevMonth);
            if(premonth == 'Dezembro' ){
                theYear = string.valueOf((integer.valueOf(setYear) - 1));
            }else{
                theYear = string.valueOf(setYear);
            }
            return premonth+'$'+theYear+'$'+setUser;
        }
        return null;
    }
    
   /*****************************************************************************************
    * Nombre del metodo: visitaStatusUpdate
    * Descripcion: Metodo que actualiza el campo Status de la Visita a 'Encerrada' cuando el 
    *              planeamiento es aprobado y la visita tiene Visita_n_o_realizada__c = true
    * Desarrollador: Elena Schwarzböck
    * Fecha: 25/03/2014
    * Modo: after update
    *****************************************************************************************/
    public static void visitaStatusUpdate(list<Planejamento__c> triggerNew, Map<Id,Planejamento__c> OldMap){

        Set<Id> setPlanIds = new Set<Id>();
        for(Planejamento__c plan: triggerNew){
            if(plan.Status_do_Planejamento__c == 'Approved' && plan.Status_do_Planejamento__c != OldMap.get(plan.Id).Status_do_Planejamento__c){
                setPlanIds.add(plan.Id);
            }
        } 
        if(!setPlanIds.isEmpty()){
            List<Visitas__c> listVisitas = [SELECT Id, Status__c,LAT_isTrigger__c FROM Visitas__c WHERE Planejamento__c IN: setPlanIds AND Visita_n_o_realizada__c = true AND Status__c != 'Encerrada'];               
            if(!listVisitas.isEmpty()){
                Map<Id,List<Visitas__c>> mapPlanIdVisitas = new Map<Id,List<Visitas__c>>();
                for(Visitas__c visita: listVisitas){
                    visita.LAT_isTrigger__c = true;
                    visita.Status__c = 'Encerrada';
                }                
                try{update listVisitas;}catch(DMLException e){
                    system.debug('Exception:' + e.getMessage() + 
                                    ' Line: ' + e.getLineNumber() + 
                                    ' Cause: ' + e.getCause()); 
            
                    LAT_DebugUtil debugUtil = new LAT_DebugUtil();
                    debugUtil.addData('Exception:' + e.getMessage() + 
                                        ' Line: ' + e.getLineNumber() + 
                                        ' Cause: ' + e.getCause());
                    debugUtil.setOrigin('LAT_BR_AP01_Planejamento');
                    debugUtil.insertDebug();
                }
            }
        }
    }
    
    /*TEST CODE IN LAT_BR_AP01_Planejamento_TEST CLASS*/
    
    /*********************************************************************************************************
    * Nombre del metodo: updatesPPCKey
    * Descripcion: Method that calls the method that updates the field Produto_Concorr_ncia__c.LAT_Key__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 07/05/2013
    * Modo: after update
    ********************************************************************************************************/
    public static void updatesPPCKey(List<Planejamento__c> triggerNew, Map<Id,Planejamento__c> oldMap){
        
        Set<Id> setIds = new Set<Id>();
        for(Planejamento__c pla: triggerNew){
            if(pla.LAT_MonthYear__c != oldMap.get(pla.Id).LAT_MonthYear__c){
                setIds.add(pla.Id);          
            }
        }
        
        Map<Id,Produto_Concorr_ncia__c> mapPPC = new Map<Id,Produto_Concorr_ncia__c>([SELECT Id FROM Produto_Concorr_ncia__c WHERE Checklist_de_Visita__r.Visita__r.Planejamento__c IN: setIds AND Checklist_de_visita__r.LAT_BR_ValidOnTradeChecklist__c = true]);
        
        if(!mapPPC.isEmpty()){
            LAT_BR_UpdatesKeyOfPPC.updatesKeyOfPPC(mapPPC.keySet());     
        }  
    }

     /*****************************************************************************************
    * Nombre del metodo: generateMonthlyPlans
    * Descripcion: Genera los planes para todos los vendedores para el mes siguiente
    * Desarrollador: Zimmic
    * Fecha: 24/03/2016
    *****************************************************************************************/
    public static void generateMonthlyPlans(List<User> owners){
        Map <integer, string> monthsByNum = new Map <integer, string>{1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril', 5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto', 9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro'};
        List<Planejamento__c> toInsert = new List<Planejamento__c>();

        Date nextMonth = Date.today().addMonths(1);
        for(User ar : owners){
            Planejamento__c plan = new Planejamento__c();
            plan.name = 'Name';
            plan.Status_do_Planejamento__c = 'Ok para solicitar Aprovação';
            plan.Ano_de_Referencia__c = String.valueOf(nextMonth.year());
            plan.M_s_de_Ref_rencia__c = monthsByNum.get(nextMonth.month());
            plan.ownerId = ar.id;
            toInsert.add(plan);
        }

        Database.SaveResult[] results = Database.Insert(toInsert, false);
        
    }

    public static void updatePlanejamentoStatus(List<Visitas__c> vMap){
        List<String> planIds = new List<String>();
        List<Planejamento__c> toUpdate = new List<Planejamento__c>();
 
        for(Visitas__c v : vMap){
            planIds.add(v.Planejamento__c);
        }

        for(Planejamento__c plan : [Select id,Data_da_Visitas_em_Branco__c,Hora_da_Visita_em_Branco__c,Status_do_Planejamento__c from Planejamento__c where Status_do_Planejamento__c != 'Encerrado' AND Status_do_Planejamento__c != 'Aguardando Aprovação' AND Status_do_Planejamento__c != 'Approved' AND  Status_do_Planejamento__c != 'Modification proposed' AND  id in: planIds]){
            String status = plan.Data_da_Visitas_em_Branco__c == 0 && plan.Hora_da_Visita_em_Branco__c == 0 ? 'Ok para solicitar Aprovação' : 'Visitas nao agendadas' ;
            if(status != plan.Status_do_Planejamento__c){
                plan.Status_do_Planejamento__c = status;
            }
            toUpdate.add(plan);
        }
        try{
            update toUpdate;
        }catch(exception ex){
            LAT_DebugUtil debugUtil = new LAT_DebugUtil();
            debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
            debugUtil.setOrigin('Update visita');
            debugUtil.insertDebug();
        }
    }

}