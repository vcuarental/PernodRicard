({
    setup: function (cmp) {
		// Validate config & set default values
		var config = cmp.get("v.config");
        if ($A.util.isUndefinedOrNull(config.labelProperties)) {
            config.labelProperties = ['LevelName'];
        }
        if ($A.util.isUndefinedOrNull(config.checked)) {
            config.collapsed = 'collapsed';
        }
        if ($A.util.isUndefinedOrNull(config.expandProperties)) {
            config.expandProperties = [];
        }
        if ($A.util.isUndefinedOrNull(config.expandLevel)) {
            config.expandLevel = 1;
        }
        cmp.set("v.config", config);
        // Get hierarchy depth for current view
        var
            hierarchyDepth = cmp.get("v.hierarchyDepth"),
            hierarchyDepths = cmp.get("v.hierarchyDepths"),
            viewName = cmp.get("v.viewName"),
            items = cmp.get("v.items"),
            viewItems = cmp.get("v.viewItems");

        if (hierarchyDepths && viewName && hierarchyDepths[viewName]) {
            hierarchyDepth = hierarchyDepths[viewName];
            cmp.set("v.hierarchyDepth", hierarchyDepth);
        }

        if (items && viewName && items[viewName]) {
            viewItems = items[viewName];
            cmp.set("v.viewItems", viewItems);
            cmp.set('v.updatedViewItems', viewItems);
        }
    },

    updateHierarchyEventHandler: function(cmp, event, helper) {
        var
            viewName = cmp.get("v.viewName"),
            updatedViewItems = cmp.get("v.updatedViewItems"),
            branchIndex = event.getParam("branchIndex"),
            hierarchy = event.getParam("hierarchy"),
            eventBranch = event.getParam("branch"),
            eventViewName = event.getParam("viewName"),
            source = event.getParam("source"),
            increaseIndexes = event.getParam("increaseIndexes");

        if(source != 'viewBuilderItemCmp') return;

        console.log('eventViewName', eventViewName);
        if(viewName == eventViewName && eventBranch && branchIndex) {
            console.log('branchIndex', branchIndex);
            console.log('eventBranch', eventBranch);
            var indexes = branchIndex.split('-');
            var branch = updatedViewItems[parseInt(indexes[1])];
            for(let i = 2; i < indexes.length; i++) {
                branch = branch.SubLevels[parseInt(indexes[i])];
            }
            branch.LevelName = eventBranch.LevelName;
            branch.SubLevels = eventBranch.SubLevels;
            branch.collapsed = eventBranch.collapsed;
            cmp.set('v.updatedViewItems', updatedViewItems);
            helper.hierarchyChangeEventHandler(cmp, viewName, updatedViewItems, false, branchIndex, increaseIndexes);
        } else if(viewName == eventViewName && hierarchy) {
            console.log('hierarchy', hierarchy);
            updatedViewItems = hierarchy;
            cmp.set('v.updatedViewItems', updatedViewItems);
            helper.hierarchyChangeEventHandler(cmp, viewName, updatedViewItems, true);
        }
    },

    changeCategoryEventHandler: function(cmp, event) {
        var
            helper = this,
            isCreate = event.getParam("isCreate"),
            isDrop = event.getParam("isDrop"),
            viewName = event.getParam("viewName"),
           //droppedItems = cmp.get('v.droppedItems');
            level = event.getParam("level"),
            //currentDepth = event.getParam("currentDepth"),
            branchIndex = event.getParam("branchIndex"),
            sourceBranchIndex = event.getParam("sourceBranchIndex"),
            productsDropEvent = cmp.getEvent("productsDropEvent"),
            items = JSON.parse(JSON.stringify(cmp.get('v.updatedViewItems')));

        if(viewName != cmp.get('v.viewName')) return;
        var indexes = branchIndex.split('-');
        var branch = items;
       
        if(indexes.length > 2) {
            for(let i = 1; i < indexes.length - 1; i++) {
                if(i == 1) {
                    branch = branch[parseInt(indexes[i])];
                } else {
                    branch = branch.SubLevels[parseInt(indexes[i])];
                }
            }
            branch = branch.SubLevels;
        }
        if(isCreate) {
            branch.push({
                LevelName: '',
                SubLevels: [],
                collapsed: false,
            });
            cmp.set('v.viewItems', items);
            cmp.set('v.updatedViewItems', items);
            helper.hierarchyChangeEventHandler(cmp, viewName, items, true);
        } else if(!isDrop) {
            if(branch.length > 1 || level != 1) {
                branch.splice(indexes[indexes.length-1], 1);
                
                productsDropEvent.setParams({
                    eventView: viewName,
                    action: 'categoryDelete',
                    branchIndex: branchIndex
                });
                productsDropEvent.fire();
                cmp.set('v.viewItems', items);
                cmp.set('v.updatedViewItems', items);
                helper.hierarchyChangeEventHandler(cmp, viewName, items, true);

            } else {
                var alertMessageEvent = cmp.getEvent("alertMessageEvent");
                alertMessageEvent.setParams({
                    isError: true,
                    message: $A.get("$Label.c.EUR_CRM_CG_RemoveBranchError")
                });
                alertMessageEvent.fire();
            }
        } else if(isDrop) {
            var indexesCurrent = branchIndex.split('-');
            var indexesData = sourceBranchIndex.split('-');

            if(indexesData.length == 2) {
                var buff = items[parseInt(indexesData[1])];
                items.splice(indexesData[1], 1);
                items.splice(indexesCurrent[1], 0, buff);
            } else {
                var dataBranch = items[parseInt(indexesData[1])];
                for(let i = 2; i < indexesCurrent.length - 1; i++) {
                     dataBranch = dataBranch.SubLevels[parseInt(indexesData[i])];
                }
                var buff = dataBranch.SubLevels[parseInt(indexesData[indexesData.length - 1])];
                dataBranch.SubLevels.splice(indexesData[indexesData.length - 1], 1);
                dataBranch.SubLevels.splice(indexesCurrent[indexesCurrent.length - 1], 0, buff);
            }
            cmp.set('v.viewItems', items);
            cmp.set('v.updatedViewItems', items);
            helper.hierarchyChangeEventHandler(cmp, viewName, items, true, branchIndex, false, isDrop, sourceBranchIndex);
        }
        
    },

    hierarchyChangeEventHandler: function(cmp, viewName, items, hierarchyChanged, branchIndex, increaseIndexes, isDrop, sourceBranchIndex) {
        var hierarchyChangeEvent = cmp.getEvent("hierarchyChangeEvent");
        hierarchyChangeEvent.setParams({
            source: 'viewBuilderCmp',
            viewName: viewName,
            hierarchy: items,
            branchIndex: branchIndex,
            sourceBranchIndex: sourceBranchIndex,
            isDrop: isDrop,
            hierarchyChanged: hierarchyChanged,
            increaseIndexes: increaseIndexes
        });
        hierarchyChangeEvent.fire();
    },

    setCategoriesHandler: function(cmp, params) {
    	if (!params) return;
        var viewName = cmp.get("v.viewName");
        
        // set hierarchy depth
        var hierarchyDepths = params.hierarchyDepths;
        if(hierarchyDepths && hierarchyDepths[viewName]) cmp.set("v.hierarchyDepth", hierarchyDepths[viewName]);
        //set categories
        var categories = params.categories;
        if(categories && categories[viewName]) {
            cmp.set("v.viewItems", categories[viewName]);
            cmp.set('v.updatedViewItems', categories[viewName]);
        }
        // set droppedItems
        var droppedItems = params.droppedItems;
        var updatedIndexes = params.updatedIndexes;
        if(droppedItems) {
            var viewItemsCmpList = [];
            viewItemsCmpList = viewItemsCmpList.concat(cmp.find('viewItemsBuilderCmp'));
            viewItemsCmpList.forEach(function(viewItemBuilder) {
                var branchIndex = viewItemBuilder.get('v.branchIndex');
                var toUpdate = false;
                if(!updatedIndexes || !updatedIndexes.length) {
                    toUpdate = true;
                } else {
                    updatedIndexes.forEach(function(index) {
                        if(index == branchIndex || index.startsWith(branchIndex)) {
                            toUpdate = true;
                        }
                    });
                }
                if(toUpdate) {
                    var itemsToSet = [];
                    droppedItems.forEach(function(item) {
                        if(item.branchIndex == branchIndex || (item.branchIndex.startsWith(branchIndex) && item.branchIndex.charAt(branchIndex.length) == '-')) {
                            // additional check to make sure that this is correct level and avoid situations
                            // like branch-1 is branch-11
                            itemsToSet.push(item);
                        }
                    });
                    viewItemBuilder.setDroppedItems(itemsToSet);
                }
            });
        }
    }
})