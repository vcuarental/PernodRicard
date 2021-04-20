/**********************************************************************************
* Name : ASI_CRM_SG_OfftakeFocMappingReport
* Created : Vincent lam
*
* Version History
* Date             Developer               Comments
* ---------------  --------------------    ----------------------------------------
* 2018-01-15		Vincent Lam				Created
**********************************************************************************/

public class ASI_CRM_SG_OfftakeFocMappingReport {

    public string year_from {get;set;}
    public string month_from {get;set;}
    public string year_to {get;set;}
    public string month_to {get;set;}
	public list<list<wrapper>> list_display {get;set;}
	
    public SelectOption[] monthOptions_from{get;set;} 	//Month picklist val
    public SelectOption[] yearOptions_from{get;set;}		//Year picklist val
    public SelectOption[] monthOptions_to{get;set;} 	//Month picklist val
    public SelectOption[] yearOptions_to{get;set;}		//Year picklist val
	
	public static map<string, string> map_month = new map<string, string>{
		'1' => 'Jan',
		'2' => 'Feb',
		'3' => 'Mar',
		'4' => 'Apr',
		'5' => 'May',
		'6' => 'Jun',
		'7' => 'Jul',
		'8' => 'Aug',
		'9' => 'Sep',
		'10' => 'Oct',
		'11' => 'Nov',
		'12' => 'Dec'
	};
	
	
	public class wrapper{
		public ASI_TH_CRM_Contract__c c {get;set;}
		public Set<String> set_detail {get;set;}
		
		public String getDetail(){
			String detailStr = '';
			for (String s : set_detail){
				List<string> year_month = s.split('_');
				detailStr += map_month.get(year_month[1]) + ' ' + year_month[0] + ', ';
			}
			detailStr = detailStr.substring(0, detailStr.length()-2);
			return detailStr;
		}
		
		public wrapper (ASI_TH_CRM_Contract__c c, Set<String> set_detail){
			this.c = c;
			this.set_detail = set_detail;
		}
	}

    public ASI_TH_CRM_Contract__c filterWrapper {
        get;
        set;
    } {
        filterWrapper = new ASI_TH_CRM_Contract__c();
    }
	
    // Constructor
    public ASI_CRM_SG_OfftakeFocMappingReport() {
		
        Integer year = Integer.valueOf(Date.Today().addYears(-4).year());
        Integer month = Integer.valueOf(Date.Today().addYears(-4).month());
        
        yearOptions_from = new SelectOption[]{};
        yearOptions_to = new SelectOption[]{};
		for(integer i = 0 ; i < 6; i++){
			yearOptions_from.add(new SelectOption(String.valueOf(year-1),String.valueOf(year-1)));
			yearOptions_to.add(new SelectOption(String.valueOf(year-1),String.valueOf(year-1)));
			year++;
		}
        monthOptions_from = new SelectOption[]{};
        monthOptions_to = new SelectOption[]{};
		for(integer i = 1 ; i < 13; i++){
			monthOptions_from.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
			monthOptions_to.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
		}
        
        Date defaultDate = system.today();
		year_from = String.valueOf(defaultDate.year());
		month_from = String.valueOf(defaultDate.month());
		year_to = String.valueOf(defaultDate.year());
		month_to = String.valueOf(defaultDate.month());
    }

    //search function
    public void runSearch() {
        Date startDate = Date.newInstance(Integer.valueOf(year_from), Integer.valueOf(month_from), 1);
        Date endDate = Date.newInstance(Integer.valueOf(year_to), Integer.valueOf(month_to), 1).addMonths(1)-1;
		
		// build the keys in the selected month range
		Set<string> key_yearMonth = getKeyYearMonth(startDate, endDate);
		
		// get all approved contracts in the selected month range
		Map<string, ASI_TH_CRM_Contract__c> map_contract = getAllApprovedContract(startDate, endDate, filterWrapper);
		
		// build map that list which contracts do not have generated FOC in which year/month
		Map<string, Set<string>> map_contractWithoutFOCMonth = buildContractWithoutFOCMonth(map_contract.keySet(), key_yearMonth);
		
		// build the list to display in the page
		list_display = buildDisplayList(map_contractWithoutFOCMonth, map_contract);
		
    }
	
