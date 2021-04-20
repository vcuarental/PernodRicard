/****************************************************
*Dev: Denis Aranda  Version: 1  Consulting: Valuenet*
****************************************************/

/********************************************************************
* Company: Valuenet
* Desarrollador: Denis Aranda
* Descripcion: extencion de la pagina VFP14_Process_AR
* Fecha: 08/11/2013hola`
*********************************************************************/

public with sharing class VFC14_Process_AR {
	public CS004_dis_enableDoseGarrafa__c CScheckBox {get; set;}
    public LAT_CS007_PushNotifications__c PNcheckBox {get; set;}
	public LAT_BR_CS003_OppLimitTime__c timeLimit {get; set;}
	public Map<String, Boolean> mapCanSeeSection {get; set;}

    public List<LAT_BR_TrainingSurveyQuestions__c> numberOfMonths {get; set;}
	public String minutes {get;Set;}
	public String hours {get;Set;}

		public boolean allowCreateReceipt{get;set;}

    public Boolean colletaCreateTasks {get; set;}
    public Date dataVencimento {get; set;}

    public VFC14_Process_AR(){

    	// Page Security
    	mapCanSeeSection = new Map<String, Boolean>{'1' => false, '2' => false, '3' => false, '4' => false, '5' => false, '6' => false, '7'=>false, '8'=>false,'9'=>false,'10'=>false};
    	string ProfileName = [SELECT Id, Name FROM Profile WHERE id =: Userinfo.getProfileId() LIMIT 1].Name;
        for (LAT_CS001_ProcessPageSecurity__c customSetting : [SELECT LAT_ProfileName__c, LAT_Seccion__c FROM LAT_CS001_ProcessPageSecurity__c WHERE LAT_ProfileName__c =: ProfileName ]){
        	mapCanSeeSection.put(customSetting.LAT_Seccion__c, true);
		}

		//seccion 2
        try{
            CScheckBox = [SELECT Id, isEnable__c FROM CS004_dis_enableDoseGarrafa__c LIMIT 1];
        }catch(Exception e){
            CScheckBox = new CS004_dis_enableDoseGarrafa__c();
        }

        //seccion 3
        try{
            timeLimit = [SELECT Id, LAT_BR_HH__c, LAT_BR_MM__c FROM LAT_BR_CS003_OppLimitTime__c LIMIT 1];
            minutes = timeLimit.LAT_BR_MM__c < 10 ? ('0'+timeLimit.LAT_BR_MM__c) : (String.ValueOf(timeLimit.LAT_BR_MM__c));
            hours = timeLimit.LAT_BR_HH__c < 10 ? ('0'+timeLimit.LAT_BR_HH__c) : (String.ValueOf(timeLimit.LAT_BR_HH__c));
        }catch(Exception e){
            timeLimit = new LAT_BR_CS003_OppLimitTime__c();
        }

        //seccion 4
        try{
            PNcheckBox = [SELECT Id, LAT_isEnabled__c FROM LAT_CS007_PushNotifications__c LIMIT 1];
        }catch(Exception e){
            PNcheckBox = new LAT_CS007_PushNotifications__c();
        }

        //seccion 5
        try{
            numberOfMonths = [SELECT Id, Name, LAT_BR_TSQ_Type__c, LAT_BR_TSQ_Question__c,
                                        LAT_BR_TSQ_Order__c, LAT_BR_TSQ_Months_Ago__c
                                    FROM LAT_BR_TrainingSurveyQuestions__c WHERE LAT_BR_TSQ_Type__c != 'OTHER' ORDER BY LAT_BR_TSQ_Order__c];
            if (numberOfMonths.isEmpty()) {
                numberOfMonths = new List<LAT_BR_TrainingSurveyQuestions__c>();
            }
        }catch(Exception e){
            numberOfMonths = new List<LAT_BR_TrainingSurveyQuestions__c>();
        }

        //seccion 6
        try{
            String[] stringBoolean = LAT_GeneralConfigDao.getValueAsStringArray('COLLETA_CREATE_TASKS', ',');
            if (!stringBoolean.isEmpty()) {
                colletaCreateTasks = Boolean.valueOf(stringBoolean[0]);
            } else {
                colletaCreateTasks = false;
            }
        }catch(Exception e){
            numberOfMonths = new List<LAT_BR_TrainingSurveyQuestions__c>();
        }

		//seccion 9
		try{
				String[] stringBoolean = LAT_GeneralConfigDao.getValueAsStringArray('ALLOW_CREATE_RECEIPT', ' ');
				if(stringBoolean != null && stringBoolean.size()>0){
						allowCreateReceipt = Boolean.valueOf(stringBoolean[0]);
				} else {
						allowCreateReceipt = true;
				}
		}catch(Exception e){
			allowCreateReceipt = true;
		}
    }

    // sec 1
    public void updatesOfAnalitics(){
        Database.executeBatch(new PCS01_AnalyticsofCCBatch_AR());
        Apexpages.addMessage( new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, Label.VFC14_00001_AR));
        //Label.VFC14_00001_AR = The process has been scheduled, you will receive an email when finished
    }

    // sec 2
    public void doSaveCheckBox(){
        //upsert CScheckBox;
        try{
        	upsert CScheckBox;
        	Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, Label.VFC14_00002_AR));
        	//Label.VFC14_00002_AR = The change was saved successfully
        }catch(DMLException e){
        	Apexpages.addMessages(e);
        }
    }

		// sec 9
		public void doallowCreateReceipt(){
				try{
					List<LAT_GeneralConfig__c> listGeneralConfigValues = [select Name,LAT_Value__c from LAT_GeneralConfig__c where Name = 'ALLOW_CREATE_RECEIPT'];
					if(listGeneralConfigValues != null && listGeneralConfigValues.size() >0){
							listGeneralConfigValues[0].LAT_Value__c = String.valueOf(allowCreateReceipt);
							update listGeneralConfigValues[0];
					}else{
							LAT_GeneralConfig__c toInsert = new LAT_GeneralConfig__c(Name =  'ALLOW_CREATE_RECEIPT', LAT_Value__c = String.valueof(allowCreateReceipt));
							insert toInsert;
					}
					Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, Label.VFC14_00002_AR));
				}catch(DMLException e){
					Apexpages.addMessages(e);
				}
		}


    // sec 2
    public void doSaveCheckNotifications(){
        //upsert CScheckBox;
        try{
            upsert PNcheckBox;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, Label.VFC14_00002_AR));
            //Label.VFC14_00002_AR = The change was saved successfully
        }catch(DMLException e){
            Apexpages.addMessages(e);
        }
    }

    // sec 3
    public void doSaveHours(){
    	timeLimit.LAT_BR_HH__c = Integer.valueOf(hours);
        timeLimit.LAT_BR_MM__c = Integer.valueOf(minutes);
    	try{
    		upsert timeLimit;
    		Apexpages.addMessage( new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, Label.VFC14_00003_AR));
    		//Labe.LAT_BR_CS003_00002 = The time limit was changed successfully
    	}catch(Exception e){
    		Apexpages.addMessages(e);
    	}
    }

    public List<selectOption> getListMinutes(){
		List<selectOption> listMinutes = new List<selectOption>();
		boolean firstTime = true;
		for(integer i=0; i<60; i++){
			if(firstTime){
				listMinutes.add(new selectOption('00', '00'));
				firstTime = false;
			}else{
				if(i<=9){
					listMinutes.add(new selectOption('0'+string.valueOf(i), '0'+string.valueOf(i)));
				}else{
					listMinutes.add(new selectOption(string.valueOf(i), string.valueOf(i)));
				}
			}
		}
		return listMinutes;
	}

	public List<selectOption> getListHours(){
		List<selectOption> listHours = new List<selectOption>();
		boolean firstTime = true;
		for(integer i=0; i<24; i++){
			if(firstTime){
				listHours.add(new selectOption('00', '00'));
				firstTime = false;
			}else{
				if(i<=9){
					listHours.add(new selectOption('0'+string.valueOf(i), '0'+string.valueOf(i)));
				}
				if(i>9 && i<24){
					listHours.add(new selectOption(string.valueOf(i), string.valueOf(i)));
				}
			}
		}
		return listHours;
	}

    // sec 4
    public void doSaveMonths(){
        //upsert CScheckBox;
        try{
            upsert this.numberOfMonths;
            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, Label.VFC14_00002_AR));
            //Label.VFC14_00002_AR = The change was saved successfully
        }catch(DMLException e){
            Apexpages.addMessages(e);
        }
    }


    // sec 6
    public void createTasks(){
        if (this.dataVencimento != null) {
            LAT_BR_SellOutTaskCreator.createTask(this.dataVencimento);
            Apexpages.addMessage( new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, 'Tarefas criadas'));
        } else {
            Apexpages.addMessage( new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, 'Favor informar o Data de Vencimento'));
        }
    }

    // sec 4
    public void runInventory(){
        //upsert CScheckBox;
        try{
            LAT_KAMPOP.runInventory();
            Apexpages.addMessage(new Apexpages.Message(Apexpages.SEVERITY.CONFIRM, Label.VF_VTS_00045));
            //Label.VFC14_00002_AR = The change was saved successfully
        }catch(DMLException e){
            Apexpages.addMessages(e);
        }
    }
    public PageReference runReportAtivado(){
        return page.LAT_AtivadoxNaoAtivado;
    }
    public PageReference runReportAtivadoAP(){
        return page.LAT_FocoxNoFocoReport;
    }
    public void saveColletaTaskAuto(){
        List<LAT_GeneralConfig__c> gcList = [SELECT id, Name, LAT_Value__c FROM LAT_GeneralConfig__c
                                                WHERE Name = 'COLLETA_CREATE_TASKS'];
        if (!gcList.isEmpty()) {
            LAT_GeneralConfig__c gc = gcList.get(0);
            gc.LAT_Value__c = String.valueOf(colletaCreateTasks);
            update gc;
        } else {
            LAT_GeneralConfig__c gc = new LAT_GeneralConfig__c(Name = 'COLLETA_CREATE_TASKS',
                                                    LAT_Value__c = String.valueOf(colletaCreateTasks));
            insert gc;
        }

    }
    
    public PageReference doCalculateBDContratos(){
        String userName = UserInfo.getUserName();
        User activeUser = [Select Email From User where Username = : userName limit 1];
        String userEmail = activeUser.Email;
       	String newPageUrl = 'https://lat-dbcontracts-production.herokuapp.com/ContractsBD?email='+userEmail;
   		PageReference newPage = new PageReference(newPageUrl);
  		newPage.setRedirect(true);
   		return newPage;

    }
}