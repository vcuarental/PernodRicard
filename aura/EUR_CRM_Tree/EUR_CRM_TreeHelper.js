({
    setup: function (cmp) {
		// Validate config & set default values
		var config = cmp.get("v.config");
        if ($A.util.isUndefinedOrNull(config.labelProperties)) {
            config.labelProperties = ['LevelName'];
        }
        if ($A.util.isUndefinedOrNull(config.itemIdentifier)) {
            config.itemIdentifier = 'Id';
        }
        if ($A.util.isUndefinedOrNull(config.sapCode)) {
            config.sapCode = 'ProductCodeSAP';
        }
        if ($A.util.isUndefinedOrNull(config.nationalCode)) {
            config.nationalCode = 'NationalCode';
        }
        if ($A.util.isUndefinedOrNull(config.eanCode)) {
            config.eanCode = 'EAN';
        }
        if ($A.util.isUndefinedOrNull(config.checked)) {
            config.checked = 'checked';
        }
        if ($A.util.isUndefinedOrNull(config.collapsed)) {
            config.collapsed = 'collapsed';
        }
        if ($A.util.isUndefinedOrNull(config.expandProperties)) {
            config.expandProperties = [];
        }
        if ($A.util.isUndefinedOrNull(config.expandLevel)) {
            config.expandLevel = 1;
        }
        if ($A.util.isUndefinedOrNull(config.isSelectable)) {
            config.isSelectable = false;
        }
        if ($A.util.isUndefinedOrNull(config.isNodeSelectionEnabled)) {
            config.isNodeSelectionEnabled = false;
        }
        cmp.set("v.config", config);
    },

    setDroppedProductsHandler: function(component, params) {
        if(params) {
            var availableCategories = params.availableCategories;
            console.log('availableCategories', availableCategories);
            var treeItemsCmpList = component.find('treeItemCmp');
            if(treeItemsCmpList) {
                [].concat(treeItemsCmpList).forEach(function(treeItemCmp) {
                    treeItemCmp.setDroppedProducts(availableCategories);
                });
            }
        }
    },

    onSelectAllProductChbxSelectHandler: function (component, event) {
        const isChecked = event.getSource().get('v.checked');
        component.set('v.isSelectAllProductChbxSelected', isChecked)

        let items = component.get('v.items');
        items = this.checkAll(items, isChecked);

        component.set('v.items', []);
        component.set('v.items', items);

        items.forEach(item => this.setParentCheckedHandler(component, item, 1));
    },

    checkAll: function (items, value) {
        items.forEach(item => {
            item.checked = value;
            if (item.SubLevels) {
                this.checkAll(item.SubLevels, value);
            }
        });
        return items;
    },

    itemSelectionEventHandler: function (component, event) {
        const eventData = JSON.parse(JSON.stringify(event.getParam('eventData')));
        const level = event.getParam('level');

        let items = component.get('v.items');
        this.setChecked(items, eventData, level);

        const isAllChecked = this.isAllChecked(items);
        component.set('v.isSelectAllProductChbxSelected', isAllChecked);
    },

    setChecked: function (items, eventData, level) {
        const sobjectId = eventData.itemIdentifier;

        let isUpdated = false;
        if (items) {
            let item = items.find(item => item.Id === sobjectId);
            if (item) {
                item.checked = eventData.checked;
                isUpdated = true;
            } else {
                items.forEach(item => {
                    isUpdated = this.setChecked(item.SubLevels, eventData, level);
                    if (isUpdated) {
                        item.checked = eventData.checked;
                    }
                });
            }
        }
        return isUpdated;
    },

    isAllChecked: function (items) {
        let isAllChecked = true;
        items.forEach(item => {
            if (isAllChecked) {
                if ( ! item.checked) {
                    isAllChecked = item.checked;
                } else {
                    if (item.SubLevels) {
                        isAllChecked = this.isAllChecked(item.SubLevels);
                    }
                }
            }
        });
        return isAllChecked;
    },

    setParentCheckedHandler: function(cmp, item, level) {
        console.log('setParentCheckedHandler()');
        console.log('item => ', item);
        var itemSelectionEvent = cmp.getEvent('itemSelectionEventFromTree');
        itemSelectionEvent.setParams({
            eventData: item,
            level: level
        });
        itemSelectionEvent.fire();
    },
})