	private Set<string> getKeyYearMonth(Date startDate, Date endDate){
		Set<string> key_yearMonth = new Set<string>();
		Date runningDate = startDate;
		
		While(runningDate <= endDate){
			key_yearMonth.add(runningDate.year()+'_'+runningDate.month());
			runningDate = runningDate.addMonths(1);
		}
		key_yearMonth.add(endDate.year()+'_'+endDate.month());
		return key_yearMonth;
	}
    
	private Map<string, ASI_TH_CRM_Contract__c> getAllApprovedContract(Date startDate, Date endDate, ASI_TH_CRM_Contract__c contract){
		String recordtypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_SG_Contract_Read_Only');
		String query = 'select Id, name, ' +
			'ASI_CRM_CN_Outlet_WS__c, ASI_CRM_CN_Outlet_WS__r.name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_SG_Category_Code_13__c, ' +
			'ASI_TH_CRM_Contract_Status__c,  ' +
			'ASI_TH_CRM_Start_Date__c, ASI_TH_CRM_End_Date__c,  ' +
			'Owner.Name, ' +
			'(select id from Contract_Target__r where ASI_CRM_SG_Sales_Incentive__c <> null limit 1) '+
			'from ASI_TH_CRM_Contract__c ' +
			'where  ' +
			'recordtypeid = :recordtypeid and ' +
			'( ' +
			'	(ASI_TH_CRM_Start_Date__c <= :startDate and ASI_TH_CRM_End_Date__c >= :startDate) OR ' +
			'	(ASI_TH_CRM_Start_Date__c <= :endDate and ASI_TH_CRM_End_Date__c >= :endDate) OR ' +
			'	(ASI_TH_CRM_Start_Date__c >= :startDate and ASI_TH_CRM_End_Date__c <= :endDate) ' +
			') ';
		if (contract.ASI_CRM_CN_Outlet_WS__c != null && String.valueOf(contract.ASI_CRM_CN_Outlet_WS__c).length() > 0){
			String Idstr = String.valueOf(contract.ASI_CRM_CN_Outlet_WS__c);
			query += 'and ASI_CRM_CN_Outlet_WS__c = :Idstr ';
		}
		map<string, ASI_TH_CRM_Contract__c> map_c = new map<string, ASI_TH_CRM_Contract__c>();
		for (ASI_TH_CRM_Contract__c c : Database.query(query)){
			if (c.Contract_Target__r.size()>0){
				map_c.put(c.Id, c);
			}
		}
		return map_c;
	}
	
	private Map<string, Set<string>> buildContractWithoutFOCMonth(Set<string> set_contract, Set<string> key_yearMonth){
		Map<string, Set<string>> map_contractWithoutFOCMonth = new Map<string, Set<string>>();
		
		// build an original map that assume all contracts do not have generated FOC
		for (string c : set_contract){
			map_contractWithoutFOCMonth.put(c, key_yearMonth);
		}
		
		system.debug(map_contractWithoutFOCMonth);
		
		// only keep those without generated FOC in this contract map
		map_contractWithoutFOCMonth = filterOutByGeneratedFOC(map_contractWithoutFOCMonth, key_yearMonth);
		
		system.debug(map_contractWithoutFOCMonth);
		
		// only keep those have SKU in this contract map
		map_contractWithoutFOCMonth = filterOutByOfftake(map_contractWithoutFOCMonth, key_yearMonth);
		
		return map_contractWithoutFOCMonth;
	}
	
