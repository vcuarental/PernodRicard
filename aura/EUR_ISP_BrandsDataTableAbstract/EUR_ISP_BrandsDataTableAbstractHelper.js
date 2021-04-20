({
	fireBrandSelected: function(rowData) {
		$A.get('e.c:EUR_ISP_BrandSelectedEvent').setParams({
			Brand: {
				Id: rowData.Id,
				Name: rowData.Name
			}
		}).fire();
	},
	getBrandData: function(cmp, callback) {
		var action = cmp.get("c." + cmp.get('v.action'));
		action.setParams({
			spendId: cmp.get('v.spendId')
		});
		action.setCallback(this, function(response) {
			var data = [];
			if (cmp.isValid() && response.getState() === "SUCCESS") {
				data = response.getReturnValue();
			}
			callback(data);
		});
		$A.enqueueAction(action);
	},
	generateTableConfig: function(cmp, tableData) {
		var MAX_ITEMS_PER_PAGE = 10;
		var label = cmp.get('v.label');
		var that = this;

		return {
			columns: [
				{
					field: "Id",
					title: "Actions",
					formatter: function(value, row, index) {
						return '<a href="javascript:void(0);" data-id="' + row.Id + '">Add</a>';
					}
				},
				{
					field: "Name",
					title: label
				}
			],
			data: tableData,
			toggle: "table",
			search: tableData.length > MAX_ITEMS_PER_PAGE,
			pagination: tableData.length > MAX_ITEMS_PER_PAGE,
			pageSize: MAX_ITEMS_PER_PAGE,
			pageList: [10, 25, 50],
			onClickCell: function(field, value, row, $element) {
				if (field === 'Id') {
					$A.run(function() {
						that.fireBrandSelected(row);
					});
				}
			}
		};
	},
	setTableData: function(cmp, tableData) {
		if (!cmp.isValid()) {
			return;
		}

		var that = this;
		var $contentTable = $('#' + cmp.get('v.tableId'));
		if ($contentTable && tableData) {
			var u = {}, _tableData = [];
			for(var i = 0, l = tableData.length; i < l; ++i) {
				if(u.hasOwnProperty(tableData[i].Id)) {
					continue;
				}
				_tableData.push(tableData[i]);
				u[tableData[i].Id] = 1;
			}
			u = {};

			$contentTable.bootstrapTable(that.generateTableConfig(cmp, _tableData));
		}
	}
})