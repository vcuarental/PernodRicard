public with sharing class GVP_AssignRackController {
	@testVisible
	private List<gvp__Label__c> labels;
	@testVisible
	private List<gvp__Program__c> programs;

	public List<PosPlacementWrapper> posPlacements { get; set; }
	public Integer selectedIndex { get; set; }

	public class PosPlacementWrapper {
		public String accountName { get; set; }
		public gvp__POS_Placement__c placement { get; set; }
		public List<gvp__POS_Material__c> availableRacks { get; set; }
		public Integer counter { get; set; }

		public PosPlacementWrapper(Account pAccount, List<gvp__POS_Material__c> pRacks, Integer pCounter) {
			if (pAccount == null) {
				accountName = '';
				placement = new gvp__POS_Placement__c();
			} else {
				accountName = pAccount.Name;
				placement = new gvp__POS_Placement__c(gvp__Account__c = pAccount.Id);
			}
			availableRacks = pRacks;
			counter = pCounter;
		}

		public List<SelectOption> getPosMaterials() {
			Set<Id> uniquePosMaterial = new Set<Id>();
			List<SelectOption> options = new List<SelectOption>();
			if (availableRacks == null) {
				options.add(new SelectOption('','--None--'));
				return options;
			}
			for (gvp__POS_Material__c currentMaterial : availableRacks) {
				if (uniquePosMaterial.contains(currentMaterial.Id)) {
					continue;
				}
				uniquePosMaterial.add(currentMaterial.Id);
				options.add(
					new SelectOption(
						currentMaterial.Id,
						currentMaterial.Name + ' (' + currentMaterial.GVP_Available__c + ')'
					)
				);
			}
			return options;
		}
	}

	public GVP_AssignRackController() {
		String accountIds = ApexPages.currentPage().getParameters().get('idArray');
		if (String.isBlank(accountIds)) {
			return;
		}

		loadData(accountIds.split(','));
	}

	public void loadData(List<String> pAccountIds) {
		Map<Id, Account> accounts = getAccounts(pAccountIds);
		Map<Id, List<gvp__POS_Material__c>> materialsByTerritoryId = fetchPosMaterialByTerritory(
			getTerritoryIdsFromAccounts(
				accounts.values()
			)
		);
		labels = fetchLabels();
		programs = fetchPrograms();
		posPlacements = createPosPlacements(
			accounts.values(),
			materialsByTerritoryId
		);
	}

	public List<SelectOption> getLabels() {
		List<SelectOption> options = new List<SelectOption>();
		for (gvp__Label__c currentLabel : labels) {
			options.add(
				new SelectOption(
					currentLabel.Id,
					currentLabel.Name
				)
			);
		}
		return options;
	}

	public List<SelectOption> getPrograms() {
		List<SelectOption> options = new List<SelectOption>();
		for (gvp__Program__c currentProgram : programs) {
			options.add(
				new SelectOption(
					currentProgram.Id,
					currentProgram.Name
				)
			);
		}
		return options;
	}

	private static Map<Id, Account> getAccounts(List<String> pAccountIds) {
		return new Map<Id, Account>([SELECT
		                                 Id,
		                                 Name,
		                                 gvp__Territory__c
		                             FROM
		                                 Account
		                             WHERE
		                                 Id IN :pAccountIds
		                             ORDER By Name]);
	}

	private static Set<Id> getTerritoryIdsFromAccounts(List<Account> pAccounts) {
		Set<Id> territoryIds = new Set<Id>();
		if (pAccounts == null || pAccounts.isEmpty()) {
			return territoryIds;
		}

		for (Account currentAccount : pAccounts) {
			territoryIds.add(currentAccount.gvp__Territory__c)	;
		}
		return territoryIds;
	}

	private static Map<Id, List<gvp__POS_Material__c>> fetchPosMaterialByTerritory(Set<Id> pTerritoryIds) {
		Map<Id, List<gvp__POS_Material__c>> posMaterialsByTerritoryId = new Map<Id, List<gvp__POS_Material__c>>();
		//add "All" list for accounts with territores that have no specific POS Materials
		posMaterialsByTerritoryId.put(null, [SELECT
		                                         Id,
		                                         Name,
		                                         GVP_Available__c
		                                     FROM
		                                         gvp__POS_Material__c
		                                     WHERE
		                                         GVP_Status__c IN ('Available', 'Active') AND
		                                         GVP_Province__c = null
		                                     ORDER By
		                                         Name
		                                     LIMIT
		                                         1000]);

		if (pTerritoryIds == null || pTerritoryIds.isEmpty()) {
			return posMaterialsByTerritoryId;
		}

		//make sure null is not in the list as its already been added
		pTerritoryIds.remove(null);
		if (pTerritoryIds.isEmpty()) {
			return posMaterialsByTerritoryId;
		}

		for (gvp__POS_Material__c currentMaterial : [SELECT
		                                                 Id,
		                                                 Name,
		                                                 GVP_Available__c,
		                                                 GVP_Province__c
		                                             FROM
		                                                 gvp__POS_Material__c
		                                             WHERE
		                                                 GVP_Status__c IN ('Available', 'Active') AND
		                                                 GVP_Province__c IN :pTerritoryIds
		                                             ORDER By
		                                                 Name
		                                             LIMIT
		                                                 1000]) {
			if (!posMaterialsByTerritoryId.containsKey(currentMaterial.GVP_Province__c)) {
				posMaterialsByTerritoryId.put(currentMaterial.GVP_Province__c, new List<gvp__POS_Material__c>());
			}
			posMaterialsByTerritoryId.get(currentMaterial.GVP_Province__c).add(currentMaterial);
		}
		return posMaterialsByTerritoryId;
	}

	private static List<gvp__Label__c> fetchLabels() {
		return [SELECT
		            Id,
		            Name
		        FROM
		            gvp__Label__c
		        WHERE
		            gvp__Visible_on_Auth__c = true
		        ORDER BY
		            Name
		        LIMIT
		            1000];
	}

	private static List<gvp__Program__c> fetchPrograms() {
		return [SELECT
		            Id,
		            Name
		        FROM
		            gvp__Program__c
		        WHERE
		            gvp__Status__c = 'Active'
		        ORDER BY
		            Name
		        LIMIT
		            1000];
	}

	private static List<PosPlacementWrapper> createPosPlacements(List<Account> pAccounts, Map<Id, List<gvp__POS_Material__c>> pPosMaterialByTerritoryId) {
		List<PosPlacementWrapper> placements = new List<PosPlacementWrapper>();
		List<gvp__POS_Material__c> nullPosMaterialsList = pPosMaterialByTerritoryId.get(null);
		if (pAccounts == null || pAccounts.isEmpty()) {
			placements.add(
				new PosPlacementWrapper(
					null,
					nullPosMaterialsList,
					0
				)
			);
			return placements;
		}

		PosPlacementWrapper wrapper;
		Integer counter = 0;
		List<gvp__POS_Material__c> accountPosMaterials;
		for (Account currentAccount : pAccounts) {
			accountPosMaterials = new List<gvp__POS_Material__c>();
			if (currentAccount.gvp__Territory__c == null || !pPosMaterialByTerritoryId.containsKey(currentAccount.gvp__Territory__c)) {
				//if account is null or territory not in the list, just add the default "NULL" list
				accountPosMaterials.addAll(nullPosMaterialsList);
			} else {
				//Account's territory is not null and is in the list, add territory specific list and "NULL" list
				accountPosMaterials.addAll(pPosMaterialByTerritoryId.get(currentAccount.gvp__Territory__c));
				accountPosMaterials.addAll(nullPosMaterialsList);
			}
			wrapper = new PosPlacementWrapper(currentAccount, accountPosMaterials, counter);
			placements.add(wrapper);
			counter++;
		}
		return placements;
	}

	@testVisible
	private static String savePosPlacements(List<PosPlacementWrapper> pPosPlacements) {
		if (pPosPlacements == null || pPosPlacements.isEmpty()) {
			return 'No Placements to save';
		}
		try {
			List<gvp__POS_Placement__c> placements = new List<gvp__POS_Placement__c>();
			for (PosPlacementWrapper currentWrapper : pPosPlacements) {
				placements.add(currentWrapper.placement);
			}
			insert placements;
			return '';
		} catch (Exception e) {
			return e.getMessage();
		}
	}

	public PageReference savePosPlacement() {
		String result = savePosPlacements(posPlacements);
		if (String.isBlank(result)) {
			return new PageReference('/' + posPlacements[0].placement.Id.getSObjectType().getDescribe().getKeyPrefix());
		}

		ApexPages.addMessage(
			new ApexPages.Message(
				ApexPages.Severity.ERROR, result
			)
		);
		return null;
	}

	private static void reindexPlacements(List<PosPlacementWrapper> pPosPlacements) {
		if (pPosPlacements == null || pPosPlacements.isEmpty()) {
			return;
		}
		Integer counter = 0;
		for (PosPlacementWrapper currentWrapper : pPosPlacements) {
			currentWrapper.counter = counter;
			counter++;
		}
	}

	public PageReference removePosPlacement() {
		posPlacements.remove(selectedIndex);
		reindexPlacements(posPlacements);
		return null;
	}
}