	private Map<string, Set<string>> filterOutByGeneratedFOC(Map<string, Set<string>> map_contractWithoutFOCMonth, Set<string> key_yearMonth){
		list<string> recordtypId = new list<string>{
			//Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC'),
			Global_RecordTypeCache.getRTId('ASI_FOC_Free_Goods_Request__cASI_CRM_SG_FOC_Read_Only')
		};
		for (AggregateResult a : [
			select 
				ASI_CRM_Contract__c c, 
				ASI_CRM_SG_Year__c y, 
				ASI_CRM_SG_Month__c m
			from ASI_FOC_Free_Goods_Request__c 
			where 
				recordtypeId in :recordtypId and 
				ASI_CRM_Contract__c in :map_contractWithoutFOCMonth.keySet() and
				ASI_CRM_SG_System_Generated__c = true and
				ASI_CRM_SYS_Key_Year_Month__c in :key_yearMonth
			group by 
				ASI_CRM_Contract__c, 
				ASI_CRM_SG_Year__c ,
				ASI_CRM_SG_Month__c
		]){
			string key = String.valueOf(a.get('y')) + '_' + String.valueOf(a.get('m'));
			String c = String.valueOf(a.get('c'));
			if (map_contractWithoutFOCMonth.containsKey(c)){
				Set<string> set_key = map_contractWithoutFOCMonth.get(c);
				if (set_key.contains(key)){
					set_key.remove(key);
				}
				if (set_key.size()==0){
					map_contractWithoutFOCMonth.remove(c);
				} else {
					map_contractWithoutFOCMonth.put(c, set_key);
				}
			}
		}
		
		return map_contractWithoutFOCMonth;
	}
	
	private Map<string, Set<string>> filterOutByOfftake(Map<string, Set<string>> map_contractWithoutFOCMonthOriginal, Set<string> key_yearMonth){
		Map<string, Set<string>> map_contractWithoutFOCMonth = new Map<string, Set<string>>();
		Set<string> set_key = new Set<string>();
		
		// build the set_key to reduce soql rows
		for (string c : map_contractWithoutFOCMonthOriginal.keySet()){
			for (string key : map_contractWithoutFOCMonthOriginal.get(c)){
				set_key.add(c+'_'+key);
			}
		}
		
		list<string> recordtypId = new list<string>{
			Global_RecordTypeCache.getRTId('ASI_TH_CRM_Actual_Offtake__cASI_CRM_SG_Actual_offtake')
		};
		for (AggregateResult a : [
			select 
				ASI_CRM_Contract__c c, 
				calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c) y, 
				calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c) m
			from ASI_TH_CRM_Actual_Offtake__c 
			where 
				recordtypeId in :recordtypId and 
				ASI_CRM_Contract__c in :map_contractWithoutFOCMonthOriginal.keySet()
			group by 
				ASI_CRM_Contract__c, 
				calendar_year(ASI_TH_CRM_Offtake_G_L_Date__c) ,
				calendar_month(ASI_TH_CRM_Offtake_G_L_Date__c)
		]){
			//system.debug(a);
			string key = String.valueOf(a.get('y')) + '_' + String.valueOf(a.get('m'));
			if (key_yearMonth.contains(key)){
				String c = String.valueOf(a.get('c'));
				Set<string> set_yearMonth = map_contractWithoutFOCMonth.containsKey(c) ? map_contractWithoutFOCMonth.get(c) : new Set<string>();
				set_yearMonth.add(key);
				map_contractWithoutFOCMonth.put(c, set_yearMonth);
			}
		}
		
		return map_contractWithoutFOCMonth;
	}
	
	public list<list<wrapper>> buildDisplayList(Map<string, Set<string>> map_contractWithoutFOCMonth, Map<string, ASI_TH_CRM_Contract__c> map_contract){
		list<list<wrapper>> list_display = new list<list<wrapper>>();
		list<wrapper> list_w = new list<wrapper>();
		Integer count = 1;
		
		for (String c : map_contractWithoutFOCMonth.keySet()){
			ASI_TH_CRM_Contract__c contract = map_contract.get(c);
			Set<string> set_month = map_contractWithoutFOCMonth.get(c);
			wrapper w = new wrapper(contract, set_month);
			if (count > 1000){
				list_display.add(list_w);
				list_w = new list<wrapper>();
				count = 0;
			}
			list_w.add(w);
			count++;
		}
		list_display.add(list_w);
		
		return list_display;
	}
}