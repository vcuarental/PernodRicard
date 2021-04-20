({
	fireRenderMatchScreen: function(settlementId) {
		var settlementShowEvent = $A.get('e.c:EUR_ISP_SettlementShowEvent');
		if (settlementShowEvent != null && settlementShowEvent != undefined) {
			settlementShowEvent.setParams({
				settlementId: settlementId
			}).fire();
		}
	},
	fireRenderSpend: function(cmp, spendId, spendActivityId, activityTypeId) {
		var showSpendEvent = cmp.getEvent('ShowSpendEvent');
		if (showSpendEvent != null && showSpendEvent != undefined) {
			showSpendEvent.setParams({
				spendId        : spendId,
				spendActivityId: spendActivityId,
				spendTypeId    : activityTypeId
			}).fire();
		}
	},
	fireRenderBrandTable: function(spendId, spendActivityType) {
		if (!spendActivityType || !spendActivityType.EUR_ISP_Product_Level_Of_Input__c) {
			return;
		}
		var brandCmpTableShowEvent = $A.get("e.c:EUR_ISP_BrandCmpTableShowEvent");
		if (brandCmpTableShowEvent != null && brandCmpTableShowEvent != undefined) {
			brandCmpTableShowEvent.setParams({
				spendId   : spendId,
				objectName: spendActivityType.EUR_ISP_Product_Level_Of_Input__c
			}).fire();
		}
	},
	setActivities: function(cmp, params, callback) {
		if (!cmp.isValid()) {
			return;
		}
		var action = cmp.get('c.getSpendActivities');
		if (action != null && action != undefined) {
			action.setParams({
				spendId   : params.spendId,
				vendorId  : params.vendorId
			});
			action.setCallback(this, function(response) {
				if (!cmp.isValid()) {
					return;
				}
	
				var data = [];
				if (response.getState() === 'SUCCESS') {
					data = response.getReturnValue()  || [];
				}
				callback(data);
			});
			$A.enqueueAction(action);
		}
	},
	generateTableConfig: function(cmp, tableData) {
		var that = this,
			UserPermissions = cmp.get('v.UserPermissions'),
			isDeProject = UserPermissions.PROJECT_NAME === 'DE_SFA_PROJECT',
			ObjectSettings = UserPermissions.EUR_ISP_Spend_Activity__c,
			tableData = cmp.get('v.activities'),
			spendId = cmp.get('v.spendId'),
			MAX_ITEMS_PER_PAGE = 5,
			DATE_FORMAT = 'DD/MM/YYYY';

		return {
			columns: [
				{
					field: "EUR_ISP_Spend_Activity_Type_Name__c",
					title: ObjectSettings.fields.EUR_ISP_Spend_Activity_Type__c.label//"Activity Type"
				},
				{
					field: "Name",
					title: ObjectSettings.fields.Name.label,//"Activity ID",
					formatter: function(value, row, index) {
						return '<a href="javascript:void(0);" data-row-id="' + row.Id + '">' + row.Name + '</a>';
					}
				},
				{
					field: "EUR_ISP_Total_Activity_Amount__c",
					title: ObjectSettings.fields.EUR_ISP_Total_Activity_Amount__c.label,//"Total Amount Spend",
					formatter: function(value, row, index) {
						var currString = value ? $A.localizationService.formatCurrency(value, value) : '0.00';
						currString = currString.replace(/[^\d+\,\.]/g, '');
						return row.CurrencyIsoCode + ' ' + currString;
					}
				},
				{
					field: "EUR_ISP_Available_Amount__c",
					title: UserPermissions.EUR_ISP_Spend__c.fields.EUR_ISP_Available_Amount__c.label, //"Available Amount",
					visible: isDeProject,
					formatter: function(value, row, index) {
						value = (row.EUR_ISP_Total_Activity_Amount__c || 0) - (row.EUR_ISP_Total_Matched__c || 0);
						var currString = value ? $A.localizationService.formatCurrency(value, value) : '0.00';
						currString = currString.replace(/[^\d+\,\.]/g, '');
						return row.CurrencyIsoCode + ' ' + currString;
					}
				},
				{
					field: "EUR_ISP_Total_Matched__c",
					title: ObjectSettings.fields.EUR_ISP_Total_Matched__c.label,//"Matched Amount",
					visible: isDeProject,
					formatter: function(value, row, index) {
						var currString = value ? $A.localizationService.formatCurrency(value, value) : '0.00';
						currString = currString.replace(/[^\d+\,\.]/g, '');
						return row.CurrencyIsoCode + ' ' + currString;
					}
				},
				{
					field: "EUR_ISP_Activity_Start_Date__c",
					title: ObjectSettings.fields.EUR_ISP_Activity_Start_Date__c.label,//"Start Date",
					formatter: function(value, row, index) {
						var dateString = value ? $A.localizationService.formatDateTime(value, DATE_FORMAT) : '-';
						return dateString;
					}
				},
				{
					field: "EUR_ISP_Activity_End_Date__c",
					title: ObjectSettings.fields.EUR_ISP_Activity_End_Date__c.label,//"End Date",
					formatter: function(value, row, index) {
						var dateString = value ? $A.localizationService.formatDateTime(value, DATE_FORMAT) : '-';
						return dateString;
					}
				},
				{
					field: "RecordType",
					title: ObjectSettings.fields.RecordTypeId.label,//"Record Type",
					visible: !isDeProject,
					formatter: function(value, row, index) {
						return value? value.Name : '-';
					}
				},
				// {
				// 	field: "EUR_ISP_Status__c",
				// 	title: ObjectSettings.fields.EUR_ISP_Status__c.label,//"Status",
				// 	visible: isDeProject
				// },
				{
					field: "EUR_ISP_Approval_Status__c",
					title: ObjectSettings.fields.EUR_ISP_Status__c.label,//"Status",
					visible: !isDeProject
				},
				{
					field: "Settlement_Lines_EU__r",
					title: $A.get('$Label.c.EUR_ISP_INVOICING_TEXT'),
					formatter: function (value, row, index) {
						if (!value || !value.length) {
							return '-';
						}

						var values = [];
						value.forEach(function(item) {
							var text = ['<a href="javascript:void(0);" data-settlement-id="',
											item.EUR_ISP_Settlement__c,
										'">',
										(isDeProject ? item.EUR_ISP_Settlement__r.EUR_ISP_Internal_Doc_Number__c : item.EUR_ISP_Settlement__r.EUR_ISP_Vendor_Invoice_Number__c),
										' ('];

							var currString = item.EUR_ISP_Amount__c ? $A.localizationService.formatCurrency(item.EUR_ISP_Amount__c) : '0.00';
							currString = currString.replace(/[^\d+\,\.]/g, '');

							text.push(row.CurrencyIsoCode + ' ' + currString);
							text.push(')</a>');
							values.push(text.join(''));
						});
						return values.join('<br/>');
					}
				}
			],
			data: tableData,
			toggle: "table",
			search: tableData.length > MAX_ITEMS_PER_PAGE,
			pagination: tableData.length > MAX_ITEMS_PER_PAGE,
			pageSize: MAX_ITEMS_PER_PAGE,
			pageList: [5, 10, 25],
			onClickCell: function(field, value, row, $element) {
				if (field === 'Name') {
					$A.run(function() {
						that.fireRenderSpend(cmp, spendId, row.Id, row.EUR_ISP_Spend_Activity_Type__c);
						that.fireRenderBrandTable(spendId, row.EUR_ISP_Spend_Activity_Type__r);
					});
				}
			},
			onPostBody: function() {
				$A.run(function() {
					that.addEvents(cmp);
				});
			}
		};
	},
	addEvents: function(cmp) {
		var that = this;
		var $contentTable = $('#' + cmp.get('v.tableId'));
		$contentTable.find('tr > td:last-child').off('click').on('click', 'a', function(e) {
			if (this.dataset && this.dataset.settlementId) {
				that.fireRenderMatchScreen(this.dataset.settlementId);
			}
		});
	},
	setTableData: function(cmp) {
		if (!cmp.isValid()) {
			return;
		}

		var that = this;
		var $contentTable = $('#' + cmp.get('v.tableId'));
		var tableData = cmp.get('v.activities');
		if ($contentTable) {
			if (!cmp.get('v.isInitialized')) {
				cmp.set('v.isInitialized', true);
				$contentTable.bootstrapTable(this.generateTableConfig(cmp));
			} else {
				$contentTable.bootstrapTable('load', tableData);
			}
			$contentTable.removeClass('slds-hide');
			$contentTable.closest('div.slds-scrollable--x').find('table.table-content--no').addClass('slds-hide');
		}
	}
})