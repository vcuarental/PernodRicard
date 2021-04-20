public with sharing class PRH_Iconic_Accounts_Controller {
   	
   	private String sortDirection = 'ASC';
    private String sortExp = 'Name';

    public List<PRH_Luxury_Accounts__c> PRH_accounts;
    public String PRH_Owner {get;set;}
	public String PRH_Owner_2 {get;set;}
	public enum Action {ONLOAD, SEARCH, EXPORT_EXCEL, EXPORT_EXCEL_ALL}
	public Action displayType {get;set;}
    public String url {get;set;}
    public ApexPages.StandardSetController con {get; set;}
    public String PRH_criteria;
    public List<string> alphabet {get;set;}
    public String alpha {get;set;}
	public Integer PRH_nbIconicAccounts = 0;
    
    public String PRH_Account_Name{get;set;}
	//public String PRH_High_Networth_Individuals{get;set;}
	public String PRH_Suppress_and_archive{get;set;} 
    public String PRH_ICT_Account{get;set;}
    //public String PRH_Full_Le_Cercle{get;set;}
    public String PRH_Le_Cercle_Brand_Presence{get;set;}
    public String PRH_Account_Not_Modified_Since{get;set;}
    public String PRH_Collect_Not_Modified_Since{get;set;}
	public String PRH_Located_in_a_hotel{get;set;}
	//public Boolean PRH_Suppress_and_archive{get;set;}
    public String PRH_Account_Type{get;set;}
    public String PRH_Account_Region{get;set;}
    public String PRH_Account_Market_Company{get;set;}
    public String PRH_Account_Country{get;set;}
	public String PRH_Account_City{get;set;}
    
	public List<SelectOption> PRH_accountTypeOptions { get;set; }
	public List<SelectOption> PRH_accountRegionOptions { get;set; }
	public List<SelectOption> PRH_accountMarketCompanyOptions { get;set; }
	public List<SelectOption> PRH_accountCountryOptions { get;set; }
	public List<SelectOption> PRH_highNetworthIndividualsOptions { get;set; }
	public List<SelectOption> PRH_suppressAndArchiveOptions { get;set; }
	public List<SelectOption> PRH_locatedInAHotelOptions { get;set; }
    public List<SelectOption> PRH_ictAccountOptions { get;set; }
	public List<SelectOption> PRH_fullLeCercleOptions { get;set; }
	public List<SelectOption> PRH_leCercleBrandPresenceOptions { get;set; }
 	public List<SelectOption> PRH_accountNotModifiedSinceOptions { get;set; }
	public List<SelectOption> PRH_collectNotModifiedSinceOptions { get;set; }

    public String[] account_Types{get;set;}
	public String sortOrder = 'Name'; 
	private String sortMode = 'ASC';
	private String sortModeAccName = 'ASC';
	private String sortModeAccType = 'ASC';
	private String sortModeAccRegion = 'ASC';
	private String sortModeAccCountry = 'ASC';
	private String sortModeAccCity  = 'ASC';
	private String sortModeAccMarketCompany = 'ASC';
	private String sortModeAccOwner2 = 'ASC';
	private String sortModeAccOwner = 'ASC';
	public Boolean sortOnColumnToDo = False;

    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public PRH_Iconic_Accounts_Controller() {
        this.alphabet=new string[]{'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'All'};
        this.alpha = '';
        this.account_Types = new String[]{};
        this.autoRun();
        
        this.PRH_Account_Name = ApexPages.currentPage().getParameters().get('acc_name');
		this.PRH_Account_Type = ApexPages.currentPage().getParameters().get('acc_type');
        if(this.PRH_Account_Type!=null){
        	this.account_Types = this.PRH_Account_Type.split(',');   
        }
		this.PRH_Account_Region = ApexPages.currentPage().getParameters().get('acc_region');
		this.PRH_Account_Country = ApexPages.currentPage().getParameters().get('acc_country');
		this.PRH_Account_City = ApexPages.currentPage().getParameters().get('acc_city');
		this.PRH_Account_Market_Company = ApexPages.currentPage().getParameters().get('acc_mc');
		this.PRH_Owner = ApexPages.currentPage().getParameters().get('acc_owner');
		this.PRH_Owner_2 = ApexPages.currentPage().getParameters().get('acc_owner2');
		if (ApexPages.currentPage().getParameters().get('export_type') == 'normal') {
			System.debug('--> PRH_Iconic_Accounts_Controller() : export_type=normal');
			this.displayType = Action.EXPORT_EXCEL;
		}
		else {
			System.debug('--> PRH_Iconic_Accounts_Controller() : export_type=all');
			this.displayType = Action.EXPORT_EXCEL_ALL;
		}
		/*if (this.displayType == Action.EXPORT_EXCEL) {
			if (ApexPages.currentPage().getParameters().get('acc_hni') == 'false')
            	this.PRH_High_Networth_Individuals = false;
			else
            	this.PRH_High_Networth_Individuals = true;
			if (ApexPages.currentPage().getParameters().get('acc_sa') == 'false')
				this.PRH_Suppress_and_archive = false;
			else
            	this.PRH_Suppress_and_archive = true;
		}*/
		//this.PRH_High_Networth_Individuals = ApexPages.currentPage().getParameters().get('acc_hni');
		this.PRH_Suppress_and_archive = ApexPages.currentPage().getParameters().get('acc_sa');
		this.PRH_Located_in_a_hotel = ApexPages.currentPage().getParameters().get('acc_lh');
        this.PRH_ICT_Account = ApexPages.currentPage().getParameters().get('acc_ict');
		//this.PRH_Full_Le_Cercle = ApexPages.currentPage().getParameters().get('acc_flc');
        this.PRH_Le_Cercle_Brand_Presence = ApexPages.currentPage().getParameters().get('acc_lcbp');
        this.PRH_Account_Not_Modified_Since = ApexPages.currentPage().getParameters().get('acc_nms');
        this.PRH_Collect_Not_Modified_Since = ApexPages.currentPage().getParameters().get('col_nms');
        
		// stockage des paramètres de l'URL pour renseigner le fichier Excel généré
		PRH_criteria = '';
		if ((this.PRH_Account_Name == '') || (this.PRH_Account_Name == null))
			PRH_criteria = PRH_criteria + 'Account Name=\'\'';
		else
			PRH_criteria = PRH_criteria + 'Account Name=' + this.PRH_Account_Name;//this.lux_acc.Name;
		if ((this.PRH_Owner == '') || (this.PRH_Owner == null))
			PRH_criteria = PRH_criteria + ', Owner=\'\'';
		else
			PRH_criteria = PRH_criteria + ', Owner=' + this.PRH_Owner;
		if ((this.PRH_Owner_2 == '') || (this.PRH_Owner_2 == null))
			PRH_criteria = PRH_criteria + ', Owner 2=\'\'';
		else
			PRH_criteria = PRH_criteria + ', Owner 2=' + this.PRH_Owner_2;
		if (this.PRH_Account_Type == null)
			PRH_criteria = PRH_criteria + ', Account Type=None';
		else
			PRH_criteria = PRH_criteria + ', Account Type=' + this.PRH_Account_Type; 
		/*if (this.PRH_Account_Region == null)
			PRH_criteria = PRH_criteria + ', Account Region=None';
		else
			PRH_criteria = PRH_criteria + ', Account Region=' + this.PRH_Account_Region; 
		if (this.PRH_Account_Country == null)
			PRH_criteria = PRH_criteria + ', Account Country=None';
		else
			PRH_criteria = PRH_criteria + ', Account Country=' + this.PRH_Account_Country;*/
		if (this.PRH_Account_Market_Company == null)
			PRH_criteria = PRH_criteria + ', Account Market Company=None';
		else
			PRH_criteria = PRH_criteria + ', Account Market Company=' + this.PRH_Account_Market_Company;
		if ((this.PRH_Account_City == '') || (this.PRH_Account_City == null))
			PRH_criteria = PRH_criteria + ', Account City=\'\'';
		else
			PRH_criteria = PRH_criteria + ', Account City=' + this.PRH_Account_City;
		/*if (this.displayType == Action.EXPORT_EXCEL) {
            if (this.PRH_High_Networth_Individuals == false)
				PRH_criteria = PRH_criteria + ', High Networth Individuals=False';
			else
				PRH_criteria = PRH_criteria + ', High Networth Individuals=True';
            if (this.PRH_Suppress_and_archive == false)
				PRH_criteria = PRH_criteria + ', Full Active Le Cercle Portfolio=False';
			else
				PRH_criteria = PRH_criteria + ', Full Active Le Cercle Portfolio=True';
		}*/
		/*
		if (this.PRH_High_Networth_Individuals == null || this.PRH_High_Networth_Individuals == '')
			PRH_criteria = PRH_criteria + ', High Networth Individuals=--None--';
		else
			PRH_criteria = PRH_criteria + ', High Networth Individuals=' + this.PRH_High_Networth_Individuals;
		*/
        if (this.PRH_ICT_Account == null || this.PRH_ICT_Account == '')
			PRH_criteria = PRH_criteria + ', ICT Account=None';
		else
			PRH_criteria = PRH_criteria + ', ICT Account=' + this.PRH_ICT_Account;
        
		if (this.PRH_Located_in_a_hotel == null || this.PRH_Located_in_a_hotel == '')
			PRH_criteria = PRH_criteria + ', Located in a hotel=None';
		else
			PRH_criteria = PRH_criteria + ', Located in a hotel=' + this.PRH_Located_in_a_hotel;
        
        if (this.PRH_Le_Cercle_Brand_Presence == null || this.PRH_Le_Cercle_Brand_Presence == '')
			PRH_criteria = PRH_criteria + ', Le Cercle Brand Presence=None';
		else
			PRH_criteria = PRH_criteria + ', Le Cercle Brand Presence=' + this.PRH_Le_Cercle_Brand_Presence;
        
		/*if (this.PRH_Full_Le_Cercle == null || this.PRH_Full_Le_Cercle == '')         // LCS-1324
			PRH_criteria = PRH_criteria + ', Full Le Cercle=None';
		else
			PRH_criteria = PRH_criteria + ', Full Le Cercle=' + this.PRH_Full_Le_Cercle; */
        
        if (this.PRH_Account_Not_Modified_Since == null)
			PRH_criteria = PRH_criteria + ', Account not modified since=None';
		else
			PRH_criteria = PRH_criteria + ', Account not modified since=' + this.PRH_Account_Not_Modified_Since;

		if (this.PRH_Collect_Not_Modified_Since == null)
			PRH_criteria = PRH_criteria + ', Collect not modified since=None';
		else
			PRH_criteria = PRH_criteria + ', Collect not modified since=' + this.PRH_Collect_Not_Modified_Since;
    }
		  
	public String constructRequest(String firstLetter) {
		Boolean flagWhereUsed = false;
        Boolean flagWhereSubSelect = false; // Salesforce limits to 2 sub selects on query, this flag is for construct query (sub select on Collect) 
		String PRH_accountName = this.PRH_Account_Name;
		String PRH_accountType = this.PRH_Account_Type; 
		//String PRH_highNetworthIndividuals = this.PRH_High_Networth_Individuals; 
		String PRH_accountRegion = this.PRH_Account_Region; 
		String PRH_accountCountry = this.PRH_Account_Country; 
		String PRH_accountCity = this.PRH_Account_City; 
		String PRH_SuppressAndArchive = this.PRH_Suppress_and_archive; 
        String PRH_ICTAccount = this.PRH_ICT_Account; 
		String PRH_LocatedInAHotel = this.PRH_Located_in_a_hotel; 
        String PRH_accountMarketCompany = this.PRH_Account_Market_Company;
        String PRH_accountNotModifiedSince = this.PRH_Account_Not_Modified_Since; 
        
        // Variables need subselect on Collect so use flag "flagWhereSubSelect"
        String PRH_collectNotModifiedSince = this.PRH_Collect_Not_Modified_Since; 
		//String PRH_Full_Le_Cercle = this.PRH_Full_Le_Cercle;    // LCS-1324
        String PRH_LCB_Presence = this.PRH_Le_Cercle_Brand_Presence; 
        // End sub select on Collect 
        
		List<User> PRH_Owner_ID;
		List<User> PRH_Owner2_ID;
        String db_query;
        String sortFullExp = sortExpression  + ' ' + sortDirection;
		
		// Check in Iconic account name contains caracter "'"
		if (PRH_accountName != null) {
			if (PRH_accountName.contains('\'') == true) {
				System.debug('PRH_accountName contains special caracter');
				String tmpAccName = PRH_accountName.replace('\'', '\\\'');
				PRH_accountName = tmpAccName;
			}
		}
		System.debug('PRH_accountName : '+ PRH_accountName);
		System.debug('PRH_accountType : '+ PRH_accountType);
		System.debug('PRH_Owner : '+ PRH_Owner);
		System.debug('PRH_Owner_2 : '+ PRH_Owner_2);
		//System.debug('PRH_highNetworthIndividuals : '+ PRH_highNetworthIndividuals);
		System.debug('PRH_accountRegion : '+ PRH_accountRegion);
		System.debug('PRH_accountCountry : '+ PRH_accountCountry);
		System.debug('PRH_accountCity : '+ PRH_accountCity);
		System.debug('PRH_SuppressAndArchive : '+ PRH_SuppressAndArchive);
        System.debug('PRH_ICTAccount : '+ PRH_ICTAccount);	
        //System.debug('PRH_Full_Le_Cercle : '+ PRH_Full_Le_Cercle);	
        System.debug('PRH_LCB_Presence : '+ PRH_LCB_Presence);
		System.debug('PRH_LocatedInAHotel : '+ PRH_LocatedInAHotel);
		//System.debug('PRH_nbOfPernodRicardProducts : '+ PRH_nbOfPernodRicardProducts);
		System.debug('PRH_accountMarketCompany : '+ PRH_accountMarketCompany);
        System.debug('account_Types : '+ account_Types);
		System.debug('account_Types : '+ this.sortOnColumnToDo);
        System.debug('PRH_accountNotModifiedSince : '+ PRH_accountNotModifiedSince);
        System.debug('PRH_collectNotModifiedSince : '+ PRH_collectNotModifiedSince);
			
		// Retrieve OwnerID with information given in field PRH_Owner
		if (!String.isEmpty(PRH_Owner)){
            db_query = 'select Id from User where Name like \''+'%'+PRH_Owner.toUpperCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_Owner.toLowerCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_Owner+'%'+'\'';
            PRH_Owner_ID = Database.query(db_query);
            System.debug('query : '+ db_query);
            System.debug(PRH_Owner_ID.size() + ' PRH_Owner_ID(s) returned.'); 
            System.debug(PRH_Owner_ID); 
        }
		
		// Retrieve OwnerID with information given in field PRH_Owner_2
		if (!String.isEmpty(PRH_Owner_2)){
            db_query = 'select Id from User where Name like \''+'%'+PRH_Owner_2.toUpperCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_Owner_2.toLowerCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_Owner_2+'%'+'\'';
            PRH_Owner2_ID = Database.query(db_query);
            System.debug('query : '+ db_query);
            System.debug(PRH_Owner2_ID.size() + ' PRH_Owner2_ID(s) returned.'); 
            System.debug(PRH_Owner2_ID); 
        }
		
		// Start of the SOQL query
		db_query = '';
		db_query = 'Select Id, Name, PRH_Account_Type__c, format(lastModifiedDate), PRH_ICT_Account__c, PRH_Located_in_a_hotel__c, OwnerId, PRH_Owner_2__c, PRH_Account_Region__c, PRH_Account_Market_Company__c, PRH_Account_Country__c, PRH_City__c, Owner.Name, PRH_Owner_2__r.Name From PRH_Luxury_Accounts__c';
		
		if (String.isEmpty(firstLetter) || (firstLetter == null) || (firstLetter == 'All')){ // No letter selected
			if (!String.isEmpty(PRH_accountName)) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (Name like \''+'%'+PRH_accountName.toUpperCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_accountName.toLowerCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_accountName+'%'+'\''+')';
				}
			} 
		} else { // One letter selected
			if ((this.sortOnColumnToDo == True) && (this.sortOrder == 'Name')) { 
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (Name like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or Name like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				} 
			} else if ((this.sortOnColumnToDo == True) && (this.sortOrder != 'Name') && (!String.isEmpty(PRH_accountName))) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (Name like \''+'%'+PRH_accountName.toUpperCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_accountName.toLowerCase()+'%'+'\'' + ' or Name like \''+'%'+PRH_accountName+'%'+'\''+')';
				}
			} else if (this.sortOnColumnToDo == False) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (Name like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or Name like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				}
			}
		}
			
        if (this.account_Types.size()>0){
            if (flagWhereUsed == false){
                if (this.account_Types.size()==1){
					if (this.account_Types.get(0) != null) {
						db_query = db_query + ' where PRH_Account_Type__c=\''+this.account_Types.get(0)+'\'';
						flagWhereUsed = true;
					}
                }else{
                    for (integer i=0; i<this.account_Types.size(); i++){
                        if (i==0){
							db_query = db_query + ' where';
							flagWhereUsed = true;
							if (this.account_Types.get(i) != null) {
								db_query = db_query + ' (PRH_Account_Type__c=\''+this.account_Types.get(i)+'\'';
							}
                        }else{
                            if (i==this.account_Types.size()-1){
								if (this.account_Types.get(i) != null) {
									db_query = db_query + ' or PRH_Account_Type__c=\''+this.account_Types.get(i)+'\')';									
								}
                            }else{
								if (this.account_Types.get(i) != null) {
									db_query = db_query + ' or PRH_Account_Type__c=\''+this.account_Types.get(i)+'\'';									
								}
                            }
                        }
                    }
                }
			} else {
                if (this.account_Types.size()==1){
					if (this.account_Types.get(0) != null) {
						db_query = db_query + ' and PRH_Account_Type__c=\''+this.account_Types.get(0)+'\'';
					}
                }else{
                    for (integer i=0; i<this.account_Types.size(); i++){
                        if (i==0){
							if (this.account_Types.get(i) != null) {
								db_query = db_query + ' and';
								db_query = db_query + ' (PRH_Account_Type__c=\''+this.account_Types.get(i)+'\'';
							}
                        }else{
                            if (i==this.account_Types.size()-1){
								if (this.account_Types.get(i) != null) {
									db_query = db_query + ' or PRH_Account_Type__c=\''+this.account_Types.get(i)+'\')';
								}
                            }else{
								if (this.account_Types.get(i) != null) {
									db_query = db_query + ' or PRH_Account_Type__c=\''+this.account_Types.get(i)+'\'';
								}
                            }
                        }
                    }
                }
			}
        }
		
		/*
		if (PRH_highNetworthIndividuals == 'Yes'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_High_Networth_Individuals__c=true';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_High_Networth_Individuals__c=true';
			}
		} else if (PRH_highNetworthIndividuals == 'No'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_High_Networth_Individuals__c=false';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_High_Networth_Individuals__c=false';
			}
		}
		*/

		if (String.isEmpty(firstLetter) || (firstLetter == null) || (firstLetter == 'All')){ // No letter selected
			if ((PRH_accountRegion != 'None') && (PRH_accountRegion != null)){
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where PRH_Account_Region__c=\''+PRH_accountRegion+'\'';
				} else {
					db_query = db_query + ' and PRH_Account_Region__c=\''+PRH_accountRegion+'\'';
				}
			} 
		} else { // One letter selected and sort is selected for column Account Region
			if ((this.sortOnColumnToDo == True) && (this.sortOrder == 'PRH_Account_Region__c')) { 
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (PRH_Account_Region__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_Account_Region__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				} else {
					db_query = db_query + ' and (PRH_Account_Region__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_Account_Region__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				}
			} else if ((PRH_accountRegion != 'None') && (PRH_accountRegion != null)) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where PRH_Account_Region__c=\''+PRH_accountRegion+'\'';
				} else {
					db_query = db_query + ' and PRH_Account_Region__c=\''+PRH_accountRegion+'\'';
				}
			}
		}
		
        /*
		if (PRH_SuppressAndArchive == 'Yes'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_Suppress_and_archive__c=true';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_Suppress_and_archive__c=true';
			}
		} else if (PRH_SuppressAndArchive == 'No'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_Suppress_and_archive__c=false';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_Suppress_and_archive__c=false';
			}
		}
        */
		if (PRH_ICTAccount == 'Yes'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_ICT_Account__c=true';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_ICT_Account__c=true';
			}
		} else if (PRH_ICTAccount == 'No'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_ICT_Account__c=false';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_ICT_Account__c=false';
			}
		}        

		if (PRH_LocatedInAHotel == 'Yes'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_Located_in_a_hotel__c=true';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_Located_in_a_hotel__c=true';
			}
		} else if (PRH_LocatedInAHotel == 'No'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where PRH_Located_in_a_hotel__c=false';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and PRH_Located_in_a_hotel__c=false';
			}
		}
        
        if (PRH_Account_Not_Modified_Since == '3 months'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where lastModifiedDate != LAST_N_DAYS:90';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and lastModifiedDate != LAST_N_DAYS:90';
			}
		} else if (PRH_Account_Not_Modified_Since == '6 months'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where lastModifiedDate != LAST_N_DAYS:180';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and lastModifiedDate != LAST_N_DAYS:180';
			}
		} else if (PRH_Account_Not_Modified_Since == '12 months'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where lastModifiedDate != LAST_N_DAYS:365';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL))
					db_query = db_query + ' and lastModifiedDate != LAST_N_DAYS:365';
			}
		}               

		if (String.isEmpty(firstLetter) || (firstLetter == null) || (firstLetter == 'All')){ // No letter selected
			if ((PRH_accountMarketCompany != 'None') && (PRH_accountMarketCompany != null)){
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where PRH_Account_Market_Company__c=\''+PRH_accountMarketCompany+'\'';
				} else {
					db_query = db_query + ' and PRH_Account_Market_Company__c=\''+PRH_accountMarketCompany+'\'';
				}
			} 
		} else { // One letter selected and sort is selected for column Account Market Company
			if ((this.sortOnColumnToDo == True) && (this.sortOrder == 'PRH_Account_Market_Company__c')) { 
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (PRH_Account_Market_Company__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_Account_Market_Company__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				} else {
					db_query = db_query + ' and (PRH_Account_Market_Company__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_Account_Market_Company__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				}
			} else if ((PRH_accountMarketCompany != 'None') && (PRH_accountMarketCompany != null)) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where PRH_Account_Market_Company__c=\''+PRH_accountMarketCompany+'\'';
				} else {
					db_query = db_query + ' and PRH_Account_Market_Company__c=\''+PRH_accountMarketCompany+'\'';
				}
			}
		}
			
		if (String.isEmpty(firstLetter) || (firstLetter == null) || (firstLetter == 'All')){ // No letter selected
			if ((PRH_accountCountry != 'None') && (PRH_accountCountry != null)){
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where PRH_Account_Country__c=\''+PRH_accountCountry+'\'';
				} else {
					db_query = db_query + ' and PRH_Account_Country__c=\''+PRH_accountCountry+'\'';
				}
			} 
		} else { // One letter selected and sort is selected for column Account Country
			if ((this.sortOnColumnToDo == True) && (this.sortOrder == 'PRH_Account_Country__c')) { 
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (PRH_Account_Country__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_Account_Country__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				} else {
					db_query = db_query + ' and (PRH_Account_Country__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_Account_Country__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				}
			} else if ((PRH_accountCountry != 'None') && (PRH_accountCountry != null)) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where PRH_Account_Country__c=\''+PRH_accountCountry+'\'';
				} else {
					db_query = db_query + ' and PRH_Account_Country__c=\''+PRH_accountCountry+'\'';
				}
			}
		}
		
		if (String.isEmpty(firstLetter) || (firstLetter == null) || (firstLetter == 'All')){ // No letter selected
			if (!String.isEmpty(PRH_accountCity)) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (PRH_City__c like \''+'%'+PRH_accountCity.toUpperCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity.toLowerCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity+'%'+'\''+')';
				} else {
					db_query = db_query + ' and (PRH_City__c like \''+'%'+PRH_accountCity.toUpperCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity.toLowerCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity+'%'+'\''+')';
				}
			} 
		} else { // One letter selected and sort is selected for column Account City
			if ((this.sortOnColumnToDo == True) && (this.sortOrder == 'PRH_City__c')) { 
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (PRH_City__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_City__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				} else {
					db_query = db_query + ' and (PRH_City__c like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or PRH_City__c like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				}
			} else if (!String.isEmpty(PRH_accountCity)) {
				if (flagWhereUsed == false){
					flagWhereUsed = true;
					db_query = db_query + ' where (PRH_City__c like \''+'%'+PRH_accountCity.toUpperCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity.toLowerCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity+'%'+'\''+')';
				} else {
					db_query = db_query + ' and (PRH_City__c like \''+'%'+PRH_accountCity.toUpperCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity.toLowerCase()+'%'+'\'' + ' or PRH_City__c like \''+'%'+PRH_accountCity+'%'+'\''+')';
				}
			}
		}
		
		//if Owner field setup by user, add the linked criteria : ownerID
		if (String.isEmpty(firstLetter) || (firstLetter == null) || (firstLetter == 'All')){ // No letter selected
			if (!String.isEmpty(PRH_Owner)) {
				if (PRH_Owner_ID.size() > 0) {
					Boolean firstId = true;
					if (flagWhereUsed == false){
						flagWhereUsed = true;
						db_query = db_query + ' where (';
					} else {
						db_query = db_query + ' and (';
					}
					for (User oid : PRH_Owner_ID) { 
						if (firstId == true) {
							firstId = false;
							db_query = db_query + 'OwnerId=\''+oid.Id+'\'';
						} else {
							db_query = db_query + ' or OwnerId=\''+oid.Id+'\'';
						}
					}
					db_query = db_query + ')';
				}
			}
		} else { // One letter selected and sort is selected for column Owner
			if ((this.sortOnColumnToDo == True) && (this.sortOrder == 'Owner.Name')) { 
				String db_query_ownerID_List;
				List<User> PRH_OwnerID_LinkedWithSelectedLetter;
				db_query_ownerID_List = 'select Id from User where (Name like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or Name like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				PRH_OwnerID_LinkedWithSelectedLetter = Database.query(db_query_ownerID_List);
				if (PRH_OwnerID_LinkedWithSelectedLetter.size() > 0) {
					Boolean firstId = true;
					if (flagWhereUsed == false){
						flagWhereUsed = true;
						db_query = db_query + ' where (';
					} else {
						db_query = db_query + ' and (';
					}
					for (User oid : PRH_OwnerID_LinkedWithSelectedLetter) { 
						if (firstId == true) {
							firstId = false;
							db_query = db_query + 'OwnerId=\''+oid.Id+'\'';
						} else {
							db_query = db_query + ' or OwnerId=\''+oid.Id+'\'';
						}
					}
					db_query = db_query + ')';
				}
			} else if (!String.isEmpty(PRH_Owner)) {
				if (PRH_Owner_ID.size() > 0) {
					Boolean firstId = true;
					if (flagWhereUsed == false){
						flagWhereUsed = true;
						db_query = db_query + ' where (';
					} else {
						db_query = db_query + ' and (';
					}
					for (User oid : PRH_Owner_ID) { 
						if (firstId == true) {
							firstId = false;
							db_query = db_query + 'OwnerId=\''+oid.Id+'\'';
						} else {
							db_query = db_query + ' or OwnerId=\''+oid.Id+'\'';
						}
					}
					db_query = db_query + ')';
				}
			}
		}
		
		//if Owner2 field setup by user, add the linked criteria : owner2ID
		if (String.isEmpty(firstLetter) || (firstLetter == null) || (firstLetter == 'All')){ // No letter selected
			if (!String.isEmpty(PRH_Owner_2)) {
				if (PRH_Owner2_ID.size() > 0) {
					Boolean firstId = true;
					if (flagWhereUsed == false){
						flagWhereUsed = true;
						db_query = db_query + ' where (';
					} else {
						db_query = db_query + ' and (';
					}
					for (User oid : PRH_Owner2_ID) { 
						if (firstId == true) {
							firstId = false;
							db_query = db_query + 'PRH_Owner_2__c=\''+oid.Id+'\'';
						} else {
							db_query = db_query + ' or PRH_Owner_2__c=\''+oid.Id+'\'';
						}
					}
					db_query = db_query + ')';
				}
			}
		} else { // One letter selected and sort is selected for column Owner2
			if ((this.sortOnColumnToDo == True) && (this.sortOrder == 'PRH_Owner_2__c')) { 
				String db_query_owner2ID_List;
				List<User> PRH_Owner2ID_LinkedWithSelectedLetter;
				db_query_owner2ID_List = 'select Id from User where (Name like \''+firstLetter.toUpperCase()+'%'+'\'' + ' or Name like \''+firstLetter.toLowerCase()+'%'+'\''+')';
				PRH_Owner2ID_LinkedWithSelectedLetter = Database.query(db_query_owner2ID_List);
				if (PRH_Owner2ID_LinkedWithSelectedLetter.size() > 0) {
					Boolean firstId = true;
					if (flagWhereUsed == false){
						flagWhereUsed = true;
						db_query = db_query + ' where (';
					} else {
						db_query = db_query + ' and (';
					}
					for (User oid : PRH_Owner2ID_LinkedWithSelectedLetter) { 
						if (firstId == true) {
							firstId = false;
							db_query = db_query + 'PRH_Owner_2__c=\''+oid.Id+'\'';
						} else {
							db_query = db_query + ' or PRH_Owner_2__c=\''+oid.Id+'\'';
						}
					}
					db_query = db_query + ')';
				}
			} else if (!String.isEmpty(PRH_Owner_2)) {
				if (PRH_Owner2_ID.size() > 0) {
					Boolean firstId = true;
					if (flagWhereUsed == false){
						flagWhereUsed = true;
						db_query = db_query + ' where (';
					} else {
						db_query = db_query + ' and (';
					}
					for (User oid : PRH_Owner2_ID) { 
						if (firstId == true) {
							firstId = false;
							db_query = db_query + 'PRH_Owner_2__c=\''+oid.Id+'\'';
						} else {
							db_query = db_query + ' or PRH_Owner_2__c=\''+oid.Id+'\'';
						}
					}
					db_query = db_query + ')';
				}
			}
		}
        
        //////////////////////////////////////////////////////////////////////
        // Variables need subselect on Collect so use flag "flagWhereSubSelect"
        
        // Start Search Full Le Cercle
        /* LCS-1324
        if (PRH_Full_Le_Cercle == 'Yes'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Full_Active_Le_Cercle_Portfolio__c=true';
					flagWhereUsed = true;
				}
			} else {
                if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)){
					db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Full_Active_Le_Cercle_Portfolio__c=true';
                }
            }
            flagWhereSubSelect = true;
		} else if (PRH_Full_Le_Cercle == 'No'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Full_Active_Le_Cercle_Portfolio__c=false';
					flagWhereUsed = true;
				}
			} else {
                if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)){
					db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Full_Active_Le_Cercle_Portfolio__c=false';
                }
			}
            flagWhereSubSelect = true;
		}   
		*/
        // End Search Full Le Cercle

        // Start Search Le Cercle Brand Presence
        if (PRH_Le_Cercle_Brand_Presence == 'Yes'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=true';
					flagWhereUsed = true;
                }
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
						db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=true';
                }             	
			} 
			flagWhereSubSelect = true;  
		} else if (PRH_Le_Cercle_Brand_Presence == 'No'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=false';
					flagWhereUsed = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
                    db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=false';
				}	
			}
			flagWhereSubSelect = true;
		}
		/*
		if (PRH_Le_Cercle_Brand_Presence == 'Yes'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=true';
					flagWhereUsed = true;   
                	flagWhereSubSelect = true;
                }
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
                    if (flagWhereSubSelect==false){
						db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=true';
                    } else {
                    	db_query = db_query + ' and PRH_Le_Cercle_Brand_Presence__c=true';    
                    } 
                	flagWhereSubSelect = true;
                }             	
			}   
		} else if (PRH_Le_Cercle_Brand_Presence == 'No'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=false';
					flagWhereUsed = true;
                    flagWhereSubSelect = true;
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
                    if (flagWhereSubSelect==false){
                    	db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Le_Cercle_Brand_Presence__c=false';
                    } else {
                    	db_query = db_query + ' and PRH_Le_Cercle_Brand_Presence__c=false';  
                    }
					flagWhereSubSelect = true; 
				}	
			}
		}
		*/
        // End Search Le Cercle Brand Presence

		// Start Search Collect not modified since
		if (PRH_Collect_Not_Modified_Since == '3 months'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:90';
					flagWhereUsed = true;
                    flagWhereSubSelect = true; 
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
                    if (flagWhereSubSelect == false){
						db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:90';
                    } else {
                    	db_query = db_query + ' and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:90';    
                    } 
                	flagWhereSubSelect = true; 
            	}
			}
		} else if (PRH_Collect_Not_Modified_Since == '6 months'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:180';
					flagWhereUsed = true;
                    flagWhereSubSelect = true; 
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
                    if (flagWhereSubSelect == false){
						db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:180';
                    } else {
                    	db_query = db_query + ' and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:180';    
                    } 
                	flagWhereSubSelect = true; 
            	}
			}
		} else if (PRH_Collect_Not_Modified_Since == '12 months'){
			if (flagWhereUsed == false){
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
					db_query = db_query + ' where ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:365';
					flagWhereUsed = true;
                    flagWhereSubSelect = true; 
				}
			} else {
				if ((this.displayType == Action.SEARCH) || (this.displayType == Action.EXPORT_EXCEL)) {
                    if (flagWhereSubSelect == false){
						db_query = db_query + ' and ID in (SELECT PRH_Iconic_Account__c from PRH_Collect__c where PRH_Active__c=true and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:365';
                    } else {
                    	db_query = db_query + ' and PRH_Collect_Last_Modified_Date__c != LAST_N_DAYS:365';    
                    } 
            		flagWhereSubSelect = true; 
        		}
			}
		}       
        // End Search Collect not modified since
        
        if (flagWhereSubSelect == true){
            db_query = db_query + ')';  
        }
        
		if (this.displayType == Action.EXPORT_EXCEL) {
			if (flagWhereUsed == false)
				db_query = db_query + ' where IsDeleted=false order by Name LIMIT 32000';
			else
				db_query = db_query + ' and IsDeleted=false order by Name LIMIT 32000';
		} else {
			/*if (flagWhereUsed == false)
				db_query = db_query + ' where IsDeleted=false order by ' + sortOrder + ' ' + sortMode + ' ' + ' LIMIT 1000';
			else
				db_query = db_query + ' and IsDeleted=false order by ' + sortOrder + ' ' + sortMode + ' ' + ' LIMIT 1000';*/
			if (flagWhereUsed == false)
				db_query = db_query + ' where IsDeleted=false order by ' + sortFullExp + ' LIMIT 1000';
			else
				db_query = db_query + ' and IsDeleted=false order by ' + sortFullExp + ' LIMIT 1000';
		}
		
		if (this.displayType == Action.EXPORT_EXCEL_ALL) {
			db_query = 'Select Id, Name, PRH_Account_Type__c, format(lastModifiedDate), PRH_ICT_Account__c, PRH_Located_in_a_hotel__c, OwnerId, PRH_Owner_2__c, PRH_Account_Region__c, PRH_Account_Market_Company__c, PRH_Account_Country__c, PRH_City__c, Owner.Name, PRH_Owner_2__r.Name From PRH_Luxury_Accounts__c where IsDeleted=false order by Name LIMIT 32000';
		}
		System.debug('query : '+ db_query);
		
		return db_query;
    }   
	
    public List<PRH_Luxury_Accounts__c> getPRH_accounts() {
		String db_query;
		List<PRH_Luxury_Accounts__c> lis_allAcc;
		
		if (this.displayType == Action.ONLOAD) {
			System.debug('--> appel getPRH_accounts() : displayType == Action.ONLOAD');
			db_query = constructRequest('');
		} else if (this.displayType == Action.SEARCH) {
			System.debug('--> appel getPRH_accounts() : displayType == Action.SEARCH');
            if (String.isEmpty(this.alpha)){
                db_query = constructRequest('');
            }else{
                db_query = constructRequest(this.alpha);
            }
		} else if (this.displayType == Action.EXPORT_EXCEL) {
			System.debug('--> appel getPRH_accounts() : displayType == Action.EXPORT_EXCEL');
			db_query = constructRequest('');
		} else if (this.displayType == Action.EXPORT_EXCEL_ALL) {
			System.debug('--> appel getPRH_accounts() : displayType == Action.EXPORT_EXCEL_ALL');
			db_query = 'Select Id, Name, PRH_Account_Type__c, format(lastModifiedDate), PRH_ICT_Account__c, PRH_Located_in_a_hotel__c, OwnerId, PRH_Owner_2__c, PRH_Account_Region__c, PRH_Account_Market_Company__c, PRH_Account_Country__c, PRH_City__c, Owner.Name, PRH_Owner_2__r.Name From PRH_Luxury_Accounts__c where IsDeleted=false order by Name LIMIT 32000';
        } 
        PRH_accounts = Database.query(db_query);	
		System.debug(PRH_accounts.size() + ' account(s) returned.'); 

		// Write all accounts info 
		//System.debug(PRH_accounts);
        
        con = new ApexPages.StandardSetController(PRH_accounts);
        // sets the number of records in each page set
        con.setPageSize(50);
		
		// Retrieve the real number of Iconic Accounts in Data Base
		db_query = 'Select Id From PRH_Luxury_Accounts__c where IsDeleted=false LIMIT 50000';
		lis_allAcc = Database.query(db_query);	
		PRH_nbIconicAccounts = lis_allAcc.size();
		System.debug('There are ' + PRH_nbIconicAccounts + ' Iconic account(s) in DB.'); 
        
        return PRH_accounts;
	}

	
	public void firstDisplay() {
        System.debug('--> appel firstDisplay()');
		this.displayType = Action.ONLOAD;		
        getPRH_accounts();
        return;
    }
	
    public void affichSearchResult() {	
        System.debug('--> appel affichSearchResult()');
		this.displayType = Action.SEARCH;
        this.alpha='';
		this.sortOnColumnToDo = False;
		getPRH_accounts();
        return;
    }
    
    public void affichSearchResultAlpha() {
		System.debug('--> appel affichSearchResultAlpha()');
		this.displayType = Action.SEARCH;
        getPRH_accounts();
        return;
	}

	public void clearSearchCriteria() {	
        System.debug('--> appel clearSearchCriteria()');
		Schema.DescribeFieldResult accountTypeFieldDescription = PRH_Luxury_Accounts__c.PRH_Account_Type__c.getDescribe(); 
        Integer nbOpt = 0;
        Integer nbTotalOptions = PRH_accountTypeOptions.size();
		this.displayType = Action.ONLOAD;
        this.alpha='';
		this.sortOnColumnToDo = False;
		
		this.PRH_Account_Type = null;
		this.PRH_Account_Name = null;
		this.PRH_Owner = null;
		this.PRH_Owner_2 = null;
        this.PRH_Account_Not_Modified_Since = null;
        this.PRH_Collect_Not_Modified_Since = null;
		//this.PRH_High_Networth_Individuals = null;
		this.PRH_Suppress_and_archive = null;
		this.PRH_Located_in_a_hotel = null;
		this.PRH_Account_Market_Company = null;  
        this.PRH_ICT_Account = null; 
        //this.PRH_Full_Le_Cercle = null;   // LCS-1324
        this.PRH_Le_Cercle_Brand_Presence = null;
		this.PRH_Account_City = null;
        this.account_Types = new String[]{};
		        
		getPRH_accounts();
        return;
    }
	
	public void displayRecords() {
        System.debug('--> appel displayRecords()');
        return;
    }
	
    public List<PRH_Luxury_Accounts__c> PRH_accounts_paginated
    {
        get
        {
            if(con != null)
                return (List<PRH_Luxury_Accounts__c>)con.getRecords();
            else
                return null ;
        }
        set;
    }

    public void updateUrlExcelExport(){
        String encoded_acc_name = '';
		String encoded_acc_owner = '';
		String encoded_acc_owner2 = '';
		String encoded_acc_type = '';
		String encoded_acc_region = '';
		String encoded_acc_country = '';
		String encoded_acc_city = '';
		String encoded_acc_mc = '';
		String encoded_acc_nbp = '';
		String url_param = '';
		Boolean flagFirstParam = true;
		
		this.sortOnColumnToDo = False;
		this.displayType = Action.EXPORT_EXCEL;
		
        if (!String.isEmpty(this.PRH_Account_Name)){
            encoded_acc_name = EncodingUtil.urlEncode(this.PRH_Account_Name, 'UTF-8');//EncodingUtil.urlEncode(lux_acc.Name, 'UTF-8');
            flagFirstParam = false;
            url_param = url_param + 'acc_name=' + encoded_acc_name;
        }
        if (!String.isEmpty(PRH_Owner)){
            encoded_acc_owner = EncodingUtil.urlEncode(PRH_Owner, 'UTF-8');
			if (flagFirstParam == true) {
				flagFirstParam = false;
				url_param = url_param + 'acc_owner=' + encoded_acc_owner;
			} else
				url_param = url_param + '&acc_owner=' + encoded_acc_owner;
        }
        if (!String.isEmpty(PRH_Owner_2)){
            encoded_acc_owner2 = EncodingUtil.urlEncode(PRH_Owner_2, 'UTF-8');
			if (flagFirstParam == true) {
				flagFirstParam = false;
				url_param = url_param + 'acc_owner2=' + encoded_acc_owner2;
			} else
				url_param = url_param + '&acc_owner2=' + encoded_acc_owner2;
        }
		if (this.account_Types.size()>0){
            string acc_type = string.join(this.account_Types,',');
            encoded_acc_type = EncodingUtil.urlEncode(acc_type, 'UTF-8');
			if (flagFirstParam == true) {
				flagFirstParam = false;
				url_param = url_param + 'acc_type=' + encoded_acc_type;
			} else
				url_param = url_param + '&acc_type=' + encoded_acc_type;
        }
		if ((this.PRH_Account_Region != 'None') && (this.PRH_Account_Region != null)){
            encoded_acc_region = EncodingUtil.urlEncode(this.PRH_Account_Region, 'UTF-8');
			if (flagFirstParam == true) {
				flagFirstParam = false;
				url_param = url_param + 'acc_region=' + encoded_acc_region;
			} else
				url_param = url_param + '&acc_region=' + encoded_acc_region;
        }
        if ((this.PRH_Account_Country != 'None') && (this.PRH_Account_Country != null)){
            encoded_acc_country = EncodingUtil.urlEncode(this.PRH_Account_Country, 'UTF-8'); 
			if (flagFirstParam == true) {
				flagFirstParam = false;
				url_param = url_param + 'acc_country=' + encoded_acc_country;
			} else
				url_param = url_param + '&acc_country=' + encoded_acc_country;
        }
        if ((this.PRH_Account_Market_Company != 'None') && (this.PRH_Account_Market_Company != null)){
            encoded_acc_mc = EncodingUtil.urlEncode(this.PRH_Account_Market_Company, 'UTF-8');
			if (flagFirstParam == true) {
				flagFirstParam = false;
				url_param = url_param + 'acc_mc=' + encoded_acc_mc;
			} else
				url_param = url_param + '&acc_mc=' + encoded_acc_mc;
        }
		if (!String.isEmpty(PRH_Account_City)){
            encoded_acc_city = EncodingUtil.urlEncode(PRH_Account_City, 'UTF-8');
			if (flagFirstParam == true) {
				flagFirstParam = false;
				url_param = url_param + 'acc_city=' + encoded_acc_city;
			} else
				url_param = url_param + '&acc_city=' + encoded_acc_city;
        }

		url_param = url_param + '&export_type=' + EncodingUtil.urlEncode('normal', 'UTF-8');
		//this.url = '/apex/PRH_Iconic_Accounts_ReportExcel?' + url_param + '&acc_hni=' + this.PRH_High_Networth_Individuals/*lux_acc.PRH_High_Networth_Individuals__c*/ + '&acc_sa=' + this.PRH_Suppress_and_archive + '&acc_lh=' + this.PRH_Located_in_a_hotel + '&acc_ict=' + this.PRH_ICT_Account  + '&acc_flc=' + this.PRH_Full_Le_Cercle;
		//this.url = '/apex/PRH_Iconic_Accounts_ReportExcel?' + url_param + '&acc_hni=' + this.PRH_High_Networth_Individuals/*lux_acc.PRH_High_Networth_Individuals__c*/ + '&acc_sa=' + this.PRH_Suppress_and_archive/*lux_acc.PRH_Suppress_and_archive__c*/ + '&acc_lh=' + this.PRH_Located_in_a_hotel + '&acc_ict=' + this.PRH_ICT_Account  + '&acc_flc=' + this.PRH_Full_Le_Cercle;
		/* LCS-1324
		this.url = '/apex/PRH_Iconic_Accounts_ReportExcel?' + url_param + '&acc_sa=' + this.PRH_Suppress_and_archive + '&acc_lh=' + this.PRH_Located_in_a_hotel + '&acc_ict=' + this.PRH_ICT_Account  + '&acc_flc=' + this.PRH_Full_Le_Cercle + '&acc_lcbp=' + this.PRH_Le_Cercle_Brand_Presence + '&acc_nms=' + this.PRH_Account_Not_Modified_Since + '&col_nms=' + this.PRH_Collect_Not_Modified_Since;
		*/
		this.url = '/apex/PRH_Iconic_Accounts_ReportExcel?' + url_param + '&acc_sa=' + this.PRH_Suppress_and_archive/*lux_acc.PRH_Suppress_and_archive__c*/ + '&acc_lh=' + this.PRH_Located_in_a_hotel + '&acc_ict=' + this.PRH_ICT_Account  /*+ '&acc_flc=' + this.PRH_Full_Le_Cercle */ + '&acc_lcbp=' + this.PRH_Le_Cercle_Brand_Presence + '&acc_nms=' + this.PRH_Account_Not_Modified_Since + '&col_nms=' + this.PRH_Collect_Not_Modified_Since;

		System.debug('--> updateUrlExcelExport() - url : '+ this.url);
	}
    
	public void updateUrlExcelExportAll(){
		String url_param = '';
		
		this.sortOnColumnToDo = False;
		this.displayType = Action.EXPORT_EXCEL_ALL;
	
		url_param = url_param + 'export_type=' + EncodingUtil.urlEncode('all', 'UTF-8');
		this.url = '/apex/PRH_Iconic_Accounts_ReportExcel?' + url_param;
		System.debug('--> updateUrlExcelExportAll() - url : '+ this.url);
	}
	
    public Integer getPRH_nbIconicAccounts() {
        return PRH_nbIconicAccounts;
    }
	

	public String getPRH_criteria() {
		return PRH_criteria;
	}
	
	public Boolean getIsClassic() {
		return (UserInfo.getUiThemeDisplayed() == 'Theme3');
	}

	private void autoRun() 
    { 
        //this.PRH_High_Networth_Individuals = false;
    	//this.PRH_Suppress_and_archive = false;
        
        Schema.DescribeFieldResult accountTypeFieldDescription = PRH_Luxury_Accounts__c.PRH_Account_Type__c.getDescribe(); 
		Schema.DescribeFieldResult accountRegionFieldDescription = PRH_Luxury_Accounts__c.PRH_Account_Region__c.getDescribe(); 
		Schema.DescribeFieldResult accountMarketCompanyFieldDescription = PRH_Luxury_Accounts__c.PRH_Account_Market_Company__c.getDescribe(); 
		Schema.DescribeFieldResult accountCountryFieldDescription = PRH_Luxury_Accounts__c.PRH_Account_Country__c.getDescribe(); 

        PRH_accountTypeOptions = new list<SelectOption>(); 
        for (Schema.Picklistentry picklistEntry : accountTypeFieldDescription.getPicklistValues()) 
        { 
            PRH_accountTypeOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel())); 
        }
        PRH_accountTypeOptions.sort();
		
        PRH_accountRegionOptions = new list<SelectOption>(); 
		PRH_accountRegionOptions.add(new SelectOption('None','--None--'));
        for (Schema.Picklistentry picklistEntry : accountRegionFieldDescription.getPicklistValues()) 
        { 
            PRH_accountRegionOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel())); 
        } 
		
        PRH_accountMarketCompanyOptions = new list<SelectOption>(); 
		PRH_accountMarketCompanyOptions.add(new SelectOption('None','--None--'));
        for (Schema.Picklistentry picklistEntry : accountMarketCompanyFieldDescription.getPicklistValues()) 
        { 
            PRH_accountMarketCompanyOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel())); 
        } 
		
        PRH_accountCountryOptions = new list<SelectOption>(); 
		PRH_accountCountryOptions.add(new SelectOption('None','--None--'));
        for (Schema.Picklistentry picklistEntry : accountCountryFieldDescription.getPicklistValues()) 
        { 
            PRH_accountCountryOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel())); 
        } 
		
		PRH_highNetworthIndividualsOptions = new list<SelectOption>(); 
		PRH_highNetworthIndividualsOptions.add(new SelectOption('None','--None--'));
		PRH_highNetworthIndividualsOptions.add(new SelectOption('Yes','Yes'));
		PRH_highNetworthIndividualsOptions.add(new SelectOption('No','No'));
		
		PRH_suppressAndArchiveOptions = new list<SelectOption>(); 
		PRH_suppressAndArchiveOptions.add(new SelectOption('None','--None--'));
		PRH_suppressAndArchiveOptions.add(new SelectOption('Yes','Yes'));
		PRH_suppressAndArchiveOptions.add(new SelectOption('No','No'));

		PRH_locatedInAHotelOptions = new list<SelectOption>(); 
		PRH_locatedInAHotelOptions.add(new SelectOption('None','--None--'));
		PRH_locatedInAHotelOptions.add(new SelectOption('Yes','Yes'));
		PRH_locatedInAHotelOptions.add(new SelectOption('No','No'));
        
        PRH_ictAccountOptions = new list<SelectOption>(); 
		PRH_ictAccountOptions.add(new SelectOption('None','--None--'));
		PRH_ictAccountOptions.add(new SelectOption('Yes','Yes'));
		PRH_ictAccountOptions.add(new SelectOption('No','No'));

        PRH_fullLeCercleOptions = new list<SelectOption>(); 
		PRH_fullLeCercleOptions.add(new SelectOption('None','--None--'));
		PRH_fullLeCercleOptions.add(new SelectOption('Yes','Yes'));
		PRH_fullLeCercleOptions.add(new SelectOption('No','No'));        
        
        PRH_leCercleBrandPresenceOptions = new list<SelectOption>(); 
        PRH_leCercleBrandPresenceOptions.add(new SelectOption('None','--None--'));
		PRH_leCercleBrandPresenceOptions.add(new SelectOption('Yes','Yes'));
		PRH_leCercleBrandPresenceOptions.add(new SelectOption('No','No'));    

        PRH_accountNotModifiedSinceOptions = new list<SelectOption>();
        PRH_accountNotModifiedSinceOptions.add(new SelectOption('None','--None--'));
		PRH_accountNotModifiedSinceOptions.add(new SelectOption('3 months','3 months'));
		PRH_accountNotModifiedSinceOptions.add(new SelectOption('6 months','6 months'));
		PRH_accountNotModifiedSinceOptions.add(new SelectOption('12 months','12 months'));

	    PRH_collectNotModifiedSinceOptions = new list<SelectOption>();
        PRH_collectNotModifiedSinceOptions.add(new SelectOption('None','--None--'));
		PRH_collectNotModifiedSinceOptions.add(new SelectOption('3 months','3 months'));
		PRH_collectNotModifiedSinceOptions.add(new SelectOption('6 months','6 months'));
		PRH_collectNotModifiedSinceOptions.add(new SelectOption('12 months','12 months'));
    } 
    
	/*public void sortByAccountName() { 
        System.debug('--> sortByAccountName() ');
        this.sortOrder = 'Name'; 
		this.sortMode = this.sortModeAccName; 
        this.displayType = Action.SEARCH;
		this.sortOnColumnToDo = True;
        getPRH_accounts();
		if (this.sortModeAccName == 'ASC') {
			this.sortModeAccName = 'DESC';
		} else {
			this.sortModeAccName = 'ASC';
		}
    } 
	
	public void sortByAccountRegion() { 
        System.debug('--> sortByAccountRegion() ');
        this.sortOrder = 'PRH_Account_Region__c'; 
		this.sortMode = this.sortModeAccRegion; 
        this.displayType = Action.SEARCH;
		this.sortOnColumnToDo = True;
        getPRH_accounts();
		if (this.sortModeAccRegion == 'ASC') {
			this.sortModeAccRegion = 'DESC';
		} else {
			this.sortModeAccRegion = 'ASC';
		}
    } 
	
	public void sortByAccountCountry() { 
        System.debug('--> sortByAccountCountry() ');
        this.sortOrder = 'PRH_Account_Country__c'; 
		this.sortMode = this.sortModeAccCountry; 
        this.displayType = Action.SEARCH;
		this.sortOnColumnToDo = True;
        getPRH_accounts();
		if (this.sortModeAccCountry == 'ASC') {
			this.sortModeAccCountry = 'DESC';
		} else {
			this.sortModeAccCountry = 'ASC';
		}
    } 

	public void sortByAccountMarketCompany() { 
        System.debug('--> sortByAccountMarketCompany() ');
        this.sortOrder = 'PRH_Account_Market_Company__c'; 
		this.sortMode = this.sortModeAccMarketCompany; 
        this.displayType = Action.SEARCH;
		this.sortOnColumnToDo = True;
        getPRH_accounts();
		if (this.sortModeAccMarketCompany == 'ASC') {
			this.sortModeAccMarketCompany = 'DESC';
		} else {
			this.sortModeAccMarketCompany = 'ASC';
		}
    } 
	
	public void sortByAccountCity() { 
        System.debug('--> sortByAccountCity() ');
        this.sortOrder = 'PRH_City__c'; 
		this.sortMode = this.sortModeAccCity; 
        this.displayType = Action.SEARCH;
		this.sortOnColumnToDo = True;
        getPRH_accounts();
		if (this.sortModeAccCity == 'ASC') {
			this.sortModeAccCity = 'DESC';
		} else {
			this.sortModeAccCity = 'ASC';
		}
    } 
	
	public void sortByAccountOwner2() { 
        System.debug('--> sortByAccountOwner2() ');
        this.sortOrder = 'PRH_Owner_2__c'; 
		this.sortMode = this.sortModeAccOwner2; 
        this.displayType = Action.SEARCH;
		this.sortOnColumnToDo = True;
        getPRH_accounts();
		if (this.sortModeAccOwner2 == 'ASC') {
			this.sortModeAccOwner2 = 'DESC';
		} else {
			this.sortModeAccOwner2 = 'ASC';
		}
    } 
	
	public void sortByAccountOwner() { 
        System.debug('--> sortByAccountOwner() ');
        this.sortOrder = 'Owner.Name'; 
		this.sortMode = this.sortModeAccOwner; 
        this.displayType = Action.SEARCH;
		this.sortOnColumnToDo = True;
        getPRH_accounts();
		if (this.sortModeAccOwner == 'ASC') {
			this.sortModeAccOwner = 'DESC';
		} else {
			this.sortModeAccOwner = 'ASC';
		}
    } */

    /**
    * ViewData allows us to filter on header column
    * */
    public PageReference ViewData() {
        this.displayType = Action.SEARCH;

        this.sortOrder = 'Name'; 
		this.sortMode = this.sortModeAccName; 
		this.sortOnColumnToDo = True;
        getPRH_accounts();

        //PageReference tempPage = ApexPages.currentPage();            
        //tempPage.setRedirect(true);
        //return tempPage;

        return null;
    }
	
	public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            // if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }

    public String getSortDirection()
    {
        // if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }

    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }

    /*public String affichSearchResult()
    {
        // if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }*/

    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext
    {
        get
        {
            return con.getHasNext();
        }
        set;
    }
 
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious
    {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
 
    //Page number of the current displaying records
    public Integer pageNumber
    {
        get
        {
            return con.getPageNumber();
        }
        set;
    }

    //Returns the previous page of records
    public void previous()
    {
        con.previous();
    }
 
    //Returns the next page of records
    public void next()
    {
        con.next();
    }
    
    //Returns the first page of records
    public void first()
    {
        con.first();
    }
 
    //Returns the last page of records
    public void last()
    {
        con.last();
    }
}