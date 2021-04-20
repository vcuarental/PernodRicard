public with sharing class LAT_CLIENTPOP {

    public static boolean closedEntrega = false;


    public LAT_CLIENTPOP() {
        
    }

    public static void createEntrega(List<LAT_ClientPOP__c> cliList){
        Integer leftAmount = 0;
        List<String> products = new List<String>();
        Map<String, LAT_KAMPOP__c> kamsMap = new Map<String, LAT_KAMPOP__c>();

        for(LAT_ClientPOP__c cli : cliList){
        	products.add(cli.Material_POP__c);
        }
        system.debug('aaaa ' + products);
        for(LAT_KAMPOP__c kpop : [SELECT id,RegionalPOP__r.product__c, Amount__c, Planned__c, AmountLeft__c, RegionalPOP__c, PlanningLeft__c FROM LAT_KAMPOP__c where KAM__c =: userinfo.getUserId()  AND RegionalPOP__r.product__c in: products]){
			kamsMap.put(kpop.RegionalPOP__r.product__c, kpop);
        }
        
        for(LAT_ClientPOP__c cli : cliList){
        	if(kamsMap.get(cli.Material_POP__c) == null){
        		cli.addError(Label.LAT_Processes_020);
        	}else{
	        	cli.LAT_KAMPOP__c = kamsMap.get(cli.Material_POP__c).id;
	        }
        }
	}

	public static void createEntregaTask(Map<id,LAT_ClientPOP__c> newMap){
		List<Task> tasks = new List<Task>();
		List<String> visitas = new List<String>();
		Map<String, Visitas__c> visitasMap = new Map<String, Visitas__c>();

		for(LAT_ClientPOP__c cli : newMap.values()){
			if(cli.visita__c != null)visitas.add(cli.visita__c);
		}

		visitasMap = new Map<String, Visitas__c>([Select id, Data_da_Visita__c from Visitas__c where id in: visitas]);

		for(LAT_ClientPOP__c cli : newMap.values()){
            if(cli.Delivered__c == null || cli.Delivered__c == 0){
                Task t = LAT_ProcessesTaks.createTask(cli.id, userinfo.getUserId(), Label.LAT_Processes_019,Label.LAT_Processes_019, Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),0,'POP-Entregar Material');
                t.ActivityDate = LAT_ProcessesTaks.AddBusinessDays(Date.today(), 15);
                if(cli.Planned_Date__c != null){
                    t.activityDate = cli.Planned_Date__c;
                    t.LAT_OriginalDueDate__c = cli.Planned_Date__c;
                }
                if(cli.visita__c != null && cli.visita__c != ''){
                  t.LAT_Visita__c = cli.visita__c;
                }
                tasks.add(t);  

    			
            }
		}
		insert tasks;
	}

	public static void updateDate(List<LAT_ClientPOP__c> newList){
		for(LAT_ClientPOP__c cli : newList){
            if(cli.LAT_Planned__c == null){
                cli.LAT_Planned__c = 0;
            }
			//if(cli.Delivered__c != null && cli.Delivered__c != 0){
			//	cli.Delivered_Date__c = Date.today();
			//}
            if(cli.Delivered_Date__c != null && (cli.Delivered__c == null || cli.Delivered__c == 0)){
              cli.Planned_Date__c = cli.Delivered_Date__c;
              cli.Delivered_Date__c = null;
            }else if(cli.Delivered_Date__c != null){
                cli.Planned_Date__c = cli.Delivered_Date__c;
                cli.LAT_Planned__c = 0;
            }

			
		}
	}

	public static void executeEntregaWPlan(Map<id,LAT_ClientPOP__c> newMap){
		List<LAT_ClientPOP__c> tmpList = [Select id,Planned_Date__c,LAT_KAMPOP__r.RegionalPOP__r.product__c,LAT_KAMPOP__r.RegionalPOP__r.product__r.name, lat_client__r.name,Delivered_Date__c,LAT_KAMPOP__c,LAT_KAMPOP__r.kam__c,LAT_KAMPOP__r.RegionalPOP__r.product__r.sku__c,Delivered__c, LAT_KAMPOP__r.RegionalPOP__r.product__r.Evidence__c,LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_evidence__c, (Select id, subject from tasks where subject =: LAbel.LAT_Processes_019) from LAT_ClientPOP__c where id in:newMap.keySet()];
        List<Task> insertList = new List<Task>();
        List<Task> updateList = new List<Task>();

        Map<String, LAT_ClientAmountPOP__c> materialClienteLst = new Map<String, LAT_ClientAmountPOP__c>();
        List<String> materialClientes = new List<String>();

        for(LAT_ClientPOP__c clP : tmpList){
            materialClientes.add(clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c);
        }

        for(LAT_ClientAmountPOP__c cli : [Select id,clientMaterial__c,product__c,client__c,actualAmount__c,oldAmount__c from LAT_ClientAmountPOP__c where clientMaterial__c in :materialClientes]){
            materialClienteLst.put(cli.clientMaterial__c, cli);
        }


        for(LAT_ClientPOP__c clP : tmpList){
            if(clP.Delivered__c != null && clP.Delivered__c != 0 && clP.Planned_Date__c != null){
                Integer valor = Integer.valueOf(clp.Delivered__c);
                String key = clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c;
                if(materialClienteLst.get(key) == null){
                    materialClienteLst.put(key, new LAT_ClientAmountPOP__c(clientMaterial__c = clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c , product__c = clP.LAT_KAMPOP__r.RegionalPOP__r.product__c,client__c = clP.lat_client__c, actualAmount__c = clP.Delivered__c,oldAmount__c = clP.Delivered__c));
                }else{
                    materialClienteLst.get(key).actualAmount__c += valor;
                    //materialClienteLst.get(key).oldAmount__c += valor;
                }

                updateList.addAll(clP.tasks);
                if(clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Evidence__c){
                    Integer days = integer.valueOf(clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_evidence__c != null ? clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_evidence__c : 1);
                    Task t = LAT_ProcessesTaks.createTask(clP.id, clP.LAT_KAMPOP__r.kam__c, Label.LAT_Processes_016 ,LAbel.LAT_Processes_017.replace('{0}',clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.sku__c + ' - ' + clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.name).replace('{1}',clP.lat_client__r.name ).replaceAll('</br>','\n'), Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),days, 'POP-Coletar Evidencia');
                    t.activityDate = clP.Planned_Date__c;
                    t.LAT_OriginalDueDate__c = clP.Planned_Date__c;
                    insertList.add(t);
                }

                Task entregaTask = LAT_ProcessesTaks.createTask(clP.id, userinfo.getUserId(), Label.LAT_Processes_019,Label.LAT_Processes_019, Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),0,'POP-Entregar Material');
                entregaTask.activityDate = clP.Planned_Date__c;
                entregaTask.LAT_OriginalDueDate__c = clP.Planned_Date__c;
                entregaTask.status = 'Concluído';
                updateList.add(entregaTask);  

            }
        }

        for(Task t : updateList)t.status = 'Concluído';

        upsert updateList;
        LAT_ProcessesTaks.insertAndNotificate(insertList);

        upsert materialClienteLst.values();
	}

    public static void executeEntrega(Map<id,LAT_ClientPOP__c> newMap, Map<id,LAT_ClientPOP__c> oldMap){
        if(!LAT_CLIENTPOP.closedEntrega){
            LAT_CLIENTPOP.closedEntrega = true;
            List<LAT_ClientPOP__c> tmpList = [Select id,LAT_KAMPOP__r.RegionalPOP__r.product__c,LAT_KAMPOP__r.RegionalPOP__r.product__r.name, lat_client__r.name,Delivered_Date__c,LAT_KAMPOP__c,LAT_KAMPOP__r.kam__c,LAT_KAMPOP__r.RegionalPOP__r.product__r.sku__c,Delivered__c, LAT_KAMPOP__r.RegionalPOP__r.product__r.Evidence__c,LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_evidence__c, (Select id, subject from tasks where subject =: LAbel.LAT_Processes_019) from LAT_ClientPOP__c where id in:newMap.keySet()];
            List<Task> insertList = new List<Task>();
            List<Task> updateList = new List<Task>();
            Map<String, LAT_ClientAmountPOP__c> materialClienteLst = new Map<String, LAT_ClientAmountPOP__c>();
            List<String> materialClientes = new List<String>();

            for(LAT_ClientPOP__c clP : tmpList){
                materialClientes.add(clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c);
            }

            for(LAT_ClientAmountPOP__c cli : [Select id,clientMaterial__c,product__c,client__c,actualAmount__c,oldAmount__c from LAT_ClientAmountPOP__c where clientMaterial__c in :materialClientes]){
                materialClienteLst.put(cli.clientMaterial__c, cli);
            } 


            for(LAT_ClientPOP__c clP : tmpList){
                if(clP.Delivered__c != 0 && oldMap.get(clP.id).Delivered_Date__c == null && oldMap.get(clP.id).Delivered__c == 0){
                    Integer valor = Integer.valueOf(clp.Delivered__c - oldMap.get(clP.id).Delivered__c);
                    String key = clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c;
                    if(materialClienteLst.get(key) == null){
                        materialClienteLst.put(key, new LAT_ClientAmountPOP__c(clientMaterial__c = clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c , product__c = clP.LAT_KAMPOP__r.RegionalPOP__r.product__c,client__c = clP.lat_client__c, actualAmount__c = clP.Delivered__c,oldAmount__c = clP.Delivered__c));
                    }else{
                        materialClienteLst.get(key).actualAmount__c += valor;
                        //materialClienteLst.get(key).oldAmount__c += valor;
                    }

                    updateList.addAll(clP.tasks);
                    if(clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Evidence__c){
                        Integer days = integer.valueOf(clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_evidence__c != null ? clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_evidence__c : 1);
                        Task t = LAT_ProcessesTaks.createTask(clP.id, clP.LAT_KAMPOP__r.kam__c, Label.LAT_Processes_016 ,LAbel.LAT_Processes_017.replace('{0}',clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.sku__c + ' - ' + clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.name).replace('{1}',clP.lat_client__r.name ).replaceAll('</br>','\n'), Global_RecordTypeCache.getRtId('Task'+'LAT_POP'),days, 'POP-Coletar Evidencia');
                        insertList.add(t);
                    }
                }
            }

            for(Task t : updateList)t.status = 'Concluído';

            update updateList;
            LAT_ProcessesTaks.insertAndNotificate(insertList);

            upsert materialClienteLst.values();

        }
    }


   
    public static void automaticInventory(){

        List<LAT_ClientPOP__c> clientsList = [Select id,lat_client__c,LAT_KAMPOP__r.RegionalPOP__r.product__c, Delivered_Date__c,Delivered__c,LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_Material__c from LAT_ClientPOP__c where LAT_KAMPOP__r.RegionalPOP__r.product__r.Inventory__c = FALSE and Delivered_Date__c != NULL and baixado__c = FALSE];
        List<LAT_ClientPOP__c> toUpdate = new List<LAT_ClientPOP__c>();
        Map<String, LAT_ClientAmountPOP__c> materialClienteLst = new Map<String, LAT_ClientAmountPOP__c>();
        List<String> materialClientes = new List<String>();
        
        for(LAT_ClientPOP__c clP : clientsList){
            materialClientes.add(clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c);
        }

        for(LAT_ClientAmountPOP__c cli : [Select id,clientMaterial__c,product__c,client__c,actualAmount__c,oldAmount__c from LAT_ClientAmountPOP__c where clientMaterial__c in :materialClientes]){
            materialClienteLst.put(cli.clientMaterial__c, cli);
        }


        for(LAT_ClientPOP__c clP : clientsList){
            Integer months = integer.valueOf(clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_Material__c != null ? clP.LAT_KAMPOP__r.RegionalPOP__r.product__r.Valid_Material__c : 1);
            if(clP.Delivered_Date__c.addMonths(months) <= Date.today()){
                clp.baixado__c = true;
                clp.Date_Baixado__c = Date.today();
                toUpdate.add(clP);

                String key = clp.lat_client__c + '' + clp.LAT_KAMPOP__r.RegionalPOP__r.product__c;
                if(materialClienteLst.get(key) != null){
                    materialClienteLst.get(key).actualAmount__c -= clP.Delivered__c;
                    materialClienteLst.get(key).oldAmount__c -= clP.Delivered__c;
                }
            }
        }

        try{
            update toUpdate;
            update materialClienteLst.values();
        }catch(exception ex){
            LAT_DebugUtil debugUtil = new LAT_DebugUtil();
            debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
            debugUtil.setOrigin('MATERIAL POP');
            debugUtil.insertDebug();
        }
    }


    public static LAT_ClientPOP__c updateDetails(LAT_ClientPOP__c Cpop){
        List<LAT_ClientPOP__c> clientPOPList= [Select id, LAT_Client__r.name FROM  LAT_ClientPOP__c 
                                                                                                                                                WHERE LAT_KAMPOP__c =: Cpop.LAT_KAMPOP__c
                                                                                                                                                    AND LAT_Client__c =: Cpop.LAT_Client__c];
        if(clientPOPList.size() > 0){
            return clientPOPList.get(0);
        }else{
            return null;
        }
    }
}