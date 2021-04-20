public with sharing class LAT_MX_VFC08_UpdateCreditLimit {
	public Integer totalReg {get; set;}
	public Integer totalActualizados {get; set;}
	public List<Account> totalLocked {get; set;}
	public Blob toParse {get; set;}
	public String country{get;set;}
	public Map<String,String> countryCodes = new Map<String,String>{'ARS'=>'6','UYU'=>'5','MXN'=>'12','BRL'=>'1'};

    public LAT_MX_VFC08_UpdateCreditLimit() {
    	country = countryCodes.get(UserInfo.getDefaultCurrency());
    	totalLocked = new List<Account>();
    }


    public void upload() {
    	try{
    		String[] approverIds = LAT_GeneralConfigDao.getValueAsStringArray('CREDIT_LIMIT_UPDATE', ';');
        	//String approverId = approverIds != null ?  approverIds[0] : '005D00000023pFE';
        	
			Map<String, String> approverMaps = new Map<String, String>();
			for (String s: approverIds) {
				String[] countryApp = s.split(':');
				if (countryApp != null && countryApp.size() > 1) {
					approverMaps.put(countryCodes.get(countryApp[0]), countryApp[1]);
				}
			}System.debug('Entro-1');
			
	        List<List<String>> values = parseCSV(toParse.toString(), true);
	        totalReg = values.size();
	        system.debug('aaaaa ' + values);
	        if(values.size() <= 0){
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'El archivo no contiene datos'));
	        }

	        List<String> countryAn8 = new List<String>();

	        Map<String,String> newValues = new Map<String,String>();
	        System.debug('Entro0');
	        for (List<String> valList: values) {
	        	if(valList.size() >= 2){
	        		countryAn8.add(country + '-' + valList[0]);
	        		newValues.put(country + '-' + valList[0] , valList[1]);
	        	}
	        }
	        
	        LAT_MasiveCreditLineHeader__c header;

	        List<id> allIDs = new List<id>();
	        Set<Id> accountEnPenID = new Set<id>();
	        List<id> tmpAccsID = new  List<id>();
	        

	        List<Account> allAcc = [Select id,client_country_an8__c,Credit_line__c from Account where client_country_an8__c in: countryAn8 ];
	     		for(Account a: allAcc){
	     			allIDs.add(a.id);
	     		}
	     		
	     		
	     		List<ProcessInstance> PI =[ Select Id,TargetObjectId,Status From ProcessInstance WHERE TargetObjectId IN: allIDs AND Status=:'Pending'];
	     		for(ProcessInstance p : PI){
	     					accountEnPenID.add(p.TargetObjectId);
	     		}
	     		for(id ac: allIds){
	     			if(!accountEnPenID.contains(ac))
	     					tmpAccsID.add(ac);
	     		}
	     		
	     		List<Account> tmpAccs = [Select id,client_country_an8__c,Credit_line__c from Account where id in: tmpAccsID];
	     		totalLocked = [Select id,client_country_an8__c,Credit_line__c,name from Account where id in: accountEnPenID];
	        if(tmpAccs != null && tmpAccs.size() > 0){
	        	header = new LAT_MasiveCreditLineHeader__c();
	        	header.lat_status__c = 'Nuevo';
	        	header.LAT_Approver__c = approverMaps.get(country) != null ? approverMaps.get(country) : UserInfo.getUserId();
	        	insert header;
	        	List<LAT_MasiveCreditLineLine__c> lines = new List<LAT_MasiveCreditLineLine__c>();
	        	for(Account acc : tmpAccs){
	        		LAT_MasiveCreditLineLine__c line = new LAT_MasiveCreditLineLine__c();
	        		line.LAT_Account__c = acc.id;
	        		line.LAT_AccountAN8__c = acc.client_country_an8__c;
	        		line.LAT_OldValue__c = acc.Credit_line__c;
	        		line.LAT_Header__c = header.id;
	        		line.LAT_New_Value__c = decimal.valueOf(newValues.get(acc.client_country_an8__c).trim());
	        		lines.add(line);
	        		System.debug('Entro4');
	        	}
	        	insert(lines);
	        	totalActualizados = lines.size();
	        	System.debug('Entro5');
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Carga satisfactoria. Proceso:<a href="/'+ header.id +'">' + header.id + '         Se actualizaron: ' + lines.size()+'/'+totalReg+'</a>'));

	        }else{
	        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'El archivo no contiene datos validos'));
	        }
		
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
    	}

    }


    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
		List<List<String>> allFields = new List<List<String>>();
 
		
		contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
		contents = contents.replaceAll('""','DBLQT');

		List<String> lines = new List<String>();
		try {
			lines = contents.split('\n');
		} catch (System.ListException e) {
			System.debug('Limits exceeded?' + e.getMessage());
		}
		Integer num = 0;
		for(String line : lines) {
			// check for blank CSV lines (only commas)
			if (line.replaceAll(',','').trim().length() == 0) break;
			
			List<String> fields = line.split(',');	
			List<String> cleanFields = new List<String>();
			String compositeField;
			Boolean makeCompositeField = false;
			for(String field : fields) {
				if (field.startsWith('"') && field.endsWith('"')) {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				} else if (field.startsWith('"')) {
					makeCompositeField = true;
					compositeField = field;
				} else if (field.endsWith('"')) {
					compositeField += ',' + field;
					cleanFields.add(compositeField.replaceAll('DBLQT','"'));
					makeCompositeField = false;
				} else if (makeCompositeField) {
					compositeField +=  ',' + field;
				} else {
					cleanFields.add(field.replaceAll('DBLQT','"'));
				}
			}
			
			allFields.add(cleanFields);
		}
		if (skipHeaders) allFields.remove(0);
		return allFields;		
	}
		

	
}